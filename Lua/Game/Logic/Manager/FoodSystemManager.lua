FoodSystemManager = {}
FoodSystemManager.__cname = "FoodSystemManager"

local this = FoodSystemManager

function FoodSystemManager.Init()
    this.cityId = DataManager.GetCityId()
    if not this.foodSystemItems then
        this.foodSystemItems = Dictionary:New()
    end
    if not this.foodSystemItems:ContainsKey(this.cityId) then
        this.foodSystemItems:Add(this.cityId, CityFoodSystem:New(this.cityId))
        if this.foodSystemItems:Count() == 1 then
            EventManager.AddListener(EventType.SCHEDULES_ADD, this.SchedulesAddFunc)
            EventManager.AddListener(EventType.SCHEDULES_REMOVE, this.SchedulesRemoveFunc)
            EventManager.AddListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)
            EventManager.AddListener(EventType.UPGRADE_FURNITURE, this.UpgradeFurnitureFunc)
            EventManager.AddListener(EventType.CHARACTER_REFRESH, this.CharacterRefreshFunc)
            EventManager.AddListener(EventType.ZONE_CARD_CHANGE, this.ZoneCardChangeFunc)
            EventManager.AddListener(EventType.UPGRADE_CARD_LEVEL, this.UpgradeCardLevelFunc)
        end
    end
end

---实例化显示
function FoodSystemManager.InitView()
    this.GetFoodSystem(this.cityId):InitView()
end

function FoodSystemManager.ClearView()
    this.GetFoodSystem(this.cityId):ClearView()
end

function FoodSystemManager.Clear(force)
    Utils.SwitchSceneClear(this.cityId, this.foodSystemItems, force)
    if this.foodSystemItems:Count() == 0 then
        EventManager.RemoveListener(EventType.SCHEDULES_ADD, this.SchedulesAddFunc)
        EventManager.RemoveListener(EventType.SCHEDULES_REMOVE, this.SchedulesRemoveFunc)
        EventManager.RemoveListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)
        EventManager.RemoveListener(EventType.UPGRADE_FURNITURE, this.UpgradeFurnitureFunc)
        EventManager.RemoveListener(EventType.CHARACTER_REFRESH, this.CharacterRefreshFunc)
        EventManager.RemoveListener(EventType.ZONE_CARD_CHANGE, this.ZoneCardChangeFunc)
        EventManager.RemoveListener(EventType.UPGRADE_CARD_LEVEL, this.UpgradeCardLevelFunc)
    end
end

function FoodSystemManager.GetFoodSystem(cityId)
    return this.foodSystemItems[cityId]
end

---------------------------------
--事件回调
---------------------------------
--日程添加监听
function FoodSystemManager.SchedulesAddFunc(cityId, schedules)
    this.GetFoodSystem(cityId):SchedulesAddFunc(schedules)
end

--日程结束监听
function FoodSystemManager.SchedulesRemoveFunc(cityId, schedules)
    this.GetFoodSystem(cityId):SchedulesRemoveFunc(schedules)
end

--建筑物升级回调
function FoodSystemManager.UpgradeZoneFunc(cityId, zoneId, zoneType, level)
    this.GetFoodSystem(cityId):UpgradeZoneFunc(zoneId, zoneType, level)
end

--建筑物升级回调
function FoodSystemManager.UpgradeFurnitureFunc(cityId, zoneId, zoneType, furnitureType, index, level)
    this.GetFoodSystem(cityId):UpgradeFurnitureFunc(zoneId, zoneType, furnitureType, index, level)
end

--建筑物升级回调
function FoodSystemManager.CharacterRefreshFunc(cityId)
    this.GetFoodSystem(cityId):CharacterRefreshFunc()
end

--区域卡牌更换
function FoodSystemManager.ZoneCardChangeFunc(cityId, zoneId)
    this.GetFoodSystem(cityId):ZoneCardChangeFunc(zoneId)
