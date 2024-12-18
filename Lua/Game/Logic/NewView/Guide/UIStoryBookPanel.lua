UIStoryBookPanel = class("UIStoryBookPanel")

--对话面板移动弹出时间
local PopupMoveTime = 0.3
--对话打字机效果时间间隔
local TypewriterInterval = 0.02

function UIStoryBookPanel:InitPanel(behaviour, obj)
    self.gameObject = obj
    self.transform = obj.transform
    self.behaviour = behaviour

    self.SkipBtn = SafeGetUIControl(self, "SkipBtn")
    self.ContinueBtn = SafeGetUIControl(self, "ContinueBtn")
    self.TutorialButton = SafeGetUIControl(self, "TutorialButton")

    self.StoryBookTalkLeft = SafeGetUIControl(self, "StoryBookTalkLeft")
    self.StoryBookTalkRight = SafeGetUIControl(self, "StoryBookTalkRight")
    self.rightText = SafeGetUIControl(self, "StoryBookTalkRight/StoryBookTalkText", "Text")

    self.StoryBookTalkRightIcon = SafeGetUIControl(self, "StoryBookTalkRight/StoryBookTalkRightIcon", "Image")
    self.StoryBookTalkLeftIcon = SafeGetUIControl(self, "StoryBookTalkLeft/StoryBookTalkLeftIcon", "Image")
    self.leftText = SafeGetUIControl(self, "StoryBookTalkLeft/StoryBookTalkText", "Text")

    self.StoryBookTalkLeftName = SafeGetUIControl(self, "StoryBookTalkLeft/LeftNameBg/StoryBookTalkLeftName", "Text")
    self.StoryBookTalkRightName = SafeGetUIControl(self, "StoryBookTalkRight/RightNameBg/StoryBookTalkRightName", "Text")

    self.StoryBookTalkImage = SafeGetUIControl(self, "StoryBookTalkImage")

    SafeGetUIControl(self, "SkipBtn/TextPass", "Text").text = GetLang("Tutorial_Tap_skip")
    SafeGetUIControl(self, "ContinueBtn/TextLV", "Text").text = GetLang("Tutorial_Tap_Next")

    -- 跳过
    SafeAddClickEvent(self.behaviour, self.SkipBtn, function()
        self:SkipDialog()
    end)

    -- 继续
    SafeAddClickEvent(self.behaviour, self.ContinueBtn, function()
        self:ContinueDialog()
    end)

    -- 继续
    SafeAddClickEvent(self.behaviour, self.TutorialButton, function()
        self:ContinueDialog()
    end)
end

function UIStoryBookPanel:OnInit(params)
    self.skipText = params.skipText
    self.dialogues = params.dialogues
    self.storyId = params.storyId
    self.currentIndex = 1

    self.StoryBookTalkLeft:SetActive(false)
    self.StoryBookTalkRight:SetActive(false)


    --运行
    local function ShowComplete()
        self:ShowStoryBookDialogView(self.currentIndex)
    end
    self:ShowStoryBookDialog(self.currentIndex, ShowComplete)
end

--根据对话获取控件
function UIStoryBookPanel:GetStoryBookItems(dialog)
    local talkObj = nil
    local talkIcon = nil
    local talkName = nil
    local talkDes = nil
    if dialog.right ~= nil and tonumber(dialog.right) > 0 then
        talkObj = self.StoryBookTalkRight
        talkIcon = self.StoryBookTalkRightIcon
        talkName = self.StoryBookTalkRightName
        talkDes = self.rightText
    else
        talkObj = self.StoryBookTalkLeft
        talkIcon = self.StoryBookTalkLeftIcon
        talkName = self.StoryBookTalkLeftName
        talkDes = self.leftText
    end
    return talkObj, talkIcon, talkName, talkDes
end

