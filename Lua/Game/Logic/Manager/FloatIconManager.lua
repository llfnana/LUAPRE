FloatIconManager = {}
FloatIconManager.__cname = "FloatIconManager"

local spDailyItem = "Daily_Ad_Times"
local spDailyFirstGet = "Daily_Ad_First_Get"

local getItemByWeight = function(itemList)
    local itemT = {}
    local itemWeight = {}
    local index = 1
    for num, item in pairs(itemList) do
        itemT[num] = item
        local itemCfg = ConfigManager.GetItemConfig(item)
        itemWeight[num] = itemCfg.ad_weight
        Log("随机奖励选项 " .. item .. " 权重" .. itemWeight[num])
    end
    local itemId = Utils.RandomByWeight(itemT, itemWeight)
    return itemId
end

local this = FloatIconManager
local _randType = {
    [AdRandType.burning_material] = {
        canGet = function()
            local cityId = DataManager.GetCityId()
            local zoneId = GeneratorManager.GetZoneId(cityId)
            local itemId = GeneratorManager.GetConsumptionItemId(cityId)
            if DataManager.CheckInfinity(cityId, itemId) then
                -- print("zhkxin 可获取燃料：不能，原因：无穷资源" )
                return false
            end
            local itemCount = GeneratorManager.GetCount(cityId) / 60
            local burnMinite = DataManager.GetMaterialCount(cityId, itemId) / itemCount
            local cityClock = TimeManager.GetClock(cityId)
            local minuteToMorning = 0
            if cityClock ~= nil then
                minuteToMorning = ((24 + 8 - cityClock.hour - 1) * 60 + (60 - cityClock.minute)) / 2
            end
            -- local isNight = TimeManager.GetCityIsNight(cityId)
            -- print("zhkxin 可获取燃料", ((not this.IsActionCity()) and isNight and (burnMinite < minuteToMorning)), ", 黑夜: " .. tostring(isNight), ", 燃料不足 ", tostring((burnMinite < minuteToMorning)))
            return (not this.IsActionCity()) and (burnMinite < minuteToMorning) -- and isNight
        end,
        reward = function()
            local reward = {}
            local cityId = DataManager.GetCityId()
            local itemId = GeneratorManager.GetConsumptionItemId(cityId)
            local itemCount = GeneratorManager.GetCount(cityId) / 60
            local countAward =
            itemCount * ConfigManager.GetAdResourceRewardConfigByType(AdRandType.burning_material).reward_value
            local minAwardCount = ConfigManager.GetItemConfig(itemId).ad_rewards_limit
            local maxAwardCount = ConfigManager.GetItemConfig(itemId).ad_rewards_max
            local finalAward = math.max(countAward, minAwardCount)
            if (finalAward < 10000) then
                finalAward = Mathf.RoundToInt(finalAward)
            end
            if (maxAwardCount > 0) then
                finalAward = math.min(maxAwardCount, finalAward)
            end
            reward[itemId] = finalAward
            return reward
        end
    },
    [AdRandType.food_material] = {
        canGet = function()
            local cityId = DataManager.GetCityId()
            if (this.IsActionCity()) then
                return false
            end
            local buildMatList = this.GetResEventTypeList(AdRandType.food_material, cityId)
            if buildMatList:Count() <= 0 then
                return false
            end
            local baseFood = DataManager.GetCityDataByKey(cityId, DataKey.FoodType)
            local output = {}
            output[baseFood] =
            CharacterManager.GetCharacterCount(cityId) *
                ConfigManager.GetAdResourceRewardConfigByType(AdRandType.food_material).reward_value
            local input = ConfigManager.GetInputByOutput(output)
            local reward = input
            for type, int in pairs(reward) do
                if (DataManager.GetMaterialCount(cityId, type) < int) then
                    -- Log("Ad 肉 现在也缺")
                    return true
                end
            end
            Log("Ad 肉 原来缺，现在不缺食物了")
            return false
        end,
        reward = function()
            local cityId = DataManager.GetCityId()
            local baseFood = ConfigManager.GetDefaultFoodType(cityId)
            local output = {}
            output[baseFood] = 1
            local input = ConfigManager.GetInputByOutput(output)
            local reward = input
            for type, int in pairs(reward) do
                local minAwardCount = ConfigManager.GetItemConfig(type).ad_rewards_limit
                local maxAwardCount = ConfigManager.GetItemConfig(type).ad_rewards_max
                local countAward =
                int * CharacterManager.GetCharacterCount(cityId) *
                    ConfigManager.GetAdResourceRewardConfigByType(AdRandType.food_material).reward_value
                local finalAward = math.max(countAward, minAwardCount)
                if (finalAward < 10000) then
                    finalAward = Mathf.RoundToInt(finalAward)
                end
                if (maxAwardCount > 0) then
                    finalAward = math.min(maxAwardCount, finalAward)
                end
                reward[type] = finalAward
                Log(
                    "食物计算 单人消耗 itemId:" ..
                    type ..
                    " num:" ..
                    int ..
                    " 人数:" ..
                    CharacterManager.GetCharacterCount(cityId) ..
                    " 奖励系数:" ..
                    ConfigManager.GetAdResourceRewardConfigByType(AdRandType.food_material).reward_value ..
                    "计算结果:" ..
                    countAward ..
                    " 最小奖励:" .. minAwardCount .. " 最大奖励:" .. maxAwardCount
                )
            end
            return reward
        end
    },
    [AdRandType.product_material] = {
        canGet = function()
            local cityId = DataManager.GetCityId()
            local buildMatList = this.GetResEventTypeList(AdRandType.product_material, cityId)
            return buildMatList:Count() > 0
        end,
        reward = function()
            return { Wood = 100 }
        end
    },
    [AdRandType.building_material] = {
        canGet = function()
            local cityId = DataManager.GetCityId()
            if (this.IsActionCity()) then
                return false
            end
            local buildMatList = this.GetResEventTypeList(AdRandType.building_material, cityId)
            Log("Can Get Building_Material " .. buildMatList:Count())
            return buildMatList:Count() > 0
        end,
        reward = function()
            local cityId = DataManager.GetCityId()
            local buildMatList = this.GetResEventTypeList(AdRandType.building_material, cityId)
            local itemId = getItemByWeight(buildMatList)
            local reward = {}
            local itemProductPerSec = StatisticalManager.GetOutputProductionsPerSecond(DataManager.GetCityId(), itemId)
            local minAwardCount = ConfigManager.GetItemConfig(itemId).ad_rewards_limit
            local countAward =
            itemProductPerSec *
                ConfigManager.GetAdResourceRewardConfigByType(AdRandType.building_material).reward_value
            local finalCount = math.max(countAward, minAwardCount)
            local maxAwardCount = ConfigManager.GetItemConfig(itemId).ad_rewards_max
            if maxAwardCount > 0 then
                finalCount = math.min(finalCount, maxAwardCount)
            end
            if (finalCount < 10000) then
                reward[itemId] = Mathf.RoundToInt(finalCount)
            else
                reward[itemId] = finalCount
            end
            Log(
                "建筑材料计算 itemId:" ..
                itemId ..
                " 秒产:" ..
                itemProductPerSec ..
                " 奖励系数:" ..
                ConfigManager.GetAdResourceRewardConfigByType(AdRandType.building_material).reward_value ..
                " 计算结果:" ..
                countAward ..
                " 最小奖励:" ..
                minAwardCount .. " 最大奖励:" .. maxAwardCount .. " 最终结果:" .. finalCount
            )
            return reward
        end
    },
    [AdRandType.BlackCoin] = {
        canGet = function()
            local function IsFuncUnlock()
                return FunctionsManager.IsOpen(DataManager.GetCityId(), FunctionsType.Fight)
            end

            return IsFuncUnlock()
        end,
        reward = function()
            -- local coinPerSec = AdventureContManager.secondCreatBC()
            local awardSec = ConfigManager.GetAdResourceRewardConfigByType(AdRandType.BlackCoin).reward_value
            -- local minAwardCount = ConfigManager.GetItemConfig("BlackCoin").ad_rewards_limit
            local countAward = awardSec --Mathf.RoundToInt(coinPerSec * awardSec)
            Log("黑市币计算 固定产出:" .. awardSec .. " 计算结果:" .. countAward)
            return { BlackCoin = countAward }
        end
    },
    [AdRandType.PlayCoin] = {
        canGet = function()
            return this.IsActionCity()
        end,
        reward = function()
            local cityId = DataManager.GetCityId()
            local coinId = ConfigManager.GetItemByType(cityId, "PlayCoin").id
            local awardConfig = ConfigManager.GetAdResourceRewardConfigByType(AdRandType.PlayCoin).reward_value
            local countAward = awardConfig
            Log("活动币计算 类型id:" .. coinId .. " 固定产出:" .. awardConfig .. " 计算结果:" ..
                countAward)
            local reward = {}
            reward[coinId] = countAward
            return reward
        end
    },
    [AdRandType.Cash] = {
        canGet = function()
            return this.IsActionCity()
        end,
        reward = function()
            local cityId = DataManager.GetCityId()
            local cashId = ConfigManager.GetItemByType(cityId, "Cash").id
            local awardConfig = ConfigManager.GetAdResourceRewardConfigByType(AdRandType.Cash).reward_value
            local countAward = OverTimeProductionManager.Get(cityId):Get(cashId, awardConfig, 1)
            local minAwardCount = ConfigManager.GetItemConfig(cashId).ad_rewards_limit
            local finalCount = math.max(countAward, minAwardCount)
            local maxAwardCount = ConfigManager.GetItemConfig(cashId).ad_rewards_max
            if maxAwardCount > 0 then
                finalCount = math.min(finalCount, maxAwardCount)
            end
            Log(
                "现金计算 类型id:" ..
                cashId ..
                " 计算结果:" ..
                countAward ..
                " 最小值:" ..
                minAwardCount .. " 最大奖励:" .. maxAwardCount .. " 最终结果:" .. finalCount
            )
            local reward = {}
            reward[cashId] = finalCount
            return reward
        end
    },
    [AdRandType.Heart] = {
        canGet = function()
            local function IsFuncUnlock()
                return FunctionsManager.IsOpen(DataManager.GetCityId(), FunctionsType.Fight)
            end

            local function HasHeart()
                local cityId = DataManager.GetCityId()
                local heartItem = ConfigManager.GetItemByType(cityId, "Heart")
                if (heartItem == nil) then
                    return false
                end
                return true
            end

            return (this.IsActionCity() and HasHeart()) or ((not this.IsActionCity()) and IsFuncUnlock())
        end,
        reward = function()
            local cityId = DataManager.GetCityId()
            local heartItem = ConfigManager.GetItemByType(cityId, "Heart")
            local heartId = ""
            if (this.IsActionCity()) then
                heartId = heartItem.id
            else
                heartId = "Heart"
            end
            local coinPerSec =0-- AdventureContManager.secondCreatBC()
            local awardSec = ConfigManager.GetAdResourceRewardConfigByType(AdRandType.Heart).reward_value
            local minAwardCount = ConfigManager.GetItemConfig(heartId).ad_rewards_limit
            local countAward = coinPerSec * awardSec
            if (countAward < 10000) then
                countAward = Mathf.RoundToInt(countAward)
            end
            Log(
                "希望之心计算 类型:" ..
                heartId ..
                " 秒产:" ..
                coinPerSec .. " 奖励系数:" .. awardSec .. " 计算结果:" .. countAward .. " 最小奖励:" ..
                minAwardCount
            )
            local reward = {}
            reward[heartId] = math.max(countAward, minAwardCount)
            return reward
        end
    },
    [AdRandType.HeartByBuilding] = {
        canGet = function()
            return this.IsActionCity()
        end,
        reward = function()
            local cityId = DataManager.GetCityId()
            local itemId = ConfigManager.GetItemByType(cityId, "Heart").id
            local reward = {}
            local itemProductPerSec = StatisticalManager.GetOutputProductionsPerSecond(DataManager.GetCityId(), itemId)
            local minAwardCount = ConfigManager.GetItemConfig(itemId).ad_rewards_limit
            local countAward =
            itemProductPerSec *
                ConfigManager.GetAdResourceRewardConfigByType(AdRandType.HeartByBuilding).reward_value
            local finalCount = math.max(countAward, minAwardCount)
            local maxAwardCount = ConfigManager.GetItemConfig(itemId).ad_rewards_max
            if maxAwardCount > 0 then
                finalCount = math.min(finalCount, maxAwardCount)
            end
            if (finalCount < 10000) then
                reward[itemId] = Mathf.RoundToInt(finalCount)
            else
                reward[itemId] = finalCount
            end
            Log(
                "HeartByBuild计算 itemId:" ..
                itemId ..
                " 秒产:" ..
                itemProductPerSec ..
                " 奖励系数:" ..
                ConfigManager.GetAdResourceRewardConfigByType(AdRandType.HeartByBuilding).reward_value ..
                " 计算结果:" ..
                countAward ..
                " 最小奖励:" ..
                minAwardCount ..
                " 最大奖励:" ..
                maxAwardCount ..
                " 最终结果:" .. finalCount .. " 化简后：" .. reward[itemId]
            )
            return reward
        end
    }
}

