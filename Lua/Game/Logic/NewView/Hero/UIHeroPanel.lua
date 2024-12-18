---@class UIHeroPanel : UIPanelBase
local Panel = UIPanelBaseMake()
local this = Panel
UIHeroPanel = Panel

require "Game/Logic/NewView/Hero/UnfoundItem"


function Panel.OnAwake()
    this.cachedata = {}
    this.InitPanel()

    this.param = nil

    this.isFirstInit = true
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.ButtonBack = SafeGetUIControl(this, "ButtonBack")

    this.uidata.HeartItem = SafeGetUIControl(this, "TopUI/HeartItem")
    this.uidata.CoinItem = SafeGetUIControl(this, "TopUI/CoinItem")
    this.uidata.GemItem = SafeGetUIControl(this, "TopUI/GemItem")

    this.uidata.HeartItemText = SafeGetUIControl(this, "TopUI/HeartItem/TxtCount", "Text")
    this.uidata.CoinItemText = SafeGetUIControl(this, "TopUI/CoinItem/TxtCount", "Text")
    this.uidata.GemItemText = SafeGetUIControl(this, "TopUI/GemItem/TxtCount", "Text")

    this.uidata.HeartIcon = SafeGetUIControl(this, "TopUI/HeartItem/Icon", "Image")
    this.uidata.CoinIcon = SafeGetUIControl(this, "TopUI/CoinItem/Icon", "Image")
    this.uidata.GemIcon = SafeGetUIControl(this, "TopUI/GemItem/Icon", "Image")


    this.uidata.CollectedTitle = SafeGetUIControl(this, "ScrollView/Viewport/Content/CollectedTitle")
    this.uidata.UnfoundTitle = SafeGetUIControl(this, "ScrollView/Viewport/Content/UnfoundTitle")
    this.uidata.LockTitle = SafeGetUIControl(this, "ScrollView/Viewport/Content/LockTitle")

    this.uidata.CollectedContent = SafeGetUIControl(this, "ScrollView/Viewport/Content/CollectedContent")
    this.uidata.UnfoundContent = SafeGetUIControl(this, "ScrollView/Viewport/Content/UnfoundContent")
    this.uidata.LockContent = SafeGetUIControl(this, "ScrollView/Viewport/Content/LockContent")

    this.uidata.HeroItem = SafeGetUIControl(this, "HeroItem")
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.ButtonBack, this.HideUI)

    -- 砖石
    SafeAddClickEvent(this.behaviour, this.uidata.GemItem, function()
        ShowUI(UINames.UIShop)
    end)
end

function Panel.InitData()
    local cardsListConfig = ConfigManager.GetCardConfigList()
    this.cityId = DataManager.GetCityId()

    if this.isFirstInit then 
        this.unlockItems = List:New()
        this.lockItems = List:New()
        this.unfoundItems = List:New()
        this.unlockListForSort = List:New()
        this.rxList = List:New()

        this.allItems = List:New()
    else 
        this.unlockItems:Clear()
        this.lockItems:Clear()
        this.unfoundItems:Clear()
        this.unlockListForSort:Clear()
        this.allItemsIndex = 1
    end

    local unfoundConfigs = {}
    local lockCardConfigs = {}
    cardsListConfig:ForEach(
        function(cardConfig)
            local cardUnlockType, lockParam = CardManager.GetCardUnlockState(cardConfig.id, this.cityId)
            if cardUnlockType == CardUnlockType.Own then
                this.AddUnlockListForSort(cardConfig, HeroBattleDataManager.GetCardPower(cardConfig.id))
            elseif cardUnlockType == CardUnlockType.UnFound then
                table.insert(unfoundConfigs, cardConfig)
            elseif cardUnlockType == CardUnlockType.Lock_ZoneId then
                table.insert(lockCardConfigs, cardConfig)
            elseif cardUnlockType == CardUnlockType.Lock_CityId then
                table.insert(lockCardConfigs, cardConfig)
            end
        end
    )

    if next(unfoundConfigs) then
        this.SortForUnfoundCardList(unfoundConfigs)
        for i, cardConfig in ipairs(unfoundConfigs) do
            this.AddCardItem(this.uidata.UnfoundContent.transform, this.unfoundItems, cardConfig.id)
        end
    end

    if next(lockCardConfigs) then
        this.SortForUnlockCardList(lockCardConfigs)
        for i, cardConfig in ipairs(lockCardConfigs) do
            this.AddCardItem(this.uidata.LockContent.transform, this.lockItems, cardConfig.id)
        end
    end

    this.CalcUnlockListForSort(this.unlockListForSort)
    for i = 1, #this.unlockListForSort do
        local item = this.unlockListForSort[i]
        this.AddCardItem(this.uidata.CollectedContent.transform, this.unlockItems, item.config.id,
            item.uiItem)
    end

    this.uidata.CollectedTitle:SetActive(this.unlockListForSort:Count() > 0)
    this.uidata.UnfoundTitle:SetActive(this.unfoundItems:Count() > 0)
    this.uidata.LockTitle:SetActive(this.lockItems:Count() > 0)

    this.uidata.CollectedContent:SetActive(this.unlockListForSort:Count() > 0)
    this.uidata.UnfoundContent:SetActive(this.unfoundItems:Count() > 0)
    this.uidata.LockContent:SetActive(this.lockItems:Count() > 0)
    this.uidata.LockContent.transform.rect.height = 368 * (math.ceil(this.lockItems:Count() / 3))

    this.isFirstInit = false

    --会有布局问题，延迟一帧刷新
    StartCoroutine(function()
        Yield(nil)
        ForceRebuildLayoutImmediate(SafeGetUIControl(this, "ScrollView/Viewport/Content/CollectedContent"))
        Yield(nil)
        ForceRebuildLayoutImmediate(SafeGetUIControl(this, "ScrollView/Viewport/Content/UnfoundContent"))
        Yield(nil)
        ForceRebuildLayoutImmediate(SafeGetUIControl(this, "ScrollView/Viewport/Content/LockContent"))
        Yield(nil)
        ForceRebuildLayoutImmediate(SafeGetUIControl(this, "ScrollView/Viewport/Content"))
    end)
