---@class CityClockNight : ITriggerBase
CityClockNight = Clone(ITriggerBase)
CityClockNight.__cname = "CityClockNight"
CityClockNight.type = EnumTriggerType.CityClockNight

---@return boolean
function CityClockNight:CheckCondition()
    local day = self.dataBase.p1.day
    local cityDay = DataManager.GetCityDataByKey(self.cityId, DataKey.Day)
    
    if tonumber(day) == tonumber(cityDay) then
        return true
    end
    
    return false
end

return CityClockNight