---@class UIArrowItem
local Element = class("UIArrowItem")
UIArrowItem = Element

function Element:ctor()
end

function Element:InitPanel(behaviour, obj, param)
    self.gameObject = obj;
    self.transform = obj.transform;
    self.behaviour = behaviour;
    param = param or {}

    if self.uidata == nil then self.uidata = {} end

    self.StatisticalChainLineArrowRectTransform = self.transform:GetComponent("RectTransform")
    self.icon = self.transform:GetComponent("Image")
end

function Element:OnInit(point, angle, state)
    self.StatisticalChainLineArrowRectTransform.eulerAngles = Vector3(0, 0, angle)
    self.StatisticalChainLineArrowRectTransform.pivot = Vector2(0, 0.5)
    self.StatisticalChainLineArrowRectTransform.position = point
    self:OnRefresh(state)
end

function Element:OnMove(arrowInfos, index)
    if nil == self.tweener then
        self.arrowInfos = arrowInfos
        self.totalArrow = arrowInfos:Count()
        self:OnMoveNext(index)
    end
end

function Element:OnMoveNext(index)
    index = index + 1
    if index > self.totalArrow then
        self.StatisticalChainLineArrowRectTransform.localPosition = self.arrowInfos[1].localPosition
        self.StatisticalChainLineArrowRectTransform.eulerAngles = Vector3(0, 0, self.arrowInfos[1].angle)
        index = 2
    end
    self.tweener = self.transform:DOLocalMove(self.arrowInfos[index].localPosition, 1)
    self.tweener:SetEase(Ease.Linear)
    self.tweener:OnComplete(
        function()
            self.StatisticalChainLineArrowRectTransform.localPosition = self.arrowInfos[index].localPosition
            self.StatisticalChainLineArrowRectTransform.eulerAngles = Vector3(0, 0, self.arrowInfos[index].angle)
            self:OnMoveNext(index)
        end
    )
end

function Element:OnStopMove()
    if nil ~= self.tweener then
        self.tweener:Kill()
        self.tweener = nil
    end
end

function Element:OnRefresh(state)
    -- self.Image:SelectColor(state)
    if state ~= 2 then
        SetImage(self.behaviour, self.icon, "statistics_img_up_0" .. (state + 1))
    end
    self.gameObject:SetActive(state ~= 2)
end

function Element:OnDestroy()
    if nil ~= self.tweener then
        self.tweener:Kill()
        self.tweener = nil
    end
    ResourceManager.Destroy(self.gameObject)
end
