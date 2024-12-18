---@class CardItemData
CardItemData = {}
CardItemData.__index = CardItemData

function CardItemData:New()
    return setmetatable({}, self)
end

--初始化卡牌数据
function CardItemData:Init(cardData)
    self.cityId = DataManager.GetCityId()
    self.cardData = cardData
    self.cardId = self.cardData.id
    self.type = cardData.type
    if self.type == "Unit" then
        local exploreUnitConfig = ConfigManager.GetExploreUnitConfig(self.cardData.id)
        local monsterid = exploreUnitConfig.monster_id
        local monsterConfig = ConfigManager.GetMonsterConfig(tonumber(monsterid))
        if monsterConfig.card_id == 0 then
            self.config = monsterConfig
            self.properties = ConfigManager.GetCardPropertiesConfig(monsterConfig.property_id)
            self.troopsProperties = ConfigManager.GetCardPropertiesConfig(monsterConfig.troop_property_id)
        else
            self.config = ConfigManager.GetCardConfig(monsterConfig.card_id)
            self.properties = ConfigManager.GetCardPropertiesConfig(self.config.property_id)
            self.troopsProperties = ConfigManager.GetCardPropertiesConfig(self.config.troop_property_id)
        end
    else
        self.config = ConfigManager.GetCardConfig(self.cardId)
        self.properties = ConfigManager.GetCardPropertiesConfig(self.config.property_id)
        self.troopsProperties = ConfigManager.GetCardPropertiesConfig(self.config.troop_property_id)
    end
end

function CardItemData:GetID()
    return self.cardId
end

function CardItemData:GetConfig()
    return self.config
end

--获取卡牌等级
function CardItemData:GetLevel()
    return self.cardData.level
end

--添加卡牌
function CardItemData:AddCard(count)
    count = count or 1
    self.cardData.count = self.cardData.count + count
end

--使用卡牌
function CardItemData:UseCard(num)
    self.cardData.count = self.cardData.count - num
end

--获取卡牌数量
function CardItemData:GetCardCount()
    return self.cardData.count
end

--判断是否可以升级
function CardItemData:IsCanUpgradeLevel()
    local maxLvl = self:GetMaxLevel(self:GetStar())
    if self.cardData.level >= maxLvl then
        return false
    end

    local heartCost = ConfigManager.GetCardUpgradeHeartCost(self:GetLevel(), self.config.upgrade_group)
    return DataManager.GetMaterialCount(DataManager.GetCityId(), CardManager.GetCardMaterial()) >= heartCost
end

--升级卡牌等级，并扣除资源
function CardItemData:UpgradeLevel(from)
    local heartCost = ConfigManager.GetCardUpgradeHeartCost(self:GetLevel(), self.config.upgrade_group)
    if DataManager.GetMaterialCount(DataManager.GetCityId(), CardManager.GetCardMaterial()) < heartCost then
        -- GameToast.Instance:Show(GetLang("ui_card_heart_not_enough"), ToastIconType.Warning)
        UIUtil.showText(GetLang("ui_card_heart_not_enough"))
        return false
    end
    if self.cardData.level >= self:GetMaxLevel() then
        -- GameToast.Instance:Show(GetLang("ui_card_reach_lvl_limit"), ToastIconType.Warning)
        UIUtil.showText(GetLang("ui_card_reach_lvl_limit"))
        return false
    end
    DataManager.UseMaterial(
        DataManager.GetCityId(),
        CardManager.GetCardMaterial(),
        heartCost,
        "CardUpgrading",
        "cardId" .. self.cardId
    )
    self.cardData.level = self.cardData.level + 1
    DataManager.SaveGlobalData()
    BoostManager.RefreshBoostByCardId(DataManager.GetCityId(), self.cardId)
    CardManager.UpdateGridView(DataManager.GetCityId(), self.cardId)

    EventManager.Brocast(EventType.UPGRADE_CARD_LEVEL, DataManager.GetCityId(), self.cardId, self.cardData.level)
    -- OfficeManager.UpdateCardSlot(DataManager.GetCityId(), self.cardId)
    Analytics.Event(
        "CardUpgrade",
        {
            bornColor = self.config.color,
            cardId = self.cardId,
            cardLevel = self:GetLevel(),
            cardStar = self:GetStarLevel(),
            from = from
        }
    )
    return true
end

