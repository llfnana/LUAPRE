---@class StoryBookHandleEvents
StoryBookHandleEvents = {}
StoryBookHandleEvents.__cname = "StoryBookHandleEvents"
local this = StoryBookHandleEvents

function StoryBookHandleEvents.Init()
    EventManager.AddListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)
    EventManager.AddListener(EventType.TASK_COMPLETE, this.TaskCompleteFunc)
    EventManager.AddListener(EventType.TASK_MILESTONE_REFRESH, this.TaskMilestoneCompleteFunc)
    EventManager.AddListener(EventType.CITY_NIGHT_CHANGE, this.CityClockNightFunc)
end 

function StoryBookHandleEvents.Clear()
    EventManager.RemoveListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)
    EventManager.RemoveListener(EventType.TASK_COMPLETE, this.TaskCompleteFunc)
    EventManager.RemoveListener(EventType.TASK_MILESTONE_REFRESH, this.TaskMilestoneCompleteFunc)
    EventManager.RemoveListener(EventType.CITY_NIGHT_CHANGE, this.CityClockNightFunc)
end

--升级建筑触发
function StoryBookHandleEvents.UpgradeZoneFunc(cityId, zoneId, zoneType, level)
    local runtimeData = {
        cityId = cityId,
        zoneId = zoneId,
        zoneType = zoneType,
        level = level,
    }
    StoryBookManager.TryTrigger(EnumTriggerType.BuildComplete, runtimeData)
end

--Task完成触发
function StoryBookHandleEvents.TaskCompleteFunc(cityId, taskId)
    local runtimeData = {
        cityId = cityId,
        taskId = taskId,
    }
    StoryBookManager.TryTrigger(EnumTriggerType.TaskComplete, runtimeData)
end

--Milestone完成触发
function StoryBookHandleEvents.TaskMilestoneCompleteFunc(cityId, mileStoneConfig)
    if mileStoneConfig == nil then
        return
    end
    local runtimeData = {
        cityId = cityId,
        mileStoneId = mileStoneConfig.id,
    }
    StoryBookManager.TryTrigger(EnumTriggerType.MileStoneComplete, runtimeData)
end

--战斗开始触发
function StoryBookHandleEvents.BattleToBeginTrigger(cityId, callBack)
    local runtimeData = {
        cityId = cityId,
        callBack = callBack,
    }
    StoryBookManager.TryTrigger(EnumTriggerType.BattleToBegin, runtimeData)
end

--战斗结束触发
function StoryBookHandleEvents.BattleToEndTrigger(cityId, callBack)
    local runtimeData = {
        cityId = cityId,
        callBack = callBack,
    }
    StoryBookManager.TryTrigger(EnumTriggerType.BattleToEnd, runtimeData)
end

--卡牌详情界面触发
function StoryBookHandleEvents.CardViewEnterTrigger(cityId, cardId)
    local runtimeData = {
        cityId = cityId,
        cardId = cardId,
    }
    StoryBookManager.TryTrigger(EnumTriggerType.CardViewEnter, runtimeData)
end

--时间触发
function StoryBookHandleEvents.CityClockNightFunc(cityId)
    local runtimeData = {
        cityId = cityId,
    }
    StoryBookManager.TryTrigger(EnumTriggerType.CityClockNight, runtimeData)
end