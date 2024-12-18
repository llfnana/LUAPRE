FunctionHandles = {}
FunctionHandles.__cname = "FunctionHandles"
FunctionHandles.StatePreSecondFunc = {}

local this = FunctionHandles

function FunctionHandles.LoadConfig()
    this.sickRate = ConfigManager.GetFormulaConfigById("sickRate")       --患病率
    this.strikeRate = ConfigManager.GetFormulaConfigById("strikeRate")   --进球率; 得分率;
    this.leaveRate = ConfigManager.GetFormulaConfigById("leaveRate")     --休假率
    this.starveRate = ConfigManager.GetFormulaConfigById("starveRate")   --饿死率
    this.hungerBoost = ConfigManager.GetFormulaConfigById("hungerBoost") --饥饿
    this.restBoost = ConfigManager.GetFormulaConfigById("RestBoost")     --休息,睡眠时间
    this.funBoost = ConfigManager.GetFormulaConfigById("FunBoost")       --享乐
    this.neverGetSick = ConfigManager.GetMiscConfig("number_of_people_never_get_sick")
    this.neverGetStrike = ConfigManager.GetMiscConfig("number_of_people_never_strike_event")
    this.hungerSpeedBoost = ConfigManager.GetFormulaConfigById("hungerSpeedBoost") --饥饿速度
end

--normal状态小人每秒钟刷新函数
FunctionHandles.StatePreSecondFunc[EnumState.Normal] = function(character)
    character:AttributeDeltaPerSecond(AttributeType.Hunger)
    character:AttributeDeltaPerSecond(AttributeType.Rest)

    local eventRefresh = false
    local hunger = character:GetAttribute(AttributeType.Hunger)
    local hungerBoost = character:GetAttributeBoost(AttributeType.Hunger)
    if hunger < this.hungerBoost.constant_a then
        if hungerBoost ~= this.restBoost.constant_b then
            character:SetAttributeBoost(AttributeType.Hunger, this.restBoost.constant_b)
            eventRefresh = true
        end
    elseif hunger >= this.hungerBoost.constant_c then
        if hungerBoost ~= this.restBoost.constant_d then
            character:SetAttributeBoost(AttributeType.Hunger, this.restBoost.constant_d)
            eventRefresh = true
        end
    else
        if hungerBoost ~= 0 then
            character:SetAttributeBoost(AttributeType.Hunger, 0)
            eventRefresh = true
        end
    end
    local rest = character:GetAttribute(AttributeType.Rest)
    local restBoost = character:GetAttributeBoost(AttributeType.Rest)
    if rest < this.restBoost.constant_a then
        if restBoost ~= this.restBoost.constant_b then
            character:SetAttributeBoost(AttributeType.Rest, this.restBoost.constant_b)
            eventRefresh = true
        end
    elseif rest >= this.restBoost.constant_c then
        if restBoost ~= this.restBoost.constant_d then
            character:SetAttributeBoost(AttributeType.Rest, this.restBoost.constant_d)
            eventRefresh = true
        end
    else
        if restBoost ~= 0 then
            character:SetAttributeBoost(AttributeType.Rest, 0)
            eventRefresh = true
        end
    end

    if CityManager.GetIsEventScene(character.cityId) then
        character:AttributeDeltaPerSecond(AttributeType.Fun)
        local fun = character:GetAttribute(AttributeType.Fun)
        local funBoost = character:GetAttributeBoost(AttributeType.Fun)
        if fun < this.funBoost.constant_a then
            if funBoost ~= this.funBoost.constant_b then
                character:SetAttributeBoost(AttributeType.Fun, this.funBoost.constant_b)
                eventRefresh = true
            end
        elseif fun >= this.funBoost.constant_c then
            if funBoost ~= this.funBoost.constant_d then
                character:SetAttributeBoost(AttributeType.Fun, this.funBoost.constant_d)
                eventRefresh = true
            end
        else
            if funBoost ~= 0 then
                character:SetAttributeBoost(AttributeType.Fun, 0)
                eventRefresh = true
            end
        end
        local eventStrike = hunger
        local cause = "hunger"
        if eventStrike > rest then
            eventStrike = rest
            cause = "rest"
        end
        if eventStrike > fun then
            eventStrike = fun
            cause = "fun"
        end
        character:ShowEventStrikeToast(eventStrike)
        if character:GetSerialNumber() > this.neverGetStrike then
            if eventStrike < this.strikeRate.constant_c then
                local randomValue = math.random()
                if
                    randomValue <
                    ((1 - eventStrike / this.strikeRate.constant_c) *
                        (this.strikeRate.constant_a - this.strikeRate.constant_b) +
                        this.strikeRate.constant_b)
                then
                    character:SetNextState(EnumState.EventStrike)
                end
            end
        end
    else
        if character:GetSerialNumber() > this.neverGetSick and not ProtestManager.IsProtestStatus(character.cityId) then
            local randomValue = math.random()
            --更新幸存者生病
            if FunctionsManager.IsOpen(character.cityId, FunctionsType.SurvivorSick) then
                local warm = character:GetAttribute(AttributeType.Warm)
                if warm < this.sickRate.constant_c then
                    if
                        randomValue <
                        ((1 - warm / this.sickRate.constant_c) *
                            (this.sickRate.constant_a - this.sickRate.constant_b) +
                            this.sickRate.constant_b)
                    then
                        character:SetNextState(EnumState.Severe)
                    end
                end
            end
            --更新幸存者逃离
            if rest <= this.leaveRate.constant_a and randomValue < this.leaveRate.constant_b then
                character:SetNextState(EnumState.RunAway)
            end
            --更新幸存者饿死
            if hunger <= this.starveRate.constant_a and randomValue < this.starveRate.constant_b then
                if ConfigManager.GetMiscConfig("is_necessities_low_die") then
                    character:SetNextState(EnumState.Dead)
                else
                    character:SetNextState(EnumState.Severe)
                end
            end
        end
    end

    character:CheckWarningView()
    if eventRefresh then
        EventManager.Brocast(EventType.CHARACTER_ATTRIBUTE_BOOST, character.cityId)
    end
