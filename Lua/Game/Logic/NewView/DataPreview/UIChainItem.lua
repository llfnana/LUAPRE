---@class UIChainItem
local Element = class("UIChainItem")
UIChainItem = Element

require "Game/Logic/NewView/DataPreview/UILineItem"
require "Game/Logic/NewView/DataPreview/UIArrowItem"

function Element:ctor()
end

function Element:InitPanel(behaviour, obj, param)
    self.gameObject = obj;
    self.transform = obj.transform;
    self.behaviour = behaviour;
    param = param or {}

    if self.uidata == nil then self.uidata = {} end

    self.content = SafeGetUIControl(self, "Content")
    self.ItemIcon = SafeGetUIControl(self, "Content/ImgIcon", "Image")
    self.ItemStock = SafeGetUIControl(self, "Content/Stock")
    self.txtStock = SafeGetUIControl(self, "Content/Stock/TxtNum", "Text")
    self.itemTxtStock = SafeGetUIControl(self, "Content/Stock/Txt", "Text")
    self.txtCost = SafeGetUIControl(self, "Content/Stock/TxtCost", "Text")
    self.ItemUnknown = SafeGetUIControl(self, "Content/Unknown")
    self.itemTxtUnknown = SafeGetUIControl(self, "Content/Unknown/Txt", "Text")
    self.ItemFire = SafeGetUIControl(self, "Content/ImgFire")
    self.LineUp = SafeGetUIControl(self, "Content/LineUp", "Text")
    self.LineLeft = SafeGetUIControl(self, "Content/LineLeft", "Text")
    self.LineRight = SafeGetUIControl(self, "Content/LineRight", "Text")
    self.imgBg1 = SafeGetUIControl(self, "Content/ImgBg1")
    self.imgBg2 = SafeGetUIControl(self, "Content/ImgBg2")
    self.imgBg3 = SafeGetUIControl(self, "Content/ImgBg3")
    self.txtAdd = SafeGetUIControl(self, "Content/TxtAdd", "Text")
    self.itemTxtAdd = SafeGetUIControl(self, "Content/TxtAdd/Txt", "Text")
    self.txtReduce = SafeGetUIControl(self, "Content/TxtReduce", "Text")
    self.itemTxtReduce = SafeGetUIControl(self, "Content/TxtReduce/Txt", "Text")
    self.Line = SafeGetUIControl(self, "Lines")
    self.Arrow = SafeGetUIControl(self, "Arrows")
    self.lineItem = SafeGetUIControl(self, "UILineItem")
    self.arrowItem = SafeGetUIControl(self, "UIArrowsItem")

    self.oneLength = 75
end

--获取生产数量
function Element:GetOutputCount()
    local outputCount = 0
    if self.offlineProductions then
        self.offlineProductions:ForEachKeyValue(
            function(zoneId, zoneData)
                for itemId, itemCount in pairs(zoneData.outputInfo) do
                    if itemId == self.nodeInfo.itemId then
                        outputCount = outputCount + itemCount
                    end
                end
            end
        )
        outputCount = outputCount / 12
    else
        outputCount = StatisticalManager.GetOnlineProductionsByItemId(self.cityId, self.nodeInfo.itemId) * 60
    end
    if outputCount < 0 then
        outputCount = 0
    end
    return outputCount
end

--获取消耗数量
function Element:GetInputCount()
    local inputCount = 0
    if self.offlineProductions then
        self.offlineProductions:ForEachKeyValue(
            function(zoneId, zoneData)
                for itemId, itemCount in pairs(zoneData.inputInfo) do
                    if itemId == self.nodeInfo.itemId then
                        inputCount = inputCount + itemCount
                    end
                end
            end
        )
        inputCount = inputCount / 12
    else
        inputCount = StatisticalManager.GetOnlineConsumptions(self.cityId, self.nodeInfo.itemId) * 60
    end
    if inputCount < 0 then
        inputCount = 0
    end
    return inputCount
end

