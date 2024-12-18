local Test_Setting_Path = "Assets/ResourcesLocal/Test_Setting.json"
local Test_Log_Path = "Assets/ResourcesLocal/Test_Log_%d.json"
---@class CityTest
CityTest = Clone(CityBase)
CityTest.__cname = "CityTest"

function CityTest:OnInit()
    self:LoadTest()
    self:InitTest()
end

function CityTest:LoadTest()
    --初始化测试设置
    local function InitTestSetting()
        local data = {}
        --game
        data.gameSpeed = 1
        --ai
        data.aiRunning = false
        data.aiSpeed = 1
        data.aiRunningDay = -1
        data.aiStopWait = -1
        data.aiPrintLog = false
        data.aiRunTime = 0
        --character
        data.isLockHealth = false
        data.lockHealth = 0
        data.isLockEventStrike = false
        data.lockEventStrike = 0
        data.isLockHope = false
        data.lockHope = 0
        data.isLockHappness = false
        data.lockHappness = 0
        --art
        data.isLockSchedules = false
        data.lockSchedules = SchedulesType.None
        data.isTeleport = false
        return data
    end

    local cityKey = tostring(self.cityId)

    if TestManager.isUseTest then
        local settingStr = nil
        --if Application.platform ~= RuntimePlatform.Android and Application.platform ~= RuntimePlatform.IPhonePlayer then
        --    local file = io.open(Test_Setting_Path, "r")
        --    if file then
        --        settingStr = file:read("a")
        --        file:flush()
        --        file:close()
        --    end
        --end
        if not settingStr then
            self.testSettting = {}
        else
            self.testSettting = JSON.decode(settingStr)
        end
        if not self.testSettting[cityKey] then
            self.testSettting[cityKey] = InitTestSetting()
            self:SaveTest()
        end
    else
        self.testSettting = {}
        self.testSettting[cityKey] = InitTestSetting()
    end
end

function CityTest:InitTest()
    self.aiRunTime = NumberRx:New(self:GetTestSetting().aiRunTime)
    self.aiRunTime:subscribe(
        function(val)
            self:GetTestSetting().aiRunTime = val
            self:SaveTest()
        end
    )
    self.aiRunning = NumberRx:New(self:GetTestSetting().aiRunning)
    self.aiRunning:subscribe(
        function(val)
            self:GetTestSetting().aiRunning = val
            if not val then
                self.aiRunTime.value = 0
            end
            self.tempSecond = 5
            if val then
                self:GetTestSetting().aiBeginTime = TimeManager.GameTime()
                self:GetTestSetting().aiUpgradeTime = TimeManager.GameTime()
            end
            self:SaveTest()
        end
    )
    self.aiGameSpeed = NumberRx:New(self:GetTestSetting().aiSpeed)
    self.aiGameSpeed:subscribe(
        function(val)
            self:GetTestSetting().aiSpeed = val
            self:SaveTest()
        end
    )
    self.gameSpeed = NumberRx:New(self:GetTestSetting().gameSpeed or false)
    self.gameSpeed:subscribe(
        function(val)
            self:GetTestSetting().gameSpeed = val
            self:SaveTest()
        end
    )
    self.moveTeleport = NumberRx:New(self:GetTestSetting().isTeleport)
    self.moveTeleport:subscribe(
        function(val)
            self:GetTestSetting().isTeleport = val
            self:SaveTest()
        end
    )
    self.aiRunningDay = NumberRx:New(self:GetTestSetting().aiRunningDay)
    self.aiRunningDay:subscribe(
        function(val)
            self:GetTestSetting().aiRunningDay = val
            self:SaveTest()
        end
    )
    self.aiStopWait = NumberRx:New(self:GetTestSetting().aiStopWait)
    self.aiStopWait:subscribe(
        function(val)
            self:GetTestSetting().aiStopWait = val
            self:SaveTest()
        end
    )
    self.aiPrintLog = NumberRx:New(self:GetTestSetting().aiPrintLog)
    self.aiPrintLog:subscribe(
        function(val)
            self:GetTestSetting().aiPrintLog = val
            self:SaveTest()
        end
    )
    self.isLockHealth = NumberRx:New(self:GetTestSetting().isLockHealth)
    self.isLockHealth:subscribe(
        function(val)
            self:GetTestSetting().isLockHealth = val
            self:SaveTest()
        end
    )
    self.lockHealth = NumberRx:New(self:GetTestSetting().lockHealth)
    self.lockHealth:subscribe(
        function(val)
            self:GetTestSetting().lockHealth = val
            self:SaveTest()
        end
    )
    self.isLockEventStrike = NumberRx:New(self:GetTestSetting().isLockEventStrike)
    self.isLockEventStrike:subscribe(
        function(val)
            self:GetTestSetting().isLockEventStrike = val
            self:SaveTest()
        end
    )
    self.lockEventStrike = NumberRx:New(self:GetTestSetting().lockEventStrike)
    self.lockEventStrike:subscribe(
        function(val)
            self:GetTestSetting().lockEventStrike = val
            self:SaveTest()
        end
    )
    self.isLockHope = NumberRx:New(self:GetTestSetting().isLockHope)
    self.isLockHope:subscribe(
        function(val)
            self:GetTestSetting().isLockHope = val
            self:SaveTest()
        end
    )
    self.lockHope = NumberRx:New(self:GetTestSetting().lockHope)
    self.lockHope:subscribe(
        function(val)
            self:GetTestSetting().lockHope = val
            self:SaveTest()
        end
    )
    self.isLockHappness = NumberRx:New(self:GetTestSetting().isLockHappness)
    self.isLockHappness:subscribe(
        function(val)
            self:GetTestSetting().isLockHappness = val
            self:SaveTest()
        end
    )
    self.lockHappness = NumberRx:New(self:GetTestSetting().lockHappness)
    self.lockHappness:subscribe(
        function(val)
            self:GetTestSetting().lockHappness = val
            self:SaveTest()
        end
    )
    self.isLockSchedules = NumberRx:New(self:GetTestSetting().isLockSchedules)
    self.isLockSchedules:subscribe(
        function(val)
            self:GetTestSetting().isLockSchedules = val
            self:SaveTest()
        end
    )
    self.lockSchedules = NumberRx:New(self:GetTestSetting().lockSchedules)
    self.lockSchedules:subscribe(
        function(val)
            self:GetTestSetting().lockSchedules = val
            self:SaveTest()
        end
    )
    self.isEventScene = CityManager.GetIsEventScene(self.cityId)
