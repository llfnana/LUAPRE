IdleState = Clone(FSMState)
IdleState.__cname = "IdleState"
IdleState.playAnimation = false

function IdleState:OnEnter(fsm)
    self:SetDuration(fsm)
end

function IdleState:OnUpdate(fsm)
end

function IdleState:OnExit(fsm)
end
