TutorialManager = {}
TutorialManager.__cname = "TutorialManager"

--矿工
TutorialManager.KeanuCardId = 19
TutorialManager.KeanuCardName = "card_19_name"
--医生
TutorialManager.MedicalCardId = 9
TutorialManager.MedicalCardName = "card_9_name"

-- 是否正在在打开首充界面(只有引导会用到这个标记，因为将它放在这里)
TutorialManager.isOpeningUIFirstCharge = false
-- 是否正在在打开英雄宝箱界面
TutorialManager.isOpeningUIOpenBox = false
-- 是否在离线收益界面，如果在，则不能打开引导
TutorialManager.isOpeningUIOffline = false


local this = TutorialManager
local nofirst = false
local rootPath = "Game/Logic/Model/Tutorial/"

function TutorialManager.Init()
    this.cityId = DataManager.GetCityId()
    this.tutorialData = DataManager.GetGlobalDataByKey(DataKey.TutorialData)
    this.tutorialData.subStep = 1
    this.CurrentStep = NumberRx:New(this.tutorialData.step)
    this.CurrentSubStep = NumberRx:New(this.tutorialData.subStep)
    this.StopTime = NumberRx:New(false)
    if nofirst then
        return
    end
    nofirst = true
    EventManager.AddListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)
    EventManager.AddListener(EventType.UPGRADE_FURNITURE, this.UpgradeFurnitureFunc)
    EventManager.AddListener(EventType.TIME_CITY_UPDATE, this.TimeCityUpdateFunc)
    EventManager.AddListener(EventType.ALL_PANEL_CLOSE, this.AllPanelCloseFunc)
    EventManager.AddListener(EventType.FUNCTIONS_UNLOCK, this.FunctionsUnlockFunc)
    EventManager.AddListener(EventType.FACTORY_GAME_BUILD_FIRST, this.FoctoryGameBuildFirst) -- 工厂游戏机
    EventManager.Brocast(EventType.TUTORIAL_INIT)
end

---------------------------------
---事件响应
---------------------------------
function TutorialManager.UpgradeZoneFunc(cityId, zoneId, zoneType, level)
    if this.cityId ~= cityId then
        return
    end
end

function TutorialManager.UpgradeFurnitureFunc(cityId, zoneId, zoneType, furnitureType, index, level)
end

--时间刷新
function TutorialManager.TimeCityUpdateFunc(cityId)
    -- 如果此时引导界面还没有加载完成，则会后错
    if this.cityId ~= cityId or UIGuidePanel.gameObject == nil then
        return
    end
    local cityDay = TimeManager.GetCityDay(this.cityId)
    local cityHour = TimeManager.GetCityClockHour(this.cityId)
    local cityClock = TimeManager.GetCityClock(this.cityId)
    local isNight = TimeManager.GetCityIsNight(this.cityId)
    --当前引导检测
    if this.currentTutorial then
        this.currentTutorial:CheckStopTime(cityDay, cityClock)
    elseif this.cityId == 1 and 0 <= cityHour and cityHour < 4 then
        if not this.IsComplete(TutorialStep.NightTalk) then
            this.TriggerTutorial(TutorialStep.NightTalk)
        end
    elseif isNight then
        if not this.IsComplete(TutorialStep.OverloadOpen) then
            this.TriggerTutorial(TutorialStep.OverloadOpen)
        end
    elseif not isNight and cityDay >= 2 then
        if not this.IsComplete(TutorialStep.OverloadClose) then
            this.TriggerTutorial(TutorialStep.OverloadClose)
        end
    end
end

function TutorialManager.AllPanelCloseFunc()
    if TutorialManager.isOpeningUIFirstCharge == false and TutorialManager.isOpeningUIOpenBox == false and TutorialManager.isOpeningUIOffline == false then 
        this.CheckTutorial()
    end
end

function TutorialManager.FunctionsUnlockFunc(functionsType)
    local config = ConfigManager.GetFunctionsUnlockConfigByType(functionsType)
    if config == nil or this.cityId ~= config.city then
        return
    end

    if functionsType == FunctionsType.SurvivorSick and this.IsNeverTrigger(TutorialStep.SurvivorSick) then
        this.TriggerTutorial(TutorialStep.SurvivorSick)
        return
    end
end

function TutorialManager.FoctoryGameBuildFirst()

