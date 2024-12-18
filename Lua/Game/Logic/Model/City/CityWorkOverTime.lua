---@class CityWorkOverTime
CityWorkOverTime = Clone(CityBase)
CityWorkOverTime.__cname = "CityWorkOverTime"

function CityWorkOverTime:OnInit()
    self:SetWorkOverTimeStatus(FunctionsManager.IsOpen(self.cityId, FunctionsType.WorkOverTime))
end

function CityWorkOverTime:OnClear()
    self = nil
end

---------------------------------
---事件响应
---------------------------------
--功能解锁事件响应
function CityWorkOverTime:SetWorkOverTimeStatus(isOpen)
    if self.isOpen == isOpen then
        return
    end
    self.isOpen = isOpen
    if self:IsOpen() then
        self:InitWorkOverTime()
    end
end

-- --城市时间每小时响应
-- function CityWorkOverTime:TimeCityPerHourFunc()
--     if not self:IsOpen() then
--         return
--     end
--     self:UpdateWorkOverTime()
-- end

---------------------------------
---方法响应
---------------------------------
---初始化加班
function CityWorkOverTime:InitWorkOverTime()
    self.workOverTimeData = DataManager.GetCityDataByKey(self.cityId, DataKey.WorkOverTimeData)
    if nil == self.workOverTimeData then
        self.workOverTimeData = {}
        DataManager.SetCityDataByKey(self.cityId, DataKey.WorkOverTimeData, self.workOverTimeData)
    end
end

function CityWorkOverTime:IsOpen()
    return (self.isOpen or CityManager.GetIsEventScene(self.cityId))
end

-- --根据游戏时间刷新
-- function CityWorkOverTime:UpdateWorkOverTime()
--     local cityDay = TimeManager.GetCityDay(self.cityId)
--     local cityClock = TimeManager.GetCityClock(self.cityId)
--     local removeZoneIds = List:New()
--     for zoneId, data in pairs(self.workOverTimeData) do
--         if cityDay >= data.endDay and cityClock >= data.endClock then
--             removeZoneIds:Add(zoneId)
--         end
--     end
--     if removeZoneIds:Count() > 0 then
--         removeZoneIds:ForEach(
--             function(zoneId)
--                 self.workOverTimeData[zoneId] = nil
--                 Analytics.Event(
--                     "OverworkEnd",
--                     {
--                         cityId = self.cityId,
--                         zoneId = zoneId,
--                         isAuto = true
--                     }
--                 )
--             end
--         )
--         DataManager.SetCityDataByKey(self.cityId, DataKey.WorkOverTimeData, self.workOverTimeData)
--     end
-- end

--添加加班数据
function CityWorkOverTime:AddWorkOverTime(zoneId)
    if not self.workOverTimeData[zoneId] then
        -- local data = {}
        -- data.endDay = TimeManager.GetCityDay(self.cityId) + 1
        -- data.endClock = self:GetOverTimeEndTime()
        self.workOverTimeData[zoneId] = true
        DataManager.SetCityDataByKey(self.cityId, DataKey.WorkOverTimeData, self.workOverTimeData)
    end
end

--删除加班数据
function CityWorkOverTime:RemoveWorkOverTime(zoneId)
    if self.workOverTimeData[zoneId] then
        self.workOverTimeData[zoneId] = nil
        DataManager.SetCityDataByKey(self.cityId, DataKey.WorkOverTimeData, self.workOverTimeData)
        Analytics.Event(
            "OverworkEnd",
            {
                cityId = self.cityId,
                zoneId = zoneId,
                isAuto = false
            }
        )
    end
end

--返回加班结束时间，必须是0点开始的那个
function CityWorkOverTime:GetOverTimeEndTime()
    local otSchedule = SchedulesManager.GetShcedulesConfig(self.cityId, "Arbeit_OverTime")
    if otSchedule ~= nil then
        local timesArray = string.split(otSchedule.schedule_times, ",")
        for i = 1, #timesArray do
            local times = string.split(timesArray[i], "|", tonumber)
            if #times ~= 2 then
                print("[error]" .. "invalid to schedule time: " .. otSchedule.schedule_times)
                return ""
            end
            if times[1] == 0 then
                return times[2]
            end
        end
    end
    return nil
end

--是否可以加班
function CityWorkOverTime:IsCanWorkOverTimeByZoneType(zoneType)
    if not self:IsOpen() then
        return false
    end
    if nil == self.workOverTimeData then
        return false
    end
    local zoneId = ConfigManager.GetZoneIdByZoneType(self.cityId, zoneType)
    if nil == zoneId then
        return false
    end
    local data = self.workOverTimeData[zoneId]
    if nil == data then
        return false
    end
    -- local cityDay = TimeManager.GetCityDay(self.cityId)
    -- local cityClock = TimeManager.GetCityClock(self.cityId)
    -- if data.endDay == cityDay then
    --     return cityClock <= data.endClock
    -- elseif data.endDay == cityDay + 1 then
    --     return cityClock > data.endClock
    -- else
    --     return false
    -- end
    return true
end

