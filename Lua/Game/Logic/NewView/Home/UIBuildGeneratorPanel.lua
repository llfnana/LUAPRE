---@class UIBuildGeneratorPanel : UIPanelBase
local Panel = UIPanelBaseMake()
local this = Panel
UIBuildGeneratorPanel = Panel

function Panel.OnAwake()
    this.cachedata = {}
    this.InitPanel()


    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.clickMask = SafeGetUIControl(this, "ClickMask")

    this.uidata.enableSwitch = SafeGetUIControl(this, "BottomView/SettingPanel/Item1/ImgBtnBg", "Image")
    this.uidata.overloadSwitch = SafeGetUIControl(this, "BottomView/SettingPanel/Item2/ImgBtnBg", "Image")
    this.uidata.btnLevelUp = SafeGetUIControl(this, "BottomView/TitleItem/BtnLevelUp", "Button")
    this.uidata.imgLevelUpRed = SafeGetUIControl(this, "BottomView/TitleItem/BtnLevelUp/ImgRed", "Image")

    this.uidata.grayMaterial = SafeGetUIControl(this, "BottomView/Production/Item2/HightFire/ImgFire", "Image").material
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.clickMask, function()
        EventManager.Brocast(EventDefine.OnClickExitCityBuild)
        this.PlayViewExitAni()
    end)

    SafeAddClickEvent(this.behaviour, this.uidata.btnLevelUp.gameObject, function()
        ShowUI(UINames.UIBuildGeneratorUpgrade, {
            exitCall = function()
                -- EventManager.Brocast(EventDefine.OnClickExitCityBuild)
                this.PlayViewExitAni()
            end
        })
    end)

    this.UpdateCardViewFunc = function()
        this.UpdateCardView()
    end
    this.AddListener(EventType.ADD_CARD, this.UpdateCardViewFunc)
    this.AddListener(EventType.UPGRADE_CARD_LEVEL, this.UpdateCardViewFunc)
    this.AddListener(EventType.UPGRADE_CARD_STAR, this.UpdateCardViewFunc)
end

function Panel.OnShow()
    this.Init()
    this.InitEvent()
    this.PlayViewEnterAni()

    local function TutorialUpdate(subStep)
        this.CheckTutorial(TutorialManager.CurrentStep.value, subStep)
    end

    this.TutorialSubStepSubscribe = TutorialManager.CurrentSubStep:subscribe(TutorialUpdate)
end

function Panel.Init()
    -- 城市ID
    this.cityId = DataManager.GetCityId()

    local characterNum = CharacterManager.GetCharacterCount(this.cityId)
    -- 区域ID
    this.zoneId = ConfigManager.GetZoneIdByZoneType(this.cityId, ZoneType.Generator)
    -- 区域数据
    this.mapItemData = MapManager.GetMapItemData(this.cityId, this.zoneId)
    -- 初始化标题Item
    this.InitTittleItem()

    -- 接下来是一些事件的初始化
    this.enable = GeneratorManager.GetIsEnable(this.cityId)
    this.overload = GeneratorManager.GetIsOverload(this.cityId)
    this.UpdateTimeListener = function(cityId)
        if this.cityId == cityId then
            this.RefreshLevelUpRedDot()
        end
    end
    this.RefreshGeneratorFunc = function(cityId)
        if this.cityId == cityId then
            this.UpdateView()
        end
    end
    this.AddListener(EventType.TIME_REAL_PER_SECOND, this.UpdateTimeListener)
    this.AddListener(EventType.REFRESH_GENERATOR, this.RefreshGeneratorFunc)
    this.UpgradeZoneFunc = function(cityId, zoneId, zoneType, level)
        if this.cityId == cityId then
            this.UpdateView()
        end
    end
    this.AddListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)
    -- 点击开启按钮
    SafeAddClickEvent(this.behaviour, this.uidata.enableSwitch.gameObject, function()
        this.OnEnableToggle()
    end)
    -- 点击过载按钮
    SafeAddClickEvent(this.behaviour, this.uidata.overloadSwitch.gameObject, function()
        this.OnOverloadToggle()
    end)

    local tipOverLoad = SafeGetUIControl(this, "BottomView/SettingPanel/Item2/TxtTitle/BtnHelp", "Image")
    UIUtil.AddToolTipBig(tipOverLoad, GetLang("UI_generator_overload_desc"))

    this.UpdateView()

    -- 初始化英雄卡牌
    this.InitHeroCard()
