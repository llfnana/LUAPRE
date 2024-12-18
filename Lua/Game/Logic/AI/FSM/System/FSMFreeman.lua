FSMFreeman = Clone(FSMSystem)
FSMFreeman.__cname = "FSMFreeman"

function FSMFreeman:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.FreemanExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.FreemanMoveToDormDoor, StateId.MoveToDormDoor)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.FreemanMoveToDormTool2, StateId.MoveToDormTool2)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.FreemanMoveToDormTool3, StateId.MoveToDormTool3)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.FreemanMoveToDormTool4, StateId.MoveToDormTool4)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.FreemanMoveToDormTool5, StateId.MoveToDormTool5)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.FreemanMoveToDormTool6, StateId.MoveToDormTool6)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.FreemanMoveToDormIdle, StateId.MoveToDormIdle)
    self:AddState(entryState)

    local moveToDoor = MoveState:New(StateId.MoveToDormDoor)
    moveToDoor:AddTransition(CheckType.Process, FSMTransitionType.FreemanExit, StateId.ExitState)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool2, StateId.MoveToDormTool2)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool3, StateId.MoveToDormTool3)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool4, StateId.MoveToDormTool4)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool5, StateId.MoveToDormTool5)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool6, StateId.MoveToDormTool6)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormIdle, StateId.MoveToDormIdle)
    self:AddState(moveToDoor)

    local moveToTool2 = MoveState:New(StateId.MoveToDormTool2)
    moveToTool2:AddTransition(CheckType.Process, FSMTransitionType.FreemanExit, StateId.ExitState)
    moveToTool2:AddTransition(CheckType.Complete, FSMTransitionType.FreemanRunWithDormTool2, StateId.RunWithDormTool2)
    self:AddState(moveToTool2)

    local moveToTool3 = MoveState:New(StateId.MoveToDormTool3)
    moveToTool3:AddTransition(CheckType.Process, FSMTransitionType.FreemanExit, StateId.ExitState)
    moveToTool3:AddTransition(CheckType.Complete, FSMTransitionType.FreemanRunWithDormTool3, StateId.RunWithDormTool3)
    self:AddState(moveToTool3)

    local moveToTool4 = MoveState:New(StateId.MoveToDormTool4)
    moveToTool4:AddTransition(CheckType.Process, FSMTransitionType.FreemanExit, StateId.ExitState)
    moveToTool4:AddTransition(CheckType.Complete, FSMTransitionType.FreemanRunWithDormTool4, StateId.RunWithDormTool4)
    self:AddState(moveToTool4)

    local moveToTool5 = MoveState:New(StateId.MoveToDormTool5)
    moveToTool5:AddTransition(CheckType.Process, FSMTransitionType.FreemanExit, StateId.ExitState)
    moveToTool5:AddTransition(CheckType.Complete, FSMTransitionType.FreemanRunWithDormTool5, StateId.RunWithDormTool5)
    self:AddState(moveToTool5)

    local moveToTool6 = MoveState:New(StateId.MoveToDormTool6)
    moveToTool6:AddTransition(CheckType.Process, FSMTransitionType.FreemanExit, StateId.ExitState)
    moveToTool6:AddTransition(CheckType.Complete, FSMTransitionType.FreemanRunWithDormTool6, StateId.RunWithDormTool6)
    self:AddState(moveToTool6)

    local moveToIdle = MoveState:New(StateId.MoveToDormIdle)
    moveToIdle:AddTransition(CheckType.Process, FSMTransitionType.FreemanExit, StateId.ExitState)
    moveToIdle:AddTransition(CheckType.Complete, FSMTransitionType.StayAtIdle, StateId.RunWithDormIdle)
    self:AddState(moveToIdle)

    local runTool2 = FreemanActionState:New(StateId.RunWithDormTool2)
    runTool2:AddTransition(CheckType.Complete, FSMTransitionType.FreemanExit, StateId.ExitState)
    runTool2:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool3, StateId.MoveToDormTool3)
    runTool2:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool4, StateId.MoveToDormTool4)
    runTool2:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool5, StateId.MoveToDormTool5)
    runTool2:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool6, StateId.MoveToDormTool6)
    runTool2:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormIdle, StateId.MoveToDormIdle)
    self:AddState(runTool2)

    local runTool3 = FreemanActionState:New(StateId.RunWithDormTool3)
    runTool3:AddTransition(CheckType.Complete, FSMTransitionType.FreemanExit, StateId.ExitState)
    runTool3:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool4, StateId.MoveToDormTool4)
    runTool3:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool5, StateId.MoveToDormTool5)
    runTool3:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool6, StateId.MoveToDormTool6)
    runTool3:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormIdle, StateId.MoveToDormIdle)
    runTool3:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool2, StateId.MoveToDormTool2)
    self:AddState(runTool3)

    local runTool4 = FreemanActionState:New(StateId.RunWithDormTool4)
    runTool4:AddTransition(CheckType.Complete, FSMTransitionType.FreemanExit, StateId.ExitState)
    runTool4:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool5, StateId.MoveToDormTool5)
    runTool4:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool6, StateId.MoveToDormTool6)
    runTool4:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormIdle, StateId.MoveToDormIdle)
    runTool4:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool2, StateId.MoveToDormTool2)
    runTool4:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool3, StateId.MoveToDormTool3)
    self:AddState(runTool4)

    local runTool5 = FreemanActionState:New(StateId.RunWithDormTool5)
    runTool5:AddTransition(CheckType.Complete, FSMTransitionType.FreemanExit, StateId.ExitState)
    runTool5:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool6, StateId.MoveToDormTool6)
    runTool5:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormIdle, StateId.MoveToDormIdle)
    runTool5:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool2, StateId.MoveToDormTool2)
    runTool5:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool3, StateId.MoveToDormTool3)
    runTool5:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool4, StateId.MoveToDormTool4)
    self:AddState(runTool5)

    local runTool6 = FreemanActionState:New(StateId.RunWithDormTool6)
    runTool6:AddTransition(CheckType.Complete, FSMTransitionType.FreemanExit, StateId.ExitState)
    runTool6:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormIdle, StateId.MoveToDormIdle)
    runTool6:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool2, StateId.MoveToDormTool2)
    runTool6:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool3, StateId.MoveToDormTool3)
    runTool6:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool4, StateId.MoveToDormTool4)
    runTool6:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool5, StateId.MoveToDormTool5)
    self:AddState(runTool6)

    local runIdle = IdleState:New(StateId.RunWithDormIdle)
    runIdle:AddTransition(CheckType.Process, FSMTransitionType.FreemanExit, StateId.ExitState)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool2, StateId.MoveToDormTool2)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool3, StateId.MoveToDormTool3)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool4, StateId.MoveToDormTool4)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool5, StateId.MoveToDormTool5)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormTool6, StateId.MoveToDormTool6)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.FreemanMoveToDormIdle, StateId.MoveToDormIdle)
    self:AddState(runIdle)

    local exitState = ExitState:New()
    self:AddState(exitState)