end

--获取测试设置
function CityTest:GetTestSetting()
    return self.testSettting[tostring(self.cityId)]
end

function CityTest:SaveTest()
    --if Application.platform ~= RuntimePlatform.Android and Application.platform ~= RuntimePlatform.IPhonePlayer then
    --    local json = JSON.encode(self.testSettting)
    --    local settingFile = io.open(Test_Setting_Path, "w")
    --    settingFile:write(json)
    --    settingFile:flush()
    --    settingFile:close()
    --end
end

--保存log
function CityTest:SaveTestLog(log)
    --if Application.platform ~= RuntimePlatform.Android and Application.platform ~= RuntimePlatform.IPhonePlayer then
        local logFile = io.open(string.format(Test_Log_Path, self.cityId), "a")
        logFile:write("\n" .. log)
        logFile:flush()
        logFile:close()
    --end
end

--清理
function CityTest:OnClear()
    self = nil
end

-------------------------------------------------------------------
-------------------------------------------------------------------
-------------------------------------------------------------------
--真实时间每秒刷新
function CityTest:TimeRealPerSecondFunc()
    if not self.aiRunning.value then
        return
    end
    self.aiRunTime.value = self.aiRunTime.value + 1
    if self.tempSecond >= 1 then
        self.tempSecond = self.tempSecond - 1
        if self:CheckAITestIsWork() then
            self:CheckZonesAndFurnitures()
            self:CheckAssignCharacter()
            self:CheckGenerator()
            self:CheckUpgradeCardLevel()
            self:CheckGetTaskReward()
            self:CheckSlotSpin()
            self:CheckUpgradeTrickLevel()
        end
    else
        self.tempSecond = self.tempSecond + 1
    end
end

--建造区域事件响应
function CityTest:UpgradeZoneFunc(zoneId, zoneType, level)
    if self.aiRunning.value then
        local mapItemData = MapManager.GetMapItemData(self.cityId, zoneId)
        if mapItemData then
            mapItemData:OpenRoof()
        end
    end
end

--检测AI是否可以运行
function CityTest:CheckAITestIsWork()
    local aiDuration = TimeManager.GameTime() - self:GetTestSetting().aiBeginTime
    if self.aiRunningDay.value ~= -1 and aiDuration >= self.aiRunningDay.value * 24 * 60 * 60 then
        self:GetTestSetting().aiDration = aiDuration
        self:GetTestSetting().aiEndMsg = "总时间达到上限结束"
        self.aiRunning.value = false
        return false
    end
    local aiUpgradeInterval = TimeManager.GameTime() - self:GetTestSetting().aiUpgradeTime
    if aiUpgradeInterval >= 48 * 60 * 60 then
        self:GetTestSetting().aiDration = aiDuration
        self:GetTestSetting().aiEndMsg = "等待升级时间过长,困难终止"
        self.aiRunning.value = false
        return false
    end
    -- if MapManager.GetCurrentExp(self.cityId) >= MapManager.GetTotalExp(self.cityId) then
    --     self:GetTestSetting().aiDration = aiDuration
    --     self:GetTestSetting().aiEndMsg = "此场景全部升级无可再升,正常结束"
    --     self.aiRunning.value = false
    --     return false
    -- end
    return true