end

--Sick状态小人每秒钟刷新函数
FunctionHandles.StatePreSecondFunc[EnumState.Sick] = function(character)
    for key, value in pairs(character:GetHealNecessities()) do
        character:ReduceSickTime(value, false)
    end
end

--获取饱腹属性低的小人，在吃饭日程内获得额外的移速加成
function FunctionHandles.GetHungerSpeedBoost(character)
    local hunger = character:GetAttribute(AttributeType.Hunger)
    if hunger < this.hungerSpeedBoost.constant_a then
        return this.hungerSpeedBoost.constant_b
    end
    return 0
end

--设置实例对象朝向
function FunctionHandles.SetEntityForward(entity)
    local markerType = entity.currGrid.markerType
    if markerType == GridMarker.Protest or markerType == GridMarker.Protest2 then
        local speech = GridManager.GetGridByMarkerType(entity.cityId, GridMarker.Speech, ZoneType.MainRoad)
        if speech then
            -- 罢工的朝向有问题，关闭修改朝向
            -- entity.transform.forward = (speech.position - entity.transform.position).normalized
        end
    elseif markerType == GridMarker.Speech then
        entity.transform.forward = -entity.transform.forward
    end
end

--重制实例格子
function FunctionHandles.UpdateGrid(self, zoneId)
    if self.isMoveRunning then
        if self.targetGrid and self.targetGrid.zoneId == zoneId and self.targetGrid.markerType ~= GridMarker.Door then
            local grid =
                GridManager.GetGridByZoneId(
                    self.cityId,
                    self.targetGrid.zoneId,
                    self.targetGrid.markerType,
                    self.targetGrid.markerIndex,
                    self.targetGrid.serialNumber,
                    GridStatus.Unlock
                )
            if grid then
                self:ChangeTargeGrid(grid)
                self:StopMove()
                self:ChangeCurrGrid(grid, true)
                self:PlayAnimEx(AnimationType.Idle)
            end
        end
    else
        if self.currGrid.zoneId == zoneId then
            local grids =
                GridManager.GetGridsByZoneId(
                    self.cityId,
                    self.currGrid.zoneId,
                    self.currGrid.markerType,
                    GridStatus.Unlock
                )
            local grid = nil
            local minDistance = 0
            for i = 1, grids:Count(), 1 do
                if nil == grid then
                    grid = grids[i]
                    minDistance = Vector3.Distance(grids[i].position, self.transform.position)
                else
                    local distance = Vector3.Distance(grids[i].position, self.transform.position)
                    if distance < minDistance then
                        grid = grids[i]
                        minDistance = distance
                    end
                end
            end
            if grid then
                self:ChangeCurrGrid(grid, true)
            end
        end
    end
