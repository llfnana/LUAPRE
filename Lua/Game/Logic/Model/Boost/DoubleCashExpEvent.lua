DoubleCashExpEvent = Clone(BoostBase)
DoubleCashExpEvent.__cname = "DoubleCashExpEvent"

function DoubleCashExpEvent:OnEnter()
    local boostFactor = BoostManager.GetBoost(self.cityId).commonBoostList[CommonBoostType.EventCashExpDouble]
    self.effect = self.effects[1]
    if boostFactor ~= nil then
        boostFactor:Set(self.params.index, self.effect)
    end
end

function DoubleCashExpEvent:OnQuit()
    local boostFactor = BoostManager.GetBoost(self.cityId).commonBoostList[CommonBoostType.EventCashExpDouble]
    if boostFactor ~= nil then
        boostFactor:Set(self.params.index, 1)
    end
end

return DoubleCashExpEvent
