---@class TaskUseItem : TaskBase
TaskUseItem = Clone(TaskBase)
TaskUseItem.__cname = "TaskUseItem"

function TaskUseItem:OnInit()
    self.itemType = self.taskConfig.task["itemType"]
    self.zoneId = self.taskConfig.task["zoneId"]
    self.itemConfig = ConfigManager.GetItemByType(self.cityId, self.itemType)
    
    if self.itemConfig == nil then
        print("[error]" .. "invalid itemType: " .. self.itemType .. ", taskId: " .. self.taskConfig.id)
    end
    
end

function TaskUseItem:OnResponse(itemId, value)
    if self.itemConfig.id == itemId then
        self:IncrCacheCount(value)
        
        return true
    end
    return false
end

function TaskUseItem:OnCheck()
    self:SetCurrCount(self:GetCacheCount())
end

function TaskUseItem:_GetTaskDesc(lang)
    return GetLangFormat(lang, self.taskMaxCount, GetLang(self.itemConfig.name_key), math.floor(self.taskCurrCount))
end

function TaskUseItem:GetIconSprite()
    -- 道具
    Utils.SetItemIcon(ImageIcon, self.itemConfig.id, true)
    ImageIcon.transform.localScale = Vector2(0.7, 0.7)
end

function TaskUseItem:GetTaskProgress()
    return Utils.FormatCount(math.floor(self:GetSafeCurrCount())), Utils.FormatCount(self.taskMaxCount)
end

function TaskUseItem:LookUpZone()
    if self.zoneId ~= nil then
        Utils.LookUpFurniture(self.zoneId, "", 0, PanelType.TaskPanel, {taskId = self.taskId}, true)
    else
        local zoneList = self:GetZoneList(self.cityId, self.itemConfig.producted_in)
        if zoneList:Count() >= 1 then
            Utils.LookUpFurniture(zoneList[1].id, "", 0, PanelType.TaskPanel, {taskId = self.taskId}, true)
        else
            -- GameToast.Instance:Show(GetLang("ui_task_need_more_unlock"),ToastIconType.Warning)
            UIUtil.showText(GetLang("ui_task_need_more_unlock"))
        end
    end
end

-- 返回给定zoneId是否是这个任务所需建筑
---@param zoneId string
---@return boolean
function TaskUseItem:IsTargetZone(zoneId)
    if self.zoneId ~= nil then
        return self.zoneId == zoneId
    else
        local zoneList = self:GetZoneList(self.cityId, self.itemConfig.producted_in)
        local exists = false
        zoneList:ForEach(
            function(v)
                if v.id == zoneId then
                    exists = true
                    return true
                end
            end
        )
    
        return exists
    end
end

---@param cityId number
---@param zoneTypeArray
---@return string[]
function TaskUseItem:GetZoneList(cityId, zoneTypeArray)
    local zoneList = List:New()
    
    for _, zoneType in ipairs(zoneTypeArray) do
        local zoneCfgList = ConfigManager.GetZoneConfigListByType(cityId, zoneType)
        zoneList:Merge(zoneCfgList)
    end
    
    return zoneList
end

return TaskUseItem
