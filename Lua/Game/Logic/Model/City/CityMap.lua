---@class CityMap
CityMap = Clone(CityBase)
CityMap.__cname = "CityMap"

--初始化
function CityMap:OnInit()
--    self.heroRoot = GameObject("HeroRoot_" .. self.cityId).transform
--    UnityEngine.Object.DontDestroyOnLoad(self.heroRoot)
--    self.vanRoot = GameObject("VanRoot_" .. self.cityId).transform
--    UnityEngine.Object.DontDestroyOnLoad(self.vanRoot)
--    local mapTr = GameObject.Find("Map").transform
--    self._rootMap = mapTr
--    self._rootChars = mapTr:Find("Chars")

    self.zones = DataManager.GetCityDataByKey(self.cityId, DataKey.Zones)
    self.bedConfig = ConfigManager.GetFurnitureById("C" .. self.cityId .. "_" .. ZoneType.Dorm .. "_" .. GridMarker.Bed)
    self.unlockMinMat = {}
    self.unlockMaxMat = {}
    -- self:InitTotalExp()
    self:InitMapItemData()
    self:CacheUnlockZoneList()
    -- self.expRx = NumberRx:New(0)
    -- self:UpdateExp()
    self.mapAllBoost = {}
    self:UpdateBoost()
    --self.heroControllers = Dictionary:New()
   -- self.vanControllers = Dictionary:New()
    self.CheckUnlockCostHander = function(cityId, itemId)
        self:CheckUnlockCost(itemId)
    end

    -- self:_initPlayer() --创建角色

    EventManager.AddListener(EventType.COLLECT_ITEM, self.CheckUnlockCostHander)
    EventManager.AddListener(EventType.USE_ITEM, self.CheckUnlockCostHander)
end
function CityMap:_initPlayer()
    local player = CityPlayer.new()
    ResInterface.SyncLoadGameObject('HomeChar', function (obj)
        local playerGo = GOInstantiate(obj, self._rootChars)

        player:bind(playerGo)

        player:playAnim(CityPlayerAnim.Idle, CityPosition.Dir.Down) --朝下
    end)

    self.player = player
end
function CityMap:OnInitView()
    -- for zoneId, mapItemData in pairs(self.mapItemDataList) do
    --     if self.heroControllers:ContainsKey(zoneId) then
    --         self.heroControllers[zoneId]:BindView()
    --     else
    --         local ret, entity = self:CreateHeroController(zoneId, mapItemData)
    --         if ret then
    --             entity:Active()
    --         end
    --     end
    -- end
    -- self.vanCount = EventSceneManager.GetVanCount()
    -- --协程事件
    -- local function CoroutineFunc()
    --     for i = 1, self.vanCount, 1 do
    --         if self.vanControllers:ContainsKey(i) then
    --             self.vanControllers[i]:BindView()
    --         else
    --             local ret, entity = self:CreateVanController(i)
    --             if ret then
    --                 entity:Active()
    --             end
    --             UnityEngine.YieldReturn(WaitForSeconds(2))
    --         end
    --     end
    --     self.createCoroutine = nil
    -- end
    -- --开启协程
    -- self.createCoroutine = UnityEngine.StartCoroutine(CoroutineFunc)
end

---实例化显示
function CityMap:OnClearView()
    -- self.heroControllers:ForEach(
    --     function(item)
    --         item:UnBindView()
    --     end
    -- )
    -- self.vanControllers:ForEach(
    --     function(item)
    --         item:UnBindView()
    --     end
    -- )
end

--清理
function CityMap:OnClear()
    -- self.heroControllers:ForEach(
    --     function(item)
    --         item:DeActive()
    --     end
    -- )
    -- self.heroControllers:Clear()

    -- self.vanControllers:ForEach(
    --     function(item)
    --         item:DeActive()
    --     end
    -- )
    -- self.vanControllers:Clear()

    if self.createCoroutine then
        UnityEngine.StopCoroutine(self.createCoroutine)
        self.createCoroutine = nil
    end

