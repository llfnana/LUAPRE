TimeManager = {}
TimeManager.__cname = "TimeManager"

local this = TimeManager
this.isInit = false
function TimeManager.Init()
    this.cityId = DataManager.GetCityId()
    if not this.clockItems then
        this.clockItems = Dictionary:New()
    end
    if not this.clockItems:ContainsKey(this.cityId) then
        this.clockItems:Add(this.cityId, CityClock:New(this.cityId))
    end
    this.isInit = true
end

--清理
function TimeManager.Clear(force)
    Utils.SwitchSceneClear(this.cityId, this.clockItems, force)
end

--刷新
function TimeManager.OnUpdate()
    if this.isInit then
        local count = this.clockItems:Count()
        local key
        for i = 1, count do
            key = this.clockItems.keyList[i]
            this.clockItems[key]:OnUpdate()
        end
    end
end

--返回游戏时间
function TimeManager.GameTime()
    return GameManager.GameTime()
end

function TimeManager.GetClock(cityId)
    if this.clockItems ~= nil then
        return this.clockItems[cityId]
    else
        return nil
    end
end

--获取城市天数
function TimeManager.GetCityDay(cityId)
    local clock = this.GetClock(cityId)
    if clock then
        return clock.cityDay
    else
        return -1
    end
end

--获取城市时钟时间
function TimeManager.GetCityClock(cityId)
    local clock = this.GetClock(cityId)
    if clock then
        return clock.cityClock
    else
        return -1
    end
end

--设置城市时间
function TimeManager.SetCityClock(cityId, clockTime)
    local cityClock = this.GetClock(cityId)
    if cityClock then
        return cityClock:SetCityClock(clockTime)
    end
end

--获取城市时钟小时
function TimeManager.GetCityClockHour(cityId)
    local clock = this.GetClock(cityId)
    if clock then
        return clock.hour
    else
        return -1
    end
end

function TimeManager.GetCityOfflineTime(cityId)
    local clock = this.GetClock(cityId)
    if clock then
        return clock.cityOnlineTime
    else
        return this.GameTime()
    end
end

--城市是否是夜晚
function TimeManager.GetCityIsNight(cityId)
    local clock = this.GetClock(cityId)
    if clock then
        return clock.isNight
    else
        return false
    end
end

--修改时间
function TimeManager.RefreshClock(cityId, minute, hour, day)
    this.GetClock(cityId):RefreshClock(minute, hour, day)
end

--返回格式化时间
function TimeManager.GetClockFormat(cityId)
    return this.GetClock(cityId):GetClockFormat()
end

function TimeManager.GetSpecialClockFormat(cityId)
    return this.GetClock(cityId):GetClockSpecailFormat()
end

--获取昼夜交替返回系数
function TimeManager.GetClockDayAndNight(cityId)
    return this.GetClock(cityId):GetClockDayAndNight()
end

--返回昼夜时间 0-1
function TimeManager.GetDayRatio(cityId)
    return this.GetClock(cityId):GetDayRatio()
end