---@class BuildComplete : ITriggerBase
BuildComplete = Clone(ITriggerBase)
BuildComplete.__cname = "BuildComplete"
BuildComplete.type = EnumTriggerType.BuildComplete

---@return boolean
function BuildComplete:CheckCondition()
    if self.dataBase.p1.zoneId == self.runtimeData.zoneId and self.dataBase.p1.level == tostring(self.runtimeData.level) then
        return true
    end
    
    return false
end

return BuildComplete