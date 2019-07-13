BinaryHeap = {}
BinaryHeap.__index = BinaryHeap

--[[
    This implementation will be used for A*,
    although it can be used for other purposes

    A* will use {id (being the tile id), weight (being the fcost)}
    then the id will be used to index in to various
    other tables containing the data which belongs to the tiles
    like x & y position, g and h cost
]]

--[[
    min-heap implementation:

    parent is at: child_index / 2
    left child is at: 2 * parent_index
    right child is at: 2 * parent_index + 1
]]

function BinaryHeap:new()
    bh = {}

    bh.heap = {}
    bh.size = 0

    setmetatable(bh, self)
    return bh
end

function BinaryHeap:get_heap()
    return self.heap
end

function BinaryHeap:sort_up(i)
    local parent = math.floor(i / 2)
    if parent > 0 then
        if self.heap[i].weight < self.heap[parent].weight then
            local temp = self.heap[i]
            self.heap[i] = self.heap[parent]
            self.heap[parent] = temp
            return self:sort_up(parent)
        end
    end
    return nil
end

function BinaryHeap:sort_down(i)
    local child_l = 2 * i
    local child_r = 2 * i + 1
    local temp = self.heap[i]

    if self.heap[child_l] and self.heap[i].weight > self.heap[child_l].weight then
		if self.heap[child_r] and self.heap[child_r].weight < self.heap[child_l].weight then
        	self.heap[i] = self.heap[child_r]
			self.heap[child_r] = temp
            return self:sort_down(child_r)
        end

		self.heap[i] = self.heap[child_l]
		self.heap[child_l] = temp
		return self:sort_down(child_l)
    end
    return nil
end

function BinaryHeap:insert(weight, data)
    self.size = self.size + 1

    table.insert(self.heap, {
                            data = data,
                            weight = weight })
    if #self.heap < 1 then
        return data
    end

    self:sort_up(self.size)
    return data
end

function BinaryHeap:pop()
    local temp = self.heap[1]
    self.heap[1] = self.heap[self.size]
    self.heap[self.size] = temp
    table.remove(self.heap, self.size)
    self:sort_down(1)
	self.size = self.size - 1
    return temp.data
end

function BinaryHeap:is_empty()
    if #self.heap < 1 then
        return true
    end
    return false
end

--[[
    Builing a heap assumes that the heap is empty!
    Meaning that it will destroy an existing heap!
]]
function BinaryHeap:build_heap(list)
    self.heap = list
    self.size = #list

    for i = math.floor(self.size / 2), 1, -1 do
        self:sort_down(i)
    end
end


-- a function that prints the heap in its array format
function BinaryHeap:print_heap()
    local map = ""
    for i, v in ipairs(self.heap) do
        map = map .. v.weight .. "|"
    end

    io.write(map,"\n")
end

return BinaryHeap