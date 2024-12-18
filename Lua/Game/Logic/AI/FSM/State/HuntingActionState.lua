HuntingActionState = Clone(FSMState)
HuntingActionState.__cname = "HuntingActionState"

function HuntingActionState:OnEnter(fsm)
    self:SetDuration(fsm)
    if self.stateId == StateId.RunWithHunterCabinTool then
        fsm.owner:OpenWaringView(false)
        fsm.owner:ShowView(fsm.owner.id, ViewType.Progress, {scale = 1, value = 0})
    elseif self.stateId == StateId.RunWithHunt then
        fsm.owner:HideNodeItem()
        fsm.owner:ShowView(fsm.owner.id, ViewType.Progress, {scale = 1, value = 0})
    elseif self.stateId == StateId.RunWithItems then
        fsm.owner:HideNodeItem()
        fsm.owner:OpenWaringView(true)
        --显示打猎产出
        local realOutput = FoodSystemManager.EndUseTool(fsm.cityId, fsm.toolId, fsm.toolIndex)
        local viewParams = List:New()
        for itemType, itemValue in pairs(realOutput) do
            local info = {}
            info.type = itemType
            info.iconFun = Utils.SetItemIcon
            info.iconParams = itemType
            info.selectIndex = 3
            info.value = itemValue
            viewParams:Add(info)
        end
        fsm.owner:ShowView("Tips_%s" .. fsm.owner.id, ViewType.Tips, viewParams)
        fsm.owner:SetSchedulesStatus(SchedulesType.Hunting, SchedulesStatus.Completed)
    elseif self.stateId == StateId.RunWithHunterCabinSpecial1 then
        fsm.owner:ShowNodeItem()
    end
end

function HuntingActionState:OnUpdate(fsm)
    if self.stateId == StateId.RunWithHunterCabinTool then
        fsm.owner:UpdateView(fsm.owner.id, ViewType.Progress, {scale = 1, value = self.currProgress})
    elseif self.stateId == StateId.RunWithHunt then
        fsm.owner:UpdateView(fsm.owner.id, ViewType.Progress, {scale = 1, value = self.currProgress})
    end
end

function HuntingActionState:OnDone(fsm)
    if self.stateId == StateId.RunWithHunterCabinTool then
        fsm.owner:HideView(fsm.owner.id)
        fsm.owner:ShowNodeItem()
        fsm.toolId = fsm.owner.currGrid.furnitureId
        fsm.toolIndex = fsm.owner.currGrid.markerIndex
        FoodSystemManager.StartUseTool(fsm.cityId, fsm.toolId, fsm.toolIndex)
    elseif self.stateId == StateId.RunWithHunt then
        fsm.owner:HideView(fsm.owner.id)
        fsm.owner:ShowNodeItem()
    end
end

function HuntingActionState:OnExit(fsm)
    if self.stateId == StateId.RunWithHunterCabinSpecial1 then
        fsm.owner:HideNodeItem()
    end
end
