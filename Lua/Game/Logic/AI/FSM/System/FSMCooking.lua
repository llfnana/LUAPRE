FSMCooking = Clone(FSMSystem)
FSMCooking.__cname = "FSMCooking"

function FSMCooking:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.BeerExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.BeerMoveToDoor, StateId.MoveToKitchenDoor)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.BeerMoveToBurner, StateId.MoveToKitchenBurner)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.BeerMoveToSpe, StateId.MoveToKitchenSpecial1)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.BearMoveToIdle, StateId.MoveToKitchenIdle)
    self:AddState(entryState)

    local moveDoor = MoveState:New(StateId.MoveToKitchenDoor)
    moveDoor:AddTransition(CheckType.Process, FSMTransitionType.BeerExit, StateId.ExitState)
    moveDoor:AddTransition(CheckType.Complete, FSMTransitionType.BeerMoveToBurner, StateId.MoveToKitchenBurner)
    moveDoor:AddTransition(CheckType.Complete, FSMTransitionType.BeerMoveToSpe, StateId.MoveToKitchenSpecial1)
    moveDoor:AddTransition(CheckType.Complete, FSMTransitionType.BearMoveToIdle, StateId.MoveToKitchenIdle)
    self:AddState(moveDoor)

    local moveToBurner = MoveState:New(StateId.MoveToKitchenBurner)
    moveToBurner:AddTransition(CheckType.Process, FSMTransitionType.BeerExit, StateId.ExitState)
    moveToBurner:AddTransition(CheckType.Complete, FSMTransitionType.BearRunWithBurner, StateId.RunWithKitchenBurner)
    moveToBurner:AddTransition(CheckType.Complete, FSMTransitionType.BeerMoveToSpe, StateId.MoveToKitchenSpecial1)
    moveToBurner:AddTransition(CheckType.Complete, FSMTransitionType.BearMoveToIdle, StateId.MoveToKitchenIdle)
    self:AddState(moveToBurner)

    local runBurner = CookingActionState:New(StateId.RunWithKitchenBurner)
    runBurner:AddTransition(CheckType.Complete, FSMTransitionType.BeerExit, StateId.ExitState)
    runBurner:AddTransition(CheckType.Complete, FSMTransitionType.BearRunWithBurner, StateId.RunWithKitchenBurner)
    runBurner:AddTransition(CheckType.Complete, FSMTransitionType.BeerMoveToSpe, StateId.MoveToKitchenSpecial1)
    runBurner:AddTransition(CheckType.Complete, FSMTransitionType.BearMoveToIdle, StateId.MoveToKitchenIdle)
    self:AddState(runBurner)

    local moveToIdle = MoveState:New(StateId.MoveToKitchenIdle)
    moveToIdle:AddTransition(CheckType.Process, FSMTransitionType.BeerExit, StateId.ExitState)
    moveToIdle:AddTransition(CheckType.Process, FSMTransitionType.BeerMoveToBurner, StateId.MoveToKitchenBurner)
    moveToIdle:AddTransition(CheckType.Complete, FSMTransitionType.BeerMoveToBurner, StateId.MoveToKitchenBurner)
    moveToIdle:AddTransition(CheckType.Complete, FSMTransitionType.StayAtIdle, StateId.RunWithKitchenIdle)
    self:AddState(moveToIdle)

    local runIdle = IdleState:New(StateId.RunWithKitchenIdle)
    runIdle:AddTransition(CheckType.Process, FSMTransitionType.BeerExit, StateId.ExitState)
    runIdle:AddTransition(CheckType.Process, FSMTransitionType.BeerMoveToBurner, StateId.MoveToKitchenBurner)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.BeerMoveToSpe, StateId.MoveToKitchenSpecial1)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.BearMoveToIdle, StateId.MoveToKitchenIdle)
    self:AddState(runIdle)

    local moveToSpecial1 = MoveState:New(StateId.MoveToKitchenSpecial1)
    moveToSpecial1:AddTransition(CheckType.Process, FSMTransitionType.BeerExit, StateId.ExitState)
    moveToSpecial1:AddTransition(CheckType.Process, FSMTransitionType.BeerMoveToBurner, StateId.MoveToKitchenBurner)
    moveToSpecial1:AddTransition(CheckType.Complete, FSMTransitionType.BeerMoveToBurner, StateId.MoveToKitchenBurner)
    moveToSpecial1:AddTransition(CheckType.Complete, FSMTransitionType.StayAtSpecial1, StateId.RunWithKitchenSpecial1)
    self:AddState(moveToSpecial1)

    local runSpecial1 = CookingActionState:New(StateId.RunWithKitchenSpecial1)
    runSpecial1:AddTransition(CheckType.Process, FSMTransitionType.BeerExit, StateId.ExitState)
    runSpecial1:AddTransition(CheckType.Process, FSMTransitionType.BeerMoveToBurner, StateId.MoveToKitchenBurner)
    runSpecial1:AddTransition(CheckType.Complete, FSMTransitionType.BeerMoveToSpe, StateId.MoveToKitchenSpecial1)
    runSpecial1:AddTransition(CheckType.Complete, FSMTransitionType.BearMoveToIdle, StateId.MoveToKitchenIdle)
    self:AddState(runSpecial1)

    local exitState = ExitState:New()
    self:AddState(exitState)
