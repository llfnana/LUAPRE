RecordType = {
    ReduceHP = "hurt",
    AddHP = "heal"
}

BuffType = {
    Shield = "shield",
    Bleed = "bleed",
    Heal = "heal",
    Move = "move",
    Fear = "fear",
    Stun = "stun",
    AttackSpeed = "attack_speed_ratio",
    AttackRatio = "attack_ratio",
    Defenceratio = "defence_ratio"
}

HeroBattleDataManager = {}
HeroBattleDataManager.__cname = "HeroBattleDataManager"

local this = HeroBattleDataManager

function HeroBattleDataManager.Init()
end

function HeroBattleDataManager.GetCardID(CardID)
    local heroData = CardManager.GetHeroBattleData()
    for index = 1, #heroData do
        if heroData[index].id == CardID then
            return false
        end
    end
    return true
end

function HeroBattleDataManager.GetEnityData(cardId)
    local heroData = nil
    if SceneSystem.currentSceneSystem == ECS.initBattleSceneSystem then
        heroData = CardManager.GetHeroBattleData()
    elseif SceneSystem.currentSceneSystem == ECS.diyBattleSystem then
        heroData = DiyCardManager.GetHeroBattleData()
    elseif SceneSystem.currentSceneSystem == ECS.roguelikeSystem then
        heroData = RoguelikeDataManager.GetHeroBattleData()
    else
        heroData = CardManager.GetHeroBattleData()
    end
    for k, v in pairs(heroData) do
        if v.id == cardId then
            return v
        end
    end
end

function HeroBattleDataManager.GetMonsterCardID()
    local cardidList = {}
    if SceneSystem.currentSceneSystem == ECS.roguelikeSystem then
        local heroData = RoguelikeDataManager.GetMonsterBattleData()
        for index = 1, #heroData do
            table.insert(cardidList, heroData[index].id)
        end
    else
        local heroData = CardManager.GetMonsterBattleData()
        for index = 1, #heroData do
            table.insert(cardidList, heroData[index].id)
        end
    end
    return cardidList
end

function HeroBattleDataManager.GetMonsterData(cardId)
    if SceneSystem.currentSceneSystem == ECS.roguelikeSystem then
        local monsterData = RoguelikeDataManager.GetMonsterBattleData()
        for index = 1, #monsterData do
            if monsterData[index].id == cardId then
                return monsterData[index]
            end
        end
    else
        local monsterData = CardManager.GetMonsterBattleData()
        for index = 1, #monsterData do
            if monsterData[index].id == cardId then
                return monsterData[index]
            end
        end
    end
end

--得到队伍战力
function HeroBattleDataManager.GetTeamPower()
    local power = 0
    for k, v in pairs(CardManager.cardData.battleArray) do
        power = power + HeroBattleDataManager.GetCardPower(v, 1)
    end
    return power
end

--得到单个英雄战力 IncludeHalo  0: 不包含羁绊   1：包含羁绊
function HeroBattleDataManager.GetCardPower(Card, IncludeHalo)
    local DataList = CardManager.GetSingleHeroBattleData(Card)
    if IncludeHalo == nil then
        IncludeHalo = 0
    end
    local heroPower = 0
    if IncludeHalo == 0 then
        heroPower = this.GetNotHaloEntityPower(DataList)
    else
        heroPower = this.GetEntityPower(DataList, "Hero")
    end
    return heroPower
end

--怪物队伍战力
function HeroBattleDataManager.GetMonsterPower()
    local heroData = CardManager.GetMonsterBattleData()
    local power = 0
    for index = 1, #heroData do
        power = power + this.GetSingleMonsterPower(heroData[index])
    end
    return power
end

function HeroBattleDataManager.GetSingleMonsterPower(MonsterData)
    return this.GetEntityPower(MonsterData, "Enemy")
end

