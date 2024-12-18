FSMSevere = Clone(FSMSystem)
FSMSevere.__cname = "FSMSevere"

function FSMSevere:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.SevereExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.SevereMoveToMedicalBed, StateId.MoveToMedicalBed)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.SevereMoveToDormBed, StateId.MoveToDormBed)
    self:AddState(entryState)

    local moveMedicalBed = MoveState:New(StateId.MoveToMedicalBed)
    moveMedicalBed:AddTransition(CheckType.Process, FSMTransitionType.SevereExit, StateId.ExitState)
    moveMedicalBed:AddTransition(CheckType.Complete, FSMTransitionType.StayAtMedicalBed, StateId.RunWithSevereAction)
    self:AddState(moveMedicalBed)

    local moveDormBed = MoveState:New(StateId.MoveToDormBed)
    moveDormBed:AddTransition(CheckType.Process, FSMTransitionType.SevereExit, StateId.ExitState)
    moveDormBed:AddTransition(CheckType.Process, FSMTransitionType.SevereMoveToMedicalBed, StateId.MoveToMedicalBed)
    moveDormBed:AddTransition(CheckType.Complete, FSMTransitionType.StayAtBed, StateId.RunWithSevereAction)
    self:AddState(moveDormBed)

    local runAction = SevereActionState:New(StateId.RunWithSevereAction)
    runAction:AddTransition(CheckType.Process, FSMTransitionType.SevereExit, StateId.ExitState)
    self:AddState(runAction)

    local exitState = ExitState:New()
    self:AddState(exitState)
end

-----------------------------------------
---是否退出Severe
-----------------------------------------
TransitionHandles[FSMTransitionType.SevereExit] = function(fsm)
    return fsm.owner:GetState() ~= EnumState.Severe
end
-----------------------------------------
---是否可以移动到医疗床
-----------------------------------------
TransitionHandles[FSMTransitionType.SevereMoveToMedicalBed] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    if fsm.owner.currGrid.markerType == GridMarker.MedicalBed then
        return false
    end
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.MedicalBed, ZoneType.Infirmary)
    if not target then
        return false
    end
    fsm.owner:SetHealZone(target)
    fsm:SetMoveInfo(target)
    return true
end
-----------------------------------------
---是否移动到宿舍床
-----------------------------------------
TransitionHandles[FSMTransitionType.SevereMoveToDormBed] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    if fsm.owner.currGrid.markerType == GridMarker.Bed then
        return false
    end
    local target = fsm.owner.bedGrid
    if not target then
        return false
    end
    fsm.owner:SetHealZone(target)
    fsm:SetMoveInfo(target)
    return true
end
