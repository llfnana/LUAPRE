---@class UIShopPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIShopPanel = Panel;

require "Game/Logic/NewView/Shop/UIShopSpecialItem"
require "Game/Logic/NewView/Shop/UIShopPanelItem"
require "Game/Logic/NewView/Shop/UIShopBoxItem"
require "Game/Logic/NewView/Shop/UIShopSubscriptionItem"
require "Game/Logic/NewView/Shop/UIShopTimeMachineItem"
require "Game/Logic/NewView/Shop/UIShopSocialItem"

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}

    this.clipFPS = this.gameObject:GetComponent("ClipFPS")
    this.btnClose = this.BindUIControl("BtnClose/ImgIcon", this.HideUI)
    this.ShopScrollView = this.GetUIControl("ScrollView")
    this.ShopContent = this.GetUIControl(this.ShopScrollView, "Viewport/Content")
    this.SubscriptionContainer = this.GetUIControl(this.ShopContent, "Subscription/Container")
    this.GemContainer = this.GetUIControl(this.ShopContent, "Gem/Container")
    this.TimeMachineContainer = this.GetUIControl(this.ShopContent, "TimeMachine/Container")
    this.BoxContainer = this.GetUIControl(this.ShopContent, "Box/Container")
    this.SpecialContainer = this.GetUIControl(this.ShopContent, "Special/Container")
    this.OwnGemCountText = this.GetUIControl("Resource/TxtNum", "Text")
    this.BoxSelectCountText1 = this.GetUIControl(this.BoxContainer, "Box1/TxtNum", "Text")
    this.BoxSelectCountText2 = this.GetUIControl(this.BoxContainer, "Box2/TxtNum", "Text")
    this.BoxSelectCountText3 = this.GetUIControl(this.BoxContainer, "Box3/TxtNum", "Text")
    this.BoxTipText1 = this.GetUIControl(this.BoxContainer, "Box1/TxtTip", "Text")
    this.BoxTipText2 = this.GetUIControl(this.BoxContainer, "Box2/TxtTip", "Text")
    this.BoxTipText3 = this.GetUIControl(this.BoxContainer, "Box3/TxtTip", "Text")
    this.socialItem = this.GetUIControl(this.GemContainer, "SocialItem")
    this.socialItem:SetActive(false)
    this.SubscriptionInfoButton = this.BindUIControl(this.SubscriptionContainer.transform.parent, "Title/Txt/ImgTip",
        function()
            ShowUI(UINames.UISubscriptionTip)
        end)
    this.txtBoxTitle = this.GetUIControl(this.ShopContent, "Box/Title/Txt", "Text")
    this.txtSpecialTitle = this.GetUIControl(this.ShopContent, "Special/Title/Txt", "Text")
    this.txtSubscriptionTitle = this.GetUIControl(this.ShopContent, "Subscription/Title/Txt", "Text")
    this.txtTimeMachineTitle = this.GetUIControl(this.ShopContent, "TimeMachine/Title/Txt", "Text")
    this.txtGemTitle = this.GetUIControl(this.ShopContent, "Gem/Title/Txt", "Text")
    this.gemItems = nil
    this.socialItems = nil
end

function Panel.InitEvent()
    --绑定UGUI事件
end

-- param : {isDown:boolean, callback:function, isPreLoad:boolean}
function Panel.OnShow(param)
    this.isInit = false
    this.SetLang()
    this.isDown = param and param.isDown
    if param and param.callback then 
        param.callback()
        return 
    end
    this.isInit = true
    this.OnInit()
    -- 关闭场景相机
    EventManager.Brocast(EventType.CITY_CAMERA_DISABLED)
end

function Panel.SetLang()
    this.txtBoxTitle.text = GetLang("item_name_Box")
    this.txtSpecialTitle.text = GetLang("ui_shop_cutline_special")
    this.txtSubscriptionTitle.text = GetLang("ui_shop_cutline_subscription")
    this.txtTimeMachineTitle.text = GetLang("ui_shop_cutline_timeskip")
    this.txtGemTitle.text = GetLang("ui_shop_gem")
end

function Panel.HideUI()
    HideUI(UINames.UIShop)
end

function Panel.OnHide()
    EventManager.Brocast(EventType.CITY_CAMERA_ENABLED)
    this.OnDestroyPanel()
end