end

---初始化英雄卡片
function Panel.InitHeroCard()
    this.uidata.hero = SafeGetUIControl(this, "Hero")
    this.uidata.btnHeroCard = SafeGetUIControl(this, "Hero/Btn", "Button")
    this.uidata.heroImage = SafeGetUIControl(this, "Hero/HeroImage", "Image")
    this.uidata.heroTag = SafeGetUIControl(this, "Hero/Info/TxtTag", "Text")
    this.uidata.heroValue = SafeGetUIControl(this, "Hero/Info/TxtValue", "Text")
    this.uidata.heroLevel = SafeGetUIControl(this, "Hero/Info/ImgTitle/TxtLevel", "Text")
    this.uidata.heroLevelName = SafeGetUIControl(this, "Hero/Info/ImgTitle/TxtTag", "Text")
    this.uidata.icon = SafeGetUIControl(this, "Hero/Info/Icon", "Image")
    this.uidata.heroSingleValue = SafeGetUIControl(this, "Hero/Info/TxtSingleValue", "Text")

    SafeAddClickEvent(this.behaviour, this.uidata.btnHeroCard.gameObject, function()
        this.OnClickHeroFun()
    end)

    this.UpdateCardView()
end
---刷新英雄卡牌
function Panel.UpdateCardView()
    -- this.LockState:SetActive(false)
    -- this.UnlockState:SetActive(false)
    -- this.gameObject:SetActive(true)
    this.uidata.btnHeroCard.gameObject:SetActive(true)
    GreyObject(this.uidata.heroImage.gameObject, false, true)

    local heroInfo = SafeGetUIControl(this, "Hero/Info")
    heroInfo:SetActive(false)
    local lockInfo = SafeGetUIControl(this, "Hero/LockInfo")
    lockInfo:SetActive(false)

    if this.mapItemData:GetIsNeedCard() then
        TimeModule.addDelay(0, function()
            this.uidata.hero:SetActive(true)
        end)

        Utils.SetCardHeroHalfPic(this.uidata.heroImage, this.mapItemData:GetDefaultCardId())
        if this.mapItemData:GetCardId() == 0 then
            -- this.LockState:SetActive(true)
            -- Utils.SetImageGray(this.HeroIcon)
            -- this.uidata.btnHeroCard.gameObject:SetActive(false)
            lockInfo:SetActive(true)
            GreyObject(this.uidata.heroImage.gameObject, true, false)
            GreyObject(lockInfo, true, false, true)
        else
            -- this.UnlockState:SetActive(true)
            this.SetCardView(this.mapItemData:GetCardId())
            -- this:RefreshCardRedDot()
        end
    else
        this.uidata.hero:SetActive(false)
    end
end
function Panel.SetCardView(cardId)
    local cardItemData = CardManager.GetCardItemData(cardId)
    local config = ConfigManager.GetCardConfig(cardId)
    local level = cardItemData:GetLevel()
    local levelUpSpine = SafeGetUIControl(this, "Hero/Info/ImgTitle/LevelUpSpine")
    local canUpgrade = cardItemData:IsCanUpgradeLevel()

    levelUpSpine.gameObject:SetActive(canUpgrade)

    local heroInfo = SafeGetUIControl(this, "Hero/Info")
    heroInfo:SetActive(true)

    this.uidata.heroLevel.text = level
    this.uidata.heroTag.gameObject:SetActive(true)
    this.uidata.heroValue.gameObject:SetActive(true)
    this.uidata.heroSingleValue.gameObject:SetActive(false)
    
    --火炉
    Utils.SetItemIcon(this.uidata.icon, GeneratorManager.GetConsumptionItemId(this.cityId), nil, true)
    this.uidata.heroTag.text = GetLang("UI_generator_consume")
    this.uidata.heroValue.text = cardItemData:GetCardBoostEffectShow()
