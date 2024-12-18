MapManager = {}
MapManager.__cname = "MapManager"

local this = MapManager

--初始化地图管理器
function MapManager.Init()
    this.cityId = DataManager.GetCityId()
    if not this.mapItems then
        this.mapItems = Dictionary:New()
    end
    if not this.mapItems:ContainsKey(this.cityId) then
        this.mapItems:Add(this.cityId, CityMap:New(this.cityId))
        if this.mapItems:Count() == 1 then
            EventManager.AddListener(EventType.AUDIO_POSITION_CHANGE, this.AudioPositionChangeFunc)
            EventManager.AddListener(EventType.AUDIO_EFFECT_SWITCH, this.AudioEffectSwitchFunc)
            EventManager.AddListener(EventType.ZONE_CARD_CHANGE, this.ZoneCardChangeFunc)
            EventManager.AddListener(EventType.UPGRADE_FURNITURE, this.UpgradeFurnitureFunc)
            EventManager.AddListener(EventType.REFRESH_TRICK_BOOST, this.RefreshTrickBoostFunc)
            EventManager.AddListener(EventType.CITY_NIGHT_CHANGE, this.RefreshNightChangeFunc)
            EventManager.AddListener(EventType.ADD_CARD, this.RefreshDefaultCardFunc)
            EventManager.AddListener(EventType.UPGRADE_ZONE, this.RefreshDefaultCardFunc)
            EventManager.AddListener(EventType.UPDATE_ZONE_GRID_DATA, this.UpgradeZoneGridDataFunc)
        end
    end
    this.buildQueue = {}
end

function MapManager.InitView()
    this.GetMap(this.cityId):InitView()
end

function MapManager.ClearView()
    this.GetMap(this.cityId):ClearView()
end

function MapManager.AfterAllInit()
    this.GetMap(this.cityId):SetDefaultCardData()
end

--清除数据
function MapManager.Clear(force)
    this.buildQueue = {}
    Utils.SwitchSceneClear(this.cityId, this.mapItems, force)
    if this.mapItems:Count() == 0 then
        EventManager.RemoveListener(EventType.AUDIO_POSITION_CHANGE, this.AudioPositionChangeFunc)
        EventManager.RemoveListener(EventType.AUDIO_EFFECT_SWITCH, this.AudioEffectSwitchFunc)
        EventManager.RemoveListener(EventType.ZONE_CARD_CHANGE, this.ZoneCardChangeFunc)
        EventManager.RemoveListener(EventType.UPGRADE_FURNITURE, this.UpgradeFurnitureFunc)
        EventManager.RemoveListener(EventType.REFRESH_TRICK_BOOST, this.RefreshTrickBoostFunc)
        EventManager.RemoveListener(EventType.CITY_NIGHT_CHANGE, this.RefreshNightChangeFunc)
        EventManager.RemoveListener(EventType.ADD_CARD, this.RefreshDefaultCardFunc)
        EventManager.RemoveListener(EventType.UPGRADE_ZONE, this.RefreshDefaultCardFunc)
        EventManager.RemoveListener(EventType.UPDATE_ZONE_GRID_DATA, this.UpgradeZoneGridDataFunc)
    end
end

--刷新
function MapManager.OnUpdate()
    local count = this.mapItems:Count()
    for i = 1, count do
        this.mapItems[this.mapItems.keyList[i]]:OnUpdate()
    end
end

---@return CityMap
function MapManager.GetMap(cityId)
    return this.mapItems[cityId]
end

---------------------------------
---事件响应
---------------------------------
---@param cityId any
---@param position any
-- 音频位置变更事件
function MapManager.AudioPositionChangeFunc(cityId, position)
    this.GetMap(cityId):AudioPositionChangeFunc(position)
end

-- 音效切换事件
function MapManager.AudioEffectSwitchFunc(cityId)
    this.GetMap(cityId):AudioEffectSwitchFunc()
end

function MapManager.ZoneCardChangeFunc(cityId, zoneId)
    this.GetMap(cityId):ZoneCardChangeFunc(zoneId)
end

function MapManager.UpgradeFurnitureFunc(cityId, zoneId, zoneType, furnitureType, index, level)
    this.GetMap(cityId):UpgradeFurnitureFunc(zoneId, zoneType, furnitureType, index, level)
end

--刷新TrickBoost事件
function MapManager.RefreshTrickBoostFunc(cityId)
    this.GetMap(cityId):RefreshTrickBoostFunc()
