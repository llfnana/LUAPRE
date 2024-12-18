-- 工厂游戏机
-- 1.解锁，TODO 地图上显示可建造的加号
-- 2.引导（对话，先跳过引导建造建筑，建造建筑需要地编支持）
-- 3.开放入口
-- 4.打开界面
-- 5.界面操作
-- 6.老号的数据修复
FactoryGameData = {

}
FactoryGameData.DataKey = "factoryGame"     --数据缓存的key

local isInit = false
function FactoryGameData.Init()
    if isInit == true then 
        return 
    end
    isInit = true
    
    -- 监听引导的触发条件
    EventManager.AddListener(EventType.UPGRADE_ZONE, FactoryGameData.OnUpgradeZone)

    -- 数据修复（老号）
    local cityId = DataManager.GetCityId()
    local data = DataManager.GetCityDataByKey(cityId, FactoryGameData.DataKey)
    if data == nil then 
        data = FactoryGameData.GetInitData()
        DataManager.SetCityDataByKey(cityId, FactoryGameData.DataKey, data)
    end
end

function FactoryGameData.OnUpgradeZone()
    if FactoryGameData.IsUnlock() == false then
        return
    end

    local cityId = DataManager.GetCityId()
    local data = DataManager.GetCityDataByKey(cityId, FactoryGameData.DataKey)
    
    local zoneLevel = FactoryGameData.IsGeneratorTwoLevel()
    if zoneLevel >= 2 and not FactoryGameData.IsBuildComplete() then 
        local path = "Map/layer_zone_map_" .. cityId .. "/FactoryGame/FactoryGamePanelEntity"
        local obj = GameObject.Find(path)
        if obj ~= nil then
            local isBuildComplete = FactoryGameData.IsBuildComplete()
            local floor = SafeGetUIControl(obj, "floor")
            local BuildCursor = SafeGetUIControl(obj, "BuildCursor")
            floor.gameObject:SetActive(isBuildComplete)
            BuildCursor.gameObject:SetActive(zoneLevel >= 2 and not isBuildComplete)
        end
    end
    if data.buildComplete == false then 
        -- TODO 地图上显示可建造的加号
        EventManager.Brocast(EventType.FACTORY_GAME_UNLOCK)
    end

    -- 已完成引导
    if TutorialManager.IsComplete(TutorialStep.FactoryGame) then 
        return
    end

    if data.buildComplete then
        -- 已完成建筑建造，但没有完成引导，可能是上次退出时没有保存，添加引导完成
        TutorialManager.CompleteTutorial(TutorialStep.FactoryGame)
        return
    end

    -- 不是城市4
    local requireCityId = FactoryGameData.GetRequireCityId()
    if cityId > requireCityId then 
        TutorialManager.CompleteTutorial(TutorialStep.FactoryGame)
        return
    end

    TutorialManager.TriggerTutorial(TutorialStep.FactoryGame)
end

function FactoryGameData.GetInitData() 
    return {
        buildComplete = false,
    }
end

-- 建造完成
function FactoryGameData.BuildComplete()
    local cityId = DataManager.GetCityId()
    local data = DataManager.GetCityDataByKey(cityId, FactoryGameData.DataKey)
    data.buildComplete = true
    DataManager.SetCityDataByKey(cityId, FactoryGameData.DataKey, data)
    --同时将引导的设置为完成，以免数据不同步
    FactoryGameData.CompleteTutorial()
    local requireCityId = FactoryGameData.GetRequireCityId()
    local mapItems = MapManager.GetMap(cityId)
    local isFirst = cityId == requireCityId and mapItems:GetUserBuildCount() == 1
    if isFirst then 
        EventManager.Brocast(EventType.FACTORY_GAME_BUILD_FIRST)
    end
    local path = "Map/layer_zone_map_" .. cityId .. "/FactoryGame/FactoryGamePanelEntity"
    local obj = GameObject.Find(path)

    ShowUI(UINames.UIUnlock, {
        type = FunctionsType.FactoryGame,
        isOpen = true,
        isEffect = true,
        cityId = cityId,
        flyOverBack = function ()
            EventManager.Brocast(EventType.FACTORY_GAME_UNLOCK)
        end ,
    })
end

function FactoryGameData.CompleteTutorial()
    local cityId = DataManager.GetCityId()
    local requireCityId = FactoryGameData.GetRequireCityId()
    if cityId == requireCityId then 
        TutorialManager.CompleteTutorial(TutorialStep.FactoryGame)
    end
end

-- 是否解锁
function FactoryGameData.IsUnlock()
    local cityId = DataManager.GetCityId()
    local requireCityId = FactoryGameData.GetRequireCityId()
    if cityId < requireCityId then 
        return false
    end

    -- 建完第一个建筑后解锁    
    local zoneLevel = FactoryGameData.IsGeneratorTwoLevel()
    if zoneLevel < 2 then 
        return false
    end
    return true
end

function FactoryGameData.GetRequireCityId()
    local config = ConfigManager.GetTutorialTypeConfigById(TutorialStep.FactoryGame)
    return config.cityId
end

function FactoryGameData.IsBuildComplete()
    local cityId = DataManager.GetCityId()
    local data = DataManager.GetCityDataByKey(cityId, FactoryGameData.DataKey)
    return data and data.buildComplete
end

function FactoryGameData.IsGeneratorTwoLevel()
    local cityId = DataManager.GetCityId()
    local name = "C".. cityId.. "_" .. "Generator" .. "_1"
    local mapItemData = MapManager.GetMapItemData(cityId, name)
    local zoneLevel = mapItemData:GetLevel()
    return zoneLevel
end