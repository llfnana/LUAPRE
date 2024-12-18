ConfigManager = {}
ConfigManager.__cname = "ConfigManager"
local this = ConfigManager
local configFiles = {
    "CitiesConf",
    "ZonesConf",
    -- "FurnituresConf",
    "PeopleConf",
    "SchedulesConf",
    "ItemsConf",
    -- "TaskConf",
    "TaskTypeConf",
    "TaskMilestoneConf",
    "CardConf",
    "CardSkillConf",
    "CardPropertiesConf",
    "CardMonsterConf",
    "CardBattleLevelConf",
    "NecessitiesConf",
    "FormulaConf",
    "CardSkillBuffConf",
    "CardUpgradeConf",
    "CardStarRankConf",
    "BoostConf",
    "BoxConf",
    "BoxChanceConf",
    "BoxChanceGuaranteeConf",
    "BoxFixConf",
    "TutorialTypeConf",
    "IAPConf",
    "FunctionsUnlockConf",
    "ShopConf",
    "AdResourceRewardsConf",
    "CardTroopsConf",
    "ShopDailyConf",
    "DiseaseConf",
    "ShopPackageConf",
    "SpecialGridConf",
    "SurveyConf",
    "HappyMailConf",
    -- "FurnituresBuildCostConf",
    "EventCitiesConf",
    "EventMilestoneConf",
    "EventRankConf",
    "EventTrickConf",
    "EventRankConf",
    "EventWarehouseConf",
    "EventVanConf",
    "ExploreConf",
    "ExploreUnitConf",
    "ProtestGroupNewConf",
    "ProtestAppeaseNewConf",
    "EventSlotConf",
    "EventConf",
    "PlayerIconConf",
    "ShopSceneDisplayConf",
    "BattleRobotConf",
    "StoryBookConf",
    "PushConf",
    -- "FurnituresMilestoneConf",
    "UserTypeConf",
    "ubt",
    "Casino_Rwd",
    "Casino",
}

local configRootPath = "Game/Config/"
this.allConfig = {}

ConfigManager.ShopDailyType = {
    dissolve = "dissolve"
}
ConfigManager.ZoneDataVersion = 2

--初始化配置表
function ConfigManager.Init()
    this.allConfig["MiscConf"] = require("Game/Config/MiscConf")[1]
end

function ConfigManager.GetCityId()
    return DataManager.GetCityId()
end

--设置FirebaseRemoteConfig
function ConfigManager.SetFirebaseMiscConfig(remoteConfig)
    for key, value in pairs(remoteConfig) do
        if this.allConfig["MiscConf"][key] ~= nil then
            if type(this.allConfig["MiscConf"][key]) == "number" then
                this.allConfig["MiscConf"][key] = tonumber(value)
            elseif type(this.allConfig["MiscConf"][key]) == "string" then
                this.allConfig["MiscConf"][key] = tostring(value)
            elseif type(this.allConfig["MiscConf"][key]) == "boolean" then
                this.allConfig["MiscConf"][key] = value == "true"
            elseif type(this.allConfig["MiscConf"][key]) == "table" then
                this.allConfig["MiscConf"][key] = JSON.decode(value)
            end
        else
            this.allConfig["MiscConf"][key] = value
        end
    end
end

--设置GMTool远程miscConfig
function ConfigManager.SetGMRemoteMiscConfig(remoteConfig)
    for key, value in pairs(remoteConfig) do
        this.allConfig["MiscConf"][key] = value
    end
end

--设置miscConfig
function ConfigManager.SetMiscConfig(key, value)
    this.allConfig["MiscConf"][key] = value
end

--AB打点Log
function ConfigManager.TraceABTestKeys()
    -- local abTestKeysStr = FirebaseManager.GetConfigParam("ABTestKeys")
    -- if abTestKeysStr ~= nil then
    --     local abTestKeys = JSON.decode(abTestKeysStr)
    --     local ablog = {}
    --     if abTestKeys ~= nil then
    --         for index, key in pairs(abTestKeys) do
    --             ablog[key] = ConfigManager.GetMiscConfig(key)
    --             LogWarning("abTestKey:" .. key .. "=" .. tostring(ConfigManager.GetMiscConfig(key)))
    --         end
    --     end
    --     Analytics.TraceEvent("ABTest", ablog)
    -- end
end

--初始化配置表
function ConfigManager.RequireConfig()
    for index, fileName in pairs(configFiles) do
        local luaFileName = fileName
        if this.GetMiscConfig(fileName) ~= nil then
            luaFileName = this.GetMiscConfig(fileName)
            LogWarning("LoadConfig: " .. fileName .. "--->" .. this.GetMiscConfig(fileName))
        end
        -- this.allConfig[fileName] = require(luaFile)
        --this.allConfig[fileName] = load(ResourceManager.Load("config/" .. luaFileName, TypeTextAsset).text)()
        this.allConfig[fileName] = require("Game/Config/" .. luaFileName)
    end
    this.HandleConfig()
end

--处理配置缓存
function ConfigManager.HandleConfig()
    -- local furnituresCfgs = this.allConfig["FurnituresConf"]
    this.furnitures = {}
    -- for id, value in pairs(furnituresCfgs) do
    --     this.furnitures[value.city_id] = this.furnitures[value.city_id] or {}
    --     this.furnitures[value.city_id][value.zone_type] = this.furnitures[value.city_id][value.zone_type] or List:New()
    --     this.furnitures[value.city_id][value.zone_type]:Add(value)
    -- end
    -- local furnituresMilestoneCfgs = this.allConfig["FurnituresMilestoneConf"]
    this.furnituresMilestone = {}
    -- for id, value in pairs(furnituresMilestoneCfgs) do
    --     this.furnituresMilestone[value.zone_id] = this.furnituresMilestone[value.zone_id] or {}
    --     this.furnituresMilestone[value.zone_id][value.type] = value
    -- end
end

function ConfigManager.GetAllConfig()
    return this.allConfig
end

--获取打点配置
---@return id
function ConfigManager.GetAnalyticsById(id)
    return this.allConfig["ubt"][id]
end

--获取城市配置
---@return Cities
function ConfigManager.GetCityById(id)
    id = tostring(id)
    return this.allConfig["CitiesConf"][id]
end

