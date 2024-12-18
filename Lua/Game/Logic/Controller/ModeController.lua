--游戏模式
ModeType = {
    None = 0,
    Loading = 1,
    MainScene = 2,
    ChangeScene = 3,
    BattleScene = 4,
    DIYBattleScene = 5,
    RebootScene = 6,
    RoguelikeScene = 7,
    BindAccountScene = 8
}

--模式状态
ModeState = {
    LOAD = 1,
    RUN = 2,
    EXIT = 3
}

ModeController = {}
ModeController.__cname = "ModeController"

function ModeController:Init()
    self.stateMachine = StateMachine:New()
    --模式填充
    self.modeList = {}
    self.modeList[ModeType.Loading] = ModeLoading:New()
    self.modeList[ModeType.MainScene] = ModeMainScene:New()
    self.modeList[ModeType.ChangeScene] = ModeChangeScene:New()
    -- self.modeList[ModeType.BattleScene] = ModeBattleScene:New()
    -- self.modeList[ModeType.DIYBattleScene] = DiyModeBattleScene:New()
    -- self.modeList[ModeType.RebootScene] = ModeRebootScene:New()
    -- self.modeList[ModeType.RoguelikeScene] = RoguelikeScene:New()
    -- self.modeList[ModeType.BindAccountScene] = ModeBindAccountScene:New()
    --模式初始化
    for type, mode in pairs(self.modeList) do
        mode:Init(self)
    end

    self.preModeType = ModeType.None
    self.currentModeType = ModeType.None
end

function ModeController:GetPreModeType()
    return self.preModeType
end

function ModeController:GetModeType()
    return self.currentModeType
end

function ModeController:Update()
   -- print(" ModeController:Update()-",os.time)
    if nil == self.stateMachine then
        return
    end
    if nil == self.stateMachine.curState then
        return
    end
    self.stateMachine.curState:Update()
end

function ModeController:ForceUpdate()
    if nil == self.stateMachine then
        return
    end
    if nil == self.stateMachine.curState then
        return
    end
    self.stateMachine.curState:ForceUpdate()
end

function ModeController:SetNextMode(modeType, forceClear)
    local modeItem = self.modeList[modeType]
    if modeItem then
        self.stateMachine:SetNextState(modeItem, forceClear)
        if self.currentModeType ~= ModeType.ChangeScene then
            self.preModeType = self.currentModeType
        end
        self.currentModeType = modeType
    else
    end
end
function ModeController:ResetMode()
    self.stateMachine:ResetCurrentState()
end

function ModeController:ChangeMode()
    if self.stateMachine then
        self.stateMachine:ChangeState()
    end
end

function ModeController:New()
    local cls = Clone(self)
    cls:Init()
    return cls
end
