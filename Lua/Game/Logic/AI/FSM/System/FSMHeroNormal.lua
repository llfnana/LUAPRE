FSMHeroNormal = Clone(FSMSystem)
FSMHeroNormal.__cname = "FSMHeroNormal"

function FSMHeroNormal:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.HeroExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.HeroMoveToIdle, StateId.MoveToHeroIdle)
    self:AddState(entryState)

    local moveIdle = MoveState:New(StateId.MoveToHeroIdle)
    moveIdle:AddTransition(CheckType.Process, FSMTransitionType.HeroExit, StateId.ExitState)
    moveIdle:AddTransition(CheckType.Complete, FSMTransitionType.StayAtIdle, StateId.RunWithHeroIdle)
    self:AddState(moveIdle)

    local runIdle = IdleState:New(StateId.RunWithHeroIdle)
    runIdle:AddTransition(CheckType.Process, FSMTransitionType.HeroExit, StateId.ExitState)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.HeroMoveToIdle, StateId.MoveToHeroIdle)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.StayAtIdle, StateId.RunWithHeroIdle)
    self:AddState(runIdle)

    local exitState = ExitState:New()
    self:AddState(exitState)
end

-----------------------------------------
---是否退出Boilerman
-----------------------------------------
TransitionHandles[FSMTransitionType.HeroExit] = function(fsm)
    return fsm.owner:GetState() ~= EnumState.Normal
end

-----------------------------------------
---是否可以移动HeroMoveToIdle
-----------------------------------------
TransitionHandles[FSMTransitionType.HeroMoveToIdle] = function(fsm)
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Idle, fsm.owner.zoneType)
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
