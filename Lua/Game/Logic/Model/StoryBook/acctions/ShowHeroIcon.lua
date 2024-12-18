---@class ShowHeroIcon : IActionBase
ShowHeroIcon = Clone(IActionBase)
ShowHeroIcon.__cname = "ShowHeroIcon"
ShowHeroIcon.type = EnumActionType.ShowHeroIcon

function ShowHeroIcon:PrepareInputs()
    local data = self.dataBase.p1
    local cityId = DataManager.GetCityId()
    self.saveKey = string.format("%s_%s_%s", EnumActionType.ShowHeroIcon, cityId, data.zoneId)
    StoryBookManager.SaveExecuteItem(self.saveKey, self.dataBase, self.runtimeData)
end

function ShowHeroIcon:OnExecuteSelf()
    -- local data = self.dataBase.p1
    -- local cityId = DataManager.GetCityId()
    -- ---@type HeroController hero
    -- local hero = MapManager.SearchHeroController(cityId, data.zoneId)
    -- local mapItem = Map.Instance:GetMapItemByZoneId(data.zoneId)
    -- if hero ~= nil and mapItem ~= nil then
    --     local clickAction = function()
    --         hero:ClearStoryBookIcon()
    --         mapItem:CloseStoryBookIcon()
    --         StoryBookManager.ClearExecuteItem(self.saveKey)
    --         self:ExecuteNextNode()
    --     end
    --     hero:ShowStoryBookIcon({}, clickAction)
    --     mapItem:SetClickStoryBookAction(clickAction)
    -- end
end

return ShowHeroIcon