---@class UIShopSpecialItem
local Element = class("UIShopSpecialItem")
UIShopSpecialItem = Element

function Element:ctor()
end

function Element:InitPanel(behaviour, obj, param)
    self.gameObject = obj;
    self.transform = obj.transform;
    self.behaviour = behaviour;
    param = param or {}

    if self.uidata == nil then self.uidata = {} end
    self.PurchaseButton = SafeGetUIControl(self, "Purchase")
    self.PriceText = SafeGetUIControl(self, "Purchase/Txt", "Text")
    self.NameText = SafeGetUIControl(self, "Name/TxtName", "Text")
    self.LimitTagText = SafeGetUIControl(self, "Limit/Txt", "Text")
    self.ScrollView = SafeGetUIControl(self, "Scroll View", "ScrollRect")
    self.item = SafeGetUIControl(self, "Scroll View/Viewport/Content/Item")
    self.item:SetActive(false)
    self.props = SafeGetUIControl(self, "Scroll View/Viewport/Content")
end

---@param data ShopPanelItemData
function Element:OnInit(data)
    self.shopPanelItemData = data
    self.cityId = DataManager.GetCityId()

    self:RefreshLastAvailableConfig()
    if self.currentConfig == nil then
        return
    end

    SafeAddClickEvent(self.behaviour, self.PurchaseButton, Handler(self, self.OnClick))
    SafeAddClickEvent(self.behaviour, self.gameObject, Handler(self, self.OnClick))
    

    self.NameText.text = GetLang(self.currentConfig.name)

    if self.currentConfig.condition_count_desc ~= "" and self.currentConfig.condition_count ~= 0 then
        self.LimitTagText.text = GetLangFormat(
            self.currentConfig.condition_count_desc,
            ShopManager.GetShopItemRemainCount(self.currentConfig.id)
        )
    else
        self.LimitTagText.transform.parent.gameObject:SetActive(false)
    end
    
    self.PriceText.text = ShopManager.GetPrice(self.currentPackage.product_id)

    local rewards = Utils.ParseReward(self.currentPackage.reward)
    for i = 1, #rewards do
        self:InitItem(rewards[i], i)
    end

    -- 多余的项要隐藏掉(有一个原始项)
    local maxCount = #rewards + 1
    if self.props.transform.childCount > maxCount then 
        for i = maxCount, self.props.transform.childCount - 1 do 
            self.props.transform:GetChild(i).gameObject:SetActive(false)
        end
    end

    self.ScrollView.enabled = #rewards > 5

    self.RefreshCooldownFunc = function()
        if self.currentConfig == nil then
            return
        end

        self:RefreshCooldownTime(self.currentConfig)
    end
    EventManager.AddListener(EventType.TIME_REAL_PER_SECOND, self.RefreshCooldownFunc)

    self:Refresh()
end

function Element:InitItem(reward, i)
    local go = nil
    if i >= self.props.transform.childCount then
        go = GOInstantiate(self.item.gameObject, self.props.transform)
    else
        go = self.props.transform:GetChild(i)
    end
    SafeSetActive(go.gameObject, true)
    local icon = go.transform:Find("ImgIcon"):GetComponent("Image")
    local bg = go.transform:Find("ImgBg"):GetComponent("Image")
    local num = go.transform:Find("TxtNum"):GetComponent("Text")

    Utils.SetRewardIcon4(reward, icon, bg, num, "x")
    -- SetImage(self.behaviour, icon, reward.id)

    num.text = "x" .. Utils.FormatCount(reward.count)

    SafeSetActive(bg.gameObject, reward.count > 0)
    SafeSetActive(num.gameObject, reward.count > 0)

    Utils.SetRewardTooltips(reward, go.gameObject, "ShopPanel")

    SafeAddClickEvent(self.behaviour, icon.gameObject, function()
        self:ItemClick(icon, reward)
    end)
end

function Element:Refresh()
    self:RefreshLastAvailableConfig()

    if self.currentConfig == nil then
        self.gameObject:SetActive(false)
        self.shopPanelItemData.rebuildFunc()
        return false
    end

    self.gameObject:SetActive(true)
    -- ShopManager.RefreshTagView(self.currentConfig, self.tagView)

    if self.currentConfig.condition_count_desc ~= "" and self.currentConfig.condition_count ~= 0 then
        self.LimitTagText.text = GetLangFormat(
            self.currentConfig.condition_count_desc,
            ShopManager.GetShopItemRemainCount(self.currentConfig.id)
        )
    else
        self.LimitTagText.gameObject:SetActive(false)
    end

    self:RefreshCooldownTime(self.currentConfig)

    return true
end

function Element:OnClick()
    if ShopManager.CheckItem(self.cityId, self.currentConfig.id, ShopManager.Action.Buy) then
        self.shopPanelItemData.onBuyButtonClick(self.currentConfig)
    end
end

function Element:RefreshLastAvailableConfig()
    self.currentConfig = ShopManager.GetLastAvailableConfigByGroup(self.cityId, self.shopPanelItemData.configList)

    if self.currentConfig ~= nil then
        self.currentPackage = ShopManager.GetPackageByShopId(self.currentConfig.id)
    end
end

function Element:RefreshCooldownTime(config)
    local inCD = ShopManager.GetShopItemInCooldown(self.currentConfig)
    if inCD then
        self.PriceText.text = Utils.GetTimeFormat(ShopManager.GetShopItemRemainTime(config, ShopManager.GetNow()))
    end

    -- self.CooldownContainer.gameObject:SetActive(inCD)
end

function Element:OnDestroy()
    EventManager.RemoveListener(EventType.TIME_REAL_PER_SECOND, self.RefreshCooldownFunc)
end

function Element:ItemClick(icon, reward)
    
    if reward.addType == RewardAddType.Card then 
        if not reward.id then
            if reward.color then 
                local id = "random_" .. reward.color
                local box = ConfigManager.GetBoxConfig(id)
                ShowUI(UINames.UITipBox, {
                    go = icon.gameObject,
                    itemId = box.id,
                    dir = ToolTipDir.Up,
                    type = TooltipType.Item,
                })
            end
            return 
        end
        local cardId = reward.id
        local cardUnlockType, lockParam = CardManager.GetCardUnlockState(cardId, self.cityId)
        local cardConfig = ConfigManager.GetCardConfig(cardId)
        if cardUnlockType == CardUnlockType.Own then
            ShowUI(UINames.UIHeroInfo, {
                cardItemData = CardManager.GetCardItemData(cardId),
            })
        elseif cardUnlockType == CardUnlockType.UnFound then
            ShowUI(UINames.UIHeroInfo,
                {
                    cardItemData = CardManager.CreateFullCardItem(cardConfig),
                }
            )
        elseif cardUnlockType == CardUnlockType.Lock_ZoneId then
            ShowUI(UINames.UIHeroInfo,
                {
                    cardItemData = CardManager.CreateFullCardItem(cardConfig),
                }
            )
        elseif cardUnlockType == CardUnlockType.Lock_CityId then
            ShowUI(UINames.UIHeroInfo,
                {
                    cardItemData = CardManager.CreateFullCardItem(cardConfig),
                }
            )
        end
    elseif reward.addType == RewardAddType.Item then 
        UIUtil.AddItem(icon, reward.id, nil, nil)
    elseif reward.addType == RewardAddType.OpenBox then 
        local box = ConfigManager.GetBoxConfig(reward.id)
        ShowUI(UINames.UITipBox, {
            go = icon.gameObject,
            itemId = box.id,
            dir = ToolTipDir.Up,
            type = TooltipType.Item,
        })
    else

    end
end
