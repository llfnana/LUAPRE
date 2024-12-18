---@class Grid
Grid = {}
Grid.__cname = Grid

function Grid:New(cityId, gridInfo)
    gridInfo = gridInfo or {}
    local cls = setmetatable(gridInfo, { __index = self })
    cls:Init(cityId)
    return cls
end

--初始化
function Grid:Init(cityId)
    self.cityId = cityId
    self.id = Utils.PositionToGridId(self.xIndex, 0, self.zIndex)
    if self:IsFurnitureGrid() then
        self.furnitureId = string.format("C%d_%s_%s", self.cityId, self.zoneType, self.markerType)
        self.furnitureConfig = ConfigManager.GetFurnitureById(self.furnitureId)
    elseif self.markerType == GridMarker.Doctor then
        self.furnitureId = string.format("C%d_%s_%s", self.cityId, self.zoneType, GridMarker.MedicalBed)
        self.furnitureConfig = ConfigManager.GetFurnitureById(self.furnitureId)
    end
    self.capacityList = List:New()
    self:ResetGrid()
end

function Grid:Clear()
    -- self.capacityList:Clear()
    -- self:ClearProductView()
end

--重制格子属性
function Grid:ResetGrid()
    --格子站立的角色对象
    self.parent = nil
    self.gCost = 0
    self.hCost = 0
    self.fCost = 0
    self.pCost = Utils.LamdaExpression(self.zoneType == ZoneType.MainRoad, 0, 10)
end

--获取家具等级
function Grid:GetFurnitureLevel()
    if nil == self.furnitureId then
        return 0
    end
    local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    if not mapItemData then
        return 0
    end
    if not mapItemData:IsUnlock() then
        return 0
    end
    return mapItemData:GetFurnitureLevel(self.furnitureId, self.markerIndex)
end

--获取区域编号
function Grid:GetZoneNumber()
    local zoneIdSplits = string.split(self.zoneId, "_")
    if #zoneIdSplits >= 3 then
        return tonumber(zoneIdSplits[3])
    end
    return 1
end

--格子是否解锁状态
function Grid:IsUnlock()
    if nil == self.furnitureId then
        return true
    end
    if self.zoneType == ZoneType.MainRoad then
        return true
    end
    if not self:IsFurnitureGrid() then
        return true
    end
    if nil ~= self.furnitureConfig then
        local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
        if mapItemData and mapItemData:IsUnlock() then
            return mapItemData:IsUnlockFurniture(self.furnitureId, self.markerIndex)
        end
    end
    return false
end

--获取格子容量
function Grid:GetCapacity()
    if self.furnitureConfig then
        return self.furnitureConfig.capacity
    elseif self.markerType == GridMarker.Queue then
        return 1
    elseif self.markerType == GridMarker.VanQueue then
        return 1
    elseif self.markerType == GridMarker.Idle then
        return 10
    elseif self.markerType == GridMarker.Special1ForIdle then
        return 1
    elseif self.markerType == GridMarker.Special2ForIdle then
        return 1
    elseif self.markerType == GridMarker.Special3ForIdle then
        return 1
    elseif self.markerType == GridMarker.Protest then
        return 1
    elseif self.markerType == GridMarker.Protest2 then
        return 1
    else
        return 9999
    end
end

--获取动画名称
function Grid:GetAnimation()
    if self.furnitureConfig then
        return self.furnitureConfig.animation
    else
        local specialGrid = ConfigManager.GetSpecialGridConfig(self.zoneType, self.markerType)
        if specialGrid then
            return specialGrid.animation
        end
    end
    return nil
end

--获取使用消耗时间
function Grid:GetUsageDuration()
    local duration = 0
    if nil == self.furnitureId then
        if self.markerType == GridMarker.Idle then
            duration = 5
        elseif self.markerType == GridMarker.Door then
            duration = 1
        elseif self.markerType == GridMarker.Queue then
            duration = 1
        elseif self.markerType == GridMarker.VanQueue then
            duration = 1
        elseif self.markerType == GridMarker.Items then
            duration = 1
        else
            local specialGrid = ConfigManager.GetSpecialGridConfig(self.zoneType, self.markerType)
            if specialGrid then
                duration = specialGrid.usage_duration
            end
        end
        duration = duration
    else
        if self.zoneId ~= "" then
            local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
            if mapItemData then
                duration = mapItemData:GetUsageDuration(self.furnitureId, self.markerIndex)
            end
        end
    end
    return duration
