---@class UIBuildPanel : UIPanelBase
local Panel = UIPanelBaseMake()
local this = Panel
UIBuildPanel = Panel

function Panel.OnAwake()
    this.cachedata = {}
    this.InitPanel()


    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.clickMask = SafeGetUIControl(this, "ClickMask")

    this.uidata.TutorialHero = SafeGetUIControl(this, "TutorialHero")

    -- 生产Item
    this.uidata.itemProduction = SafeGetUIControl(this, "BottomView/Content/ItemProduction")
    -- 标题Item
    this.uidata.titleItem = SafeGetUIControl(this, "BottomView/TitleItem")

    -- 家具Item升级按钮
    this.uidata.ToolUpgradeButton = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/Button", "Button")

    this.uidata.BoostUpgradeButton = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/Button", "Button")

    -- 升级Item
    this.uidata.upgradeItem = SafeGetUIControl(this, "BottomView/UpgradeItem")

    this.uidata.LvUpSkele = SafeGetUIControl(this, "BottomView/TitleItem/LvUpSkele")
    this.uidata.AddSkele = SafeGetUIControl(this, "BottomView/Content/ItemPeople/AddSkele")
    this.uidata.ToolUpSkele = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/ToolUpSkele")
    this.uidata.BoostUpSkele = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/BoostUpSkele")
    
    -- 升级中进度条文本
    this.upgradingTimeText = SafeGetUIControl(this, "BottomView/UpgradingItem/SliderItem/Time", "Text")
    -- 升级中进度条
    this.upgradingSlider = SafeGetUIControl(this, "BottomView/UpgradingItem/SliderItem/Slider", "Slider")

    -- 广告
    this.uidata.btnAd = SafeGetUIControl(this, "AD", "Button")
    this.uidata.btnAdRewardNum = SafeGetUIControl(this, "AD/TextNum", "Text")
    this.uidata.btnAd.gameObject:SetActive(false)
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.clickMask, function()
        this.HideUI()
    end)

    local btnPeopleAdd = SafeGetUIControl(this, "BottomView/Content/ItemPeople/BtnAdd", "Button")
    SafeAddClickEvent(this.behaviour, btnPeopleAdd.gameObject, function()
        GameManager.TeQuanAuto = true
        this.OnPeopleAddButton()
    end)
    local btnPeopleReduce = SafeGetUIControl(this, "BottomView/Content/ItemPeople/BtnReduce", "Button")
    SafeAddClickEvent(this.behaviour, btnPeopleReduce.gameObject, function()
        GameManager.TeQuanAuto = true
        this.OnPeopleSubtractButton()
    end)

    local upgradeToolFunc = function()
        -- 弹窗检测
        local reuslt = this.mapItemData:GetToolConsume()
        this.ShowGeneratorEveryWarnning(reuslt.itemId, reuslt.count, function() 
            if this.zoneId == "C1_Dorm_1" then
                SDKAnalytics.TraceEvent(141)
            elseif this.zoneId == "C1_Sawmill_1" then
                if this.mapItemData:GetToolLevel() == 19 then
                    SDKAnalytics.TraceEvent(144)
                end
                if this.mapItemData:GetToolLevel() == 29 then
                    SDKAnalytics.TraceEvent(149)
                end
            elseif this.zoneId == "C1_Carpentry_1" then
    
            end
    
            this.UpgradeToolLevel()
            Audio.PlayAudio(DefaultAudioID.ToolUpgrade)
        end) 
    end
    -- 家具1长按升级
    SafeAddLongPressEvent(this.behaviour, this.uidata.ToolUpgradeButton.gameObject, function ()
        this.CleanLevelUpPressTimer(1)
        this.toolTimer = TimeModule.addRepeat(0.2, function ()
            upgradeToolFunc()
        end)
    end, function ()
        this.CleanLevelUpPressTimer(1)
    end, function ()
        upgradeToolFunc()
    end, 0.2)

    local upgradeBoostFunc = function()
        -- 弹窗检测
        local reuslt = this.mapItemData:GetBoostConsume()
        this.ShowGeneratorEveryWarnning(reuslt.itemId, reuslt.count, function() 
            this.UpgradeBoostLevel()
            Audio.PlayAudio(DefaultAudioID.ToolUpgrade)
        end)
    end
    -- 家具2长按升级
    SafeAddLongPressEvent(this.behaviour, this.uidata.BoostUpgradeButton.gameObject, function ()
        this.CleanLevelUpPressTimer(2)
        this.boostTimer = TimeModule.addRepeat(0.2, function ()
            upgradeBoostFunc()
        end)
    end, function ()
        this.CleanLevelUpPressTimer(2)
    end, function ()
        upgradeBoostFunc()
    end, 0.2)

    -- 区域升级打开按钮
    local btnZoneLevelUp = SafeGetUIControl(this, "BottomView/TitleItem/BtnLevelUp", "Button")
    SafeAddClickEvent(this.behaviour, btnZoneLevelUp.gameObject, function()
        if this.mapItemData:IsUpgrading() then
            this.OnOpenUpgradingZone()
            return
        end
        local p = this.mapItemData:GetExp() / this.mapItemData:GetUpgradeExp()
        p = math.min(p, 1)
        if p >= 1 then
            -- 弹窗检测
            -- local reuslt = this.mapItemData:GetUnlockLevelConsume()
            -- this.ShowGeneratorEveryWarnning(reuslt.itemId, reuslt.count, function() 
                this.OnOpenUpgradeZone()
                local levelUpRed = SafeGetUIControl(this, "BottomView/TitleItem/BtnLevelUp/ImgRed")
                levelUpRed:SetActive(false)
            -- end)
        else
            SafeSetActive(this.uidata.ToolUpSkele, true)
            local actSkel = this.uidata.ToolUpSkele:GetComponent("SkeletonGraphic")
            if actSkel then
                actSkel.AnimationState:SetAnimation(0, "animation2", false):AddOnComplete(function()
                    SafeSetActive(this.uidata.ToolUpSkele, false)
                end)
            end
        end
    end)
    -- 区域升级关闭按钮
    local btnUpgradeItemClose = SafeGetUIControl(this, "BottomView/UpgradeItem/BtnClose", "Button")
    SafeAddClickEvent(this.behaviour, btnUpgradeItemClose.gameObject, function()
        this.HideUpgradeZone()
        this.RefreshLevelUpRedDot()
    end)
    -- 区域升级中关闭按钮
    local btnUpgradingItemClose = SafeGetUIControl(this, "BottomView/UpgradingItem/BtnClose", "Button")
    SafeAddClickEvent(this.behaviour, btnUpgradingItemClose.gameObject, function()
        if this.mapItemData:IsUpgrading() then
            this.OnHideUpgradingZone()
            return
        end
    end)
    -- 区域升级按钮
    local btnUpgrade = SafeGetUIControl(this, "BottomView/UpgradeItem/BtnGreen", "Button")
    SafeAddClickEvent(this.behaviour, btnUpgrade.gameObject, function()

        if this.zoneId == "C1_Dorm_1" then
            SDKAnalytics.TraceEvent(142)
        elseif this.zoneId == "C1_Dorm_2" then
            SDKAnalytics.TraceEvent(153)
        end

        this.UpgradeZoneLevel()
    end)
    -- 立即完成按钮
    local btnCompleteLevelUp = SafeGetUIControl(this, "BottomView/UpgradingItem/BtnComplete", "Button")
    SafeAddClickEvent(this.behaviour, btnCompleteLevelUp.gameObject, function()
        this.OnSpeedUpFun()
    end)

    -- 患者按钮
    local btnHealth = SafeGetUIControl(this, "BottomView/Content/ItemHealth/TextDetail/Btn", "Button")
    SafeAddClickEvent(this.behaviour, btnHealth.gameObject, function()
        ShowUI(UINames.UIHealth)
    end)

    -- 食谱按钮
    local btnFood = SafeGetUIControl(this, "BottomView/Content/ItemFoodList/TextDetail/Btn", "Button")
    SafeAddClickEvent(this.behaviour, btnFood.gameObject, function()
        ShowUI(UINames.UIFoodList, { cityId = this.cityId, zoneId = this.zoneId })
    end)

    -- 哨塔按钮
    local btnGuardTower = SafeGetUIControl(this, "BottomView/Content/ItemGuardTower/TextDetail/Btn", "Button")
    SafeAddClickEvent(this.behaviour, btnGuardTower.gameObject, function()
        ShowUI(UINames.UIGuardTower, { cityId = this.cityId, zoneId = this.zoneId })
    end)

    -- 上一个区域
    local imgLeft = SafeGetUIControl(this, "BottomView/ImageLeft", "Image")
    SafeAddClickEvent(this.behaviour, imgLeft.gameObject, function()
        local zoneId = MapManager.GetSlidePrevZoneId(this.cityId, this.zoneId)
        local build = CityModule.getMainCtrl().buildDict[zoneId]
        this.HideUI(true)
        CityModule.getMainCtrl():ShowBuildViewNoAction(build.data)
    end)
    -- 下一个区域
    local imgRight = SafeGetUIControl(this, "BottomView/ImageRight", "Image")
    SafeAddClickEvent(this.behaviour, imgRight.gameObject, function()
        local zoneId = MapManager.GetSlideNextZoneId(this.cityId, this.zoneId)
        local build = CityModule.getMainCtrl().buildDict[zoneId]
        this.HideUI(true)
        CityModule.getMainCtrl():ShowBuildViewNoAction(build.data)
    end)
    
    -- 广告
    SafeAddClickEvent(this.behaviour, this.uidata.btnAd.gameObject, this.OnClickBtnAD)

    this.CharacterStateChangeFunc = function(cId, itemId)
        if this.cityId == cId then
            if this.mapItemData.config.zone_type == ZoneType.Dorm then
                this.UpdateProductionItem()
            end
        end
    end
    this.CharacterRefreshFunc = function()
        if this.mapItemData.config.zone_type == ZoneType.Dorm then
            this.UpdateProductionItem()
        end
    end
   
    this.AddListener(EventType.CHARACTER_STATE_CHANGE, this.CharacterStateChangeFunc)
    this.AddListener(EventType.CHARACTER_REFRESH, this.CharacterRefreshFunc)
    this.AddListener(EventType.TIME_CITY_UPDATE, function()
        if this.startBuildUpgrading then
            this.UpdateUpgradingItem()
        end
        if WorkOverTimeManager.IsActiveWorkOverTimeByZoneId(this.cityId, this.zoneId) then
            this.UpdateOverTimeItem()
        end
        if this.mapItemData:GetLevel() < this.mapItemData.config.max_level then
            this.UpdateUpgradeItem()
        end
    end)
    this.AddListener(EventType.UPGRADE_ZONE, function (cityId, zoneId)
        if cityId == this.cityId and zoneId == this.zoneId then
            this.HideUI()
            this.startBuildUpgrading = false
        end
    end)

    -- TODO 这个函数耗性能
    this.UpdateCardViewFunc = function()
        this.UpdateCardView()
        this.UpdateProductionItem()
        this.InitFurnitures()

        this.InitGuardTower()
        this.InitFoodList()
        this.UpdatePeopleItem()
    end
    this.AddListener(EventType.ADD_CARD, this.UpdateCardViewFunc)
    this.AddListener(EventType.UPGRADE_CARD_LEVEL, this.UpdateCardViewFunc)
    this.AddListener(EventType.UPGRADE_CARD_STAR, this.UpdateCardViewFunc)
end

function Panel.CleanLevelUpPressTimer(index)
    if this.boostTimer and index == 2 then
        TimeModule.removeTimer(this.boostTimer)
        this.boostTimer = nil
    end
    if this.toolTimer and index == 1 then
        TimeModule.removeTimer(this.toolTimer)
        this.toolTimer = nil
    end
end

function Panel.OnSpeedUpFun()
    local status = this.mapItemData:GetBuildStatus()
    if
        ShopManager.CheckSubscriptionValid(ShopManager.SubscriptionType.City) and
        DataManager.GetMaterialCount(this.cityId, ItemType.BuildTicket) > 0 and
        ConfigManager.GetMiscConfig("building_ticket_switch")
    then
        if this.mapItemData:UseTicketSpeedBuildUpgradeComplete() == false then
            return
        end
        this.UpdateBuildTicket()
    else
        local completeFunc = function()
        end
        if this.mapItemData:IsUpgrading() then
            if this.mapItemData:SpeedUpgradeComplete(completeFunc) == false then
                return
            end
        end
    end
