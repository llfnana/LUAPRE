---@class TaskSurvivorCount : TaskBase
TaskSurvivorCount = Clone(TaskBase)
TaskSurvivorCount.__cname = "TaskSurvivorCount"

---小人数量
function TaskSurvivorCount:OnInit()
    self.targetZoneId = self.taskConfig.task["zoneId"]
end

function TaskSurvivorCount:OnResponse(cityId, isNew)
    return true
end

function TaskSurvivorCount:OnCheck()
    self:SetCurrCount(CharacterManager.GetCharacterCount(self.cityId))
end

function TaskSurvivorCount:_GetTaskDesc(lang)
    return GetLangFormat(lang, self.taskMaxCount, self.taskCurrCount)
end

function TaskSurvivorCount:GetTaskProgress()
    return math.floor(self:GetSafeCurrCount()), self.taskMaxCount
end

function TaskSurvivorCount:GetIconSprite(ImageIcon)
    -- 小人
    Utils.SetIcon(ImageIcon, "icon_task_people", nil, nil, true)
end

function TaskSurvivorCount:LookUpZone()
    Utils.LookUpFurniture(self.targetZoneId, "", 0, PanelType.TaskPanel, {taskId = self.taskId}, true)
end

function TaskSurvivorCount:IsTargetZone(zoneId)
    return self.targetZoneId == zoneId
end

return TaskSurvivorCount