end
--检测建筑和家具是否可以建造升级
function CityTest:CheckZonesAndFurnitures()
    local cityClock = TimeManager.GetCityClock(self.cityId)
    if (cityClock < 700 or cityClock > 1800) and GeneratorManager.ConsumptionLeftTime(self.cityId) < 5 then
        return
    end
    local zoneInfos = List:New()
    local toolInfos = List:New()
    local boostInfos = List:New()
    local upgradingZoneCount = 0
    local allCostInfos = {}
    local selectZoneInfos = List:New()
    local selectToolInfos = List:New()
    local selectBoostInfos = List:New()
    --遍历Tool家具
    local function EachToolFurnitureFunc(mapItemData)
        local lv = mapItemData:GetToolLevel()
        local ms, msMinLv, msMaxLv = mapItemData:GetToolMilestone()
        local maxLv = mapItemData:GetToolMaxLevel()
        if msMaxLv ~= nil and lv < maxLv then
            local buildCost = mapItemData:GetToolUpgradeCost()
            if DataManager.GetMaterialCount(self.cityId, buildCost.itemId) < buildCost.count then
                return
            end
            local info = {}
            info.mapItemData = mapItemData
            info.buildCost = buildCost
            toolInfos:Add(info)
        end
    end
    --遍历Boost家具
    local function EachBoostFurnitureFunc(mapItemData)
        local lv = mapItemData:GetBoostLevel()
        local ms, msMinLv, msMaxLv = mapItemData:GetBoostMilestone()
        local maxLv = mapItemData:GetBoostMaxLevel()
        if msMaxLv ~= nil and lv < maxLv then
            local buildCost = mapItemData:GetBoostUpgradeCost()
            if DataManager.GetMaterialCount(self.cityId, buildCost.itemId) < buildCost.count then
                return
            end
            local info = {}
            info.mapItemData = mapItemData
            info.buildCost = buildCost
            boostInfos:Add(info)
        end
    end
    --遍历建筑物
    local function EachZoneFunc(mapItemData, buildStatus)
        if mapItemData:GetLevel() < mapItemData.config.max_level then
            local unlockData = mapItemData:GetUnlockLevelIsReady()
            local costConfig = mapItemData:GetUnlockLevelCost()
            local costIsReady = mapItemData:GetUnlockLevelCostIsReady()
            local canUpgrade = costIsReady and unlockData["AllReady"]
            if canUpgrade then
                local ret = false
                local totalCost = 0
                for itemId, itemCount in pairs(costConfig) do
                    totalCost = totalCost + itemCount
                    if DataManager.GetMaterialCount(self.cityId, itemId) < itemCount then
                        ret = true
                    end
                end
                if ret then
                    return
                end
                if upgradingZoneCount >= 2 then
                    return
                end
                local info = {}
                info.mapItemData = mapItemData
                info.costConfig = costConfig
                info.totalCost = totalCost
                info.buildStatus = buildStatus
                zoneInfos:Add(info)
            end
        end
    end
    --遍历建筑物
    for zoneId, mapItemData in pairs(MapManager.GetMap(self.cityId).mapItemDataList) do
        local buildStatus = mapItemData:GetBuildStatus()
        if buildStatus == BuildingStatus.Empty then
            EachZoneFunc(mapItemData, buildStatus)
        elseif buildStatus == BuildingStatus.Complete then
            if not mapItemData:IsUpgrading() then
                EachZoneFunc(mapItemData, buildStatus)
                mapItemData:OpenRoof()
                if mapItemData:IsHaveToolFurniture() then
                    EachToolFurnitureFunc(mapItemData)
                end
                if mapItemData:IsHaveBoostFurniture() then
                    EachBoostFurnitureFunc(mapItemData)
                end
            else
                upgradingZoneCount = upgradingZoneCount + 1
            end
        elseif buildStatus == "Building" then
            upgradingZoneCount = upgradingZoneCount + 1
        end
    end

    local isSelectCompleted = false
    if zoneInfos:Count() > 0 then
        zoneInfos:Sort(
            function(a, b)
                return a.totalCost < b.totalCost
            end
        )
        for index, info in pairs(zoneInfos) do
            for itemId, itemCount in pairs(info.costConfig) do
                if nil == allCostInfos[itemId] then
                    allCostInfos[itemId] = 0
                end
                allCostInfos[itemId] = allCostInfos[itemId] + itemCount
                if DataManager.GetMaterialCount(self.cityId, itemId) >= allCostInfos[itemId] then
                    selectZoneInfos:Add(info)
                else
                    isSelectCompleted = true
                    break
                end
            end
        end
    end
    if toolInfos:Count() > 0 and not isSelectCompleted then
        toolInfos:Sort(
            function(a, b)
                return a.buildCost.count < b.buildCost.count
            end
        )
        for key, info in pairs(toolInfos) do
            if nil == allCostInfos[info.buildCost.itemId] then
                allCostInfos[info.buildCost.itemId] = 0
            end
            allCostInfos[info.buildCost.itemId] = allCostInfos[info.buildCost.itemId] + info.buildCost.count
            if DataManager.GetMaterialCount(self.cityId, info.buildCost.itemId) >= allCostInfos[info.buildCost.itemId] then
                selectToolInfos:Add(info)
            else
                isSelectCompleted = true
                break
            end
        end
    end
    if boostInfos:Count() > 0 and not isSelectCompleted then
        boostInfos:Sort(
            function(a, b)
                return a.buildCost.count < b.buildCost.count
            end
        )
        for key, info in pairs(boostInfos) do
            if nil == allCostInfos[info.buildCost.itemId] then
                allCostInfos[info.buildCost.itemId] = 0
            end
            allCostInfos[info.buildCost.itemId] = allCostInfos[info.buildCost.itemId] + info.buildCost.count
            if DataManager.GetMaterialCount(self.cityId, info.buildCost.itemId) >= allCostInfos[info.buildCost.itemId] then
                selectBoostInfos:Add(info)
            else
                isSelectCompleted = true
                break
            end
        end
    end
    for index, info in pairs(selectZoneInfos) do
        if upgradingZoneCount >= 2 then
            break
        end
        if info.buildStatus == BuildingStatus.Empty then
            info.mapItemData:UnlockZone(
                function()
                end
            )
        elseif info.buildStatus == BuildingStatus.Complete and not info.mapItemData:IsUpgrading() then
            info.mapItemData:UpgradeZoneLevel(
                function()
                end
            )
        end
        upgradingZoneCount = upgradingZoneCount + 1
    end

    for key, info in pairs(selectToolInfos) do
        info.mapItemData:UpgradeToolLevel()
    end

    for key, info in pairs(selectBoostInfos) do
        info.mapItemData:UpgradeBoostLevel()
    end
