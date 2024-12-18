FSMArbeit = Clone(FSMSystem)
FSMArbeit.__cname = "FSMArbeit" --劳动; 打工
FSMArbeit.zoneId = nil
FSMArbeit.furnitureId = nil
FSMArbeit.furnitureIndex = nil
FSMArbeit.viewId = nil
FSMArbeit.mapItemData = nil
FSMArbeit.productData = nil

function FSMArbeit:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.ArbeitExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.ArbeitMoveToDoor, StateId.MoveToArbeitDoor)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.ArbeitMoveToTool, StateId.MoveToArbeitTool)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.ArbeitMoveToIdle, StateId.MoveToArbeitIdle)
    self:AddState(entryState)

    local moveDoor = MoveState:New(StateId.MoveToArbeitDoor)
    moveDoor:AddTransition(CheckType.Process, FSMTransitionType.ArbeitExit, StateId.ExitState)
    moveDoor:AddTransition(CheckType.Complete, FSMTransitionType.ArbeitMoveToTool, StateId.MoveToArbeitTool)
    moveDoor:AddTransition(CheckType.Complete, FSMTransitionType.ArbeitMoveToIdle, StateId.MoveToArbeitIdle)
    self:AddState(moveDoor)

    local moveTool = MoveState:New(StateId.MoveToArbeitTool)
    moveTool:AddTransition(CheckType.Process, FSMTransitionType.ArbeitExit, StateId.ExitState)
    moveTool:AddTransition(CheckType.Complete, FSMTransitionType.ArbeitRunWithTool, StateId.RunWithArbeitTool)
    moveTool:AddTransition(CheckType.Complete, FSMTransitionType.ArbeitMoveToIdle, StateId.MoveToArbeitIdle)
    self:AddState(moveTool)

    local runTool = ArbeitActionState:New(StateId.RunWithArbeitTool)
    runTool:AddTransition(CheckType.Process, FSMTransitionType.ArbeitExit, StateId.ExitState)
    runTool:AddTransition(CheckType.Complete, FSMTransitionType.ArbeitRunWithTool, StateId.RunWithArbeitTool)
    runTool:AddTransition(CheckType.Complete, FSMTransitionType.ArbeitMoveToIdle, StateId.MoveToArbeitIdle)
    self:AddState(runTool)

    local moveIdle = MoveState:New(StateId.MoveToArbeitIdle)
    moveIdle:AddTransition(CheckType.Process, FSMTransitionType.ArbeitExit, StateId.ExitState)
    moveIdle:AddTransition(CheckType.Process, FSMTransitionType.ArbeitMoveToTool, StateId.MoveToArbeitTool)
    moveIdle:AddTransition(CheckType.Complete, FSMTransitionType.ArbeitMoveToTool, StateId.MoveToArbeitTool)
    moveIdle:AddTransition(CheckType.Complete, FSMTransitionType.StayAtIdle, StateId.RunWithArbeitIdle)
    self:AddState(moveIdle)

    local runIdle = IdleState:New(StateId.RunWithArbeitIdle)
    runIdle:AddTransition(CheckType.Process, FSMTransitionType.ArbeitExit, StateId.ExitState)
    runIdle:AddTransition(CheckType.Process, FSMTransitionType.ArbeitMoveToTool, StateId.MoveToArbeitTool)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.ArbeitMoveToTool, StateId.MoveToArbeitTool)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.ArbeitMoveToIdle, StateId.MoveToArbeitIdle)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.ArbeitRunWithTool, StateId.RunWithArbeitTool)
    self:AddState(runIdle)

    local exitState = ExitState:New()
    self:AddState(exitState)
end

--切换状态触发
function FSMArbeit:ChangeStateTrigger(stateId)
    if
        self.curremtStateId == StateId.RunWithArbeitTool and stateId == StateId.MoveToArbeitIdle and
            self.owner:GetWorkState() == WorkStateType.Pause
     then
        self.owner:ShowIdleToast()
    end
end

