---@class UIDataPreviewPanel : UIPanelBase
local Panel = UIPanelBaseMake()
local this = Panel
UIDataPreviewPanel = Panel

require "Game/Logic/NewView/DataPreview/UIOutputCell"
require "Game/Logic/NewView/DataPreview/UIChainItem"

COLORFACTOR = {
    "#b41212",
    "#d86906",
    "#199d4a",
    "#006c26",
}

function Panel.OnAwake()
    this.cachedata = {}
    this.InitPanel()
    this.InitEvent()
    this.InitViewData()
    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    -- this.uidata.clipFPS = this.gameObject:GetComponent("ClipFPS")
    this.uidata.Mask = SafeGetUIControl(this, "Mask")
    this.uidata.ButtonClose = SafeGetUIControl(this, "ButtonClose")

    this.uidata.OutputItem = SafeGetUIControl(this, "OutputItem")
    this.uidata.List = SafeGetUIControl(this, "ImageOutput/ScrollView/Viewport/Content")

    this.uidata.ImageSurvival = SafeGetUIControl(this, "ImageSurvival")
    this.uidata.ImageOutput = SafeGetUIControl(this, "ImageOutput")
    this.uidata.ImageChain = SafeGetUIControl(this, "ImageChain")

    this.uidata.OverviewN = SafeGetUIControl(this, "OverviewN")
    this.uidata.OverviewS = SafeGetUIControl(this, "OverviewS")
    this.uidata.ChainN = SafeGetUIControl(this, "ChainN")
    this.uidata.ChainS = SafeGetUIControl(this, "ChainS")

    this.uidata.ButtonSurvivalTip = SafeGetUIControl(this, "ImageSurvival/ButtonTip")
    this.uidata.ButtonSurvivalTipBack = SafeGetUIControl(this, "ImageSurvival/ButtonTipBack")
    this.uidata.NecessityItem = SafeGetUIControl(this, "ImageSurvival/NecessityItem")
    this.uidata.SurvivalTextDes = SafeGetUIControl(this, "ImageSurvival/TextDes")

    this.uidata.ButtonOutputTip = SafeGetUIControl(this, "ImageOutput/ButtonTip")
    this.uidata.ButtonOutputTipBack = SafeGetUIControl(this, "ImageOutput/ButtonTipBack")
    this.uidata.OutputScrollView = SafeGetUIControl(this, "ImageOutput/ScrollView")
    this.uidata.OutputTextDes = SafeGetUIControl(this, "ImageOutput/TextDes")

    this.uidata.ChainPanel = SafeGetUIControl(this, "ImageChain")
    this.uidata.ChainItem = SafeGetUIControl(this, "ImageChain/UIChainItem")
    this.uidata.ChainContent = SafeGetUIControl(this, "ImageChain/Scroll View/Viewport/Content")
    this.uidata.ChainTip = SafeGetUIControl(this, "ImageChain/ButtonTip")
    this.uidata.ChainText = SafeGetUIControl(this, "ImageChain/TextTitle", "Text")

    SafeGetUIControl(this, "ImageSurvival/TextDes", "Text").text = GetLang("UI_Subtitle_Survival_desc")
    SafeGetUIControl(this, "ImageOutput/TextDes", "Text").text = GetLang("UI_Subtitle_Production_Resources_desc")
    SafeGetUIControl(this, "ImageChain/TextDes", "Text").text = GetLang("UI_Subtitle_Survival_desc")
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.Mask, this.HideUI)
    SafeAddClickEvent(this.behaviour, this.uidata.ButtonClose, this.HideUI)

    -- 总览
    SafeAddClickEvent(this.behaviour, this.uidata.OverviewN, function()
        this.index = 1
        this.UpViewState()
    end)

    -- 生产链
    SafeAddClickEvent(this.behaviour, this.uidata.ChainN, function()
        this.index = 2
        this.UpViewState()
    end)

    SafeAddClickEvent(
        this.behaviour,
        this.uidata.ButtonSurvivalTip,
        function()
            SafeSetActive(this.uidata.ButtonSurvivalTip, false)
            SafeSetActive(this.uidata.ButtonSurvivalTipBack, true)
            SafeSetActive(this.uidata.SurvivalTextDes, true)
            SafeSetActive(this.uidata.NecessityItem, false)
        end
    )

    SafeAddClickEvent(
        this.behaviour,
        this.uidata.ButtonSurvivalTipBack,
        function()
            SafeSetActive(this.uidata.ButtonSurvivalTip, true)
            SafeSetActive(this.uidata.ButtonSurvivalTipBack, false)
            SafeSetActive(this.uidata.SurvivalTextDes, false)
            SafeSetActive(this.uidata.NecessityItem, true)
        end
    )

    SafeAddClickEvent(
        this.behaviour,
        this.uidata.ButtonOutputTip,
        function()
            SafeSetActive(this.uidata.ButtonOutputTip, false)
            SafeSetActive(this.uidata.ButtonOutputTipBack, true)
            SafeSetActive(this.uidata.OutputTextDes, true)
            SafeSetActive(this.uidata.OutputScrollView, false)
        end
    )

    SafeAddClickEvent(
        this.behaviour,
        this.uidata.ButtonOutputTipBack,
        function()
            SafeSetActive(this.uidata.ButtonOutputTip, true)
            SafeSetActive(this.uidata.ButtonOutputTipBack, false)
            SafeSetActive(this.uidata.OutputTextDes, false)
            SafeSetActive(this.uidata.OutputScrollView, true)
        end
    )
