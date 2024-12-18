GuardActionState = Clone(FSMState)
GuardActionState.__cname = "GuardActionState"

function GuardActionState:OnEnter(fsm)
    fsm.owner:ShowNodeItem()
end

function GuardActionState:OnUpdate(fsm)
    if not ProtestManager.IsProtestStatus(fsm.cityId) then
        self:DoneState(fsm)
    end
end

function GuardActionState:OnDone(fsm)
    fsm.owner:HideNodeItem()
end
