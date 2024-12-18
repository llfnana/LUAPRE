CardManager = {}
CardManager._name = "CardManager"

local this = CardManager

local nofirst = false
function CardManager.Init()
    if nofirst == true then
        return
    end
    nofirst = true
    this.maxBattle = 5
    this.cardData = DataManager.GetGlobalDataByKey(DataKey.CardData)
    if this.cardData == nil then
        this.cardData = {}
        this.cardData.cards = {}
        this.cardData.eventCards = {}
        this.cardData.battleArray = {}
        this.cardData.teamPosArray = {} --暂时这样写，这版以后重构 todo gao
        this.cardData.battleLevel = 1
        this.cardData.HangupRewardData = {}
        this.cardData.hangupRemaintime = 0
        this.cardData.isClickSpeedBtn = 0
        this.SaveCardData()
    elseif TutorialManager.CurrentStep.value == TutorialStep.ToBattle and TutorialManager.CurrentSubStep.value < 7 then
        this.cardData.battleArray = {}
        this.cardData.battleLevel = 1
        this.cardData.teamPosArray = {}
    end
    this.cardItemList = Dictionary:New()
    for cardId, cardItem in pairs(this.cardData.cards) do
        local cardItemData = CardItemData:New()
        cardItemData:Init(cardItem)
        this.cardItemList:Add(cardItem.id, cardItemData)
    end
    CardManager.checkBattleCardData()
    this.InitEventCardData()
end

--初始化event数据
function CardManager.InitEventCardData()
    if this.cardData.eventCards == nil then
        this.cardData.eventCards = {}
    end
    for cardId, cardItem in pairs(this.cardData.eventCards) do
        local cardItemData = CardItemData:New()
        cardItemData:Init(cardItem)
        this.cardItemList:Add(cardItem.id, cardItemData)
    end
    this.SaveCardData()
end

--LogUpdateCardFarm
function CardManager.LogUpdateCardFarm()
    if FunctionsManager.IsOpen(DataManager.GetCityId(), FunctionsType.Cards) then
        local cardFarmDetail = CardManager.GetUpdateCardFarm()
        Analytics.Event("UpdateCardFarm", { cardFarmDetail = cardFarmDetail })
    end
end

--重置event数据
function CardManager.ResetEventCardData(cityId)
    this.cardData.eventCards = {}
    local cardItemListNew = Dictionary:New()
    this.cardItemList:ForEachKeyValue(
        function(cardId, item)
            if this.GetCardCityValue(item.config, CityType.Event) ~= cityId then
                cardItemListNew:Add(cardId, item)
            end
        end
    )
    this.cardItemList = cardItemListNew
    this.SaveCardData()
end

--为了兼容老版本
function CardManager.checkBattleCardData()
    for key, value in pairs(this.cardData.battleArray) do
        if type(key) == "number" then
            this.cardData.battleArray = {}
            this.cardData.teamPosArray = {}
            this.cardData.isClickSpeedBtn = 0
            break
        end
    end
end

--保存卡牌数据
function CardManager.SaveCardData()
    DataManager.SetGlobalDataByKey(DataKey.CardData, this.cardData)
end

--获取卡牌CardItemData
---@return CardItemData
function CardManager.GetCardItemData(cardId)
    return this.cardItemList[cardId]
end

--设置卡牌CardItemData
function CardManager.SetCardItemData(cardId, count)
    cardId = tonumber(cardId)
    count = count or 1
    local cardConfig = ConfigManager.GetCardConfig(cardId)
    local isFirstGet = false
    local cards = this.GetCards()
    if this.GetCardCityValue(cardConfig, CityType.City) > 0 then
        cards = this.cardData.cards
    end
    local cardItemData
    if cards["card_" .. cardId] then
        cardItemData = this.GetCardItemData(cardId)
        cardItemData:AddCard(count)
    else
        count = count - 1
        local ret, ob = this.CreateCardItem(cardConfig, count)
        cardItemData = ret
        cards["card_" .. cardConfig.id] = ob
        this.cardItemList:Add(cardId, cardItemData)
        isFirstGet = true
    end
    this.SaveCardData()
    return isFirstGet
end

