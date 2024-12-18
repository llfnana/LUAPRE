---@class UIMainPanel : UIPanelBase
local Panel = UIPanelBaseMake()
local this = Panel
UIMainPanel = Panel

require "Game/Logic/NewView/Home/AttributeWarningItem"

---状态栏类型枚举
StatuType = {
    ---生产资源类型
    Res = 1,
    ---生产计划类型
    Plan = 2,
    ---人口类型
    Population = 3,
    ---道具类型
    Prop = 4,
}

function Panel.OnAwake()
    this.cachedata = {}
    this.InitPanel()

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.top = SafeGetUIControl(this, "Top")
    this.uidata.middle = SafeGetUIControl(this, "Middle")
    this.uidata.bottom = SafeGetUIControl(this, "Bottom")

    this.uidata.task = SafeGetUIControl(this, "Bottom/BoxButton/Task")     -- 任务入口
    this.uidata.map = SafeGetUIControl(this, "Bottom/BoxButton/Map")       -- 地图入口 物资净化
    this.uidata.hero = SafeGetUIControl(this, "Bottom/BoxButton/Hero")     -- 英雄入口
    this.uidata.shop = SafeGetUIControl(this, "Bottom/BoxButton/Shop")     -- 商城入口
    this.uidata.FirstCharge = SafeGetUIControl(this, "Bottom/FirstCharge") -- 首充入口

    -- 火炉
    this.uidata.stove = SafeGetUIControl(this, "Top/Stove")
    -- 火炉点击区域
    this.uidata.btnStove = SafeGetUIControl(this, "Top/Stove/Button")
    -- 火炉温度
    -- -- 大火
    -- this.uidata.stoveBigFire = SafeGetUIControl(this, "Top/Stove/Thermometer/ImgBigFire")
    -- -- 小火
    -- this.uidata.stoveFire = SafeGetUIControl(this, "Top/Stove/Thermometer/ImgFire")
    -- 白昼与黑夜
    this.uidata.nightImg = SafeGetUIControl(this, "Top/Stove/nightImg", "Image")

    -- 表盘指针
    this.uidata.stoveArrow = SafeGetUIControl(this, "Top/Stove/Thermometer/Arrow")

    -- 暴风雪
    this.uidata.WeatherItem = SafeGetUIControl(this, "Top/BoxMassage/WeatherItem")
    this.uidata.TxtWeather = SafeGetUIControl(this, "Top/BoxMassage/WeatherItem/TxtWeather", "Text")
    this.uidata.WeatherTitle = SafeGetUIControl(this, "Top/BoxMassage/WeatherItem/TxtWeatherName", "Text")

    -- 罢工
    this.uidata.StrikeItem = SafeGetUIControl(this, "Top/BoxMassage/StrikeItem")
    this.uidata.StrikeTime = SafeGetUIControl(this, "Top/BoxMassage/StrikeItem/TextTime", "Text")
    this.uidata.StrikeTitle = SafeGetUIControl(this, "Top/BoxMassage/StrikeItem/TxtStrikeName", "Text")
    this.uidata.StrikeImage = SafeGetUIControl(this, "Top/BoxMassage/StrikeItem/ImgIcon", "Image")

    -- 任务红点
    this.uidata.TaskRedDot = SafeGetUIControl(this, "Bottom/BoxButton/Task/Message")
    this.uidata.TaskRedDotText = SafeGetUIControl(this, "Bottom/BoxButton/Task/Message/TxtCount", "Text")
    this.uidata.TaskCompleRedDot = SafeGetUIControl(this, "Bottom/BoxButton/Task/ImgRed")

    -- 属性预警
    this.uidata.WarningItem = SafeGetUIControl(this, "WarningItem")

    this.uidata.menu = SafeGetUIControl(this, "Middle/UIMenu")
    this.uidata.menuItem = SafeGetUIControl(this, "Middle/MenuItem")

    -- 烟花特效
    -- this.uidata.effectYH = SafeGetUIControl(this, "Effect/EffectYH", "SkeletonGraphic")
    -- mask层遮罩
    this.uidata.mask = SafeGetUIControl(this, "Mask")

    -- 问卷
    this.uidata.survey = SafeGetUIControl(this, "Bottom/BoxSomething/Survey")
    this.uidata.survey:SetActive(false)

    --广告
    this.uidata.ad = SafeGetUIControl(this, "Bottom/BoxSomething/Ad")
    this.uidata.ad:SetActive(false)
    this.uidata.adAwardIcon = SafeGetUIControl(this, "Bottom/BoxSomething/Ad/RewardIcon", "Image")
    this.uidata.adAwardText = SafeGetUIControl(this, "Bottom/BoxSomething/Ad/RewardText", "Text")

    -- UI毒气
    this.uidata.uiDQ = SafeGetUIControl(this, "Canvas/Z_UI_map_duqi/eff", "ParticleSystem")

    this.uidata.FactoryGame = SafeGetUIControl(this, "Bottom/BoxButton/FactoryGame")

    this.DayCycleManager = DayCycleSystem.DayCycleManager.Instance

    this.CheckQuality = function()
        -- local quality = PlayerModule.getQualityWitch()
        -- DayCycleSystem.DayCycleManager.Instance.IsSystemStart = quality > 1
        -- this.DayCycleManager:Tick(TimeManager.GetDayRatio(DataManager.GetCityId()))
    end
    EventManager.AddListener(EventDefine.QualityChange, this.CheckQuality)
    this.CheckQuality()

    this.uidata.WeatherTitle.text = GetLang("ui_under_storm")

    this.uidata.FirstCharge:SetActive(false)

    -- 调整顶部高度-与胶囊错开
    if PlayerModule.getSdkPlatform() == "wx" then
        this.uidata.top.transform.anchoredPosition = Vector3(0, -LuaFramework.AppConst.cutout + 135, 0)
        print("offset top: ", LuaFramework.AppConst.cutout)
    end

    this.dynamicParticleCount()

    this.uidata.Mem = SafeGetUIControl(this, "Mem", "Text")
    this.uidata.Mem.gameObject:SetActive(true)
end

-- 动态粒子数
function Panel.dynamicParticleCount()
    local scale = 0.5
    if Core.Instance.IsIOSPlatform  then 
        if Core.Instance.IsPhoneLow then
            scale = 0.2
        else
            scale = 0.4
        end
    end

    local duqiParitcle = SafeGetUIControl(this, "Canvas/Z_UI_map_duqi/eff")
    local particles = duqiParitcle:GetComponentsInChildren(typeof(ParticleSystem))
    for i = 0, particles.Length - 1, 1 do
        particles[i].main.maxParticles = Mathf.Ceil(particles[i].main.maxParticles * scale)
    end

    for i = 0, particles.Length - 1, 1 do
        if particles[i].main.maxParticles > 20 then 
            scale = 0.3
        elseif particles[i].main.maxParticles > 15 then 
            scale = 0.4
        elseif particles[i].main.maxParticles > 10 then 
            scale = 0.5
        elseif particles[i].main.maxParticles > 5 then
            scale = 0.6
        end
        particles[i].main.maxParticles = Mathf.Ceil(particles[i].main.maxParticles * scale)
    end
