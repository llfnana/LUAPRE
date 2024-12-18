---@class UIStrikePanel : UIPanelBase
local Panel = UIPanelBaseMake()
local this = Panel
UIStrikePanel = Panel
local CountdownConst = 10
require "Game/Logic/NewView/Strike/UIStrikeItem"
require "Game/Logic/NewView/Guide/UIStoryBookDialogItem"

function Panel.OnAwake()
    this.dialogItems = List:New()

    this.cachedata = {}
    this.InitPanel()
    this.InitEvent()
    this.InitData()
    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata                         = {}
    this.uidata.ButtonBack              = SafeGetUIControl(this, "BottomUI/ButtonBack")

    this.uidata.ButtonGo                = SafeGetUIControl(this, "BottomUI/Bubble/ButtonGo")
    this.uidata.Bubble                  = SafeGetUIControl(this, "BottomUI/Bubble")
    this.uidata.BubbleDesText           = SafeGetUIControl(this, "BottomUI/Bubble/TextDes", "Text")
    this.uidata.ImageCard               = SafeGetUIControl(this, "BottomUI/Bubble/ImageCard", "Image")

    this.uidata.ProtestTitleText        = SafeGetUIControl(this, "TopUI/TextTitle", "Text")
    this.uidata.ProtestTimeText         = SafeGetUIControl(this, "TopUI/TextTime", "Text")
    this.uidata.ProtestAngerText        = SafeGetUIControl(this, "TopUI/ProtestPeople/TextAnger", "Text")
    this.uidata.ProtestPeople           = SafeGetUIControl(this, "TopUI/ProtestPeople")

    this.uidata.AppeaseTimeText         = SafeGetUIControl(this, "BottomUI/TextTime", "Text")
    this.uidata.AppeaseTimesText        = SafeGetUIControl(this, "BottomUI/TextTimes", "Text")

    this.uidata.AppeaseItem             = SafeGetUIControl(this, "BottomUI/AppeaseItem")
    this.uidata.ImageItem               = SafeGetUIControl(this, "ImageItem")

    this.uidata.WarningBg               = SafeGetUIControl(this, "WarningBg")
    this.uidata.Content                 = SafeGetUIControl(this, "ScrollView/Viewport/Content")

    this.uidata.StoryBookDialogItem     = SafeGetUIControl(this, "StoryBookDialogItem")
    this.uidata.ProtestPeopleReduce     = SafeGetUIControl(this, "TopUI/ProtestPeopleReduce", "CanvasGroup")
    this.uidata.ProtestPeopleReduceText = SafeGetUIControl(this, "TopUI/ProtestPeopleReduce/ProtestPeopleReduceText",
        "Text")
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.ButtonBack, this.HideUI)

    SafeAddClickEvent(this.behaviour, this.uidata.ButtonGo, function()
        this.HideUI()
        if this.cardLevel == 0 then
            ShowUI(UINames.UIShop)
        else
            ShowUI(UINames.UIHero)
        end
    end)
end

function Panel.InitData()
    this.cityId = DataManager.GetCityId()
    this.cardId = ProtestManager.GetCardId(this.cityId)
    this.cardConfig = ConfigManager.GetCardConfig(this.cardId)
    this.protestGroupId = ProtestManager.GetProtestGroupId(this.cityId)
    this.protestGroupCfg = ConfigManager.GetProtestGroupConfigById(this.protestGroupId)
    this.protestStatus = ProtestManager.GetProtestStatus(this.cityId)
    this.protestTime = ProtestManager.GetProtestLeftTime(this.cityId)
    this.currentPeople = ProtestManager.GetCurrentPeople(this.cityId)
    this.totalPeople = ProtestManager.GetTotalPeople(this.cityId)
    this.appeaseCount = ProtestManager.GetAppeaseCount(this.cityId)
    this.appeaseTime = ProtestManager.GetAppeaseRefreshTime(this.cityId)
    this.appeaseCountRefresh = ConfigManager.GetMiscConfig("protest_appease_count_reflash")
    this.protestAnimation = false
    this.protestWillEnd = false
    this.protestStatusChange = false
end

--更新暴动状态
function Panel.UpdateProtestStatus()
    if this.protestStatus == ProtestStatus.Talk then
        this.uidata.ProtestTitleText.text = GetLang("protest_talk")
        SafeSetActive(this.uidata.WarningBg, false)

        ProtestManager.ShowProtestMaskPoint(this.cityId, true)

        -- Map.Instance:ShowProtestCamera(this.protestStatus)
    elseif this.protestStatus == ProtestStatus.Run then
        this.uidata.ProtestTitleText.text = GetLang("protest_riot")
        SafeSetActive(this.uidata.WarningBg, true)

        ProtestManager.ShowProtestMaskPoint(this.cityId, false)

        --预警呼吸动画
        -- local function WarningAlphaFunc(a)
        --     local color = this.uidata.WarningBg.color
        --     this.uidata.WarningBg.color = Color(color.r, color.g, color.b, a)
        -- end
        -- this.WarningAlphaTw = DOTween.To(WarningAlphaFunc, 0.2, 1, 1)
        -- this.WarningAlphaTw:SetLoops(-1, CS.DG.Tweening.LoopType.Yoyo)
        -- Map.Instance:ShowProtestCamera(this.protestStatus)
    end
