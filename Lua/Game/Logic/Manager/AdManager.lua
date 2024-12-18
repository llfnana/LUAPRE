AdManager = {}
AdManager.__cname = "AdManager"
local this = AdManager
local key = 'adunit-21f35321555b5e5e'

local isInitStorage = false
local localStorage = {

}

function AdManager.Init()
    local param = WeChatWASM.WXCreateRewardedVideoAdParam.New()
    param.adUnitId = key
    param.multiton = true
    
    this.videoAd = WeChatWASM.WX.CreateRewardedVideoAd(param)

    this.videoAd:OnClose(this._Close)
    this.videoAd:OnError(this._Error)
end

function AdManager.Show(callback)
    this.callback = callback
    if PlayerModule.getSdkPlatform() == "wx" then
        this.videoAd:Show()
    else
        if this.callback then 
            this.callback()
        end
        this.callback = nil
    end
end

function AdManager.Test()
    local videoAd = WeChatWASM.WXRewardedVideoAd.New(0)
    videoAd:Show(function(ret) end, function(ret) end)
end

function AdManager._Close(response)
    print("zhkxin AdManager Close: ", response.isEnded)
    if response.isEnded then 
        if this.callback then 
            this.callback()
        end
    end
    this.callback = nil
end

function AdManager._Error(response)
    print("zhkxin AdManager Error: ", response.errMsg, response.errCode)
    this.videoAd:Load(function(response) end, function(response) end)
end

function AdManager.Release()
    this.videoAd:OffClose(this._Close)
    this.videoAd:OffError(this._Error)
end

-- 广告弹窗详情(时长收益广告弹窗，资源数量弹窗)
function AdManager.ShowConfirmDialog(sourceType, onReceive, onCancel)
    ShowUI(UINames.UIAdDialog, {sourceType = sourceType, onReceive = onReceive, onCancel = onCancel})
end

function AdManager.GetKey(adSourceType)
    local day = os.date("%j", TimeModule.getServerTime())
    local key = adSourceType .. "_" .. PlayerModule.GetUid() .. "_" .. day
    return key
end

-- 获取可观看广告数量
-- return: watchCount 已观看数量，maxCount 总数量，remainCount 剩余数量
function AdManager.GetCount(adSourceType)
    local key = this.GetKey(adSourceType)

    local watchCount = this.GetStorage(key)
    local maxCount, reward = this.GetMaxCountAndRewardFromConfig(adSourceType)
    local remainCount = Mathf.Max(0, maxCount - watchCount)

    print("zhkxin ad", "ADSourceType = ", adSourceType, ", key = ", key, ", 已观看数 = ", watchCount, ", 总数 = ", maxCount, ", 剩余数 = ", remainCount)
    return watchCount, maxCount, remainCount
end

-- 观看数量 +1
function AdManager.AddCount(adSourceType)
    local key = this.GetKey(adSourceType)
    local watchCount = this.GetStorage(key)
    -- local watchCount = PlayerPrefs.GetInt(key, 0)
    this.SetStorage(key, watchCount + 1)
    -- PlayerPrefs.SetInt(key, (watchCount + 1))
end



-- 获取最大可观看数，奖励
-- return maxCount, reward
function AdManager.GetMaxCountAndRewardFromConfig(adSourceType)
    local maxCountKey, rewardKey
    if adSourceType == AdSourceType.UIOffline then 
        maxCountKey = "offline_day_ad"
        rewardKey = "ad_offline_timing"
    elseif adSourceType == AdSourceType.UIOfflineReward then 
        maxCountKey = "Assist_day_ad"
        rewardKey = "ad_Assist_timing"
    elseif adSourceType == AdSourceType.UIBuildFoold then 
        maxCountKey = "Kitchen_food_day_ad"
        rewardKey = "ad_food_rwd"
    end
    local maxCount = ConfigManager.GetMiscConfig(maxCountKey)
    local reward = ConfigManager.GetMiscConfig(rewardKey)

    return maxCount, reward
end

-- 每日广告总上限次数(已达上限，则提示)
function AdManager.CheckMaxWatch()
    local isMax = this.IsAllMaxCount()
    if isMax then 
        ShowTips(GetLang("ad_day_limit_tip1"))
        return true
    end
    return false
end