end

function Panel.InitEvent()
    -- -- 临时增加资源
    -- SafeAddClickEvent(this.behaviour, this.uidata.survey, function()
    -- for key, value in pairs(ConfigManager.GetMaterialListByCityId(this.cityId)) do
    --     DataManager.AddMaterial(this.cityId, value.id, 100000000)
    -- end

    -- for key, value in pairs(ConfigManager.GetCardListByCity(this.cityId)) do
    --     CardManager.AddCard(value.id, 10)
    -- end

    -- DataManager.AddMaterial(this.cityId, "BlackCoin", 1000000000)

    -- -- 英雄经验
    -- DataManager.AddMaterial(this.cityId, "Heart", 10000000000)

    -- UIUtil.showText('加完资源了。。。。。')
    -- end)

    -- 首充入口点击事件
    this.AddClickEvent(this.GetEntranceBtn(this.uidata.FirstCharge), function()
        ShowUI(UINames.UIFirstCharge)
    end)

    -- 任务入口点击事件
    this.AddClickEvent(this.GetEntranceBtn(this.uidata.task), function()
        if this.cityId == 1 then
            SDKAnalytics.TraceEvent(139)
        end
        -- DataManager.GetCityId()
        -- FactoryGameModule.c2s_getInfo(4, function ()
        --     ShowUI(UINames.UIFactoryGame)
        -- end)
        ShowUI(UINames.UITask)
    end)

    -- 地图入口点击事件 物资净化
    this.AddClickEvent(this.GetEntranceBtn(this.uidata.map), function()
        PlayerModule.c2sgetOfflineProfit(function ()
            ShowUI(UINames.UIOfflineRewards)
        end)
    end)

    -- 英雄入口点击事件
    this.AddClickEvent(this.GetEntranceBtn(this.uidata.hero), function()
        ShowUI(UINames.UIHero)
    end)

    -- 商城入口点击事件
    this.AddClickEvent(this.GetEntranceBtn(this.uidata.shop), function()
        ShowUI(UINames.UIShop)
    end)

    -- 火炉点击事件
    SafeAddClickEvent(this.behaviour, this.uidata.btnStove, function()
        local data = {}
        local cityId = DataManager.GetCityId()
        data.type = ZoneType.Generator
        data.zoneId = "C" .. cityId .. "_" .. data.type .. "_1"
        CityModule.getMainCtrl():ShowBuildView(data)
    end)

    -- 燃料点击事件
    SafeAddClickEvent(this.behaviour, this.status[StatuType.Res][1].item, function()
        -- 是否功能解锁
        if FunctionsManager.IsUnlock(FunctionsType.Statistical) then 
            ShowUI(UINames.UIDataPreview)
        end
    end)

    -- 时钟点击事件
    SafeAddClickEvent(this.behaviour, this.status[StatuType.Plan][1].item, function()
        ShowUI(UINames.UISchedules)
        -- this.ShowSequenceTip("zhuzhi da bi", nil, 5)
    end)

    this.UIAttributeBtn = this.status[StatuType.Population][1].item
    -- 幸存者属性点击事件
    SafeAddClickEvent(this.behaviour, this.status[StatuType.Population][1].item, function()
        ShowUI(UINames.UIAttribute)
    end)

    -- 钻石
    SafeAddClickEvent(this.behaviour, this.status[StatuType.Prop][1].item, function()
        if not FunctionsManager.IsUnlock(FunctionsType.Shop) then
            return
        end
        ShowUI(UINames.UIShop, {isDown = true})
    end)

    -- 罢工
    SafeAddClickEvent(this.behaviour, this.uidata.StrikeItem, function()
        ShowUI(UINames.UIStrike, true)
    end)

    -- 监听解锁
    this.AddListener(EventType.FUNCTIONS_OPEN, this.OpenFunctionsUnlock)

    -- 城市时间更新事件(秒)
    this.UpdateTimeFunc = function(cityId)
        if this.cityId == cityId then
            this.UpdateStove()
            this.UpdateSchedulesTime()
            this.UpdatePeopleState()
        end
    end
    this.AddListener(EventType.TIME_CITY_UPDATE, this.UpdateTimeFunc)

    this.AddListener(EventDefine.OnClickCityBuild, this.HideBottomMainUI)
    this.AddListener(EventDefine.OnClickExitCityBuild, this.ShowBottomMainUI)

    this.AddListener(EventDefine.HideBottomMainUI, this.HideBottomMainUI)
    this.AddListener(EventDefine.ShowBottomMainUI, this.ShowBottomMainUI)

    this.AddListener(EventDefine.ShowMainUI, this.ShowMainUI)
    this.AddListener(EventDefine.HideMainUI, this.HideMainUI)

    this.AddListener(EventDefine.OnOfflineOver, this.CheckFirstCharge)

    -- 天气标识
    this.WeatherTypeChangeFunc = function(cityId, type)
        if this.cityId ~= cityId then
            return
        end
        this.UpdateWeatherType(type)
    end
    this.AddListener(EventType.WEATHER_TYPE_CHANGE, this.WeatherTypeChangeFunc)
    this.AddListener(EventType.FACTORY_GAME_UNLOCK, this.ShowFactoryGame) -- 工厂游戏机
    
    -- 天气时间
    this.WeatherTimeChangeFunc = function(cityId, time)
        if this.cityId ~= cityId then
            return
        end
        this.UpdateWeatherTime(time)
    end
    this.AddListener(EventType.WEATHER_TIME_CHANGE, this.WeatherTimeChangeFunc)

    -- 进程刷新
    this.UpdatePerPrefrshFunc = function(cityId)
        if this.cityId == cityId then
            this.UpdateSchedulesIcon()
        end
    end
    this.AddListener(EventType.TIME_CITY_PER_REFRESH, this.UpdatePerPrefrshFunc)

    -- 人数刷新
    this.RefreshCharacterFunc = function(cityId, isAdd)
        if this.cityId == cityId then
            this.UpdatePeople()
        end
    end
    this.AddListener(EventType.CHARACTER_REFRESH, this.RefreshCharacterFunc)


    this.UpdateFireResourceItem()
    this.UpgradeFireResourceSpeedFunc = function()
        local count = GeneratorManager.GetConsumptionCount(this.cityId)
        if count > 0 then
            this.uidata.ResResourceSpeedText.text = "-" .. Utils.FormatCount(count) .. "/min"
        else
            this.uidata.ResResourceSpeedText.text = "0/min"
        end
        DataManager.CheckSaveToServer(false, true)
        this.UpdateStove()
    end
    this.AddListener(EventType.REFRESH_GENERATOR, this.UpgradeFireResourceSpeedFunc)

    this.UpgradeFireResourceSpeedFunc()
    -- 建筑升级
    this.UpgradeZoneFunc = function(cityId, zoneId, zoneType, level)
        if this.cityId == cityId then
            this.UpgradeFireResourceSpeedFunc()
            this.UpdateFireResourceItem()
        end
    end
    this.AddListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)

    this.AddListener(EventDefine.LanguageChange, function()
        this.InitStaticLanguageText()
    end)

    -- 罢工状态
    this.ProtestStateChanageFunc = function(cityId, status)
        if this.cityId ~= cityId then
            return
        end
        this.UpdateProtestButtonStatus(status)
    end
    this.AddListener(EventType.PROTEST_STATE_CHANGE, this.ProtestStateChanageFunc)

    -- 罢工时间
    this.ProtestTimeChanageFunc = function(cityId, time)
        if this.cityId ~= cityId then
            return
        end
        this.UpdateProtestButtonTime(time)
    end
    this.AddListener(EventType.PROTEST_TIME_CHANGE, this.ProtestTimeChanageFunc)

    this.attributeWarningItems = {}
    --小人预警属性刷新
    this.CharacterAttributeDebuffFunc = function(cityId)
        if this.cityId ~= cityId then
            return
        end
        this.CreateAttributeDebuffItems()
    end
    this.AddListener(EventType.CHARACTER_ATTRIBUTE_BOOST, this.CharacterAttributeDebuffFunc)


    -- 1、白天毒气来袭=场景毒气+UI毒气   
    -- 2、白天啥都没有=啥都没有  
    -- 3、晚上没有毒气来袭=UI毒气   
    -- 4、晚上毒气来袭=场景毒气+UI毒气   
    -- 5、没开净化器时，要显示毒气   
    -- 净化器过载在任何情况都可以清楚UI毒气
    -- UI毒气效果
    this.UIDqFunc = function(cityId)
        if this.cityId ~= cityId then
            return
        end
        local isNight = TimeManager.GetCityIsNight(cityId)
        local isStorm = WeatherManager.GetWeatherType(cityId) == WeatherType.Storm
        local isOverload = GeneratorManager.GetIsOverload(this.cityId)
        local isEnable = GeneratorManager.GetIsEnable(this.cityId)
        if isOverload then
            this.StopDq()
        elseif isStorm or isNight or isEnable == false then
            this.PlayDq()
        else
            this.StopDq()
        end
    end
    this.UIDqFunc(this.cityId)
    this.AddListener(EventType.CHANGE_DUQI, this.UIDqFunc)

    --消息盒子插入消息
    this.AddListener(EventDefine.ShowMainUITip, this.ShowSequenceTip)
    --消息盒子移除消息
    this.AddListener(EventDefine.HideMainUITip, this.HideSequenceTip)

    --Banner图片展示
    this.AddListener(EventDefine.ShowMainUIBanner, this.ShowBannerUI)

    -- 问卷调查
    -- local btnSurvey = SafeGetUIControl(this.uidata.survey, "BtnSurvey")
    -- SafeAddClickEvent(this.behaviour, btnSurvey, this.OnClickSurveyButton)
    -- this.rxList:Add(this.SurveyStateSubscribe(this.uidata.survey))
    -- SurveyManager.RefreshAvailable()


    --视频广告按钮显示
    local btnAd = SafeGetUIControl(this.uidata.ad, "Button")
    SafeAddClickEvent(this.behaviour, btnAd, this.OnClickAdButton)
    this.RefreshAdVideoFunc = function(reward)
        if reward then
            for item, num in pairs(reward) do
                Utils.SetItemIcon(this.uidata.adAwardIcon, item, nil, true)
                this.uidata.adAwardText.text = "x" .. Utils.FormatCount(num)
            end
            this.uidata.ad:SetActive(true)
            -- LayoutRebuilder.ForceRebuildLayoutImmediate(this.VideoButton.transform.parent)
        else
            this.uidata.ad:SetActive(false)
        end
    end
    EventManager.AddListener(EventType.REFRESH_AD_VIDEO, this.RefreshAdVideoFunc)
    FloatIconManager.InitIconShow()

    EventManager.AddListener(EventDefine.OnNightChange, this.UpdateNight)

    -- 更新邮件红点
    EventManager.AddListener(EventDefine.OnMailListUpdate, this.UpdateMailRed)
    EventManager.AddListener(EventDefine.OnMailListDelete, this.UpdateMailRed)
