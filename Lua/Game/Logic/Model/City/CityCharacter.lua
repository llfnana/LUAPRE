---@class CityCharacter
CityCharacter = Clone(CityBase)
CityCharacter.__cname = "CityCharacter"

CharacterController = require "Game/Logic/AI/CharacterController"

---初始化
function CityCharacter:OnInit()
    self.bedConfig = ConfigManager.GetFurnitureById("C" .. self.cityId .. "_" .. ZoneType.Dorm .. "_" .. GridMarker.Bed)
    self.characterData = DataManager.GetCityDataByKey(self.cityId, DataKey.CharacterData)
    self.isEventScene = CityManager.GetIsEventScene(self.cityId)
    self.warmSafeLine = ConfigManager.GetNecessitiesSafeLine(self.cityId, AttributeType.Warm)

    -- 用于修改小人补充速度
    self.peopleRefreshCoolDownFixedValue = -1
    self.bodyTemp = ConfigManager.GetFormulaConfigById("bodyTemp")
    self.tempScore = ConfigManager.GetFormulaConfigById("tempScore")
    self.overdriveControl = ConfigManager.GetFormulaConfigById("overdriveControl")
    self.neverGetSick = ConfigManager.GetMiscConfig("number_of_people_never_get_sick")

    self.replenish_people_once = {}
    self.replenish_people_once[FillType.Build] = 1
    if self.isEventScene then
        self.people_refresh_cooldown = ConfigManager.GetMiscConfig("people_refresh_cooldown_event")
        self.replenish_people_frequency = ConfigManager.GetMiscConfig("replenish_people_frequency_event")
        self.replenish_people_once[FillType.Dead] = ConfigManager.GetMiscConfig("replenish_people_once_event")
    else
        self.people_refresh_cooldown = ConfigManager.GetMiscConfig("people_new_cooldown")
        self.replenish_people_frequency = ConfigManager.GetMiscConfig("people_relive_cooldown")
        self.replenish_people_once[FillType.Dead] = 1
    end
    --初始化疾病信息
    self:InitDiseaseInfo()

    --数据结构
    self.characterControllers = Dictionary:New()
    -- 不合理人数
    self.irrationalRx = NumberRx:New(0)
    --游戏速度事件监听
    local function GameSpeedFunc(val)
        local function EachCharacter(item)
            item:SetSpeed()
        end
        self.characterControllers:ForEach(EachCharacter)
    end
    self.gameSpeedSubscribe = TestManager.GetTest(self.cityId).gameSpeed:subscribe(GameSpeedFunc, false)

    --填充类型信息
    self.fillTypeInfos = Dictionary:New()
    self.fillTypeCoroutines = Dictionary:New()
    --真实时间每秒刷新回调
    local function TimeRealPerSecondFunc()
        local gameTime = GameManager.GameTime()
        for fillType, fillInfo in pairs(self.characterData.fillTypes) do
            if nil == fillInfo.coolDown then
                fillInfo.coolDown = self:GetPeopleRefreshCoolDown(fillType)
            end
            if gameTime - fillInfo.time >= fillInfo.coolDown then
                local fillCount = 0
                if fillInfo.count >= self.replenish_people_once[fillType] then
                    fillCount = self.replenish_people_once[fillType]
                else
                    fillCount = fillInfo.count
                end
                --执行创建
                fillInfo.time = gameTime
                fillInfo.coolDown = self:GetPeopleRefreshCoolDown(fillType)
                self.fillTypeInfos:Add(fillType, fillCount)
            end
        end
        --执行创建小人
        if self.fillTypeInfos:Count() > 0 then
            local characterMaxCount = self:GetCharacterMaxCount()
            --遍历每次小人填充
            local function EacheCharacterFillFunc(fillType, fillCount)
                local formType = Utils.LamdaExpression(fillType == FillType.Build, "new", "replenish")
                local isSubscription = BoostManager.GetRxBoosterValue(self.cityId, RxBoostType.PeopleFastCome) == 1
                --创建方法
                local function CoroutineFunc()
                    for i = 1, fillCount, 1 do
                        if self:CreateCharacter(self:IsPeopleCreateByVIP(fillType)) then
                            self.characterData.fillTypes[fillType].count =
                                self.characterData.fillTypes[fillType].count - 1
                            if self.characterData.fillTypes[fillType].count <= 0 then
                                self.characterData.fillTypes[fillType] = nil
                            end
                            DataManager.SaveCityData(self.cityId)
                        end
                        -- UnityEngine.YieldReturn(WaitForSeconds(i * 1))
                        WaitForSeconds(i * 1)
                    end
                    self.fillTypeCoroutines:Remove(fillType)
                end
                --开启协程
                self.fillTypeCoroutines:Add(fillType,StartCoroutine(CoroutineFunc))
                --CoroutineFunc()
            end
            self.fillTypeInfos:ForEachKeyValue(EacheCharacterFillFunc)
            self.fillTypeInfos:Clear()
            DataManager.SaveCityData(self.cityId)
        end
    end
    self.checkTimeId = setInterval(TimeRealPerSecondFunc, 1000)
