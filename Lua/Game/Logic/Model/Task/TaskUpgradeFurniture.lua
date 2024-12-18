---@class TaskUpgradeFurniture : TaskBase
TaskUpgradeFurniture = Clone(TaskBase)
TaskUpgradeFurniture.__cname = "TaskUpgradeFurniture"

---@class TaskUpgradeFurnitureAvailableZone
---@field ZoneId string
---@field ZoneLevel number
---@field ZoneSortQueue number
---@field ZoneNames string[]
---@field CanLock boolean
---@field FurnitureLevel number
---@field FurnitureIdx number
---@field FurnitureMaxLevel number
---@field NeedLevel number

function TaskUpgradeFurniture:OnInit()
    self.zoneId = self.taskConfig.task["zoneId"]
    self.zoneConfig = ConfigManager.GetZoneConfigById(self.zoneId)
    
    if self.zoneConfig == nil then
        print("[error]" .. "invalid zoneId: " .. self.zoneId .. ", taskId: " .. self.taskConfig.id)
    end
    
    self.furnitureType = self.taskConfig.task["furnitureType"]
    self.furnitureId = string.format("C%d_%s_%s", self.cityId, self.zoneConfig.zone_type, self.furnitureType)
    self.level = tonumber(self.taskConfig.task["level"])
    self.furnitureCfg = ConfigManager.GetFurnitureById(self.furnitureId)
    
    if self.furnitureCfg == nil then
        print("[error]" .. "invalid furnitureId: " .. self.furnitureId .. ", taskId: " .. self.taskConfig.id)
    end
end

function TaskUpgradeFurniture:OnResponse(zoneId, zoneType, furnitureType, index, level)
    return self.zoneId == zoneId and furnitureType == self.furnitureType
end

function TaskUpgradeFurniture:OnCheck()
    local count = 0
    local furnitureDataList = self:GetAvailableFurnitureList(self.cityId, self.zoneConfig, self.furnitureCfg, self.level, true)

    furnitureDataList:ForEach(function(v)
        if v.FurnitureLevel >= self.level then
            count = count + 1
        end
    end)
    
    self:SetCurrCount(count)
end

function TaskUpgradeFurniture:_GetTaskDesc(lang)
    local furnitureDataList =
        self:GetAvailableFurnitureList(self.cityId, self.zoneConfig, self.furnitureCfg, self.level, true)
    if furnitureDataList:Count() > 0 then
        furnitureDataList:Sort(self.SortAvailableFurnitureList)
        
        local zoneLevel = furnitureDataList[1].ZoneLevel
        if zoneLevel == 0 then
            zoneLevel = 1
        end
    
        if #self.zoneConfig.name_key < zoneLevel then
            zoneLevel = #self.zoneConfig.name_key
        end

        return GetLangFormat(
            lang,
            self.taskMaxCount,
            GetLang(self.furnitureCfg.name_key),
            self.level,
            GetLang(self.zoneConfig.name_key[zoneLevel]),
            self.taskCurrCount
        )
    else
        return ""
    end
end

function TaskUpgradeFurniture:GetIconSprite(ImageIcon)
    -- local furnitureIconName = self.furnitureCfg.assets_name .. "_Lv" .. self.furnitureCfg.assets_id[self.level]
    -- 改为一级
    -- 家具
    local furnitureIconName = self.furnitureConfig.assets_name .. "_Lv1"
    Utils.SetFurnitureIcon(ImageIcon, furnitureIconName, true)
    ImageIcon.transform.localScale = Vector2(0.8, 0.8)
end

function TaskUpgradeFurniture:LookUpZone()
    local furnitureDataList =
        self:GetAvailableFurnitureList(self.cityId, self.zoneConfig, self.furnitureCfg, self.level, true)
    if furnitureDataList:Count() > 0 then
        furnitureDataList:Sort(self.SortAvailableFurnitureList)
        Utils.LookUpFurniture(furnitureDataList[1].ZoneId, self.furnitureCfg.id, furnitureDataList[1].FurnitureIdx, PanelType.TaskPanel, {taskId = self.taskId}, true)
    else
        -- GameToast.Instance:Show(GetLang("ui_task_need_more_unlock"),ToastIconType.Warning)
        UIUtil.showText(GetLang("ui_task_need_more_unlock"))
    end
