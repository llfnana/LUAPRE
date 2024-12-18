---@class UICityPassIntroductionPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UICityPassIntroductionPanel = Panel;

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
    this.uidata.txtTitle = this.GetUIControl("Panel/Title/Txt", "Text")
    this.uidata.btnClose = this.BindUIControl("Panel/Title/BtnClose", this.HideUI)
    -- this.uidata.imgCity = this.GetUIControl("Panel/Comm/Image", "Image")
    this.uidata.txtDesc = this.GetUIControl("Panel/Comm/TxtDesc", "Text")
    this.uidata.rewardTitle = this.GetUIControl("Panel/Reward/Title")
    this.uidata.txtRewardTitle = this.GetUIControl(this.uidata.rewardTitle, "Txt", "Text")
    this.uidata.rewardItems = this.GetUIControl("Panel/Reward/Items")
    this.uidata.btnYes = this.BindUIControl("Panel/Btns/BtnYes", this.OnClickYes)
    this.uidata.txtYes = this.GetUIControl(this.uidata.btnYes, "Txt", "Text")

    this.uidata.rewardItem = this.uidata.rewardItems.transform:GetChild(0).gameObject
end

function Panel.InitEvent()
    --绑定UGUI事件
end

function Panel.OnShow(param)
    UIUtil.openPanelAction(this.gameObject)
    this.data = param or {}
    this.uidata.txtRewardTitle.text = GetLang("UI_Resources_Item")
    this.uidata.txtYes.text = GetLang("ui_ok_btn")
    this.OnInit()
end

function Panel.HideUI()

    if this.cityId == 2 then
        SDKAnalytics.TraceEvent(158)
    elseif this.cityId == 3 then
        SDKAnalytics.TraceEvent(164)
    end

    UIUtil.hidePanelAction(this.gameObject, function()
        if this.ClosePanelAction then
            this.ClosePanelAction()
        end
        HideUI(UINames.UICityPassIntroduction)
    end)
end

function Panel.OnInit()
    -- AudioManager.PlayEffect("ui_enter_new_city")
    this.cityId = DataManager.GetCityId()
    this.config = ConfigManager.GetCityById(this.cityId)
    if this.config ~= nil then
        this.uidata.txtTitle.text = GetLang(this.config.city_name)
        this.uidata.txtDesc.text = GetLang(this.config.city_desc)
        -- TODO zhkxin 项目里没有配表的 city_pic 对应的资源，在注释掉
        -- this.SetImage(this.uidata.imgCity, this.config.city_pic)
    end

    this.rewardItemList = List:New()
    -- this.YesButton.onClick:AddListener(
    --     function()
    --         this.rewardItemList:ForEach(
    --             function(item)
    --                 local data = Utils.ConvertAttachment2Rewards(item.itemId, item.countMsg, item.type)
    --                 ResAddEffectManager.AddResEffect(item.gameObject.transform.position, data)
    --             end
    --         )
    --         this.OnClickYes()
    --     end
    -- )
    this.index = 0
    if this.data.Rewards then
        for itemId, count in pairs(this.data.Rewards) do
            -- local view = ResourceManager.Instantiate(this.CityPassIntroductionItemPrefab, this.RewardContent)
            -- local rewardItem = CityPassIntroductionItem:Create(view)
            -- rewardItem:OnInit(itemId, count)
            local item = this.InitItem(itemId, count)
            this.rewardItemList:Add({
                itemId = itemId,
                countMsg = count,
                gameObject = item.gameObject,
            })
        end
    end
    if this.data.Unlocks then
        for itemId, msgKey in pairs(this.data.Unlocks) do
            -- local view = ResourceManager.Instantiate(this.CityPassIntroductionItemPrefab, this.RewardContent)
            -- local rewardItem = CityPassIntroductionItem:Create(view)
            -- rewardItem:OnInit(itemId, msgKey)
            this.InitItem(itemId, msgKey)
        end
    end

    Analytics.Event("NewCityIntroductionOpen", {
        currentCityId = this.cityId,
    })
end

function Panel.InitItem(itemId, count)
    local item = nil
    this.index = this.index + 1
    if this.index >= this.uidata.rewardItems.transform.childCount then
        item = GOInstantiate(this.uidata.rewardItem, this.uidata.rewardItems.transform)
    else
        item = this.uidata.rewardItems.transform:GetChild(this.index).gameObject
    end
    SafeSetActive(item, true)

    local icon = item.transform:Find("ImgIcon"):GetComponent("Image")
    local txt = item.transform:Find("Txt"):GetComponent("Text")
    Utils.SetItemIcon(icon, itemId)
    txt.text = count
    UIUtil.AddItem(icon, itemId, 3) -- UITipBoxDir.Down

    return item
end

function Panel.OnClickYes()
    -- Analytics.Event("NewCityIntroductionClose", {
    --     currentCityId = this.cityId,
    -- })
    this.rewardItemList:ForEach(
        function(item)
            local data = Utils.ConvertAttachment2Rewards(item.itemId, item.countMsg, item.type)
            ResAddEffectManager.AddResEffect(item.gameObject.transform.position, data)
        end
    )
    this.HideUI()
end
