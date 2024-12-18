IncreaseIdleBattleReward = Clone(BoostBase)
IncreaseIdleBattleReward.__cname = "IncreaseIdleBattleReward"

function IncreaseIdleBattleReward:OnEnter()
    local boostFactor = BoostManager.GetBoost(self.cityId).commonBoostList[CommonBoostType.IdleBattleReward]
    local capacity = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.IdleBattleCapacity]
    if boostFactor ~= nil then
        boostFactor:Add(self.boostData.params.index, self.boostData.params.effect)
    end
    if capacity ~= nil then
        capacity.value = capacity.value + tonumber(self.boostData.params.timeEffect)
    end
end

function IncreaseIdleBattleReward:OnQuit()
    local boostFactor = BoostManager.GetBoost(self.cityId).commonBoostList[CommonBoostType.IdleBattleReward]
    local capacity = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.IdleBattleCapacity]
    if boostFactor ~= nil then
        boostFactor:Remove(self.boostData.params.index, self.boostData.params.effect)
    end
    if capacity ~= nil then
        capacity.value = capacity.value - tonumber(self.boostData.params.timeEffect)
    end
end

return IncreaseIdleBattleReward
