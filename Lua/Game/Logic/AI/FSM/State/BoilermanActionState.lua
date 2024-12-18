BoilermanActionState = Clone(FSMState)
BoilermanActionState.__cname = "BoilermanActionState"

function BoilermanActionState:OnEnter(fsm)
    self:SetDuration(fsm)
    fsm.owner:ShowNodeItem()
end

function BoilermanActionState:OnUpdate(fsm)
end

function BoilermanActionState:OnDone(fsm)
    fsm.owner:HideNodeItem()
end
