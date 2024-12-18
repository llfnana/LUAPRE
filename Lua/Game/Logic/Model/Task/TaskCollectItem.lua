---@class TaskCollectItem : TaskBase
TaskCollectItem = Clone(TaskBase)
TaskCollectItem.__cname = "TaskCollectItem"

function TaskCollectItem:OnInit()
    self.itemType = self.taskConfig.task["itemType"]
    if self.itemType == nil then
        print("[error]" .. "TaskCollectItem: not found itemType")
    end
    
    self.itemConfig = ConfigManager.GetItemByType(self.cityId, self.itemType)
    
    if self.itemConfig == nil then
        print("[error]" .. "TaskCollectItem: invalid itemType: " .. self.itemType .. " in city" .. self.cityId)
    end
    
    if self:GetCacheMaxCount() ~= 0 then
        -- 如果有历史的maxCount,那么使用历史的
        self.taskMaxCount = self:GetCacheMaxCount()
    end
end

function TaskCollectItem:OnResponse(itemId, value)
    local itemConfig = ConfigManager.GetItemConfig(itemId)
    if itemConfig == nil then
        return false
    end
    if self.itemType == itemConfig.item_type then
        self:IncrCacheCount(value)
        return true
    end
    
    return false
end

function TaskCollectItem:OnActive()
    if self:GetCacheMaxCount() == 0 then
        if self.taskConfig.task["countByTime"] ~= nil then
            local sec = tonumber(self.taskConfig.task["countByTime"])
            local cityProd = OverTimeProductionManager.Get(self.cityId)
            local perSecCount = cityProd:Get(self.itemConfig.id, sec, 1)
            --取最大值
            if self.taskMaxCount < perSecCount then
                self.taskMaxCount = perSecCount
            end
            
            self:SetCacheMaxCount(self.taskMaxCount)
        end
    end
end

function TaskCollectItem:OnCheck()
    self:SetCurrCount(self:GetCacheCount())
end

function TaskCollectItem:GetTaskProgress()
    return Utils.FormatCount(math.floor(self:GetSafeCurrCount())), Utils.FormatCount(self.taskMaxCount)
end

function TaskCollectItem:_GetTaskDesc(lang)
    return GetLangFormat(lang, Utils.FormatCount(self.taskMaxCount), GetLang(self.itemConfig.name_key), Utils.FormatCount(math.floor(self.taskCurrCount)))
end

function TaskCollectItem:GetIconSprite(ImageIcon)
    -- 道具
    Utils.SetItemIcon(ImageIcon, self.itemConfig.id, true)
    ImageIcon.transform.localScale = Vector2(0.7, 0.7)
end

function TaskCollectItem:LookUpZone()
    local zoneList = self:GetZoneList(self.cityId, self.itemConfig.producted_in)
    if zoneList:Count() >= 1 then
        Utils.LookUpFurniture(zoneList[1].id, "", 0, PanelType.TaskPanel, {taskId = self.taskId}, true)
    else
        -- GameToast.Instance:Show(GetLang("ui_task_need_more_unlock"),ToastIconType.Warning)
        UIUtil.showText(GetLang("ui_task_need_more_unlock"))
    end
end

-- 返回给定zoneId是否是这个任务所需建筑
---@param zoneId string
---@return boolean
function TaskCollectItem:IsTargetZone(zoneId)
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

---@param cityId number
---@param zoneTypeArray
---@return string[]
function TaskCollectItem:GetZoneList(cityId, zoneTypeArray)
    local zoneList = List:New()

    for _, zoneType in ipairs(zoneTypeArray) do
        local zoneCfgList = ConfigManager.GetZoneConfigListByType(cityId, zoneType)
        zoneList:Merge(zoneCfgList)
    end

    return zoneList
end

return TaskCollectItem
