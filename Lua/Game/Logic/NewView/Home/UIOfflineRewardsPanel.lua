---@class UIHealthPanel : UIPanelBase
-- 物资净化
local Panel = UIPanelBaseMake()
local this = Panel
UIOfflineRewardsPanel = Panel

function Panel.OnAwake()
    this.cachedata = {}
    this.InitPanel()
    
    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}

    this.uidata.btnClose = SafeGetUIControl(this, "BtnClose", "Button")
    this.uidata.mask = SafeGetUIControl(this, "Mask")
    -- 广告
    this.uidata.btnAd = SafeGetUIControl(this, "ButtonBar/BtnAd", "Button")
    this.uidata.txtAdNum = this.GetUIControl(this.uidata.btnAd, "Txt/TxtNum", "Text")

    this.uidata.btnReceive = SafeGetUIControl(this, "ButtonBar/BtnReceive", "Button")
    this.uidata.btnBuyPrivilege = SafeGetUIControl(this, "ChargeBox2/Button", "Button")
    this.uidata.MoneyText = SafeGetUIControl(this, "ChargeBox2/Button/TextBack", "Text")

    this.uidata.curLevelExpText = SafeGetUIControl(this, "BuildInfo/Info/TextInfo1", "Text")
    this.uidata.curLevelCoinText = SafeGetUIControl(this, "BuildInfo/Info/TextInfo2", "Text")
    this.uidata.nextLevel = SafeGetUIControl(this, "BuildInfo/NextInfo/")
    this.uidata.nextLevelExpText = SafeGetUIControl(this, "BuildInfo/NextInfo/TextInfo1", "Text")
    this.uidata.nextLevelCoinText = SafeGetUIControl(this, "BuildInfo/NextInfo/TextInfo2", "Text")

    this.uidata.rewardItemNum = SafeGetUIControl(this, "RewardBox/ItemExp/TextBg/Num", "Text")
    this.uidata.rewardCoinNum = SafeGetUIControl(this, "RewardBox/ItemCoin/TextBg/Num", "Text")

    this.uidata.slider = SafeGetUIControl(this, "BuildSliderBox/Slider", "Slider")
    this.uidata.sliderMaxText = SafeGetUIControl(this, "BuildSliderBox/Slider/TextTime", "Text")
    this.uidata.sliderProgressText = SafeGetUIControl(this, "BuildSliderBox/Slider/Fill Area/Fill/Arrow/ContentBg/Text", "Text")

    this.uidata.vipInfo = SafeGetUIControl(this, "ChargeBox")
    this.uidata.vipBuy = SafeGetUIControl(this, "ChargeBox2")

    this.uidata.btnReceiveText = SafeGetUIControl(this, "ButtonBar/BtnReceive/Text", "Text")
    this.uidata.btnReceiveOutLine = SafeGetUIControl(this, "ButtonBar/BtnReceive/Text", "OutlineEx")
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.btnClose.gameObject, this.HideUI)

    SafeAddClickEvent(this.behaviour, this.uidata.mask, this.HideUI)

    SafeAddClickEvent(this.behaviour, this.uidata.btnReceive.gameObject, this.Receive)
    SafeAddClickEvent(this.behaviour, this.uidata.btnAd.gameObject, this.OnClockAd)

    SafeAddClickEvent(this.behaviour, this.uidata.btnBuyPrivilege.gameObject, this.BuyPrivilege)
end

function Panel.OnShow()
    UIUtil.openPanelAction(this.gameObject)
    this.Init()
    this.InitEvent()
    this.UpdateAd()
end

function Panel.Init()
    -- 城市ID
    this.cityId = DataManager.GetCityId()
    -- 区域ID
    this.zoneId = ConfigManager.GetZoneIdByZoneType(this.cityId, ZoneType.Generator)
    -- 区域数据
    this.mapItemData = MapManager.GetMapItemData(this.cityId, this.zoneId)

    this.uidata.MoneyText.text = ShopManager.GetPrice(ShopManager.GetPackageByShopId(207).product_id)

    this.UpdateView()
