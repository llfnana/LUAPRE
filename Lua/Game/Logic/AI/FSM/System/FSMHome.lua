FSMHome = Clone(FSMSystem)
FSMHome.__cname = "FSMHome"

function FSMHome:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.HomeExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.HomeMoveToDormDoor, StateId.MoveToDormDoor)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.HomeMoveToDormTool2, StateId.MoveToDormTool2)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.HomeMoveToDormTool3, StateId.MoveToDormTool3)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.HomeMoveToDormTool4, StateId.MoveToDormTool4)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.HomeMoveToDormTool5, StateId.MoveToDormTool5)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.HomeMoveToDormTool6, StateId.MoveToDormTool6)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.HomeMoveToDormIdle, StateId.MoveToDormIdle)
    self:AddState(entryState)

    local moveToDoor = MoveState:New(StateId.MoveToDormDoor)
    moveToDoor:AddTransition(CheckType.Process, FSMTransitionType.HomeExit, StateId.ExitState)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool2, StateId.MoveToDormTool2)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool3, StateId.MoveToDormTool3)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool4, StateId.MoveToDormTool4)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool5, StateId.MoveToDormTool5)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool6, StateId.MoveToDormTool6)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormIdle, StateId.MoveToDormIdle)
    self:AddState(moveToDoor)

    local moveToTool2 = MoveState:New(StateId.MoveToDormTool2)
    moveToTool2:AddTransition(CheckType.Process, FSMTransitionType.HomeExit, StateId.ExitState)
    moveToTool2:AddTransition(CheckType.Complete, FSMTransitionType.HomeRunWithDormTool2, StateId.RunWithDormTool2)
    self:AddState(moveToTool2)

    local moveToTool3 = MoveState:New(StateId.MoveToDormTool3)
    moveToTool3:AddTransition(CheckType.Process, FSMTransitionType.HomeExit, StateId.ExitState)
    moveToTool3:AddTransition(CheckType.Complete, FSMTransitionType.HomeRunWithDormTool3, StateId.RunWithDormTool3)
    self:AddState(moveToTool3)

    local moveToTool4 = MoveState:New(StateId.MoveToDormTool4)
    moveToTool4:AddTransition(CheckType.Process, FSMTransitionType.HomeExit, StateId.ExitState)
    moveToTool4:AddTransition(CheckType.Complete, FSMTransitionType.HomeRunWithDormTool4, StateId.RunWithDormTool4)
    self:AddState(moveToTool4)

    local moveToTool5 = MoveState:New(StateId.MoveToDormTool5)
    moveToTool5:AddTransition(CheckType.Process, FSMTransitionType.HomeExit, StateId.ExitState)
    moveToTool5:AddTransition(CheckType.Complete, FSMTransitionType.HomeRunWithDormTool5, StateId.RunWithDormTool5)
    self:AddState(moveToTool5)

    local moveToTool6 = MoveState:New(StateId.MoveToDormTool6)
    moveToTool6:AddTransition(CheckType.Process, FSMTransitionType.HomeExit, StateId.ExitState)
    moveToTool6:AddTransition(CheckType.Complete, FSMTransitionType.HomeRunWithDormTool6, StateId.RunWithDormTool6)
    self:AddState(moveToTool6)

    local moveToIdle = MoveState:New(StateId.MoveToDormIdle)
    moveToIdle:AddTransition(CheckType.Process, FSMTransitionType.HomeExit, StateId.ExitState)
    moveToIdle:AddTransition(CheckType.Complete, FSMTransitionType.StayAtIdle, StateId.RunWithDormIdle)
    self:AddState(moveToIdle)

    local runTool2 = HomeActionState:New(StateId.RunWithDormTool2)
    runTool2:AddTransition(CheckType.Complete, FSMTransitionType.HomeExit, StateId.ExitState)
    runTool2:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool3, StateId.MoveToDormTool3)
    runTool2:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool4, StateId.MoveToDormTool4)
    runTool2:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool5, StateId.MoveToDormTool5)
    runTool2:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool6, StateId.MoveToDormTool6)
    runTool2:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormIdle, StateId.MoveToDormIdle)
    self:AddState(runTool2)

    local runTool3 = HomeActionState:New(StateId.RunWithDormTool3)
    runTool3:AddTransition(CheckType.Complete, FSMTransitionType.HomeExit, StateId.ExitState)
    runTool3:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool4, StateId.MoveToDormTool4)
    runTool3:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool5, StateId.MoveToDormTool5)
    runTool3:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool6, StateId.MoveToDormTool6)
    runTool3:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormIdle, StateId.MoveToDormIdle)
    runTool3:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool2, StateId.MoveToDormTool2)
    self:AddState(runTool3)

    local runTool4 = HomeActionState:New(StateId.RunWithDormTool4)
    runTool4:AddTransition(CheckType.Complete, FSMTransitionType.HomeExit, StateId.ExitState)
    runTool4:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool5, StateId.MoveToDormTool5)
    runTool4:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool6, StateId.MoveToDormTool6)
    runTool4:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormIdle, StateId.MoveToDormIdle)
    runTool4:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool2, StateId.MoveToDormTool2)
    runTool4:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool3, StateId.MoveToDormTool3)
    self:AddState(runTool4)

    local runTool5 = HomeActionState:New(StateId.RunWithDormTool5)
    runTool5:AddTransition(CheckType.Complete, FSMTransitionType.HomeExit, StateId.ExitState)
    runTool5:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool6, StateId.MoveToDormTool6)
    runTool5:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormIdle, StateId.MoveToDormIdle)
    runTool5:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool2, StateId.MoveToDormTool2)
    runTool5:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool3, StateId.MoveToDormTool3)
    runTool5:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool4, StateId.MoveToDormTool4)
    self:AddState(runTool5)

    local runTool6 = HomeActionState:New(StateId.RunWithDormTool6)
    runTool6:AddTransition(CheckType.Complete, FSMTransitionType.HomeExit, StateId.ExitState)
    runTool6:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormIdle, StateId.MoveToDormIdle)
    runTool6:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool2, StateId.MoveToDormTool2)
    runTool6:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool3, StateId.MoveToDormTool3)
    runTool6:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool4, StateId.MoveToDormTool4)
    runTool6:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool5, StateId.MoveToDormTool5)
    self:AddState(runTool6)

    local runIdle = IdleState:New(StateId.RunWithDormIdle)
    runIdle:AddTransition(CheckType.Process, FSMTransitionType.HomeExit, StateId.ExitState)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool2, StateId.MoveToDormTool2)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool3, StateId.MoveToDormTool3)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool4, StateId.MoveToDormTool4)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool5, StateId.MoveToDormTool5)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormTool6, StateId.MoveToDormTool6)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.HomeMoveToDormIdle, StateId.MoveToDormIdle)
    self:AddState(runIdle)

    local exitState = ExitState:New()
    self:AddState(exitState)
