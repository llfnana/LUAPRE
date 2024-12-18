---@class ShowBuildIcon : IActionBase
ShowBuildIcon = Clone(IActionBase)
ShowBuildIcon.__cname = "ShowBuildIcon"
ShowBuildIcon.type = EnumActionType.ShowBuildIcon

function ShowBuildIcon:PrepareInputs()
    local data = self.dataBase.p1
    local cityId = DataManager.GetCityId()
    self.saveKey = string.format("%s_%s_%s", EnumActionType.ShowBuildIcon, cityId, data.zoneId)
    StoryBookManager.SaveExecuteItem(self.saveKey, self.dataBase, self.runtimeData)
end

function ShowBuildIcon:OnExecuteSelf()
    ---@type MapItem mapItem
    local mapItem = Map.Instance:GetMapItemByZoneId(self.dataBase.p1.zoneId)
    if mapItem ~= nil then
        --local centerPos = MainUI.Instance:GetCenterPos()
        --Map.Instance:FocusPos(centerPos, mapItem:GetTipPoint(), 20)
        --弹出对话气泡
        mapItem:ShowStoryBookIcon(function() 
            mapItem:CloseStoryBookIcon()
            mapItem:CheckRoof()
            mapItem:RefreshRoofView()

            TutorialHelper.CameraMove(
                    {
                        maskType = TutorialMaskType.None,
                        movePosition = mapItem:GetPoint(),
                        callBack = function()
                            StoryBookManager.ClearExecuteItem(self.saveKey)
                            self:ExecuteNextNode()
                        end
                    }
            )
            
        end)
    end
end

return ShowBuildIcon