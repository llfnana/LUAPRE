---@class UISettingLanguagePanel : UIPanelBase
local Panel = UIPanelBaseMake()
local this = Panel
UISettingLanguagePanel = Panel

function Panel.OnAwake()
    this.cachedata = {}
    this.InitPanel()
    this.InitEvent()

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.btnClose = SafeGetUIControl(this, "BtnClose", "Button")

    this.uidata.temp = SafeGetUIControl(this, "Item")
    this.uidata.content = SafeGetUIControl(this, "Content")
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.btnClose.gameObject, this.HideUI)
end

function Panel.OnShow()
    UIUtil.openPanelAction(this.gameObject)
    this.Init()
end

function Panel.Init()
    this.selectLang = PlayerModule.getLanguage()
    this.langs = PlayerModule.getLanguageList()
    this.items = {}
    UIUtil.RemoveAllGameobject(this.uidata.content)
    this.UpdateContent()
    local titleText = SafeGetUIControl(this, "TitleItem/Text", "Text")
    titleText.text = GetLang("UI_Setting_Title")

    this.AddListener(EventDefine.LanguageChange, function ()
        local titleText = SafeGetUIControl(this, "TitleItem/Text", "Text")
        titleText.text = GetLang("UI_Setting_Title")
    end)
end

function Panel.UpdateContent()
    for k, v in ipairs(this.langs) do
        local item = this.items[k] or GOInstantiate(this.uidata.temp, this.uidata.content.transform)
        this.items[k] = item

        item:SetActive(true)
        local imgSelect = SafeGetUIControl(item, "Select", "Image")
        imgSelect.gameObject:SetActive(k == this.selectLang)
        local text = SafeGetUIControl(item, "Image/Text", "Text")
        text.text = GetLang(v.value)
        local btn = SafeGetUIControl(item, "Button", "Button")
        SafeAddClickEvent(this.behaviour, btn.gameObject, function ()
            this.selectLang = k
            PlayerModule.switchSettingLanguage(k)
            this.UpdateContent()
        end)
    end
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UISettingLanguage)
    end)
end