--设置卡牌等级
---@param level number
function CardItemData:SetLevel(level)
    local maxLvl = self:GetMaxLevel(self:GetStar())
    if level > maxLvl then
        level = maxLvl
    end

    self.cardData.level = level
    BoostManager.RefreshBoostByCardId(DataManager.GetCityId(), self.cardId)
end

--获取卡牌星级Id
function CardItemData:GetStar()
    return self.cardData.star
end

--获取卡牌星等级(真正的等级在此)
function CardItemData:GetStarLevel()
    return ConfigManager.GetCardStarConfig(self:GetStar()).star_level
end

--依据索引获取技能id
function CardItemData:GetSkillId(index)
    local skillGroup = self.config.skill[index]
    local skillLevel = self.config.skill_level[index]
    local level = self:GetLevel()
    local sid = 0
    local max = 0
    local unlockLevel = 0
    local unlockSid = 0
    for slv, lv in pairs(skillLevel) do
        unlockSid = slv
        unlockLevel = lv
        if level >= lv and lv > max then
            max = lv
            sid = slv
        else
            break
        end
    end
    --技能id,下一级技能id
    if sid == 0 then
        return nil, skillGroup .. "_" .. unlockSid, unlockLevel
    end
    local skillId = skillGroup .. "_" .. sid
    return skillId, skillGroup .. "_" .. unlockSid, unlockLevel, unlockSid
end

--获取主动技能
function CardItemData:GetActiveSkill()
    return self:GetSkillId(2)
end

--获取小兵技能配置列表Id
function CardItemData:GetSkillIdList()
    local ret = {}
    for index, skillId in pairs(self.config.skill) do
        local id = self:GetSkillId(index)
        table.insert(ret, id)
    end
    return ret
end

--获取技能配置列表
function CardItemData:GetSkillList()
    local ret = {}
    if self:GetHeroOrMonsterConfig() == true then
        local idList = self:GetSkillIdList()
        for index, skillId in pairs(idList) do
            ret[index] = ConfigManager.GetCardSkillConfig(skillId)
        end
    else
        for skillIndex, skillId in pairs(self.config.skill) do
            ret[skillIndex] = ConfigManager.GetCardSkillConfig(skillId .. "_1")
        end
    end
    return ret
end

function CardItemData:GetNormalSkillList()
    local ret = {}
    for index, skillId in pairs(self.config.skill_normal_attack) do
        for key, value in pairs(skillId) do
            local datas = {}
            datas.skill = ConfigManager.GetCardSkillConfig(key .. "_1")
            datas.weights = value
            table.insert(ret, datas)
        end
    end
    return ret
end

--获取技能配置列表(包括未解锁)
function CardItemData:GetSkillAllList()
    local ret = {}
    for index, skillId in pairs(self.config.skill) do
        local id, unlockSid, unlockLevel = self:GetSkillId(index)
        local item = {}
        if id ~= nil then
            item.id = id
            item.unlock = true
            item.unlockLevel = unlockLevel
        else
            item.id = unlockSid
            item.unlock = false
            item.unlockLevel = unlockLevel
        end
        table.insert(ret, item)
    end
    return ret
end

--获取解锁技能配置列表(不包含默认技能)
function CardItemData:GetUnlockSkillList()
    local ret = {}
    for index, skillId in pairs(self.config.skill) do
        if index > 1 then
            local id, unlockSid, unlockLevel, unlockSkillLevel = self:GetSkillId(index)
            local item = {}
            if id ~= nil then
                item.id = id
                item.unlock = true
                item.unlockLevel = unlockLevel
                item.unlockSkillLevel = unlockSkillLevel
                table.insert(ret, item)
            end
        end
    end
    return ret
end

--依据索引获取小兵技能id
function CardItemData:GetTroopSkillId(index)
    local skillGroup = self.config.troops_skill[index]
    local skillLevel = self.config.troops_skill_level[index]
    local level = self:GetLevel()
    local sid = 0
    local max = 0
    local unlockLevel = 0
    local unlockSid = 0
    for slv, lv in pairs(skillLevel) do
        unlockSid = slv
        unlockLevel = lv
        if level >= lv and lv > max then
            max = lv
            sid = slv
        else
            break
        end
    end
    --技能id,下一级技能id
    if sid == 0 then
        return nil, skillGroup .. "_" .. unlockSid, unlockLevel
    end
    local skillId = skillGroup .. "_" .. sid
    return skillId, skillGroup .. "_" .. unlockSid, unlockLevel