end

--获取安抚事件进度
function Panel.GetAppeaseTimeProgress()
    return this.appeaseTime / this.appeaseCountRefresh, this.appeaseTime
end

--更新安抚事件
function Panel.UpdateAppeaseItems()
    this.UpdateProtestStatus()

    for i = 1, this.uidata.AppeaseItem.transform.childCount do
        local go = this.uidata.AppeaseItem.transform:GetChild(i - 1)
        SafeSetActive(go.gameObject, false)
    end

    for index = 1, 3, 1 do
        if not this.appeaseItems:ContainsKey(index) then
            local go = GOInstantiate(this.uidata.ImageItem)
            go.transform:SetParent(this.uidata.AppeaseItem.transform, false)
            SafeSetActive(go.gameObject, true)
            local item = UIStrikeItem.new()
            item:InitPanel(this.behaviour, go, index, this.totalPeople, this.cardLevel, function(isUnlock, isMeet, info)
                this.OnClickAppeaseItem(item, isUnlock, isMeet, index, info)
            end)

            this.appeaseItems:Add(index, item)
        else
            SafeSetActive(this.appeaseItems[index].gameObject, true)
            this.appeaseItems[index]:playAni()
        end
        this.appeaseItems[index]:OnRefresh()
    end
end

--更新安抚次数
function Panel.UpdateAppeaseCount()
    this.appeaseItems:ForEach(
        function(item)
            item:SetAppeaseCount(this.appeaseCount, this:GetAppeaseTimeProgress())
        end
    )
    local appeaseMaxCount = ProtestManager.GetAppeaseMaxCount(this.cityId)
    local str = ""
    if this.appeaseCount > 0 then
        str = string.format("<color=#FFFFFF>%s</color>/%s", this.appeaseCount, appeaseMaxCount)
    else
        str = string.format("<color=#e74b4b>%s</color>/%s", this.appeaseCount, appeaseMaxCount)
    end
    this.uidata.AppeaseTimesText.text = GetLang("ui_protest_appease_count") .. str

    SafeSetActive(SafeGetUIControl(this, "BottomUI/TextTime"), this.appeaseCount < appeaseMaxCount)
end

--更新安抚时间
function Panel.UpdateAppeaseTime()
    this.appeaseTime = ProtestManager.GetAppeaseRefreshTime(this.cityId)
    this.uidata.AppeaseTimeText.text = GetLangFormat("ui_protest_appease_count_restore", this.appeaseTime)
end