--添加卡牌
function CardManager.AddCard(cardId, count, from, fromId)
    local isFirstGet = this.SetCardItemData(cardId, count)
    local cardConfig = ConfigManager.GetCardConfig(cardId)
    local cardItemData = this.GetCardItemData(cardId)
    Analytics.Event(
        "CardCopyAdd",
        {
            isFirstGet = isFirstGet,
            bornColor = cardConfig.color,
            cardId = cardId,
            from = from,
            fromId = fromId,
            value = count,
            copyBalance = cardItemData:GetCardCount()
        }
    )
    EventManager.Brocast(EventType.ADD_CARD, DataManager.GetCityId(), cardId)
end

--创建CardItemData
function CardManager.CreateCardItem(cardConfig, count)
    local ob = { id = cardConfig.id, level = 1, star = 0, count = count }

    ob.star = ConfigManager.GetCardStarInitRank(cardConfig)
    ob.level = CardManager.GetOverAllCardLevel(ob.id, ob.star, ob.level)

    local cardItemData = CardItemData:New()
    cardItemData:Init(ob)

    return cardItemData, ob
end

function CardManager.CreateFullCardItem(cardConfig)
    local cardItemData = this.CreateCardItem(cardConfig, 1)
    cardItemData:SetStar(MathUtil.maxinteger)
    cardItemData:SetLevel(MathUtil.maxinteger)

    return cardItemData
end

--使用卡牌
function CardManager.UseCard(cardId, num, to, toId)
    local cardItemData = this.GetCardItemData(cardId)
    cardItemData:UseCard(num)
    Analytics.Event(
        "CardCopySink",
        {
            cardId = cardId,
            bornColor = cardItemData.config.color,
            to = to,
            totoId = toId,
            value = num,
            copyBalance = cardItemData:GetCardCount()
        }
    )
end

function CardManager.IsNewCard(cardId)
    return not this.IsUnlock(cardId)
end

--获取阵容
function CardManager.IsUnlock(cardId)
    return this.cardItemList[cardId] ~= nil
end

--获取战斗场景Level
function CardManager.GetBattleLevel()
    return this.cardData.battleLevel
end

--获取战斗场景Level
function CardManager.SetBattleLevel()
    this.cardData.battleLevel = this.cardData.battleLevel + 1
    this.SaveCardData()
end

--获取阵容
function CardManager.GetBattleArray()
    return this.cardData.battleArray
end

function CardManager.SetBattleArray(cardId)
    this.cardData.battleArray["card_" .. cardId] = cardId
end

function CardManager.removeBattleArray(cardId)
    this.cardData.battleArray["card_" .. cardId] = nil
end

function CardManager.GetBattleTeamCount()
    local count = 0
    for k, v in pairs(this.cardData.battleArray) do
        count = count + 1
    end
    return count
end

function CardManager.GetteamPosArrayCount()
    local count = 0
    for k, v in pairs(this.cardData.teamPosArray) do
        count = count + 1
    end
    return count
end

--是否上阵
function CardManager.IsBattle(cardId)
    local ret = false
    for index, cd in pairs(this.cardData.battleArray) do
        if cd == cardId then
            ret = true
            break
        end
    end
    return ret
end

--上阵卡牌
function CardManager.PlayBattle(cardId)
    if CardManager.GetBattleTeamCount() >= this.maxBattle then
        for k, v in pairs(this.cardData.battleArray) do
            if v == cardId then
                for index = 1, #BattleMap.Instance.CardAnchorPosData do
                    if BattleMap.Instance.CardAnchorPosData[index].CardId == cardId then
                        BattleMap.Instance.CardAnchorPosData[index].CardId = -1
                        CardManager.removeBattleArray(cardId)
                        local heroPosIndex =
                            string.split(BattleMap.Instance.CardAnchorPosData[index].PosBootObj.name, "_")
                        return 1, tonumber(heroPosIndex[2])
                    end
                end
            end
        end

        GameToast.Instance:Show(GetLang("battle_team_full"), nil, "battle")
        return 0, 0
    end

    for k, v in pairs(this.cardData.battleArray) do
        if v == cardId then
            for index = 1, #BattleMap.Instance.CardAnchorPosData do
                if BattleMap.Instance.CardAnchorPosData[index].CardId == cardId then
                    BattleMap.Instance.CardAnchorPosData[index].CardId = -1
                    CardManager.removeBattleArray(cardId)
                    local heroPosIndex = string.split(BattleMap.Instance.CardAnchorPosData[index].PosBootObj.name, "_")
                    return 1, tonumber(heroPosIndex[2])
                end
            end
        end
    end

    for index = 1, #BattleMap.Instance.CardAnchorPosData do
        if BattleMap.Instance.CardAnchorPosData[index].CardId == -1 then
            BattleMap.Instance.CardAnchorPosData[index].CardId = cardId
            CardManager.SetBattleArray(cardId)
            local heroPosIndex = string.split(BattleMap.Instance.CardAnchorPosData[index].PosBootObj.name, "_")
            return 2, tonumber(heroPosIndex[2])
        end
        --end
    end
    this.SaveCardData()