end

--获取小兵主动技能
function CardItemData:GetTroopActiveSkill()
    return self:GetTroopSkillId(2)
end

--获取小兵技能配置列表Id
function CardItemData:GetTroopSkillIdList()
    local ret = {}
    for index, skillId in pairs(self.config.troops_skill) do
        local id = self:GetTroopSkillId(index)
        table.insert(ret, id)
    end
    return ret
end

--获取小兵技能配置列表
function CardItemData:GetTroopSkillList()
    local ret = {}
    local idList = self:GetTroopSkillIdList()
    for index, skillId in pairs(idList) do
        ret[index] = ConfigManager.GetCardSkillConfig(skillId)
    end
    return ret
end

function CardItemData:GetTroopNormalSkilList()
    local ret = {}
    for index, skillId in pairs(self.config.troops_normal_skill) do
        for key, value in pairs(skillId) do
            local datas = {}
            datas.skill = ConfigManager.GetCardSkillConfig(key .. "_1")
            datas.weights = value
            table.insert(ret, datas)
        end
    end
    return ret
end

--获取小兵技能配置列表(包括未解锁)
function CardItemData:GetTroopSkillAllList()
    local ret = {}
    for index, skillId in pairs(self.config.troops_skill) do
        local id, unlockSid, unlockLevel = self:GetTroopSkillId(index)
        local item = {}
        if id ~= nil then
            item.id = id
            item.unlock = true
            item.unlockLevel = unlockLevel
        else
            item.id = unlockSid
            item.unlock = false
            item.unlockLevel = unlockLevel
        end
        table.insert(ret, item)
    end
    return ret
end

--获取战斗属性
function CardItemData:GetBattleProperties()
    local ret = {}
    ret.id = self.cardId
    ret.name = self.config.name
    ret.asset_name = self.config.asset_name
    ret.troops_asset_name = self.config.troops_asset_name
    ret.type = self.config.type
    ret.occupation = self.config.occupation
    ret.hero_radius = self.config.hero_radius
    ret.troops_radius = self.config.troops_radius
    ret.level = self.cardData.level
    ret.hp = self:GetHp()
    ret.attack = self:GetAttack()
    ret.defence = self:GetDefence()
    ret.attack_speed = self:GetAttackSpeed()
    ret.attack_range = self:GetAttackRange()
    ret.move_speed = self:GetMoveSpeed()
    if self:GetHeroOrMonsterConfig() == true then
        ret.troops_count = self:GetTroopsCount()
        ret.troops_hp = self:GetTroopsHp()
        ret.troops_attack = self:GetTroopsAttack()
        ret.troops_defence = self:GetTroopsDefence()
        ret.troops_attack_speed = self:GetTroopsAttackSpeed()
        ret.troops_attack_range = self:GetTroopsAttackRange()
        ret.troops_move_speed = self:GetTroopsMoveSpeed()
    end
    ret.skills = self:GetSkillList()
    ret.normalskills = self:GetNormalSkillList()
    if self:GetHeroOrMonsterConfig() == true then
        ret.troops_skills = self:GetTroopSkillList()
        ret.troops_normalskills = self:GetTroopNormalSkilList()
    end
    return ret
end

--获取战斗属性Hp
function CardItemData:GetHp(level, star)
    level = level or self.cardData.level
    if level > #self.properties.hp then
        level = #self.properties.hp
    end
    star = star or self.cardData.star
    local ret = self.properties.hp[level]
    if self:GetHeroOrMonsterConfig() == true then
        ret = ret * ConfigManager.GetCardStarConfig(star).hp_multiple
    end

    return ret
end

--获取战斗属性Attack
function CardItemData:GetAttack(level, star)
    level = level or self.cardData.level
    star = star or self.cardData.star
    if level > #self.properties.attack then
        level = #self.properties.attack
    end
    local ret = self.properties.attack[level]
    if self:GetHeroOrMonsterConfig() == true then
        ret = ret * ConfigManager.GetCardStarConfig(star).attack_multiple
    end
    return ret
end

