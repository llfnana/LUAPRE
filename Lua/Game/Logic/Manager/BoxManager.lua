BoxManager = {}
BoxManager._name = "BoxManager"
local this = BoxManager

BoxManager.Action = {
    Buy = "Buy",
    Open = "Open"
}

---@class BoxFixNewConfig : BoxFix
---@field key string
---@field key_index number


function BoxManager.Init()
    this.cityId = DataManager.GetCityId()
    this.boxData = DataManager.GetGlobalDataByKey(DataKey.BoxData)
    if this.boxData == nil then
        this.boxData = this.NewData()
        this.SaveData()
    end

    BoxManager.InitConfig()
    BoxManager.RestoreData()
end

--保存数据
function BoxManager.SaveData()
    DataManager.SetGlobalDataByKey(DataKey.BoxData, this.boxData)
end

function BoxManager.NewData()
    return {
        counter = {},
        guaranteeCounter = {},
        bag = {},
    }
end

function BoxManager.ClearData()
    this.boxData = this.NewData()
    this.SaveData()
end

function BoxManager.InitConfig()
    ---@type BoxFixNewConfig[]
    this.boxFixAllConfig = {}
    local allConfig = ConfigManager.GetBoxFixAllConfig()

    local countMap = {}

    for _, v in pairs(allConfig) do
        local config = Clone(v)
        config.key = this.NewBoxFixKeyByConfig(config)
        table.insert(this.boxFixAllConfig, config)
    end

    --sort
    ---@param a BoxFixNewConfig
    ---@param b BoxFixNewConfig
    table.sort(this.boxFixAllConfig, function(a, b)
        return a.sort < b.sort
    end)

    -- Log("boxFix: " .. JSON.encode(this.boxFixAllConfig))
end

--添加宝箱
function BoxManager.AddBox(boxId, count, from, fromId)
    count = count or 1
    this.boxData.bag[boxId] = this.boxData.bag[boxId] or 0
    this.boxData.bag[boxId] = this.boxData.bag[boxId] + count
    local csObj = {
        currency = boxId,
        value = count,
        balance = this.GetBoxBagCount(boxId),
        from = from,
        fromId = fromId
    }
    Analytics.CurrencySource(csObj)
    this.SaveData()
end

--获取宝箱数量
function BoxManager.GetBoxBagCount(boxId)
    local ret = this.boxData.bag[boxId] or 0
    return ret
end

function BoxManager.RemoveBoxBagCount(boxId)
    this.boxData.bag[boxId] = nil
end

--获取宝箱计数器
function BoxManager.GetBoxCounter(boxId)
    local ret = this.boxData.counter[boxId] or 0
    return ret
end

---@param config BoxFixNewConfig
function BoxManager.NewBoxFixKeyByConfig(config)
    return config.box_id .. "_fix"
end

---返回第一个符合条件的config列表
---@return BoxFixNewConfig[]
function BoxManager.GetFirstBoxFixConfigList(cityId, boxId)
    local configList = {}

    for i = 1, #this.boxFixAllConfig do
        local config = this.boxFixAllConfig[i]
        -- 当key还未赋值，那么判断当前config是否符合条件
        if config.box_id == boxId and config.cityId_start <= cityId then
            key = this.NewBoxFixKeyByConfig(config)
            table.insert(configList, config)
        end
    end

    return configList
end

---获取boxfix计数，从1开始
function BoxManager.GetBoxFixCounter(key)
    return this.boxData.counter[key] or 1
end

---@return BoxFixNewConfig
function BoxManager.GetNewBoxFixConfig(cityId, boxId)
    local configList = this.GetFirstBoxFixConfigList(cityId, boxId)
    if #configList == 0 then
        return nil
    end

    local key = this.NewBoxFixKeyByConfig(configList[1])

    local count = this.GetBoxFixCounter(key)
    if #configList < count then
        return nil
    end

    return configList[count]
end

--增加宝箱计数器
---@param config BoxFixNewConfig
function BoxManager.AddBoxFixCounter(config)
    --local key = boxId .. "C_" .. this.cityId
    --this.boxData.counter[key] = this.boxData.counter[key] or 0
    --this.boxData.counter[key] = this.boxData.counter[key] + 1

    this.boxData.counter[config.key] = this.GetBoxFixCounter(config.key) + 1
    this.SaveData()

    return this.boxData.counter[config.key]
end

--增加宝箱计数器
function BoxManager.AddBoxCounter(boxId)
    this.boxData.counter[boxId] = (this.boxData.counter[boxId] or 0) + 1
    this.SaveData()
end

--获取宝箱保底计数器
function BoxManager.GetBoxGuaranteeCounter(guaranteeGroup)
    local ret = this.boxData.guaranteeCounter["group_" .. guaranteeGroup] or 0
    return ret
end

