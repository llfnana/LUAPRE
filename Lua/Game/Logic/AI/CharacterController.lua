---@class CharacterController
--CharacterController = {}
local LuaEvent = require "Logic/LuaEvent"


local CharacterController = class('CharacterController', CityChar)
--function CharacterController:Create(name)
--    return ClassMono(name, CharacterController)
--end

--function CharacterController:Awake()
--    --self.moveAgent = AddComponment(self.gameObject, TypeMoveAgent)
--end
local PlayerState = {
    Idle = 1,
    Moving = 2,
    MoveDone = 3,
}

function CharacterController:ctor(id)
    CityChar.ctor(self, id)
    self.id = id
    self.gameObject = nil
    self.transform = nil
    self.animation = nil
    self.animationState = nil
    self.animationSke = nil
    self.meshRenderer = nil
    self.initPosition = nil

    self._initScaleX = nil --初始X比例
    self._isFlip = false   --是否翻转


    self.isDestroy        = false --是否回收

    self.cell             = nil ---@type City.MapCell 当前站位格
    self.cellTarget       = nil ---@type City.MapCell 当前站位格

    self._curAnim         = nil ---@type CityCharAnim 当前动画
    self._curDir          = nil ---@type City.PositionDir 当前朝向

    self._state           = PlayerState.Idle
    self._mvTargets       = {} ---@type Home.MapCell[] 移动目标格子

    self.interactEvt      = LuaEvent.new() ---@type LuaEvent 交互事件
    self._pathFinder      = nil ---@type AStar.PathFinder 寻路
    self.movecompletefunc = nil
    self.moveupdatefunc   = nil
    self.movetype         = 0
    self.bCanMove         = 1
    self.bRoom            = false
    self.bCircleActive    = false
    self.curSchedule      =  "None"

    --- 小人头项UI [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[
    self.ui_go = {}
    self.ui_load_statue = {}
    self.ui_load_statue[CityCharUI.UI.Progress] = LoadStatue.None
    self.ui_load_statue[CityCharUI.UI.Slider]   = LoadStatue.None
    self.ui_load_statue[CityCharUI.UI.Tips]     = LoadStatue.None
    self.ui_load_statue[CityCharUI.UI.Warning]  = LoadStatue.None
    --- 小人头项UI ]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
end

function CharacterController:bind(go, resid)
    self.gameObject = go
    self.transform = go.transform
    self.canvas = self.transform:Find("Canvas")
    self.initPosition = go.transform.position
    self.transform.rotation = Vector3.zero
    -- self.transform.localScale = Vector3.one * 0.65
    self.animation = go:GetComponentInChildren(typeof(SkeletonAnimation))
    self.meshRenderer = go:GetComponentInChildren(typeof(MeshRenderer))
    self.meshRenderer.sortingLayerName = "Building"
    --加载Spine DataAsset
    self.spineResGuid = ResInterface.SyncLoadCommon(resid .. '_SkeletonData.asset', function(dataAsset)
        self.animation.skeletonDataAsset = dataAsset
        self.animation:Initialize(true)
        self.animationState = self.animation.state
        self.animationSke = self.animation.skeleton
        self.animation.timeScale = 1
        --根据站位设置比例大小
        local scale = CityDefine.CharScale
        local scaleX = scale  --朝向

        if self.animationSke then 
            self.animationSke.ScaleX = scaleX
            self.animationSke.ScaleY = scale
        else 
            print("[Error] ", resid .. '_SkeletonData.asset', debug.traceback())
        end
        self._initScaleX = scaleX

         --self:SetAnim(AnimationType.Idle)
         --self:playAnim("idle",CityPosition.Dir.Down)
    end)
end

function CharacterController:setSortingOrder(order)
    --  CityChar.setSortingOrder(self, order)
    if self.meshRenderer then
        self.meshRenderer.sortingOrder = order
    end
end

---@param cell Home.MapCell
---@param notPos boolean 是否不改变位置
function CharacterController:setCell(cell, notPos)
    CityChar.setCell(self, cell, notPos)
end

---@param path Home.MapCell[]
function CharacterController:move(path)
    --    if #path > CityDefine.BlinkDistance then
    --        self:blink(path[#path])
    --        return
    --    end

    --ListUtil.clear(self._mvTargets)
    self._mvTargets = path
end

---瞬移
---@param cell Home.MapCell
function CharacterController:blink(cell)
    self._mvTargets = { cell }
    self._isBlink = true
end

---设置翻转（角色朝向）
function CharacterController:flip(isFlip)
    isFlip = isFlip or false
    if isFlip == self._isFlip then
        return
    end
    self.animationSke.ScaleX = isFlip and -self._initScaleX or self._initScaleX
    self._isFlip = isFlip
end

function CharacterController:isFlip()
    return self._isFlip
end

--播放动画（0通道，强制播放，不循环）
---@param name string|SkeletonAnimation 动画名
---@param loop boolean 是否循环（默认false）

---播放动画和朝向
---@param anim HomeCharAnim 动画
---@param dir Home.PositionDir
function CharacterController:playAnim(anim, dir, loop, callCBFun, timeScale)
    timeScale = timeScale or 1
    dir = dir or self._curDir
    loop = loop or true
    --相同动画和朝向不重复播放
    if self._curAnim == anim and self._curDir == dir then

        return
    end
    if self.animation and self.animation.state and self.animation.skeleton then
        local name, isFlip = self:_getAnimNameAndFlip(anim, dir)
        if name ~= self.animation.AnimationName then
            local entry = self.animation.state:SetAnimation(0, name, loop)
            if callCBFun ~= nil then
                entry:AddOnComplete(callCBFun)
            end
        end
        self.animation.skeleton.ScaleX = isFlip and -1 or 1
        self.animation.timeScale = timeScale

        self._curAnim = anim
        self._curDir = dir
    else
    end
end

---@private
---@param anim HomeCharAnim 动画
---@param dir Home.PositionDir 朝向
---@return string, boolean 动画名，是否翻转
function CharacterController:_getAnimNameAndFlip(anim, dir)
    --判断是否需要翻转（上下翻转为左右）
    local isFlip = dir == CityPosition.Dir.Up or dir == CityPosition.Dir.Down

    local animName = anim -- nil


    --    --上和左的动作朝后
    if dir == CityPosition.Dir.Up
        or dir == CityPosition.Dir.Left then
        animName = animName .. "_back"
    end

    return animName, isFlip
end

function CharacterController:updateEx()
    if self.transform == nil then
        return
    end

    if self.bCircleActive then
        local circle = self.transform:Find("Circle")

        if self.currGrid.zoneType == ZoneType.MainRoad or self.currGrid.zoneType == ZoneType.Kitchen then
            circle.gameObject:SetActive(false)
        else
            circle.gameObject:SetActive(true)
        end
    end
    if  self.animationSke then
       if self.currGrid.markerType == "Occlusion" then
            self.animationSke.A = 0.5
        else
           self.animationSke.A = 1.0
        end    
    end

    -- self:showName()
    if #self._mvTargets > 0 then
        if self._state == PlayerState.Moving then
            return
        end

        local tarCell = table.remove(self._mvTargets, 1)


        ---@type Home.Position 朝向向量
        local moveVec = tarCell.position - self.cell.position
        self.bCanMove = 1


        self:setCell(tarCell, true) --先设置格子，防止移动过程寻路错误


        local mt = 0.3

        -- 吃饭状态机
        if self.schedulesAgent and self.schedulesAgent.currFsmSystem  and self.schedulesAgent.currFsmSystem.__cname == "FSMEat" then 
            if self.schedulesAgent.currFsmSystem.currentState.stateId == StateId.MoveToKitchenDoor then 
                self.movetype = 100
            elseif self.schedulesAgent.currFsmSystem.currentState.stateId == StateId.EatMoveToServingTable or self.schedulesAgent.currFsmSystem.currentState.stateId == StateId.EatMoveToKitchenQueue then 
                self.movetype = 101
            end
        end

        if (self.movetype == 3) then
            mt = 0.1
            self:playAnim("run", moveVec:toDir())
        elseif (self.movetype == 15) then  --新手引导厨娘快跑
            mt = 0.06
            self:playAnim("run", moveVec:toDir())
        elseif (self.movetype == 4) then
            mt = 0.3
            self:playAnim("eatwalk", moveVec:toDir())
        elseif (self.movetype == 2) then
            mt = 0.3
            self:playAnim("walk", moveVec:toDir())
        elseif (self.movetype == 5) then
            mt = 0.3
            self:playAnim("sttrikemarch", moveVec:toDir())
        elseif (self.movetype == 8) then
            mt = 0.3
            self:playAnim("walk1", moveVec:toDir())
        elseif (self.movetype == 1) then
            mt = 0.4
            self:playAnim("lesionrun", moveVec:toDir())
        elseif self.movetype == 100 then 
            mt = 0.05
            self:playAnim("run", moveVec:toDir())
        elseif self.movetype == 101 then 
            mt = 0.18
            self:playAnim("walk", moveVec:toDir())
        else
            if self.isMoveRunning then
                self:playAnim("walk", moveVec:toDir())
            else
                self.movetype  =0
                self:SetAnim(AnimationType.Idle)
                self:playAnim("idle", moveVec:toDir())
            end
        end

        self._state = PlayerState.Moving

        local target = tarCell:getRealPos()
        local moveTween = self.transform:DOMove(target, mt)
        moveTween:SetEase(Ease.Linear)

        moveTween:OnUpdate(function()
            if self.moveupdatefunc then
                self.moveupdatefunc(self.cell.position.x, self.cell.position.y)
            end
        end)
        moveTween:OnComplete(function()
            self._state = PlayerState.MoveDone
            if self.movecompletefunc then
                if #self._mvTargets == 0 then
                    self.isMoveRunning = false

                   self:UpdateCharSorting()
                   self.movecompletefunc()
                    self:SetAnim(AnimationType.Idle)
                    self:playAnim("idle", moveVec:toDir())

                end
            end
        end)
    elseif self._state == PlayerState.MoveDone then
        self._state = PlayerState.Idle
        if self.currAnimation == "run" or self.currAnimation == "walk" then
            self:SetAnim(AnimationType.Idle)
            self:playAnim("idle")
        end
        -- 地址重复，则可能不需要走路，直接完成
        self.movecompletefunc()
    else
        
    end
end

function CharacterController:UpdateCharSorting()
    if self.transform then
        local isInside = self:GetCharIsInRoom()
        if isInside then
            local x = self.transform.position.x
            local y = self.transform.position.y --  + 0.5

            local isSleep = self.currAnimation == "sleeping"
            local orederAdd = isSleep and 100 or 0
            self:setSortingOrder(CityModule.getMainCtrl():GetSortingByPosition(x, y) + orederAdd)
        else
            self:setSortingOrder(10000)
        end
    end
end

---尝试设置动画朝向
---@param dir Home.PositionDir
function CharacterController:trySetAnimDir(dir)
    --判断是否空闲状态
    if self._state ~= PlayerState.Idle then
        return
    end

    self:playAnim(self._curAnim, dir)
end

--播放动画（0通道，强制播放，不循环）
---@param name string|SkeletonAnimation 动画名
---@param loop boolean 是否循环（默认true）
function CharacterController:playAnimLoop(name, loop)
    self:SetAnim(animation)
    loop = loop or true --默认循环播放
    return self.animationState:SetAnimation(0, name, loop)
    --self.animationSke.ScaleX = isFlip and -1 or 1
end

---添加动画队列
---@param name string 动画名
---@param loop boolean 是否循环（默认false）
---@param delay number 延迟（默认无）
---@return TrackEntry
function CharacterController:addAniEx(name, loop, delay)
    loop = loop or false --默认不循环播放
    delay = delay or 0   --默认无延迟
    return self.animationState:AddAnimation(0, name, loop, delay)
end

function CharacterController:destroy()
    if self.cell ~= nil then
        self.cell.char = nil
    end
    if self.isDestroy then
        return
    end

    for key, value in pairs(self.ui_go) do
        if value then 
            value:destroy()
        end
    end
    self.ui_go = {}
    for key, value in pairs(self.ui_load_statue) do
        self.ui_load_statue[key] = LoadStatue.None 
    end

    GODestroy(self.gameObject)
    self.gameObject = nil
    self.transform = nil

    self.isDestroy = true
    ResInterface.ReleaseRes(self.spineResGuid)
end

function CharacterController:OnDestroy()
    --self.player = nil
    self = nil
end

function CharacterController:OnInit(cityId, info)
    self.cityId = cityId
    self.id = info.id
    self.info = info
    self.toolInstances = {}
    self.speedStartRun = ConfigManager.GetMiscConfig("speed_start_run")
    self.tickTime = 0;
    -- self:_initPlayer(self.id) --创建角色

    --初始化属性配置
    self.attributeStartValue = {}
    self.attrobuteDeltaPerSecond = {}
    self.attributeMaxValue = {}
    self.attributeSafeLine = {}
    self.attributeAlertThreshold = {}
    for type, value in pairs(AttributeType) do
        local necessitiesConfig = ConfigManager.GetNecessitiesConfig(self.cityId, type)
        if nil ~= necessitiesConfig then
            self.attributeStartValue[type] = necessitiesConfig.start_value
            self.attrobuteDeltaPerSecond[type] = necessitiesConfig.delta_per_sec
            self.attributeMaxValue[type] = necessitiesConfig.max_value
            self.attributeSafeLine[type] = necessitiesConfig.safe_line
            self.attributeAlertThreshold[type] = necessitiesConfig.alert_threshold
        else
            self.attributeStartValue[type] = 0
            self.attrobuteDeltaPerSecond[type] = 0
            self.attributeMaxValue[type] = 100
            self.attributeSafeLine[type] = 0
            self.attributeAlertThreshold[type] = 0
        end
    end
    --预警显示参数
    self.warningViewParams = {
        showRx = NumberRx:New(true),
        stateRx = NumberRx:New(-1),
        attributeRx = NumberRx:New(-1),
        sickRx = NumberRx:New(0),
        markRx = NumberRx:New(0),
        warmShowRx = NumberRx:New(false),
        warmFromRx = NumberRx:New(-1),
        warmToRx = NumberRx:New(-1)
    }

    self.isGuideHeal = false
    --初始化角色速度
    self:SetSpeed()
    --设置职业配置
    self:SetPeopleConfig()
    if self.info.state == EnumState.HealthLow then
        self:SetState(EnumState.Severe)
    end
    --属性Boost
    self.attributeBoost = {}
    self.attributeBoostValue = 1
    --设置预警标记类型
    if nil == self.info.markState then
        self.info.markState = EnumMarkState.None
    end
    self:SetWarningViewMark(self.info.markState)

    --初始化床位点
    local bedGrid = GridManager.GetGridByMarkerType(self.cityId, GridMarker.Bed, ZoneType.Dorm)
    if not bedGrid then
        return false
    end
    -- self.gameObject:SetActive(true)
    self:ChangeBedGrid(bedGrid)
    --初始化位置
    local grid = nil
    if self.info.isNew then
        if TutorialManager.CurrentStep.value == TutorialStep.FirstEnterCity and self.cityId == 1 then
            grid = GridManager.GetGridByMarkerType(self.cityId, GridMarker.TutorialBorn)
        elseif TutorialManager.CurrentStep.value == TutorialStep.FirstEnterCity2 and self.cityId == 2 then
            grid = GridManager.GetGridByMarkerType(self.cityId, GridMarker.TutorialBorn)
        elseif
            (TutorialManager.CurrentStep.value == TutorialStep.EventEnterCity or
                TutorialManager.CurrentStep.value == TutorialStep.EventEnterCity1002) and
            CityManager.GetIsEventScene(self.cityId)
        then
            grid = GridManager.GetGridByMarkerType(self.cityId, GridMarker.TutorialBorn)
        else
            grid = GridManager.GetGridByMarkerType(self.cityId, GridMarker.Born)
        end
        self.info.isNew = false
    elseif self:GetState() == EnumState.Sick then
        local sickGrid = nil
        if self.info.sickInfo.healZone == ZoneType.Infirmary then
            sickGrid = GridManager.GetGridByMarkerType(self.cityId, GridMarker.MedicalBed, ZoneType.Infirmary)
        else
            sickGrid = self.bedGrid
        end
        grid = sickGrid
    elseif self:GetState() == EnumState.Protest then
        grid = GridManager.GetGridByMarkerType(self.cityId, GridMarker.Protest, ZoneType.MainRoad)
        if nil == grid then
            grid = GridManager.GetGridByMarkerType(self.cityId, GridMarker.Protest2, ZoneType.MainRoad)
        end
    else
        grid = GridManager.GetGridByZoneId(self.cityId, self.bedGrid.zoneId, GridMarker.Idle)
    end

    if nil == grid then
        grid = GridManager.GetGridByZoneId(self.cityId, self.bedGrid.zoneId, GridMarker.Idle)
    end
    --设置角色当前格子
    self:ChangeCurrGrid(grid, true)
    --初始化不需要保存的角色属性
    self.attributeInfo = {}

    --初始化SchedulesAgent
    self.schedulesAgent = FSMSystemAgent:New(self)
    self.schedulesAgent:AddSystem(SchedulesType.None, FSMFreeman:New())
    self.schedulesAgent:AddSystem(SchedulesType.Sleep, FSMSleep:New())
    self.schedulesAgent:AddSystem(SchedulesType.Cooking, FSMCooking:New())
    self.schedulesAgent:AddSystem(SchedulesType.Arbeit, FSMArbeit:New())
    self.schedulesAgent:AddSystem(SchedulesType.Eat, FSMEat:New())
    self.schedulesAgent:AddSystem(SchedulesType.Hunting, FSMHunting:New())
    self.schedulesAgent:AddSystem(SchedulesType.Home, FSMHome:New())
    self.schedulesAgent:AddSystem(SchedulesType.Arbeit_OverTime, FSMArbeit:New())
    self.schedulesAgent:AddSystem(EnumState.Protest, FSMProtest:New())
    self.schedulesAgent:AddSystem(EnumState.Severe, FSMSevere:New())
    self.schedulesAgent:AddSystem(EnumState.EventStrike, FSMStrike:New())
    self.schedulesAgent:AddSystem(EnumState.RunAway, FSMRunAway:New())
    self.schedulesAgent:AddSystem(EnumState.Dead, FSMDeath:New())
    self.schedulesAgent:AddSystem(EnumState.Celebrate, FSMCelebrate:New())
    self.schedulesAgent:AddSystem(EnumState.Sick, FSMSick:New())
    -- self.schedulesAgent:AddSystem(ZoneType.Infirmary, FSMDoctor:New()) --医生
    -- self.schedulesAgent:AddSystem(EnumState.Celebrate, FSMCelebrate:New()) --庆祝
    -- self.schedulesAgent = SchedulesAgent:New(self)
    -- self.schedulesAgent:AddSchedules(SchedulesType.None, SchedulesNone:New())
    -- self.schedulesAgent:AddSchedules(SchedulesType.Sleep, SchedulesSleep:New())
    -- self.schedulesAgent:AddSchedules(SchedulesType.Cooking, SchedulesCooking:New())
    -- self.schedulesAgent:AddSchedules(SchedulesType.Arbeit, SchedulesArbeit:New())
    -- self.schedulesAgent:AddSchedules(SchedulesType.Eat, SchedulesEat:New())
    -- self.schedulesAgent:AddSchedules(SchedulesType.Hunting, SchedulesHunting:New())
    -- self.schedulesAgent:AddSchedules(SchedulesType.Home, SchedulesNone:New())
    -- self.schedulesAgent:AddSchedules(SchedulesType.Arbeit_OverTime, SchedulesArbeit:New())
    -- self.schedulesAgent:AddSchedules(SchedulesType.Protest, SchedulesProtest:New())
    -- self.schedulesAgent:AddSchedules(SchedulesType.Celebrate, SchedulesCelebrate:New())
    -- self.schedulesAgent:AddSchedules(SchedulesType.EventStrike, SchedulesEventStrike:New())

   TimeModule.addDelay(5, function()   
        if isNil(self.transform) == false then 
            if self.currAnimation == "sleeping" then
                self._curDir =CityPosition.Dir.Right
            end       
            self:playAnim(self.currAnimation,self._curDir)
        end
    end)
    return true
end

--角色激活
function CharacterController:Active()
    self.isActive = true
    self.isMoveRunning = false
    self.schedulesStatus = {}
    self:SetNextState(self.info.state)
    self:OpenWaringView(true)
    self:SetNextSchedules()
end

--绑定显示
function CharacterController:BindView()
    if self.ui_load_statue[CityCharUI.UI.Warning] == LoadStatue.None and self.ui_go[CityCharUI.UI.Warning] == nil then
        self.ui_load_statue[CityCharUI.UI.Warning] = LoadStatue.Loading
        CityCharUI.CreateFollowUI(CityCharUI.UI.Warning, self.transform, function(go)
            self.ui_load_statue[CityCharUI.UI.Warning] = LoadStatue.Loaded
            self.ui_go[CityCharUI.UI.Warning]= CityCharacterWarningUI.new()
            self.ui_go[CityCharUI.UI.Warning]:bind(go)
            self.ui_go[CityCharUI.UI.Warning]:OnShow(self.warningViewParams)
        end)
    end

    self:RefreshRoofView()
end

--解绑显示
function CharacterController:UnBindView()
    if self.nodeInfo then
        self:UnBindNodeItem()
    end
    self:UnBindCharacterView()

    -- destroy 里销毁
end

--绑定角色显示
function CharacterController:BindCharacterView()
    --    self.characterView = ObjectPoolManager.GetCharacterView(self.cityId, self.info.gender, self.info.skinId)
    --    SetTransformParent(self.transform, self.characterView.gameObject.transform)
    --    self.nodeTransforms = {}
    --    for type, name in pairs(NodeType) do
    --        self.nodeTransforms[name] = GetTransformInChildren(self.characterView.gameObject, name)
    --    end
    --    self.moveAgent:SetAnimator(self.characterView.animator)
    --    if self.currAnimation then
    --        self.moveAgent:PlayAnimation(self.currAnimation)
    --    end
    --    self.characterView.animationAgent:AnimationCallBack(
    --        function(msg)
    --            self:SetNodeItem(msg)
    --        end
    --    )
end

--解绑解色显示
function CharacterController:UnBindCharacterView()
    --    if self.characterView then
    --        self.characterView.animationAgent:AnimationCallBack(nil)
    --        ObjectPoolManager.BackToPool(self.characterView)
    --        self.characterView = nil
    --    end
    self.nodeTransforms = nil
    --self.moveAgent:SetAnimator(nil)
end

--切换显示
function CharacterController:ChangeView(gender, skinId)
    self.info.gender = gender
    self.info.skinId = skinId
    DataManager.SaveCityData(self.cityId)
    self:UnBindCharacterView()
end

--角色消亡
function CharacterController:DeActive()
    self:UnBindView()
    -- self.moveAgent:StopMove()
    if nil ~= self.currGrid then
        self.currGrid:RemoveCapacity(self.id)
    end
    if nil ~= self.targetGrid then
        self.targetGrid:RemoveCapacity(self.id)
    end
    if nil ~= self.bedGrid then
        self.bedGrid:RemoveCapacity(self.id)
    end
    self.targetGrid = nil
    -- self.stateAgent:DeActive()
    self.schedulesAgent:DeActive()
    -- GameObject.Destroy(self.gameObject)
    self:destroy()
    -- ResourceManager.Destroy(self.gameObject)
end

------------------------------------------------------------------------------
---角色播放动画
------------------------------------------------------------------------------

--设置动画播放
function CharacterController:SetAnim(animation)
    self.pervAnimation = self.currAnimation
    self.currAnimation = animation
    self.transform.rotation = Vector3.zero
    self.movetype = 0
    if animation == AnimationType.SickSleep then --lesion  病变17
        --self.currAnimation ="sicksleep"
        self.currAnimation = "lesion"
    elseif animation == AnimationType.CarryFoodWalk then --eatwalk 端着行走吃饭6
        self.currAnimation = "eatwalk"
        self.movetype = 4
    elseif animation == AnimationType.Run then
        self.currAnimation = "run"
        self.movetype = 3

        if self:GetProfessionType() == ProfessionType.Chef then 
            if TutorialManager.IsComplete(TutorialStep.BuildSawmill) == true and TutorialManager.IsComplete(TutorialStep.BuildKitchen) == false then 
                -- 新手引导的厨娘要跑快些
                self.movetype = 15
            end
        end
    elseif animation == AnimationType.SickWalk then
        self.currAnimation = "lesionrun"
        self.movetype = 1
    elseif animation == AnimationType.Walk then
        self.currAnimation = "walk"
        self.movetype = 2
    elseif animation == AnimationType.CarryWalk then
        self.currAnimation = "walk"
        self.movetype = 2
    elseif animation == AnimationType.StrikeWalk then  -- 罢工行走14
        self.currAnimation = "sttrikemarch"
        self.movetype = 5
    elseif animation == AnimationType.Walk1 then  -- 牛腿行走19
        self.currAnimation = "walk1"
        self.movetype = 8
    elseif animation == AnimationType.Protest or animation == "protest2" then
        self.currAnimation = "strike"
    elseif animation == "sweep" then
        self.currAnimation = "sweep"
    elseif animation == "sleeping" then
        self.currAnimation = "sleeping"
    elseif animation == "eattingfood" then
        self.currAnimation = "cooking"
    elseif animation == "cooking" then
        self.currAnimation = "cook"
    elseif animation == "takeupsth" then -- eat端着吃饭5
        self.currAnimation = "eat"
    elseif animation == "hammerwork" then
        self.currAnimation = "hammerwork"
    elseif animation == "cutTree" then
        self.currAnimation = "cuttree"
    elseif animation == "speech" then
        self.currAnimation = "strike"
    elseif animation == "protest" then
        self.currAnimation = "strike"
    elseif animation == "speech" then
        self.currAnimation = "strike"
    elseif animation == "protest2" then
        self.currAnimation = "strike"
    elseif animation == "idle" then
        self.currAnimation = "idle"
    else
        --self:setStateEx(Actor.STAND)
        self.currAnimation = "hammerwork"
        --self:playAnim("idle")
    end
    -- if  self.schedulesAgent then
    --     local professionType = self:GetProfessionType()

    --     local schedulesType  = self.curSchedule --self:GetNextSchedules()
    --     if  self.currAnimation ~= "cook" and professionType == ProfessionType.Chef and schedulesType == SchedulesType.Cooking then
    --         self.currAnimation = "cook"
    --     elseif self.currAnimation ~= "hammerwork" and professionType == ProfessionType.Hunter and schedulesType == SchedulesType.Hunting then
    --         self.currAnimation = "hammerwork"     
    -- --    elseif professionType == ProfessionType.FreeMan then
    -- --        -- SchedulesType.None
    -- --    else
    -- --        -- SchedulesType.Arbeit
    --     end
      
    -- end

end
--角色播放FSM-idle动画
function CharacterController:SetPlayAniIdle()
    self:SetAnim(AnimationType.Idle)
    self:playAnim("idle",self._curDir)
end

--角色播放FSM-hw动画
function CharacterController:SetPlayAniHwork()
    self:SetAnim( "hammerwork" )
    self:playAnim( "hammerwork" ,self._curDir)
end

--角色播放动画
function CharacterController:PlayAnimEx(animation)
    self:SetAnim(animation)
    --self.transform.rotation = Vector3.zero;
    --self:playAnim(animation)
    if self.currAnimation == "sleeping" or self.currAnimation == "lesion" then
        --self:playAnim("bed",CityPosition.Dir.Right, false,function ()
        --          self:playAnim("walk",CityPosition.Dir.Right, false,function ()
        -- self:playAnim("sleeping",CityPosition.Dir.Right, true) --切回待机动作
        --            self:addAniEx("sicksleep",false)
        --        end)
        if self.currGrid.markerType == GridMarker.Bed or self.currGrid.markerType == GridMarker.MedicalBed then
            -- 设置睡觉的层级
            local zoneId = self.currGrid.zoneId
            local build = CityModule.getMainCtrl().buildDict[zoneId]
            local markerIndex = self.currGrid.markerIndex         -- 第几个床
            local index = self.currGrid:GetCapacityIndex(self.id) -- 上下床
            if index == 1 and self.currGrid.markerType == GridMarker.Bed then
                if build then
                    local bedFurn = build.transform:Find("Room/model_furniture_bed_" .. markerIndex)
                    if bedFurn then
                        -- local bedUp = bedFurn:Find("model_furniture_bed_up_"):GetComponent(typeof(SpriteRenderer))
                        -- local bedDown = bedFurn:Find("model_furniture_bed_down_"):GetComponent(typeof(SpriteRenderer))
                        -- bedDown.sortingOrder = 3021
                    else
                        self.meshRenderer.sortingOrder = 7999
                    end
                end
            else
                self.meshRenderer.sortingOrder = 7999
            end

            local curcell = self.cellTarget
            if curcell == nil then
                curcell = self.cell
            end
            local mapCtrl = CityModule.getMapCtrl()
            local ygrid = 0
            if self.currGrid.markerType == GridMarker.Bed and self.currGrid.markerIndex == 2 then
                ygrid = -3
            end
            if index > 1 then
               -- self:playAnim("walk", CityPosition.Dir.Right, false)
                TimeModule.addDelay(0.8, function()
                    if isNil(self.transform) == false then
                        local realpos2 = mapCtrl:calcRealPosition(curcell.position.x - 2, curcell.position.y + 2 + ygrid)
                        if self.currGrid.markerType == GridMarker.MedicalBed then
                            self.transform.position = Vector3.New(realpos2.x + 0.116, realpos2.y - 0.071, 0)
                        else
                            self.transform.position = Vector3.New(realpos2.x + 0.385, realpos2.y + 0.045, 0)
                        end
                        self:playAnim("sleeping", CityPosition.Dir.Right, true) --切回待机动作
                        --设置层级
                        --self:setSortingOrder(1000)
                    end
                end)
            else
                TimeModule.addDelay(0.4, function()
                    if isNil(self.transform) == false then
                        local realpos = mapCtrl:calcRealPosition(curcell.position.x, curcell.position.y + ygrid)
                        if self.currGrid.markerType == GridMarker.MedicalBed then
                            self.transform.position = Vector3.New(realpos.x + 0.116, realpos.y - 0.071, 0)
                            --                         elseif self.currAnimation =="lesion" and  self.currGrid.markerType == GridMarker.Bed then
                            --                                         self.transform.position = Vector3.New(realpos.x+0.12+0.8-0.544+0.539, realpos.y-0.15+0.249+0.426, 0)
                        else
                            self.transform.position = Vector3.New(realpos.x + 0.376, realpos.y + 0.099, 0)
                        end

                        --self.transform.position = Vector3.New(realpos.x+0.315+1.095+1.07-0.655+1.058+1.138, realpos.y-0.264+0.08, 0)
                        self:playAnim("sleeping", CityPosition.Dir.Right, true)
                    end
                end)
            end
        end
        --    elseif self.currAnimation =="lesion" then

        --        if self.currGrid.markerType == GridMarker.MedicalBed or self.currGrid.markerType == GridMarker.Bed then
        --             self:playAnim("lesion",CityPosition.Dir.Right, false,function ()
        --                 self:playAnim("sleeping",CityPosition.Dir.Right, true) --切回待机动作
        --              end)
        --        end
    elseif self.currAnimation == "strike" then
        --self.transform.rotation = Vector3.New(0, 0, 0)
        --self:playAnim("sttrikemarch",CityPosition.Dir.Right, false,function ()
        self:playAnim("strike", CityPosition.Dir.Right, true)   --切回待机动作
        -- end)
    elseif animation == "eattingfood" then
        self._curDir = self.currGrid.yIndex
        self:playAnim("cooking", self._curDir)
    else
       -- TimeModule.addDelay(0.2, function()
            if self.currGrid.markerType == GridMarker.Table then
                self._curDir = self.currGrid.yIndex
                self:playAnim(self.currAnimation, self._curDir)
            elseif self.currGrid.markerType == GridMarker.Hunt then
                self:playAnim(self.currAnimation, 1)
            else
                --self._curDir = self.currGrid.yIndex

                self:playAnim(self.currAnimation, self.currGrid.yIndex)
            end
      --  end)
        --self:playAnim(self.currAnimation)
    end
    --    if self.characterView then
    --        self.moveAgent:PlayAnimation(animation)
    --    end
end

-- 节点物品显示
function CharacterController:ShowNodeItem()
    self.nodeInfo = {}
    self.nodeInfo.zoneType = self.currGrid.zoneType
    self.nodeInfo.markerType = self.currGrid.markerType
    self.nodeInfo.furnitureId = self.currGrid.furnitureId
    self.nodeInfo.furnitureLevel = self.currGrid:GetFurnitureLevel()
end

-- 节点物品隐藏
function CharacterController:HideNodeItem()
    self:UnBindNodeItem()
    self.nodeInfo = nil
end

--添加节点物品
function CharacterController:CreateNodeItem(nodeType, assetsName, assetsLevel)
    if nil == self.nodeTransforms[nodeType] then
        return
    end
    -- local path = "prefab/character/tools/" .. assetsName .. "_Lv" .. assetsLevel
    -- local toolObj = ResourceManager.Instantiate(path, self.nodeTransforms[nodeType])
    -- self.toolInstances[nodeType] = toolObj
    -- self.toolItemNode = GetTransformInChildren(toolObj, "item_node")
end

--设置节点物品
function CharacterController:SetNodeItem(msg)
    if nil == self.toolItemNode then
        return
    end
    if msg == "Show" then
        self.toolItemNode.gameObject:SetActive(true)
    elseif msg == "Hide" then
        self.toolItemNode.gameObject:SetActive(false)
    end
end

--解绑节点信息
function CharacterController:UnBindNodeItem()
    for nodeType, go in pairs(self.toolInstances) do
        GameObject.Destroy(go)
    end
    self.toolInstances = {}
    self.toolItemNode = nil
end

--显示toast
function CharacterController:ShowListToast(msg, color, icon, sfxName, config)
    EventManager.Brocast(EventDefine.ShowMainUITip, msg, icon, false, 3)
    -- GameToastList.Instance:Show(msg, color, icon, sfxName, config)
end

--显示幸存者待机的tost
function CharacterController:ShowIdleToast()
    self:ShowListToast(
        GetLangFormat("toast_survivor_is_idle", GetLang(self.peopleConfig.people_name)),
        ToastListColor.Blue,
        ToastListIconType.ResourceLow,
        "ui_hint",
        { isRaw = true }
    )
end

--显示罢工toast
function CharacterController:ShowEventStrikeToast(eventStrike)
    local preToast = self.info.esToast
    if eventStrike < self.attributeAlertThreshold[AttributeType.EventStrike] then
        if self.info.esToast == nil or self.info.esToast then
            self:ShowListToast(
                GetLang("toast_people_not_satisfied"),
                ToastListColor.Yellow,
                ToastListIconType.RiotsWarning,
                "ui_hint"
            )
            self.info.esToast = false
        end
    elseif eventStrike >= self.attributeSafeLine[AttributeType.EventStrike] then
        if not self.info.esToast then
            self.info.esToast = true
        end
    end
    if preToast ~= self.info.esToast then
        DataManager.SaveCityData(self.cityId)
    end
end

function CharacterController:SetSpeed()
    local cityConfig = ConfigManager.GetCityById(self.cityId)
    self.speed = cityConfig.people_move_speed * TestManager.GetGameSpeed(self.cityId)
    -- self.moveAgent:SetSpeed(self.speed)
end

------------------------------------------------------------------------------
---角色属性
------------------------------------------------------------------------------
--获取角色编号
function CharacterController:GetSerialNumber()
    return self.info.serialNumber
end

--设置角色头像
function CharacterController:SetPeopleHead(imageComp)
    local gender = self.info.res_id == 60008 and "male" or "female"
    Utils.SetCharacterIcon(imageComp, self.cityId, gender) -- , self.info.skinId)
end

--设置角色职业
function CharacterController:SetProfessionType(professionType)
    local oldProfessionType = self.info.professionType
    self.info.professionType = professionType
    DataManager.SaveCityData(self.cityId)
    self:SetPeopleConfig()
    self:SetWorkStateResponse()
    EventManager.Brocast(EventType.CHARACTER_PROFESSION_CHANGE, self.cityId, professionType, oldProfessionType)
end

--设置职业配置
function CharacterController:SetPeopleConfig()
    self.peopleConfig = ConfigManager.GetPeopleConfigByType(self.cityId, self.info.professionType)
    if nil == self.peopleConfig and self.info.professionType ~= ProfessionType.FreeMan then
        self:SetProfessionType(ProfessionType.FreeMan)
        return
    end
    if nil == self.peopleConfig then
        print("[error]" .. debug.traceback())
    end
end

--角色职业类型
function CharacterController:GetProfessionType()
    return self.info.professionType
end

--获取职业名称
function CharacterController:GetProfessionName()
    return GetLang(self.peopleConfig.people_name)
end

------------------------------------------------------------------------------
---生病
------------------------------------------------------------------------------
--设置生病治愈
function CharacterController:SetHealZone(grid)
    if nil == self.info.sickInfo then
        return
    end
    if self.info.sickInfo.healZone == grid.zoneType then
        return
    end
    self.info.sickInfo.healZone = grid.zoneType
    --家具治愈了+疾病治愈率
    self.info.sickInfo.healRate = grid:GetRecoverReward() + ConfigManager.GetDiseaseCureRateFix(self:GetDiseaseId())
    DataManager.SaveCityData(self.cityId)
end

--设置生病救治
function CharacterController:SetHealStatus(b)
    self.healStatus = b
end

--获取生病救治状态
function CharacterController:GetHealStatus()
    return self.healStatus
end

--加少生病时间
function CharacterController:ReduceSickTime(time, isHeal, forceHeal)
    if self:GetState() ~= EnumState.Sick then
        return
    end
    if TutorialManager.CurrentStep.value == TutorialStep.CardInfirmary and TutorialManager.CurrentSubStep.value < 7 then
        return
    end
    local sickInfo = self.info.sickInfo
    sickInfo.sickTime = sickInfo.sickTime - time
    sickInfo.sickTimeStamp = TimeManager.GameTime()
   
    DataManager.SaveCityData(self.cityId)
    if sickInfo.sickTime <= 0 then
        if nil == sickInfo.healRate then
            sickInfo.healRate = self:GetHealRate()
        end
        if not forceHeal and math.random() > self:GetHealRate() then
            local param = {}
            param.from = "online"
            param.value = 1
            param.hasEnterHospital = self.info.sickInfo.healCount > 0
            param.totalPeople = CharacterManager.GetCharacterMaxCount(self.cityId)
            param.cause = "SickDead"
            Analytics.Event("PeopleDead", param)
            self:SetNextState(EnumState.Dead)
            self:SetNextSchedules()
        else
            local param = {}
            param.from = "online"
            param.value = 1
            param.hasEnterHospital = self.info.sickInfo.healCount > 0
            param.totalPeople = CharacterManager.GetCharacterMaxCount(self.cityId)
            Analytics.Event("PeopleHeal", param)
            self:SetNextState(EnumState.Normal)
            self:SetNextSchedules()
        end
    else
        self.warningViewParams.sickRx.value = self:GetSickProgress()
    end
end

--获取生病进度
function CharacterController:GetSickProgress()
    return 1 - self.info.sickInfo.sickTime / CharacterManager.GetDiseaseMedicalNeed(self.cityId, self:GetDiseaseId())
end

function CharacterController:GetSickHealProgress(healTime)
    return self:GetSickProgress() + healTime / CharacterManager.GetDiseaseMedicalNeed(self.cityId, self:GetDiseaseId())
end 

--是否说治疗区域
function CharacterController:IsHealZone(zoneType)
    if nil == self.info.sickInfo then
        return false
    end
    return self.info.sickInfo.healZone == zoneType
end

--获取疾病id
function CharacterController:GetDiseaseId()
    return self.info.sickInfo.diseaseId
end

--获取生病时间
function CharacterController:GetSickTime()
    if self.info.sickInfo == nil then
        return 0
    end
    return self.info.sickInfo.sickTime
end

--获取救治几率
function CharacterController:GetHealRate()
    return self.currGrid:GetRecoverReward() + ConfigManager.GetDiseaseCureRateFix(self:GetDiseaseId())
end

--添加治疗次数
function CharacterController:SetHealCount()
    if nil == self.info.sickInfo then
        return
    end
    self.info.sickInfo.healCount = self.info.sickInfo.healCount + 1
end

--获取救治次数
function CharacterController:GetHealCount()
    return self.info.sickInfo.healCount
end

--获取救治
function CharacterController:GetHealNecessities()
    return self.currGrid:GetNecessitiesRewardSick()
end

------------------------------------------------------------------------------
---状态机
------------------------------------------------------------------------------
--设置角色状态
function CharacterController:SetState(state)
    if self.info.state == state then
        return
    end
    --职业名称
    local peopleName = ""
    if nil ~= self.peopleConfig and self.peopleConfig.people_name ~= nil then
        peopleName = GetLang(self.peopleConfig.people_name)
    end
    if state == EnumState.Normal then
        if self.info.state == EnumState.Sick then --生病恢复
            self.info.sickInfo = nil
            self.info.attributeInfo[AttributeType.Hunger] = self.attributeStartValue[AttributeType.Hunger]
            self.info.attributeInfo[AttributeType.Rest] = self.attributeStartValue[AttributeType.Rest]
            --显示幸存者恢复健康toast
            Audio.PlayAudio(DefaultAudioID.Playerrecovered)
            self:ShowListToast(
                GetLangFormat("toast_survivor_recovered", peopleName),
                ToastListColor.Green,
                ToastListIconType.Heal,
                "amb_human_sick2alive",
                { isRaw = true }
            )
            -- 治愈动效
            if self.sickToNormal == nil then 
                self.sickToNormal = self.transform:Find("SickToNormal")
            end
            self.sickToNormal.gameObject:SetActive(true)
            self.sickToNormal:DOLocalMoveY(1.2, 0.8):SetEase(Ease.OutCubic):OnComplete(function()
                self.sickToNormal.localPosition = Vector3.New(-0.44, 0, 0)
                self.sickToNormal.gameObject:SetActive(false)
            end)
        end
    elseif state == EnumState.Severe then
        if nil == self.info.sickInfo then
            --获取生病影响属性类型
            local attributeType = nil
            local warm = self:GetAttribute(AttributeType.Warm)
            local hunger = self:GetAttribute(AttributeType.Hunger)
            local rest = self:GetAttribute(AttributeType.Rest)
            if warm < hunger then
                if warm < rest then
                    attributeType = AttributeType.Warm
                else
                    attributeType = AttributeType.Rest
                end
            elseif hunger < rest then
                attributeType = AttributeType.Hunger
            else
                attributeType = AttributeType.Rest
            end
            --设置生病信息
            local sickInfo = {}
            sickInfo.diseaseId = CharacterManager.GetDiseaseIdByAttributeType(self.cityId, attributeType)
            sickInfo.sickTime = CharacterManager.GetDiseaseMedicalNeed(self.cityId, sickInfo.diseaseId)
            sickInfo.sickTimeStamp = TimeManager.GameTime()
            sickInfo.healCount = 0
            self.info.sickInfo = sickInfo
            --toast
            CharacterManager.SendSickAnalytics(self.cityId)
        end
    elseif state == EnumState.Sick then
        --显示幸存者生病toast
        Audio.PlayAudio(DefaultAudioID.PlayerSick)
        self:ShowListToast(
            GetLangFormat("toast_survivor_is_sick", peopleName),
            ToastListColor.Red,
            ToastListIconType.HealthLow,
            "amb_human_sick",
            { isRaw = true }
        )
    elseif state == EnumState.Dead then
        if self.info.state == EnumState.Sick then
            self.info.sickInfo = nil
            self:SetMarkState(EnumMarkState.DeathFromSick)
            --显示幸存者病死toast
            Audio.PlayAudio(DefaultAudioID.PlayerDead)
            self:ShowListToast(
                GetLangFormat("toast_survivor_dead", peopleName),
                ToastListColor.Red,
                ToastListIconType.Dead,
                "amb_human_sick2dead",
                { isRaw = true }
            )
        else
            self:SetMarkState(EnumMarkState.DeathFromHunger)
            --显示幸存者饿死toast
            Audio.PlayAudio(DefaultAudioID.PlayerDead)
            self:ShowListToast(
                GetLangFormat("toast_survivor_dead_hunger", peopleName),
                ToastListColor.Red,
                ToastListIconType.Hunger,
                "amb_human_sick2dead",
                { isRaw = true }
            )
        end
    elseif state == EnumState.RunAway then
        --显示幸存者逃跑toast
        Audio.PlayAudio(DefaultAudioID.PlayerEscape)
        self:ShowListToast(
            GetLangFormat("toast_survivor_run", peopleName),
            ToastListColor.Red,
            ToastListIconType.RunAway,
            "amb_human_sick2dead",
            { isRaw = true }
        )
    elseif state == EnumState.EventStrike then
        --显示幸存者逃跑toast
        Audio.PlayAudio(DefaultAudioID.PlayerEscape)
        self:ShowListToast(
            GetLangFormat("toast_survivor_run", peopleName),
            ToastListColor.Red,
            ToastListIconType.RunAway,
            "amb_human_sick2dead",
            { isRaw = true }
        )
    end
    self.info.state = state
    EventManager.Brocast(EventType.CHARACTER_STATE_CHANGE, self.cityId, self, state)
    DataManager.SaveCityData(self.cityId)
end

--获取角色状态
function CharacterController:GetState()
    return self.info.state
end

--是否健康
function CharacterController:IsHealth()
    return self:GetState() == EnumState.Normal
end

--切换下一个状态
function CharacterController:SetNextState(state)
    self:SetState(state)
    self.stateRunTime = 0
    -- self.stateAgent:SetNextState(state)
    self:SetWaringViewState(state)
    self:SetWorkStateResponse()
end

function CharacterController:DebugScheduleName(scheduleName)
    self.moveAgent:SetSchedulesName(scheduleName)
end

function CharacterController:JudgeSchedulesActive(type)
    if self:GetSchedulesStatus(type) == SchedulesStatus.Stop then
        return false
    end
    if not self:IsHealth() then
        return false
    end
    local schedules = SchedulesManager.GetActiveSchedules(self.cityId, type)
    if not schedules then
        return false
    end
    if not schedules.IsMatchProfession(self:GetProfessionType()) then
        return false
    end
    if schedules.is_overtime then
        return WorkOverTimeManager.IsCanWorkOverTimeByZoneType(self.cityId, self.peopleConfig.zone_type)
    else
        return true
    end
end

--获取下一个日程
function CharacterController:GetNextSchedules()
    local state = self:GetState()
    -- if GameManager.isDebug then
    --     self:DebugScheduleName(tostring(state))
    -- end
    if not self:IsHealth() then
        if state == EnumState.HealthLow then
            self:SetNextState(EnumState.Severe)
            state = EnumState.Severe
        end
        self.curSchedule = state
        return state
    else
        local schedulesList = SchedulesManager.GetCurrentSchedules(self.cityId)
        for i = 1, schedulesList:Count(), 1 do
            local schedulesType = schedulesList[i].type
            if self:JudgeSchedulesActive(schedulesType) then
                self.curSchedule  =schedulesType
                return schedulesType
            elseif schedulesType == SchedulesType.Eat then
                if not TimeManager.GetCityIsNight(self.cityId) then
                    local professionType = self:GetProfessionType()
                    if professionType == ProfessionType.Chef then
                        self.curSchedule  =SchedulesType.Cooking
                        return SchedulesType.Cooking
                    elseif professionType == ProfessionType.Hunter then
                        self.curSchedule  =SchedulesType.Hunter
                        return SchedulesType.Hunting
                    elseif professionType == ProfessionType.FreeMan then
                        self.curSchedule  =SchedulesType.FreeMan
                        return SchedulesType.None
                    else
                        self.curSchedule  =SchedulesType.Arbeit
                        return SchedulesType.Arbeit
                    end
                elseif WorkOverTimeManager.IsActiveWorkOverTimeByZoneType(self.cityId, self.peopleConfig.zone_type) then
                    self.curSchedule  =SchedulesType.Arbeit_OverTime
                    return SchedulesType.Arbeit_OverTime
                end
            end
        end
        self.curSchedule = SchedulesType.None
        return SchedulesType.None
    end
end

--设置下一个日程
function CharacterController:SetNextSchedules()
    self.schedulesAgent:SetNextSchedules()
end

--移除日程
function CharacterController:RemoveSchedulesFunc(schedules)
    self.schedulesStatus[schedules.type] = nil
end

--设置日程状态
function CharacterController:SetSchedulesStatus(type, status)
    if SchedulesManager.IsSchdulesActive(self.cityId, type) then
        self.schedulesStatus[type] = status
    end
end

--获取日程状态
function CharacterController:GetSchedulesStatus(type)
    return self.schedulesStatus[type]
end

--获取日程工作工具点
function CharacterController:GetArbeitToolGrid()
    if self.currGrid.furnitureId == self.peopleConfig.furniture_id then
        if self.currGrid:IsFurnitureCanWork() then
            return self.currGrid
        end
    end
    local furnitureCfg = ConfigManager.GetFurnitureById(self.peopleConfig.furniture_id)
    if furnitureCfg == nil then
        return nil
    end
    local grids = GridManager.GetGridsByMarkerType(self.cityId, furnitureCfg.furniture_type, furnitureCfg.zone_type)
    grids:Sort(Utils.SortGridByAscendingUseMarkerIndex)
    for i = 1, grids:Count(), 1 do
        if grids[i]:IsFurnitureCanWork() then
            return grids[i]
        end
    end
    return nil
end

function CharacterController:ResetArbeitGrid()
    local grid = self:GetArbeitToolGrid()
    ---@type Grid
    self.arbeitGrid = grid
end

--更改工作点图标
function CharacterController:SetArbeitIconView(icon)
    
end

function CharacterController:UpdateArbeitGridView(enterProduct)
    if self.currGrid == nil then
        return
    end

    if self.info.professionType == ProfessionType.FreeMan then
        self.currGrid:UpdateProductView(false, ArbeitStateType.CannotWork, nil)
    else
        local debuff = nil
        if enterProduct then
            local t1, t2 = self:GetWarningAttribute(true, { AttributeType.Warm })
            debuff = {
                t1 = t1,
                t2 = t2
            }
        end
        self.currGrid:UpdateProductView(true, ArbeitStateType.Work, debuff)
    end
end

------------------------------------------------------------------------------
---标记状态
------------------------------------------------------------------------------
--设置标记状态
function CharacterController:SetMarkState(state)
    self.info.markState = state
    self:SetWarningViewMark(state)
end

--获取标记状态
function CharacterController:GetMarkState()
    return self.info.markState
end

------------------------------------------------------------------------------
---工作状态
------------------------------------------------------------------------------
--设置角色工作状态
function CharacterController:SetWorkState(state)
    if self.workState == state then
        return
    end
    self.workState = state
    self:SetWorkStateResponse()
end

--获取角色工作状态
function CharacterController:GetWorkState()
    return self.workState
end

--设置工作状态响应
function CharacterController:SetWorkStateResponse()
    EventManager.Brocast(EventType.WORK_STATE_CHANGE, self.cityId)
end

------------------------------------------------------------------------------
---角色属性
------------------------------------------------------------------------------
--获取角色属性
function CharacterController:GetAttribute(type)
    if type == AttributeType.Security then
        return CharacterManager.GetAttributeValue(self.cityId, AttributeType.Security)
    elseif type == AttributeType.Hope then
        if TestManager.IsLockHope(self.cityId) then
            return TestManager.GetLockHope(self.cityId)
        else
            return DataManager.GetCityDataByKey(self.cityId, DataKey.Hope)
        end
    elseif type == AttributeType.Warm then
        return CharacterManager.GetAttributeValue(self.cityId, AttributeType.Warm)
    elseif type == AttributeType.SurfaceTemperature then
        return CharacterManager.GetAttributeValue(self.cityId, AttributeType.SurfaceTemperature)
    elseif self.info.attributeInfo[type] then
        return self.info.attributeInfo[type]
    elseif self.attributeInfo[type] then
        return self.attributeInfo[type]
    else
        return 0
    end
end

--设置角色属性
function CharacterController:SetAttribute(type, value)
    if self.info.attributeInfo[type] then
        self.info.attributeInfo[type] = value
    else
        self.attributeInfo[type] = value
    end
end

--添加属性
function CharacterController:AddAttribute(type, value)
    if not self.info.attributeInfo[type] then
        return
    end
    self.info.attributeInfo[type] = self.info.attributeInfo[type] + value
    if self.info.attributeInfo[type] > self.attributeMaxValue[type] then
        self.info.attributeInfo[type] = self.attributeMaxValue[type]
    elseif self.info.attributeInfo[type] < 0 then
        self.info.attributeInfo[type] = 0
    end
end

-- 加满属性
function CharacterController:AddMaxAttribute(type)
    if type == AttributeType.Hunger or type == AttributeType.Rest then 
        local value = self.attributeMaxValue[type] or 10000
        self:AddAttribute(type, value)
    end
end

--属性每一秒衰减
function CharacterController:AttributeDeltaPerSecond(type)
    if not self.info.attributeInfo[type] then
        return
    end
    local deltaFactor = self.currGrid:GetAttributeDeltaFactor(type)
    local isOverTime = self:JudgeSchedulesActive(SchedulesType.Arbeit_OverTime)
    local deltaSpeed = BoostManager.GetNessitiesBoostFactor(self.cityId, type, isOverTime)
    local gameSpeed = TestManager.GetGameSpeed(self.cityId)
    local deltaValue = self.attrobuteDeltaPerSecond[type] * deltaFactor * deltaSpeed * gameSpeed

    self.info.attributeInfo[type] = Utils.GetPreciseDecimal(self.info.attributeInfo[type] - deltaValue, 3)
    if self.info.attributeInfo[type] < 0 then
        self.info.attributeInfo[type] = 0
    elseif self.info.attributeInfo[type] > self.attributeMaxValue[type] then
        self.info.attributeInfo[type] = self.attributeMaxValue[type]
    end
end

function CharacterController:GetAttributeProgress(type)
    return self:GetAttribute(type) / self.attributeMaxValue[type]
end

--设置属性Boost
function CharacterController:SetAttributeBoost(attributeType, value)
    if self.attributeBoost[attributeType] == value then
        return
    end
    self.attributeBoost[attributeType] = value
    local ret = 1
    for type, value in pairs(self.attributeBoost) do
        ret = ret + value
    end
    self.attributeBoostValue = ret
end

function CharacterController:GetAttributeBoost(attributeType)
    return self.attributeBoost[attributeType] or 0
end

------------------------------------------------------------------------------
---显示
------------------------------------------------------------------------------
function CharacterController:GetHeadPoint()
    return self.gameObject.transform.position + self.currGrid:GetViewOffset(self.id) + Vector3(0, 3.8, 0)
end

function CharacterController:RefreshRoofView()
    local mainCtrl = CityModule.getMainCtrl()
    self.isShowWarning = mainCtrl.camera and (not mainCtrl.camera:getRoofActive()) or false
    self:SetWaringViewShow()
end

function CharacterController:OpenWaringView(isOpen)
    self.isOpenWarning = isOpen
    self:SetWaringViewShow()
end


function CharacterController:SetWaringViewShow()
    local isShow = self.isShowWarning and self.isOpenWarning
    if self.warningViewParams.showRx.value ~= isShow then
        self.warningViewParams.showRx.value = isShow
    end
end

function CharacterController:SetWaringViewState(state)
    local index = Utils.GetSelectIndexByEnumState(state)
    if index ~= self.warningViewParams.stateRx.value then
        self.warningViewParams.stateRx.value = index
    end
end

function CharacterController:SetWaringViewAttribute(attributeType)
    local value = Utils.GetSelectIndexByAttributeType(attributeType) or -1
    if self.warningViewParams.attributeRx.value ~= value then
        self.warningViewParams.attributeRx.value = value
        EventManager.Brocast(EventType.CHARACTER_ATTRIBUTE_WARNING, self.cityId)
    end
end

function CharacterController:SetWarningViewMark(markState)
    if self.warningViewParams.markRx.value ~= markState then
        self.warningViewParams.markRx.value = markState
    end
end

function CharacterController:SetWarningViewWarmRise(from, to)
    self.warningViewParams.warmFromRx.value = from
    self.warningViewParams.warmToRx.value = to
    if self.warningViewParams.warmShowRx.value ~= true then
        self.warningViewParams.warmShowRx.value = true
    end
end

function CharacterController:GetWarningAttribute(moreAttributes, excludeTypes)
    local t1 = nil
    local t2 = nil
    excludeTypes = excludeTypes or {}
    if CityManager.GetIsEventScene(self.cityId) then
        t1 = self:CheckWarningAttribute(WarningEventSceneAttributes, excludeTypes)
        if moreAttributes and t1 ~= nil then
            table.insert(excludeTypes, t1)
            t2 = self:CheckWarningAttribute(WarningEventSceneAttributes, excludeTypes)
        end
    else
        t1 = self:CheckWarningAttribute(WarningMainSceneAttributes, excludeTypes)
        if moreAttributes and t1 ~= nil then
            table.insert(excludeTypes, t1)
            t2 = self:CheckWarningAttribute(WarningMainSceneAttributes, excludeTypes)
        end
    end

    --return AttributeType.Hunger, AttributeType.Rest
    return t1, t2
end

function CharacterController:CheckWarningView()
    local t1 = self:GetWarningAttribute()
    self:SetWaringViewAttribute(t1)
end

--遍历查找预警属性
function CharacterController:CheckWarningAttribute(attributes, excludeTypes)
    local tempType = nil
    local tempValue = 999999999
    for index, type in pairs(attributes) do
        local exclude = false
        for i, v in ipairs(excludeTypes) do
            if v == type then
                exclude = true
                break
            end
        end

        if not exclude then
            local value = self:GetAttribute(type)
            if value < self.attributeSafeLine[type] then
                if tempValue > value then
                    tempType = type
                    tempValue = value
                end
            end
        end
    end
    return tempType
end

-----------------------------------------
--日程显示展示
-----------------------------------------
--显示交互显示处理数据
function CharacterController:ShowNecessities(necessitiesReward, showLog)
    --数据
    self.necessitiesInfos = {}
    self.tempChangeProgress = 0
    -- self.showCount = 0
    local function InitNecessitiesInfos(reward)
        for type, count in pairs(reward) do
            if showLog then
            end
            if not self.necessitiesInfos[type] then
                local info = {} --数据
                info.currentValue = self:GetAttribute(type)
                -- info.addValue = 0
                info.totalValue = count
                self.necessitiesInfos[type] = info
            else
                self.necessitiesInfos[type].totalValue = self.necessitiesInfos[type].totalValue + count
            end
        end
    end
    if necessitiesReward then
        InitNecessitiesInfos(necessitiesReward)
    end
    InitNecessitiesInfos(self.currGrid:GetNecessitiesReward())
    --显示
    local viewParams = {}
    for type, info in pairs(self.necessitiesInfos) do
        viewParams[type] = self:GetAttributeProgress(type)
    end
    self:ShowView(self.id, ViewType.Slider, viewParams)
end

--刷新交互显示
function CharacterController:UpdateNecessities(changeProgress)
    if nil == changeProgress then
        print("[error]" .. debug.traceback())
        return
    end
    for type, info in pairs(self.necessitiesInfos) do
        local count = info.totalValue * changeProgress
        self:AddAttribute(type, count)
        -- info.addValue = info.addValue + count
    end
    self:CheckWarningView()

    self.tempChangeProgress = self.tempChangeProgress + changeProgress
    if self.tempChangeProgress < 0.1 then
        return
    end
    self.tempChangeProgress = self.tempChangeProgress - 0.1
    -- self.showCount = self.showCount + 1
    -- if self.id == "1659543749" then
    -- end
    local viewParams = {}
    for type, info in pairs(self.necessitiesInfos) do
        viewParams[type] = self:GetAttributeProgress(type)
    end
    self:UpdateView(self.id, ViewType.Slider, viewParams)
end

--关闭交互显示
function CharacterController:HideNecessities(isCooking, showLog)
    self:HideView(self.id, isCooking, showLog)
    self.necessitiesInfos = nil
end

function CharacterController:GetInstanceId(viewId)
    viewId = viewId or ""
    return self.currGrid.id .. "_" .. viewId
end

function CharacterController:ShowView(viewId, viewType, viewParams)
    if viewType == ViewType.Slider then
        self:ShowSlider(viewParams)
    elseif viewType == ViewType.Progress then
        self:ShowProgress(viewParams)
    elseif viewType == ViewType.Tips then
        self:ShowTips(viewParams)
    end
end

function CharacterController:ShowSlider(param)
    local isOffset = false
    if self:GetNextSchedules() == SchedulesType.Sleep then
        -- local markerIndex = self.currGrid.markerIndex         -- 第几个床
        local index = self.currGrid:GetCapacityIndex(self.id) -- 上下床
        isOffset = index == 1
    end

    if self.ui_load_statue[CityCharUI.UI.Slider] == LoadStatue.None and self.ui_go[CityCharUI.UI.Slider] == nil then
        self.ui_load_statue[CityCharUI.UI.Slider] = LoadStatue.Loading
        CityCharUI.CreateFollowUI(CityCharUI.UI.Slider, self.transform, function(go)
            self.ui_load_statue[CityCharUI.UI.Slider] = LoadStatue.Loaded
            self.ui_go[CityCharUI.UI.Slider] = CityCharacterSlider.new()
            self.ui_go[CityCharUI.UI.Slider]:bind(go)
            self.ui_go[CityCharUI.UI.Slider]:ShowView(param, isOffset)
        end)
    else
        if self.ui_go[CityCharUI.UI.Slider] ~= nil then 
            self.ui_go[CityCharUI.UI.Slider]:ShowView(param, isOffset)
        end
    end
end

function CharacterController:ShowProgress(param)
    if self.ui_load_statue[CityCharUI.UI.Progress] == LoadStatue.None and self.ui_go[CityCharUI.UI.Progress] == nil then
        self.ui_load_statue[CityCharUI.UI.Progress] = LoadStatue.Loading
        CityCharUI.CreateFollowUI(CityCharUI.UI.Progress, self.transform, function(go)
            self.ui_load_statue[CityCharUI.UI.Progress] = LoadStatue.Loaded
            self.ui_go[CityCharUI.UI.Progress] = CityCharacterProgress.new()
            self.ui_go[CityCharUI.UI.Progress]:bind(go)
            self.ui_go[CityCharUI.UI.Progress]:ShowView(param)
        end)
    else 
        if self.ui_go[CityCharUI.UI.Progress] ~= nil then 
            self.ui_go[CityCharUI.UI.Progress]:ShowView(param)
        end
    end
end

-- 显示产出飘字
function CharacterController:ShowTips(param)
    if self.ui_load_statue[CityCharUI.UI.Tips] == LoadStatue.None and self.ui_go[CityCharUI.UI.Tips] == nil then
        self.ui_load_statue[CityCharUI.UI.Tips] = LoadStatue.Loading
        CityCharUI.CreateFollowUI(CityCharUI.UI.Tips, self.transform, function(go)
            self.ui_load_statue[CityCharUI.UI.Tips] = LoadStatue.Loaded
            self.ui_go[CityCharUI.UI.Tips] = CityCharacterTips.new()
            self.ui_go[CityCharUI.UI.Tips]:bind(go)
            self.ui_go[CityCharUI.UI.Tips]:ShowView(param)
        end)
    else 
        if self.ui_go[CityCharUI.UI.Tips] ~= nil then 
            self.ui_go[CityCharUI.UI.Tips]:ShowView(param)
        end
    end
end

function CharacterController:UpdateView(viewId, viewType, viewParams)
    self:ShowView(viewId, viewType, viewParams)
end

--日程显示隐藏
function CharacterController:HideView(viewId, isCooking, showLog)
    local baseHeart, realHeart = MapManager.GetHeartProductCount(self.cityId, self.currGrid.furnitureId)
    if baseHeart > 0 then
       -- EventSceneManager.AddHeart(baseHeart, realHeart, "Production", self.currGrid.furnitureId)
    end

    if self.ui_go[CityCharUI.UI.Progress] ~= nil then
        self.ui_go[CityCharUI.UI.Progress]:HideView()
    end

    if self.ui_go[CityCharUI.UI.Slider] ~= nil then
        self.ui_go[CityCharUI.UI.Slider]:HideView()
    end
    --展示
    local viewParams = List:New()
    if self.necessitiesInfos then
        for type, data in pairs(self.necessitiesInfos) do
            local addValue = 0
            if self:GetAttribute(type) == ConfigManager.GetNecessitiesMaxValue(self.cityId, type) then
                addValue = self:GetAttribute(type) - data.currentValue
            else
                addValue = data.totalValue
            end
            if showLog then
            end
            if addValue > 0 then
                local info = {}
                info.type = type
                info.iconFun = Utils.SetIcon
                info.iconParams = string.format("icon_%s", type)
                info.selectIndex = Utils.GetSelectIndexByAttributeType(type)
                info.value = addValue
                viewParams:Add(info)
            end
        end
    end
    if isCooking then
        local info = {}
        info.type = FoodSystemManager.GetViewFoodType(self.cityId)
        info.iconFun = Utils.SetItemIcon
        info.iconParams = info.type
        info.selectIndex = 3
        info.value = 1
        viewParams:Add(info)
    end
    --爱心显示
    if realHeart > 0 then
        local info = {}
        info.type = ItemType.Heart
        info.iconFun = Utils.SetItemIcon
        info.sprite = ConfigManager.GetEventHeartItemId(self.cityId)
        info.selectIndex = 3
        info.value = realHeart
        viewParams:Add(info)
    end
    if viewParams:Count() > 0 then
        self:ShowView("Tips_%s" .. self.id, ViewType.Tips, viewParams)
    end
end

------------------------------------------------------------------------------
---角色变动信息
------------------------------------------------------------------------------
--切换角色床位格子
function CharacterController:ChangeBedGrid(nextGrid)
    if not nextGrid then
        return
    end
    if self.bedGrid then
        self.bedGrid:RemoveCapacity(self.id)
    end
    self.bedGrid = nextGrid
    self.bedGrid:AddCapacity(self.id)
end

-- 切换角色网格
function CharacterController:ChangeCurrGrid(nextGrid, forceRefresh)
    if not nextGrid then
        return
    end
    if self.currGrid then
        if self.currGrid.markerType ~= GridMarker.Bed then
            self.currGrid:RemoveCapacity(self.id)
        end
    end
    self.currGrid = nextGrid
    self.currGrid:AddCapacity(self.id)
    if forceRefresh then
        self:SetPositionByGrid(self.currGrid)
    end
    FunctionHandles.SetEntityForward(self)
end

--切换队列网格
function CharacterController:ChangeTargeGrid(nextGrid)
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

--根据格子设置角色位置
function CharacterController:SetPositionByGrid(grid)
    if nil == grid then
        return
    end
    --local pos0 =self.cell.position
    local mapCtrl = CityModule.getMapCtrl()
    local tarCell = mapCtrl:getCellByXY(grid.xIndex, grid.zIndex)
    self:setCell(tarCell)
    --local position, eulerAngles = grid:GetAnimationInfo(self.id)

    -- self.transform.position = position
    -- if eulerAngles then
    --     self.transform.eulerAngles = eulerAngles
    -- end
end

--根据路线移动
function CharacterController:MoveToGrid(targetGrid, speedPercent, animation, completeFunc)
    if nil == targetGrid then
        print("[Error] targetGrid is nil", debug.traceback())
        return
    end

    --在移动中并且目标点相同不进入
    if self.isMoveRunning then
        if self.targetGrid.id == targetGrid.id then
            return
        end
    end

    self:ChangeTargeGrid(targetGrid)
    self.isMoveRunning = true

    local moveAniamtion = nil
    if animation then
        moveAniamtion = animation
    else
        local state = self:GetState()
        if state == EnumState.Normal then
            if self.speed * speedPercent > self.speedStartRun then
                moveAniamtion = AnimationType.Run
                self.movetype = 3
            else
                moveAniamtion = AnimationType.Walk
                self.movetype = 2
            end
            --self:SetAnim(moveAniamtion)
        elseif state == EnumState.Protest or state == EnumState.Celebrate or state == EnumState.EventStrike then
            moveAniamtion = "sttrikemarch" --AnimationType.Walk
            self.movetype = 5
        elseif state == EnumState.RunAway then
            moveAniamtion = AnimationType.Run
            self.movetype = 3

        else
            moveAniamtion = AnimationType.SickWalk
            self.movetype = 1
        end
    end

    


    --self:SetAnim(moveAniamtion)

    --移动刷新角色位置网格
    local function OnMoveUpdate(x, z)
        --local tempGridId = GridManager.PositionToGridId(self.cityId, position)
        local tempGridId = Utils.PositionToGridId(x, 0, z)
        if tempGridId ~= self.currGrid.id then
            local nextGrid = GridManager.GetGridById(self.cityId, tempGridId)
            if nextGrid then
                if self.currGrid.markerType ~= GridMarker.Bed then
                    self.currGrid:RemoveCapacity(self.id)
                end
                self.currGrid = nextGrid
            end
        end
    end
    --移动完成
    local function OnMoveComplete()
        -- if self.currGrid.markerType == GridMarker.Idle or self.currGrid.markerType == GridMarker.None 
        --  or self.currGrid.markerType == GridMarker.Tool2ForDorm or self.currGrid.markerType == GridMarker.Tool3ForDorm 
        --  or self.currGrid.markerType == GridMarker.Tool4ForDorm or self.currGrid.markerType == GridMarker.Tool5ForDorm 
        --  or self.currGrid.markerType == GridMarker.Tool6ForDorm then
        --     self:SetAnim(AnimationType.Idle)
        --     self:playAnim("idle")
        -- end

        self:ChangeCurrGrid(self.targetGrid)
        if self.isMoveRunning then
            self.isMoveRunning = false
        end
        --
        -- self:playAnim("walk",self._curDir, false,function ()
        --     self:SetAnim(AnimationType.Idle)
        --     self:playAnim("idle",self._curDir, true) --切回待机动作

        -- end)

        if completeFunc then
            completeFunc()
        end
    end

    -- if TestManager.GetTest(self.cityId).moveTeleport.value then
    --     self:SetPositionByGrid(self.targetGrid)
    --     self:PlayAnimEx(AnimationType.Idle)
    --     OnMoveComplete()
    -- else
    --移动
    if self.cityId == 1 and TutorialManager.CurrentStep.value < 4  and moveAniamtion == AnimationType.Walk then
        moveAniamtion = AnimationType.Run       
        self:SetAnim(moveAniamtion)
        self.movetype = 3 --33
        --print("...RUN.TutorialManager.CurrentStep.value < 4...",TutorialManager.CurrentStep.value)
        
    else
        self:SetAnim(moveAniamtion)
    end
  


    self:playerMoveTo(targetGrid.xIndex, targetGrid.zIndex, 1, OnMoveUpdate, OnMoveComplete)

    -- end
end

function CharacterController:playerMoveTo(x, y, radio, updatefunc, completefunc)
    local mapCtrl = CityModule.getMapCtrl()
    local goal = mapCtrl:getCellByXY(x, y)
    self:setTargetCell(goal)
    local index = self.currGrid:GetCapacityIndex(self.id)
    self._mvTargets = {}

    local stop = function(message)
        if message ~= nil and Application.isEditor then 
            print(message)
        end
        self:SetAnim(AnimationType.Idle)
        self:playAnim("idle")
        self.movetype = 0
        self.isMoveRunning = false
    end

    if x == self.cell.position.x and y == self.cell.position.y then 
        stop()
        if completefunc then 
            completefunc()
        end
        return
    end

    local markerIndex = -1
    local schedule = self:GetNextSchedules()
    local serialNumber = (schedule == SchedulesType.Cooking) and 2 or 1
    local path = mapCtrl:findPath(self.cell, self.cellTarget, markerIndex, serialNumber) --self.cell
    if path == nil then
        local curGrid = Utils.GetGridByCell(self.cell)
        local targetGrid = Utils.GetGridByCell(self.cellTarget)
        local msg = string.format("form %s(%s, %s) to %s(%s, %s)", (curGrid and (curGrid.zoneId or curGrid.zoneType or "") or ""), self.cell.position.x, self.cell.position.y, (targetGrid and (targetGrid.zoneId or "") or ""), x, y)
        stop("[Error] Path is nil, city = " .. self.cityId .. ", " .. msg)
        return
    end

    self.movecompletefunc = completefunc
    self.moveupdatefunc = updatefunc
    self:move(path) --移动
end

--是否处于移动中
function CharacterController:MoveIsRunning()
    return self.isMoveRunning
end

--停止移动
function CharacterController:StopMove()
    self.isMoveRunning = false

    self:SetAnim(AnimationType.Idle)
    self:playAnim("idle")
    -- self.moveAgent:StopMove()
end

function CharacterController:UpdateGrid(zoneId, zoneType, level)
    if self.bedGrid.zoneId == zoneId then
        local grid =
            GridManager.GetGridByZoneId(
                self.cityId,
                self.bedGrid.zoneId,
                self.bedGrid.markerType,
                self.bedGrid.markerIndex,
                self.bedGrid.serialNumber
            )
        if grid then
            self:ChangeBedGrid(grid)
        end
    end
    FunctionHandles.UpdateGrid(self, zoneId)
end

function CharacterController:PlayCelebrateEffect()
    -- if not self.celebrateEffect then
    --     self.celebrateEffect =
    --         ResourceManager.Instantiate("prefab/enviroment/effect/effect_zhuansheng_qingzhu", self.transform)
    --     --self.celebrateEffect = CS.FrozenCity.SpriteAPI.CreateSkillFX("effect_jiban_soldier")
    --     --self.celebrateEffect.transform:SetParent(self.transform, false)
    --     self.celebrateEffect.transform.localPosition = Vector3(0, 0, 0)
    --     --self.celebrateEffect = ResourceManager.Instantiate("prefab/animation/effect_jianzao_over", self.transform)
    -- end
end

------------------------------------------------------------------------------
---刷新
------------------------------------------------------------------------------
--刷新
function CharacterController:Update()
    if Time.time > 1 then
        GameManager.LoadStart =false
    end 
    
    if  GameManager.LoadStart then
        return 
    end
    if not self.isActive then
        return
    end
 
    self.stateRunTime = self.stateRunTime + TimerFunction.deltaTime

   -- print("CharacterController:Update()-deltaTime" .. TimerFunction.deltaTime .. ",stateRunTime" .. self.stateRunTime)
    if self.stateRunTime >= 1 then
        self.stateRunTime = self.stateRunTime - 1
        local handleFunc = FunctionHandles.StatePreSecondFunc[self:GetState()]
        if handleFunc then
            handleFunc(self)
        end
    end

    if self.schedulesAgent then
        self.schedulesAgent:Update()
    end

    self:updateEx()
end

---瞬移至某个地块
function CharacterController:transferTo(x, y)
    local tarCell = CityModule.getMapCtrl():getCell(x, y)
    self:setPlayerCell(tarCell)
    self.transform.position = tarCell:getPlayerStandPostion()
end

-- 计算人物朝向
---@param cell City.MapCell 当前格子
---@param target City.MapCell 目标格子
function CharacterController:calcPlayerDir(cell, target)
    -- 当前格子的逻辑坐标
    local curPos = cell.position
    -- 计算出人物移动方向
    local posDir = (target.position - curPos):normalize()
    -- local isAdjacent = StageModule.getMapCtrl():isAdjacentCell(cell, target)
    -- if not isAdjacent then
    --     -- 不是相邻格
    --     posDir = self._curDir
    -- end
    if target.transform.position.y >= cell.transform.position.y then
        if target.transform.position.x >= cell.transform.position.x then
            posDir = CityPosition.Up
        else
            posDir = CityPosition.Left
        end
    else
        if target.transform.position.x >= cell.transform.position.x then
            posDir = CityPosition.Right
        else
            posDir = CityPosition.Down
        end
    end

    return posDir
end

function CharacterController:setPlayerCell(cell)
    self.cell = cell
    self:setSortingOrder(cell:getSortingOrder() + 1)
end

function CharacterController:setTargetCell(cell)
    self.cellTarget = cell
end

function CharacterController:MoveToCell(cell, moveTime, callback)
    local dir = self:calcPlayerDir(self.cell, cell)
    local _moveSeq = DOTween.Sequence() -- 人物动画

    -- 播放骨骼动画
    _moveSeq:AppendCallback(function()
        self:playAnim(StagePlayerAnim.Run, dir)
    end)

    -- 坐标移动
    local mvTw = self.transform:DOMove(cell.transform.position, moveTime):SetEase(Ease.Linear)
    _moveSeq:Append(mvTw)

    -- 移动完成
    _moveSeq:OnComplete(function()
        self:setPlayerCell(cell)
        if callback then
            callback()
        end
    end)
end

---显示名字
function CharacterController:showName()
    if self.transform then
        local textCanvas = self.transform:Find("TextCanvas")
        local nameTxt = self.transform:Find("TextCanvas/Name"):GetComponent("Text")
        local stateTxt = self.transform:Find("TextCanvas/State"):GetComponent("Text")
        textCanvas.gameObject:SetActive(true)
        if nameTxt then
            --nameTxt.text = self.id .. "(" ..  self.cell.position.x .. "," .. self.cell.position.y .. ")" .. self.bCanMove
            --nameTxt.text = self.id .. "(" ..  self.cell.realpos.x .. "," .. self.cell.realpos.y .. ")" .. self.currAnimation
            --  local index = self.currGrid:GetCapacityIndex(self.id)
            -- nameTxt.text = self.id .. self.currAnimation .. index
            -- nameTxt.text = self.id .. ", " .. self.currAnimation .. ", " ..  self:GetNextSchedules() .. ", " ..  self:GetProfessionType() .. ", " .. self:GetState()
            local curFSMStateId = "None"
            if self.schedulesAgent and self.schedulesAgent.currFsmSystem then 
                if self.schedulesAgent.currFsmSystem.currentState then 
                    curFSMStateId = self.schedulesAgent.currFsmSystem.__cname .. "_" .. self.schedulesAgent.currFsmSystem.currentState.__cname .. "_" .. (self.schedulesAgent.currFsmSystem.currentState.stateId or "nil")
                end
            end

            local stateStage = self.schedulesAgent.currFsmSystem.currentState.inState and "Process" or "Complete"
            
            -- nameTxt.text = self.id .. " + " .. curFSMStateId ..  " + " .. self.currGrid.markerType .. " + " .. stateStage ..
                -- " + " .. (self:MoveIsRunning() and "true" or "false") .. " + " .. ((self.currGrid == self.targetGrid) and "true" or "false")

            -- nameTxt.text = self.id .. " + " .. curFSMStateId .. " + " .. self:GetNextSchedules() .. " + " .. (self.isMoveRunning and "Moving" or "stay")

            nameTxt.text = self.id .. " + " .. curFSMStateId
        end
        if stateTxt then
            --nameTxt.text = self.id .. "(" ..  self.cell.position.x .. "," .. self.cell.position.y .. ")" .. self.bCanMove
            stateTxt.text = "(" .. self.cell.position.x .. "," .. self.cell.position.y .. ")" ..  self:GetState()
            --stateTxt.text = "温" ..  self:GetAttribute(AttributeType.Warm) .. "饥" .. self:GetAttribute(AttributeType.Hunger) .. "休" .. self:GetAttribute(AttributeType.Rest) ..  self:GetState()
        end
    end
end

function CharacterController:setCircleActive(bshow, bProtest)
    if self.transform then
        local circle = self.transform:Find("Circle")
        self.bCircleActive = bshow
        if bshow then
            --              if self.currGrid.zoneType == ZoneType.MainRoad or  self.currGrid.zoneType == ZoneType.Kitchen then
            --                    circle.gameObject:SetActive(false)
            --                    return
            --              end
            circle.gameObject:SetActive(true)
            local spriteRenderer = circle.gameObject:GetComponent(typeof(SpriteRenderer))

            ResInterface.SyncLoadSprite("player_b1.png", function(sprite)
                spriteRenderer.sprite = sprite
            end)

            if bProtest then
                -- spriteRenderer.color = Color.green      --
                ResInterface.SyncLoadSprite("player_b2.png", function(sprite)
                    spriteRenderer.sprite = sprite
                end)
            end

            spriteRenderer.sortingOrder = 20001
        else
            circle.gameObject:SetActive(false)
        end
    end
end

--获取睡觉的床点
function CharacterController:GetSleepBedGrid()
    local grids = GridManager.GetGridsByMarkerType(self.cityId, GridMarker.Bed, ZoneType.Dorm)
    grids:Sort(Utils.SortGridByAscendingUseMarkerIndex)
    for i = 1, grids:Count(), 1 do
        if grids[i]:IsFurnitureCanWork() then
            return grids[i]
        end
    end
    return nil
end

--设置角色是否在室内
function CharacterController:SetCharInRoom(bRoom)
    self.bRoom = bRoom
end

--获取角色是否在室内
function CharacterController:GetCharIsInRoom()
    if self.currGrid.zoneType == ZoneType.MainRoad then
        if self.currGrid.markerType == "Occlusion" then
            self.bRoom = true
        else
            self.bRoom = false            
        end 

    else
        self.bRoom = true
    end
    return self.bRoom
end

--获取医疗时间
function CharacterController:GetMedicalTime()
    if self.isGuideHeal then
        return 5
    end
    return BoostManager.GetBoost(self.cityId):GetRxBoosterValue(RxBoostType.MedicalTime)
end

--获取医疗值
function CharacterController:GetMedicalValue()
    if self.isGuideHeal then
        return 100
    end
    return BoostManager.GetBoost(self.cityId):GetRxBoosterValue(RxBoostType.MedicalValue)
end

--通知小人离开睡觉
function CharacterController:BrocastSleepExit()
    -- local zoneId = self.currGrid.zoneId
    -- local build = CityModule.getMainCtrl().buildDict[zoneId]
    -- local markerIndex = self.currGrid.markerIndex -- 第几个床
    -- local index = self.currGrid:GetCapacityIndex(self.id) -- 上下床
    -- local bedFurn = build.transform:Find("Room/model_furniture_bed_" .. markerIndex)
    -- local bedUp = bedFurn:Find("bed_up"):GetComponent(typeof(SpriteRenderer))
    -- local bedDown = bedFurn:Find("bed_down"):GetComponent(typeof(SpriteRenderer))
    -- if index == 1 then
    --     bedDown.sortingOrder = 3021
    -- else
    --     self.meshRenderer.sortingOrder = 7999
    -- end
end

return CharacterController
