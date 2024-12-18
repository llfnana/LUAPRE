---@class UIShopSubscriptionItem
local Element = class("UIShopSubscriptionItem")
UIShopSubscriptionItem = Element

function Element:ctor()
end

function Element:InitPanel(behaviour, obj, param)
    self.gameObject = obj;
    self.transform = obj.transform;
    self.behaviour = behaviour;
    param = param or {}

    if self.uidata == nil then self.uidata = {} end
    self.TitleText = SafeGetUIControl(self, "Name/Txt", "Text")
    self.Icon = SafeGetUIControl(self, "ImgIcon", "Image")
    self.PurchaseButton = SafeGetUIControl(self, "BtnOpen")
    self.txtNum = SafeGetUIControl(self, "BtnOpen/TxtNum", "Text")
    self.imgBg = SafeGetUIControl(self, "ImgBg")
    self.active = SafeGetUIControl(self, "Active")
    self.txtActive = SafeGetUIControl(self, "Active/Txt", "Text")
end

---@param data ShopPanelItemData
function Element:OnInit(data)
    self.cityId = DataManager.GetCityId()
    self.shopPanelItemData = data

    self.TitleText.text = GetLang(self.shopPanelItemData.config.name)
    Utils.SetIcon(self.Icon, self.shopPanelItemData.config.banner_pic, function()
        self.Icon.gameObject:SetActive(true)
    end)

    SafeAddClickEvent(self.behaviour, self.PurchaseButton, function()
        self:OpenConfirmPanel()
    end)

    SafeAddClickEvent(self.behaviour, self.imgBg, function()
        self:OpenConfirmPanel()
    end)
    self:Refresh()
end

function Element:Refresh()
    local purchased, canClaimed, packageId = ShopManager.CheckSubscriptionCanClaim(self.shopPanelItemData.configList)

    if not purchased and not ShopManager.CheckItem(self.cityId, self.shopPanelItemData.config.id, ShopManager.Action.Show) then
        self.gameObject:SetActive(false)
        return
    end

    self.gameObject:SetActive(true)

    -- 未购买
    if not purchased then
        self.txtNum.text = PaymentManager.GetPriceStr(self.shopPanelItemData.package.product_id)
    else
        self.txtNum.text = GetLang("ui_shop_cutline_detail")
        self.txtActive.text = GetLang("ui_shop_subscription_btn_active")
    end
    SafeSetActive(self.active.gameObject, purchased)
end

function Element:OpenConfirmPanel()
    ShowUI(UINames.UISubscription,
        {
            configList = self.shopPanelItemData.configList,
            packageList = self.shopPanelItemData.packageList,
            buyFunc = self.shopPanelItemData.onBuyButtonClick,
            showRestoreButton = true,
        })

    local packageKeyList = {}
    for i = 1, #self.shopPanelItemData.packageList do
        table.insert(packageKeyList, self.shopPanelItemData.packageList[i].id)
    end
    ShopManager.Analytics(
        "ShopSubscriptionUiIconTap",
        {
            from = "ShopPanel",
            packageKeyList = packageKeyList
        }
    )
end

function Element:ClaimReward()
    local subList = PaymentManager.GetAllValidSubscription(ShopManager.GetNow())

    for i = 1, #subList do
        if self.shopPanelItemData.config.id == subList[i].packageId then
            local rewards = PaymentManager.GetPackageDailyReward(subList[i].packageId)
            if #rewards > 0 then
                ResAddEffectManager.AddResEffectFromRewards(rewards, true, { hideFlying = true, isShop = true })
            end

            self:Refresh()
            return true
        end
    end

    return false
end

function Element:OnDestroy()
end
