---@class UISubscriptionPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UISubscriptionPanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.bg = this.GetUIControl("Bg")
    this.uidata.txtTitle = this.GetUIControl("Bg/Common/ImgBg/Txt", "Text")
    this.uidata.imgIcon = this.GetUIControl("Bg/Common/ImgIcon", "Image")
    this.uidata.btnClose = this.BindUIControl("Bg/Common/BtnClose", this.HideUI)
    this.uidata.items = this.GetUIControl("Bg/Mid/Items")
    this.uidata.day = this.GetUIControl("Bg/Mid/Day")
    this.uidata.tip = this.GetUIControl("Bg/Mid/Day/P/Tip")
    this.uidata.txtTipNum = this.GetUIControl(this.uidata.tip, "TxtNum", "Text")
    this.uidata.txtTipDay = this.GetUIControl(this.uidata.tip, "TxtDay", "Text")
    this.uidata.bar = this.GetUIControl("Bg/Mid/Day/P/Mask/Bar")
    this.uidata.txtDesc = this.GetUIControl("Bg/Mid/Day/TxtDesc", "Text")
    this.uidata.btns = this.GetUIControl("Bg/Last/Btns")
    this.uidata.Buff = this.GetUIControl("Bg/Last/Buff")
    this.uidata.txtBuff = this.GetUIControl(this.uidata.Buff, "Txt", "Text")
    this.uidata.txtBuffTime = this.GetUIControl(this.uidata.Buff, "TxtTime", "Text")

    this.uidata.btnGet = this.BindUIControl("Bg/Last/BtnGet", this.OnClickGet)
    this.uidata.imgGetIcon = this.GetUIControl(this.uidata.btnGet, "Img")
    this.uidata.txtGetNum = this.GetUIControl(this.uidata.btnGet, "TxtNum", "Text")
    this.uidata.txtGet = this.GetUIControl(this.uidata.btnGet, "Txt", "Text")
    this.uidata.txtGetOver = this.GetUIControl(this.uidata.btnGet, "TxtOver", "Text")

    this.btns = {}
    for i = 1, this.uidata.btns.transform.childCount do
        local go = this.uidata.btns.transform:GetChild(i - 1).gameObject
        SafeSetActive(go, false)
        table.insert(this.btns, go)
    end

    this.items = {}
end

function Panel.InitEvent()
    --绑定UGUI事件
end

function Panel.OnShow(data)
    UIUtil.openPanelAction(this.gameObject)
    this.cityId = DataManager.GetCityId()
    this.configList = data.configList
    this.packageList = data.packageList
    this.buyFunc = data.buyFunc
    this.successBuyFunc = data.successBuyFunc
    this.windowCloseFunc = data.windowCloseFunc
    local purchased, packageId = ShopManager.GetGroupIncludePurchased(this.configList, TimeModule.getServerTime())
    this.SetImage(this.uidata.imgIcon, this.configList[1].banner_pic)

    local descItemPackageId = packageId
    if descItemPackageId == 0 then
        --还没有购买，那么读取第一个packageId
        descItemPackageId = this.packageList[1].id
    end

    this.uidata.txtTitle.text = GetLang("ui_shop_subscription_detail")

    for i, v in ipairs(this.items) do
        SafeSetActive(v.gameObject, false)
    end

    this.descList = string.split(this.configList[1].desc, ",")
    for i = 1, #this.descList do
        this.InitItem(i, descItemPackageId)
    end
    TimeModule.addDelay(0, function()
        ForceRebuildLayoutImmediate(this.uidata.items.transform.parent.gameObject)
        ForceRebuildLayoutImmediate(this.uidata.bg.gameObject)
    end)
    this.Refresh0ClockFunc = function()
        this.Refresh()
    end
    EventManager.AddListener(EventType.SHOP_0_CLOCK_REFRESH, this.Refresh0ClockFunc)
    EventManager.AddListener(EventDefine.OnBoostRemove, this.Refresh0ClockFunc)
    EventManager.AddListener(EventDefine.OnSubscriptionRefresh, this.Refresh0ClockFunc)

    this.Refresh()
end