--显示对话框
function UIStoryBookPanel:ShowStoryBookDialog(index, callBack)
    self.ContinueBtn.gameObject:SetActive(false)
    local dialog = self.dialogues[index]
    if not dialog then return end
    local talkObj, talkIcon, talkName, talkDes = self:GetStoryBookItems(dialog)

    self.StoryBookTalkText = talkDes
    --兼容引导配置
    local picSprite = nil
    local name = ""

    if dialog.peopleId ~= nil then
        picSprite = "npc_model_10" .. dialog.peopleId
        name = Utils.GetCharacterName(self.cityId, dialog.peopleId)
    else
        picSprite = "npc_model_101"
        name = GetLang("people_name_1")
    end

    if dialog.headSprite then
        picSprite = dialog.headSprite
    end

    if dialog.name then
        name = GetLang(dialog.name)
    end

    Utils.SetIcon(talkIcon, picSprite, nil, true, true)

    talkName.text = name

    --移动完成
    local function ShowStoryBookHead()
        if callBack then
            callBack()
        end
    end

    --开始位移
    local function ShowStoryBookMove()
        self.storyBookTween = talkObj.transform:DOLocalMoveX(0, PopupMoveTime)
        self.storyBookTween:OnComplete(ShowStoryBookHead)
    end

    --控件位置兼容
    local function ResetStoryBook()
        local x = dialog.right == "1" and Screen.width or -Screen.width
        talkObj.transform.localPosition = Vector3(x, talkObj.transform.localPosition.y, talkObj.transform.localPosition.z)
        -- self.storyBookTimeId = setTimeout(ShowStoryBookMove, 0)
        talkObj:SetActive(true)
        ShowStoryBookMove()
    end

    ResetStoryBook()
end

--隐藏对话框
function UIStoryBookPanel:HideStoryBookDialog(index, callBack)
    self.ContinueBtn.gameObject:SetActive(false)
    local dialog = self.dialogues[index]
    if not dialog then return end

    -- 避免取空报错
    if index > #self.dialogues then
        return
    end

    local talkObj, _, _, talkDes = self:GetStoryBookItems(dialog)

    self.StoryBookTalkText = talkDes

    --移动完成
    local function MoveCompleteFunc()
        if callBack then
            callBack()
        end
    end

    --移动面板
    local function HideStoryBookMove()
        local moveX = dialog.right == "1" and Screen.width or -Screen.width
        self.storyBookTween = talkObj.transform:DOLocalMoveX(moveX, PopupMoveTime)
        self.storyBookTween:OnComplete(MoveCompleteFunc)
    end

    --隐藏头像
    local function HideStoryBookHead()
        talkObj:SetActive(false)
        self.storyBookTimeId = setTimeout(HideStoryBookMove, 200)
    end

    HideStoryBookHead()
end

--显示对话显示
function UIStoryBookPanel:ShowStoryBookDialogView(index)
    self.ContinueBtn.gameObject:SetActive(true)
    local dialog = self.dialogues[index]
    if not dialog then return end
    local talkText = GetLang(dialog.peopleText)
    self.dialogTalkText = talkText
    self.StoryBookTalkText.text = talkText
    self:DialogComplete()
end

function UIStoryBookPanel:DialogComplete()
    if self.dialogTween ~= nil then
        self.StoryBookTalkImage:SetActive(true)
        self.StoryBookTalkText.text = self.dialogTalkText
        self.dialogTween:Kill()
        self.dialogTween = nil
    end
end

function UIStoryBookPanel:SkipDialog()
    self:OnClose()
end

function UIStoryBookPanel:ContinueDialog()
    if self.dialogTween ~= nil then
        self:DialogComplete()
        return
    end
    self.pervIndex = self.currentIndex
    self.currentIndex = self.currentIndex + 1
    if self.currentIndex > #self.dialogues then
        local function HideComplete()
            self:OnClose()
        end
        self:HideStoryBookDialog(self.pervIndex, HideComplete)
    else
        local pervDialog = self.dialogues[self.pervIndex]
        local currDialog = self.dialogues[self.currentIndex]
        --小人相同
        if pervDialog.peopleId == currDialog.peopleId then
            if pervDialog.right == currDialog.right then
                self:ShowStoryBookDialogView(self.currentIndex)
            else
                print("[error]" .. "Error,同一角色对话方向不一致。")
            end
        else
            if pervDialog.right == currDialog.right then
                print("[error]" .. "Error,切换角色,对话的弹出方向相同。")
            else
                local function ShowComplete()
                    self:ShowStoryBookDialogView(self.currentIndex)
                end
                local function HideComplete()
                    self:ShowStoryBookDialog(self.currentIndex, ShowComplete)
                end
                self:HideStoryBookDialog(self.pervIndex, HideComplete)
            end
        end
    end
end

function UIStoryBookPanel:OnClose()
    self:OnDestroy()
    if self.closePanel ~= nil then
        self.closePanel()
    end
end

function UIStoryBookPanel:OnDestroy()
    if self.dialogTween then
        self.dialogTween:Kill()
        self.dialogTween = nil
    end
    if self.storyBookTween then
        self.storyBookTween:Kill()
        self.storyBookTween = nil
    end
    -- ResourceManager.Destroy(self.gameObject)
end
