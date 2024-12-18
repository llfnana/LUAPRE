---@class UIGuidePanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIGuidePanel = Panel;

require "Game/Logic/NewView/Guide/UIStoryBookPanel"
require "Game/Logic/NewView/Guide/UIStoryBookDialogPanel"

function Panel.OnAwake()
    this.cachedata = {}
    this.InitPanel()
    this.InitEvent()

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.TutorialNotice = SafeGetUIControl(this, "ImageNotice")
    this.TutorialNoticeText = SafeGetUIControl(this, "ImageNotice/TextDes", "Text")
    this.TutorialNarrator = SafeGetUIControl(this, "ImageNarrator")
    this.TutorialNarratorText = SafeGetUIControl(this, "ImageNarrator/TextDes", "Text")
    this.TutorialMaskNone = SafeGetUIControl(this, "Image")

    this.StoryBookDialog = SafeGetUIControl(this, "StoryBookDialog")

    this.StoryBook = SafeGetUIControl(this, "StoryBook")

    this.TutorialEvent = SafeGetUIControl(this, "TutorialEvent")

    SafeSetActive(this.StoryBookDialog, false)
end

function Panel.InitEvent()
    --绑定UGUI事件

    -- 界面显示
    local function panelRxFunc(count)
        if count == 0 then
            this.gameObject:SetActive(false)
        elseif count == 1 then
            this.gameObject:SetActive(true)
        end
    end
    this.panelRx = NumberRx:New(0)
    this.panelRxSubscribe = this.panelRx:subscribe(panelRxFunc)

    -- 遮罩类型
    local function maskTypeRxFunc(count)
        if count == 0 then
            this.TutorialMaskNone:SetActive(false)
        elseif count == 1 then
            this.TutorialMaskNone:SetActive(true)
        end
    end
    this.maskTypeRx = NumberRx:New(0)
    this.maskTypeRxSubscribe = this.maskTypeRx:subscribe(maskTypeRxFunc)

    -- 提示类型
    local function noticeRxFunc(count)
        if count == 0 then
            -- this.TutorialNotice.anchoredPosition = Vector2(0, 300)
            this.TutorialNotice.gameObject:SetActive(false)
        elseif count == 1 then
            this.TutorialNotice.gameObject:SetActive(true)
        end
    end
    this.noticeRx = NumberRx:New(0)
    this.noticeRxSubscribe = this.noticeRx:subscribe(noticeRxFunc)

    -- 旁白类型
    local function narratorRxFunc(count)
        if count == 0 then
            -- this.TutorialNarrator.localScale = Vector3.zero
            this.TutorialNarrator.gameObject:SetActive(false)
        elseif count == 1 then
            this.TutorialNarrator.gameObject:SetActive(true)
        end
    end
    this.narratorRx = NumberRx:New(0)
    this.narratorRxSubscribe = this.narratorRx:subscribe(narratorRxFunc)
end

function Panel.OnShow()
    SafeSetActive(this.StoryBook, false)
    SafeSetActive(this.StoryBookDialog, false)
end

--显示旁白
function Panel.ShowNarrator(params)
    local callBack = params.callBack
    
    --执行
    local CoroutineFunc = function()
        EventManager.Brocast(EventDefine.HideBottomMainUI)
        this.OpenPanel(params)
        this.TutorialNarrator.transform:DOScale(Vector3.one, 0.5):SetEase(Ease.InSine)
        WaitForSeconds(0.5 + params.narratorTime)
        this.ClosePanel(params)
        EventManager.Brocast(EventDefine.ShowBottomMainUI)
        WaitForSeconds(0.1)
        if callBack then
            callBack()
        end
        this.showNarratorCoroutine = nil
    end
    this.showNarratorCoroutine = StartCoroutine(CoroutineFunc)
end

--显示对话框
function Panel.ShowDialog(params)
    if this.dialogPanel ~= nil then
        this.dialogPanel:Destroy()
        this.dialogPanel = nil
    end
    if params == nil then
        return
    end
    this.OpenPanel(params)

    EventManager.Brocast(EventDefine.HideBottomMainUI)
    EventManager.Brocast(EventDefine.OnOpenStoryBookDialog)

    local StoryBookDialog = GOInstantiate(this.StoryBookDialog)
    this.dialogPanel = UIStoryBookDialogPanel.new()
    this.dialogPanel:InitPanel(this.behaviour, StoryBookDialog, params)
    StoryBookDialog.transform:SetParent(this.transform, false)
    SafeSetActive(StoryBookDialog.gameObject, true)
    this.dialogPanel:OnInit(params)
    
    this.dialogPanel.closePanel = function()
        EventManager.Brocast(EventDefine.ShowBottomMainUI)
        this.ClosePanel(params)

        if StoryBookDialog then
            GameObject.Destroy(StoryBookDialog)
        end

        this.dialogPanel = nil
        if params.callBack ~= nil then
            params.callBack()
        end
    end