end

function Panel.UpdateBuildTicket()
    if ShopManager.CheckSubscriptionValid(ShopManager.SubscriptionType.City) == false then
        return
    end
    local showBuildTicket = ConfigManager.GetMiscConfig("building_ticket_switch")
    local icon = SafeGetUIControl(this, "BottomView/UpgradingItem/Cost/Icon", "Image")
    local text = SafeGetUIControl(this, "BottomView/UpgradingItem/Cost/Text", "Text")
    if showBuildTicket then
        local ticketCount = DataManager.GetMaterialCount(this.cityId, ItemType.BuildTicket)
        this.UpgradeTicketCountText.text = "x" .. DataManager.GetMaterialCountFormat(this.cityId, ItemType.BuildTicket)
        if ticketCount > 0 then
            Utils.SetItemIcon(icon, ItemType.BuildTicket)
        else
            Utils.SetItemIcon(icon, ItemType.Gem)
        end
    else
        Utils.SetItemIcon(icon, ItemType.Gem)
    end
end

---升级区域！
function Panel.UpgradeZoneLevel()
    local onSuccess = function()
        local upgradeItem = SafeGetUIControl(this, "BottomView/UpgradeItem")

        this.HideUI()

        upgradeItem:SetActive(false)
    end

    local reuslt = this.mapItemData:GetUnlockLevelConsume()
    this.ShowGeneratorEveryWarnning(reuslt.itemId, reuslt.count, function() 
        this.mapItemData:UpgradeZoneLevel(
            function(success)
                if success then
                    onSuccess()
                end
            end
        )
    end)
end

---打开升级中面板
function Panel.OnOpenUpgradingZone()
    this.startBuildUpgrading = true
    local upgradingItem = SafeGetUIControl(this, "BottomView/UpgradingItem")

    local itemPos = upgradingItem.transform.localPosition
    local startY = itemPos.y - 100
    local endY = itemPos.y

    upgradingItem.transform.localPosition = Vector3(itemPos.x, startY, itemPos.z)
    upgradingItem.transform:DOLocalMoveY(endY, 0.3):SetEase(Ease.OutCubic)

    upgradingItem:SetActive(true)
    local btnZoneLevelUp = SafeGetUIControl(this, "BottomView/TitleItem/BtnLevelUp", "Button")
    GreyObject(btnZoneLevelUp.gameObject, true, true)
    this.UpdateUpgradingItem()

    this.InitLocalize()
end

---关闭升级中面板
function Panel.OnHideUpgradingZone(isStopUpdate)
    local upgradingItem = SafeGetUIControl(this, "BottomView/UpgradingItem")
    upgradingItem:SetActive(false)
    local btnZoneLevelUp = SafeGetUIControl(this, "BottomView/TitleItem/BtnLevelUp", "Button")
    GreyObject(btnZoneLevelUp.gameObject, false, true)
    if not isStopUpdate then 
        this.UpdateUpgradingItem()
    end
end

---打开升级面板
function Panel.OnOpenUpgradeZone()
    local upgradeItem = SafeGetUIControl(this, "BottomView/UpgradeItem")

    local itemPos = upgradeItem.transform.localPosition
    local startY = itemPos.y - 100
    local endY = itemPos.y

    upgradeItem.transform.localPosition = Vector3(itemPos.x, startY, itemPos.z)
    upgradeItem.transform:DOLocalMoveY(endY, 0.3):SetEase(Ease.OutCubic)

    upgradeItem:SetActive(true)

    local btnZoneLevelUp = SafeGetUIControl(this, "BottomView/TitleItem/BtnLevelUp", "Button")
    GreyObject(btnZoneLevelUp.gameObject, true, true, true)

    this.UpdateUpgradeItem()
    this.InitLocalize()
end

---关闭升级面板
function Panel.HideUpgradeZone()
    local upgradeItem = SafeGetUIControl(this, "BottomView/UpgradeItem")
    upgradeItem:SetActive(false)

    local btnZoneLevelUp = SafeGetUIControl(this, "BottomView/TitleItem/BtnLevelUp", "Button")
    GreyObject(btnZoneLevelUp.gameObject, false, true, true)
end

---刷新升级中面板
function Panel.UpdateUpgradingItem()
    this.lfTime, this.lfTotal = this.mapItemData:GetBuildLeftTime()
    local p = 1 - this.lfTime / this.lfTotal
    this.upgradingTimeText.text = Utils.GetTimeFormat3(this.lfTime)
    Util.TweenTo(this.upgradingSlider.value, p, 0.25, function(value)
        this.upgradingSlider.value = value
    end)

    local gemCost = this.mapItemData:GetSpeedCost()
    local costText = SafeGetUIControl(this, "BottomView/UpgradingItem/Cost/Text", "Text")
    costText.text = gemCost or 1
    local btnCompleteLevelUp = SafeGetUIControl(this, "BottomView/UpgradingItem/BtnComplete", "Button")
    btnCompleteLevelUp.gameObject:SetActive(true)
    local isReady = DataManager.GetMaterialCount(this.cityId, "Gem") >= gemCost
    GreyObject(btnCompleteLevelUp.gameObject, not isReady, isReady, true)

    -- 倒计时结束
    if this.lfTime <= 1 then
        btnCompleteLevelUp.gameObject:SetActive(false)
        this.startBuildUpgrading = false

        -- 这里会死循环
        this.OnHideUpgradingZone(true)
        -- 刷新界面等级
        this.UpdateLevelInfo()
    end
   
    this.UpdateBuildTicket()
end

---更新等级信息
function Panel.UpdateLevelInfo()
    local btnLevelUp = SafeGetUIControl(this, "BottomView/TitleItem/BtnLevelUp", "Button")
    local slider = SafeGetUIControl(this, "BottomView/TitleItem/Slider", "Slider")

    -- 刷新建筑等级文本
    this.UpdateBuildLevel()
    btnLevelUp.gameObject:SetActive(true)

    local p = this.mapItemData:GetExp() / this.mapItemData:GetUpgradeExp()
    p = math.min(p, 1)
    if p >= 1 then
        GreyObject(btnLevelUp.gameObject, false, true)
    else
        GreyObject(btnLevelUp.gameObject, true, true)
    end

    if this.isUpgradeOpen then
        this.LevelUpButton:SetInteractable(false)
        this.LevelUpInactiveButton.gameObject:SetActive(false)
    end
    if this.mapItemData:GetLevel() >= this.mapItemData.config.max_level then
        btnLevelUp.gameObject:SetActive(false)
        slider.value = 1
    else
        slider.value = p
    end

    this.RefreshLevelUpRedDot()
end

function Panel.RefreshLevelUpRedDot()
    local levelUpRed = SafeGetUIControl(this, "BottomView/TitleItem/BtnLevelUp/ImgRed")
    levelUpRed:SetActive(false)
    if GameManager.TutorialOpen then
        levelUpRed:SetActive(false)
        return
    end
    if this.mapItemData:GetLevel() >= this.mapItemData.config.max_level then
        levelUpRed:SetActive(false)
        return
    end
    if this.mapItemData:IsUpgrading() then
        levelUpRed:SetActive(false)
        return
    end
    if this.mapItemData:GetExp() < this.mapItemData:GetUpgradeExp() then
        levelUpRed:SetActive(false)
        return
    end
    local costIsReady = this.mapItemData:GetUnlockLevelCostIsReady()
    local unlockData = this.mapItemData:GetUnlockLevelIsReady()
    levelUpRed:SetActive(costIsReady and unlockData["AllReady"])
end

--升级家具1
function Panel.UpgradeToolLevel()
    this.mapItemData:UpgradeToolLevel()
    this.UpdateToolUpgradeInfo()
    this.UpdateLevelInfo()
    this.UpdateProductionItem()
    this.UpdatePeopleItem()
    this.UpdateCardViewFunc()
end

--升级家具1
function Panel.UpgradeBoostLevel()
    this.mapItemData:UpgradeBoostLevel()
    this.UpdateBoostUpgradeInfo()
    this.UpdateLevelInfo()
    this.UpdateProductionItem()
    this.UpdatePeopleItem()
    this.UpdateCardViewFunc()
end

function Panel.OnShow(param)
    this.param = param or {}
    this.toolTimer = nil
    this.boostTimer = nil

    this.Init()
    this.InitEvent()
    if not param.noAction then
        this.PlayViewEnterAni(this.CheckTutorialData)
    else
        this.CheckTutorialData()
    end
    this.FingerMoveByTask()

    -- 如果有夜间引导，则自动关闭
    if TutorialManager.currentTutorial and TutorialManager.currentTutorial.__cname == "TutorialNightTalk" then 
        StartCoroutine(function()
            Yield(nil)
            HideUI(UINames.UIBuild)
        end)
    end

    this.UpdateAd()
end

function Panel.CheckTutorialData()
    -- 检测引导
    local function TutorialUpdate(subStep)
        this.CheckTutorial(TutorialManager.CurrentStep.value, subStep)
    end
    this.TutorialSubStepSubscribe = TutorialManager.CurrentSubStep:subscribe(TutorialUpdate)
end

function Panel.Init()
    -- 城市ID
    this.cityId = DataManager.GetCityId()
    local characterNum = CharacterManager.GetCharacterCount(this.cityId)
    -- 区域ID
    this.zoneId = this.param.zoneId--  ConfigManager.GetZoneIdByZoneType(this.cityId, this.param.zoneType)
    -- 区域数据
    this.mapItemData = MapManager.GetMapItemData(this.cityId, this.zoneId)

    -- 初始化标题Item
    this.InitTittleItem()
    -- 刷新生产Item
    this.UpdateProductionItem()
    -- 初始化家具Item
    this.InitFurnitures()

    -- 初始化瞭望塔
    this.InitGuardTower()
    -- 初始化菜谱
    this.InitFoodList()
    -- 初始化医院
    this.InitHealthItem()


    -- 初始化小人分配
    this.InitPeople()
    -- 初始化加班Item
    this.InitOverTimeItem()
    -- 初始化英雄卡牌
    this.InitHeroCard()

    this.startBuildUpgrading = false
    local upgradingItem = SafeGetUIControl(this, "BottomView/UpgradingItem")
    upgradingItem:SetActive(false)
    this.uidata.upgradeItem:SetActive(false)
    -- 如果该建筑正在升级中，则打开升级中面板
    if this.mapItemData:IsUpgrading() then
        this.OnOpenUpgradingZone()
    end

    this.InitLocalize()
end

---初始化加班Item
function Panel.InitOverTimeItem()
    local itemOverTime = SafeGetUIControl(this, "BottomView/Content/ItemOverTime")
    local btn = SafeGetUIControl(itemOverTime, "ImgBtnBg")

    itemOverTime:SetActive(false)
    if FunctionsManager.IsOpen(this.cityId, FunctionsType.WorkOverTime) and this.mapItemData.config.is_work_overtime then
        itemOverTime:SetActive(true)
        SafeAddClickEvent(this.behaviour, btn, function()
            -- 加班开关
            local isActiveWorkOverTime = WorkOverTimeManager.IsActiveWorkOverTimeByZoneId(this.cityId, this.zoneId)
            if isActiveWorkOverTime then
                WorkOverTimeManager.RemoveWorkOverTime(this.cityId, this.zoneId)
            else
                WorkOverTimeManager.AddWorkOverTime(this.cityId, this.zoneId)
            end
            this.UpdateOverTimeItem(true)
        end)
    else
        return
    end

    this.UpdateOverTimeItem()
end

