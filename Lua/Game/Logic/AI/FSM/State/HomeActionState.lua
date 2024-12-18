HomeActionState = Clone(FSMState)
HomeActionState.__cname = "HomeActionState"

function HomeActionState:OnEnter(fsm)
    self:SetDuration(fsm)
    fsm.owner:OpenWaringView(false)
    fsm.owner:ShowNecessities()
end

function HomeActionState:OnUpdate(fsm)
    fsm.owner:UpdateNecessities(self.changeProgress)
end

function HomeActionState:OnExit(fsm)
    fsm.owner:HideNecessities()
    fsm.owner:OpenWaringView(true)
end