end

function Panel.UpdateMailRed()
    if this.uidata.mail == nil then return end

    -- 有未领取的奖励
    local mailList = PlayerModule.getMailList()
    local isRed = false;
    for key, value in pairs(mailList) do
        if value.items ~= nil and next(value.items) ~= nil then 
            if value.status ~= 2 then 
                isRed = true
                break
            end
        end
    end

    this.uidata.mailred:SetActive(isRed);
end

---展示Banner图片UI
---@param img string 图片名
---@param time number 展示时间
---@param callback function 展示结束回调
function Panel.ShowBannerUI(img, time, callback)
    local imgBanner = SafeGetUIControl(this, "Middle/ImgBanner", "Image")
    local imgTitle = SafeGetUIControl(this, "Middle/ImgBanner/Title", "Image")
    local titleName = ""
    if PlayerModule.getLanguageList()[PlayerModule.getLanguage()].flag == 'En' then
        if img == "home_img_gas" then 
            titleName = "home_img_gas_04"
        else 
            titleName = "home_img_gas_05"
        end
    else 
        if img == "home_img_gas" then 
            titleName = "home_img_gas_02"
        else 
            titleName = "home_img_gas_03"
        end
    end
    
    this.imgTitleResGuid = Utils.SetIcon(imgTitle, titleName, function() 
        imgBanner.transform.localScale = Vector3.New(1, 0.5, 1)
        this.imgBannerResGuid = Utils.SetIcon(imgBanner, img, function()
            imgBanner.gameObject:SetActive(true)
            local seq = DOTween.Sequence()
            seq:Append(Util.TweenTo(0.5, 1, 0.3, function(value)
                imgBanner.transform.localScale = Vector3.New(1, value, 1)
            end):SetEase(Ease.OutBack))
            seq:AppendInterval(time or 3)
            seq:Append(Util.TweenTo(1, 0, 0.1, function(value)
                imgBanner.transform.localScale = Vector3.New(1, value, 1)
            end):SetEase(Ease.OutCubic))
            seq:AppendCallback(function()
                imgBanner.gameObject:SetActive(false)
                if this.imgTitleResGuid then 
                    ResInterface.ReleaseRes(this.imgTitleResGuid)
                    this.imgTitleResGuid = nil
                end
                if this.imgBannerResGuid then 
                    ResInterface.ReleaseRes(this.imgBannerResGuid)
                    this.imgBannerResGuid = nil
                end
                
                if callback then
                    callback()
                end
            end)
        end)
    end)
    