---刷新加班Item
function Panel.UpdateOverTimeItem(isAni)
    local itemOverTime = SafeGetUIControl(this, "BottomView/Content/ItemOverTime")
    local itemOverText = SafeGetUIControl(itemOverTime, "TimeText", "Text")
    local workOverTimeState = WorkOverTimeManager.GetWorkOverTimeState(this.cityId, this.zoneId)
    local isActiveWorkOverTime = WorkOverTimeManager.IsActiveWorkOverTimeByZoneId(this.cityId, this.zoneId)
    --刷新状态信息
    if workOverTimeState == WorkOvertimeState.None then
        if SchedulesManager.IsSchdulesActive(this.cityId, SchedulesType.Sleep) then
            itemOverText.text = GetLang("over_time_state_sleeping")
        else
            itemOverText.text = GetLang("over_time_state_will_sleep")
        end
        this.PlayOverTimeSpine(false)
    elseif workOverTimeState == WorkOvertimeState.Wait then
        local remainTime = WorkOverTimeManager.GetNextOverTimeRemainTime(this.cityId, WorkOvertimeState.Wait)
        itemOverText.text = GetLangFormat("over_time_state_will_work", remainTime)
        this.PlayOverTimeSpine(true)
    elseif workOverTimeState == WorkOvertimeState.Run then
        itemOverText.text = GetLang("over_time_state_working")
        this.PlayOverTimeSpine(true)
    end

    this.SetEnableToggle(SafeGetUIControl(itemOverTime, "ImgBtnBg"), isActiveWorkOverTime, isAni, true)
end
function Panel.PlayOverTimeSpine(isPlay)
    local skel = SafeGetUIControl(this, "BottomView/Content/ItemOverTime/Icon/CzSkel", "SkeletonGraphic")
    if skel.gameObject.activeSelf == isPlay then
        return
    end
    skel.gameObject:SetActive(isPlay)
    if isPlay then
        skel.AnimationState:SetAnimation(0, "animation", true)
    end
end

function Panel.SetEnableToggle(item, enable, isAni, red)
    local btn = SafeGetUIControl(item, "ImgButton", "Image")
    local offsetX = 37
    if isAni then
        btn.transform:DOLocalMoveX(enable and offsetX or -offsetX, 0.2)
    else
        btn.transform.localPosition = Vector3.New(enable and offsetX or -offsetX, 0, 0)
    end

    local txtOn = SafeGetUIControl(item, "TxtOn", "Text")
    local txtOff = SafeGetUIControl(item, "TxtOff", "Text")
    txtOn.color = enable and Color.New(215 / 255, 242 / 255, 184 / 255, 1) or Color.New(58 / 255, 56 / 255, 55 / 255, 1)
    txtOff.color = enable and Color.New(58 / 255, 56 / 255, 55 / 255, 1) or Color.New(243 / 255, 203 / 255, 185 / 255, 1)

    local resName = enable and "com_bt_green_s" or "com_bt_red_s"
    resName = red and resName or "com_bt_green_s"
    Utils.SetIcon(btn,resName)
end

---初始化标题Item
function Panel.InitTittleItem()
    -- 设置建筑图标
    local buildIcon = SafeGetUIControl(this, "BottomView/TitleItem/ImgIcon", "Image")
    local zoneCfg = ConfigManager.GetZoneConfigById(this.zoneId)
    Utils.SetIcon(buildIcon, zoneCfg.zone_type_icon)
    -- 设置建筑名称
    local buildName = SafeGetUIControl(this, "BottomView/TitleItem/TtitleTxtBox/TxtTitle", "Text")
    buildName.text = this.mapItemData:GetUpgradeLevelName()
    -- 更新等级信息
    this.UpdateLevelInfo()
end

---刷新升级面板
function Panel.UpdateUpgradeItem()
    local btnUpgrade = SafeGetUIControl(this, "BottomView/UpgradeItem/BtnGreen", "Button")
    local upgradeContent = SafeGetUIControl(this, "BottomView/UpgradeItem/Content")
    local textUpgrade =  SafeGetUIControl(this, "BottomView/UpgradeItem/BtnGreen/Text", "Text")

    -- 是否有英雄卡牌显示
    local isHeroCard = false

    this.timeAcc = 0
    if this.mapItemData:IsUpgrading() then
        upgradeContent:SetActive(false)
        btnUpgrade.gameObject:SetActive(false)
    else
        upgradeContent:SetActive(true)
        btnUpgrade.gameObject:SetActive(true)
        local unlockData = this.mapItemData:GetUnlockLevelIsReady()
        local costConfig = this.mapItemData:GetUnlockLevelCost()
        local costIsReady = this.mapItemData:GetUnlockLevelCostIsReady()
        local canUpgrade = costIsReady and unlockData["AllReady"]
        GreyObject(btnUpgrade.gameObject, not canUpgrade, canUpgrade, true)
        -- 设置描边颜色
        local greenColor = Color.New(73 / 255, 121 / 255, 52 / 255, 1)
        local grayColor = Color.New(84 / 255, 84 / 255, 84 / 255, 1)
        local outline = textUpgrade:GetComponent("Outline")
        outline.effectColor = canUpgrade and greenColor or grayColor
        if canUpgrade == true then
            this.lastState = "CanUpgrade"
        else
            this.lastState = "DontUpgrade"
        end
        local upgradeWarning = SafeGetUIControl(this, "BottomView/UpgradeItem/Warning")
        upgradeWarning:SetActive(false)
        if unlockData["AllReady"] ~= true then
            upgradeWarning:SetActive(true)
            local upgradeWarningText = SafeGetUIControl(this, "BottomView/UpgradeItem/Warning/Text", "Text")
            local unlockLevelConfig = this.mapItemData:GetUnlockLevelConfig()
            if unlockLevelConfig["ZoneLevel"] then
                for zid, lv in pairs(unlockLevelConfig["ZoneLevel"]) do
                    local zoneName = MapManager.GetMapItemData(this.cityId, zid):GetLevelName(lv)
                    upgradeWarningText.text = GetLangFormat("UI_Building_Build_Block", zid, zoneName, lv)
                    ForceRebuildLayoutImmediate(upgradeWarning)

                    SafeAddClickEvent(this.behaviour, upgradeWarning, function ()
                        -- local zoneId = MapManager.GetSlideNextZoneId(this.cityId, zid)
                        local build = CityModule.getMainCtrl().buildDict[zid]
                        this.HideUI(true)                        
                        CityModule.getMainCtrl():ShowBuildViewNoAction(build.data)

                    end)
                    break
                end
            end
        end

        for i = 1, 3 do
            local item = SafeGetUIControl(upgradeContent, "Item" .. i)
            item:SetActive(false)
        end

        local index = 0
        local costList = Utils.SortItems(costConfig)
        costList:ForEach(
            function(itemData)
                index = index + 1
                local item = SafeGetUIControl(upgradeContent, "Item" .. index)
                item:SetActive(true)
                local itemIcon = SafeGetUIControl(item, "Image", "Image")
                local itemText = SafeGetUIControl(item, "Text", "Text")
                Utils.SetItemIcon(itemIcon, itemData.itemId)
                if DataManager.GetMaterialCount(this.cityId, itemData.itemId) >= itemData.count then
                    itemText.text =
                        DataManager.GetMaterialCountFormat(this.cityId, itemData.itemId) ..
                        "/" .. Utils.FormatCount(itemData.count)
                else
                    itemText.text =
                        Utils.RichText(DataManager.GetMaterialCountFormat(this.cityId, itemData.itemId), "#EE5D5D") ..
                        "/" .. Utils.FormatCount(itemData.count)
                end
            end
        )

        local timeText = SafeGetUIControl(upgradeContent, "Item4/Text", "Text")
        timeText.text = Utils.GetTimeFormat2(this.mapItemData:GetBuildDuration())
    end
end

---刷新建筑等级文本
function Panel.UpdateBuildLevel()
    local level = this.mapItemData:GetLevel()
    local isBuildMaxLevel = level >= this.mapItemData.config.max_level
    local buildLevel = SafeGetUIControl(this, "BottomView/TitleItem/TtitleTxtBox/TxtLevel", "Text")
    buildLevel.text = isBuildMaxLevel and " Max" or " " .. GetLangFormat("Lv" .. level)
    ForceRebuildLayoutImmediate(buildLevel.transform.parent.gameObject)
end

function Panel.UpdateProductionDorm()
    local item = SafeGetUIControl(this.uidata.itemProduction, "Dorm")
    item:SetActive(true)
    local dormPeople = this.mapItemData:GetDormPeople()
    local peopleWorkState = CharacterManager.GetPeopleStateCount(this.cityId, this.zoneId)
    local normalCount = peopleWorkState[EnumState.Normal] or 0
    local sickCount = peopleWorkState[EnumState.Sick] or 0
    local protestCount = peopleWorkState[EnumState.Protest] or 0

    -- 人数文本
    local peopleText = SafeGetUIControl(item, "Item1/TxtValue", "Text")
    peopleText.text = (normalCount + sickCount + protestCount) .. "/" .. dormPeople
    -- 人数图标列表
    for i = 1, 8 do
        local peopleBox = SafeGetUIControl(item, "Item1/ManBox")
        local peopleIcon = SafeGetUIControl(peopleBox, "ManItem" .. i)

        local state = EnumState.None
        if i <= normalCount then
            state = EnumState.Normal
        elseif i <= (normalCount + sickCount) then
            state = EnumState.Sick
        elseif i <= (normalCount + sickCount + protestCount) then
            state = EnumState.Protest
        else
            state = "Wating"
        end
        peopleIcon:SetActive(dormPeople >= i)
        local peopleInner = SafeGetUIControl(peopleIcon, "Inner")
        peopleInner:SetActive((normalCount + sickCount + protestCount) >= i)
    end

    -- 时间
    local timeText = SafeGetUIControl(item, "Item2/TxtValue", "Text")
    local usageDuration = this.mapItemData:GetToolUsageDuration()
    timeText.text = Utils.GetTimeFormat2(usageDuration)

    -- 产出
    local provideText = SafeGetUIControl(item, "Item3/TxtValue", "Text")
    local provideIcon = SafeGetUIControl(item, "Item3/Icon", "Image")
    local necessities = this.mapItemData:GetSingleNecessitiesInfo()
    for nectItem, count in pairs(necessities) do
        Utils.SetAttributeIcon(provideIcon, nectItem, function ()
            provideIcon:SetNativeSize()
        end)

        if nectItem == "CureRate" then
            UIUtil.AddTitleToolTip(
                provideIcon,
                GetLang("UI_Infirmary_Heal_Rate_Desc"),
                GetLang("UI_Infirmary_Heal_Rate")
            )
            provideText.text = Utils.FormatCount(count * 100) .. "%"
        else
            UIUtil.AddAttribute(provideIcon, nectItem, true)
            provideText.text = Utils.FormatCount(count)
        end
    end
end
function Panel.UpdateProductionKitchen()
    local item = SafeGetUIControl(this.uidata.itemProduction, "Kitchen")
    item:SetActive(true)
    -- 需要原材料
    local needIcon = SafeGetUIControl(item, "Item1/Icon", "Image")
    local needTxt = SafeGetUIControl(item, "Item1/TxtValue", "Text")
    local ingredients = this.mapItemData:GetKitchenIngredients()
    for inItem, count in pairs(ingredients) do
        Utils.SetItemIcon(needIcon, inItem, nil, true)
        needTxt.text = Utils.FormatCount(count)
        UIUtil.AddItem(needIcon, inItem, ToolTipDir.Left, true)
        break
    end

    -- 产出
    local necessities = this.mapItemData:GetKitchenNecessitiesInfo()
    local index = 0
    for nectItem, count in pairs(necessities) do
        index = index + 1
        local provideIcon = SafeGetUIControl(item, "Item4/Icon" .. index, "Image")
        local provideTxt = SafeGetUIControl(item, "Item4/Icon" .. index .. "/TxtValue", "Text")
        Utils.SetAttributeIcon(provideIcon, nectItem, function ()
            provideIcon:SetNativeSize()
        end)
        if nectItem == "CureRate" then
            UIUtil.AddTitleToolTip(
                provideIcon,
                GetLang("UI_Infirmary_Heal_Rate_Desc"),
                GetLang("UI_Infirmary_Heal_Rate")
            )
            provideTxt.text = Utils.FormatCount(count * 100) .. "%"
        else
            UIUtil.AddAttribute(provideIcon, nectItem, true)
            provideTxt.text = Utils.FormatCount(count)
        end
    end

    -- 食物
    local foodIcon = SafeGetUIControl(item, "Item3/Icon", "Image")
    local foodTxt = SafeGetUIControl(item, "Item3/TxtValue", "Text")
    local viewFoodType = FoodSystemManager.GetFoodType(this.cityId)
    Utils.SetItemIcon(foodIcon, viewFoodType, nil, true)
    UIUtil.AddItem(foodIcon, viewFoodType, ToolTipDir.Up, true)

    -- 时间
    local timeText = SafeGetUIControl(item, "Item2/TxtValue", "Text")
    local usageDuration = this.mapItemData:GetToolUsageDuration()
    timeText.text = Utils.GetTimeFormat2(usageDuration)
