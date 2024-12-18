---@class UIShopPanelItem
local Element = class("UIShopPanelItem")
UIShopPanelItem = Element

function Element:ctor()
end

function Element:InitPanel(behaviour, obj, param)
    self.gameObject = obj;
    self.transform = obj.transform;
    self.behaviour = behaviour;
    param = param or {}

    if self.uidata == nil then self.uidata = {} end
    self.CountText = SafeGetUIControl(self, "Title/TxtNum", "Text")
    self.PurchaseButton = SafeGetUIControl(self, "BtnOpen")
    self.Icon = SafeGetUIControl(self, "ImgIcon", "Image")
    self.Bg = SafeGetUIControl(self, "ImgBg", "Image")
    self.RemainCountText = SafeGetUIControl(self, "BtnOpen/Consume/TxtNum", "Text")
    self.prop = SafeGetUIControl(self, "Prop")
    self.txt1 = SafeGetUIControl(self, "Prop/Mask/Txt1", "Text")
    self.txt2 = SafeGetUIControl(self, "Prop/Mask/Txt2", "Text")

    self.tween = nil
    self.start = Vector2(0, -1.4)
    self.offset = 45
end

---@param data ShopPanelItemData
function Element:OnInit(data)
    self.cityId = DataManager.GetCityId()
    self.shopPanelItemData = data

    -- 不转换秒产奖励
    local rewards = Utils.ParseReward(self.shopPanelItemData.package.reward, true)
    local title, isTor = self:GetTitle(rewards, self.shopPanelItemData.config.name)
    self.CountText.text = title
    self.txt1.text = GetLang("ui_shop_diamond_double_show2")
    self.txt2.text = GetLang("ui_shop_diamond_double_show") ..
        "+" .. (rewards[1].count * self.shopPanelItemData.package.double_ratio)
    SafeAddClickEvent(self.behaviour, self.PurchaseButton, Handler(self, function()
        self:ClickButton(rewards, isTor)
    end))
    SafeAddClickEvent(self.behaviour, self.gameObject, Handler(self, function()
        self:ClickButton(rewards, isTor)
    end))

    Utils.SetIcon(self.Icon, self.shopPanelItemData.config.banner_pic, function()
        self.Icon.gameObject:SetActive(true)
    end)

    -- TODO zhkxin 目前第二张图与第一张图一样，先直接隐藏掉了
    SafeSetActive(self.Bg.gameObject,
        self.shopPanelItemData.config.background_pic and self.shopPanelItemData.config.background_pic[1] ~= nil)

    self:Refresh()
    self:InitTween()
    setTimeout(
        function()
            ForceRebuildLayoutImmediate(self.PurchaseButton)
        end,
        0
    )
end

function Element:Refresh()
    if not ShopManager.CheckItem(self.cityId, self.shopPanelItemData.config.id, ShopManager.Action.Show) then
        self.gameObject:SetActive(false)
        self.shopPanelItemData.rebuildFunc()
        return
    end

    self.gameObject:SetActive(true)

    self.RemainCountText.text = ShopManager.GetPrice(self.shopPanelItemData.package.product_id)
    local isDouble = PaymentManager.IsDouble(self.shopPanelItemData.package)
    SafeSetActive(self.prop.gameObject, isDouble)
end

function Element:ClickButton(rewards, isTor)
    if ShopManager.GetShopItemInCooldown(self.shopPanelItemData.config) then
        return
    end

    if ShopManager.GetShopItemRemainCount(self.shopPanelItemData.config.id) == 0 then
        return
    end

    ---TODO需要确认是不是需要什么确认弹窗界面
    if self.shopPanelItemData.package.reward_confirm then
        -- 转换秒产奖励
        local torRewards = Utils.RewardOverTime2Item(rewards)
        local hasOverTimeItem = Utils.HasOverTimeItemInRewards(rewards)
        PopupManager.Instance:OpenPanel(
            PanelType.ShopOverTimeConfirmPanel,
            {
                rewards = torRewards,
                config = self.shopPanelItemData.config,
                package = self.shopPanelItemData.package,
                hasOverTimeItem = hasOverTimeItem,
                onClick = function(cb)
                    self.shopPanelItemData.onBuyButtonClick(
                        self.shopPanelItemData.config,
                        function()
                            if cb ~= nil then
                                cb()
                            end
                        end
                    )
                end,
                isTor = isTor
            }
        )
    else
        self.shopPanelItemData.onBuyButtonClick(self.shopPanelItemData.config)
    end
end

function Element:InitTween()
    if self.tween == nil then
        self.tween = DOTween.Sequence()
        if self.start == nil then
            self.start = self.txt1.transform.anchoredPosition
        end
        self:AddTween(self.txt1, self.txt2)
        self:AddTween(self.txt2, self.txt1)
        self.tween:OnComplete(function()
            self:InitTween()
        end)
    end
    self.tween:Restart()
end

function Element:AddTween(f, s)
    local t1 = f.transform.anchoredPosition
    local t2 = s.transform.anchoredPosition
    local target1 = nil
    local target2 = nil
    local tween = DOTween.Sequence()
    tween:OnStart(function()
        f.transform.anchoredPosition = self.start
        s.transform.anchoredPosition = Vector2(0, -self.offset) + self.start
        t1 = f.transform.anchoredPosition
        t2 = s.transform.anchoredPosition
        target1 = t1 + Vector2(0, self.offset * 1.1)
        target2 = t2 + Vector2(0, self.offset * 1.1)
    end)
    ---向上位移，且字体缩放
    tween:Append(Util.TweenTo(0, 1.1, 0.25, function(v)
        local offset = Vector2(0, v * self.offset)
        f.transform.anchoredPosition = t1 + offset
        s.transform.anchoredPosition = t2 + offset
        if v > 1 then
            local scale = Vector3(1, 1, 1) * v
            f.transform.localScale = scale
            s.transform.localScale = scale
        end
    end))
    ---向下回弹，且字体缩放
    tween:Append(Util.TweenTo(0, 0.1, 0.25, function(v)
        local offset = Vector2(0, v * self.offset)
        f.transform.anchoredPosition = target1 - offset
        s.transform.anchoredPosition = target2 - offset
        local scale = Vector3(1, 1, 1) * (1.1 - v)
        f.transform.localScale = scale
        s.transform.localScale = scale
    end))
    self.tween:Append(tween)
    self.tween:AppendInterval(1)
end

---返回item的标题，是否是tor
function Element:GetTitle(rewards, name)
    local isTor, reward = ShopManager.IsWorkTimeOverReward(rewards)

    if name ~= nil and name ~= "" then
        return GetLang(name), isTor
    end

    if isTor then
        return Utils.GetTimeFormat4(reward.count), isTor
    end

    if #rewards > 0 then
        return Utils.FormatCount(rewards[1].count), isTor
    end

    return ""
end

function Element:OnDestroy()
    if self.tween then
        self.tween:Kill()
        self.tween = nil
    end
    if self.shopPanelItemData then 
        if ShopManager.HasCD(self.shopPanelItemData.config.condition_claim_cd) then
            EventManager.RemoveListener(EventType.TIME_REAL_PER_SECOND, self.RefreshCooldownFunc)
        end
    end
end
