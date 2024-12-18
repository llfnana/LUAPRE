FSMBoilerman = Clone(FSMSystem)
FSMBoilerman.__cname = "FSMBoilerman" --锅炉工

function FSMBoilerman:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.BoilermanExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.BoilermanMoveToSpecial1, StateId.MoveToGeneratorSpecial1)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.BoilermanMoveToSpecial2, StateId.MoveToGeneratorSpecial2)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.BoilermanMoveToSpecial3, StateId.MoveToGeneratorSpecial3)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.BoilermanMoveToIdle, StateId.MoveToGeneratorIdle)
    self:AddState(entryState)

    local moveS1 = MoveState:New(StateId.MoveToGeneratorSpecial1)
    moveS1:AddTransition(CheckType.Process, FSMTransitionType.BoilermanExit, StateId.ExitState)
    moveS1:AddTransition(CheckType.Complete, FSMTransitionType.BoilermanRunWithSpecial1, StateId.RunWithGeneratorSpecial1)
    self:AddState(moveS1)

    local runS1 = BoilermanActionState:New(StateId.RunWithGeneratorSpecial1)
    runS1:AddTransition(CheckType.Process, FSMTransitionType.BoilermanExit, StateId.ExitState)
    runS1:AddTransition(CheckType.Complete, FSMTransitionType.BoilermanMoveToSpecial2, StateId.MoveToGeneratorSpecial2)
    runS1:AddTransition(CheckType.Complete, FSMTransitionType.BoilermanMoveToSpecial3, StateId.MoveToGeneratorSpecial3)
    runS1:AddTransition(CheckType.Complete, FSMTransitionType.BoilermanMoveToIdle, StateId.MoveToGeneratorIdle)
    self:AddState(runS1)

    local moveS2 = MoveState:New(StateId.MoveToGeneratorSpecial2)
    moveS2:AddTransition(CheckType.Process, FSMTransitionType.BoilermanExit, StateId.ExitState)
    moveS2:AddTransition(CheckType.Complete, FSMTransitionType.BoilermanRunWithSpecial2, StateId.RunWithGeneratorSpecial2)
    self:AddState(moveS2)

    local runS2 = BoilermanActionState:New(StateId.RunWithGeneratorSpecial2)
    runS2:AddTransition(CheckType.Process, FSMTransitionType.BoilermanExit, StateId.ExitState)
    runS2:AddTransition(CheckType.Complete, FSMTransitionType.BoilermanMoveToSpecial3, StateId.MoveToGeneratorSpecial3)
    runS2:AddTransition(CheckType.Complete, FSMTransitionType.BoilermanMoveToIdle, StateId.MoveToGeneratorIdle)
    runS2:AddTransition(CheckType.Complete, FSMTransitionType.BoilermanMoveToSpecial1, StateId.MoveToGeneratorSpecial1)
    self:AddState(runS2)

    local moveS3 = MoveState:New(StateId.MoveToGeneratorSpecial3)
    moveS3:AddTransition(CheckType.Process, FSMTransitionType.BoilermanExit, StateId.ExitState)
    moveS3:AddTransition(CheckType.Complete, FSMTransitionType.BoilermanRunWithSpecial3, StateId.RunWithGeneratorSpecial3)
    self:AddState(moveS3)

    local runS3 = BoilermanActionState:New(StateId.RunWithGeneratorSpecial3)
    runS3:AddTransition(CheckType.Process, FSMTransitionType.BoilermanExit, StateId.ExitState)
    runS3:AddTransition(CheckType.Complete, FSMTransitionType.BoilermanMoveToIdle, StateId.MoveToGeneratorIdle)
    runS3:AddTransition(CheckType.Complete, FSMTransitionType.BoilermanMoveToSpecial1, StateId.MoveToGeneratorSpecial1)
    runS3:AddTransition(CheckType.Complete, FSMTransitionType.BoilermanMoveToSpecial2, StateId.MoveToGeneratorSpecial2)
    self:AddState(runS3)

    local moveIdle = MoveState:New(StateId.MoveToGeneratorIdle)
    moveIdle:AddTransition(CheckType.Process, FSMTransitionType.BoilermanExit, StateId.ExitState)
    moveIdle:AddTransition(CheckType.Complete, FSMTransitionType.StayAtIdle, StateId.RunWithGeneratorIdle)
    self:AddState(moveIdle)

    local runIdle = IdleState:New(StateId.RunWithGeneratorIdle)
    runIdle:AddTransition(CheckType.Process, FSMTransitionType.BoilermanExit, StateId.ExitState)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.BoilermanMoveToSpecial1, StateId.MoveToGeneratorSpecial1)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.BoilermanMoveToSpecial2, StateId.MoveToGeneratorSpecial2)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.BoilermanMoveToSpecial3, StateId.MoveToGeneratorSpecial3)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.BoilermanMoveToIdle, StateId.MoveToGeneratorIdle)
    self:AddState(runIdle)

    local exitState = ExitState:New()
    self:AddState(exitState)
end

-----------------------------------------
---是否退出Boilerman
-----------------------------------------
TransitionHandles[FSMTransitionType.BoilermanExit] = function(fsm)
    return fsm.owner:GetState() ~= EnumState.Normal
end

-----------------------------------------
---是否可以移动到Special1点
-----------------------------------------
TransitionHandles[FSMTransitionType.BoilermanMoveToSpecial1] = function(fsm)
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Special1ForIdle, ZoneType.Generator)
    if not target then
        return false
    end
    fsm:SetMoveInfo(target)
    return true
end
-----------------------------------------
---是否可以移动到Special2点
-----------------------------------------
TransitionHandles[FSMTransitionType.BoilermanMoveToSpecial2] = function(fsm)
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Special2ForIdle, ZoneType.Generator)
    if not target then
        return false
    end
    fsm:SetMoveInfo(target)
    return true
end
-----------------------------------------
---是否可以移动到Special3点
-----------------------------------------
TransitionHandles[FSMTransitionType.BoilermanMoveToSpecial3] = function(fsm)
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Special3ForIdle, ZoneType.Generator)
    if not target then
        return false
    end
    fsm:SetMoveInfo(target)
    return true
end
-----------------------------------------
---是否可以移动到Idle点
-----------------------------------------
TransitionHandles[FSMTransitionType.BoilermanMoveToIdle] = function(fsm)
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Idle, ZoneType.Generator)
    if not target then
        return false
    end
    fsm:SetMoveInfo(target)
    return true
end
-----------------------------------------
---是否可以运行Special1
-----------------------------------------
TransitionHandles[FSMTransitionType.BoilermanRunWithSpecial1] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Special1ForIdle
end
-----------------------------------------
---是否可以运行Special2
-----------------------------------------
TransitionHandles[FSMTransitionType.BoilermanRunWithSpecial2] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Special2ForIdle
end
-----------------------------------------
---是否可以运行Special3
-----------------------------------------
TransitionHandles[FSMTransitionType.BoilermanRunWithSpecial3] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Special3ForIdle
end
