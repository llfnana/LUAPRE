------------------------------------------------------------------------
--- @desc 时间模块
--- @author chenyl
------------------------------------------------------------------------

--region -------------引入模块-------------
--endregion

--region -------------数据定义-------------

---@class SvrSystemSysVo
---@field time number 服务器时间（毫秒）
---@field timezone number 时区

---@class TimerData 定时器的参数
---@field delay number 延迟时间
---@field interval number 间隔时间
---@field obj any 回调对象
---@field realTime boolean 是否真实时间（false）

---@class TimerInternalData : TimerData 定时器的内部数据
---@field startTime number 开始时间（用于计算首次偏移，确保精确度）
---@field index number 索引

--endregion

--region -------------私有变量-------------
local module = {}

local fn = {}

local timerDict = nil ---@type table<number, TimerInternalData> 定时器字典
local timerIndex
local removeTimeerDict = nil

local heartInterval = 5 --心跳包间隔
local heartTimer = nil --心跳包定时器

local timezone = nil --时区
local syncServerTime = nil --上次同步服务器时间
local diffTime = 0 --本地与服务器的时间差
--local baseClockTime = os.clock() --base time for measuring elapsed time

local lastDate = nil --上次日期
local triggerMap = nil --准点触发器 hour -> minute -> list<fun(hour, minute)>
local SEC_MILLS = 1000 --每秒多少毫秒
local MIN_SEC = 60 --每分多少秒
local HOUR_MIN = 60 --每小时多少分
local HOUR_SEC = HOUR_MIN * MIN_SEC
local DAY_SEC = 24 * HOUR_SEC
local DAYS_OF_WEEK = 7 --每周天数
--endregion

--region -------------导出函数-------------

function module.init()
    timerIndex = 0
    timerDict = {}
    triggerMap = {}
    removeTimeerDict = {}

    fn.onHeart(os.time()) --默认本地时间
    makergetFn(Sc(), "system"):addEvent("sys", fn.s2cSystem)

    UpdateBeat:Add(fn.update, fn)
end

function module.exit()
    if heartTimer ~= nil then
        fn.removeTimer(heartTimer)
        heartTimer = nil
    end
end

---获取服务器时间
---@param isSec boolean 是否返回秒数（向下取整）
function module.getServerTime(isSec)
    local serverTime = fn.getTimeBase() - diffTime
    return isSec and math.floor(serverTime) or serverTime
end

---获取服务器距离今日小时点的差值（秒），需要考虑当前时区
---@param hour number 小时点
function module.getHourOffset(hour)
    local serverTime = module.getServerTime(true)
    local todaySec = serverTime % TimeUtil.DAY_SEC --今日已过秒数
    todaySec = todaySec + TimeUtil.HOUR_SEC * 8 --转换为北京时间
    local offset = hour * TimeUtil.HOUR_SEC - todaySec
    return offset < 0 and offset + TimeUtil.DAY_SEC or offset
end

---@param delay number 延迟
---@param callback fun 回调
---@param obj any 回调对象
function module.addDelay(delay, callback, obj)
    return module.addRepeat(delay, nil, callback, obj)
end

---按秒重复回调
function module.addRepeatSec(cb, obj)
    return module.addRepeat(0, 1, cb, obj)
end

---添加重复回调
---@param delay number 延迟【可选】
---@param interval number 间隔
---@param cb fun 回调
---@param obj any 回调对象【可选】
function module.addRepeat(delay, interval, cb, obj)
    --注：三个参数时：delay, interval, cb
    if cb == nil then --两个参数时：interval, cb
        cb = interval
        interval = delay
        delay = 0
    end
    return fn.addTimer({
        delay = delay, interval = interval,
        callback = cb, obj = obj,
        realTime = false
    })
end

---@param data TimerData
function module.addTimer(data)
    return fn.addTimer(data)
end

function module.removeTimer(timer)
    fn.removeTimer(timer)
end

---获取定时器下一次执行的时间
function module.getTimerLeft(timer)
    local data = timerDict[timer]
    if data == nil then
        return 0
    end
    return data.delay - (Time.time - data.startTime)
end

---监听小时触发
---@param hour number 小时点
---@param cb fun(h: number) 回调
function module.onHour(hour, cb)
    module.onMinute(hour, 0, cb)
end

---移除小时触发
---@param hour number 小时点
---@param cb fun(h: number) 回调
function module.offHour(hour, cb)
    module.offMinute(hour, 0, cb)
end

function module.format(time, showSec)
    if time < 0 then
        time = 0
    end
    local day = math.floor(time / DAY_SEC)
    local daySec = day * DAY_SEC
    local hour = math.floor((time - daySec) / HOUR_SEC)
    if day >= 1 and not showSec then
        return StringUtil.concat(day, GetLang("UI_general_day"), hour, GetLang("UI_general_hour"))
    end
    local hourSec = hour * HOUR_SEC
    local min = math.floor((time - daySec - hourSec) / MIN_SEC)
    local sec = time % MIN_SEC   
    if day >= 1 and showSec then----超过一天，需要用小时表示
        hour=hour+24
    end
    return string.format("%02d:%02d:%02d", hour, min, sec)
end

