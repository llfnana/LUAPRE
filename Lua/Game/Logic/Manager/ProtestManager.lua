ProtestManager = {}
ProtestManager.__cname = "ProtestManager"

local this = ProtestManager

--初始化
function ProtestManager.Init()
    this.cityId = DataManager.GetCityId()
    if not this.protestItems then
        this.protestItems = Dictionary:New()
    end
    if not this.protestItems:ContainsKey(this.cityId) then
        this.protestItems:Add(this.cityId, CityProtest:New(this.cityId))
        if this.protestItems:Count() == 1 then
            EventManager.AddListener(EventType.TIME_REAL_PER_SECOND, this.TimeRealPerSecondFunc)
            EventManager.AddListener(EventType.CHARACTER_REFRESH, this.RefreshCharacterFunc)
            EventManager.AddListener(EventType.FUNCTIONS_OPEN, this.FunctionsOpenFunc)
            EventManager.AddListener(EventType.ADD_CARD, this.AddCardFunc)
            EventManager.AddListener(EventType.UPGRADE_CARD_LEVEL, this.UpgradeCardLevelFunc)
            EventManager.AddListener(EventType.ZONE_CARD_CHANGE, this.ZoneCardChangeFunc)
        end
    end
end

---实例化显示
function ProtestManager.InitView()
    this.GetProtest(this.cityId):InitView()
end

function ProtestManager.ClearView()
    this.GetProtest(this.cityId):ClearView()
end

--清理
function ProtestManager.Clear(force)
    Utils.SwitchSceneClear(this.cityId, this.protestItems, force)
    if this.protestItems:Count() == 0 then
        EventManager.RemoveListener(EventType.TIME_REAL_PER_SECOND, this.TimeRealPerSecondFunc)
        EventManager.RemoveListener(EventType.CHARACTER_REFRESH, this.RefreshCharacterFunc)
        EventManager.RemoveListener(EventType.FUNCTIONS_OPEN, this.FunctionsOpenFunc)
        EventManager.RemoveListener(EventType.ADD_CARD, this.AddCardFunc)
        EventManager.RemoveListener(EventType.UPGRADE_CARD_LEVEL, this.UpgradeCardLevelFunc)
        EventManager.RemoveListener(EventType.ZONE_CARD_CHANGE, this.ZoneCardChangeFunc)
    end
end

--获取加班对象
function ProtestManager.GetProtest(cityId)
    return this.protestItems[cityId]
end

---------------------------------
---事件响应
---------------------------------
--真实时间每秒刷新响应
function ProtestManager.TimeRealPerSecondFunc(cityId)
    -- LogWarning("ProtestManager.TimeRealPerSecondFunc")
    this.GetProtest(cityId):TimeRealPerSecondFunc()
end

--角色刷新事件响应
function ProtestManager.RefreshCharacterFunc(cityId, isAdd)
    this.GetProtest(cityId):RefreshCharacterFunc(isAdd)
end

--功能解锁事件响应
function ProtestManager.FunctionsOpenFunc(cityId, type, isOpen)
    if type ~= FunctionsType.Protest then
        return
    end
    this.GetProtest(cityId):SetProtestOpen(isOpen)
end

function ProtestManager.AddCardFunc(cityId, cardId)
    this.GetProtest(cityId):AddCardFunc(cardId)
end

--升级卡牌等级响应
function ProtestManager.UpgradeCardLevelFunc(cityId, cardId, level)
    this.GetProtest(cityId):UpgradeCardLevelFunc(cardId, level)
end

--区域卡牌变更响应
function ProtestManager.ZoneCardChangeFunc(cityId, zoneId)
    this.GetProtest(cityId):ZoneCardChangeFunc(zoneId)
end

---------------------------------
---方法响应
---------------------------------
--暴动是否开启
function ProtestManager.IsFunctionsOpen(cityId)
    return this.GetProtest(cityId).isOpen
end

--开启暴动
function ProtestManager.OpenProtest(cityId)
    this.GetProtest(cityId):OpenProtest()
end

--开启暴动
function ProtestManager.RunProtest(cityId)
    this.GetProtest(cityId):RunProtest()
end

--关闭暴动
function ProtestManager.CloseProtest(cityId)
    this.GetProtest(cityId):CloseProtest()
end

--获取暴动状态
function ProtestManager.IsProtestStatus(cityId)
    return this.GetProtest(cityId):IsProtestStatus()
end

--获取暴动组id
function ProtestManager.GetProtestGroupId(cityId)
    return this.GetProtest(cityId):GetProtestGroupId()
end

--获取暴动安抚事件列表
function ProtestManager.GetAppeaseInfoByIndex(cityId, index)
    return this.GetProtest(cityId):GetAppeaseInfoByIndex(index)
end

--刷新暴动安抚事件列表
function ProtestManager.UseProtestAppeaseEvent(cityId, appeaseInfo, appeaseIndex)
    return this.GetProtest(cityId):UseProtestAppeaseEvent(appeaseInfo, appeaseIndex)
end

--获取暴动状态和时间
function ProtestManager.GetProtestStatus(cityId)
    return this.GetProtest(cityId):GetProtestStatus()
end

--获取暴动状态和时间
function ProtestManager.GetProtestLeftTime(cityId)
    return this.GetProtest(cityId):GetProtestLeftTime()
end

--获取暴动安抚刷新时间
function ProtestManager.GetAppeaseRefreshTime(cityId)
    return this.GetProtest(cityId):GetAppeaseRefreshTime()
end

--获取绝望进度
function ProtestManager.GetDesparirProgress(cityId)
    return this.GetProtest(cityId):GetDesparirProgress()
end

--获取卡牌id
function ProtestManager.GetCardId(cityId)
    return this.GetProtest(cityId):GetCardId()
end

--获取卡牌等级Rx
function ProtestManager.GetCardLeveRx(cityId)
    return this.GetProtest(cityId):GetCardLeveRx()
end

--获取安抚最大数量
function ProtestManager.GetAppeaseMaxCount(cityId)
    return this.GetProtest(cityId):GetAppeaseMaxCount()
end

--获取暴动安抚次数
function ProtestManager.GetAppeaseCount(cityId)
    return this.GetProtest(cityId):GetAppeaseCount()
end

--获取安抚需求卡牌等级
function ProtestManager.GetAppeaseRequireCardLevel(cityId, index)
    return this.GetProtest(cityId):GetAppeaseRequireCardLevel(index)
end

--获取当前暴动人数
function ProtestManager.GetCurrentPeople(cityId)
    return this.GetProtest(cityId):GetCurrentPeople()
end

--获取总的暴动人数
function ProtestManager.GetTotalPeople(cityId)
    return this.GetProtest(cityId):GetTotalPeople()
end

--获取暴动安抚事件索引
function ProtestManager.GetUnlockAppeaseIndex(cityId)
    return this.GetProtest(cityId):GetUnlockAppeaseIndex()
end

--获取总的暴动人数
function ProtestManager.ShowProtestMaskPoint(cityId, bShow)
    this.GetProtest(cityId):ShowProtestMaskPoint(bShow)
end
