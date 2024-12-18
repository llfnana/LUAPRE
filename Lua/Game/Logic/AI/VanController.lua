---@class VanController  厢式货车
VanController = {}

function VanController:Create(name)
    return ClassMono(name, VanController)
end

function VanController:Awake()
    self.moveAgent = AddComponment(self.gameObject, TypeMoveAgent)
end

function VanController:OnInit(cityId, id)
    self.cityId = cityId
    self.id = id
    self:SetSpeed()
    --初始化位置
    local grid = nil
    if
        TutorialManager.CurrentStep.value == TutorialStep.EventWarehouse or
            TutorialManager.CurrentStep.value == TutorialStep.EventWarehouse1002
     then
        grid = GridManager.GetGridByMarkerType(self.cityId, GridMarker.TutorialVanBorn)
        self:SetSpeed(0)
    else
        grid = GridManager.GetGridByMarkerType(self.cityId, GridMarker.VanBorn, ZoneType.MainRoad)
    end
    if nil == grid then
        return false
    end
    self:ChangeCurrGrid(grid, true)

    -- --初始化Agent
    self.schedulesAgent = FSMSystemAgent:New(self)
    self.schedulesAgent:AddSystem(SchedulesType.Van, FSMVan:New())
    -- self.schedulesAgent = SchedulesAgent:New(self)
    -- self.schedulesAgent:AddSchedules(SchedulesType.Van, SchedulesVan:New())
    return true
end

function VanController:Active()
    self:SetNextSchedules()
    self.isActive = true
end

function VanController:BindView()
    self.isShowView = true
    if CityManager.IsEventScene(EventCityType.Water) then
        self.vanView = ObjectPoolManager.GetTransportView("Ship")
        self.idleEffect = CSUtils.SearchGameObjectByName(self.vanView.transform, "effect_ship_idle")
        self.moveEffect = CSUtils.SearchGameObjectByName(self.vanView.transform, "effect_ship_walk")
    else
        self.vanView = ObjectPoolManager.GetTransportView("Van")
    end
    if not self.vanView then
    end
    SetGameObjectParent(self.transform, self.vanView.gameObject)
    -- 初始化白天黑夜节点
    self.vanLight = self.vanView.gameObject.transform:Find("Night")
    self:SetVanLight()

    self.moveAgent:SetAnimator(self.vanView.animator)
    if self.currAnimation then
        self.moveAgent:PlayAnimation(self.currAnimation)
    end
end

function VanController:UnBindView()
    if self.vanView then
        ObjectPoolManager.BackToPool(self.vanView)
        self.vanView = nil
        self.idleEffect = nil
        self.moveEffect = nil
        self.vanLight = nil
    end
    self.moveAgent:SetAnimator(nil)
    self:HideSchedulesView()
    self.isShowView = false
end

--角色消亡
function VanController:DeActive()
    self:UnBindView()
    self.moveAgent:StopMove()
    self:PlayIdleEffect()
    if nil ~= self.currGrid then
        self.currGrid:RemoveCapacity(self.id)
    end
    if nil ~= self.bedGrid then
        self.bedGrid:RemoveCapacity(self.id)
    end
    self.targetGrid = nil
    self.schedulesAgent:DeActive()
    GameObject.Destroy(self.gameObject)
end

function VanController:SetSpeed(guideSpeed)
    if guideSpeed ~= nil then
        self.moveAgent:SetSpeed(guideSpeed)
    else
        local speed =
            ConfigManager.GetMiscConfig("event_car_default_speed")
            --BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.VanSpeed)
        self.moveAgent:SetSpeed(speed)
    end
end

function VanController:SetVanLight()
    if not self.isShowView then
        return
    end
    if nil == self.vanLight then
        return
    end
    self.vanLight.gameObject:SetActive(TimeManager.GetCityIsNight(self.cityId))
end

-- 切换角色网格
function VanController:ChangeCurrGrid(nextGrid, forceRefresh)
    if not nextGrid then
        return
    end
    if self.currGrid then
        self.currGrid:RemoveCapacity(self.id)
    end
    self:HideSchedulesView()
    self.currGrid = nextGrid
    self.currGrid:AddCapacity(self.id)
    if forceRefresh then
        self.transform.position = self.currGrid.position
    end
end

--切换队列网格
function VanController:ChangeTargeGrid(nextGrid)
    if not nextGrid then
        return
    end
    if self.targetGrid then
        --床位点格子不需要清除占用量
        if self.targetGrid.markerType ~= GridMarker.Bed then
            self.targetGrid:RemoveCapacity(self.id)
        end
    end
    self.targetGrid = nextGrid
    self.targetGrid:AddCapacity(self.id)
end

function VanController:HideSchedulesView()
    if not self.isShowView then
        return
    end
    Map.Instance:ClearView(self.currGrid.id .. "_" .. self.id)
end

--设置下一个日程
function VanController:SetNextSchedules()
    self.schedulesAgent:SetNextSchedules()
