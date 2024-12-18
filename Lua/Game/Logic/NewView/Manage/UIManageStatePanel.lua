---@class UIManageStatePanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIManageStatePanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();
    this.InitViewData()
    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.Mask = SafeGetUIControl(this, "Mask")
    this.uidata.ButtonClose = SafeGetUIControl(this, "ButtonClose")
    this.uidata.ItemCell = SafeGetUIControl(this, "ItemCell")
    this.uidata.Content = SafeGetUIControl(this, "ScrollView/Viewport/Content")
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.Mask, this.HideUI)
    SafeAddClickEvent(this.behaviour, this.uidata.ButtonClose, this.HideUI)
end

function Panel.OnShow()
    UIUtil.openPanelAction(this.gameObject)
end

function Panel.InitViewData()
    this.stateList = {
        WorkStateType.Work,
        WorkStateType.Pause,
        WorkStateType.Sick,
        WorkStateType.Protest,
        WorkStateType.Disable,
        WorkStateType.None
    }

    for key, workState in pairs(this.stateList) do
        local item = GOInstantiate(this.uidata.ItemCell)
        item.transform:SetParent(this.uidata.Content.transform, false)
        SafeSetActive(item.gameObject, true)
        local TextTitle = item.transform:Find("TextTitle"):GetComponent("Text")
        local TextDes = item.transform:Find("TextDes"):GetComponent("Text")
        TextTitle.text = GetLang("ui_survivor_working_status_title_" .. workState)
        TextDes.text = GetLang("ui_survivor_status_desc_" .. workState)

        local ImageIcon = item.transform:Find("ImageIcon"):GetComponent("Image").gameObject
        local ImageState = item.transform:Find("ImageState"):GetComponent("Image").gameObject
        local ResName = "icon_worker_people_empty_1"
        local StateResName = "icon_worker_subscript_riots"
        if workState == WorkStateType.None then
            SafeSetActive(ImageState, false)
        elseif workState == WorkStateType.Work then
            SafeSetActive(ImageState, false)
            ResName = "icon_worker_people_working_1"
        elseif workState == WorkStateType.Disable then
            SafeSetActive(ImageState, true)
            SafeSetActive(ImageIcon, true)
            ResName = "icon_worker_people_ill_1"
            StateResName = "icon_worker_subscript_lock"
        elseif workState == WorkStateType.Pause then
            ResName = "icon_worker_people_ill_1"
            SafeSetActive(ImageState, true)
            StateResName = "icon_worker_subscript_pause"
        elseif workState == WorkStateType.Sick then
            ResName = "icon_worker_people_ill_1"
            SafeSetActive(ImageState, true)
            StateResName = "icon_worker_subscript_treatmet"
        elseif workState == WorkStateType.Protest then
            ResName = "icon_worker_people_ill_1"
            StateResName = "icon_worker_subscript_riots"
            SafeSetActive(ImageState, true)
        end

        Utils.SetIcon(item.transform:Find("ImageIcon"):GetComponent("Image"), ResName)
        Utils.SetIcon(item.transform:Find("ImageState"):GetComponent("Image"), StateResName)
    end
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UIManageState)
    end)
end