end

-- --计算健康值
-- function FunctionHandles.CalculateHealth(character)
--     if TestManager.IsLockHealth(character.cityId) then
--         return TestManager.GetLockHealth(character.cityId)
--     else
--         local a1 = character:GetAttribute(AttributeType.Warm)
--         local a2 = character:GetAttribute(AttributeType.Hunger)
--         local a3 = character:GetAttribute(AttributeType.Rest)

--         local fix_float = ConfigManager.GetFormulaConfigById("necessitiesFix").constant_a
--         local b1 = 100 - a1 * ((a1 / 100) ^ fix_float)
--         local b2 = 100 - a2 * ((a2 / 100) ^ fix_float)
--         local b3 = 100 - a3 * ((a3 / 100) ^ fix_float)

--         local all = (b1 + b2 + b3)
--         if all <= 0 then
--             all = 1
--         end
--         local c1 = (b1 ^ 2) / all
--         local c2 = (b2 ^ 2) / all
--         local c3 = (b3 ^ 2) / all
--         return 100 - (c1 + c2 + c3)
--     end
-- end

-- --计算幸福值
-- function FunctionHandles.CalculateHappness(character)
--     if TestManager.IsLockHappness(character.cityId) then
--         return TestManager.GetLockHappness(character.cityId)
--     else
--         local a1 = character:GetAttribute(AttributeType.Comfort)
--         local a2 = character:GetAttribute(AttributeType.Fun)
--         local a3 = character:GetAttribute(AttributeType.Security)

--         local fix_float = ConfigManager.GetFormulaConfigById("necessitiesFix").constant_b
--         local b1 = 100 - a1 * ((a1 / 100) ^ fix_float)
--         local b2 = 100 - a2 * ((a2 / 100) ^ fix_float)
--         local b3 = 100 - a3 * ((a3 / 100) ^ fix_float)

--         local all = (b1 + b2 + b3)
--         if all <= 0 then
--             all = 1
--         end
--         local c1 = (b1 ^ 2) / all
--         local c2 = (b2 ^ 2) / all
--         local c3 = (b3 ^ 2) / all
--         local happness = 100 - (c1 + c2 + c3)
--         return happness
--     end
-- end

-- --计算罢工
-- function FunctionHandles.CalculateEventStrike(character)
--     if TestManager.IsLockEventStrike(character.cityId) then
--         return TestManager.GetLockEventStrike(character.cityId)
--     else
--         local a1 = character:GetAttribute(AttributeType.Fun)
--         local a2 = character:GetAttribute(AttributeType.Hunger)
--         local a3 = character:GetAttribute(AttributeType.Rest)

--         local fix_float = ConfigManager.GetFormulaConfigById("necessitiesFix").constant_a
--         local b1 = 100 - a1 * ((a1 / 100) ^ fix_float)
--         local b2 = 100 - a2 * ((a2 / 100) ^ fix_float)
--         local b3 = 100 - a3 * ((a3 / 100) ^ fix_float)

--         local all = (b1 + b2 + b3)
--         if all <= 0 then
--             all = 1
--         end
--         local c1 = (b1 ^ 2) / all
--         local c2 = (b2 ^ 2) / all
--         local c3 = (b3 ^ 2) / all
--         return 100 - (c1 + c2 + c3)
--     end
-- end
