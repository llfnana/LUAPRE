SleepActionState = Clone(FSMState)
SleepActionState.__cname = "SleepActionState"

function SleepActionState:OnEnter(fsm)
    fsm.owner:OpenWaringView(false)
    fsm.owner:ShowNecessities()
    self.currProgress = SchedulesManager.GetSchedulesProgress(fsm.cityId, SchedulesType.Sleep)
end

function SleepActionState:OnUpdate(fsm)
    local nextProgress = SchedulesManager.GetSchedulesProgress(fsm.cityId, SchedulesType.Sleep)
    if nextProgress > self.currProgress then
        fsm.owner:UpdateNecessities(nextProgress - self.currProgress)
        self.currProgress = nextProgress
    end
end

function SleepActionState:OnExit(fsm)
    fsm.owner:HideNecessities()
    fsm.owner:OpenWaringView(true)
end
