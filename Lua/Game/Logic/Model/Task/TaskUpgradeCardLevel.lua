---@class TaskUpgradeCardLevel : TaskBase
TaskUpgradeCardLevel = Clone(TaskBase)
TaskUpgradeCardLevel.__cname = "TaskUpgradeCardLevel"

function TaskUpgradeCardLevel:OnInit()
    self.cardLevel = tonumber(self.taskConfig.task["level"])
    self.cardColor = self.taskConfig.task["color"] or ""
end

function TaskUpgradeCardLevel:OnResponse(cardId, level)
    return level >= self.cardLevel
end

function TaskUpgradeCardLevel:OnCheck()
    self:SetCurrCount(self:GetMatchCardCount())
end

function TaskUpgradeCardLevel:GetMatchCardCount()
    local count = 0
    CardManager.GetCardItemListInCurrentCity():ForEach(
        function(card)
            if card:GetLevel() >= self.cardLevel and self:MatchColor(card:GetConfig().color) then
                count = count + 1
            end
        end
    )

    return count
end

function TaskUpgradeCardLevel:MatchColor(color)
    return self.cardColor == "" or self.cardColor == color
end

function TaskUpgradeCardLevel:_GetTaskDesc(lang)
    return GetLangFormat(lang, self.taskMaxCount, self.cardLevel, self.taskCurrCount)
end

function TaskUpgradeCardLevel:GetIconSprite(ImageIcon)
    -- 卡牌
    Utils.SetCardHeroIcon(ImageIcon, self.taskConfig.id, true, 0.39)
end

function TaskUpgradeCardLevel:LookUpZone()
    -- PopupManager.Instance:CloseAllPanel()
    -- PopupManager.Instance:LastOpenPanel(PanelType.CardPanel)
end

function TaskUpgradeCardLevel:IsTargetZone(zoneId)
    return false
end

return TaskUpgradeCardLevel