end

--问卷按钮点击
function Panel.OnClickSurveyButton()
    print("zhkxin OnClickSurveyButton")
    local uid = PlayerModule.GetUid()
    MiniGame.DHWXSDK.Instance:Survey("14057716", "1", "1", tostring(uid), "1", "1")
    MiniGame.DHWXSDK.Instance:SetSurveyCloseCallback(function (data)
        SurveyManager.ClaimActiveSurveyReward()
    end)
end

--广告按钮点击
function Panel.OnClickAdButton()
    if FloatIconManager.Check() then 
        if ShopManager.IsFreeAd() then
            FloatIconManager.OnConsumptionAwardIconClick()
        else 
            AdManager.Show(function()
                FloatIconManager.OnConsumptionAwardIconClick()
            end)
        end
    end
end

function Panel.SurveyStateSubscribe(SurveyButton)
    local function SurveyStateFunc(val)
        local b =
            (val == SurveyManager.State.Active or val == SurveyManager.State.Finished) and
            (CityManager.GetIsEventScene(this.cityId) or this.cityId == DataManager.GetMaxCityId())
        SurveyButton:SetActive(b)
        if b then
            local rewards = SurveyManager.GetActiveRewards()
            local reward = rewards[1]
            local imgIcon = SafeGetUIControl(this.uidata.survey, "PropInfo/ImgIcon", "Image")
            local count = SafeGetUIControl(this.uidata.survey, "PropInfo/TxtCount", "Text")
            Utils.SetItemIcon(imgIcon, reward.id)
            count.text = "×" .. reward.count
        end
    end
    this.SurveyStateFunc = SurveyStateFunc
    return SurveyManager.GetStateRx():subscribe(SurveyStateFunc)
end

function Panel.SendUnlockOfflineProfit()
    PlayerModule.c2sUnlockOfflineProfit()
end

function Panel.CheckFirstCharge(fromType)
    local isOpen = FunctionsManager.IsUnlock(FunctionsType.FirstCharge)
    local chargeCount = PaymentManager.GetPackageCount(999)
    this.uidata.FirstCharge:SetActive(isOpen and chargeCount < 1)

    -- 检测当日首次自动弹出
    local timestamp = os.time()
    local day = os.date("%j", os.time())
    if PlayerPrefs.GetInt(PlayerModule.GetUid() .. "FIRSTCHARGE") == tonumber(day) then
        return
    end

    if isOpen and chargeCount < 1 and this.initFunctionOver then
        local openFirstCharge = function ()
            -- 弹出
            UIUtil.CloseAllPanelOutBy()
            TutorialManager.isOpeningUIFirstCharge = true
            ShowUI(UINames.UIFirstCharge)
            PlayerPrefs.SetInt(PlayerModule.GetUid() .. "FIRSTCHARGE", day)
        end
        if fromType == nil then 
            openFirstCharge()
        else
            StartCoroutine(function()
                -- 1.任务界面领取奖励
                -- 2.弹出宝箱界面
                -- 2.1弹出功能解锁
                -- 3.引导英雄升级 
                -- 4.引导结束 
                -- 5.关闭建筑建造界面
                WaitForSeconds(2)
                while TutorialManager.isOpeningUIOpenBox or IsUIVisible(UINames.UIOpenBox) do
                    Yield(nil)
                end

                -- 功能解锁
                WaitForSeconds(2)
                while IsUIVisible(UINames.UIUnlock) do
                    Yield(nil)
                end

                WaitForSeconds(2)
                while IsUIVisible(UINames.UIBuild) or TutorialManager.currentTutorial ~= nil do
                    Yield(nil)
                end
    
                openFirstCharge()
            end)
        end
    end
end

function Panel.InitOpenFunctions()
    this.initFunctionOver = false
    this.hudUnlocks = {}
    this.hudUnlocks[FunctionsType.Tasks] = { buttons = { this.uidata.task }, switchShow = false }
    this.hudUnlocks[FunctionsType.Attributes] = { buttons = { this.uidata.mail }, switchShow = false } -- 未知功能
    -- this.hudUnlocks[FunctionsType.Map] = { buttons = { this.uidata.map }, switchShow = true }
    this.hudUnlocks[FunctionsType.Assist] = { buttons = { this.uidata.map }, switchShow = false }
    this.hudUnlocks[FunctionsType.WorkerManagement] = { buttons = { this.uidata.manage }, switchShow = false }
    this.hudUnlocks[FunctionsType.Statistical] = { buttons = { this.uidata.statistics }, switchShow = false }
    this.hudUnlocks[FunctionsType.Shop] = { buttons = { this.uidata.shop }, switchShow = false }
    this.hudUnlocks[FunctionsType.ShopGem] = { buttons = {}, switchShow = false }
    this.hudUnlocks[FunctionsType.Cards] = { buttons = { this.uidata.hero }, switchShow = false }
    this.hudUnlocks[FunctionsType.EventCity] = { buttons = {}, switchShow = false } -- 未知功能
    this.hudUnlocks[FunctionsType.Setting] = { buttons = { this.uidata.setting }, switchShow = false }
    this.hudUnlocks[FunctionsType.FactoryGame] = { buttons = { this.uidata.FactoryGame }, switchShow = false }
end