end

--自动配分职业
function CityTest:CheckAssignCharacter()
    local function EachPeopleConfig(peopleConfig)
        local zoneType = peopleConfig.zone_type
        local furnitureId = peopleConfig.furniture_id
        local unlockIndexs = MapManager.GetUnlockFurnitureIndexs(self.cityId, zoneType, furnitureId)
        local peopleWorkState = CharacterManager.GetPeopleStateCount(self.cityId, peopleConfig.type)
        local normalCount = peopleWorkState[EnumState.Normal] or 0
        local sickCount = peopleWorkState[EnumState.Sick] or 0
        local protestCount = peopleWorkState[EnumState.Protest] or 0

        self.workStateList = List:New()
        for i = 1, unlockIndexs:Count(), 1 do
            local grid = GridManager.GetGridByFurnitureId(self.cityId, furnitureId, unlockIndexs[i], GridStatus.Unlock)
            if grid then
                self.workStateList:Add(grid:GetFurnitureWorkState())
            else
            end
        end

        for i = 1, self.workStateList:Count(), 1 do
            local workState = WorkStateType.None
            local hasPeople = true
            if i <= normalCount then
                workState = self.workStateList[i]
            elseif i <= normalCount + sickCount then
                if self.workStateList[i] ~= WorkStateType.Disable then
                    workState = WorkStateType.Sick
                else
                    workState = self.workStateList[i]
                end
            elseif i <= normalCount + sickCount + protestCount then
                if self.workStateList[i] ~= WorkStateType.Disable then
                    workState = WorkStateType.Protest
                else
                    workState = self.workStateList[i]
                end
            else
                hasPeople = false
                if self.workStateList[i] ~= WorkStateType.Work then
                    workState = self.workStateList[i]
                end
            end

            if hasPeople then
                if workState == WorkStateType.Disable or workState == WorkStateType.Sick then
                    CharacterManager.CancelAssignment(self.cityId, peopleConfig.type)
                end
            else
                if workState == WorkStateType.None then
                    CharacterManager.Assignment(self.cityId, peopleConfig.type)
                end
            end
        end
    end

    for ix, peopleConfig in pairs(ConfigManager.GetPeopleList(self.cityId)) do
        if peopleConfig.type ~= ProfessionType.FreeMan then
            EachPeopleConfig(peopleConfig)
        end
    end
end

--处理火炉
function CityTest:CheckGenerator()
    if not GeneratorManager.GetIsEnable(self.cityId) and GeneratorManager.ConsumptionLeftTime(self.cityId) > 1 then
        GeneratorManager.Open(self.cityId)
    end
    if GeneratorManager.GetIsEnable(self.cityId) then
        if TimeManager.GetCityIsNight(self.cityId) then
            if not GeneratorManager.GetIsOverload(self.cityId) then
                GeneratorManager.OpenOverload(self.cityId)
            end
        else
            if GeneratorManager.GetIsOverload(self.cityId) then
                GeneratorManager.CloseOverload(self.cityId)
            end
        end
    end
end

