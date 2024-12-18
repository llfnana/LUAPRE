PaymentManager = {}
PaymentManager.__cname = "PaymentManager"
local this = PaymentManager


PaymentManager.HistoryDuration = 30 * Time2.Day

---@class PaymentItemData
---@field id number
---@field count number
---@field totalCount number
---@field lastRefreshTS number
---@field lastClaimedTS number
---@field eventId number

---@class PaymentData
---@field count number
---@field priceCount number
---@field log table<string, number>
---@field items table<number, number>  记录packageId购买次数
---@field subscriptions table<string, PaymentSubscriptionData[]> 订阅数据，记录productId对应的到期时间

---@class PaymentSubscriptionData
---@field packageId string
---@field uuid string
---@field createTS number       订单创建时间，服务器返回
---@field expireTS number    服务器返回的到期时间

---@class PaymentUUIDData
---@field uid number
---@field createTime number
---@field shortUUID string
---@field packageId number

PaymentManager.ErrCode = {
    InitFailed = 3100, -- 一般是没有google套装
    UserCancel = 3104,
    OrderInProgress = 20002,
    RequestFailed = 30001,
    CostNotEnough = 90001,
    AdNotReady = 90002,
    AdErrorNotLoaded = 90003,
    AdErrorNoReward = 90004,
    AdErrorOnAdFailedToShow = 90005
}

PaymentManager.PackageType = {
    Normal = "",
    Subscription = "subscription"
}

PaymentManager.ExtendedCostType = {
    AD = "ad",
    Discord = "discord",
    Facebook = "facebook"
}

PaymentManager.TagType = {
    Pay7 = "pay7",
    Pay60 = "pay60"
}

PaymentManagerDoubleName = "double"

PaymentManager.DailyName = "PaymentDaily"

function PaymentManager.AddEvent()
    this.productInfo = {}
    local productIds = ConfigManager.GetIAPProductIds()
    this.isInitSDK = false
    --    PaymentSDK.Instance:Init(
    --        productIds,
    --        function(method, ret)
    --            this.OnPaymentCallback(method, ret)
    --        end
    --    )

    EventManager.AddListener(EventDefine.OnChargeSuccess, function(info)
        this.ConfirmBill("", info.a.order.back.shopid)
        if this.cb ~= nil then
            local rewards = Utils.ParseReward(info.a.order.back.rewards)
            this.cb(rewards, 0)
            this.cb = nil
        end
    end)
    EventManager.AddListener(EventDefine.OnChargeFail, function(info)
        UIUtil.hideWaitTip()
        UIUtil.showText(GetLang("toast_purchase_cancel"))
    end)
end

function PaymentManager.Init()
    if this.initialized == nil then
        this.initialized = true
        this.isPaymenting = false
        this.paymentTimeId = nil
        this.InitData()
        -- this.InitSubscription()
        if this.isInitSDK == true then
            setTimeout(
                function()
                    this.GetPendingBillList()
                end,
                8000
            )
        end
    end
end

---@return PaymentData
function PaymentManager.NewData()
    return {
        priceCount = 0,
        count = 0,
        log = {},
        items = {},
        subscriptions = {}
    }
end

function PaymentManager.InitData()
    this.data = this.NewData()

    local data = DataManager.GetGlobalDataByKey(DataKey.Pay)
    for k, v in pairs(data) do
        this.data[k] = v
    end
end

function PaymentManager.ClearData()
    this.data = this.NewData()
    this.SaveData()
    this.ClearAllSubscriptionDailyShout()
end

---初始化已购买的订阅
function PaymentManager.InitSubscription()
    this.subscriptionDailyShoutList = {}
    local now = Time2:New(GameManager.GameTime())
    local subscriptions = this.GetAllValidSubscription(now)
    for i = 1, #subscriptions do
        local sub = subscriptions[i]
        Log("subscription: " .. JSON.encode(sub))

        -- 有每日手动领取的订阅才注册
        local dailyName = this.AppendSubscriptionDailyShout(sub)
        table.insert(this.subscriptionDailyShoutList, dailyName)
    end

    -- 用于每日更新boost效果
    local boostDailyName = "PaymentManagerRefreshSubscriptionBoost"
    DailyShoutManager.Register(
        boostDailyName,
        function(now)
            -- do set boost
            BoostManager.RefreshSubscriptionBoost(DataManager.GetCityId())
        end,
        -1,
        true,
        DailyShoutManager.Priority.Normal
    )

    table.insert(this.subscriptionDailyShoutList, boostDailyName)

    BoostManager.RefreshSubscriptionBoost(DataManager.GetCityId())
