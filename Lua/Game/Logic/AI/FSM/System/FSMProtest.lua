FSMProtest = Clone(FSMSystem)
FSMProtest.__cname = "FSMProtest"

function FSMProtest:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.ProtestExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.ProtestRunWithTool, StateId.RunWithProtest)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.ProtestMoveToTool, StateId.MoveToProtest)
    self:AddState(entryState)

    local moveProtest = MoveState:New(StateId.MoveToProtest)
    moveProtest:AddTransition(CheckType.Process, FSMTransitionType.ProtestExit, StateId.ExitState)
    moveProtest:AddTransition(CheckType.Complete, FSMTransitionType.ProtestRunWithTool, StateId.RunWithProtest)
    self:AddState(moveProtest)

    local runProtest = ProtestActionState:New(StateId.RunWithProtest)
    runProtest:AddTransition(CheckType.Process, FSMTransitionType.ProtestExit, StateId.ExitState)
    self:AddState(runProtest)

    local exitState = ExitState:New()
    self:AddState(exitState)
end

-----------------------------------------
---是否退出Protest
-----------------------------------------
TransitionHandles[FSMTransitionType.ProtestExit] = function(fsm)
    return fsm.owner:GetState() ~= EnumState.Protest
end

-----------------------------------------
---是否可以移动到Protest点
-----------------------------------------
TransitionHandles[FSMTransitionType.ProtestMoveToTool] = function(fsm)
    local target = nil
    if math.random() <= 0.5 then
        target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Protest, ZoneType.MainRoad)
    else
        target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Protest2, ZoneType.MainRoad)
    end
    if nil == target then
        return false
    end
    fsm:SetMoveInfo(target, 2, AnimationType.StrikeWalk )
    return true
end

-----------------------------------------
---是否可以移动到Protest点
-----------------------------------------
TransitionHandles[FSMTransitionType.ProtestRunWithTool] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    if fsm.owner.currGrid.markerType == GridMarker.Protest then
        return true
    end
    if fsm.owner.currGrid.markerType == GridMarker.Protest2 then
        return true
    end
    return false
end
