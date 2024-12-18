DataManager = {}
DataManager.__cname = "DataManager"

local this = DataManager

--服务器返回的用户数据
this.serverData = {}
this.firstInit = true
this.lockSave = false
this.lastRequestTime = nil

function DataManager.SetData(uid, serverData)
    this.dirtyFlags = {}
    this.readyToServerFlags = {}
    this.uid = uid
    this.serverData = serverData
    this.backDataJson = "{}"
    local dataKey = this.UserDataPrefsKey()

    --删档测试------------------^^^^^
    if not PlayerPrefs.HasKey(dataKey) then
        this.DeleteAllPrefs()
        if this.serverData and this.serverData.global ~= nil and this.serverData.global.markDelete == nil then
            --服务器有数据，本地没有数据
            this.userData = this.serverData
            this.backData = Clone(this.serverData)
        else
            -- 客户端服务器都没有数据
            this.userData = ConfigManager.GetInitUserData()
            this.userData.db_ver = GameManager.dbVersion
        end
    else
        local strData = PlayerPrefs.GetString(dataKey)
        local localData = JSON.decode(strData)
        this.userData = localData
        if
            this.serverData.ts ~= nil and
            (localData.ts ~= nil and this.serverData.ts > 0 and this.serverData.ts > localData.ts) or
            this.serverData["__RESOLVED"] == true
        then
            --使用服务器数据
            PlayerPrefs.DeleteKey(dataKey)
            this.DeleteAllPrefs(localData.prefsKeys)
            if this.serverData["__RESET"] == true then
                --如果服务器要求reset
                this.userData = ConfigManager.GetInitUserData()
            else
                --接受服务器数据
                this.userData = this.serverData
                --需要更新__RESOLVED标记
                this.CheckSaveToServer(true)
            end
        elseif localData.db_ver ~= nil and localData.db_ver == GameManager.dbVersion then
            --使用客户端数据
            this.userData = localData
        else
            --数据版本不对，改为新用户
            -- Analytics.UserFirstTimeOpen()
            -- this.userData = ConfigManager.GetInitUserData()
            -- this.userData.db_ver = GameManager.dbVersion
            -- this.DeleteAllPrefs()
            -- if GameManager.isDebug then
            --     Log("userData_hasLocal_useLocalInit:" .. JSON.encode(this.userData))
            -- end
            this.userData = localData
        end
    end
    this.userData["__RESOLVED"] = false
    this.userData["__RESET"] = false

    --升级表数据
    this.UpdatePlayerPrefs(this.userData)

    --根据userData表读取所有表内容
    this.ReadAllPrefs(this.userData.prefsKeys)

    this.backData = Clone(this.userData)

    this.ForceSaveServer()
end

--获取用户注册时间戳
function DataManager.GetRegTimestamp()
    local ret = 1641118097
    if this.userData ~= nil and this.userData.global ~= nil and this.userData.global.reg ~= nil then
        ret = this.userData.global.reg
    end
    return ret
end

--主表表名
function DataManager.UserDataPrefsKey()
    return this.Key2Prefs("userdata")
end

--拼接
function DataManager.Key2Prefs(key)
    --return key .. "_" .. SDKManager.fpid
    return key .. "_" .. this.uid
end

--获取表名
function DataManager.GetAllPrefsKeys(tb)
    if tb ~= nil then
        return tb
    end

    local prefsKeys = {}
    table.insert(prefsKeys, "global")
    for i = 1, 20 do
        table.insert(prefsKeys, "city" .. i)
    end

    return prefsKeys
end

--删除表数据
function DataManager.DeleteAllPrefs(prefsKeys)
    if prefsKeys == nil then
        if this.userData ~= nil then
            prefsKeys = this.GetAllPrefsKeys(this.userData.prefsKeys)
        else
            prefsKeys = this.GetAllPrefsKeys()
        end
    end
    for key, value in pairs(prefsKeys) do
        PlayerPrefs.DeleteKey(this.Key2Prefs(value))
    end
end

