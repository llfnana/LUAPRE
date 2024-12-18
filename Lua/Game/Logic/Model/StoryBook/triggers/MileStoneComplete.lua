---@class MileStoneComplete : ITriggerBase
MileStoneComplete = Clone(ITriggerBase)
MileStoneComplete.__cname = "MileStoneComplete"
MileStoneComplete.type = EnumTriggerType.MileStoneComplete

---@return boolean
function MileStoneComplete:CheckCondition()
    if self.dataBase.p1.mileStoneId == tostring(self.runtimeData.mileStoneId) then
        return true
    end

    return false
end

return MileStoneComplete