end
function Panel.OnClickHeroFun()
    if this.mapItemData:GetIsNeedCard() then
        if this.mapItemData:GetCardId() == 0 then
            UIUtil.showConfirmByData({
                DescriptionRaw = GetLang("ui_go_to_shop"),
                Title = "ui_need_hero",
                ShowYes = true,
                ShowNo = true,
                YesCallback = function(toggle)
                    -- PopupManager.Instance:CloseAllPanel()
                    -- PopupManager.Instance:OpenPanel(PanelType.ShopPanel)
                    ShowUI(UINames.UIShop)
                end,
                OnNoFunc = function(toggle)

                end
            }
            )
        else
            ShowUI(UINames.UIHeroInfo, {
                cardItemData = CardManager.GetCardItemData(this.mapItemData:GetCardId()),
                from = "UIBuild"
            })

            -- PopupManager.Instance:OpenSubPanel(
            --     PopupManager.Instance.currentPanel,
            --     PanelType.CardInfoPanel,
            --     {
            --         cardItemData = CardManager.GetCardItemData(this.cardId),
            --         from = "BuildPanel"
            --     }
            -- )
        end
    end
end

function Panel.UpdateView()
    -- 刷新火力开关
    this.enable = GeneratorManager.GetIsEnable(this.cityId)
    this.overload = GeneratorManager.GetIsOverload(this.cityId)
    this.SetEnableToggle(this.enable, true)
    this.SetOverloadToggle(this.overload, true)
    GreyObject(this.uidata.overloadSwitch.gameObject, not this.enable, true)

    -- 刷新火力值
    this:UpdateFireView()

    -- 刷新需要消耗的资源
    local iconConsume = SafeGetUIControl(this, "BottomView/Production/Item1/Icon", "Image")
    Utils.SetItemIcon(iconConsume, GeneratorManager.GetConsumptionItemId(this.cityId), nil, true)

    UIUtil.AddItem(iconConsume, GeneratorManager.GetConsumptionItemId(this.cityId), nil, UINames.UIBuildGenerator)
    local consumeText = SafeGetUIControl(this, "BottomView/Production/Item1/TxtValue", "Text")
    consumeText.text = Utils.FormatCount(GeneratorManager.GetConsumptionCount(this.cityId)) .. "/min"

    -- 道具点击提示事件
    -- ToolTipManager.AddItem(this.IconConsumeRes, GeneratorManager.GetConsumptionItemId(this.cityId))

    -- 刷新升级按钮显示
    this.uidata.btnLevelUp = SafeGetUIControl(this, "BottomView/TitleItem/BtnLevelUp", "Button")
    local level = this.mapItemData:GetLevel()
    local isBuildMaxLevel = level >= this.mapItemData.config.max_level
    this.uidata.btnLevelUp.gameObject:SetActive(not isBuildMaxLevel)
    -- 刷新建筑等级文本
    local buildLevel = SafeGetUIControl(this, "BottomView/TitleItem/TtitleTxtBox/TxtLevel", "Text")
    buildLevel.text = isBuildMaxLevel and " Max" or " " .. GetLangFormat("Lv" .. level)
    ForceRebuildLayoutImmediate(buildLevel.transform.parent.gameObject)

    -- this:UpdateStatusDesc()
    -- 刷新升级红点
    this.RefreshLevelUpRedDot()
end

function Panel.OnEnableToggle()
    this.enable = not this.enable
    if this.enable then
        -- AudioManager.PlayEffect("amb_fire")
        Audio.PlayAudio(DefaultAudioID.OpenGenerator) --打开净化器
        GeneratorManager.Open(this.cityId)
        -- Analytics.Event("GeneratorSwitch", { switchType = "open", from = "manual" })
    else
        -- AudioManager.PlayEffect("amb_fire_stop")
        -- Audio.PlayAudio(DefaultAudioID.HideGenerator) --关闭净化器音效
        if this.overload then
            this.overload = false
            GeneratorManager.CloseOverload(this.cityId)
            -- Analytics.Event("GeneratorOverloadSwitch", { switchType = "close", from = "manual" })
        end
        GeneratorManager.Close(this.cityId)
        -- Analytics.Event("GeneratorSwitch", { switchType = "close", from = "manual" })
    end