---OnInit
function Panel.OnInit()
    this.cityId = DataManager.GetCityId()
    this.CutLineActiveMap = {}

    ---宝箱item文本
    this.BoxCountTextBoxes = {
        this.BoxSelectCountText1,
        this.BoxSelectCountText2,
        this.BoxSelectCountText3
    }

    this.BoxFreeTagList = {
        this.BoxTipText1,
        this.BoxTipText2,
        this.BoxTipText3,
    }

    if DataManager.firstInit == false and DataManager.dataItems and DataManager.GetData(this.cityId) then -- 
        this.GemRxSubscribe = DataManager.GetMaterialRx(this.cityId, ItemType.Gem):subscribe(
            function(val)
                this.OwnGemCountText.text = DataManager.GetMaterialCountFormat(this.cityId, ItemType.Gem, true)
            end
        )
    end

    -- 先隐藏
    local childCount = this.SpecialContainer.transform.childCount
    for i = 1, childCount, 1 do
        this.SpecialContainer.transform:GetChild(i- 1):SetActive(false)
    end
    

    ---@type table<string, ShopPanelItemData[]>
    this.shopItemMap = {}
    this.shopItemMap[ShopManager.ShopItemType.Box] = this.InitItems(this.cityId, ShopManager.ShopItemType.Box)
    this.shopItemMap[ShopManager.ShopItemType.Special] = this.InitItems(this.cityId, ShopManager.ShopItemType.Special)
    this.shopItemMap[ShopManager.ShopItemType.Gem] = this.InitItems(this.cityId, ShopManager.ShopItemType.Gem)
    this.shopItemMap[ShopManager.ShopItemType.Resource] = this.InitItems(this.cityId, ShopManager.ShopItemType.Resource)
    this.shopItemMap[ShopManager.ShopItemType.EventResource] = this.InitItems(this.cityId,
        ShopManager.ShopItemType.EventResource)
    this.shopItemMap[ShopManager.ShopItemType.Subscription] = this.InitItems(this.cityId,
        ShopManager.ShopItemType.Subscription)
    this.shopItemMap[ShopManager.ShopItemType.TimeSkip] = this.InitItems(this.cityId, ShopManager.ShopItemType.TimeSkip)
    -- this.shopItemMap[ShopManager.ShopItemType.Social] = this.InitItems(this.cityId, ShopManager.ShopItemType.Social)
    this.RefreshContainer()

    this.Refresh0ClockFunc = function()
        this.RefreshContainer()
    end
    ForceRebuildLayoutImmediate(this.ShopContent.gameObject)

    EventManager.AddListener(EventType.SHOP_0_CLOCK_REFRESH, this.Refresh0ClockFunc)
    EventManager.AddListener(EventType.SHOP_COOL_DOWN, this.Refresh0ClockFunc)
    EventManager.AddListener(EventType.AD_LOADED, this.Refresh0ClockFunc)

    this.refreshSub = function()
        for i, v in ipairs(this.shopItemMap[ShopManager.ShopItemType.Subscription]) do
            v.uiRoot:Refresh()
        end
    end
    EventManager.AddListener(EventDefine.OnBoostRemove, this.refreshSub)
    this.time = TimeModule.addRepeatSec(function()
        this.refreshSub()
        EventManager.Brocast(EventDefine.OnSubscriptionRefresh)
    end, this.gameObject)

    this.RefreshCount()
    if this.isDown then
        TimeModule.addDelay(0, function()
            local position = this.ShopContent.transform.anchoredPosition
            Util.TweenTo(this.ShopContent.transform.anchoredPosition.y,
                this.ShopContent.transform.sizeDelta.y - this.ShopScrollView.transform.sizeDelta.y, 0.5,
                function(v)
                    this.ShopContent.transform.anchoredPosition = Vector2(position.x, v)
                end)
        end)
    else
        this.ShopContent.transform.anchoredPosition = Vector2(0, 0)
    end
end

function Panel.OnDestroyPanel()
    if this.isInit == false then return end
    EventManager.RemoveListener(EventType.SHOP_0_CLOCK_REFRESH, this.Refresh0ClockFunc)
    EventManager.RemoveListener(EventType.SHOP_COOL_DOWN, this.Refresh0ClockFunc)
    EventManager.RemoveListener(EventType.AD_LOADED, this.Refresh0ClockFunc)
    EventManager.RemoveListener(EventDefine.OnBoostRemove, this.refreshSub)

    TimeModule.removeTimer(this.time)
    if this.GemRxSubscribe then 
        this.GemRxSubscribe:unsubscribe()
    end
    -- this.GemDelayRxSubscribe:unsubscribe()

    --调用各各item的ondestroy方法
    for _, items in pairs(this.shopItemMap) do
        for i = 1, #items do
            items[i].uiRoot:OnDestroy()
        end
    end

    -- ShopManager.ResetNewShopItemsCount()

    -- ShopManager.Analytics("ShopIconClose", {})

    -- -- 查看购买项 TODO是否需要这个功能
    -- self:LookAt()