end

--升级卡牌等级
function FoodSystemManager.UpgradeCardLevelFunc(cityId, cardId, level)
    this.GetFoodSystem(cityId):UpgradeCardLevelFunc(cardId, level)
end

---------------------------------
--方法调用
---------------------------------
--获取当前食物类型
function FoodSystemManager.GetFoodType(cityId)
    return this.GetFoodSystem(cityId):GetFoodType()
end

--设置当前食物类型
function FoodSystemManager.SetFoodType(cityId, foodType)
    this.GetFoodSystem(cityId):SetFoodType(foodType)
end

--获取当前食物类型显示
function FoodSystemManager.GetViewFoodType(cityId)
    return this.GetFoodSystem(cityId):GetViewFoodType()
end

--获取当前食物类型显示
function FoodSystemManager.GetFoodInfo(cityId)
    return this.GetFoodSystem(cityId):GetFoodInfo()
end

--获取当前食物消耗物品
function FoodSystemManager.GetFoodCostItem(cityId)
    return this.GetFoodSystem(cityId):GetFoodCostItem()
end

--是否可以烹饪
function FoodSystemManager.IsCanCook(cityId)
    return this.GetFoodSystem(cityId):IsCanCook()
end

--开始一次烹饪
function FoodSystemManager.StartCooking(cityId)
    this.GetFoodSystem(cityId):StartCooking()
end

--完成一次烹饪
function FoodSystemManager.EndCooking(cityId)
    this.GetFoodSystem(cityId):EndCooking()
end

--根据状态获取食物数量
function FoodSystemManager.GetFoodCount(cityId)
    return this.GetFoodSystem(cityId):GetFoodCount()
end

--根据状态设置食物数量
function FoodSystemManager.AddFoodCount(cityId, count)
    this.GetFoodSystem(cityId):AddFoodCount(count)
end

function FoodSystemManager.GetFoodCountRx(cityId, foodId)
    return this.GetFoodSystem(cityId):GetFoodCountRx(foodId)
end

--领取食物
function FoodSystemManager.EatFood(cityId)
    return this.GetFoodSystem(cityId):EatFood()
end

--吃饭时间完成 清空剩饭
function FoodSystemManager.EatFoodOver(cityId)
    this.GetFoodSystem(cityId):EatFoodOver()
end

--获取当前工具是否可以用
function FoodSystemManager.IsCanUseTool(cityId, fid, index)
    return this.GetFoodSystem(cityId):IsCanUseTool(fid, index)
end

--开始使用当前工具
function FoodSystemManager.StartUseTool(cityId, fid, index)
    return this.GetFoodSystem(cityId):StartUseTool(fid, index)
end

--结束使用工具
function FoodSystemManager.EndUseTool(cityId, fid, index)
    return this.GetFoodSystem(cityId):EndUseTool(fid, index)
end

-- --获取吃饭移动速度加成
-- function FoodSystemManager.GetEatMoveSpeed(cityId, foodType)
--     return this.GetFoodSystem(cityId):GetEatMoveSpeed(foodType)
-- end

-- --设置当前食物替换
-- function FoodSystemManager.SetReplaceFoodItem(cityId, itemId)
--     return this.GetFoodSystem(cityId):SetReplaceFoodItem(itemId)
-- end

-- --取消当前食物替换
-- function FoodSystemManager.CancelReplaceFoodItem(cityId, itemId)
--     return this.GetFoodSystem(cityId):CancelReplaceFoodItem(itemId)
-- end

-- --取消当前食物替换
-- function FoodSystemManager.GetReplaceFoodItem(cityId, foodType)
--     return this.GetFoodSystem(cityId):GetReplaceFoodItem(foodType)
-- end

-- --判断是否有食物替换
-- function FoodSystemManager.GetIsHaveReplaceFood(cityId)
--     return this.GetFoodSystem(cityId):GetIsHaveReplaceFood()
-- end