function Panel.InitItem(i, id)
    local t = this.descList[i]
    local s = string.split(t, ":")
    local item = this.items[i]
    if item == nil then
        local go = this.uidata.items.transform:GetChild(0).gameObject
        item = GOInstantiate(go, this.uidata.items.transform)
        this.items[i] = item
    end
    SafeSetActive(item, true)
    local txtTip = item.transform:Find("Txt"):GetComponent("Text")
    local icon = item.transform:Find("Item/ImgIcon"):GetComponent("Image")
    local txt = item.transform:Find("Item/Txt"):GetComponent("Text")
    this.SetImage(icon, s[1])
    txt.text = GetLang(s[2])
    txtTip.text = GetLang(s[3])
end

---TODO
function Panel.Refresh()
    local purchased, canClaimed, packageId = ShopManager.CheckSubscriptionCanClaim(this.configList)
    local isHave = ShopManager.HasDailyRewardOfSubscription(packageId)
    local rewards = PaymentManager.GetPackageDailyReward(packageId)
    local key = PaymentManager.GetDailyNameByPackageId(packageId)
    local stock = DailyBagManager.GetItem(key, nil)

    local noHaveRward = rewards == nil or next(rewards) == nil

    SafeSetActive(this.uidata.items.gameObject, noHaveRward)
    SafeSetActive(this.uidata.day.gameObject, purchased and isHave)
    SafeSetActive(this.uidata.btns.gameObject, not purchased)
    SafeSetActive(this.uidata.Buff.gameObject, purchased and noHaveRward and not isHave)
    SafeSetActive(this.uidata.btnGet.gameObject, purchased and not noHaveRward)

    local now = ShopManager.GetNow()
    if purchased then
        if noHaveRward then
            --检查是否购买
            local pur, packageId = PaymentManager.GetSubscription(this.configList[1].id, nil, TimeModule.getServerTime())
            if pur == nil and #this.configList >= 2 then
                pur, packageId = PaymentManager.GetSubscription(this.configList[2].id, nil, TimeModule.getServerTime())
            end
            this.uidata.txtBuff.text = GetLang("ui_shop_subscription_btn_active")
            local leftTime = pur.expireTS - TimeModule.getServerTime()
            leftTime = leftTime < 0 and 0 or leftTime
            this.uidata.txtBuffTime.text = TimeUtil.format4(math.floor(leftTime) + 0.5)
            if leftTime == 0 then
                this.Refresh()
            end
        else
            local nowTime = Time2:New(GameManager.GameTime())
            local subscriptions = PaymentManager.GetAllValidSubscription(nowTime, packageId)

            local time = DailyBagManager.GetTime2()
            local can = DailyBagManager.CanUseItem(key, 1, nil)
            local day = DailyBagManager.GetItemDay(key)
            local now = subscriptions and this.GetDayNum(subscriptions.createTS, time.ts) or 0
            local maxDay = subscriptions and this.GetDayNum(subscriptions.createTS, subscriptions.expireTS) or 0
            local count = rewards[1].count
            local progress = now / maxDay
            SafeSetActive(this.uidata.imgGetIcon.gameObject, can)
            SafeSetActive(this.uidata.txtGetNum.gameObject, can)
            this.uidata.txtGetNum.text = "+" .. count

            this.uidata.txtTipNum.text = now
            this.uidata.txtTipDay.text = GetLang("UI_Mail_Time_Day")
            this.uidata.txtDesc.text = GetLangFormat("ui_vip_diamond_tips", maxDay * count, day * count)
            local barOffset = this.uidata.bar.transform.sizeDelta.x * (1 - progress)
            local tipOffset = this.uidata.bar.transform.sizeDelta.x * progress
            this.uidata.bar.transform.anchoredPosition = Vector2.New(-barOffset, 0)
            this.uidata.tip.transform.anchoredPosition = Vector2.New(tipOffset,
                this.uidata.tip.transform.anchoredPosition.y)

            GreyObject(this.uidata.btnGet.gameObject, not can, true, false)
            SafeSetActive(this.uidata.txtGet.gameObject, can)
            SafeSetActive(this.uidata.txtGetOver.gameObject, not can)
            this.uidata.txtGet.text = GetLang("ui_shop_card_box_btn_claim")
            this.uidata.txtGetOver.text = GetLang("ui_shop_subscription_btn_claimed")
        end
    else
        for i = 1, #this.btns do
            SafeSetActive(this.btns[i], #this.configList >= i and not purchased)
            if #this.configList >= i and not purchased then
                local curConfig = this.configList[i]
                local curPackage = this.packageList[i]

                local curPurchased, curCanClaimed, curPackageId = ShopManager.CheckSubscriptionCanClaim(curConfig)
                local curPackageId = PaymentManager.GetPackageDailyReward(curPackageId)
                local num = this.btns[i].transform:Find("TxtNum"):GetComponent("Text")
                local get = this.btns[i].transform:Find("Get")
                local txtGet = get.transform:Find("Txt"):GetComponent("Text")
                local txtGetNum = get.transform:Find("TxtNum"):GetComponent("Text")
                local txtOver = this.btns[i].transform:Find("TxtOver"):GetComponent("Text")

                num.text = this.GetButtonText(curConfig, curPackage)
                txtGet.text = GetLang("ui_shop_subscription_btn_claim")
                txtGetNum.text = "+" .. "100"
                txtOver.text = GetLang("ui_shop_subscription_btn_claimed")
                SafeSetActive(num.gameObject, not curCanClaimed and not curPurchased)
                SafeSetActive(get.gameObject, curCanClaimed and not curPurchased)
                SafeSetActive(txtOver.gameObject, curCanClaimed and curPurchased)

                this.AddClickEvent(this.btns[i],
                    function()
                        -- 如果是从shop窗口打开的
                        if this.buyFunc ~= nil then
                            this.buyFunc(
                                curConfig,
                                function()
                                    this.Refresh()
                                end
                            )
                            return
                        end

                        -- 从其他位置打开的这个窗口
                        this.Buy(curConfig)
                    end)
            end
        end
    end

    TimeModule.addDelay(0, function()
        ForceRebuildLayoutImmediate(this.uidata.bg.gameObject)
    end)
end

function Panel.GetDayNum(startT, endT)
    local num = math.ceil((endT - startT) / TimeUtil.DAY_SEC)
    return num < 0 and 0 or num
end

function Panel.GetButtonText(config, package)
    if config.button_desc == "" then
        return PaymentManager.GetPriceStr(package.product_id)
    end

    local t = PaymentManager.GetPriceStr(package.product_id)
    return GetLangFormat(config.button_desc, t)
end

function Panel.Buy(curConfig)
    -- 如果是从其他位置打开
    UIUtil.showWaitTip()
    ShopManager.Buy(
        this.cityId,
        curConfig.id,
        function(rewards, errCode)
            UIUtil.hideWaitTip()
            if this.successBuyFunc ~= nil then
                this.successBuyFunc(errCode == 0)
            end

            if errCode == 0 then
                if #rewards ~= 0 then
                    ResAddEffectManager.AddResEffectFromRewards(rewards, true, { hideFlying = true, isShop = true })
                end
                this.Refresh()
                if this.buyFunc then
                    this.buyFunc(this.configList[1])
                end
            else
                ShopManager.ShowErrCode(errCode)
            end
        end
    )
end

function Panel.OnClickGet()
    local purchased, canClaimed, packageId = ShopManager.CheckSubscriptionCanClaim(this.configList)
    local isHave = ShopManager.HasDailyRewardOfSubscription(packageId)
    local rewards = PaymentManager.GetPackageDailyReward(packageId)
    if not isHave then
        error("商品未购买：" .. packageId)
        return
    end
    if rewards == nil or next(rewards) == nil then
        error("商品没有奖励：" .. packageId)
        return
    end

    local key = PaymentManager.GetDailyNameByPackageId(packageId)
    local can = DailyBagManager.CanUseItem(key, 1, nil)
    if not can then
        return
    end

    PaymentManager.AddPackageDailyReward(packageId)
    this.Refresh()
    for k, v in pairs(rewards) do
        ResAddEffectManager.AddResEffect(this.uidata.imgGetIcon.transform.position, v)
    end
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        if this.windowCloseFunc ~= nil then
            this.windowCloseFunc()
        end
        HideUI(UINames.UISubscription)
    end)
end

function Panel.OnHide()
    EventManager.RemoveListener(EventType.SHOP_0_CLOCK_REFRESH, this.Refresh0ClockFunc)
    EventManager.RemoveListener(EventDefine.OnBoostRemove, this.Refresh0ClockFunc)
    EventManager.RemoveListener(EventDefine.OnSubscriptionRefresh, this.Refresh0ClockFunc)
end
