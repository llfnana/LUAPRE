TutorialProtestTalks = Clone(TutorialBase)
TutorialProtestTalks.__cname = "TutorialProtestTalks"

function TutorialProtestTalks:OnRun()
    if ProtestManager.GetProtestStatus(self.cityId) == ProtestStatus.Talk then
        if self.subStep == 1 then
            local groupId = ProtestManager.GetProtestGroupId(self.cityId) or 1
            local protestGroupCfg = ConfigManager.GetProtestGroupConfigById(groupId)
            local cardId = ProtestManager.GetCardId(self.cityId)
            local talkList = List:New()
            local peopleData = {
                peopleId = 4,
                peopleText = protestGroupCfg.desc,
                right = "0"
            }
            talkList:Add(peopleData)
            if cardId ~= 0 then
                local cardConfig = ConfigManager.GetCardConfig(cardId)
                local cardData = {
                    peopleId = 1,
                    right = "1",
                    peopleText = "protest_complain_how_reply" 
                }
                talkList:Add(cardData)
            end
            local params = {
                maskType = TutorialMaskType.None,
                dialogues = talkList,
                callBack = TutorialManager.NextSubStep
            }
            TutorialHelper.ShowTalks(params)
        elseif self.subStep == 2 then
            TutorialManager.CloseTutorial()
            if ProtestManager.IsProtestStatus(self.cityId) then
                ShowUI(UINames.UIStrike, true)
            end
        end
    else
        TutorialManager.CloseTutorial()
    end
    EventManager.Brocast(EventDefine.ShowMainUI)
end

return TutorialProtestTalks