--读取表数据
function DataManager.ReadAllPrefs(tb)
    local prefsKeys = this.GetAllPrefsKeys(tb)
    for key, value in pairs(prefsKeys) do
        local prefsKey = this.Key2Prefs(value)
        if PlayerPrefs.HasKey(prefsKey) then
            local strData = PlayerPrefs.GetString(prefsKey)
            local localData = JSON.decode(strData)
            this.userData[value] = localData
        end
    end
end

function DataManager.DeduplicationPrefsKeys(tb)
    if tb == nil then
        return nil
    end

    local resetKeys = {}
    local temp = {}
    for key, value in pairs(tb) do
        temp[value] = true
    end
    for key, value in pairs(temp) do
        table.insert(resetKeys, key)
    end

    return resetKeys
end

--升级表数据
function DataManager.UpdatePlayerPrefs(userData)
    --覆盖老表
    local needUpdate = false
    local resetKeys = {}
    if userData.prefsKeys ~= nil then
        resetKeys = this.DeduplicationPrefsKeys(userData.prefsKeys)
    else
        needUpdate = true
        resetKeys = this.GetAllPrefsKeys()
    end

    for key, value in pairs(resetKeys) do
        if userData[value] ~= nil then
            PlayerPrefs.SetString(this.Key2Prefs(value), JSON.encode(userData[value]))
        end
    end

    local saveKeys = {}
    for key, value in pairs(resetKeys) do
        if PlayerPrefs.HasKey(this.Key2Prefs(value)) then
            table.insert(saveKeys, value)
        end
    end

    local resetUserData = {}
    resetUserData.prefsKeys = saveKeys
    resetUserData.ver = userData.ver
    resetUserData.db_ver = userData.db_ver
    resetUserData.ts = GameManager.GameTime()

    userData.ts = resetUserData.ts
    userData.prefsKeys = saveKeys
    PlayerPrefs.SetString(this.UserDataPrefsKey(), JSON.encode(resetUserData))
    PlayerPrefs.Save()

    return needUpdate
end

--检测版本号
function DataManager.CheckVerion()
    if this.userData["ver"] == nil then
        this.userData["ver"] = GameManager.version
    else
        this.userData["ver"] = GameManager.version
    end
end

--检测是否限时场景如果是则跳到主场景
function DataManager.CheckCityId()
    local cId = this.userData.global.cityId
    if ConfigManager.GetCityById(cId).is_event then
        this.userData.global.cityId = this.userData.global.maxCityId
    end
end

--初始化数据
function DataManager.InitData()
    if not this.userData.global.initCity then
        this.ResetCityData()
    end
    if this.saveTimeId ~= nil then
        clearInterval(this.saveTimeId)
        this.saveTimeId = nil
    end
    if this.saveLocalTimeId ~= nil then
        clearInterval(this.saveLocalTimeId)
        this.saveLocalTimeId = nil
    end
    this.saveCount = 0
    this.saveTimeId = setInterval(this.CheckSaveToServer, 6000, false, true)
    --this.saveLocalTimeId = setInterval(this.CheckSaveToLocal, 1000)
    this.saveLocalTimeId = setInterval(this.CheckSaveToLocalByModule, 1000)
end

function DataManager.InitDataItem()
    this.cityId = this.GetCityId()
    if not this.dataItems then
        this.dataItems = Dictionary:New()
    end
    if not this.dataItems:ContainsKey(this.cityId) then
        this.dataItems:Add(this.cityId, CityData:New(this.cityId))
    end
end

