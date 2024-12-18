FSMRunAway = Clone(FSMSystem)
FSMRunAway.__cname = "FSMRunAway"

function FSMRunAway:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.RunAwayExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.RunAwayMoveToBorn, StateId.MoveToBorn)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.RunAwayRunWithAction, StateId.RunWithRunAwayAction)
    self:AddState(entryState)

    local moveBorn = MoveState:New(StateId.MoveToBorn)
    moveBorn:AddTransition(CheckType.Process, FSMTransitionType.RunAwayExit, StateId.ExitState)
    moveBorn:AddTransition(CheckType.Complete, FSMTransitionType.RunAwayRunWithAction, StateId.RunWithRunAwayAction)
    self:AddState(moveBorn)

    local runAction = RunAwayActionState:New(StateId.RunWithRunAwayAction)
    self:AddState(runAction)

    local exitState = ExitState:New()
    self:AddState(exitState)
end
-----------------------------------------
---是否退出RunAway
-----------------------------------------
TransitionHandles[FSMTransitionType.RunAwayExit] = function(fsm)
    return fsm.owner:GetState() ~= EnumState.RunAway
end
-----------------------------------------
---是否可以移动到Born
-----------------------------------------
TransitionHandles[FSMTransitionType.RunAwayMoveToBorn] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    if fsm.owner.currGrid.markerType == GridMarker.Born then
        return false
    end
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Born, ZoneType.MainRoad)
    if not target then
        return false
    end
    fsm:SetMoveInfo(target)
    return true
end
-----------------------------------------
---是否可以移动到Born
-----------------------------------------
TransitionHandles[FSMTransitionType.RunAwayRunWithAction] = function(fsm)
    if nil == fsm.owner.currGrid then

        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Born
end
