---@class HeroController
HeroController = {}

function HeroController:Create(name)
    return ClassMono(name, HeroController)
end

function HeroController:Awake()
    self.moveAgent = AddComponment(self.gameObject, TypeMoveAgent)
end

function HeroController:OnInit(cityId, cardId, zoneType)
    self.cityId = cityId
    self.id = cardId
    self.zoneType = zoneType
    self.cardConfig = ConfigManager.GetCardConfig(cardId)
    self.toolInstances = {}
    self:SetSpeed()
    self.isGuideHeal = false
    --初始化位置
    local grid = GridManager.GetGridByMarkerType(self.cityId, GridMarker.Idle, self.zoneType)
    if nil == grid then
        return false
    end
    self:ChangeCurrGrid(grid, true)
    -- --初始化Agent
    self.schedulesAgent = FSMSystemAgent:New(self)
    self.schedulesAgent:AddSystem(ZoneType.Infirmary, FSMDoctor:New()) --医生
    self.schedulesAgent:AddSystem(ZoneType.Watchtower, FSMGuard:New()) --警卫
    self.schedulesAgent:AddSystem(ZoneType.Generator, FSMBoilerman:New()) --锅炉工
    self.schedulesAgent:AddSystem(ZoneType.None, FSMHeroNormal:New())--
    self.schedulesAgent:AddSystem(EnumState.Celebrate, FSMCelebrate:New()) --庆祝

    -- self.schedulesAgent = SchedulesAgent:New(self)
    -- self.schedulesAgent:AddSchedules(ZoneType.Infirmary, SchedulesHeal:New())
    -- self.schedulesAgent:AddSchedules(ZoneType.Watchtower, SchedulesSpeech:New())
    -- self.schedulesAgent:AddSchedules(SchedulesType.None, SchedulesHero:New())

    return true
end

function HeroController:Active()
    self:SetNextState(EnumState.Normal)
    self:SetNextSchedules()
    self.isActive = true
end

function HeroController:BindView()
    self.isShowView = true
    self.heroView = ObjectPoolManager.GetHeroView(self.cardConfig.asset_name)
    if not self.heroView then
    end
    self.nodeTransforms = {}
    for type, name in pairs(NodeType) do
        self.nodeTransforms[name] = GetTransformInChildren(self.heroView.gameObject, name)
    end
    SetGameObjectParent(self.transform, self.heroView.gameObject)
    self.moveAgent:SetAnimator(self.heroView.animator)
    if self.currAnimation then
        self.moveAgent:PlayAnimation(self.currAnimation)
    end
end

function HeroController:UnBindView()
    if self.heroView then
        ObjectPoolManager.BackToPool(self.heroView)
        self.heroView = nil
    end
    self.moveAgent:SetAnimator(nil)
    self:HideSchedulesView()
    self:ClearStoryBookIcon()
    self.isShowView = false
end

function HeroController:DeActive()
    self:UnBindView()
    self.schedulesAgent:DeActive()
    self.isActive = false
end

function HeroController:SetSpeed()
    self.moveAgent:SetSpeed(ConfigManager.GetMiscConfig("hero_move_speed"))
end

--获取角色状态
function HeroController:GetState()
    return self.state
end

--切换下一个状态
function HeroController:SetNextState(state)
    self.state = state
end

--角色职业类型
function HeroController:GetProfessionType()
    return self.cardConfig.work_job
end

--获取下一个日程
function HeroController:GetNextSchedules()
    local state = self:GetState()
    if state == EnumState.Normal then
        if self.schedulesAgent:IsContent(self.zoneType) then
            return self.zoneType
        else
            return ZoneType.None
        end
    else
        return state
    end
end

--设置下一个日程
function HeroController:SetNextSchedules()
    self.schedulesAgent:SetNextSchedules()
end

function HeroController:OpenWaringView(isOpen)
    self.isOpenWarning = isOpen
end

--是否健康
function HeroController:IsHealth()
    return true
end

--获取头顶点位
function HeroController:GetHeadPoint()
    return self.gameObject.transform.position + self.currGrid:GetViewOffset(self.id) + Vector3(0, 3.8, 0)
