SevereActionState = Clone(FSMState)
SevereActionState.__cname = "SevereActionState"
SevereActionState.playAnimation = false

function SevereActionState:OnEnter(fsm)
    fsm.owner:SetNextState(EnumState.Sick)
end
