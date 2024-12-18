PushMainOffline = Clone(PushBase)
PushMainOffline.__cname = "PushMainOffline"

function PushMainOffline:OnInit()

end

function PushMainOffline:Available()
    return self:IsMaxCity()
end

---@param now Time2
function PushMainOffline:GenerateData(now)
    return {
        {
            name = self.__cname,
            schedule = now:Timestamp() + OfflineManager.GetOfflineMaxTime(),
            ttl = OfflineManager.GetOfflineMaxTime()
        }
    }
end

function PushMainOffline:OnEvent(cityId, type, params)
    if CityManager.GetIsEventScene(cityId) then
        return
    end
    
    if type ~= EventType.EFFECT_RES_ADD_COMPLETE then
        return
    end
    
    if params.eventSign ~= nil and params.eventSign.isFull == true then
        PushNotifyManager.OpenPromptPanel(PushNotifyManager.PromptType.FreeBox)
    end
end

return PushMainOffline