end

---实例化显示
function CityCharacter:OnInitView()

    --检测小人填充数据
    self:CheckCharacterFills()
    --遍历角色数据
    local characterInfos = List:New()
    local newCharacters = List:New()
    local removeIds = List:New()
    for id, info in pairs(self.characterData.infos) do
        characterInfos:Add(info)
    end
    characterInfos:Sort(Utils.SortGridByAscendingUseSerialNumber)
    characterInfos:ForEach(
        function(info)
            if self.characterControllers:ContainsKey(info.id) then
                self.characterControllers[info.id]:BindView()
            else
                local ret, entity = self:InitCharacter(info)
                if ret then
                    newCharacters:Add(entity)
                else
                    removeIds:Add(info.id)
                end
            end
        end
    )
    if removeIds:Count() > 0 then
        removeIds:ForEach(
            function(id)
                self.characterData.infos[id] = nil
            end
        )
        DataManager.SetCityDataByKey(self.cityId, DataKey.CharacterData, self.characterData)
    end
    newCharacters:ForEach(
        function(entity)
            entity:Active()
        end
    )
    self:SetIrrationalRx()
    EventManager.Brocast(EventType.CHARACTER_VIEW_COMPLETED, self.cityId)
end

---清除显示
function CityCharacter:OnClearView()
    self.characterControllers:ForEach(
        function(item)
            item:UnBindView()
        end
    )
end

--清理
function CityCharacter:OnClear()
    if self.fillTypeCoroutines:Count() > 0 then
        self.fillTypeCoroutines:ForEachKeyValue(
            function(type, coroutine)
                StopCoroutine(coroutine)
            end
        )
        self.fillTypeCoroutines:Clear()
    end

    self.gameSpeedSubscribe:unsubscribe()
    self.characterControllers:ForEach(
        function(item)
            item:DeActive()
        end
    )
    self.characterControllers:Clear()
    clearInterval(self.checkTimeId)
    --GameObject.Destroy(self.characterRoot.gameObject)
end

function CityCharacter:OnUpdate()
    local characters = self.characterControllers
    local characterKeyList = characters.keyList
    local count = characters:Count()
    for i = count, 1, -1 do
        local key = characterKeyList[i]
        local charcter = characters[key]
        if charcter ~= nil then
            charcter:Update()
        else
            print("[error]" .. 
                "CityCharacter:OnUpdate : " .. self.characterControllers.keyList .. ",count:" .. count .. ",i:" .. i
            )
        end
    end
end

---------------------------------
---事件响应
---------------------------------
--更新区域格子数据
function CityCharacter:UpgradeZoneGridDataFunc(zoneId, zoneType, level)

--暂时对建筑物件升级不处理格子更新信息
--    self.characterControllers:ForEach(
--        function(item)
--            item:UpdateGrid(zoneId, zoneType, level)
--        end
--    )
    if zoneType == ZoneType.Dorm then
        self:CheckCharacterFills()
    end
    self:SetIrrationalRx()
end

--移除日程
function CityCharacter:RemoveSchedulesFunc(schedules)
    local function EachCharacterFunc(item)
        item:RemoveSchedulesFunc(schedules)
    end
    self.characterControllers:ForEach(EachCharacterFunc)
end

--时间强制刷新
function CityCharacter:TimeForceRefreshFunc()
    local function EachCharacterFunc(item)
        item:SetNextSchedules()
    end
    self.characterControllers:ForEach(EachCharacterFunc)
end

--roof
function CityCharacter:RefreshRoofView()
    local function EachCharacterFunc(item)
        item:RefreshRoofView()
    end
    self.characterControllers:ForEach(EachCharacterFunc)
end

---------------------------------
---方法
---------------------------------
--获取小人数量
function CityCharacter:GetCharacterCount()
    local count = 0
    for id, info in pairs(self.characterData.infos) do
        count = count + 1
    end
    return count