--升级卡牌等级
function CityTest:CheckUpgradeCardLevel()
    if not CityManager.GetIsEventScene(self.cityId) then
        return
    end
    local cardItem = CardManager.GetMinLeveCardItem()
    if nil == cardItem then
        return
    end
    cardItem:UpgradeLevel("AI")
end

--ai自动领取完成的任务
function CityTest:CheckGetTaskReward()
    local taskList = TaskManager.GetTask(self.cityId):GetAvailableTaskList()
    taskList:ForEach(
        function(taskItem)
            local rewards = taskItem:GainTaskReward()
            if self.aiPrintLog.value then
                if nil ~= rewards then
                    local bag = ""
                    if CityManager.GetIsEventScene(self.cityId) then
                        -- bag = bag .. "|累计cash:" .. Utils.FormatCount(EventSceneManager.GetSumCashCount())
                        -- bag = bag .. "|秒产cash:" .. Utils.FormatCount(EventSceneManager.GetCashSpeed())
                    else
                        for itemId, itemCount in pairs(DataManager.GetData(self.cityId).cityBagData) do
                            local type = type(itemCount)
                            if type == "number" then
                                bag = bag .. string.format("%s=%s ", itemId, Utils.FormatCount(itemCount))
                            elseif type == "string" then
                                bag = bag .. string.format("%s=%s ", itemId, itemCount)
                            end
                        end
                    end
                    local taskId = taskItem:GetTaskId()
                    local desc = taskItem:GetTaskDesc()
                    local stage = taskItem:GetTaskStage()
                    local log =
                        string.format(
                        "完成时间:%s 任务Id:%s 任务Stage:%s 任务描述:%s 资源存量:%s",
                        Utils.GetTimeFormat4(self.aiRunTime.value),
                        taskId,
                        stage,
                        desc,
                        bag
                    )
                    self:SaveTestLog(log)
                end
            end
        end
    )

    -- local count, maxCount = TaskManager.GetSceneTaskProgress(self.cityId)
    -- if count == maxCount then
    --     CityPassManager.PlayCityPass()
    -- end
end

--检测slot运行
function CityTest:CheckSlotSpin()
    -- if not CityManager.IsEventScene(EventCityType.Club) then
    --     return
    -- end
    -- if
    --     DataManager.GetMaterialCount(self.cityId, EventSceneManager.playCoin) >=
    --         EventSceneManager.GetEventCityConfig().playcoin_cost
    --  then
    --     EventSceneManager.SlotSpin(1)
    -- end
end

--升级trick等级
function CityTest:CheckUpgradeTrickLevel()
    -- if not CityManager.IsEventScene(EventCityType.Club, self.cityId) then
    --     return
    -- end
    -- local trickCfg = nil
    -- local trickLv = nil
    -- local list = ConfigManager.GetEventTrickList(self.cityId)
    -- list:ForEach(
    --     function(trickConfig)
    --         if nil == trickCfg then
    --             trickCfg = trickConfig
    --             trickLv = EventSceneManager.GetTrickLevel(trickConfig.id)
    --         else
    --             local nextTrickLv = EventSceneManager.GetTrickLevel(trickConfig.id)
    --             if trickLv > nextTrickLv then
    --                 trickCfg = trickConfig
    --                 trickLv = nextTrickLv
    --             end
    --         end
    --     end
    -- )
    -- if trickLv >= #trickCfg.upgrade_cash_cost then
    --     return
    -- end
    -- local cost = trickCfg.upgrade_cash_cost[trickLv + 1]
    -- if DataManager.GetMaterialCount(self.cityId, EventSceneManager.trickItem) < cost then
    --     return
    -- end
    -- EventSceneManager.UpgradeTrickLevel(trickCfg.id)
end

function CityTest:SetAIRunning(val)
    if self.aiRunning.value ~= val then
        self.aiRunning.value = val
    end
end

function CityTest:SetAIGameSpeed(val)
    if self.aiGameSpeed.value ~= val then
        self.aiGameSpeed.value = val
    end
end

function CityTest:SetAIRunningDay(val)
    if self.aiRunningDay.value ~= val then
        self.aiRunningDay.value = val
    end
end

function CityTest:SetAIStopWait(val)
    if self.aiStopWait.value ~= val then
        self.aiStopWait.value = val
    end
end

function CityTest:SetAIPrintLog(val)
    if self.aiPrintLog.value ~= val then
        self.aiPrintLog.value = val
    end
end

function CityTest:SetGameSpeed(val)
    if self.gameSpeed.value ~= val then
        self.gameSpeed.value = val
    end
end

function CityTest:SetMoveTeleport(val)
    if self.moveTeleport.value ~= val then
        self.moveTeleport.value = val
    end
end