function FloatIconManager.Init()
    this.cityId = DataManager.GetCityId()
    Log("Init City Id " .. this.cityId)
    this.countHideIcon = 0
    this.countShowIcon = 0
    this.currentCD = 0
    this.isHideIcon = false
    this.isFirstShow = true
    this.isPanelOpening = false
    this.resEventList = {}
    this.resEventNum = {}
    this.lastReward = {}
    EventManager.AddListener(EventType.TIME_REAL_PER_SECOND, this.UpdatePerSecFunc)
    EventManager.AddListener(EventType.REWARD_BOOST_ADD, this.CheckRewardType)
end

function FloatIconManager.IsFirstShow()
    return DailyBagManager.GetItem(spDailyFirstGet, nil) < 1
end

function FloatIconManager.SetFirstShow()
    DailyBagManager.AddItem(spDailyFirstGet, 1, nil, "AdResource", "FirstGet")
end

function FloatIconManager.AddDailyItem(fromId)
    DailyBagManager.AddItem(spDailyItem, 1, nil, "AdResource", fromId)
end

function FloatIconManager.Clear()
    EventManager.RemoveListener(EventType.TIME_REAL_PER_SECOND, this.UpdatePerSecFunc)
    EventManager.RemoveListener(EventType.REWARD_BOOST_ADD, this.CheckRewardType)
