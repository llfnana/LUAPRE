TutorialFactoryGame = Clone(TutorialBase)
TutorialFactoryGame.__cname = "TutorialFactoryGame"

function TutorialFactoryGame:OnInit()
end

function TutorialFactoryGame:OnRun()
    if self.subStep == 1 then
        -- 镜头移到建筑
        local  path = "Map/layer_zone_map_4/FactoryGame/FactoryGamePanelEntity/BuildCursor"
        local obj = GameObject.Find(path)
        TutorialHelper.CameraMove(
            {
                maskType = TutorialMaskType.None,
                -- movePosition = Vector3.New(20.75, 5.61, 0),
                movePosition = obj.transform.position,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 2 then
        -- 剧情对话
        SDKAnalytics.TraceEvent(165)
        local list = List:New()
        list:Add({ peopleId = 4, peopleText = "Tutorial_gamemachine_dialogue_1", right = "0" })
        list:Add({ peopleId = 1, peopleText = "Tutorial_gamemachine_dialogue_2", right = "1" })
        list:Add({ peopleId = 4, peopleText = "Tutorial_gamemachine_dialogue_3", right = "0" })
        list:Add({ peopleId = 1, peopleText = "Tutorial_gamemachine_dialogue_4", right = "1" })

        TutorialHelper.ShowDialog(
            {
                maskType = TutorialMaskType.None,
                dialogues = list,
                callBack = TutorialManager.NextSubStep
            }
        )
    elseif self.subStep == 3 then 
        -- 手指引导点击加号，弹出建造界面
        local  path = "Mpa/layer_zone_map_4/FactoryGame/FactoryGamePanelEntity/BuildCursor"
        local obj = GameObject.Find(path)
        -- obj.transform.position
        TutorialHelper.FingerMove(
            {
                maskType = TutorialMaskType.None,
                noticeKey = "ui_gamemachine_guide_tip",

                fingerPoint = Utils.GetLocalPointInRectangleByPosition(Vector3.New(0, 0, 0)),
                -- Vector3.New(20.75, 5.61, 0)
                fingerFunc = function()
                    SDKAnalytics.TraceEvent(167)
                    ShowUI(UINames.UIBuildFactoryGame)
                end,
                callBack = TutorialManager.NextSubStep,
                fingerMove = true
            }
        )
    elseif self.subStep == 4 then
        -- 等待打开界面
        TutorialHelper.CameraLockUp({
            maskType = TutorialMaskType.None,
            stopFunc = function() 
                return UIBuildFactoryGamePanel and UIBuildFactoryGamePanel.startTutorial
            end,
            callBack = function()
                TutorialManager.NextSubStep(nil, true)
            end
        })
    elseif self.subStep == 5 then
        -- 等待点击建造
        TutorialHelper.CameraLockUp(
            {
                maskType = TutorialMaskType.None,
                stopFunc = function()
                    return FactoryGameData.IsBuildComplete()
                end,
                callBack = function()
                    TutorialManager.NextSubStep(nil, true)
                end
            }
        )
    elseif self.subStep == 6 then
        -- 引导完成
        self:Complete()
    end
end

function TutorialFactoryGame:OnComplete()
    TutorialManager.CloseTutorial()
end

return TutorialFactoryGame