end

function Panel.UpViewState()
    SafeSetActive(this.uidata.ImageSurvival, this.index == 1)
    SafeSetActive(this.uidata.ImageOutput, this.index == 1)
    SafeSetActive(this.uidata.ImageChain, this.index == 2)

    SafeSetActive(this.uidata.OverviewS, this.index == 1)
    SafeSetActive(this.uidata.OverviewN, this.index == 2)
    SafeSetActive(this.uidata.ChainS, this.index == 2)
    SafeSetActive(this.uidata.ChainN, this.index == 1)
end

function Panel.InitViewData()
    --初始化数据
    this.cityId = DataManager.GetCityId()
    this.survivals = StatisticalManager.GetSurvivalsItems(this.cityId)
    this.productionItems = Dictionary:New()

    this:InitnecessityItems()
    this:UpdateOutputItems()

    this.InitChain()

    this.UpdateStatisticalFunc = function(cityId)
        if cityId == this.cityId then
            this.UpdateOutputItems()
            --在线生产链刷新
            this.UpdateProdcutionChainPanel()
        end
    end
    this.AddListener(EventType.UPDATE_STATISTICAL, this.UpdateStatisticalFunc)

    this.TimeCityPerHourFunc = function(cityId)
        if this.cityId == cityId then
            this.UpdateProdcutionChainPanel()
        end
    end
    this.AddListener(EventType.TIME_CITY_PER_HOUR, this.TimeCityPerHourFunc)

    this.UpgradeZoneFunc = function(cityId, zoneId, zoneType, level)
        if cityId == this.cityId then
            this.UpdateProdcutionChainPanel()
        end
    end
    this.AddListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)

    this.TimeRealPerSecondFunc = function(cityId)
        if cityId == this.cityId then
            --刷新生产链消耗时间
            this.nodeInfos:ForEachKeyValue(
                function(nodeId, nodeInfo)
                    this.productionChainItems[nodeId]:OnRefreshChainConsumption()
                end
            )
        end
    end
    this.AddListener(EventType.TIME_REAL_PER_SECOND, this.TimeRealPerSecondFunc)

    this.SchedulesAddFunc = function(cityId, schedules)
        if cityId == this.cityId then
            local b = this.IsOfflineChain(schedules.type)
            if this.isOfflineChain ~= b then
                this.isOfflineChain = b
                this.UpdateProdcutionChainPanel()
            end
        end
    end
    this.AddListener(EventType.SCHEDULES_ADD, this.SchedulesAddFunc)

    this.index = 1
    this.UpViewState()
end