--    GameObject.Destroy(self.heroRoot.gameObject)
--    GameObject.Destroy(self.vanRoot.gameObject)

    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        mapItemData:Clear()
    end
    --不要搞这个危险的操作
    -- self.zones = nil
    EventManager.RemoveListener(EventType.COLLECT_ITEM, self.CheckUnlockCostHander)
    EventManager.RemoveListener(EventType.USE_ITEM, self.CheckUnlockCostHander)
    -- self.totalExp = nil
    -- self.expRx = nil
    self.mapItemDataList = nil
    self = nil
end

--刷新
function CityMap:OnUpdate()
    -- local count = self.heroControllers:Count()
    -- for i = 1, count do
    --     self.heroControllers[self.heroControllers.keyList[i]]:Update()
    -- end
    -- count = self.vanControllers:Count()
    -- for i = 1, count do
    --     self.vanControllers[self.vanControllers.keyList[i]]:Update()
    -- end
end

--------------------------------------------------
---事件响应
--------------------------------------------------
-- 音频位置变更事件
function CityMap:AudioPositionChangeFunc(position)
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        mapItemData:AudioPositionChangeFunc(position)
    end
end

-- 音效切换事件
function CityMap:AudioEffectSwitchFunc()
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        mapItemData:AudioEffectSwitchFunc()
    end
end

--卡牌变更
function CityMap:ZoneCardChangeFunc(zoneId)
    -- if self.heroControllers:ContainsKey(zoneId) then
    --     self:RemoveHeroController(zoneId)
    -- end
    local mapItemData = self.mapItemDataList[zoneId]
    if nil == mapItemData then
        return
    end
    -- local ret, entity = self:CreateHeroController(zoneId, mapItemData)
    -- if ret then
    --     entity:Active()
    --     local saveKey = string.format("%s_%s_%s", EnumActionType.ShowHeroIcon, self.cityId, zoneId)
    --     StoryBookManager.TryExecuteItemByRuntimeData(saveKey)
    -- end
end

--升级家具
function CityMap:UpgradeFurnitureFunc(zoneId, zoneType, furnitureType, index, level)
    if zoneType == ZoneType.Warehouse and furnitureType == GridMarker.Boost1ForWarehouse then
        -- self.vanCount = EventSceneManager.GetVanCount()
        -- for i = 1, self.vanCount, 1 do
        --     if not self.vanControllers:ContainsKey(i) then
        --         local ret, entity = self:CreateVanController(i)
        --         if ret then
        --             entity:Active()
        --         end
        --     end
        -- end
    end
end

--刷新TrickBoost事件
function CityMap:RefreshTrickBoostFunc()
    self.vanControllers:ForEach(
        function(item)
            item:SetSpeed()
        end
    )
    self:UpdateUnlockZone()
end

--夜晚刷新事件
function CityMap:RefreshNightChangeFunc()
    -- self.vanControllers:ForEach(
    --     function(item)
    --         item:SetVanLight()
    --     end
    -- )
end

--遍历vanControllers
---@param func function<VanController>
function CityMap:RefreshVanControllersFunc(func)
    -- self.vanControllers:ForEach(
    --     function(item)
    --         func(item)
    --     end
    -- )
end

--更新区域格子数据
function CityMap:UpgradeZoneGridDataFunc(zoneId, zoneType, level)
    -- self.heroControllers:ForEach(
    --     function(item)
    --         FunctionHandles.UpdateGrid(item, zoneId)
    --     end
    -- )
end

--------------------------------------------------
--------------------------------------------------
--初始化英雄
function CityMap:CreateHeroController(zoneId, mapItemData)
    -- local cardId = mapItemData:GetCardId()
    -- if cardId == 0 then
    --     return false
    -- end
    -- local entity = ObjectPoolManager.GetController("HeroController", self.heroRoot)
    -- if entity:OnInit(self.cityId, cardId, mapItemData:GetZoneType()) then
    --     if self.isShowView then
    --         entity:BindView()
    --     end
    --     self.heroControllers:Add(zoneId, entity)
    --     return true, entity
    -- else
    --     GameObject.Destroy(entity.gameObject)
    --     return false
    -- end