end

function Panel.UpdateView()
    this.data = PlayerModule.getOfflineRewards()
    this.isVip = this.data.privilege > 0

    this.UpdateBuildTitle()
    this.UpdateBuildInfo()
    this.UpdateBuildOut()
end

function Panel.UpdateBuildTitle()
    local level = this.mapItemData:GetLevel()
    local assistLv = this.GetAssitLevel(DataManager.GetCityId(), level)


    -- 刷新建筑等级文本
    local buildLevel = SafeGetUIControl(this, "GeneratorTitle/TxtLevel", "Text")
    buildLevel.text = GetLangFormat("Lv" .. assistLv) -- 修改为显示援助等级

    local curMapText = SafeGetUIControl(this, "GeneratorTitle/CurMap/MapName", "Text")
    curMapText.text = " " .. GetLang("city_name_" .. this.cityId)

    ForceRebuildLayoutImmediate(curMapText.transform.parent.gameObject)
end

function Panel.UpdateBuildInfo()
    this.uidata.nextLevelExpText = SafeGetUIControl(this, "BuildInfo/NextInfo/TextInfo1", "Text")
    this.uidata.nextLevelCoinText = SafeGetUIControl(this, "BuildInfo/NextInfo/TextInfo2", "Text")

    local result = this.GetSpeed()
    this.uidata.curLevelExpText.text = GetLang("item_name_Heart") .. "：" .. result.curExp .. "/" .. GetLang("UI_Time_Minute")
    this.uidata.curLevelCoinText.text = GetLang("item_name_BlackCoin") .. "：" .. result.curCoin .. "/" .. GetLang("ui_assist_title_small5")

    this.uidata.nextLevel:SetActive(result.hasNext)
    if result.hasNext then 
        this.uidata.nextLevelExpText.text = GetLang("item_name_Heart") .. "：" .. result.nextExp .. "/" .. GetLang("UI_Time_Minute")
        this.uidata.nextLevelCoinText.text = GetLang("item_name_BlackCoin") .. "：" .. result.nextCoin .. "/" .. GetLang("ui_assist_title_small5")
    end
end

function Panel.GetAssitLevel(cityId, generatorLevel)
    local assistConf = require("Game/Config/AssistConf")
    for k, v in ipairs(assistConf) do
        if v.Cities_id == cityId and v.Generator_level == generatorLevel then
            return v.id
        end
    end
end

-- todayGetDuration: 已领取的时间 number

-- todayDuration: 剩余可领取的时间 table {{lv = 1, time = 10}, {}....}

-- beforeDuration 累积可领取的时间 table {{lv = 1, time= 10}, {}....}

-- privilege: 特权数值

-- 数据同步接口 syncCityAndGenerator(cityId，generatorLv)

