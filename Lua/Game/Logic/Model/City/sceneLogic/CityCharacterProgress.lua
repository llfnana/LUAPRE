---@class CityCharacterProgress @城市角色进度条
local Element = class("CityCharacterProgress")
CityCharacterProgress = Element

function Element:ctor()
    self.gameObject = nil
    self.transform = nil
    self.isBind = false
    self.isShow = false
end

function Element:bind(go)
    self.isBind = true
    self.gameObject = go

    self.transform = self.gameObject.transform
    self.slider = SafeGetUIControl(self.gameObject, "Slider", "Slider")

    local function activeGo()
        if isNil(self.gameObject) then 
            if self.removeListener then
                self.removeListener()
                self.removeListener = nil
            end
        else 
            self:SetActive()
        end
    end

    EventManager.AddListener(EventDefine.CitySceneUIDisplay, activeGo)
    self.removeListener = function ()
        EventManager.RemoveListener(EventDefine.CitySceneUIDisplay, activeGo)
    end
end

-- 有屋顶时不显示
function Element:SetActive()
    self.gameObject:SetActive(self.isShow and CityModule.getMainCtrl().camera:getRoofActive() == false)
end

-- 初始化
function Element:ShowView(param)
    self.isShow = true
    self:SetActive()
    self.slider.value = param.value
    self.slider.gameObject:SetActive(true)
end

function Element:HideView()
    self.isShow = false
    self:SetActive()
end

function Element:destroy()
    if self.removeListener then
        self.removeListener()
        self.removeListener = nil
    end

    if self.gameObject then 
        GODestroy(self.gameObject)
    end

    self.gameObject = nil
    self.transform = nil
    self.isBind = false
end