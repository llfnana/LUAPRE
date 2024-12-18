TutorialBuildKitchen = Clone(TutorialBase)
TutorialBuildKitchen.__cname = "TutorialBuildKitchen"

function TutorialBuildKitchen:OnInit()
    self.dorm2 = MapManager.GetMapItemData(self.cityId, "C1_Dorm_2")
    self.kitchen = MapManager.GetMapItemData(self.cityId, "C1_Kitchen_1")
    self.character = CharacterManager.GetCharacterBySerialNumber(self.cityId, 3)
    self.cityDay = TimeManager.GetCityDay(self.cityId)
end

function TutorialBuildKitchen:OnRun()
    
    TutorialHelper.CameraLockUp({
        maskType = TutorialMaskType.None,
        stopTime = 0.5
    })

    -- 已派遣人。直接步骤15
    if self.kitchen:GetNormalPeople() > 0 and self.subStep < 12 then
        self.subStep = 16
    end

    if self.kitchen:IsUnlock() and self.subStep < 7 then
        self.subStep = 7
    end

    if self.subStep == 1 then
        TutorialHelper.CameraMove(
            {
                maskType = TutorialMaskType.None,
                -- movePosition = self.dorm2:GetZonePoint(),
                zoneId = self.dorm2.zoneId,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 2 then

        SDKAnalytics.TraceEvent(118)

        local list = List:New()
        list:Add({ peopleId = 4, peopleText = "Tutorial_BuildKitchen_dialogue_1", right = "0" })
        list:Add({ peopleId = 1, peopleText = "Tutorial_BuildKitchen_dialogue_2", right = "1" })
        TutorialHelper.ShowDialog(
            {
                maskType = TutorialMaskType.None,
                dialogues = list,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 3 then
        TutorialHelper.CameraMove(
            {
                maskType = TutorialMaskType.None,
                -- movePosition = self.kitchen:GetZonePoint(),
                zoneId = self.kitchen.zoneId,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 4 then
        TutorialHelper.FingerMove(
            {
                maskType = TutorialMaskType.None,
                noticeKey = "Tutorial_BuildKitchen_notice_1",
                fingerPoint = Utils.GetLocalPointInRectangleByPosition(Vector3.New(0, 0, 0)),
                fingerFunc = function()

                    SDKAnalytics.TraceEvent(119)

                    self.kitchen.view:MouseUp()
                end,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 5 then
        TutorialHelper.CameraLockUp({
            maskType = TutorialMaskType.None,
            stopFunc = function() 
                return UIBuildUnlockPanel.startTutorial == true
            end
        })
    elseif self.subStep == 6 then
        TutorialHelper.CameraLockUp(
            {
                maskType = TutorialMaskType.None,
                stopFunc = function()
                    return self.kitchen:IsUnlock()
                end,
                callBack = function()
                    TutorialManager.NextSubStep(nil, true)
                end
            }
        )
    elseif self.subStep == 7 then

        SDKAnalytics.TraceEvent(122)

        TutorialHelper.CameraMove(
            {
                maskType = TutorialMaskType.None,
                -- movePosition = self.kitchen:GetZonePoint(),
                zoneId = self.kitchen.zoneId,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 8 then
        TutorialHelper.FingerMove(
            {
                maskType = TutorialMaskType.None,
                fingerPoint = Utils.GetLocalPointInRectangleByPosition(Vector3.New(0, 0, 0)),
                fingerFunc = function()

                    SDKAnalytics.TraceEvent(123)

                    self.kitchen.view:MouseUp()
                end,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 13 then
        TutorialManager.NextSubStep()
        -- TutorialHelper.CameraMove(
        --     {
        --         maskType = TutorialMaskType.None,
        --         -- movePosition = self.dorm2:GetZonePoint(),
        --         zoneId = self.dorm2.zoneId,
        --         callBack = TutorialManager.NextSubStep
        --     }
        -- )
    elseif self.subStep == 14 then
        TutorialHelper.CameraFocus(
            {
                maskType = TutorialMaskType.None,
                target = self.character.transform,
                stopFunc = function()
                    if
                        self.character.currGrid.zoneType == ZoneType.Kitchen and
                        self.character.currGrid.markerType == GridMarker.Burner
                    then
                        return true
                    end
                    return false
                end,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 15 then
        TutorialHelper.CameraLockUp(
            {
                maskType = TutorialMaskType.None,
                stopFunc = function()
                    return FoodSystemManager.GetFoodCount(self.cityId) >= 1
                end,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 16 then

        SDKAnalytics.TraceEvent(126)

        local list = List:New()
        list:Add({ peopleId = 1, peopleText = "Tutorial_BuildKitchen_dialogue_4", right = "0" })
        list:Add({ peopleId = 4, peopleText = "Tutorial_BuildKitchen_dialogue_5", right = "1" })
        TutorialHelper.ShowDialog(
            {
                maskType = TutorialMaskType.None,
                dialogues = list,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 17 then
        TutorialHelper.CameraLockUp(
            {
                maskType = TutorialMaskType.None,
                stopFunc = function()
                    return FoodSystemManager.GetFoodCount(self.cityId) >= 4 and
                        TimeManager.GetCityClock(self.cityId) >= 1159
                end,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 18 then
        self:Complete()
    end
end

function TutorialBuildKitchen:OnComplete()
    TutorialManager.OpenTutorial(TutorialStep.SchedulesEat, 1, true)
end

return TutorialBuildKitchen
