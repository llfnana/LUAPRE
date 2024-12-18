TestManager = {}
TestManager.isUseTest = false
    --UnityEngine.Application.platform ~= UnityEngine.RuntimePlatform.Android and UnityEngine.Application.platform ~= UnityEngine.RuntimePlatform.IPhonePlayer
TestManager.showMainUIButton = false

local this = TestManager

function TestManager.Init()
    this.cityId = DataManager.GetCityId()
    if not this.testItems then
        this.testItems = Dictionary:New()
    end
    if not this.testItems:ContainsKey(this.cityId) then
        this.testItems:Add(this.cityId, CityTest:New(this.cityId))
        if this.testItems:Count() == 1 then
            this.AddListener()
        end
    end
end

function TestManager.Clear(force)
    Utils.SwitchSceneClear(this.cityId, this.testItems, force)
    if this.testItems:Count() == 0 then
        this.RemoveListener()
    end
end

function TestManager.AddListener()
    -- if not GameManager.isDebug then
    --     return
    -- end
    EventManager.AddListener(EventType.TIME_REAL_PER_SECOND, this.TimeRealPerSecondFunc)
    EventManager.AddListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)

    EventManager.AddListener(EventType.AI_RUNNING_DAY, this.AIRunningDayFunc)
    EventManager.AddListener(EventType.AI_STOP_WAIT, this.AIStopWaitFunc)
    EventManager.AddListener(EventType.AI_LOG_SWITCH_SCHEDULES, this.AILogSwitchSchedulesFunc)

    EventManager.AddListener(EventType.CHARACTER_IMMEDIATELY_SICK, this.CharacterImmediatelySickFunc)
    EventManager.AddListener(EventType.CHARACTER_IMMEDIATELY_HEALTH, this.CharacterImmediatelyHealthFunc)
    EventManager.AddListener(EventType.CHARACTER_IMMEDIATELY_DEAD, this.CharacterImmediatelyDeadFunc)
    EventManager.AddListener(EventType.CHARACTER_IMMEDIATELY_PROTEST, this.CharacterImmediatelyProtestFunc)
    EventManager.AddListener(EventType.CHARACTER_LOCK_HEALTH, this.CharacterLockHealthFunc)
    EventManager.AddListener(EventType.CHARACTER_LOCK_EVENTSTRIKE, this.CharacterLockEventStrikeFunc)
    EventManager.AddListener(EventType.CHARACTER_LOCK_HOPE, this.CharacterLockHopeFunc)
    EventManager.AddListener(EventType.CHARACTER_LOCK_HAPPNESS, this.CharacterLockHappnessFunc)
end

function TestManager.RemoveListener()
    EventManager.RemoveListener(EventType.TIME_REAL_PER_SECOND, this.TimeRealPerSecondFunc)
    EventManager.RemoveListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)

    EventManager.RemoveListener(EventType.AI_RUNNING_DAY, this.AIRunningDayFunc)
    EventManager.RemoveListener(EventType.AI_STOP_WAIT, this.AIStopWaitFunc)
    EventManager.RemoveListener(EventType.AI_LOG_SWITCH_SCHEDULES, this.AILogSwitchSchedulesFunc)

    EventManager.RemoveListener(EventType.CHARACTER_IMMEDIATELY_SICK, this.CharacterImmediatelySickFunc)
    EventManager.RemoveListener(EventType.CHARACTER_IMMEDIATELY_HEALTH, this.CharacterImmediatelyHealthFunc)
    EventManager.RemoveListener(EventType.CHARACTER_IMMEDIATELY_DEAD, this.CharacterImmediatelyDeadFunc)
    EventManager.RemoveListener(EventType.CHARACTER_IMMEDIATELY_PROTEST, this.CharacterImmediatelyProtestFunc)
    EventManager.RemoveListener(EventType.CHARACTER_LOCK_HEALTH, this.CharacterLockHealthFunc)
    EventManager.RemoveListener(EventType.CHARACTER_LOCK_EVENTSTRIKE, this.CharacterLockEventStrikeFunc)
    EventManager.RemoveListener(EventType.CHARACTER_LOCK_HOPE, this.CharacterLockHopeFunc)
    EventManager.RemoveListener(EventType.CHARACTER_LOCK_HAPPNESS, this.CharacterLockHappnessFunc)
