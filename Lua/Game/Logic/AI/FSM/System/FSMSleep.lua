FSMSleep = Clone(FSMSystem)
FSMSleep.__cname = "FSMSleep"

function FSMSleep:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.SleepExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.SleepMoveToDormDoor, StateId.MoveToDormDoor)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.SleepMoveToDormBed, StateId.MoveToDormBed)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.StayAtBed, StateId.RunWithDormBed)
    self:AddState(entryState)

    local moveToDoor = MoveState:New(StateId.MoveToDormDoor)
    moveToDoor:AddTransition(CheckType.Process, FSMTransitionType.SleepExit, StateId.ExitState)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.SleepMoveToDormBed, StateId.MoveToDormBed)
    self:AddState(moveToDoor)

    local moveToBed = MoveState:New(StateId.MoveToDormBed)
    moveToBed:AddTransition(CheckType.Process, FSMTransitionType.SleepExit, StateId.ExitState)
    moveToBed:AddTransition(CheckType.Complete, FSMTransitionType.StayAtBed, StateId.RunWithDormBed)
    self:AddState(moveToBed)

    local runBed = SleepActionState:New(StateId.RunWithDormBed)
    runBed:AddTransition(CheckType.Process, FSMTransitionType.SleepExit, StateId.ExitState)
    self:AddState(runBed)

    local exitState = ExitState:New()
    self:AddState(exitState)
end
-----------------------------------------
---是否需要离开睡觉
-----------------------------------------
TransitionHandles[FSMTransitionType.SleepExit] = function(fsm)
    if fsm.owner:GetState() ~= EnumState.Normal then
         fsm.owner:BrocastSleepExit()
        return true
    end
    if not SchedulesManager.IsSchdulesActive(fsm.cityId, SchedulesType.Sleep) then
        return true
    end
    if SchedulesManager.IsSchdulesActive(fsm.cityId, SchedulesType.Arbeit_OverTime) then
        return WorkOverTimeManager.IsCanWorkOverTimeByZoneType(fsm.cityId, fsm.owner.peopleConfig.zone_type)
    end
    return false
end
-----------------------------------------
---是否可以移动到宿舍门口
-----------------------------------------
TransitionHandles[FSMTransitionType.SleepMoveToDormDoor] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    if fsm.owner.currGrid.zoneType == ZoneType.Dorm then
        return false
    end
    local target = GridManager.GetGridByZoneId(fsm.cityId, fsm.owner.bedGrid.zoneId, GridMarker.Door)
    if not target then
        return false
    end
    fsm:SetMoveInfo(target, fsm:GetSpeedPercent(SchedulesType.Sleep))
    return true
end
-----------------------------------------
---是否可以移动到床
-----------------------------------------
TransitionHandles[FSMTransitionType.SleepMoveToDormBed] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    if fsm.owner.currGrid.markerType == GridMarker.Bed then
        return false
    end
    fsm:SetMoveInfo(fsm.owner.bedGrid,1,"sleeping")
    return true
end