end

function Panel.OnOverloadToggle()
    if not this.enable then
        return
    end
    this.overload = not this.overload
    if this.overload then
        -- AudioManager.PlayEffect("amb_fire_overheat")
        Audio.PlayAudio(DefaultAudioID.OpenMaxGenerator) --净化器最高功率
        GeneratorManager.OpenOverload(this.cityId)
        -- Analytics.Event("GeneratorOverloadSwitch", { switchType = "open", from = "manual" })
    else
        GeneratorManager.CloseOverload(this.cityId)
        -- Analytics.Event("GeneratorOverloadSwitch", { switchType = "close", from = "manual" })
    end
end

function Panel.UpdateFireView()
    local currentHeatLevel = this.mapItemData:GetHeatLevel()
    local hightFire = SafeGetUIControl(this, "BottomView/Production/Item2/HightFire")
    local lowFire = SafeGetUIControl(this, "BottomView/Production/Item2/LowFire")
    local hightFireText = SafeGetUIControl(this, "BottomView/Production/Item2/HightFire/TxtValue", "Text")
    local hightFireImg = SafeGetUIControl(this, "BottomView/Production/Item2/HightFire/ImgFire", "Image")
    local isHightFire = currentHeatLevel > 5
    hightFire:SetActive(isHightFire)
    lowFire:SetActive(not isHightFire)
    hightFireText.text = currentHeatLevel

    -- SafeGetUIControl(lowFire, "ImgFire_1", "Image").color = this.enable and Color.white or Color.black
    if this.enable then
        Utils.SetIcon(hightFireImg, this.overload and "stove_icon_fire_overload" or "stove_icon_fire")
        Utils.ClearImageGray(hightFireImg)
    else
        -- 关闭时置灰
        -- Utils.SetImageGray(hightFireImg)
        -- Utils.SetIcon(hightFireImg, "stove_icon_nofire")
        hightFireImg.material = this.uidata.grayMaterial
        hightFireImg:SetMaterialDirty()
    end

    for i = 1, 5 do
        local item = SafeGetUIControl(lowFire, "ImgFire_" .. i)
        local fireImage = SafeGetUIControl(this, "BottomView/Production/Item2/LowFire/ImgFire_" .. i, "Image") --this.overload
        if this.enable then
            Utils.ClearImageGray(fireImage)
            Utils.SetIcon(fireImage, this.overload and "stove_icon_fire_overload" or "stove_icon_fire")
        else
            -- Utils.SetImageGray(fireImage)
            -- Utils.SetIcon(fireImage, "stove_icon_nofire")
            fireImage.material = this.uidata.grayMaterial
            fireImage:SetMaterialDirty()
        end
        item:SetActive(i <= currentHeatLevel)
    end
end

function Panel.SetEnableToggle(enable, isAni)
    local btn = SafeGetUIControl(this, "BottomView/SettingPanel/Item1/ImgBtnBg/ImgButton", "Image")
    local offsetX = 37
    if isAni then
        btn.transform:DOLocalMoveX(enable and offsetX or -offsetX, 0.2)
    else
        btn.transform.localPosition = Vector3.New(enable and offsetX or -offsetX, 0, 0)
    end

    local txtOn = SafeGetUIControl(this, "BottomView/SettingPanel/Item1/ImgBtnBg/TxtOn", "Text")
    local txtOff = SafeGetUIControl(this, "BottomView/SettingPanel/Item1/ImgBtnBg/TxtOff", "Text")
    txtOn.color = enable and Color.New(215 / 255, 242 / 255, 184 / 255, 1) or Color.New(58 / 255, 56 / 255, 55 / 255, 1)
    txtOff.color = enable and Color.New(58 / 255, 56 / 255, 55 / 255, 1) or Color.New(243 / 255, 203 / 255, 185 / 255, 1)

    local resName = enable and "com_bt_green_s" or "com_bt_red_s"
    
    this.ReleaseBtnSprite()
    this.btnSpriteResGuid = ResInterface.AsyncLoadSpritePng(resName, function(_sprite)
        if isNil(btn) then 
            this.ReleaseBtnSprite()
        else
            if btn.sprite then
                if enable == this.enable then
                    btn.sprite = _sprite
                end
            end
        end
    end)
