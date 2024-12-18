TutorialProtestRiots = Clone(TutorialBase)
TutorialProtestRiots.__cname = "TutorialProtestRiots"

function TutorialProtestRiots:OnRun()
    if ProtestManager.GetProtestStatus(self.cityId) == ProtestStatus.Run then
        if self.subStep == 1 then
            local talkList = List:New()
            local peopleData = {
                --name = "people_name_Kameron",
                peopleId = 4,
                anim = "angry",
                peopleText = "protest_complain_riot_start",
                right = "1",
                think = "0"
            }
            talkList:Add(peopleData)
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
end

return TutorialProtestRiots
