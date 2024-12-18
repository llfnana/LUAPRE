---@class SelectItem
local Element = class("SelectItem")
SelectItem = Element

function Element:ctor()

end

function Element:InitPanel(behaviour, obj)
    self.gameObject = obj
    self.transform = obj.transform
    self.behaviour = behaviour

    self.cityId = DataManager.GetCityId()

    self.ButtonGo = SafeGetUIControl(self, "ButtonGo")
    self.ButtonCur = SafeGetUIControl(self, "ButtonCur")
    self.ButtonLock = SafeGetUIControl(self, "ButtonLock")

    SafeGetUIControl(self, "ButtonGo/Text", "Text").text = GetLang("ui_task_btn_next")
    SafeGetUIControl(self, "ButtonCur/Text", "Text").text = GetLang("UI_Map_Btn_Position")
    SafeGetUIControl(self, "ButtonLock/Text", "Text").text = GetLang("UI_Map_Btn_Locked")

    SafeAddClickEvent(self.behaviour, SafeGetUIControl(self, "btnClose"), function()
        self.gameObject:SetActive(false)
    end)

    SafeAddClickEvent(self.behaviour, SafeGetUIControl(self, "ButtonGo"), function()
        self.gameObject:SetActive(false)
        -- UIUtil.showText('跳转地图city')
        -- CityManager.SelectCity(self.index, true)
        UIMapPanel.PlayMoveToCheckPoint(self.index)
    end)
end

function Element:SetData(index)
    self.gameObject:SetActive(true)

    self.index = index
    local unlock = CityManager.IsUnlock(self.index)
    self.config = ConfigManager.GetCityById(self.index)
    SafeGetUIControl(self, "TextTitle", "Text").text = GetLang(self.config.city_name)
    SafeGetUIControl(self, "TextDes", "Text").text = GetLang(self.config.city_desc)
    local img = SafeGetUIControl(self, "ImageBuild", "Image")
    local path = index == 1 and "map_img_landscape" or index == 2 and "map_img_landscape_01" or "map_img_landscape_02"
    SetImage(self.behaviour, img, path)

    self.ButtonGo:SetActive(false)
    self.ButtonCur:SetActive(false)
    self.ButtonLock:SetActive(false)
    GreyObject(self.ButtonLock, true, false, false)
    if unlock then
        if self.index == DataManager.GetCityId() then
            self.ButtonCur:SetActive(true)
        end
        self.isUnlock = true
    else
        if self.index == DataManager.GetMaxCityId() + 1 then
            local taskCount, taskTotal = TaskManager.GetSceneTaskProgress(DataManager.GetMaxCityId())
            if taskCount >= taskTotal then
                -- self.ButtonGo:SetActive(true)
                -- self.isUnlock = true
            else
                self.ButtonLock:SetActive(true)
            end
        else
            self.ButtonLock:SetActive(true)
        end
    end
end
