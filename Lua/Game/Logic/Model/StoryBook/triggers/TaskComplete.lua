---@class TaskComplete : ITriggerBase
TaskComplete = Clone(ITriggerBase)
TaskComplete.__cname = "TaskComplete"
TaskComplete.type = EnumTriggerType.TaskComplete

---@return boolean
function TaskComplete:CheckCondition()
    if self.dataBase.p1.taskId == tostring(self.runtimeData.taskId) then
        return true
    end

    return false
end

return TaskComplete