--获取战斗属性Defence
function CardItemData:GetDefence(level, star)
    level = level or self.cardData.level
    star = star or self.cardData.star
    if level > #self.properties.defence then
        level = #self.properties.defence
    end
    local ret = self.properties.defence[level]
    if self:GetHeroOrMonsterConfig() == true then
        ret = ret * ConfigManager.GetCardStarConfig(star).defence_multiple
    end
    return ret
end

--获取战斗属性AttackSpeed
function CardItemData:GetAttackSpeed(level)
    level = level or self.cardData.level
    if level > #self.properties.attack_speed then
        level = #self.properties.attack_speed
    end
    local ret = self.properties.attack_speed[level]
    return ret
end

--获取战斗属性AttackRange
function CardItemData:GetAttackRange(level)
    level = level or self.cardData.level
    if level > #self.properties.attack_range then
        level = #self.properties.attack_range
    end
    local ret = self.properties.attack_range[level]
    return ret
end

--获取战斗属性MoveSpeed
function CardItemData:GetMoveSpeed(level)
    level = level or self.cardData.level
    if level > #self.properties.move_speed then
        level = #self.properties.move_speed
    end
    local ret = self.properties.move_speed[level]
    return ret
end

--获取TroopsCount
function CardItemData:GetTroopsCount(level)
    level = level or self.cardData.level
    if level > #self.properties.troops_count then
        level = #self.properties.troops_count
    end
    local ret = self.properties.troops_count[level]
    return ret
end

--获取小兵战斗属性Hp
function CardItemData:GetTroopsHp(level, star)
    level = level or self.cardData.level
    star = star or self.cardData.star
    if level > #self.troopsProperties.hp then
        level = #self.troopsProperties.hp
    end
    local ret = self.troopsProperties.hp[level]
    ret = ret * ConfigManager.GetCardStarConfig(star).hp_multiple
    return ret
end

--获取小兵战斗属性Attack
function CardItemData:GetTroopsAttack(level, star)
    level = level or self.cardData.level
    star = star or self.cardData.star
    if level > #self.troopsProperties.attack then
        level = #self.troopsProperties.attack
    end
    local ret = self.troopsProperties.attack[level]
    ret = ret * ConfigManager.GetCardStarConfig(star).attack_multiple
    return ret
end

--获取小兵战斗属性Defence
function CardItemData:GetTroopsDefence(level, star)
    level = level or self.cardData.level
    star = star or self.cardData.star
    if level > #self.troopsProperties.defence then
        level = #self.troopsProperties.defence
    end
    local ret = self.troopsProperties.defence[level]
    ret = ret * ConfigManager.GetCardStarConfig(star).defence_multiple
    return ret
end

--获取小兵战斗属性AttackSpeed
function CardItemData:GetTroopsAttackSpeed(level)
    level = level or self.cardData.level
    if level > #self.troopsProperties.attack_speed then
        level = #self.troopsProperties.attack_speed
    end
    local ret = self.troopsProperties.attack_speed[level]
    return ret
end

--获取小兵战斗属性AttackRange
function CardItemData:GetTroopsAttackRange(level)
    level = level or self.cardData.level
    if level > #self.troopsProperties.attack_range then
        level = #self.troopsProperties.attack_range
    end
    local ret = self.troopsProperties.attack_range[level]
    return ret
end

--获取小兵战斗属性MoveSpeed
function CardItemData:GetTroopsMoveSpeed(level)
    level = level or self.cardData.level
    if level > #self.troopsProperties.move_speed then
        level = #self.troopsProperties.move_speed
    end
    local ret = self.troopsProperties.move_speed[level]
    return ret
end

--获得吞卡的数量
function CardItemData:GetEatCardCount()
    local starConfig = ConfigManager.GetCardStarConfig(self:GetStar())
    return starConfig.card_req
end

--获得吞卡所需花费
function CardItemData:GetEatCardCost()
    local ret = {}
    local starConfig = ConfigManager.GetCardStarConfig(self:GetStar())
    for itemId, count in pairs(starConfig.cost) do
        ret.itemId = itemId
        ret.count = count
        break
    end
    return ret