end

---@param subData PaymentSubscriptionData
---@return string
function PaymentManager.AppendSubscriptionDailyShout(subData)
    -- 生成这个package对应的每日背包key
    local dailyName = this.GetDailyNameByPackageId(subData.packageId)
    local package = ConfigManager.GetShopPackage(subData.packageId)
    local reward_daily_auto = Utils.ParseReward(package.reward_daily_auto)
    local reward_daily = Utils.ParseReward(package.reward_daily)

    DailyShoutManager.Register(
        dailyName,
        function(now)
            -- 注册dailyReward，每天领1，一键领取在每日背包中生成一个package key，然后依据这个key领取每日奖励
            if #reward_daily > 0 then
                Log("PaymentDailyShout: " .. dailyName .. ", reward(claim): " .. package.reward_daily)
                DailyBagManager.SetItem(dailyName, 1, now:Timestamp())
            end

            -- 每天自动领取
            if #reward_daily_auto > 0 then
                Log("PaymentDailyShout: " .. dailyName .. ", reward(auto): " .. package.reward_daily_auto)
                DataManager.AddReward(DataManager.GetCityId(), reward_daily_auto, "shop", subData.packageId)
            end
        end,
        subData.expireTS,
        true,
        DailyShoutManager.Priority.Urgent
    )
end

function PaymentManager.ClearAllSubscriptionDailyShout()
    for i = 1, #this.subscriptionDailyShoutList do
        DailyShoutManager.Unregister(this.subscriptionDailyShoutList[i])
    end
end

function PaymentManager.GetDailyNameByPackageId(packageId)
    return this.DailyName .. "_" .. packageId
end

---生成uuid，包含packageId
---需要传递packageId，然后在回调中解析出来
function PaymentManager.BuildUUID(packageId)
    return DataManager.uid .. "-" .. os.time() .. "-" .. Utils.GetShortUUID() .. "-" .. packageId
end

---解uuid
---@return PaymentUUIDData
function PaymentManager.UnpackUUID(uuid)
    local s = string.split(uuid, "-")
    if #s == 4 then
        return {
            uid = tonumber(s[1]),
            createTime = tonumber(s[2]),
            shortUUID = s[3],
            packageId = tonumber(s[4])
        }
    end

    return nil
end

function PaymentManager.ParsePackageIdFromUUID(uuid)
    local data = string.split(uuid, "-")

    if #data == 4 then
        return tonumber(data[4])
    end

    return nil
end

---通过productId获取packageId，只有订阅，packageId和productId是一一对应的，其他类型是一对多
---@param productId string
---@return ShopPackage
function PaymentManager.GetPackageByProductId(productId)
    local packageMap = ConfigManager.GetAllShopPackage()

    for _, package in pairs(packageMap) do
        if package.product_id == productId and package.type == PaymentManager.PackageType.Subscription then
            return package
        end
    end

    return nil
end

--购买
function PaymentManager.Buy(packageId, cb)
    local package = ConfigManager.GetShopPackage(packageId)

    this.SetPurchaseCB(cb)
    if this.IsPurchase(package) then
        --现金
        this.Purchase(package)
    elseif this.IsAd(package) then
        -- 广告次数限制
        if AdManager.CheckMaxWatch() then 
            return
        end

        AdManager.AddCount(AdSourceType.UIShopBox)
        -- 广告
        this.AdExchange(package)
    else
        --资源交换
        this.Exchange(package)
    end
end

---@param package ShopPackage
function PaymentManager.AdExchange(package)
    UIUtil.hideWaitTip()
    -- TODO zhkxin
    if ShopManager.IsFreeAd() then
        this.OnConfirmBillResp("", package.id, 0, 0, false)
    else 
        AdManager.Show(function()
            this.OnConfirmBillResp("", package.id, 0, 0, false)
        end)
    end

    -- UIUtil.showText(GetLang("toast_purchase_failed_error_code_90002"))
end

---@param package ShopPackage
function PaymentManager.Exchange(package)
    if not this.Cost(package) then
        this.CallPurchaseCB(nil, PaymentManager.ErrCode.CostNotEnough)
        return
    end

    -- package是一个非付费项目，所以传空
    this.OnConfirmBillResp("", package.id, 0, 0, false)
