---@class UnfoundItem
local Element = class("UnfoundItem")
UnfoundItem = Element

require "Game/Logic/NewView/Hero/StarItem"

function Element:ctor()
    self.isInit = false
end

function Element:InitPanel(behaviour, obj, cardId, cardItems)
    self.gameObject = obj
    self.transform = obj.transform
    self.behaviour = behaviour
    self.cardItems = cardItems

    self.cityId = DataManager.GetCityId()
    self.cardId = cardId
    self.cardConfig = ConfigManager.GetCardConfig(self.cardId)
    self.manageType = CardManager.GetCardManageType(self.cardId)

    local cardUnlockType, lockParam = CardManager.GetCardUnlockState(cardId, self.cityId)

    self.cardUnlockType = cardUnlockType
    self.lockParam = lockParam

    if cardUnlockType == CardUnlockType.Own then
        self.cardItemData = CardManager.GetCardItemData(self.cardId)
    else
        self.cardItemData = CardManager.CreateFullCardItem(self.cardConfig)
    end

    if self.isInit == false then 
        self.isInit = true

        self.StarContent = SafeGetUIControl(self, "StarContent")
        self.WorkState = SafeGetUIControl(self, "WorkState")

        self.CollectedState = SafeGetUIControl(self, "CollectedState")
        self.UnfoundState = SafeGetUIControl(self, "UnfoundState")
        self.LockState = SafeGetUIControl(self, "LockState")

        self.lockNoticeText = SafeGetUIControl(self, "LockState/Text", "Text")
        self.UnfoundNoticeText = SafeGetUIControl(self, "UnfoundState/Text", "Text")

        self.TextLv = SafeGetUIControl(self, "CollectedState/ContentLV/TextLVNum")
        self.ImageLvUp = SafeGetUIControl(self, "CollectedState/ImageLvUp", "Image")

        SafeAddClickEvent(self.behaviour, self.gameObject, function()
            self:ItemClick()
        end)
    end

    self:UpdateView()
end

function Element:ItemClick()
    local cardUnlockType, lockParam = CardManager.GetCardUnlockState(self.cardId, self.cityId)
    if cardUnlockType == CardUnlockType.Own then
        ShowUI(UINames.UIHeroInfo, {
            cardItemData = CardManager.GetCardItemData(self.cardId),
            cardUIItems = self.cardItems,
            from = "CardList",
            showCallBack = function()
                HideUI(UINames.UIHero)
            end,
            closeCallBack = function()
                ShowUI(UINames.UIHero)
            end
        })
    elseif cardUnlockType == CardUnlockType.UnFound then
        ShowUI(UINames.UIHeroInfo,
            {
                cardItemData = CardManager.CreateFullCardItem(self.cardConfig),
                cardUIItems = self.cardItems,
                from = "CardList",
                showCallBack = function()
                    HideUI(UINames.UIHero)
                end,
                closeCallBack = function()
                    ShowUI(UINames.UIHero)
                end
            }
        )
    elseif cardUnlockType == CardUnlockType.Lock_ZoneId then
        ShowUI(UINames.UIHeroInfo,
            {
                cardItemData = CardManager.CreateFullCardItem(self.cardConfig),
                cardUIItems = self.cardItems,
                from = "CardList",
                showCallBack = function()
                    HideUI(UINames.UIHero)
                end,
                closeCallBack = function()
                    ShowUI(UINames.UIHero)
                end
            }
        )
    elseif cardUnlockType == CardUnlockType.Lock_CityId then
        ShowUI(UINames.UIHeroInfo,
            {
                cardItemData = CardManager.CreateFullCardItem(self.cardConfig),
                cardUIItems = self.cardItems,
                from = "CardList",
                showCallBack = function()
                    HideUI(UINames.UIHero)
                end,
                closeCallBack = function()
                    ShowUI(UINames.UIHero)
                end
            }
        )
    end
end

function Element:UpdateView()
    self:RefreshBaseView()

    self:RefreshState()

    self:RefreshManageView()
end

-- 图标
function Element:RefreshBaseView()
    -- 背景

    Utils.SetIcon(SafeGetUIControl(self, "ImageBg", "Image"), "hero_img_Card_" .. self.cardConfig.color)

    Utils.SetCardHeroHalfPic(SafeGetUIControl(self, "HeroIcon", "Image"), self.cardId)
    Utils.SetIconItem(SafeGetUIControl(self, "ImageBuildType", "Image"), self.cardConfig.zone_type_icon)
    
    Utils.SetCardIcon(SafeGetUIControl(self, "ImageKind/OccupationIcon", "Image"), "hero_" .. self.cardConfig.occupation)
    Utils.SetCardIcon(SafeGetUIControl(self, "ImageKind/TypeIcon", "Image"), "card_main_type_" .. self.cardConfig.type)
end

-- 状态
function Element:RefreshState()
    self.StarContent = SafeGetUIControl(self, "StarContent")
    self.StarContent:SetActive(false)
    self.CollectedState:SetActive(false)
    self.UnfoundState:SetActive(false)
    self.LockState:SetActive(false)

    if self.cardUnlockType == CardUnlockType.Own then
        self.CollectedState:SetActive(true)
        SafeGetUIControl(self, "CollectedState/ImageLvUp"):SetActive(self.cardItemData:IsCanUpgradeLevel())
        self.TextLv:SetActive(true)
        self.TextLv:GetComponent("Text").text = tostring(":" .. self.cardItemData:GetLevel())
        self.StarContent:SetActive(true)
        local StarItem = StarItem.new()
        StarItem:InitPanel(self.behaviour, self.StarContent)
        -- 星星
        local starLevel = self.cardItemData:GetStarLevel()
        StarItem:SetStarLevel(starLevel)
        if self.cardItemData:CanAddStarStatus() then
            StarItem:ShowNextUpgradeLight()
        end
    elseif self.cardUnlockType == CardUnlockType.UnFound then
        self.UnfoundState:SetActive(true)
        self.UnfoundNoticeText.text = GetLangFormat("ui_card_to_be_found")
        self.TextLv:SetActive(false)
    elseif self.cardUnlockType == CardUnlockType.Lock_ZoneId then
        self.LockState:SetActive(true)
        self.lockNoticeText.text = GetLangFormat("ui_card_unlock_zone", self.lockParam)
        self.TextLv:SetActive(false)
    elseif self.cardUnlockType == CardUnlockType.Lock_CityId then
        self.LockState:SetActive(true)
        self.lockNoticeText.text = GetLangFormat("ui_card_unlock_city", self.lockParam)
        self.TextLv:SetActive(false)
    end
end

-- 加班状态
function Element:RefreshManageView()
    if self.manageType == CardManageType.manage then
        self:RefreshWorkingContentView()
    elseif self.manageType == CardManageType.peaceManage then
        self:RefreshWorkingContentView()
    elseif self.manageType == CardManageType.overall then
        self.WorkState:SetActive(false)
    end
end

-- 工作状态
function Element:RefreshWorkingContentView()
    if self.cardUnlockType == CardUnlockType.Own then
        self.WorkState:SetActive(MapManager.IsHasCardId(self.cityId, self.cardId))
    else
        self.WorkState:SetActive(false)
    end
end

function Element:GetCardBgColor()
    if self.cardConfig.color == "blue" then
        return 1
    elseif self.cardConfig.color == "purple" then
        return 2
    elseif self.cardConfig.color == "orange" then
        return 3
    else
        return 1
    end
end

function Element:GetCardItemData()
    return self.cardItemData
end

function Element:OnDestroy()

end