end

--获取小人最大数量
function CityCharacter:GetCharacterMaxCount()
    return MapManager.GetDormPeopleAllNums(self.cityId)
end

--添加角色显示
function CityCharacter:InitCharacter(info)
    local curPos =  CityDefine.NpcPos --{ x=89, y=55 }
    if self.cityId==2 then
        curPos =  CityDefine.NpcPos --{ x=89, y=55 }
    elseif self.cityId==2 then
        curPos =  CityDefine.NpcPos --{ x=89, y=55 }
    end
    info.gender = Utils.GetGender(info.serialNumber)
    info.skinId = Utils.GetSkinId(info.serialNumber)

    -- if  PlayerModule.getSdkPlatform() == "wx" and  info.skinId > 1 then
    --     -- if self.cityId > 1 then
    --     --     info.skinId =1
    --     -- else 
    --     if   Core.Instance.IsIOSPlatform and Core.Instance.IsPhoneLow then
    --             info.skinId = 1           
    --     end
    --     -- end
    -- end

    info.res_id ="skin_" .. info.gender .. "_" .. info.skinId
    if info.id =="ID_1" then  --伐木场 男女
       -- info.res_id = 60008
    elseif info.id =="ID_2" then --建厨房女
         info.res_id = "skin_female_1"-- 60009
    elseif info.id =="ID_3" then ----吃饭女
         info.res_id = "skin_female_1" -- 60009
    elseif info.id =="ID_4" then --建猎人小屋 男
         --info.res_id = 60008
    end

   -- info.res_id =60008
    --info.playerPos = { x=90, y=55 }
     local xd =0-- math.random(0,9)
     local yd =0-- math.random(0,9)
    local characterController = CharacterController.new(info)

    local mapTr = GameObject.Find("Map").transform
    local rootChars = mapTr:Find("Chars")
    local obj = rootChars:Find("CityChar").gameObject
    local playerGo = GOInstantiate(obj, rootChars)
    playerGo:SetActive(true)
    local mapCtrl = CityModule.getMapCtrl()
    local initCell =mapCtrl:getCellByXY(curPos.x+xd,curPos.y+yd)
    characterController:bind(playerGo,info.res_id)  --暂时在这里设置小人spine 资源id =0
--    characterController:SetAnim(AnimationType.Idle)
--    characterController:playAnim("idle",CityPosition.Dir.Down) --朝下
    characterController:setSortingOrder(1010)       
    characterController:setCell(initCell)
    --characterController:setPlayerCell(initCell)

    --characterController:playAnim(CityPlayerAnim.Idle, CityPosition.Dir.Down) --朝下

    if characterController:OnInit(self.cityId, info) then
        if self.isShowView then
            characterController:BindView()
        end
        -- if bNewPlayer then
           
        --     characterController:SetAnim(AnimationType.Run)
        --     characterController:playAnim("run")
        --     characterController.movetype=33 
        -- else
              characterController:SetAnim(AnimationType.Idle)
              characterController:playAnim("idle",CityPosition.Dir.Down)
        --end     
        --非暴动状态，兼容小人数据
       if  ProtestManager and not ProtestManager.IsProtestStatus(self.cityId) then
             
                if(characterController:GetState() == EnumState.Protest) then
  
                        characterController:SetMarkState(EnumMarkState.None)
                        characterController:SetNextState(EnumState.Normal)
                end

       end

       self.characterControllers:Add(info.id, characterController)

        return true, characterController
    else
        GODestroy(characterController.gameObject)
        return false
    end


end

--删除角色
function CityCharacter:RemoveCharacter(id)
    self.characterControllers:Remove(id)
    if self.characterData.infos[id] then
        self.characterData.infos[id] = nil
        DataManager.SetCityDataByKey(self.cityId, DataKey.CharacterData, self.characterData)
        self:CreateCharacterFills(FillType.Dead, 1)
    end
end