end

---@param package ShopPackage
function PaymentManager.Purchase(package)
    local productId = package.product_id
    local iapConfig = ConfigManager.GetIAPConfig(productId)

    local uuid = this.BuildUUID(package.id)
    -- local throughCargoStr = this.ThroughCargoEncode(DataManager.uid, uuid, package.id)
    GameManager.DontReload = true
    this.isPaymenting = true

    -- PaymentManager.ConfirmBill(uuid, package.id)
    --直接加道具
    ---TODO SDK
    -- PaymentSDK.Instance:Buy(productId, throughCargoStr)
    local charge = PlayerCharge.New()
    charge:goCharge(package.id, productId, iapConfig.name, 1, iapConfig.price, "CNY", nil)

    -- BI event
    this.Analytics(
        "ShopIAPPurchaseStart",
        package,
        {
            reward = Utils.BIConvertRewards(Utils.ParseReward(package.reward, true))
        }
    )
end

---编译ThroughCargo
function PaymentManager.ThroughCargoEncode(uid, uuid, packageId)
    local throughCargo = { uid = tostring(uid), uuid = uuid, packageId = packageId }
    local tStr = JSON.encode(throughCargo)
    return Base64.encode(tStr)
end

---解析ThroughCargo
function PaymentManager.ThroughCargoDecode(throughCargo)
    local s = Base64.decode(throughCargo)
    return JSON.decode(s)
end

--是否初始化支付完成
function PaymentManager.CanMakePurchases()
    return PaymentSDK.Instance:CanMakePurchases()
end

--兑换货币价格
function PaymentManager.GetPriceStr(productId)
    if this.productInfo[productId] ~= nil and not GameManager.isEditor then
        return this.productInfo[productId].FormattedPrice
    else
        local iapConfig = ConfigManager.GetIAPConfig(productId)

        if iapConfig == nil then
            return "￥"
        end

        return "￥" .. iapConfig.price
    end
end

--支付回调
function PaymentManager.OnPaymentCallback(method, jsonStr)
    Log("PaymentManager.OnPaymentCallback: " .. method .. "@" .. jsonStr)
    this.isPaymenting = false
    clearTimeout(this.paymentTimeId)
    if method == "OnPurchaseSuccess" then
        local json = JSON.decode(jsonStr)
        local throughCargo = this.ThroughCargoDecode(json.throughCargo)
        this.ConfirmBill(throughCargo.uuid, throughCargo.packageId)
        NetManager.SendQueue()
    elseif method == "OnPurchaseError" then
        local json = JSON.decode(jsonStr)
        local errCode = json.errorCode
        local productId = nil
        local uuid = nil
        local sdk_uuid = nil
        local transaction_id = nil
        local network_time_ms = 0
        local cg_request_id = nil
        local reason = nil

        if json.extra ~= nil then
            local extra = JSON.decode(json.extra)
            if extra ~= nil and extra.network_time_ms ~= nil then
                network_time_ms = extra.network_time_ms
            end
            if extra ~= nil and extra.reason ~= nil then
                reason = extra.reason
            end
            if extra ~= nil and extra.data ~= nil then
                sdk_uuid = extra.data.uuid
                transaction_id = extra.data.transaction_id
                cg_request_id = extra.data.cg_request_id
            end
        end

        if json.paymentError ~= nil then
            local paymentError = JSON.decode(json.paymentError)
            productId = paymentError.productId

            if productId ~= nil then
                local package = this.GetPackageByProductId(productId)
                if package ~= nil then
                    --BI
                    this.Analytics(
                        "ShopIAPPurchaseFailed",
                        package,
                        {
                            reward = Utils.BIConvertRewards(Utils.ParseReward(package.reward, true)),
                            reason = reason,
                            errCode = errCode
                        }
                    )
                end
            end

            if paymentError.ErrorThroughCargo ~= nil and paymentError.ErrorThroughCargo ~= "" then
                local throughCargoStr = Base64.decode(paymentError.ErrorThroughCargo)

                if throughCargoStr ~= nil then
                    local throughCargo = JSON.decode(throughCargoStr)

                    if throughCargo ~= nil then
                        uuid = throughCargo.uuid
                    end
                end
            end
        end

        if this.cb ~= nil then
            this.cb(productId, errCode)
            this.cb = nil
        end
        local errObj = {
            pay_errorCode = errCode,
            productId = productId,
            pay_uuid = uuid,
            pay_sdk_uuid = sdk_uuid,
            pay_transaction_id = transaction_id,
            pay_network_time_ms = network_time_ms,
            pay_cg_request_id = cg_request_id,
            pay_reason = reason
        }
        Analytics.Error("PaymentBuyError", errObj)
    elseif method == "OnInitializeError" then
        local json = JSON.decode(jsonStr)
        local errCode = json.errorCode
        local errObj = {
            pay_errorCode = errCode
        }
        Analytics.Error("PaymentInitError", errObj)
    elseif method == "OnInitializeSuccess" then
        local json = JSON.decode(jsonStr)
        for index, product in pairs(json) do
            this.productInfo[product.ProductId] = product
        end
        this.isInitSDK = true
    else
        LogWarning("Unknown method: " .. method)
    end