--获取生产消耗制定item数量
function Element:GetConsumptionsCount(itemId)
    local outputCount = self:GetOutputCount()
    local inputCount = 0
    for i = 1, #self.itemConfig.ingredients, 1 do
        for id, count in pairs(self.itemConfig.ingredients[i]) do
            if itemId == id then
                inputCount = count * outputCount
            end
        end
    end

    return inputCount
end

function Element:OnInit(nodeInfo, offlineProductions)
    self.cityId = DataManager.GetCityId()
    self.nodeInfo = nodeInfo

    self.LineText = {}
    self.LineText["Up"] = self.LineUp
    self.LineText["Left"] = self.LineLeft
    self.LineText["Right"] = self.LineRight
    for index, textItem in pairs(self.LineText) do
        textItem.gameObject:SetActive(false)
    end

    if self.nodeInfo then
        self.itemConfig = ConfigManager.GetItemConfig(self.nodeInfo.itemId)
        self.itemTxtAdd.text = "/" .. GetLang("UI_Time_Minute")
        self.itemTxtReduce.text = "/" .. GetLang("UI_Time_Minute")
        self.itemTxtStock.text = GetLang("UI_Resources_Stock")
        self.itemTxtUnknown.text = GetLang("items_name_unknown")
        self:OnRefreshChain(offlineProductions)
    else
        SafeSetActive(self.content.gameObject, false)
        self.chainState = 2
    end
end

--是否是燃料
function Element:CheckItemFire()
    --是否是燃料
    if not CityManager.GetIsEventScene(self.cityId) and
        GeneratorManager.GetConsumptionItemId(self.cityId) == self.nodeInfo.itemId
    then
        self.ItemFire.gameObject:SetActive(true)
        UIUtil.AddToolTipBig(self.ItemFire, GetLang("ui_chain_fuel"))
    end
end