--区域是否激活
function CityWorkOverTime:IsActiveWorkOverTimeByZoneType(zoneType)
    return self:IsActiveWorkOverTimeByZoneId(string.format("C%d_%s_1", self.cityId, zoneType))
end

--是否激活加班数据
function CityWorkOverTime:IsActiveWorkOverTimeByZoneId(zoneId)
    if not self:IsOpen() then
        return false
    end
    if nil == self.workOverTimeData then
        return false
    end
    if not self.workOverTimeData[zoneId] then
        return false
    end
    return true
end

--获取加班状态
function CityWorkOverTime:GetWorkOverTimeState(zoneId)
    if not self:IsOpen() then
        return WorkOvertimeState.None
    end
    if nil == self.workOverTimeData then
        return WorkOvertimeState.None
    end
    if not self.workOverTimeData[zoneId] then
        return WorkOvertimeState.None
    end
    if SchedulesManager.IsSchdulesActive(self.cityId, SchedulesType.Arbeit_OverTime) then
        return WorkOvertimeState.Run
    else
        return WorkOvertimeState.Wait
    end
end

function CityWorkOverTime:GetOverTimeSchedule()
    local otSchedule = SchedulesManager.GetShcedulesConfig(self.cityId, "Arbeit_OverTime")
    local timeList = {}
    local total = 0
    if otSchedule ~= nil then
        local timesArray = string.split(otSchedule.schedule_times, ",")
        for i = 1, #timesArray do
            local times = string.split(timesArray[i], "|", tonumber)
            if #times ~= 2 then
                print("[error]" .. "invalid to schedule time: " .. otSchedule.schedule_times)
                return ""
            end

            times[1] = self:ConvertScheduleClock2Timestamp(times[1])
            times[2] = self:ConvertScheduleClock2Timestamp(times[2])

            total = times[2] - times[1] + total
            table.insert(timeList, times)
        end
    end
    return timeList, total
end

--返回下一个加班日程到现在的的倒计时
--返回rt，rt依赖于当前状态，wait表示距离加班的时间，run表示距离加班结束的时间
function CityWorkOverTime:GetNextOverTimeRemainTime(state)
    -- 解析日程时间
    local timeList, total = self:GetOverTimeSchedule()

    local rt = nil
    local curr = self:ConvertScheduleClock2Timestamp(TimeManager.GetCityClock(self.cityId))
    --加班日程必须是一个挨一个设置，他们必须是连续的
    if state == WorkOvertimeState.Wait then
        --如果当前状态是wait，那就是取start，只要取第一个元素计算当前时间的差
        if timeList[1][1] < curr then
            -- 当加班时间是0点以后开始，就要加上一天的时间在减curr
            rt = timeList[1][1] + 60 * 24 - curr
        else
            rt = timeList[1][1] - curr
        end
    elseif state == WorkOvertimeState.Run then
        --如果当前状态时run，那就是取end，那么要一个一个计算所有时间段的总和
        --首先当前时间必须在时间段内，而且timeList时间是按照时间先后排序的
        local sum = 0
        if #timeList == 2 then
            -- 有跨天
            if timeList[1][1] < curr and timeList[1][2] >= curr then
                --当前时间在0点前
                sum = timeList[1][2] - curr + timeList[2][2] - timeList[2][1]
            elseif timeList[2][1] < curr and timeList[1][2] >= curr then
                sum = timeList[2][2] - curr
            end
        elseif #timeList == 1 then
            sum = timeList[1][2] - curr
        else
            print("[error]" .. "not support > 3 overtime work")
        end

        rt = sum
    else
        print("[error]" .. "invalid state" .. state)
        return ""
    end

    return Utils.GetTimeFormat(rt), total - rt, total, rt
end

function CityWorkOverTime:ConvertScheduleClock2Timestamp(clock)
    local h, m = math.modf(clock / 100)
    m = math.floor(m * 100 + 0.5)
    return h * 60 + m
end

function CityWorkOverTime:IsShowButtonInBuild(zoneId)
    local config = ConfigManager.GetZoneConfigById(zoneId)
    -- 建筑可以加班
    return config.is_work_overtime and self:IsOpen()
end

function CityWorkOverTime:IsShowButtonInPanel(zoneId)
    local config = ConfigManager.GetZoneConfigById(zoneId)
    -- 建筑可以加班
    local hasWorkOverTime = config.is_work_overtime
    -- 加班已开启
    local isOpen = self:IsOpen()
    local inRange = self:InRangeWorkOverTime()
    local state = WorkOverTimeManager.GetWorkOverTimeState(self.cityId, zoneId)
    -- 在加班时间，state是none，那么隐藏
    local inOverTime = not (inRange and state == WorkOvertimeState.None)
    return isOpen and hasWorkOverTime and inOverTime
end

-- 当前时间是否在加班时段内
function CityWorkOverTime:InRangeWorkOverTime()
    local inRange = false
    local now = self:ConvertScheduleClock2Timestamp(TimeManager.GetCityClock(self.cityId))

    local timeList, _ = self:GetOverTimeSchedule()
    for i = 1, #timeList do
        if now >= timeList[i][1] and now <= timeList[i][2] then
            inRange = true
            break
        end
    end

    return inRange
end
