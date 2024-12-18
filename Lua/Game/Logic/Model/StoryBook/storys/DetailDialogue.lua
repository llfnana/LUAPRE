---@class DetailDialogue : IStoryBase
DetailDialogue = Clone(IStoryBase)
DetailDialogue.__cname = "DetailDialogue"
DetailDialogue.type = EnumStoryType.DetailDialogue

function DetailDialogue:PrepareInputs()
    MainUI.Instance:SetMainUIState(false)
end

function DetailDialogue:OnExecuteSelf()
    local config = self.dataBase.p1
    local arrDialogue = self.dataBase.p2
    local list = List:New()
    for i = 1, #arrDialogue do
        local dialogue = arrDialogue[i]
        if dialogue ~= nil then
            local data = {
                dialogBg = tonumber(dialogue.dialogBg),
                peopleText = dialogue.peopleText,
                peopleId = dialogue.peopleId,
                anim = dialogue.anim,
                right = dialogue.right,
                think = dialogue.think,
                name = dialogue.name,
            }
            if dialogue.pause ~= nil and dialogue.pause == "true" then
                data.pause = true
            end
            if dialogue.heroIcon ~= nil and dialogue.heroIcon ~= "" then
                data.headSprite = Utils.GetPic(dialogue.heroIcon)
            end
            if dialogue.thinkIcon ~= nil and dialogue.thinkIcon ~= "" then
                data.thinkIcon = Utils.GetCommonIcon(dialogue.thinkIcon)
            end
            list:Add(data)
        end
    end

    local params = {
        storyId = self.dataBase.id,
        maskType = TutorialMaskType.None,
        dialogType = TutorialPanel.DialogType.StoryBook,
        skipText = config.skipText,
        dialogues = list,
        callBack = function()
            MainUI.Instance:SetMainUIState(true)
            TutorialHelper.ClosePanel()
            self:ExecuteNextNode()
        end
    }
    
    TutorialHelper.ShowTalks(params)
end

return DetailDialogue