--获取新用户初始化数据
function ConfigManager.GetInitUserData()
   -- return load(ResourceManager.Load("config/InitUserData", TypeTextAsset).text)()
     return require("Game/Config/InitUserData")
end

--获取当前城市所有区域
---@return table<string, Zones>
function ConfigManager.GetZonesByCityId(cityId)
    local cfg = this.allConfig["ZonesConf"]
    local ret = Dictionary:New()
    for key, value in pairs(cfg) do
        if value["city_id"] == cityId then
            ret:Add(key, value)
        end
    end
    return ret
end

--根据卡牌类型获取zoneId
function ConfigManager.GetZoneInfoByCardId(cardId)
    local ret = nil
    local zonesConfigList = this.allConfig["ZonesConf"]
    for zoneId, zoneCfg in pairs(zonesConfigList) do
        for i, card_id in ipairs(zoneCfg.card_id) do
            if card_id == cardId then
                ret = zoneId
                return ret
            end
        end
    end
    return ret
end

--根据卡牌类型获取zoneId
function ConfigManager.GetZoneIdByCardId(cityId, cardId)
    local ret = nil
    local zonesConfigList = this.GetZonesByCityId(cityId)
    zonesConfigList:ForEachKeyValue(
        function(zoneId, zoneCfg)
            for i, card_id in ipairs(zoneCfg.card_id) do
                if card_id == cardId then
                    ret = zoneId
                    return true
                end
            end
        end
    )
    return ret
end

--根据区域类型获取zoneIds
function ConfigManager.GetZoneIdsByZoneType(cityId, zoneType)
    local zoneIds = List:New()
    local zonesConfigList = this.GetZonesByCityId(cityId)
    zonesConfigList:ForEachKeyValue(
        function(zoneId, zoneCfg)
            if zoneCfg.zone_type == zoneType then
                zoneIds:Add(zoneId)
            end
        end
    )
    return zoneIds
end

--根据区域类型获取zoneId
function ConfigManager.GetZoneIdByZoneType(cityId, zoneType)
    local zoneIds = this.GetZoneIdsByZoneType(cityId, zoneType)
    if zoneIds:Count() >= 1 then
        return zoneIds[1]
    end
    return nil
end

--获取区域配置
---@return Zones
function ConfigManager.GetZoneConfigById(id)
    local cfg = this.allConfig["ZonesConf"]
    return cfg[id]
end

--根据类型获取zone config
function ConfigManager.GetZoneConfigListByType(cityId, zoneType)
    local zones = List:New()
    local cfg = this.allConfig["ZonesConf"]
    for key, value in pairs(cfg) do
        if value["city_id"] == cityId and value["zone_type"] == zoneType then
            zones:Add(value)
        end
    end
    return zones
end

--获取区域家居列表
function ConfigManager.GetFurnituresList(cityId, zoneType)
    if this.furnitures == nil or this.furnitures[cityId] == nil then 
        ConfigManager.LoadAndHandleFurnituresConfig(cityId)
    end

    local ret = List:New()
    if this.furnitures[cityId][zoneType] then
        ret = this.furnitures[cityId][zoneType]
    end
    ret:Sort(
        function(a, b)
            return a.sort < b.sort
        end
    )
    return ret
end

function ConfigManager.LoadAndHandleFurnituresConfig(cityId)
    local cityCount = ConfigManager.GetCityCount()
    for i = 1, cityCount, 1 do
        local path = "Game/Config/FurnituresConf_" .. i
        package.loaded[path] = nil
    end
    
    this.furnitureConfig = require("Game/Config/FurnituresConf_" .. cityId)
    this.furnitures = {}
    for id, value in pairs(this.furnitureConfig) do
        this.furnitures[value.city_id] = this.furnitures[value.city_id] or {}
        this.furnitures[value.city_id][value.zone_type] = this.furnitures[value.city_id][value.zone_type] or List:New()
        this.furnitures[value.city_id][value.zone_type]:Add(value)
    end
end

--获取区域家居配置
---@return Furnitures
function ConfigManager.GetFurnitureById(furnitureId)
    if this.furnitureConfig == nil or this.furnitureConfig[furnitureId] == nil then 
        local cityId = DataManager.GetCityId()
        ConfigManager.LoadAndHandleFurnituresConfig(cityId)
    end
    -- local cfg = this.allConfig["FurnituresConf"]
    return this.furnitureConfig[furnitureId]
end

--获取离线时间
function ConfigManager.GetOfflineTime()
    return 120
end

function ConfigManager.GetSchedulesByCityId(cityId)
    local ret = List:New()
    for id, value in pairs(this.allConfig["SchedulesConf"]) do
        if value.city_id == cityId then
            ret:Add(value)
        end
    end
    return ret
end

--获取人物职业配置列表
---@return People[]
function ConfigManager.GetPeopleList(cityId)
    local ret = List:New()
    for id, people in pairs(this.allConfig["PeopleConf"]) do
        if people.city_id == cityId then
            ret:Add(people)
        end
    end
    ret:Sort(
        function(p1, p2)
            return p1.sort < p2.sort
        end
    )
    return ret
end

function ConfigManager.GetPeopleConfigByFurnitureId(cityId, furnitureId)
    for id, people in pairs(this.allConfig["PeopleConf"]) do
        if people.furniture_id == furnitureId and people.city_id == cityId then
            return people
        end
    end
end

--获取食物列表
function ConfigManager.GetFoodItemConfigs(cityId)
    local ret = List:New()
    for id, item in pairs(this.allConfig["ItemsConf"]) do
        if item.type == ItemUseType.Food and item.city_id == cityId and item.scope == "City" then
            ret:Add(item)
        end
    end
    ret:Sort(
        function(p1, p2)
            return p1.sort < p2.sort
        end
    )
    return ret
end

function ConfigManager.GetGameItemCinfig(type)
    local ret = List:New()
    for id, item in pairs(this.allConfig["ItemsConf"]) do
        if item.type == type then
            ret:Add(item)
        end
    end
    return ret
end

--初始化城市默认食物类型
function ConfigManager.GetDefaultFoodType(cityId)
    local cityConfig = this.GetCityById(cityId)
    return this.GetFoodItemConfigs(cityId)[cityConfig.default_food].id
end