--实体战力计算公式
function HeroBattleDataManager.GetEntityPower(DataList, type)
    local art, def, hp, troopsRatio, troopsmin
    if type == "Hero" then
        art, def, hp, troopsRatio, troopsmin = HaloManager.GethaloAttributeData("Hero")
    else
        art, def, hp, troopsRatio, troopsmin = HaloManager.GethaloAttributeData("Enemy")
    end
    local heroPower =
        DataList.attack * ConfigManager.GetMiscConfig("constant2") * (1 + art) +
        DataList.defence * ConfigManager.GetMiscConfig("constant3") * (1 + def) +
        DataList.hp * ConfigManager.GetMiscConfig("constant4") * (1 + hp)
    local troopPower = 0

    local troopsCount =
        DataList.troops_count * troopsRatio > troopsmin and math.ceil(DataList.troops_count * troopsRatio) or troopsmin
    local finaltroopsCount = troopsCount + DataList.troops_count
    --Debug.print("[error]" .. "finaltroopsCount:" .. finaltroopsCount .. "troopsCount:" .. troopsCount)
    for index = 1, finaltroopsCount do
        troopPower =
            troopPower + DataList.troops_attack * (1 + art) * ConfigManager.GetMiscConfig("constant2") +
            DataList.troops_defence * (1 + def) * ConfigManager.GetMiscConfig("constant3") +
            DataList.troops_hp * (1 + hp) * ConfigManager.GetMiscConfig("constant4")
    end
    return heroPower + troopPower
end

--实体战力计算公式（不包含羁绊）
function HeroBattleDataManager.GetNotHaloEntityPower(DataList)
    local heroPower =
        DataList.attack * ConfigManager.GetMiscConfig("constant2") +
        DataList.defence * ConfigManager.GetMiscConfig("constant3") +
        DataList.hp * ConfigManager.GetMiscConfig("constant4")
    local troopPower = 0
    for index = 1, DataList.troops_count do
        troopPower =
            troopPower + DataList.troops_attack * ConfigManager.GetMiscConfig("constant2") +
            DataList.troops_defence * ConfigManager.GetMiscConfig("constant3") +
            DataList.troops_hp * ConfigManager.GetMiscConfig("constant4")
    end
    return heroPower + troopPower
end

function HeroBattleDataManager.GetRougelikeEntityPower(attack, defect, hp)
    local heroPower =
        attack * ConfigManager.GetMiscConfig("constant2") + defect * ConfigManager.GetMiscConfig("constant3") +
        hp * ConfigManager.GetMiscConfig("constant4")
    return heroPower
end

function HeroBattleDataManager.OnRoguelikeTotalPower()
    local totalPower = 0
    for key, value in pairs(RoguelikeDataManager.GetBattleArray()) do
        local power = HeroBattleDataManager.GetRoguelikeSinglePower(value)
        totalPower = totalPower + power
    end
    return totalPower
end

function HeroBattleDataManager.GetRoguelikeSinglePower(cardid)
    local CardData = RoguelikeDataManager.GetCardItemData(cardid)
    local cardBattle = CardData:GetBattleProperties()
    return HeroBattleDataManager.GetRougelikeEntityPower(cardBattle.attack, cardBattle.defence, cardBattle.hp)
end

local isBatttleDebug = false

function HeroBattleDataManager.SetBattleSwitch(value)
    isBatttleDebug = value
end
function HeroBattleDataManager.parseentity(value, type)
    if isBatttleDebug == false then
        return
    end
    if SceneSystem.currentSceneSystem == ECS.initBattleSceneSystem then
        local heroData = {}
        heroData.type = type
        heroData.cardid = value.EntityData.id
        heroData.attack = value.EntityData.atack
        heroData.defence = value.EntityData.defence
        heroData.hp = value.EntityData.hp
        local addRatio, minThreshold = HaloManager.GethalotroopsData(type)
        if addRatio > 0 then
            local addCount =
                value.EntityData.troops_count * addRatio > minThreshold and
                math.ceil(value.EntityData.troops_count * addRatio) or
                minThreshold
            heroData.troopsCpunt = value.EntityData.troops_count + addCount
        else
            heroData.troopsCpunt = value.EntityData.troops_count
        end
        heroData.troopsName = value.EntityData.troops_asset_name
        heroData.troopsattack = value.EntityData.troops_attack
        heroData.trroopsdefence = value.EntityData.troops_defence
        heroData.troopshp = value.EntityData.troops_hp
        local now = Time2:New(GameManager.GameTime())
        heroData.timeStamp = now:ToLocalString()
        this.RecordBattleData(heroData)
    end