--初始化DataManager
function DataManager.Init()
    if this.firstInit then
        this.globalRx = {}
    end
    this.InitData()
    this.InitDataItem()
    if this.firstInit then
        this.firstInit = false
    end

    this.InitLoginInfo()

    --UserSet Log
    local priceCount = 0
    if DataManager.GetGlobalDataByKey(DataKey.Pay) ~= nil then
        priceCount = DataManager.GetGlobalDataByKey(DataKey.Pay).priceCount
    end
    local setUserObj = {
        GemBalance = this.GetMaterialCount(this.GetCityId(), ItemType.Gem),
        HeartBalance = this.GetMaterialCount(this.GetCityId(), ItemType.Heart),
        BlackCoinBalance = this.GetMaterialCount(this.GetCityId(), ItemType.BlackCoin),
        MaxCityId = this.GetMaxCityId(),
        MaxCeneratorLevel = this.GetMaxCeneratorId(),
        PriceCount = priceCount,
        BCBattleMaxLevel = this.GetMaxBattleLevel(),
        patchVersion = 0 -- AppCenter.version
    }

    this.ForceSaveServer()
end

function DataManager.Clear(force)
    if this.saveTimeId ~= nil then
        clearInterval(this.saveTimeId)
        this.saveTimeId = nil
    end
    if this.saveLocalTimeId ~= nil then
        clearInterval(this.saveLocalTimeId)
        this.saveLocalTimeId = nil
    end
    Utils.SwitchSceneClear(this.cityId, this.dataItems, force)
end

--重置城市数据(以后转生用)
function DataManager.ResetCityData()
    Log("ResetCityData")
    local cityId = this.GetCityId()
    local cityConfig = ConfigManager.GetCityById(cityId)
    local cityData = {}
    --时钟信息
    cityData.day = 1
    cityData.clock = cityConfig.game_defult_clock
    cityData.onlineTime = TimeManager.GameTime()
    --角色信息
    cityData.characterData = {
        version = 2,
        serialNumber = 1,
        infos = {},
        fillTypes = {}
    }
    cityData.zones = CityManager.GetInitCityZoneData(cityId)
    cityData.factoryGame = FactoryGameData.GetInitData() --工厂游戏机
    cityData.foodType = ConfigManager.GetDefaultFoodType(cityId)
    cityData.foodBag = {}
    cityData.genEnable = false
    cityData.genOverload = false
    cityData.fristInit = true
    cityData.productData = {}
    -- cityData.hope = ConfigManager.GetFormulaConfigById("hopeValue").constant_b
    cityData.despair = 0
    cityData.partId = 1
    cityData.tasks = {}
    cityData.boostData = {}
    cityData.functionsData = {}
    cityData.bag = {}
    cityData.cityPass = {}
    local initItemList = ConfigManager.GetInitItemList(cityId)
    local initItems = cityConfig.initial_items
    initItemList:ForEach(
        function(item)
            if item.scope == "City" then
                cityData.bag[item.id] = initItems[item.id] or 0
            elseif item.scope == "Global" then
                if initItems[item.id] ~= nil then
                    this.userData.global.bag[item.id] = initItems[item.id]
                elseif this.userData.global.bag[item.id] == nil then
                    this.userData.global.bag[item.id] = 0
                end
            end
        end
    )
    this.userData["city" .. cityId] = cityData
    this.userData.global.initCity = true
    if cityId == 1 then
        local tutorialData = {}
        tutorialData.step = TutorialStep.FirstEnterCity
        tutorialData.subStep = 1
        tutorialData.queues = { -1 }
        tutorialData.completes = {}
        this.userData.global[DataKey.TutorialData] = tutorialData
    elseif cityId == 2 then
        this.userData.global[DataKey.TutorialData].step = TutorialStep.FirstEnterCity2
        this.userData.global[DataKey.TutorialData].subStep = 1
    else
        local requireCityId = FactoryGameData.GetRequireCityId()
        if cityId == requireCityId then
            this.userData.global[DataKey.TutorialData].step = TutorialStep.FactoryGame
            this.userData.global[DataKey.TutorialData].subStep = 1
        end
    end

    if cityId > this.userData.global.maxCityId and not cityConfig.is_event then
        this.userData.global.maxCityId = cityId
        this.userData.global.maxGenId = 1
    end

    this.SaveCityData(cityId, true)
    this.CheckSaveToLocalByModule(true)
end

function DataManager.ClearCity(cityId)
    this.userData["city" .. cityId] = nil
    this.ForceSaveServer()
end