end

--获取交互奖励
function Grid:GetNecessitiesReward()
    if nil == self.furnitureId then
        return {}
    end
    if not self:IsUnlock() then
        return {}
    end
    local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    if not mapItemData then
        return {}
    end
    return mapItemData:GetNecessitiesReward(self.furnitureId, self.markerIndex)
end

--获取生病交互奖励
function Grid:GetNecessitiesRewardSick()
    if nil == self.furnitureId then
        return {}
    end
    if not self:IsUnlock() then
        return {}
    end
    local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    if not mapItemData then
        return {}
    end
    return mapItemData:GetNecessitiesRewardSick(self.furnitureId, self.markerIndex)
end

function Grid:GetLoadLimit()
    if nil == self.furnitureId then
        return {}
    end
    if not self:IsUnlock() then
        return {}
    end
    local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    if not mapItemData then
        return {}
    end
    return mapItemData:GetLoadLimit(self.furnitureId, self.markerIndex)
end

--获取加载物品信息
function Grid:GetLoadLimitInfo()
    for itemId, itemCount in pairs(self:GetLoadLimit()) do
        local currCount = DataManager.GetMaterialCount(self.cityId, itemId)
        local realItemCount = itemCount * TestManager.GetTest(self.cityId).aiGameSpeed.value
        if currCount < realItemCount then
            return itemId, currCount
        else
            return itemId, realItemCount
        end
    end
    print("[error]" .. "配置错误")
    return nil
end

function Grid:GetAttributeDeltaFactor(type)
    if self.zoneType == ZoneType.MainRoad then
        return 1
    end
    local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    if not mapItemData then
        return 1
    end
    return mapItemData:GetDeltaFactorByType(type)
end

--是否可用
function Grid:IsCanUse()
    if not self:IsUnlock() then
        return false
    end
    if self:GetCapacityCount() >= self:GetCapacity() then
        return false
    end
    return true
end

--是否是家具格子
function Grid:IsFurnitureGrid()
    return Utils.IsFurnitureGrid(self.markerType)
end

--家具是否可用
function Grid:IsFurnitureCanUse()
    if not self:IsUnlock() then
        return false
    end
    if not self:IsFurnitureGrid() then
        return false
    end
    local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    if nil == mapItemData then
        return false
    end
    return mapItemData:IsFurnitureCanUse(self.furnitureId, self.markerIndex)
end

--家具是否可以工作
function Grid:IsFurnitureCanWork()
    if not self:IsUnlock() then
        return false
    end
    if not self:IsFurnitureGrid() then
        return false
    end
    return MapManager.IsCanProduct(self.cityId, self.zoneId, self.furnitureId, self.markerIndex)
end

--检测家具使用状态
function Grid:GetFurnitureWorkState()
    if not self:IsUnlock() then
        return WorkStateType.Disable
    end
    if not self:IsFurnitureCanUse() then
        return WorkStateType.Disable
    end
    if self.furnitureConfig.productor_type == 1 then
        local ret, isFull = FoodSystemManager.IsCanCook(self.cityId)
        if ret or isFull then
            return WorkStateType.Work
        else
            return WorkStateType.Pause
        end
    elseif self.furnitureConfig.productor_type == 2 then
        return WorkStateType.Work
    elseif self.furnitureConfig.productor_type == 3 then
        return WorkStateType.Work
    elseif self:IsFurnitureCanWork() then
        return WorkStateType.Work
    else
        return WorkStateType.Pause
    end
end

--获取格子容量
function Grid:GetCapacityCount()
    return self.capacityList:Count()
end

-- 填充容量
function Grid:AddCapacity(id)
    if not self.capacityList:Contains(id) then
        self.capacityList:Add(id)
    end
end

-- 删除容量
function Grid:RemoveCapacity(id)
    self.capacityList:Remove(id)
end

-- 获取容量索引
function Grid:GetCapacityIndex(id)
    for i = 1, self.capacityList:Count(), 1 do
        if self.capacityList[i] == id then
            return i
        end
    end
    return -1
end

