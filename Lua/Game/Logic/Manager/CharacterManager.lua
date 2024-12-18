CharacterManager = {}
CharacterManager.__cname = "CharacterManager"
CharacterManager.useGpuSkin = false

local this = CharacterManager

local isInitStorage = false
local localStorage = {

}

---初始化
function CharacterManager.Init()
    this.cityId = DataManager.GetCityId()
    if not this.characterItems then
        this.characterItems = Dictionary:New()
    end
    if not this.characterItems:ContainsKey(this.cityId) then
        this.characterItems:Add(this.cityId, CityCharacter:New(this.cityId))
        if this.characterItems:Count() == 1 then
            EventManager.AddListener(EventType.UPDATE_ZONE_GRID_DATA, this.UpgradeZoneGridDataFunc)
            EventManager.AddListener(EventType.SCHEDULES_REMOVE, this.RemoveSchedulesFunc)
            EventManager.AddListener(EventType.CHARACTER_STATE_CHANGE, this.CharacterStateChangeFunc)
            EventManager.AddListener(EventType.CHARACTER_PROFESSION_CHANGE, this.CharacterProfessionChangeFunc)
            EventManager.AddListener(EventType.TIME_CITY_FORCE_REFRESH, this.TimeForceRefreshFunc)
            EventManager.AddListener(EventType.ZONE_CARD_CHANGE, this.ZoneCardChangeFunc)
        end
    end

    -- 特权功能检测
    if this.checkTeQuan ~= nil then
        clearInterval(this.checkTeQuan)
        this.checkTeQuan = nil
    end
    this.checkTeQuan = setInterval(this.checkTeQuanInfo, 60000)

end

function CharacterManager.getFreeManCount()
    local workCount, notWorkCount, restCount = CharacterManager.GetPeopleWorkStateCount(this.cityId)
    return restCount
end

function CharacterManager.getPeopleStateCount(peopleConfig, state)
    local zoneType = peopleConfig.zone_type
    local furnitureId = peopleConfig.furniture_id
    local unlockIndexs = MapManager.GetUnlockFurnitureIndexs(this.cityId, zoneType, furnitureId)
    local peopleWorkState = CharacterManager.GetPeopleStateCount(this.cityId, peopleConfig.type)
    return peopleWorkState[state] or 0
end

function CharacterManager.getFreeCount(peopleConfig)
    local zoneType = peopleConfig.zone_type
    local furnitureId = peopleConfig.furniture_id
    local unlockIndexs = MapManager.GetUnlockFurnitureIndexs(this.cityId, zoneType, furnitureId)
    local peopleWorkState = CharacterManager.GetPeopleStateCount(this.cityId, peopleConfig.type)
    local normalCount = peopleWorkState[EnumState.Normal] or 0
    local sickCount = peopleWorkState[EnumState.Sick] or 0
    local protestCount = peopleWorkState[EnumState.Protest] or 0
    local totalCount = normalCount + sickCount + protestCount

    local zoneId = ConfigManager.GetZoneIdByZoneType(this.cityId, peopleConfig.zone_type)
    local mapItemData = MapManager.GetMapItemData(this.cityId, zoneId)
    local canUseToolCount = mapItemData:GetCanUseToolCount()
    local maxCount = math.min(unlockIndexs:Count(), canUseToolCount)

    return maxCount - totalCount
end

--- 特权数据
function CharacterManager.checkTeQuanInfo()
    if GameManager.TeQuanAuto then
        GameManager.TeQuanAuto = false
        return
    end
    local needAgain = false
    -- 是否开启特权急速补充
    local purchased = PaymentManager.GetSubscription(206, ShopManager.GetNow())
    if purchased then
        if this.getFreeManCount() <= 0 then
            return
        end
        for __, peopleConfig in pairs(ConfigManager.GetPeopleList(this.cityId)) do
            if peopleConfig ~= nil and peopleConfig.type ~= ProfessionType.FreeMan and MapManager.GetZoneCount(this.cityId, peopleConfig.zone_type, 1) > 0 then
                -- 去除生病
                if this.getPeopleStateCount(peopleConfig, EnumState.Sick) > 0 then
                    CharacterManager.CancelAssignment(this.cityId, peopleConfig.type)
                end
                
                if this.getFreeCount(peopleConfig) > 1 then
                    needAgain = true
                end
                
                -- 有空位自动分配
                if this.getFreeCount(peopleConfig) > 0 and this.getFreeManCount() > 0 then
                    if CharacterManager.Assignment(this.cityId, peopleConfig.type) then
                        local key = CharacterManager.GetTeQuanAutoKey()
                        local count = CharacterManager.GetStorage(key)
                        CharacterManager.SetStorage(key, count + 1)
                        EventManager.Brocast(EventType.TeQuanAutohange)
                    end 
                end
            end
        end
        if this.getFreeManCount() > 0 and needAgain then
            this.checkTeQuanInfo()
        end
    else
        local key = CharacterManager.GetTeQuanAutoKey()
        CharacterManager.SetStorage(key, 0)
    end