end

function FloatIconManager.AddResEvent(type, res, time)
    local cityId = DataManager.GetCityId()
    if time == nil then
        time = 300
    end
    if type == AdRandType.building_material and res == "BlackCoin" then
        return
    end
    if this.resEventList[cityId] == nil then
        this.resEventList[cityId] = {}
        this.resEventNum[cityId] = {}
    end
    if this.resEventList[cityId][type] == nil then
        this.resEventList[cityId][type] = {}
        this.resEventNum[cityId][type] = 0
    end
    if this.resEventList[cityId][type][res] == nil then
        this.resEventNum[cityId][type] = this.resEventNum[cityId][type] + 1
    end
    this.resEventList[cityId][type][res] = time
    -- Log("记录缺少资源 " .. type .. " " .. res .. " 目前已有 " .. this.resEventNum[cityId][type])
end

function FloatIconManager.AddProductLackEvent(config)
    local output = config.output
    for itemId, num in pairs(output) do
        local outputConfig = ConfigManager.GetItemConfig(itemId)
        local input = ConfigManager.GetInputByOutput(output)
        for item, n in pairs(input) do
            if outputConfig.type == "Food" then
                FloatIconManager.AddResEvent(AdRandType.food_material, item, 600)
            else
                FloatIconManager.AddResEvent(AdRandType.product_material, item)
            end
        end
    end
