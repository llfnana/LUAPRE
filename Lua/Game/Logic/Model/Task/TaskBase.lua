---@class TaskBase
TaskBase = {}
TaskBase.__cname = "TaskBase"

---@class TaskCache
---@field count string
---@field status number
---@field maxCount string
---@field type string
---@field rewards Reward[]

--创建任务
---@param taskConfig Task
---@param taskTypeConfig TaskType
---@param saveCacheFunc fun(cache: TaskCache)
---@return TaskBase
function TaskBase:Create(cityId, taskId, taskCache, taskConfig, taskTypeConfig, saveCacheFunc)
    local cls = Clone(self)

    cls:Init(cityId, taskId, taskCache, taskConfig, taskTypeConfig, saveCacheFunc)
    return cls
end

--任务初始化123
---@param taskCache TaskCache
---@param taskConfig Task
---@param taskTypeConfig TaskType
---@param saveCacheFunc fun(cache: TaskCache)
function TaskBase:Init(cityId, taskId, taskCache, taskConfig, taskTypeConfig, saveCacheFunc)
    if self.initialized then
        return
    end

    self.cityId = cityId
    self.taskId = taskId
    self.taskCache = taskCache
    self.taskConfig = taskConfig
    self.taskTypeConfig = taskTypeConfig
    self.saveCacheFunc = saveCacheFunc

    self.initialized = true
    self.taskMaxCount = tonumber(self.taskConfig.task["count"] or 0)
    self.taskCurrCount = 0
    self.taskActiveTS = 0

    --初始化cache中的type
    self:InitCacheTaskType()

    --如果任务还未完成，并且配表中的类型和cache中不一样
    if self:GetTaskStatus() <= TaskStatus.Unfinished and self:GetCacheTaskType() ~= self.taskConfig.action then
        self:Reset()
    end
    --具体任务解析
    self:OnInit()
end

function TaskBase:GetTaskId()
    return self.taskId
end

--事件响应
function TaskBase:Response(eventType, ...)
    if self:GetTaskStatus() ~= TaskStatus.Unfinished then
        return
    end
    if self.taskTypeConfig.eventType ~= eventType then
        return
    end

    if self:OnResponse(...) then
        self:Check()
    end
end

--任务检测
function TaskBase:Check()
    local taskStatus = self:GetTaskStatus()
    if taskStatus == TaskStatus.Inactive or taskStatus == TaskStatus.Completed then
        return
    end

    --缓存中的任务如果变更,立马完成
    if self.taskConfig.isAvailable == 0 then
        self.taskCurrCount = self.taskMaxCount
    else
        local preCurrCount = self.taskCurrCount
        self:OnCheck()

        -- changed
        if preCurrCount ~= self.taskCurrCount then
            EventManager.Brocast(EventType.TASK_CHANGE, self.cityId, self.taskId, preCurrCount, self.taskCurrCount)
        end
    end
    -- unfinished
    if self.taskCurrCount < self.taskMaxCount then
        return
    end
    if taskStatus == TaskStatus.Unfinished then
        self:SetTaskStatus(TaskStatus.NotAccept)
        TaskManager.TgaEvent(
            "TaskComplete",
            {taskId = self.taskId, type = "normal", taskGroup = self.taskConfig.group, stage = self.taskConfig.stage}
        )
        EventManager.Brocast(EventType.TASK_FINISH, self.cityId, self.taskId)
        -- AudioManager.PlayEffect("ui_task_completed")
    end
end

function TaskBase:Reset()
    print("[error]" .. "task reset:" .. self.taskConfig.id)
    self.taskCache = {
        status = 1,
        type = self.taskConfig.action
    }
    self.saveCacheFunc(self.taskCache)
end

--设置任务激活
function TaskBase:ActiveTask()
    if self:GetTaskStatus() == TaskStatus.Inactive then
        self.taskActiveTS = GameManager.GameTime()
        self:OnActive()
        self:SetTaskStatus(TaskStatus.Unfinished)
    end

    -- 初始化奖励，奖励数据可能随时丢失，表也会修改，所以在这里每次登陆都会重新初始化一次
    -- 不能放到Init中，因为task初始化比较早，统计manager还没有初始化
    self:InitRewards()
    self:Check()
end

--获取任务状态
function TaskBase:GetTaskStatus()
    return self.taskCache.status
end

--设置任务状态
function TaskBase:SetTaskStatus(status)
    if self.taskCache.status == status then
        return
    end
    self.taskCache.status = status
    self.saveCacheFunc(self.taskCache)

    EventManager.Brocast(EventType.TASK_STATUS_REFRESH, self.cityId, self.taskId, status)
end

function TaskBase:GetType()
    return self.taskTypeConfig.id
end