local count = 0
-- 创建生产ItemUI
function Grid:CreateProductionUI()
    if nil == self.furnitureConfig or self.productionView ~= nil then
        return
    end
    if self.furnitureConfig.productor_type ~= 3 and self.furnitureConfig.productor_type ~= 4 then
        return
    end
    if not self:IsUnlock() then
        return
    end
    local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    if not mapItemData.isShowView then
        return
    end
    if self.productionUI then
        return
    end

    local addName = GetLang(mapItemData.config.zone_type_name)
    self.productionUI = CityProductionUI.new()

    count = count + 1
    ResInterface.SyncLoadGameObject("UIMapProduction", function(_go)
        local go = GOInstantiate(_go)
        go.name = "UIMapProduction_" .. addName
        self.productionUI:bind(go)
        self.productionUI.gameObject.transform:SetParent(CityModule.getMainCtrl()._rootMapUI)
        local viewParams = {}
        viewParams.itemId = -1
        viewParams.progress = 0
        viewParams.selectSprite = 1
        viewParams.zoneId = self.zoneId
        --cardLock
        local canUseToolCount = mapItemData:GetCanUseToolCount()
        if self.markerIndex > canUseToolCount then
            if self:GetFurnitureWorkState() == WorkStateType.Disable then
                --mapItemData:GetFurnitureNeedCardLevel(mapItemData:GetToolFurnitureId(), self.markerIndex)
                viewParams.selectSprite = 2
            end
        end

        self.productionUI:init(viewParams)
        local dir = self:GetCharacterToDir()
        local dirTb = {
            [1] = Vector3(0.3, 0.6, 0),
            [2] = Vector3(0.3, -0.6, 0),
            [3] = Vector3(-0.3, -0.6, 0),
            [4] = Vector3(-0.3, 0.6, 0),
        }
        self.productionUI.gameObject.transform.position = self:GetViewRealPosition() + dirTb[dir]
    end)
end

--添加生产显示(废弃)
function Grid:CreateProductView()
    if true then
        return
    end

    if nil == self.furnitureConfig or self.productionView ~= nil then
        return
    end
    if self.furnitureConfig.productor_type ~= 3 and self.furnitureConfig.productor_type ~= 4 then
        return
    end
    if not self:IsUnlock() then
        return
    end
    local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    if not mapItemData.isShowView then
        return
    end
    local viewId = self.id .. "_" .. self.furnitureConfig.id .. "_" .. self.markerIndex
    if Map.Instance:ExistView(viewId) then
        return
    end

    local baseParams = {}
    baseParams.cityId = self.cityId
    baseParams.viewId = viewId
    baseParams.viewType = ViewType.Production
    baseParams.viewPoint = self:GetViewPosition()
    local viewParams = {}
    viewParams.itemId = -1
    viewParams.progress = 0
    viewParams.selectSprite = 1

    --local peopleConfig = ConfigManager.GetPeopleConfigByZoneType(self.cityId, mapItemData.config.zone_type)
    --if peopleConfig ~= nil then
    --local peopleWorkState = CharacterManager.GetPeopleStateCount(self.cityId, peopleConfig.type)
    --local normalCount = peopleWorkState[EnumState.Normal] or 0
    --local sickCount = peopleWorkState[EnumState.Sick] or 0
    --local protestCount = peopleWorkState[EnumState.Protest] or 0
    --local totalCount = normalCount + sickCount + protestCount

    --cardLock
    local canUseToolCount = mapItemData:GetCanUseToolCount()
    if self.markerIndex > canUseToolCount then
        if self:GetFurnitureWorkState() == WorkStateType.Disable then
            --mapItemData:GetFurnitureNeedCardLevel(mapItemData:GetToolFurnitureId(), self.markerIndex)
            viewParams.selectSprite = 2
        end
    end
    --end

    ---@type SceneViewProduction productionView
    self.productionView = Map.Instance:CreateView(baseParams, viewParams).luaTable
end

--清理生产显示
function Grid:ClearProductView()
    if self.productionUI == nil then
        return
    end
    self.productionUI:Clear()
    -- Map.Instance:ClearView(self.id .. "_" .. self.furnitureId .. "_" .. self.markerIndex)
    self.productionUI = nil
end

