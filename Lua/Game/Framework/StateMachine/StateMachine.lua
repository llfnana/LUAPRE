StateMachine = {}

function StateMachine:New()
    return Clone(StateMachine)
end

function StateMachine:DeActive()
    self.curState = nil
    self.nextState = nil
    self.prevState = nil
end

function StateMachine:SetNextState(state, forceClear)
    self.nextState = state
    if self.curState then
        self.curState:Stop(forceClear)
    else
        self:ChangeState()
    end
    return true
end

function StateMachine:ResetCurrentState()
    if self.curState then
        self.curState:Reset()
    end
end

function StateMachine:ChangeState()
    self.prevState = self.curState
    self.curState = self.nextState
    self.nextState = nil
    if self.curState then
        self.curState:Run()
    end
end