end

--暂停游戏后台恢复
function PaymentManager.OnAppFocus(hasFocus)
    if hasFocus then
        if this.isPaymenting then
            this.isPaymenting = false
            clearTimeout(this.paymentTimeId)
            this.paymentTimeId =
                setTimeout(
                    function()
                        if this.cb ~= nil then
                            this.cb(nil, 3104)
                            this.cb = nil
                        end
                        local errObj = {
                            pay_errorCode = 3104
                        }
                        Analytics.Error("PaymentBuyError", errObj)
                    end,
                    3000
                )
        end
    end
end

---通过package生成假billData，用于在设备上创建假订阅支付
---@param uuid string
---@param packageId number
---@return BillData
function PaymentManager.BuildFakeBillData(uuid, packageId)
    local package = ConfigManager.GetShopPackage(packageId)
    local nowTS = GameManager.GameTime()
    local expire = Time2:New(nowTS + package.duration_in_editor)

    return {
        uuid = uuid,
        product_id = package.product_id,
        create_ts = nowTS,
        expire_milli = expire * 1000,
        through_cargo = this.ThroughCargoEncode(DataManager.uid, uuid, packageId),
        type = PaymentManager.PackageType.Subscription
    }
end

--确认订单
function PaymentManager.ConfirmBill(uuid, packageId)
    -- if this.data.log[uuid] ~= nil then
    --     this.OnConfirmBillErrorResp(packageId, PaymentManager.ErrCode.OrderInProgress)
    --     return
    -- end
    -- if GameManager.isEditor then
    --     this.EditorConfirmBill(uuid, packageId)
    --     return
    -- end
    -- ---@param rep Protocol_ConfirmBillResp
    -- NetManager.ConfirmBill(
    --     uuid,
    --     function(rep, err)

    --     end
    -- )
    local errCode = 0
    -- if rep ~= nil then
    --     Log("pay info: " .. JSON.encode(rep) .. " uuid: " .. uuid .. " packageId: " .. packageId)
    --     errCode = rep.err_code
    -- else
    --     errCode = PaymentManager.ErrCode.RequestFailed
    -- end
    local package = ConfigManager.GetShopPackage(packageId)
    local nowTS = GameManager.GameTime()
    local expire = nowTS + package.duration_in_editor

    if errCode == 0 then
        this.OnConfirmBillResp(
            "",
            packageId,
            nowTS,
            expire,
            false
        )
    else
        this.OnConfirmBillErrorResp(packageId, errCode)

        --BI
        local package = ConfigManager.GetShopPackage(packageId)
        this.Analytics(
            "ShopIAPPurchaseFailed",
            package,
            {
                reward = Utils.BIConvertRewards(Utils.ParseReward(package.reward, true)),
                errCode = errCode
            }
        )
    end
end

function PaymentManager.EditorConfirmBill(uuid, packageId)
    if not GameManager.isDebug then
        return
    end

    local package = ConfigManager.GetShopPackage(packageId)
    local nowTS = GameManager.GameTime()
    local expire = nowTS + package.duration_in_editor
    setTimeout(
        function()
            this.OnConfirmBillResp(uuid, packageId, nowTS, expire, false)
        end,
        2000
    )
end

