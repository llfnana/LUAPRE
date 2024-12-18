---@class UINoticePanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UINoticePanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();
    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.btnClose = SafeGetUIControl(this, "BtnClose")
    this.uidata.textContent = SafeGetUIControl(this, "Box/TextScroll/Viewport/Content")
    this.uidata.text = SafeGetUIControl(this, "Box/TextScroll/Viewport/Content/TextMail", "HyperlinkText")   --邮件内容
    this.uidata.textTitle = SafeGetUIControl(this, "TitleItem/Text", "Text")--标题       
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.btnClose.gameObject, this.HideUI)
    -- 绑定超链接函数
    this.uidata.text.luaFunction = function (data)
        Application.OpenURL(data)
    end
end

function Panel.OnShow(param)
    this.data = param
    UIUtil.openPanelAction(this.gameObject)

    this.UpdatePanel()
end

function Panel.UpdatePanel()
    this.uidata.text.text = this.data.text
    ForceRebuildLayoutImmediate(this.uidata.textContent)
    this.uidata.textTitle.text = GetLang("UI_Notice_title")
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UINotice)
    end)
end

function Panel.OnHide()
    this.uidata.text.luaFunction = nil
end