function Panel.OpenFunctionsUnlock(cityId, functionsType, isOpen, isEffect)
    if cityId ~= this.cityId then
        return
    end

    if functionsType == FunctionsType.FirstCharge then
        this.CheckFirstCharge("Unlock")
        this.initFunctionOver = true
    end

    if functionsType == FunctionsType.Assist and isOpen and isEffect then 
        -- 净化物资，需要向服务端发送解锁接口
        this.SendUnlockOfflineProfit()
    end

    local data = this.hudUnlocks[functionsType]
    if nil == data then
        return
    end

    local config = ConfigManager.GetFunctionsUnlockConfig()[functionsType]
    local flyOverBack = function()
        local isShow = false
        if data.switchShow or this.cityId == DataManager.GetCityId() or TestManager.IsShowMainUIButton() then
            isShow = isOpen
        end
        for i = 1, #data.buttons, 1 do
            if data.buttons[i].gameObject ~= nil then
                data.buttons[i].gameObject:SetActive(isShow)
            else
                data.buttons[i].target.gameObject:SetActive(isShow and data.buttons[i].customShowFunc())
            end
        end
    end

    if isEffect then
        if config.is_modal_panel then
            UIUtil.CloseAllPanelOutBy()
            -- PanelManager:CloseAllPanelOutBy(UINames.UIMain)
            ShowUI(UINames.UIUnlock, {
                type = functionsType,
                isOpen = isOpen,
                isEffect = isEffect,
                cityId = cityId,
                flyOverBack = flyOverBack,
            })
        end
        if config.is_highlight then
            ResInterface.SyncLoadCommon('HighLightEffect.prefab', function(asset)
                local item = this.hudUnlocks[functionsType].buttons[1]
                local go = GOInstantiate(asset.gameObject, item.transform, false)
                go.name = "HighLightEffect"
                local point = go:GetComponent("SkeletonGraphic")
                point:Initialize(true)
                SafeSetActive(point.gameObject, true)

                Util.SetEvent(point.gameObject, function(data)
                    Util.PassClickEvent(data) --事件渗透
                    GODestroy(point.gameObject)
                end, Define.EventType.OnClick)
            end)
        end
    end
    
    if not isEffect or (isEffect and not config.is_modal_panel and config.is_highlight) then
        flyOverBack()
    end

    this.ResetMenu()
end

function Panel.InitEffectNodeTargetNodePosition()
    if DataManager.GetCityDataByKey(this.cityId, DataKey.FristInit) and this.cityId ~= 1 then
        if DataManager.GetGlobalDataByKey(DataKey.NewUser) then
            DataManager.SetGlobalDataByKey(DataKey.NewUser, false)
        end
        if this.cityId ~= 2 then
            CityManager.OpenCityPassIntroduction(this.cityId)
        end
        -- if this.cityId ~= 2 then
        --     local function ShowCityReward()
        --         ---todo: 需要一个进入场景后打开窗口队列
        --         -- ShopManager.ShowAndClearPopupItemQueue()
        --         -- self:SetMainUIStateFlag(true, "CityPassIntroduction")
        --         -- HudHandles.PlayTaskRedAni(self.TaskRedDot)
        --     end
        --     -- local offlinePanel = PopupManager.Instance:SearchOpenPanel(PanelType.OfflinePanel)
        --     local dealyTime = 3200
        --     -- if offlinePanel ~= nil then
        --     --     offlinePanel.ClosePanelAction = function()
        --     --         setTimeout(ShowCityReward, dealyTime)
        --     --     end
        --     -- else
        --     setTimeout(ShowCityReward, dealyTime)
        --     -- end
        --     -- self:SetMainUIStateFlag(false, "CityPassIntroduction")
        -- end
    end
    -- OfflineManager.InitView()
    TimeModule.addDelay(0.1, function()
        ResAddEffectManager.SetItemCollectTarget("Gem", this.status[StatuType.Prop][1].item.transform.position)
        ResAddEffectManager.SetItemCollectTarget("FireResource", this.status[StatuType.Res][1].item.transform.position)
        ResAddEffectManager.SetItemCollectTarget("Box", this.uidata.shop.transform.position)
        ResAddEffectManager.SetItemCollectTarget("Card", this.uidata.hero.transform.position)
        ResAddEffectManager.SetItemCollectTarget("Default", this.uidata.statistics.transform.position)
    end)
end

function Panel.InitStaticLanguageText()
    local taskText = SafeGetUIControl(this, "Bottom/BoxButton/Task/BtnIcon/TxtName", "Text")
    local shopText = SafeGetUIControl(this, "Bottom/BoxButton/Shop/BtnIcon/TxtName", "Text")
    local heroText = SafeGetUIControl(this, "Bottom/BoxButton/Hero/BtnIcon/TxtName", "Text")
    local mapText = SafeGetUIControl(this, "Bottom/BoxButton/Map/BtnIcon/TxtName", "Text")
    taskText.text = GetLang("ui_task_title")
    shopText.text = GetLang("ui_shop_title")
    heroText.text = GetLang("item_name_Card")
    mapText.text = GetLang("ui_assist_title")

    SafeGetUIControl(this, "Bottom/FirstCharge/BtnIcon/TxtName", "Text").text = GetLang("ui_shop_firstrecharge")

    this.uidata.WeatherTitle.text = GetLang("ui_under_storm")
    this.UpdateProtestButtonStatus(ProtestManager.GetProtestStatus(this.cityId))
    this.CreateAttributeDebuffItems()
end

--刷新罢工按钮状态
function Panel.UpdateProtestButtonStatus(status)
    this.protestStatus = status
    if status == ProtestStatus.None then
        this.uidata.StrikeItem:SetActive(false)
    elseif status == ProtestStatus.Talk then
        this.uidata.StrikeItem:SetActive(true)
        this.uidata.StrikeTitle.text = GetLang("protest_talk")
        Utils.SetIcon(this.uidata.StrikeImage, "icon_toastListCell_riotsWarning")
    elseif status == ProtestStatus.Run then
        this.uidata.StrikeItem:SetActive(true)
        this.uidata.StrikeTitle.text = GetLang("protest_riot")
        Utils.SetIcon(this.uidata.StrikeImage, "icon_toastListCell_riotsStart")
    elseif status == ProtestStatus.CoolDown then
        if nil ~= PopupManager.Instance and not PopupManager.Instance:IsOpenPanelByType(PanelType.ProtestRiotsPanel) then
            AudioManager.SwitchMainMusic()
        end
        this.protestDuration = 0
        this.uidata.StrikeItem:SetActive(false)
    end
end

--刷新罢工按钮时间
function Panel.UpdateProtestButtonTime(time)
    this.protestDuration = time
    this.uidata.StrikeTime.text = Utils.GetTimeFormat4(time)
end

--刷新暴风雪按钮类型
function Panel.UpdateWeatherType(type)
    this.uidata.WeatherItem:SetActive(type == WeatherType.Storm)
end

--刷新暴风雪时间
function Panel.UpdateWeatherTime(time)
    this.uidata.TxtWeather.text = Utils.GetTimeFormat3(time or 0)
end

