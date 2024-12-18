---@class CityGenerator  发电机,火炉
CityGenerator = Clone(CityBase)
CityGenerator.__cname = "CityGenerator"

--初始化
function CityGenerator:OnInit()
    self.enable = DataManager.GetCityDataByKey(self.cityId, DataKey.GenEnable)
    self.overload = DataManager.GetCityDataByKey(self.cityId, DataKey.GenOverload)
    self.countBuff = ConfigManager.GetMiscConfig("generator_overload_resource_times")

    self.consumptionCountRecord = {}
    self:UpdateMapItemData()
    self:CheckAudioState()
    self.tempAcc = 0
    self.status = nil
    self.lastAutoStatus = ""
    self.overdriveControl = ConfigManager.GetFormulaConfigById("overdriveControl")
end

--清理
function CityGenerator:OnClear()
    self = nil
end

function CityGenerator:UpgradeLevel()
    self.tempAcc = 0
    self:UpdateMapItemData()
end

function CityGenerator:UpdateMapItemData()
    --每分钟消耗资源数量
    if not self.mapItemData then
        self.mapItemData = MapManager.GetMapItemData(self.cityId, "C" .. self.cityId .. "_Generator_1")
    end
    local consumption = self.mapItemData:GetConsumption()
    for itemId, count in pairs(consumption) do
        self:ChangeConsumptionItem(itemId, count)
        break
    end
end

--更换消耗资源
function CityGenerator:ChangeConsumptionItem(itemId, count)
    --剔除老的消耗资源
    if nil ~= self.itemId then
        if self.consumptionCountRecord[self.itemId] then
            StatisticalManager.SetOnlineConsumptions(
                self.cityId,
                self.itemId,
                self.consumptionCountRecord[self.itemId] / 60 * -1
            )
            self.consumptionCountRecord[self.itemId] = nil
        end
    end
    --设置新的消耗资源
    self.itemId = itemId
    self.count = count
    if not self.consumptionCountRecord[itemId] then
        self.consumptionCountRecord[itemId] = 0
    end
    self:RefreshConsumptionCount()
end

function CityGenerator:Open()
    self.enable = true
    DataManager.SetCityDataByKey(self.cityId, DataKey.GenEnable, self.enable)
    self.tempAcc = 0
    self.status = nil
    self:UpdateTime()
    self:RefreshConsumptionCount()
    self:CheckAudioState()
    EventManager.Brocast(EventType.REFRESH_GENERATOR, self.cityId)
    if self.status == "UseUp" then
        return
    end
    EventManager.Brocast(EventType.GENERATOR_ADD_FIRE, self.cityId)
    EventManager.Brocast(EventType.CHANGE_DUQI, self.cityId)
end

function CityGenerator:Close()
    self.enable = false
    DataManager.SetCityDataByKey(self.cityId, DataKey.GenEnable, self.enable)
    self.status = nil
    self:RefreshConsumptionCount()
    self:CheckAudioState()
    EventManager.Brocast(EventType.REFRESH_GENERATOR, self.cityId)
    EventManager.Brocast(EventType.GENERATOR_REDUCE_FIRE, self.cityId, 1) -- 小火减火
    EventManager.Brocast(EventType.CHANGE_DUQI, self.cityId)
end

function CityGenerator:OpenOverload()
    self.overload = true
    DataManager.SetCityDataByKey(self.cityId, DataKey.GenOverload, true)
    self:RefreshConsumptionCount()
    self:CheckAudioState()
    EventManager.Brocast(EventType.REFRESH_GENERATOR, self.cityId)

    EventManager.Brocast(EventType.CHANGE_DUQI, self.cityId)
end

function CityGenerator:CloseOverload()
    self.overload = false
    DataManager.SetCityDataByKey(self.cityId, DataKey.GenOverload, false)
    self:RefreshConsumptionCount()
    self:CheckAudioState()
    EventManager.Brocast(EventType.REFRESH_GENERATOR, self.cityId)
    EventManager.Brocast(EventType.GENERATOR_REDUCE_FIRE, self.cityId, 2) -- 大火减火

    EventManager.Brocast(EventType.CHANGE_DUQI, self.cityId)
end