--增加宝箱保底计数器
function BoxManager.AddBoxGuaranteeCounter(guaranteeGroup)
    this.boxData.guaranteeCounter["group_" .. guaranteeGroup] =
        this.boxData.guaranteeCounter["group_" .. guaranteeGroup] or 0
    this.boxData.guaranteeCounter["group_" .. guaranteeGroup] =
        this.boxData.guaranteeCounter["group_" .. guaranteeGroup] + 1
end

--重置宝箱保底计数器
function BoxManager.ResetBoxGuaranteeCounter(guaranteeGroup)
    this.boxData.guaranteeCounter["group_" .. guaranteeGroup] = 0
end

--获取宝箱物品描述
---@param boxId string
---@return table<string, string>, table<string, string>
function BoxManager.GetBoxRewardDetails(boxId)
    local boxConfig = ConfigManager.GetBoxConfig(boxId)
    if boxConfig ~= nil then
        return boxConfig.detail_show_certain, boxConfig.detail_show_random
    end

    return {}, {}
end

--开新的宝箱
function BoxManager.GetBoxRewardV2(boxId, count, to, toId)
    count = count or 1
    if this.GetBoxBagCount(boxId) < count then
        print("[error]" .. "box not enough: " .. count)
        return
    end

    if count > 1 then
        local ret = {}
        for i = 1, count, 1 do
            local sReward = this.GetBoxRewardV2(boxId, 1, to, toId)
            for ri, rItem in ipairs(sReward) do
                table.insert(ret, rItem)
            end
        end
        Utils.RandomArray(ret)
        return ret
    end

    local reward = this.InspectBox(boxId, this.cityId)

    this.AddBoxCounter(boxId)
    this.SaveData()
    this.boxData.bag[boxId] = this.boxData.bag[boxId] - 1
    local csObj = {
        currency = boxId,
        value = count,
        balance = this.GetBoxBagCount(boxId),
        to = to,
        totoId = toId
    }
    Analytics.CurrencySink(csObj)
    DataManager.AddReward(this.cityId, reward, "BoxOpen", boxId)
    EventManager.Brocast(EventType.OPEN_BOX, this.cityId, BoxManager.Action.Open, boxId, 1)
    return reward
end

---检查
---@return Reward[]
function BoxManager.InspectBox(boxId, cityId)
    local boxConfig = ConfigManager.GetBoxConfig(boxId)
    --local boxFixConfig = this.GetNewBoxFixConfig(cityId, boxId)
    local rewards = {}
    for chanceKey, chanceValue in pairs(boxConfig.chance) do
        --if boxFixConfig == nil then
        if true then
            local chance = this.TryGetBoxGuaranteeChance(boxConfig, chanceKey)
            for i = 1, tonumber(chanceValue) do
                local onceReward = this.GetRewardFromBoxChance(chance, cityId)
                if Utils.GetTableLength(onceReward) > 0 then
                    local addReward = this.TryGetBoxGuaranteeReward(boxConfig, onceReward[1])
                    addReward.origin = RewardAddType.Box
                    addReward.originId = boxConfig.id
                    table.insert(rewards, addReward)
                end
            end
        else
            --rewards = Utils.ParseReward(boxFixConfig.reward)
            --local bfCount = this.AddBoxFixCounter(boxFixConfig)
        end
    end

    rewards = Utils.PressRewards(rewards)
    return rewards
end

---返回指定box在指定city是否可用
function BoxManager.GetAvailableCityId(boxId, cityId)
    local boxConfig = ConfigManager.GetBoxConfig(boxId)
    local available = false
    local minCityId = MathUtil.maxinteger
    for k in pairs(boxConfig.chance) do
        ---@param chanceItem BoxChance
        local chanceList = ConfigManager.GetBoxChance(
            k,
            function(chanceItem)
                if minCityId > chanceItem.city_id then
                    minCityId = chanceItem.city_id
                end

                if chanceItem.city_id <= cityId and cityId <= chanceItem.city_end_id then
                    return true
                end

                return false
            end
        )

        if #chanceList > 0 then
            return true
        end
    end

    return false, minCityId
end

--开箱面板面板
function BoxManager.OpenBox(boxId, count, price, onReOpen, onClose, to, toId, eventSign)
    ShowUI(UINames.UIOpenBox, {
        boxId = boxId,
        count = count,
        price = price,
        reOpen = onReOpen,
        onClose = onClose,
        to = to,
        toId = toId,
        eventSign = eventSign
    })
end