function Panel.OnShow()
    --罢工背景音乐
    Audio.PlayAudio(DefaultAudioID.NotSatisfied)
    UIUtil.openPanelAction(this.gameObject)

    this.InitData()

    EventManager.Brocast(EventDefine.HideMainUI)

    SafeSetActive(this.uidata.Bubble, false)

    Utils.SetCardHeroIcon(this.uidata.ImageCard, this.cardId)

    this.appeaseItems = Dictionary:New()
    --更新安抚卡牌等级
    local function UpdateCardLevelFunc(lv)
        if this.cardLevel == lv then
            return
        end
        this.cardLevel = lv
        this.appeaseItems:ForEach(
            function(item)
                item:SetCardLevel(this.cardLevel)
            end
        )
    end
    this.cardLevelSubscribe = ProtestManager.GetCardLeveRx(this.cityId):subscribe(UpdateCardLevelFunc)

    this.uidata.ProtestAngerText.text = this.currentPeople
    this.uidata.ProtestTimeText.text = Utils.GetTimeFormat4(this.protestTime)
    this.UpdateProtestStatus()
    this.UpdateAppeaseItems()
    this.UpdateAppeaseCount()

    this.UpdateAppeaseTime()

    this.ProtestStateChanageFunc = function(cityId, status)
        if this.cityId ~= cityId then
            this.InitData()
            return
        end
        if this.protestStatus == status then
            return
        end
        this.protestStatus = status
        if this.protestAnimation then
            this.protestStatusChange = true
        elseif status == ProtestStatus.Run or status == ProtestStatus.CoolDown then
            this.HideUI()
        end
    end

    this.ProtestTimeChanageFunc = function(cityId, time)
        if this.cityId ~= cityId then
            this.InitData()
            return
        end
        if this.protestTime == time then
            return
        end
        if this.protestStatusChange then
            this.protestTime = 0
        else
            this.protestTime = time
        end
        
        this.uidata.ProtestTimeText.text = Utils.GetTimeFormat4(this.protestTime)
    end

    this.ProtestAppeaseCountChanageFunc = function(cityId, count)
        if this.cityId ~= cityId then
            this.InitData()
            return
        end
        if this.appeaseCount == count then
            return
        end
        this.appeaseCount = count
        this.UpdateAppeaseCount()
    end

    this.ProtestAppeaseTimeChanageFunc = function(cityId, time)
        if this.cityId ~= cityId then
            this.InitData()
            return
        end
        if this.appeaseTime == time then
            return
        end
        this.appeaseTime = time
        this.UpdateAppeaseTime()
    end

    this.TimeRealPerSecondFunc = function(cityId)
        if this.cityId ~= cityId then
            this.InitData()
            return
        end
        if this.protestStatus == ProtestStatus.Talk then
            return
        end
        if this.protestStatus == ProtestStatus.Run then
            if this.protestTime <= CountdownConst and not this.protestAnimation and not this.protestWillEnd then
                this.protestWillEnd = true
                -- this.ProtestAppease.gameObject:SetActive(false)
                -- this.ShowProtestResult(false)
            end
        end
    end
    this.AddListener(EventType.PROTEST_STATE_CHANGE, this.ProtestStateChanageFunc)
    this.AddListener(EventType.PROTEST_TIME_CHANGE, this.ProtestTimeChanageFunc)
    this.AddListener(EventType.PROTEST_APPEASE_COUNT_CHANGE, this.ProtestAppeaseCountChanageFunc)
    this.AddListener(EventType.PROTEST_APPEASE_TIME_CHANGE, this.ProtestAppeaseTimeChanageFunc)
    this.AddListener(EventType.TIME_REAL_PER_SECOND, this.TimeRealPerSecondFunc)
end

function Panel.HideUI()
    if this.showDialogCoroutine then
        StopCoroutine(this.showDialogCoroutine)
        this.showDialogCoroutine = nil
    end

    if this.cardLevelSubscribe then
        this.cardLevelSubscribe:unsubscribe()
        this.cardLevelSubscribe = nil
    end

    this.appeaseItems:ForEach(
        function(item)
            item:OnDestroy()
        end
    )

    this.appeaseItems:Clear()

    ProtestManager.ShowProtestMaskPoint(this.cityId, false)
    this.PlayAudio()
    UIUtil.hidePanelAction(this.gameObject, function()
        EventManager.Brocast(EventDefine.ShowMainUI)
        HideUI(UINames.UIStrike)
    end)
end

--播放主界面音乐
function Panel:PlayAudio()
    -- local time = TimeManager.GetClockDayAndNight(this.cityId)
    -- if time >= 19 and time < 24 or time < 7 then
    --     Audio.PlayAudio(DefaultAudioID.YeWanScene)
    -- else
    --     Audio.PlayAudio(DefaultAudioID.BaiTianScene)
    -- end
    Audio.PlayAudio(DefaultAudioID.BaiTianScene)
end