end

--夜晚刷新事件
function MapManager.RefreshNightChangeFunc(cityId)
    this.GetMap(cityId):RefreshNightChangeFunc()
end

--遍历vanControllers
---@param func function<VanController>
function MapManager.RefreshVanControllersFunc(cityId, func)
    this.GetMap(cityId):RefreshVanControllersFunc(func)
end

--上阵默认卡牌
function MapManager.RefreshDefaultCardFunc()
    this.GetMap(this.cityId):SetDefaultCardData()
end

--更新区域格子数据
function MapManager.UpgradeZoneGridDataFunc(cityId, zoneId, zoneType, level)
    this.GetMap(cityId):UpgradeZoneGridDataFunc(zoneId, zoneType, level)
end

--------------------------------------------------
--------------------------------------------------
--------------------------------------------------
function MapManager.GetAllHeroByList(cityId)
    return this.GetMap(cityId):GetAllHeroByList()
end

--获取卡车
function MapManager.SearchVanController(cityId, id)
    return this.GetMap(cityId):SearchVanController(id)
end

--获取英雄
function MapManager.SearchHeroController(cityId, zoneId)
    return this.GetMap(cityId):SearchHeroController(zoneId)
end

--获取MapItemData
---@return boolean
function MapManager.IsValidZoneId(cityId, zoneId)
    return this.GetMap(cityId):IsValidZoneId(zoneId)
end

---@return MapItemData
function MapManager.GetMapItemData(cityId, zoneId)
    return this.GetMap(cityId):GetMapItemData(zoneId)
end

--判断区域是否解锁
function MapManager.IsZoneUnlock(cityId, zoneId)
    return this.GetMap(cityId):IsZoneUnlock(zoneId)
end

--获取区域的等级
function MapManager.GetZoneLevel(cityId, zoneId)
    return this.GetMap(cityId):GetZoneLevel(zoneId)
end

--获取区域里家居的等级
function MapManager.GetFurnitureLevel(cityId, zoneId, furnitureId, index)
    return this.GetMap(cityId):GetFurnitureLevel(zoneId, furnitureId, index)
end

--获取当前需要加班的建筑
function MapManager.GetOvertimeBuild(cityId)
    return this.GetMap(cityId):GetOvertimeBuild()
end

--获取当前达到建筑等级的数量
function MapManager.GetZoneCount(cityId, zoneType, level)
    return this.GetMap(cityId):GetZoneCount(zoneType, level)
end

--获取区域是否可以解锁
function MapManager.UpdateUnlockZone(cityId)
    this.GetMap(cityId):UpdateUnlockZone()
end

function MapManager.GetUpgradeCanUnlockList(cityId, zoneType, level)
    return this.GetMap(cityId):GetUpgradeCanUnlockList(zoneType, level)
end

--获取区域里当前已经解锁的家具数量
function MapManager.GetUnlockFurnitureCount(cityId, zoneType, furnitureId, level)
    return this.GetMap(cityId):GetUnlockFurnitureCount(zoneType, furnitureId, level)
end

--获取当前解锁房间最多所乘的人数
function MapManager.GetDormPeopleAllNums(cityId)
    return this.GetMap(cityId):GetDormPeopleAllNums()
end

--获取当前地图支持的的工种最大人数
function MapManager.GetPeopleMaxAmount(cityId, peopleId)
    return this.GetMap(cityId):GetPeopleMaxAmount(peopleId)
end

--获取当前地图支持的的工种最大人数
function MapManager.GetUnlockFurnitureIndexs(cityId, zoneType, furnitureId)
    return this.GetMap(cityId):GetUnlockFurnitureIndexs(zoneType, furnitureId)
end

--刷新解锁区域
function MapManager.CacheUnlockZoneList(cityId)
    this.GetMap(cityId):CacheUnlockZoneList()
end

--判断当前区域是否能解锁
function MapManager.GetCanLock(cityId, zoneId)
    return this.GetMap(cityId):GetCanLock(zoneId)
end

-- --获取当前地图经验刷新对象
-- function MapManager.GetExpRx(cityId)
--     return this.GetMap(cityId):GetExpRx()
-- end

-- --获取当前地图总经验
-- function MapManager.GetTotalExp(cityId)
--     return this.GetMap(cityId):GetTotalExp()
-- end

