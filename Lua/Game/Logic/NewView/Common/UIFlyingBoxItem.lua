---@class UIFlyingBoxItem
local Element = class("UIFlyingBoxItem")
UIFlyingBoxItem = Element

function Element:ctor()
end

function Element:InitPanel(behaviour, obj, param)
    self.gameObject = obj;
    self.transform = obj.transform;
    self.behaviour = behaviour;
    param = param or {}

    if self.uidata == nil then self.uidata = {} end
    self.uidata.imgIcon = SafeGetUIControl(self, "ImgIcon", "Image")
    self.uidata.txtNum = SafeGetUIControl(self, "TxtNum", "Text")
    self.uidata.effect = SafeGetUIControl(self, "Z_UI_gain_tuowei")
end

function Element:OnInit(data)
    -- Utils.SetRewardIcon(data, self.uidata.imgIcon, nil)
    -- self.uidata.txtNum = "+" .. Utils.FormatCount(data.count)
    Utils.SetRewardIcon4(data, self.uidata.imgIcon, nil, self.uidata.txtNum, "+")
    SafeSetActive(self.uidata.effect.gameObject, true)
    
    -- local target = self.uidata.imgIcon.transform.position
    -- local moveTween = self.uidata.effect.transform:DOMove(target, 0.05)
    -- moveTween:SetEase(Ease.Linear)
    -- moveTween:OnUpdate(function()
    --     target = self.uidata.imgIcon.transform.position
    --     local curPosition = self.uidata.effect.transform.position
    --     if Vector3.Distance(curPosition, target) <= 10 / 100 then
    --         SafeSetActive(self.uidata.effect.gameObject, false)
    --     end
    --     moveTween:ChangeEndValue(target, true)
    -- end)
end

function Element:HideEff()
    -- self.IconEff.gameObject:SetActive(false)
end

function Element:HideIcon()
    if self.gameObject == nil then
        return
    end
    SafeSetActive(self.gameObject, false)
    self.timeout = setTimeout(
        function()
            self.timeout = nil
            self:Destroy(self.gameObject)
        end,
        1000
    )
end

function Element:Destroy()
    if (self.timeout ~= nil) then
        clearTimeout(self.timeout)
    end
    GODestroy(self.gameObject)
end
