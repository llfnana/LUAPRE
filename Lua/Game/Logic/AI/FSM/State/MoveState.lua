MoveState = Clone(FSMState)
MoveState.__cname = "MoveState"
MoveState.playAnimation = false

function MoveState:OnEnter(fsm)
    fsm:EnterMove()
end

function MoveState:OnUpdate(fsm)
    fsm:UpdateMove()
end

function MoveState:OnDone(fsm)
    fsm:DoneMove()
end
