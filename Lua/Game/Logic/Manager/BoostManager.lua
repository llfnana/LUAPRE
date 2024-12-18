BoostManager = {}
BoostManager._name = "BoostManager"

local this = BoostManager

--初始化
function BoostManager.Init()
    if not this.boostItems then
        this.boostItems = Dictionary:New()
    end
    this.cityId = DataManager.GetCityId()
    if not this.boostItems:ContainsKey(this.cityId) then
        local cityBoost = CityBoost:New(this.cityId)
        this.boostItems:Add(this.cityId, cityBoost)
        cityBoost:CreateBoost()
        if this.boostItems:Count() == 1 then
            EventManager.AddListener(EventType.TIME_REAL_PER_SECOND, this.UpdatePreSecondFunc)
        end
    end
end

--清理
function BoostManager.Clear(force)
    Utils.SwitchSceneClear(this.cityId, this.boostItems, force)
    if this.boostItems:Count() == 0 then
        EventManager.RemoveListener(EventType.TIME_REAL_PER_SECOND, this.UpdatePreSecondFunc)
    end
end

--获取Boost
function BoostManager.GetBoost(cityId)
    return this.boostItems[cityId]
end

--添加Boost
function BoostManager.AddBoost(cityId, boostId, toId, cardId)
    this.boostItems[cityId]:AddBoost(boostId, toId, cardId)
end

--添加卡牌Boost
function BoostManager.AddCardBoost(cityId, toId, cardId)
    this.boostItems[cityId]:AddCardBoost(toId, cardId)
end

--添加奖励型Boost
function BoostManager.AddRewardBoost(cityId, boostId, toId)
    this.boostItems[cityId]:AddRewardBoost(boostId, toId)
end

--清空奖励Boost
function BoostManager.ClearRewardBoost(cityId)
    this.boostItems[cityId]:ClearRewardBoost()
end

--判断boost是否存在
function BoostManager.HasBoost(cityId, boostId)
    return this.boostItems[cityId]:HasBoost(boostId)
end

--删除Boost依据Id
function BoostManager.RemoveBoostById(cityId, toId)
    this.boostItems[cityId]:RemoveBoostById(toId)
end

--更新Boost依据Id
function BoostManager.RefreshBoostByToId(cityId, toId)
    this.boostItems[cityId]:RefreshBoostByToId(toId)
end

--更新Boost依据CardId
function BoostManager.RefreshBoostByCardId(cityId, toId)
    this.boostItems[cityId]:RefreshBoostByCardId(toId)
end

--刷新订阅Boost
function BoostManager.RefreshSubscriptionBoost(cityId)
    this.boostItems[cityId]:RefreshSubscriptionBoost()
end

--每秒检测是否有过期的Boost
function BoostManager.UpdatePreSecondFunc(cityId)
    -- LogWarning("BoostManager.UpdatePreSecondFunc")
    this.boostItems[cityId]:UpdatePreSecondFunc()
end

--获取产出材料的BoostFactor
function BoostManager.GetMaterialBoostFactor(cityId, itemid)
    return this.boostItems[cityId]:GetMaterialBoostFactor(itemid)
end

-- --获取产出材料时间的BoostFactor
-- function BoostManager.GetProductTimeBoostFactor(cityId, resourceType)
--     return this.boostItems[cityId]:GetProductTimeBoostFactor(resourceType)
-- end

--获取属性影响的BoostFactor
function BoostManager.GetNessitiesBoostFactor(cityId, attributeType, isOverTime)
    return this.boostItems[cityId]:GetNessitiesBoostFactor(attributeType, isOverTime)
end

--获取通用BoostFactor
function BoostManager.GetCommonBoosterFactor(cityId, boostType)
    return this.boostItems[cityId]:GetCommonBoosterFactor(boostType)
end

--获取Rx BoostFactor
function BoostManager.GetRxBooster(cityId, boostType)
    return this.boostItems[cityId]:GetRxBooster(boostType)
end

--获取Rx value BoostFactor
function BoostManager.GetRxBoosterValue(cityId, boostType)
    return this.boostItems[cityId]:GetRxBoosterValue(boostType)
end

--获取Food的加速 BoostFactor
function BoostManager.GetFoodSpeedValue(cityId, foodLevelType)
    return this.boostItems[cityId]:GetFoodSpeedValue(foodLevelType)
end

--获取Event BoostFactor
function BoostManager.GetEventBoosterValue(cityId, boostType)
    return this.boostItems[cityId]:GetEventBoosterFactor(boostType)
end

--初始化所有Event Booster
function BoostManager.InitEventBoost(cityId)
    return this.boostItems[cityId]:InitEventBoost()
end

function BoostManager.GetCardBoostEffect(cardId, cardConfig, boostConfig)
    local boostEffectLevel = 1
    if CardManager.IsUnlock(cardId) then
        local cardItemData = CardManager.GetCardItemData(cardId)
        boostEffectLevel = cardItemData:GetCardBoostLevel()
    end
    
    local effect = boostConfig.boost_effects[boostEffectLevel]
    if string.find(cardConfig.boost_type, "resource", 0) == 1 then
        return "x" .. effect
    elseif cardConfig.boost_type == "generator" then
        return "-" .. (effect * 100) .. "%"
    elseif cardConfig.boost_type == "medical" then
        return "+" .. effect
    elseif cardConfig.boost_type == "cook" then
        return "+" .. (effect * 100) .. "%"
    elseif cardConfig.boost_type == "protest" then --治安官
        return "+" .. effect
    end
    
    return tostring(effect)
end

function BoostManager.GetCardBoostEffectByCardId(cardId)
    local cardConfig = ConfigManager.GetCardConfig(cardId)
    if cardConfig == nil then
        return ""
    end
    local boostConfig = ConfigManager.GetBoostConfig(cardConfig.boost)
    if boostConfig == nil then
        return ""
    end

    return BoostManager.GetCardBoostEffect(cardId, cardConfig, boostConfig)
end

function BoostManager.GetCardBoostEffectPreString(boost_type)
    if string.find(boost_type, "resource", 0) == 1 then
        return "x"
    elseif boost_type == "generator" then
        return "-"
    elseif boost_type == "medical" then
        return "+"
    --elseif boost_type == "cook" then
    --    return "+"
    --elseif boost_type == "protest" then --治安官
    --    return "+"
    end
    
    return ""
end

--Log
function BoostManager.Log()
    for ix, data in pairs(this.boostData) do
        Log("City" .. ix .. "| " .. data.type .. "|" .. data.id .. "|" .. data.startTime)
    end
    for ix, data in pairs(this.globalBoostData) do
        Log("Global" .. ix .. "| " .. data.type .. "|" .. data.id .. "|" .. data.startTime)
    end
end