end

local storehurtDatas = {}
function HeroBattleDataManager.RestoreData()
    if isBatttleDebug == false then
        return
    end
    storehurtDatas = {}
end

function HeroBattleDataManager.OnrecordBattleData(targetEntity, curSkill, hurt, type)
    if isBatttleDebug == false then
        return
    end
    if
        targetEntity.isDestroy == false and SceneSystem.currentSceneSystem == ECS.initBattleSceneSystem and
            curSkill.userCardid ~= 10000
     then
        local hurtData = {}
        hurtData.cardid = targetEntity.CardId
        hurtData.troopsofCardId = targetEntity.EntityData.cardid
        if RecordType.AddHP == type then
            hurtData.heal = hurt
        elseif RecordType.ReduceHP == type then
            hurtData.hurt = hurt
        end
        local hpcom = targetEntity:GetComponent(HpComponent)
        hurtData.remainhp = hpcom.current
        table.insert(storehurtDatas, hurtData)
    end
end

function HeroBattleDataManager.OntotalBattle(curSkill, loopIndex)
    if isBatttleDebug == false then
        return
    end
    if SceneSystem.currentSceneSystem == ECS.initBattleSceneSystem and curSkill.userCardid ~= 10000 then
        local totalData = {}
        totalData.casterId = curSkill.userCardid
        totalData.castertype = curSkill.userType
        totalData.skillname = curSkill.ID
        totalData.Data = storehurtDatas
        totalData.loopIndex = loopIndex
        local now = Time2:New(GameManager.GameTime())
        totalData.timeStamp = now:ToLocalString()
        this.RecordBattleData(totalData)
    end
end

function HeroBattleDataManager.OnRecordBuffData(entity, buffData, type)
    if isBatttleDebug == false then
        return
    end
    if SceneSystem.currentSceneSystem == ECS.initBattleSceneSystem then
        local data = {}
        data.userid = buffData.casterData.currnetSkill.userCardid
        data.skilname = buffData.casterData.currnetSkill.ID
        data.buffname = buffData.id
        data.recipient = entity.CardId
        data.troopsofCardId = entity.EntityData.cardid
        data.buffTime = buffData.time
        local now = Time2:New(GameManager.GameTime())
        data.timeStamp = now:ToLocalString()
        if type == BuffType.Shield then
            local datas = string.split(buffData.data, ",")
            data.shieldValue = (tonumber(datas[1])) * buffData.casterData.attact
            data.absorbRatio = tonumber(datas[2])
            data.bufftype = "护盾"
        elseif type == BuffType.Bleed then
            local datas = string.split(buffData.data, ",")
            data.hp = tonumber(datas[2]) * buffData.casterData.attact
            data.sumtime = tonumber(datas[1])
            data.Subhpratio = tonumber(datas[2])
            data.bufftype = "减血"
        elseif type == BuffType.Heal then
            local datas = string.split(buffData.data, ",")
            data.hp = tonumber(datas[2]) * buffData.casterData.attact
            data.sumtime = tonumber(datas[1])
            data.addhpratio = tonumber(datas[2])
            data.bufftype = "加血"
        elseif type == BuffType.Fear then
            data.CasterPos = buffData.casterData.CasterPos
            data.speed = tonumber(buffData.data)
            data.movetime = buffData.time
            data.entityPos = GetWorldPosByID(entity.ID)
            data.bufftype = "向四周移动"
        elseif type == BuffType.Move then
            local datas = string.split(buffData.data, ",")
            data.CasterPos = buffData.casterData.CasterPos
            data.speed = tonumber(datas[1])
            data.dir = tonumber(datas[2])
            data.movetime = buffData.time
            data.entityPos = GetWorldPosByID(entity.ID)
            data.bufftype = "移动"
        elseif type == BuffType.Stun then
            data.bufftype = "眩晕"
        elseif type == BuffType.AttackSpeed then
            local datas = string.split(buffData.data, ",")
            data.attackSpeed = tonumber(datas[2])
            data.bufftype = "增加攻击速度"
        elseif type == BuffType.AttackRatio then
            local datas = string.split(buffData.data, ",")
            data.attackRatio = tonumber(datas[2])
            data.bufftype = "增加攻击力"
        elseif type == BuffType.Defenceratio then
            local datas = string.split(buffData.data, ",")
            data.defenceRatio = tonumber(datas[2])
            data.bufftype = "增加防御力"
        end
        this.RecordBattleData(data)
    end
