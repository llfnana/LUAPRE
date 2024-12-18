TutorialOverloadClose = Clone(TutorialBase)
TutorialOverloadClose.__cname = "TutorialOverloadClose"

function TutorialOverloadClose:OnInit()
    self.mapItemData = MapManager.GetMapItemData(self.cityId, "C" .. self.cityId .. "_Generator_1")
end

function TutorialOverloadClose:OnRun()
    if self.subStep == 1 then
        local list = List:New()
        local step = nil
        if GeneratorManager.GetIsOverload(self.cityId) then --火炉,过载都开启
            list:Add({ peopleId = 4, peopleText = "Tutorial_OverloadClose_dialogue_1", right = "0" })
            list:Add({ peopleId = 1, peopleText = "Tutorial_OverloadClose_dialogue_2", right = "1" })
            step = 3
        elseif GeneratorManager.GetIsEnable(self.cityId) then --火炉未灭 过载关闭
            list:Add({ peopleId = 4, peopleText = "Tutorial_OverloadClose_dialogue_8", right = "0" })
            list:Add({ peopleId = 1, peopleText = "Tutorial_OverloadClose_dialogue_9", right = "1" })
            list:Add({ peopleId = 4, peopleText = "Tutorial_OverloadClose_dialogue_10", right = "0" })
            step = 7
        else --火炉熄灭
            list:Add({ peopleId = 4, peopleText = "Tutorial_OverloadClose_dialogue_12", right = "0" })
            list:Add({ peopleId = 1, peopleText = "Tutorial_OverloadClose_dialogue_13", right = "1" })
            list:Add({ peopleId = 4, peopleText = "Tutorial_OverloadClose_dialogue_14", right = "0" })
            step = 7
        end
        TutorialHelper.ShowDialog(
            {
                maskType = TutorialMaskType.None,
                dialogues = list,
                callBack = function()
                    TutorialManager.JumpSubStep(step)
                end
            }
        )
    elseif self.subStep == 3 then
        TutorialHelper.CameraMove(
            {
                maskType = TutorialMaskType.None,
                -- movePosition = self.mapItemData:GetZonePoint(),
                zoneId = self.mapItemData.zoneId,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 4 then
        TutorialHelper.FingerMove(
            {
                maskType = TutorialMaskType.None,
                fingerPoint = Utils.GetLocalPointInRectangleByPosition(Vector3.New(0, 0, 0)),
                fingerFunc = function()
                    self.mapItemData.view:MouseUp()
                end,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 6 then
        local list = List:New()
        list:Add({ peopleId = 4, peopleText = "Tutorial_OverloadClose_dialogue_4", right = "0" })
        list:Add({ peopleId = 1, peopleText = "Tutorial_OverloadClose_dialogue_5", right = "1" })
        list:Add({ peopleId = 4, peopleText = "Tutorial_OverloadClose_dialogue_6", right = "0" })
        list:Add({ peopleId = 1, peopleText = "Tutorial_OverloadClose_dialogue_7", right = "1" })
        TutorialHelper.ShowDialog(
            {
                maskType = TutorialMaskType.None,
                dialogues = list,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 7 then
        TutorialManager.StopTime.value = false
        self:Complete()
    end
end

function TutorialOverloadClose:OnComplete()
    LogWarning("我已经是老用户了")
    DataManager.SetGlobalDataByKey(DataKey.NewUser, false)
    TutorialManager.CloseTutorial()
end

return TutorialOverloadClose