end

function Panel.ReleaseBtnSprite()
    if this.btnSpriteResGuid then 
        ResInterface.ReleaseRes(this.btnSpriteResGuid)
        this.btnSpriteResGuid = nil
    end
end

function Panel.SetOverloadToggle(enable, isAni)
    local btn = SafeGetUIControl(this, "BottomView/SettingPanel/Item2/ImgBtnBg/ImgButton", "Image")
    local offsetX = 37
    if isAni then
        btn.transform:DOLocalMoveX(enable and offsetX or -offsetX, 0.2)
    else
        btn.transform.localPosition = Vector3.New(enable and offsetX or -offsetX, 0, 0)
    end

    local txtOn = SafeGetUIControl(this, "BottomView/SettingPanel/Item2/ImgBtnBg/TxtOn", "Text")
    local txtOff = SafeGetUIControl(this, "BottomView/SettingPanel/Item2/ImgBtnBg/TxtOff", "Text")
    txtOn.color = enable and Color.New(215 / 255, 242 / 255, 184 / 255, 1) or Color.New(58 / 255, 56 / 255, 55 / 255, 1)
    txtOff.color = enable and Color.New(58 / 255, 56 / 255, 55 / 255, 1) or Color.New(243 / 255, 203 / 255, 185 / 255, 1)

    local resName = enable and "com_bt_green_s" or "com_bt_red_s"
    Utils.SetIcon(btn, resName)
end

function Panel.RefreshLevelUpRedDot()
    if this.mapItemData:GetLevel() >= this.mapItemData.config.max_level then
        this.uidata.imgLevelUpRed.gameObject:SetActive(false)
        return
    end
    local status = this.mapItemData:GetBuildStatus()
    local costConfig = this.mapItemData:GetUnlockLevelCost()
    local costIsReady = this.mapItemData:GetUnlockLevelCostIsReady()
    local unlockData = this.mapItemData:GetUnlockLevelIsReady()
    local isUpgrading = this.mapItemData:IsUpgrading()
    this.uidata.imgLevelUpRed.gameObject:SetActive(costIsReady and unlockData["AllReady"] and not isUpgrading)
end

function Panel.InitTittleItem()
    -- 设置建筑图标
    local buildIcon = SafeGetUIControl(this, "BottomView/TitleItem/ImgIcon", "Image")
    local zoneCfg = ConfigManager.GetZoneConfigById(this.zoneId)
    Utils.SetIcon(buildIcon, zoneCfg.zone_type_icon)
    -- 设置建筑名称
    -- local buildName = SafeGetUIControl(this, "BottomView/TitleItem/TtitleTxtBox/TxtTitle", "Text")
    -- buildName.text = "净化器" -- this.mapItemData:GetUpgradeLevelName()
end

function Panel.HideUI()
    if this.TutorialSubStepSubscribe ~= nil then
        this.TutorialSubStepSubscribe:unsubscribe()
    end
    HideUI(UINames.UIBuildGenerator)
end

