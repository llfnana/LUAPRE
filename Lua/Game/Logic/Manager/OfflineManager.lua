OfflineManager = {}
OfflineManager._name = "OfflineManager"

local this = OfflineManager

function OfflineManager.Init()
    this.cityId = DataManager.GetCityId()
    local offlineTimeStamp = TimeManager.GetCityOfflineTime(this.cityId)
    this.OnCalculate(GameManager.GameTime() - offlineTimeStamp, offlineTimeStamp)
end

--获取是否需要离线处理
function OfflineManager.GetNeedOffline()
    local isNeed = false
    if CityManager.IsEventScene(EventCityType.Club) then
        isNeed = TutorialManager.IsComplete(TutorialStep.EventSlot)
    elseif CityManager.IsEventScene(EventCityType.Water) then
        isNeed = TutorialManager.IsComplete(TutorialStep.EventSlot1002)
    elseif this.cityId == DataManager.GetMaxCityId() then
        isNeed = (DataManager.GetGlobalDataByKey(DataKey.NewUser) == false)
    -- LogWarning("DataKey.NewUser:" .. tostring(DataManager.GetGlobalDataByKey(DataKey.NewUser)))
    end
    return isNeed
end

--根据离线时间计算离线收益
function OfflineManager.OnCalculate(offlineTime, offlineTimeStamp)
    this.meetTime = false
    -- this.offlineOutput = nil
    -- this.offlineInput = nil
    -- LogWarning("GetNeedOffline:" .. tostring(this.GetNeedOffline()) .. "  " .. "offlineTime:" .. offlineTime)
    if this.GetNeedOffline() and offlineTime > 0 then
        --当前时间戳
        local currentTime = GameManager.GameTime()
        --离线时间
        this.realOfflineTime = offlineTime
        --最大离线展示时间
        local offlineMaxTime = this.GetOfflineMaxTime()
        --离线展示时间
        if offlineTime >= offlineMaxTime then
            offlineTime = offlineMaxTime
        end

        --根据离线时间转换为离线的游戏内天数（游戏24小时，现实时间12分钟）
        local offlineDay, offlineScale = math.modf(offlineTime / 720)
        local offlineHours = math.floor(offlineScale * 24)
        local offlineMinutes = math.floor(offlineScale * 60)
        TimeManager.RefreshClock(this.cityId, offlineMinutes, offlineHours, offlineDay)

        this.meetTime = false
        --是否展示离线面板
        if offlineTime >= ConfigManager.GetOfflineTime() then
            this.meetTime = true
        end

        --离线处理角色数据
        local characterData = DataManager.GetCityDataByKey(this.cityId, DataKey.CharacterData)
        local deadList = List:New()
        local healList = List:New()
        local peopleTotal = 0
        local peopleProtest = 0
        local function EachCharacterInfo(info, timeStamp)
            if next(info) == nil then
                return true
            elseif info.state == EnumState.Dead then
                return true
            elseif info.state == EnumState.Sick then
                local sickInfo = info.sickInfo
                if nil == sickInfo then
                    return true
                else
                    sickInfo.sickTime = sickInfo.sickTime - (timeStamp - sickInfo.sickTimeStamp)
                    if sickInfo.sickTime <= 0 then
                        if nil == sickInfo.healRate then
                            return true
                        end
                        if math.random() > sickInfo.healRate then
                            return true
                        else
                            healList:Add(info.id)
                            info.attributeInfo[AttributeType.Hunger] =
                                ConfigManager.GetNecessitiesStartValue(this.cityId, AttributeType.Hunger)
                            info.attributeInfo[AttributeType.Rest] =
                                ConfigManager.GetNecessitiesStartValue(this.cityId, AttributeType.Rest)
                            info.state = EnumState.Normal
                            info.sickInfo = nil
                        end
                    else
                        sickInfo.sickTimeStamp = timeStamp
                    end
                end
            elseif info.state == EnumState.Protest then
                peopleProtest = peopleProtest + 1
            end
            return false
        end
        for id, info in pairs(characterData.infos) do
            peopleTotal = peopleTotal + 1
            if EachCharacterInfo(info, currentTime) then
                deadList:Add(id)
            end
        end
        this.offlineDeadCount = deadList:Count()
        this.offlineHealCount = healList:Count()
        --删除角色
        if this.offlineDeadCount > 0 then
            local param = {}
            param.from = "offline"
            param.value = this.offlineDeadCount
            param.cause = "SickDead"
            Analytics.TraceEvent("PeopleDead", param)
            deadList:ForEach(
                function(id)
                    characterData.infos[id] = nil
                end
            )
            --填充死亡数据
            if characterData.fillTypes[FillType.Dead] then
                characterData.fillTypes[FillType.Dead].time = currentTime
                characterData.fillTypes[FillType.Dead].count =
                    characterData.fillTypes[FillType.Dead].count + this.offlineDeadCount
            else
                characterData.fillTypes[FillType.Dead] = {}
                characterData.fillTypes[FillType.Dead].time = currentTime
                characterData.fillTypes[FillType.Dead].count = this.offlineDeadCount
            end
            CityPassManager.AddDeathCount(this.offlineDeadCount)
        end
        if healList:Count() > 0 then
            local param = {}
            param.from = "offline"
            param.value = this.offlineHealCount
            Analytics.TraceEvent("PeopleHeal", param)
        end
        DataManager.SetCityDataByKey(this.cityId, DataKey.CharacterData, characterData)

        --计算离线挂机战斗
        local level = CardManager.GetBattleLevel()
        LogWarning("level:" .. tostring(level))
        -- if level >= 2 then
        --     AdventureContManager.CalOfflineReward(this.realOfflineTime)
        --     AdventureContManager.CalHangUpReward(CardManager.cardData.hangupRemaintime, this.realOfflineTime)
        --     AdventureContManager.SetMainBattleRD()
        -- end

        --计算离线奖励
        local totalOutput = {}
        local totalInput = {}
        local produceInfos, produceItemIds, produceHeart = StatisticalManager.GetOfflineProductions(this.cityId)
        --根据离线时间转换为离线的游戏内天数（游戏24小时，现实时间12分钟）
        local function CalculateOffline(time, factor)
            if time <= 0 then
                return
            end
            local roundDay, roundScale = math.modf(time / 720)
            -- local factor = offlineFactor * scale
            local output, input =
                this.CalculateOutputByRound(roundDay, roundScale, factor, produceInfos, produceItemIds, produceHeart)
            for itemId, itemCount in pairs(output) do
                if totalOutput[itemId] then
                    totalOutput[itemId] = totalOutput[itemId] + itemCount
                else
                    totalOutput[itemId] = itemCount
                end
            end
            for itemId, itemCount in pairs(input) do
                if totalInput[itemId] then
                    totalInput[itemId] = totalInput[itemId] + itemCount
                else
                    totalInput[itemId] = itemCount
                end
            end
        end

        --离线暴动时间
        local offlineProtestTime = 0
        --暴动功能是否解锁
        if FunctionsManager.IsOpen(this.cityId, FunctionsType.Protest) then
            local protestData = DataManager.GetCityDataByKey(this.cityId, DataKey.ProtestData)
            if protestData and protestData.status == ProtestStatus.Run then
                offlineProtestTime = protestData.statusEndTime - offlineTimeStamp
            end
        end
        if offlineProtestTime > offlineTime then
            offlineProtestTime = offlineTime
        end

        local offlineFactor = ConfigManager.GetMiscConfig("offline_final_factor")
        --计算暴动时间产出
        local protestFactor = 1 - peopleProtest / peopleTotal
        LogFormat(
            "peopleProtest = {0}, peopleTotal = {1}, protestFactor = {2}",
            peopleProtest,
            peopleTotal,
            protestFactor
        )
        CalculateOffline(offlineProtestTime, offlineFactor * protestFactor)
        --计算非暴动时间产出
        CalculateOffline(offlineTime - offlineProtestTime, offlineFactor)

        this.offlineTime = offlineTime
        this.offlineReward = {}

        
        -- this.offlineOutput = totalOutput
        -- this.offlineInput = totalInput
        for itemId, itemCount in pairs(totalOutput) do
            this.offlineReward[itemId] = itemCount
        end
        for itemId, itemCount in pairs(totalInput) do
            if this.offlineReward[itemId] then
                this.offlineReward[itemId] = this.offlineReward[itemId] - itemCount
            else
                this.offlineReward[itemId] = 0 - itemCount
            end
        end

        --保存离线奖励
        local needSave = false
        if totalOutput then
            for itemId, itemCount in pairs(totalOutput) do
                DataManager.AddMaterial(this.cityId, itemId, itemCount, "OfflineReward", "OfflineReward")
            end
            needSave = true
        end
        if totalInput then
            for itemId, itemCount in pairs(totalInput) do
                DataManager.UseMaterial(this.cityId, itemId, itemCount, "OfflineReward", "OfflineReward")
            end
            needSave = true
        end
        if needSave then
            DataManager.SaveAll()
        end

        -- --保存离线奖励
        -- for itemId, itemCount in pairs(this.offlineReward) do
        --     DataManager.AddMaterial(this.cityId, itemId, itemCount, "OfflineReward", "OfflineReward")
        -- end
        LogWarningFormat("离线时间 = {0}, 离线天数 = {1}, 离线当天进度 = {2}", offlineTime, offlineDay, offlineScale)

        -- 计算广告收益(广告收益不需要扣除材料消耗，就纯产出)
        local _, second = AdManager.GetMaxCountAndRewardFromConfig(AdSourceType.UIOffline)
        this.adOfflineTime = second
        this.adOfflineReward = {}

        totalOutput = {}
        totalInput = {}
        CalculateOffline(this.adOfflineTime, offlineFactor)
        for itemId, itemCount in pairs(totalOutput) do
            this.adOfflineReward[itemId] = itemCount
        end
    end
