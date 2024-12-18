TaskManager = {}
TaskManager.__cname = "TaskManager"

local this = TaskManager

TaskManager.TaskScreenTipsAlignOffset = Vector2(0, 0)

--初始化
function TaskManager.Init()
    this.cityId = DataManager.GetCityId()
    if not this.taskItems then
        this.taskItems = Dictionary:New()
    end
    if not this.taskItems:ContainsKey(this.cityId) then
        this.taskItems:Add(this.cityId, CityTask:New(this.cityId))
        if this.taskItems:Count() == 1 then
            EventManager.AddListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)
            EventManager.AddListener(EventType.UPGRADE_FURNITURE, this.UpgradeFurnitureFunc)
            EventManager.AddListener(EventType.COLLECT_ITEM, this.CollectItemFunc)
            EventManager.AddListener(EventType.USE_ITEM, this.UseItemFunc)
            EventManager.AddListener(EventType.TASK_FINISH, this.TaskFinishFunc)
            EventManager.AddListener(EventType.TASK_COMPLETE, this.TaskCompleteFunc)
            EventManager.AddListener(EventType.TASK_MILESTONE_REFRESH, this.TaskMilestoneCompleteFunc)
            EventManager.AddListener(EventType.CHARACTER_PROFESSION_CHANGE, this.CharacterProfessionChangeFunc)
            EventManager.AddListener(EventType.UPGRADE_CARD_LEVEL, this.UpgradeCardLevelFunc)
            EventManager.AddListener(EventType.COLLECT_FOOD, this.CollectFoodFunc)
            EventManager.AddListener(EventType.OPEN_BOX, this.OpenBoxFunc)
            EventManager.AddListener(EventType.ADD_CARD, this.AddCardLevelFunc)
            EventManager.AddListener(EventType.SCHEDULES_REMOVE, this.SchedulesRemove)
            EventManager.AddListener(EventType.CHARACTER_REFRESH, this.CharacterRefresh)
            EventManager.AddListener(EventType.CHARACTER_EATING_FOOD, this.CharacterEatingFood)
            
        end
    end

    -- if not this.taskItems:ContainsKey(DataManager.GetMaxCityId()) then
    --     this.taskItems:Add(DataManager.GetMaxCityId(), CityTask:New(DataManager.GetMaxCityId()))
    -- end
end

function TaskManager.InitView()
    this.GetTask(this.cityId):InitView()
end

--清理
function TaskManager.Clear(force)
    Utils.SwitchSceneClear(this.cityId, this.taskItems, force)
    if this.taskItems:Count() == 0 then
        EventManager.RemoveListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)
        EventManager.RemoveListener(EventType.UPGRADE_FURNITURE, this.UpgradeFurnitureFunc)
        EventManager.RemoveListener(EventType.COLLECT_ITEM, this.CollectItemFunc)
        EventManager.RemoveListener(EventType.USE_ITEM, this.UseItemFunc)
        EventManager.RemoveListener(EventType.TASK_FINISH, this.TaskFinishFunc)
        EventManager.RemoveListener(EventType.TASK_COMPLETE, this.TaskCompleteFunc)
        EventManager.RemoveListener(EventType.TASK_MILESTONE_REFRESH, this.TaskMilestoneCompleteFunc)
        EventManager.RemoveListener(EventType.CHARACTER_PROFESSION_CHANGE, this.CharacterProfessionChangeFunc)
        EventManager.RemoveListener(EventType.UPGRADE_CARD_LEVEL, this.UpgradeCardLevelFunc)
        EventManager.RemoveListener(EventType.COLLECT_FOOD, this.CollectFoodFunc)
        EventManager.RemoveListener(EventType.OPEN_BOX, this.OpenBoxFunc)
        EventManager.RemoveListener(EventType.ADD_CARD, this.AddCardLevelFunc)
        EventManager.RemoveListener(EventType.SCHEDULES_REMOVE, this.SchedulesRemove)
        EventManager.RemoveListener(EventType.CHARACTER_REFRESH, this.CharacterRefresh)
        EventManager.RemoveListener(EventType.CHARACTER_EATING_FOOD, this.CharacterEatingFood)
    end
end

---@return CityTask
function TaskManager.GetTask(cityId)
    return this.taskItems[cityId]
end

---------------------------------
---事件响应
---------------------------------
--建造区域事件响应
function TaskManager.UpgradeZoneFunc(cityId, zoneId, zoneType, level)
    this.GetTask(cityId):EventResponse(EventType.UPGRADE_ZONE, zoneId, zoneType, level)
end

--建造家具事件响应
function TaskManager.UpgradeFurnitureFunc(cityId, zoneId, zoneType, furnitureType, index, level)
    this.GetTask(cityId):EventResponse(EventType.UPGRADE_FURNITURE, zoneId, zoneType, furnitureType, index, level)
    this.GetTask(cityId):EventResponse("UPGRADE_TARGET_FURNITURE", zoneId, zoneType, furnitureType, index, level)
end

--收集物品事件响应
function TaskManager.CollectItemFunc(cityId, itemType, value)
    this.GetTask(cityId):EventResponse(EventType.COLLECT_ITEM, itemType, value)
end

--使用物品事件响应
function TaskManager.UseItemFunc(cityId, itemType, value)
    this.GetTask(cityId):EventResponse(EventType.USE_ITEM, itemType, value)
end

