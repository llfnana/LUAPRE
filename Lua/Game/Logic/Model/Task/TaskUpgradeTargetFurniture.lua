---@class TaskUpgradeTargetFurniture : TaskBase
TaskUpgradeTargetFurniture = Clone(TaskBase)
TaskUpgradeTargetFurniture.__cname = "TaskUpgradeTargetFurniture"

function TaskUpgradeTargetFurniture:OnInit()
    --self.zoneType = self.taskConfig.task["zoneType"]
    self.zoneId = self.taskConfig.task["zoneId"]
    self.zoneConfig = ConfigManager.GetZoneConfigById(self.zoneId)
    
    if self.zoneConfig == nil then
        print("[error]" .. "invalid zoneId: " .. self.zoneId .. ", taskId: " .. self.taskConfig.id, debug.traceback())
    end
    
    self.level = tonumber(self.taskConfig.task["level"])
    self.furnitureId = self.taskConfig.task["furnitureId"]
    self.furnitureIdx = tonumber(self.taskConfig.task["index"])
    self.furnitureConfig = ConfigManager.GetFurnitureById(self.furnitureId)
    
    if self.furnitureConfig == nil then
        print("[error]" .. "invalid furnitureId: " .. self.furnitureId .. ", taskId: " .. self.taskConfig.id, debug.traceback())
    end
    
    self.taskMaxCount = self.level
end

function TaskUpgradeTargetFurniture:OnResponse(zoneId, zoneType, furnitureType, index, level)
    return self.zoneId == zoneId and self.furnitureConfig.furniture_type == furnitureType
            and self.furnitureIdx == index
end

function TaskUpgradeTargetFurniture:OnCheck()
    local itemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    if itemData == nil then
        return
    end
    
    self:SetCurrCount(itemData:GetFurnitureLevel(self.furnitureId, self.furnitureIdx))
end

function TaskUpgradeTargetFurniture:_GetTaskDesc(lang)
    local itemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    local realLevel = itemData:GetFurnitureLevel(self.furnitureId, self.furnitureIdx)
    local level = realLevel
    if level == 0 then
        level = 1
    end
    
    local zoneLvl = itemData:GetLevel()
    if zoneLvl == 0 then
        zoneLvl = 1
    end
    
    if zoneLvl > #itemData.config.name_key then
        zoneLvl = #itemData.config.name_key
    end
    
    return GetLangFormat(lang, self.furnitureIdx, GetLang(self.furnitureConfig.name_key),
        self.taskMaxCount, GetLang(itemData.config.name_key[zoneLvl]), self.taskCurrCount)
end

function TaskUpgradeTargetFurniture:GetIconSprite(ImageIcon)
    local level = self.level
    if #self.furnitureConfig.assets_id < level then
        level = #self.furnitureConfig.assets_id
    end
    
    -- local furnitureIconName = self.furnitureConfig.assets_name .. "_Lv" .. self.furnitureConfig.assets_id[level]
    -- 改为一级
    local furnitureIconName = self.furnitureConfig.assets_name .. "_Lv1"

    -- 家具
    Utils.SetFurnitureIcon(ImageIcon, furnitureIconName, true)
    ImageIcon.transform.localScale = Vector2(0.8, 0.8)
end

function TaskUpgradeTargetFurniture:LookUpZone()
    Utils.LookUpFurniture(self.zoneId, self.furnitureId, self.furnitureIdx, PanelType.TaskPanel, {taskId = self.taskId}, true)
end

-- 返回给定zoneId是否是这个任务所需建筑
---@param zoneId string
---@return boolean
function TaskUpgradeTargetFurniture:IsTargetZone(zoneId)
    return self.zoneId == zoneId
end


return TaskUpgradeTargetFurniture