--获取最大场景ID
function DataManager.GetMaxCityId()
    return this.userData.global.maxCityId
end

--获取最大场景火炉等级
function DataManager.GetMaxCeneratorId()
    return this.userData.global.maxGenId
end

--获取最大战斗等级
function DataManager.GetMaxBattleLevel()
    local ret = 0
    if this.userData.global.cardData ~= nil and this.userData.global.cardData.battleLevel ~= nil then
        ret = this.userData.global.cardData.battleLevel
    end
    return ret
end

--获取当前场景数据
---@return CityData
function DataManager.GetData(cityId)
    return this.dataItems[cityId]
end

--更新用户数据到SDK
function DataManager.UpdateUserInfoToSDK()
    -- local gameServerId = NetManager.server_mark
    -- local gameUserId = SDKManager.fpid
    -- local gameUserName = SDKManager.fpid
    -- local level = DataManager.GetMaxCityId()
    -- local vipLevel = PaymentManager.GetVipLevel()
    -- local isPaidUser = PaymentManager.data.count > 0
    -- SDKManager.LogUserInfoUpdate(gameServerId, gameUserId, gameUserName, level, vipLevel, isPaidUser)
end

--获得原材料数量
function DataManager.GetMaterialCount(cityId, materialType)
    local cityData = this.GetData(cityId)
    if cityData == nil then
        return 0
    end
    return cityData:GetMaterialCount(materialType)
end

--获得原材料数量
function DataManager.GetMaterialCountFormat(cityId, materialType, noDelay)
    noDelay = noDelay == nil and true or noDelay
    local cityData = this.GetData(cityId)
    if cityData == nil then
        print("[error]" .. cityId .. ".GetMaterialCountFormat cityData == nil:" .. debug.traceback())
        return 0
    end
    return cityData:GetMaterialCountFormat(materialType, noDelay)
end

function DataManager.AddMaterialViewDelay(cityId, materialType, val)
    local cityData = this.GetData(cityId)
    if cityData == nil then
        print("[error]" .. cityId .. ".AddMaterialViewDelay cityData == nil:" .. debug.traceback())
        return
    end
    cityData:AddMaterialViewDelay(materialType, val)
end

function DataManager.CostMaterialViewDelay(cityId, materialType, val)
    local cityData = this.GetData(cityId)
    if cityData == nil then
        print("[error]" .. cityId .. ".CostMaterialViewDelay cityData == nil:" .. debug.traceback())
        return
    end
    cityData:CostMaterialViewDelay(materialType, val)
end

function DataManager.ClearMaterialViewDelay(cityId)
    local cityData = this.GetData(cityId)
    if cityData == nil then
        print("[error]" .. cityId .. ".ClearMaterialViewDelay cityData == nil:" .. debug.traceback())
        return
    end
    cityData:ClearMaterialViewDelay()
end

--获得用于显示的素材数量（已计算resEffct延迟）
function DataManager.GetViewMaterialCountFormat(cityId, materialType)
    local cityData = this.GetData(cityId)
    if cityData == nil then
        print("[error]" .. cityId .. ".GetViewMaterialCountFormat cityData == nil:" .. debug.traceback())
        return 0
    end
    return cityData:GetViewMaterialCountFormat(materialType)
end

--判断原材料这个场景是否无正无穷
function DataManager.CheckInfinity(cityId, materialType)
    return this.GetData(cityId):CheckInfinity(materialType)
end

--获得原材料数量Rx
function DataManager.GetMaterialRx(cityId, materialType)
    return this.GetData(cityId):GetMaterialRx(materialType)
end

function DataManager.GetMaterialDelayRx(cityId, materialType)
    return this.GetData(cityId):GetMaterialDelayRx(materialType)
end

--设置原材料
function DataManager.SetMaterial(cityId, materialType, val)
    this.GetData(cityId):SetMaterial(materialType, val)
end

--使用原材料
function DataManager.UseMaterial(cityId, materialType, val, to, toId)
    this.GetData(cityId):UseMaterial(materialType, val, to, toId)
end

