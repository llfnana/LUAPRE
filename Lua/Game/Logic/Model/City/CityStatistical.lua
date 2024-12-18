CityStatistical = Clone(CityBase)
CityStatistical.__cname = "CityStatistical"

--初始化
function CityStatistical:OnInit()
    self.statisticalData = DataManager.GetCityDataByKey(self.cityId, DataKey.StatisticalData)

    self.statisticalData = nil

    if self.statisticalData == nil then
        self.statisticalData = {}
        DataManager.SetCityDataByKey(self.cityId, DataKey.StatisticalData, self.statisticalData)
    end

    for hour, data in pairs(self.statisticalData) do
        for zoneId, zoneData in pairs(data.zones) do
            local zoneConfig = ConfigManager.GetZoneConfigById(zoneId)
            if zoneConfig.zone_type == ZoneType.Generator then
                zoneData.outputInfo = nil
            else
                zoneData.inputInfo = nil
            end
        end
    end

    self.onlineProductions = {}
    self.onlineConsumptions = {}
    for zoneId, output in pairs(MapManager.GetProductionItems(self.cityId)) do
        self:InitOnlineProdutcions(zoneId, output)
    end
end

--清理
function CityStatistical:OnClear()
end

function CityStatistical:PrintStatistical()
    local log = ""
    local function EachZoneData(zoneId, zoneData)
        if zoneData.outputInfo then
            for itemId, itemCount in pairs(zoneData.outputInfo) do
                local realItemCount = itemCount * BoostManager.GetMaterialBoostFactor(self.cityId, itemId)
                log = log .. string.format("  离线产出[%s:{ %s = %s}]", zoneId, itemId, realItemCount)
                local itemConfig = ConfigManager.GetItemConfig(itemId)
                for i = 1, #itemConfig.ingredients, 1 do
                    for iItemId, iCount in pairs(itemConfig.ingredients[i]) do
                        log = log .. string.format("  离线消耗[%s:{ %s = %s}]", zoneId, iItemId, iCount * realItemCount)
                    end
                end
            end
        end
        if zoneData.inputInfo then
            for itemId, itemCount in pairs(zoneData.inputInfo) do
                log = log .. string.format("  离线消耗[%s:{ %s = %s}]", zoneId, itemId, itemCount)
            end
        end
    end

    local heartBuff = BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.HeartBuff)
    local cashExpDouble = BoostManager.GetCommonBoosterFactor(self.cityId, CommonBoostType.EventCashExpDouble)
    for hour, data in pairs(self.statisticalData) do
        log =
            string.format(
            "hour = %s, foodCost = %s, food = %s, heart = %s",
            hour,
            data.foodCost,
            data.food,
            (data.heart or 0) * heartBuff * cashExpDouble
        )
        for zoneId, zoneData in pairs(data.zones) do
            EachZoneData(zoneId, zoneData)
        end
        print("[error]" .. log)
    end
end

function CityStatistical:UpgradeZoneFunc(zoneId, zoneType, level)
    if level ~= 1 then
        return
    end
    local mapItemData = MapManager.GetMapItemData(self.cityId, zoneId)
    local ret, output = mapItemData:IsProdutcionsItem()
    if ret then
        self:InitOnlineProdutcions(zoneId, output)
    end
end

function CityStatistical:TimeCityPerHourFunc()
    if self.statisticalInfo then
        self.statisticalData[self.statisticalHour] = self.statisticalInfo
        DataManager.SetCityDataByKey(self.cityId, DataKey.StatisticalData, self.statisticalData)
    end
    self.statisticalHour = tostring(TimeManager.GetCityClockHour(self.cityId))
    self.statisticalInfo = {}
    self.statisticalInfo.foodCost = 0
    self.statisticalInfo.food = 0
    self.statisticalInfo.heart = 0
    self.statisticalInfo.zones = {}
end

--添加生产产出
function CityStatistical:AddOutputProductions(zoneId, output)
    if not self.statisticalInfo then
        return
    end
    for itemId, itemCount in pairs(output) do
        local itemConfig = ConfigManager.GetItemConfig(itemId)
        if itemConfig.resource_type ~= 1 then
            if not self.statisticalInfo.zones[zoneId] then
                local zoneInfo = {}
                zoneInfo.outputInfo = {}
                self.statisticalInfo.zones[zoneId] = zoneInfo
            end
            local zoneInfo = self.statisticalInfo.zones[zoneId]
            if zoneInfo.outputInfo[itemId] then
                zoneInfo.outputInfo[itemId] = zoneInfo.outputInfo[itemId] + itemCount
            else
                zoneInfo.outputInfo[itemId] = itemCount
            end
        end
    end
