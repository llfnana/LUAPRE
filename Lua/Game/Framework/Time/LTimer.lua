--计时器状态
LTimerState =
{
	Stop = 0,
	Delaying = 1,
	Playing = 2,
}
local LTimerState = LTimerState

--计时器事件
LTimerEvent =
{
	Start = 0,
	Update = 1,
	Repeat = 2,
	Pause = 3,
	Resume = 4,
	Stop = 5,
	SetSpeedOrTimeScale = 6,
}
local LTimerEvent = LTimerEvent

--计时器
LTimer = class("LTimer")
local LTimer = LTimer

--构造函数
-- duration一直持续是 -1
function LTimer:ctor(duration, owner)
	self.duration = duration or 0		--持续时间
	self.owner = owner					--拥有者

	self.useTimeScale = true			--是否启用时间缩放
	self.useRealTime = false			--是否使用真实时间, 真实时间模式缩放无效且不能调倍速，可以暂停但计时会继续
	self.speed = 1						--播放速度
	self.delayTime = 0					--延时执行时间
	self.delayedTime = 0				--已延时执行时间
	self.playCount = 1					--播放次数
	self.playedCount = 0				--已播放次数
	self.startRealTime = 0				--启动时的真实时间：如果有delay则是delay的启动时间
	self.startTime = 0					--开始执行时的时间：如果有delay则是delay后的执行时间
	self.runTime = 0					--已运行时间
	self.state = LTimerState.Stop		--当前状态
	self.isPause = false				--是否暂停

	self.typeEvents = {}				--事件：按类型分类
end

--剩余时间
function LTimer:GetLeftTime()
	if self.state ~= LTimerState.Playing then
		return self.duration
	end
	if self.duration < 0 then
		return -1
	elseif self.duration == 0 then
		return 0
	end
	return self.duration + self.delayTime - self.runTime
end

--获取进度
function LTimer:GetProgress()
	if self.duration < 0 then
		return 0
	elseif self.duration == 0 then
		return 1
	end
	return self.runTime / self.duration
end

--是否在播放中
function LTimer:IsPlaying()
	if self.state == LTimerState.Playing then
		return true
	end
	if self.state == LTimerState.Delaying then
		return true
	end
	return false
end

--是否在真实播放中
function LTimer:IsRealPlaying()
	if self.isPause then
		return false
	end
	if self.state == LTimerState.Playing then
		return true
	end
	return false
end

--是否在播放中
function LTimer:IsDelaying()
	return self.state == LTimerState.Delaying
end

--是否在真实的延时中
function LTimer:IsRealDelaying()
	if self.isPause then
		return false
	end
	return self.state == LTimerState.Delaying
end

--是否可更新
function LTimer:CanUpdate()
	if self.isPause then
		return false
	end
	if self.state == LTimerState.Stop then
		return false
	end
	return true
end

--是否完成
function LTimer:IsCompleted()
	return self:GetProgress() >= 1
end