---确认订单
---@param uuid string
---@param packageId number
---@param createTS number
---@param expireTS number
---@param is_grace_period boolean
function PaymentManager.OnConfirmBillResp(uuid, packageId, createTS, expireTS, is_grace_period)
    local package = ConfigManager.GetShopPackage(packageId)

    print("[确认订单] " .. string.format("uuid = %s, packageId = %s, createTS = %s, expireTS = %s, is_grace_period = %s", uuid or "nil", packageId or "nil", createTS or "nil", expireTS or "nil", is_grace_period or "nil"))

    local rt = {}

    if not (is_grace_period or false) then
        if package.reward ~= "" then
            -- parse中会计算随机奖励
            local rewards = Utils.ParseReward(package.reward, true)

            rt = DataManager.AddReward(DataManager.GetCityId(), rewards, "Purchase", packageId)
            -- 双倍
            if this.IsDouble(package) then
                local doubleReward = Utils.MultiRewards(rewards, package.double_ratio, true)
                local rt2 = DataManager.AddReward(DataManager.GetCityId(), doubleReward, "Purchase", packageId)
                --合并到rewards
                --Utils.MergeRewards(rt2, rt)
                for i = 1, #rt2 do
                    local rw = rt2[i]
                    rw.tagType = PaymentManagerDoubleName
                    table.insert(rt, rw)
                end
            end
        end

        -- 隐式奖励
        if package.reward_backend ~= "" then
            local rewards = Utils.ParseReward(package.reward_backend)

            DataManager.AddReward(DataManager.GetCityId(), rewards, "Purchase", packageId)
        end
    end

    local autoRewards = {}
    if package.reward_daily_auto ~= "" then
        autoRewards = Utils.ParseReward(package.reward_daily_auto)
        -- 自动每日奖励不在这里领，在AppendSubscriptionInfo中领取
        --DataManager.AddReward(DataManager.GetCityId(), autoRewards  , "Purchase", packageId)
    end

    -- 现金支付
    if this.IsPurchase(package) then
        local biRewards = {}
        biRewards = Utils.MergeRewards(rt, biRewards)
        biRewards = Utils.MergeRewards(autoRewards, biRewards)

        this.Analytics(
            "ShopIAPPurchaseComplete",
            package,
            {
                reward = Utils.BIConvertRewards(biRewards)
            }
        )

        -- 订阅要保存信息
        if package.type == PaymentManager.PackageType.Subscription then
            this.AppendSubscriptionInfo(packageId, createTS, expireTS)
        end
    end

    -- 调用boost，必须在订阅信息保存之后
    if package.reward_boost ~= "" then
        BoostManager.RefreshSubscriptionBoost(DataManager.GetCityId())
    end

    this.IncrPackageCount(package.id, GameManager.GameTime())

    this.CallPurchaseCB(rt, 0)
end

---确认支付出错
function PaymentManager.OnConfirmBillErrorResp(packageId, errCode)
    print("[error]" .. "packageId: " .. packageId .. " errCode: " .. errCode)
    this.CallPurchaseCB(nil, errCode)
end

---@param cb fun(errCode:number)
function PaymentManager.SetPurchaseCB(cb)
    this.cb = cb
end

---@param rewards table
---@param errCode number
function PaymentManager.CallPurchaseCB(rewards, errCode)
    if this.cb ~= nil then
        this.cb(rewards, errCode)
        this.cb = nil
    else
        if rewards == nil or #rewards == 0 then
            return
        end

        ResAddEffectManager.AddResEffectFromRewards(
            rewards,
            false,
            {
                title = GetLang("ui_resource_get_buy"),
                openLast = true
            }
        )
    end
end

--拉取未确认的订单处理
function PaymentManager.GetPendingBillList()
    DataManager.GetRegTimestamp()
    ---@param rep Protocol_GetPendingBillResp
    NetManager.GetPendingBill(
        function(rep)
            Log(JSON.encode(rep))

            if rep ~= nil then
                this.CheckPendingBill(rep.bill_list)
                this.CheckHistoryBill(rep.bill_history_list)
            end
        end
    )
end

