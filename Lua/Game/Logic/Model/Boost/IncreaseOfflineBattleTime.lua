IncreaseOfflineBattleTime = Clone(BoostBase)
IncreaseOfflineBattleTime.__cname = "IncreaseOfflineBattleTime"
function IncreaseOfflineBattleTime:OnEnter()
    local fightTimeRx = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.OfflineBattleTime]
    if fightTimeRx ~= nil then
        fightTimeRx.value = tonumber(self.params.add_time)
    end
end
function IncreaseOfflineBattleTime:OnQuit()
    local fightTimeRx = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.OfflineBattleTime]
    if fightTimeRx ~= nil then
        fightTimeRx.value = 0
    end
end
return IncreaseOfflineBattleTime
