---@class CitySchedules
CitySchedules = Clone(CityBase)
CitySchedules.__cname = "CitySchedules"

--处理日程配置
function CitySchedules:InitConfigs()
    self.schedulesConfigs = List:New()
    --生成游戏中使用的日程配置
    local function GenerateSchedulesConfig(cfg, startTime, endTime)
        local professionLimit = {}
        for k, v in pairs(cfg.people_limit) do
            professionLimit[v] = true
        end
        local schedulesCfg = Clone(cfg)
        schedulesCfg.startTime = startTime
        schedulesCfg.endTime = endTime
        schedulesCfg.professionLimit = professionLimit
        --日程获取图片
        schedulesCfg.GetSprite = function()
            return Utils.GetCommonIcon(schedulesCfg.type)
        end
        --日程设置图片
        schedulesCfg.SetSprite = function(imageComp)
            Utils.SetCommonIcon(imageComp, schedulesCfg.type)
        end
        --日程职业是否匹配
        schedulesCfg.IsMatchProfession = function(type)
            return schedulesCfg.professionLimit[ProfessionType.None] or schedulesCfg.professionLimit[type]
        end
        --判断时钟时间里日程是否可以运行
        schedulesCfg.IsMatchClock = function(clockTime)
            if clockTime >= schedulesCfg.startTime and clockTime < schedulesCfg.endTime then
                return true
            end
            return false
        end
        --获取日程执行进度
        schedulesCfg.GetSchedulesProgress = function(clockTime)
            local startH, startM = math.modf(schedulesCfg.startTime / 100)
            startM = Mathf.RoundToInt(startM * 100)
            local currH, currM = math.modf(clockTime / 100)
            currM = Mathf.RoundToInt(currM * 100)
            local endH, endM = math.modf(schedulesCfg.endTime / 100)
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
        schedulesCfg.GetIsFirstTime = function(clockTime)
            local startH, startM = math.modf(schedulesCfg.startTime / 100)
            local currH, currM = math.modf(clockTime / 100)
            return startH == currH
        end
        return schedulesCfg
    end
    --处理每一条日程配置数据
    local function DealSchedulesConfig(cfg)
        local timesArray = string.split(cfg.schedule_times, ",")
        for i = 1, #timesArray do
            local times = string.split(timesArray[i], "|", tonumber)
            if #times == 2 then
                self.schedulesConfigs:Add(GenerateSchedulesConfig(cfg, times[1], times[2]))
            end
        end
    end
    --根据城市id遍历日程配置
    for id, cfg in pairs(ConfigManager.GetSchedulesByCityId(self.cityId)) do
        DealSchedulesConfig(cfg)
    end
    --按照开始时间排序
    local function SortFunc(v1, v2)
        return v1.startTime < v2.startTime
    end
    self.schedulesConfigs:Sort(SortFunc)
    --设置日程索引
    for i = 1, self.schedulesConfigs:Count(), 1 do
        self.schedulesConfigs[i].schedulesIndex = i
    end
end

--初始化
function CitySchedules:OnInit()
    self.currSchedules = {}
    self:InitConfigs()
    self.isLockSchedulesSubscribe =
        TestManager.GetTest(self.cityId).isLockSchedules:subscribe(
        function(val)
            if val then
                self:RefreshSchedulesByTest(TestManager.GetTest(self.cityId).lockSchedules.value)
            else
                self:RefreshSchedules()
            end
        end
    )
end

--清理
function CitySchedules:OnClear()
    self.isLockSchedulesSubscribe:unsubscribe()
    self.currSchedules = nil
    self = nil
end

---------------------------------
---方法
---------------------------------
--刷新日程
function CitySchedules:RefreshSchedules()
    if TestManager.GetTest(self.cityId).isLockSchedules.value then
        return
    end
    self:RefreshSchedulesByClock(TimeManager.GetCityClock(self.cityId))
end

--根据时钟时间刷新日程
function CitySchedules:RefreshSchedulesByClock(clockTime)
    local newSchedules = self:GetSchedulesByClockTime(clockTime)
    --根据新的日程，从当前日程中筛选需要移除的类型
    local removeSchedules = {}
    for key, value in pairs(self.currSchedules) do
        if not newSchedules[key] then
            removeSchedules[key] = value
        end
    end
    --执行移除操作
    for key, value in pairs(removeSchedules) do
        self:RemoveSchedules(key, value)
    end
    --从新日程中，将未添加的日程添加进来
    for key, value in pairs(newSchedules) do
        self:AddSchedules(key, value)
    end
end

--根据测试面板刷新日程
function CitySchedules:RefreshSchedulesByTest(type)
    local schedulesCfg = nil
    for id, cfg in pairs(ConfigManager.GetSchedulesByCityId(self.cityId)) do
        if cfg.type == type then
            schedulesCfg = cfg
        end
    end
    if not schedulesCfg then
        return
    end
    local timesArray = string.split(schedulesCfg.schedule_times, ",")
    local times = string.split(timesArray[1], "|", tonumber)
    local clockTime = times[1] + 1
    self:RefreshSchedulesByClock(clockTime)