end

function FloatIconManager.GetResEventTypeList(type, cityId)
    local list = List:New()
    if this.resEventList[cityId] == nil then
    elseif (this.resEventList[cityId][type] == nil) then
    else
        for type, num in pairs(this.resEventList[cityId][type]) do
            if num ~= nil and type ~= "BlackCoin" then
                list:Add(type)
            end
        end
    end
    return list
end

function FloatIconManager.UpdateResEvent(cityId)
    if this.resEventList[cityId] == nil then
        return
    end
    for eventType, list in pairs(this.resEventList[cityId]) do
        for type, time in pairs(list) do
            if time ~= nil then
                list[type] = time - 1
            end
            if list[type] <= 0 and
                (eventType ~= AdRandType.building_material or this.resEventNum[cityId][eventType] > 3)
            then
                list[type] = nil
                this.resEventNum[cityId][eventType] = this.resEventNum[cityId][eventType] - 1
            end
        end
    end
end

function FloatIconManager.CheckRewardType(boostId)
    local config = ConfigManager.GetBoostConfig(boostId)
    function IsReward()
        return config.from_type == "Reward"
    end

    function IsEvent()
        return config.scope == "Event"
    end

    function HasBoostEffect()
        return config.boost_effects[1] > 0
    end

    local isCashEffect = IsEvent() and IsReward() and HasBoostEffect()
    if (isCashEffect) then
        if (not this.isHideIcon) then
            this.SetConsumptionAwardIcon(false)
        end
    end
