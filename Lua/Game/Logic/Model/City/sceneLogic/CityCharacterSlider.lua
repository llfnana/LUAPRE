---@class CityCharacterSlider @城市角色进度条
local Element = class("CityCharacterSlider")
CityCharacterSlider = Element

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
   
    local function activeGo(display)
        self:SetActive()
    end
    EventManager.AddListener(EventDefine.CitySceneUIDisplay, activeGo)
    self.removeListener = function ()
        EventManager.RemoveListener(EventDefine.CitySceneUIDisplay, activeGo)
    end

    self.sliderParent = self.transform:Find("Content")
    self.offsetGO = SafeGetUIControl(self.gameObject, "Content/Offset")

    self.sliderItems = {}
    self.slider = SafeGetUIControl(self.gameObject, "Content/SliderItem")
    table.insert(self.sliderItems, self:InitSliderItem(self.slider))
end

function Element:SetActive()
    if isNil(self.gameObject) == false then 
        self.gameObject:SetActive(self.isShow and CityModule.getMainCtrl().camera:getRoofActive() == false)
    end
end

function Element:InitSliderItem(slider)
    local sliderItem = {}
    sliderItem.gameObject = slider
    sliderItem.icon = SafeGetUIControl(slider, "Icon", "Image")
    sliderItem.fillImg = SafeGetUIControl(slider, "Slider/Fill Area/Fill", "Image")
    sliderItem.fillBg = SafeGetUIControl(slider, "Slider/Background", "Image")
    sliderItem.slider = SafeGetUIControl(slider, "Slider", "Slider")
    return sliderItem
end

function Element:GetSliderItem(index)
    if index > #self.sliderItems then 
        table.insert(self.sliderItems, self:InitSliderItem(GOInstantiate(self.slider, self.sliderParent)))
    end
    return self.sliderItems[index]
end

function Element:UpdateSliderItem(sliderItem, attributeType, progress)
    sliderItem.gameObject:SetActive(true)
    Utils.SetAttributeIcon(sliderItem.icon, attributeType)
    -- 进度条颜色
    -- self.Fill:SelectSprite(Utils.GetSelectIndexByAttributeType(attributeType) or 3)
    Utils.SetIcon(sliderItem.fillImg, Utils.GetCharacterStateSliderName(attributeType), nil, true)
    Utils.SetIcon(sliderItem.fillBg, Utils.GetCharacterStateSliderBgName(attributeType), nil, true)
    sliderItem.slider.value = progress
end

-- 初始化
function Element:ShowView(params, isOffset)
    self.isShow = true
    self:SetActive()
    isOffset = isOffset or false
    self.transform.localPosition = Vector3.zero
    self.transform.localScale = Vector3.one
    self.offsetGO:SetActive(isOffset)

    local index = 1
    for key, value in pairs(params) do
        local sliderItem = self:GetSliderItem(index)
        self:UpdateSliderItem(sliderItem, key, value)
        index = index + 1
    end
end

function Element:HideView()
    self.isShow = false
    self:SetActive()
    for index, value in ipairs(self.sliderItems) do
        if isNil(value.gameObject)  == false then 
            value.gameObject:SetActive(false)
        end
    end
end

function Element:destroy()
    if self.removeListener then
        self:removeListener()
        self.removeListener = nil
    end

    if self.gameObject then 
        GODestroy(self.gameObject)
    end

    self.gameObject = nil
    self.transform = nil
    self.isBind = false
end