--获取小人刷新时间间隔
function CityCharacter:GetPeopleRefreshCoolDown(fillType)
    if fillType == FillType.Build then
        if self.peopleRefreshCoolDownFixedValue >= 0 then
            return self.peopleRefreshCoolDownFixedValue
        end
        if
            TutorialManager.CurrentStep.value == TutorialStep.FirstEnterCity or
            TutorialManager.CurrentStep.value == TutorialStep.FirstEnterCity2 or
            TutorialManager.CurrentStep.value == TutorialStep.EventEnterCity or
            TutorialManager.CurrentStep.value == TutorialStep.EventWarehouse
        then
            return 1
        elseif
            ConfigManager.GetMiscConfig("people_first4_come_immediately") and
            self.characterData.serialNumber <= self.neverGetSick
        then
            return 1
        else
            return math.random(self.people_refresh_cooldown[1], self.people_refresh_cooldown[2])
        end
    elseif fillType == FillType.Dead then
        if self.isEventScene then
            return self.replenish_people_frequency
        else
            if BoostManager.GetRxBoosterValue(self.cityId, RxBoostType.PeopleFastCome) == 1 then
                return 1
            else
                return math.random(self.replenish_people_frequency[1], self.replenish_people_frequency[2])
            end
        end
    end
end

function CityCharacter:IsPeopleCreateByVIP(fillType)
    return fillType == FillType.Dead and BoostManager.GetRxBoosterValue(self.cityId, RxBoostType.PeopleFastCome) == 1
end

--检测填充小人
function CityCharacter:CheckCharacterFills()
    local fillCount = 0
    for type, info in pairs(self.characterData.fillTypes) do
        fillCount = fillCount + info.count
    end
    local addCount = self:GetCharacterMaxCount() - self:GetCharacterCount() - fillCount
    if addCount > 0 then
        self:CreateCharacterFills(FillType.Build, addCount)
    end
end

--创建填充类型
function CityCharacter:CreateCharacterFills(type, count)
    if count <= 0 then
        return
    end
    if self.characterData.fillTypes[type] then
        self.characterData.fillTypes[type].count = self.characterData.fillTypes[type].count + count
    else
        self.characterData.fillTypes[type] = {}
        self.characterData.fillTypes[type].count = count
        self.characterData.fillTypes[type].time = TimeManager.GameTime()
        self.characterData.fillTypes[type].coolDown = self:GetPeopleRefreshCoolDown(type)
    end
    DataManager.SaveCityData(self.cityId)
    --更新小人数量
    self:SetIrrationalRx()
    --发送事件
    local fromType = ""
    if type == FillType.Build then
        fromType = "new"
        EventManager.Brocast(EventType.CHARACTER_REFRESH, self.cityId, true)
    elseif type == FillType.Dead then
        fromType = "replenish"
        EventManager.Brocast(EventType.CHARACTER_REFRESH, self.cityId, false)
        EventManager.Brocast(EventType.CHARACTER_ATTRIBUTE_BOOST, self.cityId)
    end
end

--创建角色协程
function CityCharacter:CreateCharacter(isCreateByVIP)
    --查找空床位
    isCreateByVIP = isCreateByVIP or false
    local bed = GridManager.GetGridByMarkerType(self.cityId, GridMarker.Bed, ZoneType.Dorm)
    if not bed then
        return false
    end
    --初始化角色信息
    local id = "ID_" .. self.characterData.serialNumber
    local info = {}
    info.id = id
    info.serialNumber = self.characterData.serialNumber
    info.isNew = true
    info.state = EnumState.Normal
    info.professionType = ProfessionType.FreeMan
--    info.gender = Utils.GetGender(info.serialNumber)
--    info.skinId = Utils.GetSkinId(info.serialNumber)
    info.attributeInfo = Utils.GetAttributeInfo(self.cityId)
    --添加角色显示
    local ret, entity = self:InitCharacter(info)
    if not ret then
        return false
    end
    if nil ~= entity then
        entity:Active()
    end
    if not GameManager.TutorialOpen and self.isShowView then
        if isCreateByVIP then
            self:ShowListToast(GetLang("toast_new_survivor_arrived"), ToastListColor.Gold, ToastListIconType.Staff)
            -- self:ShowListToast(GetLang("toast_new_survivor_arrived"), ToastListColor.Gold, ToastListIconType.StaffVIP)
        else
            self:ShowListToast(GetLang("toast_new_survivor_arrived"), ToastListColor.Green, ToastListIconType.Staff)
        end
    end
    --添加角色信息
    self.characterData.infos[id] = info
    self.characterData.serialNumber = self.characterData.serialNumber + 1
    DataManager.SetCityDataByKey(self.cityId, DataKey.CharacterData, self.characterData)
    EventManager.Brocast(EventType.CHARACTER_REFRESH, self.cityId, true)
    self:SetIrrationalRx()
    return true
end

