BoostAgent = {}
BoostAgent.__cname = "BoostAgent"

function BoostAgent:New(owner)
    local cls = Clone(self)
    cls:Init(owner)
    return cls
end

-- 初始化对象
function BoostAgent:Init(owner)
    self.owner = owner
    self.cityId = owner.cityId
    if nil == owner.info.boostDatas then
        owner.info.boostDatas = {}
    end
    self.boostDatas = owner.info.boostDatas
    self.boostFactors = Dictionary:New()
    for i = 1, #self.boostDatas, 1 do
        self:AddFactor(self.boostDatas[i].boostType, self.boostDatas[i].boostFactor, self.boostDatas[i].boostEffect)
    end
end

-- 消亡
function BoostAgent:DeActive()
end

--是否存在boost
function BoostAgent:IsExsitBoost(boostName)
    for i = #self.boostDatas, 1, -1 do
        if self.boostDatas[i].boostName == boostName then
            return true
        end
    end
    return false
end

--添加booster
function BoostAgent:AddBoost(boostData)
    table.insert(self.boostDatas, boostData)
    DataManager.SaveCityData(self.cityId)
    self:AddFactor(boostData.boostType, boostData.boostFactor, boostData.boostEffect)
end

--刷新boost
function BoostAgent:UpdateBoost()
    local schedules = SchedulesManager.GetCurrentSchedulesByMenu(self.cityId)
    if nil == schedules then
        return
    end
    local cityDay = TimeManager.GetCityDay(self.cityId)
    local function CheckExpire(boostData)
        if boostData.boostName == BoostName.EatFood then
            if cityDay > boostData.boostParams.cityDay then
                return true
            elseif cityDay == boostData.boostParams.cityDay then
                if schedules.schedulesIndex > boostData.boostParams.schedulesIndex then
                    return true
                elseif schedules.schedulesIndex == boostData.boostParams.schedulesIndex then
                    if self.owner:GetSchedulesStatus(schedules.type) == SchedulesStatus.Stop then
                        return true
                    end
                end
            end
        end
        return false
    end
    for i = #self.boostDatas, 1, -1 do
        if CheckExpire(self.boostDatas[i]) then
            self:RemoveBoost(i)
        end
    end
end

--移除booster
function BoostAgent:RemoveBoost(index)
    local boostData = self.boostDatas[index]
    self:RemoveFactor(boostData.boostType, boostData.boostFactor, boostData.boostEffect)
    table.remove(self.boostDatas, index)
    DataManager.SaveCityData(self.cityId)
end

function BoostAgent:AddFactor(boostType, index, factor)
    if nil == self.boostFactors[boostType] then
        self.boostFactors[boostType] = BoostFactor:New()
    end
    self.boostFactors[boostType]:Add(index, factor)
end

function BoostAgent:RemoveFactor(boostType, index, factor)
    self.boostFactors[boostType]:Remove(index, factor)
end

function BoostAgent:GetFactor(boostType)
    if nil == self.boostFactors[boostType] then
        self.boostFactors[boostType] = BoostFactor:New()
    end
    return self.boostFactors[boostType].factor
end
