---@class UINewHeroPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UINewHeroPanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.mask = this.BindUIControl("Mask", this.HideUI)
    this.uidata.imgBg = this.GetUIControl("ImgBg", "Image")
    this.uidata.imgBuildType = this.GetUIControl("ImageBuildType", "Image")
    this.uidata.imgKind = this.GetUIControl("ImageKind")
    this.uidata.imgOccupation = this.GetUIControl(this.uidata.imgKind, "OccupationIcon", "Image")
    this.uidata.imgTypeIcon = this.GetUIControl(this.uidata.imgKind, "TypeIcon", "Image")
    this.uidata.txtOutPut = this.GetUIControl("TextOutPut", "Text")
    this.uidata.txtOutPutValue = this.GetUIControl("TextOutPutVal", "Text")
    this.uidata.txtName = this.GetUIControl("TextName", "Text")
    this.uidata.contentLv = this.GetUIControl("ContentLV")
    this.uidata.txtLv = this.GetUIControl(this.uidata.contentLv, "TextLV", "Text")
    this.uidata.txtLvNum = this.GetUIControl(this.uidata.contentLv, "TextLVNum", "Text")
    this.uidata.imgShadow = this.GetUIControl("ImageShadow")
    this.uidata.animation = SafeGetUIControl(this, "SkeletonGraphic", "SkeletonGraphic")
    this.uidata.txt = this.GetUIControl("Txt", "Text")
    this.uidata.effect = this.GetUIControl("Z_UI_heroget")
end

function Panel.InitEvent()
    --绑定UGUI事件
end

function Panel.OnShow(param)
    this.flag = true
    this.cardId = param.cardId
    this.cardConfig = ConfigManager.GetCardConfig(param.cardId)
    this.cardItemData = CardManager.GetCardItemData(param.cardId)
    this.InitLang()
    this.Refresh()
    this.PlayAni()
    this.PlayGetHeroAudio()
end

function Panel.InitLang()
    this.uidata.txtOutPut.text = GetLang("UI_Building_Info_Output")
    this.uidata.txt.text = GetLang("Tutorial_Tap_Next")
    this.uidata.txtLv.text = GetLang("ui_build_card_lvl") .. ":"
end

function Panel.Refresh()
    this.SetImage(this.uidata.imgBuildType, this.cardConfig.zone_type_icon)
    this.SetImage(this.uidata.imgOccupation, "icon_hero_" .. this.cardConfig.occupation)
    this.SetImage(this.uidata.imgTypeIcon, "icon_card_main_type_" .. this.cardConfig.type)
    this.uidata.txtOutPutValue.text = this.cardItemData:GetCardBoostEffectShow()
    this.uidata.txtName.text = GetLang(this.cardConfig.name)
    this.uidata.txtLvNum.text = this.cardItemData:GetLevel() .. "/" .. this.cardItemData:GetMaxLevel()

    UIUtil.AddToolTip(this.uidata.imgBuildType, GetLang(this.cardConfig.zone_type_icon_desc), ToolTipDir.Left)
    UIUtil.AddToolTip(this.uidata.imgTypeIcon, Utils.GetCardMainTypeLang(this.cardConfig.type), ToolTipDir.Right)
    UIUtil.AddToolTip(this.uidata.imgOccupation, Utils.GetCardOccupationLang(this.cardConfig.occupation),
        ToolTipDir.Right)

    this.SetImage(this.uidata.imgBg, "hero_img_bg_" .. this.cardConfig.color)
    local resCardPath = string.format("hero_model_%d_SkeletonData.asset", this.cardId)

    if ResInterface.IsExist(resCardPath) then
        ResInterface.SyncLoadCommon(resCardPath, function(dataAsset)
            this.uidata.animation.skeletonDataAsset = dataAsset
            this.uidata.animation:Initialize(true)
            this.uidata.animation.gameObject:SetActive(true)
        end)
    end
end

function Panel.PlayAni()
    local start = Vector2(0, 800)
    local target = Vector2(0, -312)
    this.uidata.animation.transform.anchoredPosition = Vector2(0, 800)
    this.uidata.animation.transform.localScale = Vector3(1.3, 1.3, 1)
    Util.TweenTo(0, 1, 0.4, function(v)
        local distance = target - start
        this.uidata.animation.transform.anchoredPosition = start + distance * v
    end)
    TimeModule.addDelay(0.4, function()
        Util.TweenTo(1.3, 1, 0.2, function(v)
            this.uidata.animation.transform.localScale = Vector3(v, v, 1)
        end)
    end)

    SafeSetActive(this.uidata.imgBuildType.gameObject, false)
    TimeModule.addDelay(0.6, function()
        SafeSetActive(this.uidata.imgBuildType.gameObject, true)
    end)
    SafeSetActive(this.uidata.txtOutPut.gameObject, false)
    SafeSetActive(this.uidata.txtOutPutValue.gameObject, false)
    TimeModule.addDelay(0.7, function()
        SafeSetActive(this.uidata.txtOutPut.gameObject, true)
        SafeSetActive(this.uidata.txtOutPutValue.gameObject, true)
    end)

    SafeSetActive(this.uidata.imgKind.gameObject, false)
    TimeModule.addDelay(0.8, function()
        SafeSetActive(this.uidata.imgKind.gameObject, true)
    end)

    SafeSetActive(this.uidata.txtName.gameObject, false)
    SafeSetActive(this.uidata.contentLv.gameObject, false)
    TimeModule.addDelay(0.9, function()
        SafeSetActive(this.uidata.txtName.gameObject, true)
        SafeSetActive(this.uidata.contentLv.gameObject, true)
        this.flag = false
    end)
end

function Panel.PlayGetHeroAudio()
    Audio.PlayAudio(DefaultAudioID.GetHero)
end

function Panel.HideUI()
    if this.flag then
        return
    end
    HideUI(UINames.UINewHero)
end
