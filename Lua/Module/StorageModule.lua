------------------------------------------------------------------------
--- @desc 存储模块
--- @author chenyl
------------------------------------------------------------------------

--region -------------引入模块-------------
--endregion

--region -------------私有变量-------------
local fn = {}

local Enum = {
    SETTING = 1,
    HOME_BUILDING = 2,
    HOME_DATA = 3, --家园数据
    LOGIN_MEMORY = 4,
    FIGHT_LINEUP = 5, --战斗阵容（站位->tid）
    WORLD_BOSS = 6, --世界boss
    GM = 7, --GM
    FIGHT_DATA = 8, --战斗数据
    AD = 10, --广告数据
    CHARACTER_NAMAGER = 11, -- 角色管理
} --枚举

local SaveType = {
    REPLACE = 1,
    ADD = 2,
} --数据保存类型

local SaveMode = {
    CLIENT = 1,
    SERVER = 2,
} --存储模式

local DataType = {
    STRING = 1,
    NUMBER = 2,
    TABLE = 3,
} --数据类型

local cache = {} ---内容缓存
local expandSuffix ---拓展后缀，用来区分唯一性

local wxStorage = nil
--endregion

--region -------------默认参数-------------
local module = {}

module.enum = Enum
--endregion

--region -------------导出函数-------------

function module.init()
    makergetFn(Sc(), "loginMod"):addEvent("loginAccount", fn.s2cLoginAccount)

    --module.reset(module.enum.HOME_BUILDING)
    --module.reset(module.enum.LOGIN_MEMORY)
end

function module.release()
end

---获取配置内容
---@param tid number
---@param default any 默认值
function module.get(tid, default)
    return fn.get(tid, default)
end

---设置配置
---@param tid number
---@param value number|string|table
function module.set(tid, value)
    local cfg = TbStorage[tid]
    local key = fn.getKey(cfg)

    if cfg.Mode == SaveMode.CLIENT then --客户端
        fn.setClientData(key, cfg.Type, value)
    elseif cfg.Mode == SaveMode.SERVER then --服务端
        -- todo 服务端
    end
    cache[key] = value
end

---重置配置
function module.reset(tid, default)
    local cfg = TbStorage[tid]
    if not cfg then
        error("StorageTable不存在")
        return
    end

    module.set(tid, fn.getDefault(cfg.Type, default))
end

--endregion

--region -------------私有函数-------------

---@param vo SvrLoginAccountVo
function fn.s2cLoginAccount(vo)
    local svrId = NetModule.getServerId() --服务器ID
    expandSuffix = svrId .. '_' .. vo.uid
end

---获取最终存储的key值
function fn.getKey(cfg)
    local key = cfg.Key
    --不共享数据，带后缀
    if not cfg.Share then
        if expandSuffix == nil then
            error(key .. '共享配置，但后缀expandSuffix未赋值，只能在登录之后获取')
        else
            key = key .. "_" .. expandSuffix
        end
    end
    --Log.info('获取最终存储Key：', key, cfg.share)
    return key
end

---获取数据
function fn.get(tid, default)
    local cfg = TbStorage[tid]
    local key = fn.getKey(cfg)
    if cache[key] ~= nil then
        return cache[key]
    end

    local value
    if cfg.Mode == SaveMode.CLIENT then --客户端
        value = fn.getClientData(key, cfg.Type, default)
    elseif cfg.Mode == SaveMode.SERVER then --服务端
        -- todo 服务端
    end

    cache[key] = value --缓存

    return value
end

---获取客户端存储数据
---@param key string
---@param type number 数据类型
---@param default any
function fn.getClientData(key, type, default)
    local data
    if BaseConfig.IsMiniSdkEnable then
        if wxStorage == nil then
            local storageStr = Core.Instance:WxStorageReadSync()
            wxStorage = ListUtil.deserialize(storageStr) or {}
        end
        data = wxStorage[key]
    else
        data = PlayerPrefs.GetString(key)
    end
    if StringUtil.isEmpty(data) then
        return fn.getDefault(type, default)
    end

    if type == DataType.NUMBER then
        return tonumber(data)
    elseif type == DataType.STRING then
        return data
    elseif type == DataType.TABLE then
        --return json.decode(data)
        return ListUtil.deserialize(data)
    end
end

---设置客户端存储数据
---@param key string
---@param type number 数据类型
---@param value number|string|table
function fn.setClientData(key, type, value)
    local data
    --根据类型判断数据转换
    if type == DataType.NUMBER then
        data = tostring(value)
    elseif type == DataType.STRING then
        data = value
    elseif type == DataType.TABLE then
        --data = json.encode(value)
        data = ListUtil.serialize(value)
    else
        error("客户端不存在这个类型,去表中改改:key=" .. key)
        return
    end

    if BaseConfig.IsMiniSdkEnable then
        if wxStorage == nil then
            local storageStr = Core.Instance:WxStorageReadSync()
            wxStorage = ListUtil.deserialize(storageStr) or {}
        end
        wxStorage[key] = data
        local storageStr = ListUtil.serialize(wxStorage)
        Core.Instance:WxStorageWriteAsync(storageStr)
    else
        PlayerPrefs.SetString(key, data) --保存值
    end
end

---获取默认值
function fn.getDefault(type, default)
    if default ~= nil then
        return default
    end

    if type == DataType.NUMBER then
        return 0
    elseif type == DataType.STRING then
        return StringUtil.EMPTY
    elseif type == DataType.TABLE then
        return {}
    end
end

--endregion

return module