function Element:OnRefreshChain(offlineProductions)
    --获取离线时游戏内的单位时间产出,离线过程中会影响的物品id列表
    self.offlineProductions = offlineProductions

    Utils.SetItemIcon(self.ItemIcon, self.nodeInfo.itemId)
    self.ItemStock.gameObject:SetActive(false)
    self.txtCost.gameObject:SetActive(false)
    self.itemTxtStock.gameObject:SetActive(false)
    self.txtStock.gameObject:SetActive(false)
    self.ItemUnknown.gameObject:SetActive(false)
    -- self.ItemCount.gameObject:SetActive(true)
    self.ItemFire.gameObject:SetActive(false)
    self.ItemIcon.gameObject:SetActive(false)
    self.imgBg1.gameObject:SetActive(false)
    self.imgBg2.gameObject:SetActive(false)
    self.imgBg3.gameObject:SetActive(false)
    -- self.ItemLock.gameObject:SetActive(false)
    -- self.Tips:SetActive(false)

    local outputCount = Utils.GetRoundPreciseDecimal(self:GetOutputCount(), 3)
    local inputCount = Utils.GetRoundPreciseDecimal(self:GetInputCount(), 3)
    local zoneList = Utils.GetZoneListByItemId(self.cityId, self.nodeInfo.itemId)

    local color = {
        [0] = CreateColorFromHex(58, 58, 55),
        [1] = CreateColorFromHex(191, 57, 54),
        [2] = CreateColorFromHex(58, 58, 55),
    }
    ---原材料是否正无穷
    if DataManager.CheckInfinity(self.cityId, self.nodeInfo.itemId) then
        -- self.Frame:SelectSprite(0)
        self.imgBg1.gameObject:SetActive(true)
        --是否是燃料
        self:CheckItemFire()
        self.ItemStock.gameObject:SetActive(true)
        self.itemTxtStock.gameObject:SetActive(true)
        self.txtStock.gameObject:SetActive(true)
        self.txtStock.text = GetLang("ui_infinity_name")
        UIUtil.AddItem(self.ItemIcon, self.nodeInfo.itemId, nil, nil, GetLang("UI_item_infinity_desc"))
        -- self.TitleBg:SelectColor(0)
        self.ItemIcon.gameObject:SetActive(true)
        self.txtAdd.text = GetLang("ui_infinity_name")
        self.txtAdd.color = color[0]
        self.txtReduce.text = "-" .. Utils.FormatCount(inputCount)
        self.txtReduce.color = color[0]
        self.chainState = -1
    elseif zoneList:Count() > 0 then
        ---生产大于消耗
        if outputCount >= inputCount then
            -- self.Frame:SelectSprite(0)
            self.imgBg1.gameObject:SetActive(true)
            --是否是燃料
            self:CheckItemFire()

            -- self.TitleBg:SelectColor(0)
            self.ItemStock.gameObject:SetActive(true)
            self.itemTxtStock.gameObject:SetActive(true)
            self.txtStock.gameObject:SetActive(true)
            -- self.ItemStock:SelectColor(0)
            self.txtStock.text = DataManager.GetMaterialCountFormat(self.cityId, self.nodeInfo.itemId)
            UIUtil.AddItem(self.ItemIcon, self.nodeInfo.itemId, ToolTipDir.Up, UINames.UIDataPreview)

            self.ItemIcon.gameObject:SetActive(true)
            self.txtAdd.text = "+" .. Utils.FormatCount(outputCount)
            self.txtAdd.color = color[0]
            self.txtReduce.text = "-" .. Utils.FormatCount(inputCount)
            self.txtReduce.color = color[0]
            self.chainState = 0
        else
            local itemCount = DataManager.GetMaterialCount(self.cityId, self.nodeInfo.itemId)
            -- self.Frame:SelectSprite(1)
            --是否是燃料
            self:CheckItemFire()

            -- self.TitleBg:SelectColor(1)
            self.imgBg2.gameObject:SetActive(true)
            self.ItemStock.gameObject:SetActive(true)
            self.txtCost.gameObject:SetActive(true)
            -- self.ItemStock:SelectColor(1)
            self.txtStock.text = Utils.FormatCount(itemCount)
            UIUtil.AddItem(self.ItemIcon, self.nodeInfo.itemId, ToolTipDir.Up, UINames.UIDataPreview)

            -- self.Tips:SetActive(true)
            self:RefreshConsumptionTime(itemCount, inputCount)

            self.ItemIcon.gameObject:SetActive(true)
            self.txtAdd.text = "+" .. Utils.FormatCount(outputCount)
            self.txtAdd.color = color[0]
            self.txtReduce.text = "-" .. Utils.FormatCount(inputCount)
            self.txtReduce.color = color[1]
            self.chainState = 1
        end
    else
        -- self.Frame:SelectSprite(2)
        -- self.TitleBg:SelectColor(2)
        self.ItemUnknown.gameObject:SetActive(true)
        -- self.ItemCount.gameObject:SetActive(false)
        -- self.ItemLock.gameObject:SetActive(true)
        self.imgBg3.gameObject:SetActive(true)
        UIUtil.AddToolTipBig(self.imgBg3, GetLang("UI_statistical_tips_unknown"))
        -- self.ItemCount.text = GetLang("items_name_unknown")
        self.txtReduce.text = "--"
        self.txtReduce.color = color[2]
        self.txtAdd.text = "--"
        self.txtAdd.color = color[2]
        self.chainState = 2
    end
end