end

-----------------------------------------
---自由人需要离开
-----------------------------------------
TransitionHandles[FSMTransitionType.FreemanExit] = function(fsm)
    if fsm.owner:GetState() ~= EnumState.Normal then
        return true
    end
    if fsm.owner:GetProfessionType() ~= ProfessionType.FreeMan then
        if SchedulesManager.IsSchdulesActive(fsm.cityId, SchedulesType.Arbeit) then
            return true
        end
    end
    if SchedulesManager.IsSchdulesActive(fsm.cityId, SchedulesType.Eat) then
        if fsm.owner:GetSchedulesStatus(SchedulesType.Eat) ~= SchedulesStatus.Stop then
            return true
        end
    end
    if SchedulesManager.IsSchdulesActive(fsm.cityId, SchedulesType.Sleep) then
        return true
    end
    return false
end
-----------------------------------------
---自由人是否可以移动到宿舍门
-----------------------------------------
TransitionHandles[FSMTransitionType.FreemanMoveToDormDoor] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    if fsm.owner.currGrid.zoneType == ZoneType.Dorm then
        return false
    end
    local target = GridManager.GetGridByZoneId(fsm.cityId, fsm.owner.bedGrid.zoneId, GridMarker.Door)
    if not target then
        fsm.owner:SetPlayAniIdle()
        return false
    end
    fsm:SetMoveInfo(target, fsm:GetSpeedPercent(SchedulesType.None))
    return true
end
-----------------------------------------
---自由人是否可以移动到tool2
-----------------------------------------
TransitionHandles[FSMTransitionType.FreemanMoveToDormTool2] = function(fsm)
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
TransitionHandles[FSMTransitionType.FreemanMoveToDormTool3] = function(fsm)
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
TransitionHandles[FSMTransitionType.FreemanMoveToDormTool4] = function(fsm)
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
TransitionHandles[FSMTransitionType.FreemanMoveToDormTool5] = function(fsm)
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
TransitionHandles[FSMTransitionType.FreemanMoveToDormTool6] = function(fsm)
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
TransitionHandles[FSMTransitionType.FreemanMoveToDormIdle] = function(fsm)
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
TransitionHandles[FSMTransitionType.FreemanRunWithDormTool2] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Tool2ForDorm
end
-----------------------------------------
---是否可以和tool3交互
-----------------------------------------
TransitionHandles[FSMTransitionType.FreemanRunWithDormTool3] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Tool3ForDorm
end
-----------------------------------------
---是否可以和tool4交互
-----------------------------------------
TransitionHandles[FSMTransitionType.FreemanRunWithDormTool4] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Tool4ForDorm
end
-----------------------------------------
---是否可以和tool5交互
-----------------------------------------
TransitionHandles[FSMTransitionType.FreemanRunWithDormTool5] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Tool5ForDorm
end
-----------------------------------------
---是否可以和tool6交互
-----------------------------------------
TransitionHandles[FSMTransitionType.FreemanRunWithDormTool6] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Tool6ForDorm
end