end

-- 切换角色网格
function HeroController:ChangeCurrGrid(nextGrid, forceRefresh)
    if not nextGrid then
        return
    end
    self:HideSchedulesView()
    self.currGrid = nextGrid
    if forceRefresh then
        self.transform.position = self.currGrid.position
    end
    FunctionHandles.SetEntityForward(self)
end

--切换队列网格
function HeroController:ChangeTargeGrid(nextGrid)
    if not nextGrid then
        return
    end
    self.targetGrid = nextGrid
end

function HeroController:HideSchedulesView()
    if not self.isShowView then
        return
    end
    Map.Instance:ClearView(self.currGrid.id .. "_" .. self.id)
end

--是否处于移动中
function HeroController:MoveIsRunning()
    return self.isMoveRunning
end

--根据路线移动
function HeroController:MoveToGrid(targetGrid, speedPercent)
    self:ChangeTargeGrid(targetGrid)
    if not self.isMoveRunning then
        self.isMoveRunning = true
    end
    --移动刷新
    local function OnMoveComplete()
        self:SetAnim(AnimationType.Idle)
        if self.currGrid.id ~= targetGrid.id then
            self:ChangeCurrGrid(targetGrid)
        end
        if self.isMoveRunning then
            self.isMoveRunning = false
        end
    end
    self:SetAnim(AnimationType.Walk)
    self.moveAgent:SetMovement(
        GridManager.GetPath(self.cityId, self.currGrid, targetGrid),
        speedPercent,
        AnimationType.Walk,
        nil,
        nil,
        OnMoveComplete
    )
end

--停止移动
function HeroController:StopMove()
    self.isMoveRunning = false
    self.moveAgent:StopMove()
end

--设置动画播放
function HeroController:SetAnim(animation)
    self.pervAnimation = self.currAnimation
    self.currAnimation = animation
end

--角色播放动画
function HeroController:PlayAnimEx(animation)
    self:SetAnim(animation)
    if self.heroView then
        self.moveAgent:PlayAnimation(animation)
    end
end

-- 节点物品显示
function HeroController:ShowNodeItem()
    self.nodeInfo = {}
    self.nodeInfo.zoneType = self.currGrid.zoneType
    self.nodeInfo.markerType = self.currGrid.markerType
    self.nodeInfo.furnitureId = self.currGrid.furnitureId
    self.nodeInfo.furnitureLevel = self.currGrid:GetFurnitureLevel()
    self:BindNodeItem()
end

-- 节点物品隐藏
function HeroController:HideNodeItem()
    self:UnBindNodeItem()
    self.nodeInfo = nil
end

--绑定节点信息
function HeroController:BindNodeItem()
    if not self.isShowView then
        return
    end
    self:UnBindNodeItem()
    --设置节点信息
    local config = ConfigManager.GetSpecialGridConfig(self.nodeInfo.zoneType, self.nodeInfo.markerType)
    if config then
        --特殊格子随机动画挂点
        if config.left_hand_name ~= "" then
            self:CreateNodeItem(NodeType.HandLeft, config.left_hand_name, config.left_hand_id)
        end
        if config.right_hand_name ~= "" then
            self:CreateNodeItem(NodeType.HandRight, config.right_hand_name, config.right_hand_id)
        end
    else
        local config = ConfigManager.GetFurnitureById(self.nodeInfo.furnitureId)
        if not config then
            return
        end
        --家具格子家具等级为挂点等级索引
        local index = self.nodeInfo.furnitureLevel
        if config.left_hand_name ~= "" then
            self:CreateNodeItem(NodeType.HandLeft, config.left_hand_name, config.left_hand_id[index])
        end
        if config.right_hand_name ~= "" then
            self:CreateNodeItem(NodeType.HandRight, config.right_hand_name, config.right_hand_id[index])
        end
    end
end

--添加节点物品
function HeroController:CreateNodeItem(nodeType, assetsName, assetsLevel)
    if nil == self.nodeTransforms[nodeType] then
        return
    end
    local path = "prefab/character/tools/" .. assetsName .. "_Lv" .. assetsLevel
    self.toolInstances[nodeType] = ResourceManager.Instantiate(path, self.nodeTransforms[nodeType])
