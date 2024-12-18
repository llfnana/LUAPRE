---@class IActionBase
IActionBase = {
    ---@type EnumActionType type
    type = EnumActionType.None,
    ---@type DataBase dataBase
    dataBase = {},
    ---@type table runtimeData
    runtimeData = {},
}
IActionBase.__cname = "IActionBase"

---@param dataBase DataBase
---@return IActionBase
function IActionBase:Create(dataBase)
    local obj = Clone(self)
    obj.dataBase = dataBase or {}
    return obj
end

---@param runtimeData table
function IActionBase:Execute(runtimeData)
    self.runtimeData = runtimeData or {}
    
    self:PrepareInputs()

    self:OnExecuteSelf()

    --self:ExecuteNextNode()
end

function IActionBase:PrepareInputs()

end

function IActionBase:OnExecuteSelf()

end

function IActionBase:ExecuteNextNode()
    local dataBase = StoryBookManager.GetDataById(self.dataBase.next)
    if dataBase ~= nil then
        StoryBookManager.ExecuteItem(dataBase, self.runtimeData)
    else
        StoryBookManager.FinishItem(dataBase, self.runtimeData)
    end
end 