-- lastRewardTime：上次领取时间
-- 进度条：当前已领取+可领取的时间
-- 真正有奖励，是看下面的道具奖励项，有值才有奖励
function Panel.UpdateBuildOut()
    print("zhkxin todayGetDuration: ", this.data.todayGetDuration,
        "\ntodayDuration: ", ListUtil.dump(this.data.todayDuration), "\nbeforeDuration: ", ListUtil.dump(this.data.beforeDuration))

    local maxHour = this.isVip and 6 or 2
    local maxValue = maxHour * 60 * 60
    local maxValidTime = maxValue - this.data.todayGetDuration -- 今日剩余的最大有效时间

    -- 进度条
    local todayTime = this.getTodayTotalTime(this.data.todayDuration, this.data.todayGetDuration)

    local progressValue = Mathf.Min(maxValue, todayTime)
    local progressMin = math.floor(progressValue / 60)
    this.uidata.slider.value = progressValue / maxValue
    this.uidata.sliderMaxText.text = GetLang("ui_assist_title_small6") .. " " .. maxHour .. "h"
    this.uidata.sliderProgressText.text = progressMin .. GetLang("UI_Time_Minute")

    -- 奖励
    this.reward = this.convertToReward(this.data.todayDuration, this.data.beforeDuration, maxValidTime)
    this.uidata.rewardItemNum.text = "+" .. Utils.FormatCount(this.reward.exp)
    this.uidata.rewardCoinNum.text = "+" .. Utils.FormatCount(this.reward.coin)

    -- 特权
    this.uidata.vipInfo:SetActive(this.isVip)
    this.uidata.vipBuy:SetActive(not this.isVip)

    local isRewardMax = this.data.todayGetDuration >= maxValue --到达上限
    -- 没有奖励或已达最大值
    
    local todayTime = this.getDurationTime(this.data.todayDuration)
    todayTime = Mathf.Min(todayTime, maxValidTime)
    local beforeTime = this.getDurationTime(this.data.beforeDuration)
    local isGray = (isRewardMax or todayTime == 0) and beforeTime == 0 -- 最少奖励为1分钟，没有累积奖励
    GreyObject(this.uidata.btnReceive.gameObject, isGray, isGray == false, true)
    -- 没有累积奖励
    this.uidata.btnReceiveText.text = (isRewardMax and beforeTime == 0) and GetLang("ui_assist_buttons2") or GetLang("ui_assist_buttons1") 
    this.uidata.btnReceiveOutLine.enabled = isGray
end

function Panel.Receive()
    PlayerModule.c2sReceiveOfflineRewards(function ()
        local rewards = {}
        local cityId = DataManager.GetCityId()
        if this.reward then 
            if this.reward.exp > 0 then
                rewards[1] = Utils.ConvertAttachment2Rewards("Heart", this.reward.exp, RewardAddType.Item)
                DataManager.AddMaterial(cityId, "Heart", this.reward.exp) 
            end
            if this.reward.coin > 0 then
                rewards[2] = Utils.ConvertAttachment2Rewards("BlackCoin", this.reward.coin, RewardAddType.Item)
                DataManager.AddMaterial(cityId, "BlackCoin", this.reward.coin)
            end
        end
        ResAddEffectManager.AddResEffectFromRewards(rewards, true)
        this.UpdateView()
    end)
end

-- 特权购买
function Panel.BuyPrivilege()
    ShopManager.Buy(
        DataManager.GetCityId(),
        207,
        function(rewards, errCode)
            this.UpdateView()
            if errCode == 0 then
                -- this.UpdatePanel()
            else
                ShopManager.ShowErrCode(errCode)
            end
        end
    )
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UIOfflineRewards)
    end)
end

function Panel.GetSpeed()
    local result = {curExp = 0, curCoin = 0, hasNext = false, nextExp = 0, nextCoin = 0}

    local assistConf = require("Game/Config/AssistConf")
    local level = this.mapItemData:GetLevel()
    local assistConfigId = this.GetAssitLevel(DataManager.GetCityId(), level)
    local curAssitlv = assistConf[assistConfigId]
    result.curExp = curAssitlv.Rwd[2].Heart
    result.curCoin = curAssitlv.Rwd[1].BlackCoin

    local nextAssistConfigId = assistConfigId + 1
    if assistConf[nextAssistConfigId] then 
        result.hasNext = true
        local nextAssitlv = assistConf[nextAssistConfigId]
        result.nextExp = nextAssitlv.Rwd[2].Heart
        result.nextCoin = nextAssitlv.Rwd[1].BlackCoin
    end

    return result
end