end

function Panel.RefreshBoxTab()
    local boxItems = this.shopItemMap[ShopManager.ShopItemType.Box]

    for i = 1, boxItems:Count() do
        this.BoxCountTextBoxes[i].gameObject:SetActive(false)

        local uiItem = boxItems[i].uiRoot
        local config, package = uiItem:GetCurrentConfig()
        if config ~= nil and package ~= nil then
            local boxId = uiItem:GetPackageBoxId(package)
            if boxId ~= nil then
                if BoxManager.GetBoxBagCount(boxId) > 0 then
                    this.BoxCountTextBoxes[i].text = "x" .. Utils.FormatCount(BoxManager.GetBoxBagCount(boxId))
                    this.BoxCountTextBoxes[i].gameObject:SetActive(true)
                end

                ---TODO临时注释
            end

            local inCD = ShopManager.GetShopItemInCooldown(config)
            local hasCD = config.condition_claim_cd > 0

            this.BoxFreeTagList[i].gameObject:SetActive(PaymentManager.IsFree(package) and (hasCD and not inCD))
        else
            this.BoxFreeTagList[i].gameObject:SetActive(false)
        end
    end
end

---刷新商店面板上的数字
function Panel.RefreshCount()
    -- --this.OwnBoxCountText.text = Utils.FormatCount(BoxManager.GetBoxBagCount(this.boxId))
    this.RefreshBoxTab()
end

---@return ShopItemTypeDefine
function Panel.GetShopItemTypeDefine(type)
    return this.shopItemTypeDefineMap[type]
end

---@return ShopItemTypeDefine
function Panel.CreateShopItemTypeDefine(parent, prefab, createFunc)
    return {
        parent = parent,
        prefab = prefab,
        createFunc = createFunc
    }
end

---@param cityId number
---@param config Shop
---@param silent boolean
---@param cb fun()
---@param errCb fun(errId : string)
function Panel.BuyBox(cityId, config, silent, cb, errCb)
    local package = ShopManager.GetPackageByShopId(config.id)
    local rewards = Utils.ParseReward(package.reward)
    local boxCount = BoxManager.GetBoxBagCount(rewards[1].id)
    local count = rewards[1].count

    -- 如果身上宝箱足够
    if count <= boxCount then
        this.OpenBox(cityId, config, silent, rewards, cb, errCb, "ShopOpenBox", "Use")
        return true
    end

    --静默状态下先检查消耗是否足够
    if silent then
        if not PaymentManager.Enough(package) then
            return false
        end
    end

    ShopManager.BuyWithDiamondConfirm(
        cityId,
        config,
        function()
            for i = 1, #rewards do
                if rewards[1].addType == RewardAddType.Box then
                    EventManager.Brocast(
                        EventType.OPEN_BOX,
                        this.cityId,
                        BoxManager.Action.Buy,
                        rewards[i].id,
                        rewards[i].count
                    )
                end
            end

            this.OpenBox(cityId, config, silent, rewards, cb, errCb, "ShopOpenBox", "Buy")
        end,
        function(errCode)
            if errCb ~= nil then
                errCb(errCode)
            end
        end
    )

    return true
end

---@param cityId number
---@param config Shop
---@param silent boolean
---@param rewards table
---@param cb fun()
---@param errCb fun()
function Panel.OpenBox(cityId, config, silent, rewards, cb, errCb, to, toId)
    if not silent then
        ---理论上购买宝箱是可以付费买的，但是现在ui只支持钻石买，所以这里直接传cost
        local price = 0
        local package = ConfigManager.GetShopPackage(config.id)
        for k, v in pairs(package.cost) do
            price = v
            break
        end

        local reOpenFunc
        if not ShopManager.HasCD(config.condition_claim_cd) then
            reOpenFunc = function(reOpenCb)
                local rt = self:BuyBox(cityId, config, true, reOpenCb, errCb)
                if not rt then
                    --只有钻石不足会返回false
                    ShopManager.ShowErrCode(PaymentManager.ErrCode.CostNotEnough)
                end

                return rt
            end
        end

        BoxManager.OpenBox(
            rewards[1].id,
            rewards[1].count,
            price,
            reOpenFunc,
            function()
                cb()
            end,
            to,
            toId,
            {
                shopId = config.id
            }
        )
    else
        cb()
    end

    -- --BI
    -- local obj = {
    --     boxId = rewards[1].id,
    --     value = rewards[1].count,
    --     openType = rewards[1].count
    -- }
    -- ShopManager.Analytics("ShopOpenBox", obj)