end

-----------------------------------------
---自由人需要离开
-----------------------------------------
TransitionHandles[FSMTransitionType.HomeExit] = function(fsm)
    if fsm.owner:GetState() ~= EnumState.Normal then
        return true
    end
    if not SchedulesManager.IsSchdulesActive(fsm.cityId, SchedulesType.Home) then
        return true
    end
    return false
end
-----------------------------------------
---自由人是否可以移动到tool2
-----------------------------------------
TransitionHandles[FSMTransitionType.HomeMoveToDormDoor] = function(fsm)
    if fsm.owner.currGrid.zoneType == ZoneType.Dorm then
        return false
    end
    local target = GridManager.GetGridByZoneId(fsm.cityId, fsm.owner.bedGrid.zoneId, GridMarker.Door)
    if not target then
        fsm.owner:SetPlayAniIdle()
        return false
    end
    fsm:SetMoveInfo(target, fsm:GetSpeedPercent(SchedulesType.Home),AnimationType.Idle)
    return true
end
-----------------------------------------
---自由人是否可以移动到tool2
-----------------------------------------
TransitionHandles[FSMTransitionType.HomeMoveToDormTool2] = function(fsm)
    local target = GridManager.GetGridByZoneId(fsm.cityId, fsm.owner.bedGrid.zoneId, GridMarker.Tool2ForDorm)
    if not target then
        fsm.owner:SetPlayAniIdle()
        return false
    end
    fsm:SetMoveInfo(target,1,AnimationType.Idle)
    return true