end

function Panel.UpdateProductionHunterCabin()
    local item = SafeGetUIControl(this.uidata.itemProduction, "HunterCabin")
    item:SetActive(true)
    -- 时间
    local timeText = SafeGetUIControl(item, "Item1/TxtValue", "Text")
    local usageDuration = this.mapItemData:GetToolUsageDuration()
    timeText.text = Utils.GetTimeFormat2(usageDuration)

    -- 产出
    local provideIcon = SafeGetUIControl(item, "Item2/Icon", "Image")
    local provideTxt = SafeGetUIControl(item, "Item2/TxtValue", "Text")
    local outputItemData = this.mapItemData:GetOutputInfo()
    Utils.SetItemIcon(provideIcon, outputItemData.itemId, nil, true)
    provideTxt.text = Utils.FormatCount(outputItemData.count)
    UIUtil.AddItem(provideIcon, outputItemData.itemId, nil, true)
end

function Panel.UpdateProductionInfirmary()
    local item = SafeGetUIControl(this.uidata.itemProduction, "Infirmary")
    item:SetActive(true)

    -- 产出
    local provideIcon = SafeGetUIControl(item, "Item1/Icon", "Image")
    local provideTxt = SafeGetUIControl(item, "Item1/TxtValue", "Text")
    local necessities = this.mapItemData:GetSingleRecoverRewardInfo()
    local index = 0
    for nectItem, count in pairs(necessities) do
        index = index + 1
        Utils.SetAttributeIcon(provideIcon, nectItem)
        if nectItem == "CureRate" then
            provideTxt.text = Utils.FormatCount(count * 100) .. "%"
            UIUtil.AddTitleToolTip(
                provideIcon,
                GetLang("UI_Infirmary_Heal_Rate_Desc"),
                GetLang("UI_Infirmary_Heal_Rate")
            )
        else
            provideTxt.text = Utils.FormatCount(count)
            UIUtil.AddAttribute(provideIcon, nectItem, true)
        end
    end

    -- 刷新病床
    this.UpdateHealthItem()
end

function Panel.UpdateProductionWatchtower()
    local item = SafeGetUIControl(this.uidata.itemProduction, "Watchtower")
    item:SetActive(true)

    --安全屋
    local boostReward = this.mapItemData:GetBoostRewardInfo()
    -- 产出
    local provideIcon = SafeGetUIControl(item, "Item1/Icon", "Image")
    local provideTxt = SafeGetUIControl(item, "Item1/TxtValue", "Text")
    for boostId, count in pairs(boostReward) do
        Utils.SetAttributeIcon(provideIcon, boostId)
        UIUtil.AddAttribute(provideIcon, boostId)
        provideTxt.text = string.format("%.2f", (count * 100)) .. "%"
    end

    this.UpdateGuardTowerItem()
end

function Panel.UpdateProductionProduct()
    local item = SafeGetUIControl(this.uidata.itemProduction, "Product")
    item:SetActive(true)
    -- 时间
    local timeText = SafeGetUIControl(item, "Item2/TxtValue", "Text")
    local usageDuration = this.mapItemData:GetToolUsageDuration()
    timeText.text = Utils.GetTimeFormat2(usageDuration)

    -- 产出
    local provideIcon = SafeGetUIControl(item, "Item3/Content/Icon1", "Image")
    local provideTxt = SafeGetUIControl(item, "Item3/Content/Icon1/TxtValue", "Text")
    local outputItemData = this.mapItemData:GetOutputInfo()
    Utils.SetItemIcon(provideIcon, outputItemData.itemId, nil, true)
    provideTxt.text = Utils.FormatCount(outputItemData.count)
    UIUtil.AddItem(provideIcon, outputItemData.itemId)

    -- 需要原材料
    local input = this.mapItemData:GetInputInfo()
    local inputList = Utils.SortItems(input)
    for i = 1, 3 do
        local icon = SafeGetUIControl(item, "Item1/Content/Icon" .. i, "Image")
        icon.gameObject:SetActive(false)
    end
    local index = 0
    inputList:ForEach(
        function(itemData)
            index = index + 1
            local icon = SafeGetUIControl(item, "Item1/Content/Icon" .. index, "Image")
            if icon then
                Utils.SetItemIcon(icon, itemData.itemId, nil, true)
                local txt = SafeGetUIControl(item, "Item1/Content/Icon" .. index .. "/TxtValue", "Text")
                txt.text = Utils.FormatCount(itemData.count)
            end
        end
    )

    local item1 = SafeGetUIControl(item, "Item1")
    local arrow1 = SafeGetUIControl(item, "Arrow1")
    local item2 = SafeGetUIControl(item, "Item2")
    local item3 = SafeGetUIControl(item, "Item3")
    item1:SetActive(index > 0)
    arrow1:SetActive(index > 0)
    if index == 0 then
        item.transform.anchoredPosition = Vector3(-82, 0, 0)
    else
        item.transform.anchoredPosition = Vector3(0, 0, 0)
    end

    local inputContent = SafeGetUIControl(item, "Item1/Content")
    ForceRebuildLayoutImmediate(inputContent)
end
---刷新生产Item
function Panel.UpdateProductionItem()
    UIUtil.HideGameObjectChild(this.uidata.itemProduction)

    local function CheckProductionItem(name, callback)
        if this.uidata.itemProduction.transform:Find(name) then
            if callback then
                callback()
            end
        else
            ResInterface.SyncLoadGameObject(name, function(_go)
                local item = GOInstantiate(_go, this.uidata.itemProduction.transform)
                item.name = name
                if callback then
                    callback()
                end
                this.InitLocalize()
            end)
        end
    end

    if this.param.zoneType == ZoneType.Dorm then
        CheckProductionItem("Dorm", this.UpdateProductionDorm)
    elseif this.param.zoneType == ZoneType.Kitchen then
        CheckProductionItem("Kitchen", this.UpdateProductionKitchen)
    elseif this.param.zoneType == ZoneType.HunterCabin then
        CheckProductionItem("HunterCabin", this.UpdateProductionHunterCabin)
    elseif this.mapItemData.config.zone_type == ZoneType.Infirmary then
        CheckProductionItem("Infirmary", this.UpdateProductionInfirmary)
    elseif this.mapItemData.config.zone_type == ZoneType.Watchtower then
        CheckProductionItem("Watchtower", this.UpdateProductionWatchtower)
    elseif this.mapItemData:IsProductType() then
        CheckProductionItem("Product", this.UpdateProductionProduct)
    end
end

---初始化家具Item
function Panel.InitFurnitures()
    local furniture_1 = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1")
    local furniture_2 = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2")
    if this.mapItemData:IsHaveToolFurniture() then
        -- this.ToolProgressBar.value = 1
        furniture_1:SetActive(true)
        this.UpdateToolUpgradeInfo(true)
    else
        furniture_1:SetActive(false)
    end
    if this.mapItemData:IsHaveBoostFurniture() then
        -- this.ToolProgressBar.value = 1
        furniture_2:SetActive(true)
        this.UpdateBoostUpgradeInfo(true)
    else
        furniture_2:SetActive(false)
    end
end

---初始化瞭望塔
function Panel.InitGuardTower()
    local itemGuardTower = SafeGetUIControl(this, "BottomView/Content/ItemGuardTower")
    itemGuardTower:SetActive(this.param.zoneType == ZoneType.Watchtower and this.mapItemData:GetIsNeedCard())
    if this.param.zoneType ~= ZoneType.Watchtower then
        return
    end

    -- 刷新瞭望塔Item
    this.UpdateGuardTowerItem()
end

---刷新瞭望塔Item
function Panel.UpdateGuardTowerItem()
    local itemGuardTower = SafeGetUIControl(this, "BottomView/Content/ItemGuardTower")
    local icon = SafeGetUIControl(itemGuardTower, "TowerIcon", "Image")
    local text = SafeGetUIControl(itemGuardTower, "Text", "Text")
    local iconArr = {"riots_bad_stop", "riots_normal_talk", "riots_good_peace"}
    local appeaseIndex = ProtestManager.GetUnlockAppeaseIndex(this.cityId)
    Utils.SetCommonIcon(icon, iconArr[appeaseIndex])
    text.text = GetLang("UI_Building_Info_Appease_" .. appeaseIndex)
end

---初始化菜谱
function Panel.InitFoodList()
    local itemFoodList = SafeGetUIControl(this, "BottomView/Content/ItemFoodList")
    itemFoodList:SetActive(this.param.zoneType == ZoneType.Kitchen and this.mapItemData:GetIsNeedCard())
    if this.param.zoneType ~= ZoneType.Kitchen then
        return
    end

    -- 刷新菜谱Item
    this.UpdateFoodListItem()
end

---刷新菜谱Item
function Panel.UpdateFoodListItem()
    local foodListName = SafeGetUIControl(this, "BottomView/Content/ItemFoodList/Text", "Text")
    local viewFoodType = FoodSystemManager.GetFoodType(this.cityId)
    foodListName.text = GetLang(ConfigManager.GetItemConfig(viewFoodType).name_key)
end

---初始化患者Item
function Panel.InitHealthItem()
    local itemHealth = SafeGetUIControl(this, "BottomView/Content/ItemHealth")
    itemHealth:SetActive(this.param.zoneType == ZoneType.Infirmary)
    if this.param.zoneType ~= ZoneType.Infirmary then
        return
    end

    -- 刷新患者Item
    this.UpdateHealthItem()
end

---刷新患者Item
function Panel.UpdateHealthItem()
    local itemHealth = SafeGetUIControl(this, "BottomView/Content/ItemHealth")
    local bedText = SafeGetUIControl(itemHealth, "Bed/Num", "Text")
    local dormBedText = SafeGetUIControl(itemHealth, "Beds/Num", "Text")

    local infirmarySicks = CharacterManager.GetCharactersBySickZone(this.cityId, ZoneType.Infirmary)
    local dormSicks = CharacterManager.GetCharactersBySickZone(this.cityId, ZoneType.Dorm)
    bedText.text = infirmarySicks:Count()
    dormBedText.text = dormSicks:Count()
end

---初始化小人分配
function Panel.InitPeople()
    --是否可分配小人
    this.peopleConfig = ConfigManager.GetPeopleConfigByZoneType(this.cityId, this.mapItemData.config.zone_type)
    local peopleItem = SafeGetUIControl(this, "BottomView/Content/ItemPeople")
    peopleItem:SetActive(false)
    if this.peopleConfig ~= nil then
        peopleItem:SetActive(true)
        this.UpdatePeopleItem()
    end
end

---初始化英雄卡片
function Panel.InitHeroCard()
    this.uidata.hero = SafeGetUIControl(this, "Hero")
    this.uidata.btnHeroCard = SafeGetUIControl(this, "Hero/Btn", "Button")
    this.uidata.heroImage = SafeGetUIControl(this, "Hero/HeroImage", "Image")
    this.uidata.heroTag = SafeGetUIControl(this, "Hero/Info/TxtTag", "Text")
    this.uidata.heroValue = SafeGetUIControl(this, "Hero/Info/TxtValue", "Text")
    this.uidata.heroLevel = SafeGetUIControl(this, "Hero/Info/ImgTitle/TxtLevel", "Text")
    this.uidata.heroLevelName = SafeGetUIControl(this, "Hero/Info/ImgTitle/TxtTag", "Text")
    this.uidata.icon = SafeGetUIControl(this, "Hero/Info/Icon", "Image")
    this.uidata.heroSingleValue = SafeGetUIControl(this, "Hero/Info/TxtSingleValue", "Text")

    SafeAddClickEvent(this.behaviour, this.uidata.btnHeroCard.gameObject, function()
        this.OnClickHeroFun()
    end)

    this.UpdateCardView()
