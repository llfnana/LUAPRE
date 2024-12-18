ProtestActionState = Clone(FSMState)
ProtestActionState.__cname = "ProtestActionState"

function ProtestActionState:OnEnter(fsm)
    fsm.owner:OpenWaringView(false)
    fsm.owner:ShowNodeItem()
end

function ProtestActionState:OnUpdate(fsm)
end

function ProtestActionState:OnExit(fsm)
    fsm.owner:OpenWaringView(true)
    fsm.owner:HideNodeItem()
end