end
--获得吞卡的列表
-- function CardItemData:GetEatCardList()
--     local ret = List:New()
--     local starConfig = ConfigManager.GetCardStarConfig(self:GetStar())
--     for i = 0, 4, 1 do
--         local reqItem = starConfig["card_req_" .. i]
--         local item = {}
--         item.index = i
--         if reqItem["self"] ~= nil and reqItem.self ~= 0 then
--             item.req = "self"
--             item.value = self.cardId
--             item.count = reqItem.self
--             ret:Add(item)
--         elseif reqItem["occupation"] ~= nil and reqItem.occupation ~= 0 then
--             item.req = "occupation"
--             item.value = self.config.occupation
--             item.count = reqItem.occupation
--             ret:Add(item)
--         elseif reqItem["type"] ~= nil and reqItem.type ~= 0 then
--             item.req = "type"
--             item.value = self.config.type
--             item.count = reqItem.type
--             ret:Add(item)
--         end
--     end

--     return ret
-- end

--获取是否可以升星的状态
function CardItemData:CanAddStarStatus()
    local ret = false
    if self:GetStar() >= ConfigManager.GetCardMaxStarRank(self.config) then
        ret = false
    else
        local costData = self:GetEatCardCost()
        if self:GetEatCardCount() > 0 or costData.count > 0 then
            if CardManager.GetCardCount(self.cardId) >= self:GetEatCardCount() then
                if DataManager.GetMaterialCount(DataManager.GetCityId(), costData.itemId) >= costData.count then
                    ret = true
                end
            end
        end
    end
    return ret
end

function CardItemData:IsCanAddStar()
    local costData = self:GetEatCardCost()
    if self:GetEatCardCount() > 0 or costData.count > 0 then
        if CardManager.GetCardCount(self.cardId) >= self:GetEatCardCount() then
            if DataManager.GetMaterialCount(DataManager.GetCityId(), costData.itemId) >= costData.count then
                return true
            end
        end
    end
    return false
end

--卡牌升星
---@param from string
---@param upgradeType string
---@param gemValue number
function CardItemData:AddStar(from, upgradeType, gemValue)
    local ret = true
    local costData = self:GetEatCardCost()
    if self:GetEatCardCount() > 0 or costData.count > 0 then
        if CardManager.GetCardCount(self.cardId) >= self:GetEatCardCount() then
            if DataManager.GetMaterialCount(DataManager.GetCityId(), costData.itemId) >= costData.count then
                CardManager.UseCard(self.cardId, self:GetEatCardCount(), "StarUp", self.cardId)
                DataManager.UseMaterial(
                    DataManager.GetCityId(),
                    costData.itemId,
                    costData.count,
                    "CardStarUp",
                    "cardId" .. self.cardId
                )
                self.cardData.star = self.cardData.star + 1
                self.cardData.level =
                    CardManager.GetOverAllCardLevel(self.cardId, self.cardData.star, self.cardData.level)
                BoostManager.RefreshBoostByCardId(DataManager.GetCityId(), self.cardId)
                DataManager.SaveGlobalData()
                EventManager.Brocast(
                    EventType.UPGRADE_CARD_STAR,
                    DataManager.GetCityId(),
                    self.cardId,
                    self:GetStarLevel()
                )
            else
                UIUtil.showText(GetLang("insufficient_materials"))
                return false
            end
        else

            UIUtil.showText(GetLang("toast_card_no_enough"))
            return false
        end
    end
    -- for cardId, count in pairs(eatCardList) do
    --     if count ~= nil and count > 0 and count > CardManager.GetCardCount(cardId) then
    --         GameToast.Instance:Show(GetLang("toast_card_no_enough"))
    --         return false
    --     end
    -- end
    -- for cardId, count in pairs(eatCardList) do
    --     CardManager.UseCard(cardId, count, "StarUp", self.cardId)
    -- end
    -- self.cardData.star = self.cardData.star + 1
    -- OfficeManager.UpdateCardSlot(DataManager.GetCityId(), self.cardId)
    return ret
end

function CardItemData:SetStar(star)
    local maxStar = ConfigManager.GetCardMaxStarRank(self.config)
    if star > maxStar then
        star = maxStar
    end

    self.cardData.star = star
end

--获取小兵战斗属性Attack
function CardItemData:GetMaxLevel(star)
    star = star or self.cardData.star
    local ret = ConfigManager.GetCardStarConfig(star).limit_level
    return ret
end

--获取卡牌Boost
function CardItemData:GetCardBoost()
    return ConfigManager.GetBoostConfig(self.config.boost)
end

--计算Reset返还多少心
function CardItemData:SumResetHeart()
    local ret = 0
    for i = 1, self:GetLevel() - 1, 1 do
        ret = ret + ConfigManager.GetCardUpgradeHeartCost(i, self.config.upgrade_group)
    end
    return ret
