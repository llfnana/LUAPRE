ShopManager = {}
ShopManager.__cname = "ShopManager"

local this = ShopManager

ShopManager.ShopItemType = {
    Gem = "Gem",
    Special = "Special",
    Resource = "Resource",
    EventResource = "EventResource",
    Box = "Box",
    Subscription = "Subscription",
    TimeSkip = "TimeSkip",
    Social = "Social"
}

ShopManager.ShopItemTagType = {
    None = "none",
    Double = "double"
}

ShopManager.ErrCode = {
    InvalidItem = 91001
}

ShopManager.SubscriptionType = {
    AD = "ad",
    Battle = "battle",
    Diamond = "diamond",
    City = "city"
}

ShopManager.Action = {
    Show = "show",
    Buy = "buy"
}

ShopManager.ShopManagerRefreshShop = "ShopManagerRefreshShop"

---@class TagPos
---@field id string
---@field lineSpacing number

function ShopManager.Init()
    this.inInitial = true --标记当前进入初始化状态
    if this.initialized == nil then
        this.newShopItemsCountRx = NumberRx:New(0)
        this.subscriptionCanClaimedCountRx = NumberRx:New(0)

        this.data = DataManager.GetGlobalDataByKey(DataKey.Shop) or this.NewData()
        this.InitRefreshShop(this.GetNow())

        this.AddListener()
        this.UpdateCooldownEvent()

        this.initialized = true
    end

    this.ClearPopupItem()
    this.UpdateNewShopItemsCount()
end

function ShopManager.InitView()
    this.inInitial = false
end

---返回是否初始化完成
function ShopManager.IsInitialized()
    return this.initialized or false
end

function ShopManager.SaveData()
    DataManager.SetGlobalDataByKey(DataKey.Shop, this.data)
end

function ShopManager.NewData()
    return {
        preShowSign = {}
    }
end

function ShopManager.ClearData()
    this.data = this.NewData()
    PaymentManager.ClearData()
    ShopManager.UpdateNewShopItemsCount()
end

function ShopManager.InitRefreshShop()
    DailyShoutManager.Register(
        ShopManager.ShopManagerRefreshShop,
        function(now)
            this.UpdateNewShopItemsCount()
            EventManager.Brocast(EventType.SHOP_0_CLOCK_REFRESH)
        end,
        -1,
        false,
        DailyShoutManager.Priority.Slack
    )
end

---@param shopId number
---@return Shop
function ShopManager.GetShopConfig(shopId)
    return ConfigManager.GetAllShop()[shopId]
end

---@param shopId number
---@return ShopPackage
function ShopManager.GetPackageByShopId(shopId)
    -- shopId === packageId
    return ConfigManager.GetAllShopPackage()[shopId]
end

---@param cityId number
---@param shopId number
---@param action string     show:展示用,buy:购买
---@param reason fun(reason: string)
---@return boolean
function ShopManager.CheckItem(cityId, shopId, action, reason)
    local reasonFunc = function(r)
        -- print("zhkxin " .. shopId .. " ShopManager CheckItem false reason is ", r)
        if reason ~= nil then
            reason(r)
        end
    end

    local config = this.GetShopConfig(shopId)
    --预加载的
    if not PaymentManager.initialized then 
        return false
    end

    local packageItem = PaymentManager.GetPackageItem(shopId)
    -- packageId === shopId
    local package = this.GetPackageByShopId(shopId)

    if not this.CheckADSwitch(config, package) then
        reasonFunc("ad_switch")
        return false
    end

    if package == nil then
        print("[error]" .. "not found package: " .. shopId)
    end
    local now = this.GetNow()

    if not this.CheckSwitch(shopId, config.switch, package.type, TimeModule.getServerTime()) then
        reasonFunc("switch")
        return false
    end

    -- shopId === packageId
    local reset, available = this.CheckResetDate(config.reset, packageItem, now)
    if reset then
        PaymentManager.ResetPackageItem(shopId, now)
    end

    if not this.CheckCityId(config.condition_city, cityId) then
        reasonFunc("cityId")
        return false
    end

    --前面已经reset过了，就不重复了，必须放在cityId判断之后，有时候，可能需要在某些场景的活动里才刷新
    if not reset and this.CheckScopeReset(config.reset, cityId, packageItem) then
        PaymentManager.ResetPackageItem(shopId, now)
    end

    if action == this.Action.Show then
        -- 展示时，没有cd配置的，那么数量不足就不显示
        if
            not this.HasCD(config.condition_claim_cd) and
            not this.CheckCount(config.condition_count, this.GetShopItemCount(shopId))
        then
            reasonFunc("count")
            return false
        end
    elseif action == this.Action.Buy then
        -- 如果是买，那么cd不到，或者数量不足
        if
            not this.CheckCD(config.condition_claim_cd, packageItem, now) or
            not this.CheckCount(config.condition_count, this.GetShopItemCount(shopId))
        then
            reasonFunc("cd")
            return false
        end
    end

    if not this.CheckFunctionsUnlock(config.condition_functions_unlock) then
        reasonFunc("unlock")
        return false
    end

    if config.type ~= ShopManager.ShopItemType.Subscription and this.IsEmptyRewards(package.reward) then
        reasonFunc("emptyReward")
        return false
    end

    if not this.CheckGroup(cityId, config, action) then
        reasonFunc("group")
        return false
    end

    if not this.CheckAd(package) then
        reasonFunc("ad")
        return false
    end

    if not this.CheckUserType(config.condition_user_type) then
        reasonFunc("userType")
        return false
    end

    if not available then
        reasonFunc("available")
        return false
    end

    return true