--获取食物配置
function ConfigManager.GetFoodConfigByType(foodType)
    return this.allConfig["ItemsConf"][foodType]
end

--获取必需品配置
function ConfigManager.GetNecessitiesConfig(cityId, type)
    return this.allConfig["NecessitiesConf"]["C" .. cityId .. "_" .. type]
end

--获取必需品初始值
function ConfigManager.GetNecessitiesStartValue(cityId, type)
    local config = this.GetNecessitiesConfig(cityId, type)
    if nil ~= config then
        return config.start_value
    end
    return 0
end

--获取属性最大值
function ConfigManager.GetNecessitiesMaxValue(cityId, type)
    local config = this.GetNecessitiesConfig(cityId, type)
    if nil ~= config then
        return config.max_value
    end
    return 100
end

--获取属性安全值
function ConfigManager.GetNecessitiesSafeLine(cityId, type)
    local config = this.GetNecessitiesConfig(cityId, type)
    if nil ~= config then
        return config.safe_line
    end
    return 0
end

--获取原材料列表
function ConfigManager.GetMaterialListByCityId(cityId, needInfinity)
    local ret = List:New()
    for id, item in pairs(this.allConfig["ItemsConf"]) do
        if item.type == ItemUseType.Material and item.city_id == cityId then
            if needInfinity then
                ret:Add(item)
            elseif not DataManager.CheckInfinity(cityId, id) then
                ret:Add(item)
            end
        end
    end
    ret:Sort(
        function(p1, p2)
            return p1.sort < p2.sort
        end
    )
    return ret
end

--根据城市id获取所有item
---@return Items[]
function ConfigManager.GetItemList(cityId)
    local ret = List:New()
    for id, item in pairs(this.allConfig["ItemsConf"]) do
        if item.city_id == cityId then
            ret:Add(item)
        end
    end
    return ret
end

function ConfigManager.GetItemListBySort(cityId, scope)
    local ret = List:New()
    for id, item in pairs(this.allConfig["ItemsConf"]) do
        if item.city_id == cityId and item.scope == scope then
            ret:Add(item)
        end
    end
    ret:Sort(
        function(p1, p2)
            return p1.sort < p2.sort
        end
    )
    return ret
end

--获取全局Item列表
function ConfigManager.GetInitItemList(cityId)
    local ret = List:New()
    for id, item in pairs(this.allConfig["ItemsConf"]) do
        if item.is_init and item.city_id <= cityId then
            ret:Add(item)
        end
    end
    ret:Sort(
        function(p1, p2)
            return p1.sort < p2.sort
        end
    )
    return ret
end

--根据城市id获取物品类型，只获取资源类型（没有食物）
function ConfigManager.GetItemTypeMaterialList(cityId)
    local ret = List:New()
    for id, item in pairs(this.allConfig["ItemsConf"]) do
        if item.scope == "City" then
            if item.city_id == cityId and item.type ~= "Food" then
                ret:Add(item.id)
            end
        elseif item.scope == "Global" then
            ret:Add(item.id)
        end
    end
    return ret
end

--根据城市id获取物品类型
function ConfigManager.GetItemTypesById(cityId, containGlobal)
    local ret = List:New()
    for id, item in pairs(this.allConfig["ItemsConf"]) do
        if item.scope == "City" and item.city_id == cityId then
            ret:Add(item.id)
        elseif containGlobal and item.scope == "Global" then
            ret:Add(item.id)
        end
    end
    return ret
end

--获取Item物品配置
---@return Items
function ConfigManager.GetItemConfig(itemId)
    return this.allConfig["ItemsConf"][itemId]
end

-- function ConfigManager.GetItemConfigByType(cityId, type)
--     local itemList = this.GetItemList(cityId)
--     local item = {}
--     itemList:ForEach(
--         function(value)
--             if value.item_type == type then
--                 item = value
--                 return true
--             end

--             return false
--         end
--     )

--     return item
-- end

function ConfigManager.GetItemIdByZoneType(cityId, zoneType)
    local itemList = List:New()
    for _, item in pairs(this.allConfig["ItemsConf"]) do
        if item.city_id <= cityId then
            itemList:Add(item)
        end
    end

    local itemId = ""

    itemList:Sort(
        function(a, b)
            return a.city_id > b.city_id
        end
    )

    itemList:ForEach(
        function(item)
            if Utils.ArrayHas(item.producted_in, zoneType) then
                itemId = item.id
                return true
            end

            return false
        end
    )

    return itemId
end

---@return Items
function ConfigManager.GetItemByType(cityId, type)
    for _, item in pairs(this.allConfig["ItemsConf"]) do
        if item.city_id == cityId and item.item_type == type then
            return item
        end
    end

    return nil
end

---根据资源类型返回item
---@param cityId number
---@param resourceType number
---@return Items[]
function ConfigManager.GetItemByResourceType(cityId, resourceType)
    local itemList = List:New()

    for _, item in pairs(this.allConfig["ItemsConf"]) do
        if item.city_id == cityId and item.resource_type == resourceType then
            itemList:Add(item)
        end
    end

    return itemList
end

---返回场景中最高resource_type
function ConfigManager.GetItemResourceTypeMax(cityId)
    local max = 0
    for _, item in pairs(this.allConfig["ItemsConf"]) do
        if item.city_id == cityId and item.resource_type > max then
            max = item.resource_type
        end
    end

    return max
end

--返回人物属性
function ConfigManager.GetPeopleConfig(peopleId)
    return this.allConfig["PeopleConf"][peopleId]
end

--根据区域类型返回职业配置
---@return People
function ConfigManager.GetPeopleConfigByZoneType(cityId, zoneType)
    local ret = nil
    for id, people in pairs(this.allConfig["PeopleConf"]) do
        if people.city_id == cityId and people.zone_type == zoneType then
            ret = people
        end
    end
    return ret
end

--根据职业类型获取职业配置
function ConfigManager.GetPeopleConfigByType(cityId, type)
    local ret = nil
    for id, people in pairs(this.allConfig["PeopleConf"]) do
        if people.city_id == cityId and people.type == type then
            ret = people
        end
    end
    return ret
end

