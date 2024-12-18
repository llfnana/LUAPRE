PushEventOffline = Clone(PushBase)
PushEventOffline.__cname = "PushEventOffline"

function PushEventOffline:OnInit()

end

function PushEventOffline:Available()
    return self:IsEventCity() and self:InEvent()
end

---@param now Time2
function PushEventOffline:GenerateData(now)
    return {
        {
            name = self.__cname,
            schedule = now:Timestamp() + OfflineManager.GetOfflineMaxTime(),
            ttl = OfflineManager.GetOfflineMaxTime()
        }
    }
end

function PushEventOffline:OnEvent(cityId, type, params)
    if not CityManager.GetIsEventScene(cityId) then
        return
    end
    
    if type ~= EventType.EFFECT_RES_ADD_COMPLETE then
        return
    end
    
    if params.eventSign ~= nil and params.eventSign.isFull == true then
        PushNotifyManager.OpenPromptPanel(PushNotifyManager.PromptType.FreeBox)
    end
end

return PushEventOffline
