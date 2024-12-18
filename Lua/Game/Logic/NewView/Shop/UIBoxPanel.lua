---@class UIBoxPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIBoxPanel = Panel;

local BgPath = {
    ["box_blue"] = "store_img_blue",
    ["box_purple"] = "store_img_purple",
    ["box_gold"] = "store_img_yellow",
}

local animation = {
    ["box_blue"] = 1,
    ["box_purple"] = 2,
    ["box_gold"] = 3,
}

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}

    this.uidata.mask = this.BindUIControl("Mask", this.HideUI)
    this.uidata.imgBg = this.GetUIControl("Bg/Common/ImgBg", "Image")
    this.uidata.icon = this.GetUIControl("Bg/Common/ImgIcon", "Image")
    this.uidata.btnClose = this.BindUIControl("Bg/Common/BtnClose", this.HideUI)
    this.uidata.txtName = this.GetUIControl("Bg/Common/Txts/TxtName", "Text")
    this.uidata.txtGold = this.GetUIControl("Bg/Common/Txts/TxtGold", "Text")
    this.uidata.txtTip = this.GetUIControl("Bg/Common/Txts/TxtTip", "Text")
    this.uidata.baseItems = this.GetUIControl("Bg/Common/Items")
    this.uidata.imgTitle = this.GetUIControl("Bg/Odds/ImgTitle")
    this.uidata.addTitle = this.GetUIControl("Bg/Odds/ImgTitle/Txt", "Text")
    this.uidata.addItems = this.GetUIControl("Bg/Odds/Items")
    this.uidata.btnBuy = this.BindUIControl("Bg/Btn/BtnBuy", this.OnBuyClick)
    this.uidata.buy = this.GetUIControl("Bg/Btn/BtnBuy/Buy")
    this.uidata.txtBuy = this.GetUIControl("Bg/Btn/BtnBuy/Buy/Txt", "Text")
    this.uidata.imgBuy = this.GetUIControl("Bg/Btn/BtnBuy/Buy/Img", "Image")
    this.uidata.txtCD = this.GetUIControl("Bg/Btn/BtnBuy/TxtCD", "Text")
    this.uidata.box = this.GetUIControl("Bg/Common/Box", "SkeletonGraphic")
    this.uidata.ad = this.GetUIControl("Bg/Btn/BtnBuy/Ad")
end

function Panel.InitEvent()
    --绑定UGUI事件
end

function Panel.OnShow(id, shopPanelItemData, buyClick)
    UIUtil.openPanelAction(this.gameObject)
    this.cityId = DataManager.GetCityId()
    this.boxId = id
    this.boxConfig = ConfigManager.GetBoxConfig(this.boxId)
    this.shopPanelItemData = shopPanelItemData
    this.buyClick = buyClick

    this.RefreshButton()
    this.RefreshTip()
    EventManager.AddListener(EventType.TIME_REAL_PER_SECOND, this.RefreshButton)

    SetImage(this.behaviour, this.uidata.imgBg, BgPath[this.boxConfig.id])

    SafeSetActive(this.uidata.txtName.gameObject, this.boxConfig.id ~= "box_gold")
    SafeSetActive(this.uidata.txtGold.gameObject, this.boxConfig.id == "box_gold")
    this.uidata.txtName.text = GetLang(this.boxConfig.name)
    this.uidata.txtGold.text = GetLang(this.boxConfig.name)
    this.uidata.addTitle.text = GetLang("ui_shop_box_probability")

    local baseRewardStr, additionRewardStr = BoxManager.GetBoxRewardDetails(this.boxId)
    local base = Utils.ParseReward(baseRewardStr, false)
    local add = Utils.ParseReward(additionRewardStr, false)
    for i = 1, this.uidata.baseItems.transform.childCount do
        local go = this.uidata.baseItems.transform:GetChild(i - 1).gameObject
        SafeSetActive(go, false)
    end
    for i = 1, this.uidata.addItems.transform.childCount do
        local go = this.uidata.addItems.transform:GetChild(i - 1).gameObject
        SafeSetActive(go, false)
    end
    this.InitItem(this.uidata.baseItems, base)
    this.InitItem(this.uidata.addItems, add)
    ForceRebuildLayoutImmediate(this.uidata.imgTitle.gameObject)

    this.ShowSpine()
end

function Panel.ShowSpine()
    this.uidata.box:Initialize(true)
    local e = this.uidata.box.AnimationState:SetAnimation(0, animation[this.boxConfig.id] .. "_1", false)
    e:AddOnComplete(function()
        this.uidata.box.AnimationState:SetAnimation(0, animation[this.boxConfig.id] .. "_2", true)
    end)
