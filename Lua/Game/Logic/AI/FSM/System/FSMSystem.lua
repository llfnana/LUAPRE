FSMSystem = {}
FSMSystem.__cname = "FSMSystem"

function FSMSystem:New()
    return Clone(self)
end

function FSMSystem:Init(agent, type)
    self.agent = agent
    self.owner = agent.owner
    self.type = type
    self.cityId = self.owner.cityId
    self.stateList = Dictionary:New()
    self:ConfigAI()
end

--添加状态
function FSMSystem:AddState(stateItem)
    if self.stateList:ContainsKey(stateItem.stateId) then
        return
    end
    self.stateList:Add(stateItem.stateId, stateItem)
end

function FSMSystem:GetState(stateId)
    if self.stateList:ContainsKey(stateId) then
        return self.stateList[stateId]
    end
    return nil
end

function FSMSystem:EnterSystem()
    self.currentState = self:GetState(StateId.EntryState)
    self.currentState:EnterState(self)
end

function FSMSystem:UpdateSystem()
    self.currentState:UpdateState(self)
end

function FSMSystem:ExitSystem()
    self.currentState:ExitState(self)
end

--切换有效状态
function FSMSystem:ChangeActiveState(stateId)
    local nextState = self:GetState(stateId)
    if nil == nextState then
        return
    end
    self:ChangeStateTrigger(stateId)
    self.currentState:ExitState(self)
    self.currentState = nextState
    self.curremtStateId = stateId
    self.currentState:EnterState(self)
end

--状态是否运行
function FSMSystem:IsRunning(stateId)
    if nil ~= self.currentState then
        return self.currentState.stateId == stateId
    end
    return false
end

--------------------------------------------------
---通用移动行为
--------------------------------------------------

--获取主干道速度加成
function FSMSystem:GetSpeedPercent(type)
    local defaltSpeedPercent = 1
    local boostSpeedPercent = MapManager.GetBoostValueByType(self.cityId, BoostType.Speed)
    local schedulesSpeedPercent = 0
    local hungerSpeedPercent = 0
    if type ~= SchedulesType.None then
        schedulesSpeedPercent = SchedulesManager.GetSchedulesSpeedUp(self.cityId, type)
        defaltSpeedPercent = self:GetTutorialSpeedPercent()
    end
    if type == SchedulesType.Eat then
        hungerSpeedPercent = FunctionHandles.GetHungerSpeedBoost(self.owner)
    end
    if boostSpeedPercent ~= 0 or schedulesSpeedPercent ~= 0 or hungerSpeedPercent ~= 0 then
        LogWarningFormat(
            "boostSpeedPercent = {0}, schedulesSpeedPercent = {1}, hungerSpeedPercent = {2}",
            boostSpeedPercent,
            schedulesSpeedPercent,
            hungerSpeedPercent
        )
    end
    return defaltSpeedPercent + boostSpeedPercent + schedulesSpeedPercent + hungerSpeedPercent
end

--获取引导加速
function FSMSystem:GetTutorialSpeedPercent()
    if TutorialManager.IsComplete(TutorialStep.BuildHunterCabin) then
        return 1
    end
    return FSMConst.TUTORIAL_MOVE_SPEED_PERCENT
end

--设置移动信息
function FSMSystem:SetMoveInfo(target, speedPercent, animation)
    if nil == target then
        print("[error]" .. debug.traceback())
        return
    end
    self.moveTarget = target
    self.speedPercent = speedPercent or 1
    self.moveAnimation = animation
end

--移动进入
function FSMSystem:EnterMove()
    if nil == self.moveTarget then
        print("[Error] self.moveTarget is nil", debug.traceback())
        print("[error]" .. debug.traceback())
        return
    end
     self.owner:MoveToGrid(self.moveTarget, self.speedPercent, self.moveAnimation)
end

--移动刷新
function FSMSystem:UpdateMove()
    if not self.owner:MoveIsRunning() and self.owner.currGrid == self.owner.targetGrid then
        self.currentState:DoneState(self)
    end
end

--移动退出
function FSMSystem:DoneMove()
    self.moveTarget = nil
    self.speedPercent = 1
    self.moveAnimation = nil
end

--------------------------------------------------
---需要具体模式继承后重构方法
---实现具体的逻辑实现
--------------------------------------------------
function FSMSystem:ConfigAI()
end

function FSMSystem:ChangeStateTrigger(stateId)
end
