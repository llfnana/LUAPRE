Stack = {}
Stack.__index = Stack
Stack.stack = {}

function Stack:New()
    return setmetatable({}, self)
end

function Stack:Push(element)
    if element == nil then return end
    table.insert(self.stack, element)
end

function Stack:Count()
    return #self.stack
end

function Stack:Clear()
    for i = 1, self:Count() do
        self:Pop()
    end
end

function Stack:Pop()
    local len = self:Count()
    if len == 0 then
        print("空栈")
        return nil
    end
    local value = self.stack[len]
    self.stack[len] = nil
    return value
end

function Stack:Peek()
    local len = self:Count()
    if len == 0 then
        print("空栈")
        return nil
    end
    return self.stack[len]
end

-- function Stack:FindIndex(predicate, value)
--     if (predicate == nil or type(predicate) ~= 'function') then
--         print('predicate is invalid!')
--         return -1
--     end
--     local count = #self.stack
--     for i = 1, count do
--         if predicate(self[i], value) then 
--             return i
--         end
--     end
--     return -1
-- end

function Stack:ForEach(action)
    if (action == nil or type(action) ~= 'function') then
        print('action is invalid!')
        return
    end
    local count = self:Count()
    for i = 1, count do
        if action(self.stack[i]) == true then
            break
        end
    end
end