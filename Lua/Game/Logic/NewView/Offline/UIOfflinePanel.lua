---@class UIOfflinePanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIOfflinePanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.txtTitle1 = this.GetUIControl("Title/TxtTitle1", "Text")
    this.uidata.txtTitle2 = this.GetUIControl("Title/TxtTitle2", "Text")
    this.uidata.progress = this.GetUIControl("Time/Progress")
    this.uidata.progressBg = this.GetUIControl(this.uidata.progress, "ImgBg")
    this.uidata.progressBar = this.GetUIControl(this.uidata.progress, "ImgBar", "Image")
    this.uidata.tip = this.GetUIControl(this.uidata.progressBg, "Tip")
    this.uidata.txtTip = this.GetUIControl(this.uidata.tip, "TxtTime", "Text")
    this.uidata.cursor = this.GetUIControl(this.uidata.tip, "Cursor")
    this.uidata.txtTimeInfo = this.GetUIControl("Time/TxtInfo", "Text")
    this.uidata.scroll = this.GetUIControl("Props", "ScrollRect")
    this.uidata.content = this.GetUIControl(this.uidata.scroll, "Viewport/Content")
    this.uidata.item = this.GetUIControl(this.uidata.content, "Item")
    this.uidata.report = this.GetUIControl("Info/Report")
    this.uidata.txtInfo = this.GetUIControl("Info/Report/Txt", "Text")
    this.uidata.imgDie = this.GetUIControl("Info/Report/Die/ImgIcon", "Image")
    this.uidata.txtDie = this.GetUIControl("Info/Report/Die/TxtNum", "Text")
    this.uidata.imgMan = this.GetUIControl("Info/Report/Man/ImgIcon", "Image")
    this.uidata.txtMan = this.GetUIControl("Info/Report/Man/TxtNum", "Text")
    this.uidata.subscription = this.GetUIControl("Info/Subscription")
    this.uidata.imgIcon = this.GetUIControl("Info/Subscription/ImgIcon", "Image")
    this.uidata.txtDesc = this.GetUIControl("Info/Subscription/TxtDesc", "Text")
    this.uidata.txtAddTime = this.GetUIControl("Info/Subscription/TxtTime", "Text")
    this.uidata.btnBuy = this.BindUIControl("Info/Subscription/BtnBuy", this.OnClickGiftBag)
    this.uidata.txtBuy = this.GetUIControl(this.uidata.btnBuy, "Txt", "Text")
    this.uidata.btnGet = this.BindUIControl("Info/ButtonBar/BtnGet", this.OnClockClaim)
    this.uidata.txtGet = this.GetUIControl(this.uidata.btnGet, "Txt", "Text")
    this.uidata.btnAd = this.BindUIControl("Info/ButtonBar/BtnAd", this.OnClockAd)
    this.uidata.txtAdNum = this.GetUIControl(this.uidata.btnAd, "Txt/TxtNum", "Text")

    this.uidata.none = this.GetUIControl("None")
    this.uidata.txtNone = this.GetUIControl(this.uidata.none, "Txt", "Text")

    this.items = {}

    this.canvasWidth = 750
end

function Panel.InitEvent()
    --绑定UGUI事件
end