end

---刷新英雄卡牌
function Panel.UpdateCardView()
    -- this.LockState:SetActive(false)
    -- this.UnlockState:SetActive(false)
    -- this.gameObject:SetActive(true)
    this.uidata.btnHeroCard.gameObject:SetActive(true)
    GreyObject(this.uidata.heroImage.gameObject, false, true)

    local heroInfo = SafeGetUIControl(this, "Hero/Info")
    heroInfo:SetActive(false)
    local lockInfo = SafeGetUIControl(this, "Hero/LockInfo")
    lockInfo:SetActive(false)

    if this.mapItemData:GetIsNeedCard() then
        TimeModule.addDelay(0, function()
            this.uidata.hero:SetActive(true)
        end)

        Utils.SetCardHeroHalfPic(this.uidata.heroImage, this.mapItemData:GetDefaultCardId())
        if this.mapItemData:GetCardId() == 0 then
            -- this.LockState:SetActive(true)
            -- Utils.SetImageGray(this.HeroIcon)
            -- this.uidata.btnHeroCard.gameObject:SetActive(false)
            lockInfo:SetActive(true)
            GreyObject(this.uidata.heroImage.gameObject, true, false)
            GreyObject(lockInfo, true, false, true)
        else
            -- this.UnlockState:SetActive(true)
            this.SetCardView(this.mapItemData:GetCardId())
            -- this:RefreshCardRedDot()
        end
    else
        this.uidata.hero:SetActive(false)
    end
end

function Panel.SetCardView(cardId)
    local cardItemData = CardManager.GetCardItemData(cardId)
    local config = ConfigManager.GetCardConfig(cardId)
    local level = cardItemData:GetLevel()
    local levelUpSpine = SafeGetUIControl(this, "Hero/Info/ImgTitle/LevelUpSpine")
    local canUpgrade = cardItemData:IsCanUpgradeLevel()
    local imgBg = SafeGetUIControl(this, "Hero/Info/ImgBg")

    levelUpSpine.gameObject:SetActive(canUpgrade)

    local heroInfo = SafeGetUIControl(this, "Hero/Info")
    heroInfo:SetActive(true)

    this.uidata.heroLevel.text = level
    this.uidata.heroTag.gameObject:SetActive(true)
    this.uidata.heroValue.gameObject:SetActive(true)
    this.uidata.heroSingleValue.gameObject:SetActive(false)
    if this.mapItemData.config.zone_type == ZoneType.Kitchen then
        --厨房
        local foodType = FoodSystemManager.GetFoodType(this.cityId)
        local foodConfig = ConfigManager.GetFoodConfigByType(foodType)
        Utils.SetItemIcon(this.uidata.icon, foodType, nil, true)
        this.uidata.heroSingleValue.text = GetLang(foodConfig.name_key)
        local width = this.uidata.heroSingleValue.preferredWidth
        local isOverWidth = width > 150
        imgBg.transform.sizeDelta = Vector2(imgBg.transform.sizeDelta.x, isOverWidth and 500 or 400)

        this.uidata.heroTag.gameObject:SetActive(false)
        this.uidata.heroValue.gameObject:SetActive(false)
        this.uidata.heroSingleValue.gameObject:SetActive(true)
    elseif this.mapItemData.config.zone_type == ZoneType.Infirmary then
        --医院
        Utils.SetIcon(this.uidata.icon, "icon_health", nil, true)
        this.uidata.heroTag.gameObject:SetActive(false)
        this.uidata.heroValue.gameObject:SetActive(false)
        this.uidata.heroSingleValue.gameObject:SetActive(true)
        this.uidata.heroSingleValue.text = cardItemData:GetCardBoostEffectShow()

        local width = this.uidata.heroSingleValue.preferredWidth
        local isOverWidth = width > 150
        imgBg.transform.sizeDelta = Vector2(imgBg.transform.sizeDelta.x, isOverWidth and 500 or 400)
    elseif this.mapItemData.config.zone_type == ZoneType.Watchtower then
        --安全屋
        local iconArr = { "riots_bad_stop", "riots_normal_talk", "riots_good_peace" }

        this.uidata.heroTag.gameObject:SetActive(false)
        this.uidata.heroValue.gameObject:SetActive(false)
        this.uidata.heroSingleValue.gameObject:SetActive(true)
        Utils.SetCommonIcon(this.uidata.icon, iconArr[ProtestManager.GetUnlockAppeaseIndex(this.cityId)])
        this.uidata.heroSingleValue.text =
            GetLangFormat("UI_Building_Info_Appease_short", ProtestManager.GetUnlockAppeaseIndex(this.cityId))

        local width = this.uidata.heroSingleValue.preferredWidth
        local isOverWidth = width > 150
        imgBg.transform.sizeDelta = Vector2(imgBg.transform.sizeDelta.x, isOverWidth and 500 or 400)
    elseif this.mapItemData.config.zone_type == ZoneType.Generator then
        --火炉
        Utils.SetItemIcon(this.uidata.icon, GeneratorManager.GetConsumptionItemId(this.cityId), nil, true)
        this.uidata.heroTag.text = GetLang("UI_generator_consume")
        this.uidata.heroValue.text = cardItemData:GetCardBoostEffectShow()
    elseif this.mapItemData:IsProductType() then
        --原材料产出
        local output = this.mapItemData:GetOutputInfo()
        Utils.SetItemIcon(this.uidata.icon, output.itemId, nil, true)
        this.uidata.heroTag.text = GetLang("UI_Building_Info_Output")
        this.uidata.heroValue.text = cardItemData:GetCardBoostEffectShow()
    end
end

function Panel.OnClickHeroFun()
    if this.mapItemData:GetIsNeedCard() then
        if this.mapItemData:GetCardId() == 0 then
            UIUtil.showConfirmByData({
                DescriptionRaw = GetLang("ui_go_to_shop"),
                Title = "ui_need_hero",
                ShowYes = true,
                ShowNo = true,
                YesCallback = function(toggle)
                    -- PopupManager.Instance:CloseAllPanel()
                    -- PopupManager.Instance:OpenPanel(PanelType.ShopPanel)
                    ShowUI(UINames.UIShop)
                end,
                OnNoFunc = function(toggle)

                end
            }
            )
        else
            ShowUI(UINames.UIHeroInfo, {
                cardItemData = CardManager.GetCardItemData(this.mapItemData:GetCardId()),
                from = "UIBuild"
            })

            -- PopupManager.Instance:OpenSubPanel(
            --     PopupManager.Instance.currentPanel,
            --     PanelType.CardInfoPanel,
            --     {
            --         cardItemData = CardManager.GetCardItemData(this.cardId),
            --         from = "BuildPanel"
            --     }
            -- )
        end
    end
end

---刷新小人分配Item
function Panel.UpdatePeopleItem()
    if this.peopleConfig == nil then
        return
    end
    local btnAdd = SafeGetUIControl(this, "BottomView/Content/ItemPeople/BtnAdd", "Button")
    local btnReduce = SafeGetUIControl(this, "BottomView/Content/ItemPeople/BtnReduce", "Button")

    local zoneType = this.peopleConfig.zone_type
    local furnitureId = this.peopleConfig.furniture_id
    local unlockIndexs = MapManager.GetUnlockFurnitureIndexs(this.cityId, zoneType, furnitureId)
    local canUseToolCount = this.mapItemData:GetCanUseToolCount()
    local peopleWorkState = CharacterManager.GetPeopleStateCount(this.cityId, this.peopleConfig.type)
    local normalCount = peopleWorkState[EnumState.Normal] or 0
    local sickCount = peopleWorkState[EnumState.Sick] or 0
    local protestCount = peopleWorkState[EnumState.Protest] or 0
    local maxCount = math.min(unlockIndexs:Count(), canUseToolCount)
    local totalCount = normalCount + sickCount + protestCount

    local canAdd = totalCount < maxCount
    local canReduce = totalCount > 0
    GreyObject(btnAdd.gameObject, not canAdd, canAdd)
    GreyObject(btnReduce.gameObject, not canReduce, canReduce)
    this.workStateList = List:New()
    for i = 1, unlockIndexs:Count(), 1 do
        local grid = GridManager.GetGridByFurnitureId(this.cityId, furnitureId, unlockIndexs[i], GridStatus.Unlock)
        if grid then
            local state = grid:GetFurnitureWorkState()
            this.workStateList:Add(grid:GetFurnitureWorkState())
        else
        end
    end
    this.workStateList:Sort(
        function(s1, s2)
            if s1 == s2 then
                return false
            end
            return s1 < s2
        end
    )

    this.PeopleItemList = List:New()
    for i = 1, 6 do
        local item = SafeGetUIControl(this, "BottomView/Content/ItemPeople/ManBox/Item" .. i)
        local redManIcon = SafeGetUIControl(item, "RedMan", "Image")
        local greenManIcon = SafeGetUIControl(item, "GreenMan", "Image")
        local stateIcon = SafeGetUIControl(item, "State", "Image")
        local lockManIcon = SafeGetUIControl(item, "ImageLock", "Image")
        redManIcon.gameObject:SetActive(false)
        greenManIcon.gameObject:SetActive(false)
        stateIcon.gameObject:SetActive(false)
        lockManIcon.gameObject:SetActive(false)
        item:SetActive(false)
    end
    for i = 1, this.workStateList:Count(), 1 do
        local workState = WorkStateType.None
        local hasPeople = true
        if i <= normalCount then
            workState = this.workStateList[i]
        elseif i <= normalCount + sickCount then
            if this.workStateList[i] ~= WorkStateType.Disable then
                workState = WorkStateType.Sick
            else
                workState = this.workStateList[i]
            end
        elseif i <= normalCount + sickCount + protestCount then
            if this.workStateList[i] ~= WorkStateType.Disable then
                workState = WorkStateType.Protest
            else
                workState = this.workStateList[i]
            end
        else
            hasPeople = false
            if this.workStateList[i] ~= WorkStateType.Work then
                workState = this.workStateList[i]
            end
        end

        -- local view = ResourceManager.Instantiate(this.BuildPanelPeopleItemPrefab, this.PeopleListContent)
        -- local item = BuildPanelPeopleItem:Create(view)
        -- if workState == WorkStateType.Disable then
        --     item:SetCardNeedLevel(this.mapItemData:GetFurnitureNeedCardLevel(this.mapItemData:GetToolFurnitureId(), i))
        -- end
        local item = SafeGetUIControl(this, "BottomView/Content/ItemPeople/ManBox/Item" .. i)
        if item == nil then
            return
        end

        item:SetActive(true)
        local redManIcon = SafeGetUIControl(item, "RedMan", "Image")
        local greenManIcon = SafeGetUIControl(item, "GreenMan", "Image")
        local stateIcon = SafeGetUIControl(item, "State", "Image")
        local lockManIcon = SafeGetUIControl(item, "ImageLock", "Image")
        local lockText = SafeGetUIControl(item, "ImageLock/TextLock", "Text")
        local needLevel = this.mapItemData:GetFurnitureNeedCardLevel(this.mapItemData:GetToolFurnitureId(), i)

        local StateResName = "icon_worker_subscript_riots"
        if workState == WorkStateType.None then
            -- this.StateText.text = GetLang("UI_People_Unemployed")
            redManIcon.gameObject:SetActive(false)
            greenManIcon.gameObject:SetActive(false)
            lockManIcon.gameObject:SetActive(false)
            -- this.StateText:SelectColor(2)
            stateIcon.gameObject:SetActive(false)
        elseif workState == WorkStateType.Work then
            -- this.StateText.text = GetLang("UI_People_Working")
            redManIcon.gameObject:SetActive(false)
            greenManIcon.gameObject:SetActive(true)
            lockManIcon.gameObject:SetActive(false)
            -- this.StateText:SelectColor(2)
            stateIcon.gameObject:SetActive(false)
        elseif workState == WorkStateType.Disable then
            stateIcon.gameObject:SetActive(false)
            lockManIcon.gameObject:SetActive(true)
            lockText.text = needLevel
            -- this.CardLock:SetActive(true)
            -- this.NeedLevelText.text = this.needLevel
            if hasPeople then
                ---- this.StateText:SelectColor(1)
                ---- this.StateText.text = GetLang("UI_People_Sick")
                --stateIcon.gameObject:SetActive(true)
                redManIcon.gameObject:SetActive(true)
                greenManIcon.gameObject:SetActive(false)
                ---- this.NeedLevelText.text = ""
                UIUtil.AddToolTip(lockManIcon, GetLangFormat("ui_card_level_require_tips", needLevel))
            else
                -- this.StateText:SelectColor(2)
                -- this.StateText.text = GetLang("UI_People_Unemployed")
                stateIcon.gameObject:SetActive(false)
                -- this.Icon:SelectSprite(3)
                UIUtil.AddToolTip(lockManIcon, GetLangFormat("ui_card_level_require_tips", needLevel))
            end
        elseif workState == WorkStateType.Pause then
            StateResName = "icon_worker_subscript_pause"
            stateIcon.gameObject:SetActive(true)
            lockManIcon.gameObject:SetActive(false)
            if hasPeople then
                -- this.StateText:SelectColor(1)
                -- this.StateText.text = GetLang("UI_People_Sick")
                redManIcon.gameObject:SetActive(true)
                greenManIcon.gameObject:SetActive(false)
                UIUtil.AddToolTip(redManIcon, GetLang("ui_survivor_status_desc_2"))
            else
                -- this.StateText:SelectColor(2)
                -- this.StateText.text = GetLang("UI_People_Unemployed")
                redManIcon.gameObject:SetActive(false)
                greenManIcon.gameObject:SetActive(false)
            end
        elseif workState == WorkStateType.Sick then
            redManIcon.gameObject:SetActive(true)
            greenManIcon.gameObject:SetActive(false)
            stateIcon.gameObject:SetActive(true)
            lockManIcon.gameObject:SetActive(false)
            StateResName = "icon_worker_subscript_treatmet"
            UIUtil.AddToolTip(redManIcon, GetLang("ui_survivor_status_desc_4"))
        elseif workState == WorkStateType.Protest then
            redManIcon.gameObject:SetActive(true)
            greenManIcon.gameObject:SetActive(false)
            StateResName = "icon_worker_subscript_riots"
            -- this.StateText:SelectColor(1)
            -- this.StateText.text = GetLang("UI_People_Sick")
            stateIcon.gameObject:SetActive(true)
            UIUtil.AddToolTip(redManIcon, GetLang("ui_survivor_status_desc_5"))
        end

        Utils.SetIcon(stateIcon, StateResName)
    end