---@param chance string
function BoxManager.GetRewardFromBoxChance(chance, cityId)
    local condition = function(chanceItem)
        if cityId < chanceItem.city_id or cityId > chanceItem.city_end_id then
            return false
        end

        if cityId == chanceItem.city_id then
            if chanceItem.unlock_zone_id == nil or chanceItem.unlock_zone_id == "" then
                return true
            end
            --区域是否有建筑
            local mapItemData = MapManager.GetMapItemData(cityId, chanceItem.unlock_zone_id)
            if mapItemData ~= nil and mapItemData:GetLevel() > 0 then
                return true
            else
                return false
            end
        else
            return true
        end
    end
    local boxChance = ConfigManager.GetBoxChance(chance, condition)
    BoxManager.AdjustChanceWeight(boxChance)
    local weightSum = 0
    for index, chanceItem in pairs(boxChance) do
        weightSum = weightSum + chanceItem.fixWeight
        --LogWarning("chanceItem:" .. chanceItem.chance_group .. "," .. chanceItem.reward .. "," .. chanceItem.fixWeight)
    end
    local random = Mathf.RoundToInt(math.random() * 10000) / 100
    local weightTemp = 0
    local randomIndex = -1
    -- Log("random:" .. random)
    for index, chanceItem in pairs(boxChance) do
        weightTemp = weightTemp + (chanceItem.fixWeight / weightSum) * 100
        if random <= weightTemp then
            randomIndex = index
            break
        end
    end

    if randomIndex == -1 then
        Log("empty random, chance: " .. chance)
        return {}
    end

    local randomItem = boxChance[randomIndex]
    local reward = Utils.ParseReward(randomItem.reward)
    if #reward > 0 and reward[1].count == 0 then
        return {}
    end

    return reward
end

--宝箱平衡机制
function BoxManager.AdjustChanceWeight(boxChance)
    for index, chanceItem in pairs(boxChance) do
        local reward = Utils.ParseReward(chanceItem.reward)
        local selfNum = 1
        if Utils.GetTableLength(reward) > 0 then
            if reward[1].addType == RewardAddType.Card then
                local cardId = reward[1].id
                local cardItemData = CardManager.GetCardItemData(cardId)
                if cardItemData ~= nil then
                    local star = cardItemData:GetStar()
                    local starConfig = ConfigManager.GetCardStarConfig(star)
                    local color = starConfig.color
                    selfNum = selfNum - starConfig.card_req

                    while starConfig ~= nil and starConfig.color == color do
                        selfNum = selfNum + starConfig.card_req
                        star = star - 1
                        starConfig = ConfigManager.GetCardStarConfig(star)
                    end

                    selfNum = selfNum + cardItemData:GetCardCount()
                end
            end
        end

        chanceItem.selfNum = selfNum
    end

    local maxNum = 0
    for index, chanceItem in pairs(boxChance) do
        if chanceItem.selfNum > maxNum then
            maxNum = chanceItem.selfNum
        end
    end

    for index, chanceItem in pairs(boxChance) do
        chanceItem.fixWeight = (maxNum - chanceItem.selfNum) * chanceItem.weight_fix_card + chanceItem.weight
    end
end

--保底机制
function BoxManager.TryGetBoxGuaranteeChance(boxConfig, chance)
    local config = ConfigManager.GetBoxChanceGuarantee()[boxConfig.id]
    if config == nil then
        return chance
    end
    local counter = this.GetBoxGuaranteeCounter(config.guarantee_group)
    if counter >= config.guarantee_require then
        return config.chance_guarantee
    end

    return chance
end

function BoxManager.TryGetBoxGuaranteeReward(boxConfig, reward)
    if reward.addType == "addToCard" and reward.id == nil then
        reward = CardManager.RandomCard(reward)
    end

    local config = ConfigManager.GetBoxChanceGuarantee()[boxConfig.id]
    if config ~= nil then
        this.AddBoxGuaranteeCounter(config.guarantee_group)
        local cardConfig = ConfigManager.GetCardConfig(reward.id)
        if cardConfig ~= nil and cardConfig.color == config.guarantee_reset then
            this.ResetBoxGuaranteeCounter(config.guarantee_group)
        end
    end

    return reward
end

-------------------------
---从老版本数据恢复
function BoxManager.RestoreData()
    local count = 0
    local overflow = 0
    -- 读取counter下是否有high_box_1_2和high_box_3_99，如果存在那么就是老数据，直接修改
    if this.boxData.counter["high_box_1_2"] ~= nil then
        count = this.boxData.counter["high_box_1_2"] - 1
        this.boxData.counter["high_box_1_2"] = nil
        overflow = overflow + 1
    end

    if this.boxData.counter["high_box_3_99"] ~= nil then
        count = count + this.boxData.counter["high_box_3_99"] - 1
        this.boxData.counter["high_box_3_99"] = nil
        overflow = overflow + 1
    end

    -- 溢出的数值只能是1或0
    if overflow == 2 then
        overflow = 1
    end

    if count + overflow ~= 0 then
        this.boxData.counter["high_box_fix"] = count + overflow
        LogWarning("BoxManager restoreData")
        this.SaveData()
    end
end