function Panel.OnShow()
    TutorialManager.isOpeningUIOffline = false
    this.cityId = DataManager.GetCityId()
    this.uidata.txtTitle1.text = GetLang("UI_Oflline_Title")
    this.uidata.txtTitle2.text = GetLang("UI_Oflline_Subtitle_2")
    this.uidata.txtInfo.text = GetLang("UI_Oflline_Subtitle_3")
    this.uidata.txtBuy.text = GetLang("ui_shop_subscription_btn_get")
    this.uidata.txtGet.text = GetLang("ui_shop_card_box_btn_claim")
    
    this.uidata.txtNone.text = GetLang("UI_Oflline_Tips_1")
    this.offlineDefaultMaxTime = ConfigManager.GetMiscConfig("default_max_offline_time")
    this.offlineRealTime = OfflineManager.realOfflineTime
    this.offlineReward = OfflineManager.offlineReward

    this.UpdateOfflineTime()
    this.uidata.txtDesc.text = GetLang("ui_city_subscription_offline")
    this.uidata.txtAddTime.text = GetLang("ui_city_subscription_offline_hour")
    local unlock = FunctionsManager.IsOpen(this.cityId, FunctionsType.SurvivorSick)
    SafeSetActive(this.uidata.report.gameObject, unlock)
    if unlock then
        this.uidata.txtDie.text = Utils.FormatCount(OfflineManager.offlineHealCount)
        this.uidata.txtMan.text = Utils.FormatCount(OfflineManager.offlineDeadCount)
    end
    --创建离线奖励
    this.rewardItemList = {}
    this.rewardItemNumList = {}
    for itemId, itemCount in pairs(this.offlineReward) do
        if not DataManager.CheckInfinity(this.cityId, itemId) then
            local item = this.InitItem(itemId, itemCount)
            this.rewardItemList[itemId] = item
            this.rewardItemNumList[itemId] = itemCount
        end
    end
    ForceRebuildLayoutImmediate(this.uidata.content)
    SafeSetActive(this.uidata.none, this.rewardItemList == nil or next(this.rewardItemList) == nil)
    --添加图标tips
    UIUtil.AddToolTip(this.uidata.imgMan, GetLang("UI_cured_survivor_name"), ToolTipDir.Up)
    UIUtil.AddToolTip(this.uidata.imgDie, GetLang("UI_dead_survivor_name"), ToolTipDir.Up)
    this.OnRefresh(2)

    this.UpdateAd()
end

function Panel.InitItem(itemId, itemCount)
    local item = GOInstantiate(this.uidata.item, this.uidata.content.transform)
    this.items[itemId] = item
    SafeSetActive(item, true)
    local icon = item.transform:Find("ImgIcon"):GetComponent("Image")
    local txt = item.transform:Find("TxtNum"):GetComponent("Text")
    Utils.SetItemIcon(icon, itemId, nil, true)
    txt.text = Utils.FormatCount(itemCount)
    txt.color = itemCount < 0 and CreateColorFromHex(180, 18, 18) or CreateColorFromHex(235, 201, 164)
    UIUtil.AddItem(icon, itemId)

    return item
end

--更新离线时间
function Panel.UpdateOfflineTime()
    this.offlineMaxTime = OfflineManager.GetOfflineMaxTime()
    this.offlineTime = 0
    if this.offlineRealTime > this.offlineMaxTime then
        this.offlineTime = this.offlineMaxTime
    else
        this.offlineTime = this.offlineRealTime
    end
end

--更新离线奖励
function Panel.UpdateOfflineReward()
    this.offlineRewardExtra = {}
    if this.offlineRealTime > this.offlineDefaultMaxTime then
        local extraFactor = this.offlineTime / this.offlineDefaultMaxTime - 1
        for itemId, itemCount in pairs(this.offlineReward) do
            if itemCount > 0 then
                this.offlineRewardExtra[itemId] = itemCount * extraFactor
                DataManager.AddMaterial(this.cityId, itemId, itemCount * extraFactor, "OfflineReward", "OfflineReward")
            end
        end
    end
end

