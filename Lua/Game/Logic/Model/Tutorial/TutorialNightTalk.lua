TutorialNightTalk = Clone(TutorialBase)
TutorialNightTalk.__cname = "TutorialNightTalk"

function TutorialNightTalk:OnInit()
    self.mapItemData = MapManager.GetMapItemData(self.cityId, "C1_Dorm_1")
end

function TutorialNightTalk:OnRun()
    local cityHour = TimeManager.GetCityClockHour(self.cityId)
    if self.cityId == 1 and 0 <= cityHour and cityHour < 4 then
    elseif self.subStep == 3 then
    else
        TutorialManager.CloseTutorial()
        return
    end
    if self.subStep == 1 then
        TutorialHelper.CameraMove(
            {
                maskType = TutorialMaskType.None,
                -- movePosition = self.mapItemData:GetZonePoint(),
                zoneId = self.mapItemData.zoneId,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 2 then

        SDKAnalytics.TraceEvent(151)
        
        local list = List:New()
        list:Add({ peopleId = 4, peopleText = "Tutorial_NightTalk_dialogue_1", right = "0" })
        list:Add({ peopleId = 1, peopleText = "Tutorial_NightTalk_dialogue_2", right = "1" })
        list:Add({ peopleId = 4, peopleText = "Tutorial_NightTalk_dialogue_3", right = "0" })
        list:Add({ peopleId = 1, peopleText = "Tutorial_NightTalk_dialogue_4", right = "1" })
        list:Add({ peopleId = 4, peopleText = "Tutorial_NightTalk_dialogue_5", right = "0" })
        list:Add({ peopleId = 1, peopleText = "Tutorial_NightTalk_dialogue_6", right = "1" })
        list:Add({ peopleId = 4, peopleText = "Tutorial_NightTalk_dialogue_7", right = "0" })
        list:Add({ peopleId = 1, peopleText = "Tutorial_NightTalk_dialogue_8", right = "1" })

        TutorialHelper.ShowDialog(
            {
                maskType = TutorialMaskType.None,
                dialogues = list,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 3 then
        self:Complete()
    end
end

function TutorialNightTalk:OnComplete()
    TutorialManager.CloseTutorial()
    TutorialManager.StopTime.value = false
end

--检测停止时间
function TutorialNightTalk:CheckStopTime(cityDay, cityClock)
    local cityHour = TimeManager.GetCityClockHour(self.cityId)
    if self.cityId == 1 and 0 <= cityHour and cityHour < 4 then
        TutorialManager.StopTime.value = false
    else
        TutorialManager.StopTime.value = true
    end
end

return TutorialNightTalk
