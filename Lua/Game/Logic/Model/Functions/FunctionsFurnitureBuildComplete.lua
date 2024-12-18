FunctionsFurnitureBuildComplete = Clone(FunctionsBase)
FunctionsFurnitureBuildComplete.__cname = "FunctionsFurnitureBuildComplete"

function FunctionsFurnitureBuildComplete:OnInit()
    self.eventType = EventType.UPGRADE_FURNITURE
    self.furnitureId = self.config.unlockParams["furnitureId"]
    self.level = tonumber(self.config.unlockParams["level"])
    self.count = tonumber(self.config.unlockParams["count"])
    self.furnitureConfig = ConfigManager.GetFurnitureById(self.furnitureId)
end

function FunctionsFurnitureBuildComplete:OnCheck()
    local count = MapManager.GetUnlockFurnitureCount(self.cityId, self.furnitureConfig.zone_type, self.furnitureId, self.level)
    if count >= self.count then
        self:Unlock()
    end
end

function FunctionsFurnitureBuildComplete:OnResponse(zoneId, zoneType, furnitureType, index, level)
    if self.furnitureConfig.furniture_type == furnitureType and self.level < tonumber(level) then
        self:OnCheck()
    end
end

return FunctionsFurnitureBuildComplete
