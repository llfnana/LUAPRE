DeathActionState = Clone(FSMState)
DeathActionState.__cname = "DeathActionState"
DeathActionState.playAnimation = false

function DeathActionState:OnEnter(fsm)
    self.isTimeLimited = true
    self.startTime = 0
    self.currProgress = 0
    self.dutationTime = 2
    if fsm.owner:GetMarkState() == EnumMarkState.DeathFromHunger then
        fsm.owner:PlayAnimEx(AnimationType.Death)
    end
    fsm.owner:StopMove()
end

function DeathActionState:OnDone(fsm)
    CityPassManager.AddDeathCount(1)
    CharacterManager.RemoveCharacter(fsm.owner.cityId, fsm.owner.id)
    fsm.owner:DeActive()
end
