TutorialSchedulesEat = Clone(TutorialBase)
TutorialSchedulesEat.__cname = "TutorialSchedulesEat"

function TutorialSchedulesEat:OnInit()
    self.dorm2 = MapManager.GetMapItemData(self.cityId, "C1_Dorm_2")
    self.kitchen = MapManager.GetMapItemData(self.cityId, "C1_Kitchen_1")
    self.character = CharacterManager.GetCharacterBySerialNumber(self.cityId, 4)
    local foodCount = FoodSystemManager.GetFoodCount(self.cityId)
    local needCount = CharacterManager.GetCharacterCount(self.cityId) - foodCount
    FoodSystemManager.AddFoodCount(self.cityId, needCount)
    -- self.currOrthographicSize = Camera.main.orthographicSize
    self.minOrthographicSize = -38
    self.maxOrthographicSize = -84
end

function TutorialSchedulesEat:OnRun()
    if self.subStep == 1 then
        TutorialManager.StopTime.value = true
        -- self.kitchen:OpenRoof()
        TutorialHelper.CameraMove(
            {
                -- movePosition = self.kitchen:GetZonePoint(),
                zoneId = self.kitchen.zoneId,
                maskType = TutorialMaskType.None,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 2 then

        SDKAnalytics.TraceEvent(127)

        TutorialManager.StopTime.value = false
        TutorialHelper.ShowNarrator(
            {
                maskType = TutorialMaskType.None,
                narratorKey = "Tutorial_Eating_storytell_1",
                narratorTime = 8,
                -- callBack = TutorialManager.NextSubStep
            }
        )
        TutorialHelper.CameraZoom(
            {
                orthographicSize = self.maxOrthographicSize,
                orthographicTime = 2, --4
                maskType = TutorialMaskType.None,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 3 then

        SDKAnalytics.TraceEvent(128)

        TutorialHelper.CameraWait({
            maskType = TutorialMaskType.None,
            stopTime = 6,
            callBack = function()
                local list = List:New()
                list:Add({ peopleId = 4, peopleText = "Tutorial_Eating_dialogue_1", right = "0" })
                list:Add({ peopleId = 1, peopleText = "Tutorial_Eating_dialogue_2", right = "1" })
                list:Add({ peopleId = 4, peopleText = "Tutorial_Eating_dialogue_3", right = "0" })
                list:Add({ peopleId = 1, peopleText = "Tutorial_Eating_dialogue_4", right = "1" })
                TutorialHelper.ShowDialog(
                    {
                        maskType = TutorialMaskType.None,
                        dialogues = list,
                        callBack = function() end
                    }
                )
            end
        })

        TutorialHelper.CameraZoom(
            {
                orthographicSize = self.minOrthographicSize,
                orthographicTime = 4,  --18
                maskType = TutorialMaskType.None,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 4 then
        TutorialHelper.CameraLockUp(
            {
                maskType = TutorialMaskType.None,
                stopFunc = function()
                    return not self.character:JudgeSchedulesActive(SchedulesType.Eat)
                end,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 5 then


        DOTween.Sequence():Append(CityModule.getMainCtrl().camera.transform:DOMoveZ(-55, 1):SetEase(Ease.OutCubic))

        SDKAnalytics.TraceEvent(129)

        SDKAnalytics.TraceEvent(130)

        local list = List:New()
        list:Add({ peopleId = 1, peopleText = "Tutorial_BuildCattleFarm_dialogue_1", right = "0" })
        list:Add({ peopleId = 4, peopleText = "Tutorial_BuildCattleFarm_dialogue_2", right = "1" })
        list:Add({ peopleId = 1, peopleText = "Tutorial_BuildCattleFarm_dialogue_3", right = "0" })
        TutorialHelper.ShowDialog(
            {
                maskType = TutorialMaskType.None,
                dialogues = list,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 6 then
        TutorialManager.StopTime.value = false
        self:Complete()
    end
end

function TutorialSchedulesEat:OnComplete()
    TutorialManager.OpenTutorial(TutorialStep.BuildHunterCabin, 1, true)
end

return TutorialSchedulesEat