--根据Id获取角色对象
function CityCharacter:GetCharacterById(id)
    local character = nil
    self.characterControllers:ForEach(
        function(item)
            if item.id == id then
                character = item
                return true
            end
        end
    )
    return character
end

--根据编号获取角色对象
function CityCharacter:GetCharacterBySerialNumber(serialNumber)
    local character = nil
    self.characterControllers:ForEach(
        function(item)
            if item:GetSerialNumber() == serialNumber then
                character = item
                return true
            end
        end
    )
    return character
end

--根据索引获取角色对象
function CityCharacter:GetCharacterByIndex(index)
    return self.characterControllers[index]
end

--根据状态类型获取角色列表
function CityCharacter:GetCharactersByStateType(stateType)
    local ret = List:New()
    self.characterControllers:ForEach(
        function(item)
            if item:GetState() == stateType then
                ret:Add(item)
            end
        end
    )
    return ret
end

--根据标记类型获取角色列表
function CityCharacter:GetCharactersByMarkType(markType)
    local ret = List:New()
    self.characterControllers:ForEach(
        function(item)
            if item:GetMarkState() == markType then
                ret:Add(item)
            end
        end
    )
    return ret
end

--根据状态类型获取角色数量
function CityCharacter:GetCharacterCountByStateType(stateType)
    local ret = 0
    self.characterControllers:ForEach(
        function(item)
            if item:GetState() == stateType then
                ret = ret + 1
            end
        end
    )
    return ret
end

--获取全部角色
function CityCharacter:GetAllCharactersByList()
    local ret = List:New()
    self.characterControllers:ForEach(
        function(item)
            ret:Add(item)
        end
    )
    return ret
end

--根据职业类型获取角色列表
function CityCharacter:GetCharactersByPeopleType(professionType)
    local ret = List:New()
    self.characterControllers:ForEach(
        function(item)
            if item:GetProfessionType() == professionType then
                ret:Add(item)
            end
        end
    )
    return ret
end

--根据生病区域获取角色列表
function CityCharacter:GetCharactersBySickZone(zoneType, state)
    local ret = List:New()
    if state then
        self.characterControllers:ForEach(
            function(item)
                if item:GetState() == state and item:IsHealZone(zoneType) then
                    ret:Add(item)
                end
            end
        )
    else
        self.characterControllers:ForEach(
            function(item)
                if item:IsHealZone(zoneType) then
                    ret:Add(item)
                end
            end
        )
    end
    return ret
end

--获取生病小人信息
function CityCharacter:SendSickAnalytics()
    local sick = 0
    local EachCharacterFunc = function(charcter)
        local state = charcter:GetState()
        if state == EnumState.Severe then
            sick = sick + 1
        elseif state == EnumState.Sick then
            sick = sick + 1
        end
    end
    self.characterControllers:ForEach(EachCharacterFunc)
    Analytics.Event("PeopleGetSick", { totalSickPeople = sick, totalPeople = self:GetCharacterMaxCount() })
end

---分配
function CityCharacter:Assignment(professionType)
    local list = self:GetCharactersByPeopleType(ProfessionType.FreeMan)
    if list:Count() <= 0 then
        return false
    end
    if GameManager.TutorialOpen then
        list:Sort(Utils.SortCharacterBySerialNumber)
    else
        list:Sort(Utils.SortCharacterByAscendingUseHealth)
    end
    local character = nil
    list:ForEach(
        function(item)
            if item:GetState() == EnumState.Normal then
                character = item
                return true
            end
        end
    )
    if character then
        character:SetProfessionType(professionType)
        return true
    else
        return false
    end
end

---取消职业分配
function CityCharacter:CancelAssignment(professionType)
    local list = self:GetCharactersByPeopleType(professionType)
    if list:Count() <= 0 then
        return false
    end
    local character = nil
    list:ForEach(
        function(item)
            if item:GetState() == EnumState.Sick then
                character = item
                return true
            end
            if item:GetState() == EnumState.Severe then
                character = item
                return true
            end
            if item:GetState() == EnumState.Protest then
                character = item
                return true
            end
        end
    )
    if nil == character then
        list:Sort(Utils.SortCharacterByDescendingUseHealth)
        character = list[1]
    end
    if character then
        character:SetProfessionType(ProfessionType.FreeMan)
        return true
    else
        return false
    end
end