end

--初始布阵英雄界面位置
function CardManager.initCardTeam(cardId)
    if CardManager.GetteamPosArrayCount() == 0 then
        this.PlayBattle(cardId)
    else
        for k, v in pairs(this.cardData.teamPosArray) do
            if v.cardid == cardId then
                BattleMap.Instance.CardAnchorPosData[tonumber(k)].CardId = cardId
                CardManager.SetBattleArray(cardId)
                return 2, tonumber(this.cardData.teamPosArray[k].pos)
            end
        end
    end
end

--获取英雄列表
function CardManager.GetHeroList()
    local ret = {}
    for index, cardId in pairs(this.cardData.battleArray) do
        ret[index] = this.cardItemList[cardId]
    end
    return ret
end

--获取英雄战斗数据
function CardManager.GetHeroBattleData()
    local data = {}
    for index, cardId in pairs(this.cardData.battleArray) do
        data[index] = this.cardItemList[cardId]:GetBattleProperties()
    end
    return data
end

--得到单个卡牌数据
function CardManager.GetSingleHeroBattleData(cardId)
    return this.cardItemList[cardId]:GetBattleProperties()
end

--获取怪物的战斗数据
function CardManager.GetMonsterBattleData()
    local data = {}
    local battleLevel = nil
    if SceneSystem.currentSceneSystem == ECS.initBattleSceneSystem then
        battleLevel = this.cardData.battleLevel
    elseif SceneSystem.currentSceneSystem == ECS.diyBattleSystem then
        battleLevel = DiyCardManager.GetMonsterLevel()
    else
        battleLevel = this.cardData.battleLevel
    end
    local battleLevelConfig = ConfigManager.GetCardBattleLevel(battleLevel)
    local monsters = nil
    if SceneSystem.currentSceneSystem == ECS.hangUpBattleSceneSystem then
        monsters = battleLevelConfig.idle_performance_monsters
    else
        monsters = battleLevelConfig.monsters
    end
    for index, mid in pairs(monsters) do
        local monsterConfig = nil
        local masterCardID = ConfigManager.GetMonsterConfig(mid).card_id
        if masterCardID == 0 then
            monsterConfig = ConfigManager.GetMonsterConfig(mid)
        else
            monsterConfig = ConfigManager.GetCardConfig(ConfigManager.GetMonsterConfig(mid).card_id)
        end
        local monsterLevel = 1
        local troopLevel = 1
        if SceneSystem.currentSceneSystem == ECS.hangUpBattleSceneSystem then
        else
            monsterLevel = battleLevelConfig.monster_level[index]
            troopLevel = battleLevelConfig.monster_troops_level[index]
        end
        local pConfig = ConfigManager.GetCardPropertiesConfig(monsterConfig.property_id)
        local tPConfig = ConfigManager.GetCardPropertiesConfig(monsterConfig.troop_property_id)
        local ret = {}
        ret.monsterTableid = mid
        ret.id = monsterConfig.id
        ret.name = monsterConfig.name
        ret.asset_name = monsterConfig.asset_name
        ret.troops_asset_name = monsterConfig.troops_asset_name
        ret.type = monsterConfig.type
        ret.occupation = monsterConfig.occupation
        ret.hero_radius = monsterConfig.hero_radius
        ret.troops_radius = monsterConfig.troops_radius
        ret.level = monsterLevel
        ret.color = monsterConfig.color
        ret.hp = pConfig.hp[monsterLevel] * battleLevelConfig.hp_ratio
        ret.attack = pConfig.attack[monsterLevel] * battleLevelConfig.attack_ratio
        ret.defence = pConfig.defence[monsterLevel] * battleLevelConfig.defence_ratio
        ret.attack_speed = pConfig.attack_speed[monsterLevel]
        ret.attack_range = pConfig.attack_range[monsterLevel]
        ret.move_speed = pConfig.move_speed[monsterLevel]
        ret.troops_count = pConfig.troops_count[monsterLevel]
        ret.troops_hp = (tPConfig.hp[troopLevel] + pConfig.troops_hp[monsterLevel]) * battleLevelConfig.hp_ratio
        ret.troops_attack =
            (tPConfig.attack[troopLevel] + pConfig.troops_attack[monsterLevel]) * battleLevelConfig.attack_ratio
        ret.troops_defence =
            (tPConfig.defence[troopLevel] + pConfig.troops_defence[monsterLevel]) * battleLevelConfig.defence_ratio
        ret.troops_attack_range = tPConfig.attack_range[troopLevel] + pConfig.troops_attack_range[monsterLevel]
        ret.troops_move_speed = tPConfig.move_speed[troopLevel] + pConfig.troops_move_speed[monsterLevel]
        ret.skills = {}
        for skillIndex, skillId in pairs(monsterConfig.skill) do
            ret.skills[skillIndex] = ConfigManager.GetCardSkillConfig(skillId .. "_1")
        end
        if monsterConfig.skill_normal_attack ~= nil then
            ret.normalskills = {}
            for index, skillid in pairs(monsterConfig.skill_normal_attack) do
                for key, value in pairs(skillid) do
                    local datas = {}
                    datas.skill = ConfigManager.GetCardSkillConfig(key .. "_1")
                    datas.weights = value
                    table.insert(ret.normalskills, datas)
                end
            end
        end

        ret.troops_skills = {}
        for skillIndex, skillId in pairs(monsterConfig.troops_skill) do
            ret.troops_skills[skillIndex] = ConfigManager.GetCardSkillConfig(skillId .. "_1")
        end

        if monsterConfig.troops_normal_skill ~= nil then
            ret.troops_normalskills = {}
            for index, skillid in pairs(monsterConfig.troops_normal_skill) do
                for key, value in pairs(skillid) do
                    local datas = {}
                    datas.skill = ConfigManager.GetCardSkillConfig(key .. "_1")
                    datas.weights = value
                    table.insert(ret.troops_normalskills, datas)
                end
            end
        end

        data[index] = ret
    end
    return data