---@param bills BillData[]
function PaymentManager.CheckPendingBill(bills)
    if bills == nil or #bills == 0 then
        return
    end

    for index, billData in pairs(bills) do
        -- 普通订单
        local packageId = this.ParsePackageIdFromUUID(billData.uuid)
        if packageId ~= nil then
            this.ConfirmBill(billData.uuid, packageId)
        else
            -- 续订订单
            ---@type ShopPackage
            local package
            if this.IsSubscription(billData) then
                -- 订阅订单需要从productId获取package
                package = this.GetPackageByProductId(billData.product_id)
            else
                local throughCargo = this.ThroughCargoDecode(billData.through_cargo)
                package = ConfigManager.GetShopPackage(throughCargo.packageId)
            end

            this.ConfirmBill(billData.uuid, package.id)
        end
    end
    NetManager.SendQueue()
end

---@param bills BillData[]
function PaymentManager.CheckHistoryBill(bills)
    for _, billData in pairs(bills) do
        local time = this.data.log[billData.uuid]
        if time == nil then
            -- uuid不存在，说明客户端没有收到这个被确认的订单
            -- 普通订单
            local packageId = this.ParsePackageIdFromUUID(billData.uuid)
            ---@type ShopPackage
            local package

            if packageId == nil then
                -- 续订订单
                if this.IsSubscription(billData) then
                    -- 订阅订单需要从productId获取package
                    package = this.GetPackageByProductId(billData.product_id)
                    if package ~= nil then
                        packageId = package.id
                    end
                else
                    local throughCargo = this.ThroughCargoDecode(billData.through_cargo)
                    packageId = throughCargo.packageId
                end
            end
            if packageId ~= nil then
                -- 只有创建时间大于注册时间才补单
                if billData.create_ts > DataManager.GetRegTimestamp() then
                    package = ConfigManager.GetShopPackage(packageId)

                    -- this.OnConfirmBillResp(
                    --     billData.uuid,
                    --     packageId,
                    --     billData.create_ts,
                    --     billData.expire_ts,
                    --     billData.is_grace_period
                    -- )
                    Log("Payment PurchaseHistoryRestore: " .. JSON.encode(billData))
                    PaymentManager.Analytics(
                        "PurchaseHistoryRestore",
                        package,
                        {
                            billData = billData
                        }
                    )
                end
            else
                print("[error]" .. "invalid bill: " .. JSON.encode(billData))
            end
        end
    end
end

--计算vip Level
this.VipLevelList = { 0, 10, 50, 200, 1000 }
function PaymentManager.GetVipLevel()
    local ret = 0
    for index, value in pairs(this.VipLevelList) do
        if this.data.priceCount > value then
            ret = index
        else
            break
        end
    end
    return ret
end

function PaymentManager.GetPriceCount()
    return this.data.priceCount
end

function PaymentManager.SaveData()
    DataManager.SetGlobalDataByKey(DataKey.Pay, this.data)
end

---这个接口只能在调用前使用
---@param package ShopPackage
---@return boolean
function PaymentManager.IsDouble(package)
    local count = this.GetPackageCount(package.id)
    return count == 0 and package.double
end

---返回package是否是现金支付项
---@param package ShopPackage
---@return boolean
function PaymentManager.IsPurchase(package)
    return package.product_id ~= ""
end

---检查给定billData是否是订阅
---@param data BillData
---@return boolean
function PaymentManager.IsSubscription(data)
    return data.through_cargo == "" and data.expire_milli ~= 0
end

---@param package ShopPackage
---@return boolean
function PaymentManager.IsFree(package)
    local count = 0
    for _, v in pairs(package.cost) do
        count = v + count
    end

    return count == 0 and not this.IsExtendedCost(package) and not this.IsPurchase(package)
end

function PaymentManager.IsAd(package)
    return package.extended_cost == this.ExtendedCostType.AD
end

function PaymentManager.IsExtendedCost(package)
    return package.extended_cost ~= ""
end

function PaymentManager.IsPurchaseByPackageId(id)
    local config = ConfigManager.GetShopPackage(id)
    return this.IsPurchase(config)
end

function PaymentManager.Enough(package)
    if PaymentManager.IsPurchase(package) then
        --现金支付总是足够的
        return true
    end

    return DataManager.CheckMaterials(DataManager.GetCityId(), package.cost)
end

---@param package ShopPackage
---@return boolean
function PaymentManager.Cost(package)
    if not this.Enough(package) then
        return false
    end

    DataManager.UseMaterials(DataManager.GetCityId(), package.cost, "Payment", package.id)
    return true
end

---@return PaymentItemData
function PaymentManager.NewItemData(packageId)
    return {
        id = packageId,
        count = 0,
        totalCount = 0,
        lastClaimedTS = 0,
        lastRefreshTS = 0,
        eventId = 0
    }
