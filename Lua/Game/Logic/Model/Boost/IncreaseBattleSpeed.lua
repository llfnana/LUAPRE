IncreaseBattleSpeed = Clone(BoostBase)
IncreaseBattleSpeed.__cname = "IncreaseBattleSpeed"
function IncreaseBattleSpeed:OnEnter()
    local battleSpeedRx = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.BattleSpeed]
    if battleSpeedRx ~= nil then
        battleSpeedRx.value = 1
    end
end
function IncreaseBattleSpeed:OnQuit()
    local battleSpeedRx = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.BattleSpeed]
    if battleSpeedRx ~= nil then
        battleSpeedRx.value = 0
    end
end
return IncreaseBattleSpeed