---监听分钟触发
---@param hour number 小时点
---@param min number 分钟点
---@param cb fun(h: number, m: number) 回调
function module.onMinute(hour, min, cb)
    local hourMap = triggerMap[hour]
    if hourMap == nil then
        hourMap = {}
        triggerMap[hour] = hourMap
    end

    local minList = hourMap[min]
    if minList == nil then
        minList = {}
        hourMap[min] = minList
    end

    table.insert(minList, cb)
end

---移除分钟触发
---@param hour number 小时点
---@param min number 分钟点
---@param cb fun(h: number, m: number) 回调
function module.offMinute(hour, min, cb)
    local hourMap = triggerMap[hour]
    if hourMap == nil then
        return
    end

    local minList = hourMap[min]
    if minList == nil then
        return
    end

    ListUtil.delete(minList, cb)
end

--endregion

--region -------------私有函数-------------

---@param vo SvrSystemSysVo
function fn.s2cSystem(vo)
    --print('fn.s2cSystem', ListUtil.dump(vo))
    timezone = vo.timezone
    fn.onHeart(TimeUtil.millsToSec(vo.time))

    if heartTimer == nil then
        -- heartTimer = module.addRepeat(heartInterval, heartInterval, fn.doHeart)
    end
end

-- 有报过错 invalid key to 'next'，所以将删除操作从循环里剔除
function fn.update()

    if GameStateData.isGameLogicRunning == false  then
       return
    end
    --local dt = Time.deltaTime
    local time, realTime = Time.time, Time.realtimeSinceStartup

    --遍历字典，更新剩余时间，时间到了就执行函数
    for _, v in pairs(timerDict) do
        if removeTimeerDict[v.index] == nil then 
            local useTime = v.realTime and realTime or time
            --v.delayTime = v.delayTime - dt --self.interval
            if useTime - v.startTime >= v.delay then
            --if v.delayTime <= 0 then
                if v.callback then
                    v.callback(v.obj)
                end

                if v.interval ~= nil then
                    v.delay = v.interval + v.delay
                else --不是间隔调用
                    fn.removeTimer(v.index)
                end
            end
        end
    end

    -- 删除
    for key, value in pairs(removeTimeerDict) do
        timerDict[key] = nil
    end

    removeTimeerDict = {}
    --fn.trigger() --触发每小时、每分钟回调  hanabi delete   os.date 方法会申请内存 update里执行不合理
end

function fn.trigger()
    local now = module.getServerTime(true)
    if lastDate == nil then
        lastDate = os.date("*t", now)
        return
    end

    local nowDate = os.date("*t", now)
    if nowDate.hour ~= lastDate.hour then --跨小时
        fn.triggerHour(lastDate.hour, lastDate.min + 1, nowDate.hour, nowDate.min)
    elseif nowDate.min ~= lastDate.min then --跨分钟
        fn.triggerMinute(nowDate.hour, lastDate.min + 1, nowDate.min)
    end

    lastDate = nowDate
end

---触发小时回调
---@param startHour number 开始小时点
---@param startMin number 开始分钟点
---@param endHour number 结束小时点
---@param endMin number 结束分钟点【可选】
function fn.triggerHour(startHour, startMin, endHour, endMin)
    for h = startHour, endHour do
        if h == startHour then --开始小时
            for m = startMin, 59 do
                fn.triggerMinute(h, m)
            end
        elseif h == endHour then --结束小时
            fn.triggerMinute(h, 0, endMin)
        else --中间小时
            fn.triggerMinute(h, 0, 59)
        end
    end
end

---触发分钟回调
---@param hour number 小时点
---@param startMin number 开始分钟点
---@param endMin number 结束分钟点【可选】
function fn.triggerMinute(hour, startMin, endMin)
    local hourMap = triggerMap[hour]
    if hourMap == nil then
        return
    end

    for m = startMin, endMin or 59 do
        local minList = hourMap[m]
        if minList ~= nil then
            --倒序
            for i = #minList, 1, -1 do
                minList[i](hour, m)
            end
        end
    end
end

---@param data TimerData
function fn.addTimer(data)
    if data.callback == nil then
        return
    end

    if not GameUtil.isFunction(data.callback) then
        error("callback is not function")
        return
    end

    timerIndex = timerIndex + 1

    local internal = data ---@type TimerInternalData
    internal.startTime = data.realTime and Time.realtimeSinceStartup or Time.time
    internal.index = timerIndex

    timerDict[timerIndex] = data

    return timerIndex
end

function fn.removeTimer(timerIndex)
    if timerIndex == nil then
        return
    end

    -- 放入删除列表
    removeTimeerDict[timerIndex] = true
    -- timerDict[timerIndex] = nil
end

function fn.doHeart()
    local vo = NewCs("user")
    vo.info.user.heartbeat.ver = StringUtil.EMPTY
    vo.info.user.heartbeat.label = StringUtil.EMPTY
    vo:send()
end

function fn.onHeart(serverTime)
    syncServerTime = serverTime

    diffTime = fn.getTimeBase() - syncServerTime
end



---获取时间基准
function fn.getTimeBase()
    return Time.realtimeSinceStartup --os.clock()
end

--endregion

return module