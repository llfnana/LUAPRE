FSMCelebrate = Clone(FSMSystem)
FSMCelebrate.__cname = "FSMCelebrate" --庆祝

function FSMCelebrate:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.CelebrateExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.CelebrateRunWithAction, StateId.RunWithCelebrateAction)
    self:AddState(entryState)

    local runCelebrate = CelebrateActionState:New(StateId.RunWithCelebrateAction)
    runCelebrate:AddTransition(CheckType.Process, FSMTransitionType.CelebrateExit, StateId.ExitState)
    self:AddState(runCelebrate)

    local exitState = ExitState:New()
    self:AddState(exitState)
end

-----------------------------------------
---是否退出Celebrate
-----------------------------------------
TransitionHandles[FSMTransitionType.CelebrateExit] = function(fsm)
    return fsm.owner:GetState() ~= EnumState.Celebrate
end
-----------------------------------------
---是否执行Celebrate
-----------------------------------------
TransitionHandles[FSMTransitionType.CelebrateRunWithAction] = function(fsm)
    return fsm.owner:GetState() == EnumState.Celebrate
end