end

function FloatIconManager.UpdatePerSecFunc(cityId)
    -- LogWarning("FloatIconManager.UpdatePerSecFunc")
    this.UpdateResEvent(cityId)
    if this.cityId ~= cityId then
        return
    end
    if this.isPanelOpening then
        return
    end
    if (this.isHideIcon) then
        this.countHideIcon = this.countHideIcon + 1 -- 30
        if (this.countHideIcon >= this.GetRandCD()) then
            this.SetConsumptionAwardIcon(true, this.IsAdFree())
        end
    else
        this.countShowIcon = this.countShowIcon + 1 -- 5
        if (this.countShowIcon >= this.GetShowDuration()) then
            this.SetConsumptionAwardIcon(false)
        end
    end
end

function FloatIconManager.InitIconShow()
    this.SetConsumptionAwardIcon(false)
end

function FloatIconManager.GetRandCD()
    if this.currentCD <= 0 then
        if this.IsFirstShow() then
            local rand1 = ConfigManager.GetMiscConfig("ad_resource_icon_first_show")[1]
            local rand2 = ConfigManager.GetMiscConfig("ad_resource_icon_first_show")[2]
            this.currentCD = math.random(rand1, rand2)
        else
            local rand1 = ConfigManager.GetMiscConfig("ad_resource_icon_cd")[1]
            local rand2 = ConfigManager.GetMiscConfig("ad_resource_icon_cd")[2]
            this.currentCD = math.random(rand1, rand2)
        end
    end
    return this.currentCD
end

function FloatIconManager.GetMaxWaitingTime()
    return ConfigManager.GetMiscConfig("ad_resource_icon_max_show")
end

