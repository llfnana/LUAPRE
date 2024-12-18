DissolveCardManager = {}
DissolveCardManager.__cname = "DissolveCardManager"

local this = DissolveCardManager

---@class DissolveShopItemData
---@field id number
---@field count number
---@field lastRefreshTS number

---@class DissolveShopData
---@field auto boolean
---@field items DissolveShopItemData[]

DissolveCardManager.ItemRefreshType = {
    None = "none",
    Special = "special",
    Day = "day",
    Week = "week",
    Month = "month"
}

function DissolveCardManager.Init()
    if this.initialized then
        return
    end

    this.initialized = true

    ---@type DissolveShopData
    this.shopDailyData =
        DataManager.GetGlobalDataByKey(DataKey.ShopDaily) or
        {
            auto = false,
            items = {}
        }

    this.shopDailyConfig = ConfigManager.GetShopDailyByType(ConfigManager.ShopDailyType.dissolve)
    this.UpdateShopItems()

    this.InitRefreshShop(DissolveCardManager.GetNow())
end

function DissolveCardManager.InitRefreshShop(now)
    local delay = this.GetLastRefreshTime(now) * 1000
    if delay <= 0 then
        return
    end

    setTimeout(this.RefreshShop, delay)
end

function DissolveCardManager.RefreshShop()
    this.UpdateShopItems()
    EventManager.Brocast(EventType.SHOP_DAILY_REFRESH)

    this.InitRefreshShop(DissolveCardManager.GetNow())
end

---返回每日商店的config，类型是Dictionary
---@return table
function DissolveCardManager.GetShopDailyConfig()
    return this.shopDailyConfig
end

---返回分解卡牌商店中items列表
---@return DissolveShopItemData[]
function DissolveCardManager.GetShopItems()
    return this.shopDailyData.items
end

---返回是否自动分解card
---@return boolean
function DissolveCardManager.GetAutoState()
    return this.shopDailyData.auto
end

---设置自动分解
function DissolveCardManager.SetAutoState(state)
    this.shopDailyData.auto = state
end

function DissolveCardManager.SaveData()
    DataManager.SetGlobalDataByKey(DataKey.ShopDaily, this.shopDailyData)
end

---刷新商店item，对商店任何操作之前都要调用这个函数，确保item状态真实可用
function DissolveCardManager.UpdateShopItems()
    local now = this.GetNow()
    ---@type DissolveShopItemData[]
    local newItems = {}

    --遍历config中所有item
    this.GetShopDailyConfig():ForEach(
        function(cfg)
            local item = this.GetShopItemData(cfg.id)
            if item == nil then
                --item不存在，那么创建他
                item = {
                    id = cfg.id,
                    count = cfg.limit,
                    lastRefreshTS = 0
                }
            end

            local lastRefreshTime = Time2:New(item.lastRefreshTS)

            local reset, available = this.CheckShopItemTime(lastRefreshTime, now, cfg)
            if reset then
                item.count = cfg.limit
                item.lastRefreshTS = now:Timestamp()
            end

            if available then
                table.insert(newItems, item)
            end
        end
    )

    ---@param left DissolveShopItemData
    ---@param right DissolveShopItemData
    table.sort(
        newItems,
        function(left, right)
            return this.GetShopItemConfig(left.id).sort < this.GetShopItemConfig(right.id).sort
        end
    )

    -- replace items
    this.shopDailyData.items = newItems
    this.SaveData()
    return true
end

function DissolveCardManager.OnAddCard(reward)
    if #reward > 0 then
        for ix, value in pairs(reward) do
            this.AddReward(cityId, value, from, fromId)
        end
        return
    end

    if reward.addType == "addToCard" then
    end
end

---@param itemId number
---@return DissolveShopItemData
function DissolveCardManager.GetShopItemData(itemId)
    for i = 1, #this.shopDailyData.items do
        if this.shopDailyData.items[i].id == itemId then
            return this.shopDailyData.items[i]
        end
    end

    return nil
end

---@param itemId number
---@return ShopDaily
function DissolveCardManager.GetShopItemConfig(itemId)
    local rt, val = this.shopDailyConfig:TryGetValue(itemId)
    if rt then
        return val
    end

    return nil
end

