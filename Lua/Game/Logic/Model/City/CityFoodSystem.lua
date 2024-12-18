CityFoodSystem = Clone(CityBase)
CityFoodSystem.__cname = "CityFoodSystem"

function CityFoodSystem:OnInit()
    self.foodBag = DataManager.GetCityDataByKey(self.cityId, DataKey.FoodBag)
    self.foodType = DataManager.GetCityDataByKey(self.cityId, DataKey.FoodType)
    if not self.foodBag then
        self.foodBag = {}
    end
    --解锁食物类型
    self.foodItemInfos = List:New()
    for index, cfg in pairs(ConfigManager.GetFoodItemConfigs(self.cityId)) do
        if nil == self.foodBag[cfg.id] then
            self.foodBag[cfg.id] = 0
        end
        local info = {}
        info.requireLv = self.cityConfig.food_card_level[index]
        info.config = cfg
        self.foodItemInfos:Add(info)
    end
    --厨房
    self.zoneId = ConfigManager.GetZoneIdByZoneType(self.cityId, ZoneType.Kitchen)
    self.mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    local cardId = self.mapItemData:GetCardId()
    if cardId == 0 then
        cardId = self.mapItemData:GetDefaultCardId()
    end
    self.cardId = cardId
    --更新食物类型
    local function UpdateFoodType(cardLevel)
        local foodType = nil
        self.foodItemInfos:ForEach(
            function(item)
                if cardLevel >= item.requireLv then
                    foodType = item.config.id
                end
            end
        )
        if foodType and foodType ~= self.foodType then
            self:SetFoodType(foodType)
        end
    end
    self.cardLevelRx = NumberRx:New(self:GetCardLevel())
    self.cardLevelRxSubscribe = self.cardLevelRx:subscribe(UpdateFoodType)

    self.foodCountRx = {}
    for foodId, foodCount in pairs(self.foodBag) do
        self.foodCountRx[foodId] = NumberRx:New(foodCount)
        self.foodCountRx[foodId]:subscribe(
            function(val)
                self.foodBag[foodId] = val
                DataManager.SetCityDataByKey(self.cityId, DataKey.FoodBag, self.foodBag)
            end,
            false
        )
    end
    self.replaceFood = {}
    self.tempFood = 0
    self.tempTool = {}
end

---实例化显示
function CityFoodSystem:OnInitView()
    self:CreateFoodCountView()
    self:CreateFoodCostView()
    self.meatRxSubscribe =
        DataManager.GetMaterialRx(self.cityId, self:GetFoodCostItem()):subscribe(
        function(count)
            self:UpdateFoodCostView()
        end,
        false
    )
    self.meatDelayRxSubscribe =
        DataManager.GetMaterialDelayRx(self.cityId, self:GetFoodCostItem()):subscribe(
        function(count)
            self:UpdateFoodCostView()
        end,
        false
    )
end

---清除显示
function CityFoodSystem:OnClearView()
   -- Map.Instance:ClearView("FoodCountView")
   -- Map.Instance:ClearView("FoodCostView")

    if self.foodCostUI then
        self.foodCostUI:Clear()
        self.foodCostUI = nil
    end
    if self.foodUI then
        self.foodUI:Clear()
        self.foodUI = nil
    end
    self.meatRxSubscribe:unsubscribe()
    self.meatDelayRxSubscribe:unsubscribe()
end

function CityFoodSystem:OnClear()
    self.cardLevelRxSubscribe:unsubscribe()
    self = nil
end

---------------------------------
--事件回调
---------------------------------
--日程结束监听
function CityFoodSystem:SchedulesAddFunc(schedules)
    if schedules.type == SchedulesType.Arbeit then
        self.tempTool = {}
    end
end

--日程结束监听
function CityFoodSystem:SchedulesRemoveFunc(schedules)
    if schedules.type == SchedulesType.Eat then
        self.tempFood = 0
    end
end

--建筑物升级回调
function CityFoodSystem:UpgradeZoneFunc(zoneId, zoneType, level)
    if zoneType == ZoneType.Kitchen and level == 1 then
        self:CreateFoodCostView()
        self:CreateFoodCountView()
    end
end

--建筑物升级回调
function CityFoodSystem:UpgradeFurnitureFunc(zoneId, zoneType, furnitureType, index, level)
    if zoneType == ZoneType.Kitchen and furnitureType == GridMarker.ServingTable and level == 1 then
        self:CreateFoodCountView()
    end