function FloatIconManager.GetShowDuration()
    return ConfigManager.GetMiscConfig("ad_resource_icon_show_cd")[1]
end

-- 是否可以显示广告
-- 1.配置表开关， 2.隐藏状态， 3.cd时间到了， 4.功能解锁，5.当前城市，6.没完成引导或已完成引导且没超过今天可看广告的最大次数，7.免费或有奖励
function FloatIconManager.IsIconCanShow()
    local function IsConfigOpen()
        -- print("zhkxin IsIconCanShow IsConfigOpen: ", (ConfigManager.GetMiscConfig("ads_switch")))
        return ConfigManager.GetMiscConfig("ads_switch")
    end

    local function IsHide()
        -- print("zhkxin IsIconCanShow IsHide: ", this.isHideIcon)
        return this.isHideIcon
    end

    local function IsCDOver()
        -- print("zhkxin IsIconCanShow IsCDOver: ", (this.countHideIcon >= this.GetRandCD()), this.countHideIcon, this.GetRandCD())
        return this.countHideIcon >= this.GetRandCD()
    end

    local function IsFuncUnlock()
        -- print("zhkxin IsIconCanShow IsFuncUnlock: ", (FunctionsManager.IsOpen(DataManager.GetCityId(), FunctionsType.Ads)))
        return FunctionsManager.IsOpen(DataManager.GetCityId(), FunctionsType.Ads)
    end

    local function HasActiveReward()
        this.nextAward = this.GetActiveReward()
        -- print("zhkxin IsIconCanShow HasActiveReward: ", (this.nextAward ~= nil))
        return this.nextAward ~= nil
    end

    local function IsMaxCity()
        -- print("zhkxin IsIconCanShow IsMaxCity: ", (DataManager.GetCityId() == DataManager.GetMaxCityId()))
        return DataManager.GetCityId() == DataManager.GetMaxCityId()
    end

    local function IsMaxDaily()
        -- print("zhkxin IsIconCanShow IsMaxDaily: ", "已看广告次数：", DailyBagManager.GetItem(spDailyItem, nil), "每日最大可看广告次数：", ConfigManager.GetMiscConfig("ad_resource_claim_limit_daily"))
        return DailyBagManager.GetItem(spDailyItem, nil) >= ConfigManager.GetMiscConfig("ad_resource_claim_limit_daily")
    end

    return IsConfigOpen() and IsHide() and IsCDOver() and IsFuncUnlock() and (IsMaxCity() or this.IsActionCity()) and
        (this.IsAdFree() or not IsMaxDaily()) and
        (this.IsAdFree() or HasActiveReward())
end

function FloatIconManager.IsActionCity()
    return CityManager.GetIsEventScene(DataManager.GetCityId())
end

-- 消费奖励图标
function FloatIconManager.SetConsumptionAwardIcon(show, isFree)
    if (show and not (this.IsIconCanShow())) then
        -- 不能显示广告，则进行新一轮的隐藏
        this.countHideIcon = 0
        return 
    end

    this.isHideIcon = not show
    if (show) then
        local lockIndex = nil
        if this.IsAdFree() then
            lockIndex = AdRandType.burning_material
        end
        this.lastReward = this.RandAdAward(lockIndex)
        if this.lastReward == nil then
            LogWarning("Ad 无可用广告奖励")
            return
        end
        Analytics.Event("adIconShow", { cityId = DataManager.GetCityId(), from = "AdResource" })
        this.countHideIcon = 0
        this.currentCD = 0
        EventManager.Brocast(EventType.REFRESH_AD_VIDEO, this.lastReward.reward)
    else
        EventManager.Brocast(EventType.REFRESH_AD_VIDEO)
        this.countShowIcon = 0
    end
end

