PushEventBuilding = Clone(PushBase)
PushEventBuilding.__cname = "PushEventBuilding"

function PushEventBuilding:OnInit()

end

function PushEventBuilding:Available()
    return self:IsEventCity() and self:InEvent()
end

---@param now Time2
function PushEventBuilding:GenerateData(now)
    local zones = ConfigManager.GetZonesByCityId(self.cityId)
    local rt = {}
    
    zones:ForEach(
        function(z)
            local mapItemData = MapManager.GetMapItemData(self.cityId, z.id)
            local status = Utils.GetMapItemDataStatus(mapItemData)
            if status == MapItemDataStatus.Building or status == MapItemDataStatus.Upgrading then
                local left, _ = mapItemData:GetBuildLeftTime()
                table.insert(rt, {
                    name = self.__cname,
                    schedule = now:Timestamp() + left,
                    ttl = left
                })
            end
        end
    )
    
    return rt
end

return PushEventBuilding