end

---刷新家具1信息
function Panel.UpdateToolUpgradeInfo(noSliderAction)
    local textLevel = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/TxtLevel", "Text")
    local textName = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/TxtLevel/TxtName", "Text")
    local itemIcon = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/ItemIcon", "Image")
    local warning = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/Warning")
    local warningTxt = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/Warning/Text", "Text")
    local btnLevelUp = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/Button", "Button")
    local imgLevelUp = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/Button", "Image")
    local productionIcon = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/ProductionIcon", "Image")
    local productionText = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/ProductionIcon/TxtValue", "Text")
    local cost = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/Cost")
    local costIcon = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/Cost/Icon", "Image")
    local costText = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/Cost/Text", "Text")
    local nextLevelIcon = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/Slider/Icon", "Image")
    local nextLevelRed = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/Slider/Red")
    local nextLevelTxt = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/Slider/Red/Text", "Text")
    local slider = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/Slider", "Slider")
    local sliderFollow = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_1/SliderFollow", "Slider")

    nextLevelIcon.gameObject:SetActive(false)
    nextLevelRed:SetActive(false)

    local lv = this.mapItemData:GetToolLevel()
    local ms, msMinLv, msMaxLv = this.mapItemData:GetToolMilestone()
    local maxLv = this.mapItemData:GetToolMaxLevel()

    -- 刷新家具图标
    local furnitureIconName = this.mapItemData:GetToolFurnitureIconName()
    Utils.SetFurnitureIcon(itemIcon, furnitureIconName)

    -- 刷新title
    local selectFurnitureId, findex = this.mapItemData:GetToolLastFurnitureId()
    local namekey = ConfigManager.GetFurnitureById(selectFurnitureId).name_key
    textName.text = GetLang(ConfigManager.GetFurnitureById(selectFurnitureId).name_key)
    textLevel.text = GetLangFormat("Lv" .. lv)

    if this.rxId1 ~= nil then
        this.rxId1:unsubscribe()
        this.rxId1 = nil
    end

    productionIcon.gameObject:SetActive(false)
    if msMaxLv ~= nil then
        if lv >= maxLv then
            warning:SetActive(true)
            warningTxt.text = GetLangFormat("UI_Building_Info_Block", this.mapItemData:GetToolNeedLevel())
            GreyObject(btnLevelUp.gameObject, true, false, true)
            imgLevelUp.raycastTarget = false
            this.CleanLevelUpPressTimer(1)
            costIcon.gameObject:SetActive(false)
            costText.text = "-"
        else
            warning:SetActive(false)
            costIcon.gameObject:SetActive(true)
            local costIsReady = this.mapItemData:GetToolUpgradeCostIsReady()
            local buildCost = this.mapItemData:GetToolUpgradeCost()
            Utils.SetItemIcon(costIcon, buildCost.itemId)
            if this.mapItemData:IsProductType() and this.mapItemData:GetOutputInfo().itemId == buildCost.itemId then
                UIUtil.AddItem(costIcon, buildCost.itemId, nil, true)
            else
                UIUtil.AddItem(costIcon, buildCost.itemId, nil, true)
            end
            GreyObject(btnLevelUp.gameObject, not costIsReady, costIsReady, true)
            imgLevelUp.raycastTarget = costIsReady
            if not costIsReady then
                this.CleanLevelUpPressTimer(1)
            end
            this.rxId1 =
                DataManager.GetMaterialRx(this.cityId, buildCost.itemId):subscribe(
                    function(val)
                        local _costIsReady = this.mapItemData:GetToolUpgradeCostIsReady()
                        GreyObject(btnLevelUp.gameObject, not _costIsReady, _costIsReady, true)
                        imgLevelUp.raycastTarget = _costIsReady
                        if not _costIsReady then
                            this.CleanLevelUpPressTimer(1)
                        end
                        if _costIsReady then
                            costText.text =
                                DataManager.GetMaterialCountFormat(this.cityId, buildCost.itemId) ..
                                "/" .. Utils.FormatCount(buildCost.count)
                        else
                            costText.text =
                                Utils.RichText(DataManager.GetMaterialCountFormat(this.cityId, buildCost.itemId),
                                    "#b41212") ..
                                "/" .. Utils.FormatCount(buildCost.count)
                        end
                    end
                )

            -- 刷新下一级奖励
            local nextReward = this.mapItemData:GetToolMilestoneNextReward()
            if nextReward ~= nil then
                if nextReward.type == "UnlockFurniture" then
                    nextLevelIcon.gameObject:SetActive(true)
                    nextLevelRed:SetActive(true)
                    Utils.SetFurnitureIcon(nextLevelIcon, this.mapItemData:GetToolFurnitureIconName(msMaxLv))
                    nextLevelTxt.text = "+" .. nextReward.count
                elseif nextReward.type == "AddOutput" then
                    nextLevelIcon.gameObject:SetActive(true)
                    nextLevelRed:SetActive(true)
                    local output = this.mapItemData:GetToolOutput()
                    Utils.SetItemIcon(nextLevelIcon, output.itemId)
                    nextLevelTxt.text = "x" .. nextReward.count
                end
            end

            -- 刷新提供的东西
            if lv + 1 <= maxLv then
                if this.mapItemData:IsProductType() then
                    --生产建筑
                    local output = this.mapItemData:GetToolOutput()
                    local nextOutput = this.mapItemData:GetToolOutput(lv + 1)
                    if lv + 1 == msMaxLv then
                        output = this.mapItemData:GetToolOutput(lv - 1)
                        nextOutput = this.mapItemData:GetToolOutput()
                    end
                    Utils.SetItemIcon(productionIcon, output.itemId, nil, true)
                    productionText.text = "+" .. Utils.FormatCount(nextOutput.count - output.count)
                elseif this.mapItemData.config.zone_type == ZoneType.Kitchen then
                    --厨房
                    local nowTime = this.mapItemData:GetToolUsageDuration()
                    local nextTime = this.mapItemData:GetToolUsageDuration(lv + 1)
                    if nowTime ~= nextTime then
                        Utils.SetIcon(productionIcon, "colliery_icon_time", nil, true)
                        productionText.text = Utils.GetTimeFormat2(nextTime - nowTime)
                    end
                elseif this.mapItemData.config.zone_type == ZoneType.Dorm then
                    --宿舍
                    local neces = this.mapItemData:GetToolNecessitiesInfo()
                    local nextNeces = this.mapItemData:GetToolNecessitiesInfo(lv + 1)
                    for nectItem, count in pairs(neces) do
                        if nextNeces[nectItem] ~= count then
                            Utils.SetAttributeIcon(productionIcon, nectItem)
                            productionText.text = "+" .. Utils.FormatCount(nextNeces[nectItem] - count)
                        end
                        break
                    end
                elseif this.mapItemData.config.zone_type == ZoneType.Infirmary then
                    --医院
                    local neces = this.mapItemData:GetToolRecoverRewardInfo()
                    local nextNeces = this.mapItemData:GetToolRecoverRewardInfo(lv + 1)
                    for nectItem, count in pairs(neces) do
                        if nextNeces[nectItem] ~= count then
                            Utils.SetAttributeIcon(productionIcon, nectItem)
                            productionText.text =
                                "+" .. Utils.FormatCount((nextNeces[nectItem] - count) * 100) .. "%"
                        end
                        break
                    end
                end
            end
        end
        local p = (lv - msMinLv) / (msMaxLv - msMinLv)
        
        slider.value = p
        if noSliderAction then
            sliderFollow.value = p
        else
            Util.TweenTo(sliderFollow.value, p, 0.5, function (value)
                sliderFollow.value = value
            end)
        end
    else
        costText.text = "-"
        costIcon.gameObject:SetActive(false)
        warning:SetActive(false)
        slider.value = 1
        if noSliderAction then
            sliderFollow.value = 1
        else
            Util.TweenTo(sliderFollow.value, 1, 0.5, function (value)
                sliderFollow.value = value
            end)
        end
        GreyObject(btnLevelUp.gameObject, true, false, true)
        this.CleanLevelUpPressTimer(1)
        imgLevelUp.raycastTarget = false
    end
end

