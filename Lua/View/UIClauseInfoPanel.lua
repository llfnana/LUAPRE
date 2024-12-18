---@class UIClauseInfoPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIClauseInfoPanel = Panel;

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
    this.uidata.Box = SafeGetUIControl(this, "Box")
    -- this.uidata.text = SafeGetUIControl(this, "Box/TextScroll/Viewport/Content/TextMail", "HyperlinkText")
    -- this.uidata.Content1 = SafeGetUIControl(this, "Box/TextScroll_1/Viewport/Content")   --邮件内容
    this.uidata.textTitle = SafeGetUIControl(this, "TitleItem/Text", "Text")--标题                   
    this.TextContent = {}
    this.text = {}
    for i = 1 , 3 do
        this.TextContent[i] = SafeGetUIControl(this, "Box/" .. i .. "/Viewport/Content")
    end
    for i = 1, this.uidata.Box.transform.childCount do
        this.text[i] = this.uidata.Box.transform:Find(i)
    end
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.btnClose.gameObject, this.HideUI)
    -- 绑定超链接函数
    -- this.uidata.text.luaFunction = function (data)
    --     Application.OpenURL(data)
    -- end
end

function Panel.OnShow(type)
    UIUtil.openPanelAction(this.gameObject)

    this.UpdatePanel(type)
    for i = 1, 3 do
        ForceRebuildLayoutImmediate(this.TextContent[i])
        -- this.text[1]:SetActive(type == 1)
        SafeSetActive(this.uidata.Box.transform:Find(i).gameObject,type == i)
        -- SafeSetActive(SafeGetUIControl(this, "Box/TextScroll_" .. i .. "/Viewport/Content/TextMail", "HyperlinkText"), i == Type)
    end
end

function Panel.UpdatePanel(type)
    -- this.uidata.text.text = GetLang(title)
    
    if type == 3 then
        this.uidata.textTitle.text = "适龄提示"
    elseif type == 1 then
        -- body
        this.uidata.textTitle.text = "隐私政策"
        -- this.uidata.text.text = this.str1
    elseif type == 2 then
        -- body
        this.uidata.textTitle.text = "服务条款"
        -- this.uidata.text.text = this.str2
    end
    
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UIClauseInfo)
    end)
end