end

--添加生产消耗
function CityStatistical:AddInputProductions(zoneId, itemId, itemCount)
    if not self.statisticalInfo then
        return
    end
    if not self.statisticalInfo.zones[zoneId] then
        local zoneInfo = {}
        zoneInfo.inputInfo = {}
        self.statisticalInfo.zones[zoneId] = zoneInfo
    end
    local zoneInfo = self.statisticalInfo.zones[zoneId]
    if zoneInfo.inputInfo[itemId] then
        zoneInfo.inputInfo[itemId] = zoneInfo.inputInfo[itemId] + itemCount
    else
        zoneInfo.inputInfo[itemId] = itemCount
    end
end

--添加食材产出
function CityStatistical:AddFoodCostProductions(count)
    if not self.statisticalInfo then
        return
    end
    self.statisticalInfo.foodCost = self.statisticalInfo.foodCost + count
end

--添加食物产出
function CityStatistical:AddFoodProductions(count)
    if not self.statisticalInfo then
        return
    end
    self.statisticalInfo.food = self.statisticalInfo.food + count
end

--添加爱心产出
function CityStatistical:AddHeartProductions(count)
    if not self.statisticalInfo then
        return
    end
    if nil == self.statisticalInfo.heart then
        self.statisticalInfo.heart = 0
    end
    self.statisticalInfo.heart = self.statisticalInfo.heart + count
end

--获取指定物品秒产
function CityStatistical:GetOutputProductionsPerSecond(id)
    local itemConfig = ConfigManager.GetItemConfig(id)
    local outputValue = 0
    if itemConfig.item_type == ItemType.Heart then
        --获取爱心物产出
        for hour, data in pairs(self.statisticalData) do
            outputValue = outputValue + (data.heart or 0)
        end
        outputValue = outputValue / 12 / 60
        if outputValue < itemConfig.shop_rewards_limit then
            outputValue = itemConfig.shop_rewards_limit
        end
        local heartBuff = BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.HeartBuff)
        local cashExpDouble = BoostManager.GetCommonBoosterFactor(self.cityId, CommonBoostType.EventCashExpDouble)
        outputValue = outputValue * heartBuff * cashExpDouble
    else
        for hour, data in pairs(self.statisticalData) do
            for zoneId, zoneData in pairs(data.zones) do
                if zoneData.outputInfo then
                    for itemId, itemCount in pairs(zoneData.outputInfo) do
                        if itemId == id then
                            outputValue = outputValue + itemCount
                        end
                    end
                end
            end
        end
        outputValue = outputValue / 12 / 60
        if outputValue < itemConfig.shop_rewards_limit then
            outputValue = itemConfig.shop_rewards_limit
        end
        outputValue = outputValue * BoostManager.GetMaterialBoostFactor(self.cityId, id)
    end
    return outputValue
end

--根据类型获取生存数量
function CityStatistical:GetSurvivalCount(itemId)
    local currentCount = 0
    local maxCount = 0
    if itemId == FoodSystemManager.GetFoodCostItem(self.cityId) then
        for hour, data in pairs(self.statisticalData) do
            currentCount = currentCount + data.foodCost * BoostManager.GetMaterialBoostFactor(self.cityId, itemId)
        end
        local itemConfig = ConfigManager.GetItemConfig(FoodSystemManager.GetFoodType(self.cityId))
        for i = 1, #itemConfig.ingredients, 1 do
            for id, count in pairs(itemConfig.ingredients[i]) do
                maxCount = CharacterManager.GetCharacterCount(self.cityId) * 2 * count
            end
        end
    elseif itemId == FoodSystemManager.GetFoodType(self.cityId) then
        for hour, data in pairs(self.statisticalData) do
            currentCount = currentCount + data.food
        end
        maxCount = CharacterManager.GetCharacterCount(self.cityId) * 2
    else
        local itemIdBoost = BoostManager.GetMaterialBoostFactor(self.cityId, itemId)
        for hour, data in pairs(self.statisticalData) do
            for zoneId, zoneData in pairs(data.zones) do
                if zoneData.outputInfo then
                    for iItemId, iItemCount in pairs(zoneData.outputInfo) do
                        if iItemId == itemId then
                            currentCount = currentCount + iItemCount * itemIdBoost
                        end
                    end
                end
            end
        end
        local dayHours = CityManager.GetDayHours(self.cityId)
        local dayConsumption = GeneratorManager.GetDayConsumption(self.cityId) * (dayHours / 24) * 12
        local nightConsumption = GeneratorManager.GetNightConsumption(self.cityId) * (24 - dayHours) / 24 * 12
        maxCount = dayConsumption + nightConsumption
    end
    return currentCount, maxCount