--获取属性平均值
function CityCharacter:GetAttributeValue(type)
    if type == AttributeType.SurfaceTemperature then
        return self:GetSurfaceTempValue()
    elseif type == AttributeType.Warm then
        return self:GetWarmValue()
    else
        local count = 0
        local value = 0
        self.characterControllers:ForEach(
            function(item)
                value = value + item:GetAttribute(type)
                count = count + 1
            end
        )
        return value / count
    end
end

--获取生存着不合理人数numberRx
function CityCharacter:GetIrrationalRx()
    return self.irrationalRx
end

-- 刷新生存者不合理人数 min（工作坑位数，无职业数）
function CityCharacter:SetIrrationalRx()
    local freeCount = 0
    self.characterControllers:ForEach(
        function(item)
            if item:GetState() == EnumState.Normal and item:GetProfessionType() == ProfessionType.FreeMan then
                freeCount = freeCount + 1
            end
        end
    )
    local wantCount = 0
    for ix, peopleCfg in pairs(ConfigManager.GetPeopleList(self.cityId)) do
        if peopleCfg.type ~= ProfessionType.FreeMan and MapManager.GetZoneCount(self.cityId, peopleCfg.zone_type, 1) > 0 then
            local totalCount = self:GetCharactersByPeopleType(peopleCfg.type):Count()
            local wantWorkerCount = self:GetWantWorkerCount(peopleCfg)
            if wantWorkerCount > totalCount then
                wantCount = wantCount + (wantWorkerCount - totalCount)
            end
        end
    end
    if freeCount > wantCount then
        self.irrationalRx.value = wantCount
    else
        self.irrationalRx.value = freeCount
    end
end

--获取工作状态人数
function CityCharacter:GetPeopleStateCount(parameter)
    local peopleCount = {}
    --填充小人数量
    local function FillPeopleCount(state)
        if state == EnumState.Severe then
            state = EnumState.Sick
        elseif state == EnumState.HealthLow then
            state = EnumState.Normal
        end
        if not peopleCount[state] then
            peopleCount[state] = 0
        end
        peopleCount[state] = peopleCount[state] + 1
    end
    --遍历小人
    local function EachCharacterFunc(character)
        if character:GetProfessionType() == parameter then
            FillPeopleCount(character:GetState())
        elseif character.bedGrid.zoneId == parameter then
            FillPeopleCount(character:GetState())
        end
    end
    self.characterControllers:ForEach(EachCharacterFunc)
    return peopleCount
end

--获取小人工作状态数量统计
function CityCharacter:GetPeopleWorkStateCount()
    local workCount = 0
    local cantWorkCount = 0

    local function EachWorkPeople(peopleCfg)
        local wc = 0
        local cwc = 0
        local unlockIndexs =
            MapManager.GetUnlockFurnitureIndexs(self.cityId, peopleCfg.zone_type, peopleCfg.furniture_id)

        for i = 1, unlockIndexs:Count(), 1 do
            local grid =
                GridManager.GetGridByFurnitureId(
                    self.cityId,
                    peopleCfg.furniture_id,
                    unlockIndexs[i],
                    GridStatus.Unlock
                )
            local state = grid:GetFurnitureWorkState()
            if state == WorkStateType.Work then
                wc = wc + 1
            elseif state ~= WorkStateType.None and state ~= WorkStateType.Work then
                cwc = cwc + 1
            end
        end

        return wc, cwc
    end

    -- 无职员工
    local function EachPeopleCfg(peopleType)
        local peopleStateCount = self:GetPeopleStateCount(peopleType)
        local normalCount = peopleStateCount[EnumState.Normal] or 0
        local sickCount = peopleStateCount[EnumState.Sick] or 0
        local protestCount = peopleStateCount[EnumState.Protest] or 0

        return normalCount, sickCount + protestCount
    end

    -- 在职员工
    for ix, peopleCfg in pairs(ConfigManager.GetPeopleList(self.cityId)) do
        if peopleCfg.type ~= ProfessionType.FreeMan and MapManager.GetZoneCount(self.cityId, peopleCfg.zone_type, 1) > 0 then
            local zoneWC, zoneCTC = EachWorkPeople(peopleCfg)
            local charWC, charCTC = EachPeopleCfg(peopleCfg.type)

            local realWC = charWC
            if zoneWC < charWC then
                realWC = zoneWC
            end

            workCount = workCount + realWC
            cantWorkCount = cantWorkCount + (charWC - realWC) + charCTC
        end
    end

    local fc, cantc = EachPeopleCfg(ProfessionType.FreeMan)
    cantWorkCount = cantWorkCount + cantc

    return workCount, cantWorkCount, fc
