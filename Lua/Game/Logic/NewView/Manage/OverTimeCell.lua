---@class OverTimeCell
local Element = class("OverTimeCell")
OverTimeCell = Element

function Element:ctor()

end

function Element:InitPanel(behaviour, obj, zoneId)
    self.gameObject = obj
    self.transform = obj.transform
    self.behaviour = behaviour

    if self.uidata == nil then self.uidata = {} end

    self.uidata.ImageIcon = SafeGetUIControl(self, "ImageIcon", "Image")
    self.uidata.ImageItemIcon = SafeGetUIControl(self, "ImageItemIcon", "Image")
    -- self.uidata.ImageLock = SafeGetUIControl(self, "ImageLock")
    -- self.uidata.ImageState = SafeGetUIControl(self, "ImageState")
    self.ScheduleStateText = SafeGetUIControl(self, "TextDes", "Text")

    self.cityId = DataManager.GetCityId()
    self.zoneId = zoneId
    self.mapItemData = MapManager.GetMapItemData(self.cityId, zoneId)

    local peopleConfig = ConfigManager.GetPeopleConfigByZoneType(self.cityId, self.mapItemData.config.zone_type)
    local typeLang = ""
    if peopleConfig.people_name ~= "" then
        typeLang = GetLang(peopleConfig.people_name)
    end

    Utils.SetZoneBonusIcon(self.mapItemData.config.id, self.uidata.ImageItemIcon)
    Utils.SetZoneIcon(self.uidata.ImageIcon, zoneId, 1) -- self.mapItemData:GetLevel()
    UIUtil.AddZone(self.uidata.ImageIcon, self.mapItemData.config.id, UINames.UIManage, self.mapItemData:GetLevel())

    SafeGetUIControl(self, "lab/TextBuild", "Text").text = self.mapItemData:GetName()
    SafeGetUIControl(self, "lab/TextJob", "Text").text = typeLang
    self:OnInit()
end

function Element:OnInit()
    self.isActiveWorkOverTime = WorkOverTimeManager.IsActiveWorkOverTimeByZoneId(self.cityId, self.zoneId)
    self:SetToggle(self.isActiveWorkOverTime, true)

    SafeAddClickEvent(self.behaviour, SafeGetUIControl(self, "ImgBtnBg", "Image").gameObject, function()
        self:OnToggle()
    end)

    
end

function Element:OnToggle()
    self.isActiveWorkOverTime = not self.isActiveWorkOverTime
    if self.isActiveWorkOverTime then
        WorkOverTimeManager.AddWorkOverTime(self.cityId, self.zoneId)
    else
        WorkOverTimeManager.RemoveWorkOverTime(self.cityId, self.zoneId)
    end
    self:SetToggle(self.isActiveWorkOverTime, true)
end

function Element:SetToggle(enable, isAni)
    local btn = SafeGetUIControl(self, "ImgBtnBg/ImgButton", "Image")
    local offsetX = 37
    if isAni then
        btn.transform:DOLocalMoveX(enable and offsetX or -offsetX, 0.2)
    else
        btn.transform.localPosition = Vector3.New(enable and offsetX or -offsetX, 0, 0)
    end

    local resName = enable and "com_bt_green_s" or "com_bt_red_s"
    Utils.SetIcon(btn, resName)

    self:OnRefresh()
end

function Element:OnRefresh()
    self.workOverTimeState = WorkOverTimeManager.GetWorkOverTimeState(self.cityId, self.zoneId)
    --刷新状态信息
    if self.workOverTimeState == WorkOvertimeState.None then
        if SchedulesManager.IsSchdulesActive(self.cityId, SchedulesType.Sleep) then
            self.ScheduleStateText.text = GetLang("over_time_state_sleeping")
        else
            self.ScheduleStateText.text = GetLang("over_time_state_will_sleep")
        end
    elseif self.workOverTimeState == WorkOvertimeState.Wait then
        self:RefreshWaitRemainTime()
    elseif self.workOverTimeState == WorkOvertimeState.Run then
        self.ScheduleStateText.text = GetLang("over_time_state_working")
    end
end

function Element:RefreshWaitRemainTime()
    local remainTime = WorkOverTimeManager.GetNextOverTimeRemainTime(self.cityId, WorkOvertimeState.Wait)
    self.ScheduleStateText.text = GetLangFormat("over_time_state_will_work", remainTime)
end