end

function FSMCooking:ChangeStateTrigger(stateId)
    if
        self.curremtStateId == StateId.RunWithKitchenBurner and stateId == StateId.MoveToKitchenIdle and
            self.owner:GetWorkState() == WorkStateType.Pause
     then
        --print("--切换状态触发FSMCooking:ChangeStateTrigger()stateId-",stateId,"id",self.owner.id)
        self.owner:ShowIdleToast()
    end
end

-----------------------------------------
---是否可退出做饭状态
-----------------------------------------
TransitionHandles[FSMTransitionType.BeerExit] = function(fsm)
    if fsm.owner:GetState() ~= EnumState.Normal then
        --print("--退出做饭状态FSMCooking-CookingExit- ~= EnumState.Normal-id",fsm.owner.id)
        return true
    end
    if fsm.owner:GetProfessionType() ~= ProfessionType.Chef then
        return true
    end
    if not SchedulesManager.IsSchdulesActive(fsm.cityId, SchedulesType.Cooking) then
        if not SchedulesManager.IsSchdulesActive(fsm.cityId, SchedulesType.Eat) then
            --print("--退出做饭状态FSMCooking-CookingExit- not  SchedulesType.Eat-id",fsm.owner.id)
            return true
        end
        if fsm.owner:GetSchedulesStatus(SchedulesType.Eat) ~= SchedulesStatus.Stop then
            --print("--退出做饭状态FSMCooking-CookingExit-  ~= SchedulesStatus.Stop-id",fsm.owner.id)
            return true
        end
    end
--    local isCooking, isFull = FoodSystemManager.IsCanCook(fsm.cityId)
--    if isFull ==false and isCooking ==false then
--          print("--FSMCooking-CookingExit-id",fsm.owner.id,"fsmtype-",fsm.type,"pcnf",fsm.owner.peopleConfig.type,"isFull ==false and isCooking ==false")

--        return true
--    end

    return false
end
-----------------------------------------
---是否可以移动到厨房door点
-----------------------------------------
TransitionHandles[FSMTransitionType.BeerMoveToDoor] = function(fsm)
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Door, ZoneType.Kitchen, -1, 2)
    if not target then
        fsm.owner:SetPlayAniIdle()
        --print("--移动到厨房door点FSMCooking-CookingMoveToKitchenDoor- not target-id",fsm.owner.id)
        return false
    end
    fsm:SetMoveInfo(target, fsm:GetSpeedPercent(SchedulesType.Cooking))
    return true