-- 将时间转换为奖励，防止服务端的数值没有限制，客户端做下最大值保护
-- todayDuration : {{lv = 1, time = 10}, {lv = 2, time = 20}, ...}
-- beforeDuration : {{lv = 1, time = 10}, {lv = 2, time = 20}, ...}
function Panel.convertToReward(todayDuration, beforeDuration, maxValidTime)
    local reward = {exp = 0, coin = 0}
    local configTable = require("Game/Config/AssistConf")
    maxValidTime = Mathf.Max(0, maxValidTime)
    for _, value in pairs(todayDuration) do
        local config = configTable[value.lv]
        if config then 
            -- 有效时间
            local validTime = Mathf.Min(maxValidTime, value.time)
            maxValidTime = maxValidTime - validTime
            reward.exp = reward.exp + config.Rwd[2].Heart * Mathf.Floor(validTime / 60)
            reward.coin = reward.coin + config.Rwd[1].BlackCoin * Mathf.Floor(validTime / 3600)
        end
    end

    for _, value in pairs(beforeDuration) do
        local config = configTable[value.lv]
        if config then 
            reward.exp = reward.exp + config.Rwd[2].Heart * Mathf.Floor(value.time / 60)
            reward.coin = reward.coin + config.Rwd[1].BlackCoin * Mathf.Floor(value.time / 3600)
        end
    end

    return reward
end

-- 今日总时间
function Panel.getTodayTotalTime(todayDuration, todayGetDuration)
    return this.getDurationTime(todayDuration) + (todayGetDuration or 0)
end

-- 获取可领取时间，若是小于 60 秒，则返回0
function Panel.getDurationTime(todayDuration)
    local todayTime = 0

    for _, value in pairs(todayDuration) do
        if value.time >= 60 then
            todayTime = todayTime + value.time
        end
    end

    return todayTime
end

function Panel.OnClockAd()
    local watchCount, maxCount, remainCount = AdManager.GetCount(AdSourceType.UIOfflineReward)
    if remainCount == 0 then 
        ShowTips(GetLang("ad_day_limit_tip2"))
        return
    end
    AdManager.ShowConfirmDialog(AdSourceType.UIOfflineReward, function()
        -- 观看广告成功
        AdManager.AddCount(AdSourceType.UIOfflineReward)
        this.UpdateAd()
        this.GetAdReward()
    end, function()
        -- 取消观看
    end)
end

-- 
function Panel.UpdateAd()
    local watchCount, maxCount, remainCount = AdManager.GetCount(AdSourceType.UIOfflineReward)
    this.uidata.txtAdNum.text = ("(%s/%s)"):format(maxCount - watchCount, maxCount)
    GreyObject(this.uidata.btnAd.gameObject, remainCount == 0, true, true)
end

-- 展示时间奖励
function Panel.GetAdReward()
    local level = this.mapItemData:GetLevel()
    local assistLv = this.GetAssitLevel(DataManager.GetCityId(), level)
    local configTable = require("Game/Config/AssistConf")
    local config = configTable[assistLv]

    local _, second = AdManager.GetMaxCountAndRewardFromConfig(AdSourceType.UIOfflineReward)
    local reward = {exp = 0, coin = 0}
    if config then 
        -- 有效时间
        reward.exp = reward.exp + config.Rwd[2].Heart * Mathf.Floor(second / 60)
        reward.coin = reward.coin + config.Rwd[1].BlackCoin * Mathf.Floor(second / 3600)
    end
    
    local rewards = {}
    local cityId = DataManager.GetCityId()
    if reward.exp > 0 then
        rewards[1] = Utils.ConvertAttachment2Rewards("Heart", reward.exp, RewardAddType.Item)
        DataManager.AddMaterial(cityId, "Heart", reward.exp) 
    end
    if reward.coin > 0 then
        rewards[2] = Utils.ConvertAttachment2Rewards("BlackCoin", reward.coin, RewardAddType.Item)
        DataManager.AddMaterial(cityId, "BlackCoin", reward.coin)
    end
    ResAddEffectManager.AddResEffectFromRewards(rewards, true)
   
    DataManager.SaveAll()
end