end

function Panel.RefreshButton()
    this.RefreshLastAvailableConfig()
    local inCD = ShopManager.GetShopItemInCooldown(this.config)
    local isAd = PaymentManager.IsAd(ConfigManager.GetShopPackage(this.packageId))

    local gemCount = PaymentManager.GetDiamondFromCost(this.packageId)

    SafeSetActive(this.uidata.buy.gameObject, not inCD and gemCount > 0)
    SafeSetActive(this.uidata.txtCD.gameObject, inCD or gemCount <= 0 or isAd)
    SafeSetActive(this.uidata.ad.gameObject, isAd)
    GreyObject(this.uidata.btnBuy, inCD and gemCount <= 0, true, false)
    ForceRebuildLayoutImmediate(this.uidata.btnBuy.gameObject)
    if inCD then
        this.uidata.txtCD.text = TimeUtil.format4(ShopManager.GetShopItemRemainTime(this.config, ShopManager.GetNow()))
    else
        if gemCount > 0 then
            this.uidata.txtBuy.text = "x" .. gemCount
        else
            this.uidata.txtCD.text = GetLang("ui_shop_box_free")
        end
    end
end

function Panel.RefreshTip()
    local hasCD = this.config.condition_claim_cd > 0
    local count = ShopManager.GetShopItemRemainCount(this.config.id)

    SafeSetActive(this.uidata.txtTip.gameObject, hasCD)

    if hasCD then
        if count >= 0 then
            this.uidata.txtTip.text = GetLangFormat(this.config.condition_count_desc, count)
        else
            this.uidata.txtTip.text = GetLangFormat("ui_shop_box_reset_time", this.config.condition_claim_cd / Time2
                .Hour)
        end
    end
end

function Panel.InitItem(parent, datas)
    SafeSetActive(parent.transform.parent.gameObject, next(datas) ~= nil)
    if next(datas) ~= nil then
        local go = parent.transform:GetChild(0).gameObject
        local count = parent.transform.childCount
        for i, v in ipairs(datas) do
            local item = nil
            if i >= count then
                item  = GOInstantiate(go, parent.transform)
                count = count + 1
            else
                item = parent.transform:GetChild(i)
            end
            item.gameObject:SetActive(true)
            this.Refresh(item, v)
        end
    end
end

function Panel.Refresh(item, data)
    local itemConfig = (data.addType == RewardAddType.Item or data.addType == RewardAddType.OverTime or
            data.addType == RewardAddType.DailyItem) and ConfigManager.GetItemConfig(data.id) or
        data.addType == RewardAddType.Box and ConfigManager.GetBoxConfig(data.id) or nil
    local icon = item.transform:Find("ImgIcon"):GetComponent("Image")
    local num = item.transform:Find("TxtNum"):GetComponent("Text")

    Utils.SetIcon(icon, itemConfig.icon, function ()
        icon:SetNativeSize()
    end)
    num.text = data.count
    UIUtil.AddItem(icon, data.id, ToolTipDir.Up)
end

function Panel.OnBuyClick()

    SDKAnalytics.TraceEvent(163)

    if this.buyClick then
        this.buyClick()
    end
end

---@return Shop, ShopPackage
function Panel.RefreshLastAvailableConfig()
    -- box 获取可用config
    -- 免费箱子和广告箱子都CD时，展示免费箱子CD
    -- 免费箱子CD，广告箱子都有时，展示广告箱子可领，领取后，展示免费箱子CD
    -- 免费箱子有，广告箱子CD时，展示免费箱子可领，领取后，展示免费箱子CD
    -- 免费箱子有，广告箱子有时，展示免费箱子可领，领取后，展示广告箱子可领，领取后展示免费箱子CD
    -- 配置要求，免费箱子的sort必须小于广告箱子的sort

    table.sort(
        this.shopPanelItemData.configList,
        function(a, b)
            return a.sort < b.sort
        end
    )

    local config
    for i = 1, #this.shopPanelItemData.configList do
        if ShopManager.CheckItem(this.cityId, this.shopPanelItemData.configList[i].id, ShopManager.Action.Buy) then
            config = this.shopPanelItemData.configList[i]
            break
        end
    end

    --如果没有找到可以买的项目，那么就是用第一个配置(免费箱子)
    if config == nil then
        config = this.shopPanelItemData.configList[1]
    end

    local package

    if config ~= nil then
        package = ShopManager.GetPackageByShopId(config.id)
    end

    this.config = config
    this.packageId = package.id
end

function Panel.HideUI()
    EventManager.RemoveListener(EventType.TIME_REAL_PER_SECOND, this.RefreshButton)
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UIBox)
    end)
end