--添加原材料
function DataManager.AddMaterial(cityId, materialType, val, from, fromId)
    this.GetData(cityId):AddMaterial(materialType, val, from, fromId)
end

--判断原材料是否足够
function DataManager.CheckMaterials(cityId, input)
    return this.GetData(cityId):CheckMaterials(input)
end

--使用原材料 By一个字典
function DataManager.UseMaterials(cityId, input, to, toId)
    this.GetData(cityId):UseMaterials(input, to, toId)
end

--添加原材料 By一个字典
function DataManager.AddMaterials(cityId, output, from, fromId)
    this.GetData(cityId):AddMaterials(output, from, fromId)
end

-----------------------------------------------------------------------
---切换场景新添加方法
-----------------------------------------------------------------------

--获取当前城市Id
function DataManager.GetCityId()
    return this.userData.global.cityId
end

--添加奖励
---@param reward Reward
function DataManager.AddReward(cityId, reward, from, fromId)
    --支持添加数组
    if #reward > 0 then
        local rt = {}
        for ix, value in pairs(reward) do
            local r = this.AddReward(cityId, value, from, fromId)
            for i = 1, #r do
                table.insert(rt, r[i])
            end
        end

        return Utils.PressRewards(rt)
    end

    local _, other = Utils.SplitRewardByCityId(cityId, { reward }, from, fromId)
    if #other == 1 then
        -- 如果这个奖励是其他场景的，那么保存到驿站
        PostStationManager.AddRewards(other, from, fromId)
        return {}
    end

    if reward.addType == RewardAddType.Card then
        if reward.id == nil then
            local randReward = {}
            --卡牌随机
            if reward.random == "single" then
                local r = CardManager.RandomCard(reward)
                r.count = reward.count
                CardManager.AddCard(r.id, r.count, from, fromId)
                table.insert(randReward, r)
            else
                for i = 1, reward.count do
                    local r = CardManager.RandomCard(reward)
                    r.count = 1
                    CardManager.AddCard(r.id, r.count, from, fromId)
                    table.insert(randReward, r)
                end
            end
            --返回随机生成的卡牌，方便调用者展示
            return randReward
        else
            CardManager.AddCard(reward.id, reward.count, from, fromId)
        end
    elseif reward.addType == RewardAddType.Item then
        this.AddMaterial(cityId, reward.id, reward.count, from, fromId)
    elseif reward.addType == RewardAddType.Box then
        BoxManager.AddBox(reward.id, reward.count, from, fromId)
    elseif reward.addType == RewardAddType.OpenBox then
        BoxManager.AddBox(reward.id, reward.count, from, fromId)
        return BoxManager.GetBoxRewardV2(reward.id, reward.count, from, fromId)
    elseif reward.addType == RewardAddType.DailyItem then
        DailyBagManager.AddItem(reward.id, reward.count, nil, from, fromId)
    elseif reward.addType == RewardAddType.Boost then
        BoostManager.AddRewardBoost(cityId, reward.id, reward.id)
    elseif reward.addType == RewardAddType.ZoneTime then
        local zoneMapItemDataList = OverTimeProductionManager.Get(cityId):GetValidUpgradingZoneList()

        for i = 1, #zoneMapItemDataList do
            local mapItemData = zoneMapItemDataList[i]
            Log("zone reward: " .. mapItemData.config.id .. ", count: " .. reward.count)
            mapItemData:DecreaseUpgradeTime(reward.count)
        end
    elseif
        reward.addType == RewardAddType.ItemOverTime or reward.addType == RewardAddType.OverTime or
        reward.addType == RewardAddType.OverTimeResType
    then
        local rl = Utils.RewardOverTime2Item({ reward })
        return DataManager.AddReward(cityId, rl, from, fromId)
    elseif reward.addType == RewardAddType.ItemType then
        local itemId = Utils.GetItemId(cityId, reward.id)
        this.AddMaterial(cityId, itemId, reward.count, from, fromId)
    end

    return { reward }
end

--根据数据key 获取全局数据
function DataManager.GetGlobalDataByKey(dataKey)
    return this.userData.global[dataKey]
