local function metaType(obj)
    if getmetatable(obj) == nil then
        return type(obj)
    else 
        return getmetatable(obj)._type or type(obj)
    end
end

local TYPE = {
    ENUM = "enum",
    HASH = "hash",
    ARRAY = "array",
    NUMBER = "number",
    BOOLEAN = "boolean",
    STRING = "string"
}

local function toTrace(obj)
    local meta = getmetatable(obj)
    if meta and meta._toTrace then
        return meta._toTrace(obj)
    else
        return tostring(obj)
    end
end

local function getAddress(obj)
    local meta = getmetatable(obj)
    if meta and meta._address then
        return tostring(meta._address)
    else
        if meta == nil or meta.__tostring == nil then
            return string.sub(tostring(obj), 8, -1)
        else
            return ""
        end
    end
end

local function toTraceFormat(obj, name, ...)
    local out = "[" .. name .. "(" .. getAddress(obj) .. ")"
    for i, v in ipairs({ ... }) do
        out = out .. "," .. v .. "=" .. toTrace(obj[v])
    end
    out = out .. "]"
    return out
end

local function instanceToTrace(self)
    return toTraceFormat(self, self.classname)
end

local function classToTrace(self)
    return toTraceFormat(self, "ZeroClass", "classname")
end

local function defineToTrace(obj, ...)
    local meta = getmetatable(obj)
    if meta == nil then
        meta = {}
    end
    meta._address = getAddress(obj)
    local args = { ... }
    meta._toTrace = function(o)
        return toTraceFormat(obj, unpack(args))
    end
    setmetatable(obj, meta)
end

local function getAddress(obj)
    local meta = getmetatable(obj)
    if meta and meta._address then
        return tostring(meta._address)
    else
        if meta == nil or meta.__tostring == nil then
            return string.sub(tostring(obj), 8, -1)
        else
            return ""
        end
    end
end

-- enum--------------------------------------------------------------------------------------------- enum

local Enum = {}
function Enum.__tostring(obj)
    return obj.enumKey .. "." .. obj.value
end
function Enum:new(enumKey, ...)
    local pool = {}
    if enumKey ~= nil then
        if Enum[enumKey] ~= nil then
            print("重定义枚举" .. enumKey)
        end
        Enum[enumKey] = pool
    end
    for i, v in ipairs({ ... }) do
        local obj = { enumKey = enumKey, parent = pool, index = i, value = v }
        setmetatable(obj, { _address = getAddress(obj), _type = "enum", __tostring = Enum.__tostring });
        defineToTrace(obj, "Enum", "enumKey", "index", "value")
        pool[v] = obj
        pool[i] = obj
    end
    return pool
end

-- 有序table--------------------------------------------------------------------------------------------- Pool
local Pool = {}
function Pool:new()
    local pool = {}
    setmetatable(pool, { _date = {}, __index = Pool });
    return pool
end

function Pool:get(key)
    local meta = getmetatable(self)
    return meta._date[key]
end

function Pool:add(key, val)
    local meta = getmetatable(self)
    if meta._date[key] == nil then
        table.insert(self, key)
    end
    meta._date[key] = val or key
end

function Pool:del(key)
    local meta = getmetatable(self)
    if meta._date[key] ~= nil then
        local find = false
        for k, v in ipairs(self) do
            if v ~= key then
                find = true;
            end
            if find then
                self[k] = self[k + 1]
            end
        end
    end
end

local function traceError(val, depath)
    print(debug.traceback(val, depath))
end

local function indexFn(obj, key)
    local proxy = getmetatable(obj)._proxy
    return proxy[key]
end

local function removeItemFn(obj, key)
    local proxy = getmetatable(obj)._proxy
    obj:change(key)
    proxy[key] = nil
end