--返回产物所需的原材料
function ConfigManager.GetInputByOutput(output)
    local input = {}
    for itemId, count in pairs(output) do
        local itemConfig = this.GetItemConfig(itemId)
        for i = 1, #itemConfig.ingredients, 1 do
            for iItemId, iCount in pairs(itemConfig.ingredients[i]) do
                input[iItemId] = iCount * count
            end
        end
    end
    return input
end

function ConfigManager.GetPriceByLoadLimit(loadLimit)
    local price = {}
    for itemId, count in pairs(loadLimit) do
        local itemConfig = this.GetItemConfig(itemId)
        for iItemId, iCount in pairs(itemConfig.price) do
            price[iItemId] = iCount
        end
    end
    return price
end

--返回MiscConfig
function ConfigManager.GetMiscConfig(key)
    return this.allConfig["MiscConf"][key]
end

--根据城市id和章节id获取配置列表
function ConfigManager.GetTaskConfigList(partId)
    local ret = Dictionary:New()
    local taskConfig = this._GetTaskConfig()
    for id, value in pairs(taskConfig) do
        if value.part == partId then
            ret:Add(id, value)
        end
    end
    return ret
end

--获取所有小于给定stage的任务partId和taskId
function ConfigManager.GetTaskPartIdAndIdByStage(stage)
    local partId = 0
    local taskIdx = 0
    local taskConfig = this._GetTaskConfig()
    for id, value in pairs(taskConfig) do
        if value.stage < stage then
            if value.part > partId then
                partId = value.part
                taskIdx = 0
            end

            if value.index > taskIdx then
                taskIdx = value.index
            end
        end
    end
    return partId, taskIdx
end

function ConfigManager._GetTaskConfig()
    local city_id = DataManager.GetCityId()
    if this.taskConfigs == nil or this.taskConfigs[city_id] == nil then 
        local cityCount = ConfigManager.GetCityCount()
        for i = 1, cityCount, 1 do
            local path = "Game/Config/TaskConf_" .. i
            package.loaded[path] = nil
        end

        this.taskConfigs = {}
        this.taskConfigs[city_id] = require("Game/Config/TaskConf_" .. city_id)
    end

    return this.taskConfigs[city_id]
end

--根据任务id获取配置
---@return Task
function ConfigManager.GetTaskConfig(id)
    return this._GetTaskConfig()[id]
end

--根据id获取任务类型
function ConfigManager.GetTaskTypeConfig(id)
    return this.allConfig["TaskTypeConf"][id]
end

--根据id获取任务里程
---@return TaskMilestone
function ConfigManager.GetTaskMilestoneConfig(cityId, partId)
    for id, value in pairs(this.allConfig["TaskMilestoneConf"]) do
        if value.city == cityId and value.part == partId then
            return value
        end
    end
    return nil
end

--获取当前场景所有章节
function ConfigManager.GetTaskMilestoneList(cityId)
    local ret = Dictionary:New()
    for id, value in pairs(this.allConfig["TaskMilestoneConf"]) do
        if value.city == cityId then
            ret:Add(id, value)
        end
    end
    return ret
end

--获取城市数量
function ConfigManager.GetCityCount()
    local count = Utils.GetTableCount(this.allConfig["CitiesConf"])
    return count
end

--获取城市id列表
function ConfigManager.GetCityIdList()
    local cityIds = List:New()
    for k, v in pairs(this.allConfig["CitiesConf"]) do
        cityIds:Add(k)
    end

    return cityIds
end

--返回Card Config
---@return Card
function ConfigManager.GetCardConfig(id)
    return this.allConfig["CardConf"][id]
end

--返回Card List
function ConfigManager.GetCardConfigList()
    local filter = function(item)
        return CardManager.IsCardValidInCurrentCity(item.id)
    end
    local cardList = ConfigManager.GetCardConfigListByFilter(filter)

    cardList:Sort(
        function(p1, p2)
            return p1.sort < p2.sort
        end
    )
    return cardList
end

function ConfigManager.GetUnlockCardConfigList()
    if GameManager.IsCardNew() then
        local filter = function(item)
            return CardManager.IsCardUnlockInCurrentCity(item)
        end
        local cardList = ConfigManager.GetCardConfigListByFilter(filter)

        cardList:Sort(
            function(p1, p2)
                return p1.sort < p2.sort
            end
        )
        return cardList
    else
        return ConfigManager.GetCardConfigList()
    end
end

function ConfigManager.GetCityCardList()
    local filter = function(item)
        local scope = item.scope[CityType.City]
        if scope ~= nil and scope > 0 then
            return true
        end

        return false
    end
    return ConfigManager.GetCardConfigListByFilter(filter)
end

function ConfigManager.GetEventCardList(cityId)
    local filter = function(item)
        local scope = item.scope[CityType.Event]
        if scope ~= nil and scope == cityId then
            return true
        end

        return false
    end

    local cardList = ConfigManager.GetCardConfigListByFilter(filter)
    return cardList
end

---@param filter function
function ConfigManager.GetCardConfigListByFilter(filter)
    local ret = List:New()
    for id, item in pairs(this.allConfig["CardConf"]) do
        if filter ~= nil then
            if filter(item) then
                ret:Add(item)
            end
        else
            ret:Add(item)
        end
    end
    return ret
end

function ConfigManager.GetCardConfigListbyPower()
    local filter = function(item)
        if not CardManager.IsCardValidInCurrentCity(item.id) then
            return false
        end
        if CardManager.IsUnlock(item.id) then
            return true
        end
        return false
    end
    local cardList = ConfigManager.GetCardConfigListByFilter(filter)
    cardList:Sort(
        function(p1, p2)
            local p1pow = HeroBattleDataManager.GetCardPower(p1.id)
            local p2pow = HeroBattleDataManager.GetCardPower(p2.id)
            if p1pow == p2pow then
                return p1.sort < p2.sort
            else
                return p1pow > p2pow
            end
        end
    )
    return cardList
end

--返回CardLevelConfig
function ConfigManager.GetCardLevelConfig(level)
    return this.allConfig["CardLevelConf"][level]
end

--返回卡牌属性
function ConfigManager.GetCardPropertiesConfig(id)
    return this.allConfig["CardPropertiesConf"][id]
end

--返回卡牌技能属性
function ConfigManager.GetCardSkillConfig(skillId)
    return this.allConfig["CardSkillConf"][skillId]
end