---返回是否需要重置和是否可用
---@param preTime Time2
---@param now Time2
---@param config
---@return boolean, boolean
function DissolveCardManager.CheckShopItemTime(preTime, now, config)
    local startTime = 0
    local endTime = MathUtil.maxinteger

    if config.refresh == DissolveCardManager.ItemRefreshType.Special then
        startTime = config.startTime
        endTime = config.endTime
    elseif config.refresh == DissolveCardManager.ItemRefreshType.Day then
        startTime = now:GetToday()
        endTime = startTime + Time2.Day
    elseif config.refresh == DissolveCardManager.ItemRefreshType.Week then
        startTime = now:GetMonday()
        endTime = startTime + Time2.Week
    elseif config.refresh == DissolveCardManager.ItemRefreshType.Month then
        startTime = now:GetMonthFirstDay()
        endTime = now:GetMonthLastDay()
    end

    --只有在preTime不在时间段内，并且now在时间段内时刷新
    local a = preTime:Timestamp() < startTime
    local b = now:Timestamp() >= startTime and now:Timestamp() < endTime
    return a and b, b
end

---确认item当前时间可购买
---@field itemId number
---@field now Time2
---@return boolean
function DissolveCardManager.InAvailableTimeShopItem(itemId, now)
    local data = this.GetShopItemData(itemId)
    local cfg = this.GetShopItemConfig(itemId)

    if data == nil or cfg == nil then
        return false
    end

    local reset, available = this.CheckShopItemTime(Time2:New(data.lastRefreshTS), now, cfg)
    return available
end

---返回最近的一个项目的刷新时间
---@param now Time2
---@return number
function DissolveCardManager.GetLastRefreshTime(now)
    local lastTS = now:Timestamp() -- MathUtil.maxinteger

    for i = 1, #this.shopDailyData.items do
        local cfg = this.GetShopItemConfig(this.shopDailyData.items[i].id)
        local lt = now:Timestamp()  --MathUtil.maxinteger
        if cfg.refresh == DissolveCardManager.ItemRefreshType.Special then
            lt = cfg.endTime - now:Timestamp()
        elseif cfg.refresh == DissolveCardManager.ItemRefreshType.Day then
            --今天24点
            lt = now:GetToday() + Time2.Day - now:Timestamp()
        elseif cfg.refresh == DissolveCardManager.ItemRefreshType.Week then
            --本周日24点
            lt = now:GetMonday() + Time2.Week - now:Timestamp()
        elseif cfg.refresh == DissolveCardManager.ItemRefreshType.Month then
            lt = now:GetMonthLastDay() - now:Timestamp()
        end

        if lt < lastTS then
            lastTS = lt
        end
    end

    return lastTS
end

---返回下一个刷新时间，仅用于窗口倒计时
---@param now Time2
---@return number
function DissolveCardManager.GetNextRefreshTime(now)
    -- 由于每一个item都有自己的刷新时间，所以只获取第一个刷新时间为special的item的结束时间
    for i = 1, #this.shopDailyData.items do
        local cfg = this.GetShopItemConfig(this.shopDailyData.items[i].id)
        if cfg.refresh == DissolveCardManager.ItemRefreshType.Special then
            return cfg.endTime - now:Timestamp()
        end
    end

    -- 如果没找到
    return 0
end

---@param now Time2
---@return number
function DissolveCardManager.GetRefreshTime(refreshType, now)
    -- none 和special 没有刷新时间
    if refreshType == DissolveCardManager.ItemRefreshType.Day then
        return now:GetToday() + Time2.Day - now:Timestamp()
    elseif refreshType == DissolveCardManager.ItemRefreshType.Week then
        return now:GetMonday() + Time2.Week - now:Timestamp()
    elseif refreshType == DissolveCardManager.ItemRefreshType.Month then
        return now:GetMonthLastDay() - now:Timestamp()
    else
        return 0
    end
end

---@field cards Dictionary
---@return table
function DissolveCardManager.DissolveCard(cards)
    local totalHeroCoin = 0
    local available = true
    local heroCoinMap = {}
    cards:ForEachKeyValue(
        function(cardId, cardCount)
            local cfg = CardManager.GetCardItemData(cardId):GetConfig()
            if cfg == nil then
                print("[error]" .. "not found card config, cardId: " .. cardId)
                available = false
                return true
            end

            local dissolveHeroCoin = 0
            -- 目前只能分解HeroCoin,并且HeroCoin这个名字并没有最后确定，所以这里把map里的所有数都加起来
            for _, c in pairs(cfg.dissolve) do
                dissolveHeroCoin = dissolveHeroCoin + c
            end

            totalHeroCoin = totalHeroCoin + dissolveHeroCoin * cardCount
            heroCoinMap[cardId] = dissolveHeroCoin * cardCount

            if CardManager.GetCardCount(cardId) < cardCount then
                print("[error]" .. "dissolve shop item not enough, itemId: " .. cardId)
                available = false
                return true
            end
        end
    )

    if not available then
        return
    end

    local biCards = {}
    -- 扣卡
    cards:ForEachKeyValue(
        function(k, v)
            CardManager.UseCard(k, v, "CardDissolve", k)
            table.insert(
                biCards,
                {
                    id = k,
                    count = v
                }
            )
        end
    )
    -- 给币
    for k, v in pairs(heroCoinMap) do
        DataManager.AddMaterial(DataManager.GetCityId(), ItemType.HeroCoin, v, "CardDissolve", k)
    end

    Analytics.Event(
        "CardDissolveSuccess",
        {
            dissolveCards = biCards,
            heroCoinCount = totalHeroCoin
        }
    )

    -- 返回reward数组
    return {
        {
            addType = RewardAddType.Item,
            id = ItemType.HeroCoin,
            count = totalHeroCoin
        }
    }
