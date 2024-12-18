---@class PersonCell
local Element = class("PersonCell")
PersonCell = Element

function Element:ctor()

end

function Element:InitPanel(behaviour, obj, workState, hasPeople, needLevel)
    self.gameObject = obj
    self.transform = obj.transform
    self.behaviour = behaviour

    if self.uidata == nil then self.uidata = {} end

    self.uidata.ImageIcon = SafeGetUIControl(self, "ImageIcon")
    self.uidata.ImageLock = SafeGetUIControl(self, "ImageLock")
    self.uidata.ImageState = SafeGetUIControl(self, "ImageState")
    self.uidata.TextLock = SafeGetUIControl(self, "ImageLock/TextLock", "Text")

    self:OnRefresh(workState, hasPeople, needLevel)
end

function Element:OnRefresh(workState, hasPeople, needLevel)
    SafeSetActive(self.uidata.ImageLock, false)

    local ResName = "icon_worker_people_empty_1"
    local StateResName = "icon_worker_subscript_riots"

    if workState == WorkStateType.None then
        SafeSetActive(self.uidata.ImageState, false)
    elseif workState == WorkStateType.Work then
        SafeSetActive(self.uidata.ImageState, false)
        ResName = "icon_worker_people_working_1"
    elseif workState == WorkStateType.Disable then
        SafeSetActive(self.uidata.ImageState, false)
        SafeSetActive(self.uidata.ImageLock, true)
        SafeSetActive(self.uidata.ImageIcon, false)
        self.uidata.TextLock.text = needLevel
    elseif workState == WorkStateType.Pause then
        ResName = "icon_worker_people_ill_1"
        SafeSetActive(self.uidata.ImageState, true)
        StateResName = "icon_worker_subscript_pause"
    elseif workState == WorkStateType.Sick then
        ResName = "icon_worker_people_ill_1"
        SafeSetActive(self.uidata.ImageState, true)
        StateResName = "icon_worker_subscript_treatmet"
    elseif workState == WorkStateType.Protest then
        ResName = "icon_worker_people_ill_1"
        StateResName = "icon_worker_subscript_riots"
        SafeSetActive(self.uidata.ImageState, true)
    end

    if not hasPeople then
        ResName = "icon_worker_people_empty_1"
    end

    local icon = SafeGetUIControl(self, "ImageIcon", "Image")
    local state = SafeGetUIControl(self, "ImageState", "Image")
    Utils.SetIcon(icon, ResName, nil, nil, true)
    Utils.SetIcon(state, StateResName, nil, nil, true)
end