--生产进入
function FSMArbeit:ProductionEnter()
    self.zoneId = self.owner.currGrid.zoneId
    self.furnitureId = self.owner.currGrid.furnitureId
    self.furnitureIndex = self.owner.currGrid.markerIndex
    self.viewId = self.furnitureId .. "_" .. self.furnitureIndex
    self.mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    self.productData = self.mapItemData:GetProductData(self.furnitureId, self.furnitureIndex)
    --添加在线收益
    self.realOutput = {}
    self:AddOnlineProductions()
    self:SetProductionView(true)
end

--生产刷新
function FSMArbeit:ProductionUpdate()
    self.productData.time = self.productData.time + (TimerFunction.deltaTime / self.owner.attributeBoostValue)
    if self.productData.time >= self.productData.duration then
        self.productData.finished = true
        --处理数据
        DataManager.AddMaterials(self.cityId, self.productData.output, "Production", self.furnitureId)
        local baseHeart, realHeart = MapManager.GetHeartProductCount(self.cityId, self.furnitureId)
        if baseHeart > 0 then
            --EventSceneManager.AddHeart(baseHeart, realHeart, "Production", self.furnitureId)
        end
        MapManager.SaveData(self.cityId)
        --展示完成效果
        -- if self.owner.isShowView then
            --生产显示
            local viewTips = List:New()
            for itemType, itemValue in pairs(self.productData.output) do
                local info = {}
                info.type = itemType
                info.iconFun = Utils.SetItemIcon
                info.iconParams = itemType
                info.selectIndex = 3
                info.value = itemValue
                viewTips:Add(info)
            end
            --爱心显示
            if realHeart > 0 then
                local info = {}
                info.type = ItemType.Heart
                info.iconFun = Utils.SetItemIcon
                info.iconParams = ConfigManager.GetEventHeartItemId(self.cityId)
                info.selectIndex = 3
                info.value = realHeart
                viewTips:Add(info)
            end
            if viewTips:Count() > 0 then
                self.owner:ShowView("Tips_%s" .. self.owner.id, ViewType.Tips, viewTips)
            end
        -- end

        --创建新数据
        local ret, lackMaterials = self.mapItemData:IsCanProduct(self.furnitureId, self.furnitureIndex)
        if ret then
            self.productData = self.mapItemData:GetProductData(self.furnitureId, self.furnitureIndex)
            self:UpdateOnlineProductions()
            self:SetProductionView(true)
        else
            self.lackMaterials = lackMaterials
            return true
        end
    else
        self:SetProductionView(true)
    end
    return false
end

--生产结束
function FSMArbeit:ProductionQuit()


    self:SetProductionView(false)
    self:RemoveOnlineProductions()
    self.zoneId = nil
    self.furnitureId = nil
    self.furnitureIndex = nil
    self.viewId = nil
    self.mapItemData = nil
    self.productData = nil
end

--生产显示
function FSMArbeit:SetProductionView(enterProduct)
    self.owner:UpdateArbeitGridView(enterProduct)
end

--添加在线收益
function FSMArbeit:AddOnlineProductions()
    for id, count in pairs(self.productData.output) do
        self.realOutput[id] = count / self.productData.duration
    end
    StatisticalManager.AddOnlineProdutcions(self.cityId, self.zoneId, self.realOutput)
end

--刷新在线收益
function FSMArbeit:UpdateOnlineProductions()
    local isChange = false
    local changeOutput = {}
    for id, cout in pairs(self.productData.output) do
        local value = cout / self.productData.duration
        if value ~= self.realOutput[id] then
            changeOutput[id] = value - self.realOutput[id]
            isChange = true
        end
        self.realOutput[id] = value
    end
    if isChange then
        StatisticalManager.AddOnlineProdutcions(self.cityId, self.zoneId, changeOutput)
    end
end

--移除在线收益
function FSMArbeit:RemoveOnlineProductions()
    if not self.realOutput then
        return
    end
    StatisticalManager.RemoveOnlineProdutcions(self.cityId, self.zoneId, self.realOutput)
    self.realOutput = nil
