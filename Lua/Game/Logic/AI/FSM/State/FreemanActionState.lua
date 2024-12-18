FreemanActionState = Clone(FSMState)
FreemanActionState.__cname = "FreemanActionState"

function FreemanActionState:OnEnter(fsm)
    self:SetDuration(fsm)
    fsm.owner:OpenWaringView(false)
    fsm.owner:ShowNecessities()
end

function FreemanActionState:OnUpdate(fsm)
    fsm.owner:UpdateNecessities(self.changeProgress)
end

function FreemanActionState:OnExit(fsm)
    fsm.owner:HideNecessities()
    fsm.owner:OpenWaringView(true)
end