--分配小人事件相应
function TaskManager.CharacterProfessionChangeFunc(cityId, newType, oldType)
    this.GetTask(cityId):EventResponse(EventType.CHARACTER_PROFESSION_CHANGE, newType, oldType)
end

--卡牌升级
function TaskManager.UpgradeCardLevelFunc(cityId, cardId, level)
    this.GetTask(cityId):EventResponse(EventType.UPGRADE_CARD_LEVEL, cardId, level)
    this.GetTask(cityId):EventResponse("UPGRADE_TARGET_CARD_LEVEL", cardId, level)
end

--添加卡牌
function TaskManager.AddCardLevelFunc(cityId, cardId)
    -- 这个事件没有cityId
    this.GetTask(DataManager.GetCityId()):EventResponse(EventType.UPGRADE_CARD_LEVEL, cardId, 1)
    this.GetTask(DataManager.GetCityId()):EventResponse("UPGRADE_TARGET_CARD_LEVEL", cardId, 1)
end

--收集物品事件响应
function TaskManager.CollectFoodFunc(cityId, itemType, value)
    this.GetTask(cityId):EventResponse(EventType.COLLECT_FOOD, itemType, value)
end

function TaskManager.OpenBoxFunc(cityId, action, boxId, count)
    this.GetTask(cityId):EventResponse(EventType.OPEN_BOX, action, boxId, count)
end

function TaskManager.SchedulesRemove(cityId, schedules)
    this.GetTask(cityId):EventResponse(EventType.SCHEDULES_REMOVE, cityId, schedules)
end

function TaskManager.CharacterRefresh(cityId, isNew)
    this.GetTask(cityId):EventResponse(EventType.CHARACTER_REFRESH, cityId, isNew)
end

function TaskManager.CharacterEatingFood(cityId, id)
    this.GetTask(cityId):EventResponse(EventType.CHARACTER_EATING_FOOD, cityId, id)
end

--任务完成事件响应
function TaskManager.TaskFinishFunc(cityId, taskId)
    this.GetTask(cityId):TaskFinishFunc()
end

--任务完毕事件响应
function TaskManager.TaskCompleteFunc(cityId, taskId)
    this.GetTask(cityId):TaskCompleteFunc(taskId)
end

--任务章节事件响应
function TaskManager.TaskMilestoneCompleteFunc(cityId)
    this.GetTask(cityId):TaskMilestoneCompleteFunc()
end

---------------------------------
---方法响应
---------------------------------
--红点显示
function TaskManager.GetNotAcceptTaskCountRx(cityId)
    return this.GetTask(cityId).notAcceptTaskCountRx
end

--红点显示
function TaskManager.GetAllCompleteTaskCountRx(cityId)
    return this.GetTask(cityId).allTaskCompleteRx
end

--获取任务配置
function TaskManager.GetTaskMilestoneConfig(cityId)
    return this.GetTask(cityId).taskMilestoneConfig
end

--章节任务是否完成
function TaskManager.IsTaskMilestoneFinished(cityId)
    return this.GetTask(cityId):IsTaskMilestoneFinished()
end

--获取任务章节进度
function TaskManager.GetTaskMilestoneProgress(cityId)
    return this.GetTask(cityId):GetTaskMilestoneProgress()
end

function TaskManager.GetSceneTaskProgress(cityId)
    return this.GetTask(cityId):GetSceneTaskProgress()
end

--章节任务状态
function TaskManager.RefreshAndGetTaskMilestoneStatus(cityId)
    return this.GetTask(cityId):RefreshAndGetTaskMilestoneStatus()
end

--完成当前章节所有任务
function TaskManager.DebugFinishAllTask(cityId)
    return this.GetTask(cityId):DebugFinishAllTask()
end

--跳到最后一个章节任务，并且完成所有任务
function TaskManager.DebugFinishAllMilestone(cityId)
    return this.GetTask(cityId):DebugFinishAllMilestone()
end

---@return TaskBase
function TaskManager.GetTaskById(cityId, taskId)
    return this.GetTask(cityId):GetTaskById(taskId)
end

---从缓存中读取task raw数据
function TaskManager.GetCacheTaskState(cityId, taskId)
    return this.GetTask(cityId):GetCacheTaskState(taskId)
end

function TaskManager.CloseScreenTips(cityId)
end

--返回用于mainUI的任务
--只返回任务面板中可显示的任务
--优先顺序：完成的 > 未完成
---@return TaskBase
function TaskManager.GetTaskForMainUITip(cityId)
    return this.GetTask(cityId):GetTaskForMainUITip()
end

--检查是否来自task跳转，如果是，就打开tips
function TaskManager.CheckAndShowTaskTips(panel)
    if false and TaskManager.IsFromTaskPanel(panel.cityId, panel.data) then
        TaskManager.ShowScreenTipsById(panel.cityId, panel.data.extented.taskId, panel.transform)
    end
end

function TaskManager.IsFromTaskPanel(cityId, data)
    if data.extented ~= nil and data.extented.taskId ~= nil then
        local task = this.GetTaskById(cityId, data.extented.taskId)
        return task:GetTaskStatus() == TaskStatus.Unfinished
    end

    return false
end

function TaskManager.ShowScreenTipsById(cityId, taskId, transform)
end

function TaskManager.TgaEvent(eventName, obj)
    if CityManager.GetIsEventScene(this.cityId) then
        obj.currentEM = 1--EventSceneManager.GetEventMilestoneCount()
    end
    
    Analytics.Event(eventName, obj)
end

function TaskManager.Reset()
end