end

--初始化卡车
function CityMap:CreateVanController(id)
    -- local entity = ObjectPoolManager.GetController("VanController", self.vanRoot)
    -- if entity:OnInit(self.cityId, id) then
    --     if self.isShowView then
    --         entity:BindView()
    --     end
    --     self.vanControllers:Add(id, entity)
    --     return true, entity
    -- else
    --     GameObject.Destroy(entity.gameObject)
    --     return false
    -- end
end

--查找卡车
---@return VanController
function CityMap:SearchVanController(id)
    return nil
   -- return self.vanControllers[id]
end

--查找英雄
---@return HeroController
function CityMap:SearchHeroController(zoneId)
    return nil
    --return self.heroControllers[zoneId]
end

--移除英雄
function CityMap:RemoveHeroController(zoneId)
    -- local entity = self.heroControllers[zoneId]
    -- entity:DeActive()
    -- self.heroControllers:Remove(zoneId)
    -- GameObject.Destroy(entity.gameObject)
end

--获取全部英雄
function CityMap:GetAllHeroByList()
    return nil
    -- local ret = List:New()
    -- self.heroControllers:ForEach(
    --     function(item)
    --         ret:Add(item)
    --     end
    -- )
    -- return ret
end

-- --获取当前地图经验刷新对象
-- function CityMap:GetExpRx()
--     return self.expRx
-- end

-- --获取当前地图总经验
-- function CityMap:GetTotalExp()
--     return self.totalExp
-- end

-- --初始化当前地图总经验
-- function CityMap:InitTotalExp()
--     local ret = 0
--     local zonesConfigList = ConfigManager.GetZonesByCityId(self.cityId)
--     zonesConfigList:ForEachKeyValue(
--         function(zoneId, zone)
--             for i = 1, zone.max_level, 1 do
--                 ret = ret + zone.upgrade_generated_exp[i]
--             end
--             local list = ConfigManager.GetFurnituresList(self.cityId, zone.zone_type)
--             for ix, furniture in pairs(list) do
--                 local count_in_room = furniture.count_in_room[zone.max_level]
--                 if count_in_room ~= nil and count_in_room > 0 then
--                     local fexp = 0
--                     local max_level = furniture.max_level[zone.max_level]
--                     for j = 1, max_level, 1 do
--                         fexp = fexp + furniture.building_exp[j]
--                     end
--                     ret = ret + fexp * count_in_room
--                 end
--             end
--         end
--     )
--     self.totalExp = ret
-- end

--初始化MapItemData
function CityMap:InitMapItemData()
    self.mapItemDataList = {}
    local zonesConfigList = ConfigManager.GetZonesByCityId(self.cityId)
    zonesConfigList:ForEachKeyValue(
        function(zoneId, zone)
            local mapItemData = MapItemData:New()
            mapItemData:InitData(self.cityId, zoneId, self.zones[zoneId])
            self.mapItemDataList[zoneId] = mapItemData
        end
    )
end

--初始化默认卡牌
function CityMap:SetDefaultCardData()
    if self.mapItemDataList == nil then
        return
    end
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        ---@type MapItemData mapItemData
        mapItemData:SetDefaultCardData()
    end
end

--判断有效区域
---@return boolean
function CityMap:IsValidZoneId(zoneId)
    if self.mapItemDataList[zoneId] == nil then
        return false
    end

    return true
end

--获取MapItemData
function CityMap:GetMapItemData(zoneId)
    if self.mapItemDataList[zoneId] == nil then
        print("当前地图没有名为 " .. zoneId .. " 的建筑", debug.traceback())
        return nil
    end
    return self.mapItemDataList[zoneId]
end

--判断区域是否解锁
function CityMap:IsZoneUnlock(zoneId)
    if self.mapItemDataList[zoneId] == nil then
        print("当前地图没有名为 " .. zoneId .. " 的建筑", debug.traceback())
        return false
    end
    return self.mapItemDataList[zoneId]:IsUnlock()
