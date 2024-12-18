FunctionsManager = {}
FunctionsManager._name = "FunctionsManager"

local this = FunctionsManager
local nofirst = false
FunctionsManager.rootPath = "Game.Logic.Model.Functions."

FunctionsManager.Scope = {
    City = "city",
    Global = "global"
}

local function IsFunctionsOpen(cityConfig, functionsConfig)
    --场景功能是否有效
    local function IsInitialFunctions()
        for index, value in pairs(cityConfig.initial_functions) do
            if value == functionsConfig.id then
                return true
            end
        end
        return false
    end
    local isOpen = false
    if this.IsUnlock(functionsConfig.id) then
        if functionsConfig.id == FunctionsType.Map then
            isOpen = true
        elseif cityConfig.id >= functionsConfig.city then
            if functionsConfig.is_read_city_conf then
                isOpen = IsInitialFunctions()
            else
                isOpen = true
            end
        end
    end
    return isOpen
end

--初始化
function FunctionsManager.Init()
    this.cityId = DataManager.GetCityId()

    --场景切换数据处理
    this.functionsUnlockCityData, this.functionsUnlockCityItems = this.InitDataAndItems(this.Scope.City)
    --缓存数据
    this.functionsUnlockData, this.functionsUnlockItems = this.InitDataAndItems(this.Scope.Global)

    if nofirst then
        return
    end
    nofirst = true
    EventManager.AddListener(EventType.COMPLETE_TUTORIAL, this.CompleteTutorialFunc)
    EventManager.AddListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)
    EventManager.AddListener(EventType.TASK_COMPLETE, this.TaskCompleteFunc)
    EventManager.AddListener(EventType.CHARACTER_STATE_CHANGE, this.CharacterStateChangeFunc)
    EventManager.AddListener(EventType.UPGRADE_FURNITURE, this.UpgradeFurnitureFunc)
    EventManager.AddListener(EventType.BATTLE_FINISH_CB, this.BattleFinishCB)
    EventManager.AddListener(EventType.REFRESH_EVENT_MILESTONE, this.RefreshEventMilestoneFunc)
    EventManager.AddListener(EventType.ADD_CARD, this.AddCardFunc)
    EventManager.AddListener(EventType.FUNCTIONS_UNLOCK, this.FunctionsUnlockFunc)
end

---@return table<string, boolean>, table<string, FunctionsBase>
function FunctionsManager.InitDataAndItems(scope)
    local functionsUnlockData
    if scope == this.Scope.City then
        functionsUnlockData = DataManager.GetCityDataByKey(this.cityId, DataKey.FunctionsUnlockData) or {}
    else
        functionsUnlockData = DataManager.GetGlobalDataByKey(DataKey.FunctionsUnlockData) or {}
    end

    local functionsUnlockItems = {}

    for type, config in pairs(ConfigManager.GetFunctionsUnlockConfig()) do
        if (not functionsUnlockData[type] or false) and "" ~= config.unlockLogic and config.scope == scope then
            local cls = require(this.rootPath .. config.unlockLogic)
            if cls then
                functionsUnlockItems[type] = cls:Create(config)
            end
        end
    end

    return functionsUnlockData, functionsUnlockItems
end

function FunctionsManager.InitView()
    local cityConfig = ConfigManager.GetCityById(this.cityId)
    --解锁对象列表
    for type, config in pairs(ConfigManager.GetFunctionsUnlockConfig()) do
        local isOpen = IsFunctionsOpen(cityConfig, config)
        EventManager.Brocast(EventType.FUNCTIONS_OPEN, this.cityId, type, isOpen, false)
    end
    for type, item in pairs(this.functionsUnlockItems) do
        item:Check(this.cityId)
    end
end

---------------------------------
---事件响应
---------------------------------
--完成引导事件响应
function FunctionsManager.CompleteTutorialFunc(cityId, step)
    for type, item in pairs(this.functionsUnlockCityItems) do
        item:Response(EventType.COMPLETE_TUTORIAL, cityId, step)
    end
    for type, item in pairs(this.functionsUnlockItems) do
        item:Response(EventType.COMPLETE_TUTORIAL, cityId, step)
    end
end

--建造区域事件响应
function FunctionsManager.UpgradeZoneFunc(cityId, zoneId, zoneType, level)
    for type, item in pairs(this.functionsUnlockCityItems) do
        item:Response(EventType.UPGRADE_ZONE, cityId, zoneId, zoneType, level)
    end
    for type, item in pairs(this.functionsUnlockItems) do
        item:Response(EventType.UPGRADE_ZONE, cityId, zoneId, zoneType, level)
    end
end