end

---获得item的价格
function DissolveCardManager.GetShopItemHeroCoinForPurchase(itemId)
    return this.GetShopItemConfig(itemId).cost["HeroCoin"]
end

---获得item的奖励
function DissolveCardManager.GetShopItemReward(itemId)
    return Utils.ParseReward(this.GetShopItemConfig(itemId).reward)
end

---检查item是否有足够的币购买
function DissolveCardManager.IsEnoughForPurchaseShopItem(itemId, count)
    local total = this.GetShopItemHeroCoinForPurchase(itemId) * count
    local own = this.GetOwnHeroCoin()
    return own >= total
end

function DissolveCardManager.GetOwnHeroCoin()
    return DataManager.GetMaterialCount(DataManager.GetCityId(), ItemType.HeroCoin)
end

---检查卡牌是否可分解
function DissolveCardManager.IsCanDissolve(cardId)
    local item = CardManager.GetCardItemData(cardId)
    local maxStar = ConfigManager.GetCardMaxStarRank(item:GetConfig())
    -- 字段为空，或者卡牌没有满星都不能分解
    return Utils.GetTableLength(item:GetConfig().dissolve) > 0 and maxStar == item:GetStar() and item:GetCardCount() > 0
end

---购买定时商品
function DissolveCardManager.PurchaseShopItem(itemId, count, now)
    -- 币够不够
    if not this.IsEnoughForPurchaseShopItem(itemId, count) then
        return 1
    end

    -- 时间对不对
    if not this.InAvailableTimeShopItem(itemId, now) then
        return 2
    end

    -- 存货够不够
    local data = this.GetShopItemData(itemId)
    if data.count < count then
        return 3
    end

    local totalHeroCoin = this.GetShopItemHeroCoinForPurchase(itemId) * count

    DataManager.UseMaterial(DataManager.GetCityId(), ItemType.HeroCoin, totalHeroCoin, "CardDissolve", itemId)
    local reward = this.GetShopItemReward(itemId)

    local rewards = {}
    for i = 1, count do
        local rt = DataManager.AddReward(DataManager.GetCityId(), reward, "CardDissolve", itemId)
        Utils.MergeRewards(rt, rewards)
    end

    -- 修改数据并保存
    data.count = data.count - count
    this.SaveData()

    Analytics.Event(
        "CardDissolveBuy",
        {
            reward = Utils.BIConvertRewards(rewards),
            heroCoinCost = totalHeroCoin
        }
    )

    return 0, rewards
end

function DissolveCardManager.GetShopItemLang(shopConfig)
    local lang = ""

    if shopConfig.refresh == DissolveCardManager.ItemRefreshType.Day then
        lang = "card_dissolve_refresh_day"
    elseif shopConfig.refresh == DissolveCardManager.ItemRefreshType.Week then
        lang = "card_dissolve_refresh_week"
    elseif shopConfig.refresh == DissolveCardManager.ItemRefreshType.Month then
        lang = "card_dissolve_refresh_month"
    else
        lang = "card_dissolve_refresh_never"
    end

    return lang
end

---返回now，方便修改测试
function DissolveCardManager.GetNow()
    -- 增加一个时间偏移
    --if this.offset == nil then
    --    --1分钟后刷新
    --    local refreshTime = Time2.Minute
    --    this.offset = this.GetNextRefreshTime(Time2:New(GameManager.GameTime())) - refreshTime
    --end
    return Time2:New(GameManager.GameTime() + (this.offset or 0))
end

--切换帐号重置数据
function DissolveCardManager.Reset()
    this.initialized = nil
end