local function newindexFn(obj, key, value)

    local meta = getmetatable(obj)
    local childType = metaType(value)
    if childType == TYPE.Array then
        traceError("array对象无法重置，请使用返原 revert", 3)
    elseif childType == TYPE.HASH then
        traceError("hash对象无法重置，请使用返原 revert", 3)
    elseif meta._childTypes[key] == nil then
        traceError("对象属性 " .. key .. " 没有被初始化")
    elseif meta._childTypes[key] == childType then
        meta._proxy[key] = value
        obj:change(key)
    elseif meta._childTypes[key] == TYPE.ENUM and childType == TYPE.STRING then
        local newValue = meta._proxy[key].parent[value]
        if newValue ~= nil then
            meta._proxy[key] = newValue
            obj:change(key)
        else
            traceError("枚举超出", meta._proxy[key].parent.key, "\"" .. value .. "\"")
        end
    elseif meta._childTypes[key] == TYPE.ENUM and childType == TYPE.NUMBER then
        local newValue = meta._proxy[key].parent[value]
        if newValue ~= nil then
            meta._proxy[key] = newValue
            obj:change(key)
        else
            traceError("枚举超出", meta._proxy[key].parent.key, value)
        end
    elseif meta._childTypes[key] == TYPE.NUMBER and childType == TYPE.STRING then
        meta._proxy[key] = tonumber(value)
        obj:change(key)
    elseif meta._childTypes[key] == TYPE.NUMBER and childType == TYPE.BOOLEAN then
        if value then
            meta._proxy[key] = 1
        else
            meta._proxy[key] = 0
        end
        obj:change(key)
    elseif meta._childTypes[key] == TYPE.STRING and childType == TYPE.NUMBER then
        meta._proxy[key] = tostring(value)
        obj:change(key)
    elseif meta._childTypes[key] == TYPE.STRING and childType == TYPE.BOOLEAN then
        if value then
            meta._proxy[key] = "true"
        else
            meta._proxy[key] = "false"
        end
        obj:change(key)
    elseif meta._childTypes[key] == TYPE.BOOLEAN and childType == TYPE.STRING then
        meta._proxy[key] = (value == "true")
        obj:change(key)
    elseif meta._childTypes[key] == TYPE.BOOLEAN and childType == TYPE.NUMBER then
        meta._proxy[key] = (value ~= 0)
        obj:change(key)
    else
        traceError("类型不匹配, " .. key .. " 需要 " .. meta._childTypes[key] .. " 当前为 " .. childType, 3)
    end
end

local function newindexArrayFn(obj, key, value)
    local meta = getmetatable(obj)
    local childType = metaType(value)
    if key > meta._size + 1 then
        traceError("无法添加", 3)
    elseif key == meta._size + 1 then
        addFn(obj)
        meta._proxy[key] = value
    else
        if meta._childType == TYPE.ARRAY or meta._childType == TYPE.HASH then
            traceError("数组子项为对象类型不支持直接修改", 3)
        elseif meta._childType == childType then
            if meta._proxy[key] ~= value then
                -- meta._oldProxy[key] = meta._proxy[key]
                meta._proxy[key] = value
                obj:change(key)
            end
        else
            traceError("数组对象类型不正确", 3)
        end
    end
end

local function initSet(obj, key, value)
    if metaType(obj) == TYPE.HASH then
        local meta = getmetatable(obj)
        local childType = metaType(value)
        meta._proxy[key] = value
        meta._initValues[key] = value
        meta._childTypes[key] = childType
        if childType == TYPE.HASH or childType == TYPE.ARRAY then
            local childMeta = getmetatable(value)
            childMeta._parent = obj
            childMeta._key = key
        end
    elseif metaType(obj) == TYPE.ARRAY then
    else
        traceError("obj不是hash类型")
    end
end

local function changeFn(obj, key)
    local upType = NetModule.SCUpType
    local meta = getmetatable(obj)

    meta["_changePool_"..upType][key] = true
    if meta._parent ~= nil and meta._key ~= nil then
        meta._parent:change(meta._key)
    end
    
    if metaType(meta._parent) == TYPE.ARRAY then
        local parentMeta = getmetatable(meta._parent)
        if parentMeta._indexKeyPool[key] ~= nil then
            if obj[key] == nil then
                traceError("找不到索引字段:" .. key);
            else
                parentMeta._indexPool[key .. "_" .. obj[key]] = obj:getKey()
            end
        end
    end
end

local function revertFn(obj, loop)
    local meta = getmetatable(obj)
    for k, v in pairs(meta._proxy) do
        if (meta._childTypes[k] == TYPE.HASH or meta._childTypes[k] == TYPE.ARRAY) then
            if loop then
                obj[k]:revert(loop)
            end
        else
            if meta._initValues[k] == nil then
                obj[k] = meta._initValue
            else
                obj[k] = meta._initValues[k]
            end
        end
    end
end

