CookingActionState = Clone(FSMState)
CookingActionState.__cname = "CookingActionState"

function CookingActionState:OnEnter(fsm)
    if self.stateId == StateId.RunWithKitchenBurner then
        self:SetDuration(fsm, true)
        fsm.owner:ShowNodeItem()
        fsm.owner:ShowView(fsm.owner.id, ViewType.Progress, {scale = 1, value = 0})
        fsm.owner:OpenWaringView(false)
        FoodSystemManager.StartCooking(fsm.cityId)
    elseif self.stateId == StateId.RunWithKitchenSpecial1 then
        self:SetDuration(fsm)
        fsm.owner:ShowNodeItem()
    end
end

function CookingActionState:OnUpdate(fsm)
    if self.stateId == StateId.RunWithKitchenBurner then
        fsm.owner:UpdateView(fsm.owner.id, ViewType.Progress, {scale = 1, value = self.currProgress})
    end
end

function CookingActionState:OnDone(fsm)
    if self.stateId == StateId.RunWithKitchenBurner then
        fsm.owner:HideNodeItem()
        fsm.owner:HideView(fsm.owner.id, true)
        fsm.owner:OpenWaringView(true)
        FoodSystemManager.EndCooking(fsm.cityId)
    end
end

function CookingActionState:OnExit(fsm)
    if self.stateId == StateId.RunWithKitchenSpecial1 then
        fsm.owner:HideNodeItem()
    end
end
