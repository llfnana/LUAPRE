RunAwayActionState = Clone(FSMState)
RunAwayActionState.__cname = "RunAwayActionState"
RunAwayActionState.playAnimation = false

function RunAwayActionState:OnEnter(fsm)
    CityPassManager.AddDeathCount(1)
    CharacterManager.RemoveCharacter(fsm.cityId, fsm.owner.id)
    fsm.owner:DeActive()
end