end

--建筑物升级回调
function CityFoodSystem:CharacterRefreshFunc()
    self:UpdateFoodCountView()
end

--区域卡牌更换
function CityFoodSystem:ZoneCardChangeFunc(zoneId)
    if self.zoneId ~= zoneId then
        return
    end
    self.cardLevelRx.value = self:GetCardLevel()
end

--更新卡牌等级
function CityFoodSystem:UpgradeCardLevelFunc(cardId, level)
    if cardId ~= self.cardId then
        return
    end
    self.cardLevelRx.value = level
end

---------------------------------
--显示调用调用
---------------------------------
--创建食物数量显示
function CityFoodSystem:CreateFoodCountView()
    -- if not self.isShowView then
    --     return
    -- end
    local gird = GridManager.GetGridByMarkerType(self.cityId, GridMarker.ServingTable, ZoneType.Kitchen)
    if not gird then
        return
    end
    -- local baseParams = {}
    -- baseParams.cityId = self.cityId
    -- baseParams.viewId = "FoodCountView"
    -- baseParams.viewType = ViewType.Display
    -- baseParams.viewPoint = gird:GetViewPosition()
    -- local viewParams = {}       
    -- viewParams.selectIndex = 3
    -- viewParams.value = self:GetFoodCount() .. "/" .. CharacterManager.GetCharacterCount(self.cityId)
    -- Map.Instance:CreateView(baseParams, viewParams)

    local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    if not mapItemData.isShowView then
        return
    end

    if self.foodUI then
        return
    end

    self.foodUI = CityFoodUI.new()
    local addName = GetLang(mapItemData.config.zone_type_name)
    ResInterface.SyncLoadGameObject("UIMapProduction", function (_go)
        local go = GOInstantiate(_go)
        go.name = "UIMapProduction_" .. addName
        self.foodUI:bind(go)
        self.foodUI.gameObject.transform:SetParent(CityModule.getMainCtrl()._rootMapUI)
        local viewParams = {}
        viewParams.sprite = self.foodType
        viewParams.selectIndex = 3
        viewParams.value = self:GetFoodCount() .. "/" .. CharacterManager.GetCharacterCount(self.cityId)
        self.foodUI:init(viewParams)
        self.foodUI.gameObject.transform.position = gird:GetViewRealPosition()
    end)
end

--更新食物数量显示  
function CityFoodSystem:UpdateFoodCountView()
    -- if not self.isShowView then
    --     return
    -- end
    local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    if not mapItemData.isShowView then
        return
    end
    if not self.foodUI then
        return
    end

    local viewParams = {}
    viewParams.value = self:GetFoodCount() .. "/" .. CharacterManager.GetCharacterCount(self.cityId)
    self.foodUI:UpdateView(viewParams)
end

--更新食物ICON
function CityFoodSystem:UpdateFoodIconView()
    local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    if not mapItemData.isShowView then
        return
    end
    if not self.foodUI then
        return
    end

    local viewParams = {}
    viewParams.sprite = self.foodType
    viewParams.value = self:GetFoodCount() .. "/" .. CharacterManager.GetCharacterCount(self.cityId)
    self.foodUI:UpdateView(viewParams)
end

--创建食物消耗显示
function CityFoodSystem:CreateFoodCostView()
    -- if not self.isShowView then
    --     return
    -- end
    local gird = GridManager.GetGridByMarkerType(self.cityId, GridMarker.Items, ZoneType.Kitchen)
    if not gird then
        return
    end
    -- local baseParams = {}
    -- baseParams.cityId = self.cityId
    -- baseParams.viewId = "FoodCostView"
    -- baseParams.viewType = ViewType.Display
    -- baseParams.viewPoint = gird:GetViewPosition()
    -- local viewParams = {}
    -- viewParams.selectIndex = 3
    -- viewParams.value = DataManager.GetMaterialCountFormat(self.cityId, self:GetFoodCostItem())
    -- Map.Instance:CreateView(baseParams, viewParams)

    local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    if not mapItemData.isShowView then
        return
    end

    if self.foodCostUI then
        return
    end

    local addName = GetLang(mapItemData.config.zone_type_name)
    self.foodCostUI = CityFoodCostUI.new()
    ResInterface.SyncLoadGameObject("UIMapProduction", function (_go)
        local go = GOInstantiate(_go)
        go.name = "UIMapProduction_" .. addName
        self.foodCostUI:bind(go)
        self.foodCostUI.gameObject.transform:SetParent(CityModule.getMainCtrl()._rootMapUI)
        local viewParams = {}
        viewParams.sprite = self:GetFoodCostItem() -- Utils.GetItemIcon(self:GetFoodCostItem())
        viewParams.selectIndex = 3
        viewParams.value = DataManager.GetMaterialCountFormat(self.cityId, self:GetFoodCostItem())
        self.foodCostUI:init(viewParams)
        self.foodCostUI.gameObject.transform.position = gird:GetViewRealPosition()
    end)