--刷新面板
function Panel.OnRefresh(tweenTime)
    this.isSubscription = false
    -- if CityManager.GetIsEventScene(this.cityId) then
    --     if BoostManager.GetCommonBoosterFactor(this.cityId, CommonBoostType.EventCashExpDouble) > 1 then
    --         this.SetGiftBag(true, false)
    --     else
    --         this.SetGiftBag(false, true)
    --     end
    -- else
    if BoostManager.GetRxBoosterValue(this.cityId, RxBoostType.OfflineTime) > 0 then
        this.isSubscription = true
        this.SetGiftBag(true, false)
    else
        this.SetGiftBag(false, FunctionsManager.IsOpen(this.cityId, FunctionsType.Shop))
    end
    -- end
    --离线时间进度
    local reaOfflineTimeFormat = Utils.GetTimeFormat4(this.offlineRealTime)
    local maxOfflineTimeFormat = Utils.GetTimeFormat4(this.offlineMaxTime)
    local offlineProgress = this.offlineTime / this.offlineMaxTime
    if offlineProgress >= 1 then
        this.uidata.txtTimeInfo.text = GetLangFormat("ui_offline_earning_full", reaOfflineTimeFormat,
            maxOfflineTimeFormat)
        this.isFull = true
    else
        this.uidata.txtTimeInfo.text = GetLangFormat("ui_offline_earning", reaOfflineTimeFormat)
    end
    -- this.OfflineMax.text = GetLang("UI_Oflline_Tips_time_max") .. " " .. maxOfflineTimeFormat
    -- ForceRebuildLayoutImmediate(this.Content)
    --刷新进度条
    local width = this.uidata.progressBg.transform.rect.width - 20
    local offset = 0
    local function UpdateSliderProgress(p)
        local progress = offlineProgress * p
        this.uidata.progressBar.fillAmount = progress
        this.uidata.txtTip.text = Utils.GetTimeFormat4(this.offlineMaxTime * progress)
        this.uidata.tip.transform.anchoredPosition = Vector2(width * progress + offset,
            this.uidata.tip.transform.anchoredPosition.y)
        ForceRebuildLayoutImmediate(this.uidata.tip.gameObject)
        this.PatchOffset()
    end
    --更新进度条完成
    local function UpdateSliderComplete()
        this.uidata.txtTip.text = Utils.GetTimeFormat4(this.offlineTime)
        this.uidata.tip.transform.anchoredPosition = Vector2(width * offlineProgress + offset,
            this.uidata.tip.transform.anchoredPosition.y)
        ForceRebuildLayoutImmediate(this.uidata.tip.gameObject)
        TimeModule.addDelay(0, function()
            this.PatchOffset()
        end)
    end
    this.sliderTweener = DOTween.Sequence()
    this.sliderTweener:Append(Util.TweenTo(0, 1, tweenTime, UpdateSliderProgress))
    this.sliderTweener:OnComplete(UpdateSliderComplete)
    TimeModule.addDelay(0.5, function()
        this.sliderTweener:Play()
    end)
    --检测额外奖励
    if this.offlineRewardExtra then
        for itemId, itemCount in pairs(this.offlineRewardExtra) do
            this.UpdateItem(itemId, this.offlineReward[itemId] + itemCount)
        end
    end
end

function Panel.PatchOffset()
    if this.widthOffset == nil then
        this.widthOffset = (this.canvasWidth - this.uidata.progressBg.transform.sizeDelta.x) / 2
    end
    local size = this.uidata.tip.transform.sizeDelta.x / 2
    local tipOffsetMin = this.uidata.tip.transform.anchoredPosition.x - size
    local tipOffsetMax = this.uidata.tip.transform.anchoredPosition.x + size
    local targetOffset = nil
    local width = this.canvasWidth / 2
    if tipOffsetMin < -this.widthOffset then
        targetOffset = tipOffsetMin + this.widthOffset
    elseif tipOffsetMax > this.canvasWidth - this.widthOffset then
        targetOffset = tipOffsetMax - (this.canvasWidth - this.widthOffset)
    else
        targetOffset = 0
    end

    local target = Vector2(targetOffset, 0)
    this.uidata.tip.transform.anchoredPosition = this.uidata.tip.transform.anchoredPosition - target
    this.uidata.cursor.transform.anchoredPosition = target
end

function Panel.UpdateItem(itemId, itemCount)
    local item = this.rewardItemList[itemId]
    local txt = item.transform:Find("TxtNum"):GetComponent("Text")
    local start = tonumber(txt.text)
    local function UpdateItemCount(v)
        txt.text = Utils.FormatCount(v)
    end
    local function UpdateItemComplete()
        this.rewardItemNumList[itemId] = itemCount
        txt.text = Utils.FormatCount(itemCount)
    end

    local itemUpdateTweener = Util.TweenTo(start, itemCount, 2, UpdateItemCount)
    itemUpdateTweener:OnComplete(UpdateItemComplete)
