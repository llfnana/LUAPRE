DailyShoutManager = {}
DailyShoutManager.__cname = "DailyShoutManager"
local this = DailyShoutManager

---@class DailyShoutData
---@field preCheckTS number
---@field expireTS number

---@class DailyShoutRuntimeData
---@field name string
---@field callback fun(now: Time2)
---@field sort number

DailyShoutManager.Priority = {
    Urgent = 5,
    Normal = 10,
    Slack = 15
}

function DailyShoutManager.Init()
    if this.initialized then
        return
    end

    this.initialized = true
    ---@type table<string, DailyShoutData>
    this.data = DataManager.GetGlobalDataByKey(DataKey.DailyShout) or this.NewData()
    ---@type table<string, DailyShoutRuntimeData>
    this.callbackMap = {}
    this.refreshTimeoutUUID = nil

    this.InitRefresh(Time2:New(GameManager.GameTime()))
end
---@private
---@param now Time2
function DailyShoutManager.InitRefresh(now)
    local remainTS = now:GetToday() + Time2.Day - now:Timestamp()

    if remainTS <= 0 then
        Analytics.Error(
            "TimeError: ",
            {
                today = now:GetToday(),
                now = now:Timestamp()
            }
        )

        print("[error]" .. "invalid remain timestamp")
        return
    end

    this.refreshTimeoutUUID = setTimeout(this.Refresh, remainTS * 1000)
end

function DailyShoutManager.ClearTimeout()
    if this.refreshTimeoutUUID ~= nil then
        clearTimeout(this.refreshTimeoutUUID)
    end
end

function DailyShoutManager.OnAppFocus()
    if this.initialized ~= true then
        return
    end

    this.ClearTimeout()
    this.InitRefresh(Time2:New(GameManager.GameTime()))
    Log("DailyShoutManager OnAppFocus")
end

---@private
function DailyShoutManager.Refresh()
    local now = Time2:New(GameManager.GameTime())
    this.InvokeAll(now)

    this.InitRefresh(now)
end

function DailyShoutManager.NewData()
    return {}
end

function DailyShoutManager.ClearData()
    this.data = this.NewData()
    this.SaveData()
end

function DailyShoutManager.InvokeAll(now)
    ---@type DailyShoutRuntimeData[]
    local line = {}
    for k, v in pairs(this.callbackMap) do
        table.insert(line, v)
    end

    ---@param a DailyShoutRuntimeData
    ---@param b DailyShoutRuntimeData
    table.sort(
        line,
        function(a, b)
            return a.sort < b.sort
        end
    )

    for i = 1, #line do
        this.Invoke(line[i].name, now, false)
    end

    for i = 1, #line do
        if this.IsExpire(line[i].name, now) then
            this.Unregister(line[i].name)
        end
    end
end

---@param name string
---@param callback fun(now: Time2)
---@param expire number     过期时间
---@param initCall boolean  注册后是否调用
---@param priority number   调用优先级，数字越小越先被调用
function DailyShoutManager.Register(name, callback, expire, initCall, priority)
    if this.data[name] ~= nil and this.data[name].expireTS > expire then
        print("[error]" .. 
            "dailyShout expire new < old, name: " ..
                name .. ", new: " .. expire .. ", old: " .. this.data[name].expireTS
        )
        return
    end

    this.callbackMap[name] = {
        name = name,
        sort = priority,
        callback = callback
    }

    local preCheckTS = 0
    local preData = this.data[name]
    if preData ~= nil then
        Log("DailyShoutManager.Register: " .. name .. "preData: " .. JSON.encode(preData))
        preCheckTS = preData.preCheckTS
    end

    this.data[name] = {
        preCheckTS = preCheckTS,
        expireTS = expire
    }

    this.SaveData()

    this.Invoke(name, Time2:New(GameManager.GameTime()), not initCall)
end

function DailyShoutManager.Unregister(name)
    this.callbackMap[name] = nil
    this.data[name] = nil
    this.SaveData()
end

function DailyShoutManager.SaveData()
    DataManager.SetGlobalDataByKey(DataKey.DailyShout, this.data)
end

---@private
---@param name string
---@param now Time2
---@param onlySet boolean 默认false，true时，不调用回调只重制时间
function DailyShoutManager.Invoke(name, now, onlySet)
    local callInfo = this.data[name]
    local rtData = this.callbackMap[name]

    if callInfo == nil or rtData == nil then
        this.Unregister(name)
        return
    end

    Log("DailyShoutManager.Invoke: " .. name .. ", callInfo: " .. JSON.encode(callInfo))

    -- 如果今天已经调用过
    if callInfo.preCheckTS >= now:GetToday() then
        Log("DailyShoutManager.Invoke: " .. name .. ", called in today: " .. callInfo.preCheckTS)
        return
    end
    callInfo.preCheckTS = now:Timestamp()
    this.data[name] = callInfo
    this.SaveData()

    if not onlySet then
        rtData.callback(now)
    end

    Log("DailyShoutManager.Invoke: " .. name .. " onlySet: " .. tostring(onlySet))
end

---检查是否过期
function DailyShoutManager.IsExpire(name, now)
    local callInfo = this.data[name]

    -- 过期时间小于0，表示永远不过期
    if callInfo.expireTS >= 0 and callInfo.expireTS <= now:Timestamp() then
        return true
    end

    return true
end

--切换帐号重置数据
function DailyShoutManager.Reset()
    this.ClearTimeout()
    this.initialized = nil
end