--动画时间
local DIALOG_SHOW_TIME = 1.8
local DIALOG_ANIM_TIME = 0.5
local DIALOG_WAIT_TIME = 0.5
--点击安抚事件
function Panel.OnClickAppeaseItem(appeaseItem, isUnlock, isMeet, appeaseIndex, appeaseInfo)
    if isUnlock then
        SafeSetActive(this.uidata.Bubble, false)
        --资源充足
        if isMeet then
            if this.appeaseCount > 0 then
                --记录暴动状态
                this.protestAnimation = true

                local appeaseConfig = ConfigManager.GetProtestAppeaseConfigById(appeaseInfo.appeaseId)
                local peopleReplys = ConfigManager.GetMiscConfig("reply_desc_people" .. appeaseIndex)
                local appeasePeople = appeaseItem.appeasePeopleCount
                --使用暴动安抚事件
                ProtestManager.UseProtestAppeaseEvent(this.cityId, appeaseInfo, appeaseIndex)
                local currNewPeople = ProtestManager.GetCurrentPeople(this.cityId)

                -- 自动关闭面板
                local function AutoClosePanel()
                    this.protestStatusChange = false
                    this.protestAnimation = false
                    this.HideUI()
                end

                --状态变更处理
                local function StatusChangeFunc()
                    if this.protestStatus == ProtestStatus.Run then
                        AutoClosePanel()
                    elseif this.protestStatus == ProtestStatus.CoolDown then
                        AutoClosePanel()
                    end
                end

                --结果处理
                local function CompleteAppeaseEvent()
                    this.currentPeople = currNewPeople
                    this.uidata.ProtestPeopleReduce.transform.anchoredPosition = Vector3.zero
                    this.uidata.ProtestPeopleReduce.alpha = 0
                    this.uidata.ProtestPeopleReduceText.text = ""
                    if this.protestStatusChange then
                        StatusChangeFunc()
                    else
                        this.UpdateAppeaseItems()
                        this.protestAnimation = false
                    end
                end

                --更新暴动小人
                local function UpdateProtestPeople(count)
                    this.uidata.ProtestPeopleText.text = math.ceil(count)
                end

                --展示更新暴动小人
                local function ShowUpdateProtestPeople()
                    local time = 0.15 * appeasePeople
                    this.uidata.ProtestPeopleReduce.alpha = 1
                    this.uidata.ProtestPeopleReduceText.text = "-" .. appeasePeople
                    this.uidata.ProtestAngerText.text = math.ceil(currNewPeople)
                    TimeModule.addDelay(0.5, function()
                        CompleteAppeaseEvent()
                    end)
                end

                --显示暴动头像缩放
                local function ShowProtestPeolpeScale()
                    if this.uidata.ProtestPeople then
                        this.replyTween = this.uidata.ProtestPeople.transform:DOScale(Vector3(1.3, 1.3, 1.3), 0.1)
                        this.replyTween:SetLoops(2, LoopType.Yoyo)
                        this.replyTween:OnComplete(ShowUpdateProtestPeople)
                        appeaseItem:ShowAppeaseScale()
                    end
                end

                local dialogues = List:New()
                dialogues:Add(
                    {
                        peopleId = 1,
                        peopleText = appeaseConfig.card_reply,
                        right = "0",
                        -- name = this.cardConfig.name
                    }
                )
                dialogues:Add(
                    {
                        peopleId = 4,
                        peopleText = peopleReplys[math.random(#peopleReplys)],
                        right = "1",
                    }
                )

                local function ShowAppeaseDialog()
                    this.uidata.Content.transform:DetachChildren()

                    this.uidata.Content.transform.localPosition = Vector3(this.uidata.Content.transform.localPosition.x, 0, 0)

                    WaitForSeconds(0.2)
                    --展示对话
                    for i = 1, dialogues:Count(), 1 do
                        local dialogItem = GOInstantiate(this.uidata.StoryBookDialogItem,
                            this.uidata.Content.transform)
                        SafeSetActive(dialogItem.gameObject, true)
                        local item = UIStoryBookDialogItem.new()
                        item:InitPanel(this.behaviour, dialogItem)
                        this.dialogItems:Add(item)

                        this.uidata.Content.transform:DOLocalMove(
                        Vector2(0, 300 + this.uidata.Content.transform.localPosition.y), DIALOG_ANIM_TIME)

                        item:OnInit(dialogues[i])
                        WaitForSeconds(DIALOG_SHOW_TIME)
                    end
                    WaitForSeconds(DIALOG_WAIT_TIME)

                    --清理对话
                    this.ClearDialogItems()
                    ShowProtestPeolpeScale()
                end

                --播放安抚对话
                local function PlayAppeaseDialog()
                    this.showDialogCoroutine = StartCoroutine(ShowAppeaseDialog)
                end

                if appeaseConfig.appease_type ~= "None" then
                    appeaseItem:ShowAppeaseCost(PlayAppeaseDialog)
                else
                    PlayAppeaseDialog()
                end
            end
        else
            UIUtil.showText(GetLang("toast_res_lack"))
            -- GameToast.Instance:Show(GetLang("toast_res_lack"), ToastIconType.Warning)
        end
    else
        --显示安抚事件气泡弹窗
        SafeSetActive(this.uidata.Bubble, true)
        SafeSetActive(SafeGetUIControl(this, "BottomUI/Bubble/Image2"), appeaseIndex == 2)
        SafeSetActive(SafeGetUIControl(this, "BottomUI/Bubble/Image3"), appeaseIndex == 3)

        if this.cardLevel == 0 then
            this.uidata.BubbleDesText.text = GetLang("toast_card_lack")
        else
            local cardRequireLevel = ProtestManager.GetAppeaseRequireCardLevel(this.cityId, appeaseIndex)
            this.uidata.BubbleDesText.text = GetLangFormat("toast_card_level_lack", cardRequireLevel)
        end

        if this.index == appeaseIndex then
            SafeSetActive(this.uidata.Bubble, false)
            this.index = 0
            return
        end

        this.index = appeaseIndex
    end
end

--清理对话
function Panel.ClearDialogItems()
    for i = 1, this.dialogItems:Count(), 1 do
        this.dialogItems[i]:OnDestroy()
    end
    this.dialogItems:Clear()
end
