StrikeActionState = Clone(FSMState)
StrikeActionState.__cname = "StrikeActionState"
StrikeActionState.playAnimation = false

function StrikeActionState:OnEnter(fsm)
    CityPassManager.AddDeathCount(1)
    CharacterManager.RemoveCharacter(fsm.cityId, fsm.owner.id)
    fsm.owner:DeActive()
end
