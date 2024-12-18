---@class TaskEatWell : TaskBase
TaskEatWell = Clone(TaskBase)
TaskEatWell.__cname = "TaskEatWell"

---小人数量
function TaskEatWell:OnInit()
end

function TaskEatWell:OnResponse(cityId, id)
    self:IncrCacheCount(1)
    
    return true
end

function TaskEatWell:OnCheck()
    self:SetCurrCount(self:GetCacheCount())
end

function TaskEatWell:_GetTaskDesc(lang)
    return GetLangFormat(lang, self.taskMaxCount, math.floor(self.taskCurrCount))
end

function TaskEatWell:GetTaskProgress()
    return math.floor(self:GetSafeCurrCount()), self.taskMaxCount
end

function TaskEatWell:GetIconSprite(ImageIcon)
    -- 小人
    Utils.SetIcon(ImageIcon, "icon_task_people", nil, nil, true)
end

function TaskEatWell:LookUpZone()
    -- PopupManager.Instance:CloseAllPanel()
    -- PopupManager.Instance:LastOpenPanel(PanelType.CardPanel)
end

function TaskEatWell:IsTargetZone(zoneId)
    return false
end

function TaskEatWell:GetJumpButtonShow()
    return false
end

return TaskEatWell