end

--计算Reset返还多少心
function CardItemData:ResetLevel()
    local costPrice = ConfigManager.GetMiscConfig("reset_card_exp_price")[self:GetLevel()]
    if costPrice > DataManager.GetMaterialCount(DataManager.GetCityId(), ItemType.Gem) then
        GameToast.Instance:Show(GetLang("toast_gem_not_enough"), ToastIconType.Warning)
        return false
    end
    local logObj = {
        bornColor = self.config.color,
        cardId = self.cardId,
        cardStar = self:GetStarLevel(),
        cardLevel = self:GetLevel()
    }
    Analytics.Event("CardRestConfirm", logObj)

    DataManager.UseMaterial(DataManager.GetCityId(), ItemType.Gem, costPrice, "ResetCard", "cardId" .. self.cardId)
    local addHeart = self:SumResetHeart()
    DataManager.AddMaterial(
        DataManager.GetCityId(),
        CardManager.GetCardMaterial(),
        addHeart,
        "ResetCard",
        "cardId" .. self.cardId
    )
    self.cardData.level = 1
    DataManager.SaveGlobalData()
end

--获取卡牌Boost
function CardItemData.GetCardBoostLevelStatic(cardLevel, boostLevel)
    local boostArray = List:New()
    for boostLv, cardLv in pairs(boostLevel) do
        boostArray:Add({boostLv = boostLv, cardLv = cardLv})
    end
    boostArray:Sort(
        function(a, b)
            return a.boostLv < b.boostLv
        end
    )
    local ret = 0
    local max = 0
    local unlockCardLevel = 0
    local unlockBoostLevel = 0
    for k, value in pairs(boostArray) do
        unlockBoostLevel = value.boostLv
        unlockCardLevel = value.cardLv
        if cardLevel >= unlockCardLevel and unlockCardLevel > max then
            max = unlockCardLevel
            ret = unlockBoostLevel
        else
            break
        end
    end
    return ret, unlockBoostLevel, unlockCardLevel
end

--获取卡牌Boost
function CardItemData:GetCardBoostLevel()
    return CardItemData.GetCardBoostLevelStatic(self:GetLevel(), self.config.boost_level)
end

--获取卡牌Boost
function CardItemData:GetCardBoostEffect(level)
    level = level or self:GetCardBoostLevel()
    local boostConfig = ConfigManager.GetBoostConfig(self.config.boost)
    local effect = boostConfig.boost_effects[level]
    return effect
end

--获取卡牌Boost介绍
function CardItemData:GetCardBoostDesc()
    local boostConfig = ConfigManager.GetBoostConfig(self.config.boost)
    local effect = self:GetCardBoostEffect()
    local ret
    if self.config.boost_type == "medical" then
        ret = GetLangFormat(boostConfig.desc, effect, tostring(boostConfig.boost_params.cureRate * 100) .. "%")
    elseif self.config.boost_type == "protest" or string.find(self.config.boost_type, "resource", 0) == 1 then
        ret = GetLangFormat(boostConfig.desc, effect, boostConfig.boost_params.count)
    else
        ret = GetLangFormat(boostConfig.desc, tostring(effect * 100) .. "%")
    end
    return ret
end

function CardItemData:GetCardBoostEffectShow()
    local preString = BoostManager.GetCardBoostEffectPreString(self.config.boost_type)
    local effect = self:GetCardBoostEffect()

    if not effect then 
        local boostConfig = ConfigManager.GetBoostConfig(self.config.boost)
        print("[Error] BoostConf id = " .. self.config.boost .. ", boost_effects.length = " .. #boostConfig.boost_effects .. ", level = " .. level .. ", cardId = " .. self.config.id)
        return ""
    end
    local ret = ""
    if
        self.config.boost_type == "medical" or self.config.boost_type == "protest" or
            string.find(self.config.boost_type, "resource", 0) == 1
    then
        
        ret = preString .. tostring(Utils.FormatCount(effect))
    else
        ret = preString .. tostring(effect * 100) .. "%"
    end
    return ret
end

function CardItemData:GetHeroOrMonsterConfig()
    local isHero = true
    if self.type == "Unit" then
        isHero = false
    end
    return isHero
end

function CardItemData:GetWorkJob()
    return self.config.work_job
end
