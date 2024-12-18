---@class UISubscriptionTipPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UISubscriptionTipPanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.txtTitle = this.GetUIControl("ImgBg/Txt", "Text")
    this.uidata.btnClose = this.BindUIControl("BtnClose", this.HideUI)
    this.uidata.items = this.GetUIControl("Items")
    this.uidata.btns = this.GetUIControl("Btns")

    this.btns = {}
    for i = 1, this.uidata.btns.transform.childCount do
        local go = this.uidata.btns.transform:GetChild(i - 1).gameObject
        table.insert(this.btns, go)
    end
end

function Panel.InitEvent()
    --绑定UGUI事件
end

function Panel.OnShow()
    UIUtil.openPanelAction(this.gameObject)
    this.uidata.txtTitle.text = GetLang("ui_shop_subscription_detail")
    for i = 1, 6 do
        this.InitItem(i)
    end
    this.InitBtn(1, "UI_Setting_Terms_of_Service", function()
        Application.OpenURL(ConfigManager.GetMiscConfig("service_url"))
        -- UIUtil.showText("服务条款SDK")
    end)
    this.InitBtn(2, "UI_Setting_Privacy_Policy", function()
        Application.OpenURL(ConfigManager.GetMiscConfig("privacy_url"))
        -- UIUtil.showText("隐私政策SDK")
    end)
    this.InitBtn(3, "ui_setting_fanpage", function()
        UIUtil.showConfirmByData({
            Title = "ui_shop_subscription_recover_title",
            Description = "ui_shop_subscription_recover_content",
            YesText = "ui_yes_btn",
            ShowYes = true,
            OnYesFunc = function()
                PopupManager.Instance:CloseAllPanel()
            end
        })
    end)
    TimeModule.addDelay(0, function()
        ForceRebuildLayoutImmediate(this.uidata.items.gameObject)
    end)
end

function Panel.InitItem(i)
    local key = "ui_shop_subscription_tips_" .. i
    local item = nil
    if i >= this.uidata.items.transform.childCount then
        local go = this.uidata.items.transform:GetChild(0).gameObject
        item = GOInstantiate(go, this.uidata.items.transform)
    else
        item = this.uidata.items.transform:GetChild(i).gameObject
    end
    item:SetActive(true)
    local txt = item.transform:Find("TxtDesc"):GetComponent("Text")
    txt.text = GetLang(key)
end

function Panel.InitBtn(i, key, func)
    local btn = this.btns[i]
    local txt = btn.transform:Find("Txt"):GetComponent("Text")
    txt.text = GetLang(key)
    SafeAddClickEvent(this.behaviour, btn, func)
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UISubscriptionTip)
    end)
end