end

--获取卡片副本数量
function CardManager.GetCardCount(cardId)
    local ret = 0
    if CardManager.IsUnlock(cardId) then
        ret = CardManager.GetCardItemData(cardId):GetCardCount()
    end
    return ret
end

--得到现在一共有多少张卡牌
function CardManager.GetTotalCardCount()
    local count = 0
    for key, value in pairs(this.GetCards()) do
        count = count + 1
    end
    return count
end

--获取某职业的卡牌列表
function CardManager.GetCardIdListByOccupation(occupation, color)
    local ret = List:New()
    this.cardItemList:ForEach(
        function(item)
            if not this.IsCardValidInCurrentCity(item.cardId) then
                return
            end
            if item.config.occupation == occupation and item:GetCardCount() > 0 and item.config.color == color then
                ret:Add(item.config.id)
            end
        end
    )
    return ret
end

--获取某职业的卡牌数量
function CardManager.GetCardCountByOccupation(occupation, color)
    local ret = 0
    this.cardItemList:ForEach(
        function(item)
            if not this.IsCardValidInCurrentCity(item.cardId) then
                return
            end
            if item.config.occupation == occupation and item.config.color == color then
                ret = ret + item:GetCardCount()
            end
        end
    )
    return ret
end

--获取某类型的卡牌列表
function CardManager.GetCardIdListByType(type, color)
    local ret = List:New()
    this.cardItemList:ForEach(
        function(item)
            if not this.IsCardValidInCurrentCity(item.cardId) then
                return
            end
            if item.config.type == type and item:GetCardCount() > 0 and item.config.color == color then
                ret:Add(item.config.id)
            end
        end
    )
    return ret
end

--获取某类型的卡牌数量
function CardManager.GetCardCountByType(type, color)
    local ret = 0
    this.cardItemList:ForEach(
        function(item)
            if not this.IsCardValidInCurrentCity(item.cardId) then
                return
            end
            if item.config.type == type and item.config.color == color then
                ret = ret + item:GetCardCount()
            end
        end
    )
    return ret
