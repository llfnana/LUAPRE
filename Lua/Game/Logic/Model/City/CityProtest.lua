CityProtest = Clone(CityBase) --抗议
CityProtest.__cname = "CityProtest"

function CityProtest:OnInit()
    self.protestTrigger = ConfigManager.GetFormulaConfigById("protestTrigger")
    self.appeaseCountRefresh = ConfigManager.GetMiscConfig("protest_appease_count_reflash")
    self.isOpen = FunctionsManager.IsOpen(self.cityId, FunctionsType.Protest)
    if self.isOpen then
        self:InitProtest()
    end
end

---实例化显示
function CityProtest:OnInitView()
    --非暴动状态，兼容小人数据
    if not self:IsProtestStatus() then
        CharacterManager.GetCharactersByStateType(self.cityId, EnumState.Protest):ForEach(
            function(item)
                item:SetMarkState(EnumMarkState.None)
                item:SetNextState(EnumState.Normal)
            end
        )
    end
end

---清除显示
function CityProtest:OnClearView()
end

function CityProtest:OnClear()
    if self.protestAppeaseSubscribe then
        self.protestAppeaseSubscribe:unsubscribe()
        self.protestAppeaseSubscribe = nil
    end
    self = nil
end

---------------------------------
---事件响应
---------------------------------
--功能解锁事件响应
function CityProtest:SetProtestOpen(isOpen)
    if self.isOpen ~= isOpen then
        self.isOpen = isOpen
        if isOpen then
            self:InitProtest()
        end
    end
end

--真实时间每秒刷新响应
function CityProtest:TimeRealPerSecondFunc()
    if not self.isOpen then
        return
    end
    if CityManager.GetIsEventScene(self.cityId) then
        return
    end
    self:UpdateProtest()
end

--角色刷新事件响应
function CityProtest:RefreshCharacterFunc(isAdd)
    if not self.isOpen then
        return
    end
    if CityManager.GetIsEventScene(self.cityId) then
        return
    end
    if not isAdd then
        self:AddDespairValue()
    end
end

--获取卡牌事件响应
function CityProtest:AddCardFunc(cardId)
    if not self.isOpen then
        return
    end
    if CityManager.GetIsEventScene(self.cityId) then
        return
    end
    if cardId ~= self.cardId then
        return
    end
    self:UpdateCardLevel()
end

--升级卡牌等级响应
function CityProtest:UpgradeCardLevelFunc(cardId, level)
    if not self.isOpen then
        return
    end
    if cardId ~= self.cardId then
        return
    end
    self:UpdateCardLevel()
end

--升级卡牌等级响应
function CityProtest:ZoneCardChangeFunc(zoneId)
    if not self.isOpen then
        return
    end
    if zoneId ~= self.cardZoneId then
        return
    end
    self:SetCardInfo()
end

---初始化暴动
function CityProtest:InitProtest()
    self.cardZoneId = ConfigManager.GetZoneIdByZoneType(self.cityId, ZoneType.Watchtower)
    self.cardLevelRx = NumberRx:New(0)
    self:SetCardInfo()

    self.despairValue = DataManager.GetCityDataByKey(self.cityId, DataKey.Despair) or 0
    --读取数据
    self.protestData = DataManager.GetCityDataByKey(self.cityId, DataKey.ProtestData)
    if nil == self.protestData then
        self.protestData = {}
        self.protestData.status = ProtestStatus.None
        self.protestData.protestNum = 0
        DataManager.SetCityDataByKey(self.cityId, DataKey.ProtestData, self.protestData)
    elseif nil == self.protestData.protestNum then
        self.protestData.protestNum = 0
    end

    --暴动治安官触发安抚次数事件监听
    self.protestAppeaseSubscribe =
        BoostManager.GetRxBooster(self.cityId, RxBoostType.ProtestPeopleCount):subscribe(
            function(count)
                self.protestAppeaseMaxCount = count + ConfigManager.GetMiscConfig("protest_appease_count")
                if self.protestData.status == ProtestStatus.Talk or self.protestData.status == ProtestStatus.Run then
                    if nil == self.protestData.appeaseRefreshTime then
                        self.protestData.appeaseCount = self.protestAppeaseMaxCount
                        DataManager.SetCityDataByKey(self.cityId, DataKey.ProtestData, self.protestData)
                    elseif self.protestData.appeaseCount > self.protestAppeaseMaxCount then
                        self.protestData.appeaseCount = self.protestAppeaseMaxCount
                        self.protestData.appeaseRefreshTime = nil
                        DataManager.SetCityDataByKey(self.cityId, DataKey.ProtestData, self.protestData)
                    end
                end
            end
        )