-- 火炉资源
function Panel.UpdateFireResourceItem()
    if this.fireResourceItemRx ~= nil then
        this.fireResourceItemRx:unsubscribe()
    end
    if this.fireResourceItemDelayRx ~= nil then
        this.fireResourceItemDelayRx:unsubscribe()
    end
    local fireResourceItem = GeneratorManager.GetConsumptionItemId(this.cityId)
    Utils.SetItemIcon(this.uidata.ResIcon, fireResourceItem)
    Utils.SetItemIcon(this.uidata.ResIcon, fireResourceItem)
    this.fireResourceItemRx =
        DataManager.GetMaterialRx(this.cityId, fireResourceItem):subscribe(
            function(val)
                this.uidata.ResResourceCount.text = DataManager.GetMaterialCountFormat(this.cityId, fireResourceItem)
            end
        )
    this.fireResourceItemDelayRx =
        DataManager.GetMaterialDelayRx(this.cityId, fireResourceItem):subscribe(
            function(val)
                this.uidata.ResResourceCount.text = DataManager.GetMaterialCountFormat(this.cityId, fireResourceItem)
            end
        )
end

function Panel.OnShow(param)
    this.rxList = List:New()
    -- this.AdapterTop()
    this.cityId = DataManager.GetCityId()
    this.InitStove()
    this.InitStatusBar()
    this.InitMessageBox()
    this.InitMenu()
    this.ShowFactoryGame()
    this.InitOpenFunctions()

    -- this.InitUID = function()
    --     local uidText = SafeGetUIControl(this, "TxtUid", "Text")
    --     uidText.text = "UID:" .. PlayerModule.GetUid()
    -- end
    -- this.InitUID()

    this.InitEvent()
    this.UpdateNight()

    PlayerModule.c2sGetMail(function ()
        this.UpdateMailRed()
    end)

    FunctionsManager.InitView()

    this.InitStaticLanguageText()
    this.UpdateSchedulesTime()
    this.UpdateSchedulesIcon()
    this.UpdatePeople()
    this.UpdatePropItem()
    this.UpdateWeatherType(WeatherManager.GetWeatherType(this.cityId))
    this.UpdateWeatherTime(WeatherManager.GetLeftTime(this.cityId))

    this.UpdateProtestButtonStatus(ProtestManager.GetProtestStatus(this.cityId))
    this.UpdateProtestButtonTime(ProtestManager.GetProtestLeftTime(this.cityId))

    this.InitEffectNodeTargetNodePosition()

    this.CreateAttributeDebuffItems()

    this.rxList:Add(TaskManager.GetNotAcceptTaskCountRx(this.cityId):subscribe(function(val)
        SafeSetActive(this.uidata.TaskRedDot, val > 0)
        this.uidata.TaskRedDotText.text = val
    end))

    this.rxList:Add(TaskManager.GetAllCompleteTaskCountRx(this.cityId):subscribe(function(val)
        SafeSetActive(this.uidata.TaskCompleRedDot, val > 0)
    end))

    -- 管理红点
    this.rxList:Add(CharacterManager.GetIrrationalRx(this.cityId):subscribe(function(val)
        SafeSetActive(SafeGetUIControl(this.uidata.manage, "ImgRed"), val > 0)
    end))

    
end

function Panel.AdapterTop()
    local cutout = LuaFramework.AppConst.cutout

    local top = SafeGetUIControl(this, "Top", "RectTransform")
    local topHeight = top.sizeDelta.y
    local topPos = top.anchoredPosition
    topPos.y = topPos.y - cutout
    top.anchoredPosition = topPos
end

---------------------------------------菜单栏---------------------------------------
---初始化菜单栏
function Panel.InitMenu()
    UIUtil.RemoveAllGameobject(this.uidata.menu)

    this.uidata.setting = this.AddMenuItem("home_bt_set", function()
        ShowUI(UINames.UISetting)
    end)

    this.uidata.mail = this.AddMenuItem("home_bt_mail", function()
        PlayerModule.c2sGetMail(function()
            ShowUI(UINames.UIMail)
        end)
    end)
    this.uidata.mailred = SafeGetUIControl(this.uidata.mail, "ImgRed")

    this.uidata.statistics = this.AddMenuItem("home_bt_statistics", function()
        ShowUI(UINames.UIDataPreview)
    end)

    this.uidata.manage = this.AddMenuItem("home_bt_manage", function()
        ShowUI(UINames.UIManage)
    end)
end

---添加菜单项
function Panel.AddMenuItem(icon, callback)
    local newItem = GOInstantiate(this.uidata.menuItem, this.uidata.menu.transform)
    newItem:SetActive(true)

    local btn = SafeGetUIControl(newItem, "BtnIcon")
    SafeAddClickEvent(this.behaviour, btn, function()
        callback()
        -- local point = SafeGetUIControl(newItem, "point")
        -- SafeSetActive(point, false)
    end)

    Utils.SetIcon(SafeGetUIControl(newItem, "BtnIcon", "Image"), icon)

    this.ResetMenu()
    return newItem
end

---重设菜单栏
function Panel.ResetMenu()
    local childCount = this.uidata.menu.transform.childCount
    local activeCount = 0
    for k = 1, childCount do
        local index = k - 1
        local child = this.uidata.menu.transform:GetChild(index)
        SafeGetUIControl(child, "ImgLine"):SetActive(k ~= childCount)
        if child.gameObject.activeSelf then
            activeCount = activeCount + 1
        end
    end

    this.uidata.menu:SetActive(activeCount > 0)
    -- this.uidata.menu.transform.sizeDelta = Vector2(70, 130 + (activeCount - 1) * 90 + 70)
end

--------------------------------------消息盒子--------------------------------------
---初始化消息盒子
function Panel.InitMessageBox()

end

function Panel.PushMessage(event, message)
    -- body
end

----------------------------------------火炉----------------------------------------
---初始化火炉
function Panel.InitStove()
    this.UpdateStove()
end

---更新火炉
function Panel.UpdateStove(muteAction)
    local isEnable = GeneratorManager.GetIsEnable(this.cityId)           --是否燃烧
    local isOverload = GeneratorManager.GetIsOverload(this.cityId)      --是否高功率
    local temperature = CharacterManager.GetSurfaceTempValue(this.cityId) --温度

    local targetRotateZ = isEnable and (isOverload and 135 or 0) or -135
    if muteAction then
        this.uidata.stoveArrow.transform.localRotation = Quaternion.Euler(0, 0, targetRotateZ)
        this.arrowRotateZ = targetRotateZ
        return
    end
    if this.rotateArrowTween then
        this.rotateArrowTween:Kill()
        this.rotateArrowTween = nil
    end

    local curRotateZ = this.arrowRotateZ or this.uidata.stoveArrow.transform.localRotation.z
    local subRotateZ = math.abs(targetRotateZ - curRotateZ)
    this.rotateArrowTween = Util.TweenTo(curRotateZ, targetRotateZ, subRotateZ / 180, function(value)
        this.uidata.stoveArrow.transform.localRotation = Quaternion.Euler(0, 0, value)
        this.arrowRotateZ = value
    end):SetEase(Ease.Linear)

    -- note: 温度相关代码，策划说不要删，先保留
    -- temperature = GeneratorManager.temperatureUnitSwitch and temperature or (temperature * 1.8 + 32)

    -- local num = 0
    -- if temperature > 0 then
    --     num = (20 - temperature + 1) / 20 / 5 * 100
    -- else
    --     num = math.abs(temperature - 20)
    -- end

    -- this.uidata.txtTemperature.text = "" -- string.format("%.2f", num) .. "%"