end

--根据数据key 获取城市数据
function DataManager.GetCityDataByKey(cityId, dataKey)
    return this.userData["city" .. cityId][dataKey]
end

--根据数据key 设置全局数据
function DataManager.SetGlobalDataByKey(dataKey, val)
    this.userData.global[dataKey] = val
    -- Log("SaveGlobal:" .. dataKey)
    this.SaveGlobalData()
end

--根据数据key 设置城市数据
function DataManager.SetCityDataByKey(cityId, dataKey, val)
    this.userData["city" .. cityId][dataKey] = val
    -- Log("SaveCity:" .. dataKey)
    this.SaveCityData(cityId)
end

--根据数据key 设置城市缓存数据(不重要的信息保存)
function DataManager.SetCacheCityDataByKey(cityId, dataKey, val)
    this.userData["city" .. cityId][dataKey] = val
end

--是否锁住保存数据
function DataManager.SaveIgnore(force)
    if force then
        return false
    end
    return TutorialManager.NeedLimitSave() or this.lockSave == true
end

--保存数据 global
function DataManager.SaveGlobalData(force)
    if this.SaveIgnore(force) then
        return
    end
    local saveKey = "global"
    this.dirtyFlags[saveKey] = true
    this.readyToServerFlags[saveKey] = true
end

--保存数据 city
function DataManager.SaveCityData(cityId, force)
    if this.SaveIgnore(force) then
        return
    end
    local saveKey = "city" .. cityId
    this.dirtyFlags[saveKey] = true
    this.readyToServerFlags[saveKey] = true
end

function DataManager.SetDefaultToServer(userData, diff2, key)
    if this.Diff2(userData[key], this.backData[key], key, diff2, false, nil, false, false) == 1 then
        diff2[key] = userData[key]
    end
    this.backServerFlags[key] = true
end

function DataManager.SaveAll()
    this.SaveGlobalData()
    local maxCityId = this.GetMaxCityId()
    for i = 1, maxCityId do
        this.SaveCityData(i)
    end
end

--强制保存到服务器 
function DataManager.ForceSaveServer()
    this.userData.ts = GameManager.GameTime()
    local userData = Clone(this.userData)

    local time = Time2:New(GameManager.GameTime())

    -- 服务器有问题 暂时屏蔽
    local vo = NewCs("map")
    vo.info.map.setAllDocument.document = JSON.encode(userData)
    vo:add(function(vo)
        this.backData = userData
    end, true)
    vo:send()

    --同时同步到本地
    this.CheckSaveToLocalByModule(true)
end

--定时检查保存本地
function DataManager.CheckSaveToLocal()
    if not this.localSave then
        return
    end
    this.localSave = false
    this.userData.ts = GameManager.GameTime()
    PlayerPrefs.SetString(this.UserDataPrefsKey(), JSON.encode(this.userData))
end

function DataManager.UserDataPrefsContainKey(key)
    if this.userData.prefsKeys == nil then
        return false
    end
    for k, v in pairs(this.userData.prefsKeys) do
        if v == key then
            return true
        end
    end

    return false
end

--定时检查保存本地
function DataManager.CheckSaveToLocalByModule(force)
    if this.SaveIgnore(force) then
        return
    end

    if this.userData.prefsKeys == nil then
        this.userData.prefsKeys = {}
    end
    local ts = GameManager.GameTime()
    this.userData.ts = ts
    local saveUserData = false
    for key, value in pairs(this.dirtyFlags) do
        if value and this.userData[key] ~= nil then
            if not this.UserDataPrefsContainKey(key) then
                table.insert(this.userData.prefsKeys, key)
                saveUserData = true
            end
            local saveData = this.userData[key]
            saveData.ver = this.userData.ver
            saveData.db_ver = this.userData.db_ver
            saveData.ts = ts
            PlayerPrefs.SetString(this.Key2Prefs(key), JSON.encode(saveData))
            this.dirtyFlags[key] = false
        end
    end

    --if saveUserData then
    local saveData = {}
    saveData.prefsKeys = this.userData.prefsKeys
    saveData.ver = this.userData.ver
    saveData.db_ver = this.userData.db_ver
    saveData.ts = ts
    PlayerPrefs.SetString(this.UserDataPrefsKey(), JSON.encode(saveData))
    --end
