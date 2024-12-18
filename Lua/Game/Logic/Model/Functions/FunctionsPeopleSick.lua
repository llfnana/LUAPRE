FunctionsPeopleSick = Clone(FunctionsBase)
FunctionsPeopleSick.__cname = "FunctionsPeopleSick"

function FunctionsPeopleSick:OnInit()
    self.eventType = EventType.CHARACTER_STATE_CHANGE
    self.count = tonumber(self.config.unlockParams["count"])
end

function FunctionsPeopleSick:OnCheck()
    local characters = CharacterManager.GetCharactersByStateType(self.cityId, EnumState.Sick)
    if tonumber(characters:Count()) >= self.count then
        self:Unlock()
    end
end

function FunctionsPeopleSick:OnResponse(character, state)
    if character.cityId == self.cityId and state == EnumState.Sick then
        self:Unlock()
    end
end

return FunctionsPeopleSick