end

---实例化显示
function CharacterManager.InitView()
    this.GetCharacter(this.cityId):InitView()
end

function CharacterManager.ClearView()
    this.GetCharacter(this.cityId):ClearView()
end

--清理
function CharacterManager.Clear(force)
    Utils.SwitchSceneClear(this.cityId, this.characterItems, force)
    if this.characterItems:Count() == 0 then
        EventManager.RemoveListener(EventType.UPDATE_ZONE_GRID_DATA, this.UpgradeZoneGridDataFunc)
        EventManager.RemoveListener(EventType.SCHEDULES_REMOVE, this.RemoveSchedulesFunc)
        EventManager.RemoveListener(EventType.CHARACTER_STATE_CHANGE, this.CharacterStateChangeFunc)
        EventManager.RemoveListener(EventType.CHARACTER_PROFESSION_CHANGE, this.CharacterProfessionChangeFunc)
        EventManager.RemoveListener(EventType.TIME_CITY_FORCE_REFRESH, this.TimeForceRefreshFunc)
        EventManager.RemoveListener(EventType.ZONE_CARD_CHANGE, this.ZoneCardChangeFunc)
    end

    if this.checkTeQuan ~= nil then
        clearInterval(this.checkTeQuan)
        this.checkTeQuan = nil
    end
end

--刷新
function CharacterManager.OnUpdate()
    local count = this.characterItems:Count()
    for i = 1, count do
        this.characterItems[this.characterItems.keyList[i]]:OnUpdate()
    end

    local mainCtrl = CityModule.getMainCtrl()
    if mainCtrl then 
        local showRoof = mainCtrl.camera:getRoofActive()
        if showRoof == this.showRoof then
            return
        end

        this.showRoof = showRoof
        CharacterManager.RefreshRoofView(DataManager.GetCityId())
    end
end

---@return CityCharacter
function CharacterManager.GetCharacter(cityId)
    return this.characterItems[cityId]
end

---------------------------------
---事件响应
---------------------------------
--更新区域格子数据
function CharacterManager.UpgradeZoneGridDataFunc(cityId, zoneId, zoneType, level)
    this.GetCharacter(cityId):UpgradeZoneGridDataFunc(zoneId, zoneType, level)
end

--移除日程事件
function CharacterManager.RemoveSchedulesFunc(cityId, schedules)
    this.GetCharacter(cityId):RemoveSchedulesFunc(schedules)
end

--角色状态变更
function CharacterManager.CharacterStateChangeFunc(cityId, character, state)
    this.GetCharacter(cityId):SetIrrationalRx()
end

--角色职业变更
function CharacterManager.CharacterProfessionChangeFunc(cityId, newType, oldType)
    this.GetCharacter(cityId):SetIrrationalRx()
end

--roof
function CharacterManager.RefreshRoofView(cityId)
    this.GetCharacter(cityId):RefreshRoofView()
end

--建筑卡牌变更
function CharacterManager.ZoneCardChangeFunc(cityId)
    this.GetCharacter(cityId):SetIrrationalRx()
end

--时间强制刷新事件
function CharacterManager.TimeForceRefreshFunc(cityId)
    this.GetCharacter(cityId):TimeForceRefreshFunc()
end

---------------------------------
---方法响应
---------------------------------
--删除角色
function CharacterManager.RemoveCharacter(cityId, id)
    this.GetCharacter(cityId):RemoveCharacter(id)
end

---获取角色数量
function CharacterManager.GetCharacterCount(cityId)
    return this.GetCharacter(cityId):GetCharacterCount()
end

---获取角色最大数量
function CharacterManager.GetCharacterMaxCount(cityId)
    return this.GetCharacter(cityId):GetCharacterMaxCount()
end

--获取角色列表
function CharacterManager.GetCharacterControllers(cityId)
    return this.GetCharacter(cityId).characterControllers
end

--根据索引获取角色对象
function CharacterManager.GetCharacterBySerialNumber(cityId, serialNumber)
    return this.GetCharacter(cityId):GetCharacterBySerialNumber(serialNumber)
end

--根据索引获取角色对象
function CharacterManager.GetCharacterByIndex(cityId, index)
    return this.GetCharacter(cityId):GetCharacterByIndex(index)
end

--根据状态类型获取角色列表
function CharacterManager.GetCharactersByStateType(cityId, stateType)
    return this.GetCharacter(cityId):GetCharactersByStateType(stateType)