end

--解绑节点信息
function HeroController:UnBindNodeItem()
    for nodeType, go in pairs(self.toolInstances) do
        GameObject.Destroy(go)
    end
    self.toolInstances = {}
end

function HeroController:GetInstanceId(viewId)
    viewId = viewId or ""
    return self.currGrid.id .. "_" .. viewId
end

function HeroController:ShowView(viewId, viewType, viewParams)
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

function HeroController:UpdateView(viewId, viewType, viewParams)
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
function HeroController:HideView(viewId)
    if not self.isShowView then
        return
    end
    Map.Instance:ClearView(self:GetInstanceId(viewId))
end

--获取医疗时间
function HeroController:GetMedicalTime()
    if self.isGuideHeal then
        return 5
    end
    return BoostManager.GetBoost(self.cityId):GetRxBoosterValue(RxBoostType.MedicalTime)
end

--获取医疗值
function HeroController:GetMedicalValue()
    if self.isGuideHeal then
        return 100
    end
    return BoostManager.GetBoost(self.cityId):GetRxBoosterValue(RxBoostType.MedicalValue)
end

--刷新
function HeroController:Update()
    if not self.isActive then
        return
    end
    if self.schedulesAgent then
        self.schedulesAgent:Update()
    end

    if self.storyBookItem ~= nil then
        self.storyBookItem.transform.position = self:GetTipPoint(Vector3(0, 5, 0))
    end
end

--获取Tip的中心点
function HeroController:GetTipPoint(offset)
    local tar = self.transform.position
    local rotation = Quaternion.Euler(45, 45, 0)
    local newPos = tar + rotation * Vector3(0, 0, -20)
    if offset ~= nil then
        newPos = newPos + offset
    end
    return newPos
end

---@param params table
---@param clickAction function
function HeroController:ShowStoryBookIcon(params, clickAction)
    --if not self.dialogueView then
    --    self.dialogueView = ObjectPoolManager.GetSceneView(ViewType.Dialogue)
    --    SetTransformParent(self.transform, self.dialogueView.transform)
    --    --self.dialogueView.transform.localPosition = Vector3(0, 3.3, 0)
    --    ---@type SceneViewDialogue viewDialogue
    --    local viewDialogue = self.dialogueView.luaTable
    --    viewDialogue:OnShow(params, clickAction)
    --    self.moveAgent:SetWaringViewGo(self.dialogueView.gameObject)
    --end
    if self.storyBookItem == nil then
        if self.storyBookTimeout ~= nil then
            clearTimeout(self.storyBookTimeout)
            self.storyBookTimeout = nil
        end
        self.storyBookTimeout =
            setTimeout(
            function()
                self.storyBookTimeout = nil
                self.storyBookItem = ResourceManager.Instantiate("ui/MapUI/StoryBookHeroIcon", Map.Instance.mapUI)
            end,
            300
        )

    --self.storyBookItem.transform.position = self:GetTipPoint(Vector3(0, 0, 0))
    ---@type StoryBookBuildIcon storyBookItemView
    --self.storyBookItemView = StoryBookBuildIcon:Create(self.storyBookItem)
    --self.storyBookItemView:SetClickAction(clickAction)
    --self.storyBookItemView.transform.localScale = Vector3(0.5, 0.5, 0.5)
    end
end

function HeroController:ClearStoryBookIcon()
    --if self.dialogueView then
    --    self.dialogueView.luaTable:OnHide()
    --    ObjectPoolManager.BackToPool(self.dialogueView)
    --    self.dialogueView = nil
    --    self.moveAgent:SetWaringViewGo(nil)
    --end
    if self.storyBookTimeout ~= nil then
        clearTimeout(self.storyBookTimeout)
        self.storyBookTimeout = nil
    end
    if self.storyBookItem ~= nil then
        ResourceManager.Destroy(self.storyBookItem)
        self.storyBookItem = nil
    --self.storyBookItemView = nil
    end
end
