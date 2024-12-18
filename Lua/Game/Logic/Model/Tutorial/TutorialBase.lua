---@class TutorialBase
TutorialBase = {}
TutorialBase.__cname = "TutorialBase"

--创建任务
function TutorialBase:Create()
    return Clone(self)
end

function TutorialBase:Init(cityId, step, subStep, config, isCheck)
    self.cityId = cityId
    self.step = step
    self.subStep = subStep
    self.config = config
    self.readyStep = {}
    if isCheck then
        return
    end
    self:OnInit()
    self:Run()
end
 
--添加引导步骤
---@param stepFunc function
function TutorialBase:AddStep(stepFunc)
    table.insert(self.readyStep, stepFunc)
    return self
end

--是否限制保存
function TutorialBase:NeedLimitSave()
    -- return self.config.needLimitSave
    return false
end

function TutorialBase:SaveTutorial(forceSave)
    TutorialManager.SaveTutorial(self.step, self.subStep, forceSave)
end

--设置引导下一步
function TutorialBase:NextSubStep(delay, forceSave)
    print("[Tutorial] NextSubStep: ", self.__cname, ", Curr: " .. self.subStep .. ", Next: " .. (self.subStep + 1))
    local function ChangeStep()
        self.subStep = self.subStep + 1
        self:SaveTutorial(forceSave)
        self:Run()
    end
    if delay then
        TutorialHelper.CameraLockUp(
            {
                maskType = TutorialMaskType.None,
                stopTime = delay,
                callBack = ChangeStep
            }
        )
    else
        ChangeStep()
    end
end

--跳转引导下一步
function TutorialBase:JumpSubStep(subStep, forceSave)
    self.subStep = subStep
    self:SaveTutorial(forceSave)
    self:Run()
end

--检测停止时间
function TutorialBase:CheckStopTime(cityDay, cityClock)
    if self.config.needStop and not TutorialManager.StopTime.value then
        if cityDay == self.config.stopDay and cityClock >= self.config.stopClock then
            TutorialManager.StopTime.value = true
        end
    end
end

function TutorialBase:Run()
    self:OnRun()
    self:OnRunStep()
end

function TutorialBase:Complete()
    TutorialManager.CompleteTutorial(self.step)
    self:OnComplete()
end

--重构
function TutorialBase:OnInit()
end

function TutorialBase:OnRun()
end

function TutorialBase:OnRunStep()
    if self.readyStep[self.subStep] ~= nil then
        self.readyStep[self.subStep]()
    end
end

function TutorialBase:OnComplete()
end
