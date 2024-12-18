VanActionState = Clone(FSMState)
VanActionState.__cname = "VanActionState"
VanActionState.playAnimation = false

function VanActionState:OnEnter(fsm)
    self.isTimeLimited = true
    self.startTime = 0
    self.currProgress = 0
    if self.stateId == StateId.RunWithWarehouseTool then
        if
            TutorialManager.CurrentStep.value == TutorialStep.EventCarMove or
                TutorialManager.CurrentStep.value == TutorialStep.EventCarMove1002
         then
            self.dutationTime = 3
        else
            self.dutationTime = fsm.owner.currGrid:GetUsageDuration()
        end
        fsm.owner:ShowView(fsm.owner.id, ViewType.Progress, {scale = 2, value = 0})
    elseif self.stateId == StateId.RunWithVanBorn then
        -- self.dutationTime = EventSceneManager.GetVanDeliveringTime()
        -- local born = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.VanBorn, ZoneType.MainRoad)
        -- fsm.owner:ChangeCurrGrid(born, true)
        -- fsm.owner:HideVanView()
    end
end

function VanActionState:OnUpdate(fsm)
    if self.stateId == StateId.RunWithWarehouseTool then
        fsm.owner:UpdateView(fsm.owner.id, ViewType.Progress, {scale = 2, value = self.currProgress})
    end
end

function VanActionState:OnDone(fsm)
    if self.stateId == StateId.RunWithWarehouseTool then
        fsm.owner:HideView(fsm.owner.id)
        fsm.owner:ShowCashView()
    elseif self.stateId == StateId.RunWithVanBorn then
        fsm.owner:ShowVanView()
    end
end