end

--获取生存列表
function CityStatistical:GetSurvivalsItems()
    local survivals = List:New()
    if CityManager.GetIsEventScene(self.cityId) then
        survivals:Add(FoodSystemManager.GetFoodType(self.cityId))
        -- survivals:Add(EventSceneManager.cashItem)
        -- survivals:Add(EventSceneManager.heartItem)
    else
        survivals:Add(FoodSystemManager.GetFoodCostItem(self.cityId))
        survivals:Add(FoodSystemManager.GetFoodType(self.cityId))
        survivals:Add(GeneratorManager.GetConsumptionItemId(self.cityId))
    end

    return survivals
end

--获取离线生产
function CityStatistical:GetOfflineProductions()
    local offlineItemIds = List:New()
    local offlineProductions = Dictionary:New()
    local offlionHeart = 0
    --添加离线物品id
    local function AddOfflineItemId(itemId)
        if not offlineItemIds:Contains(itemId) then
            offlineItemIds:Add(itemId)
        end
    end
    --判断是否包含区域id
    local function IsContentOffline(zoneId)
        if not offlineProductions:ContainsKey(zoneId) then
            local info = {}
            info.outputInfo = {}
            info.inputInfo = {}
            offlineProductions:Add(zoneId, info)
        end
        return offlineProductions[zoneId]
    end

    --添加离线消耗
    local function AddOfflineInput(zoneId, itemId, itemCount)
        AddOfflineItemId(itemId)
        local zoneInfo = IsContentOffline(zoneId)
        if zoneInfo.inputInfo[itemId] then
            zoneInfo.inputInfo[itemId] = zoneInfo.inputInfo[itemId] + itemCount
        else
            zoneInfo.inputInfo[itemId] = itemCount
        end
    end

    --添加离线产出
    local function AddOfflineOutput(zoneId, itemId, itemCount)
        AddOfflineItemId(itemId)
        local boosterFactor = BoostManager.GetMaterialBoostFactor(self.cityId, itemId)
        local realItemCount = itemCount * boosterFactor
        local zoneInfo = IsContentOffline(zoneId)
        if zoneInfo.outputInfo[itemId] then
            zoneInfo.outputInfo[itemId] = zoneInfo.outputInfo[itemId] + realItemCount
        else
            zoneInfo.outputInfo[itemId] = realItemCount
        end

        local itemConfig = ConfigManager.GetItemConfig(itemId)
        for i = 1, #itemConfig.ingredients, 1 do
            for iItemId, iCount in pairs(itemConfig.ingredients[i]) do
                AddOfflineInput(zoneId, iItemId, iCount * realItemCount)
            end
        end
    end

    local count = 0
    for hour, data in pairs(self.statisticalData) do
        count = count + 1
    end
    if count >= 24 then
        --根据统计数据获取离线数据
        local function EachZoneData(zoneId, zoneData)
            if zoneData.outputInfo then
                for itemId, itemCount in pairs(zoneData.outputInfo) do
                    AddOfflineOutput(zoneId, itemId, itemCount)
                end
            end
            if zoneData.inputInfo then
                for itemId, itemCount in pairs(zoneData.inputInfo) do
                    AddOfflineInput(zoneId, itemId, itemCount)
                end
            end
        end
        local heartBuff = BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.HeartBuff)
        local cashExpDouble = BoostManager.GetCommonBoosterFactor(self.cityId, CommonBoostType.EventCashExpDouble)
        for hour, data in pairs(self.statisticalData) do
            for zoneId, zoneData in pairs(data.zones) do
                EachZoneData(zoneId, zoneData)
            end
            offlionHeart = offlionHeart + (data.heart or 0) * heartBuff * cashExpDouble
        end
    else
        --根据角色数据获取离线数据
        local offline_default_factor = ConfigManager.GetMiscConfig("offline_default_factor")
        --设置炉子生产
        local zoneId = GeneratorManager.GetZoneId(self.cityId)
        local itemId = GeneratorManager.GetConsumptionCount(self.cityId)
        local itemCount = GeneratorManager.GetCount(self.cityId)
        itemCount = itemCount * BoostManager.GetCommonBoosterFactor(self.cityId, CommonBoostType.GeneratorResource)
        AddOfflineInput(zoneId, itemId, itemCount * 12)
        --遍历职业列表
        local function EachPeopleList(peopleConfig, list)
            local zoneIds = ConfigManager.GetZoneIdsByZoneType(self.cityId, peopleConfig.zone_type)
            zoneIds:ForEach(
                function(zoneId)
                    local mapItemData = MapManager.GetMapItemData(self.cityId, zoneId)
                    if not mapItemData then
                        return
                    end
                    local fconfig = ConfigManager.GetFurnitureById(peopleConfig.furniture_id)
                    if fconfig.productor_type == 1 or fconfig.productor_type == 2 then
                        return
                    end
                    for i = 1, list:Count(), 1 do
                        local duration = mapItemData:GetUsageDuration(peopleConfig.furniture_id, i)
                        --根据家具id 索引和等级 返回真实产出和基础产出
                        local realOutput, baseOutput = mapItemData:GetOutput(peopleConfig.furniture_id, i)
                        for itemId, itemCount in pairs(baseOutput) do
                            local itemConfig = ConfigManager.GetItemConfig(itemId)
                            if itemConfig.resource_type ~= 1 then
                                AddOfflineOutput(
                                    zoneId,
                                    itemId,
                                    Mathf.RoundToInt((itemCount / duration) * 60 * 12 * offline_default_factor)
                                )
                            end
                        end
                    end
                end
            )
        end
        local peopleDatas = {}
        local characterData = DataManager.GetCityDataByKey(self.cityId, DataKey.CharacterData)
        --遍历处理角色数据
        for id, info in pairs(characterData.infos) do
            if info.state == EnumState.Normal or info.state == EnumState.Protest then
                if not peopleDatas[info.professionType] then
                    peopleDatas[info.professionType] = List:New()
                end
                peopleDatas[info.professionType]:Add(info)
            end
        end
        for peopleType, peopleList in pairs(peopleDatas) do
            local peopleConfig = ConfigManager.GetPeopleConfigByType(self.cityId, peopleType)
            if peopleConfig.furniture_id ~= "" then
                EachPeopleList(peopleConfig, peopleList)
            end
        end

        if CityManager.GetIsEventScene(self.cityId) then
            local heartBuff = BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.HeartBuff)
            local cashExpDouble = BoostManager.GetCommonBoosterFactor(self.cityId, CommonBoostType.EventCashExpDouble)
            local itemConfig = ConfigManager.GetItemByType(self.cityId, ItemType.Heart)
            if itemConfig then
                offlionHeart = offlionHeart + itemConfig.shop_rewards_limit * 12 * 60 * heartBuff * cashExpDouble
            end
        end
    end
    --< 编号从小到大
    --> 编号从大到小
    offlineProductions:Sort(
        function(zoneId1, zoneId2)
            local cfg1 = ConfigManager.GetZoneConfigById(zoneId1)
            local cfg2 = ConfigManager.GetZoneConfigById(zoneId2)
            if cfg1.sort_queue == cfg2.sort_queue then
                return false
            end
            return cfg1.sort_queue < cfg2.sort_queue
        end
    )
    return offlineProductions, offlineItemIds, offlionHeart