-- 生存资源
function Panel.InitnecessityItems()
    for i = 1, 3 do
        SafeSetActive(SafeGetUIControl(this, "ImageSurvival/NecessityItem/necessityItem" .. i), false)
    end

    this.sub = List:New()

    for index, itemid in pairs(this.survivals) do
        SafeSetActive(SafeGetUIControl(this, "ImageSurvival/NecessityItem/necessityItem" .. index), true)
        this.itemConfig = ConfigManager.GetItemConfig(itemid)
        local materialRx = nil
        if this.itemConfig.type == ItemUseType.Food then
            materialRx = FoodSystemManager.GetFoodCountRx(this.cityId, itemid)
        else
            materialRx = DataManager.GetMaterialRx(this.cityId, itemid)
            if this.itemConfig.item_type == ItemType.Cash then
            elseif this.itemConfig.item_type == ItemType.Heart then
            else
            end
        end
        local function MatrialSubscribeFunc(val)
            local progress = 0
            if DataManager.CheckInfinity(this.cityId, itemid) then
                progress = 1.2
            else
                local currentCount, maxCount = StatisticalManager.GetSurvivalCount(this.cityId, itemid)
                progress = (val + currentCount) / maxCount
            end
            local factor = StatisticalManager.GetStatisticalFactor(progress, itemid)
            local textState = SafeGetUIControl(this, "ImageSurvival/NecessityItem/necessityItem" .. index .. "/TextState",
                "Text")
            textState.text = "<color=" ..
                COLORFACTOR[factor] ..
                ">" .. GetLang(ConfigManager.GetMiscConfig("data_analysis_meme_desc")[factor]) .. "</color>"

            local ImageState = SafeGetUIControl(this, "ImageSurvival/NecessityItem/necessityItem" .. index ..
                "/ImageState", "Image")
            Utils.SetIcon(ImageState, "statistics_img_" .. factor) 

            -- 道具图标
            -- Utils.GetItemIcon(itemid)
            local ImageIcon = SafeGetUIControl(this, "ImageSurvival/NecessityItem/necessityItem" .. index .. "/ImageIcon",
                "Image")
            Utils.SetItemIcon(ImageIcon, itemid)
            UIUtil.AddItem(ImageIcon, itemid, false, UINames.UIDataPreview)
        end
        local matrialSubmaterial = materialRx:subscribe(MatrialSubscribeFunc)
        this.sub:Add(matrialSubmaterial)
    end
end

function Panel.CreateProductionItemView(itemId)
    local go = GOInstantiate(this.uidata.OutputItem)
    go.transform:SetParent(this.uidata.List.transform, false)
    SafeSetActive(go.gameObject, true)
    local item = UIOutputCell.new()
    item:InitPanel(this.behaviour, go, itemId)
    return item
end

-- 生产资源
function Panel.UpdateOutputItems()
    local productionItemIds = StatisticalManager.GetOnlineProductions(this.cityId)
    productionItemIds:ForEach(
        function(itemId)
            if this.productionItems:ContainsKey(itemId) then
                this.productionItems[itemId]:OnUpdate()
            else
                local item = this.CreateProductionItemView(itemId)
                this.productionItems:Add(itemId, item)
            end
        end
    )
end

-- 按钮显示
function Panel.UpdateButtonView()
end

function Panel.OnShow()
    UIUtil.openPanelAction(this.gameObject)
    EventManager.Brocast(EventType.CITY_CAMERA_DISABLED)
end

function Panel.OnHide()
    EventManager.Brocast(EventType.CITY_CAMERA_ENABLED)
    if this.sub then
        this.sub:ForEach(
            function(item)
                item:unsubscribe()
                item = nil
            end
        )
    end

    this.productionItems:ForEach(
        function(item)
            if this.productionItems:ContainsKey(item.itemId) then
                item:OnDestroy()
            end
        end
    )
end

function Panel.HideUI()
    UIUtil.hidePanelAction(
        this.gameObject,
        function()
            HideUI(UINames.UIDataPreview)
        end
    )
end

---数据链
--------------------------------------------------------------------------

function Panel.IsOfflineChain(schedulesType)
    if schedulesType == SchedulesType.Sleep or schedulesType == SchedulesType.Home or schedulesType == SchedulesType.Eat then
        return true
    end
    return false
end

