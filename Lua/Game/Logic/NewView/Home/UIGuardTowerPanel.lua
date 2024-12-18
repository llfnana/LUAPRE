---@class UIGuardTowerPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIGuardTowerPanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.btnClose = SafeGetUIControl(this, "BtnClose", "Button")
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.btnClose.gameObject, this.HideUI)
end

function Panel.OnShow(param)
    UIUtil.openPanelAction(this.gameObject)

    this.zoneId = param.zoneId
    this.cityId = param.cityId
    this.mapItemData = MapManager.GetMapItemData(this.cityId, this.zoneId)

    this.Init()
end

function Panel.Init()
    local titleText = SafeGetUIControl(this, "TitleItem/Text", "Text")
    local slider = SafeGetUIControl(this, "Slider", "Slider")
    local sliderText = SafeGetUIControl(this, "Slider/Fill Area/Fill/Arrow/ContentBg/Text", "Text")
    local heroImage = SafeGetUIControl(this, "Hero/HeroImg", "Image")
    local heroLevel = SafeGetUIControl(this, "Hero/LvBox/LevelText", "Text")

    titleText.text = GetLang("UI_Building_Info_Appease_Chg")

    local protestCardLevelList = ConfigManager.GetCityById(this.cityId).protest_card_level
    local cardId = this.mapItemData:GetCardId()
    local cardlevel = 0
    if cardId == 0 then
        GreyObject(heroImage.gameObject)
        local defaultCardId = this.mapItemData:GetDefaultCardId() == 0 and 1 or this.mapItemData:GetDefaultCardId()
        Utils.SetCardHeroBuildPic(heroImage, defaultCardId, function ()
            heroImage:SetNativeSize()
        end)
    else
        Utils.SetCardHeroBuildPic(heroImage, cardId, function ()
            heroImage:SetNativeSize()
        end)
        local cardItemData = CardManager.GetCardItemData(cardId)
        cardlevel = cardItemData:GetLevel()
    end
    heroLevel.text = GetLangFormat("UI_LEVEL", cardlevel)
    sliderText.text = GetLangFormat("UI_LEVEL", cardlevel)

    local p = this.GetCardProgress(protestCardLevelList, cardlevel)
    slider.value = p


    local i = 0
    for index, cfg in pairs(protestCardLevelList) do
        i = i + 1
        local item = SafeGetUIControl(this, "Item" .. i)
        local black = SafeGetUIControl(item, "Black")
        local sure = SafeGetUIControl(item, "Sure")
        local tip = SafeGetUIControl(item, "Tip")
        local tipText = SafeGetUIControl(item, "Tip/Text", "Text")
        local icon = SafeGetUIControl(item, "Icon", "Image")
        local name = SafeGetUIControl(item, "Name", "Text")

        local iconArr = {"riots_bad_stop", "riots_normal_talk", "riots_good_peace"}
        Utils.SetCommonIcon(icon, iconArr[index], function ()
            icon:SetNativeSize()
        end)
        name.text = GetLang("UI_Building_Info_Appease_" .. index)
        -- tipText.text = GetLang(ConfigManager.GetItemConfig(index).name_key .. "_short")

        local level = cardlevel
        local unlockLevel = protestCardLevelList[index]
        local isUnlock = level >= unlockLevel

        black:SetActive(not isUnlock)
        sure:SetActive(isUnlock)
        tip:SetActive(not isUnlock)

        tipText.text = GetLangFormat("UI_Kitchen_Menu_Lock", unlockLevel)

        -- local tipsIcon = SafeGetUIControl(this, "Tips/Icon", "Image")
        -- tipsIcon.gameObject:SetActive(false)
    end
    local tipsText = SafeGetUIControl(this, "Tips/Text", "Text")
    tipsText.text = GetLang("UI_Building_Info_Appease_Desc")
end


function Panel.GetCardProgress(cardLevelList, cardlevel)
    local minLevel = 0
    local midLevel = cardLevelList[#cardLevelList - 1]
    local maxLevel = cardLevelList[#cardLevelList]
    local p = 0
    if cardlevel <= midLevel then
        p = (cardlevel - minLevel) / midLevel * 0.5
    else
        p = 0.5 + ((cardlevel - midLevel) / (maxLevel - midLevel) * 0.5)
    end
    p = math.min(p, 1)
    return p
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UIGuardTower)
    end)
end