---刷新家具2信息
function Panel.UpdateBoostUpgradeInfo(noSliderAction)
    local textLevel = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/TxtLevel", "Text")
    local textName = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/TxtLevel/TxtName", "Text")
    local itemIcon = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/ItemIcon", "Image")
    local warning = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/Warning")
    local warningTxt = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/Warning/Text", "Text")
    local btnLevelUp = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/Button", "Button")
    local imgLevelUp = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/Button", "Image")
    local productionIcon = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/ProductionIcon", "Image")
    local productionText = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/ProductionIcon/TxtValue", "Text")
    local cost = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/Cost")
    local costIcon = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/Cost/Icon", "Image")
    local costText = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/Cost/Text", "Text")
    local nextLevelIcon = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/Slider/Icon", "Image")
    local nextLevelRed = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/Slider/Red")
    local nextLevelTxt = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/Slider/Red/Text", "Text")
    local slider = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/Slider", "Slider")
    local sliderFollow = SafeGetUIControl(this, "BottomView/Content/ItemFurniture_2/SliderFollow", "Slider")

    nextLevelIcon.gameObject:SetActive(false)
    nextLevelRed:SetActive(false)

    local lv = this.mapItemData:GetBoostLevel()
    local ms, msMinLv, msMaxLv = this.mapItemData:GetBoostMilestone()
    local maxLv = this.mapItemData:GetBoostMaxLevel()

    local namsse = this.mapItemData:GetBoostFurnitureIconName()
    -- 刷新家具图标
    Utils.SetFurnitureIcon(itemIcon, this.mapItemData:GetBoostFurnitureIconName())

    -- 刷新title
    local selectFurnitureId, findex = this.mapItemData:GetBoostLastFurnitureId()
    local namekey = ConfigManager.GetFurnitureById(selectFurnitureId).name_key
    textName.text = GetLang(ConfigManager.GetFurnitureById(selectFurnitureId).name_key)
    textLevel.text = GetLangFormat("Lv" .. lv)

    if this.rxId2 ~= nil then
        this.rxId2:unsubscribe()
        this.rxId2 = nil
    end

    productionIcon.gameObject:SetActive(false)
    if msMaxLv ~= nil then
        if lv >= maxLv then
            warning:SetActive(true)
            warningTxt.text = GetLangFormat("UI_Building_Info_Block", this.mapItemData:GetBoostNeedLevel())
            GreyObject(btnLevelUp.gameObject, true, false, true)
            imgLevelUp.raycastTarget = false
            this.CleanLevelUpPressTimer(2)
            costIcon.gameObject:SetActive(false)
            costText.text = "-"
        else
            warning:SetActive(false)
            costIcon.gameObject:SetActive(true)
            local costIsReady = this.mapItemData:GetBoostUpgradeCostIsReady()
            local buildCost = this.mapItemData:GetBoostUpgradeCost()
            Utils.SetItemIcon(costIcon, buildCost.itemId)
            if this.mapItemData:IsProductType() and this.mapItemData:GetOutputInfo().itemId == buildCost.itemId then
                UIUtil.AddItem(costIcon, buildCost.itemId, nil, true)
            else
                UIUtil.AddItem(costIcon, buildCost.itemId, nil, true)
            end
            GreyObject(btnLevelUp.gameObject, not costIsReady, costIsReady, true)
            imgLevelUp.raycastTarget = costIsReady
            if not costIsReady then
                this.CleanLevelUpPressTimer(2)
            end
            this.rxId2 =
                DataManager.GetMaterialRx(this.cityId, buildCost.itemId):subscribe(
                    function(val)
                        local _costIsReady = this.mapItemData:GetBoostUpgradeCostIsReady()
                        GreyObject(btnLevelUp.gameObject, not _costIsReady, _costIsReady, true)
                        imgLevelUp.raycastTarget = _costIsReady
                        if not _costIsReady then
                            this.CleanLevelUpPressTimer(2)
                        end

                        if _costIsReady then
                            costText.text =
                                DataManager.GetMaterialCountFormat(this.cityId, buildCost.itemId) ..
                                "/" .. Utils.FormatCount(buildCost.count)
                        else
                            costText.text =
                                Utils.RichText(DataManager.GetMaterialCountFormat(this.cityId, buildCost.itemId),
                                    "#b41212") ..
                                "/" .. Utils.FormatCount(buildCost.count)
                        end
                    end
                )

            -- 刷新下一级奖励
            local nextReward = this.mapItemData:GetBoostMilestoneNextReward()
            if nextReward ~= nil then
                if nextReward.type == "UnlockFurniture" then
                    nextLevelIcon.gameObject:SetActive(true)
                    nextLevelRed:SetActive(true)
                    Utils.SetFurnitureIcon(nextLevelIcon, this.mapItemData:GetBoostFurnitureIconName(msMaxLv))
                    nextLevelTxt.text = "+" .. nextReward.count
                elseif nextReward.type == "AddFurniture" then
                    nextLevelIcon.gameObject:SetActive(true)
                    nextLevelRed:SetActive(true)
                    -- local output = this.mapItemData:GetBoostOutput()
                    Utils.SetFurnitureIcon(nextLevelIcon, this.mapItemData:GetBoostFurnitureIconName(msMaxLv))
                    nextLevelTxt.text = "NEW"
                end
            end

            -- 刷新提供的东西
            if lv + 1 <= maxLv then
                if this.mapItemData:IsProductType() then
                    --生产建筑
                    if this.mapItemData.config.zone_type == ZoneType.HunterCabin then
                        local output = this.mapItemData:GetBoostOutput()
                        local nextOutput = this.mapItemData:GetBoostOutput(lv + 1)
                        Utils.SetItemIcon(productionIcon, output.itemId, nil, true)

                        productionText.text = "+" .. string.format("%.2f", nextOutput.count - output.count)
                    else
                        local usageDuration = this.mapItemData:GetBoostUsageDuration()
                        local nextUsageDuration = this.mapItemData:GetBoostUsageDuration(lv + 1)
                        if usageDuration ~= nextUsageDuration then
                            Utils.SetIcon(productionIcon, "colliery_icon_time", nil, true)
                            productionText.text = Utils.GetTimeFormat2(nextUsageDuration - usageDuration)
                        end
                    end
                elseif this.mapItemData.config.zone_type == ZoneType.Kitchen then
                    --厨房
                    local neces = this.mapItemData:GetBoostNecessitiesInfo()
                    local nextNeces = this.mapItemData:GetBoostNecessitiesInfo(lv + 1)
                    for nectItem, count in pairs(neces) do
                        if nextNeces[nectItem] ~= count then
                            Utils.SetAttributeIcon(productionIcon, nectItem)
                            productionText.text = "+" .. Utils.FormatCount(nextNeces[nectItem] - count)
                        end
                        break
                    end
                elseif this.mapItemData.config.zone_type == ZoneType.Dorm then
                    --宿舍
                    local neces = this.mapItemData:GetBoostNecessitiesInfo()
                    local nextNeces = this.mapItemData:GetBoostNecessitiesInfo(lv + 1)
                    for nectItem, count in pairs(neces) do
                        if nextNeces[nectItem] ~= count then
                            Utils.SetAttributeIcon(productionIcon, nectItem)
                            productionText.text = "+" .. Utils.FormatCount(nextNeces[nectItem] - count)
                        end
                        break
                    end
                elseif this.mapItemData.config.zone_type == ZoneType.Infirmary then
                    --医院
                    local neces = this.mapItemData:GetBoostRecoverRewardInfo()
                    local nextNeces = this.mapItemData:GetBoostRecoverRewardInfo(lv + 1)
                    for nectItem, count in pairs(neces) do
                        if nextNeces[nectItem] ~= count then
                            Utils.SetAttributeIcon(productionIcon, nectItem)
                            productionText.text =
                                "+" .. Utils.FormatCount((nextNeces[nectItem] - count) * 100) .. "%"
                        end
                        break
                    end
                elseif this.mapItemData.config.zone_type == ZoneType.Watchtower then
                    --安全屋
                    local boostReward = this.mapItemData:GetBoostRewardInfo()
                    local nextBoostReward = this.mapItemData:GetBoostRewardInfo(lv + 1)
                    for boostId, count in pairs(boostReward) do
                        if nextBoostReward[boostId] ~= count then
                            Utils.SetAttributeIcon(productionIcon, boostId)
                            UIUtil.AddAttribute(productionIcon, boostId)
                            productionText.text =
                                "+" .. string.format("%.2f", ((nextBoostReward[boostId] - count) * 100)) .. "%"
                        end
                    end
                end
            end
        end
        local p = (lv - msMinLv) / (msMaxLv - msMinLv)
        slider.value = p
        if noSliderAction then
            sliderFollow.value = p
        else
            Util.TweenTo(sliderFollow.value, p, 0.5, function (value)
                sliderFollow.value = value
            end)
        end
    else
        costText.text = "-"
        warning:SetActive(false)
        costIcon.gameObject:SetActive(false)
        slider.value = 1
        if noSliderAction then
            sliderFollow.value = 1
        else
            Util.TweenTo(sliderFollow.value, 1, 0.5, function (value)
                sliderFollow.value = value
            end)
        end
        GreyObject(btnLevelUp.gameObject, true, false, true)
        imgLevelUp.raycastTarget = false
        this.CleanLevelUpPressTimer(2)
    end
end

function Panel.OnPeopleAddButton()
    if CharacterManager.Assignment(this.cityId, this.peopleConfig.type) then
        -- Analytics.Event(
        --     "PeopleAssign",
        --     {
        --         from = "zonePeoplePanel",
        --         workerType = this.peopleConfig.type,
        --         workingPeople = workCount,
        --         notWorkingPeople = notWorkCount,
        --         unassignPeople = restCount,
        --         totalPeople = CharacterManager.GetCharacterMaxCount(this.cityId)
        --     }
        -- )
        -- this:RefreshPeopleRedDot()
        -- local workCount, notWorkCount, restCount = CharacterManager.GetPeopleWorkStateCount(this.cityId)
     else
        UIUtil.showText(GetLang("toast_no_freeman"))
        --     GameToast.Instance:Show(GetLang("toast_no_freeman"), ToastIconType.Warning)
    end
    this.UpdatePeopleItem()
    this.UpdateProductionItem()
end

function Panel.OnPeopleSubtractButton()
    if CharacterManager.CancelAssignment(this.cityId, this.peopleConfig.type) then
        -- this:RefreshPeopleRedDot()
        -- local workCount, notWorkCount, restCount = CharacterManager.GetPeopleWorkStateCount(this.cityId)
        -- Analytics.Event(
        --     "PeopleUnassign",
        --     {
        --         from = "zonePeoplePanel",
        --         workerType = this.peopleConfig.type,
        --         workingPeople = workCount,
        --         notWorkingPeople = notWorkCount,
        --         unassignPeople = restCount,
        --         totalPeople = CharacterManager.GetCharacterMaxCount(this.cityId)
        --     }
        -- )
    end
    this.UpdatePeopleItem()
    this.UpdateProductionItem()
end

function Panel.HideUI(noAction)
    this.uidata.btnAd.gameObject:SetActive(false)
    if noAction then
        this.HideUIBuild()
        return
    end
    this.PlayViewExitAni()
end

function Panel.HideUIBuild()
    HideUI(UINames.UIBuild)
end

function Panel.OnHide()
    this.CleanLevelUpPressTimer(1)
    this.CleanLevelUpPressTimer(2)
    if this.TutorialSubStepSubscribe ~= nil then
        this.TutorialSubStepSubscribe:unsubscribe()
    end
    if this.rxId1 ~= nil then
        this.rxId1:unsubscribe()
        this.rxId1 = nil
    end
    if this.rxId2 ~= nil then
        this.rxId2:unsubscribe()
        this.rxId2 = nil
    end
end

function Panel.PlayViewEnterAni(callBack)
    local bottomView = SafeGetUIControl(this, "BottomView")
    local canvasGroup = bottomView:GetComponent("CanvasGroup")
    local acTime = 0.25

    this.initBottomLocalPosition = this.initBottomLocalPosition or bottomView.transform.localPosition
    -- Y轴上升出现
    bottomView.transform.localPosition = this.initBottomLocalPosition + Vector3.New(0, -200, 0)
    local tween = bottomView.transform:DOLocalMoveY(this.initBottomLocalPosition.y, acTime):SetEase(Ease.OutBack)
    -- 透明度渐变出现
    canvasGroup.alpha = 0

    tween:OnComplete(function()
        if callBack then
            callBack()
        end
    end)

    local startX = this.uidata.hero.transform.localPosition.x
    local heroY = this.uidata.hero.transform.localPosition.y
    this.uidata.hero.transform.localPosition = Vector3(startX - 370, heroY, 0)

    local seq = DOTween.Sequence()
    seq:Append(Util.TweenTo(0, 1, acTime, function(value)
        canvasGroup.alpha = value
    end):SetEase(Ease.OutCubic))
    seq:Join(this.uidata.hero.transform:DOLocalMoveX(startX, acTime):SetEase(Ease.OutCubic))
    seq:AppendCallback(function()
        -- this.uidata.hero:SetActive(true)
    end)
end