end

--刷新暴动
function CityProtest:UpdateProtest()
    local currentTime = GameManager.GameTime()
    if self.protestData.status == ProtestStatus.Talk then
        self:UpdateProtestAppeaseCount()
        local remainingTime = self.protestData.statusEndTime - currentTime
        if remainingTime > 0 then
            EventManager.Brocast(EventType.PROTEST_TIME_CHANGE, self.cityId, remainingTime)
        else
            self:RunProtest()
        end
    elseif self.protestData.status == ProtestStatus.Run then
        self:UpdateProtestAppeaseCount()
        local remainingTime = self.protestData.statusEndTime - currentTime
        if remainingTime > 0 then
            EventManager.Brocast(EventType.PROTEST_TIME_CHANGE, self.cityId, remainingTime)
        else
            self:CloseProtest()
        end
    elseif self.protestData.status == ProtestStatus.CoolDown then
        if currentTime >= self.protestData.statusEndTime then --重制暴动
            self.protestData.status = ProtestStatus.None
            self.protestData.statusEndTime = nil
            DataManager.SetCityDataByKey(self.cityId, DataKey.ProtestData, self.protestData)
            EventManager.Brocast(EventType.PROTEST_STATE_CHANGE, self.cityId, ProtestStatus.None)
        end
    end
end

--获取暴动组
function CityProtest:SetProtestGroupId()
    local groupIds = List:New()
    for id, config in pairs(ConfigManager.GetProtestGroupConfigs()) do
        groupIds:Add(id)
    end
    return groupIds[math.random(groupIds:Count())]
end

--获取暴动事件列表
function CityProtest:SetProtestAppeaseInfos()
    --获取当前场景可用的消耗资源
    local materialLog = ""
    local materialItems = List:New()
    ConfigManager.GetZonesByCityId(self.cityId):ForEachKeyValue(
        function(zoneId, zone)
            local mapItemData = MapManager.GetMapItemData(self.cityId, zoneId)
            local ret, output = mapItemData:IsProdutcionsItem()
            if ret then
                for itemId, itemCount in pairs(output) do
                    materialItems:Add(itemId)
                    if materialLog == "" then
                        materialLog = itemId
                    else
                        materialLog = materialLog .. "|" .. itemId
                    end
                end
            end
        end
    )
    local materialCount = materialItems:Count()

    --获取安抚配置
    local protestAppeaseConfigs = ConfigManager.GetProtestAppeaseConfigsByGroupId(self.protestData.groupId)
    local function SelectAppeaseConfig(subGroup)
        local selectConfigs = List:New()
        protestAppeaseConfigs:ForEach(
            function(config)
                --安抚事件是否可用
                if config.sub_group == subGroup then
                    if config.appease_type == "Resources" then
                        if materialCount > 0 then
                            selectConfigs:Add(config)
                        end
                    else
                        selectConfigs:Add(config)
                    end
                end
            end
        )
        return selectConfigs[math.random(selectConfigs:Count())]
    end

    --获取安抚图标
    local function SelectAppeaseIconInfo(subGroup)
        local buttonInfo = ConfigManager.GetMiscConfig("appease_btn" .. subGroup)
        local iconPaths = List:New()
        for path, name in pairs(buttonInfo) do
            iconPaths:Add(path)
        end
        local path = iconPaths[math.random(iconPaths:Count())]
        return path, buttonInfo[path]
    end

    --获取生产物品的秒产
    local productionsPerSeconds = {}
    local function GetProductionsPerSeconds(itemId)
        if not productionsPerSeconds[itemId] then
            productionsPerSeconds[itemId] = StatisticalManager.GetOutputProductionsPerSecond(self.cityId, itemId)
        end
        return productionsPerSeconds[itemId]
    end

    --选择三个安抚事件
    local protestAppeaseInfos = {}

    for subGroup = 1, 3, 1 do
        local config = SelectAppeaseConfig(subGroup)
        local itemId = nil
        if config.appease_type == "BurnRes" then
            itemId = GeneratorManager.GetConsumptionItemId(self.cityId)
        elseif config.appease_type == "Resources" then
            itemId = materialItems[math.random(materialCount)]
        end
        local path, name = SelectAppeaseIconInfo(subGroup)
        local info = {}
        info.appeaseId = config.id
        info.appeaseIcon = path
        info.appeaseName = name
        if itemId then
            info.itemId = itemId
            info.itemCost = math.ceil(GetProductionsPerSeconds(itemId) * config.appease_cost)
        end

        table.insert(protestAppeaseInfos, info)
    end

    return protestAppeaseInfos
