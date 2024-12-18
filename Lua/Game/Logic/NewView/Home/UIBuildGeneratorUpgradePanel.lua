---@class UIBuildGeneratorUpgradePanel : UIPanelBase
local Panel = UIPanelBaseMake()
local this = Panel
UIBuildGeneratorUpgradePanel = Panel

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

    this.uidata.upgradeNeedBox = SafeGetUIControl(this, "BottomView/UpgradeNeed")
    this.uidata.upgradeItem = SafeGetUIControl(this, "BottomView/BuildProgress")

    this.uidata.upgradingTimeText = SafeGetUIControl(this, "BottomView/BuildProgress/Slider/Text", "Text")
    this.uidata.upgradingSlider = SafeGetUIControl(this, "BottomView/BuildProgress/Slider", "Slider")

    this.uidata.btnLevelUp = SafeGetUIControl(this, "BottomView/BtnUpgrade", "Button")
    this.uidata.btnComplete = SafeGetUIControl(this, "BottomView/BtnComplete", "Button")
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.clickMask, function ()
        -- if this.state == "upgrading" then
        --     EventManager.Brocast(EventDefine.OnClickExitCityBuild)
        -- end
        this.PlayViewExitAni()
    end)

    SafeAddClickEvent(this.behaviour, this.uidata.btnClose, function ()
        -- if this.state == "upgrading" then
        --     EventManager.Brocast(EventDefine.OnClickExitCityBuild)
        -- end
        this.PlayViewExitAni()
    end)

    SafeAddClickEvent(this.behaviour, this.uidata.btnLevelUp.gameObject, function ()
        this.OnUpgradeBuildFun()
    end)

    SafeAddClickEvent(this.behaviour, this.uidata.btnComplete.gameObject, function ()
        this.OnSpeedUpFun()
    end)

    this.AddListener(EventType.UPGRADE_ZONE, function (cityId, zoneId)
        if cityId == this.cityId and zoneId == this.zoneId then
            if this.exitCall then
                this.exitCall()
            end
            EventManager.Brocast(EventDefine.OnClickExitCityBuild)
            this.PlayViewExitAni()
        end
    end)

    this.AddListener(EventType.TIME_CITY_UPDATE, function()
        if this.state == "upgrading" then
            this.UpdateUpgradingItem()
            return
        end

        -- 刷新升级按钮是否置灰
        local costIsReady = this.mapItemData:GetUnlockLevelCostIsReady()
        GreyObject(this.uidata.btnLevelUp.gameObject, not costIsReady, costIsReady)
    end)
end

function Panel.OnShow(param)
    this.state = "normal"
    if param then
        this.exitCall = param.exitCall
    end

    this.Init()
    this.InitEvent()

    this.PlayViewEnterAni()
end

function Panel.Init()
    -- 城市ID
    this.cityId = DataManager.GetCityId()
    -- 区域ID
    this.zoneId = ConfigManager.GetZoneIdByZoneType(this.cityId, ZoneType.Generator)
    -- 区域数据
    this.mapItemData = MapManager.GetMapItemData(this.cityId, this.zoneId)
    -- 初始化标题Item
    this.InitTittleItem()
    -- 初始化升级Content 
    this.InitUpgradeContent()   
    if this.mapItemData:IsUpgrading() then
        this.state = "upgrading"
    end
    -- 刷新状态
    this.UpdateState()
end

function Panel.UpdateState()
    this.uidata.upgradeNeedBox:SetActive(this.state == "normal")
    this.uidata.upgradeItem:SetActive(this.state == "upgrading")
    this.uidata.btnLevelUp.gameObject:SetActive(true)
    this.uidata.btnComplete.gameObject:SetActive(false)
    if this.state == "upgrading" then
        this.UpdateUpgradingItem()
    end

    local costIsReady = this.mapItemData:GetUnlockLevelCostIsReady()
    GreyObject(this.uidata.btnLevelUp.gameObject, not costIsReady, costIsReady)
end 

function Panel.UpdateSpeedUpCost()
    local speedUpCostText = SafeGetUIControl(this, "BottomView/BtnComplete/Cost/Text", "Text")
    local gemCost = this.mapItemData:GetSpeedCost()
    speedUpCostText.text = gemCost
end

function Panel.UpdateUpgradingItem()
    this.lfTime, this.lfTotal = this.mapItemData:GetBuildLeftTime()
    this.uidata.upgradingTimeText.text = Utils.GetTimeFormat3(this.lfTime)
    local p = 1 - this.lfTime / this.lfTotal
    Util.TweenTo(this.uidata.upgradingSlider.value, p, 0.25, function(value)
        this.uidata.upgradingSlider.value = value
    end)
    this.uidata.btnLevelUp.gameObject:SetActive(false)
    this.uidata.btnComplete.gameObject:SetActive(true)

    this.UpdateSpeedUpCost()

    if this.lfTime <= 0 then
        this.state = "normal"
        EventManager.Brocast(EventDefine.OnClickExitCityBuild)
        this.PlayViewExitAni()
    end
