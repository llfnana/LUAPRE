---@class UIBuildUnlockPanel : UIPanelBase
local Panel = UIPanelBaseMake()
local this = Panel
UIBuildUnlockPanel = Panel

function Panel.OnAwake()
    this.cachedata = {}
    this.InitPanel()
    

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}  
    this.uidata.clickMask = SafeGetUIControl(this, "ClickMask") 
    this.uidata.btnClose = SafeGetUIControl(this, "BottomView/TitleItem/BtnClose")
    this.uidata.btnClose2 = SafeGetUIControl(this, "BottomView2/TitleItem/BtnClose")
    this.uidata.warning = SafeGetUIControl(this, "Warning")
    this.uidata.warningText = SafeGetUIControl(this, "Warning/Text", "Text")

    this.uidata.upgradingTimeText = SafeGetUIControl(this, "BottomView2/BuildProgress/Slider/Text", "Text")
    this.uidata.upgradingSlider = SafeGetUIControl(this, "BottomView2/BuildProgress/Slider", "Slider")

    this.uidata.costText = SafeGetUIControl(this, "BottomView2/Cost/Text", "Text")
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.clickMask, function ()
        EventManager.Brocast(EventDefine.OnClickExitCityBuild)
        this.PlayViewExitAni()
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.btnClose, function ()
        EventManager.Brocast(EventDefine.OnClickExitCityBuild)
        this.PlayViewExitAni()
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.btnClose2, function ()
        EventManager.Brocast(EventDefine.OnClickExitCityBuild)
        this.PlayViewExitAni()
    end)

    local btnBuild = SafeGetUIControl(this, "BottomView/BtnUpgrade", "Button")
    SafeAddClickEvent(this.behaviour, btnBuild.gameObject, function ()
        -- -- 弹窗检测
        local reuslt = this.mapItemData:GetUnlockLevelConsume()
        this.ShowGeneratorEveryWarnning(reuslt.itemId, reuslt.count, function() 
            -- 建造建筑打点
            if this.zoneId == "C1_Dorm_3" then
                SDKAnalytics.TraceEvent(150)
            elseif this.zoneId == "C1_Carpentry_1" then
                SDKAnalytics.TraceEvent(152)
            elseif this.zoneId == "C2_Kitchen_1" then
                SDKAnalytics.TraceEvent(159)
            elseif this.zoneId == "C2_CoalMine_1" then
                SDKAnalytics.TraceEvent(160)
            elseif this.zoneId == "C2_HunterCabin_1" then
                SDKAnalytics.TraceEvent(161)
            elseif this.zoneId == "C2_CollectionStation_1" then
                SDKAnalytics.TraceEvent(162)
            end
            this.OnUnlockBuildFun()
        end)
    end)

    local btnBuildSpeedUp = SafeGetUIControl(this, "BottomView2/BtnBuildSpeedUp", "Button")
    SafeAddClickEvent(this.behaviour, btnBuildSpeedUp.gameObject, function ()
        local status = this.mapItemData:GetBuildStatus()
        if
            ShopManager.CheckSubscriptionValid(ShopManager.SubscriptionType.City) and
            DataManager.GetMaterialCount(this.cityId, ItemType.BuildTicket) > 0 and
            ConfigManager.GetMiscConfig("building_ticket_switch")
        then
            if this.mapItemData:UseTicketSpeedBuildUpgradeComplete() == false then
                return
            end
        else
            local completeFunc = function()
            end
            if status == "Building" then
                if this.mapItemData:SpeedBuildComplete(completeFunc) == false then
                    return
                end
            end
        end
    end)

    this.AddListener(EventType.TIME_CITY_UPDATE, function()
        local status = this.mapItemData:GetBuildStatus()

        if status == "Building" then
            this.UpdateProgress()
        end
    end)

    this.AddListener(EventType.UPGRADE_ZONE, function (cityId, zoneId)
        if cityId == this.cityId and zoneId == this.zoneId then
            EventManager.Brocast(EventDefine.OnClickExitCityBuild)
            this.PlayViewExitAni()
        end
    end)
end

