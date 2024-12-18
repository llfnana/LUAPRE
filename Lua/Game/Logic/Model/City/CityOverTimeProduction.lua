---@class CityOverTimeProduction
CityOverTimeProduction = Clone(CityBase)
CityOverTimeProduction.__cname = "CityOverTimeProduction"

---@class OverTimeProductionData
---@field ItemOverTimeHistory table<string, number>
---@field OverTimeHistory table<string, number>

-- ************ OverTime表示非material类型的物品产出，比如cash，heart
-- ************ ItemOverTime表示material类型的物品产出

function CityOverTimeProduction:OnInit()
    ---@type OverTimeProductionData
    self.data =
        DataManager.GetCityDataByKey(self.cityId, DataKey.OverTimeProduction) or
        {
            ItemOverTimeHistory = {},
            OverTimeHistory = {}
        }
    
    self.OvertimeItemList = {
        ItemType.Heart,
        ItemType.Cash
    }
end

function CityOverTimeProduction:OnClear()
    self = nil
end

function CityOverTimeProduction:SaveData()
    DataManager.SetCityDataByKey(self.cityId, DataKey.OverTimeProduction, self.data)
end

---@return table<string, number>
function CityOverTimeProduction:CalcItemOverTime()
    local output = OfflineManager.CalculateOutputByTime(1)

    ---@type Items[]
    local cityItems = ConfigManager.GetItemList(DataManager.GetCityId())

    cityItems:ForEach(
        function(item)
            if item.resource_type > 1 then
                -- 只要建筑建好了，就要有保底产出
                local zoneList = Utils.GetZoneListByItemIdIncludeBuilding(DataManager.GetCityId(), item.id)
                if zoneList:Count() > 0 then
                    if output[item.id] == nil or output[item.id] < item.shop_rewards_limit then
                        --todo 基础数据 * 物品id的boost
                        output[item.id] =
                            item.shop_rewards_limit * BoostManager.GetMaterialBoostFactor(self.cityId, item.id)
                    end
                end
            end
        end
    )
    
    local newOut = {}
    for k, v in pairs(output) do
        local itemConfig = ConfigManager.GetItemConfig(k)

        -- 离线奖励中现在包含cash，所以在这里要去掉cash
        if itemConfig.type == "Material" and itemConfig.item_type ~= ItemType.Cash then
            newOut[k] = v
        end
    end

    return newOut
end

---@param id number 物品id
function CityOverTimeProduction:CalcOverTime(id, guarantee)
    local itemConfig = ConfigManager.GetItemConfig(id)
    local count = 0
    if itemConfig.item_type == ItemType.Heart then
        if CityManager.GetIsEventScene(itemConfig.city_id) then
            count = StatisticalManager.GetOutputProductionsPerSecond(itemConfig.city_id, id)
        else
            -- if FunctionsManager.IsUnlock(FunctionsType.Fight) then
            --     count = AdventureContManager.secondCreatShoplimit()
            -- end
        end
    elseif itemConfig.item_type == ItemType.Cash then
        count =0-- EventSceneManager.GetCashSpeed()
    end
    
    if guarantee == 1 then
        if count < itemConfig.shop_rewards_limit then
            count = itemConfig.shop_rewards_limit
        end
    end

    return count
end

---获取场景资源秒产
---@param sec number 获取秒数
---@return Reward[]
function CityOverTimeProduction:GetItemOverTimeReward(sec)
    local rewards = {}
    for k, v in pairs(self:GetItemOverTime(sec)) do
        table.insert(
            rewards,
            {
                id = k,
                count = v,
                addType = RewardAddType.Item
            }
        )
    end

    -- 添加物品保底
    local item = self:GetGuaranteeRewardOfCity(self.cityId)
    local found = false

    for i = 1, #rewards do
        if rewards[i].id == item.id then
            found = true
        end
    end

    if not found then
        table.insert(
            rewards,
            {
                id = item.id,
                addType = RewardAddType.Item,
                count = sec * 1.0 * item.shop_rewards_limit
            }
        )
    end

    return rewards
end

---获取场景资源秒产
---@param sec number 获取秒数
---@return table<string, number>
function CityOverTimeProduction:GetItemOverTime(sec, guarantee)
    -- 历史最高秒产都要有保底
    self:UpdateItemOverTime()
    local rt = {}
    for k, v in pairs(self.data.ItemOverTimeHistory) do
        local c = v * 1.0
        rt[k] = math.floor(c * sec)
    end
    
    if guarantee == 1 then
        local items = ConfigManager.GetItemList(DataManager.GetCityId())
        items:ForEach(
            function(v)
                if not self:IsOverTimeByItemType(v.item_type) then
                    if self.data.ItemOverTimeHistory[v.id] == nil then
                        rt[v.id] = math.floor(sec * 1.0 * v.shop_rewards_limit)
                    end
                end
            end
        )
    end
    
    return rt
end

