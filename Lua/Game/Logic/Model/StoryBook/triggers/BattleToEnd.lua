---@class BattleToEnd : ITriggerBase
BattleToEnd = Clone(ITriggerBase)
BattleToEnd.__cname = "BattleToEnd"
BattleToEnd.type = EnumTriggerType.BattleToEnd

---@return boolean
function BattleToEnd:CheckCondition()
    local cityId = self.dataBase.city_id
    --data
    local storyBookData = DataManager.GetCityDataByKey(cityId, DataKey.StoryBook)
    if storyBookData == nil or storyBookData.battleToEndFlag then
        return false
    end

    storyBookData.battleToEndFlag = true
    DataManager.SaveCityData(cityId, true)
end

return BattleToEnd