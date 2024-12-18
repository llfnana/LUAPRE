---@class CardViewEnter : ITriggerBase
CardViewEnter = Clone(ITriggerBase)
CardViewEnter.__cname = "CardViewEnter"
CardViewEnter.type = EnumTriggerType.CardViewEnter

---@return boolean
function CardViewEnter:CheckCondition()
    local cityId = self.dataBase.city_id
    local cardId = self.dataBase.p1.cardId

    if tonumber(cardId) ~= self.runtimeData.cardId then
        return false
    end
    
    if not CardManager.IsUnlock(tonumber(cardId)) then
        return false
    end
    
    for i = 1, cityId do
        --data
        local storyBookData = DataManager.GetCityDataByKey(cityId, DataKey.StoryBook)
        if storyBookData ~= nil and storyBookData.cardViewEnterFlag ~= nil and storyBookData.cardViewEnterFlag[cardId] then
            return false
        end 
    end

    local storyBookData = DataManager.GetCityDataByKey(cityId, DataKey.StoryBook)
    if storyBookData.cardViewEnterFlag == nil then
        storyBookData.cardViewEnterFlag = {}
    end

    storyBookData.cardViewEnterFlag[cardId] = true
    DataManager.SaveCityData(cityId, true)
end

return CardViewEnter