end

---@param now number
function ShopManager.CheckSwitch(shopId, switch, packageType, now)
    if packageType ~= PaymentManager.PackageType.Subscription then
        return switch
    end

    return switch or PaymentManager.GetSubscription(shopId, nil, now) ~= nil
end

function ShopManager.IsEmptyRewards(rewardStr)
    local rewards = Utils.ParseReward(rewardStr)
    local count = 0
    for i = 1, #rewards do
        -- boost配置一般数量为0，所以boost不能通过count来判断是否为空
        if rewards[i].addType == RewardAddType.Boost then
            return false
        end

        if rewards[i].addType ~= RewardAddType.ZoneTime and rewards[i].count > 0 then
            return false
        end
    end

    return true
end

---@param condition number
---@param count number
---@return boolean
function ShopManager.CheckCount(condition, count)
    if condition == nil then
        return true
    end

    return condition == 0 or condition > count
end

---@param itemData PaymentItemData
---@param now Time2
---@return boolean
function ShopManager.CheckCD(condition, itemData, now)
    if condition == 0 then
        -- 0表示没有cd
        return true
    end

    if (itemData.lastClaimedTS or 0) == 0 then
        return true
    end

    return condition + itemData.lastClaimedTS <= TimeModule.getServerTime()
end

---返回冷却时间剩余时间
---@param config Shop
---@param now Time2
---@return number
function ShopManager.GetShopItemRemainTime(config, now)
    local item = PaymentManager.GetPackageItem(config.id)
    return item.lastClaimedTS + config.condition_claim_cd - TimeModule.getServerTime()
end

---有CD
function ShopManager.HasCD(condition)
    return condition > 0
end

---检查购买项是否在CD中
---@param config Shop
---@return boolean
function ShopManager.GetShopItemInCooldown(config)
    --shopId === packageId
    local item = PaymentManager.GetPackageItem(config.id)
    if not this.HasCD(config.condition_claim_cd) then
        return false
    end

    return not this.CheckCD(config.condition_claim_cd, item, this.GetNow())
end

---@param op string
---@param count number
---@param value number
---@return boolean
function ShopManager.CompareCount(op, count, value)
    if op == "gt" then
        return value > count
    elseif op == "lt" then
        return value < count
    elseif op == "eq" then
        return value == count
    end

    return false
end

---@param itemData PaymentItemData
function ShopManager.CheckScopeReset(condition, cityId, itemData)
    if condition.scope ~= "event" then
        return false
    end

    if not CityManager.GetIsEventScene(cityId) then
        return false
    end

    return itemData.eventId ~= 1--EventSceneManager.GetEventId()
end

function ShopManager.CheckScope(condition, cityId)
    if condition == "" or condition == "Global" then
        return true
    end

    return (condition == "City" and not CityManager.GetIsEventScene(cityId)) or
        (condition == "Event" and CityManager.GetIsEventScene(cityId))
end

---@param condition number[]
---@param cityId number
---@return boolean
function ShopManager.CheckCityId(condition, cityId)
    if #condition == 0 then
        return true
    end

    local rt = false
    for i = 1, #condition, 2 do
        rt = rt or this.CompareCityId(condition, i, cityId)
        if rt then
            return true
        end
    end

    return rt
end

---@param cityIds number[]
---@param index number
---@param cityId number
---@return boolean
function ShopManager.CompareCityId(cityIds, index, cityId)
    if index == #cityIds then
        return cityIds[index] <= cityId
    end

    return cityIds[index] <= cityId and cityIds[index + 1] >= cityId
end

---@param condition string
---@return boolean
function ShopManager.CheckFunctionsUnlock(condition)
    if condition == "" then
        return true
    end

    return FunctionsManager.IsUnlock(condition)
end

---@param condition table<string, number>
---@param itemData PaymentItemData
---@param now Time2
function ShopManager.CheckResetDate(condition, itemData, now)
    condition.refresh = condition.refresh or DissolveCardManager.ItemRefreshType.None
    condition.startTime = tonumber(condition.startTime or 0)
    condition.endTime = tonumber(condition.endTime or 0)
    condition.count = tonumber(condition.count or 0)

    return DissolveCardManager.CheckShopItemTime(Time2:New(itemData.lastRefreshTS), now, condition)
end

---检查当前shop item是否在组内可见
---@param cityId number
---@param config Shop
---@param action string     show:展示用,buy:购买
function ShopManager.CheckGroup(cityId, config, action)
    if config.group == 0 then
        return true
    end

    if config.type == ShopManager.ShopItemType.Special then
        -- special 只展示当前组中最后一个可用的item，如果最后一个可用的项目购买剩余数量为0，那么整组都不显示
        for _, shop in pairs(ConfigManager.GetAllShop()) do
            if shop.group == config.group and shop.sort > config.sort then
                if this.CheckItem(cityId, shop.id, action) then
                    return false
                end

                if not this.CheckCount(shop.condition_count, this.GetShopItemCount(shop.id)) then
                    return false
                end
            end
        end
    end

    return true
end

---@param package ShopPackage
function ShopManager.CheckAd(package)
    if package.ad_cost and not AdManager.IsLoaded() then
        return false
    end

    return true
end

---@param userTypeList string[]
function ShopManager.CheckUserType(userTypeList)
    if #userTypeList == 0 then
        return true
    end

    for i = 1, #userTypeList do
        if UserTypeManager.Is(userTypeList[i]) then
            return true
        end
    end

    return false
