---@class UIEffectPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIEffectPanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.interlude = this.GetUIControl("Interlude")
    this.uidata.interludeStart = this.GetUIControl(this.uidata.interlude, "Start", "SkeletonGraphic")
    this.uidata.interludeHoldOn = this.GetUIControl(this.uidata.interlude, "HoldOn", "SkeletonGraphic")
    this.uidata.interludeEnd = this.GetUIControl(this.uidata.interlude, "End", "SkeletonGraphic")
end

function Panel.InitEvent()
    --绑定UGUI事件
end

function Panel.OnShow()
    -- SafeSetActive(this.uidata.interlude.gameObject, false)
    this.PlayInterlude()
end

function Panel.PlayInterlude()
    Audio.PlayAudio(DefaultAudioID.ZhuanChang)
    this.uidata.interludeStart:Initialize(true)
    this.uidata.interludeStart.AnimationState:SetAnimation(0, "animation", true)
    this.uidata.interludeHoldOn:Initialize(true)
    this.uidata.interludeHoldOn.AnimationState:SetAnimation(0, "animation", true)
    this.uidata.interludeEnd:Initialize(true)
    this.uidata.interludeEnd.AnimationState:SetAnimation(0, "animation", true)
    SafeSetActive(this.uidata.interlude.gameObject, true)
    SafeSetActive(this.uidata.interludeStart.gameObject, true)
    SafeSetActive(this.uidata.interludeHoldOn.gameObject, false)
    SafeSetActive(this.uidata.interludeEnd.gameObject, false)

    local holdOnStartTime = 1
    TimeModule.addDelay(holdOnStartTime, function()
        SafeSetActive(this.uidata.interludeStart.gameObject, false)
        SafeSetActive(this.uidata.interludeHoldOn.gameObject, true)
    end)
    local endStartTime = holdOnStartTime + 2
    TimeModule.addDelay(endStartTime, function()
        SafeSetActive(this.uidata.interludeHoldOn.gameObject, false)
        SafeSetActive(this.uidata.interludeEnd.gameObject, true)
    end)
    local endTime = endStartTime + 0.36
    TimeModule.addDelay(endTime, function()
        SafeSetActive(this.uidata.interludeEnd.gameObject, false)
        SafeSetActive(this.uidata.interlude.gameObject, false)
    end)
end

function Panel.HideUI()
    HideUI(UINames.UIEffect)
end