end

--根据zone_type返回mapItemData
---@param zoneType ZoneType
---@return MapItemData
function CityMap:GetMapItemDataByZoneType(zoneType)
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        if mapItemData.config.zone_type == zoneType then
            return mapItemData
        end
    end
    return nil
end

--获取区域的等级
function CityMap:GetZoneLevel(zoneId)
    if self.mapItemDataList[zoneId] == nil then
        print("[error]" .. "当前地图没有名为 " .. zoneId .. " 的建筑")
        return 0
    end
    return self.mapItemDataList[zoneId]:GetLevel()
end

--获取区域里家居的等级
function CityMap:GetFurnitureLevel(zoneId, furnitureId, index)
    local ret = 0
    local mapItemData = self:GetMapItemData(zoneId)
    if mapItemData then
        ret = mapItemData:GetFurnitureLevel(furnitureId, index)
    end
    return ret
end


--获取需要加班的建筑
function CityMap:GetOvertimeBuild()
    local OvertimeBuild = {}
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        if mapItemData:IsUnlock() and WorkOverTimeManager.IsShowButtonInBuild(self.cityId, mapItemData.zoneId) then
            table.insert(OvertimeBuild,mapItemData)
        end
    end
    return OvertimeBuild
end


--获取当前达到建筑等级的数量
function CityMap:GetZoneCount(zoneType, level)
    local ret = 0
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        if mapItemData.config.zone_type == zoneType and mapItemData:IsUnlock() and mapItemData:GetLevel() >= level then
            ret = ret + 1
        end
    end
    return ret
end

--获取区域是否可以解锁
function CityMap:UpdateUnlockZone()
    self.unlockMinMat = {}
    self.unlockMaxMat = {}
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        mapItemData:UpdateCanUnlock()
    end
end

--获取区域里当前已经解锁的家具数量
function CityMap:GetUnlockFurnitureCount(zoneType, furnitureId, level)
    local count = 0
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        if mapItemData.config.zone_type == zoneType then
            count = count + mapItemData:GetUnlockFurnitureCountById(furnitureId, level)
        end
    end
    return count
end

--获取当前解锁房间最多所乘的人数
function CityMap:GetDormPeopleAllNums()
    return self:GetUnlockFurnitureCount(ZoneType.Dorm, self.bedConfig.id) * self.bedConfig.capacity
end

--获取当前地图支持的的工种最大人数
function CityMap:GetPeopleMaxAmount(peopleId)
    local ret = 0
    local people = ConfigManager.GetPeopleConfig(peopleId)
    local furniture = ConfigManager.GetFurnitureById(people.furniture_id)
    ret = self:GetUnlockFurnitureCount(people.zone_type, people.furniture_id)
    ret = ret * furniture.capacity
    return ret
end

--获取家具解锁索引
function CityMap:GetUnlockFurnitureIndexs(zoneType, furnitureId)
    local ret = List:New()
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        if mapItemData.config.zone_type == zoneType then
            ret:AddRange(mapItemData:GetUnlockFurnitureIndexs(furnitureId))
        end
    end
    return ret
end

--刷新解锁区域
function CityMap:CacheUnlockZoneList()
    self.unlockZoneList = {}
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        local list = mapItemData:GetUnlockZoneList()
        for index, unlockZoneId in pairs(list) do
            self.unlockZoneList[unlockZoneId] = true
        end
    end
end

function CityMap:GetUpgradeCanUnlockList(inputZoneId, level)
    local ret = {}
    local zones = ConfigManager.GetZonesByCityId(self.cityId)
    for zoneId, cfg in pairs(zones) do
        local unlockLevelConfig = cfg
        if unlockLevelConfig["unlock_zone_level"] then
            for i = 1, #unlockLevelConfig["unlock_zone_level"], 1 do
                local unlock = unlockLevelConfig["unlock_zone_level"][i]
                for zid, lv in pairs(unlock) do
                    if zid == inputZoneId and lv == level then
                        ret[zoneId] = i
                    end
                end
            end
        end
    end
    return ret