end

-- 添加carItem
function Panel.AddCardItem(content, itemList, id, listItem)
    local item 
    local cardItem
    if this.isFirstInit then 
        item = UnfoundItem.new()
        cardItem = GOInstantiate(this.uidata.HeroItem)
        this.allItems:Add({item, cardItem})
    else
        local value = this.allItems[this.allItemsIndex]
        this.allItemsIndex = this.allItemsIndex + 1
        item = value[1]
        cardItem = value[2]
    end

    cardItem.transform:SetParent(content, false)
    SafeSetActive(cardItem.gameObject, true)
    item:InitPanel(this.behaviour, cardItem, id, itemList)
    itemList:Add(item)
    if listItem then
        listItem = item
    end
end

function Panel.UpdateView()
    this.unlockItems:ForEach(
        function(item)
            item:UpdateView()
        end
    )
end

function Panel.AddUnlockListForSort(config, power, uiItem)
    this.unlockListForSort:Add(
        {
            config = config,
            uiItem = uiItem,
            power = power
        }
    )
end

function Panel.OnShow()
    UIUtil.openPanelAction(this.gameObject)
    
    this.InitEvent()
    this.InitData()

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

    -- 关闭场景相机
    EventManager.Brocast(EventType.CITY_CAMERA_DISABLED)
end

function Panel.HideUI()
    this.rxList:ForEach(
        function(rx)
            rx:unsubscribe()
        end
    )
    this.rxList:Clear()

    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UIHero)
    end)
end

function Panel.OnHide()
    EventManager.Brocast(EventType.CITY_CAMERA_ENABLED)
end

function Panel.SortForUnfoundCardList(list)
    table.sort(
        list,
        function(configA, configB)
            if configA.color ~= configB.color then
                return this.GetQualityByColor(configA.color) > this.GetQualityByColor(configB.color)
            else
                return configA.id < configB.id
            end
        end
    )
end

function Panel.SortForUnlockCardList(list)
    table.sort(
        list,
        function(configA, configB)
            local idA = CardManager.GetCardCityValue(configA, CityType.City)
            local idB = CardManager.GetCardCityValue(configB, CityType.City)
            if idA ~= idB then
                return idA < idB
            else
                if configA.color ~= configB.color then
                    return this.GetQualityByColor(configA.color) > this.GetQualityByColor(configB.color)
                else
                    return configA.id < configB.id
                end
            end
        end
    )
end

function Panel.CalcUnlockListForSort(list)
    list:Sort(
        function(a, b)
            if a.power ~= b.power then
                return a.power > b.power
            elseif a.config.color ~= b.config.color then
                return this.GetQualityByColor(a.config.color) > this.GetQualityByColor(b.config.color)
            else
                return a.config.id < b.config.id
            end
        end
    )
end

function Panel.GetQualityByColor(color)
    if color == "orange" then
        return 3
    elseif color == "purple" then
        return 2
    else
        return 1
    end
end
