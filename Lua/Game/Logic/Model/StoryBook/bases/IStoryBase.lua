---@class IStoryBase
IStoryBase = {
    ---@type EnumStoryType type
    type = EnumStoryType.None,
    ---@type DataBase dataBase
    dataBase = {},
    ---@type table runtimeData
    runtimeData = {},
}
IStoryBase.__cname = "IStoryBase"

---@param dataBase DataBase
---@return IStoryBase
function IStoryBase:Create(dataBase)
    local obj = Clone(self)
    obj.dataBase = dataBase or {}
    return obj
end

---@param runtimeData table
function IStoryBase:Execute(runtimeData)
    self.runtimeData = runtimeData or {}
    
    self:PrepareInputs()

    self:OnExecuteSelf()

    --self:ExecuteNextNode()
end

function IStoryBase:PrepareInputs()

end

function IStoryBase:OnExecuteSelf()

end

function IStoryBase:ExecuteNextNode()
    local dataBase = StoryBookManager.GetDataById(self.dataBase.next)
    if dataBase ~= nil then
        StoryBookManager.ExecuteItem(dataBase, self.runtimeData)
    else
        StoryBookManager.FinishItem(dataBase, self.runtimeData)
    end
end 