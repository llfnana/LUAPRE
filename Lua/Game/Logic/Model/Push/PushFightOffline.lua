PushFightOffline = Clone(PushBase)
PushFightOffline.__cname = "PushFightOffline"

function PushFightOffline:OnInit()

end

function PushFightOffline:Available()
    return true
end

---@param now Time2
function PushFightOffline:GenerateData(now)
    local left =0 -- math.floor(AdventureContManager.GetCurrentLefttime())
    return {
        {
            name = self.__cname,
            schedule = now:Timestamp() + left,
            ttl = left
        }
    }
end

return PushFightOffline
