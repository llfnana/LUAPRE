GeneratorManager = {}
GeneratorManager.__cname = "GeneratorManager"

local this = GeneratorManager
local UseFahrenheitCountries = {
    BS = true,
    AS = true,
    BZ = true,
    KY = true,
    PW = true,
    US = true,
    UM = true,
    PR = true,
    VI = true,
    GU = true,
    default = false
}

function GeneratorManager.Init()
    this.temperatureUnitSwitch = true
    if (DataManager.GetGlobalDataByKey(DataKey.UseFahrenheit) == nil) then
        local country =  "default"--SDKManager.GetCountry()
--        if (country == nil) then
--            country = "default"
--        end
        Log("Player Country " .. country)
        DataManager.SetGlobalDataByKey(DataKey.UseFahrenheit, UseFahrenheitCountries[country] == true)
    end
    if DataManager.GetGlobalDataByKey(DataKey.UseFahrenheit) == true then
        this.temperatureUnitSwitch = false
    end
    this.cityId = DataManager.GetCityId()
    if not this.generatorItems then
        this.generatorItems = Dictionary:New()
    end
    if not this.generatorItems:ContainsKey(this.cityId) then
        this.generatorItems:Add(this.cityId, CityGenerator:New(this.cityId))
        if this.generatorItems:Count() == 1 then
            EventManager.AddListener(EventType.TIME_REAL_PER_SECOND, this.TimeRealPerSecondFunc)
            EventManager.AddListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)
            EventManager.AddListener(EventType.TIME_CITY_PER_REFRESH, this.CityTimeRefresh)
        end
    end
end

function GeneratorManager.SwitchTemperatureUnit(b)
    this.temperatureUnitSwitch = b
    DataManager.SetGlobalDataByKey(DataKey.UseFahrenheit, not b)
end

function GeneratorManager.Clear(force)
    --DOTO
    Utils.SwitchSceneClear(this.cityId, this.generatorItems, force)
    if this.generatorItems:Count() == 0 then
        EventManager.RemoveListener(EventType.TIME_REAL_PER_SECOND, this.TimeRealPerSecondFunc)
        EventManager.RemoveListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)
        EventManager.RemoveListener(EventType.TIME_CITY_PER_REFRESH, this.CityTimeRefresh)
    end
end

---@return CityGenerator
function GeneratorManager.GetGenerator(cityId)
    return this.generatorItems[cityId]
end

--真实时间每秒刷新
function GeneratorManager.TimeRealPerSecondFunc(cityId)
    -- LogWarning("GeneratorManager.TimeRealPerSecondFunc")
    this.GetGenerator(cityId):UpdateTime()
end

--每半个小时刷新
function GeneratorManager.CityTimeRefresh(cityId)
    -- if BoostManager.GetRxBoosterValue(cityId, RxBoostType.AutoGeneratorOverload) == 1 then
    --     this.CheckGeneratorAutoload(cityId)
    -- end
end

--建造区域事件响应
function GeneratorManager.UpgradeZoneFunc(cityId, zoneId, zoneType, level)
    if ZoneType.Generator == zoneType then
        this.GetGenerator(cityId):UpgradeLevel()
    end
end

function GeneratorManager.UpdateMapItemData(cityId)
    this.GetGenerator(cityId):UpdateMapItemData()
end

function GeneratorManager.Open(cityId)
    this.GetGenerator(cityId):Open()
end

function GeneratorManager.Close(cityId)
    this.GetGenerator(cityId):Close()
end

function GeneratorManager.OpenOverload(cityId)
    this.GetGenerator(cityId):OpenOverload()
end

function GeneratorManager.CloseOverload(cityId)
    this.GetGenerator(cityId):CloseOverload()
end

function GeneratorManager.GetZoneId(cityId)
    return this.GetGenerator(cityId):GetZoneId()
end

function GeneratorManager.GetConsumptionItemId(cityId)
    return this.GetGenerator(cityId):GetConsumptionItemId()
end

function GeneratorManager.GetCount(cityId)
    return this.GetGenerator(cityId):GetCount()
end

--白天理论消耗
function GeneratorManager.GetDayConsumption(cityId)
    return this.GetGenerator(cityId):GetDayConsumption()
end

--夜晚理论消耗
function GeneratorManager.GetNightConsumption(cityId)
    return this.GetGenerator(cityId):GetNightConsumption()
end

--获取消耗数量
function GeneratorManager.GetConsumptionCount(cityId)
    return this.GetGenerator(cityId):GetConsumptionCount()
end

function GeneratorManager.GetNextConsumption(cityId)
    return this.GetGenerator(cityId):GetNextConsumption()
end

function GeneratorManager.GetConsumptionCountForMaterialCheck(cityId)
    return this.GetGenerator(cityId):GetConsumptionCountForMaterialCheck()
end

function GeneratorManager.GetIsEnable(cityId)
    return this.GetGenerator(cityId):GetIsEnable()
end

function GeneratorManager.GetIsOverload(cityId)
    return this.GetGenerator(cityId):GetIsOverload()
end

function GeneratorManager.GetCanLock(cityId, zoneId)
    return this.GetGenerator(cityId):GetCanLock(zoneId)
end

function GeneratorManager.GetStatus(cityId)
    return this.GetGenerator(cityId):GetStatus()
end

function GeneratorManager.ConsumptionLeftTime(cityId)
    return this.GetGenerator(cityId):ConsumptionLeftTime()
end

function GeneratorManager.GetSumConsumptionCount(cityId)
    return this.GetGenerator(cityId):GetSumConsumptionCount()
end

function GeneratorManager.SumConsumptionLeftTime(cityId)
    return this.GetGenerator(cityId):SumConsumptionLeftTime()
end

function GeneratorManager.GetTemperature(cityId)
    return this.GetGenerator(cityId):GetTemperature()
end

function GeneratorManager.CheckGeneratorAutoload(cityId)
    return this.GetGenerator(cityId):CheckGeneratorAutoload()
end

function GeneratorManager.RefreshConsumptionCount(cityId)
    return this.GetGenerator(cityId):RefreshConsumptionCount()
end

function GeneratorManager.IsToLack(cityId, itemId, sonsumeCount)
    return this.GetGenerator(cityId):IsToLack(itemId, sonsumeCount)
end

