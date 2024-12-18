SchedulesManager = {}
SchedulesManager.__cname = "SchedulesManager"

local this = SchedulesManager

--初始化
function SchedulesManager.Init()
    this.cityId = DataManager.GetCityId()
    if not this.schedulesItems then
        this.schedulesItems = Dictionary:New()
    end
    if not this.schedulesItems:ContainsKey(this.cityId) then
        this.schedulesItems:Add(this.cityId, CitySchedules:New(this.cityId))
        if this.schedulesItems:Count() == 1 then
            EventManager.AddListener(EventType.TIME_CITY_PER_REFRESH, this.RefreshSchedules)
        end
    end
end

--清理
function SchedulesManager.Clear(force)
    Utils.SwitchSceneClear(this.cityId, this.schedulesItems, force)
    if this.schedulesItems:Count() == 0 then
        EventManager.RemoveListener(EventType.TIME_CITY_PER_REFRESH, this.RefreshSchedules)
    end
end

---@return CitySchedules
function SchedulesManager.GetSchedules(cityId)
    return this.schedulesItems[cityId]
end

--刷新日程
function SchedulesManager.RefreshSchedules(cityId)
    this.GetSchedules(cityId):RefreshSchedules()
end

--获取界面显示日程列表
function SchedulesManager.GetSchedulesConfigsByMenu(cityId)
    return this.GetSchedules(cityId):GetSchedulesConfigsByMenu()
end

--根据类型获取日程
function SchedulesManager.GetShcedulesConfig(cityId, type)
    return this.GetSchedules(cityId):GetShcedulesConfig(type)
end

--获取当前日程列表
function SchedulesManager.GetCurrentSchedules(cityId)
    return this.GetSchedules(cityId):GetCurrentSchedules()
end

--判断是否在指定日程中
function SchedulesManager.IsSchdulesActive(cityId, type)
    return this.GetSchedules(cityId):IsSchdulesActive(type)
end

--根据类型获取有效的日程
function SchedulesManager.GetActiveSchedules(cityId, type)
    return this.GetSchedules(cityId):GetActiveSchedules(type)
end

--获取有效日程的索引
function SchedulesManager.GetNextSchedulesInfo(cityId, type)
    return this.GetSchedules(cityId):GetNextSchedulesInfo(type)
end

--获取界面显示日程配置
function SchedulesManager.GetCurrentSchedulesByMenu(cityId)
    return this.GetSchedules(cityId):GetCurrentSchedulesByMenu()
end

--根据类型获取有效的日程进度
function SchedulesManager.GetSchedulesSpeedUp(cityId, type)
    if nil == cityId then
        print("[error]" .. debug.traceback())
    end
    return this.GetSchedules(cityId):GetSchedulesSpeedUp(type)
end

--获取日程进度
function SchedulesManager.GetSchedulesProgress(cityId, type)
    return this.GetSchedules(cityId):GetSchedulesProgress(type)
end
