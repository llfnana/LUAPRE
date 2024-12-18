---@class CityFoodUI @城市食物UI
local Element = class("CityFoodUI")
CityFoodUI = Element

function Element:ctor()
    self.gameObject = nil
    self.isBind = false
end

function Element:bind(go)
    self.isBind = true
    self.gameObject = go
end

function Element:init(params)
    if self.isBind == false then
        return
    end
    local ItemDetail = SafeGetUIControl(self.gameObject, "ItemDetail")
    ItemDetail:SetActive(true)

    self.Icon = SafeGetUIControl(self.gameObject, "ItemDetail/Icon", "Image")
    self.Text = SafeGetUIControl(self.gameObject, "ItemDetail/Text", "Text")  
    self.InnerText = SafeGetUIControl(self.gameObject, "ItemDetail/Text/Text", "Text") 

    local function activeGo(display)
        self.gameObject:SetActive(display)
    end
    EventManager.AddListener(EventDefine.CitySceneUIDisplay, activeGo)
    self.removeListener = function ()
        EventManager.RemoveListener(EventDefine.CitySceneUIDisplay, activeGo)
    end

    self:UpdateView(params)
end

function Element:UpdateView(params)
    if self.isBind == false then
        return
    end
    if params.sprite then
        Utils.SetItemIcon(self.Icon, params.sprite, false, true)
    end
    if params.value then
        self.Text.text = params.value
        self.InnerText.text = params.value
    end
end

function Element:Clear()
    self:removeListener()
end