end

--添加日程
function CitySchedules:AddSchedules(schedulesType, schedules)
    if self.currSchedules[schedulesType] then
        return
    end
    self.currSchedules[schedulesType] = schedules
    EventManager.Brocast(EventType.SCHEDULES_ADD, self.cityId, schedules)
end

--移除日程
function CitySchedules:RemoveSchedules(schedulesType, schedules)
    if not self.currSchedules[schedulesType] then
        return
    end
    self.currSchedules[schedulesType] = nil
    EventManager.Brocast(EventType.SCHEDULES_REMOVE, self.cityId, schedules)
end

--获取日常安排配置
function CitySchedules:GetSchedulesByClockTime(clockTime)
    local schedules = {}
    self.schedulesConfigs:ForEach(
        function(config)
            if config.IsMatchClock(clockTime) then
                schedules[config.type] = config
            end
        end
    )
    return schedules
end

--获取界面显示日程列表
function CitySchedules:GetSchedulesConfigsByMenu()
    local schedulesCfgs = List:New()
    self.schedulesConfigs:ForEach(
        function(config)
            if config.visible_on_menu then
                schedulesCfgs:Add(config)
            end
        end
    )
    return schedulesCfgs
end

--根据类型获取日程
function CitySchedules:GetShcedulesConfig(type)
    for i = 1, self.schedulesConfigs:Count(), 1 do
        if self.schedulesConfigs[i].type == type then
            return self.schedulesConfigs[i]
        end
    end
    return nil
end

--获取当前日程列表
function CitySchedules:GetCurrentSchedules()
    local schedulesList = List:New()
    for schedulesType, schedules in pairs(self.currSchedules) do
        schedulesList:Add(schedules)
    end
    schedulesList:Sort(
        function(s1, s2)
            return s1.schedule_priority < s2.schedule_priority
        end
    )
    return schedulesList
end

--判断是否在指定日程中
function CitySchedules:IsSchdulesActive(type)
    if self.currSchedules[type] then
        return true
    end
    return false
end

--根据类型获取有效的日程
function CitySchedules:GetActiveSchedules(type)
    return self.currSchedules[type]
end

--获取有效日程的索引
function CitySchedules:GetNextSchedulesInfo(type)
    local schedulesCfgs = List:New()
    self.schedulesConfigs:ForEach(
        function(config)
            if config.type == type then
                schedulesCfgs:Add(config)
            end
        end
    )
    local nextSchedulesInfo = {}
    local cityDay = TimeManager.GetCityDay(self.cityId)
    if schedulesCfgs:Count() == 1 then
        nextSchedulesInfo.cityDay = cityDay + 1
        nextSchedulesInfo.schedulesIndex = schedulesCfgs[1].schedulesIndex
    else
        local nextSchedules = nil
        local currSchedules = self:GetCurrentSchedulesByMenu()
        if currSchedules.type == type then
            schedulesCfgs:ForEach(
                function(config)
                    if config.schedulesIndex ~= currSchedules.schedulesIndex then
                        nextSchedules = config
                        return true
                    end
                end
            )
        else
            local maxInterval = 0
            schedulesCfgs:ForEach(
                function(config)
                    local tempInterval = math.abs(config.schedulesIndex - currSchedules.schedulesIndex)
                    if tempInterval > maxInterval then
                        maxInterval = tempInterval
                        nextSchedules = config
                    end
                end
            )
        end
        if nextSchedules.schedulesIndex > currSchedules.schedulesIndex then
            nextSchedulesInfo.cityDay = cityDay
        else
            nextSchedulesInfo.cityDay = cityDay + 1
        end
        nextSchedulesInfo.schedulesIndex = nextSchedules.schedulesIndex
    end
    return nextSchedulesInfo
end

--获取界面显示日程配置
function CitySchedules:GetCurrentSchedulesByMenu()
    for key, value in pairs(self.currSchedules) do
        if value.visible_on_menu then
            return value
        end
    end
    return nil
end

--根据类型获取有效的日程进度
function CitySchedules:GetSchedulesSpeedUp(type)
    local ret = 0
    local schedules = self:GetActiveSchedules(type)
    if schedules then
        local progress = schedules.GetSchedulesProgress(TimeManager.GetCityClock(self.cityId))
        local index = 0
        for i = 1, #schedules.run_open do
            if progress >= schedules.run_open[i] then
                index = i
            end
        end
        if index > 0 then
            ret = ret + schedules.run_speed[index]
        end
    end
    return ret
end

--获取日程进度
function CitySchedules:GetSchedulesProgress(type)
    local schedules = self:GetActiveSchedules(type)
    if schedules then
        return schedules.GetSchedulesProgress(TimeManager.GetCityClock(self.cityId))
    end
    return 0
end