end

--获取弹出红心的提示
function CardManager.GetPeopleView()
    local info = {}
    info["heart"] = {
        sprite = Utils.GetItemIcon("heart"),
        color = Color.green,
        value = "+" .. this.addHearts
    }
    return info
end

--依据BoostType返回已经解锁的卡牌
function CardManager.GetCardListByBoostType(boostType)
    local ret = List:New()
    this.cardItemList:ForEach(
        function(item)
            if not this.IsCardValidInCurrentCity(item.cardId) then
                return
            end
            if item.config.boost_type == boostType then
                ret:Add(item)
            end
        end
    )
    ret:Sort(
        function(a, b)
            if a:GetLevel() == b:GetLevel() then
                return a.config.sort < b.config.sort
            else
                return a:GetLevel() > b:GetLevel()
            end
        end
    )
    return ret
end

--依据BoostType返回已经解锁的卡牌红点用
function CardManager.GetRedPointCardListByBoostType(boostType)
    local ret = List:New()
    this.cardItemList:ForEach(
        function(item)
            if not this.IsCardValidInCurrentCity(item.cardId) then
                return
            end
            if
                item.config.boost_type == boostType and
                not MapManager.IsHasCardId(DataManager.GetCityId(), item.config.id)
            then
                ret:Add(item)
            end
        end
    )
    ret:Sort(
        function(a, b)
            return a:GetLevel() > b:GetLevel()
        end
    )
    return ret
end

--依据BoostType返回未解锁的卡牌
function CardManager.GetLockCardIdsByBoostType(boostType)
    local ret = List:New()
    local cardConfigs = ConfigManager.GetCardConfigList()
    for key, cardConfig in pairs(cardConfigs) do
        if cardConfig.boost_type == boostType then
            if not this.IsUnlock(cardConfig.id) then
                ret:Add(cardConfig)
            end
        end
    end
    return ret
end

--依据不是这个BoostType的所有卡牌
function CardManager.GetOtherCardIdsByBoostType(boostType)
    local ret = List:New()
    this.cardItemList:ForEach(
        function(item)
            if not this.IsCardValidInCurrentCity(item.cardId) then
                return
            end
            if item.config.boost_type ~= boostType then
                ret:Add(item)
            end
        end
    )
    ret:Sort(
        function(a, b)
            return a:GetLevel() > b:GetLevel()
        end
    )
    return ret
end

--随机依据规则一张卡牌 例子addToCard*1?color=blue返回addToCard*1?id=1
function CardManager.RandomCard(reward)
    local ret = {}
    local cardPool = List:New()
    local cardsListConfig = ConfigManager.GetCardConfigList()
    if reward.scope == "City" then
        cardsListConfig = ConfigManager.GetCityCardList()
    end
    cardsListConfig:ForEach(
        function(card)
            if reward.color ~= nil and reward.color ~= card.color then
            elseif reward.occupation ~= nil and reward.occupation ~= card.occupation then
            elseif reward.type ~= nil and reward.type ~= card.type then
            else
                cardPool:Add(card)
            end
        end
    )
    if cardPool:Count() == 0 then
        print("[error]" .. "奖励类型不合法" .. JSON.encode(reward))
        return ret
    end
    local random = math.random(1, cardPool:Count())
    ret.addType = reward.addType
    ret.count = reward.count
    ret.id = cardPool[random].id
    return ret
end

function CardManager.addCountDrop(value)
    local reward = {}
    local configData = ConfigManager.GetCardBattleLevel(this.cardData.battleLevel - value)
    for k, v in pairs(configData.drop_group) do
        if reward[k] == nil then
            reward[k] = v
        else
            reward[k] = reward[k] + v
        end
    end
    for k, v in pairs(configData.milestone_drop) do
        if reward[k] == nil then
            reward[k] = v
        else
            reward[k] = reward[k] + v
        end
    end
    return reward
end