end

---@param cityId number
---@param type string
---@return ShopPanelItemData[]
function Panel.InitItems(cityId, type)
    local list = ShopManager.GetAvailableItems(cityId, type)
    list = ShopManager.ConvAvailableItems2Group(list)

    ---@type ShopPanelItemData[]
    local items = List:New()
    for i = 1, #list do
        if type == ShopManager.ShopItemType.Box then
            items:Add(this.InitBoxItem(list, type, i))
        else
            if type ~= ShopManager.ShopItemType.Subscription or i <= 3 then
                local rt = this.InitShopItem(list, type, i)
                if rt then 
                    items:Add(rt)
                end
            end
        end
    end

    return items
end

function Panel.InitPackageList(shopConfigList, type)
    local packageList = {}
    for i = 1, #shopConfigList do
        -- shopId === packageId
        table.insert(packageList, ConfigManager.GetShopPackage(shopConfigList[i].id))
    end
    return packageList
end

function Panel.InitBoxItem(list, type, i)
    local shopConfigList = list[i]
    local packageList = this.InitPackageList(shopConfigList, type)
    if i > 3 then
        return
    end
    local boxGo = this.BoxContainer.transform:Find("Box" .. i).gameObject
    local boxItem = UIShopBoxItem.new()
    boxItem:InitPanel(this.behaviour, boxGo, {index = i})
    local config = shopConfigList[1]

    ---@type ShopPanelItemData
    local rt = {
        config = config,
        package = packageList[1],
        configList = shopConfigList,
        packageList = packageList,
        uiRoot = boxItem,
        onBuyButtonClick = function(cfg, cb, disableRewardsShow)
            this.BuyBox(
                this.cityId,
                cfg,
                false,
                function()
                    boxItem:Refresh()
                    this.RefreshContainer(cfg.type, true)
                    this.RefreshCount()

                    -- 返回上层回调
                    if cb ~= nil then
                        cb()
                    end
                end,
                function(errId)
                    boxItem:Refresh()
                end
            )
        end,
        rebuildFunc = function()
            setTimeout(
                function()
                    ForceRebuildLayoutImmediate(this.ShopContent.gameObject)
                end,
                0
            )
        end
    }

    boxItem:OnInit(rt)
    return rt
end

function Panel.InitShopItem(list, type, i)
    local shopConfigList = list[i]
    local packageList = this.InitPackageList(shopConfigList, type)
    local item = nil
    local config = shopConfigList[1]
    if type == ShopManager.ShopItemType.Special then
        -- 限制次数为 0 时，不显示
        if ShopManager.CheckLimitCount(this.cityId, shopConfigList) == false then 
            return nil 
        end
        item = this.InitSpecialItem(i)
    elseif type == ShopManager.ShopItemType.Gem or type == ShopManager.ShopItemType.Resource or
        type == ShopManager.ShopItemType.EventResource then
        item = this.InitGemItem(i)
    elseif type == ShopManager.ShopItemType.Subscription then
        item = this.InitSubscriptionItem(i)
    elseif type == ShopManager.ShopItemType.TimeSkip then
        item = this.InitTimeMachineItem(i)
    elseif type == ShopManager.ShopItemType.Social then
        item = this.InitSocialItem(i)
    end

    ---@type ShopPanelItemData
    local rt = {
        config = config,
        package = packageList[1],
        configList = shopConfigList,
        packageList = packageList,
        uiRoot = item,
        onBuyButtonClick = function(cfg, cb, disableRewardsShow)
            -- 是否是首充双倍，要在购买前获取
            ShopManager.BuyWithDiamondConfirm(
                this.cityId,
                cfg,
                function(rewards)
                    if this.isClosed then
                        return
                    end
                    if PaymentManager.IsPurchaseByPackageId(cfg.id) then
                        UIUtil.showText(GetLang("toast_purchase_successed"))
                    end

                    if disableRewardsShow ~= true and #rewards > 0 then
                        ResAddEffectManager.AddResEffectFromRewards(
                            rewards,
                            true,
                            { hideFlying = true, isShop = true, eventSign = { shopId = config.id } }
                        )
                    end

                    -- 返回上层回调
                    if cb ~= nil then
                        cb()
                    end

                    item:Refresh()
                    this.RefreshContainer(cfg.type, true)
                    this.RefreshCount()
                end,
                function(errCode)
                    if this.isClosed then
                        return
                    end
                    item:Refresh()
                end
            )
        end,
        rebuildFunc = function()
            setTimeout(
                function()
                    ForceRebuildLayoutImmediate(this.ShopContent.gameObject)
                end,
                0
            )
        end
    }
    if item then
        item:OnInit(rt)
    end
    return rt