end

--获取想要工作人数
function CityCharacter:GetWantWorkerCount(peopleCfg)
    local zoneType = peopleCfg.zone_type
    local furnitureId = peopleCfg.furniture_id
    local unlockIndexs = MapManager.GetUnlockFurnitureIndexs(self.cityId, zoneType, furnitureId)
    local wantWorkerCount = 0
    for i = 1, unlockIndexs:Count(), 1 do
        local grid = GridManager.GetGridByFurnitureId(self.cityId, furnitureId, unlockIndexs[i], GridStatus.Unlock)
        if nil == grid then
        else
            if grid:GetFurnitureWorkState() ~= WorkStateType.Disable then
                wantWorkerCount = wantWorkerCount + 1
            end
        end
    end
    return wantWorkerCount
end

--获取小人体表温度
function CityCharacter:GetSurfaceTempValue()
    --环境温度
    local environmentTemp = CityManager.GetTemperature(self.cityId) + WeatherManager.GetTemperature(self.cityId)
    --火炉温度
    local generatorTemp = GeneratorManager.GetTemperature(self.cityId)
    --小人数量对温度丼影响
    local characterCount = self:GetCharacterCount()
    -- --体表温度
    local surfaceTemp =
        (generatorTemp - characterCount * self.bodyTemp.constant_a + environmentTemp) * self.bodyTemp.constant_c
    local finalTemp = surfaceTemp
    --衰减温度线
    if surfaceTemp > self.bodyTemp.constant_d then
        finalTemp = math.sqrt(surfaceTemp - self.bodyTemp.constant_d) + self.bodyTemp.constant_d
    end
    if surfaceTemp < self.bodyTemp.constant_e then
        finalTemp = -math.sqrt(-surfaceTemp + self.bodyTemp.constant_e) + self.bodyTemp.constant_e
    end
    return finalTemp
end

--获取当前温暖
function CityCharacter:GetWarmValue()
    local surfaceTemp = self:GetSurfaceTempValue()
    local warmValue = self.tempScore.constant_a * surfaceTemp + self.tempScore.constant_b
    if warmValue > 100 then
        warmValue = 100
    elseif warmValue < 0 then
        warmValue = 0
    end

    --温度是否安全
    if nil == self.warmSafe then
        if warmValue < self.overdriveControl.constant_a then
            self.warmSafe = false
        else
            self.warmSafe = true
        end
    elseif self.warmSafe then
        if warmValue < self.overdriveControl.constant_a then
            self.warmSafe = false
        end
    elseif warmValue >= self.overdriveControl.constant_b then
        self.warmSafe = true
    end

    --温度是否预警
    if nil == self.warmWarning then
        if warmValue < self.warmSafeLine then
            self.warmWarning = true
        else
            self.warmWarning = false
        end
        EventManager.Brocast(EventType.WARM_WARNING_CHANEG, self.cityId, self.warmWarning, true)
    elseif self.warmWarning then
        if warmValue >= self.warmSafeLine then
            self.warmWarning = false
            EventManager.Brocast(EventType.WARM_WARNING_CHANEG, self.cityId, self.warmWarning, false)
        end
    else
        if warmValue < self.warmSafeLine then
            self.warmWarning = true
            EventManager.Brocast(EventType.WARM_WARNING_CHANEG, self.cityId, self.warmWarning, false)
        end
    end
    if nil ~= self.warmValue and warmValue > self.warmValue and not self.isEventScene then
        self.characterControllers:ForEach(
            function(item)
                item:SetWarningViewWarmRise(self.warmValue, warmValue)
            end
        )
    end
    self.warmValue = warmValue
    return warmValue
end

--温暖属性是否高于健康的安全线
function CityCharacter:IsWarmAboveSafeLine()
    return self.warmSafe
end

