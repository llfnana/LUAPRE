---@class TaskUpgradeTargetCardLevel : TaskBase
TaskUpgradeTargetCardLevel = Clone(TaskBase)
TaskUpgradeTargetCardLevel.__cname = "TaskUpgradeTargetCardLevel"

function TaskUpgradeTargetCardLevel:OnInit()
    --self.zoneType = self.taskConfig.task["zoneType"]
    self.cardId = tonumber(self.taskConfig.task["id"])
    self.level = tonumber(self.taskConfig.task["level"])
    self.cardConfig = ConfigManager.GetCardConfig(self.cardId)
    
    if self.cardConfig == nil then
        print("[error]" .. "invalid cardId: " .. self.cardId .. ", taskId: " .. self.taskConfig.id)
    end
    
    self.taskMaxCount = self.level
end

function TaskUpgradeTargetCardLevel:OnResponse(cardId, level)
    return self.cardId == cardId
end

function TaskUpgradeTargetCardLevel:OnCheck()
    local cardItemData = CardManager.GetCardItemData(self.cardId)
    if cardItemData == nil then
        return
    end

    self:SetCurrCount(cardItemData:GetLevel())
end

function TaskUpgradeTargetCardLevel:_GetTaskDesc(lang)
    local cardItemData = CardManager.GetCardItemData(self.cardId)
    local level = 0
    if cardItemData ~= nil then
        level = cardItemData:GetLevel()
    end

    if level > self.level then
        level = self.level
    end

    return GetLangFormat(lang, GetLang(self.cardConfig.name), self.level, level)
end

function TaskUpgradeTargetCardLevel:GetIconSprite(ImageIcon)
    -- 英雄卡牌
    -- ImageIcon.transform.localScale = Vector2(0.9, 0.9)
    Utils.SetCardHeroIcon(ImageIcon, self.cardId, true, 0.39)
    
end

function TaskUpgradeTargetCardLevel:LookUpZone()
    local zone = self:FindZoneByCardId(self.cardId)
    if zone ~= nil then
        Utils.LookUpFurniture(zone.id, "", 0, PanelType.TaskPanel, {taskId = self.taskId}, true)
        return
    end
    
    -- PopupManager.Instance:CloseAllPanel()
    -- PopupManager.Instance:LastOpenPanel(PanelType.CardPanel)
end

-- 返回给定zoneId是否是这个任务所需建筑
---@param zoneId string
---@return boolean
function TaskUpgradeTargetCardLevel:IsTargetZone(zoneId)
    local zone = self:FindZoneByCardId(self.cardId)
    if zone == nil then
        return false
    end
    
    return zone.id == zoneId
end

---@return Zones
function TaskUpgradeTargetCardLevel:FindZoneByCardId(cardId)
    local zones = ConfigManager.GetZonesByCityId(self.cityId)
    local zoneCfg = nil
    ---@param v Zones
    zones:ForEach(
        function(v)
            for i = 1, #v.card_id do
                if v.card_id[i] == cardId then
                    local mapItemData = MapManager.GetMapItemData(self.cityId, v.id)
                    local status = Utils.GetMapItemDataStatus(mapItemData)
                    if status ~= MapItemDataStatus.Lock then
                        zoneCfg = v
                        return true
                    end
                end
            end
        end
    )
    
    return zoneCfg
end

return TaskUpgradeTargetCardLevel