end

function Panel.UpdateNight()
    local isNight = TimeManager.GetCityIsNight(this.cityId)
    if isNight then 
        Utils.SetIcon(this.uidata.nightImg, "icon_night", nil, true)
    else 
        Utils.SetIcon(this.uidata.nightImg, "icon_day", nil, true)
    end
end

----------------------------------------状态栏----------------------------------------
---初始化状态栏
function Panel.InitStatusBar()
    --保存状态栏item以及一些参数
    --初始化完成以后,可以通过this.status[StatuType.Res]这样的方式拿到对应类型的item参数列表
    this.status = {
        [StatuType.Res] = {},
        [StatuType.Plan] = {},
        [StatuType.Population] = {},
        [StatuType.Prop] = {},
    }
    this.AddStatuItem(StatuType.Res, 1)
    this.AddStatuItem(StatuType.Plan)
    this.AddStatuItem(StatuType.Population)
    this.AddStatuItem(StatuType.Prop, 2)

    -- 火炉资源与消耗
    local ResItem = this.status[StatuType.Res][1].item
    this.uidata.ResIcon = SafeGetUIControl(ResItem, "Icon", "Image")
    this.uidata.ResResourceCount = SafeGetUIControl(ResItem, "TxtCount", "Text")
    this.uidata.ResResourceSpeedText = SafeGetUIControl(ResItem, "TxtTimeInfo", "Text")

    -- 人物状态
    local PlanItem = this.status[StatuType.Plan][1].item
    this.uidata.PlanText = SafeGetUIControl(PlanItem, "TxtTime", "Text")
    this.uidata.PlanIcon = SafeGetUIControl(PlanItem, "Icon", "Image")
    this.uidata.PlanSlider = SafeGetUIControl(PlanItem, "PlanProgress", "Slider")

    -- 人数
    local pupulationItem = this.status[StatuType.Population][1].item
    this.uidata.PeopleText = SafeGetUIControl(pupulationItem, "TxtCount", "Text")
    this.uidata.PeopleIcon = SafeGetUIControl(pupulationItem, "Icon", "Image")

    local PropItem = this.status[StatuType.Prop][1].item
    this.uidata.GenText = SafeGetUIControl(PropItem, "TxtCount", "Text")
end

---添加状态栏item
function Panel.AddStatuItem(statuType, param)
    local tempName = ""
    ---根据类型拿到预制体的名字
    if statuType == StatuType.Res then
        tempName = "ResItem"
    elseif statuType == StatuType.Plan then
        tempName = "PlanItem"
    elseif statuType == StatuType.Population then
        tempName = "PopulationItem"
    elseif statuType == StatuType.Prop then
        tempName = "PropItem"
    end

    local newItem = SafeGetUIControl(this, "Top/BoxStatus/" .. tempName)
    table.insert(this.status[statuType], { item = newItem, param1 = param })
end

---刷新状态栏生产计划时间
function Panel.UpdateSchedulesTime()
    this.uidata.PlanText.text = TimeManager.GetClockFormat(this.cityId)
    this.DayCycleManager:Tick(TimeManager.GetDayRatio(this.cityId))
    this.currScheduleCfg = SchedulesManager.GetCurrentSchedulesByMenu(this.cityId)
    this.uidata.PlanSlider.value = this.currScheduleCfg.GetSchedulesProgress(TimeManager.GetCityClock(this.cityId))
end

---刷新状态栏生产计划图标
function Panel.UpdateSchedulesIcon()
    -- 图标
    this.currScheduleCfg = SchedulesManager.GetCurrentSchedulesByMenu(this.cityId)
    this.currScheduleCfg.SetSprite(this.uidata.PlanIcon)
end

function Panel.UpdatePeopleState()
    local iconRes = "main_survivor_icon_man_6"
    local isOpen = FunctionsManager.IsOpen(this.cityId, FunctionsType.Protest)
    if isOpen then
        local desparirProgress = ProtestManager.GetDesparirProgress(this.cityId)
        if desparirProgress > 0.6 then
            iconRes = "main_survivor_icon_man_8"
        elseif desparirProgress > 0.3 then
            iconRes = "main_survivor_icon_man_7"
        end
    end

    if this.resPath ~= iconRes then
        Utils.SetIcon(this.uidata.PeopleIcon, iconRes)
    end
    this.resPath = iconRes
end

---刷新状态栏人口Item
function Panel.UpdatePeople()
    this.uidata.PeopleText.text =
        string.format(
            "%d/%d",
            CharacterManager.GetCharacterCount(this.cityId),
            CharacterManager.GetCharacterMaxCount(this.cityId)
        )
end

---刷新状态栏道具Item
function Panel.UpdatePropItem()
    if this.MaterrialRx ~= nil then
        this.MaterrialRx:unsubscribe()
    end
    this.MaterrialRx = DataManager.GetMaterialRx(this.cityId, ItemType.Gem):subscribe(function()
        this.uidata.GenText.text = DataManager.GetMaterialCountFormat(this.cityId, ItemType.Gem, true)
    end)
end

----------------------------------------消息盒子----------------------------------------
---显示队列消息
---@param key string 文本语言key
---@param icon string 图标
---@param hold boolean 是否保持
---@param second number 持续时间
---@param id number id 用于区分不同的消息
function Panel.ShowSequenceTip(key, icon, hold, second, id)
    Audio.PlayAudio(DefaultAudioID.UiTip)
    this.tipSequence = this.tipSequence or {}
    hold = hold or false
    id = id or "mainui_tip_default_" .. tostring(os.time())

    if this.tipSequence[id] ~= nil then
        return
    end

    key = key or "Unknown label"
    second = second or 3

    local temp = SafeGetUIControl(this, "Top/BoxMassage/MassageItem")
    local parent = SafeGetUIControl(this, "Top/BoxMassage")

    local messageItem = GOInstantiate(temp, parent.transform)
    messageItem:SetActive(true)

    this.tipSequence[id] = messageItem

    local imgIcon = SafeGetUIControl(messageItem, "Content/ImgIcon", "Image")
    Utils.SetIcon(imgIcon, icon)
    local text = SafeGetUIControl(messageItem, "Content/TxtMassage", "Text")
    text.text = GetLang(key)

    local messageItemContent = SafeGetUIControl(messageItem, "Content")
    messageItemContent.transform.localPosition = Vector3.zero + Vector3(-320, 0, 0)
    local seq = DOTween.Sequence()
    seq:Append(messageItemContent.transform:DOLocalMoveX(0, 0.5):SetEase(Ease.OutBack))
    if not hold then
        seq:AppendInterval(second)
        seq:OnComplete(
            function()
                this.HideSequenceTip(id)
            end
        )
    end
