IncreaseOfflineTimeEvent = Clone(BoostBase)
IncreaseOfflineTimeEvent.__cname = "IncreaseOfflineTimeEvent"

function IncreaseOfflineTimeEvent:OnEnter()
    local boostFactorTime = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.OfflineTime]
    if boostFactorTime ~= nil then
        boostFactorTime.value = boostFactorTime.value + tonumber(self.params.add_time)
    end
end

function IncreaseOfflineTimeEvent:OnQuit()
    local boostFactorTime = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.OfflineTime]
    if boostFactorTime ~= nil then
        boostFactorTime.value = boostFactorTime.value - tonumber(self.params.add_time)
    end
end

return IncreaseOfflineTimeEvent
