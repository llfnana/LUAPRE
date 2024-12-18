IncreaseMaterialProduction = Clone(BoostBase)
IncreaseMaterialProduction.__cname = "IncreaseMaterialProduction"

function IncreaseMaterialProduction:OnEnter()
    self.materialBoostList = BoostManager.GetBoost(self.cityId).materialBoostList
    local zoneId = self.boostData.toId
    LogWarning(zoneId .. " to Boost")
    local cardId = self.boostData.cardId
    local outputId = MapManager.GetMapItemData(self.cityId, zoneId):GetProductId()
    local itemBoostFactor = self.materialBoostList[outputId]
    local boostLevel = CardManager.GetCardItemData(cardId):GetCardBoostLevel()
    self.effect = self.effects[boostLevel]
    if itemBoostFactor ~= nil then
        itemBoostFactor:Set(self.params.index, self.effect)
    end
end

function IncreaseMaterialProduction:OnQuit()
    local zoneId = self.boostData.toId
    local outputId = MapManager.GetMapItemData(self.cityId, zoneId):GetProductId()
    local itemBoostFactor = self.materialBoostList[outputId]
    if itemBoostFactor ~= nil then
        itemBoostFactor:Set(self.params.index, 1) 
    end
end
return IncreaseMaterialProduction