--完成日程log
function CityTest:AILogCompleteSchedules(character, costTime, schedulesType, markerType, info)
    if not self.aiPrintLog.value then
        return
    end
    local log = ""
    local attributeValue = ""
    for key, value in pairs(character.info.attributeInfo) do
        if attributeValue ~= "" then
            attributeValue = attributeValue .. ","
        end
        attributeValue = attributeValue .. string.format("%s:%s", key, Utils.GetRoundPreciseDecimal(value, 2))
    end
    if info then
        local val = ""
        local function EachInfo(data)
            if val ~= "" then
                val = val .. ","
            end
            val = val .. string.format("%s:%s", data.type, data.value)
        end
        info:ForEach(EachInfo)
        log =
            string.format(
            "%s <小人%d>花费<%d>游戏时间,完成了<%s>日程的<%s>操作,当前小人属性:<%s>,恢复了属性:<%s>",
            TimeManager.GetClockFormat(self.cityId),
            character:GetSerialNumber(),
            costTime,
            schedulesType,
            markerType,
            attributeValue,
            val
        )
    else
        log =
            string.format(
            "%s <小人%d>花费<%d>游戏时间,完成了<%s>日程的<%s>操作, 当前小人属性:<%s>",
            TimeManager.GetClockFormat(self.cityId),
            character:GetSerialNumber(),
            costTime,
            schedulesType,
            markerType,
            attributeValue
        )
    end
    self:SaveTestLog(log)
end

--日程切换log
function CityTest:AILogSwitchSchedules(from, to)
    if not self.aiPrintLog.value then
        return
    end
    self:SaveTestLog(string.format("%s <%s>日程结束,<%s>日程开启", TimeManager.GetClockFormat(self.cityId), from, to))
end

--天数切换log
function CityTest:AILogSwitchDay()
    if not self.aiPrintLog.value then
        return
    end
    self:SaveTestLog(
        string.format(
            "\n\n\n%s Day<%s>开始",
            TimeManager.GetClockFormat(self.cityId),
            TimeManager.GetCityDay(self.cityId)
        )
    )
end

--小人立刻生病
---@param val number
function CityTest:CharacterImmediatelySick(val)
    local characters = CharacterManager.GetCharactersByStateType(self.cityId, EnumState.Normal)
    characters:Sort(Utils.SortCharacterByDescendingUseHealth)

    local count = val
    if count > characters:Count() then
        count = characters:Count()
    end

    for i = 1, count do
        characters[i]:SetNextState(EnumState.Severe)
    end
end

--小人立刻健康
function CityTest:CharacterImmediatelyHealth(val)
    local characters = CharacterManager.GetCharactersByStateType(self.cityId, EnumState.Sick)

    local count = val
    if count > characters:Count() then
        count = characters:Count()
    end

    for i = 1, count do
        characters[i]:SetNextState(EnumState.Normal)
    end
end

--小人立刻死亡
function CityTest:CharacterImmediatelyDead(val)
    local characters = CharacterManager.GetCharactersByStateType(self.cityId, EnumState.Sick)
    if characters:Count() <= 0 then
        characters = CharacterManager.GetCharactersByStateType(self.cityId, EnumState.Normal)
    end
    local count = val
    if count > characters:Count() then
        count = characters:Count()
    end
    for i = 1, count do
        characters[i]:SetNextState(EnumState.Dead)
    end
end

--小人立刻暴动
function CityTest:CharacterImmediatelyProtest()
    if FunctionsManager.IsOpen(self.cityId, FunctionsType.Protest) then
        ProtestManager.OpenProtest(self.cityId)
    end
end

--小人锁定健康
function CityTest:CharacterLockHealth(val)
    if self.isLockHealth.value then
        self.isLockHealth.value = false
        self.lockHealth.value = 0
    else
        self.isLockHealth.value = true
        self.lockHealth.value = val
    end
end

--小人锁定罢工
function CityTest:CharacterLockEventStrike(val)
    if self.isLockEventStrike.value then
        self.isLockEventStrike.value = false
        self.lockHealth.value = 0
    else
        self.isLockEventStrike.value = true
        self.lockHealth.value = val
    end
end

--小人锁定希望
function CityTest:CharacterLockHope(val)
    if self.isLockHope.value then
        self.isLockHope.value = false
        self.lockHope.value = 0
    else
        self.isLockHope.value = true
        self.lockHope.value = val
        local characters = CharacterManager.GetCharacterControllers(self.cityId)
        characters:ForEach(
            function(item)
                item:SetAttribute(AttributeType.Hope, val)
            end
        )
    end
end

--小人锁定幸福值
function CityTest:CharacterLockHappness(val)
    if self.isLockHappness.value then
        self.isLockHappness.value = false
        self.lockHappness.value = 0
    else
        self.isLockHappness.value = true
        self.lockHappness.value = val
    end
end

---新作弊接口--------------------------------------------------------------------------------
--设置小人锁定健康
---@param val number
---@param lock boolean
function CityTest:SetCharacterHealthLock(val, lock)
    self.isLockHealth.value = lock

    if lock then
        self.lockHealth.value = val
    end
end

