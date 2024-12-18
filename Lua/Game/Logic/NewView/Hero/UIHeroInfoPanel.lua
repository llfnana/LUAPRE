---@class UIHeroInfoPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIHeroInfoPanel = Panel;

require "Game/Logic/NewView/Hero/StarItem"

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.ButtonBack = SafeGetUIControl(this, "ButtonBack")

    this.uidata.ButtonLvUp = SafeGetUIControl(this, "ButtonLvUp")
    this.uidata.ButtonGo = SafeGetUIControl(this, "ButtonGo")
    this.uidata.ButtonLUpStart = SafeGetUIControl(this, "ButtonLUpStart")
    this.uidata.ButtonR = SafeGetUIControl(this, "ButtonR")
    this.uidata.ButtonL = SafeGetUIControl(this, "ButtonL")
    this.uidata.StartRed = SafeGetUIControl(this, "ButtonLUpStart/ImageRed")

    this.uidata.CardItemText = SafeGetUIControl(this, "TopUI/CardItem/TxtCount", "Text")
    this.uidata.HeartItemText = SafeGetUIControl(this, "TopUI/HeartItem/TxtCount", "Text")
    this.uidata.CoinItemText = SafeGetUIControl(this, "TopUI/CoinItem/TxtCount", "Text")
    this.uidata.GemItemText = SafeGetUIControl(this, "TopUI/GemItem/TxtCount", "Text")
    this.uidata.HeartIcon = SafeGetUIControl(this, "TopUI/HeartItem/Icon", "Image")
    this.uidata.CoinIcon = SafeGetUIControl(this, "TopUI/CoinItem/Icon", "Image")
    this.uidata.GemIcon = SafeGetUIControl(this, "TopUI/GemItem/Icon", "Image")

    this.uidata.StarContent = SafeGetUIControl(this, "StarContent")

    this.uidata.TextOutPut = SafeGetUIControl(this, "TextOutPutVal/TextOutPut")
    this.uidata.TextOutPutVal = SafeGetUIControl(this, "TextOutPutVal")

    this.uidata.TextName = SafeGetUIControl(this, "TextName", "Text")

    this.uidata.ExpIcon = SafeGetUIControl(this, "ImageExp/ExpIcon")
    this.uidata.TextExp = SafeGetUIControl(this, "ImageExp/TextExp", "Text")

    this.uidata.UpgradeText = SafeGetUIControl(this, "ButtonLvUp/Text", "Text")

    this.uidata.ImageWorkState = SafeGetUIControl(this, "ImageWorkState")

    this.uidata.TextLV = SafeGetUIControl(this, "ContentLV/TextLV", "Text")

    this.animation = SafeGetUIControl(this, "SkeletonGraphic", "SkeletonGraphic")

    this.animationLvUp = SafeGetUIControl(this, "LvUpSkeletonGraphic")
    this.animationGuang = SafeGetUIControl(this, "LvGuangSkeletonGraphic")

    -- 调整顶部高度-与胶囊错开
    if PlayerModule.getSdkPlatform() == "wx" then
        SafeGetUIControl(this, "TopUI").transform.anchoredPosition = Vector3(0, -LuaFramework.AppConst.cutout + 60, 0)
    end
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.ButtonBack, function()
        if this.closeCallBack then 
            this.closeCallBack()
            this.closeCallBack = nil
        end
        this.HideUI()
    end)

    -- 长按升级
    SafeAddLongPressEvent(this.behaviour, this.uidata.ButtonLvUp.gameObject, function()
        this.Timer = TimeModule.addRepeat(0.2, function()
            this.LevelUp()
        end)
    end, function()
        this.CleanLevelUpPressTimer()
    end, function()
        this.LevelUp()
    end, 0.2)


    -- 获取
    SafeAddClickEvent(this.behaviour, this.uidata.ButtonGo, function()
        ShowUI(UINames.UIShop)
    end)

    -- 升星
    SafeAddClickEvent(this.behaviour, this.uidata.ButtonLUpStart, function()
        if this.cardItemData:GetStar() >= ConfigManager.GetCardMaxStarRank(this.cardConfig) then
            UIUtil.showText(GetLang("toast_max_star"))
            -- GameToast.Instance:Show(GetLang("toast_max_star"), ToastIconType.Warning)
            return
        end
        ShowUI(UINames.UIHeroStarUp, { cardId = this.cardItemData:GetID(), from = this.from })
    end)

    -- 砖石
    SafeAddClickEvent(this.behaviour, SafeGetUIControl(this, "TopUI/GemItem"), function()
        ShowUI(UINames.UIShop)
    end)

    this.AddListener(EventType.UPGRADE_CARD_STAR, function()
        this.UpdateView(this.cardItemData)
        this.lVuP()
    end)
