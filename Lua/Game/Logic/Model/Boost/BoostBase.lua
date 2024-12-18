---@class BoostBase
BoostBase = {}
BoostBase.__cname = "BoostBase"

--创建effect
function BoostBase:Create(cityId, boostData)
    local cls = Clone(self)
    cls.cityId = cityId
    cls.boostData = boostData
    cls:Enter()
    return cls
end

function BoostBase:GetId()
    return tostring(self.boostData.boostId)
end

function BoostBase:GetToId()
    return tostring(self.boostData.toId)
end

function BoostBase:GetCardId()
    return self.boostData.cardId
end

--初始化effect
function BoostBase:Enter()
    self.endTime = -1
    self.config = ConfigManager.GetBoostConfig(self.boostData.boostId)
    self.effects = self.config.boost_effects
    self.params = self.config.boost_params
    self.params.duration = tonumber(self.params.duration)
    self.params.index = tonumber(self.params.index)
    if self.params.duration > 0 then
        self.endTime = self.boostData.startTime + self.params.duration
    end
    --具体任务解析
    self:OnEnter()
end

function BoostBase:GetEffect()
    local cardId = self.boostData.cardId
    local boostLevel = CardManager.GetCardItemData(cardId):GetCardBoostLevel()
    return self.effects[boostLevel]
end

---@return BoostFromType
function BoostBase:GetFromType()
    return self.config.from_type
end

function BoostBase:CheckExpire()
    if self.endTime > 0 and TimeManager.GameTime() >= self.endTime then
        BoostManager.RemoveBoostById(self.cityId, self:GetToId())
        return true
    end
    return false
end

function BoostBase:Quit()
    self:OnQuit()
end

function BoostBase:Refresh()
    self:OnQuit()
    self:OnEnter()
end

---@return boolean
function BoostBase:GetBoostLevel()
    local level = 0
    local boostScopeType = self:GetFromType()
    if boostScopeType == BoostFromType.Card then
        local cardId = self.boostData.cardId
        level = CardManager.GetCardItemData(cardId):GetCardBoostLevel()
    elseif boostScopeType == BoostFromType.Trick then
        level =0-- EventSceneManager.GetTrickLevel(self:GetToId())
    end
    
    return level
end

--重构effect
function BoostBase:OnEnter()
end

function BoostBase:OnQuit()
end
