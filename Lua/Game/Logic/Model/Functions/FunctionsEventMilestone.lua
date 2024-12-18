FunctionsEventMilestone = Clone(FunctionsBase)
FunctionsEventMilestone.__cname = "FunctionsEventMilestone"

function FunctionsEventMilestone:OnInit()
    self.eventType = EventType.REFRESH_EVENT_MILESTONE
    self.eventMilestoneId = tonumber(self.config.unlockParams["id"])
end

function FunctionsEventMilestone:OnCheck()
    -- local config = EventSceneManager.GetNextMileStoneConfig()
    -- if config == nil then
    --     self:Unlock()
    --     return
    -- end
    
    -- if tonumber(config.id) >= self.eventMilestoneId then
    --     self:Unlock()
    -- end
end

function FunctionsEventMilestone:OnResponse()
    self:OnCheck()
end

return FunctionsEventMilestone