end

function Panel.LevelUp()
    if this.canClick then
        if this.cardItemData:UpgradeLevel(this.from) then
            Audio.PlayAudio(DefaultAudioID.HeroLevelUp)
            this.UpdateView(this.cardItemData)
            this.lVuP()
        end
    end
end


function Panel.CleanLevelUpPressTimer()
    if this.Timer then
        TimeModule.removeTimer(this.Timer)
        this.Timer = nil
    end
end

function Panel.lVuP()
    local actSkel = this.animationLvUp:GetComponent("SkeletonGraphic")
    if actSkel then
        SafeSetActive(this.animationLvUp, true)
        actSkel.AnimationState:SetAnimation(0, "animation", false):AddOnComplete(function()
            SafeSetActive(this.animationLvUp, false)
        end)
    end

    local actSkel = this.animationGuang:GetComponent("SkeletonGraphic")
    if actSkel then
        SafeSetActive(this.animationGuang, true)
        actSkel.AnimationState:SetAnimation(0, "animation2", false):AddOnComplete(function()
            SafeSetActive(this.animationGuang, false)
        end)
    end
end

function Panel.ShowCardEffect()
    this.animationCard = SafeGetUIControl(this, "TopUI/CardItem/guangSkeletonGraphic")
    this.IconCard = SafeGetUIControl(this, "TopUI/CardItem/Icon")
    local actSkel = this.animationCard:GetComponent("SkeletonGraphic")
    if actSkel then
        SafeSetActive(this.animationCard, true)
        SafeSetActive(this.IconCard, false)
        actSkel.AnimationState:SetAnimation(0, "animation", false):AddOnComplete(function()
            SafeSetActive(this.animationCard, false)
            SafeSetActive(this.IconCard, true)
        end)
    end
end

function Panel.OnShow(param)
    UIUtil.openPanelAction(this.gameObject)
    this.InitEvent()
    this.uidata.ButtonR:SetActive(true)
    this.uidata.ButtonL:SetActive(true)
    this.ShowCardEffect()

    if param.showCallBack then 
        param.showCallBack()
    end
    this.closeCallBack = param.closeCallBack
    this.cardItemData = param.cardItemData
    this.cardUIItems = param.cardUIItems
    this.readOnly = param.readOnly or false
    this.from = param.from
    this.rxList = List:New()
    this.cityId = DataManager.GetCityId()

    this.canClick = false

    -- 升级材料
    Utils.SetItemIcon(this.uidata.HeartIcon, ItemType.Heart)
    this.rxList:Add(
        DataManager.GetMaterialRx(this.cityId, ItemType.Heart):subscribe(
            function(val)
                this.uidata.HeartItemText.text = DataManager.GetMaterialCountFormat(this.cityId, ItemType.Heart)
            end
        )
    )

    -- 升星材料
    Utils.SetItemIcon(this.uidata.CoinIcon, ItemType.BlackCoin)
    this.rxList:Add(
        DataManager.GetMaterialRx(this.cityId, ItemType.BlackCoin):subscribe(
            function(val)
                this.uidata.CoinItemText.text = DataManager.GetMaterialCountFormat(this.cityId, ItemType.BlackCoin)
            end
        )
    )

    -- 砖石
    Utils.SetItemIcon(this.uidata.GemIcon, ItemType.Gem)
    this.rxList:Add(
        DataManager.GetMaterialRx(this.cityId, ItemType.Gem):subscribe(
            function(val)
                this.uidata.GemItemText.text = DataManager.GetMaterialCountFormat(this.cityId, ItemType.Gem)
            end
        )
    )

    if param.from == "AssignList" then
        this.uidata.ButtonR:SetActive(false)
        this.uidata.ButtonL:SetActive(false)
    end

    if this.cardUIItems ~= nil and #this.cardUIItems > 1 then
        -- 上一个
        SafeAddClickEvent(this.behaviour, this.uidata.ButtonL, function()
            this.cardItemData = this.GetNextCardItemData(this.cardItemData:GetID(), -1)
            this.UpdateView(this.cardItemData)
        end)

        -- 下一个
        SafeAddClickEvent(this.behaviour, this.uidata.ButtonR, function()
            this.cardItemData = this.GetNextCardItemData(this.cardItemData:GetID(), 1)
            this.UpdateView(this.cardItemData)
        end)
    else
        this.uidata.ButtonR:SetActive(false)
        this.uidata.ButtonL:SetActive(false)
    end

    this.UpdateView(this.cardItemData)
