FSMDeath = Clone(FSMSystem)
FSMDeath.__cname = "FSMDeath"

function FSMDeath:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.DeathExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.DeathRunWithAction, StateId.RunWithDeathAction)
    self:AddState(entryState)

    local runAction = DeathActionState:New(StateId.RunWithDeathAction)
    runAction:AddTransition(CheckType.Process, FSMTransitionType.DeathExit, StateId.ExitState)
    self:AddState(runAction)

    local exitState = ExitState:New()
    self:AddState(exitState)
end

-----------------------------------------
---是否退出RunAway
-----------------------------------------
TransitionHandles[FSMTransitionType.DeathExit] = function(fsm)
    return fsm.owner:GetState() ~= EnumState.Dead
end
-----------------------------------------
---是否进入死亡
-----------------------------------------
TransitionHandles[FSMTransitionType.DeathRunWithAction] = function(fsm)
    return fsm.owner:GetState() == EnumState.Dead
end