end

---返回指定类型里所有可展示的项目
---@param cityId number
---@param type string
---@return Shop[]
function ShopManager.GetAvailableItems(cityId, type)
    local rt = List:New()
    local config = ConfigManager.GetAllShop()
    for k, v in pairs(config) do
        if v.type == type then
            if this.CheckItem(cityId, v.id, this.Action.Show) then
                rt:Add(v)
            end
        end
    end

    return rt
end

---@param a Shop
---@param b Shop
function ShopManager.SortShopFunc(a, b)
    if a.sort == b.sort then
        if a.group == b.group then
            return a.id < b.id
        end

        return a.group < b.group
    end

    return a.sort < b.sort
end

function ShopManager.SortShopListFunc(a, b)
    return a[1].sort < b[1].sort
end

---@param items Shop[]
---@return Shop[][]
function ShopManager.ConvAvailableItems2Group(items)
    items:Sort(this.SortShopFunc)

    local newItems = {}
    local groupItems = {}
    ---@param item Shop
    items:ForEach(
        function(item)
            if item.group ~= 0 then
                --table.insert(newItems[#newItems], item)
                if groupItems[item.group] == nil then
                    groupItems[item.group] = {}
                end

                table.insert(groupItems[item.group], item)
            else
                table.insert(newItems, { item })
            end
        end
    )

    for _, v in pairs(groupItems) do
        table.insert(newItems, v)
    end

    table.sort(newItems, this.SortShopListFunc)

    return newItems
end

---@param shopId number
---@param cb fun(rewards:table, errCode:number)
---@return boolean
function ShopManager.Buy(cityId, shopId, cb)
    -- PopupManager.Instance:ShowLoading()
    UIUtil.showWaitTip()
    local f = function(rewards, errCode)
        -- PopupManager.Instance:HideLoading()
        UIUtil.hideWaitTip()
        cb(rewards, errCode)

        EventManager.Brocast(EventType.SHOP_BUY, shopId)
    end

    local config = this.GetShopConfig(shopId)

    -- 检查项目是否可用
    if not this.CheckItem(cityId, shopId, this.Action.Buy) then
        -- cb(nil, ShopManager.ErrCode.InvalidItem)
        f(nil, ShopManager.ErrCode.InvalidItem)
        return
    end

    PaymentManager.Buy(config.id, f)
end

---@param cityId number
---@param config Shop
---@param cb fun(rewards : Reward[])
---@param errCb fun(errCode : number)
function ShopManager.BuyWithDiamondConfirm(cityId, config, cb, errCb)
    local diamond, confirmDiamond = PaymentManager.GetDiamondFromCost(config.id)

    this.Buy(
        cityId,
        config.id,
        function(rewards, errCode)
            if errCode == 0 then
                cb(rewards)
            else
                if errCb == nil or errCb(errCode) ~= true then
                    this.ShowErrCode(errCode)
                end
            end
        end
    )
    -- local enough =
    --     Utils.ShowDiamondConfirmBox(
    --         function()
    --             return diamond
    --         end,
    --         function()
    --             this.Buy(
    --                 cityId,
    --                 config.id,
    --                 function(rewards, errCode)
    --                     if errCode == 0 then
    --                         cb(rewards)
    --                     else
    --                         if errCb == nil or errCb(errCode) ~= true then
    --                             this.ShowErrCode(errCode)
    --                         end
    --                     end
    --                 end
    --             )
    --         end,
    --         nil,
    --         confirmDiamond
    --     )

    -- if not enough then
    --     this.ShowErrCode(PaymentManager.ErrCode.CostNotEnough)
    -- end
end

---返回商店项目历史购买次数，当商品为付费商品时，使用package购买次数
---@param shopId number
---@return number
function ShopManager.GetShopItemCount(shopId)
    local package = this.GetPackageByShopId(shopId)
    return PaymentManager.GetPackageCount(package.id)
end

---返回商店项目剩余数量, 如果没有限制，那么返回-1
---@return number
function ShopManager.GetShopItemRemainCount(shopId)
    local config = this.GetShopConfig(shopId)
    if config.condition_count == 0 then
        return -1
    end

    local remainCount = config.condition_count - this.GetShopItemCount(shopId)

    if remainCount < 0 then
        -- 如果剩余数量小于0，表示很可能这个配置之前是无限消费
        return 0
    end

    return remainCount
end

---@param pic string
function ShopManager.GetBannerImage(pic)
   -- if pic == nil or pic == "" then
        return nil
    --end
    --return ResourceManager.Load(string.format("images/pic/%s", pic), TypeSprite)
end

function ShopManager.InstanceObjectByName(params, name, parent)
    if name == nil or name == "" then
        return
    end

    local obj = params:GetGameObject(name)
    if obj == nil then
        return
    end

    --这个函数主要用于创建特效，所以传true
    --return ResourceManager.Instantiate(obj, parent, true)
end

---@param tag string
function ShopManager.GetTagImage(tag)
   -- if tag == nil or tag == "" then
        return nil
   -- end
   -- return ResourceManager.Load(string.format("images/tag/%s", tag), TypeSprite)
end

function ShopManager.GetBackgroundImage(bg)
   -- if bg == nil or bg == "" then
        return nil
   -- end
   -- return ResourceManager.Load(string.format("images/shop/%s", bg), TypeSprite)
end

---@param bgList table[]
---@param config Shop
function ShopManager.UISetBackground(bgList, config)
    for i = 1, #bgList do
        if config.background_pic[i] ~= nil then
            bgList[i].sprite = this.GetBackgroundImage(config.background_pic[i])
        else
            bgList[i].gameObject:SetActive(false)
            bgList[i].sprite = nil
        end
    end
end

---@param bgList table[]
---@param config Shop
function ShopManager.UISetPopupBackground(bgList, config)
    for i = 1, #bgList do
        if config.popup_background_pic[i] ~= nil then
            bgList[i].sprite = this.GetBackgroundImage(config.popup_background_pic[i])
        else
            bgList[i].gameObject:SetActive(false)
            bgList[i].sprite = nil
        end
    end
end

---设置tag，1.0，新版本使用CreateTagOnPos
---@param tagIcon table
---@param tagText table
---@param tag table
---@param tag_params table
function ShopManager.UISetTag(tagIcon, tagText, tag, tag_params)
    if not this.UITagIsActive(tag, tag_params) then
        tagIcon.gameObject:SetActive(false)
        return
    end

    if tag.pic ~= nil then
        tagIcon.sprite = this.GetTagImage(tag.pic)
    end

    if tag.text ~= nil and tag.text ~= "" then
        tagText.text = GetLangFormat(tag.text, table.unpack(tag_params))
    elseif #tag_params > 0 then
        tagText.text = tag_params[1]
    end
end

---@param itemIcon table
---@param countText table
---@param config Shop
---@param package ShopPackage
function ShopManager.UISetPurchaseButton(btnImg, itemIcon, countText, config, package)
    if PaymentManager.IsPurchase(package) then
        if btnImg ~= nil then
            btnImg:SelectSprite(0)
        end

        itemIcon.gameObject:SetActive(false)
        countText.text = this.GetPrice(package.product_id)
    else
        if ShopManager.GetShopItemRemainCount(config.id) == 0 then
            --数量用完了
            if btnImg ~= nil then
                btnImg:SelectSprite(2)
            end
            itemIcon.gameObject:SetActive(false)
            countText.text = GetLang("ui_shop_resource_limit_done_daily")
        elseif PaymentManager.IsFree(package) then
            if btnImg ~= nil then
                btnImg:SelectSprite(1)
            end
            itemIcon.gameObject:SetActive(false)
            countText.text = GetLang("ui_shop_resource_free")
        else
            if btnImg ~= nil then
                btnImg:SelectSprite(0)
            end
            if Utils.GetTableLength(package.cost) > 0 then
                for k, v in pairs(package.cost) do
                    Utils.SetItemIcon(itemIcon, k)
                    countText.text = v
                    break
                end
            end
        end
    end
end

---@param productId string
function ShopManager.GetPrice(productId)
    if productId == "" then
        return ""
    end

    return PaymentManager.GetPriceStr(productId)
end

---@return Time2
function ShopManager.GetNow()
    return Time2:New(GameManager.GameTime())
end

---返回奖励中是否包含时间资源
function ShopManager.IsWorkTimeOverReward(rewards)
    for i = 1, #rewards do
        if rewards[i].addType == RewardAddType.ItemOverTime or rewards[i].addType == RewardAddType.OverTime then
            return true, rewards[i]
        end
    end

    return false, nil
end

---判断tag是否展示
function ShopManager.UITagIsActive(tag, tag_params)
    return not (Utils.GetTableLength(tag) == 0 and #tag_params == 0 or tag.type == nil)
end

---@param config Shop
---@return table[]
function ShopManager.CreateTagOnPos(config, gameObject, prefab)
    local param = gameObject:GetComponent(typeof(CS.FrozenCity.GameObjectParams))

    if not this.UITagIsActive(config.tag, config.tag_params) then
        return nil
    end

    if config.tag.pos == nil then
        config.tag.pos = "1"
    end

    local posObj = param:GetGameObject("pos" .. config.tag.pos)
    if posObj == nil then
        return nil
    end

    -- local ui = ResourceManager.Instantiate(prefab, posObj.transform)
    -- ---@type ShopTagIcon
    -- local tagView = ShopTagIcon:Create(ui)
    -- tagView:OnInit(config.tag, config.tag_params)

    -- return tagView
    return nil
end

---@param config Shop
---@param tagView ShopTagIcon
function ShopManager.RefreshTagView(config, tagView)
    if tagView == nil then
        return
    end

    local package = ConfigManager.GetShopPackage(config.id)

    if tagView:GetType() == ShopManager.ShopItemTagType.Double then
        tagView.gameObject:SetActive(PaymentManager.IsDouble(package))
    end

    tagView:Refresh(config.tag, config.tag_params)
end

function ShopManager.Analytics(name, data)
    data.gemBalance = DataManager.GetMaterialCount(DataManager.GetCityId(), ItemType.Gem)
    data.heartBalance = DataManager.GetMaterialCount(DataManager.GetCityId(), ItemType.Heart)
    data.purchaseAmount = PaymentManager.GetPriceCount()
    Analytics.Event(name, data)
end

---返回订阅中可领取的数量，目前只有钻石和广告是可领取的,所以这里只判断这两种
---如果要修改，UI界面和这里都要修改
function ShopManager.UpdateAndGetSubscriptionCanClaimedCount()
    local count = 0
    local _, diamondSub, _ = this.CheckSubscriptionCanClaimByType(ShopManager.SubscriptionType.Diamond)

    if diamondSub then
        count = count + 1
    end

    this.subscriptionCanClaimedCountRx.value = count

    return count
end

function ShopManager.GetCanClaimFreeItemCount(cityId, type)
    local count = 0
    local items = this.GetAvailableItems(DataManager.GetCityId(), type)
    ---@param item Shop
    items:ForEach(
        function(item)
            local package = ConfigManager.GetShopPackage(item.id)
            if PaymentManager.IsFree(package) and this.CheckItem(cityId, item.id, this.Action.Buy)
            then
                count = count + 1
            end
        end
    )

    return count
end

function ShopManager.UpdateNewShopItemsCount()
    local cityId = DataManager.GetCityId()
    local count = 0

    --local boxItems = this.CompareAvailableItems(cityId, ShopManager.ShopItemType.Box)
    --local gemItems = this.CompareAvailableItems(cityId, ShopManager.ShopItemType.Gem)
    --local specialItems = this.CompareAvailableItems(cityId, ShopManager.ShopItemType.Special)
    --local resourceItems = this.CompareAvailableItems(cityId, ShopManager.ShopItemType.Resource)
    --local subscriptionItems = this.CompareAvailableItems(cityId, ShopManager.ShopItemType.Subscription)
    --
    --count = #boxItems + #gemItems + #specialItems + #resourceItems + #subscriptionItems
    count = count + this.GetCanClaimFreeItemCount(cityId, ShopManager.ShopItemType.EventResource)
    count = count + this.GetCanClaimFreeItemCount(cityId, ShopManager.ShopItemType.Resource)
    count = count + this.GetCanClaimFreeItemCount(cityId, ShopManager.ShopItemType.Box)
    count = count + this.UpdateAndGetSubscriptionCanClaimedCount()

    this.newShopItemsCountRx.value = count
end

function ShopManager.ResetNewShopItemsCount()
    --local cityId = DataManager.GetCityId()
    --
    --this.ResetPreSignOfItems(cityId, ShopManager.ShopItemType.Box)
    --this.ResetPreSignOfItems(cityId, ShopManager.ShopItemType.Gem)
    --this.ResetPreSignOfItems(cityId, ShopManager.ShopItemType.Special)
    --this.ResetPreSignOfItems(cityId, ShopManager.ShopItemType.Resource)
    --this.ResetPreSignOfItems(cityId, ShopManager.ShopItemType.Subscription)
    --
    this.UpdateNewShopItemsCount()
end

---比较当前可用项目和之前的区别，如果有新增，那么返回新增项
---@param type string
function ShopManager.CompareAvailableItems(cityId, type)
    local newItems = {}
    if this.data.preShowSign[type] == nil then
        this.data.preShowSign[type] = {}
    end

    local items = this.GetAvailableItems(cityId, type)
    for i = 1, #items do
        local sign = this.data.preShowSign[type][tostring(items[i].id)]
        if sign == nil then
            table.insert(newItems, items[i].id)
        end
    end


    this.SaveData()
    return newItems
end

---重置preShowSign
---@param type string
function ShopManager.ResetPreSignOfItems(cityId, type)
    local items = this.GetAvailableItems(cityId, type)
    this.data.preShowSign[type] = {}
    for i = 1, #items do
        this.data.preShowSign[type][tostring(items[i].id)] = 1
    end

    this.SaveData()
end

function ShopManager.GetNewShopItemsCountRx()
    return this.newShopItemsCountRx
end

function ShopManager.GetSubscriptionCanClaimedCountRx()
    return this.subscriptionCanClaimedCountRx
end

---返回当前有每日领奖的订阅
---@param now Time2
---@return PaymentSubscriptionData[]
function ShopManager.CheckDailyReward(now)
    local subList = PaymentManager.GetAllValidSubscription(now)
    local rt = {}

    for i = 1, #subList do
        local dailyName = PaymentManager.GetDailyNameByPackageId(subList[i].packageId)
        local package = ConfigManager.GetShopPackage(subList[i].packageId)

        if DailyBagManager.GetItem(dailyName, now:Timestamp()) > 0 then
            local dailyRewards = Utils.ParseReward(package.reward_daily)
            if #dailyRewards > 0 then
                table.insert(rt, subList[i])
            end
        end
    end

    return rt
end

---领取所有每日奖励，又名：一键领取
---@return table  返回获取的奖励
function ShopManager.GetAllDailyReward()
    local subList = PaymentManager.GetAllValidSubscription(ShopManager.GetNow())
    local rewards = {}

    for i = 1, #subList do
        local dailyRewards = PaymentManager.GetPackageDailyReward(subList[i].packageId)

        if dailyRewards ~= nil then
            Utils.MergeRewards(dailyRewards, rewards)
        end
    end

    return rewards
end

---获得当前所有可用boost
---@return string[]
function ShopManager.GetAllBoostReward()
    local subList = PaymentManager.GetAllValidSubscription(this.GetNow())
    local rt = {}

    for i = 1, #subList do
        local package = ConfigManager.GetShopPackage(subList[i].packageId)
        if package.reward_boost ~= "" then
            local boosts = string.split(package.reward_boost, ",")
            for j = 1, #boosts do
                table.insert(rt, boosts[j])
            end
        end
    end

    return rt
end

function ShopManager.GetBoostRewardStartTime(boost)
    local subList = PaymentManager.GetAllValidSubscription(this.GetNow())

    local startTime = 0
    for i = 1, #subList do
        local package = ConfigManager.GetShopPackage(subList[i].packageId)
        if package.reward_boost ~= "" then
            local boosts = string.split(package.reward_boost, ",")
            for j = 1, #boosts do
                if boost == boosts[j] then
                    startTime = subList[i].createTS
                end
            end
        end
    end

    return startTime
end

---返回列表中是否有已购买和已购买的packageId
---@param configList Shop[]
---@param now number
---@return boolean, number
function ShopManager.GetGroupIncludePurchased(configList, now)
    -- 这里要检查所有package是否其中有已购买
    local purchased = false
    local purchasedPackageId = 0
    for i = 1, #configList do
        local sub = PaymentManager.GetSubscription(configList[i].id, nil, now)
        if sub ~= nil then
            purchased = true
            purchasedPackageId = sub.packageId
            break
        end
    end

    return purchased, purchasedPackageId
end

--- 返回指定子类型的订阅
---@return Shop[], ShopPackage[]
function ShopManager.FindSubscription(shopSubscriptType)
    local subList = ShopManager.GetAvailableItems(DataManager.GetCityId(), ShopManager.ShopItemType.Subscription)
    subList = this.ConvAvailableItems2Group(subList)

    -- 查找子类型
    local subConfigList = nil
    local packageList = {}
    for i = 1, #subList do
        if subList[i][1].sub_type == shopSubscriptType then
            subConfigList = subList[i]

            for j = 1, #subConfigList do
                local package = ConfigManager.GetShopPackage(subConfigList[j].id)
                table.insert(packageList, package)
            end

            break
        end
    end

    return subConfigList, packageList
end

--- 打开指定子类型的订阅窗口
---@param buyFunc fun(success: boolean)
---@param windowOpenFunc fun()
---@param claimFunc fun(rewards: table)
---@param showRestoreButton boolean
function ShopManager.OpenSubscriptionConfirmPanel(
    shopSubscriptType,
    buyFunc,
    windowOpenFunc,
    claimFunc,
    showRestoreButton,
    closeWindowFunc)
    local configList, packageList = this.FindSubscription(shopSubscriptType)

    if configList == nil then
        return
    end

    if configList ~= nil then
        ShowUI(UINames.UISubscription, {
            configList = configList,
            packageList = packageList,
            successBuyFunc = buyFunc,
            windowOpenFunc = windowOpenFunc,
            claimFunc = claimFunc,
            showRestoreButton = showRestoreButton,
            windowCloseFunc = closeWindowFunc
        })

        local packageKeyList = {}
        for i = 1, #packageList do
            table.insert(packageKeyList, packageList[i].id)
        end
        ShopManager.Analytics(
            "ShopSubscriptionUiIconTap",
            {
                from = shopSubscriptType,
                packageKeyList = packageKeyList
            }
        )
    end
end

--- 检查订阅是否可用
---@return boolean
function ShopManager.CheckSubscriptionValid(shopSubscriptType)
    if not FunctionsManager.IsUnlock(FunctionsType.Shop) then
        return false
    end

    local configList, packageList = this.FindSubscription(shopSubscriptType)

    if configList == nil then
        return false
    end

    return this.CheckItem(DataManager.GetCityId(), configList[1].id, this.Action.Buy)
end

---检查订阅是否已购买，是否可领取, packageId，configList
---@return boolean, boolean, number, Shop[]
function ShopManager.CheckSubscriptionCanClaimByType(shopSubscriptType)
    local configList = this.FindSubscription(shopSubscriptType)

    if configList == nil then
        return false, false, nil, nil
    end

    local purchased, canClaimed, packageId = this.CheckSubscriptionCanClaim(configList)
    return purchased, canClaimed, packageId, configList
end

---检查订阅是否已购买，是否可领取, 对应的packageId
---@return boolean, boolean, number
function ShopManager.CheckSubscriptionCanClaim(configList)
    local now = TimeModule.getServerTime()
    --检查是否购买
    local purchased, packageId = ShopManager.GetGroupIncludePurchased(configList, now)
    --检查是否已领
    local dailyName = PaymentManager.GetDailyNameByPackageId(packageId)
    local count = DailyBagManager.GetItem(dailyName, now)

    return purchased, count > 0, packageId
end

---检查订阅是否有每日领取
function ShopManager.HasDailyRewardOfSubscription(shopId)
    local package = ConfigManager.GetShopPackage(shopId)
    if package == nil then
        return false
    end
    local dailyReward = Utils.ParseReward(package.reward_daily)
    return #dailyReward > 0
end

function ShopManager.ShowErrCode(errCode)
    if errCode == PaymentManager.ErrCode.UserCancel then
        -- GameToast.Instance:Show(GetLang("toast_purchase_cancel"))
    elseif errCode == 20001 then
        -- GameToast.Instance:Show(GetLang("toast_order_not_found"), ToastIconType.Warning)
        UIUtil.showText(GetLang("toast_order_not_found"))
    elseif errCode == PaymentManager.ErrCode.OrderInProgress then
        -- GameToast.Instance:Show(GetLang("toast_order_in_progress"), ToastIconType.Warning)
        UIUtil.showText(GetLang("toast_order_in_progress"))
    elseif errCode == PaymentManager.ErrCode.RequestFailed then
        -- GameToast.Instance:Show(GetLang("toast_request_failed"), ToastIconType.Warning)
        UIUtil.showText(GetLang("toast_request_failed"))
    else
        -- GameToast.Instance:Show(GetLang("toast_purchase_failed_error_code_" .. errCode), ToastIconType.Warning)
        UIUtil.showText(GetLang("toast_purchase_failed_error_code_" .. errCode))
    end
end

-- 临时控制广告是否显示
---@param config Shop
---@param package ShopPackage
function ShopManager.CheckADSwitch(config, package)
    local adsSwitch = ConfigManager.GetMiscConfig("ads_switch")

    if PaymentManager.IsAd(package) or config.sub_type == this.SubscriptionType.AD then
        return adsSwitch
    end

    return true
end

---@param configList Shop[]
---@return Shop
function ShopManager.GetLastAvailableConfigByGroup(cityId, configList)
    table.sort(
        configList,
        function(a, b)
            return a.sort > b.sort
        end
    )

    for i = 1, #configList do
        if ShopManager.CheckItem(cityId, configList[i].id, ShopManager.Action.Show) then
            return configList[i]
        end

        ---- 如果item不可用，检查是否是数量不足，如果是数量不足，那么直接返回空
        --if not this.CheckCount(configList[i].condition_count, this.GetShopItemCount(configList[i].id)) then
        --    return nil
        --end
    end

    return nil
end

---根据unlock获取当前可用的shop config
---@return Shop
function ShopManager.GetAvailableShopConfigByUnlock(cityId, unlock, condition)
    local shopConfig
    for k, v in pairs(ConfigManager.GetAllShop()) do
        if v.condition_functions_unlock == unlock then
            if this.CheckItem(cityId, k, this.Action.Show) then
                if condition(v) and (shopConfig == nil or shopConfig.sort < v.sort) then
                    shopConfig = v
                end
            end
        end
    end

    return shopConfig
end

function ShopManager.AddListener()
    MailManager.AddEventListener(MailEventName.PendingSubscription, this.OnPendingSubscriptionFunc)
    EventManager.AddListener(EventType.FUNCTIONS_UNLOCK, this.OnFunctionUnlock)
    EventManager.AddListener(EventType.FUNCTIONS_UNLOCK, this.UpdateNewShopItemsCount)
    EventManager.AddListener(EventType.UPGRADE_ZONE_BEGIN, this.UpdateNewShopItemsCount)
    EventManager.AddListener(EventType.SHOP_COOL_DOWN, this.UpdateNewShopItemsCount)
end

---@param config Shop
function ShopManager.IsPopupItem(config)
    return config.type == ShopManager.ShopItemType.Special
end

function ShopManager.HasPopupItem()
    return this.popupData ~= nil
end

---@param cityId number
---@param config Shop
function ShopManager.AddPopupItemToQueue(cityId, config)
    local package = this.GetPackageByShopId(config.id)

    if this.HasPopupItem() then
        -- 检查当前shop item是否同组
        if
            not (
                this.popupData.config.group ~= 0 and
                this.popupData.config.group == config.group and
                this.popupData.config.sort < config.sort
            )
        then
            return
        end
    end

    this.popupData = {
        config = config,
        package = package,
        cityId = cityId
    }
end

function ShopManager.ShowAndClearPopupItemQueue()
    if not this.HasPopupItem() then
        return
    end

    if GameManager.TutorialOpen then
        this.ClearPopupItem()
        return
    end

    local cityId, config, package = this.popupData.cityId, this.popupData.config, this.popupData.package
    PopupManager.Instance:LastOpenPanel(
        PanelType.ShopPopupPanel,
        {
            shopPanelItemData = {
                config = config,
                package = package,
                configList = { config },
                packageList = { package },
                onBuyButtonClick = function(cfg, cb)
                    this.BuyWithDiamondConfirm(
                        cityId,
                        cfg,
                        function(rewards)
                            if #rewards > 0 then
                                ResAddEffectManager.AddResEffectFromRewards(
                                    rewards,
                                    true,
                                    { hideFlying = true, isShop = false, eventSign = { shopId = cfg.id } }
                                )
                            end

                            if cb ~= nil then
                                cb()
                            end
                        end
                    )
                end
            },
            onClose = function()
                this.ClearPopupItem()
            end
        }
    )
end

function ShopManager.ClearPopupItem()
    this.popupData = nil
end

function ShopManager.OnPendingSubscriptionFunc()
    Log("call PendingSubscription")
    PaymentManager.GetPendingBillList()
end

function ShopManager.OnFunctionUnlock(unlock)
    if this.hasPopup == true then
        return
    end

    local cityId = DataManager.GetCityId()

    local config =
        this.GetAvailableShopConfigByUnlock(
            cityId,
            unlock,
            function(cfg)
                return this.IsPopupItem(cfg)
            end
        )
    if config == nil then
        return
    end

    this.AddPopupItemToQueue(cityId, config)

    if this.inInitial ~= true then
        this.ShowAndClearPopupItemQueue()
    end
end

---返回当前是否有免广告
function ShopManager.IsFreeAd()
    local isFreeAd = false

    local time = ShopManager.GetNow()
    local list = PaymentManager.GetAllValidSubscription(time)
    for i, v in ipairs(list) do
        if (v.packageId == 202 or v.packageId == 203) and v.expireTS > time.ts then
            isFreeAd = DailyBagManager.GetItem(ItemType.ADTicket, GameManager.GameTime()) > 0
        end
    end
    return isFreeAd
end

---返回在冷却中，并且距离结束最短的shop config
---@param cityId number
---@param now Time2
---@return Shop, number
function ShopManager.GetMinCooldownConfig(cityId, now)
    local configCD = nil
    local preCD = MathUtil.maxinteger
    for k, v in pairs(ConfigManager.GetAllShop()) do
        local reason = ""
        local show =
            this.CheckItem(
                cityId,
                k,
                this.Action.Buy,
                function(r)
                    reason = r
                end
            )

        if not show and reason == "cd" and this.HasCD(v.condition_claim_cd) then
            -- 如果不能buy的原因是cd
            local cd = this.GetShopItemRemainTime(v, now)
            if cd < preCD then
                preCD = cd
                configCD = v
            end
        end
    end

    return configCD, preCD
end

---@param cityId number
---@param now Time2
function ShopManager.UpdateCooldownEvent()
    local cityId = DataManager.GetCityId()
    local now = Time2:New(GameManager.GameTime())

    if this.nextCooldownTimeoutId ~= nil then
        return
    end

    local config, cd = this.GetMinCooldownConfig(cityId, now)
    if config == nil then
        return
    end

    Log("shop cd min:" .. cd .. " config: " .. JSON.encode(config))

    cd = cd + 1 -- 加一秒，避免极限情况下，同一个物品连续刷新

    -- 最多5秒触发一次
    if cd <= 5 then
        cd = 5
    end

    Log("update cool down, id:" .. config.id .. ", cd: " .. Utils.GetTimeFormat4(cd))

    this.nextCooldownTimeoutId =
        setTimeout(
            function()
                this.nextCooldownTimeoutId = nil
                EventManager.Brocast(EventType.SHOP_COOL_DOWN, config.id)
                this.UpdateCooldownEvent()
            end,
            cd * 1000
        )
end

---金爷爷专用，返回是否购买
function ShopManager.HasBuyZone(zoneId)
    local shopDisplay = ConfigManager.GetShopSceneDisplayByZoneId(zoneId)
    if shopDisplay == nil then
        return false
    end

    local shopPackage = ShopManager.GetPackageByShopId(shopDisplay.id)
    if shopPackage == nil then
        return false
    end

    local hasBoost = 0
    local boostCount = 0
    local rewards = Utils.ParseReward(shopPackage.reward)
    for i = 1, #rewards do
        if rewards[i].addType == RewardAddType.Boost then
            boostCount = boostCount + 1
            if BoostManager.HasBoost(DataManager.GetCityId(), rewards[i].id) then
                hasBoost = hasBoost + 1
            end
        end
    end

    return hasBoost >= boostCount
end

--切换登录 清空
function ShopManager.Clear()
    this.inInitial = nil
    this.initialized = nil

    EventManager.RemoveListener(EventType.FUNCTIONS_UNLOCK, this.OnFunctionUnlock)
    EventManager.RemoveListener(EventType.FUNCTIONS_UNLOCK, this.UpdateNewShopItemsCount)
    EventManager.RemoveListener(EventType.UPGRADE_ZONE_BEGIN, this.UpdateNewShopItemsCount)
    EventManager.RemoveListener(EventType.SHOP_COOL_DOWN, this.UpdateNewShopItemsCount)
    MailManager.RemoveEventListener(MailEventName.PendingSubscription, this.OnPendingSubscriptionFunc)
    DailyShoutManager.Unregister(ShopManager.ShopManagerRefreshShop)

    if this.nextCooldownTimeoutId ~= nil then
        clearTimeout(this.nextCooldownTimeoutId)
        this.nextCooldownTimeoutId = nil
    end
end

function ShopManager.GetUserPayAmount(day, now)
    local time = now:Timestamp() - day * Time2.Day
    local amount = 0

    if true then
        return amount
    end

    for k, v in pairs(PaymentManager.GetLog()) do
        local data = PaymentManager.UnpackUUID(k)
        if data ~= nil then
            if time < data.createTime then
                local config = this.GetShopConfig(data.packageId)
                if config ~= nil and config.type ~= ShopManager.ShopItemType.Subscription then
                    local package = this.GetPackageByShopId(data.packageId)
                    local iapConfig = ConfigManager.GetIAPConfig(package.product_id)

                    amount = amount + iapConfig.price
                end
            end
        end
    end

    -- 遍历订阅
    for _, v in pairs(PaymentManager.GetSubscriptionData()) do
        for _, sub in ipairs(v) do
            if time < sub.createTS then
                local config = this.GetShopConfig(sub.packageId)
                if config ~= nil and config.type == ShopManager.ShopItemType.Subscription then
                    local package = this.GetPackageByShopId(sub.packageId)
                    local iapConfig = ConfigManager.GetIAPConfig(package.product_id)

                    amount = amount + iapConfig.price
                end
            end
        end
    end

    return amount
end

---当购买特殊物品后，要聚焦某些场景建筑
function ShopManager.LookUpZoneByShopId(shopId, panelTransform)
    if shopId == nil then
        return
    end

    local sceneDisplay = ConfigManager.GetShopSceneDisplay(shopId)
    if sceneDisplay == nil then
        return
    end

    local mapItem = Map.Instance:GetMapItemByZoneId(sceneDisplay.display.zoneId)
    local focusPos = Utils.GetCamera():WorldToScreenPoint(panelTransform.position)
    focusPos = Vector2(focusPos.x, focusPos.y)

    Map.Instance:FocusPos(focusPos, mapItem:GetTipPoint(), 20)

    setTimeout(
        function()
            -- todo：这里直接调用独有的函数，以后应该使用一个基类函数，目前只有golden grandpa建筑
            mapItem:ActiveEffect(true)
        end,
        300
    )
end

-- 检查限购数：为0不显示
function ShopManager.CheckLimitCount(city_id, configList)
    local config = ShopManager.GetLastAvailableConfigByGroup(city_id, configList)
    local count = ShopManager.GetShopItemRemainCount(config.id)
    return count > 0
end
