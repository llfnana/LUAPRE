TutorialBuildHunterCabin = Clone(TutorialBase)
TutorialBuildHunterCabin.__cname = "TutorialBuildHunterCabin"

function TutorialBuildHunterCabin:OnInit()
    self.mapItemData = MapManager.GetMapItemData(self.cityId, "C1_HunterCabin_1")
    self.mapGenerator = MapManager.GetMapItemData(self.cityId, "C1_Generator_1")
    self.character = CharacterManager.GetCharacterBySerialNumber(self.cityId, 4)
    self.cityDay = TimeManager.GetCityDay(self.cityId)
    self.maxOrthographicSize = -70
end

function TutorialBuildHunterCabin:OnRun()

    TutorialHelper.CameraLockUp({
        maskType = TutorialMaskType.None,
        stopTime = 0.5
    })

    if self.mapItemData:IsUnlock() and self.subStep < 5 then
        self.subStep = 5
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
        TutorialHelper.FingerMove(
            {
                maskType = TutorialMaskType.None,
                noticeKey = "Tutorial_BuildCattleFarm_notice_1",
                fingerPoint = Utils.GetLocalPointInRectangleByPosition(Vector3.New(0, 0, 0)),
                fingerFunc = function()

                    SDKAnalytics.TraceEvent(131)

                    self.mapItemData.view:MouseUp()
                end,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 3 then
        TutorialHelper.CameraLockUp({
            maskType = TutorialMaskType.None,
            stopFunc = function() 
                return UIBuildUnlockPanel.startTutorial == true
            end
        })
    elseif self.subStep == 4 then
        TutorialHelper.CameraLockUp(
            {
                maskType = TutorialMaskType.None,
                stopFunc = function()
                    return self.mapItemData:IsUnlock()
                end,
                callBack = function()
                    TutorialManager.NextSubStep(nil, true)
                end
            }
        )
    elseif self.subStep == 5 then

        SDKAnalytics.TraceEvent(134)

        TutorialHelper.CameraMove(
            {
                maskType = TutorialMaskType.None,
                -- movePosition = self.mapItemData:GetZonePoint(),
                zoneId = self.mapItemData.zoneId,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 6 then
        TutorialHelper.FingerMove(
            {
                maskType = TutorialMaskType.None,
                fingerPoint = Utils.GetLocalPointInRectangleByPosition(Vector3.New(0, 0, 0)),
                fingerFunc = function()

                    SDKAnalytics.TraceEvent(135)

                    self.mapItemData.view:MouseUp()
                end,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 10 then

        SDKAnalytics.TraceEvent(137)

        TutorialHelper.ShowNarrator(
            {
                maskType = TutorialMaskType.None,
                narratorKey = "Tutorial_BuildCattleFarm_storytell_1",
                narratorTime = 4,
                callBack = TutorialManager.NextSubStep
            }
        )
        TutorialHelper.CameraMove(
            {
                maskType = TutorialMaskType.None,
                zoneId = self.mapGenerator.zoneId,
            }
        )
        TutorialHelper.CameraZoom(
            {
                orthographicSize = self.maxOrthographicSize,
                orthographicTime = 1,
                maskType = TutorialMaskType.None,
            }
        )
        -- TutorialHelper.CameraMoveZoom(
        --     {
        --         maskType = TutorialMaskType.None,
        --         -- movePosition = self.mapGenerator:GetZonePoint(),
        --         zoneId = self.mapItemData.zoneId,
        --         orthographicSize = 45,
        --         duration = 4,
        --         callBack = TutorialManager.NextSubStep
        --     }
        -- )
    elseif self.subStep == 11 then
        self:Complete()
    end
end

function TutorialBuildHunterCabin:OnComplete()
    TutorialManager.CloseTutorial()
    TutorialManager.StopTime.value = false
end

return TutorialBuildHunterCabin