end 

function Panel.OnSpeedUpFun()
    local speedUpCostText = SafeGetUIControl(this, "BottomView/BtnComplete/Cost/Text", "Text")
    local gemCost = this.mapItemData:GetSpeedCost()
    speedUpCostText.text = gemCost
    if this.mapItemData:IsUpgrading() then
        if this.mapItemData:SpeedUpgradeComplete( function() end) == false
            then
            return
        end
    end
end

function Panel.InitTittleItem()
    -- 设置建筑图标
    local buildIcon = SafeGetUIControl(this, "BottomView/TitleItem/ImgIcon", "Image")
    local zoneCfg = ConfigManager.GetZoneConfigById(this.zoneId)
    Utils.SetIcon(buildIcon, zoneCfg.zone_type_icon)
    -- 设置建筑名称
    -- local buildName = SafeGetUIControl(this, "BottomView/TitleItem/TtitleTxtBox/TxtTitle", "Text")
    -- buildName.text = "净化器" -- this.mapItemData:GetUpgradeLevelName()
    -- 设置建筑等级
    local buildLevel = SafeGetUIControl(this, "BottomView/TitleItem/TtitleTxtBox/TxtLevel", "Text")
    local level = this.mapItemData:GetLevel()
    buildLevel.text = " " .. GetLangFormat("Lv" .. level)
    ForceRebuildLayoutImmediate(buildLevel.transform.parent.gameObject)
end