---获取特定物品秒产
---@param id number 物品id
---@param sec number 获取秒数
---@return number
function CityOverTimeProduction:GetOverTime(id, sec, guarantee)
    -- 历史最高秒产都要有保底
    self:UpdateOverTime(id, guarantee)
    local count = self.data.OverTimeHistory[id] or 0
    local c = count * 1.0
    return math.floor(c * sec)
end

function CityOverTimeProduction:Get(id, sec, guarantee)
    local itemConfig = ConfigManager.GetItemConfig(id)
    
    if itemConfig == nil then
        print("[error]" .. "CityOverTimeProduction: invalid item: " .. id)
    end
    
    if self:IsOverTimeByItemType(itemConfig.item_type) then
        return self:GetOverTime(id, sec, guarantee)
    end
    
    local rewards = self:GetItemOverTime(sec, guarantee)
    return rewards[id] or 0
end

function CityOverTimeProduction:UpdateItemOverTime()
    local newOt = self:CalcItemOverTime()
    for k, v in pairs(newOt) do
        local oldCount = self.data.ItemOverTimeHistory[k] or 0
        if oldCount < v then
            self.data.ItemOverTimeHistory[k] = v
            EventManager.Brocast(EventType.OverTimeProductionChange, k)
        end
    end
    
    self:SaveData()
end

---@param id number 物品id
---@param guarantee number
function CityOverTimeProduction:UpdateOverTime(id, guarantee)
    local count = self:CalcOverTime(id, guarantee)

    local oldCount = self.data.OverTimeHistory[id] or 0
    if count > oldCount then
        self.data.OverTimeHistory[id] = count
        EventManager.Brocast(EventType.OverTimeProductionChange, id)
    end

    self:SaveData()
end

---返回当前秒产中最大的Resource Type
---@return number
function CityOverTimeProduction:GetMaxResourceTypeFromItemOverTime()
    -- 历史最高秒产都要有保底
    self:UpdateItemOverTime()
    local maxResType = -1
    for k, v in pairs(self.data.ItemOverTimeHistory) do
        local itemCfg = ConfigManager.GetItemConfig(k)
        if itemCfg.resource_type > maxResType then
            maxResType = itemCfg.resource_type
        end
    end

    return maxResType
end

function CityOverTimeProduction:UseTimeSkip(id, to, toId)
    local config = ConfigManager.GetItemConfig(id)

    if DataManager.GetMaterialCount(self.cityId, id) == 0 then
        return {}
    end

    DataManager.UseMaterial(self.cityId, id, 1, to, toId)

    return DataManager.AddReward(self.cityId, self:GetTimeSkipReward(config.duration), to, toId)
end

---@return Items
function CityOverTimeProduction:GetGuaranteeRewardOfCity(cityId)
    local items = ConfigManager.GetItemList(cityId)

    ---@param a Items
    ---@param b Items
    items:Sort(
        function(a, b)
            return a.sort < b.sort
        end
    )

    local selItem = nil
    ---@param v Items
    items:ForEach(
        function(v)
            if v.resource_type > 1 then
                selItem = v
                return true
            end
        end
    )

    return selItem
end

---返回时间机器的奖励
---@return Reward[]
function CityOverTimeProduction:GetTimeSkipReward(sec)
    --获取material资源
    local rewards = self:GetItemOverTimeReward(sec)
    
    if CityManager.GetIsEventScene(self.cityId) then
        -- 加入cash
        local cashId = Utils.GetItemId(self.cityId, ItemType.Cash)
        table.insert(
            rewards,
            {
                addType = RewardAddType.Item,
                id = cashId,
                count = self:GetOverTime(cashId, sec),
                sort = MathUtil.maxinteger - 1
            }
        )
    end
    
    --heart在活动场景中属于建筑生产内容，会出现在itemOverTime中
    local heartId = Utils.GetItemId(self.cityId, ItemType.Heart)
    local heardCount = self:GetOverTime(heartId, sec, 1)
    if heardCount > 0 then
        table.insert(
            rewards,
            {
                addType = RewardAddType.Item,
                id = heartId,
                count = heardCount,
                sort = MathUtil.maxinteger
            }
        )
    end
    
    --建筑升级时间
    table.insert(
        rewards,
        {
            addType = RewardAddType.ZoneTime,
            count = sec,
            sort = -1
        }
    )

    return rewards
end

---@return MapItemData[]
function CityOverTimeProduction:GetValidUpgradingZoneList()
    local zoneMap = ConfigManager.GetZonesByCityId(self.cityId)

    local zones = {}

    ---@param value Zones
    zoneMap:ForEach(
        function(value)
            local mapItemData = MapManager.GetMapItemData(self.cityId, value.id)
            if
                mapItemData.config.zone_type ~= "GoldenGrandpa" and
                    (Utils.GetMapItemDataStatus(mapItemData) == MapItemDataStatus.Building or
                        Utils.GetMapItemDataStatus(mapItemData) == MapItemDataStatus.Upgrading)
             then
                table.insert(zones, mapItemData)
            end
        end
    )

    return zones
end

---item是OverTime类型秒产
function CityOverTimeProduction:IsOverTimeByItemType(itemType)
    return Utils.ArrayHas(self.OvertimeItemList, itemType)
end
