---@class CityTask
CityTask = Clone(CityBase)
CityTask.__cname = "CityTask"

local rootPath = "Game/Logic/Model/Task/"

--排序任务
local function SortTask(t1, t2)
    local index1 = t1.taskConfig.index
    local index2 = t2.taskConfig.index
    if index1 == index2 then
        return false
    end
    return index1 < index2
end

CityTask.MaxGroup = 4

--初始化
function CityTask:OnInit()
    self:InitMilestone()
    self.notAcceptTaskCountRx = NumberRx:New(0)
    self.allTaskCompleteRx = NumberRx:New(0)
    
    self.showTaskCompletedToast = true
end

--刷新任务
function CityTask:OnInitView()
    self:CheckAllAvailableTask()
    
    self:RefreshNotAcceptTaskCount()
end

--清理
function CityTask:OnClear()
    self = nil
end

function CityTask:CheckAllAvailableTask()
    local taskList = self:GetAvailableTaskList()
    taskList:ForEach(
        function(task)
            task:Check()
        end
    )
end
---------------------------------
---事件响应
---------------------------------
--事件响应
function CityTask:EventResponse(eventType, ...)
    local taskList = self:GetAvailableTaskList()
    for i = 1, taskList:Count() do
        if taskList[i]:GetTaskStatus() == TaskStatus.Unfinished then
            taskList[i]:Response(eventType, ...)
        end
    end

    self:RefreshNotAcceptTaskCount()
    DataManager.SetCityDataByKey(self.cityId, DataKey.TaskData, self.taskCache)
end

--任务完成事件响应
function CityTask:TaskFinishFunc()
    if self.showTaskCompletedToast and not GameManager.LoadStart then
        self:ShowTaskToast(GetLang("ui_task_done"),ToastIconType.Complete)
        Audio.PlayAudio(DefaultAudioID.RcvTaskTipe)
    end
    
    self:RefreshNotAcceptTaskCount()
    EventManager.Brocast(EventType.TASK_REFRESH, self.cityId)
end

--任务完毕事件响应
function CityTask:TaskCompleteFunc(taskId)
    local config = ConfigManager.GetTaskConfig(taskId)
    local removeTask = nil
    ---@param task TaskBase
    self.taskGroupList[config.group + 1]:RemoveOne(
        function(task)
            return tonumber(task.taskConfig.id) == tonumber(taskId)
        end
    )
    
    self:CheckAllAvailableTask()
    self:RefreshNotAcceptTaskCount()
    EventManager.Brocast(EventType.TASK_REFRESH, self.cityId)
end

--任务章节事件响应
function CityTask:TaskMilestoneCompleteFunc()
    self:InitMilestone()
    self:CheckAllAvailableTask()
    self:RefreshNotAcceptTaskCount()
end

function CityTask:InitMilestone()
    self.partId = DataManager.GetCityDataByKey(self.cityId, DataKey.PartId)
    
    -- 未知原因导致partId是空，增加容错
    if self.partId == nil then
        self.partId = 1
        DataManager.SetCityDataByKey(self.cityId, DataKey.PartId, self.partId)
    end
    
    self.taskMilestoneConfig = ConfigManager.GetTaskMilestoneConfig(self.cityId, self.partId)
    if self.taskMilestoneConfig == nil then
        self:Reset(self.cityId, self.partId)
        DataManager.SetCityDataByKey(self.cityId, DataKey.PartId, self.partId)
    else
        --读取数据
        self.taskCache = DataManager.GetCityDataByKey(self.cityId, DataKey.TaskData) or {}
        if self.taskCache.partId ~= self.partId or not self.taskCache.tasks or next(self.taskCache.tasks) == nil then 
            print("[CityTask]", self.taskCache.partId, self.partId)
            if Application.isEditor then 
                DataManager.ToLog()
            end
        end
        
        if self.taskCache.partId ~= self.partId then
            self.taskCache = self:CreateTaskCache(self.partId)
        end
    end
    
    self:CheckCache(self.partId)
    --初始化任务数据对象
    ---@type TaskBase[][]
    self.taskGroupList = List:New()
    
    -- 支持4组,0,1,2,3
    for i = 1, CityTask.MaxGroup do
        self.taskGroupList:Add(List:New())
    end
    
    for id, value in pairs(self.taskCache.tasks) do
        if value.status ~= TaskStatus.Completed then
            local taskConfig = ConfigManager.GetTaskConfig(id)
            if taskConfig then
                local taskTypeConfig = ConfigManager.GetTaskTypeConfig(taskConfig.action)
                local cls = require(rootPath .. taskTypeConfig.logicName)
                if cls then
                    local taskId = id
                    local saveCacheFunc = function(cache)
                        self.taskCache.tasks[taskId] = cache
                        DataManager.SaveCityData(self.cityId)
                    end
                    self.taskGroupList[taskConfig.group + 1]:Add(cls:Create(self.cityId, id, value, taskConfig, taskTypeConfig, saveCacheFunc))
                end
            else
                self.taskCache.tasks[id] = nil
            end
        end
    end
    
    for i = 1, CityTask.MaxGroup do
        self.taskGroupList[i]:Sort(SortTask)
    end
    
    DataManager.SetCityDataByKey(self.cityId, DataKey.TaskData, self.taskCache)