end

---------------------------------
---方法响应
---------------------------------
--保存教程步骤
function TutorialManager.SaveTutorial(step, subStep, forceSave)
    this.CurrentStep.value = step
    this.CurrentSubStep.value = subStep
    if forceSave then
        this.tutorialData.step = step
        this.tutorialData.subStep = subStep
        DataManager.SetGlobalDataByKey(DataKey.TutorialData, this.tutorialData)
        CardManager.SaveCardData()
        DataManager.SaveCityData(this.cityId, forceSave)
        DataManager.SaveGlobalData(true)
        DataManager.ForceSaveServer()
    end
end

--设置引导队列
function TutorialManager.SetTutorialQueues(step)
    for index, value in ipairs(this.tutorialData.queues) do
        if value == step then
            return
        end
    end
    table.insert(this.tutorialData.queues, step)
    DataManager.SetGlobalDataByKey(DataKey.TutorialData, this.tutorialData)
    DataManager.SaveCityData(this.cityId)
    DataManager.SaveGlobalData(true)
    DataManager.ForceSaveServer()
end

--获取引导队列
function TutorialManager.GetTutorialQueues()
    for index, step in ipairs(this.tutorialData.queues) do
        if step ~= -1 then
            local config = ConfigManager.GetTutorialTypeConfigById(step)
            if config.cityId == -1 then
                return true, step, index
            end
            if config.cityId == this.cityId then
                return true, step, index
            end
        end
    end
    return false
end

function TutorialManager.CanTriggerTutorial(step)
    local config = ConfigManager.GetTutorialTypeConfigById(step)
    return config.cityId == this.cityId
end

--触发教程引导
function TutorialManager.TriggerTutorial(step)
    local config = ConfigManager.GetTutorialTypeConfigById(step)
    if config.cityId ~= -1 and config.cityId ~= this.cityId then
        return
    end
    if config.ignore then
        return
    end
    if GameManager.TutorialOpen or GameManager.OfflineAction.value == GameAction.OfflineShow or not CheckAllPanelClose()
    then
        this.SetTutorialQueues(step)
        if step == TutorialStep.ToHalo then
            local ret, step, index = this.GetTutorialQueues()
            if ret then
                table.remove(this.tutorialData.queues, index)
                this.OpenTutorial(step, 1, true)
            end
        end
    else
        this.OpenTutorial(step, 1, true)
    end
end

--是否有引导
function TutorialManager.IsExistTutorial()
    if this.tutorialData.step ~= -1 then
        return true
    elseif #this.tutorialData.queues > 1 then
        local ret, step, index = this.GetTutorialQueues()
        if ret then
            return true
        end
    end
end

--开始教程引导
function TutorialManager.OpenTutorial(step, subStep, forceSave)
    if this.IsComplete(step) then
        return
    end

    this.SaveTutorial(step, subStep, forceSave)
    local config = ConfigManager.GetTutorialTypeConfigById(step)
    if not config then
        return
    end

    -- 重复进引导
    if this.step and this.step == step then
        return
    end

    this.step = step

    if config.ignore then
        return
    end

    local cls = require(rootPath .. config.logicName)
    if cls then
        GameManager.TutorialOpen = true
        ---@type TutorialBase
        this.currentTutorial = cls:Create()

        -- 强制关闭其他界面
        UIUtil.CloseAllPanelOutBy()
        
        this.currentTutorial:Init(this.cityId, step, subStep, config)
    end
end

-- 检测引导是否需要暂停
function TutorialManager.CheckTutorialNeedStop()
    local config = ConfigManager.GetTutorialTypeConfigById(this.CurrentStep.value)
    if not config then
        return
    end
    if config.ignore then
        return
    end
    local cls = require(rootPath .. config.logicName)
    if cls then
        local cityDay = TimeManager.GetCityDay(this.cityId)
        local cityClock = TimeManager.GetCityClock(this.cityId)
        local currentTutorial = cls:Create()
        currentTutorial:Init(this.cityId, this.CurrentStep.value, this.tutorialData.subStep, config, true)
        currentTutorial:CheckStopTime(cityDay, cityClock)
    end
end

