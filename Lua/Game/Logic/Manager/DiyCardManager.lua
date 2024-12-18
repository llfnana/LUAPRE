DiyCardManager = {}
DiyCardManager._name = "DiyCardManager"

local this = DiyCardManager

function DiyCardManager.Init()
    this.DiycardList = Dictionary:New()
end

local groupIndex = 1
local battleTeams = {}
function DiyCardManager.parseData()
    local robotHeroConfig = ConfigManager.GetRobotBattleConfig()
    battleTeams = {}
    for key, value in pairs(robotHeroConfig) do
        if value.isBattle == true then
            local teams = {}
            teams.id = value.id
            teams.isbattle = value.isBattle
            teams.team = {}
            teams.startBattlelevel = value.start_battle_level
            for index = 1, #value.cards_id do
                local teamData = {}
                teamData.cardid = value.cards_id[index]
                teamData.level = value.cards_level[1]
                table.insert(teams.team, teamData)
            end
            table.insert(battleTeams, teams)
        end
    end

    for key, value in pairs(battleTeams) do
        for v = #value.team, 1, -1 do
            local cardConfig = ConfigManager.GetCardConfig(value.team[v].cardid)
            local maxStar = ConfigManager.GetCardMaxStarRank(cardConfig)
            local cardstarConfig = ConfigManager.GetCardStarConfig(maxStar)
            local maxLevel = cardstarConfig.limit_level
            if maxLevel < value.team[v].level then
                print("[error]" .. 
                    "robot_battle cardid:" ..
                        value.team[v].cardid ..
                            " color:" ..
                                cardConfig.color .. " maxLevel:" .. maxLevel .. " 超出配置的等级:" .. value.team[v].level
                )
                table.remove(value.team, v)
            end
        end
    end

    for key, value in pairs(battleTeams) do
        for v = #value.team, 1, -1 do
            local cardConfig = ConfigManager.GetCardConfig(value.team[v].cardid)
            value.team[v].starLevel = DiyCardManager.GetStarBaseLevelRange(cardConfig.color, value.team[v].level)
        end
    end
    this.addDataToCardItem()
end

local monsterlevel = 1
function DiyCardManager.addDataToCardItem()
    for key, value in pairs(battleTeams) do -- 生成 cardItemData
        if groupIndex == key then
            for v = #value.team, 1, -1 do
                LogWarning(
                    "teamid:" ..
                        value.id ..
                            " cardid:" ..
                                value.team[v].cardid ..
                                    " level:" .. value.team[v].level .. "starlevel:" .. value.team[v].starLevel
                )
                DiyCardManager.AddCard(value.team[v].cardid, value.team[v].level, value.team[v].starLevel)
            end
            monsterlevel = value.startBattlelevel
        end
    end
end

function DiyCardManager.AddCard(cardId, level, star)
    local cardConfig = ConfigManager.GetCardConfig(cardId)
    local ob = {id = cardId, level = level, star = star}
    local cardItemData = CardItemData:New()
    cardItemData:Init(ob)
    this.DiycardList:Add(cardId, cardItemData)
end

function DiyCardManager.parseCardStar(color, star)
    local starData = 0
    if color == "orange" then
        starData = 3000 + star
    elseif color == "purple" then
        starData = 2000 + star
    elseif color == "blue" then
        starData = 1000 + star
    end
    return starData
end

function DiyCardManager.GetHeroCardId()
    local data = {}
    for index = 1, #battleTeams[groupIndex].team do
        data[index] = tonumber(battleTeams[groupIndex].team[index].cardid)
    end
    return data
end

function DiyCardManager.GetHeroBattleData()
    local data = {}
    for index = 1, #battleTeams[groupIndex].team do
        data[index] = this.DiycardList[tonumber(battleTeams[groupIndex].team[index].cardid)]:GetBattleProperties()
    end
    return data
end

function DiyCardManager.GetCardItemData(cardId)
    return this.DiycardList[cardId]
end

function DiyCardManager.GetgroupIndex()
    return groupIndex
end

function DiyCardManager.SetgroupIndex()
    groupIndex = groupIndex + 1
    Log("groupIndex:" .. groupIndex)
end

function DiyCardManager.GetMonsterLevel()
    return monsterlevel
end

function DiyCardManager.SetMonsterLevel()
    monsterlevel = monsterlevel + 1
    Log("robot_battle 第" .. battleTeams[groupIndex].id .. "组 胜利关卡" .. monsterlevel)
end

local failuretime = 0
function DiyCardManager.SetCurrentidfailuretime()
    local micconfig = ConfigManager.GetMiscConfig("battle_robot_try")
    failuretime = failuretime + 1
    if failuretime == 1 then
        print("[error]" .. "robot_battle 第" .. battleTeams[groupIndex].id .. "组机器人首次失败关卡" .. monsterlevel)
        if tonumber(micconfig) == 1 then
            this.RoundOverClear()
            this.SetgroupIndex()
            this.DiycardList:Clear()
            this.addDataToCardItem()
            ECS.diyBattleSystem:Enter(false)
        else
            ECS.diyBattleSystem:Enter(false)
        end
    elseif failuretime == tonumber(micconfig) then
        print("[error]" .. "robot_battle 第" .. battleTeams[groupIndex].id .. "组机器人第" .. failuretime .. "次失败关卡" .. monsterlevel)
        this.RoundOverClear()
        this.SetgroupIndex()
        this.DiycardList:Clear()
        this.addDataToCardItem()
        ECS.diyBattleSystem:Enter(false)
    else
        --Log("robot_battle 第" .. groupIndex .. "组机器人第" .. failuretime .. "次失败关卡" .. monsterlevel)
        ECS.diyBattleSystem:Enter(false)
    end
end

function DiyCardManager.RoundOverClear()
    failuretime = 0
    monsterlevel = 1
end

function DiyCardManager.GetStarBaseLevelRange(color, level)
    local colorList = {}
    for key, value in pairs(ConfigManager.GetAllStarRank()) do
        if value.color == color then
            table.insert(colorList, value)
        end
    end
    local star = 1
    if color == "blue" then
        if level > 0 and level <= colorList[1].limit_level then
            star = colorList[1].id
        elseif level > colorList[1].limit_level and level <= colorList[2].limit_level then
            star = colorList[2].id
        elseif level > colorList[2].limit_level and level <= colorList[3].limit_level then
            star = colorList[3].id
        end
    elseif color == "purple" then
        if level > 0 and level <= colorList[1].limit_level then
            star = colorList[1].id
        elseif level > colorList[1].limit_level and level <= colorList[2].limit_level then
            star = colorList[2].id
        elseif level > colorList[2].limit_level and level <= colorList[3].limit_level then
            star = colorList[3].id
        elseif level > colorList[3].limit_level and level <= colorList[4].limit_level then
            star = colorList[4].id
        end
    elseif color == "orange" then
        star = colorList[1].id
    end
    return star
end
