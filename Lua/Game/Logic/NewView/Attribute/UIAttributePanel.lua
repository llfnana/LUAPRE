---@class UIAttributePanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIAttributePanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.Slider = SafeGetUIControl(this, "Slider"):GetComponent("Slider")
    this.uidata.Slider1 = SafeGetUIControl(this, "Slider1"):GetComponent("Slider")
    this.uidata.Slider2 = SafeGetUIControl(this, "Slider2"):GetComponent("Slider")
    this.uidata.Slider3 = SafeGetUIControl(this, "Slider3"):GetComponent("Slider")
    this.uidata.SliderBar = SafeGetUIControl(this, "Slider/FillArea")
    this.uidata.LockIcon = SafeGetUIControl(this, "ImageLockIcon")
    this.uidata.ImageHappy = SafeGetUIControl(this, "ImageHappy")
    this.uidata.ImageAngry = SafeGetUIControl(this, "ImageAngry")


    this.uidata.Mask = SafeGetUIControl(this, "Mask")
    this.uidata.ButtonHelp = SafeGetUIControl(this, "ImageTttleBg/ButtonHelp")
    this.uidata.ButtonClose = SafeGetUIControl(this, "ButtonClose")

    this.uidata.TextTitle = SafeGetUIControl(this, "ImageTttleBg/TextTitle", "Text")
    this.uidata.TextAttDes = SafeGetUIControl(this, "TextAttDes", "Text")
    this.uidata.TextTitleAtt = SafeGetUIControl(this, "TextTitleAtt", "Text")

    this.uidata.TextTitle.text = GetLang("UI_Title_Attribute")
end

function Panel.InitViewData()
    --初始化数据
    this.cityId = DataManager.GetCityId()
    local attributeList = List:New()
    attributeList:Add(AttributeType.Warm)

    -- 是否开启罢工
    local isOpen = FunctionsManager.IsOpen(this.cityId, FunctionsType.Protest)
    if isOpen then
        SafeSetActive(this.uidata.ImageHappy, true)
        SafeSetActive(this.uidata.ImageAngry, true)
        SafeSetActive(this.uidata.SliderBar, true)
        SafeSetActive(this.uidata.LockIcon, false)
        this.uidata.TextTitleAtt.text = GetLang("ui_discontent_title")
        this.uidata.TextAttDes.text = GetLang("ui_discontent_desc")
        local desparirProgress = ProtestManager.GetDesparirProgress(this.cityId)
        this.uidata.Slider.value = 1 - desparirProgress
    else
        SafeSetActive(this.uidata.ImageHappy, false)
        SafeSetActive(this.uidata.ImageAngry, false)
        SafeSetActive(this.uidata.LockIcon, true)
        SafeSetActive(this.uidata.SliderBar, false)
        this.uidata.TextTitleAtt.text = GetLang("ui_statistics_lock")
        this.uidata.TextAttDes.text = GetLang("ui_statistics_lock_desc")
    end

    attributeList:Add(AttributeType.Hunger)
    attributeList:Add(AttributeType.Rest)
    this.attributeList = attributeList

    -- 每秒刷新
    this.RefreshFunc = function(cityId)
        if this.cityId ~= cityId then
            return
        end
        this:OnRefresh()
    end
    this.AddListener(EventType.TIME_REAL_PER_SECOND, this.RefreshFunc)
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.Mask, this.HideUI)
    SafeAddClickEvent(this.behaviour, this.uidata.ButtonClose, this.HideUI)
    SafeAddClickEvent(this.behaviour, this.uidata.ButtonHelp, function()
        -- 幸存者属性详情说明
        ShowUI(UINames.UIPersonAttributeInfo)
    end)

    SafeAddClickEvent(this.behaviour, this.uidata.ImageAngry, function()
        ShowUI(UINames.UIPersonAttributeInfo, 4)
    end)
end

function Panel.OnShow()
    UIUtil.openPanelAction(this.gameObject)
    this.InitEvent();
    this.InitViewData()
    this:OnRefresh()
end

function Panel.OnRefresh()
    for i = 1, this.attributeList:Count(), 1 do
        local currValue = CharacterManager.GetAttributeValue(this.cityId, this.attributeList[i])
        local attributeMaxValue = ConfigManager.GetNecessitiesMaxValue(this.cityId, this.attributeList[i])
        local item = this.uidata["Slider" .. i]
        item.value = currValue / attributeMaxValue

        SafeAddClickEvent(this.behaviour, item.transform:Find("ImageIcon").gameObject, function()
            ShowUI(UINames.UIPersonAttributeInfo, i)
        end)
    end
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UIAttribute)
    end)
end