function CityGenerator:CheckAudioState()
--    if self.enable then
--        if self.overload then
--            AudioManager.SetState("firewood_state", "overdrive")
--        else
--            AudioManager.SetState("firewood_state", "on")
--        end
--    else
--        AudioManager.SetState("firewood_state", "off")
--    end
end

function CityGenerator:GetZoneId()
    return self.mapItemData.zoneId
end

function CityGenerator:GetConsumptionItemId()
    return self.itemId
end

function CityGenerator:GetCount()
    return self.count
end

--白天理论消耗
function CityGenerator:GetDayConsumption()
    return self.count
end

--夜晚理论消耗
function CityGenerator:GetNightConsumption()
    return self.count * self.countBuff
end

--刷新路子消耗变更值
function CityGenerator:RefreshConsumptionCount()
    local changeCount = 0
    local tempCount = self:GetConsumptionCount()
    if self.consumptionCountRecord[self.itemId] then
        if self.consumptionCountRecord[self.itemId] ~= tempCount then
            changeCount = tempCount - self.consumptionCountRecord[self.itemId]
            self.consumptionCountRecord[self.itemId] = tempCount
        end
    else
        self.consumptionCountRecord[self.itemId] = tempCount
        changeCount = tempCount
    end
    if changeCount ~= 0 then
        changeCount = changeCount / 60
        StatisticalManager.SetOnlineConsumptions(self.cityId, self.itemId, changeCount)
    end
end

function CityGenerator:GetConsumptionCount()
    local ret = 0
    if self.enable then
        ret = self.count
        if self.overload then
            ret = ret * self.countBuff
        end
        ret = ret * BoostManager.GetCommonBoosterFactor(self.cityId, CommonBoostType.GeneratorResource)
    end
    return ret * TestManager.GetTest(self.cityId).aiGameSpeed.value
end

function CityGenerator:GetSumConsumptionCount()
    local ret = 0
    ret = self.count
    ret = ret * BoostManager.GetCommonBoosterFactor(self.cityId, CommonBoostType.GeneratorResource)
    return ret
end

function CityGenerator:SumConsumptionLeftTime()
    local count = DataManager.GetMaterialCount(self.cityId, self.itemId)
    local ret = math.ceil(count / self:GetSumConsumptionCount())
    return ret
end

---获取火炉消耗，关闭时返回普通状态，打开时根据过载返回消耗
function CityGenerator:GetConsumptionCountForMaterialCheck()
    local count = self:GetSumConsumptionCount()

    if self:GetIsOverload() then
        return count * self.countBuff
    end

    return count
end

function CityGenerator:GetNextConsumption()
    local level = self.mapItemData:GetLevel()
    local consumption = self.mapItemData:GetConsumption(level + 1)
    local ret = {}
    for itemId, count in pairs(consumption) do
        ret.itemId = itemId
        ret.count = count
        break
    end
    return ret
end

function CityGenerator:GetIsEnable()
    return self.enable
end

function CityGenerator:GetIsOverload()
    return self.overload
end

function CityGenerator:GetCanLock(zoneId)
    local ret = false
    local genConfig = self.mapItemData.config
    local zones_unlocked = genConfig.zones_unlocked
    local level = self.mapItemData:GetLevel()
    for i = 1, level, 1 do
        local lc = zones_unlocked[i]
        for key, value in pairs(lc) do
            if zoneId == key then
                ret = true
                break
            end
        end
    end
    return ret
end

function CityGenerator:GetStatus()
    return self.status
end

function CityGenerator:ConsumptionLeftTime()
    local count = DataManager.GetMaterialCount(self.cityId, self.itemId)
    local ret = math.ceil(count / self:GetConsumptionCount())
    return ret
end

