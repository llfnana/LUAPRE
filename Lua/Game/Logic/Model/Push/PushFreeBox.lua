PushFreeBox = Clone(PushBase)
PushFreeBox.__cname = "PushFreeBox"

function PushFreeBox:OnInit()
    self.shopConfigList = {}
    
    for i = 1, #self.params.shopId do
        local config = ShopManager.GetShopConfig(self.params.shopId[i])
        if config == nil then
            print("[error]" .. "not found shop: " .. self.params.shopId[i])
        else
            table.insert(self.shopConfigList, config)
        end
    end
end

function PushFreeBox:Available()
    return true
end

---@param now Time2
function PushFreeBox:GenerateData(now)
    local rt = {}
    
    for i = 1, #self.shopConfigList do
        local remainTime = self:GetBoxItemRemainTime(self.shopConfigList[i], now)
        if remainTime > 0 then
            table.insert(
                rt,
                {
                    name = self.__cname,
                    schedule = now:Timestamp() + remainTime,
                    ttl = remainTime
                }
            )
        end
    end
    
    return rt
end

function PushFreeBox:OnEvent(cityId, type, params)
    if type ~= EventType.EFFECT_RES_ADD_COMPLETE then
        return
    end
    
    if params.eventSign ~= nil and Utils.ArrayHas(self.params.shopId, params.eventSign.shopId) then
        PushNotifyManager.OpenPromptPanel(PushNotifyManager.PromptType.FreeBox)
    end
end

---@param config Shop
---@param now Time2
function PushFreeBox:GetBoxItemRemainTime(config, now)
    local remainTime = ShopManager.GetShopItemRemainTime(config, now)
    if remainTime <= 0 then
        return 0
    end
    
    if ShopManager.GetShopItemRemainCount(config.id) == 0 then
        return 0
    end
    
    return remainTime
end

return PushFreeBox
