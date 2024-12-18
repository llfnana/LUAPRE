---@class BattleToBegin : ITriggerBase
BattleToBegin = Clone(ITriggerBase)
BattleToBegin.__cname = "BattleToBegin"
BattleToBegin.type = EnumTriggerType.BattleToBegin

---@return boolean
function BattleToBegin:CheckCondition()
    local cityId = self.dataBase.city_id
    --data
    local storyBookData = DataManager.GetCityDataByKey(cityId, DataKey.StoryBook)
    if storyBookData == nil or storyBookData.battleToBeginFlag then
        return false
    end

    storyBookData.battleToBeginFlag = true
    DataManager.SaveCityData(cityId, true)
end

return BattleToBegin