function CityGenerator:UpdateTime()
    if self.enable then
        local cost = (self:GetConsumptionCount() / 60)
        cost = cost - self.tempAcc
        local intCost = math.ceil(cost)
        self.tempAcc = intCost - cost
        local count = DataManager.GetMaterialCount(self.cityId, self.itemId)
        local alarm = ConfigManager.GetMiscConfig("generator_consumption_alarm")
        if count < self:GetConsumptionCount() * alarm and self.status ~= "Lack" then
            self.status = "Lack"
            EventManager.Brocast(EventType.REFRESH_GENERATOR, self.cityId)
            FloatIconManager.SetConsumptionAwardIcon(true)
            LogWarning("原料快耗尽了")
        elseif count > self:GetConsumptionCount() * alarm and self.status == "Lack" then
            self.status = nil
            EventManager.Brocast(EventType.REFRESH_GENERATOR, self.cityId)
        end
        if count < intCost then
            self:CloseOverload()
            self:Close()
            Analytics.Event("GeneratorSwitch", {switchType = "close", from = "auto"})
            Analytics.Event("GeneratorOverloadSwitch", {switchType = "close", from = "auto"})
            self.status = "UseUp"
            FloatIconManager.SetConsumptionAwardIcon(true)
            EventManager.Brocast(EventType.REFRESH_GENERATOR, self.cityId)
            self:PlayAudioEffect("ui_toast_alert")
            LogWarning("没原料了")
            return
        end
        DataManager.UseMaterial(self.cityId, self.itemId, intCost, "Generator", self.mapItemData:GetLevel())
        StatisticalManager.AddInputProductions(self.cityId, self:GetZoneId(), self.itemId, intCost)
    end
end

-- 是否会导致缺乏
function CityGenerator:IsToLack(itemId, sonsumeCount)
    local result = {isLock = false, minute = 0}
    if itemId ~= self.itemId then 
        return result
    end

    local count = DataManager.GetMaterialCount(self.cityId, self.itemId) - sonsumeCount

    local alarm = ConfigManager.GetMiscConfig("generator_consumption_alarm")
    result.minute = alarm
    if count < self:GetConsumptionCount() * alarm then
        result.isLock = true
    end

    return result
end

function CityGenerator:GetTemperature()
    return self.mapItemData:GetTemperature()
end

function CityGenerator:CheckGeneratorAutoload()
    if GeneratorManager.GetIsEnable(self.cityId) then
        if
            CharacterManager.IsWarmAboveSafeLine(self.cityId) or
                GeneratorManager.ConsumptionLeftTime(self.cityId) < self.overdriveControl.constant_c
         then
            if GeneratorManager.GetIsOverload(self.cityId) then
                LogWarning("自动关闭过载")
                GeneratorManager.CloseOverload(self.cityId)
                Analytics.Event("GeneratorOverloadSwitch", {switchType = "close", from = "boost"})
            end
        else
            if
                not GeneratorManager.GetIsOverload(self.cityId) and
                    GeneratorManager.ConsumptionLeftTime(self.cityId) > self.overdriveControl.constant_c
             then
                LogWarning("自动开启过载")
                GeneratorManager.OpenOverload(self.cityId)
                Analytics.Event("GeneratorOverloadSwitch", {switchType = "open", from = "boost"})
            end
        end
    else
        if GeneratorManager.SumConsumptionLeftTime(self.cityId) > self.overdriveControl.constant_d then
            GeneratorManager.Open(self.cityId)
            LogWarning("自动开启火炉")
            Analytics.Event("GeneratorSwitch", {switchType = "open", from = "boost"})
        end
    end

    -- if TimeManager.GetCityIsNight(self.cityId) then
    --     if self.lastAutoStatus ~= "Night" then
    --         self.lastAutoStatus = "Night"
    --         if
    --             GeneratorManager.GetIsEnable(self.cityId) and not GeneratorManager.GetIsOverload(self.cityId) and
    --                 GeneratorManager.ConsumptionLeftTime(self.cityId) > 0 and
    --                 not CharacterManager.IsWarmAboveSafeLine(self.cityId)
    --          then
    --             GeneratorManager.OpenOverload(self.cityId)
    --             Analytics.Event("GeneratorOverloadSwitch", {type = "open", from = "boost"})
    --         end
    --     end
    -- else
    --     if self.lastAutoStatus ~= "Day" then
    --         self.lastAutoStatus = "Day"
    --         if
    --             GeneratorManager.GetIsEnable(self.cityId) and GeneratorManager.GetIsOverload(self.cityId) and
    --                 GeneratorManager.ConsumptionLeftTime(self.cityId) > 0 and
    --                 CharacterManager.IsWarmAboveSafeLine(self.cityId)
    --          then
    --             GeneratorManager.CloseOverload(self.cityId)
    --             Analytics.Event("GeneratorOverloadSwitch", {type = "close", from = "boost"})
    --         end
    --     end
    -- end
end
