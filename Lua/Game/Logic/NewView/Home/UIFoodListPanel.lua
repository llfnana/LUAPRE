---@class UIFoodListPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIFoodListPanel = Panel;

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

    titleText.text = GetLang("UI_Kitchen_Info_List")

    local foodCardLevelList = ConfigManager.GetCityById(this.cityId).food_card_level
    local foodItems = ConfigManager.GetFoodItemConfigs(this.cityId)
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

    local p = this.GetCardProgress(foodCardLevelList, cardlevel)
    slider.value = p


    local i = 0
    for index, cfg in pairs(foodItems) do
        i = i + 1
        local item = SafeGetUIControl(this, "Item" .. i)
        local black = SafeGetUIControl(item, "Black")
        local sure = SafeGetUIControl(item, "Sure")
        local tip = SafeGetUIControl(item, "Tip")
        local tipText = SafeGetUIControl(item, "Tip/Text", "Text")
        local addValueText = SafeGetUIControl(item, "AddValue", "Text")
        local icon = SafeGetUIControl(item, "Icon", "Image")
        local outputIcon = SafeGetUIControl(item, "HungryIcon", "Image")
        local name = SafeGetUIControl(item, "Name", "Text")

        Utils.SetItemIcon(icon, cfg.id)
        icon.transform.localScale = Vector3.New(0.8, 0.8, 1)
        name.text = GetLang(ConfigManager.GetItemConfig(cfg.id).name_key .. "_short")
        local foodConfig = ConfigManager.GetFoodConfigByType(cfg.id)
        for nectItem, count in pairs(foodConfig.necesities_reward) do
            Utils.SetAttributeIcon(outputIcon, nectItem, function ()
                outputIcon:SetNativeSize()
            end)
            -- ToolTipManager.AddAttribute(self.OutputIcon, nectItem)
            addValueText.text = "+" .. count
        end

        local level = cardlevel
        local unlockLevel = foodCardLevelList[index]
        local isUnlock = level >= unlockLevel

        black:SetActive(not isUnlock)
        sure:SetActive(isUnlock)
        tip:SetActive(not isUnlock)

        tipText.text = GetLangFormat("UI_Kitchen_Menu_Lock", unlockLevel)

        local tipsIcon = SafeGetUIControl(this, "Tips/Icon", "Image")
        local tipsText = SafeGetUIControl(this, "Tips/Text", "Text")
        local foodConfig = ConfigManager.GetFoodConfigByType(FoodSystemManager.GetFoodType(this.cityId))
        local ingredients = foodConfig.ingredients[1]
        for itemId, count in pairs(ingredients) do
            tipsText.text = GetLangFormat("UI_Kitchen_Menu_Desc", Utils.FormatCount(count))
            Utils.SetItemIcon(tipsIcon, itemId)
            break
        end
    end
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
        HideUI(UINames.UIFoodList)
    end)
end
