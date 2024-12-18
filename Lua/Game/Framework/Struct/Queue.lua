Queue = {}
Queue.__index = Queue

function Queue:New()
    local o = {tab = {}, tail = 0, head = 1}
    setmetatable(o, self)
    return o
end

function Queue:Enqueue(value)
    local index = self.tail + 1
    self.tail = index
    self.tab[index] = value
end

function Queue:Dequeue()
    if self.head > self.tail then
        return nil
    else
        local value = self.tab[self.head]
        self.tab[self.head] = nil
        self.head = self.head + 1
        return value
    end
end

function Queue:Peek()
    if self.head > self.tail then
        return nil
    else
        return self.tab[self.head]
    end
end

function Queue:Count()
    return self.tail - self.head + 1
end

function Queue:Clear()
    self.tab = {}
    self.tail = 0
    self.head = 1
end
