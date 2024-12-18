TutorialOverloadOpen = Clone(TutorialBase)
TutorialOverloadOpen.__cname = "TutorialOverloadOpen"

function TutorialOverloadOpen:OnInit()
    self.mapItemData = MapManager.GetMapItemData(self.cityId, "C" .. self.cityId .. "_Generator_1")
end

function TutorialOverloadOpen:OnRun()
    if self.subStep == 1 then
        local consumptionItemId = GeneratorManager.GetConsumptionItemId(self.cityId)
        local consumptionItemCount = DataManager.GetMaterialCount(self.cityId, consumptionItemId)
        local nightConsumption = GeneratorManager.GetNightConsumption(self.cityId)
        local leftTime = math.ceil(consumptionItemCount / nightConsumption)
        if leftTime < 1 then
            local itemId = GeneratorManager.GetConsumptionItemId(self.cityId)
            local itemCount = GeneratorManager.GetCount(self.cityId)
            DataManager.SetMaterial(self.cityId, itemId, itemCount)
        end
        if not GeneratorManager.GetIsEnable(self.cityId) then
            GeneratorManager.Open(self.cityId)
        end
        if GeneratorManager.GetIsOverload(self.cityId) then
            GeneratorManager.CloseOverload(self.cityId)
        end

        TutorialHelper.CameraMove(
            {
                maskType = TutorialMaskType.None,
                zoneId = "C1_Sawmill_1",
                callBack = TutorialManager.NextSubStep
            }
        )

    elseif self.subStep == 2 then
        -- WeatherManager.OnWeatherChange(DataManager.GetCityId(), WeatherType.Storm)
        EventManager.Brocast(EventDefine.ShowMainUIBanner, "home_img_gas_01", 2)

        TutorialHelper.CameraLockUp({
            maskType = TutorialMaskType.None,
            stopTime = 2,
            callBack = function()

                SDKAnalytics.TraceEvent(146)

                local list = List:New()
                list:Add({ peopleId = 4, peopleText = "Tutorial_OverloadOpen_dialogue_1", right = "1" })
                list:Add({ peopleId = 1, peopleText = "Tutorial_OverloadOpen_dialogue_2", right = "0" })
                list:Add({ peopleId = 4, peopleText = "Tutorial_OverloadOpen_dialogue_3", right = "1" })

                TutorialHelper.ShowDialog(
                    {
                        maskType = TutorialMaskType.None,
                        dialogues = list,
                        callBack = TutorialManager.NextSubStep
                    }
                )
            end
        })
    elseif self.subStep == 3 then
        TutorialHelper.CameraMove(
            {
                maskType = TutorialMaskType.None,
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
    elseif self.subStep == 5 then
    elseif self.subStep == 6 then
        EventManager.Brocast(EventType.TIME_CITY_UPDATE, self.cityId)

        SDKAnalytics.TraceEvent(148)

        local list = List:New()
        list:Add({ peopleId = 4, peopleText = "Tutorial_OverloadOpen_dialogue_5", right = "0" })
        list:Add({ peopleId = 1, peopleText = "Tutorial_OverloadOpen_dialogue_6", right = "1" })
        list:Add({ peopleId = 4, peopleText = "Tutorial_OverloadOpen_dialogue_7", right = "0" })

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

function TutorialOverloadOpen:OnComplete()
    TutorialManager.CloseTutorial()
end

return TutorialOverloadOpen