end

--判断当前区域是否能解锁
function CityMap:GetCanLock(zoneId)
    local ret = false
    if self.unlockZoneList[zoneId] == true then
        ret = true
    end
    return ret
end

-- --获取当前地图经验
-- function CityMap:GetCurrentExp()
--     local ret = 0
--     for zoneId, mapItemData in pairs(self.mapItemDataList) do
--         ret = ret + mapItemData:GetAllExp()
--     end
--     return ret
-- end

-- --获取当前地图经验
-- function CityMap:UpdateExp()
--     self.expRx.value = self:GetCurrentExp()
-- end

--获取当前地图移动加成
function CityMap:GetBoostValueByType(type)
    return self.mapAllBoost[type] or 0
end

--更新地图安全值
function CityMap:UpdateBoost()
    local ret = {}
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        for key, value in pairs(mapItemData:GetAllBoost()) do
            if not ret[key] then
                ret[key] = 0
            end
            ret[key] = ret[key] + value
        end
    end
    self.mapAllBoost = ret
end

--刷新所有建筑的生产数据(Boost用)
function CityMap:UpdateAllProductData()
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        mapItemData:UpdateAllProductData()
    end
end

--是否可以生产
function CityMap:IsCanProduct(zoneId, furnitureId, index)
    local mapItemData = self:GetMapItemData(zoneId)
    if nil == mapItemData then
        return false
    end
    return mapItemData:IsCanProduct(furnitureId, index)
end

--获取生产信息
function CityMap:GetProductData(zoneId, furnitureId, index)
    local mapItemData = self:GetMapItemData(zoneId)
    if nil == mapItemData then
        return nil
    end
    return mapItemData:GetProductData(furnitureId, index)
end

--获取爱心产出数量
function CityMap:GetHeartProductCount(furnitureId)
    if self.cityConfig.furniture_add_heart == 0 then
        return 0, 0
    end
    if nil == furnitureId then
        return 0, 0
    end
    local furnitureConfig = ConfigManager.GetFurnitureById(furnitureId)
    if nil == furnitureConfig then
        return 0, 0
    end
    if furnitureConfig.heart_fix == 0 then
        return 0, 0
    end
    local baseRet = self.cityConfig.furniture_add_heart * furnitureConfig.heart_fix
    local realRet = 0
    if CityManager.GetIsEventScene(self.cityId) then
        local heartBuff = BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.HeartBuff)
        local cashExpDouble = BoostManager.GetCommonBoosterFactor(self.cityId, CommonBoostType.EventCashExpDouble)
        realRet = baseRet * heartBuff * cashExpDouble
    end
    return baseRet, realRet
end

--设置全局开盖
function CityMap:SetRoof()
    self.isOpen = not self.isOpen
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        if self.isOpen then
            mapItemData.view:OpenRoof()
        else
            mapItemData.view:CloseRoof()
        end
    end
end

--获取生产Item
function CityMap:GetProductionItems()
    local items = {}
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        local ret, output = mapItemData:IsProdutcionsItem()
        if ret then
            items[zoneId] = output
        end
    end
    return items
end

--获取同Slide组的Id list
function CityMap:GetSlideGroup(zoneId)
    local zoneCfg = ConfigManager.GetZoneConfigById(zoneId)
    local retList = List:New()
    for z, mapItemData in pairs(self.mapItemDataList) do
        if mapItemData:IsUnlock() and mapItemData.config.slide_group == zoneCfg.slide_group then
            retList:Add(mapItemData.zoneId)
        end
    end
    retList:Sort(
        function(p1, p2)
            return ConfigManager.GetZoneConfigById(p1).slide_sort < ConfigManager.GetZoneConfigById(p2).slide_sort
        end
    )
    return retList
end

--获取同Slide组的数量
function CityMap:GetSlideGroupCount(zoneId)
    local ret = self:GetSlideGroup(zoneId):Count()
    return ret
