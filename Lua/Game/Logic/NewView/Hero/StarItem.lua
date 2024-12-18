---@class StarItem
local Element = class("StarItem")
StarItem = Element

Element.MAX_STAR = 3
Element.MAX_NUMBER = 5

function Element:ctor()

end

function Element:InitPanel(behaviour, obj)
    self.gameObject = obj
    self.transform = obj.transform
    self.behaviour = behaviour
end

function Element:SetStarLevel(starLevel)
    self.StarLevel = starLevel
    self:RefreshView()

    for i = 1, 5 do
        SafeSetActive(SafeGetUIControl(self, "Star" .. i .. "/SkeletonGraphic"), false)
    end

end

function Element:RefreshView()
    local starType = math.floor((self.StarLevel - 1) / self.MAX_STAR)
    local starNum = self.StarLevel - starType * self.MAX_STAR

    for i = 1, 5 do
        for j = 1, self.MAX_STAR do
            SafeGetUIControl(self, "Star" .. i .. "/ImageIcon" .. j):SetActive(false)
        end
    end

    for i = 0, starType do
        if i < starType then
            for j = 1, self.MAX_STAR do
                SafeGetUIControl(self, "Star" .. (i + 1) .. "/ImageIcon" .. j):SetActive(true)
            end
        else
            for j = 1, starNum do
                SafeGetUIControl(self, "Star" .. (i + 1) .. "/ImageIcon" .. j):SetActive(true)
            end
        end
    end
end

function Element:ShowNextUpgradeLight()
    local starlevel = self.StarLevel + 1
    if starlevel > self.MAX_STAR * self.MAX_NUMBER then
        return
    end
    local starType = math.floor((starlevel - 1) / self.MAX_STAR)
    local starNum = starlevel - starType * self.MAX_STAR

    local target = SafeGetUIControl(self, "Star" .. starType + 1 .. "/SkeletonGraphic")

    SafeSetActive(target, true)

    local actSkel = target:GetComponent("SkeletonGraphic")
    if actSkel then
        actSkel.AnimationState:SetAnimation(0, tostring(starNum), true)
    end
end