end

function CityFoodSystem:UpdateFoodCostView()
    local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    if not mapItemData.isShowView then
        return
    end
    if not self.foodCostUI then
        return
    end

    local viewParams = {}
    viewParams.value = DataManager.GetMaterialCountFormat(self.cityId, self:GetFoodCostItem())
    self.foodCostUI:UpdateView(viewParams)
end

---------------------------------
--方法调用
---------------------------------
--获取厨房卡牌等级
function CityFoodSystem:GetCardLevel()
    if self.mapItemData then
        return self.mapItemData:GetCardLevel()
    end
    return 0
end

--获取当前食物类型
function CityFoodSystem:GetFoodType()
    return self.foodType
end

--设置当前食物类型
function CityFoodSystem:SetFoodType(foodType)
    self.foodType = foodType
    DataManager.SetCityDataByKey(self.cityId, DataKey.FoodType, foodType)
    self:UpdateFoodIconView()
end

--获取当前食物类型
function CityFoodSystem:GetViewFoodType()
    -- local foodType = self.foodType
    -- local itemConfig = ConfigManager.GetItemConfig(foodType)
    -- if self.replaceFood[itemConfig.item_type] ~= nil then
    --     foodType = self.replaceFood[itemConfig.item_type]
    -- end
    return self:GetFoodType()
end

--获取食物信息
function CityFoodSystem:GetFoodInfo()
    return self:GetViewFoodType(), self:GetCardLevel(), self.foodItemInfos
end

-- --设置当前食物替换
-- function CityFoodSystem:SetReplaceFoodItem(itemId)
--     self.foodItemInfos:ForEach(
--         function(foodItem)
--             self.replaceFood[foodItem.config.item_type] = itemId
--         end
--     )
-- end

-- --取消当前食物替换
-- function CityFoodSystem:CancelReplaceFoodItem(itemId)
--     self.foodItemInfos:ForEach(
--         function(foodItem)
--             self.replaceFood[foodItem.config.item_type] = nil
--         end
--     )
-- end

-- --获取当前食物替换
-- function CityFoodSystem:GetReplaceFoodItem(foodType)
--     local itemConfig = ConfigManager.GetItemConfig(foodType)
--     if self.replaceFood[itemConfig.item_type] ~= nil then
--         foodType = self.replaceFood[itemConfig.item_type]
--     end
--     return foodType
-- end

-- --判断是否有食物替换
-- function CityFoodSystem:GetIsHaveReplaceFood()
--     local ret = false
--     if self.replaceFood ~= nil then
--         for key, value in pairs(self.replaceFood) do
--             if value ~= nil then
--                 ret = true
--                 break
--             end
--         end
--     end
--     return ret
-- end

--添加食物背包
function CityFoodSystem:AddFood(type, count)
    self.foodCountRx[type].value = self.foodCountRx[type].value + count
    EventManager.Brocast(EventType.COLLECT_FOOD, self.cityId, type, count)
    self:UpdateFoodCountView()
end

--从食物背包中移除指定食物
function CityFoodSystem:RemoveFood(type, count)
    if self.foodCountRx[type].value > count then
        self.foodCountRx[type].value = self.foodCountRx[type].value - count
    else
        self.foodCountRx[type].value = 0
    end
    self:UpdateFoodCountView()
end

--添加默认食物
function CityFoodSystem:AddFoodCount(count)
    self:AddFood(self.foodType, count)
end

--获取食物背包数量
function CityFoodSystem:GetFoodCount()
    local foodCount = 0
    for type, count in pairs(self.foodBag) do
        foodCount = foodCount + count
    end
    return foodCount