function Panel.InitUpgradeContent()
    local status = this.mapItemData:GetBuildStatus()
    -- 刷新升级前后的燃料消耗
    local currentLevelCostIcon = SafeGetUIControl(this, "BottomView/UpgradeInfo/Item2/Res1", "Image")
    Utils.SetItemIcon(currentLevelCostIcon, GeneratorManager.GetConsumptionItemId(this.cityId))
    local currentLevelText = SafeGetUIControl(this, "BottomView/UpgradeInfo/Item2/Res1/Text", "Text")
    currentLevelText.text = GetLang("UI_generator_consume_min", Utils.FormatCount(GeneratorManager.GetCount(this.cityId)))
    local nextLevelCostIcon = SafeGetUIControl(this, "BottomView/UpgradeInfo/Item2/Res2", "Image")
    local nextConsumption = GeneratorManager.GetNextConsumption(this.cityId)
    Utils.SetItemIcon(nextLevelCostIcon, nextConsumption.itemId)
    local nextLevelText = SafeGetUIControl(this, "BottomView/UpgradeInfo/Item2/Res2/Text", "Text")
    nextLevelText.text = GetLang("UI_generator_consume_min", Utils.FormatCount(nextConsumption.count))
    -- 刷新升级前后的火力
    local currentHeatLevel = this.mapItemData:GetHeatLevel()
    local nextHeatLevel = this.mapItemData:GetNextHeatLevel()
    local lf1 = SafeGetUIControl(this, "BottomView/UpgradeInfo/Item1/LowFire1")
    local lf2 = SafeGetUIControl(this, "BottomView/UpgradeInfo/Item1/LowFire2")
    lf1:SetActive(not (nextHeatLevel > 5))
    lf2:SetActive(not (nextHeatLevel > 5))
    local f1 = SafeGetUIControl(this, "BottomView/UpgradeInfo/Item1/Fire1")
    local f2 = SafeGetUIControl(this, "BottomView/UpgradeInfo/Item1/Fire2")
    f1:SetActive(nextHeatLevel > 5)
    f2:SetActive(nextHeatLevel > 5)
    for i = 1, 5 do
        local lf1Item = SafeGetUIControl(lf1, "ImgFire_" .. i)
        lf1Item:SetActive(i <= currentHeatLevel)
    end
    for i = 1, 5 do
        local lf2Item = SafeGetUIControl(lf2, "ImgFire_" .. i)
        lf2Item:SetActive(i <= nextHeatLevel)
    end
    local textCurrentFireText = SafeGetUIControl(f1, "Text", "Text")
    local textNextFireText = SafeGetUIControl(f2, "Text", "Text")
    textCurrentFireText.text = currentHeatLevel
    textNextFireText.text = nextHeatLevel
    -- 刷新升级后解锁和升级的建筑列表
    local buildContent = SafeGetUIControl(this, "BottomView/UnlockBuildings/ScrollBuilds/Viewport/Content")
    UIUtil.RemoveAllGameobject(buildContent.transform)
    -- 解锁列表
    local list = this.mapItemData:GetNextUnlockZoneList()
    local zoneTypeList = {}
    local simpleList = {}
    for index, unlockZoneId in pairs(list) do
        if unlockZoneId ~= this.zoneId then
            local zoneCfg = ConfigManager.GetZoneConfigById(unlockZoneId)
            if zoneTypeList[zoneCfg.zone_type] ~= nil then
                zoneTypeList[zoneCfg.zone_type] = zoneTypeList[zoneCfg.zone_type] + 1
            else
                zoneTypeList[zoneCfg.zone_type] = 1
                simpleList[index] = unlockZoneId
            end
        end
    end

    local tempItem = SafeGetUIControl(this, "BottomView/UnlockBuildings/Build")
    tempItem:SetActive(false)
    for index, unlockZoneId in pairs(simpleList) do
        if unlockZoneId ~= this.zoneId then
            local zoneCfg = ConfigManager.GetZoneConfigById(unlockZoneId)
            local buildItem = GOInstantiate(tempItem, buildContent.transform)
            buildItem:SetActive(true)

            SafeGetUIControl(buildItem, "ImgGreen"):SetActive(false)
            local newTextStr = GetLang("UI_generator_new_building") .. "×" .. zoneTypeList[zoneCfg.zone_type]
            SafeGetUIControl(buildItem, "ImgRed/Text", "Text").text = newTextStr
            local imgProduction = SafeGetUIControl(buildItem, "ImgProduction", "Image") -- 产出图标
            local imgBuild = SafeGetUIControl(buildItem, "Image", "Image") -- 建筑图标

            Utils.SetZoneIcon(imgBuild, unlockZoneId, 1)

            local zoneCfg = ConfigManager.GetZoneConfigById(unlockZoneId)
            local tryItem = string.match(zoneCfg.zone_bonus, "item_(%w+)")
            local tryIcon = string.match(zoneCfg.zone_bonus, "attr_(%w+)")
            if tryItem ~= nil then
                Utils.SetItemIcon(imgProduction, tryItem)
            elseif tryIcon ~= nil then
                Utils.SetAttributeIcon(imgProduction, string.lower(tryIcon), function ()
                    imgProduction:SetNativeSize()
                    if string.lower(tryIcon) == "speed" then
                        imgProduction.transform.localScale = Vector3(0.5, 0.5, 1)
                    end
                end)
            end

            local num = zoneTypeList[zoneCfg.zone_type]
            if (num ~= nil and num > 1) then
                -- this.MultiBuildingTagNum.gameObject:SetActive(true)
                -- this.MultiBuildingTagNum.text = "<SIZE=20>X</SIZE>"..num;
                UIUtil.AddZoneType(imgBuild, unlockZoneId, false, 1, num)
            else
                -- this.MultiBuildingTagNum.gameObject:SetActive(false)
                UIUtil.AddZone(imgBuild, unlockZoneId, false, 1)
            end
        end
    end
    -- 升级列表
    local upList = this.mapItemData:GetUpgradeCanUnlockList()
    local upZoneTypeList = {}
    local upSimpleList = {}
    for zid, level in pairs(upList) do
        if zid ~= this.zoneId then
            local zoneCfg = ConfigManager.GetZoneConfigById(zid)
            if upZoneTypeList[zoneCfg.zone_type] ~= nil then
                upZoneTypeList[zoneCfg.zone_type] = upZoneTypeList[zoneCfg.zone_type] + 1
            else
                upZoneTypeList[zoneCfg.zone_type] = 1
                upSimpleList[zid] = level
            end
        end
    end
    for zid, level in pairs(upSimpleList) do
        local zoneCfg = ConfigManager.GetZoneConfigById(zid)
        local buildItem = GOInstantiate(tempItem, buildContent.transform)
        buildItem:SetActive(true)

        SafeGetUIControl(buildItem, "ImgRed"):SetActive(false)
        local imgProduction = SafeGetUIControl(buildItem, "ImgProduction", "Image") -- 产出图标
        local imgBuild = SafeGetUIControl(buildItem, "Image", "Image") -- 建筑图标

        -- 策划说都读等级为1级的
        Utils.SetZoneIcon(imgBuild, zid, 1)

        local zoneCfg = ConfigManager.GetZoneConfigById(zid)
        local tryItem = string.match(zoneCfg.zone_bonus, "item_(%w+)")
        local tryIcon = string.match(zoneCfg.zone_bonus, "attr_(%w+)")
        if tryItem ~= nil then
            Utils.SetItemIcon(imgProduction, tryItem)
        elseif tryIcon ~= nil then
            Utils.SetAttributeIcon(imgProduction, string.lower(tryIcon), function ()
                imgProduction:SetNativeSize()
                if string.lower(tryIcon) == "speed" then
                    imgProduction.transform.localScale = Vector3(0.5, 0.5, 1)
                end
            end)
        end
        local num = zoneTypeList[zoneCfg.zone_type]
        if (num ~= nil and num > 1) then
            -- this.MultiBuildingTagNum.gameObject:SetActive(true)
            -- this.MultiBuildingTagNum.text = "<SIZE=20>X</SIZE>"..num;
            UIUtil.AddZoneType(imgBuild, zid, false, 1, num)
        else
            -- this.MultiBuildingTagNum.gameObject:SetActive(false)
            UIUtil.AddZone(imgBuild, zid, false, 1)
        end
    end

    -- 刷新升级成本列表
    local costConfig = this.mapItemData:GetUnlockLevelCost()
    local costIsReady = this.mapItemData:GetUnlockLevelCostIsReady()
    local btnUpgrade = SafeGetUIControl(this, "BottomView/BtnUpgrade", "Button")
    -- btnUpgrade:SetInteractable(costIsReady) -- 置灰，暂时没写

    local upgradeNeed = SafeGetUIControl(this, "BottomView/UpgradeNeed")
    for i = 1, 4 do
        local item = SafeGetUIControl(upgradeNeed, "Item" .. i)
        item:SetActive(false)
    end
    local costList = Utils.SortItems(costConfig)
    local index = 0
    costList:ForEach(
        function(itemData)
            index = index + 1
            local item = SafeGetUIControl(this, "BottomView/UpgradeNeed/Item" .. index)
            item:SetActive(true)
            local icon = SafeGetUIControl(item, "Icon", "Image")
            local txtNeed = SafeGetUIControl(item, "NeedValue", "Text")
            local itemId = itemData.itemId
            local count = itemData.count
            Utils.SetItemIcon(icon, itemId)
            UIUtil.AddItem(icon, itemId, nil, { UINames.UIBuildGeneratorUpgrade, UINames.UIBuildGenerator })
            if DataManager.GetMaterialCount(this.cityId, itemId) >= count then
                txtNeed.text =
                    Utils.RichText(DataManager.GetMaterialCountFormat(this.cityId, itemId), "#006C26") ..
                    "/" .. Utils.FormatCount(count)
            else
                txtNeed.text =
                    Utils.RichText(DataManager.GetMaterialCountFormat(this.cityId, itemId), "#f85d5d") ..
                    "/" .. Utils.FormatCount(count)
            end
        end
    )
    index = index + 1
    local item4 = SafeGetUIControl(this, "BottomView/UpgradeNeed/Item" .. index)
    local txtNeed = SafeGetUIControl(item4, "NeedValue", "Text")
    local icon = SafeGetUIControl(item4, "Icon", "Image")
    Utils.SetIcon(icon, "colliery_icon_time")
    local buildDuration = this.mapItemData:GetBuildDuration()
    if buildDuration ~= 0 then
        item4:SetActive(true)
        txtNeed.text = Utils.GetTimeFormat2(buildDuration)
    end