--获取任务奖励
function TaskBase:GainTaskReward()
    if self:GetTaskStatus() ~= TaskStatus.NotAccept then
        return
    end
    local rewards = self:GetRewards()
    local results = DataManager.AddReward(self.cityId, rewards, "TaskId", "id" .. self.taskId)

    self:SetTaskStatus(TaskStatus.Completed)
    TaskManager.TgaEvent(
        "CollectTaskReward",
        {taskId = self.taskId, type = "normal", taskGroup = self.taskConfig.group, stage = self.taskConfig.stage}
    )
    -- AudioManager.PlayEffect("ui_reward_click")
    EventManager.Brocast(EventType.TASK_COMPLETE, self.cityId, self.taskId)

    return results
end

function TaskBase:GetIconColor()
    local rt, color = UnityEngine.ColorUtility.TryParseHtmlString("#" .. self.taskTypeConfig.iconColor, color)
    if rt then
        return color
    end

    return UnityEngine.Color(255, 255, 255)
end

function TaskBase:GetTypeIconSprite()
    -- return ResourceManager.Load(string.format("images/icon/%s", self.taskTypeConfig.icon), TypeSprite)
    return self.taskTypeConfig.icon
end

function TaskBase:GetTaskDesc()
    local desc = self.taskConfig.desc
    if desc == "" then
        desc = self.taskTypeConfig.desc
    end

    return self:_GetTaskDesc(desc)
end

function TaskBase:GetTaskShortDesc()
    return self:_GetTaskDesc(self.taskTypeConfig.desc_short)
end

function TaskBase:GetTaskStage()
    return self.taskConfig.stage
end

function TaskBase:SetCurrCount(curr)
    self.taskCurrCount = self:Min(curr, self.taskMaxCount)
end

---@return number
function TaskBase:GetCacheCount()
    if self.taskCache.count == nil or self.taskCache.count == "" then
        return 0
    end

    return tonumber(self.taskCache.count)
end

function TaskBase:GetCacheMaxCount()
    if self.taskCache.maxCount == nil or self.taskCache.maxCount == "" then
        return 0
    end

    return tonumber(self.taskCache.maxCount)
end

function TaskBase:SetCacheMaxCount(maxCount)
    if maxCount == nil then
        return
    end

    self.taskCache.maxCount = tostring(maxCount)
    self.saveCacheFunc(self.taskCache)
end

function TaskBase:SetCacheCount(count)
    self.taskCache.count = count
    self.saveCacheFunc(self.taskCache)
end

function TaskBase:Min(a, b)
    if a > b then
        return b
    end

    return a
end

function TaskBase:IncrCacheCount(count)
    count = self:GetCacheCount() * 1.0 + count
    self:SetCacheCount(count)
end

function TaskBase:GetCacheTaskType()
    return self.taskCache.type
end

function TaskBase:InitCacheTaskType()
    if self.taskCache.type == nil then
        self.taskCache.type = self.taskConfig.action
    end
end

function TaskBase:InitRewards()
    -- 任务奖励不再固定，改回按照任务结束时的秒产来计算
    --local isDynamic = Utils.RewardsIsDynamic(Utils.ParseReward(self.taskConfig.rewards, true))
    --if self.taskCache.rewards == nil and isDynamic then
    --    -- 如果奖励还没有初始化，并且奖励是动态奖励
    --    self.taskCache.rewards = Utils.ParseReward(self.taskConfig.rewards)
    --    self.saveCacheFunc(self.taskCache)
    --elseif self.taskCache.rewards ~= nil and not isDynamic then
    --    -- 如果有奖励，并且
    self.taskCache.rewards = nil
    self.saveCacheFunc(self.taskCache)
    --end
end

function TaskBase:GetRewards()
    --if self.taskCache.rewards ~= nil then
    --    return self.taskCache.rewards
    --end

    return Utils.ParseReward(self.taskConfig.rewards, true)
end

function TaskBase:GetSafeCurrCount()
    return math.min(self.taskCurrCount, self.taskMaxCount)
end

---------------------------------------------------------------------------------------
---继承方法
---------------------------------------------------------------------------------------
--获取任务进度
function TaskBase:GetTaskProgress()
    return self:GetSafeCurrCount(), self.taskMaxCount
end

function TaskBase:GetJumpButtonShow()
    return true
end

--重构任务初始化
function TaskBase:OnInit()
end

--重构任务激活事件
function TaskBase:OnActive()
end
--重构任务事件响应
function TaskBase:OnResponse(...)
end

--重构任务检测
function TaskBase:OnCheck()
end

function TaskBase:GetIconSprite()
end

function TaskBase:LookUpZone()
end

-- 返回给定zoneId是否是这个任务所需建筑
---@param zoneId string
---@return boolean
function TaskBase:IsTargetZone(zoneId)
end