end

--开启暴动
function CityProtest:OpenProtest()
    Audio.PlayAudio(DefaultAudioID.PlayerNotSatisfied)
    local characterCount = 0
    local characters = CharacterManager.GetCharactersByStateType(self.cityId, EnumState.Normal)
    characters:ForEach(
        function(item)
            item:SetMarkState(EnumMarkState.Talk)
            characterCount = characterCount + 1
        end
    )
    self.protestData.status = ProtestStatus.Talk
    self.protestData.statusEndTime = TimeManager.GameTime() + self.cityConfig.talks_duration
    self.protestData.totalCount = characterCount
    self.protestData.currentCount = characterCount
    self.protestData.groupId = self:SetProtestGroupId()
    self.protestData.appeaseInfos = self:SetProtestAppeaseInfos()
    self.protestData.appeaseCount = self.protestAppeaseMaxCount
    DataManager.SetCityDataByKey(self.cityId, DataKey.ProtestData, self.protestData)

    EventManager.Brocast(EventType.PROTEST_STATE_CHANGE, self.cityId, ProtestStatus.Talk)
    EventManager.Brocast(EventType.PROTEST_TIME_CHANGE, self.cityId, self.cityConfig.talks_duration)

    -- 
    if GameManager.GetModeType() == ModeType.MainScene then
        TutorialManager.TriggerTutorial(TutorialStep.ProtestTalks)
    end
end

--运行暴动
function CityProtest:RunProtest()
    self:ShowListToast(GetLang("ui_protest_toast_start"), ToastListColor.Red, ToastListIconType.RiotsStart)
    self.protestData.status = ProtestStatus.Run
    self.protestData.statusEndTime = TimeManager.GameTime() + self.cityConfig.protest_duration
    DataManager.SetCityDataByKey(self.cityId, DataKey.ProtestData, self.protestData)

    local characters = CharacterManager.GetCharactersByMarkType(self.cityId, EnumMarkState.Talk)
    characters:ForEach(
        function(item)
            item:SetMarkState(EnumMarkState.None)
            item:SetNextState(EnumState.Protest)
        end
    )
    --暴动状态切换
    EventManager.Brocast(EventType.PROTEST_STATE_CHANGE, self.cityId, ProtestStatus.Run)
    EventManager.Brocast(EventType.PROTEST_TIME_CHANGE, self.cityId, self.cityConfig.protest_duration)

    if GameManager.GetModeType() == ModeType.MainScene then
        -- 若是没有引导界面，则不进行引导（第四关以后就没有引导界面了）
        TutorialManager.TriggerTutorial(TutorialStep.ProtestRiots)
    end
end

--关闭暴动
function CityProtest:CloseProtest()
    
    --重制小人属性
    local characterCount = 0
    if self.protestData.status == ProtestStatus.Talk then
        local characters = CharacterManager.GetCharactersByMarkType(self.cityId, EnumMarkState.Talk)
        characters:ForEach(
            function(item)
                item:SetMarkState(EnumMarkState.None)
                characterCount = characterCount + 1
            end
        )
    elseif self.protestData.status == ProtestStatus.Run then
        local characters = CharacterManager.GetCharactersByStateType(self.cityId, EnumState.Protest)
        characters:ForEach(
            function(item)
                item:SetMarkState(EnumMarkState.None)
                item:SetNextState(EnumState.Normal)
                characterCount = characterCount + 1
            end
        )
    end

    local isSuccess = false
    local remainingTime = self.protestData.statusEndTime - TimeManager.GameTime()
    if remainingTime > 10 and self.protestData.currentCount <= 0 then
        isSuccess = true
    end

    --获取小人数量
    local params = {}
    params.isSuccess = isSuccess
    params.totalPeople = CharacterManager.GetCharacterMaxCount(self.cityId)
    if self.cardId ~= 0 then
        params.cardId = self.cardId
        params.cardLevel = self.cardLevelRx.value
    end
    if not isSuccess then
        params.leaveProtester = characterCount
    end
    -- Analytics.Event("ProtestEnd", params)

    --设置暴动状态
    self.protestData.status = ProtestStatus.CoolDown
    self.protestData.statusEndTime = TimeManager.GameTime() + self.cityConfig.protest_cooldown
    self.protestData.protestNum = self.protestData.protestNum + 1
    self.protestData.totalCount = nil
    self.protestData.currentCount = 0
    self.protestData.groupId = nil
    self.protestData.appeaseInfos = nil
    self.protestData.appeaseRefreshTime = nil
    DataManager.SetCityDataByKey(self.cityId, DataKey.ProtestData, self.protestData)
    --暴动状态切换
    EventManager.Brocast(EventType.PROTEST_STATE_CHANGE, self.cityId, ProtestStatus.CoolDown)
    --重制希望值
    self.despairValue = 0
    DataManager.SetCityDataByKey(self.cityId, DataKey.Despair, self.despairValue)