-- --获取当前地图经验
-- function MapManager.GetCurrentExp(cityId)
--     return this.GetMap(cityId):GetCurrentExp()
-- end

-- --获取当前地图经验
-- function MapManager.UpdateExp(cityId)
--     this.GetMap(cityId):UpdateExp()
-- end

--获取当前地图安全值刷新对象
function MapManager.GetBoostValueByType(cityId, type)
    return this.GetMap(cityId):GetBoostValueByType(type)
end

--更新地图BoostReward
function MapManager.UpdateBoost(cityId)
    this.GetMap(cityId):UpdateBoost()
end

--刷新所有建筑的生产数据(Boost用)
function MapManager.UpdateAllProductData(cityId)
    this.GetMap(cityId):UpdateAllProductData()
end

--是否可以生产
function MapManager.IsCanProduct(cityId, zoneId, furnitureId, index)
    return this.GetMap(cityId):IsCanProduct(zoneId, furnitureId, index)
end

--获取爱心产出数量
function MapManager.GetHeartProductCount(cityId, furnitureId)
    return this.GetMap(cityId):GetHeartProductCount(furnitureId)
end

--设置全局开盖
function MapManager.SetRoof(cityId)
    return this.GetMap(cityId):SetRoof()
end

--获取生产Item
function MapManager.GetProductionItems(cityId)
    return this.GetMap(cityId):GetProductionItems()
end

--设置zone数据
function MapManager.SetZoneData(cityId, zoneId, val)
    return this.GetMap(cityId):SetZoneData(zoneId, val)
end

--判断建造队列是否已满
function MapManager.GetBuildQueueIsFull()
    return this.GetBuildQueueCount() >= this.GetMaxBuildQueue()
end

--获得当前建筑队列
function MapManager.GetBuildQueueCount()
    local num = 0
    for key, value in pairs(this.buildQueue) do
        if value > 0 then
            num = num + 1
        end
    end
    return num
end

--获得最大队列
function MapManager.GetMaxBuildQueue()
    local max =
        ConfigManager.GetMiscConfig("base_build_queue") +
        BoostManager.GetRxBoosterValue(this.cityId, RxBoostType.ConstructionQueue)
    return max
end

-- --添加建筑队列
function MapManager.AddBuildQueue(zoneId)
    this.buildQueue[zoneId] = 1
end

--移除建筑队列
function MapManager.RemoveBuildQueue(zoneId)
    if this.buildQueue[zoneId] ~= nil then
        this.buildQueue[zoneId] = 0
    end
end

--获取建造队列
function MapManager.GetBuildQueue()
    return this.buildQueue
end

--获取同Slide组的数量
function MapManager.GetSlideGroupCount(cityId, zoneId)
    return this.GetMap(cityId):GetSlideGroupCount(zoneId)
end

--获取上一个zoneId
function MapManager.GetSlidePrevZoneId(cityId, zoneId)
    return this.GetMap(cityId):GetSlidePrevZoneId(zoneId)
end

--获取下一个zoneId
function MapManager.GetSlideNextZoneId(cityId, zoneId)
    return this.GetMap(cityId):GetSlideNextZoneId(zoneId)
end

--获取下一个zoneId
function MapManager.IsHasCardId(cityId, cardId)
    return this.GetMap(cityId):IsHasCardId(cardId)
end

--获取上某张卡的ZoneId
function MapManager.GetZoneIdByCardId(cityId, cardId)
    return this.GetMap(cityId):GetZoneIdByCardId(cardId)
end

--设置解锁建筑所需材料
function MapManager.SetUnlockNeedMat(cityId, type, itemId, count)
    this.GetMap(cityId):SetUnlockNeedMat(type, itemId, count)
end

--获取所有上卡的建筑与ZoneId 列表
function MapManager.GetZoneCardList(cityId)
    return this.GetMap(cityId):GetZoneCardList()
end

--设置打开面板获得焦点建筑zoneId
function MapManager.SetFocusZone(cityId, zoneId)
    return this.GetMap(cityId):SetFocusZone(zoneId)
end

--获取获得焦点建筑
function MapManager.GetFocusZone(cityId)
    return this.GetMap(cityId):GetFocusZone()
end

--获取区域stage值
function MapManager.GetZoneMaxStage(cityId)
    return this.GetMap(cityId):GetZoneMaxStage()
end

--保存数据
function MapManager.SaveData(cityId)
    return this.GetMap(cityId):SaveData()
end
