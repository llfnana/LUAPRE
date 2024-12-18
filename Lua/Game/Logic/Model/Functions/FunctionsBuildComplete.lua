FunctionsBuildComplete = Clone(FunctionsBase)
FunctionsBuildComplete.__cname = "FunctionsBuildComplete"

function FunctionsBuildComplete:OnInit()
    self.eventType = EventType.UPGRADE_ZONE
    self.zoneType = self.config.unlockParams["zoneType"]
    self.level = tonumber(self.config.unlockParams["level"])
    self.count = tonumber(self.config.unlockParams["count"])
    
    if GameManager.isEditor then
        local zoneConfig = ConfigManager.GetZoneConfigListByType(self.cityId, self.zoneType)
        if zoneConfig:Count() == 0 then
            print("[error]" .. "FunctionsBuildComplete, not found zoneType: " .. self.zoneType)
        end
    end
end

function FunctionsBuildComplete:OnCheck()
    local count = MapManager.GetZoneCount(self.cityId, self.zoneType, self.level)
    if count >= self.count then
        self:Unlock()
    end
end

function FunctionsBuildComplete:OnResponse(zoneId, zoneType, level)
    if self.zoneType == zoneType and self.level == tonumber(level) then
        self:OnCheck()
    end
end

return FunctionsBuildComplete