end

--使用暴动安抚事件
function CityProtest:UseProtestAppeaseEvent(appeaseInfo, appeaseIndex)
    local appeaseConfig = ConfigManager.GetProtestAppeaseConfigById(appeaseInfo.appeaseId)
    if appeaseConfig.appease_type == "BurnRes" or appeaseConfig.appease_type == "Resources" then
        DataManager.AddMaterial(self.cityId, appeaseInfo.itemId, appeaseInfo.itemCost)
    end
    local peopleCount = math.ceil(self.protestData.totalCount * appeaseConfig.anti_anger)
    if peopleCount <= 0 then
        return
    end
    --设置小人状态
    local protestStatus = self:GetProtestStatus()
    if protestStatus == ProtestStatus.Talk then
        local characters = CharacterManager.GetCharactersByMarkType(self.cityId, EnumMarkState.Talk)
        local characterCount = characters:Count()
        if peopleCount < characterCount then
            characterCount = peopleCount
        end
        for i = 1, characterCount, 1 do
            characters[i]:SetMarkState(EnumMarkState.None)
        end
    elseif protestStatus == ProtestStatus.Run then
        local characters = CharacterManager.GetCharactersByStateType(self.cityId, EnumState.Protest)
        local characterCount = characters:Count()
        if peopleCount < characterCount then
            characterCount = peopleCount
        end
        for i = 1, characterCount, 1 do
            characters[i]:SetMarkState(EnumMarkState.None)
            characters[i]:SetNextState(EnumState.Normal)
        end
    end

    --更新安抚事件
    self.protestData.currentCount = self.protestData.currentCount - peopleCount
    if self.protestData.currentCount < 0 then
        self.protestData.currentCount = 0
    end

    --埋点事件
    local params = {}
    params.sub_group = appeaseIndex
    params.protestPeople = self.protestData.currentCount
    params.totalPeople = CharacterManager.GetCharacterMaxCount(self.cityId)
    if self.cardId ~= 0 then
        params.cardId = self.cardId
        params.cardLevel = self.cardLevelRx.value
    end
    -- Analytics.Event("ProtestMethodChoose", params)

    --刷新暴动数据
    if self.protestData.currentCount > 0 then
        self.protestData.appeaseInfos = self:SetProtestAppeaseInfos()
        self.protestData.appeaseCount = self.protestData.appeaseCount - 1
        if nil == self.protestData.appeaseRefreshTime then
            self.protestData.appeaseRefreshTime = GameManager.GameTime() + self.appeaseCountRefresh
        end
        DataManager.SetCityDataByKey(self.cityId, DataKey.ProtestData, self.protestData)
        --触发暴动安抚数量事件
        EventManager.Brocast(EventType.PROTEST_APPEASE_COUNT_CHANGE, self.cityId, self.protestData.appeaseCount)
    else
        self:CloseProtest()
    end
end

--更新暴动安抚事件次数
function CityProtest:UpdateProtestAppeaseCount()
    if self.protestData.appeaseCount >= self.protestAppeaseMaxCount then
        return
    end
    local currentTime = GameManager.GameTime()
    local remainingTime = self.protestData.appeaseRefreshTime - currentTime
    if remainingTime > 0 then
        EventManager.Brocast(EventType.PROTEST_APPEASE_TIME_CHANGE, self.cityId, remainingTime)
    else
        self.protestData.appeaseCount = self.protestData.appeaseCount + 1
        EventManager.Brocast(EventType.PROTEST_APPEASE_COUNT_CHANGE, self.cityId, self.protestData.appeaseCount)
        if self.protestData.appeaseCount < self.protestAppeaseMaxCount then
            self.protestData.appeaseRefreshTime = currentTime + self.appeaseCountRefresh
            EventManager.Brocast(EventType.PROTEST_APPEASE_TIME_CHANGE, self.cityId, self.appeaseCountRefresh)
        else
            self.protestData.appeaseRefreshTime = nil
        end
        DataManager.SetCityDataByKey(self.cityId, DataKey.ProtestData, self.protestData)
    end
