FSMStrike = Clone(FSMSystem)
FSMStrike.__cname = "FSMStrike"

function FSMStrike:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.StrikeExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.StrikeMoveToBorn, StateId.MoveToBorn)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.StrikeRunWithAction, StateId.RunWithStrikeAction)
    self:AddState(entryState)

    local moveBorn = MoveState:New(StateId.MoveToBorn)
    moveBorn:AddTransition(CheckType.Process, FSMTransitionType.StrikeExit, StateId.ExitState)
    moveBorn:AddTransition(CheckType.Complete, FSMTransitionType.StrikeRunWithAction, StateId.RunWithStrikeAction)
    self:AddState(moveBorn)

    local runAction = StrikeActionState:New(StateId.RunWithStrikeAction)
    self:AddState(runAction)

    local exitState = ExitState:New()
    self:AddState(exitState)
end
-----------------------------------------
---是否退出Severe
-----------------------------------------
TransitionHandles[FSMTransitionType.StrikeExit] = function(fsm)
    return fsm.owner:GetState() ~= EnumState.EventStrike
end
-----------------------------------------
---是否可以移动到Born
-----------------------------------------
TransitionHandles[FSMTransitionType.StrikeMoveToBorn] = function(fsm)
    if fsm.owner.currGrid.markerType == GridMarker.Born then
        return false
    end
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Born, ZoneType.MainRoad)
    if not target then
        return false
    end
    fsm:SetMoveInfo(target, 1, AnimationType.StrikeWalk)
    return true
end
-----------------------------------------
---是否可以移动到Born
-----------------------------------------
TransitionHandles[FSMTransitionType.StrikeRunWithAction] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Born
end