end

function Panel.UpdateView(cardItemData)
    local cardId = cardItemData.cardId
    this.cardId = cardId
    this.cardConfig = ConfigManager.GetCardConfig(cardId)
    this.UpdateManageView()
    local level = cardItemData:GetLevel()

    UIUtil.AddToolTip(SafeGetUIControl(this, "ImageBuildType"), GetLang(this.cardConfig.zone_type_icon_desc),
        ToolTipDir.Left)
    UIUtil.AddToolTip(SafeGetUIControl(this, "ImageKind/TypeIcon"), Utils.GetCardMainTypeLang(this.cardConfig.type),
        ToolTipDir.Right)
    UIUtil.AddToolTip(SafeGetUIControl(this, "ImageKind/OccupationIcon"),
        Utils.GetCardOccupationLang(this.cardConfig.occupation), ToolTipDir.Right)

    local resCardPath = string.format("hero_model_%d_SkeletonData.asset", cardId)

    Utils.SetCardHeroIcon(SafeGetUIControl(this, "TopUI/CardItem/Icon", "Image"), cardId)

    -- 卡牌数量
    this.uidata.CardItemText.text = CardManager.GetCardCount(this.cardId)

    if ResInterface.IsExist(resCardPath) then
        ResInterface.SyncLoadCommon(resCardPath, function(dataAsset)
            this.animation.skeletonDataAsset = dataAsset
            this.animation:Initialize(true)
            
            -- this.animation.state:SetAnimation(0, "standby", true)
            this.animation.gameObject:SetActive(true)
        end)
    end

    -- 英雄形象
    Utils.SetIcon(SafeGetUIControl(this, "Image", "Image"), "hero_img_bg_" .. this.cardConfig.color)

    Utils.SetIconItem(SafeGetUIControl(this, "ImageBuildType", "Image"), this.cardConfig.zone_type_icon)

    Utils.SetCardIcon(SafeGetUIControl(this, "ImageKind/OccupationIcon", "Image"), "hero_" .. this.cardConfig.occupation)

    Utils.SetCardIcon(SafeGetUIControl(this, "ImageKind/TypeIcon", "Image"), "card_main_type_" .. this.cardConfig.type)

    local cardUnlockType, lockParam = CardManager.GetCardUnlockState(this.cardConfig.id, this.cityId)
    if cardUnlockType == CardUnlockType.Own and not this.readyOnly then
        this.canClick = true
        this.uidata.ButtonLvUp:SetActive(true)

        this.uidata.ButtonGo:SetActive(false)
        local maxStar = cardItemData:GetStar() < ConfigManager.GetCardMaxStarRank(this.cardConfig)
        this.uidata.ButtonLUpStart:SetActive(maxStar)
        local maxLvl = cardItemData:GetMaxLevel(ConfigManager.GetCardMaxStarRank(this.cardConfig))
        if cardItemData:GetLevel() >= maxLvl then
            GreyObject(this.uidata.ButtonLvUp.gameObject, true, false)
            this.uidata.TextExp.text = "-"
            this.uidata.ExpIcon:SetActive(false)
            this.uidata.UpgradeText.text = GetLang("toast_card_full_level")
        else
            GreyObject(this.uidata.ButtonLvUp.gameObject, false, true)
            this.uidata.UpgradeText.text = GetLang("ui_card_btn_upgrade")
            this.uidata.ExpIcon:SetActive(true)

            local needHeartCount = ConfigManager.GetCardUpgradeHeartCost(level, this.cardConfig.upgrade_group)

            if this.rxId ~= nil then
                this.rxId:unsubscribe()
            end

            this.rxId =
                DataManager.GetMaterialRx(this.cityId, CardManager.GetCardMaterial()):subscribe(
                    function(val)
                        local hasHeartCount = DataManager.GetMaterialCount(this.cityId, CardManager.GetCardMaterial())
                        if needHeartCount <= hasHeartCount then
                            this.uidata.TextExp.text =
                                Utils.RichText(
                                    DataManager.GetMaterialCountFormat(this.cityId, CardManager.GetCardMaterial()),
                                    "#6fa566"
                                ) ..
                                "/" .. Utils.FormatCount(needHeartCount)
                            GreyObject(this.uidata.ButtonLvUp.gameObject, false, true)
                        else
                            this.uidata.TextExp.text =
                                Utils.RichText(
                                    DataManager.GetMaterialCountFormat(this.cityId, CardManager.GetCardMaterial()),
                                    "#F85D5D"
                                ) ..
                                "/" .. Utils.FormatCount(needHeartCount)
                            GreyObject(this.uidata.ButtonLvUp.gameObject, true, false)
                        end
                    end
                )
        end
    else
        
        if cardUnlockType == CardUnlockType.UnFound then
            this.uidata.ButtonLvUp:SetActive(false)
            this.uidata.ButtonLUpStart:SetActive(false)
            this.uidata.ButtonGo:SetActive(true)

            this.uidata.TextExp.text = "-"
            this.uidata.ExpIcon:SetActive(false)
        else
            this.uidata.ButtonLvUp:SetActive(true)
            this.uidata.ButtonLUpStart:SetActive(false)
            this.uidata.ButtonGo:SetActive(false)

            this.uidata.TextExp.text = "-"
            this.uidata.ExpIcon:SetActive(false)
            
            this.uidata.UpgradeText.text = GetLang("ui_event_rank_lock")
        end
        this.canClick = false
        GreyObject(this.uidata.ButtonLvUp.gameObject, true, false)
    end

    this.RefreshWorkingContentView()
    this.uidata.TextName.text = GetLang(this.cardConfig.name)
    this.uidata.TextOutPutVal:GetComponent("Text").text = cardItemData:GetCardBoostEffectShow()
    this.uidata.TextLV.text = GetLang("UI_BuildingInfo_Level") .. ":" .. level .. "/" .. cardItemData:GetMaxLevel()

    -- 星星
    local starLevel = 15
    if cardUnlockType == CardUnlockType.Own and not this.readyOnly then
        starLevel = cardItemData:GetStarLevel()
    end
    local StarItem = StarItem.new()
    StarItem:InitPanel(this.behaviour, this.uidata.StarContent)
    StarItem:SetStarLevel(starLevel)

    SafeSetActive(this.uidata.StartRed, cardItemData:CanAddStarStatus())

    if cardItemData:CanAddStarStatus() then
        StarItem:ShowNextUpgradeLight()
    end
