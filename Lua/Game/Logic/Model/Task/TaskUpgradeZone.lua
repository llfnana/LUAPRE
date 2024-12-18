---@class TaskUpgradeZone : TaskBase
TaskUpgradeZone = Clone(TaskBase)
TaskUpgradeZone.__cname = "TaskUpgradeZone"

---@class TaskUpgradeZoneAvailableZoneData
---@field ZoneId string
---@field CanLock boolean
---@field ZoneLevel number
---@field SortQueue number
---@field NameList string[]
---@field ZoneTypeName string
---@field NeedLevel number

function TaskUpgradeZone:OnInit()
    --self.zoneType = self.taskConfig.task["zoneType"]
    self.zoneId = self.taskConfig.task["zoneId"]
    self.level = tonumber(self.taskConfig.task["level"])
    self.taskMaxCount = self.level
end

function TaskUpgradeZone:OnResponse(zoneId, zoneType, level)
    return zoneId == self.zoneId
end

function TaskUpgradeZone:OnCheck()
    local itemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    
    self:SetCurrCount(itemData:GetLevel())
end

function TaskUpgradeZone:_GetTaskDesc(lang)
    local itemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    local lvl = itemData:GetLevel()
    if lvl == 0 then
        lvl = 1
    end
    
    if #itemData.config.name_key < lvl then
        lvl = #itemData.config.name_key
    end

    return GetLangFormat(lang, GetLang(itemData.config.name_key[lvl]), self.level, self.taskCurrCount, self.taskMaxCount)
end

function TaskUpgradeZone:GetIconSprite(ImageIcon)
    -- 建筑
    Utils.SetZoneIcon(ImageIcon, self.zoneId, 1, true)
    ImageIcon.transform.localScale = Vector2(0.6, 0.6)
end

function TaskUpgradeZone:LookUpZone()
    Utils.LookUpFurniture(self.zoneId, "", 0, PanelType.TaskPanel, {taskId = self.taskId}, true)
end

-- 返回给定zoneId是否是这个任务所需建筑
---@param zoneId string
---@return boolean
function TaskUpgradeZone:IsTargetZone(zoneId)
    local zoneDataList = self:GetAvailableZoneList(self.cityId, self.zoneType, self.level, false)
    local exists = false
    zoneDataList:ForEach(function(v)
        if v.ZoneId == zoneId then
            exists = true
            return true
        end
    end)

    return exists
end

function TaskUpgradeZone:GetFirstDormName(cityId)
    local zoneList = ConfigManager.GetZoneConfigListByType(cityId, ZoneType.Dorm)
    zoneList:Sort(function(a, b)
        return a.sort_queue < b.sort_queue
    end)

    return zoneList[1].name_key[1]
end

---获取所有符合条件的ZoneData
---@param cityId number
---@param zoneType string
---@param needLevel number
---@param ignoreCanLock boolean
---@return TaskUpgradeZoneAvailableZoneData[]
function TaskUpgradeZone:GetAvailableZoneList(cityId, zoneType, needLevel, ignoreCanLock)
    local zoneList = ConfigManager.GetZoneConfigListByType(cityId, zoneType)
    local zoneDataList = List:New()

    zoneList:ForEach(function(zoneConfig)
        local mapItemData = MapManager.GetMapItemData(cityId, zoneConfig.id)
        if MapManager.GetCanLock(cityId, zoneConfig.id) then
            ---@type TaskUpgradeZoneAvailableZoneData
            local zoneData = {
                ZoneId = zoneConfig.id,
                CanLock = true,
                ZoneLevel = mapItemData:GetLevel(),
                SortQueue = zoneConfig.sort_queue,
                NameList = zoneConfig.name_key,
                ZoneTypeName = zoneConfig.zone_type_name,
                NeedLevel = needLevel
            }
            zoneDataList:Add(zoneData)
        else
            if ignoreCanLock then
                ---@type TaskUpgradeZoneAvailableZoneData
                local zoneData = {
                    ZoneId = zoneConfig.id,
                    CanLock = false,
                    ZoneLevel = 0,
                    SortQueue = zoneConfig.sort_queue,
                    NameList = zoneConfig.name_key,
                    ZoneTypeName = zoneConfig.zone_type_name,
                    NeedLevel = needLevel
                }
                zoneDataList:Add(zoneData)
            end
        end
    end)

    return zoneDataList
end

---@param a TaskUpgradeZoneAvailableZoneData
---@param b TaskUpgradeZoneAvailableZoneData
---@return boolean
function TaskUpgradeZone.SortAvailableZoneList(a, b)
    if (a.NeedLevel > a.ZoneLevel) ~= (b.NeedLevel > b.ZoneLevel) then
        return a.NeedLevel > a.ZoneLevel or not (b.NeedLevel > b.ZoneLevel)
    end

    return a.SortQueue < b.SortQueue
end

-- 获取第一个unlock的zone如果没有，就用第一个未解锁的
---@param cityId number
---@param zoneType string
---@param needLevel number
---@param ignoreCanLock boolean
---@return Zones, number
function TaskUpgradeZone:GetAvailableZoneId(cityId, zoneType, needLevel, ignoreCanLock)
    local zoneList = ConfigManager.GetZoneConfigListByType(cityId, zoneType)
    local zoneCfg = nil
    local lvl = 0
    local sortQueue = 9999999

    zoneList:ForEach(function(value)
        local mapItemData = MapManager.GetMapItemData(cityId, value.id)
        -- 是否忽略未解锁地块
        if ignoreCanLock or MapManager.GetCanLock(cityId, value.id) then
            -- 目标建筑等级不能高于needLevel
            if needLevel > mapItemData:GetLevel() then
                -- 先取一个
                if zoneCfg == nil then
                    -- 默认取第一个
                    zoneCfg = value
                    lvl = mapItemData:GetLevel()
                    sortQueue = mapItemData:GetSortQueue()
                end

                if mapItemData:IsUnlock() then
                    -- 如果有已经解锁的，那么就用已经解锁的，而且找到等级最低的
                    if lvl > mapItemData:GetLevel() then
                        zoneCfg = value
                        lvl = mapItemData:GetLevel()
                        sortQueue = mapItemData:GetSortQueue()
                    elseif lvl == mapItemData:GetLevel() then
                        -- 如果等级一样，那么找到SortQueue小的那个
                        if sortQueue > mapItemData:GetSortQueue() then
                            zoneCfg = value
                            lvl = mapItemData:GetLevel()
                            sortQueue = mapItemData:GetSortQueue()
                        end
                    end
                end
            end
        end
        return false
    end)

    return zoneCfg, lvl
end

return TaskUpgradeZone