end

--根据标记类型获取角色列表
function CharacterManager.GetCharactersByMarkType(cityId, markType)
    return this.GetCharacter(cityId):GetCharactersByMarkType(markType)
end

--根据状态类型获取角色数量
function CharacterManager.GetCharacterCountByStateType(cityId, stateType)
    return this.GetCharacter(cityId):GetCharacterCountByStateType(stateType)
end

--获取全部角色列表
function CharacterManager.GetAllCharactersByList(cityId)
    return this.GetCharacter(cityId):GetAllCharactersByList()
end

--根据职业类型获取角色列表
function CharacterManager.GetCharactersByPeopleType(cityId, professionType)
    return this.GetCharacter(cityId):GetCharactersByPeopleType(professionType)
end

--根据生病区域获取小人列表
function CharacterManager.GetCharactersBySickZone(cityId, zoneType, state)
    return this.GetCharacter(cityId):GetCharactersBySickZone(zoneType, state)
end

--获取生病小人信息
function CharacterManager.SendSickAnalytics(cityId)
    this.GetCharacter(cityId):SendSickAnalytics(cityId)
end

---分配
function CharacterManager.Assignment(cityId, professionType)
    return this.GetCharacter(cityId):Assignment(professionType)
end

---取消职业分配
function CharacterManager.CancelAssignment(cityId, professionType)
    return this.GetCharacter(cityId):CancelAssignment(professionType)
end

--获取属性平均值
function CharacterManager.GetAttributeValue(cityId, type)
    return this.GetCharacter(cityId):GetAttributeValue(type)
end

--获取小人体表温度
function CharacterManager.GetSurfaceTempValue(cityId)
    return this.GetCharacter(cityId):GetSurfaceTempValue()
end

--温暖属性是否高于健康的安全线
function CharacterManager.IsWarmAboveSafeLine(cityId)
    return this.GetCharacter(cityId):IsWarmAboveSafeLine()
end

--获取生存着不合理人数numberRx
function CharacterManager.GetIrrationalRx(cityId)
    return this.GetCharacter(cityId):GetIrrationalRx()
end

--获取职业分配数量
function CharacterManager.GetPeopleStateCount(cityId, parameter)
    return this.GetCharacter(cityId):GetPeopleStateCount(parameter)
end

function CharacterManager.GetPeopleWorkStateCount(cityId)
    return this.GetCharacter(cityId):GetPeopleWorkStateCount()
end

function CharacterManager.GetWantWorkerCount(cityId, peopleConfig)
    return this.GetCharacter(cityId):GetWantWorkerCount(peopleConfig)
end

--根据属性获取生病信息
function CharacterManager.GetDiseaseIdByAttributeType(cityId, attributeType)
    return this.GetCharacter(cityId):GetDiseaseIdByAttributeType(attributeType)
end

--获取疾病医疗值
function CharacterManager.GetDiseaseMedicalNeed(cityId, diseaseId)
    return this.GetCharacter(cityId):GetDiseaseMedicalNeed(diseaseId)
end

--设置强制生病
function CharacterManager.SetCharacterForceSick(cityId, gender, skinId)
    return this.GetCharacter(cityId):SetCharacterForceSick(gender, skinId)
end

--根据cityId获取小人预警信息 属性类型&&数量
function CharacterManager.GetAttributeDebuffCount(cityId)
    return this.GetCharacter(cityId):GetAttributeDebuffCount()
end

function CharacterManager.AddMaxAttribute(cityId, type, count)
    this.GetCharacter(cityId):AddMaxAttribute(type, count)
end

function CharacterManager.GetTeQuanAutoKey()
    return PlayerModule.GetUid() .. "_TeQuanAuto"
end

--region 本地缓存
function CharacterManager.InitStorage()
    if isInitStorage == false then 
        isInitStorage = true
        localStorage = StorageModule.get(StorageModule.enum.CHARACTER_NAMAGER, localStorage)
    end
end

function CharacterManager.GetLocalStorage(key)
    this.InitStorage()
    return localStorage[key]
end

function CharacterManager.SetLocalStorage(key, value)
    this.InitStorage()
    localStorage[key] = value
    StorageModule.set(StorageModule.enum.CHARACTER_NAMAGER, localStorage)
end

function CharacterManager.GetStorage(key)
    if PlayerModule.getSdkPlatform() == "wx" then
        return this.GetLocalStorage(key) or 0 
    else 
        return PlayerPrefs.GetInt(key)
    end
end

function CharacterManager.SetStorage(key, value)
    if PlayerModule.getSdkPlatform() == "wx" then
        this.SetLocalStorage(key, value)
    else 
        PlayerPrefs.SetInt(key, value)
    end
end
--endregion
