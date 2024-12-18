ArbeitActionState = Clone(FSMState)
ArbeitActionState.__cname = "ArbeitActionState"

function ArbeitActionState:OnEnter(fsm)
    fsm.owner:ShowNodeItem()
    fsm.owner:OpenWaringView(false)
    fsm:ProductionEnter()
end

function ArbeitActionState:OnUpdate(fsm)
    if fsm:ProductionUpdate() then
        self:DoneState(fsm)
    end
end

function ArbeitActionState:OnExit(fsm)
    fsm:ProductionQuit()
    fsm.owner:HideNodeItem()
    fsm.owner:OpenWaringView(true)
end