end

--创建任务缓存数据
function CityTask:CreateTaskCache(partId)
    local taskConfigs = ConfigManager.GetTaskConfigList(partId)
    local cache = {}
    cache.partId = partId
    cache.partComplete = false
    cache.partReward = false
    cache.tasks = {}
    for id, value in pairs(taskConfigs) do
        if value.isAvailable == 1 then
            cache.tasks[id] = {status = TaskStatus.Inactive}
        end
    end
    DataManager.SetCityDataByKey(self.cityId, DataKey.TaskData, cache)
    return cache
end

function CityTask:BuildCheatTaskCache(partId, taskId)
    local taskConfigs = ConfigManager.GetTaskConfigList(partId)
    local cache = {}
    cache.partId = partId
    cache.partComplete = false
    cache.partReward = false
    cache.tasks = {}
    for id, value in pairs(taskConfigs) do
        if value.isAvailable == 1 then
            if value.index <= taskId then
                cache.tasks[id] = {status = TaskStatus.Completed}
            else
                cache.tasks[id] = {status = TaskStatus.Inactive}
            end
        end
    end
    DataManager.SetCityDataByKey(self.cityId, DataKey.TaskData, cache)
    return cache
end

function CityTask:CheckCache(partId)
    local taskConfigs = ConfigManager.GetTaskConfigList(partId)

    for id, value in pairs(taskConfigs) do
        if value.isAvailable == 1 then
            local task = self.taskCache.tasks[id]
            -- 如果没找到，那么就添加这个任务
            if task == nil then
                print("[CityTask] add task")
                self.taskCache.tasks[id] = {status = TaskStatus.Inactive}
            end
        end
    end

    -- 反查，是否存在cache中的数据，没有config数据
    for id, value in pairs(self.taskCache.tasks) do
        local task = taskConfigs[id]
        if task == nil then
            self.taskCache.tasks[id] = nil
        end
    end
end

--章节任务是否完成
function CityTask:IsTaskMilestoneFinished()
    return self.taskCache.partReward
end

--获取任务章节奖励
function CityTask:GainTaskMilestoneReward()
    local rewards = Utils.ParseReward(self.taskMilestoneConfig.rewards)
    local result = DataManager.AddReward(self.cityId, rewards, "TaskMilestone", "id" .. self.taskMilestoneConfig.id)
    self.taskCache.partReward = true
    DataManager.SaveCityData(self.cityId)
    
    -- 未知原因导致partId是空，增加容错
    if self.partId == nil then
        self.partId = 1
    end
    
    local newPartId = self.partId + 1
    local newTaskMilestoneConfig = ConfigManager.GetTaskMilestoneConfig(self.cityId, newPartId)
    if newTaskMilestoneConfig then
        DataManager.SetCityDataByKey(self.cityId, DataKey.PartId, newPartId)
    end
    TaskManager.TgaEvent("CollectTaskReward", {type = "milestone", taskGroup = -1})
    -- AudioManager.PlayEffect("ui_reward_click")
    EventManager.Brocast(EventType.TASK_MILESTONE_REFRESH, self.cityId, self.taskMilestoneConfig)
    
    return result
end

