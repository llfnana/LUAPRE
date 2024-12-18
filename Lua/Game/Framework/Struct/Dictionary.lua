---@class Dictionary
Dictionary = {}
Dictionary.__index = Dictionary

function Dictionary:New(tk, tv)
    local o = {keyType = tk, valueType = tv}
    setmetatable(o, self)
    o.keyList = {}
    return o
end

function Dictionary:Add(key, value)
    if self[key] == nil then
        self[key] = value
        table.insert(self.keyList, key)
    else
        self[key] = value
    end
end

function Dictionary:Clear()
    local count = self:Count()
    for i = count, 1, -1 do
        self[self.keyList[i]] = nil
        table.remove(self.keyList)
    end
end

function Dictionary:ForEachKeyValue(action)
    if (action == nil or type(action) ~= "function") then
        print("Dictionary : action is invalid!")
        return
    end
    local count = self:Count()
    local ret, key
    for i = 1, count do
        key = self.keyList[i]
        ret = action(key, self[key])
        if ret then
            break
        end
    end
    --for i = count, 1, -1 do
    --    key = self.keyList[i]
    --    ret = action(key, self[key])
    --    if ret then break end
    --end
end

function Dictionary:ForEach(action)
    if (action == nil or type(action) ~= "function") then
        print("Dictionary : action is invalid!")
        return
    end
    local count = self:Count()
    for i = count, 1, -1 do
        if action(self[self.keyList[i]]) == true then
            break
        end
    end
end

-- function Dictionary:ForEach(action)
--     if (action == nil or type(action) ~= 'function') then
--         print('Dictionary : action is invalid!')
--         return
--     end
--     local count = self:Count()
--     for i = count, 1, -1 do
--         action(self[self.keyList[i]])
--     end
-- end

function Dictionary:TryGetValue(key)
    local ret = false
    local value = nil
    local count = self:Count()
    for i = 1, count do
        if self.keyList[i] == key then
            ret = true
            value = self[key]
            break
        end
    end
    return ret, value
end

function Dictionary:TryGetValueByIndex(index)
    local ret = false
    local key = nil
    local value = nil
    local count = self:Count()
    if count >= index then
        ret = true
        key = self.keyList[index]
        value = self[key]
    end
    return ret, key, value
end

function Dictionary:ContainsKey(key)
    local count = self:Count()
    for i = 1, count do
        if self.keyList[i] == key then
            return true
        end
    end
    return false
end

function Dictionary:ContainsValue(value)
    local count = self:Count()
    for i = 1, count do
        if self[self.keyList[i]] == value then
            return true
        end
    end
    return false
end

function Dictionary:Count()
    return #self.keyList
end

function Dictionary:IsEmpty()
    return self:Count() == 0
end

function Dictionary:Iter()
    local i = 0
    local n = self:Count()
    return function()
        i = i + 1
        if i <= n then
            return self.keyList[i]
        end
        return nil
    end
end

function Dictionary:Remove(key)
    if self:ContainsKey(key) then
        local count = self:Count()
        for i = 1, count do
            if self.keyList[i] == key then
                table.remove(self.keyList, i)
                break
            end
        end
        self[key] = nil
    end
end

function Dictionary:KeyType()
    return self.keyType
end

function Dictionary:ValueType()
    return self.valueType
end

function Dictionary:Sort(comparison)
    if (comparison ~= nil and type(comparison) ~= "function") then
        print("comparison is invalid")
        return
    end
    table.sort(self.keyList, comparison)
end

function Dictionary:ToTable()
    local rt = {}
    self:ForEachKeyValue(
        function(k, v)
            rt[k] = v
        end
    )
    return rt
end