end

---移除队列消息
---@param id number id 用于区分不同的消息
function Panel.HideSequenceTip(id)
    if this.tipSequence[id] ~= nil then
        local item = this.tipSequence[id]
        this.tipSequence[id] = nil
        local messageItemContent = SafeGetUIControl(item, "Content")
        local seq = DOTween.Sequence()

        seq:Append(messageItemContent.transform:DOLocalMoveX(-320, 0.5):SetEase(Ease.InBack))
        seq:OnComplete(
            function()
                GameObject.Destroy(item)
            end
        )
    end
end

----------------------------------------界面基础----------------------------------------
---隐藏中部和底部主界面UI
function Panel.HideBottomMainUI()
    this.uidata.middle:SetActive(false)
    this.uidata.bottom:SetActive(false)
end

---显示中部和底部主界面UI
function Panel.ShowBottomMainUI()
    this.uidata.middle:SetActive(true)
    this.uidata.bottom:SetActive(true)
end

---隐藏全部主界面UI
function Panel.HideMainUI()
    this.uidata.top:SetActive(false)
    this.uidata.middle:SetActive(false)
    this.uidata.bottom:SetActive(false)
    this.uidata.mask:SetActive(true)
end

---显示全部主界面UI
function Panel.ShowMainUI()
    this.uidata.top:SetActive(true)
    this.uidata.middle:SetActive(true)
    this.uidata.bottom:SetActive(true)
    this.uidata.mask:SetActive(false)
end

function Panel.AddClickEvent(go, callback)
    SafeAddClickEvent(this.behaviour, go, callback)
end

function Panel.GetEntranceBtn(entranceGo)
    return SafeGetUIControl(entranceGo, "BtnIcon")
end

function Panel.HideUI()
    HideUI(UINames.UIMain)
end

function Panel.OnHide()
    -- this.RemoveListener(EventType.TIME_CITY_UPDATE, this.UpdateTimeFunc)
    this.attributeWarningItems = nil

    if this.MaterrialRx ~= nil then
        this.MaterrialRx:unsubscribe()
    end

    this.rxList:ForEach(
        function(rx)
            rx:unsubscribe()
        end
    )
    this.rxList:Clear()
    EventManager.RemoveListener(EventDefine.OnNightChange, this.UpdateNight)
end

--添加属性deff显示
function Panel.CreateAttributeDebuffItems()
    local infos = CharacterManager.GetAttributeDebuffCount(this.cityId)
    local removeItems = Dictionary:New()
    for type, item in pairs(this.attributeWarningItems) do
        if not infos[type] then
            removeItems:Add(type, item)
        end
    end
    removeItems:ForEachKeyValue(
        function(type, item)
            this.attributeWarningItems[type] = nil
            -- 销毁
            -- ResourceManager.Destroy(item.gameObject)
            GODestroy(item.gameObject)
        end
    )

    local function func()
        for type, item in pairs(this.attributeWarningItems) do
            item:ShowTip(false)
            item.isShow = false
        end
    end

    for type, count in pairs(infos) do
        if this.attributeWarningItems[type] then
            this.attributeWarningItems[type]:OnRefresh(count)
        else
            local view = GOInstantiate(this.uidata.WarningItem)
            view:SetActive(true)
            local AttributeWarningItem = AttributeWarningItem.new()
            local pupulationItem = this.status[StatuType.Population][1].item
            local Panel = SafeGetUIControl(pupulationItem, "Panel")
            view.transform:SetParent(Panel.transform, false)
            SafeSetActive(view.gameObject, true)
            AttributeWarningItem:InitPanel(this.behaviour, view, type, count, func)
            this.attributeWarningItems[type] = AttributeWarningItem
        end
    end
end

----------------------------------------特效----------------------------------------
---播放烟花特效
function Panel.PlayEffectYH()
    if this.cityId == 1 then
        SDKAnalytics.TraceEvent(157)
    end

    
    this.LoadEffectYH()

    -- this.uidata.effectYH:Initialize(true)
    -- this.uidata.effectYH.AnimationState:SetAnimation(0, "animation", false)
    -- local time = 1.34
    -- TimeModule.addDelay(time, function()
    --     SafeSetActive(this.uidata.effectYH.gameObject, false)
    -- end)
end

--烟花特效为动态加载，播完就销毁
function Panel.LoadEffectYH() 

    this.effectYHResGuid = ResInterface.SyncLoadGameObject("EffectYH", function(_go)
        this.effectYH = GOInstantiate(_go)
        this.effectYH.transform:SetParent(SafeGetUIControl(this, "Effect").transform, false)

        local spine = SafeGetUIControl(this, "Effect/EffectYH(Clone)", "SkeletonGraphic")
        spine:Initialize(true)
        spine.AnimationState:SetAnimation(0, "animation", false):AddOnComplete(function()
            this.UnloadEffectYH()
        end)
    end)
end

function Panel.UnloadEffectYH() 
    if this.effectYHResGuid then 
        GODestroy(this.effectYH)
        ResInterface.ReleaseRes(this.effectYHResGuid)
        this.effectYHResGuid = nil
        this.effectYH = nil
    end
end

function Panel.StopDq()
    this.uidata.uiDQ:Stop()
end

function Panel.PlayDq()
    this.uidata.uiDQ:Play()
end

-- 工厂游戏机 显示
function Panel.ShowFactoryGame()
    local isActive = FactoryGameData.IsBuildComplete()
    local city = DataManager.GetCityId()
    if isActive then 
        this.AddClickEvent(this.GetEntranceBtn(this.uidata.FactoryGame), function()
            
            FactoryGameModule.c2s_getInfo(city, function ()
                ShowUI(UINames.UIFactoryGame)
            end)
        end)
    end
    --刷新游戏机建筑状态
    local path = "Map/layer_zone_map_" .. city .. "/FactoryGame/FactoryGamePanelEntity"
    local obj = GameObject.Find(path)
    if obj ~= nil then
        local isBuildComplete = FactoryGameData.IsBuildComplete()
        local floor = SafeGetUIControl(obj, "floor")
        local BuildCursor = SafeGetUIControl(obj, "BuildCursor")
        floor.gameObject:SetActive(isBuildComplete)
        -- BuildCursor.gameObject:SetActive(not isBuildComplete)
    end
    this.uidata.FactoryGame.gameObject:SetActive(isActive)
end