end

--根据食物id获取数量
function CityFoodSystem:GetFoodCountById(foodId)
    return self.foodCountRx[foodId].value
end

--获取食物数量监听
function CityFoodSystem:GetFoodCountRx(foodId)
    return self.foodCountRx[foodId] or NumberRx:New(0)
end

--获取当前食物消耗物品
function CityFoodSystem:GetFoodCostItem()
    local itemConfig = ConfigManager.GetItemConfig(self.foodType)
    for i = 1, #itemConfig.ingredients, 1 do
        for itemId, itemCount in pairs(itemConfig.ingredients[i]) do
            return itemId
        end
    end
end

-----------------------------------------------------------------------
---日程逻辑调用
-----------------------------------------------------------------------
--是否可以烹饪
function CityFoodSystem:IsCanCook()
    local ret = true
    local isFull = false
    if self:GetFoodCount() + self.tempFood >= CharacterManager.GetCharacterCount(self.cityId) then
        ret = false
        isFull = true
        --print("ID_-0是否可以烹饪-IsCanCook,ret0,isFull1,FoodCount",self:GetFoodCount(),"tempFood", self.tempFood,"CharacterCount",CharacterManager.GetCharacterCount(self.cityId))

    else
        local output = {}
        output[self.foodType] = 1
        local input = ConfigManager.GetInputByOutput(output)
        ret = DataManager.CheckMaterials(self.cityId, input)
        if not ret then
            FloatIconManager.AddProductLackEvent({output = output})
        end
        --print("ID_-1是否可以烹饪-IsCanCook,ret1,isFull0,FoodCount",self:GetFoodCount(),"tempFood", self.tempFood,"CharacterCount",CharacterManager.GetCharacterCount(self.cityId),"原材料是否足够",ret )

    end
    return ret, isFull
end

--开始一次烹饪
function CityFoodSystem:StartCooking()
    self.tempFood = self.tempFood + 1
    local output = {}
    output[self.foodType] = 1
    DataManager.UseMaterials(self.cityId, ConfigManager.GetInputByOutput(output), "Cooking", foodType)
end

--完成一次烹饪
function CityFoodSystem:EndCooking()
    self.tempFood = self.tempFood - 1
    if self:GetFoodCount() < CharacterManager.GetCharacterCount(self.cityId) then
        self:AddFood(self.foodType, 1)
        StatisticalManager.AddFoodProductions(self.cityId, 1)
    end
end

--领取食物
function CityFoodSystem:EatFood()
    local foodType = self.foodType
    if self:GetFoodCountById(foodType) <= 0 then
        self.foodItemInfos:ForEach(
            function(item)
                if self:GetFoodCountById(item.config.id) > 0 then
                    foodType = item.config.id
                    return true
                end
                return false
            end
        )
    end
    if foodType then
        self:RemoveFood(foodType, 1)
    end
    return foodType
end

--获取当前工具是否可以用
function CityFoodSystem:IsCanUseTool(fid, index)
    if self.tempTool[fid .. "_" .. index] then
        return false
    end
    return true
end

--开始使用当前工具
function CityFoodSystem:StartUseTool(fid, index)
    self.tempTool[fid .. "_" .. index] = true
end

--结束使用工具
function CityFoodSystem:EndUseTool(fid, index)
    local HunterCabinId = ConfigManager.GetZoneIdByZoneType(self.cityId, ZoneType.HunterCabin)
    local mapItemData = MapManager.GetMapItemData(self.cityId, HunterCabinId)
    --根据家具id 索引和等级 返回真实产出和基础产出
    local realOutput, baseOutput = mapItemData:GetOutput(fid, index)
    --添加资源产出
    DataManager.AddMaterials(self.cityId, realOutput, "Hunting", fid)
    --添加基础产出统计
    for key, value in pairs(baseOutput) do
        StatisticalManager.AddFoodCostProductions(self.cityId, value)
    end
    return realOutput
end

-- --获取吃饭移动速度加成
-- function CityFoodSystem:GetEatMoveSpeed(foodType)
--     local itemConfig = ConfigManager.GetItemConfig(foodType)
--     local ret = itemConfig.food_effect["Speed"]
--     ret = ret + BoostManager.GetCommonBoosterFactor(self.cityId, CommonBoostType.CookSpeed)
--     return ret
-- end