end

--定时检查保存
function DataManager.CheckSaveToServer(force, isTickCheck)
    if this.SaveIgnore(force) then
        return
    end

    if this.backData == nil then
        -- 如果还没有back数据
        this.ForceSaveServer()
        return
    end
    if this.saveCount == nil then 
        this.saveCount = 0
    end
    this.saveCount = this.saveCount + 1

    local diff2 = {}
    local userData = Clone(this.userData)

    if isTickCheck then
        this.readyToServerFlags["global"] = true
        this.backServerFlags = Clone(this.readyToServerFlags)
        this.SetDefaultToServer(userData, diff2, "db_ver")
        this.SetDefaultToServer(userData, diff2, "ver")
        this.SetDefaultToServer(userData, diff2, "ts")
        this.SetDefaultToServer(userData, diff2, "prefsKeys")
        for key, value in pairs(this.readyToServerFlags) do
            if value then
                if userData[key] == nil then
                    LogWarning(key .. ",table is nil data")
                else
                    this.Diff2(userData[key], this.backData[key], key, diff2, false, nil, false, false)
                end
            end
            this.readyToServerFlags[key] = false
        end

        --小人数据每十次检测执行一次
        if this.saveCount % 10 == 0 then
            this.saveCount = 0
            local subKey = "characterData"
            for key, value in pairs(this.backServerFlags) do
                -- diff2中不能存在city的根结点，否则mongo的update会失败: "mongo updating the path 'city2.characterdata' would create a conflict at"
                if value and string.find(key, "city") and diff2[key] == nil then
                    diff2[key .. "." .. subKey] = userData[key][subKey]
                end
            end
        end
    else
        this.Diff2(userData, this.backData, "root", diff2, false, nil, false, true) -- checkDel false 第一层table不检查del
    end

    -- 服务器有问题 暂时屏蔽
    -- print("zhkxin 保存数据到服务端", this.lastRequestTime, UnityEngine.Time.realtimeSinceStartup)

    -- 有数据同步没返回，则服务端已经挂了，弹窗提示退出游戏
    if this.lastRequestTime ~= nil and UnityEngine.Time.realtimeSinceStartup > this.lastRequestTime + 15 then 
        Utils.ReLoginDailog("server_disconnect_1", "server_disconnect_2")
        -- 弹窗后，重置状态
        this.lastRequestTime = nil
        return
    end

    local vo = NewCs("map")
    vo.info.map.setDocument.document = JSON.encode(diff2)
    vo:add(function(vo)
        this.lastRequestTime = nil
        if this.backServerFlags ~= nil then
            for key, value in pairs(this.backServerFlags) do
                if value then
                    this.backData[key] = userData[key]
                end
            end
            this.backServerFlags = nil
        else
            this.backData = userData
        end
    end, true)
    vo:send()
    this.lastRequestTime = UnityEngine.Time.realtimeSinceStartup
end

function DataManager.OnUpdate()
end

function DataManager.Diff(diffPath, path, obj1, obj2)
    if type(obj1) == "table" then
        for key, value in pairs(obj1) do
            if obj1 == nil or obj2 == nil then
                -- Log(path .. " : " .. tostring(obj1) .. " / " .. tostring(obj2))
                table.insert(diffPath, path)
            else
                DataManager.Diff(diffPath, path .. "|" .. key, value, obj2[key])
            end
        end
    else
        if obj1 ~= obj2 then
            -- Log(path .. " : " .. tostring(obj1) .. " / " .. tostring(obj2))
            table.insert(diffPath, path)
        end
    end
end

