TutorialHelper = {}
TutorialHelper._cname = "TutorialHelper"

local this = TutorialHelper

function TutorialHelper.AttachRoot()
    -- local view = ResourceManager.Instantiate("ui/TutorialPanel", root)
    -- ---@type TutorialPanel tutorialPanel
    -- this.tutorialPanel = TutorialPanel.Create(view)
    -- this.tutorialPanel.OnInit()
    
    ShowUI(UINames.UIGuide)
    this.tutorialPanel = UIGuidePanel
end

function TutorialHelper.OnDestroy()
    this.tutorialPanel.OnDestroy()
end

--教程移动相机
function TutorialHelper.CameraMove(params)
    this.tutorialPanel.CameraMove(params)
end

--相机聚焦
function TutorialHelper.CameraFocus(params)
    this.tutorialPanel.CameraFocus(params)
end

--相机等待
function TutorialHelper.CameraWait(params)
    this.tutorialPanel.CameraWait(params)
end

--相机锁定
function TutorialHelper.CameraLockUp(params)
    this.tutorialPanel.CameraLockUp(params)
end

--相机变焦
function TutorialHelper.CameraZoom(params)
    this.tutorialPanel.CameraZoom(params)
end

--相机移动变焦
function TutorialHelper.CameraMoveZoom(params)
    this.tutorialPanel.CameraMoveZoom(params)
end

--教程移动手指
function TutorialHelper.FingerMove(params)
    this.tutorialPanel.FingerMove(params)
end

--引导显示对话
function TutorialHelper.ShowDialog(params)
    this.tutorialPanel.ShowDialog(params)
end

--引导显示旁白
function TutorialHelper.ShowNarrator(params)
    this.tutorialPanel.ShowNarrator(params)
end

--引导显示说话
function TutorialHelper.ShowTalks(params)
    this.tutorialPanel.ShowTalks(params)
end

--关闭引导界面
function TutorialHelper.ClosePanel(params)
    this.tutorialPanel.ClosePanel(params)
end

--移动到建筑
---@param mapItemData MapItemData
---@param callBackFunc function
function TutorialHelper.FocusToMapItem(mapItemData, callBackFunc, focusPostion)
    local movePosition = nil
    if focusPostion ~= nil then
        movePosition = focusPostion
    else
        movePosition = mapItemData.GetZonePoint()
    end
    TutorialHelper.CameraMove(
        {
            maskType = TutorialMaskType.None,
            movePosition = movePosition,
            callBack = function()
                local close_roof_size = ConfigManager.GetMiscConfig("close_roof_size")
                if Map.Instance.cameraSize > close_roof_size then
                    TutorialHelper.CameraZoom(
                        {
                            orthographicSize = close_roof_size - 10,
                            orthographicTime = 2,
                            maskType = TutorialMaskType.None,
                            callBack = function()
                                if callBackFunc then
                                    callBackFunc()
                                end
                            end
                        }
                    )
                else
                    if callBackFunc then
                        callBackFunc()
                    end
                end
            end
        }
    )
end

function TutorialHelper.NonMandatoryFinger(targetButton, bindPanel, delayDestroy)
    -- require("Game/Logic/View/UI/NonMandatoryTutorialFinger")
    -- local obj = ResourceManager.Instantiate("ui/NonMandatoryTutorialFinger", targetButton.transform)
    -- local view = NonMandatoryTutorialFinger.Create(obj)
    -- view.OnInit(targetButton, bindPanel, delayDestroy)
    
    -- return view
end
