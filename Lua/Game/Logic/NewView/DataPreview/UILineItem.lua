---@class UILineItem
local Element = class("UILineItem")
UILineItem = Element

function Element:ctor()
end

local Path = {
    [0] = "statistics_blue",
    [1] = "statistics_red",
    [2] = "statistics_bg"
}

function Element:InitPanel(behaviour, obj, param)
    self.gameObject = obj;
    self.transform = obj.transform;
    self.behaviour = behaviour;
    self.param = param or {}

    if self.uidata == nil then
        self.uidata = {}
    end

    self.imgs = {}
    for i = 1, self.transform.childCount do
        local img = self.transform:GetChild(i - 1).transform:GetComponent("Image")
        table.insert(self.imgs, img)
    end

    self.oneLength = 75
    self.type = nil
end

function Element:OnInit(startPos, angle, distance, state, isOne)
    self.angle = angle
    self.distance = distance
    self.transform.pivot = Vector2(0.5, 0)
    self.transform.eulerAngles = Vector3(0, 0, self.angle)
    self.transform.position = startPos
    self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x,
        self.distance + self.transform.sizeDelta.x / 2 - self.oneLength * 2)
    local dir = self.angle > 0 and -1 or 1
    local yOffset = self.angle == -180 and Vector2(0, -self.oneLength) or Vector2(dir * self.oneLength, 0)
    self.transform.anchoredPosition = self.transform.anchoredPosition + yOffset
    SafeSetActive(self.gameObject, isOne)
    if isOne then
        self:OnRefresh(state, 0, true)
    end
end

function Element:OnInitSpinodal(pos, state, type, endIds, indexs)
    self.endIds = endIds
    self.indexs = indexs
    if endIds == nil then
        local width = 31
        local length = 75
        local mid = width / 2 / 75
        local pivotY = (type == 1 or type == 2 or type == 5) and mid or 1 - mid
        self.transform.pivot = Vector2(0.5, pivotY)
    else
        self.transform.pivot = Vector2(0.5, 0)
    end
    self.transform.position = pos
    self:OnRefresh(state, type, true)
end

function Element:GetLineToward()
    if self.angle == -90 then
        return "Left"
    elseif self.angle == -180 then
        return "Up"
    elseif self.angle == 90 then
        return "Right"
    else
    end
end

---@param state number 0:正常 1:不足 2:未知
function Element:OnRefresh(state, type, isFirst)
    self.type = self.type or type
    if self.type == nil then
        return
    end
    local index = self.type + 1
    local bgType = self.type == 0 and 1 or self.type >= 5 and 3 or 2
    local show = true
    if index > 5 then
        local state1 = self.param.chainItem:GetLineShowState(self.endIds[1])
        local state2 = self.param.chainItem:GetLineShowState(self.endIds[2])

        if state1 == state2 then
            local row1 = math.floor(self.indexs[1] / 10)
            local row2 = math.floor(self.indexs[2] / 10)
            index = row1 == row2 and 10 or 11
            bgType = row1 == row2 and 5 or 6
            show = self.indexs[1] < self.indexs[2] and self.endIds[1] == self.param.itemId
        else
            local num1 = state1 < state2 and 0 or 1
            local num2 = state1 >= state2 and 0 or 1
            local num = self.endIds[1] == self.param.itemId and num1 or num2
            index = index + num
            bgType = bgType + num
            if num == 0 then
                self.gameObject.transform:SetAsLastSibling()
            else
                self.gameObject.transform:SetAsFirstSibling()
            end
        end
    end
    local img = self.imgs[index]
    for i, v in ipairs(self.imgs) do
        SafeSetActive(v.gameObject, show and i == index)
    end
    SetImage(self.behaviour, img, Path[state] .. bgType)

    if isFirst and index == 1 then
        local sizeOffset = self.angle == -90 and Vector2(0, 35) or self.angle == 90 and Vector2(0, 25) or Vector2(0, 0)
        local xOffset = self.angle == -90 and Vector2(-3.7, 0) or self.angle == 90 and Vector2(1, 0) or Vector2(0, 0)
        img.transform.sizeDelta = img.transform.sizeDelta + sizeOffset
        img.transform.anchoredPosition = img.transform.anchoredPosition + xOffset
    end
end

function Element:OnDestroy()
    ResourceManager.Destroy(self.gameObject)
end
