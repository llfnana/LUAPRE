ModeNormal = {}
ModeNormal.__cname = "ModeNormal"

---创建对象
function ModeNormal:New()
    return Clone(self)
end

function ModeNormal:Init(owner)
    self.owner = owner
    self.inState = false
end

--------------------------------------------------
---重构StateNormal接口
--------------------------------------------------
---模式进入
function ModeNormal:Run()
    self:OnEnter()
end

---模式刷新
function ModeNormal:Update()
    self:OnUpdate()
end

---强制模式刷新
function ModeNormal:ForceUpdate()
    self:OnForceUpdate()
end

---Reset数据
function ModeNormal:Reset()
    self:OnReset()
end

---模式停止
function ModeNormal:Stop(forceClear)
    self:OnExit(forceClear)
    self.owner:ChangeMode()
end

-- --------------------------------------------------
-- ---需要具体模式继承后重构方法
-- ---实现具体的逻辑实现
-- --------------------------------------------------
---模式运行状态进入
function ModeNormal:OnEnter()
end

--模式运行状态刷新
function ModeNormal:OnUpdate()
end

--强制模式运行状态刷新
function ModeNormal:OnForceUpdate()
end

--模式运行清除
function ModeNormal:OnClear()
end

--模式退出状态执行
function ModeNormal:OnExit(forceClear)
end