end

---------------------------------
---方法响应
---------------------------------
--添加绝望值
function CityProtest:AddDespairValue(value)
    if self.protestData.status == ProtestStatus.Talk or self.protestData.status == ProtestStatus.Run then
        return
    end
    self.despairValue = self.despairValue + (value or 1)
    DataManager.SetCityDataByKey(self.cityId, DataKey.Despair, self.despairValue)
    if self.despairValue >= self.protestTrigger.constant_a then
        self:OpenProtest()
    end
end

--获取绝望进度
function CityProtest:GetDesparirProgress()
    return self.despairValue / self.protestTrigger.constant_a
end

--设置卡牌信息
function CityProtest:SetCardInfo()
    local mapItemData = MapManager.GetMapItemData(self.cityId, self.cardZoneId)
    local cardId = mapItemData:GetCardId()
    if cardId == 0 then
        cardId = mapItemData:GetDefaultCardId()
    end
    self.cardId = cardId
    self:UpdateCardLevel()
end

--刷新卡牌信息
function CityProtest:UpdateCardLevel()
    self.cardLevelRx.value = CardManager.GetCardLevel(self.cardId)
    --设置暴动安抚事件索引
    local newIndex = nil
    for index, cardLevel in pairs(self.cityConfig.protest_card_level) do
        if self.cardLevelRx.value >= cardLevel then
            newIndex = index
        end
    end
    if newIndex and newIndex ~= self.protestAppeaseIndex then
        self.protestAppeaseIndex = newIndex
    end
end

--获取卡牌id
function CityProtest:GetCardId()
    return self.cardId
end

--获取卡牌等级Rx
function CityProtest:GetCardLeveRx()
    return self.cardLevelRx
end

--获取暴动组id
function CityProtest:GetProtestGroupId()
    return self.protestData.groupId
end

--是否是暴动状态
function CityProtest:IsProtestStatus()
    if nil == self.protestData then
        return false
    end
    if self.protestData.status == ProtestStatus.None then
        return false
    end
    if self.protestData.status == ProtestStatus.CoolDown then
        return false
    end
    return true
end

--获取暴动状态
function CityProtest:GetProtestStatus()
    local status = ProtestStatus.None
    if self.protestData then
        status = self.protestData.status
    end
    return status
end

--获取暴动剩余时间
function CityProtest:GetProtestLeftTime()
    local leftTime = 0
    if self.protestData then
        if self.protestData.status == ProtestStatus.Talk then
            leftTime = self.protestData.statusEndTime - TimeManager.GameTime()
        elseif self.protestData.status == ProtestStatus.Run then
            leftTime = self.protestData.statusEndTime - TimeManager.GameTime()
        end
    end
    return leftTime
end

--根据索引获取安抚事件
function CityProtest:GetAppeaseInfoByIndex(index)
    if self.protestData and self.protestData.appeaseInfos then
        return self.protestData.appeaseInfos[index]
    end
    return nil
end

--获取暴动安抚刷新时间
function CityProtest:GetAppeaseRefreshTime()
    local time = 0
    if self.protestData and self.protestData.appeaseRefreshTime then
        time = self.protestData.appeaseRefreshTime - GameManager.GameTime()
    end
    return time
end

--获取暴动安抚次数
function CityProtest:GetAppeaseCount()
    return self.protestData.appeaseCount
end

--获取最大安抚数量
function CityProtest:GetAppeaseMaxCount()
    return self.protestAppeaseMaxCount
end

--获取安抚需求卡牌等级
function CityProtest:GetAppeaseRequireCardLevel(index)
    return self.cityConfig.protest_card_level[index]
end

--获取当前暴动人数
function CityProtest:GetCurrentPeople()
    if self.protestData then
        return self.protestData.currentCount or 0
    end
    return 0
end

--获取总的暴动人数
function CityProtest:GetTotalPeople()
    if self.protestData then
        return self.protestData.totalCount
    end
    return 0
end

--获取暴动安抚事件索引
function CityProtest:GetUnlockAppeaseIndex()
    return self.protestAppeaseIndex
end

---显示罢工谈判阶段，显示罢工和没罢工小人原点
function CityProtest:ShowProtestMaskPoint(bShow)
    local characters = CharacterManager.GetCharacterControllers(self.cityId)
    characters:ForEach(
        function(item)
            if item:GetMarkState() == EnumMarkState.Talk then
                item:setCircleActive(bShow, false)
            else
                item:setCircleActive(bShow, true)
            end
        end
    )
end
