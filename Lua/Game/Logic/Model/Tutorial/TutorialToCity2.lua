TutorialToCity2 = Clone(TutorialBase)
TutorialToCity2.__cname = "TutorialToCity2"

function TutorialToCity2:OnInit()

end

function TutorialToCity2:OnRun()
    if self.subStep == 1 then
        TutorialManager.NextSubStep(1)
    elseif self.subStep == 2 then
        local list = List:New()
        list:Add({
            peopleId = 1,
            peopleText = "Tutorial_ToCity2_dialogue_1",
            right = "0"
        })
        list:Add({
            peopleId = 4,
            peopleText = "Tutorial_ToCity2_dialogue_2",
            right = "1"
        })
        list:Add({
            peopleId = 1,
            peopleText = "Tutorial_ToCity2_dialogue_3",
            right = "0"
        })
        list:Add({
            peopleId = 4,
            peopleText = "Tutorial_ToCity2_dialogue_4",
            right = "1"
        })

        TutorialHelper.ShowDialog({
            maskType = TutorialMaskType.None,
            dialogues = list,
            callBack = function()
                TutorialManager.NextSubStep(0.3)
            end
        })
    elseif self.subStep == 3 then
        TutorialHelper.FingerMove({
            maskType = TutorialMaskType.None,
            fingerPoint = Utils.GetLocalPointInRectangleByUI(UIMainPanel.uidata.task),
            fingerFunc = function()
                ShowUI(UINames.UITask)
            end,
            callBack = function()
                TutorialManager.NextSubStep(0.5)
            end
        })
    elseif self.subStep == 4 then
        TutorialHelper.CameraLockUp({
            maskType = TutorialMaskType.None,
            stopFunc = function()
                return UITaskPanel.uidata and isNil(UITaskPanel.uidata.ButtonPass) == false
            end,
            callBack = function()
                TutorialHelper.FingerMove({
                    maskType = TutorialMaskType.None,
                    fingerToward = FingerToward.Left,
                    fingerPoint = Utils.GetLocalPointInRectangleByUI(UITaskPanel.uidata.ButtonPass),
                    fingerFunc = function()
                        SDKAnalytics.TraceEvent(155)
                        CityPassManager.PlayCityPass()
                        HideUI(UINames.UITask)
                    end,
                    callBack = function()
                        TutorialManager.NextSubStep(0.3)
                    end
                })
            end
        })
    elseif self.subStep == 5 then
        TutorialHelper.CameraLockUp({
            maskType = TutorialMaskType.None,
            stopFunc = function()
                return isNil(UICityPassSummaryPanel.bottonGet) == false 
            end,
            callBack = function()
                TutorialHelper.FingerMove({
                    maskType = TutorialMaskType.None,
                    fingerPoint = Utils.GetLocalPointInRectangleByUI(UICityPassSummaryPanel.bottonGet),
                    fingerFunc = function()
                        UICityPassSummaryPanel.HideUI()
                    end,
                    callBack = TutorialManager.NextSubStep
                })
            end
        })

    elseif self.subStep == 6 then
        self:Complete()
    end
end

function TutorialToCity2:OnComplete()
    TutorialManager.CloseTutorial()
    TutorialManager.StopTime.value = false
end

return TutorialToCity2