function Panel.PlayViewExitAni()
    EventManager.Brocast(EventDefine.OnClickExitCityBuild)
    local bottomView = SafeGetUIControl(this, "BottomView")
    local canvasGroup = bottomView:GetComponent("CanvasGroup")
    local acTime = 0.25

    this.uidata.hero:SetActive(false)

    local seq = DOTween.Sequence()
    -- Y轴下移消失
    bottomView.transform.localPosition = this.initBottomLocalPosition
    seq:Append(bottomView.transform:DOLocalMoveY(this.initBottomLocalPosition.y - 200, acTime):SetEase(Ease.InBack))
    -- 透明度渐变消失
    canvasGroup.alpha = 1

    seq:Join(Util.TweenTo(1, 0, acTime, function(value)
        canvasGroup.alpha = value
    end))

    seq:AppendCallback(function()
        this.HideUIBuild()
    end)
end

-- 任务跳转
function Panel.FingerMoveByTask()
    SafeSetActive(this.uidata.AddSkele, false)
    SafeSetActive(this.uidata.LvUpSkele, false)
    SafeSetActive(this.uidata.ToolUpSkele, false)
    SafeSetActive(this.uidata.BoostUpSkele, false)

    if not TaskManager.IsFromTaskPanel(this.cityId, this.param) then
        return
    end

    if GameManager.TutorialOpen then
        return
    end

    local target
    local animation = "animation"
    local taskConfig = ConfigManager.GetTaskConfig(this.param.extented.taskId)
    if taskConfig.action == "UPGRADE_FURNITURE" or taskConfig.action == "SURVIVOR_COUNT" or taskConfig.action == "UPGRADE_TARGET_FURNITURE" then
        animation = "animation2"
        target = this.uidata.ToolUpSkele
        if taskConfig.action == "UPGRADE_TARGET_FURNITURE" and string.find(taskConfig.task.furnitureId, "Boost") then
            animation = "animation2"
            target = this.uidata.BoostUpSkele
        end
    elseif taskConfig.action == "CHARACTER_PROFESSION_CHANGE" then
        animation = "animation3"
        target = this.uidata.AddSkele
    elseif taskConfig.action == "UPGRADE_ZONE" then
        animation = "animation"
        target = this.uidata.LvUpSkele
    else
        return
    end

    SafeSetActive(target, true)

    local actSkel = target:GetComponent("SkeletonGraphic")
    if actSkel then
        actSkel.AnimationState:SetAnimation(0, animation, false):AddOnComplete(function()
            SafeSetActive(target, false)
        end)
    end
end

--刷新引导
function Panel.CheckTutorial(step, subStep)
    this.step = step
    if step == TutorialStep.BuildSawmill then
        local step = 7
        if subStep == step then
            TutorialManager.NextSubStep(0.1)
        elseif subStep == step + 1 then
            this.TutorialClickUpgradeButton(4, false, "Tutorial_BuildLumberMill_notice_3")
        elseif subStep == step + 2 then
            TutorialManager.NextSubStep(0.1)
        elseif subStep == step + 3 then
            this.TutorialClickPeopleAddButton(2, "Tutorial_BuildLumberMill_notice_6")
        elseif subStep == step + 4 then
            this:TutorialClickOverlay()
        end
    elseif step == TutorialStep.BuildKitchen then
        local step = 9
        if subStep == step then
            TutorialManager.NextSubStep(0.1)
        elseif subStep == step + 1 then
            TutorialManager.NextSubStep(0.1)
        elseif subStep == step + 2 then
            local clickCallBack = function()
                TutorialHelper.CameraLockUp(
                    {
                        maskType = TutorialMaskType.None,
                        stopTime = 2,
                        callBack = function()
                            TutorialManager.NextSubStep()
                        end
                    }
                )
            end
            this.TutorialClickPeopleAddButton(1, "Tutorial_BuildKitchen_notice_4", clickCallBack)
        elseif subStep == step + 3 then
            this.TutorialClickOverlay()
        end
    elseif step == TutorialStep.BuildHunterCabin then
        local step = 7
        if subStep == step then
            TutorialManager.NextSubStep(0.1)
        elseif subStep == step + 1 then
            this.TutorialClickPeopleAddButton(1, "Tutorial_BuildCattleFarm_notice_2")
        elseif subStep == step + 2 then
            this.TutorialClickOverlay()
        end
    end
end

--引导升级按钮
function Panel.TutorialClickUpgradeButton(count, needMove, noticeKey)

    this.UpgradeCount = 1

    TutorialHelper.FingerMove(
        {
            maskType = TutorialMaskType.None,
            noticeKey = noticeKey,
            noticePos = this.TutorialPos,
            fingerPoint = Utils.GetLocalPointInRectangleByUI(this.uidata.ToolUpgradeButton.gameObject),
            fingerSize = this.uidata.ToolUpgradeButton.gameObject.transform.sizeDelta,
            fingerFunc = function()

                
                SDKAnalytics.TraceEvent(110 + this.UpgradeCount)

                this.UpgradeToolLevel()
                Audio.PlayAudio(DefaultAudioID.ToolUpgrade)

                this.UpgradeCount = this.UpgradeCount + 1

            end,
            fingerCount = count,
            fingerMove = needMove,
            callBack = TutorialManager.NextSubStep
        }
    )
end

--引导选择Item
function Panel.TutorialClickItem(item, needMove, noticeKey)
    TutorialHelper.FingerMove(
        {
            maskType = TutorialMaskType.None,
            noticeKey = noticeKey,
            noticePos = this.TutorialPos,
            fingerPoint = Utils.GetLocalPointInRectangleByUI(item.ClickButton),
            fingerSize = item.ClickButton.transform.sizeDelta,
            fingerMove = needMove,
            fingerFunc = function()
                this:ItemClick(item)
            end,
            callBack = TutorialManager.NextSubStep
        }
    )
end

-- 加人
function Panel.TutorialClickPeopleAddButton(count, noticeKey, clickCallBack)
    this.addCount = 1

    TutorialHelper.FingerMove(
        {
            maskType = TutorialMaskType.None,
            noticeKey = noticeKey,
            noticePos = this.TutorialPos,
            fingerPoint = Utils.GetLocalPointInRectangleByUI(SafeGetUIControl(this, "BottomView/Content/ItemPeople/BtnAdd").gameObject),
            fingerSize = SafeGetUIControl(this, "BottomView/Content/ItemPeople/BtnAdd").gameObject.transform.sizeDelta,
            fingerCount = count,
            fingerMove = true,
            fingerFunc = function()
                if this.step == TutorialStep.BuildSawmill then
                    SDKAnalytics.TraceEvent(114 + this.addCount)
                elseif this.step == TutorialStep.BuildKitchen then
                    SDKAnalytics.TraceEvent(124)
                    this.PlayKitchenEffect()
                elseif this.step == TutorialStep.BuildHunterCabin then
                    SDKAnalytics.TraceEvent(136)
                end

                this.OnPeopleAddButton()

                this.addCount = this.addCount + 1
            end,
            callBack = function()
                if this.step == TutorialStep.BuildSawmill then
                    SDKAnalytics.TraceEvent(117)
                elseif this.step == TutorialStep.BuildKitchen then
                    SDKAnalytics.TraceEvent(125)
                elseif this.step == TutorialStep.BuildHunterCabin then
                end

                if clickCallBack == nil then
                    TutorialManager.NextSubStep()
                else
                    clickCallBack()
                end
            end
        }
    )
end

--引导点击选择卡牌
function Panel.TutorialClickSelectCardButton(count, noticeKey)
    TutorialHelper.FingerMove(
        {
            maskType = TutorialMaskType.None,
            noticeKey = noticeKey,
            noticePos = this.TutorialPos,
            fingerPoint = Utils.GetLocalPointInRectangleByUI(this.SelectCardButton),
            fingerSize = this.SelectCardButton.transform.sizeDelta,
            fingerCount = count,
            fingerMove = true,
            fingerFunc = function()
                this:OnSelectCardFun()
            end,
            callBack = TutorialManager.NextSubStep
        }
    )
end

--点击空白区域
function Panel.TutorialClickOverlay(forceSave, needFinger)
    if needFinger then
        TutorialHelper.FingerMove(
            {
                maskType = TutorialMaskType.None,
                fingerPoint = Vector2(0, 500),
                fingerSize = Vector2(600, 600),
                fingerMove = true,
                fingerFunc = function()
                    this.HideUI()
                end,
                callBack = function()
                    TutorialManager.NextSubStep(0.3, forceSave)
                end
            }
        )
    else
        this.HideUI()
        TutorialManager.NextSubStep(0.3, forceSave)
    end
end

-- 播放厨房食物亮光
function Panel.PlayKitchenEffect()
    local Skele1 = SafeGetUIControl(this, "BottomView/Content/ItemProduction/Kitchen/Skele1")
    local Skele2 = SafeGetUIControl(this, "BottomView/Content/ItemProduction/Kitchen/Skele2")
    local sp1 = SafeGetUIControl(this, "BottomView/Content/ItemProduction/Kitchen/Skele1", "SkeletonGraphic")
    local sp2 = SafeGetUIControl(this, "BottomView/Content/ItemProduction/Kitchen/Skele2", "SkeletonGraphic")
    SafeSetActive(Skele1, true)
    SafeSetActive(Skele2, true)
    if sp1 then
        sp1.AnimationState:SetAnimation(0, "animation", true):AddOnComplete(function()
            -- SafeSetActive(Skele1, false)
        end)
    end
    if sp2 then
        sp2.AnimationState:SetAnimation(0, "animation", true):AddOnComplete(function()
            -- SafeSetActive(Skele2, false)
        end)
    end

    TimeModule.addDelay(2, function()   
        SafeSetActive(Skele1, false)
        SafeSetActive(Skele2, false)
    end)
end

-- 显示净化器燃料不足警告弹窗
function Panel.ShowGeneratorEveryWarnning(itemId, sonsumeCount, callback)
    local isShow = PlayerModule.getGeneratorEverydayWarnning()
    -- 判断燃料是否足够
    if isShow then 
        local result = GeneratorManager.IsToLack(this.cityId, itemId, sonsumeCount)
        if result.isLock then 
            ShowUI(UINames.UIMessageBox, {
                Title = "ui_alert_title",
                DescriptionRaw = GetLang("Popup_Overload_Building", result.minute),
                
                ShowYes = true,
                YesCallback = function (toggleIsOn)
                    PlayerModule.setGeneratorEverydayWarnning(toggleIsOn)
                    if callback then 
                        callback()
                    end
                end,

                ShowNo = true,
                NoCallback = function (toggleIsOn) 
                    PlayerModule.setGeneratorEverydayWarnning(toggleIsOn)
                end,

                ShowToggle = true,
                ToggleDefault = false,
                ToggleText = "Popup_Overload_Check",
            })
        else 
            if callback then 
                callback()
            end
        end
    else
        if callback then 
            callback()
        end
    end
end

-- 广告
function Panel.OnClickBtnAD()
    AdManager.ShowConfirmDialog(AdSourceType.UIBuildFoold, function()
        -- 观看广告成功
        AdManager.AddCount(AdSourceType.UIBuildFoold)
        this.UpdateAd()
        this.GetAdReward()
    end, function()
        -- 取消观看
    end)
end

-- 更新广告
function Panel.UpdateAd()
    if this.mapItemData.config.zone_type ~= ZoneType.Kitchen then
        this.uidata.btnAd.gameObject:SetActive(false)
        return 
    end

    local watchCount, maxCount, remainCount = AdManager.GetCount(AdSourceType.UIBuildFoold)
    this.uidata.btnAd.gameObject:SetActive(watchCount < maxCount)

    local _, rewardStr = AdManager.GetMaxCountAndRewardFromConfig(AdSourceType.UIBuildFoold)
    local reward = Utils.ParseReward(rewardStr)

    this.uidata.btnAdRewardNum.text = "+"..reward[1].count
end

-- 获取广告奖励
function Panel.GetAdReward()
    local _, rewardStr = AdManager.GetMaxCountAndRewardFromConfig(AdSourceType.UIBuildFoold)
    local reward = Utils.ParseReward(rewardStr)

    ResAddEffectManager.AddResEffectFromRewards(reward, true)
    -- 厨房食物
    FoodSystemManager.AddFoodCount(this.cityId, reward[1].count)
end