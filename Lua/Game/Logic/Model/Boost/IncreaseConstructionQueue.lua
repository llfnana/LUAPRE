IncreaseConstructionQueue = Clone(BoostBase)
IncreaseConstructionQueue.__cname = "IncreaseConstructionQueue"
function IncreaseConstructionQueue:OnEnter()
    local boostFactorQueue = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.ConstructionQueue]
    if boostFactorQueue ~= nil then
        -- boostFactorQueue.value = boostFactorQueue.value + tonumber(self.params.queueEffect)
        boostFactorQueue.value = tonumber(self.params.queueEffect)
    end
end
function IncreaseConstructionQueue:OnQuit()
    local boostFactorQueue = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.ConstructionQueue]
    if boostFactorQueue ~= nil then
        boostFactorQueue.value = 0
    end
end
return IncreaseConstructionQueue
