---@class UIMapPanel : UIPanelBase
local Panel = UIPanelBaseMake()
local this = Panel;
UIMapPanel = Panel;

require "Game/Logic/NewView/Map/SelectItem"

function Panel.OnAwake()
    this.cachedata = {}
    this.InitPanel()
    this.InitEvent()

    this.param = nil
end

-- TODO zhkxin SelectItem 并没有显示，也没有调用显示的地方，先游戏对应的贴图资源删掉

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.ButtonBack = SafeGetUIControl(this, "BottomUI/ButtonBack")
    this.uidata.content = SafeGetUIControl(this, "ScrollView/Viewport/Content")
    this.uidata.contentBg = SafeGetUIControl(this, "ScrollView/Viewport/Content/ImageBg")

    this.uidata.car = SafeGetUIControl(this, "ScrollView/Viewport/Content/ImageBg/Effect/Car")
    this.uidata.carSkeleton = this.GetUIControl(this.uidata.car, "SkeletonGraphic", "SkeletonGraphic")

    this.uidata.carSkeleton:Initialize(true)
    this.uidata.carSkeleton.AnimationState:SetAnimation(0, "animation", true)
end

function Panel.InitEvent()
    SafeAddClickEvent(this.behaviour, this.uidata.ButtonBack, this.HideUI)
end

function Panel.OnShow(param)
    this.cityId = DataManager.GetCityId()
    this.param = param or {}
    if this.param.callback then 
        this.param.callback()
    end

    this.PlayShowAni()

    this.maxCityId = ConfigManager.GetCityCount()
    this.unlockCityId = DataManager.GetCityId()
    this.readyUnlockCity = this.unlockCityId
    local taskCount, taskTotal = TaskManager.GetSceneTaskProgress(this.unlockCityId)
    if taskCount >= taskTotal then
        this.readyUnlockCity = math.min(this.unlockCityId + 1, this.maxCityId)
    end

    local count = ConfigManager.GetCityCount()
    local tempPath = "ScrollView/Viewport/Content/ImageBg/Image"
    for i = 1, count, 1 do
        SafeGetUIControl(this, tempPath..i):SetActive(this.unlockCityId > i)
    end

    for cityId = 1, count do
        -- 图标
        local checkPoint = this.GetCheckPoint(cityId)
        local icon = this.InitPointIcon(cityId, checkPoint)

        -- 名字
        local name = this.InitPointName(cityId, checkPoint)
    end

    for cityId = 1, count do
        local cityConfig = ConfigManager.GetCityById(cityId)
        local checkPoint = this.GetCheckPoint(cityId)
        checkPoint.transform:Find("ImageComPoint/TextTitle"):GetComponent("Text").text = GetLang(cityConfig.city_name)

        local icon = checkPoint.transform:Find("ImageComPoint/ImageIcon").gameObject
        local arrow = checkPoint.transform:Find("ImageComPoint/Arrow").gameObject
        local bg1 = checkPoint.transform:Find("ImageComPoint/ImageTitleBg1").gameObject
        local bg2 = checkPoint.transform:Find("ImageComPoint/ImageTitleBg2").gameObject
        local point = checkPoint.transform:Find("ImageComPoint/Point")
        SafeSetActive(arrow, cityId == this.cityId)
        SafeSetActive(bg1, cityId <= this.unlockCityId)
        SafeSetActive(bg2, cityId > this.unlockCityId)
        GreyObject(icon.gameObject, cityId > this.unlockCityId)
        if cityId == this.cityId then
            this.uidata.car.transform.position = point.transform.position
        end
    end

    if param and param.isPass then
        SafeGetUIControl(this, string.format("ScrollView/Viewport/Content/ImageBg/Image%d", (this.readyUnlockCity - 1)))
            :SetActive(true)
        TimeModule.addDelay(1, function()
            this.PlayMoveToCheckPoint(this.readyUnlockCity)
        end)
    end

    local x = -512
    local y = -1200
    if this.cityId >= 8 then 
        y = -1600
    end

    -- this.uidata.contentBg.transform.localPosition = Vector3(-12, y + 1000, 0)
    this.uidata.contentBg:GetComponent("RectTransform").anchoredPosition = Vector2(x, y)
end

function Panel.PlayShowAni()
    this.uidata.content.transform.localScale = Vector3(0.95, 0.95, 1)
    Util.TweenTo(0.95, 1, 0.2, function(v)
        this.uidata.content.transform.localScale = Vector3(v, v, 1)
    end):SetEase(Ease.Linear)
end

function Panel.GetCheckPoint(cityId)
    return SafeGetUIControl(this, "ScrollView/Viewport/Content/ImageBg/CheckPoint" .. cityId)
end

-- 建筑图标
function Panel.InitPointIcon(cityId, checkPoint)
    local icon = nil
    local pointIcon = checkPoint.transform:Find("ImageComPoint/ImageIcon")
    if pointIcon ~= nil then
        icon = pointIcon.gameObject:GetComponent("Image")
        Utils.SetIcon(icon, string.format("map_img_build_%s", cityId))
    end
end

-- 关卡数字
function Panel.InitPointName(cityId, checkPoint)
    local TextNum1 = checkPoint.transform:Find("ImageComPoint/TextNum")
    if TextNum1 ~= nil then
        TextNum1.gameObject:GetComponent("Text").text = cityId
    end
end

function Panel.PlayMoveToCheckPoint(nextCityId, endCallBack)
    local currentCityId = this.cityId
    if nextCityId > ConfigManager.GetCityCount() or currentCityId - 1 > nextCityId then
        return
    end
    local nowPoint = this.GetCheckPoint(currentCityId)
    local checkPoint = this.GetCheckPoint(nextCityId)
    local point = checkPoint.transform:Find("ImageComPoint/Point")

    --调转车头
    local y = checkPoint.transform.anchoredPosition.x > nowPoint.transform.anchoredPosition.x and 0 or 180
    this.uidata.car.transform.rotation = Quaternion.Euler(0, y, 0)

    TimeModule.addDelay(0.3, function()
        nowPoint.transform:Find("ImageComPoint/Arrow").gameObject:SetActive(false)
    end)
    Audio.PlayAudio(DefaultAudioID.KaiChe)
    this.uidata.car.transform:DOMove(point.transform.position, 1):SetEase(Ease.OutSine):OnComplete(function()
        if CityManager.IsUnlock(nextCityId) then
            checkPoint.transform:Find("ImageComPoint/Arrow").gameObject:SetActive(true)
            CityManager.SelectCity(nextCityId, true)
        else
            CityManager.UnlockCity(nextCityId, currentCityId, true)
            UIMainPanel.ShowMainUI()
            this.param.isPass = nil
            this.HideUI()
        end
        -- this.HideUI()
    end)

    TimeModule.addDelay(0.6, function()
        local icon = checkPoint.transform:Find("ImageComPoint/ImageIcon").gameObject
        GreyObject(icon.gameObject, false)
        local img = icon:GetComponent("Image")
        TimeModule.addDelay(0, function()
            img.color = Color.New(1, 1, 1, 0.9)
            TimeModule.addDelay(0.01, function()
                img.color = Color.New(1, 1, 1, 1)
            end)
        end)
    end)
end

function Panel.HideUI()
    if this.param and this.param.isPass then
        return
    end
    HideUI(UINames.UIMap)
end