--获取任务章节进度
function CityTask:GetTaskMilestoneProgress()
    local ret = 0
    local maxCount = self:GetPartMaxCount(self.partId)
    local cacheCount = 0
    for id, value in pairs(self.taskCache.tasks) do
        cacheCount = cacheCount + 1
        if value.status == TaskStatus.Completed then
            ret = ret + 1
        end
    end
    if ret > maxCount then
        ret = maxCount
    end
    
    return ret, maxCount
end

--获取当前场景总的章节进度
function CityTask:GetSceneTaskProgress()
    local total = ConfigManager.GetTaskMilestoneList(self.cityId):Count()
    local count = 0
    if self:IsTaskMilestoneFinished() then
        count = self.partId
    else
        count = self.partId - 1
    end
    return count, total
end

--获取任务章节状态
---@return number
function CityTask:RefreshAndGetTaskMilestoneStatus()
    if self:IsTaskMilestoneFinished() then
        return TaskMilestoneStatus.Claimed
    end
    local count, total = self:GetTaskMilestoneProgress()
    if count < total then
        return TaskMilestoneStatus.NoFinished
    end
    if not self.taskCache.partComplete then
        self.taskCache.partComplete = true
        DataManager.SaveCityData(self.cityId)
        TaskManager.TgaEvent("TaskComplete", {type = "milestone"})
    end
    return TaskMilestoneStatus.Finished
end

function CityTask:GetNotAcceptTaskCount()
    local ret = 0
    local taskList = self:GetAvailableTaskList()
    ---@param task TaskBase
    taskList:ForEach(
        function(task)
            if task:GetTaskStatus() == TaskStatus.NotAccept then
                ret = ret + 1
            end
        end
    )
    
    --章节任务完成了
    local milestoneStatus = self:RefreshAndGetTaskMilestoneStatus()
    if milestoneStatus == TaskMilestoneStatus.Finished then
        ret = ret + 1
    end
    
    local allTask = 0
    --所有章节任务都完成了
    local mtCount, mtTotal = self:GetSceneTaskProgress()
    if mtCount == mtTotal and milestoneStatus == TaskMilestoneStatus.Claimed then
        allTask = 1
    else
        allTask = 0
    end
    
    return ret, allTask
end

-- 获取availableTaskCount数量以内的没有获取奖励的任务数量
function CityTask:RefreshNotAcceptTaskCount(force)
    local notAcceptTaskCount, allTaskComplete = self:GetNotAcceptTaskCount()
    
    -- 避免值相同的时候，再刷新
    if force or notAcceptTaskCount ~= self.notAcceptTaskCountRx.value then
        self.notAcceptTaskCountRx.value = notAcceptTaskCount
    end
    
    if force or allTaskComplete ~= self.allTaskCompleteRx.value then
        if self.cityId >= ConfigManager.GetCityCount() then
            self.allTaskCompleteRx.value = 0
        else
            self.allTaskCompleteRx.value = allTaskComplete
        end
    end
end

function CityTask:GetTaskById(taskId)
    local config = ConfigManager.GetTaskConfig(taskId)
    local rt = nil
    self.taskGroupList[config.group + 1]:ForEach(
        function(item)
            if item:GetTaskId() == taskId then
                rt = item
                return true
            end
        end
    )

    return rt
end

function CityTask:GetTaskForMainUITip()
    local taskList = self:GetAvailableTaskList()
    local rtTask = nil
    
    taskList:ForEach(
        function(task)
            if task:GetTaskStatus() == TaskStatus.NotAccept then
                -- 有完成的就用完成的
                rtTask = task
                return true
            end
        
            if rtTask == nil and task:GetTaskStatus() == TaskStatus.Unfinished then
                rtTask = task
            end
        end
    )
    return rtTask
end

function CityTask:GetCacheTaskState(id)
    local data = self.taskCache.tasks[id]
    if data == nil then
        return TaskStatus.Inactive
    end
    
    return data.status
end

---是否是普通task配置
function CityTask:IsNormalGroup()
    --当第一组存在配置，就认为这是一个普通task配置，所有任务只从第一组中读取
    return self.taskGroupList[1]:Count() > 0
end