--返回战斗场景配置
function ConfigManager.GetCardBattleLevel(bl)
    return this.allConfig["CardBattleLevelConf"][bl]
end

--返回战斗场景配置数量
function ConfigManager.GetCardBattleCount()
    return #this.allConfig["CardBattleLevelConf"]
end

--返回怪物配置
function ConfigManager.GetMonsterConfig(mid)
    return this.allConfig["CardMonsterConf"][mid]
end

--获取温度配置
function ConfigManager.GetTempConfigByExp(exp)
    local tempConfig = nil
    for key, value in pairs(this.allConfig["TempConf"]) do
        if exp < value.scene_exp then
            break
        else
            tempConfig = value
        end
    end
    return tempConfig
end

--获取公式配置
function ConfigManager.GetFormulaConfigById(id)
    return this.allConfig["FormulaConf"][id]
end

--返回技能buff属性
function ConfigManager.GetSkillBuffConfig(buffId)
    return this.allConfig["CardSkillBuffConf"][buffId]
end

function ConfigManager.GetCasino_RwdConfig()
    return this.allConfig["Casino_Rwd"]
end

function ConfigManager.GetCasino(level)
    return this.allConfig["Casino"][level]
end

function ConfigManager.GetCasinoAll()
    return this.allConfig["Casino"]
end

--获取升级卡牌所需要的爱心
---@return number
function ConfigManager.GetCardUpgradeHeartCost(cardLevel, group)
    if group == nil then
        group = 1
    end
    local cardUpgrade = this.allConfig["CardUpgradeConf"]
    for key, value in pairs(cardUpgrade) do
        if value.level == cardLevel and value.group == group then
            return value.heart_cost
        end
    end

    return 0
    --return this.allConfig["CardUpgradeConf"][cardLevel].heart_cost
end

--获取卡牌星级配置
function ConfigManager.GetCardStarConfig(star)
    return this.allConfig["CardStarRankConf"][star]
end

--获取卡牌初始星级
function ConfigManager.GetCardStarInitRank(cardConfig)
    --local cardColor = cardConfig.color
    --local cardCityId = CardManager.GetCardCityId(cardConfig)
    --local ret = 999999999
    --for rank, rankConfig in pairs(this.allConfig["CardStarRankConf"]) do
    --    if rankConfig.color == cardColor and rankConfig.id < ret then
    --        local rankCityId = CardManager.GetCardCityId(rankConfig)
    --        if cardCityId == rankCityId then
    --            ret = rankConfig.id
    --        end
    --    end
    --end
    local ret = 1001
    if cardConfig ~= nil then
        local starConfig = ConfigManager.GetCardStarConfig(cardConfig.born_stars)
        if starConfig ~= nil and starConfig.id > ret then
            ret = starConfig.id
        end
    end
    return ret
end

--获取卡牌最高星级
function ConfigManager.GetCardMaxStarRank(cardConfig)
    local cardColor = cardConfig.color
    local cardCityId = CardManager.GetCardCityId(cardConfig)
    local isEventCity = CityManager.GetIsEventScene(cardCityId)
    local ret = 0
    for rank, rankConfig in pairs(this.allConfig["CardStarRankConf"]) do
        if rankConfig.color == cardColor and rankConfig.id > ret then
            local rankCityId = CardManager.GetCardCityId(rankConfig)
            if isEventCity then
                if cardCityId == rankCityId then
                    ret = rankConfig.id
                end
            else
                if cardCityId >= rankCityId then
                    ret = rankConfig.id
                end
            end
        end
    end
    return ret
end

-- --根据id获取效果类型
-- function ConfigManager.GetEffectTypeConfig(id)
--     return this.allConfig["EffectTypeConf"][id]
-- end

-- --根据id获取暴动计数器配置
-- function ConfigManager.GetProtestCounterConfig(id)
--     return this.allConfig["ProtestCounterConf"][id]
-- end

--根据城市id获取黑市配置列表
-- function ConfigManager.GetBlackMarketConfigList(cityId)
--     local ret = List:New()
--     for id, item in pairs(this.allConfig["BlackMarketConf"]) do
--         if item.city == cityId then
--             ret:Add(item)
--         end
--     end
--     ret:Sort(
--         function(p1, p2)
--             return p1.sort < p2.sort
--         end
--     )
--     return ret
-- end

-- --获取OfficeConfig
-- function ConfigManager.GetOfficeConfig(cityId)
--     local ret = nil
--     for id, item in pairs(this.allConfig["OfficeConf"]) do
--         if item.city_id == cityId then
--             ret = item
--         end
--     end
--     return ret
-- end

--获取当前城市解锁的ResourceType的材料
function ConfigManager.GetItemListByResourceType(cityId, resourceType)
    local ret = List:New()
    for id, item in pairs(this.allConfig["ItemsConf"]) do
        if item.city_id <= cityId and item.resource_type == resourceType then
            ret:Add(item)
        end
    end
    ret:Sort(
        function(p1, p2)
            return p1.sort < p2.sort
        end
    )
    return ret
end

--获取当前城市的卡牌
function ConfigManager.GetCardListByCity(cityId)
    local ret = List:New()
    for id, item in pairs(this.allConfig["CardConf"]) do
        if item.scope.City and item.scope.City == cityId then
            ret:Add(item)
        end
    end
    return ret
end

--获取当前城市解锁的ResourceType的材料
function ConfigManager.GetItemListByResourceTypeOnlyCity(cityId, resourceType)
    local ret = List:New()
    for id, item in pairs(this.allConfig["ItemsConf"]) do
        if item.city_id == cityId and item.resource_type == resourceType then
            ret:Add(item)
        end
    end
    ret:Sort(
        function(p1, p2)
            return p1.sort < p2.sort
        end
    )
    return ret
end

--获取宝箱配置
---@return Box
function ConfigManager.GetBoxConfig(boxId)
    return this.allConfig["BoxConf"][boxId]
end

--获取所有宝箱配置
function ConfigManager.GetAllBoxConfig()
    return this.allConfig["BoxConf"]
end

--获取宝箱暴率
---@param chanceGroup string
---@param condition function
function ConfigManager.GetBoxChance(chanceGroup, condition)
    local ret = {}
    for index, chanceItem in pairs(this.allConfig["BoxChanceConf"]) do
        if chanceItem.chance_group == chanceGroup and condition(chanceItem) then
            table.insert(ret, chanceItem)
        end
    end
    return ret
