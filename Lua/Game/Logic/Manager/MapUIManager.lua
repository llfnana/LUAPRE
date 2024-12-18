MapUIManager = {}
MapUIManager.__cname = "MapUIManager"

local this = MapUIManager

MapUIManager.MapType = {
    ScaleBig = 1,
    ScaleSmall = 2
}

MapUIManager.WorldType = {
    CanScale = 1,
    NotCantScale = 2
}

this.itemcontent = nil
this.ViewportRectTrans = nil
this.selectPanleCallback = nil
this.maplineRootCanvasGroup = nil

this.currentMapType = 0

this.currentWorldType = 0
--初始化地图管理器
function MapUIManager.Init()
end

function MapUIManager.InitView()
end
--
function MapUIManager.OnMapProcess(Itemobj, moveConfig, movetarget, arriveAction, type)
    local scale = 1
    if type == 1 then
        scale = 1
    else
        scale = movetarget.gameObject:GetComponent(typeof(CS.FrozenCity.MapScale)).MapScaleValue
    end

    Itemobj.transform:DOScale(scale, 0.7)
    moveConfig:MoveToLevelPoint(
        movetarget.gameObject,
        function()
        end,
        function()
            if arriveAction ~= nil then
                arriveAction()
            end
        end,
        1500,
        scale
    )
end

function MapUIManager.initMapProcess(Itemobj, moveConfig, selectCallback, movetarget, type)
    this.itemcontent = Itemobj
    this.moveConfig = moveConfig
    if type == 1 then
        local scale = movetarget.gameObject:GetComponent(typeof(CS.FrozenCity.MapScale)).MapScaleValue
        Itemobj.transform.localScale = luaVector3.New(scale, scale, scale)
        moveConfig:ScrollToLevelPoint(movetarget.gameObject, scale)
        this.selectPanleCallback = selectCallback
    else
        moveConfig:ScrollToCheckPoint(movetarget.gameObject)
    end
end
function MapUIManager.initMapProcess_old(Itemobj, moveConfig, movetarget)
    moveConfig:SetIsVerticalMove(true)
    moveConfig:SetHorizontalMove(true)
    scale = movetarget.gameObject:GetComponent(typeof(CS.FrozenCity.MapScale)).MapScaleValue
    Itemobj.transform.localScale = luaVector3.New(scale, scale, scale)
    moveConfig:ScrollToLevelPoint(movetarget.gameObject, scale)
    moveConfig:SetIsVerticalMove(false)
    moveConfig:SetHorizontalMove(false)
end

function MapUIManager.MouseDown()
end

function MapUIManager.MouseUp()
end

function MapUIManager.OnDrag()
    --MapUIManager.ResetPivot()
    -- local ContentX = 0
    -- if Mathf.Abs(this.itemcontent.localPosition.x + Screen.width / 2) + Screen.width > 1222 then
    --     ContentX = Screen.width - 1222 - Screen.width / 2
    -- end
    --this.itemcontent.localPosition =
    --    Vector3(ContentX, this.itemcontent.localPosition.y, this.itemcontent.localPosition.z)
end

function MapUIManager.OnZoomMap(value, fingerpos)
    if this.itemcontent == nil then
        LogWarning("old version UI world map")
    else
        if this.currentWorldType == this.WorldType.CanScale then
            local delateValue = value
            MapUIManager.ZoomImgByMousePos(fingerpos, delateValue)
        end
    end
end

