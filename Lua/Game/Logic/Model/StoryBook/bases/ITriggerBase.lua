---@class ITriggerBase
ITriggerBase = {
    ---@type EnumTriggerType type
    type = EnumTriggerType.None,
    ---@type DataBase dataBase
    dataBase = {},
    ---@type table runtimeData
    runtimeData = {},
}
ITriggerBase.__cname = "ITriggerBase"

---@param dataBase DataBase
---@return ITriggerBase
function ITriggerBase:Create(dataBase)
    local obj = Clone(self)
    obj.dataBase = dataBase or {}
    return obj
end

---@param runtimeData table
function ITriggerBase:Execute(runtimeData)
    self.runtimeData = runtimeData or {}

    if self:CheckCondition() then

        self:PrepareInputs()

        self:OnExecuteSelf()

        self:ExecuteNextNode()
        
    else
        StoryBookManager.FinishItem(self.dataBase, self.runtimeData)
    end
end

function ITriggerBase:PrepareInputs()
    
end

---@param runtimeData table
---@return boolean
function ITriggerBase:CheckCondition()
    return false
end 

function ITriggerBase:OnExecuteSelf()
    
end 

function ITriggerBase:ExecuteNextNode()
    local dataBase = StoryBookManager.GetDataById(self.dataBase.next)
    if dataBase ~= nil then
        StoryBookManager.ExecuteItem(dataBase, self.runtimeData)
    else
        StoryBookManager.FinishItem(dataBase, self.runtimeData)
    end
end 