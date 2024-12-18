--region -------------引入模块-------------

--endregion

--region -------------数据定义-------------
--endregion


---@class UIFactoryGameItem
local Element = class('UIFactoryGameItem')
UIFactoryGameItem = Element
local FactoryGameDefine = require("Game/Logic/NewView/FactoryGame/FactoryGameDefine")
local LampType = FactoryGameDefine.LampType ---@type GashaponLampType
local GridType = FactoryGameDefine.GridType ---@type GashaponGridType

function Element:InitPanel(behavior, go, pos)
    self.gameObject = go
    self.behavior = behavior
    self.gameObject = go.gameObject
    self.transform = go.transform
    self.pos = pos
    self.uidata = {}
    self.uidata.lamp = SafeGetUIControl(self, "lamp")
    self.uidata.lamp_alpha = SafeGetUIControl(self, "lamp","CanvasGroup")
    self.uidata.img_icon = SafeGetUIControl(self, "img_icon", "Image")
    self.uidata.txt_count = SafeGetUIControl(self, "txt_count", "Text")

    self.uidata.iconText = SafeGetUIControl(self, "img_icon/img_icon_1/Text", "Text")
    self.uidata.img_icon_1 = SafeGetUIControl(self, "img_icon/img_icon_1")
    self.uidata.Box = SafeGetUIControl(self, "Box")

    -- self.uidata.kuang_rainbow = SafeGetUIControl(self, "lamp/img_xz")
    -- self.uidata.kuang = SafeGetUIControl(self, "lamp/img_xz_1")
    self.uidata.click = SafeGetUIControl(self, "kuang")
    self.uidata.lamp_alpha.alpha = 0
    self.delayTime = 0.1
end

--item 初始化
function Element:Init(config)
    if config == nil then
        return
    end
    self.config = config
    self.uidata.img_icon_1:SetActive(false)
    local itemConfig = ConfigManager.GetItemConfig(config.id)
    if config.id == "Resources10" or config.id == "Resources30" or config.id == "Resources60" then
        self.uidata.iconText.text = (itemConfig.duration / 60) .. GetLang("UI_Mail_Time_Min")
        self.uidata.img_icon_1:SetActive(true)
    end
    local path =  ResInterface.IsExist(itemConfig.icon .. ".png") and
    itemConfig.icon or "icon_item_timeskip120"

    ResInterface.SyncLoadSprite( path .. ".png", function(_sprite)
        self.uidata.img_icon.sprite = _sprite
    end)
    self.uidata.txt_count.text = self.config.num
    SafeAddClickEvent(self.behavior, self.uidata.img_icon.gameObject, function()
        self:OnClick()
    end)
end

--清除
function Element:Clear()
    self.uidata.lamp_alpha.alpha = 0
    if self.group_kuang then
        self.group_kuang.alpha = 0
    end
end

--抵达停止点
---@param lamp lamp 跑马灯数据
function Element:OnReachStop()
    self:DoClick()
end

---@param lamp lamp 跑马灯数据
function Element:OnMove(lamp, translate_cur_pos)
    self:GetEffect()
    if lamp.type == LampType.Outer then
        if translate_cur_pos == 0 and self.pos == 1 then
            -- print("ggggggggggggggggggggggg")
            -- or (translate_cur_pos == 0 and self.pos == 1)
        end
        if self.pos == translate_cur_pos then
            self.uidata.lamp_alpha.alpha = 1
            self:setDOFade(0, 0.4, function ()
                self.uidata.lamp_alpha.alpha = 0
            end,1)
        end
    elseif lamp.type == LampType.Inner then
        if self.pos == translate_cur_pos then
            self.uidata.lamp_alpha.alpha = 1
            if self.tweener then
                self.tweener:Kill()
            end
            self.tweener = self:setDOFade(0.2, 1)
            if self.group_kuang then
                self.group_kuang.alpha = 1
                self:setDOFade(0.2, 1)
            end
        end
    elseif lamp.type == LampType.Train then
        --限制拖尾的数量 跑火车初始一节节出现
        local trail = math.min(4, lamp.cur_pos - lamp.start_pos)
        if translate_cur_pos - self.pos >= 0 and translate_cur_pos - self.pos <= trail then
            self.uidata.lamp_alpha.alpha = 1 -- 14 12
            self:setDOFade(0.2, 1)
        elseif translate_cur_pos + 20 - self.pos <= trail then
            self.uidata.lamp_alpha.alpha = 1 -- 0  18
            self:setDOFade(0.2, 1)
            self.uidata.lamp.transform.sizeDelta = Vector2(2, 2)
        else
            self.uidata.lamp_alpha.alpha = 0
        end
    elseif lamp.type == LampType.BeginAni then
        if self.pos == translate_cur_pos then
            self.uidata.lamp_alpha.alpha = 1
            self:setDOFade(0, 0.2,function ()
                self.uidata.lamp_alpha.alpha = 0
            end,1)
            -- self.uidata.lamp.transform:DOFade(0, self.isMax and 1 or 2):SetEase(Ease.Linear):OnComplete(function()
            --     self.group_lamp.alpha = 0
            -- end)
        end
    end
end

---获取跑马灯特效
function Element:GetEffect()
    local inner = self.kuangUp ~= nil
end

--被电到了
function Element:OnElectricity()
    self:GetEffect()
    self:DoClick()
end

function Element:DoClick()
    self.uidata.lamp_alpha.alpha = 1
    self:ShowClick(true)
end

function Element:ShowClick(show)
    local effect= self.uidata.Box:GetComponent("SkeletonGraphic")
    SafeSetActive(self.uidata.click.gameObject, show)
    SafeSetActive(self.uidata.Box.gameObject, show)
    if show then
        effect:Initialize(true)
        effect.AnimationState:SetAnimation(0, "animation", false)
    end
end

function Element:ShowElectricityEffect()
    SafeSetActive(self.flicker.gameObject, true)
    self.flicker:Play()
    TimeModule.addDelay(0.5, function()
        SafeSetActive(self.flicker.gameObject, false)
        SafeSetActive(self.flashboom.gameObject, true)
        self.flashboom:Play()
        TimeModule.addDelay(0.5, function()
            SafeSetActive(self.flashboom.gameObject, false)
        end)
    end)

    Audio.PlayAudio(259)

    self:ShowClick()

    return 1
end

function Element:OnClick()
    ShowUI(UINames.UIFactoryGameIItemInfo,{
        id = self.config.id,
        target = self.gameObject,
        index = self.pos,
    })
end

function Element:setDOFade(value, time,cb,start)
    local sequence = DOTween.Sequence()
    local start = start or 0 
    local loop = loop or 1 
    sequence:Append(Util.TweenTo(start, value, time, function(value)
        self.uidata.lamp_alpha.alpha = value
    end)):SetLoops(loop, LoopType.Yoyo):OnComplete(function()
        if cb then
            cb()
        end
    end)
end

return Element
