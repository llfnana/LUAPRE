---@class UIShopBoxItem
local Element = class("UIShopBoxItem")
UIShopBoxItem = Element

function Element:ctor()
end

function Element:InitPanel(behaviour, obj, param)
    self.gameObject = obj;
    self.transform = obj.transform;
    self.behaviour = behaviour;
    param = param or {}

    if self.uidata == nil then self.uidata = {} end
    self.BuyButton = SafeGetUIControl(self, "BtnOpen")
    self.Title = SafeGetUIControl(self, "Title/Txt", "Text")
    self.txtOpen = SafeGetUIControl(self, "BtnOpen/TxtOpen", "Text")
    self.txtTime = SafeGetUIControl(self, "BtnOpen/TxtTime", "Text")
    self.consume = SafeGetUIControl(self, "BtnOpen/Consume")
    self.txtConsumeNum = SafeGetUIControl(self, "BtnOpen/Consume/TxtNum", "Text")
    self.txtTip = SafeGetUIControl(self, "TxtTip", "Text")

    self:InitLight()
    self:InitSpine(param.index)
end

function Element:InitLight() 
    -- 为什么这么，为了降低 DrawCall，将spine动画，放在一起（同一层级）
    self.light = SafeGetUIControl(self.transform.parent, self.gameObject.name .. "Spine/Light", "SkeletonGraphic")
    self.lightResGuid = ResInterface.SyncLoadCommon('effect_013_xiangsg_SkeletonData.asset', function(dataAsset)
        if isNil(self.light) then 
            if self.lightResGuid then
                ResInterface.ReleaseRes(self.lightResGuid)
                self.lightResGuid = nil
            end
            return
        end

        self.light.skeletonDataAsset = dataAsset
        self.light:Initialize(true)
        self.light.AnimationState:SetAnimation(0, "animation5", true)
        self.light.gameObject:SetActive(true)
    end)
end

function Element:InitSpine(index)
    -- 为什么这么，为了降低 DrawCall，将spine动画，放在一起（同一层级）
    self.spine = SafeGetUIControl(self.transform.parent, self.gameObject.name .. "Spine/SkeletonGraphic", "SkeletonGraphic")
    self.spineResGuid = ResInterface.SyncLoadCommon('effect_016_uixiang_SkeletonData.asset', function(dataAsset)
        if isNil(self.spine)then 
            if self.spineResGuid then 
                ResInterface.ReleaseRes(self.spineResGuid)
                self.spineResGuid = nil
            end
            return
        end

        self.spine.skeletonDataAsset = dataAsset
        self.spine:Initialize(true)
        self.spine.AnimationState:SetAnimation(0, index.."_2", true)
        self.spine.gameObject:SetActive(true)
    end)
end

---@param data ShopPanelItemData
function Element:OnInit(data)
    self.cityId = DataManager.GetCityId()
    self.shopPanelItemData = data

    --扫光特效
    -- self.light:Initialize(true)
    -- self.light.AnimationState:SetAnimation(0, "animation5", true)

    SafeAddClickEvent(self.behaviour, self.BuyButton, function()
        -- if ShopManager.CheckItem(self.cityId, self.currentConfig.id, ShopManager.Action.Buy) then
        --     self.shopPanelItemData.onBuyButtonClick(self.currentConfig)
        -- end
        self:ShowBoxPanel()
    end)
    SafeAddClickEvent(self.behaviour, self.gameObject, function()
        -- if ShopManager.CheckItem(self.cityId, self.currentConfig.id, ShopManager.Action.Buy) then
        --     self.shopPanelItemData.onBuyButtonClick(self.currentConfig)
        -- end
        self:ShowBoxPanel()
    end)


    -- self:CreateAllRewardItems()
    self:Refresh()
    local baseRewardStr, additionRewardStr = BoxManager.GetBoxRewardDetails(self.boxId)
    local base = Utils.ParseReward(baseRewardStr, false)
    local add = Utils.ParseReward(additionRewardStr, false)

    SafeAddClickEvent(self.behaviour, self.gameObject, function()
        self:ShowBoxPanel()
    end)


    self.RefreshCooldownFunc = function()
        if self.currentConfig == nil or self.currentPackage == nil then
            return
        end

        self:RefreshButtonAndText(self.currentConfig, self.currentPackage)
    end

    EventManager.AddListener(EventType.TIME_REAL_PER_SECOND, self.RefreshCooldownFunc)
end

