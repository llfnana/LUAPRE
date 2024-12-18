---@class UIHeroStarUpPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIHeroStarUpPanel = Panel;
require "Game/Logic/NewView/Hero/StarItem"

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.StarContent = SafeGetUIControl(this, "StarContent")
    this.uidata.Mask = SafeGetUIControl(this, "Mask")
    this.uidata.BtnClose = SafeGetUIControl(this, "BtnClose")
    this.uidata.ButtonGet = SafeGetUIControl(this, "ButtonGet")
    this.uidata.CostCardImage = SafeGetUIControl(this, "ImageNeed/CostCard/ImageIcon", "Image")
    this.uidata.TextCostCard = SafeGetUIControl(this, "ImageNeed/CostCard/TextCostCard", "Text")
    this.uidata.CostItemImage = SafeGetUIControl(this, "ImageNeed/CostItem/ImageIcon", "Image")
    this.uidata.TextCostItem = SafeGetUIControl(this, "ImageNeed/CostItem/TextCostItem", "Text")
end

function Panel.InitEvent()
    --绑定UGUI事件

    -- 退出
    SafeAddClickEvent(this.behaviour, this.uidata.BtnClose, function()
        this.HideUI()
    end)

    -- 退出
    SafeAddClickEvent(this.behaviour, this.uidata.Mask, function()
        this.HideUI()
    end)

    -- 升级
    SafeAddClickEvent(this.behaviour, this.uidata.ButtonGet, function()
        Audio.PlayAudio(DefaultAudioID.HeroStarUp)
        this.OnUpgradeStar()
    end)
end

function Panel.OnShow(param)
    this.data = param
    this.cardId = param.cardId
    this.cardItemData = CardManager.GetCardItemData(this.cardId)
    local star = this.cardItemData:GetStar()
    this.cityId = DataManager.GetCityId()

    -- 星星
    local starLevel = this.cardItemData:GetStarLevel()
    local StarItem = StarItem.new()
    StarItem:InitPanel(this.behaviour, this.uidata.StarContent)
    StarItem:SetStarLevel(starLevel)

    if this.cardItemData:CanAddStarStatus() then
        StarItem:ShowNextUpgradeLight()
    end

    this.UpdateView()
end

function Panel.OnUpgradeStar()
    if GameManager.IsCardNew() then
        if this.cardItemData:CanAddStarStatus() then
            this.UpgradeStar("normal", 0)
        else
            local gemCost = 0
            local hasCardCount = CardManager.GetCardCount(this.cardId)
            local lackCardCount = this.cardItemData:GetEatCardCount() - hasCardCount
            local cardRewards = {}
            if lackCardCount > 0 then
                -- UIUtil.showText(GetLang("toast_card_no_enough"))

                local cardItem = {}
                cardItem.addType = RewardAddType.Card
                cardItem.count = lackCardCount
                cardItem.id = this.cardId
                table.insert(cardRewards, cardItem)

                local cardConfig = ConfigManager.GetCardConfig(this.cardId)
                if cardConfig ~= nil and cardConfig.gem_cost ~= nil then
                    gemCost = gemCost + cardConfig.gem_cost * lackCardCount
                end
            else
                lackCardCount = 0
            end

            --item
            local costData = this.cardItemData:GetEatCardCost()
            local hasItemCount = DataManager.GetMaterialCount(this.cityId, costData.itemId)
            local lackItemCount = costData.count - hasItemCount
            local rewards = {}
            if lackItemCount > 0 then
                -- UIUtil.showText(GetLang("insufficient_materials"))

                rewards[costData.itemId] = lackItemCount
                local itemConfig = ConfigManager.GetItemConfig(costData.itemId)
                if itemConfig ~= nil and itemConfig.gem_cost ~= nil then
                    gemCost = gemCost + itemConfig.gem_cost * lackItemCount
                end
            else
                lackItemCount = 0
            end

            gemCost = math.floor(gemCost)

            --call function
            local confirmFunc = function()
                if DataManager.GetMaterialCount(this.cityId, ItemType.Gem) < gemCost then
                    -- ShopManager.ShowErrCode(PaymentManager.ErrCode.CostNotEnough)
                    return
                end

                DataManager.UseMaterial(this.cityId, ItemType.Gem, gemCost, "CardStarUp", "CardStarUp")
                if lackCardCount > 0 then
                    CardManager.AddCard(this.cardId, lackCardCount, "CardStarUp", "CardStarUp")
                end
                if lackItemCount > 0 then
                    DataManager.AddMaterial(this.cityId, costData.itemId, lackItemCount, "CardStarUp", "CardStarUp")
                end

                this:UpgradeStar("gemBuy", gemCost)
            end

            UIUtil.showConfirmByData({
                Title = "ui_buy_resource",
                DescriptionRaw = GetLang("ui_buy_resource_txt"),
                CardRewards = cardRewards,
                Rewards = rewards,
                ShowGemButton = true,
                GemCost = gemCost,
                GemButtonText = "ui_yes_btn",
                OnCostFunc = function()
                    confirmFunc()
                end,
                NoPlayEffect = true,
                ShowGemMax = true,
            })

            -- PopupManager.Instance:OpenPanel(
            --     PanelType.MessageBoxPanel,
            --     {
            --         Title = "ui_buy_resource",
            --         DescriptionRaw = GetLang("ui_buy_resource_txt"),
            --         CardRewards = cardRewards,
            --         Rewards = rewards,
            --         ShowGemButton = true,
            --         GemCost = gemCost,
            --         GemButtonText = "ui_yes_btn",
            --         OnCostFunc = function()
            --             confirmFunc()
            --         end,
            --         NoPlayEffect = true,
            --         ShowGemMax = true,
            --     }
            -- )
        end
    else
        this:UpgradeStar("normal", 0)
    end
