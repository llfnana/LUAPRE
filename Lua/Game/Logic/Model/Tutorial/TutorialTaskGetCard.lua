TutorialTaskGetCard = Clone(TutorialBase)
TutorialTaskGetCard.__cname = "TutorialTaskGetCard"

function TutorialTaskGetCard:OnInit()
    self.cardId = TutorialManager.KeanuCardId
end

function TutorialTaskGetCard:OnRun()
    if self.subStep == 1 then
        local maxCityId = DataManager.GetMaxCityId()
        if maxCityId == self.config.cityId then
            TutorialManager.NextSubStep(0.2)
        else
            self:Complete()
        end
    elseif self.subStep == 2 then
        local list = List:New()
        local sprite = "npc_model_105"
        list:Add({
            headSprite = sprite,
            peopleText = "Tutorial_CardCoalMine_dialogue_1",
            name = TutorialManager.KeanuCardName
        })
        list:Add({
            headSprite = sprite,
            peopleText = "Tutorial_CardCoalMine_dialogue_2",
            name = TutorialManager.KeanuCardName
        })
        TutorialHelper.ShowDialog({
            dialogues = list,
            callBack = function()
                TutorialManager.NextSubStep(0.3)
            end
        })
    elseif self.subStep == 3 then
        local heroMapItemData = nil
        for zoneId, mapItem in pairs(CityModule.getMainCtrl().buildDict) do
            if MapManager.IsValidZoneId(DataManager.GetCityId(), zoneId) then
                local mapItemData = MapManager.GetMapItemData(DataManager.GetCityId(), zoneId)
                local cardId = mapItemData:GetDefaultCardId()
                if self.cardId == tonumber(cardId) then
                    heroMapItemData = mapItemData
                    break
                end
            end
        end

        if heroMapItemData ~= nil then
            MapManager.GetMapItemData(self.cityId, heroMapItemData.zoneId)
            TutorialHelper.CameraMove({
                maskType = TutorialMaskType.None,
                zoneId = heroMapItemData.zoneId,
                -- movePosition = heroMapItemData.view:GetPoint(),
                callBack = function()
                    TutorialHelper.FingerMove({
                        maskType = TutorialMaskType.None,
                        fingerPoint = Utils.GetLocalPointInRectangleByPosition(Vector3.New(0, 0, 0)),
                        fingerFunc = function()
                            heroMapItemData.view:MouseUp()
                        end,
                        callBack = function()
                            TutorialManager.NextSubStep(0.2)
                        end
                    })
                end
            })
        else
            self:Complete()
        end
    elseif self.subStep == 4 then
        TutorialHelper.CameraLockUp({
            maskType = TutorialMaskType.None,
            stopFunc = function()
                return UIBuildPanel.uidata and isNil(UIBuildPanel.uidata.TutorialHero) == false
            end,
            callBack = function()
                local peopleItem = UIBuildPanel.uidata.TutorialHero
                TutorialHelper.FingerMove({
                    maskType = TutorialMaskType.None,
                    noticeKey = "Tutorial_ToBattle_tips",
                    noticePos = Utils.GetLocalPointInRectangleByUI(peopleItem) + Vector2.New(0, 100),
                    fingerPoint = Utils.GetLocalPointInRectangleByUI(peopleItem),
                    fingerFunc = function()
                        UIBuildPanel.OnClickHeroFun()
                    end,
                    callBack = function()
                        TutorialManager.NextSubStep(0.3)
                    end
                })
            end
        })

    elseif self.subStep == 5 then
        TutorialHelper.CameraLockUp({
            maskType = TutorialMaskType.None,
            stopFunc = function()
                return UIHeroInfoPanel.uidata
            end,
            callBack = function()
                TutorialHelper.FingerMove({
                    maskType = TutorialMaskType.None,
                    noticeKey = "Tutorial_HeroGuide_dialogue_2",
                    noticePos = Utils.GetLocalPointInRectangleByUI(UIHeroInfoPanel.uidata.ButtonLvUp) + Vector2.New(0, 200),
                    fingerPoint = Utils.GetLocalPointInRectangleByUI(UIHeroInfoPanel.uidata.ButtonLvUp),
                    fingerCount = 4,
                    fingerFunc = function()
                        UIHeroInfoPanel.LevelUp()
                    end,
                    callBack = function()
                        TutorialManager.NextSubStep(0.1)
                    end
                })
            end
        })

    elseif self.subStep == 6 then
        self:Complete()
    end
end

function TutorialTaskGetCard:OnComplete()
    TutorialManager.CloseTutorial()
end

return TutorialTaskGetCard
