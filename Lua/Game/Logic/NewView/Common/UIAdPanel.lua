---@class UIAdPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIAdPanel = Panel;

function Panel.OnAwake()
    this.cachedata = {}
    this.InitPanel()
    this.InitEvent()

    this.param = nil
end

function Panel.InitPanel()
    this.uidata = {}

    this.uidata.btnClose = SafeGetUIControl(this, "DialogBg/BtnClose", "Button")
    this.uidata.BtnReceive = SafeGetUIControl(this, "DialogBg/BtnReceive", "Button")
    this.uidata.RewardIcon = SafeGetUIControl(this, "DialogBg/RewardIcon", "Image")
    this.uidata.RewardText = SafeGetUIControl(this, "DialogBg/RewardTextBg/RewardText", "Text")
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.btnClose.gameObject, this.HideUI)

    SafeAddClickEvent(this.behaviour, this.uidata.BtnReceive.gameObject, function ()
        FloatIconManager.OnCloseAdPanel()
        this.param.onReceive()
        this.HideUI()
    end)
end

function Panel.OnShow(param)
    this.param = param
    UIUtil.openPanelAction(this.gameObject)

    this.UpdateView()
end

function Panel.HideUI()
    FloatIconManager.OnCloseAdPanel()
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UIAd)
    end)
end

function Panel.UpdateView()
    for item, num in pairs(this.param.reward) do
        Utils.SetItemIcon(this.uidata.RewardIcon, item, nil, true)
        this.uidata.RewardText.text = Utils.FormatCount(num)
    end
end