function Element:Refresh()
    local currentConfig, currentPackage = self:RefreshLastAvailableConfig()
    -- if currentConfig == nil then
    --     self.ShopBoxItemImagePlus:SetActive(false)
    --     return
    -- end

    self.Title.text = GetLang(currentConfig.name)
    -- self.DescriptionText.color = self.params:GetColor(currentConfig.background_pic[1])
    -- self.DescriptionText4.color = self.params:GetColor(currentConfig.background_pic[1])
    -- ShopManager.UISetBackground({self.ShopBoxItemImagePlus}, currentConfig)

    -- self:RefreshBannerEffect(currentConfig)
    local hasCD = currentConfig.condition_claim_cd > 0
    local count = ShopManager.GetShopItemRemainCount(currentConfig.id)

    SafeSetActive(self.txtTip.gameObject, hasCD)

    if hasCD then
        if count >= 0 then
            self.txtTip.text = GetLangFormat(currentConfig.condition_count_desc, count)
        else
            self.txtTip.text = GetLangFormat("ui_shop_box_reset_time", currentConfig.condition_claim_cd / Time2
                .Hour)
        end
    end

    local configHasChange = self.currentConfig == nil or currentConfig.id ~= self.currentConfig.id


    self.boxId = self:GetPackageBoxId(currentPackage)

    local baseRewardStr, additionRewardStr = BoxManager.GetBoxRewardDetails(self.boxId)
    local base = Utils.ParseReward(baseRewardStr, false)
    local add = Utils.ParseReward(additionRewardStr, false)
    local itemConfig = ConfigManager.GetBoxConfig(self.boxId)
    -- if configHasChange then
    --     self:DestroyAllRewardItems()
    --     self:CreateAllRewardItems()
    -- end
    self:RefreshButtonAndText()
    -- self:RefreshResetTag()
end

function Element:ShowBoxPanel()
    ShowUI(UINames.UIBox, self.boxId, self.shopPanelItemData, function()
        if ShopManager.CheckItem(self.cityId, self.currentConfig.id, ShopManager.Action.Buy) then
            self.shopPanelItemData.onBuyButtonClick(self.currentConfig)
        end
    end)
    Audio.PlayAudio(DefaultAudioID.jiemiandakai)
end

---返回package的奖励中boxId，如果不存在，那么返回nil
---@param package ShopPackage
---@return string
function Element:GetPackageBoxId(package)
    local rewards = Utils.ParseReward(package.reward)

    for i = 1, #rewards do
        if rewards[i].addType == RewardAddType.Box then
            return rewards[i].id
        end
    end

    return nil
end

---@param config Shop
---@param package ShopPackage
function Element:RefreshButtonAndText()
    local config, package = self:RefreshLastAvailableConfig()
    local inCD = ShopManager.GetShopItemInCooldown(config)
    local isAd = PaymentManager.IsAd(package)

    local gemCount = PaymentManager.GetDiamondFromCost(package.id)

    self.txtOpen.text = isAd and GetLang("ui_shop_box_free") or GetLang("ui_shop_box_free")
    SafeSetActive(self.txtOpen.gameObject, (not inCD and gemCount <= 0))

    if gemCount <= 0 then
        local ad = SafeGetUIControl(self, "BtnOpen/Ad")
        SafeSetActive(ad.gameObject, isAd)
    end
    ForceRebuildLayoutImmediate(self.BuyButton)

    self:RefreshCooldownTime(self.currentConfig)
    SafeSetActive(self.txtTime.gameObject, inCD and gemCount <= 0)
    GreyObject(self.BuyButton, inCD and gemCount <= 0, true, false)

    self.txtConsumeNum.text = "x" .. gemCount
    SafeSetActive(self.consume.gameObject, gemCount > 0)
end

function Element:RefreshCooldownTime(config)
    self.txtTime.text = TimeUtil.format4(ShopManager.GetShopItemRemainTime(config, ShopManager.GetNow()))
end

---@return Shop, ShopPackage
function Element:RefreshLastAvailableConfig()
    -- box 获取可用config
    -- 免费箱子和广告箱子都CD时，展示免费箱子CD
    -- 免费箱子CD，广告箱子都有时，展示广告箱子可领，领取后，展示免费箱子CD
    -- 免费箱子有，广告箱子CD时，展示免费箱子可领，领取后，展示免费箱子CD
    -- 免费箱子有，广告箱子有时，展示免费箱子可领，领取后，展示广告箱子可领，领取后展示免费箱子CD
    -- 配置要求，免费箱子的sort必须小于广告箱子的sort

    table.sort(
        self.shopPanelItemData.configList,
        function(a, b)
            return a.sort < b.sort
        end
    )

    local config
    for i = 1, #self.shopPanelItemData.configList do
        if ShopManager.CheckItem(self.cityId, self.shopPanelItemData.configList[i].id, ShopManager.Action.Buy) then
            config = self.shopPanelItemData.configList[i]
            break
        end
    end

    --如果没有找到可以买的项目，那么就是用第一个配置(免费箱子)
    if config == nil then
        config = self.shopPanelItemData.configList[1]
    end

    local package

    if config ~= nil then
        package = ShopManager.GetPackageByShopId(config.id)
    end

    self.currentConfig = config
    self.currentPackage = package
    return config, package
end

function Element:GetCurrentConfig()
    return self.currentConfig, self.currentPackage
end

function Element:OnDestroy()
    EventManager.RemoveListener(EventType.TIME_REAL_PER_SECOND, self.RefreshCooldownFunc)
    if self.lightResGuid then 
        ResInterface.ReleaseRes(self.lightResGuid)
        self.lightResGuid = nil
    end

    if self.spineResGuid then 
        ResInterface.ReleaseRes(self.spineResGuid)
        self.spineResGuid = nil
    end
end
