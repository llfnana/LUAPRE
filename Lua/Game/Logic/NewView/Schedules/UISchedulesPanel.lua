---@class UISchedulesPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UISchedulesPanel = Panel;

this.StateEnum = {
    Active = 0,
    Inactive = 1
}

this.IconPath = {
    ["Sleep"] = "clock_icon_sleep",
    ["Arbeit"] = "clock_icon_work",
    ["Eat"] = "clock_icon_food",
}

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}

    this.uidata.mask = this.BindUIControl("Mask", this.HideUI)
    this.uidata.imgFill = this.GetUIControl("ImgBg/ImgFill", "Image")
    this.uidata.txtNormal = this.GetUIControl("Txt/Normal")
    this.uidata.txtSelect = this.GetUIControl("Txt/Select")
    this.uidata.line = this.GetUIControl("Line")
    this.uidata.lineOne = this.GetUIControl("Line/Item")
    this.uidata.icon = this.GetUIControl("Icon")
    this.uidata.iconOne = this.GetUIControl("Icon/Item")
    this.uidata.Pointer = this.GetUIControl("TimeInfo/Pointer")
    this.uidata.imgSunBg = this.GetUIControl(this.uidata.Pointer, "ImgSunBg")
    this.uidata.imgMoonBg = this.GetUIControl(this.uidata.Pointer, "ImgMoonBg")
    this.uidata.imgSun = this.GetUIControl("TimeInfo/ImgSun")
    this.uidata.imgMoon = this.GetUIControl("TimeInfo/ImgMoon")
    this.uidata.txtTime = this.GetUIControl("TimeInfo/TxtTime", "Text")

    this.normalGos = {} ---默认显示的文字
    for i = 1, this.uidata.txtNormal.transform.childCount do
        local go = this.uidata.txtNormal.transform:GetChild(i - 1).gameObject
        go.name = "Normal" .. (i - 1)
        table.insert(this.normalGos, go)
        this.SetTextPosition(go, i - 1)
    end
    this.selectGos = {} ---选中显示的文字
    for i = 1, this.uidata.txtSelect.transform.childCount do
        local go = this.uidata.txtSelect.transform:GetChild(i - 1).gameObject
        go.name = "Select" .. (i - 1)
        table.insert(this.selectGos, go)
        this.SetTextPosition(go, i - 1)
    end

    SafeSetActive(this.uidata.iconOne.gameObject, false)
    SafeSetActive(this.uidata.lineOne.gameObject, false)
    this.icons = nil           ---icon缓存 map<startTime, go>
    this.lines = nil           ---线条缓存
    this.schedulesCfgs = nil   ---当前城市的所有日程配置
    this.currScheduleCfg = nil ---当前城市的当前日程配置
    this.hasFirstSwitch = nil  ---是否初始化过

end

function Panel.InitEvent()
    --绑定UGUI事件
end

function Panel.OnShow()
    UIUtil.openPanelAction(this.gameObject)
    
    this.TimeCityUpdateFunc = function(cityId)
        if this.cityId == cityId then
            this.OnRefreshUI()
        end
    end
    this.AddListener(EventType.TIME_CITY_UPDATE, this.TimeCityUpdateFunc)
    this.SchedulesRefreshFunc = function(cityId)
        if this.cityId == cityId then
            this.OnRefreshSchedulesInfo()
        end
    end
    this.AddListener(EventType.TIME_CITY_PER_REFRESH, this.SchedulesRefreshFunc)

    this.icons = this.icons or {}
    this.hasFirstSwitch = false
    this.cityId = DataManager.GetCityId()
    this.schedulesCfgs = SchedulesManager.GetSchedulesConfigsByMenu(this.cityId)

    this.currScheduleCfg = SchedulesManager.GetCurrentSchedulesByMenu(this.cityId)
    for index, cfg in pairs(this.schedulesCfgs) do
        local rt, factor = this.BuildHourIdxList(cfg.startTime, cfg.endTime)
        local state = this.currScheduleCfg.startTime == cfg.startTime
        --字体显示
        for i, v in ipairs(rt) do
            SafeSetActive(this.normalGos[v % 24 + 1].gameObject, not state)
            SafeSetActive(this.selectGos[v % 24 + 1].gameObject, state)
        end
        --icon位置以及显示
        if this.icons[cfg.startTime] == nil then
            local icon = GOInstantiate(this.uidata.iconOne, this.uidata.icon.transform)
            this.icons[cfg.startTime] = icon
            SafeSetActive(icon, true)
        end
        local path = this.IconPath[cfg.type]
        local normal = this.icons[cfg.startTime].transform:Find("Normal"):GetComponent("Image")
        local select = this.icons[cfg.startTime].transform:Find("Select"):GetComponent("Image")
        --图片加载
        Utils.SetIcon(normal, path .. "_01")
        Utils.SetIcon(select, path)
        SafeSetActive(normal.gameObject, not state)
        SafeSetActive(select.gameObject, state)
        this.AdjustHeight(this.icons[cfg.startTime], factor)
    end


    this.ChangeTime(not TimeManager.GetCityIsNight(this.cityId))

    this.OnRefreshSchedulesInfo()
    this.OnRefreshUI()
    EventManager.AddListener(EventDefine.OnNightChange, this.ChangeTime)
end

