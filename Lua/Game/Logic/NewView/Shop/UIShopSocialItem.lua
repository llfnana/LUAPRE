---@class UIShopSocialItem
local Element = class("UIShopSocialItem")
UIShopSocialItem = Element

function Element:ctor()
end

function Element:InitPanel(behaviour, obj, param)
    self.gameObject = obj;
    self.transform = obj.transform;
    self.behaviour = behaviour;
    param = param or {}

    if self.uidata == nil then self.uidata = {} end
    self.txtTitle = SafeGetUIControl(self, "Txt", "Text")
    self.imgIcon = SafeGetUIControl(self, "ImgIcon", "Image")
    self.btnOpen = SafeGetUIControl(self, "BtnOpen")
    self.txtOpen = SafeGetUIControl(self, "BtnOpen/TxtOpen", "Text")
end

---@param data ShopPanelItemData
function Element:OnInit(data)
    self.shopPanelItemData = data
    self.cityId = DataManager.GetCityId()
    self.claimed = false


    self.txtTitle.text = GetLang(self.shopPanelItemData.config.name)
    Utils.SetIcon(self.imgIcon, self.shopPanelItemData.config.banner_pic, function()
        self.imgIcon.gameObject:SetActive(true)
    end)
    SafeAddClickEvent(self.behaviour, self.btnOpen, function()
        self:GotoSocial()
    end)

    self:Refresh()
    
    self.onAppJoinGame = function()
        self:ClaimReward()
    end
    EventManager.AddListener(EventType.APPLICATION_JOIN_GAME, self.onAppJoinGame)
end

function Element:Refresh()
    if not self:IsAvailableGotoSocial() and self.claimed == false and not ShopManager.CheckItem(self.cityId, self.shopPanelItemData.config.id, ShopManager.Action.Show) then
        self.gameObject:SetActive(false)
        self.shopPanelItemData.rebuildFunc()
        return
    end

    self.gameObject:SetActive(true)
    if self.claimed then
        self.txtOpen.text = GetLang("ui_shop_diamond_claimed")
    else
        self.txtOpen.text = GetLang("ui_shop_diamond_free")
    end
end

function Element:ClaimReward()
    if not self:IsAvailableGotoSocial() then
        self:ClearSocial()
        return
    end

    self:ClearSocial()
    self.claimed = true
    self.shopPanelItemData.onBuyButtonClick(self.shopPanelItemData.config)
end

function Element:SetSocial()
    self.gotoSocialTime = ShopManager.GetNow()
end

function Element:ClearSocial()
    self.gotoSocialTime = nil
end

function Element:HasGotoSocial()
    return self.gotoSocialTime ~= nil
end

function Element:ClaimReward()
    if not self:IsAvailableGotoSocial() then
        self:ClearSocial()
        return
    end

    self:ClearSocial()
    self.claimed = true
    self.shopPanelItemData.onBuyButtonClick(self.shopPanelItemData.config)
end

function Element:IsAvailableGotoSocial()
    if not self:HasGotoSocial() then
        return false
    end

    local stayTime = ConfigManager.GetMiscConfig("social_stay_time")
    if stayTime == nil then
        return false
    end

    if #stayTime ~= 2 then
        return false
    end

    local userStayTime = ShopManager.GetNow():Timestamp() - self.gotoSocialTime:Timestamp()

    return stayTime[1] < userStayTime and userStayTime < stayTime[2]
end

function Element:GotoSocial()
    if self.claimed then
        return
    end

    local extendedType = self.shopPanelItemData.package.extended_cost

    local url = ConfigManager.GetMiscConfig(extendedType .. "_url")
    if url == nil then
        return
    end

    self:SetSocial()
    Application.OpenURL(url)
end

function Element:OnDestroy()
    EventManager.RemoveListener(EventType.APPLICATION_JOIN_GAME, self.onAppJoinGame)
end