function DataManager.InitLoginInfo()
    this.loginInfo =
        DataManager.GetGlobalDataByKey(DataKey.LoginInfo) or
        {
            preLogin = 0,
            count = 0
        }

    local now = Time2:New(GameManager.GameTime())
    local pre = Time2:New(this.loginInfo.preLogin)

    if now:GetYear() == pre:GetYear() and now:GetMonth() == pre:GetMonth() and now:GetDay() == pre:GetDay() then
        return
    end
    --计算用户登录天数
    this.loginInfo.preLogin = now:Timestamp()
    this.loginInfo.count = this.loginInfo.count + 1

    DataManager.SetGlobalDataByKey(DataKey.LoginInfo, this.loginInfo)
end

function DataManager.GetLoginInfo()
    return this.loginInfo
end

---获得1相对于2，缺少，增加，改变了什么
---@return number       0:表示不操作, 1:obj1缺少了字段
function DataManager.Diff2(obj1, obj2, path, diff, checkDel, debugInfo, ignoreNumber, checkCharacter)
    if obj2 == nil then
        diff[path] = obj1
        return 1
    end
    --类型都变了
    if Utils.Type(obj1) ~= Utils.Type(obj2) then
        return 1
    end

    if Utils.Type(obj1) == "table" then
        --由于空数组对象和空table判断区别，所以两个完全空的对象就是想等的
        if Utils.GetTableLength(obj1) == 0 and Utils.GetTableLength(obj2) == 0 then
            return 0
        end

        --数量少了
        if checkDel and Utils.GetTableLength(obj1) < Utils.GetTableLength(obj2) then
            return 1
        end

        -- 如果数量一样
        if checkDel then
            --obj2中字段在obj1找不到
            for k in pairs(obj2) do
                if obj1[k] == nil then
                    return 1
                end
            end
        end

        --obj1中字段在obj2中
        for k, v in pairs(obj1) do
            local checkDiff = true
            if k == "characterData" then
                checkDiff = checkCharacter
            end
            if checkDiff then
                local subPath = path .. "." .. k
                if path == "root" then
                    subPath = k
                end
                if
                    obj2[k] == nil or
                    this.Diff2(v, obj2[k], subPath, diff, true, debugInfo, ignoreNumber, checkCharacter) == 1
                then
                    --新增
                    diff[subPath] = v
                    if debugInfo ~= nil then
                        debugInfo[subPath] = {
                            obj1 = obj1[k],
                            obj2 = obj2[k]
                        }
                    end
                end
            end
        end
    elseif Utils.Type(obj1) == "array" then
        if #obj1 ~= #obj2 then
            return 1
        end

        for i = 1, #obj1 do
            local arrDiff = {}
            local arrResult =
                this.Diff2(obj1[i], obj2[i], path .. "." .. i, arrDiff, true, debugInfo, ignoreNumber, checkCharacter)
            --数组中任何变化，都返回1
            if arrResult == 1 or Utils.GetTableLength(arrDiff) > 0 then
                return 1
            end
        end
    elseif Utils.Type(obj1) == "number" then
        if not ignoreNumber then
            if tostring(obj1 + 0.0) ~= tostring(obj2 + 0.0) then
                diff[path] = obj1
                if debugInfo ~= nil then
                    debugInfo[path] = {
                        obj1 = obj1,
                        obj2 = obj2
                    }
                end
            end
        end
    elseif obj1 ~= obj2 then
        diff[path] = obj1
        if debugInfo ~= nil then
            debugInfo[path] = {
                obj1 = obj1,
                obj2 = obj2
            }
        end
    end

    return 0
end

function DataManager.ToLog()
    DataManager.WriteFile(JSON.encode(this.serverData))
end

--- 写入本地文件
--- @param city any
--- @param content any
function DataManager.WriteFile(content)
    local file, err = io.open("Logs/SaveData_" .. (os.date("%Y-%m-%d-%H-%M-%S")) .. ".json", "w") -- "w" 表示写入模式，如果文件不存在将创建文件
    if not file then
        print("打开文件时出错：", err)
        return
    end
    
    -- 写入内容
    file:write(content)
    
    -- 关闭文件
    file:close()
end