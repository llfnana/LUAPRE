OverTimeProductionManager = {}
OverTimeProductionManager.__cname = "OverTimeProductionManager"

local this = OverTimeProductionManager

OverTimeProductionManager.TimeMachineType = {
    TimeMachine1H = "TimeMachine1H",
    TimeMachine4H = "TimeMachine4H",
    TimeMachine12H = "TimeMachine12H"
}

--初始化
function OverTimeProductionManager.Init()
    this.cityId = DataManager.GetCityId()
    if not this.Items then
        this.Items = Dictionary:New()
    end
    if not this.Items:ContainsKey(this.cityId) then
        this.Items:Add(this.cityId, CityOverTimeProduction:New(this.cityId))
    end
end

--清理
function OverTimeProductionManager.Clear(force)
    Utils.SwitchSceneClear(this.cityId, this.Items, force)
end

--获取加班对象
---@return CityOverTimeProduction
function OverTimeProductionManager.Get(cityId)
    return this.Items[cityId]
end