function Panel.InitChain()
    --初始化数据
    this.nodeInfos = Dictionary:New()
    local cityConfig = ConfigManager.GetCityById(this.cityId)
    local line = cityConfig.chain_lines / 10
    local column = cityConfig.chain_lines % 10
    for id, info in pairs(cityConfig.chain_list) do
        local datas = string.split(info, "|")
        local nodeInfo = {}
        nodeInfo.index = id
        nodeInfo.itemId = datas[1]
        nodeInfo.lines = List:New()
        if datas[2] then
            local function EachLinePath(path)
                local linePath = string.split(path, "_", tonumber)
                local lineInfo = List:New()
                for i = 1, #linePath, 1 do
                    lineInfo:Add(linePath[i])
                end
                nodeInfo.lines:Add(lineInfo)
            end
            local linePaths = string.split(datas[2], "&&")
            for i = 1, #linePaths, 1 do
                EachLinePath(linePaths[i])
            end
        end
        this.nodeInfos:Add(id, nodeInfo)
    end
    local currScheduleCfg = SchedulesManager.GetCurrentSchedulesByMenu(this.cityId)
    this.isOfflineChain = this.IsOfflineChain(currScheduleCfg.type)

    -- this.UpdateProdcutionChainTips()

    --实力化节点对象
    this.productionChainItems = Dictionary:New()
    for i = 1, line, 1 do
        for j = 1, column, 1 do
            --节点id
            local nodeId = i * 10 + j
            --初始化节点数据对象
            local item = UIChainItem.new()
            -- this.uidata.clipFPS:AddFPS(1, 1, function()
            local view = GOInstantiate(this.uidata.ChainItem, this.uidata.ChainContent.transform)
            -- local index = (i - 1) * 5 + j - 1
            -- "index:" .. index)
            -- local view = this.uidata.ChainContent.transform:GetChild(index).gameObject
            SafeSetActive(view, true)
            item:InitPanel(this.behaviour, view.gameObject)
            if this.isOfflineChain then
                item:OnInit(this.nodeInfos[nodeId], StatisticalManager.GetOfflineProductions(this.cityId))
            else
                item:OnInit(this.nodeInfos[nodeId], nil)
            end
            this.productionChainItems:Add(nodeId, item)
            -- end)
        end
        -- ForceRebuildLayoutImmediate(this.uidata.ChainContent)
    end
    ForceRebuildLayoutImmediate(this.uidata.ChainContent)
    this.InitLine()
    SafeAddClickEvent(
        this.behaviour,
        this.uidata.ChainTip,
        function()
            local title = ""
            local desc = ""
            if this.isOfflineChain then
                title = "UI_statisticalitems_productivity_theory"
                if CityManager.GetIsEventScene() then
                    desc = "ui_statisticalitems_productivity_theory_desc_event"
                else
                    desc = "ui_statisticalitems_productivity_theory_desc"
                end
            else
                title = "ui_data_chain_desc_arbeit_tips"
                if CityManager.GetIsEventScene() then
                    desc = "ui_data_chain_desc_arbeit_tips_desc_event"
                else
                    desc = "ui_data_chain_desc_arbeit_tips_desc"
                end
            end
            UIUtil.showConfirmByData(
                {
                    Title = title,
                    Description = desc,
                    YesText = "ui_ok_btn",
                }
            )
        end
    )
end

--初始化节点线
function Panel.InitLine()
    TimeModule.addDelay(0, function()
        this.nodeInfos:ForEachKeyValue(
            function(nodeId, nodeInfo)
                this.productionChainItems[nodeId]:OnInitLine(this.productionChainItems)
            end
        )
    end)
end

--更新生产链 tips
function Panel.UpdateProdcutionChainTips()
    -- if this.isOfflineChain then
    this.uidata.ChainText.text = GetLang("UI_statisticalitems_productivity_theory")
    -- else
    --     this.uidata.ChainText.text = GetLang("ui_data_chain_desc_arbeit_tips")
    -- end
    ForceRebuildLayoutImmediate(this.uidata.ChainPanel)
end

--刷新生产链界面
function Panel.UpdateProdcutionChainPanel()
    local offlineProductions = nil
    if this.isOfflineChain then
        offlineProductions = StatisticalManager.GetOfflineProductions(this.cityId)
    end
    this.UpdateProdcutionChainTips()
    this.nodeInfos:ForEachKeyValue(
        function(nodeId, nodeInfo)
            this.productionChainItems[nodeId]:OnRefreshChain(offlineProductions)
        end
    )
    this.nodeInfos:ForEachKeyValue(
        function(nodeId, nodeInfo)
            this.productionChainItems[nodeId]:OnRefreshLine()
        end
    )
end
