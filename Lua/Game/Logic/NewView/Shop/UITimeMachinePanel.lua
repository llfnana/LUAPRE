---@class UITimeMachinePanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UITimeMachinePanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.txtTitle = this.GetUIControl("Content/Title/Txt", "Text")
    this.uidata.txtName = this.GetUIControl("Content/Item/TxtName", "Text")
    this.uidata.txtDesc = this.GetUIControl("Content/Item/TxtDesc", "Text")
    this.uidata.imgIcon = this.GetUIControl("Content/Item", "Image")
    this.uidata.btnClose = this.BindUIControl("Content/BtnClose", this.HideUI)
    this.uidata.txtOddTitle = this.GetUIControl("Content/Odds/ImgTitle/Txt", "Text")
    this.uidata.items = this.GetUIControl("Content/Odds/Items")
    this.uidata.btnBuy = this.GetUIControl("Content/Btn/BtnBuy")
    this.uidata.imgBuyIcon = this.GetUIControl("Content/Btn/BtnBuy/ImgIcon", "Image")
    this.uidata.txtBuyNum = this.GetUIControl("Content/Btn/BtnBuy/TxtNum", "Text")
    this.uidata.txtUse = this.GetUIControl("Content/Btn/BtnBuy/TxtUse", "Text")
end

function Panel.InitEvent()
    --绑定UGUI事件
end

function Panel.OnShow(data)
    UIUtil.openPanelAction(this.gameObject)
    this.cityId = DataManager.GetCityId()
    this.config = data.config
    this.package = data.package
    this.itemConfig = data.itemConfig
    this.status = data.status
    this.onClick = data.onClick

    this.uidata.txtTitle.text = GetLang("ui_shop_subscription_detail")
    this.uidata.txtOddTitle.text = GetLang("ui_shop_box_probability")
    this.uidata.txtName.text = GetLang(this.config.button_desc)
    this.uidata.txtDesc.text = GetLang(this.config.desc)
    this.SetImage(this.uidata.imgIcon, this.config.banner_pic, nil, true)
    this.gemCost = 0
    if Utils.GetTableLength(this.package.cost) > 0 then
        for k, v in pairs(this.package.cost) do
            if k == "Gem" then
                this.gemCost = this.gemCost + v
            end
        end
    end
    this.uidata.txtUse.text = GetLang("ui_shop_timeskip_use")
    this.uidata.txtBuyNum.text = this.gemCost

    this.rewards = OverTimeProductionManager.Get(this.cityId):GetTimeSkipReward(this.itemConfig.duration)

    table.sort(
        this.rewards,
        function(a, b)
            local aSort = a.sort
            local bSort = b.sort

            if aSort == nil then
                aSort = ConfigManager.GetItemConfig(a.id).sort
            end

            if bSort == nil then
                bSort = ConfigManager.GetItemConfig(b.id).sort
            end

            return aSort > bSort
        end
    )

    for i = 1, this.uidata.items.transform.childCount do
        local go = this.uidata.items.transform:GetChild(i - 1).gameObject
        SafeSetActive(go, false)
    end

    for i = 1, #this.rewards do
        if this.rewards[i].addType ~= RewardAddType.ZoneTime then
            this.InitItem(i)
        end
    end

    SafeSetActive(this.uidata.imgBuyIcon.gameObject, this.status == UIShopTimeMachineItem.Status.None)
    SafeSetActive(this.uidata.txtBuyNum.gameObject, this.status == UIShopTimeMachineItem.Status.None)
    SafeSetActive(this.uidata.txtUse.gameObject, this.status == UIShopTimeMachineItem.Status.Remain)

    this.AddClickEvent(this.uidata.btnBuy, function()
        this.onClick(
            function()
                this.HideUI()
            end
        )
    end)
end

function Panel.InitItem(i)
    local data = this.rewards[i]
    local item = nil
    if i >= this.uidata.items.transform.childCount then
        local go = this.uidata.items.transform:GetChild(0).gameObject
        item = GOInstantiate(go, this.uidata.items.transform)
    else
        item = this.uidata.items.transform:GetChild(i).gameObject
    end
    SafeSetActive(item, true)
    local icon = item.transform:Find("ImgIcon"):GetComponent("Image")
    icon.gameObject:SetActive(false)
    local num = item.transform:Find("TxtNum"):GetComponent("Text")
    Utils.SetRewardIcon(data, icon, nil)
    num.text = Utils.FormatCount(data.count)
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UITimeMachine)
    end)
end
