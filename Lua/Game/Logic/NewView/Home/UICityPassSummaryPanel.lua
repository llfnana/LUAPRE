---@class UICityPassSummaryPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UICityPassSummaryPanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.mask = this.BindUIControl("Mask", this.HideUI)
    this.DescSurvived = this.GetUIControl("Info/Survived/Txt", "Text")
    this.DescRescued = this.GetUIControl("Info/Rescued/Txt", "Text")
    this.SummaryProtest = this.GetUIControl("Info/Protest")
    this.DescProtest = this.GetUIControl("Info/Protest/Txt", "Text")
    this.SummaryProduct = this.GetUIControl("Info/Product")
    this.IconProduct = this.GetUIControl("Info/Product/ImgIcon", "Image")
    this.DescProduct = this.GetUIControl("Info/Product/Txt", "Text")
    this.IconResource = this.GetUIControl("Info/Resource1/ImgIcon", "Image")
    this.DescResource = this.GetUIControl("Info/Resource1/Txt", "Text")
    this.SummaryResource2 = this.GetUIControl("Info/Resource2")
    this.IconResource2 = this.GetUIControl("Info/Resource2/ImgIcon", "Image")
    this.DescResource2 = this.GetUIControl("Info/Resource2/Txt", "Text")
    this.CityDesc = this.GetUIControl("Info/Tip/Viewport/Content/Txt", "Text")
    this.CityNameText = this.GetUIControl("Title/TxtTitle2", "Text")
    this.CitySpr = this.GetUIControl("Info/Img", "Image")
    this.bottonGet = this.GetUIControl("Info/BtnGet")
    this.btnGet = this.BindUIControl("Info/BtnGet", this.HideUI)
    this.txtBtn = this.GetUIControl(this.btnGet, "Txt", "Text")
    this.title = this.GetUIControl("Title/TxtTitle1", "Text")

    this.uidata.imgBg = SafeGetUIControl(this.behaviour, "ImgBg", "Image")
end

function Panel.InitEvent()
    --绑定UGUI事件
end

function Panel.OnShow(param)
    UIUtil.openPanelAction(this.gameObject)
    this.param = param
    this.cityId = DataManager.GetCityId()
    this.OnInit()
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()

        if this.cityId == 1 then
            SDKAnalytics.TraceEvent(156)
        end

        if this.param then
            this.param()
        end
        HideUI(UINames.UICityPassSummary)
    end)
end

function Panel.OnInit()
    -- AudioManager.PlayEffect("ui_rebuild_celebrate")
    this.txtBtn.text = GetLang("ui_cities_continue_btn")
    this.title.text = GetLang("ui_cities_complete_well_done_title")

    local colorBegin = ""
    local colorEnd = ""
    --存活天数
    local liveDay = TimeManager.GetCityDay(this.cityId)
    this.DescSurvived.text = GetLangFormat("ui_cities_complete_well_done_day", colorBegin .. liveDay .. colorEnd)

    --幸存者数量
    local rescuedCount = CharacterManager.GetCharacterCount(this.cityId)
    --死亡数量
    local deathCount = CityPassManager.GetDeathCount()
    this.DescRescued.text =
        GetLangFormat("ui_cities_complete_well_done_people", colorBegin .. rescuedCount + deathCount .. colorEnd)

    --平息暴动数量
    local protestNum = 0
    SafeSetActive(this.SummaryProtest, this.cityId > 2)
    if this.cityId > 2 then
        this.protestData = DataManager.GetCityDataByKey(this.cityId, DataKey.ProtestData)
        if nil ~= this.protestData then
            protestNum = this.protestData.protestNum
        end
        if protestNum == 0 then
            this.DescProtest.text = GetLang("ui_cities_complete_well_done_no_strike")
        else
            this.DescProtest.text =
                GetLangFormat("ui_cities_complete_well_done_strike", colorBegin .. protestNum .. colorEnd)
        end
    end

    --新产品
    if this.cityId == 1 then
        this.SummaryProduct.gameObject:SetActive(false)
    end
    local itemList = ConfigManager.GetItemListBySort(this.cityId, "City")
    local item = itemList[itemList:Count()]
    Utils.SetItemIcon(this.IconProduct, item.id)

    local productCfg = ConfigManager.GetItemConfig(item.id)
    local productName = ""
    if productCfg ~= nil then
        productName = GetLang(productCfg.name_key)
    end
    this.DescProduct.text = GetLangFormat("ui_cities_complete_well_done_product", colorBegin .. productName .. colorEnd)

    --无限资源
    local cityConfig = ConfigManager.GetCityById(this.cityId + 1)
    SafeSetActive(this.SummaryResource2.gameObject, false)
    local resourceId = 0
    if cityConfig ~= nil and cityConfig.show_infinity_resource ~= nil and next(cityConfig.show_infinity_resource) ~= nil then
        for index, itemId in ipairs(cityConfig.show_infinity_resource) do
            if index == 1 then
                local resourceName = ""
                Utils.SetItemIcon(this.IconResource, itemId)
                local resourceCfg = ConfigManager.GetItemConfig(itemId)
                if resourceCfg ~= nil then
                    resourceName = GetLang(resourceCfg.name_key)
                end
                resourceId = itemId
                this.DescResource.text =
                    GetLangFormat("ui_cities_complete_well_done_resource", colorBegin .. resourceName .. colorEnd)
            else
                this.SummaryResource2:SetActive(true)
                local resourceName = ""
                Utils.SetItemIcon(this.IconResource2, itemId)
                local resourceCfg = ConfigManager.GetItemConfig(itemId)
                if resourceCfg ~= nil then
                    resourceName = GetLang(resourceCfg.name_key)
                end
                resourceId = itemId
                this.DescResource2.text =
                    GetLangFormat("ui_cities_complete_well_done_resource", colorBegin .. resourceName .. colorEnd)
            end
        end
    end

    --描述
    cityConfig = ConfigManager.GetCityById(this.cityId)
    if cityConfig ~= nil then
        this.CityDesc.text = GetLang(cityConfig.city_summary_desc)
        this.CityNameText.text = GetLang(cityConfig.city_name)
        this.SetImage(this.CitySpr, cityConfig.city_pic)
    end

    local eventJson = {
        currentCityId = this.cityId,
        nextCityId = this.cityId + 1,
        daySurived = liveDay,
        peopleCame = rescuedCount,
        protestsNumber = protestNum,
        newProductId = item.id,
        --unlimitedResource = resourceId,
        infinityResource = resourceId
    }

    -- Analytics.Event("CitySummarizeOpen", eventJson)
    -- this.YesButton.onClick:AddListener(
    --     function()
    --         Analytics.Event("CitySummarizeContinue", eventJson)
    --         this.ClosePanelAction()
    --         if PopupManager.Instance ~= nil then
    --             PopupManager.Instance:CloseAllPanel()
    --         end
    --     end
    -- )

    -- this.BackBtn.onClick:AddListener(
    --     function()
    --         Analytics.Event("CitySummarizeClose", eventJson)
    --         self:ClosePanel()
    --         CityPassManager.isPlayingCityPass = false
    --     end
    -- )

    -- ForceRebuildLayoutImmediate(this.RewardContent.transform)
    -- ForceRebuildLayoutImmediate(this.Infor.transform)
end
