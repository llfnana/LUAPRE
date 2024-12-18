TutorialSurvivorSick = Clone(TutorialBase)
TutorialSurvivorSick.__cname = "TutorialSurvivorSick"

function TutorialSurvivorSick:OnInit()
    if SchedulesManager.IsSchdulesActive(self.cityId, SchedulesType.Sleep) then
        self.isSleep = true
    else
        self.isSleep = false
    end
end

function TutorialSurvivorSick:OnRun()
    if self.subStep == 1 then
        local list = List:New()
        if not self.isSleep then
            list:Add({
                peopleId = 1,
                peopleText = "Tutorial_SurvivorSick_dialogue_1",
                right = "0"
            })
            list:Add({
                peopleId = 1,
                peopleText = "Tutorial_SurvivorSick_dialogue_2",
                right = "0"
            })
            list:Add({
                peopleId = 4,
                peopleText = "Tutorial_SurvivorSick_dialogue_3",
                right = "1"
            })
            list:Add({
                peopleId = 1,
                peopleText = "Tutorial_SurvivorSick_dialogue_4",
                right = "0"
            })
        else
            list:Add({
                peopleId = 4,
                peopleText = "Tutorial_SurvivorSick_dialogue_sleep_1",
                right = "0"
            })
            list:Add({
                peopleId = 4,
                peopleText = "Tutorial_SurvivorSick_dialogue_sleep_2",
                right = "0"
            })
            list:Add({
                peopleId = 4,
                peopleText = "Tutorial_SurvivorSick_dialogue_sleep_3",
                right = "0"
            })
            list:Add({
                peopleId = 4,
                peopleText = "Tutorial_SurvivorSick_dialogue_sleep_4",
                right = "0"
            })
        end
        TutorialHelper.ShowDialog({
            maskType = TutorialMaskType.None,
            dialogues = list,
            callBack = TutorialManager.NextSubStep
        })
    elseif self.subStep == 2 then
        TutorialHelper.FingerMove({
            maskType = TutorialMaskType.None,
            fingerPoint = Utils.GetLocalPointInRectangleByUI(UIMainPanel.UIAttributeBtn),
            fingerFunc = function()
                ShowUI(UINames.UIAttribute)
            end,
            callBack = TutorialManager.NextSubStep
        })
    elseif self.subStep == 3 then
        TutorialManager.NextSubStep(0.3)
    elseif self.subStep == 4 then
        TutorialHelper.CameraLockUp({
            maskType = TutorialMaskType.None,
            stopFunc = function()
                return UIAttributePanel.uidata and isNil(UIAttributePanel.uidata.ButtonHelp) == false
            end,
            callBack = function()
                TutorialHelper.FingerMove({
                    maskType = TutorialMaskType.None,
                    noticeKey = "Tutorial_SurvivorSick_notice_1",
                    fingerPoint = Utils.GetLocalPointInRectangleByUI(UIAttributePanel.uidata.ButtonHelp),
                    fingerFunc = function()
                        ShowUI(UINames.UIPersonAttributeInfo)
                    end,
                    callBack = TutorialManager.NextSubStep
                })
            end
        })
    elseif self.subStep == 5 then
        self:Complete()
    end
end

function TutorialSurvivorSick:OnComplete()
    TutorialManager.CloseTutorial()
end

return TutorialSurvivorSick