-- 每日广告总上限次数
function AdManager.IsAllMaxCount()
    local maxCount = 0
    local logCount = {"离线=", "援助=", "食物=", "商城=", "主界面=", "每日广告总上限次数="}
    local keys = {AdSourceType.UIOffline, AdSourceType.UIOfflineReward, AdSourceType.UIBuildFoold, AdSourceType.UIShopBox}
    for index, value in ipairs(keys) do
        local key = this.GetKey(value)
        maxCount = maxCount +  AdManager.GetStorage(key)
        logCount[index] = logCount[index] .. AdManager.GetStorage(key) .. ", " 
    end

    -- 主界面底部广告
    maxCount = maxCount + DailyBagManager.GetItem("Daily_Ad_Times", nil)
    local configMaxCount = ConfigManager.GetMiscConfig("ad_day_limit")

    logCount[5] = logCount[5] .. DailyBagManager.GetItem("Daily_Ad_Times", nil) .. ", " 
    logCount[6] = logCount[6] .. configMaxCount .. ", " 
    print("广告数: " .. logCount[1] .. logCount[2] .. logCount[3] .. logCount[4] .. logCount[5] .. logCount[6])
    return maxCount >= configMaxCount
end

--region 本地缓存
function AdManager.InitStorage()
    if isInitStorage == false then 
        isInitStorage = true
        localStorage = StorageModule.get(StorageModule.enum.AD, localStorage)
    end
end

function AdManager.GetLocalStorage(key)
    this.InitStorage()
    return localStorage[key]
end

function AdManager.SetLocalStorage(key, value)
    this.InitStorage()
    localStorage[key] = value
    StorageModule.set(StorageModule.enum.AD, localStorage)
end

function AdManager.GetStorage(key)
    if PlayerModule.getSdkPlatform() == "wx" then
        return this.GetLocalStorage(key) or 0 
    else 
        return PlayerPrefs.GetInt(key)
    end
end

function AdManager.SetStorage(key, value)
    if PlayerModule.getSdkPlatform() == "wx" then
        this.SetLocalStorage(key, value)
    else 
        PlayerPrefs.SetInt(key, value)
    end
end
--endregion


-- ADCallBackEvent = {
--     OnAdvertisingInited = "onAdvertisingInited",
--     OnAdLoaded = "onAdLoaded",
--     OnAdFailedToLoad = "onAdFailedToLoad",
--     OnAdShown = "onAdShown",
--     OnAdFailedToShow = "onAdFailedToShow",
--     OnAdClosed = "onAdClosed",
--     OnAdClicked = "onAdClicked",
--     OnRewarded = "onRewarded",
--     OnShouldShowGDPR = "onShouldShowGDPR",
--     OnShowGDPRSuccess = "onShowGDPRSuccess",
--     OnShowGDPRFailed = "onShowGDPRFailed"

-- }

-- --广告SDK 初始化
-- function AdManager.Init()
--     Log("AdSDK.Init")
--     this.adUid = "ca-app-pub-8451717056497276/9882802919"
--     this.isSDKInit = false
--     this.isLoaded = false
--     this.isRewarded = false
--     this.isLoading = false
--     this.reloadCount = 0
--     this.reloadTimeId = 0
--     if Application.platform == RuntimePlatform.Android then
--         this.adUid = ConfigManager.GetMiscConfig("android_admob_aduid")
--     elseif Application.platform == RuntimePlatform.IPhonePlayer then
--         this.adUid = ConfigManager.GetMiscConfig("ios_admob_aduid")
--     end
--     AdSDK.Instance:Init(
--         function(result)
--             this.OnAdvertisingCommon(result)
--         end
--     )
-- end

-- --广告SDK 回调
-- function AdManager.OnAdvertisingCommon(result)
--     Log("OnAdvertisingCommon:" .. result)
--     local retJson = JSON.decode(result)
--     if retJson.callback_function_name == ADCallBackEvent.OnAdvertisingInited then
--         this.isSDKInit = true
--         this.LoadAd()
--     elseif retJson.callback_function_name == ADCallBackEvent.OnAdLoaded then
--         --TODO
--         clearTimeout(this.reloadTimeId)
--         Analytics.TraceEvent("adLoadSuccess", {})
--         this.isLoaded = true
--         this.isLoading = false
--         this.reloadCount = 0
--         EventManager.Brocast(EventType.AD_LOADED)
--     elseif retJson.callback_function_name == ADCallBackEvent.OnAdFailedToLoad then
--         --TODO
--         Analytics.TraceEvent("adLoadFail", {errorId = retJson.errorCode})
--         this.isLoaded = false
--         this.isLoading = false
--         if this.reloadCount < 6 then
--             this.reloadTimeId =
--                 setTimeout(
--                 function()
--                     this.LoadAd()
--                 end,
--                 20000
--             )
--             this.reloadCount = this.reloadCount + 1
--         end
--     elseif retJson.callback_function_name == ADCallBackEvent.OnAdFailedToShow then
--         this.AdClose("OnAdFailedToShow")
--     elseif retJson.callback_function_name == ADCallBackEvent.OnRewarded then
--         this.isRewarded = true
--     elseif retJson.callback_function_name == ADCallBackEvent.OnAdClosed then
--         this.AdClose()
--     end
-- end