local function revertArrayFn(obj, loop)
    local meta = getmetatable(obj)
    for i, v in ipairs(meta._proxy) do
        obj:change(i)
    end
    meta._size = 0
    meta._proxy = {}
end

local function addEventFn(obj, key, callBack)
    if obj[key] == nil then
        traceError(key .. "不存在这个属性", 3)
    else
        local meta = getmetatable(obj)
        if meta._eventPool[key] == nil then
            meta._eventPool[key] = Pool:new()
        end
        meta._eventPool[key]:add(callBack)
    end
end

local function addEventUpdateFn(obj, key, callBack)
    if obj[key] == nil then
        traceError(key .. "不存在这个属性", 3)
    else
        local meta = getmetatable(obj)
        if meta._upEeventPool[key] == nil then
            meta._upEeventPool[key] = Pool:new()
        end
        meta._upEeventPool[key]:add(callBack)
    end
end

local function addEventDeleteFn(obj, key, callBack)
    if obj[key] == nil then
        traceError(key .. "不存在这个属性", 3)
    else
        local meta = getmetatable(obj)
        if meta._delEventPool[key] == nil then
            meta._delEventPool[key] = Pool:new()
        end
        meta._delEventPool[key]:add(callBack)
    end
end

local function addEventArrayFn(obj, callBack)
    if callBack == nil then
        traceError("callback不能为空", 3)
    end
    local meta = getmetatable(obj)
    meta._eventPool:add(callBack)
end

local function removeEventFn(obj, key, callBack)
    local meta = getmetatable(obj)
    if meta._eventPool[key] ~= nil then
        meta._eventPool[key]:del(callBack)
    end
    if meta._eventPool[key] ~= nil then
        meta._delEventPool[key]:del(callBack)
    end
    if meta._eventPool[key] ~= nil then
        meta._upEeventPool[key]:del(callBack)
    end
end

local function removeEventArrayFn(obj, callBack)
    local meta = getmetatable(obj)
    meta._eventPool:del(callBack)
    meta._delEventPool:del(callBack)
    meta._upEeventPool:del(callBack)
end

local function clearEventFn(obj, key)
    local meta = getmetatable(obj)
    if meta._eventPool[key] ~= nil then
        meta._eventPool[key] = nil
    end
end

local function clearEventArrayFn(obj)
    local meta = getmetatable(obj)
    meta._eventPool = {}
end

local callEvent
local callEventArray

-- callEvent2 = function(obj)
--     local meta = getmetatable(obj)
--     for k, v in pairs(meta._changePool) do
--         if v == true then
--             if meta._eventPool[k] ~= nil then
--                 for i, callback in ipairs(meta._eventPool[k]) do
--                     callback(obj, k)
--                 end
--             end
--             if obj[k] ~= nil then
--                 if meta._childTypes[k] == TYPE.HASH then
--                     callEvent(obj[k])
--                 elseif meta._childTypes[k] == TYPE.ARRAY then
--                     callEventArray(obj[k])
--                 end
--             end
--         end
--     end
--     meta._changePool = {}
-- end

callEvent = function(obj, type, infos, requestData)
    local meta = getmetatable(obj)

    local _changePool = meta["_changePool_"..type]

    local metaEventPool = {}
    if type == "a" then
        metaEventPool = meta._eventPool
    elseif type == "d" then
        metaEventPool = meta._delEventPool
    elseif type == "u" then
        metaEventPool = meta._upEeventPool
    end
    for k, v in pairs(_changePool) do 
        if v == true then
            if metaEventPool[k] ~= nil then
                for i, callback in ipairs(metaEventPool[k]) do
                    if type == "a" then
                        callback(obj[k]:soul(), requestData)
                    else
                        local paths = {}
                        local nodeMeta = getmetatable(obj)
                        table.insert(paths, k)
                        while(nodeMeta._parent ~= nil and nodeMeta._key ~= nil) do
                            table.insert(paths, nodeMeta._key)
                            nodeMeta = getmetatable(nodeMeta._parent)   
                        end
                        local cInfos = clone(infos)
                        for i = #paths, 1, -1 do
                            cInfos = cInfos[paths[i]]
                        end
                        callback(cInfos, requestData)
                    end
                end
            end
            if obj[k] ~= nil then
                if meta._childTypes[k] == TYPE.HASH then
                    callEvent(obj[k], type, infos, requestData)
                elseif meta._childTypes[k] == TYPE.ARRAY then
                    callEventArray(obj[k], type, infos, requestData)
                end
            end
        end
    end
    meta["_changePool_"..type] = {}