end

--获取下一个日程
function VanController:GetNextSchedules()
    return SchedulesType.Van
end

--是否处于移动中
function VanController:MoveIsRunning()
    return self.isMoveRunning
end

--根据路线移动
function VanController:MoveToGrid(targetGrid, speedPercent)
    self:ChangeTargeGrid(targetGrid)
    self.isMoveRunning = true
    --移动刷新
    local function OnMoveComplete()
        if self.currGrid.id ~= targetGrid.id then
            self:ChangeCurrGrid(targetGrid)
        end
        if self.isMoveRunning then
            self.isMoveRunning = false
        end
        self:PlayIdleEffect()
    end
    self.moveAgent:SetMovement(
        GridManager.GetPath(self.cityId, self.currGrid, targetGrid),
        speedPercent,
        AnimationType.Walk,
        self.targetGrid:GetAnimationParmas(self.id),
        nil,
        OnMoveComplete
    )

    self:PlayMoveEffect()
end

--停止移动
function VanController:StopMove()
    self.isMoveRunning = false
    self.moveAgent:StopMove()
    self:PlayIdleEffect()
end

------------------------------------------------------------------------------
---警告显示
------------------------------------------------------------------------------
function VanController:GetHeadPoint()
    return self.gameObject.transform.position + self.currGrid:GetViewOffset(self.id) + Vector3(0, 3.8, 0)
end

function VanController:OpenWaringView(isOpen)
    self.isOpenWarning = isOpen
end

function VanController:ShowVanView()
    if self.vanView then
        self.vanView.gameObject:SetActive(true)
    end
end

function VanController:HideVanView()
    if self.vanView then
        self.vanView.gameObject:SetActive(false)
    end
end

function VanController:ShowCashView()
    if not self.isShowView then
        return
    end
    AudioManager.PlayEffect("ui_dock_cash")
    local cashView = ResourceManager.Instantiate("prefab/character/car/fx_addmoney")
    cashView.transform.position = self:GetHeadPoint()
end

function VanController:GetInstanceId(viewId)
    viewId = viewId or ""
    return self.currGrid.id .. "_" .. viewId
end

function VanController:ShowView(viewId, viewType, viewParams)
    if not self.isShowView then
        return
    end
    local baseParams = {}
    baseParams.cityId = self.cityId
    baseParams.viewId = self:GetInstanceId(viewId)
    baseParams.viewType = viewType
    baseParams.viewPoint = self:GetHeadPoint()
    Map.Instance:CreateView(baseParams, viewParams)
end

function VanController:UpdateView(viewId, viewType, viewParams)
    if not self.isShowView then
        return
    end
    if not Map.Instance:ExistView(self:GetInstanceId(viewId)) then
        self:ShowView(viewId, viewType, viewParams)
    else
        Map.Instance:UpdateView(self:GetInstanceId(viewId), viewParams)
    end
end

--日程显示隐藏
function VanController:HideView(viewId)
    local itemId, itemCount = self.currGrid:GetLoadLimitInfo()
    EventSceneManager.ExchangeCash(itemId, itemCount)
    local baseHeart, realHeart = MapManager.GetHeartProductCount(self.cityId, self.currGrid.furnitureId)
    if baseHeart > 0 then
        EventSceneManager.AddHeart(baseHeart, realHeart, "Production", self.currGrid.furnitureId)
    end
    if not self.isShowView then
        return
    end
    Map.Instance:ClearView(self:GetInstanceId(viewId))
    local viewParams = List:New()
    for cashId, cashCount in pairs(EventSceneManager.ExchangeCashFormula(itemId, itemCount)) do
        local info = {}
        info.type = ItemType.Cash
        info.sprite = Utils.GetItemIcon(cashId)
        info.selectIndex = 3
        info.value = cashCount
        viewParams:Add(info)
    end
    --爱心显示
    if realHeart > 0 then
        local info = {}
        info.type = ItemType.Heart
        info.sprite = Utils.GetItemIcon(ConfigManager.GetEventHeartItemId(self.cityId))
        info.selectIndex = 3
        info.value = realHeart
        viewParams:Add(info)
    end
    if viewParams:Count() > 0 then
        self:ShowView("Tips_%s" .. self.id, ViewType.Tips, viewParams)
    end
end

function VanController:PlayMoveEffect()
    if self.idleEffect ~= nil then
        self.idleEffect.gameObject:SetActive(false)
    end
    if self.moveEffect ~= nil then
        self.moveEffect.gameObject:SetActive(true)
    end
end

function VanController:PlayIdleEffect()
    if self.idleEffect ~= nil then
        self.idleEffect.gameObject:SetActive(true)
    end
    if self.moveEffect ~= nil then
        self.moveEffect.gameObject:SetActive(false)
    end
end
--刷新
function VanController:Update()
    if not self.isActive then
        return
    end
    if self.schedulesAgent then
        self.schedulesAgent:Update()
    end
end