end

function Panel.HideUI()
    this.rxList:ForEach(
        function(rx)
            rx:unsubscribe()
        end
    )
    this.rxList:Clear()

    if this.rxId ~= nil then
        this.rxId:unsubscribe()
    end


    if this.from and this.from == "CardList" and UIHeroPanel then
        UIHeroPanel.UpdateView()
    end

    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UIHeroInfo)
    end)
end

-- 英雄切换
function Panel.GetNextCardItemData(currCardId, dir)
    local idx =
        this.cardUIItems:FindIndex(
            function(item)
                return item:GetCardItemData():GetID() == currCardId
            end
        )

    idx = idx + dir

    if idx == 0 then
        idx = this.cardUIItems:Count()
    elseif idx == this.cardUIItems:Count() + 1 then
        idx = 1
    end

    return this.cardUIItems[idx]:GetCardItemData()
end

function Panel.UpdateManageView()
    this.manageType = CardManager.GetCardManageType(this.cardItemData.cardId)
    if this.manageType == CardManageType.manage then
        this.uidata.TextOutPutVal:SetActive(true)
    elseif this.manageType == CardManageType.peaceManage then
        this.uidata.TextOutPutVal:SetActive(true)
    elseif this.manageType == CardManageType.overall then
        this.uidata.TextOutPutVal:SetActive(false)
        this.uidata.ImageWorkState:SetActive(false)
    end

    local workJob = this.cardItemData:GetWorkJob()
    if workJob == ProfessionType.Chef or workJob == ProfessionType.Guard then
        this.uidata.TextOutPutVal:SetActive(false)
    end
    if workJob == ProfessionType.Boilerman then
        this.uidata.TextOutPut:GetComponent("Text").text = GetLang("ui_build_card_cost")
    elseif workJob == ProfessionType.Doctor then
        this.uidata.TextOutPut:GetComponent("Text").text = GetLang("ui_card_skill_medical_point")
    else
        this.uidata.TextOutPut:GetComponent("Text").text = GetLang("UI_Building_Info_Output")
    end
end

function Panel.IsUnlock()
    return CardManager.IsUnlock(this.cardItemData:GetID()) and (not this.readOnly)
end

function Panel.RefreshWorkingContentView()
    if this:IsUnlock() then
        this.uidata.ImageWorkState:SetActive(MapManager.IsHasCardId(this.cityId, this.cardId))
    else
        this.uidata.ImageWorkState:SetActive(false)
    end
end