function Panel.OnUnlockBuildFun()
    local onSuccess = function()
        CityModule.getMainCtrl():RefreshBuildingActive()
        EventManager.Brocast(EventDefine.OnClickExitCityBuild)
        this.PlayViewExitAni()
        -- AudioManager.PlayEffect("ui_builing_working")
    end
    


    this.mapItemData:UnlockZone(
        function(success)
            if success then
                onSuccess()
            end
        end,
        this
    )
end

function Panel.OnShow(param)
    this.param = param or {}

    HideUI(UINames.UIBuild)

    this.Init()
    this.InitEvent()
end

function Panel.Init()
    this.cityId = DataManager.GetCityId()
    this.zoneId = this.param.zoneId
    this.backToBuild = this.param.from == "BuildPanel"
    this.mapItemData = MapManager.GetMapItemData(this.cityId, this.zoneId)
    local status = this.mapItemData:GetBuildStatus()

    if status == "Building" then
        this.bottomView = SafeGetUIControl(this, "BottomView2")
        this.bottomView:SetActive(true)
        SafeGetUIControl(this, "BottomView"):SetActive(false)
        this.UpdateProgress()

        -- 设置建筑图标
        local buildIcon = SafeGetUIControl(this, "BottomView2/TitleItem/ImgIcon", "Image")
        local zoneCfg = ConfigManager.GetZoneConfigById(this.zoneId)
        Utils.SetIcon(buildIcon, zoneCfg.zone_type_icon)

        this.ClearTimer()
        this.timer = TimeModule.addRepeatSec(function()
            this.uidata.costText.text = this.mapItemData:GetSpeedCost()
        end)
    else
        this.ClearTimer()
        this.bottomView = SafeGetUIControl(this, "BottomView")
        this.bottomView:SetActive(true)
        SafeGetUIControl(this, "BottomView2"):SetActive(false)
        -- 初始化标题Item
        this.InitTittleItem()
        -- 初始化建筑Item
        this.InitBuildItem()
        -- 初始化建造成本
        this.InitBuildCost()
    end

    this.PlayViewEnterAni()
end

function Panel.UpdateProgress()
    this.lfTime, this.lfTotal = this.mapItemData:GetBuildLeftTime()
    this.uidata.upgradingTimeText.text = Utils.GetTimeFormat3(this.lfTime)
    local p = 1 - this.lfTime / this.lfTotal
    Util.TweenTo(this.uidata.upgradingSlider.value, p, 0.25, function(value)
        this.uidata.upgradingSlider.value = value
    end)
    if this.lfTime <= 0 then
        EventManager.Brocast(EventDefine.OnClickExitCityBuild)
        this.PlayViewExitAni()
    end
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

    ForceRebuildLayoutImmediate(buildName.transform.parent.gameObject)
end
---初始化建筑Item
function Panel.InitBuildItem()
    local buildIcon = SafeGetUIControl(this, "BottomView/UnlockBuildings/Build/Image", "Image")
    local provideIcon = SafeGetUIControl(this, "BottomView/UnlockBuildings/Build/ImgProduction", "Image")

    -- 临时代码
    local level = 1 -- this.mapItemData:GetLevel() + 1
    Utils.SetZoneIcon(buildIcon, this.zoneId, 1)
    local bonus = this.mapItemData:GetZoneBonus()
    local bonusIcon = nil
    local bonusLang = nil
    if bonus ~= nil then 
        local tryItem = string.match(bonus, "item_(%w+)")
        local tryIcon = string.match(bonus, "attr_(%w+)")
        
        if tryItem ~= nil then
            Utils.SetItemIcon(provideIcon, tryItem, nil, true)
            bonusLang = "UI_Building_Build_Product"
            -- ToolTipManager.AddItem(this.BonusIcon, tryItem, ToolTipDir.Up, true)
        elseif tryIcon ~= nil then
            Utils.SetAttributeIcon(provideIcon, tryIcon)
            bonusLang = "UI_Hospital_Build_Improve"
            -- ToolTipManager.AddAttribute(this.BonusIcon, tryIcon, false, ToolTipDir.Up)
        end
    end 
