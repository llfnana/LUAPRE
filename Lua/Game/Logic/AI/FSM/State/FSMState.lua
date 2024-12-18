FSMState = {}
FSMState.__cname = "FSMState"
FSMState.stateId = StateId.None
FSMState.playAnimation = true
local this = FSMState
function FSMState:New(stateId)
    local cls = Clone(self)
    cls:Init(stateId)
    return cls
end

function FSMState:Init(stateId)
    self.transitionMap = {}
    self.stateId = stateId
    self:OnInit()
end

--添加转换
function FSMState:AddTransition(checkType, transitionType, stateId)
    if checkType == nil or transitionType == nil or stateId == nil then
        print("[error]" .. debug.traceback())
        return
    end
    if not self.transitionMap[checkType] then
        self.transitionMap[checkType] = Dictionary:New()
    end
    self.transitionMap[checkType]:Add(transitionType, stateId)
end

function FSMState:CheckTransition(checkType, fsm)
    if not self.transitionMap[checkType] then
        return
    end
    this.checkFSM = fsm
    self.transitionMap[checkType]:ForEachKeyValue(this.EachTransitionFunc)
end

function this.EachTransitionFunc(transitionType, stateId)
    local handle = TransitionHandles[transitionType]
    if handle and handle(this.checkFSM) then
        this.checkFSM :ChangeActiveState(stateId)
        return true
    end
end

function FSMState:EnterState(fsm)
    self.lifeTime = 0
    self.inState = true
    --播放动画
    if self.playAnimation then
        local animation = fsm.owner.currGrid:GetAnimation()
        if nil ~= animation and animation ~= "" then
            fsm.owner:PlayAnimEx(animation)
        end
    end
    self.isTimeLimited = false
    self.isPrintError = false
    self.checkTime = FSMConst.TRANSITION_TIME --条件检测事件
    self:OnEnter(fsm)
end

--设置持续时间
function FSMState:SetDuration(fsm, needBoost)
    self.isTimeLimited = true
    self.startTime = 0
    local time = fsm.owner.currGrid:GetUsageDuration()
    if needBoost then
        time = time * fsm.owner.attributeBoostValue
    end
    self.dutationTime = time
    self.currProgress = 0
end

--刷新进度
function FSMState:UpdateProgress()
    self.startTime = self.startTime + TimerFunction.deltaTime
    local newProgress = 0
    if self.dutationTime > 0 then
        newProgress = self.startTime / self.dutationTime
        if newProgress > 1 then
            newProgress = 1
        end
    else
        newProgress = 1
    end
    self.changeProgress = newProgress - self.currProgress
    self.currProgress = newProgress
end

function FSMState:UpdateState(fsm)
    if self.inState then
        self.lifeTime = self.lifeTime + TimerFunction.deltaTime
        self.checkTime = self.checkTime + TimerFunction.deltaTime
        local processCheck = false
        if self.checkTime >= FSMConst.TRANSITION_TIME then
            self.checkTime = self.checkTime - FSMConst.TRANSITION_TIME
            processCheck = true
        end
        if self.isTimeLimited then
            self:UpdateProgress()
            self:OnUpdate(fsm)
            if self.startTime >= self.dutationTime then
                self:DoneState(fsm)
            elseif processCheck then
                self:CheckTransition(CheckType.Process, fsm)
            end
        else
            self:OnUpdate(fsm)
            if processCheck then
                self:CheckTransition(CheckType.Process, fsm)
            end
        end
    else
        --错误log
        if not self.isPrintError then
            self.isPrintError = true
        end
        fsm.owner:SetNextSchedules()
    end
end

function FSMState:DoneState(fsm)
    self.isTimeLimited = false
    self.inState = false
    self:OnDone(fsm)
    self:CheckTransition(CheckType.Complete, fsm)
end

function FSMState:ExitState(fsm)
    self:OnExit(fsm)
    self.lifeTime = 0
    self.inState = false
end

--------------------------------------------------
---需要具体模式继承后重构方法
---实现具体的逻辑实现
--------------------------------------------------
function FSMState:OnInit()
end

function FSMState:OnEnter(fsm)
end

function FSMState:OnUpdate(fsm)
end

function FSMState:OnDone(fsm)
end

function FSMState:OnExit(fsm)
end