end

function Panel.UpgradeStar(upgradeType, gemValue)
    if this.cardItemData:AddStar(this.data.from, upgradeType, gemValue) then
        this.HideUI()
    end
end

function Panel.UpdateView()
    local star = this.cardItemData:GetStar()
    SafeGetUIControl(this, "HeroHp/TextCur", "Text").text = Mathf.RoundToInt(this.cardItemData:GetHp())
    SafeGetUIControl(this, "HeroHp/TextNextNum", "Text").text = Mathf.RoundToInt(this.cardItemData:GetHp(nil, star + 1))
    SafeGetUIControl(this, "HeroAtk/TextCur", "Text").text = Mathf.RoundToInt(this.cardItemData:GetAttack())
    SafeGetUIControl(this, "HeroAtk/TextNextNum", "Text").text = Mathf.RoundToInt(this.cardItemData:GetAttack(nil,
        star + 1))
    SafeGetUIControl(this, "HeroDef/TextCur", "Text").text = Mathf.RoundToInt(this.cardItemData:GetDefence())
    SafeGetUIControl(this, "HeroDef/TextNextNum", "Text").text = Mathf.RoundToInt(this.cardItemData:GetDefence(nil,
        star + 1))

    SafeGetUIControl(this, "ArmyHp/TextCur", "Text").text = Mathf.RoundToInt(this.cardItemData:GetTroopsHp())
    SafeGetUIControl(this, "ArmyHp/TextNextNum", "Text").text = Mathf.RoundToInt(this.cardItemData:GetTroopsHp(nil,
        star + 1))
    SafeGetUIControl(this, "ArmyAtk/TextCur", "Text").text = Mathf.RoundToInt(this.cardItemData:GetTroopsAttack())
    SafeGetUIControl(this, "ArmyAtk/TextNextNum", "Text").text = Mathf.RoundToInt(this.cardItemData:GetTroopsAttack(nil,
        star + 1))
    SafeGetUIControl(this, "ArmyDef/TextCur", "Text").text = Mathf.RoundToInt(this.cardItemData:GetTroopsDefence())
    SafeGetUIControl(this, "ArmyDef/TextNextNum", "Text").text = Mathf.RoundToInt(this.cardItemData:GetTroopsDefence(nil,
        star + 1))
    SafeGetUIControl(this, "Panel/TextCurNum", "Text").text = this.cardItemData:GetMaxLevel()
    SafeGetUIControl(this, "Panel/TextNextNum", "Text").text = this.cardItemData:GetMaxLevel(star + 1)


    this.cardConfig = ConfigManager.GetCardConfig(this.cardId)

    -- 卡牌图标
    Utils.SetCardHeroIcon(SafeGetUIControl(this, "ImageNeed/CostCard/ImageIcon", "Image"), this.cardId)
    if CardManager.GetCardCount(this.cardId) >= this.cardItemData:GetEatCardCount() then
        this.uidata.TextCostCard.text =
            Utils.RichText(CardManager.GetCardCount(this.cardId), "#8ed740") ..
            "/" .. this.cardItemData:GetEatCardCount()
    else
        this.uidata.TextCostCard.text =
            Utils.RichText(CardManager.GetCardCount(this.cardId), "#e1423f") ..
            "/" .. this.cardItemData:GetEatCardCount()
    end

    local costData = this.cardItemData:GetEatCardCost()
    
    Utils.SetItemIcon(this.uidata.CostItemImage, costData.itemId)
    if DataManager.GetMaterialCount(this.cityId, costData.itemId) >= costData.count then
        this.uidata.TextCostItem.text =
            Utils.RichText(DataManager.GetMaterialCountFormat(this.cityId, costData.itemId), "#8ed740") ..
            "/" .. costData.count
    else
        this.uidata.TextCostItem.text =
            Utils.RichText(DataManager.GetMaterialCountFormat(this.cityId, costData.itemId), "#e1423f") ..
            "/" .. costData.count
    end
end

function Panel.HideUI()
    HideUI(UINames.UIHeroStarUp)
end
