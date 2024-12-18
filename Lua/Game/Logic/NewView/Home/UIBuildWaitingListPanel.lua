---@class UIBuildWaitingListPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIBuildWaitingListPanel = Panel;

require "Game/Logic/NewView/Home/UIBuildWaitingListPanelItem"

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
    this.uidata.panel = this.GetUIControl("Panel")
    this.uidata.title = this.GetUIControl("Panel/Title")
    this.uidata.txtTitle = this.GetUIControl(this.uidata.title, "Txt", "Text")
    this.uidata.btnClose = this.BindUIControl(this.uidata.title, "BtnClose", this.HideUI)
    this.uidata.comm = this.GetUIControl("Panel/Comm")
    this.uidata.max = this.GetUIControl(this.uidata.comm, "Max")
    this.uidata.txtMax = this.GetUIControl(this.uidata.max, "Txt", "Text")
    this.uidata.vipView = this.GetUIControl(this.uidata.comm, "VipView")
    this.uidata.txtVipViewTip = this.GetUIControl(this.uidata.vipView, "Txt", "Text")
    this.uidata.txtVipViewAddNum = this.GetUIControl(this.uidata.vipView, "TxtNum", "Text")
    this.uidata.btnGet = this.BindUIControl(this.uidata.vipView, "Btn", this.OnClickGet)
    this.uidata.txtGet = this.GetUIControl(this.uidata.btnGet, "Txt", "Text")
    this.uidata.items = this.GetUIControl(this.uidata.comm, "Items")
    this.uidata.noAny = this.GetUIControl("Panel/NoAny")
    this.uidata.txtNoAny = this.GetUIControl(this.uidata.noAny, "Txt", "Text")
end

function Panel.InitEvent()
    --绑定UGUI事件
end

function Panel.OnShow()
    this.cityId = DataManager.GetCityId()
    this.isClosed = false
    this.OnInit()
    this.SetLang()
    UpdateBeat:Add(this.OnUpdate, this)
end

function Panel.SetLang()
    this.uidata.txtTitle.text = GetLang("ui_survivor_statistics_title")
    this.uidata.txtVipViewTip.text = GetLang("ui_shop_subscription_city_build")
    this.uidata.txtNoAny.text = GetLang("UI_build_waiting_tips")
end

function Panel.HideUI()
    UpdateBeat:Remove(this.OnUpdate, this)
    this.isClosed = true
    HideUI(UINames.UIBuildWaitingList)
end

function Panel.OnInit()
    ---@type List

    this.RefreshVipView()

    this.RefreshPanelItems()
end

function Panel.OnClickGet()
    ShopManager.OpenSubscriptionConfirmPanel(
        ShopManager.SubscriptionType.City,
        function(success)
            if success then
                this.RefreshVipView()
                this.RefreshPanelItems()
                this.HideUI()
            end
        end,
        nil,
        nil,
        nil,
        function()
            if not this.isClosed then
                this.RefreshVipView()
                this.RefreshPanelItems()
            end
        end
    )
end

function Panel.RefreshVipView()
    -- this.SubscribedGroup:SetActive(false)
    -- this.NotSubscribedGroup:SetActive(false)
    -- if CityManager.GetIsEventScene() then
    --     this.EventDescriptionGroup:SetActive(true)
    --     return
    -- end
    SafeSetActive(this.uidata.vipView.gameObject, false)
    SafeSetActive(this.uidata.max.gameObject, false)
    local shopId = 206
    if not ShopManager.CheckItem(this.cityId, shopId, ShopManager.Action.Show) then
        return
    end
    local vipBuildQueue = BoostManager.GetRxBoosterValue(this.cityId, RxBoostType.ConstructionQueue)
    SafeSetActive(this.uidata.vipView.gameObject, vipBuildQueue <= 0)
    SafeSetActive(this.uidata.max.gameObject, vipBuildQueue > 0)
    this.uidata.txtMax.text = GetLang("toast_reach_max_queue")
    this.uidata.txtGet.text = GetLang("ui_shop_subscription_btn_get")
    if vipBuildQueue <= 0 then
        -- this.SubscribedGroup:SetActive(true)
    else
        -- this.NotSubscribedGroup:SetActive(true)
        local config = ConfigManager.GetBoostConfig("construction_queue2")
        local params = config.boost_params
        local buildQueue = tonumber(params.queueEffect)
        --TODO
        this.uidata.txtVipViewAddNum.text = "+" .. tostring(buildQueue)
    end
end

function Panel.RefreshPanelItems()
    this.panelItems = List:New()
    local buildQueue = MapManager.GetBuildQueue()
    for i = 1, this.uidata.items.transform.childCount do
        local go = this.uidata.items.transform:GetChild(i - 1)
        SafeSetActive(go.gameObject, false)
    end
    local index = 0
    for zoneId, value in pairs(buildQueue) do
        if value > 0 then
            index = index + 1
            local item = nil
            if index >= this.uidata.items.transform.childCount then
                local go = this.uidata.items.transform:GetChild(0).gameObject
                item = GOInstantiate(go, this.uidata.items.transform)
            else
                item = this.uidata.items.transform:GetChild(index).gameObject
            end
            SafeSetActive(item, true)

            ---@type UIBuildWaitingListPanelItem
            local panelItem = UIBuildWaitingListPanelItem:new()
            panelItem:InitPanel(this.behaviour, item)
            panelItem:OnInit(zoneId, this)
            this.panelItems:Add(panelItem)
        end
    end

    this.uidata.noAny:SetActive(MapManager.GetBuildQueueCount() == 0)
    TimeModule.addDelay(0.1, function()
        ForceRebuildLayoutImmediate(this.uidata.panel.gameObject)
    end)
end

function Panel.OnUpdate()
    local refresh = false
    this.panelItems:ForEach(function(paneItem)
        if paneItem:IsComplete() then
            refresh = true
            return true
        end
    end)

    if refresh then
        this.RefreshPanelItems()
        return
    end
    this.panelItems:ForEach(function(paneItem)
        paneItem:Update()
    end)
end