function CardManager.AddReward2bag()
    local configData = ConfigManager.GetCardBattleLevel(this.cardData.battleLevel)
    for k, v in pairs(configData.drop_group) do
        DataManager.AddMaterial(DataManager.GetCityId(), k, v, "BCFightLevel", tostring(this.cardData.battleLevel))
    end
    for k, v in pairs(configData.milestone_drop) do
        DataManager.AddMaterial(DataManager.GetCityId(), k, v, "BCFightMilestone", tostring(this.cardData.battleLevel))
    end
end

this.HangupRewardData = {}
function CardManager.CalHangupData()
    if GameManager.GetModeType() == ModeType.ChangeScene then
        return
    end
    local configData = ConfigManager.GetCardBattleLevel(this.cardData.battleLevel)
    for k, v in pairs(configData.idle_coin) do
        local duration = BoostManager.GetCommonBoosterFactor(DataManager.GetCityId(), CommonBoostType.ConstructionSpeed)
        --Log("duration:"..duration)
        local count = math.floor(v / 60 * ConfigManager.GetMiscConfig("level_idle_drop_gap")) * duration
        if count <= 0 then
            count = 1
        end
        --Log("count" .. count)
        if this.HangupRewardData[k] == nil then
            this.HangupRewardData[k] = count
        else
            this.HangupRewardData[k] = this.HangupRewardData[k] + count
        end
        this.cardData.HangupRewardData = this.HangupRewardData
    end
    this.SaveCardData()
end

--挂机奖励领取
function CardManager.AddtHang2Bag()
    for k, v in pairs(this.HangupRewardData) do
        DataManager.AddMaterial(DataManager.GetCityId(), k, v, "BCFightIdleReward", CardManager.GetBattleLevel())
        --AdventureContManager.ShowRewardFormatTop(k, v)
    end
    this.HangupRewardData = {}
    this.cardData.HangupRewardData = {}
    CardManager.cardData.hangupRemaintime = 0
    this.SaveCardData()
end

--得到挂机奖励
function CardManager.GetRewardData()
    return this.HangupRewardData
end

function CardManager.isCanCollect()
    local boolValue = false
    for k, v in pairs(this.HangupRewardData) do
        boolValue = true
    end
    return boolValue
end

--根据当前卡牌获取下一张卡牌id
function CardManager.GetNextCardId(cardId)
    local cardConfigList = ConfigManager.GetCardConfigList()
    local cardList = List:New()
    local isUnlock = this.IsUnlock(cardId)

    for index, value in pairs(cardConfigList) do
        if this.IsUnlock(value.id) == isUnlock then
            cardList:Add(value.id)
        end
    end

    local index = cardList:IndexOf(cardId)
    index = index + 1
    local cardId
    if index > cardList:Count() then
        cardId = cardList[1]
    else
        cardId = cardList[index]
    end
    return cardId
end

--根据当前卡牌获取上一张卡牌id
function CardManager.GetPrevCardId(cardId)
    local cardConfigList = ConfigManager.GetCardConfigList()
    local cardList = List:New()
    local isUnlock = this.IsUnlock(cardId)

    for index, value in pairs(cardConfigList) do
        if this.IsUnlock(value.id) == isUnlock then
            cardList:Add(value.id)
        end
    end

    local index = cardList:IndexOf(cardId)
    index = index - 1
    local cardId
    if index < 1 then
        cardId = cardList[cardList:Count()]
    else
        cardId = cardList[index]
    end
    return cardId
end

--获取当前所有英雄的item
---@return Dictionary<number, CardItemData>
function CardManager.GetCardItemListInCurrentCity()
    local cardInCurrentCity = Dictionary:New()
    this.cardItemList:ForEach(
        function(item)
            if not this.IsCardValidInCurrentCity(item.cardId) then
                return
            end
            cardInCurrentCity:Add(item.cardId, item)
        end
    )
    return cardInCurrentCity
end

function CardManager.GetCardBgColorId(color)
    local cardQualityLevel = {
        green = 0,
        blue = 1,
        purple = 2,
        orange = 3
    }
    return cardQualityLevel[color]
end

---返回品质大小，1：大于，-1：小于，0：等于
---@return number
function CardManager.CompareCardColor(q1, q2)
    if this.GetCardBgColorId(q1) > this.GetCardBgColorId(q2) then
        return 1
    elseif this.GetCardBgColorId(q1) < this.GetCardBgColorId(q2) then
        return -1
    end

    return 0
end

