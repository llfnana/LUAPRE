TroopsComponentManager = {}
TroopsComponentManager.__cname = "TroopsComponentManager"
local this = TroopsComponentManager

--初始化ToolTip管理器
function TroopsComponentManager.Init()
end

--解析小兵配置
function TroopsComponentManager.parseConfi(selfData)
    local entityData = selfData
    local assetName = entityData.EntityData.asset_name
    local troopCpms = ConfigManager.GettroopsComponents(assetName)
    local assetName = troopCpms.asset_name
    local type = troopCpms.type
    local poolKey = ""
    if entityData.spriteType == 1 then
        assetName = assetName .. "_red"
        poolKey = entityData.EntityData.asset_name .. "_red"
    else
        assetName = assetName .. "_blue"
        poolKey = entityData.EntityData.asset_name .. "_blue"
    end
    local hangPointData = {
        originassetName = troopCpms.asset_name,
        gun = troopCpms.gun,
        head = troopCpms.head,
        lefthand = troopCpms.left_hand,
        back = troopCpms.back,
        assetname = assetName,
        poolkey = poolKey
    }

    return hangPointData, type == "gpu"
end

--解析技能配置
function TroopsComponentManager.parseActionConfig(selfData)
    local entityData = selfData
    local assetName = entityData.EntityData.asset_name
    local troopCpms = ConfigManager.GettroopsComponents(assetName)
    local actionMap = {
        idle = troopCpms.idle,
        run = troopCpms.run,
        attack = troopCpms.attack,
        attack_1 = troopCpms.attack_1,
        attack_2 = troopCpms.attack_2,
        attack_3 = troopCpms.attack_3,
        celebrate_1 = "celebrate_1",
        celebrate_2 = "celebrate_2"
    }
    return actionMap
end
