CityBoost = Clone(CityBase)
CityBoost.__cname = "CityBoost"

local rootPath = "Game/Logic/Model/Boost/"

function CityBoost:OnInit()
    self:InitBoostList()
    --当前场景生效的Boost
    self.boostData = DataManager.GetCityDataByKey(self.cityId, DataKey.RewardBoostData)
    if self.boostData == nil or #self.boostData == 0 then
        self.boostData = {}
    end
    --全局生效的Boost
    self.globalBoostData = DataManager.GetGlobalDataByKey(DataKey.RewardBoostData)
    if self.globalBoostData == nil or #self.globalBoostData == 0 then
        self.globalBoostData = {}
    end
end

function CityBoost:CreateBoost()
    self.boostItemList = List:New()
    ---@type table<number, List<number>>
    local zoneBoostList = MapManager.GetZoneCardList(self.cityId)
    for zoneId, cardIds in pairs(zoneBoostList) do
        for i = 1, cardIds:Count() do
            local cardId = cardIds[i]
            self:AddCardBoost(zoneId, cardId) 
        end
    end
    if CityManager.GetIsEventScene() then
        self:InitEventBoost()
    end
    for id, data in pairs(self.boostData) do
        self:CreateBoostItem(data)
    end
    for id, data in pairs(self.globalBoostData) do
        self:CreateBoostItem(data)
    end
end

--添加卡牌Boost
function CityBoost:AddCardBoost(toId, cardId)
    local cardConfig = ConfigManager.GetCardConfig(cardId)
    self:AddBoost(cardConfig.boost, toId, cardId)
end

--添加建筑Boost
--toId  就是作用于谁 如果是建筑就是建筑zoneId 如果是暴动就写 protest
--cardId 选填
function CityBoost:AddBoost(boostId, toId, cardId)
    if boostId == nil then
        print("[error]" .. boostId .. "BoostId不能为空")
        return
    end
    local boostConfig = ConfigManager.GetBoostConfig(boostId)
    local scope = boostConfig.scope or "City"
    local data = {}
    data.startTime = ShopManager.GetBoostRewardStartTime(boostId)
    data.boostId = boostId
    data.scope = scope
    data.toId = toId
    data.cardId = cardId
    self:CreateBoostItem(data)
end

--添加奖励性Boost
function CityBoost:AddRewardBoost(boostId, toId)
    local boostConfig = ConfigManager.GetBoostConfig(boostId)
    local scope = boostConfig.scope or "City"
    local data = {}
    data.startTime = TimeManager.GameTime()
    data.boostId = boostId
    data.scope = scope
    data.toId = toId
    self:CreateBoostItem(data)
    if scope == "Global" then
        table.insert(self.globalBoostData, data)
        DataManager.SetGlobalDataByKey(DataKey.RewardBoostData, self.globalBoostData)
    else
        table.insert(self.boostData, data)
        DataManager.SetCityDataByKey(self.cityId, DataKey.RewardBoostData, self.boostData)
    end

    EventManager.Brocast(EventType.REWARD_BOOST_ADD, boostId)
end

--创建BoostItem
function CityBoost:CreateBoostItem(data)
    local config = ConfigManager.GetBoostConfig(data.boostId)
    local model = require(rootPath .. config.logic_name)
    if model then
        self.boostItemList:Add(model:Create(self.cityId, data))
    end
end

--删除Boost依据Id
function CityBoost:RemoveBoostById(toId)
    local i = 1
    while i <= self.boostItemList:Count() do
        if self.boostItemList[i]:GetToId() == toId then
            local data = self.boostItemList[i].boostData
            local targetData
            if data.scope == "Global" then
                targetData = self.globalBoostData
            else
                targetData = self.boostData
            end
            local j = 1
            while j <= #targetData do
                if data == targetData[j] then
                    table.remove(targetData, j)
                else
                    j = j + 1
                end
            end
            self.boostItemList[i]:Quit()
            self.boostItemList:Remove(self.boostItemList[i])
        else
            i = i + 1
        end
    end
    DataManager.SetGlobalDataByKey(DataKey.RewardBoostData, self.globalBoostData)
    DataManager.SetCityDataByKey(self.cityId, DataKey.RewardBoostData, self.boostData)
    EventManager.Brocast(EventDefine.OnBoostRemove)
end

--清空RewardBoost
function CityBoost:ClearRewardBoost()
    for index, data in pairs(self.boostData) do
        self:RemoveBoostById(data.toId)
    end
end

--判断boost是否存在
function CityBoost:HasBoost(boostId)
    local ret = false
    self.boostItemList:ForEach(
        function(item)
            if item:GetId() == boostId then
                ret = true
            end
        end
    )
    return ret
end

--刷新Boost依据toId
function CityBoost:RefreshBoostByToId(toId)
    self.boostItemList:ForEach(
        function(item)
            if item:GetToId() == toId then
                item:Refresh()
            end
        end
    )
end

--刷新Boost依据CardId
function CityBoost:RefreshBoostByCardId(cardId)
    self.boostItemList:ForEach(
        function(item)
            if item:GetCardId() == cardId then
                item:Refresh()
            end
        end
    )
end