-- function FloatIconManager.AddConsumptionAward()
--     local count = GeneratorManager.GetConsumptionCount(this.cityId)
--     if count <= 0 then
--         count = GeneratorManager.GetCount(this.cityId)
--         count = count * ConfigManager.GetMiscConfig("generator_overload_resource_times")
--     end
--     count = count * ConfigManager.GetMiscConfig("ads_resource_per_minute")
--     local type = GeneratorManager.GetConsumptionItemId(this.cityId)
--     DataManager.AddMaterial(this.cityId, type, count)
--     GameToast.Instance:Show(string.format("播放1个广告。获取了燃料 " .. type .. "x" .. count))
--     this.SetConsumptionAwardIcon(false)
-- end

--[[
    function:获得随机奖励
    param1:是否锁定获得
    return:奖励列表
]]
function FloatIconManager.RandAdAward(lockIndex)
    local reward = {
        reward = {},
        fromId = ""
    }
    if lockIndex ~= nil then
        reward.fromId = lockIndex
        Log("是否免费 " .. tostring(lockIndex ~= nil) .. " 奖励类型 " .. reward.fromId)
        reward.reward = _randType[lockIndex].reward()
    else
        local activeRewardType = {}
        local weightByType = {}
        local typeIndex = 1
        local cityId = DataManager.GetCityId()
        local totalWeight = 0
        for type, data in pairs(_randType) do
            if data.canGet() then
                activeRewardType[typeIndex] = type
                weightByType[typeIndex] = ConfigManager.GetAdWeightByCityId(cityId, type)
                -- Log("type " .. type)
                -- Log(" weight " .. weightByType[typeIndex].." "..tostring(totalWeight))
                totalWeight = totalWeight + weightByType[typeIndex]
                typeIndex = typeIndex + 1
            end
        end
        if typeIndex == 1 then
            return nil
        end
        if totalWeight == 0 then
            return nil
        end
        reward.fromId = Utils.RandomByWeight(activeRewardType, weightByType)
        Log("是否免费 " .. tostring(lockIndex ~= nil) .. " 奖励类型 " .. reward.fromId)
        reward.reward = _randType[reward.fromId].reward()
    end
    for type, num in pairs(reward.reward) do
        Log("奖励内容 " .. type .. ":" .. num)
    end
    return reward
end