------------------------------------------------------------------------------
---生病
------------------------------------------------------------------------------
--初始化疾病信息
function CityCharacter:InitDiseaseInfo()
    self.diseaseWeightInfos = List:New()
    self.diseaseTotalWeight = {}
    --获取生病权重
    local function GetDiseaseWeight(type)
        if nil == self.diseaseTotalWeight[type] then
            self.diseaseTotalWeight[type] = 0
        end
        return self.diseaseTotalWeight[type]
    end
    --设置生病权重
    local function SetDiseaseWeight(type, value)
        if nil == self.diseaseTotalWeight[type] then
            self.diseaseTotalWeight[type] = 0
        end
        self.diseaseTotalWeight[type] = self.diseaseTotalWeight[type] + value
    end
    --获取生病权重信息
    local function GetDiseaseWeightInfo(weight)
        local weightInfo = {}
        for type, value in pairs(weight) do
            weightInfo[type] = {}
            weightInfo[type].minValue = GetDiseaseWeight(type)
            SetDiseaseWeight(type, value)
            weightInfo[type].maxValue = GetDiseaseWeight(type)
        end
        return weightInfo
    end
    for i = 1, #self.cityConfig.disease_pool, 1 do
        local config = ConfigManager.GetDiseaseConfigById(self.cityConfig.disease_pool[i])
        local info = {}
        info.id = config.id
        info.weightInfo = GetDiseaseWeightInfo(config.weight)
        self.diseaseWeightInfos:Add(info)
    end
    -- local function EachWeightInfo(info)
    --     for type, weight in pairs(info.weightInfo) do
    --     end
    -- end
    -- self.diseaseWeightInfos:ForEach(EachWeightInfo)
end

--根据属性获取生病信息
function CityCharacter:GetDiseaseIdByAttributeType(attributeType)
    local randomWeight = math.random(self.diseaseTotalWeight[attributeType]) - 1
    local diseaseId = nil
    local function EachDiseaseInfo(info)
        if
            randomWeight >= info.weightInfo[attributeType].minValue and
            randomWeight < info.weightInfo[attributeType].maxValue
        then
            diseaseId = info.id
            return true
        end
    end
    self.diseaseWeightInfos:ForEach(EachDiseaseInfo)
    if diseaseId == nil then
        local function LogEachDiseaseInfo(info)
        end
        self.diseaseWeightInfos:ForEach(LogEachDiseaseInfo)
    end
    return diseaseId
end

--获取疾病医疗值
function CityCharacter:GetDiseaseMedicalNeed(diseaseId)
    local diseaseConfig = ConfigManager.GetDiseaseConfigById(diseaseId)
    if nil == diseaseConfig then
    end
    return diseaseConfig.medical_need * self.cityConfig.medical_difficulty
end

--设置强制生病
function CityCharacter:SetCharacterForceSick(gender, skinId)
    local entity = nil
    local sickEntitys = self:GetCharactersBySickZone(ZoneType.Infirmary, EnumState.Sick)
    if sickEntitys:Count() > 0 then
        entity = sickEntitys[1]
    else
        local severeEntitys = self:GetCharactersBySickZone(ZoneType.Infirmary, EnumState.Severe)
        if severeEntitys:Count() > 0 then
            entity = severeEntitys[1]
        else
            local freeManEntitys = self:GetCharactersByPeopleType(ProfessionType.FreeMan)
            if freeManEntitys:Count() > 0 then
                entity = freeManEntitys[1]
                entity:SetNextState(EnumState.Severe)
            else
                local characters = List:New()
                self.characterControllers:ForEach(
                    function(item)
                        if
                            item:GetState() == EnumState.Normal and item:GetProfessionType() ~= ProfessionType.Hunter and
                            item:GetProfessionType() ~= ProfessionType.Chef
                        then
                            characters:Add(item)
                        end
                    end
                )
                entity = characters[math.random(characters:Count())]
                entity:SetNextState(EnumState.Severe)
            end
        end
    end
    return entity
end

--获取小人刷新冷却修正值
function CityCharacter:SetPeopleRefreshCoolDownFixedValue(v)
    self.peopleRefreshCoolDownFixedValue = v
    if self.characterData.fillTypes[FillType.Build] then
        self.characterData.fillTypes[FillType.Build].coolDown = 1
    end
end

--获取小人
function CityCharacter:GetAttributeDebuffCount()
    local info = {}
    self.characterControllers:ForEach(
        function(item)
            for type, value in pairs(item.attributeBoost) do
                if value > 0 then
                    if not info[type] then
                        info[type] = 0
                    end
                    info[type] = info[type] + 1
                end
            end
        end
    )
    return info
end

function CityCharacter:AddMaxAttribute(type, count)
    local target
    local num = 0
    self.characterControllers:ForEach(
        function(item)
            if count <= num then
                return
            end
            for key, value in pairs(item.attributeBoost) do
                if key == type then 
                    if value > 0 then
                        item:AddMaxAttribute(type)
                        num = num +1
                        return
                    end
                end
            end
        end
    )
end
