FSMGuard = Clone(FSMSystem)
FSMGuard.__cname = "FSMGuard"

function FSMGuard:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.GuardExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.GuardMoveToSpeech, StateId.MoveToSpeech)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.GuardMoveToMainRoadIdle, StateId.MoveToMainRoadIdle)
    self:AddState(entryState)

    local moveSpeech = MoveState:New(StateId.MoveToSpeech)
    moveSpeech:AddTransition(CheckType.Process, FSMTransitionType.GuardExit, StateId.ExitState)
    moveSpeech:AddTransition(CheckType.Complete, FSMTransitionType.GuardRunWithSpeeh, StateId.RunWithSpeech)
    moveSpeech:AddTransition(CheckType.Complete, FSMTransitionType.GuardMoveToMainRoadIdle, StateId.MoveToMainRoadIdle)
    self:AddState(moveSpeech)

    local runSpeech = GuardActionState:New(StateId.RunWithSpeech)
    runSpeech:AddTransition(CheckType.Process, FSMTransitionType.GuardExit, StateId.ExitState)
    runSpeech:AddTransition(CheckType.Complete, FSMTransitionType.GuardMoveToMainRoadIdle, StateId.MoveToMainRoadIdle)
    self:AddState(runSpeech)

    local moveIdle = MoveState:New(StateId.MoveToMainRoadIdle)
    moveIdle:AddTransition(CheckType.Process, FSMTransitionType.GuardExit, StateId.ExitState)
    moveIdle:AddTransition(CheckType.Process, FSMTransitionType.GuardMoveToSpeech, StateId.MoveToSpeech)
    moveIdle:AddTransition(CheckType.Complete, FSMTransitionType.StayAtIdle, StateId.RunWithMainRoadIdle)
    self:AddState(moveIdle)

    local runIdle = IdleState:New(StateId.RunWithMainRoadIdle)
    runIdle:AddTransition(CheckType.Process, FSMTransitionType.GuardExit, StateId.ExitState)
    runIdle:AddTransition(CheckType.Process, FSMTransitionType.GuardMoveToSpeech, StateId.MoveToSpeech)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.GuardMoveToMainRoadIdle, StateId.MoveToMainRoadIdle)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.StayAtIdle, StateId.RunWithMainRoadIdle)
    self:AddState(runIdle)

    local exitState = ExitState:New()
    self:AddState(exitState)
end

-----------------------------------------
---是否退出Guard
-----------------------------------------
TransitionHandles[FSMTransitionType.GuardExit] = function(fsm)
    return fsm.owner:GetState() ~= EnumState.Normal
end

-----------------------------------------
---是否可以移动到speech点
-----------------------------------------
TransitionHandles[FSMTransitionType.GuardMoveToSpeech] = function(fsm)
    if not ProtestManager.IsProtestStatus(fsm.cityId) then
        return false
    end
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Speech, ZoneType.MainRoad)
    if not target then
        return false
    end
    fsm:SetMoveInfo(target, 2)
    return true
end
-----------------------------------------
---是否可以移动到mainroad idle点
-----------------------------------------
TransitionHandles[FSMTransitionType.GuardMoveToMainRoadIdle] = function(fsm)
    if ProtestManager.IsProtestStatus(fsm.cityId) then
        return false
    end
    local grids = List:New()
    grids:AddRange(GridManager.GetGridsByMarkerType(fsm.cityId, GridMarker.Idle, ZoneType.MainRoad))
    grids:AddRange(GridManager.GetGridsByMarkerType(fsm.cityId, GridMarker.Idle, ZoneType.Watchtower))
    local target = grids[math.random(grids:Count())]
    if not target then
        return false
    end
    if nil == fsm.owner.currGrid then
        return false
    end
    if fsm.owner.currGrid == target then
        return false
    end
    fsm:SetMoveInfo(target)
    return true
end
-----------------------------------------
---是否可以run speech
-----------------------------------------
TransitionHandles[FSMTransitionType.GuardRunWithSpeeh] = function(fsm)
    if not ProtestManager.IsProtestStatus(fsm.cityId) then
        return false
    end
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Speech
end
