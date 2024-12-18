---@class CityCharacterTips @城市角色进度条
local Element = class("CityCharacterTips")
CityCharacterTips = Element

function Element:ctor()
    self.gameObject = nil
    self.transform = nil
    self.isBind = false
end

function Element:bind(go)
    self.isBind = true
    self.gameObject = go
    self.transform = self.gameObject.transform
    self.icon = SafeGetUIControl(self.gameObject, "ItemReward/Icon", "Image")
    self.text = SafeGetUIControl(self.gameObject, "ItemReward/Text", "Text")
    self.item = SafeGetUIControl(self.gameObject, "ItemReward")
    self.itemTransform = self.item.transform
end

function Element:ShowView(param)
    self.transform.localPosition = Vector3.zero
    self.transform.localScale = Vector3.one
    self.gameObject:SetActive(true)

    self:UpdateView(param)
end

function Element:UpdateView(param) 
    self.item:SetActive(true)
    self:_SetParam(param[1])

    local seq = DOTween.Sequence()
    seq:Append(self.itemTransform:DOLocalMoveY(0.6, 0.5))
    seq:AppendInterval(0.3)

    if param[2] ~= nil then
        seq:AppendCallback(function()
            self:_SetParam(param[2])
        end)
        seq:Append(self.itemTransform:DOLocalMoveY(0.6, 0.5))
        seq:AppendInterval(0.3)
    end

    seq:AppendCallback(function()
        self.gameObject:SetActive(false)
    end)
end

function Element:_SetParam(param)
    self.itemTransform.localPosition = Vector3.zero
    param.iconFun(self.icon, param.iconParams, nil, true)
    self.text.text = "+" .. Utils.FormatCount(param.value)
end

function Element:destroy()
    if self.gameObject then 
        GODestroy(self.gameObject)
    end

    self.gameObject = nil
    self.transform = nil
    self.isBind = false
end