-- --加载广告
-- function AdManager.LoadAd()
--     clearTimeout(this.reloadTimeId)
--     Log("AdSDK.LoadAd")
--     this.isLoaded = false
--     this.isLoading = true
--     AdSDK.Instance:LoadRewardAd(2, this.adUid)
-- end

-- function AdManager.IsLoaded()
--     if GameManager.isEditor then
--         return true
--     end
    
--     return this.isLoaded
-- end

-- --显示广告
-- ---@param cb fun(success : boolean, errId : string)
-- function AdManager.ShowAd(cb, from, fromId, resource, isAdSubscriptionNew)
--     if ShopManager.IsFreeAd() then
--         cb(true)
--         return
--     end
    
--     if GameManager.isEditor then
--         this.showAdForEditor(cb)
--         return
--     end
    
--     clearTimeout(this.reloadTimeId)
--     Log("AdSDK.ShowAd")
--     this.callBack = cb
--     if this.isLoaded == false then
--         GameToast.Instance:Show(GetLang("toast_ads_loading_unfinish"),ToastIconType.Warning)
--         this.callBack(false, "notLoaded")
--         return
--     end
--     this.isRewarded = false
--     this.isLoaded = false
--     local incomeNotice = {}
--     incomeNotice.ad_from = from
--     incomeNotice.ad_local_id = this.adUid
--     local incomeNoticeStr = JSON.encode(incomeNotice)
--     Analytics.TraceEvent(
--         "adViewStart",
--         {
--             cityId = DataManager.GetCityId(),
--             from = from,
--             fromId = fromId,
--             resource = resource,
--             isAdSubscriptionNew = isAdSubscriptionNew
--         }
--     )
--     this.lastPlay = {
--         cityId = DataManager.GetCityId(),
--         from = from,
--         fromId = fromId,
--         resource = resource,
--         isAdSubscriptionNew = isAdSubscriptionNew
--     }
--     GameManager.DontReload = true
--     AdSDK.Instance:ShowRewardAd(2, this.adUid, incomeNoticeStr)
-- end

-- function AdManager.showAdForEditor(cb)
--     PopupManager.Instance:ShowLoading()
    
--     setTimeout(
--         function()
--             PopupManager.Instance:HideLoading()
--             cb(true)
--         end,
--         2000
--     )
-- end

-- --广告结束
-- function AdManager.AdClose(errorId)
--     Log("AdSDK.AdClose")
--     Log("AdSDK hasLastPlay " .. tostring(this.lastPlay ~= nil))
--     if this.lastPlay ~= nil then
--         Log("AdSDK isRewarded " .. tostring(this.isRewarded))
--         if this.isRewarded then
--             Analytics.TraceEvent(
--                 "adViewSuccess",
--                 {
--                     cityId = this.lastPlay.cityId,
--                     from = this.lastPlay.from,
--                     fromId = this.lastPlay.fromId,
--                     resource = this.lastPlay.resource,
--                     isAdSubscriptionNew = this.lastPlay.isAdSubscriptionNew
--                 }
--             )
--         else
--             errorId = errorId or "NoReward"
--             Analytics.TraceEvent(
--                 "adViewFail",
--                 {
--                     cityId = this.lastPlay.cityId,
--                     from = this.lastPlay.from,
--                     fromId = this.lastPlay.fromId,
--                     resource = this.lastPlay.resource,
--                     isAdSubscriptionNew = this.lastPlay.isAdSubscriptionNew,
--                     errorId = errorId
--                 }
--             )
--         end
--     end
--     Log("AdSDK has callback " .. tostring(this.callBack ~= nil))
--     if this.callBack ~= nil then
--         this.callBack(this.isRewarded, errorId)
--     end
--     this.callBack = nil
--     this.isRewarded = false
--     this.LoadAd()
-- end