end

--获取上一个zoneId
function CityMap:GetSlidePrevZoneId(zoneId)
    local list = self:GetSlideGroup(zoneId)
    local ix = list:IndexOf(zoneId)
    ix = ix - 1
    if ix <= 0 then
        ix = list:Count()
    end
    return list[ix]
end

--获取下一个zoneId
function CityMap:GetSlideNextZoneId(zoneId)
    local list = self:GetSlideGroup(zoneId)
    local ix = list:IndexOf(zoneId)
    ix = ix + 1
    if ix > list:Count() then
        ix = 1
    end
    return list[ix]
end

--获取是否有上卡
function CityMap:IsHasCardId(cardId)
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        if mapItemData:GetCardId() == cardId then
            return true
        end
    end
    return false
end

--获取上某张卡的ZoneId
function CityMap:GetZoneIdByCardId(cardId)
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        if mapItemData:GetCardId() == cardId then
            return zoneId
        end
    end
    return nil
end

--获取所有上卡的建筑与ZoneId 列表
---@return table<number, List<number>>
function CityMap:GetZoneCardList()
    local ret = {}
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        if mapItemData:CanSetMultipleCardIds() then
            ---@type List<number>
            local cardIds = mapItemData:GetCardIds()
            ret[zoneId] = cardIds
        else
            local cardId = mapItemData:GetCardId()
            if cardId ~= 0 then
                ---@type List<number>
                local cardIds = List:New()
                cardIds:Add(cardId)
                ret[zoneId] = cardIds
            end
        end
    end
    return ret
end

--设置解锁建筑所需材料
function CityMap:SetUnlockNeedMat(type, itemId, count)
    if type == "Min" then
        if self.unlockMinMat[itemId] == nil or self.unlockMinMat[itemId] > count then
            self.unlockMinMat[itemId] = count
        end
    else
        if self.unlockMaxMat[itemId] == nil or self.unlockMaxMat[itemId] < count then
            self.unlockMaxMat[itemId] = count
        end
    end
end

--获取区域stage值
function CityMap:GetZoneMaxStage()
    local ret = 0
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        local stage = mapItemData:GetMaxStage()
        if stage > ret then
            ret = stage
        end
    end
    return ret
end

--检查解锁建筑所需材料
function CityMap:CheckUnlockCost(collectItemId)
    if self.unlockMinMat ~= nil then
        for itemId, count in pairs(self.unlockMinMat) do
            if itemId == collectItemId and DataManager.GetMaterialCount(self.cityId, itemId) >= count then
                self:UpdateUnlockZone()
                break
            end
        end
    end
    if self.unlockMaxMat ~= nil then
        for itemId, count in pairs(self.unlockMaxMat) do
            if itemId == collectItemId and DataManager.GetMaterialCount(self.cityId, itemId) < count then
                self:UpdateUnlockZone()
                break
            end
        end
    end
end

--设置打开面板获得焦点建筑zoneId
function CityMap:SetFocusZone(zoneId)
    self.focusZoneId = zoneId
end

--获取获得焦点建筑
function CityMap:GetFocusZone()
    return self.focusZoneId
end

--设置zone数据
function CityMap:SetZoneData(zoneId, val)
    self.zones[zoneId] = val
    self:SaveData()
end

--保存zone数据
function CityMap:SaveData()
    --防止存一个坏的数据
    if Utils.GetTableLength(self.zones) == 0 then
        return
    end
    DataManager.SetCityDataByKey(self.cityId, DataKey.Zones, self.zones)
end

function CityMap:GetUserBuildCount()
    local count = 0
    for zoneId, mapItemData in pairs(self.mapItemDataList) do
        local config = ConfigManager.GetZoneConfigById(zoneId)
        if config.finished == false and mapItemData.zoneData ~= nil and mapItemData.zoneData.level ~= nil and mapItemData.zoneData.level >= 1 then
            count = count + 1
        end
    end
    return count
end
