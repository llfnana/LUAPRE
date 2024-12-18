TutorialFirstEnterCity = Clone(TutorialBase)
TutorialFirstEnterCity.__cname = "TutorialFirstEnterCity"

function TutorialFirstEnterCity:OnRun()
    if self.subStep == 1 then

        SDKAnalytics.TraceEvent(101)

        TutorialHelper.ShowNarrator(
            {
                maskType = TutorialMaskType.None,
                narratorKey = "Tutorial_FirstEnterCity_storytell_1",
                narratorTime = 9,
            }
        )
        local grid = GridManager.GetGridByMarkerType(self.cityId, GridMarker.TutorialBorn)
        TutorialHelper.CameraMove(
            {
                movePosition = grid:GetBonePosition() + Vector3(0, 0,
                    CityModule.getMainCtrl().camera.transform.position.z),
                maskType = TutorialMaskType.None,
                rightNow = true,
            }
        )
        TutorialHelper.CameraLockUp(
            {
                maskType = TutorialMaskType.None,
                stopFunc = function()
                    self.character = CharacterManager.GetCharacterBySerialNumber(self.cityId, 1)
                    return nil ~= self.character
                end,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 2 then
        TutorialHelper.CameraFocus(
            {
                maskType = TutorialMaskType.None,
                target = self.character.transform,
                stopFunc = function()
                    if self.character.currGrid.zoneType == ZoneType.Dorm then
                        return true
                    end
                    return false
                end,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 3 then

        SDKAnalytics.TraceEvent(102)

        local list = List:New()
        list:Add({ peopleId = 4, peopleText = "Tutorial_FirstEnterCity_dialogue_1", right = "1" })
        list:Add({ peopleId = 1, peopleText = "Tutorial_FirstEnterCity_dialogue_2", right = "0" })
        TutorialHelper.ShowDialog(
            {
                maskType = TutorialMaskType.None,
                dialogues = list,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 4 then
        self:Complete()
    end
end

function TutorialFirstEnterCity:OnComplete()
    TutorialManager.OpenTutorial(TutorialStep.BuildGenerator, 1, true)
end

return TutorialFirstEnterCity
