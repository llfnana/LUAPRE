---@class DecreaseBuildCost : BoostBase
DecreaseBuildCost = Clone(BoostBase)
DecreaseBuildCost.__cname = "DecreaseBuildCost"

function DecreaseBuildCost:OnEnter()
    ---@type BoostFactor
    local boostFactor = BoostManager.GetBoost(self.cityId).eventBoostList[EventBoostType.BuildCost]
    local level = self:GetBoostLevel()
    if level > 0 then
        self.effect = self.effects[level]
        if boostFactor ~= nil then
            --boostFactor:Add(self.params.index, -self.effect)
            boostFactor:Division(self.params.index, self.effect)
        end
    end
end

function DecreaseBuildCost:OnQuit()
    local boostFactor = BoostManager.GetBoost(self.cityId).eventBoostList[EventBoostType.BuildCost]
    if boostFactor ~= nil then
        boostFactor:Set(self.params.index, 1)
    end
end

return DecreaseBuildCost
