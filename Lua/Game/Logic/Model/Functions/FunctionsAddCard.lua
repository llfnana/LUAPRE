FunctionsAddCard = Clone(FunctionsBase)
FunctionsAddCard.__cname = "FunctionsAddCard"

function FunctionsAddCard:OnInit()
    self.eventType = EventType.ADD_CARD
    self.cardId = tonumber(self.config.unlockParams["cardId"])
end

function FunctionsAddCard:OnCheck()
    local cardItemData = CardManager.GetCardItemData(self.cardId)
    if cardItemData ~= nil then
        self:Unlock()
    end
end

function FunctionsAddCard:OnResponse(cardId)
    if self.cardId == tonumber(cardId) then
        self:Unlock()
    end
end

function FunctionsAddCard:OnIsCity(cityId)
    return not CityManager.GetIsEventScene(cityId)
end

return FunctionsAddCard