--添加事件
--eventType：事件类型
--eventFunc：回调事件方法
--...：回调参数
function LTimer:AddEvent(eventType, eventFunc, ...)
	local events = self.typeEvents[eventType]
	if events == nil then
		events = {}
		self.typeEvents[eventType] = events
	end
	local argsList = events[eventFunc]
	if argsList == nil then
		argsList = {}
		events[eventFunc] = argsList
	end
	argsList[#argsList + 1] = {...}
end

--移除事件
--eventType：事件类型
--eventFunc：回调事件方法，为空时则移除指定类型的所有事件
--...：回调参数，为空时则移除指定回调事件，否则移除对应参数的一个回调事件
function LTimer:RemoveEvent(eventType, eventFunc, ...)
	local events = self.typeEvents[eventType]
	if events == nil then
		return
	end
	if eventFunc == nil then
		self.typeEvents[eventType] = nil
		return
	end
	if ... == nil then
		events[eventFunc] = nil
		return
	end
	local args = {...}
	local argsLen = #args
	local eventArgsList = events[eventFunc]
	for k, eventArgs in ipairs(eventArgsList) do
		local eventArgLen = #eventArgs
		if eventArgLen == argsLen then
			local sameArgs = true
			for i = 1, argsLen do
				if eventArgs[i] ~= args[i] then
					sameArgs = false
					break
				end
			end
			if sameArgs then
				table.remove(eventArgsList, k)
				break
			end
		end
	end
end

--清除所有事件
function LTimer:ClearAllEvent()
	self.typeEvents = {}
end

--执行事件
--eventType：事件类型
function LTimer:ExecuteEvent(eventType)
	if self.owner ~= nil then
		self.owner.OnTimerEvent(self.owner, self, eventType)
	end
	local events = self.typeEvents[eventType]
	if events == nil then
		return
	end
	for eventFunc, argsList in pairs(events) do
		if eventFunc ~= nil then
			for _, args in ipairs(argsList) do
				eventFunc(unpack(args))
			end
		end
	end
end

--开始执行
--runTime：从什么时间开始
function LTimer:Start(runTime)
	self:OnStart(runTime)
end

--重新执行开始
--runTime：重新执行开始时间
function LTimer:RepeatStart(runTime)
	self:OnStart(runTime, true)
end

--开始执行
--runTime：从什么时间开始
--byRepeat：是否被自动重复执行
function LTimer:OnStart(runTime, byRepeat)
	runTime = runTime or 0
	if self.state ~= LTimerState.Stop then
		self:Stop()
	end
	self.isPause = false
	if self.delayTime > 0 then
		if runTime > self.delayTime then
			self.delayedTime = self.delayTime
			self.runTime = runTime - self.delayTime
		else
			self.delayedTime = runTime
			self.runTime = 0
		end
	else
		self.delayedTime = 0
		self.runTime = runTime
	end
	self.startRealTime = Time.realtimeSinceStartup - self.runTime
	--重复执行时不重置执行次数
	if not byRepeat then
		self.playedCount = 0
	end

	--延时执行
	if self.delayTime > 0 and self.delayedTime < self.delayTime then
		self.state = LTimerState.Delaying
		LTimerManager.AddTimer(self)
	else
		self:Run(self.runTime)
	end
end

--正式运行
--runedTime：进入正式运行已迭代时间
function LTimer:Run(runedTime)
	self.state = LTimerState.Playing
	--为重复执行计算的开始时间
	if self.duration >= 0 then
		if runedTime >= self.duration then
			runedTime = runedTime - self.duration
			self.runTime = self.duration
		else
			self.runTime = runedTime
		end
	else
		self.runTime = runedTime
	end
	--开始时间包含delay开始时间
	if self.useRealTime then
		self.startTime = Time.realtimeSinceStartup - self.runTime
	else
		self.startTime = Time.time - self.runTime
	end

	self:ExecuteEvent(LTimerEvent.Start)
	self.playedCount = self.playedCount + 1

	--没有持续时间则直接完成，也不执行一次更新
	if self.duration == 0 then
		self:Stop(true)
	else
		--正式启动时已有运行时间，触发一次更新
		if self.runTime ~= 0 then
			self:ExecuteEvent(LTimerEvent.Update)
		end

		--已完成
		if self.runTime >= self.duration and self.duration > 0 then
			self:Complete(runedTime)
		else
			LTimerManager.AddTimer(self)
		end
	end
end

--更新
--deltaTime：迭代时间
function LTimer:Update(deltaTime)
	if deltaTime == 0 or self.speed == 0 or self.duration == 0 or not self:CanUpdate() then
		return
	end
	if self.useRealTime then
		local playTime = (Time.realtimeSinceStartup - self.startRealTime) * self.speed
		if self.state == LTimerState.Delaying then
			if playTime >= self.delayTime then
				self.delayedTime = self.delayTime
				self:Run(playTime - self.delayTime)
			else
				self.delayedTime = playTime
			end
		else
			if self.duration > 0 and playTime >= self.duration then
				--OverTime
				deltaTime = playTime - self.duration
				self.runTime = self.duration
				self:Complete(deltaTime)
			else
				self.runTime = playTime
				self:ExecuteEvent(LTimerEvent.Update)
			end
		end
	else
		deltaTime = deltaTime * self.speed
		if self.state == LTimerState.Delaying then
			if self.delayedTime + deltaTime >= self.delayTime then
				self.delayedTime = self.delayTime
				self:Run(self.delayedTime + deltaTime - self.delayTime)
			else
				self.delayedTime = self.delayedTime + deltaTime
			end
		else
			if self.duration > 0 and self.runTime + deltaTime >= self.duration then
				--OverTime
				deltaTime = self.runTime + deltaTime - self.duration
				self.runTime = self.duration
				self:Complete(deltaTime)
			else
				self.runTime = self.runTime + deltaTime
				self:ExecuteEvent(LTimerEvent.Update)
			end
		end
	end
end

--自动执行情况下的完成
--overTime：超过时间
function LTimer:Complete(overTime)
	self:Stop(true)
	--一直循环或播放次数还未达到最大值继续播放
	if self.playedCount < self.playCount then
		self:RepeatStart(overTime)
	end
end

--停止
--sendEvent：是否发送事件
function LTimer:Stop(sendEvent)
	self.isPause = false
	if self.state ~= LTimerState.Stop then
		self:OnStop(sendEvent)
	end
end

--停止
--sendEvent：是否发送事件
function LTimer:OnStop(sendEvent)
	self.state = LTimerState.Stop
	LTimerManager.RemoveTimer(self)
	if sendEvent then
		self:ExecuteEvent(LTimerEvent.Stop)
	end
end

--暂停
function LTimer:Pause()
	if self.isPause then
		return
	end
	self.isPause = true
	self:ExecuteEvent(LTimerEvent.Pause)
end

--恢复
function LTimer:Resume()
	if not self.isPause then
		return
	end
	self.isPause = false
	self:ExecuteEvent(LTimerEvent.Resume)
end

--设置播放速度和时间缩放
--speed：速度
--useTimeScale：时间缩放
function LTimer:SetSpeedAndUseTimeScale(speed, useTimeScale)
	if self.speed ~= speed or self.useTimeScale ~= useTimeScale then
		self.speed = speed
		self.useTimeScale = useTimeScale
		self:ExecuteEvent(LTimerEvent.SetSpeedOrTimeScale)
	end
end

--释放
function LTimer:Dispose()
	self:ClearAllEvent()
	self.owner = nil
	self:Stop()
end