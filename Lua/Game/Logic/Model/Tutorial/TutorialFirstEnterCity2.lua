TutorialFirstEnterCity2 = Clone(TutorialBase)
TutorialFirstEnterCity2.__cname = "TutorialFirstEnterCity2"

function TutorialFirstEnterCity2:OnRun()
    -- if self.subStep == 1 then
    --     -- MainUI.Instance:SetBottomByTutorialDialog(false)
    --     local grid = GridManager.GetGridByMarkerType(self.cityId, GridMarker.TutorialBorn)
    --     TutorialHelper.CameraMove(
    --         {
    --             movePosition = grid.position,
    --             maskType = TutorialMaskType.None,
    --             rightNow = true
    --         }
    --     )
    --     TutorialHelper.CameraLockUp(
    --         {
    --             maskType = TutorialMaskType.None,
    --             stopFunc = function()
    --                 return CharacterManager.GetCharacterCount(self.cityId) > 0
    --             end,
    --             callBack = TutorialManager.NextSubStep
    --         }
    --     )
    -- elseif self.subStep == 2 then
    --     self.character = CharacterManager.GetCharacterBySerialNumber(self.cityId, 1)
    --     TutorialHelper.CameraMove(
    --         {
    --             movePosition = self.character.transform.position,
    --             maskType = TutorialMaskType.None,
    --             callBack = TutorialManager.NextSubStep
    --         }
    --     )
    -- elseif self.subStep == 3 then
    --     TutorialHelper.CameraFocus(
    --         {
    --             maskType = TutorialMaskType.None,
    --             target = self.character.transform,
    --             stopFunc = function()
    --                 if self.character.currGrid.zoneType == ZoneType.Dorm then
    --                     return true
    --                 end
    --                 return false
    --             end,
    --             callBack = TutorialManager.NextSubStep
    --         }
    --     )
    -- elseif self.subStep == 4 then
    --     local list = List:New()
    --     list:Add({ peopleId = 1, peopleText = "Tutorial_EnterCity2_dialogue_1", right = "0" })
    --     list:Add({ peopleId = 4, peopleText = "Tutorial_EnterCity2_dialogue_2", right = "1" })
    --     list:Add({ peopleId = 3, peopleText = "Tutorial_EnterCity2_dialogue_3", right = "0" })
    --     list:Add({ peopleId = 2, peopleText = "Tutorial_EnterCity2_dialogue_4", right = "1" })
    --     TutorialHelper.ShowDialog(
    --         {
    --             maskType = TutorialMaskType.None,
    --             dialogues = list,
    --             callBack = TutorialManager.NextSubStep
    --         }
    --     )
    -- elseif self.subStep == 5 then
    --     CityManager.OpenCityPassIntroduction(self.cityId)
    --     -- ShopManager.ShowAndClearPopupItemQueue()
    --     self:Complete()
    -- end

    if self.subStep == 1 then
        local list = List:New()
        list:Add({ peopleId = 4, peopleText = "Tutorial_EnterCity2_dialogue_1", right = "0" })
        list:Add({ peopleId = 1, peopleText = "Tutorial_EnterCity2_dialogue_2", right = "1" })
        list:Add({ peopleId = 1, peopleText = "Tutorial_EnterCity2_dialogue_3", right = "1" })
        list:Add({ peopleId = 4, peopleText = "Tutorial_EnterCity2_dialogue_4", right = "0" })
        TutorialHelper.ShowDialog(
            {
                maskType = TutorialMaskType.None,
                dialogues = list,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 2 then
        CityManager.OpenCityPassIntroduction(self.cityId)
        -- ShopManager.ShowAndClearPopupItemQueue()
        self:Complete()
    end
end

function TutorialFirstEnterCity2:OnComplete()
    TutorialManager.CloseTutorial()
end

return TutorialFirstEnterCity2
