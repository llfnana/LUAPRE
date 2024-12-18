PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

function PriorityQueue:New(comparator)
    local cls = Clone(self)
    cls:Init(comparator)
    return cls
end

function PriorityQueue:Init(comparator)
    self.tail = 0
    self.head = 1
    self.tab = List:New()
    self.comparator = comparator
end

function PriorityQueue:Sort()
    if self.comparator then
        self.tab:Sort(self.comparator)
    end
end

function PriorityQueue:Enqueue(value)
    self.tab:Add(value)
    self:Sort()
    self.tail = self.tab:Count()
end

function PriorityQueue:Dequeue()
    if self.head > self.tail then
        return nil
    else
        local value = self.tab[self.head]
        self.tab:Remove(value)
        return value
    end
end

function PriorityQueue:Peek()
    if self.head > self.tail then
        return nil
    else
        return self.tab[self.head]
    end
end

function PriorityQueue:Count()
    return self.tab:Count()
end

function PriorityQueue:ForEach(action)
    self.tab:ForEach(action)
end

function PriorityQueue:Clear()
    self.tab:Clear()
    self.tail = 0
    self.head = 1
end