end
callEventArray = function(obj, type, infos, requestData)
    local meta = getmetatable(obj)

    local _changePool = meta["_changePool_"..type]

    local metaEventPool = {}
    if type == "a" then
        metaEventPool = meta._eventPool
    elseif type == "d" then
        metaEventPool = meta._delEventPool
    elseif type == "u" then
        metaEventPool = meta._upEeventPool
    end
    for k, v in pairs(_changePool) do
        if v == true then
            for i, callback in ipairs(metaEventPool) do
                if type == "a" then
                    callback(obj[k]:soul(), requestData)
                else
                    local paths = {}
                    local nodeMeta = getmetatable(obj)
                    table.insert(paths, k)
                    while(nodeMeta._parent ~= nil and nodeMeta._key ~= nil) do
                        table.insert(paths, nodeMeta._key)
                        nodeMeta = getmetatable(nodeMeta._parent)   
                    end
                    local cInfos = clone(infos)
                    for i = #paths, 1, -1 do
                        cInfos = cInfos[paths[i]]
                    end
                    callback(cInfos, requestData)
                end
            end
            if obj[k] ~= nil then
                if meta._childType == TYPE.HASH then
                    callEvent(obj[k], type, infos, requestData)
                elseif meta._childType == TYPE.ARRAY then
                    callEventArray(obj[k], type, infos, requestData)
                end
            end
        end
    end
    meta["_changePool_"..type] = {}
end

local function flushFn(obj, callList, infos, requestData)
    if callList["a"] then callEvent(obj, "a", nil, requestData) end
    if callList["d"] then callEvent(obj, "d", infos["d"], requestData) end
    if callList["u"] then callEvent(obj, "u", infos["u"], requestData) end
end

local function flushArrayFn(obj)
    callEventArray(obj)
end

local function getKeyHd(obj)
    local meta = getmetatable(obj)
    return meta._key
end

local function pairsFn(obj)
    local meta = getmetatable(obj)
    return pairs(meta._proxy)
end

local function ipairsFn(obj)
    local meta = getmetatable(obj)
    return ipairs(meta._proxy)
end

local function cloneFn(obj, parent, key)
    local meta = getmetatable(obj)
    local newTable = {}
    for k, v in pairs(obj) do
        newTable[k] = v
    end
    local newMeta = {}
    for k, v in pairs(meta) do
        newMeta[k] = v
    end
    newMeta._proxy = {}
    -- newMeta._oldProxy = {}
    newMeta._indexPool = {}
    newMeta._parent = parent
    newMeta._key = key
    newMeta._changePool = {}
    newMeta._eventPool = {}
    for k, v in pairs(meta._proxy) do
        if type(v) == "table" and v.clone ~= nil then
            newMeta._proxy[k] = v:clone(newTable, k)
        else
            newMeta._proxy[k] = v
        end
    end
    if meta._indexPool ~= nil then
        for k, v in pairs(meta._indexPool) do
            newMeta._indexPool[k] = v
        end
    end
    setmetatable(newTable, newMeta)
    return newTable
end

local function addFn(obj)
    local meta = getmetatable(obj)
    local size = meta._size + 1
    meta._size = size
    local item
    if meta._childType == TYPE.HASH or meta._childType == TYPE.ARRAY then
        item = meta._initValue:clone(obj, size)
    else
        item = meta._initValue --todo
    end
    meta._proxy[size] = item
    obj:change(size)
    return item
end

local function getByFn(obj, key, index)
    local meta = getmetatable(obj)
    return meta._proxy[meta._indexPool[key .. "_" .. index]]
end

local function soulFn(obj)
    local out = {}
    if metaType(obj) == TYPE.HASH then
        for k, v in obj:pairs() do
            out[k] = soulFn(v)
        end
    elseif metaType(obj) == TYPE.ARRAY then
        for k, v in obj:ipairs() do
            out[k] = soulFn(v)
        end
    elseif metaType(obj) == TYPE.NUME then
        out = obj.index
    else
        out = obj
    end
    return out
end

-- local function getOldFn(obj, key)
--     local meta = getmetatable(obj)
--     return meta._oldProxy[key]
-- end

