---@class IncreaseVanSpeed : BoostBase
IncreaseVanSpeed = Clone(BoostBase)
IncreaseVanSpeed.__cname = "IncreaseVanSpeed"

function IncreaseVanSpeed:OnEnter()
    local boostFactor = BoostManager.GetBoost(self.cityId).eventBoostList[EventBoostType.VanSpeed]
    local level = self:GetBoostLevel()
    if level > 0 then
        self.effect = self.effects[level]
        if boostFactor ~= nil then
            boostFactor:Set(self.params.index, self.effect)
        end
    end
    
    MapManager.RefreshVanControllersFunc(self.cityId, function(vanController)
        if vanController ~= nil then
            vanController:SetSpeed()
        end
    end)
end

function IncreaseVanSpeed:OnQuit()
    local boostFactor = BoostManager.GetBoost(self.cityId).eventBoostList[EventBoostType.VanSpeed]
    if boostFactor ~= nil then
        boostFactor:Set(self.params.index, 1)
    end

    MapManager.RefreshVanControllersFunc(self.cityId, function(vanController)
        if vanController ~= nil then
            vanController:SetSpeed()
        end
    end)
end

return IncreaseVanSpeed