function FloatIconManager.GetActiveReward()
    local activeRewardType = {}
    local weightByType = {}
    local typeIndex = 1
    local reward = {}
    local totalWeight = 0
    for type, data in pairs(_randType) do
        if data.canGet() then
            if ConfigManager.GetAdResourceRewardConfigByType(type).weight ~= nil and
                ConfigManager.GetAdResourceRewardConfigByType(type).weight > 0
            then
                activeRewardType[typeIndex] = type
                weightByType[typeIndex] = ConfigManager.GetAdResourceRewardConfigByType(type).weight
                totalWeight = totalWeight + weightByType[typeIndex]
                typeIndex = typeIndex + 1
            end
        end
    end
    if totalWeight == 0 then
        return nil
    end
    if (#activeRewardType > 0) then
        reward.fromId = Utils.RandomByWeight(activeRewardType, weightByType)
        if reward.fromId == nil then
            return nil
        end
        reward.reward = _randType[reward.fromId].reward()
    else
        reward = nil
    end
    return reward
end

function FloatIconManager.GetAdAward(reward)
    for type, count in pairs(reward) do
        DataManager.AddMaterial(this.cityId, type, count, "AdResource", "RewardId" .. this.lastRewardId)
        -- if type == ItemType.BlackCoin or type == ItemType.Heart or type == ItemType.Gem then
        --     local csObj = {
        --         currency = type,
        --         value = count,
        --         balance = DataManager.GetMaterialCount(DataManager.GetCityId(), type),
        --         from = "AdResource",
        --         fromId = "RewardId" .. this.lastRewardId
        --     }
        --     Analytics.Event("CurrencySource", csObj)
        -- end
    end
end

function FloatIconManager.Check()
    if (this.lastReward == nil or this.lastReward.reward == nil) then
        this.SetConsumptionAwardIcon(false)
        return false
    end
    return true
end

function FloatIconManager.OnCloseAdPanel()
    this.isPanelOpening = false
    this.SetConsumptionAwardIcon(false)
end

function FloatIconManager.OnConsumptionAwardIconClick()
    local reward = this.lastReward
    local isFree = this.IsAdFree()
    if AdManager.CheckMaxWatch() then 
        return
    end

    ShowUI(UINames.UIAd, {reward = reward.reward, isFree = isFree, onReceive = function()
        if (reward == nil or reward.reward == nil) then
            return
        end
        this.GetAdAward(reward.reward)
        -- 需要对 reward 格式进行转换{addType = , id = , count = }
        local formatReward = {}
        for key, value in pairs(reward.reward) do
            table.insert(formatReward, {
                addType = RewardAddType.Item, 
                id = key, 
                count = value
            })
        end
        
        ResAddEffectManager.AddResEffectFromRewards(formatReward, false, {})
        this.SetConsumptionAwardIcon(false)
        if (not isFree) then
            this.AddDailyItem(reward.fromId)
            this.SetFirstShow()
        end
    end})
    -- PopupManager.Instance:OpenPanel(
    --     PanelType.AdAwardPanel,
    --     {
    --         isFree = isFree,
    --         Rewards = reward.reward,
    --         OnYesFunc = function()
    --             if (reward == nil or reward.reward == nil) then
    --                 this.SetConsumptionAwardIcon(false)
    --                 return
    --             end
    --             this.GetAdAward(reward.reward)
    --             this.SetConsumptionAwardIcon(false)
    --             if (not isFree) then
    --                 this.AddDailyItem(reward.fromId)
    --                 this.SetFirstShow()
    --             end
    --         end,
    --         fromId = reward.fromId
    --     }
    -- )
    this.lastReward = reward.reward
    this.lastRewardId = reward.fromId
    this.isPanelOpening = true
end

-- 是否是免费的广告（在没有完成xxx任务之前，都是免费的）
function FloatIconManager.IsAdFree()
    return not TutorialManager.IsComplete(ConfigManager.GetMiscConfig("ad_resource_free_get")[1])
end

-- function FloatIconManager.OnCloseAdPanel(hasGetReward)
--     --TODO
--     local cityId = DataManager.GetCityId()
--     Log("广告面板关闭，是否获得奖励？" .. tostring(hasGetReward))
--     this.SetConsumptionAwardIcon(false)
--     this.isPanelOpening = false
--     if hasGetReward then
--         for type, num in pairs(this.lastReward) do
--             local msg = GetLangFormat("toast_ads_get_reward", this.GetItemName(type), num)
--             Log(msg)
--             AudioManager.PlayEffect("ui_reward_click")
--             -- GameToast.Instance:Show(msg, Color.black)
--             if this.lastRewardId == AdRandType.food_material then
--                 this.RemoveResEvent(this.lastRewardId, type, cityId)
--             end
--         end
--     else
--         if this.lastRewardId == AdRandType.building_material or this.lastRewardId == AdRandType.food_material then
--             for type, num in pairs(this.lastReward) do
--                 this.RemoveResEvent(this.lastRewardId, type, cityId)
--             end
--         end
--     end
-- end

function FloatIconManager.RemoveResEvent(type, res, cityId)
    if this.resEventList[cityId] ~= nil and this.resEventList[cityId][type] ~= nil and this.resEventList[cityId][type][res] ~= nil then
        this.resEventList[cityId][type][res] = nil
        this.resEventNum[cityId][type] = this.resEventNum[cityId][type] - 1
        Log("剩余原料队列 " .. this.resEventNum[cityId][type])
    end
end

function FloatIconManager.GetItemName(itemId)
    local cfg = ConfigManager.GetItemConfig(itemId)
    return GetLang(cfg.name_key)
end
