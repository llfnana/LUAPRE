UIStoryBookDialogPanel = class("UIStoryBookDialogPanel")
UIStoryBookDialogPanel.DIALOG_ANIM_TIME = 0.5
UIStoryBookDialogPanel.DIALOG_SHOW_TIME = 2.3

require "Game/Logic/NewView/Guide/UIStoryBookDialogItem"

function UIStoryBookDialogPanel:InitPanel(behaviour, obj)
    self.gameObject = obj
    self.transform = obj.transform
    self.behaviour = behaviour

    self.SkipBtn = SafeGetUIControl(self, "SkipBtn")
    self.TutorialButton = SafeGetUIControl(self, "TutorialButton")
    self.Content = SafeGetUIControl(self, "ScrollView/Viewport/Content", "Image")
    self.StoryBookDialogItem = SafeGetUIControl(self, "StoryBookDialogItem")
    self.StoryBookMaskNone = SafeGetUIControl(self, "StoryBookMaskNone")
    self.TextSkipTip = SafeGetUIControl(self, "TextSkipTip")

    SafeGetUIControl(self, "TextSkipTip", "Text").text = GetLang("Tutorial_Tap_Next")
    SafeGetUIControl(self, "SkipBtn/TextPass", "Text").text = GetLang("Tutorial_Tap_skip")
end

function UIStoryBookDialogPanel:OnInit(params)
    -- 跳过
    SafeAddClickEvent(self.behaviour, self.SkipBtn, function()
        self:SkipDialog()
    end)

    -- 立即显示下一句
    SafeAddClickEvent(self.behaviour, self.StoryBookMaskNone, function()
        self:ImmediateShowNextDialog()
    end)

    self:ShowDialog(params)
end

--显示对话框
function UIStoryBookDialogPanel:ShowDialog(params)
    self.dialogues = params.dialogues
    self.skipText = params.skipText
    self.storyId = params.storyId

    self.StoryBookMaskNone.gameObject:SetActive(true)
    self.TextSkipTip.gameObject:SetActive(false)
    self.TutorialButton.gameObject:SetActive(false)
    SafeGetUIControl(self, "ScrollView", "ScrollRect").enabled = false
    self.Content.raycastTarget = false
    self.dialogItems = List:New()

    local function CoroutineFunc()
        WaitForSeconds(0.5)
        --展示对话
        for i = 1, self.dialogues:Count(), 1 do
            self.dialogWaitTime = 0
            local item = self:CreateDialogItem(true)
            item:OnInit(self.dialogues[i])
            while self.dialogWaitTime < self.DIALOG_SHOW_TIME do
                WaitForSeconds(0.01)
                self.dialogWaitTime = self.dialogWaitTime + TimerFunction.deltaTime
            end
            self.dialogWaitTime = 0
        end

        self.SkipBtn:SetActive(false)
        TouchUtil.onOnceTap(function()
            self:Destroy()
        end)

        SafeGetUIControl(self, "ScrollView", "ScrollRect").enabled = true
        self.StoryBookMaskNone.gameObject:SetActive(false)
        self.TextSkipTip.gameObject:SetActive(true)
        self.TutorialButton.gameObject:SetActive(true)
        self.Content.raycastTarget = true
        self.showDialogCoroutine = nil
        self.isShowAllDialogs = true
    end
    self.showDialogCoroutine = StartCoroutine(CoroutineFunc)
end

--创建对话对象
function UIStoryBookDialogPanel:CreateDialogItem(isAction)
    local dialogItem = GOInstantiate(self.StoryBookDialogItem, self.Content.transform)
    SafeSetActive(dialogItem.gameObject, true)
    local item = UIStoryBookDialogItem.new()
    item:InitPanel(self.behaviour, dialogItem)
    self.dialogItems:Add(item)
    self.dialogItems:ForEach(
        function(dialogItem)
            if isAction then
                self.Content.transform:DOLocalMove(Vector2(0, 300 + self.Content.transform.localPosition.y), self.DIALOG_ANIM_TIME)
            end
        end
    )
    return item
end

--跳过对话
function UIStoryBookDialogPanel:SkipDialog()
    if self.isShowAllDialogs then
        self:Destroy()
    else
        self:ShowAllDialogs()
    end
end

--直接显示下一句对话
function UIStoryBookDialogPanel:ImmediateShowNextDialog()
    if self.dialogWaitTime == nil then
        return
    end
    if self.dialogWaitTime < self.DIALOG_ANIM_TIME then
        return
    end
    self.dialogWaitTime = self.DIALOG_SHOW_TIME
end

--显示所有对话
function UIStoryBookDialogPanel:ShowAllDialogs()

    if self.showDialogCoroutine then
        StopCoroutine(self.showDialogCoroutine)
        self.showDialogCoroutine = nil
    end
    self.isShowAllDialogs = true

    for i = 1, self.dialogItems:Count(), 1 do
        self.dialogItems[i]:OnDestroy()
    end
    self.dialogItems:Clear()

    self.SkipBtn:SetActive(false)
    for i = 1, self.dialogues:Count(), 1 do
        local item = self:CreateDialogItem()
        item:OnInit(self.dialogues[i])
        self.Content.transform:DOLocalMoveY(300 * i, 0.2)
    end

    TouchUtil.onOnceTap(function()
        self:Destroy()
    end)

    SafeGetUIControl(self, "ScrollView", "ScrollRect").enabled = true
    self.StoryBookMaskNone.gameObject:SetActive(false)
    self.TextSkipTip.gameObject:SetActive(true)
    self.TutorialButton.gameObject:SetActive(true)
    self.Content.raycastTarget = true
end

function UIStoryBookDialogPanel:ClearDialogItems()
    for i = 1, self.dialogItems:Count(), 1 do
        self.dialogItems[i].gameObject:SetActive(false)
    end
end

function UIStoryBookDialogPanel:Destroy()
    for i = 1, self.dialogItems:Count(), 1 do
        self.dialogItems[i]:OnDestroy()
    end

    self.dialogItems:Clear()

    if self.closePanel ~= nil then
        self.closePanel()
        self.closePanel = nil
    end
end