end
-----------------------------------------
---自由人是否可以移动到tool3
-----------------------------------------
TransitionHandles[FSMTransitionType.HomeMoveToDormTool3] = function(fsm)
    local target = GridManager.GetGridByZoneId(fsm.cityId, fsm.owner.bedGrid.zoneId, GridMarker.Tool3ForDorm)
    if not target then
        fsm.owner:SetPlayAniIdle()
        return false
    end
    fsm:SetMoveInfo(target,1,AnimationType.Idle)
    return true
end
-----------------------------------------
---自由人是否可以移动到tool4
-----------------------------------------
TransitionHandles[FSMTransitionType.HomeMoveToDormTool4] = function(fsm)
    local target = GridManager.GetGridByZoneId(fsm.cityId, fsm.owner.bedGrid.zoneId, GridMarker.Tool4ForDorm)
    if not target then
        fsm.owner:SetPlayAniIdle()
        return false
    end
    fsm:SetMoveInfo(target,1,AnimationType.Idle)
    return true
end
-----------------------------------------
---自由人是否可以移动到tool5
-----------------------------------------
TransitionHandles[FSMTransitionType.HomeMoveToDormTool5] = function(fsm)
    local target = GridManager.GetGridByZoneId(fsm.cityId, fsm.owner.bedGrid.zoneId, GridMarker.Tool5ForDorm)
    if not target then
        fsm.owner:SetPlayAniIdle()
        return false
    end
    fsm:SetMoveInfo(target,1,AnimationType.Idle)
    return true
end
-----------------------------------------
---自由人是否可以移动到tool6
-----------------------------------------
TransitionHandles[FSMTransitionType.HomeMoveToDormTool6] = function(fsm)
    local target = GridManager.GetGridByZoneId(fsm.cityId, fsm.owner.bedGrid.zoneId, GridMarker.Tool6ForDorm)
    if not target then
        fsm.owner:SetPlayAniIdle()
        return false
    end
    fsm:SetMoveInfo(target,1,AnimationType.Idle)
    return true
end
-----------------------------------------
---自由人是否可以移动到idle
-----------------------------------------
TransitionHandles[FSMTransitionType.HomeMoveToDormIdle] = function(fsm)
    local target = GridManager.GetGridByZoneId(fsm.cityId, fsm.owner.bedGrid.zoneId, GridMarker.Idle)
    if not target then
        fsm.owner:SetPlayAniIdle()
        return false
    end
    fsm:SetMoveInfo(target,1,AnimationType.Idle)
    return true
end
-----------------------------------------
---是否可以和tool2交互
-----------------------------------------
TransitionHandles[FSMTransitionType.HomeRunWithDormTool2] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Tool2ForDorm
end
-----------------------------------------
---是否可以和tool3交互
-----------------------------------------
TransitionHandles[FSMTransitionType.HomeRunWithDormTool3] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Tool3ForDorm
end
-----------------------------------------
---是否可以和tool4交互
-----------------------------------------
TransitionHandles[FSMTransitionType.HomeRunWithDormTool4] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Tool4ForDorm
end
-----------------------------------------
---是否可以和tool5交互
-----------------------------------------
TransitionHandles[FSMTransitionType.HomeRunWithDormTool5] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Tool5ForDorm
end
-----------------------------------------
---是否可以和tool6交互
-----------------------------------------
TransitionHandles[FSMTransitionType.HomeRunWithDormTool6] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Tool6ForDorm
end
