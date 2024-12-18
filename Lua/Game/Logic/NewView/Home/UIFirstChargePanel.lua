---@class UIFirstChargePanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIFirstChargePanel = Panel;

function Panel.OnAwake()
    this.cachedata = {}
    this.InitPanel()

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.Button = SafeGetUIControl(this, "Button")
    this.uidata.mask = this.BindUIControl("Mask", this.HideUI)
    this.uidata.priceText = SafeGetUIControl(this, "Button/Text", "Text")
    this.uidata.TextName = SafeGetUIControl(this, "ImageName/TextName", "Text")
    this.uidata.TextAdd = SafeGetUIControl(this, "ImageBuild/ImageAdd/TextAdd", "Text")
    this.uidata.TextBuild = SafeGetUIControl(this, "ImageBuild/ImageTitle/TextBuild", "Text")
    this.uidata.TitleImg = SafeGetUIControl(this, "ImageTitleE", "Image")
end

function Panel.InitEvent()
    --绑定UGUI事件

    SafeAddClickEvent(this.behaviour, this.uidata.Button, function()
        ShopManager.Buy(
            this.cityId,
            999,
            function(reward, errCode)
                if errCode == 0 then
                    -- 购买成功
                    UIMainPanel.uidata.FirstCharge:SetActive(false)
                    this.HideUI()
                    BoxManager.OpenBox(
                        this.rewards[1].id,
                        this.rewards[1].count,
                        6,
                        nil,
                        nil,
                        "ShopOpenBox",
                        "Buy",
                        {
                            shopId = 999
                        }
                    )
                else
                    -- 购买失败
                    ShopManager.ShowErrCode(errCode)
                end
            end
        )
    end)
end

function Panel.initData()
    this.cityId = DataManager.GetCityId()
    this.package = ConfigManager.GetShopPackage(999)
    this.rewards = Utils.ParseReward(this.package.reward, true)

    local rewards = Utils.ParseReward(this.package.reward)
    this.boxRewards = BoxManager.InspectBox(rewards[1].id, this.cityId)

    -- local baseRewardStr, additionRewardStr = BoxManager.GetBoxRewardDetails(rewards[1].id)
    -- this.boxRewards = Utils.ParseReward(baseRewardStr, false)


    this.cardId = this.GetCardId()
    this.cardConfig = ConfigManager.GetCardConfig(this.cardId)

    this.price = ShopManager.GetPrice(ShopManager.GetPackageByShopId(999).product_id)


    this.animation = SafeGetUIControl(this, "SkeletonGraphic", "SkeletonGraphic")
    local resCardPath = string.format("hero_model_%d_SkeletonData.asset", this.cardId)
    if ResInterface.IsExist(resCardPath) then
        this.CardResGuid = ResInterface.SyncLoadCommon(resCardPath, function(dataAsset)
            if isNil(this.animation) then 
                if this.CardResGuid ~= nil then 
                    ResInterface.ReleaseRes(this.CardResGuid)
                    this.CardResGuid = nil
                end
                return 
            end
            this.animation.skeletonDataAsset = dataAsset
            this.animation:Initialize(true)
            -- this.animation.state:SetAnimation(0, "standby", true)
        end)
    end
    
end

function Panel.OnShow()
    TutorialManager.isOpeningUIFirstCharge = false

    UIUtil.openPanelAction(this.gameObject)

    this.initData()

    this.InitEvent()

    local zoneId = ConfigManager.GetZoneInfoByCardId(this.cardId)
    local zoneConfig = ConfigManager.GetZoneConfigById(zoneId)
    this.uidata.TextAdd.text = GetLang("ui_shop_firstrecharge_tips") .. this.GetBoost(10)
    this.uidata.TextBuild.text = GetLang(zoneConfig.name_key[1])
    this.uidata.TextName.text = GetLang(this.cardConfig.name)
    Utils.SetZoneIcon(SafeGetUIControl(this, "ImageBuild/ImageIcon", "Image"), zoneId, 1)

    this.uidata.priceText.text = this.price

    -- 文本适应
    SafeGetUIControl(this, "ImageBuild/ImageTitle").transform.sizeDelta = Vector2.New(this.uidata.TextBuild.preferredWidth + 100, 36)
    SafeGetUIControl(this, "ImageBuild/ImageItem1/TextNum", "Text").text = 1
    SafeGetUIControl(this, "ImageBuild/ImageItem2/TextNum", "Text").text = this.GetItemCount("Heart")
    SafeGetUIControl(this, "ImageBuild/ImageItem3/TextNum", "Text").text = this.GetItemCount("BlackCoin")

    local path = "charge_img_title"
    local curlanguage = PlayerModule.getLanguageList()[PlayerModule.getLanguage()].flag
    if curlanguage == 'En' then
        path = "charge_img_title_01"
    end

    Utils.SetIcon(this.uidata.TitleImg, path, nil, true, true)
end

function Panel.HideUI()
    EventManager.Brocast(EventDefine.ShowMainUI)

    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UIFirstCharge)
    end)
end

function Panel.GetItemCount(item)
    for index, value in ipairs(this.boxRewards) do
        if value.id == item then
            return value.count
        end
    end
end

function Panel.GetCardId()
    for index, value in ipairs(this.boxRewards) do
        if value.addType == "addToCard" then
            return value.id
        end
    end
end

function Panel.GetBoost(level)
    local preString = BoostManager.GetCardBoostEffectPreString(this.cardConfig.boost_type)
    local boostConfig = ConfigManager.GetBoostConfig(this.cardConfig.boost)
    local effect = boostConfig.boost_effects[level]
    local ret = ""
    if this.cardConfig.boost_type == "medical" or this.cardConfig.boost_type == "protest" or
        string.find(this.cardConfig.boost_type, "resource", 0) == 1
    then
        ret = preString .. tostring(effect)
    else
        ret = preString .. tostring(effect * 100) .. "%"
    end
    return ret
end

function Panel.OnHide()
    if this.CardResGuid ~= nil then 
        ResInterface.ReleaseRes(this.CardResGuid)
        this.CardResGuid = nil
    end
end