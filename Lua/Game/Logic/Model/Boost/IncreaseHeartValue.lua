---@class IncreaseHeartValue : BoostBase
IncreaseHeartValue = Clone(BoostBase)
IncreaseHeartValue.__cname = "IncreaseHeartValue"

function IncreaseHeartValue:OnEnter()
    local boostFactor = BoostManager.GetBoost(self.cityId).eventBoostList[EventBoostType.HeartBuff]
    local level = self:GetBoostLevel()
    if level > 0 then
        self.effect = self.effects[level]
        if boostFactor ~= nil then
            boostFactor:Set(self.params.index, self.effect)
        end
    end
end

function IncreaseHeartValue:OnQuit()
    local boostFactor = BoostManager.GetBoost(self.cityId).eventBoostList[EventBoostType.HeartBuff]
    if boostFactor ~= nil then
        boostFactor:Set(self.params.index, 1)
    end
end

return IncreaseHeartValue