local scaleMin = 1
local scaleMax = 3.5
local swithcThreshold = 2.5
function MapUIManager.ZoomImgByMousePos(mousePosition, delateValue)
    if this.itemcontent ~= nil and MapUIManager.ViewportRectTrans ~= nil then
        local x, y = this.moveConfig:OnScreenPointToLocalPointInRectangle(mousePosition.x, mousePosition.y)
        local OffsetX = x - this.itemcontent.anchoredPosition.x
        local OffsetY = y - this.itemcontent.anchoredPosition.y

        local PivotX = OffsetX / this.itemcontent.rect.width / this.itemcontent.localScale.x
        local Pivoty = OffsetY / this.itemcontent.rect.height / this.itemcontent.localScale.y

        this.itemcontent.pivot = this.itemcontent.pivot + Vector2(PivotX, Pivoty)
        this.itemcontent.anchoredPosition = this.itemcontent.anchoredPosition + Vector2(OffsetX, OffsetY)
        this.itemcontent.localScale = this.itemcontent.localScale + Vector3(delateValue, delateValue, delateValue)
        if this.itemcontent.localScale.x > swithcThreshold then -- 大于阈值 切换到 MapType.ScaleBig
            if this.currentMapType == this.MapType.ScaleSmall then
                this.currentMapType = this.MapType.ScaleBig
                if this.selectPanleCallback ~= nil then
                    this.selectPanleCallback()
                end
            end
        else -- 小于阈值  切换到 MapType.ScaleSmall
            if this.currentMapType == this.MapType.ScaleBig then
                this.currentMapType = this.MapType.ScaleSmall
                if this.selectPanleCallback ~= nil then
                    this.selectPanleCallback()
                end
            end
        end
        if this.itemcontent.localScale.x < scaleMin then
            this.itemcontent.localScale = Vector3(scaleMin, scaleMin, scaleMin)
        elseif this.itemcontent.localScale.x > scaleMax then
            this.itemcontent.localScale = Vector3(scaleMax, scaleMax, scaleMax)
        end
        this.SetLineRootCanvasGroup(this.itemcontent.localScale.x)
    end
end

function MapUIManager.initWolrdAutoScale(callback)
    this.initAutoCallback = callback
end

function MapUIManager.UpdateWolrdAutoScale(targetPos)
    local ScreenPos = Utils.GetCamera():WorldToScreenPoint(targetPos)
    local x, y = this.moveConfig:OnScreenPointToLocalPointInRectangle(ScreenPos.x, ScreenPos.y)
    local OffsetX = x - this.itemcontent.anchoredPosition.x
    local OffsetY = y - this.itemcontent.anchoredPosition.y

    local PivotX = OffsetX / this.itemcontent.rect.width / this.itemcontent.localScale.x
    local Pivoty = OffsetY / this.itemcontent.rect.height / this.itemcontent.localScale.y

    this.itemcontent.pivot = this.itemcontent.pivot + Vector2(PivotX, Pivoty)
    this.itemcontent.anchoredPosition = this.itemcontent.anchoredPosition + Vector2(OffsetX, OffsetY)
    local delateValue = 0.06
    this.itemcontent.localScale = this.itemcontent.localScale + Vector3(delateValue, delateValue, delateValue)
    if this.itemcontent.localScale.x > swithcThreshold then
        if this.currentMapType == this.MapType.ScaleSmall then
            this.currentMapType = this.MapType.ScaleBig
            if this.initAutoCallback ~= nil then
                this.initAutoCallback()
            end
        end
    end
    if this.itemcontent.localScale.x > scaleMax then
        this.itemcontent.localScale = Vector3(scaleMax, scaleMax, scaleMax)
    end
    MapUIManager.SetLineRootCanvasGroup(this.itemcontent.localScale.x)
end

function MapUIManager.ResetPivot()
    local pivot = Vector2(0, 0.5)
    local pos = this.itemcontent.anchoredPosition
    pos.x = pos.x - this.itemcontent.rect.width * (this.itemcontent.pivot.x - pivot.x) * this.itemcontent.localScale.x
    pos.y = pos.y - this.itemcontent.rect.height * (this.itemcontent.pivot.y - pivot.y) * this.itemcontent.localScale.y
    this.itemcontent.pivot = pivot
    this.itemcontent.anchoredPosition = pos
end

function MapUIManager.SetLineRootCanvasGroup(mapScale)
    local value = -0.67 * mapScale + 1.67
    if value < 0 then
        value = 0
    elseif value > 1 then
        value = 1
    end
    this.maplineRootCanvasGroup.alpha = value
end
