WorkOverTimeManager = {}
WorkOverTimeManager.__cname = "WorkOverTimeManager"

local this = WorkOverTimeManager

--初始化
function WorkOverTimeManager.Init()
    this.cityId = DataManager.GetCityId()
    if not this.workOverTimeItems then
        this.workOverTimeItems = Dictionary:New()
    end
    if not this.workOverTimeItems:ContainsKey(this.cityId) then
        this.workOverTimeItems:Add(this.cityId, CityWorkOverTime:New(this.cityId))
        if this.workOverTimeItems:Count() == 1 then
            -- EventManager.AddListener(EventType.TIME_CITY_PER_HOUR, this.TimeCityPerHourFunc)
            EventManager.AddListener(EventType.FUNCTIONS_OPEN, this.FunctionsOpenFunc)
        end
    end
end

--清理
function WorkOverTimeManager.Clear(force)
    Utils.SwitchSceneClear(this.cityId, this.workOverTimeItems, force)
    if this.workOverTimeItems:Count() == 0 then
        -- EventManager.RemoveListener(EventType.TIME_CITY_PER_HOUR, this.TimeCityPerHourFunc)
        EventManager.RemoveListener(EventType.FUNCTIONS_OPEN, this.FunctionsOpenFunc)
    end
end

--获取加班对象
---@return CityWorkOverTime
function WorkOverTimeManager.GetWorkOverTime(cityId)
    return this.workOverTimeItems[cityId]
end

---------------------------------
---事件响应
---------------------------------
-- --城市时间每小时响应
-- function WorkOverTimeManager.TimeCityPerHourFunc(cityId)
--     this.GetWorkOverTime(cityId):TimeCityPerHourFunc()
-- end

--功能解锁事件响应
function WorkOverTimeManager.FunctionsOpenFunc(cityId, type, isOpen)
    if type ~= FunctionsType.WorkOverTime then
        return
    end
    this.GetWorkOverTime(cityId):SetWorkOverTimeStatus(isOpen)
end

---------------------------------
---方法响应
---------------------------------
--添加加班数据
function WorkOverTimeManager.AddWorkOverTime(cityId, zoneId)
    this.GetWorkOverTime(cityId):AddWorkOverTime(zoneId)
end

--删除加班数据
function WorkOverTimeManager.RemoveWorkOverTime(cityId, zoneId)
    this.GetWorkOverTime(cityId):RemoveWorkOverTime(zoneId)
end

--区域是否可以加班
function WorkOverTimeManager.IsCanWorkOverTimeByZoneType(cityId, zoneType)
    return this.GetWorkOverTime(cityId):IsCanWorkOverTimeByZoneType(zoneType)
end

--区域是否激活加班
function WorkOverTimeManager.IsActiveWorkOverTimeByZoneType(cityId, zoneType)
    return this.GetWorkOverTime(cityId):IsActiveWorkOverTimeByZoneType(zoneType)
end

--是否激活加班数据
function WorkOverTimeManager.IsActiveWorkOverTimeByZoneId(cityId, zoneId)
    return this.GetWorkOverTime(cityId):IsActiveWorkOverTimeByZoneId(zoneId)
end

--获取加班状态
function WorkOverTimeManager.GetWorkOverTimeState(cityId, zoneId)
    return this.GetWorkOverTime(cityId):GetWorkOverTimeState(zoneId)
end

--返回下一个睡觉日程到现在的clock
function WorkOverTimeManager.GetNextOverTimeRemainTime(cityId, isStart)
    return this.GetWorkOverTime(cityId):GetNextOverTimeRemainTime(isStart)
end

function WorkOverTimeManager.IsOpen(cityId)
    return this.GetWorkOverTime(cityId):IsOpen()
end

function WorkOverTimeManager.IsShowButtonInBuild(cityId, zoneId)
    return this.GetWorkOverTime(cityId):IsShowButtonInBuild(zoneId)
end

function WorkOverTimeManager.IsShowButtonInPanel(cityId, zoneId)
    return this.GetWorkOverTime(cityId):IsShowButtonInPanel(zoneId)
end

function WorkOverTimeManager.InRangeWorkOvertime(cityId)
    return this.GetWorkOverTime(cityId):InRangeWorkOverTime()
end

--返回加班的开始和结束时间
function WorkOverTimeManager.GetStartAndEndTime(cityId)
    local otSchedule = SchedulesManager.GetShcedulesConfig(cityId, "Arbeit_OverTime")
    local timeList = {}
    local timesArray = string.split(otSchedule.schedule_times, ",")
    for i = 1, #timesArray do
        local times = string.split(timesArray[i], "|", tonumber)
        if #times ~= 2 then
            print("[error]" .. "invalid to schedule time: " .. otSchedule.schedule_times)
            return ""
        end
        table.insert(timeList, times)
    end
    return timeList[1][1], timeList[#timeList][2]
end

function WorkOverTimeManager.GetTimeProgress(startTime, endTime, clockTime)
    local startH, startM = math.modf(startTime / 100)
    startM = Mathf.RoundToInt(startM * 100)
    local currH, currM = math.modf(clockTime / 100)
    currM = Mathf.RoundToInt(currM * 100)
    local endH, endM = math.modf(endTime / 100)
    endM = Mathf.RoundToInt(endM * 100)
    local pass = (currH - startH) * 60 + (currM - startM)
    local total = (endH - startH) * 60 + (endM - startM)
    local value = pass / total
    if value > 1 then
        value = 1
    end
    if value < 0 then
        value = 0
    end
    return value
end