---@class lineItem
---@field toChainItem UIChainItem 生产链节点
---@field showState number 显示状态 0:正常 1:不足 2:未知
---@field lineCount number 线段数量
---@field linePaths List<UILineItem> 线段列表
---@field lineArrows List<UIArrowItem> 箭头列表
---@field lineArrowInfos List<ArrowInfo> 箭头信息列表
--初始化生产链线路
function Element:OnInitLine(productionChainItems)
    self.lineItems = List:New()
    ---数据标记
    local flag = {}    ---记录拐点类型
    local isOne = true ---是否单边拐点
    self.nodeInfo.lines:ForEach(
        function(lineInfo)
            local lineCount = #lineInfo
            for i = 1, lineCount - 1, 1 do
                --统计链接节点数量
                local min = lineInfo[i] < lineInfo[i + 1] and lineInfo[i] or lineInfo[i + 1]
                local max = lineInfo[i] == min and lineInfo[i + 1] or lineInfo[i]
                local key = min .. "|" .. max
                if flag[key] == nil then
                    flag[key] = {
                        num = 0,
                        type = 0,
                    }
                end
                flag[key].num = flag[key].num + 1
                if flag[key].num > 1 then
                    isOne = false
                end
                --判断是否需要拐角 起点跟下一个终点x轴或者y轴值不同
                if lineInfo[i + 2] then
                    local startX = lineInfo[i] % 10
                    local midX = lineInfo[i + 1] % 10
                    local endX = lineInfo[i + 2] % 10
                    local startY = math.floor(lineInfo[i] / 10)
                    local midY = math.floor(lineInfo[i + 1] / 10)
                    local endY = math.floor(lineInfo[i + 2] / 10)
                    if startX == midX then
                        flag[key].type = startX < endX and 1 or startX > endX and 2 or 0
                    elseif startY == midY then
                        flag[key].type = startX < endX and 3 or startX > endX and 4 or 0
                    end
                end
            end
        end)

    local lineEndItemIds = {}
    local lineEndItemIndexs = {}
    if #self.nodeInfo.lines >= 2 then
        for i, v in ipairs(self.nodeInfo.lines) do
            table.insert(lineEndItemIds, productionChainItems[v[#v]].nodeInfo.itemId)
            table.insert(lineEndItemIndexs, v[#v])
        end
    end

    self.nodeInfo.lines:ForEach(
        function(lineInfo)
            local lineCount = #lineInfo
            local toNodeIndex = lineInfo[lineCount]
            local lineItem = {} ---@type lineItem
            lineItem.toChainItem = productionChainItems[toNodeIndex]
            lineItem.showState = self:GetLineShowState(lineItem.toChainItem.nodeInfo.itemId)
            -- lineItem.showState = 1
            lineItem.lineCount = lineCount
            lineItem.linePaths = List:New()
            lineItem.lineFlagPaths = List:New()
            lineItem.lineArrows = List:New()
            lineItem.lineArrowInfos = List:New()

            for i = 1, lineCount - 1, 1 do
                local startGo = productionChainItems[lineInfo[i]]
                local endGo = productionChainItems[lineInfo[i + 1]]
                local startWorldPos = RectTransformUtility.WorldToScreenPoint(PanelManager:GetUICamera(),
                    startGo.transform.position)
                local endWorldPos = RectTransformUtility.WorldToScreenPoint(PanelManager:GetUICamera(),
                    endGo.transform.position)

                local _, startPos = RectTransformUtility.ScreenPointToWorldPointInRectangle(
                    UIDataPreviewPanel.transform, startWorldPos, PanelManager:GetUICamera(), Vector3.zero)
                local _, endPos = RectTransformUtility.ScreenPointToWorldPointInRectangle(
                    UIDataPreviewPanel.transform, endWorldPos, PanelManager:GetUICamera(), Vector3.zero)
                local angle = Utils.GetUIAngle(startPos, endPos)
                -- local distance = Utils.GetUIDistance(startPos, endPos)
                local distance = Vector3.Distance(endPos, startPos)
                distance = distance * 1 / PanelManager.UICanvas.transform.localScale.x
                local direction = Utils.GetDirection(startPos, endPos)

                ---结束点遍历所有点位，如果存在同行同列需要额外生成拐角
                local line = UILineItem.new()
                local min = lineInfo[i] < lineInfo[i + 1] and lineInfo[i] or lineInfo[i + 1]
                local max = lineInfo[i] == min and lineInfo[i + 1] or lineInfo[i]
                local key = min .. "|" .. max
                local type = flag[key].type
                if flag[key].num > 1 then
                    local lastGo = productionChainItems[lineInfo[lineCount]]
                    type = lastGo.transform.position.x < startGo.transform.position.x and 5 or 7
                end

                local noneLine = GOInstantiate(self.lineItem, self.Line.transform)
                noneLine.gameObject.name = key
                SafeSetActive(noneLine, true)
                line:InitPanel(self.behaviour, noneLine)
                line:OnInit(startPos, angle, distance, lineItem.showState, isOne)
                --生成拐角
                if isOne or type >= 5 then
                    local Spinodal = UILineItem.new()
                    local SpinodalLine = GOInstantiate(self.lineItem, self.Line.transform)
                    SpinodalLine.gameObject.name = key
                    SafeSetActive(SpinodalLine, true)
                    Spinodal:InitPanel(self.behaviour, SpinodalLine,
                        { chainItem = self, itemId = lineItem.toChainItem.nodeInfo.itemId })
                    if type >= 5 then
                        Spinodal:OnInitSpinodal(endPos, lineItem.showState, type, lineEndItemIds, lineEndItemIndexs)
                    else
                        Spinodal:OnInitSpinodal(endPos, lineItem.showState, type)
                    end
                    lineItem.lineFlagPaths:Add(Spinodal)
                end

                local arrowSpace = 60
                local count = math.floor(distance / arrowSpace)
                for i = 1, count, 1 do
                    local arrow = UIArrowItem.new()
                    local go = GOInstantiate(self.arrowItem, self.Arrow.transform)
                    SafeSetActive(go, true)
                    arrow:InitPanel(self.behaviour, go)
                    local tempV3 = (i - 1) * arrowSpace * PanelManager.UICanvas.transform.localScale.x
                    arrow:OnInit(
                        startPos + direction * tempV3,
                        angle + 90,
                        lineItem.showState
                    )
                    lineItem.lineArrows:Add(arrow)

                    local info = {}
                    info.localPosition = arrow.transform.localPosition
                    info.angle = angle + 90
                    lineItem.lineArrowInfos:Add(info)
                    -- end)
                end
                lineItem.linePaths:Add(line)
            end

            local toward = lineItem.linePaths[lineCount - 1]:GetLineToward()
            if lineItem.showState ~= 2 then
                lineItem.toChainItem:ShowLineConsumptions(lineItem.showState, toward, self.nodeInfo.itemId)
            end
            self.lineItems:Add(lineItem)
        end
    )

    --排序
    self.lineItems:Sort(
        function(lineItem1, lineItem2)
            return lineItem1.showState <= lineItem2.showState
        end
    )
    self.lineItems:ForEach(
        function(lineItem)
            if lineItem.showState ~= 2 then
                for i = 1, lineItem.lineArrows:Count(), 1 do
                    lineItem.lineArrows[i]:OnMove(lineItem.lineArrowInfos, i)
                end
            end
            lineItem.linePaths:ForEach(
                function(linePath)
                    linePath.transform:SetAsFirstSibling()
                end
            )
        end
    )
end

--获取线显示状态
function Element:GetLineShowState(toItemId)
    local realState = self.chainState
    local zoneList = Utils.GetZoneListByItemId(self.cityId, toItemId)
    if zoneList:Count() <= 0 then
        realState = 2
    elseif realState == -1 then
        realState = 0
    end
    return realState
end

--刷新生产链线路
function Element:OnRefreshLine()
    self.lineItems:ForEach(
        function(lineItem)
            local showState = self:GetLineShowState(lineItem.toChainItem.nodeInfo.itemId)
            if lineItem.showState ~= showState then
                lineItem.showState = showState
                lineItem.linePaths:ForEach(
                    function(viewItem)
                        viewItem:OnRefresh(showState)
                    end
                )
                lineItem.lineFlagPaths:ForEach(
                    function(viewItem)
                        viewItem:OnRefresh(showState)
                    end
                )
            end
            local toward = lineItem.linePaths[lineItem.lineCount - 1]:GetLineToward()
            if lineItem.showState ~= 2 then
                lineItem.toChainItem:ShowLineConsumptions(showState, toward, self.nodeInfo.itemId)
                for i = 1, lineItem.lineArrows:Count(), 1 do
                    lineItem.lineArrows[i]:OnMove(lineItem.lineArrowInfos, i)
                end
            end
            lineItem.lineArrows:ForEach(
                function(arrow)
                    arrow:OnRefresh(showState)
                end
            )
        end
    )
    --排序
    self.lineItems:Sort(
        function(lineItem1, lineItem2)
            return lineItem1.showState <= lineItem2.showState
        end
    )
    self.lineItems:ForEach(
        function(lineItem)
            lineItem.linePaths:ForEach(
                function(linePath)
                    linePath.transform:SetAsFirstSibling()
                end
            )
        end
    )
end

--显示路线生产消耗的资源数量
function Element:ShowLineConsumptions(showState, toward, itemId)
    if toward == nil then
        return
    end
    local consumptionsCount = Utils.GetRoundPreciseDecimal(self:GetConsumptionsCount(itemId), 3)
    local v = string.format("-%s/<size=23>%s</size>", Utils.FormatCount(consumptionsCount), GetLang("UI_Time_Minute"))
    self.LineText[toward].gameObject:SetActive(true)
    self.LineText[toward].text = v
end

--刷新消耗时间
function Element:OnRefreshChainConsumption()
    if self.chainState == 2 then
        return
    end
    local inputCount = Utils.GetRoundPreciseDecimal(self:GetInputCount(), 3)
    if self.chainState == 0 then
        self.txtStock.text = DataManager.GetMaterialCountFormat(self.cityId, self.nodeInfo.itemId)
        self.txtReduce.text = "-" .. Utils.FormatCount(inputCount)
    elseif self.chainState == 1 then
        local itemCount = DataManager.GetMaterialCount(self.cityId, self.nodeInfo.itemId)
        self.txtStock.text = Utils.FormatCount(itemCount)
        self.txtReduce.text = "-" .. Utils.FormatCount(inputCount)
        self:RefreshConsumptionTime(itemCount, inputCount)
    elseif self.chainState == -1 then
        self.txtReduce.text = "-" .. Utils.FormatCount(inputCount)
    end
end

--刷新消耗时间
function Element:RefreshConsumptionTime(itemCount, itemInput)
    if itemInput > 0 then
        local time = itemCount / itemInput
        if time > 0 then
            local seconds = time * 60
            local d = math.modf(seconds / (3600 * 24))
            local h = math.modf((seconds / 3600) % 24)
            local m = math.modf((seconds % 3600) / 60)
            local s = math.modf(seconds % 60)
            local ret = ""
            if d >= 7 then
                ret = GetLang("UI_statisticalitems_run_out_week_later")
            elseif d > 0 then
                ret = ret .. d .. GetLang("UI_Mail_Time_Day")
                ret = ret .. h .. GetLang("UI_Mail_Time_Hour")
            elseif h > 0 then
                ret = ret .. h .. GetLang("UI_Mail_Time_Hour")
                ret = ret .. m .. GetLang("UI_Mail_Time_Min")
                ret = ret .. s .. GetLang("UI_Mail_Time_Sec")
            elseif m > 0 then
                ret = ret .. m .. GetLang("UI_Mail_Time_Min")
                ret = ret .. s .. GetLang("UI_Mail_Time_Sec")
            elseif s > 0 then
                ret = ret .. s .. GetLang("UI_Mail_Time_Sec")
            else
                ret = GetLang("UI_statistical_resource_run_out")
            end
            self.txtCost.text = ret
        end
    else
        -- self.Tips:SetActive(false)
    end
end

function Element:OnDestroy()
    if self.lineItems then
        self.lineItems:ForEach(
            function(lineItem)
                lineItem.linePaths:ForEach(
                    function(path)
                        path:OnDestroy()
                    end
                )
                lineItem.lineArrows:ForEach(
                    function(arrow)
                        arrow:OnDestroy()
                    end
                )
            end
        )
    end
    ResourceManager.Destroy(self.gameObject)
end
