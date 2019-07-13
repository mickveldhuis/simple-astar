local binheap = require("binheap")

--[[
    start & goal are represented as nodes!

    node = {
        x
        y
        fcost
        gcost
        hcost
        parent
    }

    for instance the start and goal nodes,
    they can be represented as follows:

    start = {
        x = random_x,
        y = random_y,
        fcost = nil,
        gcost = 0,
        hcost = nil,
        parent = nil
    }

    goal = {
        x = random_x,
        y = random_y,
        fcost = nil,
        gcost = nil,
        hcost = 0,
        parent = nil
    }

    map representation:
        > 0 for movable terain
        > 1 for blocked terain

    map = {
        {0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0,0,0,0},
    }

]]

local four_dir = {{0,1}, {0,-1}, {-1,0}, {1,0}}
local eight_dir = {{0,1}, {0,-1}, {1,0}, {-1,0}, {-1,1}, {1,1}, {-1,-1}, {1,-1}}

function calc_h(start, goal)
    return 10*(math.abs(goal.x - start.x) + math.abs( goal.y - start.y ))
end

function astar(start, goal, map)
    assert(map[goal.y][goal.x] == 0, "the goal is set at unwalkable terain")
    open_list = binheap:new()
    local start = start
    start.gcost = 0
    start.hcost = calc_h(start, goal)
    start.fcost = start.gcost + start.hcost
    open_list:insert(0, start)
    closed_list = {}

    while not open_list:is_empty() do
        local current = open_list:get_heap()[1]
        if current.data.x == goal.x and current.data.y == goal.y then
            return get_path(current.data) -- path found
        end
        open_list:pop()
        table.insert(closed_list, current.data)

        local neighbours = get_neighbours(current.data, eight_dir, map)
        for _, n in ipairs(neighbours) do
            if not_in(n, closed_list) then
                n.hcost = calc_h(n, goal)
                n.fcost = n.gcost + n.hcost
                if not_in(n, open_list:get_heap()) then
                    open_list:insert(n.fcost, n)
                else
                    local open_n = get_from(n, open_list:get_heap())
                    if n.gcost < open_n.gcost then
                        open_n.gcost = n.gcost
                        open_n.parent = n.parent
                    end
                end
            end
        end
    end
    return false
end

--[[
    create node basically does what it says.
    x being the x position,
    y the y position,
    f the f cost,
    g the g cost,
    h the h cost,
    parent the parent node
]]
function create_node(x, y, f, g, h, parent)
    assert(x, "x not defined for 'node'")
    assert(y, "y not defined for 'node'")
    node = {
        x = x,
        y = y,
        fcost = f or nil,
        gcost = g or nil,
        hcost = h or nil,
        parent = parent or nil
    }
    return node
end

--[[
    options is a list containing all the possible neighbour positions

    4_possibilities = {{0,1}, {0,-1}, {1,0}, {-1,0}}

    8_possibilities = {
                        {0,1}, {0,-1}, {1,0}, {-1,0},
                        {-1,1}, {1,1}, {-1,-1}, {1,-1}
                      }
]]

function get_neighbours(node, options, map)
    local neighbours = {}

    for _, v in ipairs(options) do
		if node.x + v[1] > 0 and node.x + v[1] <= #map[1] and node.y + v[2] > 0 and node.y + v[2] <= #map then
			if map[node.y + v[2]][node.x + v[1]] == 0 then
                local g_cost = nil
                if (v[1] == 1 and v[2] == 1) or (v[1] == 1 and v[2] == -1) or (v[1] == -1 and v[2] == -1) or (v[1] == -1 and v[2] == 1) then
                    g_cost = node.gcost + 14
                else
                    g_cost = node.gcost + 10
                end
			
                table.insert( neighbours, create_node(node.x + v[1], node.y + v[2], _, g_cost, _, node))
			end
		end
    end

    return neighbours
end

function get_path(node)
    local path = {}
	table.insert(path, node)
    while node.parent do
        node = node.parent
        table.insert(path, node)
    end

    return path
end

function not_in(node, table)
    for _, n in ipairs(table) do
		local n_x = n.x or n.data.x
		local n_y = n.y or n.data.y
        if node.x == n_x and node.y == n_y then
            return false
        end
    end
    return true
end

function get_from(node, table)
    for _, n in ipairs(table) do
		local n_x = n.x or n.data.x
		local n_y = n.y or n.data.y
        if node.x == n_x and node.y == n_y then
            return n.data or n
        end
    end
	return nil
end