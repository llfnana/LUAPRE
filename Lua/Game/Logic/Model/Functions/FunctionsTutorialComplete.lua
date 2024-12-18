FunctionsTutorialComplete = Clone(FunctionsBase)
FunctionsTutorialComplete.__cname = "FunctionsTutorialComplete"

function FunctionsTutorialComplete:OnInit()
    self.eventType = EventType.COMPLETE_TUTORIAL
    self.step = tonumber(self.config.unlockParams["step"])
end

function FunctionsTutorialComplete:OnCheck()
    if TutorialManager.IsComplete(self.step) then
        self:Unlock()
    end
end

function FunctionsTutorialComplete:OnResponse(step)
    if self.step == tonumber(step) then
        self:Unlock()
    end
end

return FunctionsTutorialComplete