--更新生产显示
---@param isAssign boolean
---@param arbeitStateType ArbeitStateType
---@param debuff table
function Grid:UpdateProductView(isAssign, arbeitStateType, debuff)
    if self.productionUI == nil then
        return
    end
    local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    if not mapItemData.isShowView then
        return
    end
    local viewParams = {}
    viewParams.debuff = nil
    if not isAssign then
        viewParams.itemId = -1
        viewParams.progress = 0
        viewParams.selectSprite = 1
        --cardLock
        local canUseToolCount = mapItemData:GetCanUseToolCount()
        if self.markerIndex > canUseToolCount then
            if self:GetFurnitureWorkState() == WorkStateType.Disable then
                viewParams.selectSprite = 2
            end
        end
        self.productionUI:UpdateView(viewParams)
        return
    end

    viewParams.debuff = debuff
    local ret, lackMaterial = self:IsFurnitureCanWork()
    if lackMaterial then
        local itemId, progress = mapItemData:GetProductDataProgress(self.furnitureConfig.id, self.markerIndex)
        viewParams.itemId = itemId
        viewParams.progress = progress
        viewParams.selectSprite = 0
        self.productionUI:UpdateView(viewParams)
        return
    end

    if arbeitStateType == ArbeitStateType.Work then
        local itemId, progress = mapItemData:GetProductDataProgress(self.furnitureConfig.id, self.markerIndex)
        viewParams.itemId = itemId
        viewParams.progress = progress
        viewParams.selectSprite = 1
        self.productionUI:UpdateView(viewParams)
        return
    end
end

function Grid:UpdateCardLevelUp()
    if self.productionUI == nil then
        return
    end
    local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    if not mapItemData.isShowView then
        return
    end

    local viewParams = {}
    viewParams.debuff = nil
    viewParams.itemId = -1
    viewParams.progress = 0
    viewParams.selectSprite = 1
    --cardLock
    local canUseToolCount = mapItemData:GetCanUseToolCount()
    if self.markerIndex > canUseToolCount then
        if self:GetFurnitureWorkState() == WorkStateType.Disable then
            viewParams.selectSprite = 2
        end
    end
    self.productionUI:UpdateView(viewParams)
end

--获取交互概率
function Grid:GetRecoverReward()
    if nil == self.furnitureId then
        return 0
    end
    if not self:IsUnlock() then
        return 0
    end
    local mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    if not mapItemData then
        return 0
    end
    local reward = mapItemData:GetRecoverReward(self.furnitureId, self.markerIndex)
    for key, value in pairs(reward) do
        return value
    end
    return 0
end

function Grid:GetViewPosition()
    return self.position + Vector3(0, 3.8, 0)
end

function Grid:GetViewRealPosition()
    local mapCtrl = CityModule.getMapCtrl()
    local cell = mapCtrl:getCellByXY(self.xIndex, self.zIndex)
    return Vector3(cell.realpos.x, cell.realpos.y, 0) + Vector3(0, 0.2, 0)
end

-- 获取出生点坐标
function Grid:GetBonePosition()
    local mapCtrl = CityModule.getMapCtrl()
    local cell = mapCtrl:getCellByXY(self.xIndex, self.zIndex)
    return Vector3(cell.realpos.x, cell.realpos.y, 0)
end

function Grid:GetViewOffset(characterId)
    if self.markerType == GridMarker.Bed then
        local index = self:GetCapacityIndex(characterId)
        if index == 1 then
            return Camera.main.transform.rotation * Vector3.left * 0.3
        elseif index == 2 then
            return Camera.main.transform.rotation * Vector3.right * 0.3
        end
    end
    return Vector3.zero
end

--获取格子动画参数
function Grid:GetAnimationParmas(characterId)
    if nil ~= self.animationParams then
        local index = self:GetCapacityIndex(characterId)
        if #self.animationParams >= index then
            return self.animationParams[index]
        end
    end
    return nil
end

--获取格子动画信息
function Grid:GetAnimationInfo(characterId)
    local animationParams = self:GetAnimationParmas(characterId)
    local position = self.position
    local eulerAngles = nil
    if nil ~= animationParams then
        position = position + animationParams.animOffset
        eulerAngles = animationParams.animEulerAngles
    end
    return position, eulerAngles
end

--获取当前格子所设置的小人的朝向
function Grid:GetCharacterToDir()
    return self.yIndex
end
