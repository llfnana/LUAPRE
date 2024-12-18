FunctionsBattleFinished = Clone(FunctionsBase)
FunctionsBattleFinished.__cname = "FunctionsBattleFinished"

function FunctionsBattleFinished:OnInit()
    self.eventType = EventType.BATTLE_FINISH_CB
    self.battleLevel = tonumber(self.config.unlockParams["level"])
end

function FunctionsBattleFinished:OnCheck()
    if self.battleLevel <= CardManager.GetBattleLevel() then
        self:Unlock()
    end
end

function FunctionsBattleFinished:OnResponse(level)
    if self.battleLevel == tonumber(level) then
        self:Unlock()
    end
end

return FunctionsBattleFinished
