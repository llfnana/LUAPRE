---@class StoryBookManager
StoryBookManager = {}
StoryBookManager.__cname = "StoryBookManager"
local this = StoryBookManager
local RootPath = "Game/Logic/Model/StoryBook"
local TriggerPath = RootPath .. "/Triggers/"
local ActionPath = RootPath .. "/Actions/"
local StoryPath = RootPath .. "/Storys/"

function StoryBookManager.Init()
    this.cityId = DataManager.GetCityId()
    
    --config
    this.dataConf = ConfigManager.GetStoryBook()
    
    --event
    require(RootPath .. "/StoryBookHandleEvents")
    StoryBookHandleEvents.Init()
    
    --behaviors
    require(RootPath .. "/Datas/DataBase")
    local behaviors = require(RootPath .. "/Enums/EnumBehaviorType")
    for _, value in pairs(behaviors) do
        local behavior = value
        local enumPath = string.format("%s/Enums/Enum%sType", RootPath, behavior)
        require(enumPath)
        
        local basePath = string.format("%s/Bases/I%sBase", RootPath, behavior)
        require(basePath)
    end
    
    --data
    local storyBookData = DataManager.GetCityDataByKey(this.cityId, DataKey.StoryBook)
    if storyBookData == nil then
        storyBookData = {}
        storyBookData.waitToExecuteItems = {}
        DataManager.SetCityDataByKey(this.cityId, DataKey.StoryBook, storyBookData)
        DataManager.SaveCityData(this.cityId, true)
    end
    this.storyBookData = storyBookData
end

function StoryBookManager.Clear()
    StoryBookHandleEvents.Clear()
end

function StoryBookManager.AfterAllInit()
    for i, v in pairs(this.storyBookData.waitToExecuteItems) do
        this.TryExecuteItemByRuntimeData(i)
    end
end

---@param dataBase DataBase
---@param runtimeData table
function StoryBookManager.Trigger(dataBase, runtimeData)
    ---@type ITriggerBase cls
    local cls = require(TriggerPath .. dataBase.type)
    if cls then
        local trigger = cls:Create(dataBase)
        trigger:Execute(runtimeData)
    end
end

---@param dataBase DataBase
---@param runtimeData table
function StoryBookManager.Action(dataBase, runtimeData)
    ---@type IActionBase cls
    -- local cls = require(ActionPath .. dataBase.type)
    -- if cls then
    --     local action = cls:Create(dataBase)
    --     action:Execute(runtimeData)
    -- end
end

---@param dataBase DataBase
---@param runtimeData table
function StoryBookManager.Story(dataBase, runtimeData)
    ---@type IStoryBase cls
    local cls = require(StoryPath .. dataBase.type)
    if cls then
        local story = cls:Create(dataBase)
        story:Execute(runtimeData)
    end
end

---@return DataBase
function StoryBookManager.GetDataById(id)
    if id == nil then
        return nil
    end
    return this.dataConf[id]
end 

---@param enumTriggerType EnumTriggerType
---@return table<string, DataBase>
function StoryBookManager.FindTriggerItems(enumTriggerType)
    local result = {}
    for key, value in pairs(this.dataConf) do
        ---@type DataBase data
        local data = value
        if (data.city_id == -1 or data.city_id == this.cityId) and data.behavior == EnumBehaviorType.Trigger and data.type == enumTriggerType then
            result[key] = data
        end
    end
    return result
end

---@param enumTriggerType EnumTriggerType
---@param runtimeData table
function StoryBookManager.TryTrigger(enumTriggerType, runtimeData)
    local triggerItems = this.FindTriggerItems(enumTriggerType)
    for key, value in pairs(triggerItems) do
        if this.Trigger(value, runtimeData) then
            return true
        end
    end

    StoryBookManager.FinishItem(nil, runtimeData)
    return false
end

---@param dataBase DataBase
---@param runtimeData table
function StoryBookManager.ExecuteItem(dataBase, runtimeData)
    if dataBase.behavior == EnumBehaviorType.Trigger then
        this.Trigger(dataBase, runtimeData)
    elseif dataBase.behavior == EnumBehaviorType.Action then
        this.Action(dataBase, runtimeData)
    elseif dataBase.behavior == EnumBehaviorType.Story then
        this.Story(dataBase, runtimeData)
    end
end

---@param saveKey string
---@param dataBase DataBase
---@param runtimeData table
function StoryBookManager.SaveExecuteItem(saveKey, dataBase, runtimeData)
    local executeItem = {}
    executeItem.dataBase = dataBase
    executeItem.runtimeData = runtimeData
    this.storyBookData.waitToExecuteItems[saveKey] = executeItem
    DataManager.SaveCityData(this.cityId)
end

function StoryBookManager.ClearExecuteItem(saveKey)
    this.storyBookData.waitToExecuteItems[saveKey] = nil
end


---@param saveKey string
function StoryBookManager.TryExecuteItemByRuntimeData(saveKey)
    local executeItem = this.storyBookData.waitToExecuteItems[saveKey]
    if executeItem ~= nil then
        this.ExecuteItem(executeItem.dataBase, executeItem.runtimeData)
    end
    DataManager.SaveCityData(this.cityId)
end 

--结束剧情
function StoryBookManager.FinishItem(dataBase, runtimeData)
    if runtimeData == nil then
        return
    end
    if runtimeData.callBack ~= nil and type(runtimeData.callBack) == "function" then
        runtimeData.callBack()
    end
end