---返回可用的任务列表
---@return TaskBase[]
function CityTask:GetAvailableTaskList()
    local taskList = List:New()
    
    local group = 0
    if self:IsNormalGroup() then
        for i = 1, self.taskMilestoneConfig.availableTaskCount do
            local task = self:GetTaskByGroup(group, i)
            if task ~= nil then
                taskList:Add(task)
                self:ActiveTask(task)
            end
        end
    else
        for i = 1, self.taskMilestoneConfig.availableTaskCount do
            local task = self:GetTaskByGroup(i, 1)
            if task ~= nil then
                taskList:Add(task)
                self:ActiveTask(task)
            end
        end
        
        --当其中1组任务都完成时，从其他组中拿取
        local needSupplementary = self.taskMilestoneConfig.availableTaskCount - taskList:Count()
        for i = 1, needSupplementary do
            local foundTask
            for g = 1, self.taskMilestoneConfig.availableTaskCount do
                local taskCount = self:GetTaskGroupCount(g)
                for t = 1, taskCount do
                    local task = self:GetTaskByGroup(g, t)
                    if task ~= nil then
                        --查找这个任务是否是已经选取的任务
                        ---@param val TaskBase
                        local findIdx = taskList:FindIndex(
                            function(val)
                                return val.taskConfig.id == task.taskConfig.id
                            end
                        )
    
                        if findIdx == -1 then
                            foundTask = task
                            break
                        end
                    end
                end
    
                if foundTask ~= nil then
                    break
                end
            end
    
            if foundTask ~= nil then
                taskList:Add(foundTask)
                self:ActiveTask(foundTask)
            end
        end
    end
    
    ---@param a TaskBase
    ---@param b TaskBase
    taskList:Sort(
        function(a, b)
            if a.taskConfig.group == b.taskConfig.group then
                return a.taskConfig.index < b.taskConfig.index
            end
            
            return a.taskConfig.group < b.taskConfig.group
        end
    )
    
    return taskList
end

---@return TaskBase
function CityTask:GetTaskByGroup(group, idx)
    local groupList = self.taskGroupList[group + 1]
    
    return groupList[idx]
end

function CityTask:GetTaskGroupCount(group)
    return self.taskGroupList[group + 1]:Count()
end

function CityTask:ActiveTask(task)
    if task:GetTaskStatus() == TaskStatus.Inactive then
        task:ActiveTask()
    end
end

--完成当前章节所有任务
function CityTask:DebugFinishAllTask()
    --由于最后一个任务是自动领取章节任务，所以这里总是保留一个任务未领取
    ---@type TaskBase
    local task = nil
    for i = self.taskGroupList:Count(), 1, -1 do
        local groupTask = self.taskGroupList[i]
        for j = groupTask:Count(), 1, -1 do
            if task == nil then
                task = groupTask[j]
                task:SetTaskStatus(TaskStatus.NotAccept)
            else
                groupTask[j]:SetTaskStatus(TaskStatus.Completed)
                groupTask:RemoveAt(j)
            end
        end
    end

    DataManager.SaveCityData(self.cityId)
    
    self:RefreshNotAcceptTaskCount()
end

--跳到最后一个章节任务，并且完成所有任务
function CityTask:DebugFinishAllMilestone()
    -- 获取最后一个章节id
    local LastPartId = ConfigManager.GetTaskMilestoneList(self.cityId):Count()
    DataManager.SetCityDataByKey(self.cityId, DataKey.PartId, LastPartId)
    self:InitMilestone()
    self:DebugFinishAllTask()
end

function CityTask:SetShowTaskCompletedToast(show)
    self.showTaskCompletedToast = show
end

function CityTask:GetPartMaxCount(partId)
    local taskConfigs = ConfigManager.GetTaskConfigList(partId)
    return taskConfigs:Count()
end

function CityTask:Reset(cityId, partId)
    print("[CityTask] Reset: ", cityId, partId, debug.traceback())
    local selectedTaskMilestoneConfig, selectedPartId
    for i = partId, 1, -1 do
        selectedTaskMilestoneConfig = ConfigManager.GetTaskMilestoneConfig(cityId, i)
        if selectedTaskMilestoneConfig ~= nil then
            selectedPartId = i
            break
        end
    end
    
    if selectedTaskMilestoneConfig == nil then
        print("[error]" .. "not found partId, cityId: " .. cityId)
        return
    end
    
    print("[error]" .. "part lost and reset success, cityId: " .. cityId)
    self.taskMilestoneConfig = selectedTaskMilestoneConfig
    self.taskCache = self:CreateTaskCache(selectedPartId)
    self.partId = selectedPartId
end