function Panel.PlayViewEnterAni()
    local bottomView = SafeGetUIControl(this, "BottomView")
    local canvasGroup = bottomView:GetComponent("CanvasGroup")
    local acTime = 0.25

    this.initBottomLocalPosition = this.initBottomLocalPosition or bottomView.transform.localPosition
    -- Y轴上升出现
    bottomView.transform.localPosition = this.initBottomLocalPosition + Vector3.New(0, -200, 0)
    bottomView.transform:DOLocalMoveY(this.initBottomLocalPosition.y, acTime):SetEase(Ease.OutBack)
    -- 透明度渐变出现
    canvasGroup.alpha = 0

    local startX = this.uidata.hero.transform.localPosition.x
    local heroY = this.uidata.hero.transform.localPosition.y
    this.uidata.hero.transform.localPosition = Vector3(startX - 370, heroY, 0)

    local seq = DOTween.Sequence()
    seq:Append(Util.TweenTo(0, 1, acTime, function(value)
        canvasGroup.alpha = value
    end):SetEase(Ease.OutCubic))
    seq:Join(this.uidata.hero.transform:DOLocalMoveX(startX, acTime):SetEase(Ease.OutCubic))
    seq:AppendCallback(function()
        -- this.uidata.hero:SetActive(true)
    end)
end

function Panel.PlayViewExitAni()
    local bottomView = SafeGetUIControl(this, "BottomView")
    local canvasGroup = bottomView:GetComponent("CanvasGroup")
    local acTime = 0.25

    this.uidata.hero:SetActive(false)

    local seq = DOTween.Sequence()
    -- Y轴下移消失
    bottomView.transform.localPosition = this.initBottomLocalPosition
    seq:Append(bottomView.transform:DOLocalMoveY(this.initBottomLocalPosition.y - 200, acTime):SetEase(Ease.InBack))
    -- 透明度渐变消失
    canvasGroup.alpha = 1

    seq:Join(Util.TweenTo(1, 0, acTime, function(value)
        canvasGroup.alpha = value
    end))

    seq:AppendCallback(function()
        this.HideUI()
    end)
end

function Panel.CheckTutorial(step, subStep)
    if step == TutorialStep.BuildGenerator then --强制Generator引导
        if subStep == 3 then
            TutorialHelper.FingerMove(
                {
                    maskType = TutorialMaskType.None,
                    noticeKey = "Tutorial_BuildGenerator_notice_2",
                    noticePos = this.TutorialPos,
                    -- fingerPoint = Vector3(270, -280, 0),
                    fingerPoint = Utils.GetLocalPointInRectangleByUI(SafeGetUIControl(this, "commonBtn")),
                    fingerFunc = function()
                        SDKAnalytics.TraceEvent(104)
                        this.OnEnableToggle()
                        this.HideUI()
                    end,
                    callBack = function()
                        -- TutorialManager.TryCloseFreezeEffect()
                        TutorialManager.NextSubStep(0.1)
                    end
                }
            )
        end
    elseif step == TutorialStep.OverloadOpen then
        if subStep == 5 then
            TutorialHelper.FingerMove(
                {
                    maskType = TutorialMaskType.None,
                    noticeKey = "Tutorial_OverloadOpen_notice_1",
                    noticePos = this.TutorialPos,
                    fingerPoint = Utils.GetLocalPointInRectangleByUI(SafeGetUIControl(this, "OverloadBtn")),
                    fingerSize = this.uidata.overloadSwitch.transform.sizeDelta,
                    fingerFunc = function()

                        SDKAnalytics.TraceEvent(147)

                        this.OnOverloadToggle()
                        this.HideUI()
                    end,
                    callBack = function()
                        TutorialManager.NextSubStep(1)
                    end
                }
            )
        end
    elseif step == TutorialStep.OverloadClose then
        if subStep == 5 then
            TutorialHelper.FingerMove(
                {
                    maskType = TutorialMaskType.None,
                    noticeKey = "Tutorial_OverloadClose_notice_1",
                    noticePos = this.TutorialPos,
                    -- fingerPoint = Vector3(270, -400, 0),
                    fingerPoint = Utils.GetLocalPointInRectangleByUI(SafeGetUIControl(this, "OverloadBtn")),
                    fingerSize = this.uidata.overloadSwitch.transform.sizeDelta,
                    fingerFunc = function()
                        this.OnOverloadToggle()
                        this.HideUI()
                    end,
                    callBack = TutorialManager.NextSubStep
                }
            )
        end
    end
end

function Panel.OnHide()
    this.ReleaseBtnSprite()
end