end

function Panel.InitSpecialItem(i)
    local special = nil
    local item = UIShopSpecialItem.new()
    this.clipFPS:AddFPS(1, 1, function(index)
        if i >= this.SpecialContainer.transform.childCount then
            local go = this.SpecialContainer.transform:GetChild(0).gameObject
            go:SetActive(false)
            special = GOInstantiate(go, this.SpecialContainer.transform)
        else
            special = this.SpecialContainer.transform:GetChild(i).gameObject
        end
        SafeSetActive(special, true)
        item:InitPanel(this.behaviour, special)
    end)
    return item
end

function Panel.InitGemItem(i)
    if this.gemItems == nil then
        this.gemItems = {}
    end
    local item = UIShopPanelItem.new()
    this.clipFPS:AddFPS(1, 1, function(index)
        local gem = this.gemItems[i]
        if gem == nil then
            local go = this.GemContainer.transform:GetChild(0).gameObject
            go:SetActive(false)
            gem = GOInstantiate(go, this.GemContainer.transform)
            this.gemItems[i] = gem
        end
        SafeSetActive(gem, true)
        item:InitPanel(this.behaviour, gem)
    end)
    return item
end

function Panel.InitSocialItem(i)
    if this.socialItems == nil then
        this.socialItems = {}
    end
    local item = UIShopSocialItem.new()
    this.clipFPS:AddFPS(1, 1, function(index)
        local social = this.socialItems[i]
        if social == nil then
            social = GOInstantiate(this.socialItem, this.GemContainer.transform)
            this.socialItems[i] = social
        end
        SafeSetActive(social, true)
        item:InitPanel(this.behaviour, social)
    end)
    return item
end

function Panel.InitSubscriptionItem(i)
    local subscription = this.SubscriptionContainer.transform:Find("Subscription" .. i).gameObject
    local item = UIShopSubscriptionItem.new()
    item:InitPanel(this.behaviour, subscription)
    return item
end

function Panel.InitTimeMachineItem(i)
    local timeMachine = this.TimeMachineContainer.transform:Find("TimeMachine" .. i).gameObject
    local item = UIShopTimeMachineItem.new()
    item:InitPanel(this.behaviour, timeMachine)
    return item
end

function Panel.RefreshContainer()
    SafeSetActive(this.SpecialContainer.transform.parent.gameObject, this.GetNum(ShopManager.ShopItemType.Special) > 0)
    SafeSetActive(this.GemContainer.transform.parent.gameObject, this.GetNum(ShopManager.ShopItemType.Gem) +
        this.GetNum(ShopManager.ShopItemType.Resource) + this.GetNum(ShopManager.ShopItemType.EventResource)
        + this.GetNum(ShopManager.ShopItemType.Social) > 0)
    SafeSetActive(this.BoxContainer.transform.parent.gameObject, this.GetNum(ShopManager.ShopItemType.Box) > 0)
    SafeSetActive(this.SubscriptionContainer.transform.parent.gameObject,
        this.GetNum(ShopManager.ShopItemType.Subscription) > 0)
    SafeSetActive(this.TimeMachineContainer.transform.parent.gameObject,
        this.GetNum(ShopManager.ShopItemType.TimeSkip) > 0)

    ForceRebuildLayoutImmediate(this.ShopContent.gameObject)
end

-- 已购买的仍然存在，但不显示
function Panel.GetNum(type)
    -- local num = this.shopItemMap[type] == nil and 0 or this.shopItemMap[type]:Count()
    -- return num

    local num = 0
    if this.shopItemMap[type] ~= nil and this.shopItemMap[type]:Count() > 0 then 
        for key, value in pairs(this.shopItemMap[type]) do
            if value.uiRoot and  value.uiRoot.gameObject.activeSelf then 
                num = num + 1
            end
        end
    end

    return num
end
