FunctionsTaskComplete = Clone(FunctionsBase)
FunctionsTaskComplete.__cname = "FunctionsTaskComplete"

function FunctionsTaskComplete:OnInit()
    self.eventType = EventType.TASK_COMPLETE
    self.taskId = tonumber(self.config.unlockParams["taskId"])
    self.taskPart = tonumber(self.config.unlockParams["part"])
end

function FunctionsTaskComplete:OnCheck()
    local part = TaskManager.GetSceneTaskProgress(self.cityId)
    part = part + 1
    if part > tonumber(self.taskPart) then
        self:Unlock()
        return
    end

    if part == tonumber(self.taskPart) then
        local taskStatus = TaskManager.GetCacheTaskState(self.cityId, self.taskId)
        if taskStatus >= TaskStatus.Completed then
            self:Unlock()
        end
    end
end

function FunctionsTaskComplete:OnResponse(taskId)
    if self.taskId == tonumber(taskId) then
        self:Unlock()
        return
    end

    local taskStatus = TaskManager.GetCacheTaskState(self.cityId, self.taskId)
    if taskStatus >= TaskStatus.Completed then
        self:Unlock()
    end
end

return FunctionsTaskComplete