end

---初始化建造成本Item
function Panel.InitBuildCost()
    local btnBuild = SafeGetUIControl(this, "BottomView/BtnUpgrade", "Button")

    local status = this.mapItemData:GetBuildStatus()
    this.ItemList = List:New()
    local unlockData = this.mapItemData:GetUnlockLevelIsReady()
    local costConfig = this.mapItemData:GetUnlockLevelCost()
    local costIsReady = this.mapItemData:GetUnlockLevelCostIsReady()
    local canUpgrade = costIsReady and unlockData["AllReady"]

    this.uidata.warning:SetActive(not unlockData["AllReady"])
    local unlockLevelConfig = this.mapItemData:GetUnlockLevelConfig()
    if unlockLevelConfig and unlockLevelConfig["ZoneLevel"] then
        for zid, lv in pairs(unlockLevelConfig["ZoneLevel"]) do
            local zoneName = MapManager.GetMapItemData(this.cityId, zid):GetLevelName(lv)
            this.uidata.warningText.text = GetLangFormat("UI_Building_Build_Block", zid, zoneName, lv)
            ForceRebuildLayoutImmediate(this.uidata.warning)
            break
        end
    end

    GreyObject(btnBuild.gameObject, not canUpgrade, canUpgrade)
    this.lastState = canUpgrade == true and "CanUpgrade" or "DontUpgrade"

    -- if unlockData["AllReady"] ~= true then
    --     this.WarningText.gameObject:SetActive(true)
    --     local unlockLevelConfig = this.mapItemData:GetUnlockLevelConfig()
    --     if unlockLevelConfig["ZoneLevel"] then
    --         for zid, lv in pairs(unlockLevelConfig["ZoneLevel"]) do
    --             local zoneName = MapManager.GetMapItemData(this.cityId, zid):GetLevelName(lv)
    --             this.WarningText.text = GetLangFormat("UI_Building_Build_Block", zid, zoneName, lv)
    --             break
    --         end
    --     end
    -- end

    for i = 1, 4 do
        local item = SafeGetUIControl(this, "BottomView/UpgradeNeed/Item" .. i)
        item:SetActive(false)
    end
    local costList = Utils.SortItems(costConfig)
    local index = 0
    costList:ForEach(
        function(itemData)
            index = index + 1
            local item = SafeGetUIControl(this, "BottomView/UpgradeNeed/Item" .. index)
            if item == nil then
                return
            end
            item:SetActive(true)
            local icon = SafeGetUIControl(item, "Icon", "Image")
            Utils.SetItemIcon(icon, itemData.itemId)

            local txtValue = SafeGetUIControl(item, "NeedValue", "Text")
            if DataManager.GetMaterialCount(this.cityId, itemData.itemId) >= itemData.count then
                txtValue.text =
                    DataManager.GetMaterialCountFormat(this.cityId, itemData.itemId) .. "/" .. Utils.FormatCount(itemData.count)
            else
                txtValue.text =
                    Utils.RichText(DataManager.GetMaterialCountFormat(this.cityId, itemData.itemId), "#FF6262") ..
                    "/" .. Utils.FormatCount(itemData.count)
            end
        end
    )
    local itemTime = SafeGetUIControl(this, "BottomView/UpgradeNeed/Item" .. index + 1)
    if itemTime == nil then
        return
    end
    itemTime:SetActive(true)
    local icon = SafeGetUIControl(itemTime, "Icon", "Image")
    Utils.SetIcon(icon, string.format("colliery_icon_time", type))
    local txtValue = SafeGetUIControl(itemTime, "NeedValue", "Text")
    txtValue.text = Utils.GetTimeFormat2(this.mapItemData:GetBuildDuration())
end

function Panel.HideUI()
    if this.TutorialSubStepSubscribe ~= nil then
        this.TutorialSubStepSubscribe:unsubscribe()
    end
    EventManager.Brocast(EventDefine.OnCloseBuildUnlockPanel, this.zoneId)
    HideUI(UINames.UIBuildUnlock)
    this.ClearTimer()