end
---@return CityTest
function TestManager.GetTest(cityId)
    return this.testItems[cityId]
end

-------------------------------------------------------------------
---事件监听
-------------------------------------------------------------------
--真实时间每秒刷新
function TestManager.TimeRealPerSecondFunc(cityId)
    -- LogWarning("TestManager.TimeRealPerSecondFunc")
    this.GetTest(cityId):TimeRealPerSecondFunc()
end

--建造区域事件响应
function TestManager.UpgradeZoneFunc(cityId, zoneId, zoneType, level)
    this.GetTest(cityId):UpgradeZoneFunc(zoneId, zoneType, level)
end

function TestManager.AIRunningDayFunc(cityId, val)
    this.GetTest(cityId):SetAIRunningDay(val)
end

function TestManager.AIStopWaitFunc(cityId, val)
    this.GetTest(cityId):SetAIStopWait(val)
end

function TestManager.AILogSwitchSchedulesFunc(cityId, from, to)
    this.GetTest(cityId):AILogSwitchSchedules(from, to)
end

function TestManager.CharacterImmediatelySickFunc(cityId, val)
    this.GetTest(cityId):CharacterImmediatelySick(val)
end

function TestManager.CharacterImmediatelyHealthFunc(cityId, val)
    this.GetTest(cityId):CharacterImmediatelyHealth(val)
end

function TestManager.CharacterImmediatelyDeadFunc(cityId, val)
    this.GetTest(cityId):CharacterImmediatelyDead(val)
end

function TestManager.CharacterImmediatelyProtestFunc(cityId)
    this.GetTest(cityId):CharacterImmediatelyProtest()
end

function TestManager.CharacterLockHealthFunc(cityId, val)
    this.GetTest(cityId):CharacterLockHealth(val)
end

function TestManager.CharacterLockEventStrikeFunc(cityId, val)
    this.GetTest(cityId):CharacterLockEventStrike(val)
end

function TestManager.CharacterLockHopeFunc(cityId, val)
    this.GetTest(cityId):CharacterLockHope(val)
end

function TestManager.CharacterLockHappnessFunc(cityId, val)
    this.GetTest(cityId):CharacterLockHappness(val)
end

function TestManager.ArtUpgradeFull(cityId)
    this.GetTest(cityId):ArtUpgradeFull()
end

function TestManager.ArtUpgradeByStage(cityId, stage)
    this.GetTest(cityId):ArtUpgradeByStage(stage)
end

-------------------------------------------------------------------
---方法
-------------------------------------------------------------------
function TestManager.IsLockHope(cityId)
    return this.GetTest(cityId).isLockHope.value
end

function TestManager.GetLockHope(cityId)
    return this.GetTest(cityId).lockHope.value
end

function TestManager.IsLockHealth(cityId)
    return this.GetTest(cityId).isLockHealth.value
end

function TestManager.GetLockHealth(cityId)
    return this.GetTest(cityId).lockHealth.value
end

function TestManager.IsLockEventStrike(cityId)
    return this.GetTest(cityId).isLockEventStrike.value
end

function TestManager.GetLockEventStrike(cityId)
    return this.GetTest(cityId).lockEventStrike.value
end

function TestManager.IsLockHappness(cityId)
    return this.GetTest(cityId).isLockHappness.value
end

function TestManager.GetLockHappness(cityId)
    return this.GetTest(cityId).lockHappness.value
end

function TestManager.IsPrintLog(cityId)
    return this.GetTest(cityId).aiPrintLog.value
end

function TestManager.IsTeleport(cityId)
    return this.GetTest(cityId).isTeleport.value
end

function TestManager.GetGameSpeed(cityId)
    return this.GetTest(cityId).gameSpeed.value
end

function TestManager.IsShowMainUIButton()
    return this.showMainUIButton
end

function TestManager.SetShowMainUIButton(show)
    this.showMainUIButton = show
end