function CardManager.GetUpdateCardFarm()
    local ret = {}
    this.cardItemList:ForEach(
        function(item)
            if not this.IsCardValidInCurrentCity(item.cardId) then
                return
            end
            local cardFarmDetail = {}
            cardFarmDetail.cardId = item.cardId
            cardFarmDetail.cardStar = item:GetStarLevel()
            cardFarmDetail.cardLevel = item:GetLevel()
            cardFarmDetail.cardCopy = item:GetCardCount()
            table.insert(ret, cardFarmDetail)
        end
    )
    return ret
end

function CardManager.GetCards()
    if CityManager.GetIsEventScene() then
        return this.cardData.eventCards
    else
        return this.cardData.cards
    end
end

function CardManager.GetCardMaterial()
    local cityId = DataManager.GetCityId()
    if this.cardMaterialCache == nil then
        this.cardMaterialCache = {}
    end
    if this.cardMaterialCache[cityId] ~= nil then
        return this.cardMaterialCache[cityId]
    end

    local itemType = ItemType.Heart
    if CityManager.GetIsEventScene() then
        local cityId = DataManager.GetCityId()
        local items = ConfigManager.GetItemTypesById(cityId)
        local count = items:Count()
        for i = 1, count do
            local item = ConfigManager.GetItemConfig(items[i])
            if item ~= nil and item.item_type == "Heart" then
                itemType = item.id
                break
            end
        end
    end

    this.cardMaterialCache[cityId] = itemType
    return itemType
end

function CardManager.GetCardCityValue(cardConfig, cityType)
    if cardConfig ~= nil and cardConfig.scope ~= nil and cardConfig.scope[cityType] ~= nil then
        return tonumber(cardConfig.scope[cityType])
    end

    return -1
end

function CardManager.IsCardValidInCurrentCity(cardId)
    local card = ConfigManager.GetCardConfig(cardId)
    if card == nil then
        return true
    end

    if CityManager.GetIsEventScene() then
        if this.GetCardCityValue(card, CityType.Event) == DataManager.GetCityId() then
            return true
        end
    else
        if this.GetCardCityValue(card, CityType.City) > 0 then
            return true
        end
    end

    return false
end

function CardManager.IsCardUnlockInCurrentCity(cardConfig)
    if cardConfig == nil then
        return false
    end

    if CityManager.GetIsEventScene() then
        if this.GetCardCityValue(cardConfig, CityType.Event) == DataManager.GetCityId() then
            return true
        end
    else
        local cityValue = this.GetCardCityValue(cardConfig, CityType.City)
        if 0 < cityValue and cityValue <= DataManager.GetCityId() then
            return true
        end
    end

    return false
end

function CardManager.GetCardCityType(cardId)
    local cardConfig = ConfigManager.GetCardConfig(cardId)
    if cardConfig == nil then
        return CityType.None
    end

    if this.GetCardCityValue(cardConfig, CityType.City) > 0 then
        return CityType.City
    end

    if this.GetCardCityValue(cardConfig, CityType.Event) > 0 then
        return CityType.Event
    end
end

--获取卡牌城市id
---@return number
function CardManager.GetCardCityId(cardConfig)
    if cardConfig == nil then
        return -1
    end

    local cityId = this.GetCardCityValue(cardConfig, CityType.City)
    if cityId > 0 then
        return cityId
    end

    local eventId = this.GetCardCityValue(cardConfig, CityType.Event)
    if eventId > 0 then
        return eventId
    end
end

--获取卡牌建筑Cash最大Effect
function CardManager.GetEventSpecialCashEffect1()
    local ret = 1
    this.cardItemList:ForEach(
        function(item)
            if this.IsCardValidInCurrentCity(item.cardId) then
                if item:GetCardBoostEffect() > ret then
                    ret = item:GetCardBoostEffect()
                end
            end
        end
    )
    return ret
end

--获取最小等级的cardItem
function CardManager.GetMinLeveCardItem()
    local cardItem = nil
    this.cardItemList:ForEach(
        function(item)
            if this.IsCardValidInCurrentCity(item.cardId) then
                if nil == cardItem then
                    cardItem = item
                elseif item:GetLevel() < cardItem:GetLevel() then
                    cardItem = item
                end
            end
        end
    )
    return cardItem
end

