--是否是函数
function IsFunction(func)
    return type(func) == "function"
end

function IsTable(tbl)
    return type(tbl) == "table"
end

--是否是空对象
function IsObjectNullOrEmpty(obj)
    local ret = true
    if obj ~= nil then
        for key, value in pairs(obj) do
            ret = false
            break
        end
    end
    return ret
end

---打印table
local key = ""
function PrintTable(table, level)
    level = level or 1
    local indent = ""
    for i = 1, level do
        indent = indent .. "  "
    end

    if key ~= "" then
        print("[error]" .. indent .. key .. " " .. "=" .. " " .. "{")
    else
        print("[error]" .. indent .. "{")
    end

    key = ""
    for k, v in pairs(table) do
        if type(v) == "table" then
            key = k
            PrintTable(v, level + 1)
        else
            local content = string.format("%s%s = %s", indent .. "  ", tostring(k), tostring(v))
            print("[error]" .. content)
        end
    end
    print("[error]" .. indent .. "}")
end

--克隆
function Clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--检测可用
local function CheckInvalid(tbl, k, v)
    if IsFunction(tbl[k]) then
        if Mono.IsProtectedFunc(k) then
            error(string.format("不能创建与Mono基类同名方法或变量 : %s", k))
        end
    elseif Mono[k] then
        error(string.format("不能创建与Mono基类同名变量 : %s", k))
    else
        rawset(tbl, k, v)
    end
end

--继承mono
function ClassMono(classname, tbl)
    local base = tbl or {}
    local isMobilePlatform = Application.isMobilePlatform
    if not isMobilePlatform then
        for k, v in pairs(tbl) do
            CheckInvalid(tbl, k, v)
        end
    end

    local father = Clone(Mono)
    local cls = Clone(base)
    cls.super = father
    cls.__cname = classname

    local meta = {
        __gc = function(self)
            print("destroying self: " .. self.name)
            if cls.OnGC then
                cls:OnGC()
            end
        end
    }

    if isMobilePlatform then
        setmetatable(cls, {__index = father, __gc = meta})
    else
        setmetatable(cls, {__index = father, __newindex = CheckInvalid, __gc = meta})
    end

    return cls
end

-- --继承
-- function ClassMore(base)
--     base = base or {}
--     local father = Clone(base)
--     local cls = {}
--     cls.base = father
--     return Clone(cls)
-- end

-- 字符串分割 parseFunc:单个值解析方法,默认nil
function string.split(input, delimiter, parseFunc)
    local func = nil
    if IsFunction(parseFunc) then
        func = parseFunc
    end
    input = tostring(input)
    delimiter = tostring(delimiter)
    if delimiter == "" then
        return false
    end
    local pos, arr = 0, {}
    local tmp, value
    -- for each divider found
    for st, sp in function()
        return string.find(input, delimiter, pos, true)
    end do
        tmp = string.sub(input, pos, st - 1)
        if func then
            value = func(tmp)
            if value == nil then
                value = tmp
            end
        else
            value = tmp
        end
        table.insert(arr, value)
        pos = sp + 1
    end
    tmp = string.sub(input, pos)
    if func then
        value = func(tmp)
        if value == nil then
            value = tmp
        end
    else
        value = tmp
    end
    table.insert(arr, value)
    return arr
end

local GetWorldPosByIDtempRetX
local GetWorldPosByIDtempRetY
local GetWorldPosByIDtempRetZ
function GetWorldPosByID(targetEntityID)
    GetWorldPosByIDtempRetX, GetWorldPosByIDtempRetY, GetWorldPosByIDtempRetZ =
        CS.FrozenCity.SpriteAPI.GetWorldPos(targetEntityID, nil, nil, nil)
    return luaVector3.New(GetWorldPosByIDtempRetX, GetWorldPosByIDtempRetY, GetWorldPosByIDtempRetZ)
end

function GetheroScaleByID(targetEntityID)
    local scalex, scaley, scalez = CS.FrozenCity.SpriteAPI.GetBindHeroScale(targetEntityID, nil, nil, nil)
    return luaVector3.New(scalex, scaley, scalez)
end

function GetLang(key, ...)
    -- return Localization.Get(key)
    return Language.language(key, ...)
end

function GetLangFormat(key, ...)
    -- return Localization.GetFormat(key, ...)
    return Language.language(key, ...)
end

function LangKeyExist(key) 
    -- return Localization.KeyExist(key)
    return key
end

function printtable(tbl, level, filteDefault)
    local msg = ""
    filteDefault = filteDefault or true --默认过滤关键字（DeleteMe, _class_type）
    level = level or 1
    local indent_str = ""
    for i = 1, level do
        indent_str = indent_str .. "  "
    end

    print(indent_str .. "{")
    for k, v in pairs(tbl) do
        if filteDefault then
            if k ~= "_class_type" and k ~= "DeleteMe" then
                local item_str = string.format("%s%s = %s", indent_str .. " ", tostring(k), tostring(v))
                print(item_str)
                if type(v) == "table" then
                    printtable(v, level + 1)
                end
            end
        else
            local item_str = string.format("%s%s = %s", indent_str .. " ", tostring(k), tostring(v))
            print(item_str)
            if type(v) == "table" then
                printtable(v, level + 1)
            end
        end
    end
    print(indent_str .. "}")
end
