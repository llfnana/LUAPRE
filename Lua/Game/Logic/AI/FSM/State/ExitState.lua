ExitState = Clone(FSMState)
ExitState.__cname = "ExitState"
ExitState.playAnimation = false

function ExitState:OnInit()
    self.stateId = StateId.ExitState
end

function ExitState:OnEnter(fsm)
    fsm.owner:SetNextSchedules()
end

function ExitState:OnUpdate(fsm)
end

function ExitState:OnExit(fsm)
end
