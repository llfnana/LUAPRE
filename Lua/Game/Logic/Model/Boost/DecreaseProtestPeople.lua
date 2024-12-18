DecreaseProtestPeople = Clone(BoostBase)
DecreaseProtestPeople.__cname = "DecreaseProtestPeople"

function DecreaseProtestPeople:OnEnter()
    local protestPeopleCount = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.ProtestPeopleCount]
    protestPeopleCount.value = tonumber(self.params.count)
    local boostFactor = BoostManager.GetBoost(self.cityId).commonBoostList[CommonBoostType.ProtestEffect]
    self.effect = self:GetEffect()
    if boostFactor ~= nil then
        boostFactor:Set(self.params.index, self.effect)
    end
end

function DecreaseProtestPeople:OnQuit()
    local protestPeopleCount = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.ProtestPeopleCount]
    protestPeopleCount.value = 0
    local boostFactor = BoostManager.GetBoost(self.cityId).commonBoostList[CommonBoostType.ProtestEffect]
    if boostFactor ~= nil then
        boostFactor:Set(self.params.index, 1)
    end
end
return DecreaseProtestPeople