--刷新订阅Boost
function CityBoost:RefreshSubscriptionBoost()
    if CityManager.GetIsEventScene() then
        return
    end
    self:ClearSubscriptionBoost()
    -- self:AddBoost("construction_queue2", "sub", nil)
    -- self:AddBoost("fight_speed", "sub", nil)
    -- self:AddBoost("offline_fight_time", "sub", nil)
    local boostRewardArr = ShopManager.GetAllBoostReward()
    LogWarning(JSON.encode(ShopManager.GetAllBoostReward()))
    for index, boostId in pairs(boostRewardArr) do
        self:AddBoost(boostId, "sub", nil)
        LogWarning("Boost: " .. boostId)
    end
    -- LogWarning(JSON.encode(ShopManager.GetAllBoostReward()))
    -- LogWarning("asdasdasdasdad")
    -- self:AddBoost("people_fast_come", "sub", nil)
end

--初始化限时场景Boost
function CityBoost:InitEventBoost()
    local trickList = ConfigManager.GetEventTrickList(self.cityId)
    for index, trickConfig in pairs(trickList) do
        self:AddBoost(trickConfig.boost_id, trickConfig.id, nil)
    end
end

--清理订阅Boost
function CityBoost:ClearSubscriptionBoost()
    local i = 1
    while i <= self.boostItemList:Count() do
        if self.boostItemList[i]:GetFromType() == "Subscription" then
            self.boostItemList[i]:Quit()
            self.boostItemList:Remove(self.boostItemList[i])
        else
            i = i + 1
        end
    end
end

--每秒检测是否有过期的Boost
function CityBoost:UpdatePreSecondFunc()
    self.boostItemList:ForEach(
        function(item)
            return item:CheckExpire()
        end
    )
end

--初始化BoostFactor列表
function CityBoost:InitBoostList()
    -- 材料加成的列表
    self.materialBoostList = Dictionary:New()
    local itemsList = ConfigManager.GetInitItemList(self.cityId)
    itemsList:ForEach(
        function(item)
            self.materialBoostList:Add(item.id, BoostFactor:New())
        end
    )
    self.nessitiesBoostList = Dictionary:New()
    for key, value in pairs(AttributeType) do
        self.nessitiesBoostList:Add(string.format("%s_%d", value, 0), BoostFactor:New())
        self.nessitiesBoostList:Add(string.format("%s_%d", value, 1), BoostFactor:New())
    end
    self.commonBoostList = Dictionary:New()
    for key, value in pairs(CommonBoostType) do
        self.commonBoostList:Add(value, BoostFactor:New())
    end
    self.rxBoostList = Dictionary:New()
    for key, value in pairs(RxBoostType) do
        self.rxBoostList:Add(value, NumberRx:New(0))
    end
    self.foodSpeedList = Dictionary:New()
    for key, value in pairs(FoodLevelType) do
        self.foodSpeedList:Add(value, 0)
    end
    self.eventBoostList = Dictionary:New()
    for key, value in pairs(EventBoostType) do
        self.eventBoostList:Add(value, BoostFactor:New())
    end
    for i = 1, 4 do
        self.eventBoostList:Add("resource_type_" .. i, BoostFactor:New())
    end
end

--获取产出材料的BoostFactor
function CityBoost:GetMaterialBoostFactor(itemid)
    local ret = 1
    if self.materialBoostList[itemid] then
        ret = self.materialBoostList[itemid].factor
    end
    return ret
end

-- --获取产出材料时间的BoostFactor
-- function CityBoost:GetProductTimeBoostFactor(resourceType)
--     local ret = 1
--     if self.productTimeBoostList[resourceType] then
--         ret = self.productTimeBoostList[resourceType].factor
--     end
--     return ret
-- end

function CityBoost:GetBoostFactor(key)
    local ret = 1
    if self.nessitiesBoostList[key] then
        ret = self.nessitiesBoostList[key].factor
    end
    return ret
end

--获取属性影响的BoostFactor
function CityBoost:GetNessitiesBoostFactor(attributeType, isOverTime)
    local factorCommon = self:GetBoostFactor(string.format("%s_%d", attributeType, 0))
    local factorOverTime = 1
    if isOverTime then
        factorOverTime = self:GetBoostFactor(string.format("%s_%d", attributeType, 1))
    end
    return factorCommon * factorOverTime
end

--获取通用BoostFactor
function CityBoost:GetCommonBoosterFactor(boostType)
    local ret = 1
    if self.commonBoostList[boostType] then
        ret = self.commonBoostList[boostType].factor
    end
    return ret
end

--获取Rx BoostFactor
function CityBoost:GetRxBooster(boostType)
    if self.rxBoostList[boostType] then
        return self.rxBoostList[boostType]
    end
    return NumberRx:New(1)
end

--获取Rx value BoostFactor
function CityBoost:GetRxBoosterValue(boostType)
    local ret = 1
    if self.rxBoostList[boostType] then
        ret = self.rxBoostList[boostType].value
    end
    return ret
end

--获取Food的加速 BoostFactor
function CityBoost:GetFoodSpeedValue(foodLevelType)
    local ret = 0
    if self.foodSpeedList[foodLevelType] ~= nil then
        ret = self.foodSpeedList[foodLevelType]
    end
    return ret
end

--获取EventBoostFactor
function CityBoost:GetEventBoosterFactor(boostType)
    local ret = 1
    if self.eventBoostList[boostType] then
        ret = self.eventBoostList[boostType].factor
    end
    return ret
end

--清理
function CityBoost:OnClear()
    self = nil
end

--Log
function CityBoost:Log()
    for ix, data in pairs(self.boostData) do
        Log("City" .. ix .. "| " .. data.type .. "|" .. data.id .. "|" .. data.startTime)
    end
    for ix, data in pairs(self.globalBoostData) do
        Log("Global" .. ix .. "| " .. data.type .. "|" .. data.id .. "|" .. data.startTime)
    end
end
