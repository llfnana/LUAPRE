TutorialBuildSawmill = Clone(TutorialBase)
TutorialBuildSawmill.__cname = "TutorialBuildSawmill"

function TutorialBuildSawmill:OnInit()
    self.mapItemData = MapManager.GetMapItemData(self.cityId, "C1_Sawmill_1")
    self.character = CharacterManager.GetCharacterBySerialNumber(self.cityId, 1)
end

function TutorialBuildSawmill:OnRun()

    if self.mapItemData:IsUnlock() and self.subStep < 6 then
        self.subStep = 5
    end

    TutorialHelper.CameraLockUp({
        maskType = TutorialMaskType.None,
        stopTime = 0.5
    })


    if self.subStep == 1 then -- 相机移动到伐木场
        TutorialHelper.CameraMove({
            maskType = TutorialMaskType.None,
            zoneId = self.mapItemData.zoneId,
            -- movePosition = self.mapItemData:GetZonePoint(),
            callBack = TutorialManager.NextSubStep
        })
    elseif self.subStep == 2 then -- 点击建造
        TutorialHelper.FingerMove({
            maskType = TutorialMaskType.None,
            noticeKey = "Tutorial_BuildLumberMill_notice_1",
            fingerPoint = Utils.GetLocalPointInRectangleByPosition(Vector3.New(0, 0, 0)),
            fingerFunc = function()

                SDKAnalytics.TraceEvent(106)
                self.mapItemData.view:MouseUp()
            end,
            callBack = TutorialManager.NextSubStep
        })
    elseif self.subStep == 3 then
        TutorialHelper.CameraLockUp({
            maskType = TutorialMaskType.None,
            stopFunc = function() 
                return UIBuildUnlockPanel.startTutorial == true
            end
        })
    elseif self.subStep == 4 then
        TutorialHelper.CameraLockUp({
            maskType = TutorialMaskType.None,
            stopFunc = function()
                return self.mapItemData:IsUnlock()
            end,
            callBack = function()
                TutorialManager.NextSubStep(nil, true)
            end
        })
    elseif self.subStep == 5 then

        SDKAnalytics.TraceEvent(109)

        TutorialHelper.CameraMove({
            maskType = TutorialMaskType.None,
            zoneId = self.mapItemData.zoneId,
            -- movePosition = self.mapItemData:GetZonePoint(),
            callBack = TutorialManager.NextSubStep
        })
    elseif self.subStep == 6 then

        TutorialHelper.CameraLockUp({
            maskType = TutorialMaskType.None,
            stopTime = 1
        })

        TutorialHelper.FingerMove({
            maskType = TutorialMaskType.None,
            fingerPoint = Utils.GetLocalPointInRectangleByPosition(Vector3.New(0, 0, 0)),
            fingerFunc = function()

                SDKAnalytics.TraceEvent(110)

                self.mapItemData.view:MouseUp()
            end,
            callBack = TutorialManager.NextSubStep
        })
    elseif self.subStep == 12 then
        TutorialHelper.CameraFocus({
            maskType = TutorialMaskType.None,
            target = self.character.transform,
            stopFunc = function()
                if self.character.currGrid.zoneType == ZoneType.Sawmill and self.character.currGrid.markerType ==
                    GridMarker.Tool1ForSawmill then
                    return true
                end
                return false
            end,
            callBack = function()
                TutorialManager.NextSubStep(0.2)
            end
        })
    elseif self.subStep == 13 then
        self:Complete()
    end
end

function TutorialBuildSawmill:OnComplete()
    TutorialManager.OpenTutorial(TutorialStep.BuildKitchen, 1, true)
end

return TutorialBuildSawmill