end

--设置礼包购买
function Panel.SetGiftBag(isbuy, isShowGift)
    SafeSetActive(this.uidata.subscription, not isbuy)
end

--点击购买礼包
function Panel.OnClickGiftBag()
    if CityManager.GetIsEventScene(this.cityId) then
        ShopManager.Buy(
            this.cityId,
            this.shopDisplay.id,
            function(rewards, errCode)
                if errCode == 0 then
                    this.UpdateOfflineTime()
                    this.UpdateOfflineReward()
                    this.OnRefresh(4)
                    this.needLookUpZoneByShopId = this.shopDisplay.id
                else
                    ShopManager.ShowErrCode(errCode)
                end
            end
        )
    else
        ShopManager.OpenSubscriptionConfirmPanel(
            ShopManager.SubscriptionType.City,
            function(success)
                this.isSuccess = success
                if success then
                    this.UpdateOfflineTime()
                    this.UpdateOfflineReward()
                end
            end,
            nil,
            nil,
            nil,
            function()
                if this.isSuccess then
                    this.OnRefresh(4)
                end
            end
        )
    end
end

--点击领奖
function Panel.OnClockClaim()
    this.HideUI()
end



function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        if this.ClosePanelAction ~= nil and type(this.ClosePanelAction) == "function" then
            this.ClosePanelAction()
        end
        if this.sliderTweener then
            this.sliderTweener:Kill()
            this.sliderTweener = nil
        end

        -- if this.needLookUpZoneByShopId ~= nil then
        --     ShopManager.LookUpZoneByShopId(this.needLookUpZoneByShopId, this.OfflinePanelCanvasGroup.transform)
        -- end
        HideUI(UINames.UIOffline)
        HideUI(UINames.UILoading)
    end)
end

function Panel.OnHide()
    this.pos = {}
    for k, v in pairs(this.items) do
        this.pos[k] = v.transform.position
    end
    Analytics.Event("OfflinePanelClick", { isBuffActive = false, isCitySubscription = this.isSubscription })
    GameManager.SetOfflineAction(GameAction.OfflineClose)
    local reward = {}
    for itemId, item in pairs(this.rewardItemList) do
        if this.rewardItemNumList[itemId] > 0 then
            reward[itemId] = this.rewardItemNumList[itemId]
        end
    end
    if next(reward) then
        ResAddEffectManager.AddResEffectFromNormalBoard(reward, false, { isFull = this.isFull }, this.pos)
    end
    EventManager.Brocast(EventDefine.OnOfflineOver)
end

function Panel.OnClockAd()
    -- 没有收益
    if not OfflineManager.adOfflineReward or next(OfflineManager.adOfflineReward) == nil then 
        ShowTips(GetLang("ad_offline_tip"))
        return 
    end

    local watchCount, maxCount, remainCount = AdManager.GetCount(AdSourceType.UIOffline)
    if remainCount == 0 then 
        ShowTips(GetLang("ad_day_limit_tip2"))
        return
    end
    AdManager.ShowConfirmDialog(AdSourceType.UIOffline, function()
        -- 观看广告成功
        AdManager.AddCount(AdSourceType.UIOffline)
        this.UpdateAd()
        this.GetAdReward()
    end, function()
        -- 取消观看
    end)
end

-- 
function Panel.UpdateAd()
    local watchCount, maxCount, remainCount = AdManager.GetCount(AdSourceType.UIOffline)
    this.uidata.txtAdNum.text = ("(%s/%s)"):format(maxCount - watchCount, maxCount)
    GreyObject(this.uidata.btnAd.gameObject, remainCount == 0, true, true)
end

-- 展示 30 分钟的奖励
function Panel.GetAdReward()
    OfflineManager.GetAdReward()
end