FSMSystemAgent = {}
FSMSystemAgent.__cname = "FSMSystemAgent"

function FSMSystemAgent:New(owner)
    local cls = Clone(self)
    cls:Init(owner)
    return cls
end

-- 初始化对象
function FSMSystemAgent:Init(owner)
    self.owner = owner
    self.fsmSystemList = {}
    self.currFsmSystem = nil
    self.pervFsmSystem = nil
end

function FSMSystemAgent:AddSystem(type, fsmItem)
    fsmItem:Init(self, type)
    self.fsmSystemList[type] = fsmItem
end

-- 消亡
function FSMSystemAgent:DeActive()
    if self.currFsmSystem then
        self.currFsmSystem:ExitSystem()
    end
    self = nil
end

-- 刷新
function FSMSystemAgent:Update()
    if nil ~= self.currFsmSystem then
        self.currFsmSystem:UpdateSystem()
    end
end

--是否包含类型
function FSMSystemAgent:IsContent(type)
    if self.fsmSystemList[type] then
        return true
    end
    return false
end

--状态是否运行
function FSMSystemAgent:IsRunning(stateId)
    if nil ~= self.currFsmSystem then
        return self.currFsmSystem:IsRunning(stateId)
    end
    return false
end

--设置下一个有限状态机
function FSMSystemAgent:SetNextSchedules()
    local nextType = self.owner:GetNextSchedules()
    self.owner.curSchedule =nextType
    local nextSystem = self.fsmSystemList[nextType] or nil
    if self.currFsmSystem then
        self.currFsmSystem:ExitSystem()
    end
    self.pervFsmSystem = self.currFsmSystem
    self.currFsmSystem = nextSystem
    if self.currFsmSystem then
        self.currFsmSystem:EnterSystem()
    end
end