end
-----------------------------------------
---是否可以移动到炉灶
-----------------------------------------
TransitionHandles[FSMTransitionType.BeerMoveToBurner] = function(fsm)
    if not SchedulesManager.IsSchdulesActive(fsm.cityId, SchedulesType.Cooking) then
        --print("--是否可以移动到炉灶FSMCooking-CookingMoveToBurner- 0  notActiveCooking--id",fsm.owner.id)
        -- if  not SchedulesManager.IsSchdulesActive(fsm.cityId, SchedulesType.Arbeit)  then
        --     print("--是否可以移动到炉灶FSMCooking-CookingMoveToBurner  notActiveArbeit--id",fsm.owner.id)
        --     return false
        -- else
        --    --return false
        -- end
        return false
    end
    local ret = false
    local workState = WorkStateType.None
    local target = fsm.owner:GetArbeitToolGrid()
    if target then
        workState = WorkStateType.Work
        fsm:SetMoveInfo(target, fsm:GetTutorialSpeedPercent(),"cooking")
        ret = true
    else
        local isCooking, isFull = FoodSystemManager.IsCanCook(fsm.cityId)
        if isCooking then
            workState = WorkStateType.Disable
        else
            workState = WorkStateType.Pause
        end

        if isCooking and isFull == false then
            target =  fsm.owner.currGrid
            workState = WorkStateType.Work
            fsm:SetMoveInfo(target, fsm:GetTutorialSpeedPercent())
            ret = true
            --print("--是否可以移动到炉灶FSMCooking-CookingMoveToBurner- 1not target-id",fsm.owner.id,"workState",workState,"IsCanCook",isCooking,"isFull",isFull)    
        else
            fsm.owner:SetPlayAniHwork()  
           --print("--是否可以移动到炉灶FSMCooking-CookingMoveToBurner- 2not target-id",fsm.owner.id,"workState",workState,"IsCanCook",isCooking,"isFull",isFull)    
        end
  
     end
    fsm.owner:SetWorkState(workState)
    --print("--是否可以移动到炉灶FSMCooking-CookingMoveToBurner- 3--id",fsm.owner.id,"workState",workState,"ret",ret)
    return ret
end
-----------------------------------------
---是否可以移动到厨房special1点
-----------------------------------------
TransitionHandles[FSMTransitionType.BeerMoveToSpe] = function(fsm)
    if math.random() > 0.5 then
        return false
    end
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Special1ForIdle, ZoneType.Kitchen)
    if not target then
        fsm.owner:SetPlayAniIdle()
        --print("--是否可以移动到厨房special1点FSMCooking-CookingMoveToSpecial1- not target-id",fsm.owner.id)
        return false
    end
    fsm:SetMoveInfo(target)
    return true
end
-----------------------------------------
---是否可以移动到厨房idle点
-----------------------------------------
TransitionHandles[FSMTransitionType.BearMoveToIdle] = function(fsm)
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Idle, ZoneType.Kitchen)
    if not target then
        fsm.owner:SetPlayAniIdle()
        --print("--是否可以移动到厨房idle点FSMCooking-CookingMoveToIdle- not target-id",fsm.owner.id)
        return false
    end
    fsm:SetMoveInfo(target)
    return true
end
-----------------------------------------
---是否可以厨房做饭
-----------------------------------------
TransitionHandles[FSMTransitionType.BearRunWithBurner] = function(fsm)
    local workState = WorkStateType.None
    local ret = false
    if fsm.owner.currGrid:IsFurnitureCanUse() then
        local isCooking, isFull = FoodSystemManager.IsCanCook(fsm.cityId)
        if isCooking then
            workState = WorkStateType.Work
            ret = true
        elseif isFull then
            workState = WorkStateType.Work
            ret = false
        else
            workState = WorkStateType.Pause
        end
    else
        workState = WorkStateType.Disable
        -- local isCooking, isFull = FoodSystemManager.IsCanCook(fsm.cityId)
        -- if isCooking==true and isFull==false then
        --     workState = WorkStateType.Work
        --     ret = true
        -- end
    end
    fsm.owner:SetWorkState(workState)
     --print("--是否可以厨房做饭FSMCooking-CookingRunWithBurner- not target-id",fsm.owner.id,"workState",workState,"IsCanUse",fsm.owner.currGrid:IsFurnitureCanUse())
    return ret
end