--检测引导队列
function TutorialManager.CheckTutorial()
    -- 检查新手界面是否打开
    if not IsUIVisible(UINames.UIGuide) then
        return
    end

    local cityCtrl = CityModule.getMainCtrl()
    if cityCtrl == nil then 
        return 
    end

    if table.size(cityCtrl.buildDict) < 1 then
        return
    end

    if GameManager.TutorialOpen then
        return
    end
    
    if this.tutorialData.step == 15 then
        --if SceneSystem.currentSceneSystem ~= ECS.initBattleSceneSystem then
            return
        --end
    end

    local checkFunc = function(step)
        local config = ConfigManager.GetTutorialTypeConfigById(step)
        if config == nil then
            return false
        end
        if config.cityId ~= -1 and config.cityId ~= this.cityId then
            return false
        end
        return true
    end
    if this.tutorialData.step == TutorialStep.FactoryGame then
        if FactoryGameData.IsUnlock() and not FactoryGameData.IsBuildComplete() then
            this.OpenTutorial(this.tutorialData.step, this.tutorialData.subStep, true)
        end
    elseif this.tutorialData.step ~= -1 then
        if not checkFunc(this.tutorialData.step) then
            return
        end
        this.OpenTutorial(this.tutorialData.step, this.tutorialData.subStep, true)
    elseif #this.tutorialData.queues > 1 then
        local ret, step, index = this.GetTutorialQueues()
        if not checkFunc(step) then
            return
        end
        if ret then
            table.remove(this.tutorialData.queues, index)
            this.OpenTutorial(step, 1, true)
        end
    end
end

--设置下一步教程
function TutorialManager.NextSubStep(delay, forceSave)
    if this.currentTutorial then
        this.currentTutorial:NextSubStep(delay, forceSave)
    end
end

--跳转引导下一步
function TutorialManager.JumpSubStep(subStep, forceSave)
    if this.currentTutorial then
        this.currentTutorial:JumpSubStep(subStep, forceSave)
    end
end

--完成教程引导
function TutorialManager.CompleteTutorial(id)
    this.tutorialData.completes["tutorial_" .. id] = true
    EventManager.Brocast(EventType.COMPLETE_TUTORIAL, this.cityId, id)
end

--教程是否完成
function TutorialManager.IsComplete(step)
    return this.tutorialData.completes["tutorial_" .. step] or false
end

function TutorialManager.GetCurrnetTutorialstep()
    return this.tutorialData.step
end

--从未触发过引导
function TutorialManager.IsNeverTrigger(step)
    --已经完成
    if this.IsComplete(step) then
        return false
    end
    --正在触发中
    if this.CurrentStep.value == step then
        return false
    end
    --准备队列中
    for index, queueStep in ipairs(this.tutorialData.queues) do
        if queueStep == step then
            return false
        end
    end

    return true
end

--结束教程引导
function TutorialManager.CloseTutorial()
    GameManager.TutorialOpen = false
    this.SaveTutorial(-1, -1, true)
    this.currentTutorial = nil
    this.CheckTutorial()
end

--跳过引导
function TutorialManager.SkipTutorial()
    if TutorialManager.IsExistTutorial() then
        this.TryCloseFreezeEffect()
        DataManager.SetGlobalDataByKey(DataKey.NewUser, false)
        for id, config in pairs(ConfigManager.GetTutorialTypeConfigs()) do
            if config.cityId == this.cityId then
                this.CompleteTutorial(id)
            end
        end
    end
    this.CloseTutorial()
end

--是否限制保存
function TutorialManager.NeedLimitSave()
    if this.currentTutorial then
        return this.currentTutorial:NeedLimitSave()
    end
    return false
end

function TutorialManager.TryAddFreezeEffect()
    if this.cityId == 1 then
        -- CameraEffectManager.OnSetFreeze(1, 2)
        CityModule.getMainCtrl().camera:DoCameraSize(-55, 2, 1)
        this.tutorialData.firstFreeze = true
    end
end

function TutorialManager.TryCloseFreezeEffect()
    if this.tutorialData.firstFreeze then
        -- CameraEffectManager.OnSetFreeze(0, 2)
        CityModule.getMainCtrl().camera:zoomRecover()
        this.tutorialData.firstFreeze = false
    end
end

---@return table
function TutorialManager.GetCardGuideData()
    local cardData = DataManager.GetGlobalDataByKey(DataKey.CardData)
    if cardData.guideData == nil then
        cardData.guideData = {}
    end
    return cardData.guideData
end