---任务完成事件回调
function FunctionsManager.TaskCompleteFunc(cityId, taskId)
    for type, item in pairs(this.functionsUnlockCityItems) do
        item:Response(EventType.TASK_COMPLETE, cityId, taskId)
    end
    for type, item in pairs(this.functionsUnlockItems) do
        item:Response(EventType.TASK_COMPLETE, cityId, taskId)
    end
end

--角色状态切换回调
function FunctionsManager.CharacterStateChangeFunc(cityId, character, state)
    for type, item in pairs(this.functionsUnlockCityItems) do
        item:Response(EventType.CHARACTER_STATE_CHANGE, cityId, character, state)
    end
    for type, item in pairs(this.functionsUnlockItems) do
        item:Response(EventType.CHARACTER_STATE_CHANGE, cityId, character, state)
    end
end

--建造家具事件响应
function FunctionsManager.UpgradeFurnitureFunc(cityId, zoneId, zoneType, furnitureType, index, level)
    for type, item in pairs(this.functionsUnlockCityItems) do
        item:Response(EventType.UPGRADE_FURNITURE, cityId, zoneId, zoneType, furnitureType, index, level)
    end
    for type, item in pairs(this.functionsUnlockItems) do
        item:Response(EventType.UPGRADE_FURNITURE, cityId, zoneId, zoneType, furnitureType, index, level)
    end
end

--战斗完成时间相应
function FunctionsManager.BattleFinishCB(cityId, level)
    for type, item in pairs(this.functionsUnlockCityItems) do
        item:Response(EventType.BATTLE_FINISH_CB, cityId, level)
    end
    for type, item in pairs(this.functionsUnlockItems) do
        item:Response(EventType.BATTLE_FINISH_CB, cityId, level)
    end
end

--活动场景milestone完成相应
function FunctionsManager.RefreshEventMilestoneFunc(cityId)
    for type, item in pairs(this.functionsUnlockCityItems) do
        item:Response(EventType.REFRESH_EVENT_MILESTONE, cityId, step)
    end
    for type, item in pairs(this.functionsUnlockItems) do
        item:Response(EventType.REFRESH_EVENT_MILESTONE, cityId)
    end
end

function FunctionsManager.AddCardFunc(cityId, cardId)
    for type, item in pairs(this.functionsUnlockCityItems) do
        item:Response(EventType.ADD_CARD, cityId, step)
    end
    for type, item in pairs(this.functionsUnlockItems) do
        item:Response(EventType.ADD_CARD, cityId, cardId)
    end
end

--功能解锁事件回调
function FunctionsManager.FunctionsUnlockFunc(functionsType)
    local funcUnlock = this.functionsUnlockItems[functionsType] or this.functionsUnlockCityItems[functionsType]
    if funcUnlock == nil then
        print("[error]" .. "not found functionsUnlock: " .. functionsType)
        return
    end

    local config = funcUnlock.config

    if config.scope == this.Scope.City then
        this.functionsUnlockCityData[functionsType] = true
        DataManager.SetCityDataByKey(this.cityId, DataKey.FunctionsUnlockData, this.functionsUnlockCityData)
    else
        this.functionsUnlockData[functionsType] = true
        DataManager.SetGlobalDataByKey(DataKey.FunctionsUnlockData, this.functionsUnlockData)
    end

    this.functionsUnlockItems[functionsType] = nil

    local isOpen = this.cityId >= config.city
    local isEffect = this.cityId == config.city and config.is_highlight
    EventManager.Brocast(EventType.FUNCTIONS_OPEN, this.cityId, functionsType, isOpen, isEffect)
end

---------------------------------
---方法响应
---------------------------------
--是否功能解锁
function FunctionsManager.IsUnlock(functionsType)
    return (this.functionsUnlockData[functionsType] or false) or (this.functionsUnlockCityData[functionsType] or false)
end

--解锁全部功能呢
function FunctionsManager.UnlockAll()
    for type, item in pairs(this.functionsUnlockItems) do
        item:Unlock()
    end
    --强制
    this.UnlockFunction(FunctionsType.Fight)
end

--功能是否开启
function FunctionsManager.IsOpen(cityId, functionsType)
    local cityConfig = ConfigManager.GetCityById(cityId)
    local functionsConfig = ConfigManager.GetFunctionsUnlockConfigByType(functionsType)
    if functionsConfig == nil then
        return false
    end

    return IsFunctionsOpen(cityConfig, functionsConfig)
end

--解锁功能
function FunctionsManager.UnlockFunction(functionsType)
    if this.IsUnlock(functionsType) then
        return
    end
    this.FunctionsUnlockFunc(functionsType)
end
