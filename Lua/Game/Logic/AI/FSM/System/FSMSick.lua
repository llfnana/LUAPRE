FSMSick = Clone(FSMSystem)
FSMSick.__cname = "FSMSick"

function FSMSick:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.SickExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.SickRunWithAction, StateId.RunWithSickAction)
    self:AddState(entryState)

    local runSick = SickActionState:New(StateId.RunWithSickAction)
    runSick:AddTransition(CheckType.Process, FSMTransitionType.SickExit, StateId.ExitState)
    runSick:AddTransition(CheckType.Process, FSMTransitionType.SickChangeToSevere, StateId.RunWithSevereChange)
    self:AddState(runSick)

    local runChange = SickActionState:New(StateId.RunWithSevereChange)
    runChange:AddTransition(CheckType.Process, FSMTransitionType.SickExit, StateId.ExitState)
    self:AddState(runChange)

    local exitState = ExitState:New()
    self:AddState(exitState)
end

-----------------------------------------
---是否退出Sick
-----------------------------------------
TransitionHandles[FSMTransitionType.SickExit] = function(fsm)
    return fsm.owner:GetState() ~= EnumState.Sick
end

-----------------------------------------
---是否执行Sick
-----------------------------------------
TransitionHandles[FSMTransitionType.SickRunWithAction] = function(fsm)
    return fsm.owner:GetState() == EnumState.Sick
end

-----------------------------------------
---是否切换到Severe
-----------------------------------------
TransitionHandles[FSMTransitionType.SickChangeToSevere] = function(fsm)
    if fsm.owner.currGrid.zoneType == ZoneType.Dorm then
        local targetGrid = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.MedicalBed, ZoneType.Infirmary)
        if nil ~= targetGrid then
            return true
        end
    end
    return false
end