end

function Panel.HideUI()
    HideUI(UINames.UIBuildGeneratorUpgrade)
end

function Panel.OnUpgradeBuildFun()
    local onSuccess = function()
        -- this.BuildButton:SetInteractable(false)
        -- this.closeType = "complete"
        -- this.from = nil
        -- this.UpdateState
        if this.exitCall then
            this.exitCall()
        end
        EventManager.Brocast(EventDefine.OnClickExitCityBuild)
        this.HideUI()
        -- if this.parentPanel then
        --     this.parentPanel:ClosePanel()
        -- end
        -- AudioManager.PlayEffect("ui_builing_working")
    end

    -- onSuccess()
    local status = this.mapItemData:GetBuildStatus()
    if status == BuildingStatus.Complete then
        this.mapItemData:UpgradeZoneLevel(
            function(success)
                if success then
                    onSuccess()
                end
            end
        )
    else
        this.mapItemData:UnlockZone(
            function(success)
                if success then
                    onSuccess()
                end
            end
        )
    end
end

function Panel.PlayViewEnterAni()
    local bottomView = SafeGetUIControl(this, "BottomView")
    local canvasGroup = bottomView:GetComponent("CanvasGroup")
    local acTime = 0.25

    this.initBottomLocalPosition = this.initBottomLocalPosition or bottomView.transform.localPosition
    -- Y轴上升出现
    bottomView.transform.localPosition = this.initBottomLocalPosition + Vector3.New(0, -200, 0)
    bottomView.transform:DOLocalMoveY(this.initBottomLocalPosition.y, acTime):SetEase(Ease.OutBack)
    -- 透明度渐变出现
    canvasGroup.alpha = 0

    Util.TweenTo(0, 1, acTime, function (value)
        canvasGroup.alpha = value
    end):SetEase(Ease.OutCubic)
end
function Panel.PlayViewExitAni()
    local bottomView = SafeGetUIControl(this, "BottomView")
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