end

function HeroBattleDataManager.Onbuffend(entity, buffData, type)
    if isBatttleDebug == false then
        return
    end
    if SceneSystem.currentSceneSystem == ECS.initBattleSceneSystem then
        local data = {}
        data.userid = buffData.casterData.currnetSkill.userCardid
        data.skilname = buffData.casterData.currnetSkill.ID
        data.buffname = buffData.id
        data.recipient = entity.CardId
        data.troopsofCardId = entity.EntityData.cardid
        data.buffTime = buffData.time
        local now = Time2:New(GameManager.GameTime())
        data.timeStamp = now:ToLocalString()
        if type == BuffType.Shield then
            data.bufftype = "护盾结束"
        elseif type == BuffType.Bleed then
            data.bufftype = "减血结束"
        elseif type == BuffType.Heal then
            data.bufftype = "加血结束"
        elseif type == BuffType.Fear then
            data.bufftype = "向四周移动结束"
        elseif type == BuffType.Move then
            data.bufftype = "移动结束"
        elseif type == BuffType.Stun then
            data.bufftype = "眩晕结束"
        elseif type == BuffType.AttackSpeed then
            data.bufftype = "增加攻击速度结束"
        elseif type == BuffType.AttackRatio then
            data.bufftype = "增加攻击力结束"
        elseif type == BuffType.Defenceratio then
            data.bufftype = "增加防御力结束"
        end
        this.RecordBattleData(data)
    end
end

local battleData = {}
function HeroBattleDataManager.RecordBattleData(data)
    if isBatttleDebug == false then
        return
    end
    if SceneSystem.currentSceneSystem == ECS.initBattleSceneSystem then
        local jsonStr = JSON.encode(data)
        Log("[BATTLE]:" .. jsonStr)
        table.insert(battleData, data)
    end
end

function HeroBattleDataManager.RestoreBattleData()
    if isBatttleDebug == false then
        return
    end
    if SceneSystem.currentSceneSystem == ECS.initBattleSceneSystem then
        local lastData = {}
        lastData.time = "战斗结束了"
        table.insert(battleData, lastData)
        local str = ""
        str = str .. "战斗开始了................................" .. "\n"
        for index = 1, #battleData do
            local jsonStr = JSON.encode(battleData[index])
            str = str .. jsonStr .. "\n"
        end
        local battlelevel = tostring(CardManager.GetBattleLevel())
        CS.FrozenCity.SpriteAPI.CreatBattleData(str, battlelevel)
        battleData = {}
    end
end

function HeroBattleDataManager.radomNormalSkill(normalskill)
    local weightsList = {}
    local index = -1
    for key, value in pairs(normalskill) do
        table.insert(weightsList, value.weights)
    end
    if #weightsList == 1 then
        index = 1
    elseif #weightsList == 2 then
        local radom = math.random(1, 10)
        if radom >= 1 and radom <= weightsList[1] * 10 then
            index = 1
        elseif radom > weightsList[1] * 10 and radom <= (weightsList[1] + weightsList[2]) * 10 then
            index = 2
        end
    elseif #weightsList == 3 then
        local radom = math.random(1, 10)
        if radom >= 1 and radom <= weightsList[1] * 10 then
            index = 1
        elseif radom > weightsList[1] * 10 and radom <= (weightsList[1] + weightsList[2]) * 10 then
            index = 2
        elseif
            radom > (weightsList[1] + weightsList[2]) * 10 and
                radom <= (weightsList[1] + weightsList[2] + weightsList[3]) * 10
         then
            index = 3
        end
    end
    return index
end

function HeroBattleDataManager.clearBattleData()
    if isBatttleDebug == false then
        return
    end
    if SceneSystem.currentSceneSystem == ECS.initBattleSceneSystem then
        battleData = {}
    end
end