end

--获取宝箱固定概率
function ConfigManager.GetBoxFixConfig(boxId, cityId, index)
    local key = boxId .. "_C" .. cityId .. "_" .. index
    return this.allConfig["BoxFixConf"][key]
end

---@return table<string, BoxFix>
function ConfigManager.GetBoxFixAllConfig()
    return this.allConfig["BoxFixConf"]
end

--获取引导类型配置列表
function ConfigManager.GetTutorialTypeConfigs()
    return this.allConfig["TutorialTypeConf"]
end

--获取引导类型配置
function ConfigManager.GetTutorialTypeConfigById(step)
    return this.allConfig["TutorialTypeConf"][step]
end

--获得支付表信息
---@return IAP
function ConfigManager.GetIAPConfig(id)
    return this.allConfig["IAPConf"][id]
end

--获取小兵组件配置
function ConfigManager.GettroopsComponents(id)
    return this.allConfig["CardTroopsConf"][id]
end
--获得支付Ids
function ConfigManager.GetIAPProductIds()
    local ret = {}
    for id, cfg in pairs(this.allConfig["IAPConf"]) do
        table.insert(ret, id)
    end
    return ret
end

--获取功能解锁配置
---@return table<string, FunctionsUnlock>
function ConfigManager.GetFunctionsUnlockConfig()
    return this.allConfig["FunctionsUnlockConf"]
end

--根据类型获取功能解锁配置
function ConfigManager.GetFunctionsUnlockConfigByType(type)
    return this.allConfig["FunctionsUnlockConf"][type]
end

--获取商店列表
function ConfigManager.GetShopListByType(type)
    local ret = List:New()
    for id, item in pairs(this.allConfig["ShopConf"]) do
        if item.type == type then
            ret:Add(item)
        end
    end
    ret:Sort(
        function(p1, p2)
            return p1.sort < p2.sort
        end
    )
    return ret
end

--获取广告奖励配置
function ConfigManager.GetAdResourceRewardConfigByType(id)
    return this.allConfig["AdResourceRewardsConf"][id]
end

function ConfigManager.GetAdWeightByCityId(cityId, typeId)
    local typeWeight = this.GetCityById(cityId).ad_weight[typeId]
    if (typeWeight == nil) then
        return 0
    end
    return typeWeight
end

--根据城市id获取地图格子数据
function ConfigManager.GetMapGrid(cityId)
    local configKey = string.format("map_%s", cityId)
    if not this.allConfig[configKey] then
        --this.allConfig[configKey] = load(ResourceManager.Load("mapconfig/" .. configKey, TypeTextAsset).text)()
         this.allConfig[configKey] = require("Game/Config/" .. configKey)
    end
    return this.allConfig[configKey]
end

--根据城市id获取地图格子数据
function ConfigManager.GetMapGridEx(cityId)
    local configKey = string.format("MRMap_%sData", cityId)
    if not this.allConfig[configKey] then
        --this.allConfig[configKey] = load(ResourceManager.Load("mapconfig/" .. configKey, TypeTextAsset).text)()
        ResInterface.LoadTextSync(configKey, function(str)
            local mdata = json.decode(str)
            local size = mdata.size --地图大小

            local map={}
            map.mapWidth = mdata.size.x *39
            map.mapHeight = mdata.size.y *27
            map.gridWidth = 39
            map.gridHeight = 27
            map.nodeInfos ={}


           
        end, ".json")
        --this.allConfig[configKey] = require("Game/Config/" .. configKey)
    end
    return this.allConfig[configKey]
end

--根据等级区域格子配置
function ConfigManager.GetZoneGridsConfig(assetsName, zoneType)
    local configKey = string.format("zone_%s_%s", assetsName, zoneType)
    if not this.allConfig[configKey] then
       -- this.allConfig[configKey] = load(ResourceManager.Load("mapconfig/" .. configKey, TypeTextAsset).text)()
        this.allConfig[configKey] = require("Game/Config/" .. configKey)
    end
    return this.allConfig[configKey]
end

-- --根据等级区域格子数据
-- function ConfigManager.GetZoneGridsByLevel(assetsName, zoneType, assetLevel)
--     local configKey = string.format("zone_%s_%s", assetsName, zoneType)
--     if not this.allConfig[configKey] then
--         this.allConfig[configKey] = load(ResourceManager.Load("mapconfig/" .. configKey, TypeTextAsset).text)()
--     end
--     return this.allConfig[configKey].zoneGrids[assetLevel]
-- end

-- --根据等级区域格子数据
-- function ConfigManager.GetZoneStairsesByLevel(assetsName, zoneType, assetLevel)
--     local configKey = string.format("zone_%s_%s", assetsName, zoneType)
--     if not this.allConfig[configKey] then
--         this.allConfig[configKey] = load(ResourceManager.Load("mapconfig/" .. configKey, TypeTextAsset).text)()
--     end
--     return this.allConfig[configKey].zoneStairses[assetLevel]
-- end

-- --根据等级获取路径缓存数据
-- function ConfigManager.GetZonePathsByLevel(assetsName, zoneType, assetLevel)
--     local configKey = string.format("zone_%s_%s", assetsName, zoneType)
--     if not this.allConfig[configKey] then
--         this.allConfig[configKey] = load(ResourceManager.Load("mapconfig/" .. configKey, TypeTextAsset).text)()
--     end
--     return this.allConfig[configKey].zonePaths[assetLevel]
-- end

--根据行为树名字读取配置
function ConfigManager.GetBehaivorTreeByName(configKey)
    if not this.allConfig[configKey] then
        --this.allConfig[configKey] = load(ResourceManager.Load("mapconfig/" .. configKey, TypeTextAsset).text)()
        this.allConfig[configKey] =  require("Game/Config" .. configKey)

    end
    return this.allConfig[configKey]
end

---根据type返回所有ShopDaily的项目的Dictionary
---@field type ShopDaily
function ConfigManager.GetShopDailyByType(type)
    local rt = Dictionary:New()
    for k, v in pairs(this.allConfig["ShopDailyConf"]) do
        if v.type == type then
            rt:Add(k, v)
        end
    end

    return rt
end

