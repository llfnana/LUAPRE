---@class PushBase
PushBase = {}
PushBase.__cname = "PushBase"

---@param cityId number
---@param config Push
---@param data table
---@param saveFunc fun(data:table)
function PushBase:Create(cityId, config, data, saveFunc)
    local cls = Clone(self)
    
    cls:Init(cityId, config, data, saveFunc)
    return cls
end

---@param cityId number
---@param config Push
---@param data table
---@param saveFunc fun(data:table)
function PushBase:Init(cityId, config, data, saveFunc)
    if self.initialized then
        return
    end
    
    self.cityId = cityId
    self.config = config
    self.params = JSON.decode(self.config.params)
    self.data = data
    self.saveFunc = saveFunc
    self:OnInit()
end

--- 刷新数据
---@param now Time2
function PushBase:Refresh(now)
    if self:Available() then
        self.saveFunc(self:GenerateData(now))
    end
end

--- 是最大场景
function PushBase:IsMaxCity()
    return DataManager.GetMaxCityId() == self.cityId
end

function PushBase:IsEventCity()
    return CityManager.GetIsEventScene(self.cityId)
end

function PushBase:InEvent()
    return false
    --return EventSceneManager.GetEventState() == "Active"
end

function PushBase:Available()
    return false
end

function PushBase:OnInit()

end

function PushBase:OnEvent(cityId, type, params)

end

---@param now Time2
function PushBase:GenerateData(now)
    return {}
end
