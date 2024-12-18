FunctionsLoginDay = Clone(FunctionsBase)
FunctionsLoginDay.__cname = "FunctionsLoginDay"

function FunctionsLoginDay:OnInit()
    self.dayCount = tonumber(self.config.unlockParams["day"])
end

function FunctionsLoginDay:OnCheck()
    --local reg = DataManager.GetGlobalDataByKey(DataKey.RegisterTS)
    --local regTime = Time2:New(reg)
    --local d = math.floor((GameManager.GameTime() - regTime:GetToday()) / Time2.Day) + 1
    local d = DataManager.GetLoginInfo().count
    
    if tonumber(d) >= self.dayCount then
        self:Unlock()
    end
end

function FunctionsLoginDay:OnIsCity(cityId)
    return true
end

return FunctionsLoginDay