end

---计算过期时间，返回过期时间当天24点时间戳
---@param expire Time2 过期时间，平台返回的精确过期时间
---@param delay number 延迟过期秒
---@return number
function PaymentManager.CalcExpireDate(expire, delay)
    if delay >= 0 then
        local t = expire:Timestamp() + delay
        local newExpire = Time2:New(t)
        return newExpire:GetToday() + Time2.Day - 8 * TimeUtil.HOUR_SEC
    end

    return expire:Timestamp() - 8 * TimeUtil.HOUR_SEC
end

---@param packageId number
---@return PaymentItemData
function PaymentManager.GetPackageItem(packageId)
    local strPkgId = tostring(packageId)
    if this.data.items[strPkgId] == nil then
        this.data.items[strPkgId] = this.NewItemData(packageId)
    end

    return this.data.items[strPkgId]
end

---@param packageId number
---@return number
function PaymentManager.GetPackageCount(packageId)
    local data = this.GetPackageItem(packageId)
    return data.count
end

---@param packageId number
---@param nowTS number
function PaymentManager.IncrPackageCount(packageId, nowTS)
    local data = this.GetPackageItem(packageId)
    data.count = data.count + 1
    data.totalCount = data.totalCount + 1
    data.lastClaimedTS = nowTS
    data.eventId =1-- EventSceneManager.GetEventId()

    this.SetPackageItem(data)
end

---@param packageId number
---@param now Time2
function PaymentManager.ResetPackageItem(packageId, now)
    local data = this.GetPackageItem(packageId)
    data.count = 0
    data.lastRefreshTS = now:Timestamp()
    data.lastClaimedTS = 0
    data.eventId = 0
    this.SetPackageItem(data)
end

---@param data PaymentItemData
function PaymentManager.SetPackageItem(data)
    this.data.items[tostring(data.id)] = data
    this.SaveData()
end

function PaymentManager.SaveInfoOnPurchaseSuccess(uuid, productId)
    local iapConfig = ConfigManager.GetIAPConfig(productId)

    this.data.count = this.data.count + 1
    this.data.log[uuid] = TimeModule.getServerTime()
    this.data.priceCount = this.data.priceCount + iapConfig.price
    this.SaveData()
end

---@return PaymentSubscriptionData
function PaymentManager.NewSubscriptionItem(packageId, createTS, expireTS)
    -- local expire = this.CalcExpireDate(Time2:New(expireTS), this.GetSubscriptionDelayExpire())
    local expire = expireTS
    return {
        packageId = packageId,
        createTS = createTS,
        expireTS = expire
    }
end

---设置订阅信息
function PaymentManager.AppendSubscriptionInfo(packageId, createTS, expireTS)
    local package = ConfigManager.GetShopPackage(packageId)

    local subInfoList = this.data.subscriptions[tostring(package.id)]
    if subInfoList == nil then
        subInfoList = {}
        this.data.subscriptions[tostring(package.id)] = subInfoList
    end

    local subInfo = this.NewSubscriptionItem(package.id, createTS, expireTS)
    table.insert(subInfoList, subInfo)

    local realExpire = Time2:New(subInfo.expireTS)
    Log("subscription update: " .. JSON.encode(subInfo) .. " expire: " .. realExpire:ToString())

    this.AppendSubscriptionDailyShout(subInfo)
    EventManager.Brocast(EventType.PAYMENT_SUBSCRIPTION_SUCCESS, subInfo)
end

function PaymentManager.GetSubscriptionDelayExpire()
    return ConfigManager.GetMiscConfig("payment_subscription_delay_expire")
end

