---@class TaskSleepWell : TaskBase
TaskSleepWell = Clone(TaskBase)
TaskSleepWell.__cname = "TaskSleepWell"

---小人数量
function TaskSleepWell:OnInit()
    self.hungerCount = tonumber(self.taskConfig.task["hunger"])
end

---@param schedules Schedules
function TaskSleepWell:OnResponse(cityId, schedules)
    if schedules.type ~= SchedulesType.Sleep then
        return false
    end
    
    local count = 0
    local chars = CharacterManager.GetAllCharactersByList(cityId)
    ---@param v CharacterController
    chars:ForEach(
        function(v)
            if v:GetAttribute(AttributeType.Hunger) > self.hungerCount and v:IsHealth() then
                count = count + 1
            end
        end
    )
    self:IncrCacheCount(count)
    
    return true
end

function TaskSleepWell:OnCheck()
    self:SetCurrCount(self:GetCacheCount())
end

function TaskSleepWell:_GetTaskDesc(lang)
    return GetLangFormat(lang, self.taskMaxCount, math.floor(self.taskCurrCount))
end

function TaskSleepWell:GetTaskProgress()
    return math.floor(self:GetSafeCurrCount()), self.taskMaxCount
end

function TaskSleepWell:GetIconSprite(ImageIcon)
    -- 小人
    Utils.SetIcon(ImageIcon, "icon_task_people", nil, nil, true)
end

function TaskSleepWell:LookUpZone()
    -- PopupManager.Instance:CloseAllPanel()
    -- PopupManager.Instance:LastOpenPanel(PanelType.CardPanel)
end

function TaskSleepWell:IsTargetZone(zoneId)
    return false
end

function TaskSleepWell:GetJumpButtonShow()
    return false
end

return TaskSleepWell
