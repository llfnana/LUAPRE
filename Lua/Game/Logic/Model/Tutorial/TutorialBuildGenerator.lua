TutorialBuildGenerator = Clone(TutorialBase)
TutorialBuildGenerator.__cname = "TutorialBuildGenerator"

function TutorialBuildGenerator:OnInit()
    self.mapItemData = MapManager.GetMapItemData(self.cityId, "C" .. self.cityId .. "_Generator_1")
    self.character = CharacterManager.GetCharacterBySerialNumber(self.cityId, 1)
end

function TutorialBuildGenerator:OnRun()

    TutorialHelper.CameraLockUp({
        maskType = TutorialMaskType.None,
        stopTime = 0.5
    })

    if self.subStep == 1 then --相机移动到炉子
        if GeneratorManager.GetIsEnable(self.cityId) then
            GeneratorManager.Close(self.cityId)
        end
        TutorialHelper.CameraMove(
            {
                zoneId = self.mapItemData.zoneId,
                -- movePosition = self.mapItemData:GetZonePoint(),
                maskType = TutorialMaskType.None,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 2 then --手指移动点击炉子
        TutorialHelper.FingerMove(
            {
                maskType = TutorialMaskType.None,
                noticeKey = "Tutorial_BuildGenerator_notice_1",
                -- fingerPoint = Utils.GetLocalPointInRectangleByScene(self.mapItemData.view),
                fingerPoint = Vector2(20, 30),
                fingerFunc = function()
                    -- self.mapItemData:MouseUp()
                    local data = {}
                    data.type = self.mapItemData.config.zone_type
                    data.zoneId = self.mapItemData.zoneId
                    CityModule.getMainCtrl():ShowBuildView(data)

                    SDKAnalytics.TraceEvent(103)
                end,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 3 then --检测炉子开启引导
        -- elseif self.subStep == 4 then
        -- TutorialHelper.CameraMove(
        --     {
        --         maskType = TutorialMaskType.None,
        --         movePosition = self.character.transform.position,
        --         callBack = TutorialManager.NextSubStep
        --     }
        -- )
    elseif self.subStep == 4 then
        SDKAnalytics.TraceEvent(105)
        TutorialHelper.CameraLockUp({
            maskType = TutorialMaskType.None,
            stopTime = 0.5,
            callBack = function()
                local list = List:New()
                list:Add({ peopleId = 4, peopleText = "Tutorial_BuildLumberMill_dialogue_1", right = "0" })
                list:Add({ peopleId = 1, peopleText = "Tutorial_BuildLumberMill_dialogue_2", right = "1" })
                list:Add({ peopleId = 4, peopleText = "Tutorial_BuildLumberMill_dialogue_3", right = "0" })

                TutorialHelper.ShowDialog(
                    {
                        maskType = TutorialMaskType.None,
                        dialogues = list,
                        callBack = TutorialManager.NextSubStep
                    }
                )
            end
        })
    elseif self.subStep == 5 then
        self:Complete()
    end
end

function TutorialBuildGenerator:OnComplete()
    TutorialManager.OpenTutorial(TutorialStep.BuildSawmill, 1, true)
end

return TutorialBuildGenerator