--获得小人锁定健康状态
---@return number, boolean
function CityTest:GetCharacterHealthLock()
    return self.lockHealth.value, self.isLockHealth.value
end

--设置小人锁定罢工
---@param val number
---@param lock boolean
function CityTest:SetCharacterEventStrikeLock(val, lock)
    self.isLockEventStrike.value = lock

    if lock then
        self.lockEventStrike.value = val
    end
end

--获得小人锁定罢工状态
---@return number, boolean
function CityTest:GetCharacterEventStrikeLock()
    return self.lockEventStrike.value, self.isLockEventStrike.value
end

--设置小人锁定希望
---@param val number
---@param lock boolean
function CityTest:SetCharacterHopeLock(val, lock)
    self.isLockHope.value = lock

    if lock then
        self.lockHope.value = val
    end
end

--获得小人锁定希望状态
---@return number, boolean
function CityTest:GetCharacterHopeLock()
    return self.lockHope.value, self.isLockHope.value
end

--设置小人锁定幸福
---@param val number
---@param lock boolean
function CityTest:SetCharacterHappinessLock(val, lock)
    self.isLockHappness.value = lock

    if lock then
        self.lockHappness.value = val
    end
end

--获得小人锁定幸福状态
---@return number, boolean
function CityTest:GetCharacterHappinessLock()
    return self.lockHappness.value, self.isLockHappness.value
end

---@return string, boolean
function CityTest:GetLockSchedules()
    return self.lockSchedules.value, self.isLockSchedules.value
end

---@param schedule string
---@param lock boolean
function CityTest:LockSchedules(schedule, lock)
    self.lockSchedules.value = schedule
    self.isLockSchedules.value = lock
end

