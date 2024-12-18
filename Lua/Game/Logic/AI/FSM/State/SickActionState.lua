SickActionState = Clone(FSMState)
SickActionState.__cname = "SickActionState"
SickActionState.playAnimation = false


function SickActionState:SetDuration(fsm)
    self.isTimeLimited = true
    self.startTime = 0
    self.dutationTime = fsm.owner:GetMedicalTime()
    self.currProgress = 0
end

function SickActionState:OnEnter(fsm)
    if self.stateId == StateId.RunWithSickAction then
        fsm.owner:PlayAnimEx(AnimationType.SickSleep)
        self:SetDuration(fsm)
        fsm.owner:SetHealCount()
        fsm.owner:SetHealStatus(true)
        fsm.owner:ShowView(fsm.owner.id, ViewType.Progress, {scale = 1, value = fsm.owner:GetSickProgress()})
    elseif self.stateId == StateId.RunWithSevereChange then
        fsm.owner:SetNextState(EnumState.Severe)
        fsm.owner:HideView(fsm.owner.id)
    end
end

-- 一次生病需要多次治疗，但进度不是显示多次治疗的进度，而是总治疗进度
function SickActionState:OnUpdate(fsm)
    local healTime = fsm.owner:GetMedicalValue() * (self.currProgress or 0)
    -- 注意 UpdateView 其实就是ShowView， 所以要先做个判断
    if fsm.owner:GetState() == EnumState.Sick then 
        fsm.owner:UpdateView(fsm.owner.id, ViewType.Progress, {scale = 1, value = fsm.owner:GetSickHealProgress(healTime)})
    end
    self:HideProgressView(fsm)
end


function SickActionState:OnDone(fsm)
    fsm.owner:SetHealStatus(false)
    fsm.owner:ReduceSickTime(fsm.owner:GetMedicalValue(), true, fsm.owner.isGuideHeal)
    -- 治疗成功了，再关闭进度
    self:HideProgressView(fsm)
    if fsm.owner:GetSickTime() <= 0 then
        fsm.owner.isGuideHeal = false
    end
    fsm.sickEntity = nil
end


function SickActionState:OnExit(fsm)
    self:HideProgressView(fsm)
end

function SickActionState:HideProgressView(fsm)
    if fsm.owner:GetState() ~= EnumState.Sick then 
        fsm.owner:HideView(fsm.owner.id)
    end
end