--缺少 删除指定项的功能！
local function removeFn(obj)
    if meta._size > 0 then
        local meta = getmetatable(obj)
        local size = meta._size - 1
        meta._size = size
        meta._proxy[size] = nil
        obj:change(size)
    end
end

local function makeDataTable(obj, ...)
    obj.revert = revertFn
    obj.change = changeFn
    obj.addEvent = addEventFn
    obj.addEventUpdate = addEventUpdateFn
    obj.addEventDelete = addEventDeleteFn
    obj.removeEvent = removeEventFn
    obj.clearEvent = clearEventFn
    obj.flush = flushFn
    obj.pairs = pairsFn
    obj.ipairs = ipairsFn
    obj.clone = cloneFn
    obj.getKey = getKeyHd
    obj.soul = soulFn
    obj.removeItem = removeItemFn
    -- obj.getOld = getOldFn
    -- setmetatable(obj, { _childTypes = {}, _proxy = {}, _oldProxy = {}, _initValues = {}, _path = {}, _eventPool = {}, _changePool = {}, _type = TYPE.HASH, __index = indexFn, __newindex = newindexFn })
    setmetatable(obj, { _childTypes = {}, _proxy = {}, _initValues = {}, _path = {}, _eventPool = {}, _delEventPool = {}, _upEeventPool = {}, _changePool_a = {}, _changePool_d = {}, _changePool_u = {}, _type = TYPE.HASH, __index = indexFn, __newindex = newindexFn })
    return obj
end

local function makeDataArray(initValue, ...)
    if initValue == nil then
        traceError("数组的初始化不能为空")
    end
    local obj = {}
    obj.add = addFn
    obj.remove = removeFn
    obj.revert = revertArrayFn
    obj.change = changeFn
    obj.addEvent = addEventArrayFn
    obj.removeEvent = removeEventArrayFn
    obj.clearEvent = clearEventArrayFn
    obj.flush = flushArrayFn
    obj.pairs = pairsFn
    obj.ipairs = ipairsFn
    obj.clone = cloneFn
    obj.getKey = getKeyHd
    obj.soul = soulFn
    obj.getBy = getByFn
    obj.removeItem = removeItemFn
    local indexKeyPool = {}
    for i, v in ipairs({ ... }) do
        indexKeyPool[v] = true
    end
    -- setmetatable(obj, { _size = 0, _childType = metaType(initValue), _proxy = {}, _indexKeyPool = indexKeyPool, _indexPool = {}, _oldProxy = {}, _initValue = initValue, _path = {}, _eventPool = Pool:new(), _changePool = {}, _type = TYPE.ARRAY, __index = indexFn, __newindex = newindexArrayFn })
    setmetatable(obj, { _size = 0, _childType = metaType(initValue), _proxy = {}, _indexKeyPool = indexKeyPool, _indexPool = {}, _initValue = initValue, _path = {}, _eventPool = Pool:new(), _upEeventPool = {}, _delEventPool = {}, _changePool_a = {}, _changePool_d = {}, _changePool_u = {}, _type = TYPE.ARRAY, __index = indexFn, __newindex = newindexArrayFn })
    return obj
end

local function indexLiteFn(obj, key)
    local proxy = getmetatable(obj)._proxy
    if proxy[key] ~= nil then
        rawset(obj, key, proxy[key])
    end
    return proxy[key]
end

local function newindexLiteFn(obj, key, value)
    local proxy = getmetatable(obj)._proxy
    if proxy[key] ~= nil then
        rawset(obj, key, value)
    end
end

local function makeLiteArray()
    local obj = {}
    setmetatable(obj, { _proxy = {}, __index = indexLiteFn, __newindex = newindexLiteFn })
    return obj
end

local function makeLiteTable(obj)
    setmetatable(obj, { _proxy = {}, __index = indexLiteFn, __newindex = newindexLiteFn })
    return obj
end

local function initLiteSet(obj, key, value)
    local meta = getmetatable(obj)
    meta._proxy[key] = value
end

local zeroData = {}

zeroData.Enum = Enum
zeroData.Pool = Pool
zeroData.makeLiteTable = makeLiteTable
zeroData.initLiteSet = initLiteSet
zeroData.makeLiteArray = makeLiteArray
zeroData.makeDataArray = makeDataArray
zeroData.makeDataTable = makeDataTable
zeroData.initSet = initSet
zeroData.metaType = metaType
zeroData.TYPE = TYPE
return zeroData