--建筑升满级
function CityTest:ArtUpgradeFull()
    --每个建筑处理
    local function EacheZone(zoneId, zoneData)
        local mapItemData = MapManager.GetMapItemData(self.cityId, zoneId)
        if not mapItemData then
            return
        end
        local furnitureMilestoneConfig = ConfigManager.GetFurnituresMilestoneConfig(zoneId)
        if nil == furnitureMilestoneConfig then
            local function EacheFurniture(furnitureId, count_in_room)
                local maxLevel = mapItemData:GetFurnitureMaxLevel(furnitureId)
                for i = 1, count_in_room, 1 do
                    if not zoneData.furnitures[furnitureId] then
                        zoneData.furnitures[furnitureId] = {}
                    end
                    zoneData.furnitures[furnitureId]["ix_" .. i] = maxLevel
                end
            end
            mapItemData:GetFurnitureList():ForEachKeyValue(EacheFurniture)
        else
            local toolCfg = furnitureMilestoneConfig.Tool
            if toolCfg then
                local toolMaxLevel = toolCfg.milestone_cut[#toolCfg.milestone_cut]
                zoneData.toolLevel = toolMaxLevel
                mapItemData:GetToolFurnitureList(toolMaxLevel):ForEachKeyValue(
                    function(furnitureId, count_in_room)
                        for i = 1, count_in_room, 1 do
                            if not zoneData.furnitures[furnitureId] then
                                zoneData.furnitures[furnitureId] = {}
                            end
                            zoneData.furnitures[furnitureId]["ix_" .. i] = toolMaxLevel
                        end
                    end
                )
            end
            local boostCfg = furnitureMilestoneConfig.Boost
            if boostCfg then
                local boostMaxLevel = boostCfg.milestone_cut[#boostCfg.milestone_cut]
                zoneData.boostLevel = boostMaxLevel
                mapItemData:GetBoostFurnitureList(boostMaxLevel):ForEachKeyValue(
                    function(furnitureId, count_in_room)
                        for i = 1, count_in_room, 1 do
                            if not zoneData.furnitures[furnitureId] then
                                zoneData.furnitures[furnitureId] = {}
                            end
                            zoneData.furnitures[furnitureId]["ix_" .. i] = boostMaxLevel
                        end
                    end
                )
            end
        end
    end
    --遍历城市建筑列表
    ConfigManager.GetZonesByCityId(self.cityId):ForEachKeyValue(
        function(zoneId, zoneCfg)
            local zoneData = DataManager.GetCityDataByKey(self.cityId, DataKey.Zones)[zoneId]
            if not zoneData then
                zoneData = {furnitures = {}}
            end
            EacheZone(zoneId, zoneData)
            zoneData.level = zoneCfg.max_level
            zoneData.buildTime = TimeManager.GameTime()
            zoneData.finished = true
            MapManager.SetZoneData(self.cityId, zoneId, zoneData)
        end
    )
    CityManager.SelectCity(self.cityId, true)
end

function CityTest:ArtUpgradeByStage(stage)
    local characterMaxCount = 0
    local function EachFurniture(zoneData, zoneLevel, furnitureCfg)
        if not zoneData.furnitures[furnitureCfg.id] then
            zoneData.furnitures[furnitureCfg.id] = {}
        end
        local count_in_room = furnitureCfg.count_in_room[zoneLevel]
        local furnitureLvl = self:getFurnitureLevelFromStage(furnitureCfg, stage)
        local maxFurnitureLvl = self:getFurnitureMaxLevelByZoneLevel(furnitureCfg, zoneLevel)

        if furnitureLvl > maxFurnitureLvl then
            furnitureLvl = maxFurnitureLvl
        end

        for i = 1, count_in_room, 1 do
            zoneData.furnitures[furnitureCfg.id]["ix_" .. i] = furnitureLvl
            if furnitureCfg.furniture_type == GridMarker.Bed then
                characterMaxCount = characterMaxCount + furnitureCfg.capacity
            end
        end

        return furnitureLvl
    end
    local function EachFurnitureList(zoneData, zoneCfg)
        local list = ConfigManager.GetFurnituresList(self.cityId, zoneCfg.zone_type)
        local zoneLevel = self:GetZoneLevelFromStage(zoneCfg, stage)
        if zoneLevel == 0 then
            return 0
        end

        for ix, furniture in pairs(list) do
            local furnitureLvl = EachFurniture(zoneData, zoneLevel, furniture)

            --local zLvl = self:getZoneLevelFromFurnitureLevel(furniture, furnitureLvl)
            --if zLvl > zoneLevel then
            --    zoneLevel = zLvl
            --end
        end

        return zoneLevel
    end
    local function EachZone(zoneId, zoneCfg)
        local zoneData = DataManager.GetCityDataByKey(self.cityId, DataKey.Zones)[zoneId]
        if not zoneData then
            zoneData = {furnitures = {}}
        end
        local zoneLvl = EachFurnitureList(zoneData, zoneCfg)

        if zoneLvl > 0 then
            zoneData.level = zoneLvl
            zoneData.buildTime = TimeManager.GameTime()
            zoneData.finished = true
        else
            zoneData = nil
        end

        MapManager.SetZoneData(self.cityId, zoneId, zoneData)
    end
    local zonesConfigList = ConfigManager.GetZonesByCityId(self.cityId)
    zonesConfigList:ForEachKeyValue(
        function(zoneId, zoneCfg)
            EachZone(zoneId, zoneCfg)
        end
    )
    local characterData = DataManager.GetCityDataByKey(self.cityId, DataKey.CharacterData)
    local characterCount = 0
    for id, info in pairs(characterData.infos) do
        characterCount = characterCount + 1
    end
    local characterFill = 0
    for type, info in pairs(characterData.fillTypes) do
        characterFill = characterFill + info.count
    end
    local buildFillInfo = nil
    if not characterData.fillTypes[FillType.Build] then
        characterData.fillTypes[FillType.Build] = {}
        characterData.fillTypes[FillType.Build].count = 0
        characterData.fillTypes[FillType.Build].time = TimeManager.GameTime()
    end
    buildFillInfo = characterData.fillTypes[FillType.Build]
    buildFillInfo.count = buildFillInfo.count + (characterMaxCount - characterCount - characterFill)

    -- task
    local partId, taskId = ConfigManager.GetTaskPartIdAndIdByStage(stage)
    TaskManager.GetTask(self.cityId):BuildCheatTaskCache(partId, taskId)

    CityManager.SelectCity(self.cityId, true)
end

---返回家具配置的stage中最接近stage并且小于stage的level，如果没有就返回1
---@param furnitureCfg table
---@param stage number
---@return number
function CityTest:getFurnitureLevelFromStage(furnitureCfg, stage)
    for i = #furnitureCfg.stage, 1, -1 do
        if furnitureCfg.stage[i] < stage then
            return i
        end
    end

    return 1
end

---返回家具最大等级
---@param furnitureCfg table
---@return number
function CityTest:getFurnitureMaxLevel(furnitureCfg, zoneLevel)
    return furnitureCfg.max_level[#furnitureCfg.max_level]
end

---返回建筑等级对应的家具最大等级
---@param furnitureCfg table
---@param zoneLevel number
---@return number
function CityTest:getFurnitureMaxLevelByZoneLevel(furnitureCfg, zoneLevel)
    return furnitureCfg.max_level[zoneLevel]
end

---根据给定的家具等级获取建筑等级
---@param furnitureCfg table
---@param furnitureLevel number
---@return number
function CityTest:getZoneLevelFromFurnitureLevel(furnitureCfg, furnitureLevel)
    for i = #furnitureCfg.max_level, 1 do
        if furnitureCfg.max_level[i] <= furnitureLevel then
            return furnitureCfg.max_level[i]
        end
    end

    return 1
end

---根据给定的stage获取建筑等级
---@param zoneCfg table
---@param stage number
---@return number
function CityTest:GetZoneLevelFromStage(zoneCfg, stage)
    for i = #zoneCfg.stage, 1, -1 do
        if zoneCfg.stage[i] < stage then
            return i
        end
    end

    return 0
end