end

function Panel.PlayViewEnterAni()
    local bottomView = this.bottomView
    local canvasGroup = bottomView:GetComponent("CanvasGroup")
    local acTime = 0.25

    this.initBottomLocalPosition = this.initBottomLocalPosition or bottomView.transform.localPosition
    -- Y轴上升出现
    bottomView.transform.localPosition = this.initBottomLocalPosition + Vector3.New(0, -200, 0)
    local tween = bottomView.transform:DOLocalMoveY(this.initBottomLocalPosition.y, acTime):SetEase(Ease.OutBack)
    -- 透明度渐变出现
    canvasGroup.alpha = 0

    tween:OnComplete(function()
        this.startTutorial = true
        -- 检测引导
        local function TutorialUpdate(subStep)
            this.CheckTutorial(TutorialManager.CurrentStep.value, subStep)
        end
        this.TutorialSubStepSubscribe = TutorialManager.CurrentSubStep:subscribe(TutorialUpdate)
    end)

    Util.TweenTo(0, 1, acTime, function (value)
        canvasGroup.alpha = value
    end):SetEase(Ease.OutCubic)
end
function Panel.PlayViewExitAni()
    local bottomView = this.bottomView
    local canvasGroup = bottomView:GetComponent("CanvasGroup")
    local acTime = 0.25

    local seq = DOTween.Sequence()
    -- Y轴下移消失
    bottomView.transform.localPosition = this.initBottomLocalPosition
    seq:Append(bottomView.transform:DOLocalMoveY(this.initBottomLocalPosition.y - 200, acTime):SetEase(Ease.InBack))
    -- 透明度渐变消失
    canvasGroup.alpha = 1

    seq:Join(Util.TweenTo(1, 0, acTime, function (value)
        canvasGroup.alpha = value
    end))

    seq:AppendCallback(function ()
        this.HideUI()
    end)
end

--引导点击建造按钮
function Panel.TutorialClickBuildButton(noticeKey, step)
    TutorialHelper.FingerMove(
        {
            maskType = TutorialMaskType.None,
            noticeKey = noticeKey,
            noticePos = this.TutorialPos,
            fingerPoint = Utils.GetLocalPointInRectangleByUI(SafeGetUIControl(this, "BottomView/BtnUpgrade")),
            -- fingerPoint = Vector3(0, -(Screen.height / 2) + 100, 0),
            fingerSize = SafeGetUIControl(this, "BottomView/BtnUpgrade").gameObject.transform.sizeDelta,
            fingerFunc = function()

                if step == TutorialStep.BuildSawmill then
                    SDKAnalytics.TraceEvent(107)
                elseif step == TutorialStep.BuildKitchen then
                    SDKAnalytics.TraceEvent(120)
                elseif step == TutorialStep.BuildHunterCabin then
                    SDKAnalytics.TraceEvent(132)
                end

                this.OnUnlockBuildFun(true)


                if step == TutorialStep.BuildSawmill then
                    SDKAnalytics.TraceEvent(108)
                elseif step == TutorialStep.BuildKitchen then
                    SDKAnalytics.TraceEvent(121)
                elseif step == TutorialStep.BuildHunterCabin then
                    SDKAnalytics.TraceEvent(133)
                end
            end,
            callBack = TutorialManager.NextSubStep
        }
    )
end

--刷新引导
function Panel.CheckTutorial(step, subStep)
    if step == TutorialStep.BuildSawmill and subStep == 3 then --建造伐木场引导
        this.TutorialClickBuildButton("Tutorial_StartBuild_notice", step)
    elseif step == TutorialStep.BuildKitchen and subStep == 5 then --建造厨房引导
        this.TutorialClickBuildButton("Tutorial_StartBuild_notice", step)
    elseif step == TutorialStep.BuildHunterCabin and subStep == 3 then --建造猎人小屋引导
        this.TutorialClickBuildButton("Tutorial_StartBuild_notice", step)
    end
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

function Panel.ClearTimer()
    if this.timer then
        TimeModule.removeTimer(this.timer)
        this.timer = nil
   end
end