end

--显示说话
function Panel.ShowTalks(params)
    if this.talkPanel ~= nil then
        this.talkPanel:OnDestroy()
        this.talkPanel = nil
    end
    EventManager.Brocast(EventDefine.HideBottomMainUI)
    this.OpenPanel(params)

    this.talkPanel = UIStoryBookPanel.new()
    this.talkPanel:InitPanel(this.behaviour, this.StoryBook, params)
    SafeSetActive(this.StoryBook, true)
    this.talkPanel:OnInit(params)

    this.talkPanel.closePanel = function()
        this.ClosePanel(params)
        if this.talkPanel ~= nil then
            this.talkPanel:OnDestroy()
            this.talkPanel = nil
        end
        if params.callBack ~= nil then
            params.callBack()
        end
    end
end

--打开界面
function Panel.OpenPanel(params)
    if params then
        this.panelRx.value = this.panelRx.value + 1
        if params.maskType then
            this.maskTypeRx.value = this.maskTypeRx.value + 1
        end
        local noticeKey = params.noticeKey
        if noticeKey then
            this.noticeRx.value = this.noticeRx.value + 1
            this.TutorialNoticeText.text = GetLang(noticeKey)
        end
        local narratorKey = params.narratorKey
        if narratorKey then
            this.narratorRx.value = this.narratorRx.value + 1
            this.TutorialNarratorText.text = GetLang(narratorKey)
        end
    else
        this.noticeRx.value = 0
        this.maskTypeRx.value = 0
        this.panelRx.value = 0
    end
end

--关闭界面
function Panel.ClosePanel(params)
    if params then
        if params.maskType then
            this.maskTypeRx.value = this.maskTypeRx.value - 1
        end
        if params.noticeKey then
            this.noticeRx.value = this.noticeRx.value - 1
        end
        if params.narratorKey then
            this.narratorRx.value = this.narratorRx.value - 1
        end
        if this.panelRx.value > 0 then
            this.panelRx.value = this.panelRx.value - 1
        end
    else
        this.noticeRx.value = 0
        this.maskTypeRx.value = 0
        this.panelRx.value = 0
    end
end

function Panel.OnHide()
    HideUI(UINames.UIGuide)
end

--教程移动手指
function Panel.FingerMove(params)
    local callBack = params.callBack
    local fingerPoint = params.fingerPoint
    local fingerSize = params.fingerSize or Vector2(150, 150)
    local fingerFunc = params.fingerFunc
    local fingerCount = params.fingerCount or 1
    local fingerMove = params.fingerMove or false
    --执行移动
    this.OpenPanel(params)
    this.TutorialEvent.gameObject:SetActive(true)

    --设置引导事件点击回调
    local function TutorialFingerClick()
        local fingerTrigger = false
        if fingerCount > 0 then
            fingerTrigger = true
        end
        fingerCount = fingerCount - 1
        if fingerCount == 0 then
            this.TutorialEvent.gameObject:SetActive(false)
            this.TutorialEvent.transform.sizeDelta = Vector2.zero
            this.ClosePanel(params)
        end
        if fingerTrigger then
            if fingerFunc then
                fingerFunc()
            end
        end
        if fingerCount == 0 then
            if callBack then
                callBack()
            end
        end
    end

    --设置引导手指移动完毕
    local function TutorialFingerMoveCompleted()
        this.TutorialEvent.transform.sizeDelta = fingerSize
        --设置引导事件点击回调
        -- this.TutorialEvent:SetCallBack(TutorialFingerClick)

        SafeAddClickEvent(this.behaviour, this.TutorialEvent, function()
            TutorialFingerClick()
        end)
    end

    -- print("fingerPoint.x ==" .. fingerPoint.x .. "fingerPoint.y ==" .. fingerPoint.y, debug.traceback())

    --设置引导手指移动到指定位置
    if fingerMove then
        local tweenTime = Vector2.Distance(this.TutorialEvent.transform.anchoredPosition, fingerPoint)
        tweenTime = tweenTime / 1500
        if tweenTime < 0.3 then
            tweenTime = 0.3
        end
        this.TutorialEvent.transform:DOLocalMove(fingerPoint, tweenTime):OnComplete(TutorialFingerMoveCompleted)
    else
        this.TutorialEvent.transform.localPosition = fingerPoint
        TutorialFingerMoveCompleted()
    end

    if params.stopTime ~= nil and params.stopTime > 0 then
        local function CoroutineFunc()
            WaitForSeconds(params.stopTime)
            this.ClosePanel(params)
            if callBack then
                callBack()
            end
            this.cameraLockUpCoroutine = nil
        end
        this.cameraLockUpCoroutine = StartCoroutine(CoroutineFunc)
    end
