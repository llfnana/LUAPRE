StatisticalManager = {}
StatisticalManager._name = "StatisticalManager"

local this = StatisticalManager

function StatisticalManager.Init()
    this.cityId = DataManager.GetCityId()
    if not this.statisticalItems then
        this.statisticalItems = Dictionary:New()
    end
    if not this.statisticalItems:ContainsKey(this.cityId) then
        this.statisticalItems:Add(this.cityId, CityStatistical:New(this.cityId))
        if this.statisticalItems:Count() == 1 then
            EventManager.AddListener(EventType.TIME_CITY_PER_HOUR, this.TimeCityPerHourFunc)
            EventManager.AddListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)
        end
    end
end

function StatisticalManager.Clear(force)
    Utils.SwitchSceneClear(this.cityId, this.statisticalItems, force)
    if this.statisticalItems:Count() == 0 then
        EventManager.RemoveListener(EventType.TIME_CITY_PER_HOUR, this.TimeCityPerHourFunc)
        EventManager.RemoveListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)
    end
end

function StatisticalManager.GetStatisticalFactor(progress, type)
    local factor = nil
    if type == FoodSystemManager.GetFoodType(this.cityId) then
        factor = ConfigManager.GetMiscConfig("data_analysis_factor_food")
    else
        factor = ConfigManager.GetMiscConfig("data_analysis_factor")
    end
    if progress < factor[2] then
        return 1
    elseif progress < factor[3] then
        return 2
    elseif progress < factor[4] then
        return 3
    else
        return 4
    end
end

function StatisticalManager.GetStatisticalItem(cityId)
    return this.statisticalItems[cityId]
end

--每小时刷新
function StatisticalManager.TimeCityPerHourFunc(cityId)
    this.GetStatisticalItem(cityId):TimeCityPerHourFunc()
end

--建造区域回调
function StatisticalManager.UpgradeZoneFunc(cityId, zoneId, zoneType, level)
    this.GetStatisticalItem(cityId):UpgradeZoneFunc(zoneId, zoneType, level)
end

--添加生产产出
function StatisticalManager.AddOutputProductions(cityId, zoneId, output)
    this.GetStatisticalItem(cityId):AddOutputProductions(zoneId, output)
end

--添加生产消耗
function StatisticalManager.AddInputProductions(cityId, zoneId, itemId, itemCount)
    this.GetStatisticalItem(cityId):AddInputProductions(zoneId, itemId, itemCount)
end

--获取指定物品秒产
function StatisticalManager.GetOutputProductionsPerSecond(cityId, itemId)
    return this.GetStatisticalItem(cityId):GetOutputProductionsPerSecond(itemId)
end

--添加肉
function StatisticalManager.AddFoodCostProductions(cityId, count)
    this.GetStatisticalItem(cityId):AddFoodCostProductions(count)
end

--添加食物
function StatisticalManager.AddFoodProductions(cityId, count)
    this.GetStatisticalItem(cityId):AddFoodProductions(count)
end

--添加食物
function StatisticalManager.AddHeartProductions(cityId, count)
    this.GetStatisticalItem(cityId):AddHeartProductions(count)
end

function StatisticalManager.GetSurvivalCount(cityId, type)
    return this.GetStatisticalItem(cityId):GetSurvivalCount(type)
end

function StatisticalManager.GetSurvivalsItems(cityId)
    return this.GetStatisticalItem(cityId):GetSurvivalsItems()
end

--在线添加生产
function StatisticalManager.AddOnlineProdutcions(cityId, zoneId, info)
    this.GetStatisticalItem(cityId):AddOnlineProdutcions(zoneId, info)
end

--在线删除生产
function StatisticalManager.RemoveOnlineProdutcions(cityId, zoneId, info)
    this.GetStatisticalItem(cityId):RemoveOnlineProdutcions(zoneId, info)
end

--获取在线生产
function StatisticalManager.GetOnlineProductions(cityId)
    return this.GetStatisticalItem(cityId):GetOnlineProductions()
end

--获取在线生产
function StatisticalManager.GetOnlineProductionsByItemId(cityId, itemId)
    return this.GetStatisticalItem(cityId):GetOnlineProductionsByItemId(itemId)
end

--获取离线生产
function StatisticalManager.GetOfflineProductions(cityId)
    return this.GetStatisticalItem(cityId):GetOfflineProductions()
end

--移除在线消耗
function StatisticalManager.SetOnlineConsumptions(cityId, itemId, count)
    this.GetStatisticalItem(cityId):SetOnlineConsumptions(itemId, count)
end

--获取在线消耗
function StatisticalManager.GetOnlineConsumptions(cityId, itemId)
    return this.GetStatisticalItem(cityId):GetOnlineConsumptions(itemId)
end

function StatisticalManager.PrintStatistical(cityId)
    this.GetStatisticalItem(cityId):PrintStatistical()
end
