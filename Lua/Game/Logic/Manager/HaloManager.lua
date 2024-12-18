HaloManager = {}
HaloManager.__cname = "HaloManager"

local this = HaloManager

--初始化
function HaloManager.Init()
end

this.halotype = -1
function HaloManager.HeroHaloData()
    local teamCamp = {}
    local sceneEntity = SceneEntity.currentScene
    sceneComp = sceneEntity:GetComponent(SceneComponent)
    for k, v in pairs(sceneComp.HeroEntitys) do
        local cmap = v.EntityData.occupation
        table.insert(teamCamp, cmap)
    end
    this.halotype = this.CalculateHaloData(teamCamp)
    --print("[error]" .. "type:" .. this.halotype)
    if this.halotype ~= -1 then
        if not TutorialManager.IsComplete(TutorialStep.ToHalo) then
            TutorialManager.TriggerTutorial(TutorialStep.ToHalo)
        end
    end
    EventManager.Brocast(EventType.HALO_DATA_HERO, this.halotype)
end

this.enemyHalotype = -1
function HaloManager.EnemyHaloData()
    local teamCamp = {}
    local sceneEntity = SceneEntity.currentScene
    sceneComp = sceneEntity:GetComponent(SceneComponent)
    for k, v in pairs(sceneComp.BossEntitys) do
        local cmap = v.EntityData.occupation
        table.insert(teamCamp, cmap)
    end
    this.enemyHalotype = this.CalculateHaloData(teamCamp)
    LogWarning("Enemy type:" .. this.enemyHalotype)
    EventManager.Brocast(EventType.HALO_DATA_ENEMY, this.enemyHalotype)
end

--计算光环数据
function HaloManager.CalculateHaloData(teamCamp)
    local soldoer = 0
    local scientist = 0
    local gang = 0
    for index = 1, #teamCamp do
        if teamCamp[index] == "soldier" then
            soldoer = soldoer + 1
        elseif teamCamp[index] == "scientist" then
            scientist = scientist + 1
        elseif teamCamp[index] == "gang" then
            gang = gang + 1
        end
    end

    local halotype = -1
    if soldoer == 5 or scientist == 5 or gang == 5 then
        halotype = 5
    elseif soldoer == 4 or scientist == 4 or gang == 4 then
        halotype = 4
    elseif soldoer == 3 and (scientist == 2 or gang == 2) then
        halotype = 6
    elseif scientist == 3 and (soldoer == 2 or gang == 2) then
        halotype = 6
    elseif gang == 3 and (soldoer == 2 or scientist == 2) then
        halotype = 6
    elseif soldoer == 3 or scientist == 3 or gang == 3 then
        halotype = 3
    end
    return halotype
end

-- 得到hero光环类型
function HaloManager.GetHeroHaloType()
    return this.halotype
end

--得到enemy光环类型
function HaloManager.GetenemyHaloType()
    return this.enemyHalotype
end

this.paneltype = ""
function HaloManager.SetpanelType(type)
    this.paneltype = type
end

function HaloManager.GetpanelType()
    return this.paneltype
end

function HaloManager.GethaloAttributeData(type)
    local atk = 1
    local def = 1
    local hp = 1
    local troopsRatio
    local troopsmin
    local typeData = -1
    if type == "Hero" then
        typeData = this.halotype
    elseif type == "Enemy" then
        typeData = this.enemyHalotype
    end
    local data = nil
    if typeData == 6 then
        data = ConfigManager.GetMiscConfig("card_property_group_3_2")
    elseif typeData == 5 then
        data = ConfigManager.GetMiscConfig("card_property_group_5")
    elseif typeData == 4 then
        data = ConfigManager.GetMiscConfig("card_property_group_4")
    elseif typeData == 3 then
        data = ConfigManager.GetMiscConfig("card_property_group_3")
    else
        data = {0, 0, 0, 0, 0}
    end
    atk = data[1]
    def = data[2]
    hp = data[3]
    troopsRatio = data[4]
    troopsmin = data[5]
    return atk, def, hp, troopsRatio, troopsmin
end

function HaloManager.GethalotroopsData(type)
    local addRatio = 1
    local minThreshold = 1
    local typeData = -1
    if type == "Hero" then
        typeData = this.halotype
    elseif type == "Enemy" then
        typeData = this.enemyHalotype
    end
    local data = nil
    if typeData == 6 then
        data = ConfigManager.GetMiscConfig("card_property_group_3_2")
    elseif typeData == 5 then
        data = ConfigManager.GetMiscConfig("card_property_group_5")
    elseif typeData == 4 then
        data = ConfigManager.GetMiscConfig("card_property_group_4")
    elseif typeData == 3 then
        data = ConfigManager.GetMiscConfig("card_property_group_3")
    else
        data = {0, 0, 0, 0, 0}
    end
    addRatio = data[4]
    minThreshold = data[5]
    --EventManager.Brocast(EventType.Battle_HALO_ADDTROOPS_HERO, addRatio, minThreshold)
    return addRatio, minThreshold
end