---获得所有有效的订阅
---@param now Time2
---@return PaymentSubscriptionData[]
function PaymentManager.GetAllValidSubscription(now, packageId)
    local rt = {}
    for _, sub in pairs(this.data.subscriptions) do
        if #sub > 0 then
            if sub[#sub].expireTS > now:Timestamp() then
                if sub[#sub].packageId == packageId then
                    return sub[#sub]
                end
                table.insert(rt, sub[#sub])
            end
        end
    end

    return rt
end

---根据packageId获取每日手动领取的奖励(领取每日奖励)
---@return table 返回获得的奖励
function PaymentManager.GetPackageDailyReward(packageId)
    local dailyName = this.GetDailyNameByPackageId(packageId)
    local package = ConfigManager.GetShopPackage(packageId)

    -- if DailyBagManager.CanUseItem(dailyName, 1, nil) then
    local dailyRewards = nil
    if package then
        dailyRewards = Utils.ParseReward(package.reward_daily)
    end
    return dailyRewards
    -- end

    -- return nil
end

---根据packageId获取每日手动领取的奖励(领取每日奖励)
---@return table 返回获得的奖励
function PaymentManager.AddPackageDailyReward(packageId)
    local dailyName = this.GetDailyNameByPackageId(packageId)
    local package = ConfigManager.GetShopPackage(packageId)

    if DailyBagManager.UseItem(dailyName, 1, nil, "ShopDaily", packageId) then
        local dailyRewards = Utils.ParseReward(package.reward_daily)
        DataManager.AddReward(DataManager.GetCityId(), dailyRewards, "shopDaily", package.id)
    end
end

---@param packageId number
---@param now Time2
---@return PaymentSubscriptionData
function PaymentManager.GetSubscription(packageId, now, nowTime)
    local sub = this.data.subscriptions[tostring(packageId)]
    if sub == nil then
        return nil
    end

    if #sub == 0 then
        return nil
    end

    local time = nowTime or now:Timestamp()
    if sub[#sub].expireTS <= time then
        return nil
    end

    return sub[#sub]
end

---@param finishCallback fun()
function PaymentManager.RestoreSubscription(finishCallback)
    local now = Time2:New(GameManager.GameTime())
    ---@param resp Protocol_GetValidBillResp
    NetManager.GetValidBill(
        this.GetSubscriptionDelayExpire(),
        function(resp)
            ---@type table<string, BillData>
            local billMap = {} --去重
            for _, billData in ipairs(resp.bill_list) do
                local throughCargo = this.ThroughCargoDecode(billData.through_cargo)
                local package = ConfigManager.GetShopPackage(throughCargo.packageId)

                local bill = billMap[package.id]
                if bill == nil or (bill ~= nil and bill.expire_milli < billData.expire_milli) then
                    billMap[package.id] = billData
                end
            end

            for pid, billData in pairs(billMap) do
                local sub = this.GetSubscription(billData, now)
                if sub == nil or sub.uuid ~= billData.uuid then
                    this.AppendSubscriptionInfo(pid, billData.create_ts, billData.expire_milli)
                end
            end

            finishCallback()
        end
    )
end

---返回这个订阅package是不是一个可以领取的订阅，不是表示是否可以领取的状态
---@param packageId number
function PaymentManager.IsSubscriptionCanClaimable(packageId)
    local package = ConfigManager.GetShopPackage(packageId)

    return package.reward_daily ~= ""
end

--- 返回钻石数和需要弹窗确认钻石数
---@param packageId number
---@return number, number
function PaymentManager.GetDiamondFromCost(packageId)
    local package = ConfigManager.GetShopPackage(packageId)
    if package.cost == "" then
        return 0
    end

    local count = 0
    for k, v in pairs(package.cost) do
        if k == ItemType.Gem then
            count = count + v
        end
    end

    return count, package.diamond_confirm_count
end

---@param package ShopPackage
function PaymentManager.Analytics(name, package, data)
    local iapConfig = ConfigManager.GetIAPConfig(package.product_id)
    local cityId = DataManager.GetCityId()
    data.gemBalance = DataManager.GetMaterialCount(cityId, ItemType.Gem)
    data.heartBalance = DataManager.GetMaterialCount(DataManager.GetCityId(), ItemType.Heart)
    data.packageKey = package.id
    data.productId = package.product_id
    data.packagePrice = iapConfig.price
    data.purchaseAmount = this.GetPriceCount()
    data.isDouble = this.IsDouble(package)
    data.type = ConfigManager.GetAllShop()[package.id].type

    if Utils.GetTableLength(package.cost) > 0 then
        local gemCount = package.cost[ItemType.Gem] or 0
        data.diamondPrice = gemCount
    end

    Analytics.Event(name, data)
end

function PaymentManager.GetSubscriptionData()
    return this.data.subscriptions
end

function PaymentManager.GetLog()
    return ""
    -- return this.data.log
end

--切换帐号重置数据
function PaymentManager.Reset()
    this.initialized = nil
end