function Panel.OnRefreshUI()
    this.uidata.txtTime.text = TimeManager.GetClockFormat(this.cityId)
    local hours = TimeManager.GetCityClockHour(this.cityId)
    local minites = TimeManager.GetCityClock(this.cityId) - hours * 100
    local final = hours + minites / 60 - 90
    this.uidata.Pointer.transform.localEulerAngles = Vector3(0, 0, (final) / 24 * -360)
end

function Panel.OnRefreshSchedulesInfo()
    this.currScheduleCfg = SchedulesManager.GetCurrentSchedulesByMenu(this.cityId)
    if this.currScheduleCfg then
        this.Switch(this.currScheduleCfg.startTime)
    end
end

---@param startTime number
function Panel.Switch(startTime)
    local rt, factor = this.BuildHourIdxList(this.currScheduleCfg.startTime, this.currScheduleCfg.endTime)
    --字体显示
    local temp = {}
    for i, v in ipairs(rt) do
        temp[v] = true
    end
    for i = 1, #this.normalGos do
        local normal = this.normalGos[i % 24 + 1]
        local select = this.selectGos[i % 24 + 1]
        SafeSetActive(normal.gameObject, temp[i] == nil)
        SafeSetActive(select.gameObject, temp[i] ~= nil)
    end
    for k, v in pairs(this.icons) do
        local normal = v.transform:Find("Normal")
        local select = v.transform:Find("Select")
        SafeSetActive(normal.gameObject, k ~= startTime)
        SafeSetActive(select.gameObject, k == startTime)
    end

    local hourIdxList, _ = this.BuildHourIdxList(this.currScheduleCfg.startTime, this.currScheduleCfg.endTime)
    local startHour, m1 = math.modf(this.currScheduleCfg.startTime / 100)
    local endHour, m2 = math.modf(this.currScheduleCfg.endTime / 100)
    startHour = math.floor(m1 * 100 + 0.5) == 30 and startHour + 0.5 or startHour
    endHour = math.floor(m2 * 100 + 0.5) == 30 and endHour + 0.5 or endHour
    local startFill = this.uidata.imgFill.fillAmount
    local endFill = (endHour - startHour) / 24
    local startAngles = this.uidata.imgFill.transform.localEulerAngles
    local endZ = (startHour) / 24 * -360
    endZ = endZ + 180
    if math.abs(endZ - startAngles.z) > 180 then
        endZ = endZ + 360
    end
    local endAngles = Vector3(0, 0, endZ)
    if (this.hasFirstSwitch ~= true) then
        this.uidata.imgFill.fillAmount = endFill
        this.uidata.imgFill.transform.localEulerAngles = endAngles
        this.hasFirstSwitch = true
    else
        Util.TweenTo(0, 1, 0.3, function(p)
            this.uidata.imgFill.fillAmount = startFill + (endFill - startFill) * p
            this.uidata.imgFill.transform.localEulerAngles = startAngles + (endAngles - startAngles) * p
        end)
    end
end

---根据开始结束时间获取时间段以及中间点
---@param startTime number
---@param endTime number
---@return List<number>, number
---@return number
function Panel.BuildHourIdxList(startTime, endTime)
    local rt = List:New()
    local factor = (startTime + endTime) / 2 / 100

    local h1, m1 = math.modf(startTime / 100)
    local h2, m2 = math.modf(endTime / 100)

    for i = h1, h2 do
        rt:Add(i)
    end

    if math.floor(m2 * 100 + 0.5) == 30 then
        h2 = h2 + 0.5
    end

    if math.floor(m1 * 100 + 0.5) == 30 then
        rt:Remove(h1)
        h1 = h1 + 0.5
    end

    --实例化线条
    this.AdjustLine(startTime, h1)
    this.AdjustLine(endTime, h2)

    return rt, factor
end

---设置对应的位置坐标
function Panel.AdjustHeight(go, half)
    local radius = 200
    --调整位置
    local angle = -this.GetHourAngle(half)
    local x = radius * math.sin(angle * math.pi / 180)
    local y = radius * math.cos(angle * math.pi / 180)
    go.transform.localPosition = Vector3(x, y, 0)
end

function Panel.GetHourAngle(hour)
    return (hour) * -360 / 24
end

function Panel.SetTextPosition(go, half)
    local radius = 320
    --调整位置
    local angle = -this.GetHourAngle(half)
    local x = radius * math.sin(angle * math.pi / 180)
    local y = radius * math.cos(angle * math.pi / 180)
    go.transform.localPosition = Vector3(x, y, 0)
end

---调整线条
function Panel.AdjustLine(index, hour)
    this.lines = this.lines or {}
    if this.lines[index] == nil then
        local line = GOInstantiate(this.uidata.lineOne, this.uidata.line.transform)
        this.lines[index] = line
        SafeSetActive(line, true)
    end
    local angle = this.GetHourAngle(hour)
    this.lines[index].transform.localEulerAngles = Vector3(0, 0, angle)
end

function Panel.ChangeTime(isSun)
    if this.uidata == nil then
        return
    end
    SafeSetActive(this.uidata.imgMoonBg.gameObject, not isSun)
    SafeSetActive(this.uidata.imgSunBg.gameObject, isSun)
    SafeSetActive(this.uidata.imgMoon.gameObject, not isSun)
    SafeSetActive(this.uidata.imgSun.gameObject, isSun)
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        EventManager.RemoveListener(EventDefine.OnNightChange, this.ChangeTime)
        HideUI(UINames.UISchedules)
    end)
end