end

---------------------------------
---
---------------------------------

--初始化在线数据
function CityStatistical:InitOnlineProdutcions(zoneId, info)
    for itemId, itemCount in pairs(info) do
        local itemConfig = ConfigManager.GetItemConfig(itemId)
        if itemConfig.resource_type ~= 1 then
            self.onlineProductions[itemId] = 0
            for i = 1, #itemConfig.ingredients, 1 do
                for id, count in pairs(itemConfig.ingredients[i]) do
                    self:SetOnlineConsumptions(id, 0)
                end
            end
        end
    end
    EventManager.Brocast(EventType.UPDATE_STATISTICAL, self.cityId)
end

--在线添加
function CityStatistical:AddOnlineProdutcions(zoneId, info)
    for itemId, itemCount in pairs(info) do
        local itemConfig = ConfigManager.GetItemConfig(itemId)
        if itemConfig.resource_type ~= 1 then
            if self.onlineProductions[itemId] then
                self.onlineProductions[itemId] = self.onlineProductions[itemId] + itemCount
            else
                self.onlineProductions[itemId] = itemCount
            end
            for i = 1, #itemConfig.ingredients, 1 do
                for id, count in pairs(itemConfig.ingredients[i]) do
                    self:SetOnlineConsumptions(id, count * itemCount)
                end
            end
        end
    end
    EventManager.Brocast(EventType.UPDATE_STATISTICAL, self.cityId)
end

