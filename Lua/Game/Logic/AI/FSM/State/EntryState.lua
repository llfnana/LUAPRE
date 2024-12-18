EntryState = Clone(FSMState)
EntryState.__cname = "EntryState"
EntryState.playAnimation = false

function EntryState:OnInit()
    self.stateId = StateId.EntryState
end

function EntryState:OnEnter(fsm)
end

function EntryState:OnUpdate(fsm)
end

function EntryState:OnExit(fsm)
end
