---@class FunctionsBase
FunctionsBase = {}
FunctionsBase.__cname = "FunctionsBase"

--创建任务
function FunctionsBase:Create(config)
    local cls = Clone(self)
    cls:Init(config)
    return cls
end

--功能初始化
---@param config FunctionsUnlock
function FunctionsBase:Init(config)
    self.config = config
    self.functionsType = config.id
    self.cityId = config.city
    self.eventType = ""
    self:OnInit()
end

function FunctionsBase:Check(cityId)
    if self:IsCity(cityId) then
        self:OnCheck()
    elseif not CityManager.GetIsEventScene(cityId) and cityId > self.cityId then
        self:Unlock()
    end
end

--事件响应
function FunctionsBase:Response(eventType, cityId, ...)
    if self.eventType ~= eventType then
        return
    end
    
    if not self:IsCity(cityId) then
        return
    end
    self:OnResponse(...)
end

function FunctionsBase:IsCity(cityId)
    if self.config.scope == "city" and self.cityId ~= cityId then
        -- 如果scope是city，当前城市不是设置城市，那么不触发
        return false
    end
    
    return self:OnIsCity(cityId)
end

function FunctionsBase:Unlock()
    Log("Unlock: " .. self.functionsType)
    EventManager.Brocast(EventType.FUNCTIONS_UNLOCK, self.functionsType)
end
---------------------------------
---重构方法
---------------------------------
--重构功能初始化
function FunctionsBase:OnInit()
end

--重构功能刷新
function FunctionsBase:OnCheck()
end

--重构功能事件响应
function FunctionsBase:OnResponse(...)
end

function FunctionsBase:OnIsCity(cityId)
    return self.cityId == cityId
end