--获取最大卡牌等级
function CardManager.GetCardMaxLeve()
    local cardLevel = nil
    this.cardItemList:ForEach(
        function(item)
            if this.IsCardValidInCurrentCity(item.cardId) then
                local lv = item:GetLevel()
                if nil == cardLevel or lv > cardLevel then
                    cardLevel = lv
                end
            end
        end
    )
    return cardLevel
end

---@class CardUnlockType
CardUnlockType = {
    Own = "Own",
    UnFound = "UnFound",
    Lock_ZoneId = "Lock_ZoneId",
    Lock_CityId = "Lock_CityId"
}

--获取卡牌解锁状态
---@param cardId number
---@param cityId number
---@return CardUnlockType
function CardManager.GetCardUnlockState(cardId, cityId)
    local cardConfig = ConfigManager.GetCardConfig(cardId)
    if CardManager.IsUnlock(cardId) then
        return CardUnlockType.Own
    else
        ---@type CityType
        local cityType = CardManager.GetCardCityType(cardId)
        if cityType == CityType.City then
            local unlockCityId = CardManager.GetCardCityValue(cardConfig, CityType.City)
            if unlockCityId > cityId then
                return CardUnlockType.Lock_CityId, unlockCityId
            elseif unlockCityId == cityId then
                if cardConfig.unlock_zone_id ~= nil and cardConfig.unlock_zone_id ~= "" then
                    --区域是否有建筑
                    local mapItemData = MapManager.GetMapItemData(cityId, cardConfig.unlock_zone_id)
                    if mapItemData ~= nil and mapItemData:GetLevel() == 0 then
                        return CardUnlockType.Lock_ZoneId, mapItemData:GetName()
                    end
                end
            end
        elseif CityManager.IsEventScene(EventCityType.Water, cityId) then
            if cardConfig.unlock_zone_id ~= nil and cardConfig.unlock_zone_id ~= "" then
                --区域是否有建筑
                local mapItemData = MapManager.GetMapItemData(cityId, cardConfig.unlock_zone_id)
                if mapItemData ~= nil and mapItemData:GetLevel() == 0 then
                    return CardUnlockType.Lock_ZoneId, mapItemData:GetName()
                end
            end
        end

        return CardUnlockType.UnFound
    end
end

---@class CardManageType
CardManageType = {
    manage = "manage",
    peaceManage = "peaceManage",
    overall = "overall"
}

--获取卡牌管理类型
---@param cardId number
---@return CardManageType
function CardManager.GetCardManageType(cardId)
    local cardConfig = ConfigManager.GetCardConfig(cardId)
    return cardConfig.effect_type
end

--全局卡重置等级
---@return number
function CardManager.GetOverAllCardLevel(cardId, star, rawLevel)
    if CardManager.GetCardManageType(cardId) == CardManageType.overall then
        local starConfig = ConfigManager.GetCardStarConfig(star)
        return starConfig.limit_level
    end

    return rawLevel
end

--获取卡牌上卡zoneId
function CardManager.UpdateGridView(cityId, cardId)

    for zoneId, build in pairs(CityModule.getMainCtrl().buildDict) do
        if MapManager.IsValidZoneId(cityId, zoneId) then
            ---@type MapItemData
            local mapItemData = MapManager.GetMapItemData(cityId, zoneId)
            if mapItemData:GetDefaultCardId() == cardId then
                mapItemData:UpdateGridView()
                return true
            end
        end
    end

    -- local map = Map.Instance
    -- map.zoneIdToMapItem:ForEachKeyValue(
    --     function(zoneId, mapItem)
    --         if MapManager.IsValidZoneId(cityId, zoneId) then
    --             ---@type MapItemData
    --             local mapItemData = MapManager.GetMapItemData(cityId, zoneId)
    --             if mapItemData:GetDefaultCardId() == cardId then
    --                 mapItemData:UpdateGridView()
    --                 return true
    --             end
    --         end
    --     end
    -- )
end

--根据cardId 获取卡牌等级
function CardManager.GetCardLevel(cardId)
    local cardItemData = this.GetCardItemData(cardId)
    if nil ~= cardItemData then
        return cardItemData:GetLevel()
    end
    return 0
end

--切换帐号重置数据
function CardManager.Reset()
    nofirst = false
    this.cardItemList:ForEach(
        function(item)
            item = nil
        end
    )
end