--根据id获取BoostConfig
---@return Boost
function ConfigManager.GetBoostConfig(boostId)
    return this.allConfig["BoostConf"][boostId]
end

--根据疾病id获取配置
function ConfigManager.GetDiseaseConfigById(id)
    return this.allConfig["DiseaseConf"][id]
end

--根据疾病id获取疾病治愈修正值
function ConfigManager.GetDiseaseCureRateFix(diseaseId)
    local diseaseConfig = this.GetDiseaseConfigById(diseaseId)
    if nil == diseaseConfig then
    end
    return diseaseConfig.cureRate_fix
end

---@return table<number,Shop>
function ConfigManager.GetAllShop()
    return this.allConfig["ShopConf"]
end

---@return table<number,ShopPackage>
function ConfigManager.GetAllShopPackage()
    return this.allConfig["ShopPackageConf"]
end

---@param packageId number
---@return ShopPackage
function ConfigManager.GetShopPackage(packageId)
    return this.allConfig["ShopPackageConf"][packageId]
end

--根据区域类型和格子类型获取配置
function ConfigManager.GetSpecialGridConfig(zoneType, markerType)
    for k, v in pairs(this.allConfig["SpecialGridConf"]) do
        if v.zone_type == zoneType and v.grid_Type == markerType then
            return v
        end
    end
    return nil
end

---@return table<number, Survey>
function ConfigManager.GetAllSurvey()
    return this.allConfig["SurveyConf"]
end

---@return table<number, HappyMail>
function ConfigManager.GetAllHappyMail()
    return this.allConfig["HappyMailConf"]
end

function ConfigManager.GetFurnituresBuildCostConfig(id)
    if this.furnituresBuildCostConfig == nil or this.furnituresBuildCostConfig[id] == nil then 
        this.LoadAndHandleFurnituresBuildCostConfig()
    end

    return this.furnituresBuildCostConfig[id]
end

function ConfigManager.LoadAndHandleFurnituresBuildCostConfig()
    local cityCount = ConfigManager.GetCityCount()
    for i = 1, cityCount, 1 do
        local path = "Game/Config/FurnituresBuildCostConf_" .. i
        package.loaded[path] = nil
    end

    this.furnituresBuildCostConfig = require("Game/Config/FurnituresBuildCostConf_" .. DataManager.GetCityId())
end

---@return Event[]
function ConfigManager.GetEventSceneList()
    local ret = List:New()
    for id, item in pairs(this.allConfig["EventConf"]) do
        ret:Add(item)
    end
    return ret
end

---@return Event
function ConfigManager.GetEventSceneConfigById(id)
    return this.allConfig["EventConf"][id]
end

function ConfigManager.GetEventCashItemId(eventCityId)
    for id, item in pairs(this.allConfig["ItemsConf"]) do
        if item.city_id == eventCityId and item.item_type == ItemType.Cash then
            return item.id
        end
    end
end

function ConfigManager.GetEventPlayCoinItemId(eventCityId)
    for id, item in pairs(this.allConfig["ItemsConf"]) do
        if item.city_id == eventCityId and item.item_type == ItemType.PlayCoin then
            return item.id
        end
    end
end

function ConfigManager.GetEventTrickItemId(eventCityId)
    for id, item in pairs(this.allConfig["ItemsConf"]) do
        if item.city_id == eventCityId and item.item_type == ItemType.Trick then
            return item.id
        end
    end
end

function ConfigManager.GetEventHeartItemId(eventCityId)
    for id, item in pairs(this.allConfig["ItemsConf"]) do
        if item.city_id == eventCityId and item.item_type == ItemType.Heart then
            return item.id
        end
    end
    return nil
end

function ConfigManager.GetEventBlackItemId(eventCityId)
    for id, item in pairs(this.allConfig["ItemsConf"]) do
        if item.city_id == eventCityId and item.item_type == ItemType.BlackCoin then
            return item.id
        end
    end
    return nil
end

---@return EventCities
function ConfigManager.GetEventCityConfigById(id)
    return this.allConfig["EventCitiesConf"][id]
end

function ConfigManager.GetEventMilestoneConfigById(id)
    return this.allConfig["EventMilestoneConf"][id]
end

function ConfigManager.GetEventMilestoneList(group)
    local ret = List:New()
    for id, item in pairs(this.allConfig["EventMilestoneConf"]) do
        if item.group == group then
            ret:Add(item)
        end
    end
    ret:Sort(
        function(p1, p2)
            return p1.sort < p2.sort
        end
    )
    return ret
end

function ConfigManager.GetEventMilestoneRewardList(group)
    local ret = List:New()
    local list = ConfigManager.GetEventMilestoneList(group)
    list:Sort(
        function(p1, p2)
            return p1.sort > p2.sort
        end
    )
    for index, item in pairs(list) do
        local reward = Utils.ParseReward(item.rewards)[1]
        local has = false
        for ix, rwd in pairs(ret) do
            if rwd.id == reward.id then
                rwd.count = rwd.count + reward.count
                has = true
            end
        end
        if not has then
            ret:Add(reward)
        end
    end
    return ret
end

function ConfigManager.GetEventTrickConfig(id)
    return this.allConfig["EventTrickConf"][id]
end

function ConfigManager.GetEventWarehouseList(cityId)
    local ret = List:New()
    for id, item in pairs(this.allConfig["EventWarehouseConf"]) do
        if item.city_id == cityId then
            ret:Add(item)
        end
    end
    ret:Sort(
        function(p1, p2)
            return p1.sort < p2.sort
        end
    )
    return ret
end

---@return EventRank[]
function ConfigManager.GetEventRankByGroup(group)
    local ret = List:New()
    local eventRankConf = this.allConfig["EventRankConf"]
    for i = 1, #eventRankConf do
        if eventRankConf[i].group == group then
            ret:Add(eventRankConf[i])
        end
    end

    return ret
end

function ConfigManager.GetEventWarehouseConfig(itemId)
    return this.allConfig["EventWarehouseConf"][itemId]
end

function ConfigManager.GetEventVanConfig(cityId)
    return this.allConfig["EventVanConf"][cityId]
end

function ConfigManager.GetExploreConfig(id)
    for key, value in pairs(this.allConfig["ExploreConf"]) do
        if value.point_index == tostring(id) then
            return value
        end
    end
    --return this.allConfig["ExploreConf"][id]
