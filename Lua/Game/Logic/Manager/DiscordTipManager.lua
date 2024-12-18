DiscordTipManager = {}
DiscordTipManager.__cname = "DiscordTipManager"

local this = DiscordTipManager

function DiscordTipManager.Init()
    EventManager.AddListener(EventType.BATTLE_FINISH_CB, this.BattleFinishedFunc)
    EventManager.AddListener(EventType.TASK_COMPLETE, this.TaskCompleteFunc)
    EventManager.AddListener(EventType.TASK_MILESTONE_REFRESH, this.TaskMilestoneCompleteFunc)
end

function DiscordTipManager.BattleFinishedFunc()
    function IsUsefulCity(id)
        local cityConf = ConfigManager.GetCityById(id)
        return cityConf.is_event == false and cityConf._tags_ ~= "develop"
    end

    function IsPopupCity()
        local cityId = DataManager.GetCityId()
        local cityList = ConfigManager.GetCityIdList()
        local maxCityId = 0
        cityList:ForEach(
            function(id)
                if IsUsefulCity(id) and id > maxCityId then
                    maxCityId = id
                end
            end
        )
        Log("检测最大城市id:" .. maxCityId)
        return cityId == maxCityId
    end

    function HasShown()
        local shownTimes = DataManager.GetGlobalDataByKey(DataKey.DiscordShown)
        return shownTimes ~= nil and shownTimes >= 1
    end

    if IsPopupCity() and not HasShown() then
        local shownTimes = DataManager.GetGlobalDataByKey(DataKey.DiscordShown)
        local newTimes = 1
        if (shownTimes ~= nil) then
            newTimes = shownTimes + 1
        end
        PopupManager.Instance:OpenPanel(PanelType.DiscordTipPanel, { from = DiscordFromType.fightComplete })
        DataManager.SetGlobalDataByKey(DataKey.DiscordShown, newTimes)
    end
end

function DiscordTipManager.TaskCompleteFunc(cityId, taskId)
    function IsAimTask()
        local aimTasks = ConfigManager.GetMiscConfig("mission_discord_popup")
        for index, id in pairs(aimTasks) do
            if tostring(taskId) == tostring(id) then
                return true
            end
        end
        return false
    end

    if IsAimTask() then
        -- PopupManager.Instance:OpenSubPanel(
        --     PopupManager.Instance.currentPanel,
        --     PanelType.DiscordTipPanel,
        --     { from = DiscordFromType.TaskComplete, fromid = taskId }
        -- )
    end
end

function DiscordTipManager.TaskMilestoneCompleteFunc()
    -- if this.IsCompleteDiscordCanShow() then
    --     PopupManager.Instance:LastOpenPanel(
    --         PanelType.DiscordTipPanel,
    --         { from = DiscordFromType.cityComplete }
    --     )
    -- end
end

function DiscordTipManager.IsCompleteDiscordCanShow()
    function IsUsefulCity(id)
        local cityConf = ConfigManager.GetCityById(id)
        return cityConf.is_event == false and cityConf._tags_ ~= "develop"
    end

    function IsPopupCity()
        local cityId = DataManager.GetCityId()
        local cityList = ConfigManager.GetCityIdList()
        local maxCityId = 0
        cityList:ForEach(
            function(id)
                if IsUsefulCity(id) and id > maxCityId then
                    maxCityId = id
                end
            end
        )
        Log("检测最大城市id:" .. maxCityId)
        return cityId == maxCityId
    end

    function IsAllTaskOver()
        local cityId = DataManager.GetCityId()
        local MilestoneStatus = TaskManager.RefreshAndGetTaskMilestoneStatus(cityId)
        return MilestoneStatus == TaskMilestoneStatus.Claimed
    end

    return IsPopupCity() and IsAllTaskOver()
end

function DiscordTipManager.Clear()
    EventManager.RemoveListener(EventType.BATTLE_FINISH_CB, this.BattleFinishedFunc)
    EventManager.RemoveListener(EventType.TASK_COMPLETE, this.TaskCompleteFunc)
    EventManager.RemoveListener(EventType.TASK_MILESTONE_REFRESH, this.TaskMilestoneCompleteFunc)
end
