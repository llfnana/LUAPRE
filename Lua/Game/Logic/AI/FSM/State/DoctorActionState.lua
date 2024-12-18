DoctorActionState = Clone(FSMState)
DoctorActionState.__cname = "DoctorActionState"

--设置持续时间
function DoctorActionState:SetDuration(fsm)
    self.isTimeLimited = true
    self.startTime = 0
    self.dutationTime = fsm.owner:GetMedicalTime()
    self.currProgress = 0
end

function DoctorActionState:OnEnter(fsm)
    self:SetDuration(fsm)
    fsm.sickEntity:SetHealCount()
    fsm.sickEntity:SetHealStatus(true)
    fsm.owner:ShowView(fsm.owner.id, ViewType.Progress, {scale = 1, value = 0})
end

function DoctorActionState:OnUpdate(fsm)
    fsm.owner:UpdateView(fsm.owner.id, ViewType.Progress, {scale = 1, value = self.currProgress})
end

function DoctorActionState:OnDone(fsm)
    fsm.owner:HideView(fsm.owner.id)
    fsm.sickEntity:SetHealStatus(false)
    fsm.sickEntity:ReduceSickTime(fsm.owner:GetMedicalValue(), true, fsm.owner.isGuideHeal)
    if fsm.sickEntity:GetSickTime() <= 0 then
        fsm.owner.isGuideHeal = false
    end
    fsm.sickEntity = nil
end
