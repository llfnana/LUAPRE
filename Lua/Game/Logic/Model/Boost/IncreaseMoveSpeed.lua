IncreaseMoveSpeed = Clone(BoostBase)
IncreaseMoveSpeed.__cname = "IncreaseMoveSpeed"

function IncreaseMoveSpeed:OnEnter()
    local boostFactor = BoostManager.GetBoost(self.cityId).commonBoostList[CommonBoostType.Speed]
    if boostFactor ~= nil then
        boostFactor:Add(self.boostData.params.index, self.boostData.params.effect)
    end
end

function IncreaseMoveSpeed:OnQuit()
    local boostFactor = BoostManager.GetBoost(self.cityId).commonBoostList[CommonBoostType.Speed]
    if boostFactor ~= nil then
        boostFactor:Remove(self.boostData.params.index, self.boostData.params.effect)
    end
end

return IncreaseMoveSpeed
