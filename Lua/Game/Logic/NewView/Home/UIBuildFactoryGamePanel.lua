---@class UIBuildFactoryGamePanel : UIPanelBase
local Panel = UIPanelBaseMake()
local this = Panel
UIBuildFactoryGamePanel = Panel

function Panel.OnAwake()
    this.InitPanel()
    this.InitEvent()
end

function Panel.InitPanel()
    this.uidata = {}
    this.uidata.btnClose = SafeGetUIControl(this, "BottomView/TitleItem/BtnClose")
    this.uidata.bottomView = SafeGetUIControl(this, "BottomView")
    this.uidata.canvasGroup = this.uidata.bottomView:GetComponent("CanvasGroup")
    this.uidata.btnBuild = SafeGetUIControl(this, "BottomView/BtnBuild")
    this.uidata.ClickMask = SafeGetUIControl(this, "ClickMask")
    this.uidata.TtitleTxtBox = SafeGetUIControl(this, "BottomView/TitleItem/TtitleTxtBox")
end

function Panel.InitEvent()
    SafeAddClickEvent(this.behaviour, this.uidata.btnClose, function ()
        this.PlayViewExitAni()
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.ClickMask, function ()
        this.HideUI()
    end)
    
    SafeAddClickEvent(this.behaviour, this.uidata.btnBuild.gameObject, function ()
        -- 建造建筑打点
        SDKAnalytics.TraceEvent(166)
        this.OnClickBuild()
    end)
end

function Panel.OnShow(param)
    this.param = param

    this.PlayViewEnterAni()
    this.UpdateView()
    EventManager.Brocast(EventDefine.HideBottomMainUI)
    ForceRebuildLayoutImmediate(this.uidata.TtitleTxtBox.gameObject)
end

function Panel.PlayViewEnterAni()
    local acTime = 0.25

    this.initBottomLocalPosition = this.initBottomLocalPosition or this.uidata.bottomView.transform.localPosition
    -- Y轴上升出现
    this.uidata.bottomView.transform.localPosition = this.initBottomLocalPosition + Vector3.New(0, -200, 0)
    local tween = this.uidata.bottomView.transform:DOLocalMoveY(this.initBottomLocalPosition.y, acTime):SetEase(Ease.OutBack)
    -- 透明度渐变出现
    this.uidata.canvasGroup.alpha = 0

    tween:OnComplete(function()
        -- 引导完成
        this.startTutorial = true
        -- 检测引导
        local function TutorialUpdate(subStep)
            this.CheckTutorial(TutorialManager.CurrentStep.value, subStep)
        end
        this.TutorialSubStepSubscribe = TutorialManager.CurrentSubStep:subscribe(TutorialUpdate)
    end)

    Util.TweenTo(0, 1, acTime, function (value)
        this.uidata.canvasGroup.alpha = value
    end):SetEase(Ease.OutCubic)
end

function Panel.UpdateView()
    --没有消耗，固定1秒
end

function Panel.PlayViewExitAni()
    local acTime = 0.25

    local seq = DOTween.Sequence()
    -- Y轴下移消失
    this.uidata.bottomView.transform.localPosition = this.initBottomLocalPosition
    seq:Append(this.uidata.bottomView.transform:DOLocalMoveY(this.initBottomLocalPosition.y - 200, acTime):SetEase(Ease.InBack))
    -- 透明度渐变消失
    this.uidata.canvasGroup.alpha = 1

    seq:Join(Util.TweenTo(1, 0, acTime, function (value)
        this.uidata.canvasGroup.alpha = value
    end))

    seq:AppendCallback(function ()
        this.HideUI()
    end)
end

--刷新引导
function Panel.CheckTutorial(step, subStep)
    if step == TutorialStep.FactoryGame and subStep == 5 then
        print("[工厂游戏机] 引导-点击建造")
        this.TutorialClickBuildButton("Tutorial_StartBuild_notice", step)
    end
end

--引导点击建造按钮
function Panel.TutorialClickBuildButton(noticeKey, step)
    TutorialHelper.FingerMove(
        {
            maskType = TutorialMaskType.None,
            noticeKey = noticeKey,
            noticePos = this.TutorialPos,
            fingerPoint = Utils.GetLocalPointInRectangleByUI(SafeGetUIControl(this, "BottomView/BtnBuild")),
            fingerSize = SafeGetUIControl(this, "BottomView/BtnBuild").gameObject.transform.sizeDelta,
            fingerFunc = function()

                if step == TutorialStep.FactoryGame then
                    SDKAnalytics.TraceEvent(168)
                end

                this.OnClickBuild()

                if step == TutorialStep.FactoryGame then
                    SDKAnalytics.TraceEvent(169)
                end
            end,
        }
    )
end

function Panel.OnClickBuild()
    -- 不需要建造过程，直接显示建筑
    FactoryGameData.BuildComplete()
    EventManager.Brocast(EventDefine.ShowBottomMainUI)
    HideUI(UINames.UIBuildFactoryGame)
end

function Panel.HideUI()
    HideUI(UINames.UIBuildFactoryGame)
    EventManager.Brocast(EventDefine.ShowBottomMainUI)
    this.ClearTimer()
end

function Panel.ClearTimer()
    if this.timer then
        TimeModule.removeTimer(this.timer)
        this.timer = nil
   end
end