end

-----------------------------------------
---是否退出Arbeit
-----------------------------------------
TransitionHandles[FSMTransitionType.ArbeitExit] = function(fsm)

    local ret = false
    while true do
        if fsm.owner:GetState() ~= EnumState.Normal then
            ret = true
            break
        end
        if fsm.owner.peopleConfig.type == ProfessionType.FreeMan then
            ret = true
            break
        end
--        if WorkOverTimeManager.IsActiveWorkOverTimeByZoneType(fsm.owner.cityId, fsm.owner.peopleConfig.zone_type) then
--               ret = false
--            break
--        end
        local schedules = SchedulesManager.GetActiveSchedules(fsm.cityId, fsm.type)
        if schedules then
            if not schedules.IsMatchProfession(fsm.owner.peopleConfig.type) then
                ret = true
                break
            end
            if schedules.is_overtime then
                if not WorkOverTimeManager.IsCanWorkOverTimeByZoneType(fsm.cityId, fsm.owner.peopleConfig.zone_type) then
                    ret = true
                    break
                end

            end
            ret = false
            break
        elseif SchedulesManager.IsSchdulesActive(fsm.cityId, SchedulesType.Eat) then
            if fsm.owner:GetSchedulesStatus(SchedulesType.Eat) ~= SchedulesStatus.Stop then
                ret = true
                break
            end
            ret = false
            break
        else

           if fsm.type == "Arbeit_OverTime"  then
                     ret = false
                     break
           end
            ret = true

            break
        end
        break
    end

    --if ret then
    --    fsm.owner:UpdateArbeitView()
    --end
    
    return ret
end

-----------------------------------------
---是否可以移动到Arbeit Door
-----------------------------------------
TransitionHandles[FSMTransitionType.ArbeitMoveToDoor] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    if fsm.owner.currGrid.zoneType == fsm.owner.peopleConfig.zone_type then
        return false
    end
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Door, fsm.owner.peopleConfig.zone_type)
    if not target then
        fsm.owner:SetPlayAniIdle()
        return false
    end
    fsm:SetMoveInfo(target, fsm:GetSpeedPercent(fsm.type))
    --fsm.owner:SetArbeitIconView("icon_notice_onTheWay")
    return true
end
-----------------------------------------
---是否可以移动到Arbeit Tool
-----------------------------------------
TransitionHandles[FSMTransitionType.ArbeitMoveToTool] = function(fsm)
    if not SchedulesManager.IsSchdulesActive(fsm.cityId, fsm.type) then
        
        return false
    end
    if nil == fsm.owner.currGrid then

        return false
    end
    if fsm.owner.currGrid.zoneType ~= fsm.owner.peopleConfig.zone_type then


        return false
    end
    local workState = WorkStateType.None
    local ret = false
    local target = fsm.owner:GetArbeitToolGrid()
    if target then
        workState = WorkStateType.Work
        fsm:SetMoveInfo(target, fsm:GetTutorialSpeedPercent())
        ret = true
    else

        workState = WorkStateType.Pause
    end
    fsm.owner:SetWorkState(workState)
    return ret
end
-----------------------------------------
---是否可以移动到Arbeit Idle
-----------------------------------------
TransitionHandles[FSMTransitionType.ArbeitMoveToIdle] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    if fsm.owner.currGrid.zoneType ~= fsm.owner.peopleConfig.zone_type then
        return false
    end
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Idle, fsm.owner.peopleConfig.zone_type)
    if not target then
        fsm.owner:SetPlayAniIdle()
        return false
    end
    fsm:SetMoveInfo(target)

    return true
end
-----------------------------------------
---是否可以工作
-----------------------------------------
TransitionHandles[FSMTransitionType.ArbeitRunWithTool] = function(fsm)
    local workState = fsm.owner.currGrid:GetFurnitureWorkState()
    fsm.owner:SetWorkState(workState)

    return workState == WorkStateType.Work
end
