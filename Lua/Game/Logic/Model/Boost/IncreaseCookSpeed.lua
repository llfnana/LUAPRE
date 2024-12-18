IncreaseCookSpeed = Clone(BoostBase)
IncreaseCookSpeed.__cname = "IncreaseCookSpeed"

function IncreaseCookSpeed:OnEnter()
    -- self.foodSpeedList = BoostManager.GetBoost(self.cityId).foodSpeedList
    -- local itemConfig = ConfigManager.GetItemConfig(self.params.item_id)
    -- self.foodLevelType = itemConfig.item_type
    -- local cardId = self.boostData.cardId
    -- local boostLevel = CardManager.GetCardItemData(cardId):GetCardBoostLevel()
    local boostFactor = BoostManager.GetBoost(self.cityId).commonBoostList[CommonBoostType.CookSpeed]
    self.effect = self:GetEffect()
    if boostFactor ~= nil then
        boostFactor:Add(self.params.index, self.effect)
    end
    -- self.foodSpeedList[self.foodLevelType] = self.foodSpeedList[self.foodLevelType] + self.effect
    -- FoodSystemManager.SetReplaceFoodItem(self.cityId, self.params.item_id)
end

function IncreaseCookSpeed:OnQuit()
    local boostFactor = BoostManager.GetBoost(self.cityId).commonBoostList[CommonBoostType.CookSpeed]
    if boostFactor ~= nil then
        boostFactor:Remove(self.params.index, self.effect)
    end
    -- FoodSystemManager.CancelReplaceFoodItem(self.cityId, self.params.item_id)
    -- self.foodSpeedList[self.foodLevelType] = self.foodSpeedList[self.foodLevelType] - self.effect
end
return IncreaseCookSpeed