end

-- 返回给定zoneId是否是这个任务所需建筑
---@param zoneId string
---@return boolean
function TaskUpgradeFurniture:IsTargetZone(zoneId)
    return zoneId == self.zoneId
end

---获得可用的家具列表
---@param cityId number
---@param zoneId string
---@param furnitureCfg table
---@param needFurnitureLevel number
---@param mustHas boolean
---@return TaskUpgradeFurnitureAvailableZone[]
function TaskUpgradeFurniture:GetAvailableFurnitureList(cityId, zoneCfg, furnitureCfg, needFurnitureLevel, mustHas)
    local mapItemData = MapManager.GetMapItemData(cityId, zoneCfg.id)
    local zoneLevel = mapItemData:GetLevel()
    local zoneLevelSafe = zoneLevel
    if zoneLevelSafe == 0 then
        zoneLevelSafe = 1
    end

    local furnitureMaxLevel = furnitureCfg.max_level[zoneLevelSafe]

    local furnitureDataList = List:New()
    -- 地块是否可建造
    if MapManager.GetCanLock(cityId, zoneCfg.id) then
        -- 建筑还没有建造
        if zoneLevel == 0 then
            ---@type TaskUpgradeFurnitureAvailableZone
            local furnitureData = {
                ZoneId = zoneCfg.id,
                ZoneLevel = zoneLevel,
                ZoneNames = zoneCfg.name_key,
                CanLock = true,
                FurnitureLevel = 0,
                FurnitureIdx = 0,
                FurnitureMaxLevel = furnitureMaxLevel,
                NeedLevel = needFurnitureLevel
            }
            furnitureDataList:Add(furnitureData)
        else
            --获得解锁的家具数量
            local count = mapItemData:GetUnlockFurnitureCountById(furnitureCfg.id, 0)

            for i = 1, count, 1 do
                local lvl = mapItemData:GetFurnitureLevel(furnitureCfg.id, i)
                ---@type TaskUpgradeFurnitureAvailableZone
                local furnitureData = {
                    ZoneId = zoneCfg.id,
                    ZoneLevel = zoneLevel,
                    ZoneNames = zoneCfg.name_key,
                    CanLock = true,
                    FurnitureLevel = lvl,
                    FurnitureIdx = i,
                    FurnitureMaxLevel = furnitureMaxLevel,
                    NeedLevel = needFurnitureLevel
                }
                furnitureDataList:Add(furnitureData)
            end
        end
    end
    
    -- 如果忽略未解锁
    if furnitureDataList:Count() == 0 and mustHas then
        -- 如果这个地块还没有解锁
        ---@type TaskUpgradeFurnitureAvailableZone
        local furnitureData = {
            ZoneId = zoneCfg.id,
            ZoneLevel = zoneLevel,
            ZoneNames = zoneCfg.name_key,
            CanLock = false,
            FurnitureLevel = 0,
            FurnitureIdx = 0,
            FurnitureMaxLevel = furnitureMaxLevel,
            NeedLevel = needFurnitureLevel
        }
        furnitureDataList:Add(furnitureData)
    end
    
    return furnitureDataList
end

--- 对可用furnitureData列表排序
---@param a TaskUpgradeFurnitureAvailableZone
---@param b TaskUpgradeFurnitureAvailableZone
---@return boolean
function TaskUpgradeFurniture.SortAvailableFurnitureList(a, b)
    -- 能建造的优先
    if a.CanLock ~= b.CanLock then
        return a.CanLock
    end

    -- 家具最大等级能够达到需求等级的优先
    if (a.NeedLevel <= a.FurnitureMaxLevel) ~= (b.NeedLevel <= b.FurnitureMaxLevel) then
        return (a.NeedLevel <= a.FurnitureMaxLevel) or not (b.NeedLevel <= b.FurnitureMaxLevel)
    end

    -- 还没有达到需求等级的优先
    if (a.FurnitureLevel < a.NeedLevel) ~= (b.FurnitureLevel < a.NeedLevel) then
        return (a.FurnitureLevel < a.NeedLevel) or not (b.FurnitureLevel < a.NeedLevel)
    end

    -- 等级低的优先
    return a.FurnitureIdx < b.FurnitureIdx
