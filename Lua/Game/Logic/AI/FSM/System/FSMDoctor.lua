FSMDoctor = Clone(FSMSystem)
FSMDoctor.__cname = "FSMDoctor"

function FSMDoctor:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.DoctorExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.DoctorMoveToDoctor, StateId.MoveToDoctor)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.DoctorMoveToInfirmaryIdle, StateId.MoveToInfirmaryIdle)
    self:AddState(entryState)

    local moveDoctor = MoveState:New(StateId.MoveToDoctor)
    moveDoctor:AddTransition(CheckType.Process, FSMTransitionType.DoctorExit, StateId.ExitState)
    moveDoctor:AddTransition(CheckType.Complete, FSMTransitionType.DoctorRunWithDoctor, StateId.RunWithDoctor)
    moveDoctor:AddTransition(CheckType.Complete, FSMTransitionType.DoctorMoveToDoctor, StateId.MoveToDoctor)
    moveDoctor:AddTransition(CheckType.Complete, FSMTransitionType.DoctorMoveToInfirmaryIdle, StateId.MoveToInfirmaryIdle)
    self:AddState(moveDoctor)

    local runDoctor = DoctorActionState:New(StateId.RunWithDoctor)
    runDoctor:AddTransition(CheckType.Process, FSMTransitionType.DoctorExit, StateId.ExitState)
    runDoctor:AddTransition(CheckType.Complete, FSMTransitionType.DoctorMoveToDoctor, StateId.MoveToDoctor)
    runDoctor:AddTransition(CheckType.Complete, FSMTransitionType.DoctorRunWithDoctor, StateId.RunWithDoctor)
    runDoctor:AddTransition(CheckType.Complete, FSMTransitionType.DoctorMoveToInfirmaryIdle, StateId.MoveToInfirmaryIdle)
    self:AddState(runDoctor)

    local moveIdle = MoveState:New(StateId.MoveToInfirmaryIdle)
    moveIdle:AddTransition(CheckType.Process, FSMTransitionType.DoctorExit, StateId.ExitState)
    moveIdle:AddTransition(CheckType.Process, FSMTransitionType.DoctorMoveToDoctor, StateId.MoveToDoctor)
    moveIdle:AddTransition(CheckType.Complete, FSMTransitionType.StayAtIdle, StateId.RunWithInfirmaryIdle)
    self:AddState(moveIdle)

    local runIdle = IdleState:New(StateId.RunWithInfirmaryIdle)
    runIdle:AddTransition(CheckType.Process, FSMTransitionType.DoctorExit, StateId.ExitState)
    runIdle:AddTransition(CheckType.Process, FSMTransitionType.DoctorMoveToDoctor, StateId.MoveToDoctor)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.DoctorMoveToInfirmaryIdle, StateId.MoveToInfirmaryIdle)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.StayAtIdle, StateId.RunWithInfirmaryIdle)
    self:AddState(runIdle)

    local exitState = ExitState:New()
    self:AddState(exitState)
end

-----------------------------------------
---是否退出Doctor
-----------------------------------------
TransitionHandles[FSMTransitionType.DoctorExit] = function(fsm)
    return fsm.owner:GetState() ~= EnumState.Normal
end

-----------------------------------------
---是否可以移动到doctor点
-----------------------------------------
TransitionHandles[FSMTransitionType.DoctorMoveToDoctor] = function(fsm)
    local sickList = CharacterManager.GetCharactersBySickZone(fsm.cityId, ZoneType.Infirmary, EnumState.Sick)
    local sickCount = sickList:Count()
    if sickCount <= 0 then
        return false
    end
    local sickEntity = sickList[math.random(sickCount)]
    fsm.sickEntity = sickEntity
    local markerIndex = sickEntity.currGrid.markerIndex
    if fsm.owner.currGrid.markerType == GridMarker.Doctor and fsm.owner.currGrid.markerIndex == markerIndex then
        return false
    end
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Doctor, ZoneType.Infirmary, markerIndex)
    if not target then
        return false
    end
    fsm:SetMoveInfo(target, 2)
    return true
end
-----------------------------------------
---是否可以移动到idle点
-----------------------------------------
TransitionHandles[FSMTransitionType.DoctorMoveToInfirmaryIdle] = function(fsm)
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Idle, ZoneType.Infirmary)
    if not target then
        return false
    end
    if fsm.owner.currGrid == target then
        return false
    end
    fsm:SetMoveInfo(target)
    return true
end
-----------------------------------------
---是否可以运行doctor
-----------------------------------------
TransitionHandles[FSMTransitionType.DoctorRunWithDoctor] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    if fsm.owner.currGrid.markerType ~= GridMarker.Doctor then
        return false
    end
    if nil == fsm.sickEntity then
        return false
    end
    if fsm.sickEntity:GetState() ~= EnumState.Sick then
        return false
    end
    return true
end
