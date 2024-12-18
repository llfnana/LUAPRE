---@class UIStoryBookDialogItem
UIStoryBookDialogItem = class("UIStoryBookDialogItem")

function UIStoryBookDialogItem:InitPanel(behaviour, obj)
    self.gameObject = obj
    self.transform = obj.transform
    self.behaviour = behaviour

    self.ContentLeft = SafeGetUIControl(self, "ContentLeft")
    self.HeadIconLeft = SafeGetUIControl(self, "ContentLeft/HeadIconLeft", "Image")
    self.DialogTextLeft = SafeGetUIControl(self, "ContentLeft/DialogTextLeft", "Text")
    self.HeadNameTextLeft = SafeGetUIControl(self, "ContentLeft/NameBg/HeadNameTextLeft", "Text")

    self.ContentRight = SafeGetUIControl(self, "ContentRight")
    self.HeadIconRight = SafeGetUIControl(self, "ContentRight/HeadIconRight", "Image")
    self.DialogTextRight = SafeGetUIControl(self, "ContentRight/DialogTextRight", "Text")
    self.HeadNameTextRight = SafeGetUIControl(self, "ContentRight/NameBgRight/HeadNameTextRight", "Text")
end

function UIStoryBookDialogItem:OnInit(dialog)
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

    --left/right
    if dialog.right ~= nil and tonumber(dialog.right) > 0 then
        self.ContentLeft:SetActive(false)
        self.ContentRight:SetActive(true)
        self.DialogTextRight.text = GetLang(dialog.peopleText)

        --name
        self.HeadNameTextRight.text = name

        Utils.SetIcon(self.HeadIconRight, picSprite, nil, true, true)
    else
        self.ContentLeft:SetActive(true)
        self.ContentRight:SetActive(false)
        self.DialogTextLeft.text = GetLang(dialog.peopleText)

        --name
        self.HeadNameTextLeft.text = name

        Utils.SetIcon(self.HeadIconLeft, picSprite, nil, true, true)
    end

    -- self.pause = dialog.pause
end

function UIStoryBookDialogItem:OnDestroy()
    GameObject.Destroy(self.gameObject)
end
