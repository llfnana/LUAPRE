FunctionsAddEventCard = Clone(FunctionsBase)
FunctionsAddEventCard.__cname = "FunctionsAddEventCard"

function FunctionsAddEventCard:OnInit()
    self.eventType = EventType.ADD_CARD
    self.cardId = tonumber(self.config.unlockParams["cardId"])
end

function FunctionsAddEventCard:OnCheck()
    local cardItemData = CardManager.GetCardItemData(self.cardId)
    if cardItemData ~= nil then
        self:Unlock()
    end
end

function FunctionsAddEventCard:OnResponse(cardId)
    if self.cardId == tonumber(cardId) then
        self:Unlock()
    end
end

function FunctionsAddEventCard:OnIsCity(cityId)
    return CityManager.GetIsEventScene(cityId)
end

return FunctionsAddEventCard
