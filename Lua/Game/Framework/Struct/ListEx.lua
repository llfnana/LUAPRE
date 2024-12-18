---@class List
List = {}
List.__index = List

---@return List
function List:New(t)
    local o = { itemType = t }
    setmetatable(o, self)
    return o
end

function List:Add(item)
    table.insert(self, item)
end

function List:AddRange(items)
    local count = #items
    for i = 1, count do
        self:Add(items[i])
    end
end

function List:Clear()
    local count = self:Count()
    for i = count, 1, -1 do
        table.remove(self)
    end
end

function List:Contains(item)
    local count = self:Count()
    for i = 1, count do
        if self[i] == item then
            return true
        end
    end
    return false
end

function List:Count()
    return #self
end

function List:IsEmpty()
    return self:Count() == 0
end

function List:Find(predicate, value)
    -- if (predicate == nil or type(predicate) ~= 'function') then
    --     print('predicate is invalid!')
    --     return
    -- end
    -- local count = self:Count()
    -- for i=1,count do
    --     if predicate(self[i], value) then
    --         return self[i]
    --     end
    -- end
    -- return nil

    local idx = self:FindIndex(predicate, value)
    if idx ~= -1 then
        return self[idx]
    else
        return nil
    end
end

function List:FindIndex(predicate, value)
    if (predicate == nil or type(predicate) ~= "function") then
        print("predicate is invalid!")
        return -1
    end
    local count = self:Count()
    for i = 1, count do
        if predicate(self[i], value) then
            return i
        end
    end
    return -1
end

-- function List:Find(predicate)
--     print('List:Find(predicate)')
--     if (predicate == nil or type(predicate) ~= 'function') then
--         print('predicate is invalid!')
--         return
--     end
--     local count = self:Count()
--     for i=1,count do
--         if predicate(self[i]) then
--             return self[i]
--         end
--     end
--     return nil
-- end

function List:ForEach(action)
    if (action == nil or type(action) ~= "function") then
        print("action is invalid!")
        return
    end
    local count = self:Count()
    for i = 1, count do
        if action(self[i], i) == true then
            break
        end
    end
end

function List:ReverseForEach(action)
    if (action == nil or type(action) ~= "function") then
        print("action is invalid!")
        return
    end
    local count = self:Count()
    for i = count, 1, -1 do
        if action(self[i]) == true then
            break
        end
    end
end

function List:IndexOf(item)
    local count = self:Count()
    for i = 1, count do
        if self[i] == item then
            return i
        end
    end
    return -1
end

function List:pairIndexOf(item)
    for key, value in pairs(self) do
        if value == item then
            return key
        end
    end
    return -1
end

function List:LastIndexOf(item)
    local count = self:Count()
    for i = count, 1, -1 do
        if self[i] == item then
            return i
        end
    end
    return -1
end

--添加一个没有的元素：添加到链表末尾
--self：List
--item：元素
function List:AddNoHave(item)
    local idx = self:LastIndexOf(item)
    if idx > 0 then
        return false
    else
        table.insert(self, item)
        return true
    end
end

function List:Insert(index, item)
    table.insert(self, index, item)
end

function List:ItemType()
    return self.itemType
end

function List:Remove(item)
    local idx = self:LastIndexOf(item)
    if idx > 0 then
        table.remove(self, idx)
        return true
    end
    return false
end

function List:RemoveOne(func)
    for i = 1, self:Count() do
        if func(self[i]) then
            self:RemoveAt(i)
            return
        end
    end
end

function List:RemoveAt(index)
    return table.remove(self, index)
end

function List:Sort(comparison)
    if (comparison ~= nil and type(comparison) ~= "function") then
        print("comparison is invalid")
        return
    end
    table.sort(self, comparison)
end

function List:Reverse()
    local temp = List:New()
    local endCount = self:Count()
    for index = 1, self:Count() do
        temp:Add(self[endCount])
        endCount = endCount - 1
    end
    -- local reverseTable = function(tab)
    --     local tmp = {}
    --     for i = 1, #tab do
    --         tmp[i] = table.remove(tab)
    --     end
    --     return tmp
    -- end
    -- local tab = reverseTable(self)
    -- for i = 1, #tab do
    --     self:Add(tab[i])
    -- end
    return temp
end

function List:Merge(list)
    list:ForEach(
        function(i)
            self:Add(i)
        end
    )
end