end



--离线显示
function OfflineManager.InitView()
    GameManager.SetOfflineAction(GameAction.OfflineInit)
    if this.GetNeedOffline() then
        -- --添加离线奖励
        if this.meetTime and not GameManager.TutorialOpen then
            LogWarning("弹出离线面板")
            GameManager.SetOfflineAction(GameAction.OfflineShow)
            TutorialManager.isOpeningUIOffline = true
            ShowUI(UINames.UIOffline)
        else
            GameManager.SetOfflineAction(GameAction.OfflineNo)
            EventManager.Brocast(EventDefine.OnOfflineOver)
        end
    else
        GameManager.SetOfflineAction(GameAction.OfflineNo)
        EventManager.Brocast(EventDefine.OnOfflineOver)
    end
end

--根据真实时间计算产出
function OfflineManager.CalculateOutputByTime(time)
    local roundDay, roundScale = math.modf(time / 720)
    local produceInfos, produceItemIds, produceHeart = StatisticalManager.GetOfflineProductions(this.cityId)
    return this.CalculateOutputByRound(roundDay, roundScale, 1, produceInfos, produceItemIds, produceHeart)
end

--根据游戏内经过了几天计算产出
function OfflineManager.CalculateOutputByRound(roundDay, roundScale, factor, produceInfos, produceItemIds, produceHeart)
    --离线相关物品数量
    local tempItemCount = {}
    --计算离线过程总的消耗
    local totalInput = {}
    --计算离线过程的总的产出
    local totalOutput = {}
    --填充离线消耗
    local function AddItemInput(itemId, itemCount)
        if tempItemCount[itemId] then
            tempItemCount[itemId] = tempItemCount[itemId] - itemCount
            if tempItemCount[itemId] < 0 then
                tempItemCount[itemId] = 0
            end
        else
        end
        if totalInput[itemId] then
            totalInput[itemId] = totalInput[itemId] + itemCount
        else
            totalInput[itemId] = itemCount
        end
    end
    --填充离线产出
    local function AddItemOutput(itemId, itemCount)
        if tempItemCount[itemId] then
            tempItemCount[itemId] = tempItemCount[itemId] + itemCount
        end
        if totalOutput[itemId] then
            totalOutput[itemId] = totalOutput[itemId] + itemCount
        else
            totalOutput[itemId] = itemCount
        end
    end

    --获取离线时游戏内的单位时间产出,离线过程中会影响的物品id列表
    produceItemIds:ForEach(
        function(itemId)
            if nil == tempItemCount[itemId] then
                tempItemCount[itemId] = DataManager.GetMaterialCount(this.cityId, itemId)
            end
        end
    )
    --卡车数量
    -- local vanLoadPortMax = 0
    -- local vanLoadPortIndex = 0
    -- local vanLoadRecord = List:New()
    -- local vanWaitTime = 0
    -- local vanCount = EventSceneManager.GetVanCount()
    -- local vanLoadPorts = EventSceneManager.GetVanLoadPorts(VanLoadPortType.CanUse)
    -- local vanProductionLog = {}
    -- local vanLoadPortLog = {}

    -- if vanLoadPorts then
    --     vanLoadPortMax = #vanLoadPorts
    --     local totlaUsageDuration = 0
    --     for index, info in pairs(vanLoadPorts) do
    --         totlaUsageDuration = totlaUsageDuration + info.usageDuration
    --         for itemId, itemCount in pairs(info.loadLimit) do
    --             if nil == tempItemCount[itemId] then
    --                 tempItemCount[itemId] = DataManager.GetMaterialCount(this.cityId, itemId)
    --             end
    --         end
    --     end
    --     vanWaitTime = totlaUsageDuration / vanLoadPortMax
    --     for i = 1, vanCount, 1 do
    --         local info = {}
    --         info.index = i
    --         info.time = 0
    --         vanLoadRecord:Add(info)
    --     end
    --     --卡车log记录
    --     for i = 1, vanCount, 1 do
    --         local log = {}
    --         log.workCount = 0
    --         log.waitCount = 0
    --         log.workInput = {}
    --         log.workOutput = {}
    --         vanProductionLog[i] = log
    --     end
    -- end

    -- --获取可用的卡车加载点
    -- local function GetVanLoadPort()
    --     if nil == vanLoadPorts then
    --         return nil
    --     end
    --     if vanLoadPortIndex > vanLoadPortMax then
    --         return nil
    --     end
    --     for i = vanLoadPortIndex, vanLoadPortMax, 1 do
    --         local vanLoadPort = vanLoadPorts[i]
    --         local isFull = true
    --         for itemId, itemCount in pairs(vanLoadPort.loadLimit) do
    --             if tempItemCount[itemId] < itemCount then
    --                 isFull = false
    --             end
    --         end
    --         if isFull then
    --             vanLoadPortIndex = i
    --             return vanLoadPort
    --         end
    --     end
    --     return nil
    -- end

    --打印库存
    for itemId, itemCount in pairs(tempItemCount) do
        LogWarningFormat("itemId = {0}, itemCount = {1}", itemId, itemCount)
    end

    local function EachOfflineZone(zoneId, zoneData, dayScale)
        --库存资源比例
        local minScale = 1
        --真实消耗判断仓库是否充足，获取消耗系数
        for itemId, itemCount in pairs(zoneData.inputInfo) do
            local tempScale = tempItemCount[itemId] / itemCount
            if tempScale < minScale then
                minScale = tempScale
            end
        end

        if minScale > 0 then
            local realScale = 0
            --炉子的消耗不受总体比例影响
            if ConfigManager.GetZoneConfigById(zoneId).zone_type == ZoneType.Generator then
                realScale = minScale * dayScale
            else
                realScale = minScale * dayScale * factor
            end
            --真实消耗
            for itemId, itemCount in pairs(zoneData.inputInfo) do
                local inputValue = realScale * itemCount
                if inputValue > 0 then
                    AddItemInput(itemId, inputValue)
                end
            end
            --真实生产
            for itemId, itemCount in pairs(zoneData.outputInfo) do
                local outputValue = realScale * itemCount
                if outputValue > 0 then
                    AddItemOutput(itemId, outputValue)
                end
            end
        end
    end

    --离线游戏内每天的建筑产出处理
    local function EachOfflineRound(roundFactor)
        produceInfos:ForEachKeyValue(
            function(zoneId, zoneData)
                EachOfflineZone(zoneId, zoneData, roundFactor)
            end
        )
    end

    -- --离线内对每天的卡车生产处理
    -- local function EachVanRound(roundFactor)
    --     if vanCount <= 0 then
    --         return
    --     end
    --     if vanLoadPortMax == 0 then
    --         LogWarning("任何兑换点都资源不足")
    --         return
    --     end
    --     --游戏内一天的真实事件
    --     local dayTime = roundFactor * 12 * 60
    --     LogWarningFormat("dayTime = {0}", dayTime)
    --     --更新卡车加载记录
    --     vanLoadRecord:ForEach(
    --         function(record)
    --             if record.time >= 720 then
    --                 record.time = record.time - 720
    --             end
    --         end
    --     )
    --     --添加卡车生产log
    --     local function AddLogVanWork(van, costId, costCount, output)
    --         local log = vanProductionLog[van.index]
    --         log.workCount = log.workCount + 1
    --         --添加消耗
    --         if log.workInput[costId] then
    --             log.workInput[costId] = log.workInput[costId] + costCount
    --         else
    --             log.workInput[costId] = costCount
    --         end
    --         --添加产出
    --         for itemId, itemCount in pairs(output) do
    --             if log.workOutput[itemId] then
    --                 log.workOutput[itemId] = log.workOutput[itemId] + itemCount
    --             else
    --                 log.workOutput[itemId] = itemCount
    --             end
    --         end
    --     end
    --     --添加卡车加载口log
    --     local function AddLogLoadPortCount(furnitureId)
    --         if vanLoadPortLog[furnitureId] then
    --             vanLoadPortLog[furnitureId] = vanLoadPortLog[furnitureId] + 1
    --         else
    --             vanLoadPortLog[furnitureId] = 1
    --         end
    --     end
    --     --添加卡车等待log
    --     local function AddLogVanWait(van)
    --         local log = vanProductionLog[van.index]
    --         log.waitCount = log.waitCount + 1
    --     end

    --     --计算卡车生产
    --     local function CalculateVanProduction()
    --         vanLoadPortIndex = 1
    --         local canWorkVans = List:New()
    --         for index, info in pairs(vanLoadRecord) do
    --             if info.time < dayTime then
    --                 canWorkVans:Add(info)
    --             end
    --         end
    --         if canWorkVans:Count() > 0 then
    --             --按照加载时间排序
    --             canWorkVans:Sort(
    --                 function(info1, info2)
    --                     if info1.time == info2.time then
    --                         return info1.index < info2.index
    --                     else
    --                         return info1.time < info2.time
    --                     end
    --                 end
    --             )
    --             canWorkVans:ForEach(
    --                 function(van)
    --                     local vanLoadPort = GetVanLoadPort()
    --                     vanLoadPortIndex = vanLoadPortIndex + 1
    --                     local recordTime = 0
    --                     local vanLog = string.format("vanIndex = %s,", van.index)
    --                     if vanLoadPort then
    --                         --获取根据家具 获取卡车路径长度
    --                         recordTime =
    --                             EventSceneManager.GetVanMoveTime(vanLoadPort.furnitureId) + vanLoadPort.usageDuration
    --                         for itemId, itemCount in pairs(vanLoadPort.loadLimit) do
    --                             --添加卡车消耗
    --                             AddItemInput(itemId, itemCount)
    --                             local output = EventSceneManager.ExchangeCashFormula(itemId, itemCount)
    --                             for iItemId, iItemCount in pairs(output) do
    --                                 --添加卡车产出
    --                                 AddItemOutput(iItemId, iItemCount)
    --                             end
    --                             --log
    --                             AddLogVanWork(van, itemId, itemCount, output)
    --                         end
    --                         --log
    --                         AddLogLoadPortCount(vanLoadPort.furnitureId)
    --                         vanLog =
    --                             vanLog ..
    --                             string.format(
    --                                 "portId = %s,portIndex = %s,",
    --                                 vanLoadPort.furnitureId,
    --                                 vanLoadPort.furnitureIndex
    --                             )
    --                     else
    --                         recordTime = vanWaitTime
    --                         --log
    --                         AddLogVanWait(van)
    --                     end
    --                     van.time = van.time + recordTime
    --                     vanLog = vanLog .. string.format("vanTime = %s", van.time)
    --                     LogWarning(vanLog)
    --                 end
    --             )
    --             CalculateVanProduction()
    --         end
    --     end
    --     --执行计算卡车生产
    --     CalculateVanProduction()
    --end

    --离线内对每天的爱心产出
    local function EachProduceHeart(scale)
        if produceHeart <= 0 then
            return
        end
        local itemConfig = ConfigManager.GetItemByType(this.cityId, ItemType.Heart)
        if nil == itemConfig then
            return
        end
        AddItemOutput(itemConfig.id, produceHeart * scale)
    end

    for i = 1, roundDay, 1 do
        EachOfflineRound(1)
        --EachVanRound(1)
        EachProduceHeart(1)
    end
    if roundScale > 0 then
        EachOfflineRound(roundScale)
       -- EachVanRound(roundScale)
        EachProduceHeart(roundScale)
    end
    -- for itemId, itemCount in pairs(totalOutput) do
    -- end
    -- for itemId, itemCount in pairs(totalInput) do
    -- end
    -- for vanIndex, log in pairs(vanProductionLog) do
    --     LogWarningFormat("vanIndex = {0}, workCount = {1}, waitCount = {1}", vanIndex, log.workCount, log.waitCount)
    --     -- for itemId, itemCount in pairs(log.workInput) do
    --     -- end
    --     -- for itemId, itemCount in pairs(log.workOutput) do
    --     -- end
    -- end
    -- for furnitureId, count in pairs(vanLoadPortLog) do
    --     LogWarningFormat("离线furnitureId = {0}, count = {1}", furnitureId, count)
    -- end
    return totalOutput, totalInput
end

function OfflineManager.GetOfflineMaxTime()
    return ConfigManager.GetMiscConfig("default_max_offline_time") +
        BoostManager.GetRxBoosterValue(this.cityId, RxBoostType.OfflineTime)
end

-- 获取观看广告奖励（显示奖励界面）
function OfflineManager.GetAdReward()
    if this.adOfflineReward then
        local formatReward = {}
        for key, value in pairs(this.adOfflineReward) do
            table.insert(formatReward, {
                addType = RewardAddType.Item, 
                id = key, 
                count = value
            })
        end

        ResAddEffectManager.AddResEffectFromRewards(formatReward, true)
        for itemId, itemCount in pairs(this.adOfflineReward) do
            DataManager.AddMaterial(this.cityId, itemId, itemCount, "OfflineAdReward", "OfflineAdReward")
        end
        DataManager.SaveAll()
    end
end
