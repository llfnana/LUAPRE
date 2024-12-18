---@class TaskOpenBox : TaskBase
TaskOpenBox = Clone(TaskBase)
TaskOpenBox.__cname = "TaskOpenBox"

function TaskOpenBox:OnInit()
    self.boxId = self.taskConfig.task["id"]
end

function TaskOpenBox:OnResponse(action, boxId, count)
    if action == BoxManager.Action.Buy and self.boxId == boxId then
        self:IncrCacheCount(count)
        
        return true
    end
    return false
end

function TaskOpenBox:OnCheck()
    self:SetCurrCount(self:GetCacheCount())
end

function TaskOpenBox:_GetTaskDesc(lang)
    return GetLangFormat(lang, self.taskMaxCount, self.taskCurrCount)
end

function TaskOpenBox:GetIconSprite(ImageIcon)
    -- 宝箱
    Utils.SetBoxIcon(ImageIcon, self.boxId)
    ImageIcon.transform.localScale = Vector2(0.7, 0.7)
end

function TaskOpenBox:LookUpZone()
    -- PopupManager.Instance:OpenPanel(PanelType.ShopPanel)
end

-- 返回给定zoneId是否是这个任务所需建筑
---@param zoneId string
---@return boolean
function TaskOpenBox:IsTargetZone(zoneId)
    return false
end

return TaskOpenBox
