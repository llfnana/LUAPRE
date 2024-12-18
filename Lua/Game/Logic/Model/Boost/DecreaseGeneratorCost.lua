DecreaseGeneratorCost = Clone(BoostBase)
DecreaseGeneratorCost.__cname = "DecreaseGeneratorCost"

function DecreaseGeneratorCost:OnEnter()
    local boostFactor = BoostManager.GetBoost(self.cityId).commonBoostList[CommonBoostType.GeneratorResource]
    local autoOverload = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.AutoGeneratorOverload]
    self.effect = self:GetEffect()
    boostFactor:Add(self.params.index, -self.effect)
    if autoOverload ~= nil then
        autoOverload.value = 1
    end
end

function DecreaseGeneratorCost:OnQuit()
    local boostFactor = BoostManager.GetBoost(self.cityId).commonBoostList[CommonBoostType.GeneratorResource]
    local autoOverload = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.AutoGeneratorOverload]
    if boostFactor ~= nil then
        boostFactor:Remove(self.params.index, -self.effect)
    end
    if autoOverload ~= nil then
        autoOverload.value = 0
    end
end
return DecreaseGeneratorCost
