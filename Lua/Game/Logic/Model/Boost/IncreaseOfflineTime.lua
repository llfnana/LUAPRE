IncreaseOfflineTime = Clone(BoostBase)
IncreaseOfflineTime.__cname = "IncreaseOfflineTime"

function IncreaseOfflineTime:OnEnter()
    local boostFactorTime = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.OfflineTime]
    if boostFactorTime ~= nil then
        boostFactorTime.value = boostFactorTime.value + tonumber(self.params.add_time)
    end
end

function IncreaseOfflineTime:OnQuit()
    local boostFactorTime = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.OfflineTime]
    if boostFactorTime ~= nil then
        boostFactorTime.value = boostFactorTime.value - tonumber(self.params.add_time)
    end
end

return IncreaseOfflineTime
