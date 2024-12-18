EatActionState = Clone(FSMState)
EatActionState.__cname = "EatActionState"

function EatActionState:OnEnter(fsm)
    self:SetDuration(fsm)
    if self.stateId == StateId.RunWithEatStop then
        fsm.owner:SetSchedulesStatus(SchedulesType.Eat, SchedulesStatus.Stop)
        fsm.owner:SetNextSchedules()
    elseif self.stateId == StateId.RunWithServingTable then
        self.dutationTime = self.dutationTime  * 0.2
        fsm.owner:OpenWaringView(false)
        fsm.owner:ShowView(fsm.owner.id, ViewType.Progress, {scale = 1, value = 0})
        fsm.eatFoodType = FoodSystemManager.EatFood(fsm.cityId)
    elseif self.stateId == StateId.RunWithKitchenTable then
        fsm.owner:OpenWaringView(false)
        fsm.owner:ShowNodeItem()
        local foodConfig = ConfigManager.GetFoodConfigByType(fsm.eatFoodType)
        fsm.owner:ShowNecessities(foodConfig.necesities_reward)
    end
end

function EatActionState:OnUpdate(fsm)
    if self.stateId == StateId.RunWithServingTable then
        fsm.owner:UpdateView(fsm.owner.id, ViewType.Progress, {scale = 1, value = self.currProgress})
    elseif self.stateId == StateId.RunWithKitchenTable then
        fsm.owner:UpdateNecessities(self.changeProgress)
    end
end

function EatActionState:OnDone(fsm)
    if self.stateId == StateId.RunWithKitchenTable then
        fsm.owner:SetSchedulesStatus(SchedulesType.Eat, SchedulesStatus.Stop)
        EventManager.Brocast(EventType.CHARACTER_EATING_FOOD, fsm.cityId, fsm.owner.id)
    end
end

function EatActionState:OnExit(fsm)
    if self.stateId == StateId.RunWithServingTable then
        fsm.owner:ShowNodeItem()
        fsm.owner:HideView(fsm.owner.id)
        fsm.owner:OpenWaringView(true)
    elseif self.stateId == StateId.RunWithKitchenTable then
        fsm.eatFoodType = nil
        fsm.owner:HideNodeItem()
        fsm.owner:HideNecessities()
        fsm.owner:OpenWaringView(true)
    end
end