end

---获得所有符合条件的家具列表
---@param cityId number
---@param zoneType string
---@param furniture table
---@param needFurnitureLevel number
---@param ignoreCanLock boolean
---@return TaskUpgradeFurnitureAvailableZone[]
function TaskUpgradeFurniture:GetAvailableZoneList(cityId, zoneType, furniture, needFurnitureLevel, ignoreCanLock)
    -- 获得这个城市指定类型的zoneId列表
    local zoneList = ConfigManager.GetZoneConfigListByType(cityId, zoneType)
    local zoneDataList = List:New()

    -- 找到第一个还达到等级的家具
    zoneList:ForEach(
        function(zoneCfg)
            local mapItemData = MapManager.GetMapItemData(cityId, zoneCfg.id)
            local zoneLevel = mapItemData:GetLevel()
            local zoneLevelSafe = zoneLevel
            if zoneLevelSafe == 0 then
                zoneLevelSafe = 1
            end

            local furnitureMaxLevel = furniture.max_level[zoneLevelSafe]
            -- 地块是否可建造
            if MapManager.GetCanLock(cityId, zoneCfg.id) then
                -- 建筑还没有建造
                if zoneLevel == 0 then
                    ---@type TaskUpgradeFurnitureAvailableZone
                    local zoneData = {
                        ZoneId = zoneCfg.id,
                        ZoneSortQueue = zoneCfg.sort_queue,
                        CanLock = true,
                        FurnitureLevel = 0,
                        FurnitureIdx = 0,
                        FurnitureMaxLevel = furnitureMaxLevel,
                        NeedLevel = needFurnitureLevel
                    }
                    zoneDataList:Add(zoneData)
                else
                    --获得解锁的家具数量
                    local count = mapItemData:GetUnlockFurnitureCountById(furniture.id, 0)

                    for i = 1, count, 1 do
                        local lvl = mapItemData:GetFurnitureLevel(furniture.id, i)
                        ---@type TaskUpgradeFurnitureAvailableZone
                        local zoneData = {
                            ZoneId = zoneCfg.id,
                            ZoneSortQueue = zoneCfg.sort_queue,
                            CanLock = true,
                            FurnitureLevel = lvl,
                            FurnitureIdx = i,
                            FurnitureMaxLevel = furnitureMaxLevel,
                            NeedLevel = needFurnitureLevel
                        }
                        zoneDataList:Add(zoneData)
                    end
                end
            else
                -- 如果忽略未解锁
                if ignoreCanLock then
                    -- 如果这个地块还没有解锁
                    ---@type TaskUpgradeFurnitureAvailableZone
                    local zoneData = {
                        ZoneId = zoneCfg.id,
                        ZoneSortQueue = zoneCfg.sort_queue,
                        CanLock = false,
                        FurnitureLevel = 0,
                        FurnitureIdx = 0,
                        FurnitureMaxLevel = furnitureMaxLevel,
                        NeedLevel = needFurnitureLevel
                    }
                    zoneDataList:Add(zoneData)
                end
            end

            return false
        end
    )

    return zoneDataList
end

--- 对可用zoneData列表排序
---@param a TaskUpgradeFurnitureAvailableZone
---@param b TaskUpgradeFurnitureAvailableZone
---@return boolean
function TaskUpgradeFurniture.SortAvailableZoneList(a, b)
    -- 能建造的优先
    if a.CanLock ~= b.CanLock then
        return a.CanLock
    end

    -- 家具最大等级能够达到需求等级的优先
    if (a.NeedLevel <= a.FurnitureMaxLevel) ~= (b.NeedLevel <= b.FurnitureMaxLevel) then
        return (a.NeedLevel <= a.FurnitureMaxLevel) or not (b.NeedLevel <= b.FurnitureMaxLevel)
    end

    -- 还没有达到需求等级的优先
    if (a.FurnitureLevel < a.NeedLevel) ~= (b.FurnitureLevel < a.NeedLevel) then
        return (a.FurnitureLevel < a.NeedLevel) or not (b.FurnitureLevel < a.NeedLevel)
    end
    -- 建筑顺序小的优先
    return a.ZoneSortQueue < b.ZoneSortQueue
end

return TaskUpgradeFurniture