end

function ConfigManager.GetExploreUnitConfig(Unitid)
    for id, item in pairs(this.allConfig["ExploreUnitConf"]) do
        if item.unit_id == Unitid then
            return item
        end
    end
end

--获取暴动组配置
function ConfigManager.GetProtestGroupConfigs()
    return this.allConfig["ProtestGroupNewConf"]
end

--根据id获取暴动组配置
function ConfigManager.GetProtestGroupConfigById(id)
    return this.allConfig["ProtestGroupNewConf"][id]
end

--根据暴动组id获取暴动安抚列表
function ConfigManager.GetProtestAppeaseConfigsByGroupId(groupId)
    local ret = List:New()
    for id, item in pairs(this.allConfig["ProtestAppeaseNewConf"]) do
        if item.group == groupId then
            ret:Add(item)
        end
    end
    return ret
end

--根据id获取暴动安抚事件
function ConfigManager.GetProtestAppeaseConfigById(id)
    return this.allConfig["ProtestAppeaseNewConf"][id]
end

--获取slot配置数组
function ConfigManager.GetSlotGroup(cityId)
    local ret = List:New()
    for id, item in pairs(this.allConfig["EventSlotConf"]) do
        if item.city_id == cityId then
            ret:Add(item)
        end
    end
    return ret
end

--获取slot配置数组
function ConfigManager.GetSlotConfig(id)
    return this.allConfig["EventSlotConf"][id]
end

--获取slot物品列表
function ConfigManager.GetSlotSymbolList(cityId)
    local temp = {}
    for id, item in pairs(this.allConfig["EventSlotConf"]) do
        if item.city_id == cityId and item.symbol ~= "Empty" then
            temp[item.symbol] = item.icon
        end
    end
    local ret = {}
    local ret2 = {}
    for item, icon in pairs(temp) do
        table.insert(ret, item)
        table.insert(ret2, icon)
    end
    return ret, ret2
end

--获取slot物品列表
function ConfigManager.GetSlotRewardList(cityId)
    local ret = List:New()
    for id, item in pairs(this.allConfig["EventSlotConf"]) do
        if item.city_id == cityId and item.symbol ~= "Empty" then
            ret:Add(item)
        end
    end
    ret:Sort(
        function(p1, p2)
            return p1.id < p2.id
        end
    )
    return ret
end

--获取slot物品列表
function ConfigManager.GetSlotMainPanelRewardList(cityId)
    local ret = List:New()
    for id, item in pairs(this.allConfig["EventSlotConf"]) do
        if item.city_id == cityId and item.show_reward == true then
            ret:Add(item)
        end
    end
    ret:Sort(
        function(p1, p2)
            return p1.id < p2.id
        end
    )
    return ret
end

function ConfigManager.GetProfileIcons()
    return this.allConfig["PlayerIconConf"]
end

function ConfigManager.GetSortProfileIcons()
    local ret = List:New()
    for id, icon in pairs(this.allConfig["PlayerIconConf"]) do
        ret:Add(icon)
    end
    ret:Sort(
        function(a, b)
            return tonumber(a.id) < tonumber(b.id)
        end
    )
    return ret
end

function ConfigManager.GetEventTrickList(eventCityId)
    local ret = List:New()
    for id, item in pairs(this.allConfig["EventTrickConf"]) do
        if item.city_id == eventCityId then
            ret:Add(item)
        end
    end
    ret:Sort(
        function(p1, p2)
            return p1.sort < p2.sort
        end
    )
    return ret
end

function ConfigManager.GetEventRankRewards(group, rank)
    local ret = nil
    local eventRankConf = this.allConfig["EventRankConf"]
    for i = 1, #eventRankConf do
        if eventRankConf[i].group == group then
            if eventRankConf[i].rank_start <= rank and eventRankConf[i].rank_end >= rank then
                ret = Utils.ParseReward(eventRankConf[i].rewards)
                break
            end
        end
    end

    return ret
end

function ConfigManager.GetShopSceneDisplay(shopId)
    return this.allConfig["ShopSceneDisplayConf"][shopId]
end

---@return ShopSceneDisplay
function ConfigManager.GetShopSceneDisplayByZoneId(zoneId)
    for k, v in pairs(this.allConfig["ShopSceneDisplayConf"]) do
        if v.type == "zone" and v.display.zoneId == zoneId then
            return v
        end
    end

    return nil
end

function ConfigManager.GetRobotBattleConfig()
    return this.allConfig["BattleRobotConf"]
end

function ConfigManager.GetAllStarRank()
    return this.allConfig["CardStarRankConf"]
end

function ConfigManager.GetStoryBook()
    return this.allConfig["StoryBookConf"] or {}
end

function ConfigManager.GetBoxChanceGuarantee()
    return this.allConfig["BoxChanceGuaranteeConf"] or {}
end

---@return table<string, Push>
function ConfigManager.GetPush()
    return this.allConfig["PushConf"]
end

function ConfigManager.GetFurnituresMilestoneConfig(zoneId)
    if this.furnituresMilestone == nil or this.furnituresMilestone[zoneId] == nil then 
        ConfigManager.LoadAndHandleFurnituresMilestoneConfig()
    end

    local ret = this.furnituresMilestone[zoneId]
    return ret
end

function ConfigManager.LoadAndHandleFurnituresMilestoneConfig()
    local cityCount = ConfigManager.GetCityCount()
    for i = 1, cityCount, 1 do
        local path = "Game/Config/FurnituresMilestoneConf_" .. i
        package.loaded[path] = nil
    end

    this.furnituresMilestoneConfig = require("Game/Config/FurnituresMilestoneConf_" .. DataManager.GetCityId())

    this.furnituresMilestone = {}
    for id, value in pairs(this.furnituresMilestoneConfig) do
        this.furnituresMilestone[value.zone_id] = this.furnituresMilestone[value.zone_id] or {}
        this.furnituresMilestone[value.zone_id][value.type] = value
    end
end

---@return table<string, UserType>
function ConfigManager.GetAllUserTypeConfig()
    return this.allConfig["UserTypeConf"]
end

---@return UserType
function ConfigManager.GetUserTypeConfig(userType)
    return this.allConfig["UserTypeConf"][userType]
end