end

--教程移动相机
function Panel.CameraMove(params)
    local zoneId = params.zoneId
    local movePosition = params.movePosition
    local moveSpeed = params.moveSpeed or 40
    local callBack = params.callBack
    local rightNow = params.rightNow
    local time = params.time
    --移动完成
    local function CompletedFunc()
        this.ClosePanel(params)
        if callBack then
            callBack()
        end
    end
    --执行
    this.OpenPanel(params)

    if movePosition then
        CityModule.getMainCtrl().camera:moveToPosition(movePosition.x, movePosition.y, CompletedFunc)
        -- CityModule.getMainCtrl().camera.transform:DOMove(movePosition, 1):OnComplete(CompletedFunc)
        return
    end

    if zoneId and CityModule.getMainCtrl().buildDict[zoneId] then
        local build = CityModule.getMainCtrl().buildDict[zoneId].gameObject
        local pos = build.transform.position
        if pos then
            if rightNow == true then
                CityModule.getMainCtrl().camera:setPosition(pos.x, pos.y)
                CompletedFunc()
            else
                CityModule.getMainCtrl().camera.transform:DOMove(
                    Vector3.New(pos.x, pos.y, CityModule.getMainCtrl().camera.transform.position.z), time or 1):OnComplete(
                    CompletedFunc)
            end
        end
    else
        CompletedFunc()
    end
end

--相机锁定
function Panel.CameraLockUp(params)
    local stopTime = params.stopTime
    local stopFunc = params.stopFunc
    local callBack = params.callBack
    
    --执行
    local function CoroutineFunc()
        this.OpenPanel(params)
        if stopTime then
            WaitForSeconds(stopTime)
        elseif stopFunc then
            while not stopFunc() do
                Yield(nil)
            end
        end

        Yield(nil)

        this.ClosePanel(params)
        if callBack then
            callBack()
        end
        this.cameraLockUpCoroutine = nil
    end
    this.cameraLockUpCoroutine = StartCoroutine(CoroutineFunc)
end

--相机等待
function Panel.CameraWait(params)
    local stopTime = params.stopTime
    local stopFunc = params.stopFunc
    local callBack = params.callBack
    local checkDelta = 0.5
    if params.checkDelta ~= nil then
        checkDelta = params.checkDelta
    end

    --执行
    local function CoroutineFunc()
        if stopTime then
            WaitForSeconds(stopTime)
        elseif stopFunc then
            while not stopFunc() do
                WaitForSeconds(checkDelta)
            end
        end
        if callBack then
            callBack()
        end
        this.cameraWaitCoroutine = nil
    end
    this.cameraWaitCoroutine = StartCoroutine(CoroutineFunc)
end

--相机变焦
function Panel.CameraZoom(params)
    local callBack = params.callBack
    local orthographicSize = params.orthographicSize
    local orthographicTime = params.orthographicTime or 0.26
    --执行
    local function CompletedFunc()
        this.ClosePanel(params)
        if callBack then
            callBack()
        end
    end
    this.OpenPanel(params)

    local seq = DOTween.Sequence()
    seq:Append(CityModule.getMainCtrl().camera.transform:DOMoveZ(orthographicSize, orthographicTime):SetEase(Ease.OutCubic)
        :OnComplete(CompletedFunc))
end

--相机聚焦
function Panel.CameraFocus(params)
    local target = params.target
    local stopTime = params.stopTime
    local stopFunc = params.stopFunc
    local callBack = params.callBack
    --执行
    this.OpenPanel(params)
    local function CoroutineFunc()

        CityModule.getMainCtrl().camera:setCameraFocus(target)

        if stopTime then
            WaitForSeconds(stopTime)
        elseif stopFunc then
            while not stopFunc() do
                WaitForSeconds(0.2)
            end
        end

        CityModule.getMainCtrl().camera:cancelCameraFocus()

        this.ClosePanel(params)
        if callBack then
            callBack()
        end
        this.cameraFocusCoroutine = nil
    end
    this.cameraFocusCoroutine = StartCoroutine(CoroutineFunc)
end