--在线删除
function CityStatistical:RemoveOnlineProdutcions(zoneId, info)
    for itemId, itemCount in pairs(info) do
        local itemConfig = ConfigManager.GetItemConfig(itemId)
        if itemConfig.resource_type ~= 1 then
            if self.onlineProductions[itemId] then
                self.onlineProductions[itemId] = self.onlineProductions[itemId] - itemCount
            end
            for i = 1, #itemConfig.ingredients, 1 do
                for id, count in pairs(itemConfig.ingredients[i]) do
                    self:SetOnlineConsumptions(id, -count * itemCount)
                end
            end
        end
    end
    EventManager.Brocast(EventType.UPDATE_STATISTICAL, self.cityId)
end

--获取在线生产
function CityStatistical:GetOnlineProductions()
    local dataList = List:New()
    for itemId, itemCount in pairs(self.onlineProductions) do
        dataList:Add(itemId)
    end
    dataList:Sort(
        function(itemId1, itemId2)
            local item1 = ConfigManager.GetItemConfig(itemId1)
            local item2 = ConfigManager.GetItemConfig(itemId2)
            return item1.sort < item2.sort
        end
    )
    return dataList
end

--根据物品id获取在线生产数量
function CityStatistical:GetOnlineProductionsByItemId(itemId)
    return self.onlineProductions[itemId] or 0
end

--设置在线消耗
function CityStatistical:SetOnlineConsumptions(itemId, count)
    if self.onlineConsumptions[itemId] then
        self.onlineConsumptions[itemId] = self.onlineConsumptions[itemId] + count
    else
        self.onlineConsumptions[itemId] = count
    end
    EventManager.Brocast(EventType.UPDATE_STATISTICAL, self.cityId)
end

--获取在线消耗
function CityStatistical:GetOnlineConsumptions(itemId)
    if self.onlineConsumptions[itemId] then
        return self.onlineConsumptions[itemId]
    else
        return 0
    end
end

--按时间计算生产
function CityStatistical:GetProductionByTime()
    local produnctionInfos = {}
    --填充生产数据
    local function FillProductionInfo(outputInfo, inputInfo, duration)
        --根据家具id 索引和等级 返回真实产出和基础产出
        for itemId, itemCount in pairs(outputInfo) do
            if nil == produnctionInfos[itemId] then
                local info = {}
                info.outSpeed = 0
                info.inputSpeed = 0
                produnctionInfos[itemId] = info
            end
            produnctionInfos[itemId].outSpeed = produnctionInfos[itemId].outSpeed + itemCount / duration
        end
        for itemId, itemCount in pairs(inputInfo) do
            if nil == produnctionInfos[itemId] then
                local info = {}
                info.outSpeed = 0
                info.inputSpeed = 0
                produnctionInfos[itemId] = info
            end
            produnctionInfos[itemId].inputSpeed = produnctionInfos[itemId].inputSpeed + itemCount / duration
        end
    end
    --遍历职业列表
    local function EachPeopleList(peopleConfig, list)
        local zoneIds = ConfigManager.GetZoneIdsByZoneType(self.cityId, peopleConfig.zone_type)
        zoneIds:ForEach(
            function(zoneId)
                local mapItemData = MapManager.GetMapItemData(self.cityId, zoneId)
                if not mapItemData then
                    return
                end
                local fconfig = ConfigManager.GetFurnitureById(peopleConfig.furniture_id)
                if fconfig.productor_type == 1 or fconfig.productor_type == 2 then
                    return
                end
                for i = 1, list:Count(), 1 do
                    local duration = mapItemData:GetUsageDuration(peopleConfig.furniture_id, i)
                    --根据家具id 索引和等级 返回真实产出和基础产出
                    local outputInfo = mapItemData:GetOutput(peopleConfig.furniture_id, i)
                    --真实的消耗资源
                    local inputInfo = {}
                    if fconfig.productor_type == 4 then
                        inputInfo = ConfigManager.GetInputByOutput(outputInfo)
                    end
                    FillProductionInfo(outputInfo, inputInfo, duration)
                end
            end
        )
    end

    local peopleDatas = {}
    local characterData = DataManager.GetCityDataByKey(self.cityId, DataKey.CharacterData)
    --遍历处理角色数据
    for id, info in pairs(characterData.infos) do
        if info.state == EnumState.Normal or info.state == EnumState.Protest then
            if not peopleDatas[info.professionType] then
                peopleDatas[info.professionType] = List:New()
            end
            peopleDatas[info.professionType]:Add(info)
        end
    end
    for peopleType, peopleList in pairs(peopleDatas) do
        local peopleConfig = ConfigManager.GetPeopleConfigByType(self.cityId, peopleType)
        if peopleConfig.furniture_id ~= "" then
            EachPeopleList(peopleConfig, peopleList)
        end
    end
end
