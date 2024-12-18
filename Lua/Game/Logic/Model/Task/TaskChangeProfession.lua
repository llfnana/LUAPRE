---@class TaskChangeProfession : TaskBase
TaskChangeProfession = Clone(TaskBase)
TaskChangeProfession.__cname = "TaskChangeProfession"

function TaskChangeProfession:OnInit()
    self.professionType = self.taskConfig.task["professionType"]
end

function TaskChangeProfession:OnResponse(newProfessionType, oldProfessionType)
    return self.professionType == newProfessionType
end

function TaskChangeProfession:OnCheck()
    local charList = CharacterManager.GetCharactersByPeopleType(self.cityId, self.professionType)

    self:SetCurrCount(charList:Count())
end

function TaskChangeProfession:_GetTaskDesc(lang)
    local zoneCfg, lvl = self:GetZone(self.cityId, self.professionType)
    
    if lvl > #zoneCfg.name_key then
        lvl = #zoneCfg.name_key
    end
    
    return GetLangFormat(lang, self.taskMaxCount, GetLang(zoneCfg.name_key[lvl]), self.taskCurrCount)
end

function TaskChangeProfession:GetIconSprite(ImageIcon)
    -- 建筑
    local zoneCfg, lvl = self:GetZone(self.cityId, self.professionType)
    Utils.SetZoneIconByType(ImageIcon, self.cityId, zoneCfg.zone_type, 1, true)
    ImageIcon.transform.localScale = Vector2(0.6, 0.6)
end

function TaskChangeProfession:LookUpZone()
    local zoneCfg = self:GetZone(self.cityId, self.professionType)
    --local mapItemData = MapManager.GetMapItemData(self.cityId, zoneCfg.id)
    
    --if MapManager.IsZoneUnlock(self.cityId, zoneCfg.id) and mapItemData:GetLevel() > 0 then
    --
    --    PopupManager.Instance:CloseAllPanel()
    --    PopupManager.Instance:LastOpenPanel(PanelType.PeoplePanel,
    --        {from = PanelType.TaskPanel, extented = {
    --            taskId = self.taskId
    --        }}, true)
    --    return
    --end
    
    Utils.LookUpFurniture(zoneCfg.id, "", 0, PanelType.TaskPanel, {taskId = self.taskId}, true)
end

-- 返回给定zoneId是否是这个任务所需建筑
---@param zoneId string
---@return boolean
function TaskChangeProfession:IsTargetZone(zoneId)
    local peopleCfg = ConfigManager.GetPeopleConfigByType(self.cityId, self.professionType)
    local zoneCfgList = ConfigManager.GetZoneConfigListByType(self.cityId, peopleCfg.zone_type)

    local exists = false
    zoneCfgList:ForEach(
        function(v)
            if v.id == zoneId then
                exists = true
                return true
            end
        end
    )

    return exists
end

function TaskChangeProfession:GetZone(cityId, professionType)
    local peopleCfg = ConfigManager.GetPeopleConfigByType(cityId, professionType)
    local zoneCfgList = ConfigManager.GetZoneConfigListByType(cityId, peopleCfg.zone_type)
    if zoneCfgList:Count() == 0 then
        return nil
    end

    local mapItemData = MapManager.GetMapItemData(cityId, zoneCfgList[1].id)
    local lvl = mapItemData:GetLevel()
    if lvl == 0 then
        lvl = 1
    end

    return zoneCfgList[1], lvl
end

return TaskChangeProfession
