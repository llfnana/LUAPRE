local gridPath = "Game.Config.zone_%s_%s"
---@class MapItemData
MapItemData = {}
MapItemData.__index = MapItemData

function MapItemData:New()
    return setmetatable({}, self)
end

--初始化数据
function MapItemData:InitData(cityId, id, zoneData)
    self.cityId = cityId
    self.zoneId = id
    self.zoneData = zoneData
    self.config = ConfigManager.GetZoneConfigById(id)

    -- 净化器数据初始化完成，同步数据至服务端（致物质援助等级变化）
    if self.config.zone_type == ZoneType.Generator then
        local level = 1
        if self.zoneData then
            level = self.zoneData.level
        end
        PlayerModule.c2sSyncCityAndGenerator(self.cityId, level)
    end

    if self.zoneData then
        self.zoneData.product = self.zoneData.product or {}
    end
    self.furnitureMilestoneConfig = ConfigManager.GetFurnituresMilestoneConfig(self.zoneId)
    self:FixZoneData()
    self:FixFurnitureData()
    self:CacheAllExp()
    self:CacheAllBoost()
    self:LoadGridData()
end

--修地图数据
function MapItemData:FixZoneData()
    if self.zoneData ~= nil and self:GetBuildStatus() == BuildingStatus.Complete then
        if self:GetLevel() > self.config.max_level then
            self.zoneData.level = self.config.max_level
        end
        if self.zoneData.v == nil or self.zoneData.v ~= 2 then
            if self.zoneData.toolLevel == nil and self.zoneData.boostLevel == nil then
                if self:IsHaveToolFurniture() then
                    local toolCfg = self.furnitureMilestoneConfig.Tool
                    local toolMaxLevel = toolCfg.zone_level_unlock[self.zoneData.level]
                    self.zoneData.toolLevel = toolMaxLevel
                end
                if self:IsHaveBoostFurniture() then
                    local boostCfg = self.furnitureMilestoneConfig.Boost
                    local boostMaxLevel = boostCfg.zone_level_unlock[self.zoneData.level]
                    self.zoneData.boostLevel = boostMaxLevel
                end
            end
            self.zoneData.v = 2
        end
    end
end

function MapItemData:SetDefaultCardData()
    --上阵默认卡牌
    if self:CanSetMultipleCardIds() then
        if self:GetIsNeedCard() then
            if self.zoneData.cardIds == nil then
                self.zoneData.cardIds = {}
            end
            local cardIds = self:GetDefaultCardIds()
            for i, defaultCardId in ipairs(cardIds) do
                local hasCard = false
                for key, hasCardId in pairs(self.zoneData.cardIds) do
                    if defaultCardId == hasCardId then
                        hasCard = true
                        break
                    end
                end

                local cardItemData = CardManager.GetCardItemData(defaultCardId)
                if not hasCard and defaultCardId > 0 and cardItemData ~= nil then
                    BoostManager.AddCardBoost(self.cityId, self.zoneId, defaultCardId)
                    local assignLogObj = {
                        cardId = defaultCardId,
                        bornColor = ConfigManager.GetCardConfig(defaultCardId).color,
                        cardLevel = cardItemData:GetLevel(),
                        cardStar = cardItemData:GetStarLevel(),
                        cardEffect = cardItemData:GetCardBoostEffect(),
                        zoneId = self.zoneId,
                        zoneLevel = self:GetLevel(),
                        assignfrom = "DefaultCard"
                    }
                    Analytics.Event("CardAssign", assignLogObj)
                    self.zoneData.cardIds[tostring(defaultCardId)] = defaultCardId
                    EventManager.Brocast(EventType.ZONE_CARD_CHANGE, self.cityId, self.zoneId)
                end
            end
        end
    else
        local defaultCardId = self:GetDefaultCardId()
        if self:GetIsNeedCard() and defaultCardId > 0 and self.zoneData.cardId ~= defaultCardId then
            if CardManager.GetCardItemData(defaultCardId) ~= nil then
                self:SetCardId(defaultCardId, true, "DefaultCard")
                self:TryTutorialHero(defaultCardId)
            else
                self.zoneData.cardId = 0
            end
        end
    end
    self:SaveData()
end

--TutorialHero
function MapItemData:TryTutorialHero(cardId)
    if cardId == TutorialManager.KeanuCardId then
        -- 获得卡牌引导
        if TutorialManager.IsNeverTrigger(TutorialStep.TaskGetCard) then
            TutorialManager.TriggerTutorial(TutorialStep.TaskGetCard, 1, true)
        end
    elseif cardId == TutorialManager.MedicalCardId then
        -- 医院引导
        -- if self.cityId == 2 and TutorialManager.IsNeverTrigger(TutorialStep.CardInfirmaryV2) then
        --     TutorialManager.TriggerTutorial(TutorialStep.CardInfirmaryV2)
        -- end
    end
end


--根据区域zoneName加载room地图配置
function MapItemData.LoadZoneGridsCnf(zoneName)
    local configData = string.format("%sData", zoneName)
    ResInterface.LoadTextSync(configData, function (str)
        local roomData = json.decode(str)
        local values = roomData.facilities
        for i=1, #values, 8 do
            local fctId, fctType = values[i+2], values[i+3]
            local index = (i + 3) / 8

        end
    end, ".json")
end

function MapItemData:LoadRoomMData(data,nodeInfo)

    local values = data.facilities
    local assets_name = ""
    local zone_type = ""
    for i=1, #values, 8 do
        local fctId, fctType,facDir = values[i+2], values[i+3], values[i+4]   --小人站位方向
        local markerIndex, serialNumber,level = values[i+5], values[i+6], values[i+7]
        local x,y =values[i], values[i+1]
        local index = (i + 3) / 8
        local tbsMarker = TbSceneMarker[fctId]
--        if fctType == 1  then  --(室内建筑)

--        elseif fctType == 3  then  --格子标记

--        end

        local gridInfo = {}
        gridInfo.zoneId = nodeInfo.zoneId
        gridInfo.zoneType = nodeInfo.zoneType
        gridInfo.xIndex = x + nodeInfo.xIndex
        gridInfo.yIndex = facDir --0  --暂时用来作为 小人站位方向
        gridInfo.zIndex = y + nodeInfo.zIndex
        gridInfo.effectType = 1--gridInfos[i].effectType
        gridInfo.markerType = "None"-- gridInfos[i].markerType  --Protest
        gridInfo.markerIndex = markerIndex-- gridInfos[i].markerIndex
        gridInfo.serialNumber = serialNumber--gridInfos[i].serialNumber

        if(markerIndex<1) then
            gridInfo.markerIndex = -1-- gridInfos[i].markerIndex
        end
        if(serialNumber<1) then
            gridInfo.serialNumber = -1--gridInfos[i].serialNumber
        end
        gridInfo.animationParams ={}-- gridInfos[i].animationParams

        if tbsMarker then
            gridInfo.markerType =tbsMarker.Name
            local strSub=tbsMarker.Name
--             if level > self.assetLevel then
--                 gridInfo.markerIndex = -1-- gridInfos[i].markerIndex
--                 gridInfo.serialNumber = -1--gridInfos[i].serialNumber
--             end
           if CityDefine.debug then
                --临时显示建筑坐标代码
                local data ={}
                data.id = strSub
                data.res_id = 60008
                local characterController = CharacterController.new(data)
                local mapTr = GameObject.Find("Map").transform
                local rootChars = mapTr:Find("Chars")
                local obj = rootChars:Find("CityChar").gameObject
                local playerGo = GOInstantiate(obj, rootChars)
                playerGo:SetActive(true)
                local mapCtrl = CityModule.getMapCtrl()
                local initCell =mapCtrl:getCellByXY( gridInfo.xIndex , gridInfo.zIndex)
                characterController:bind(playerGo,data.res_id)  --暂时在这里设置小人spine 资源id =0
                --   characterController:SetAnim(AnimationType.Idle)
                --   characterController:playAnim("idle",1) --朝下
                    --characterController:playAnim("sleeping",CityPosition.Dir.Right)
                characterController:setSortingOrder(30100)
                characterController:setCell(initCell)
                characterController.gameObject.name =strSub
                local Animation = characterController.transform:Find("Animation")
                    Animation.gameObject:SetActive(false)
                local textCanvas =  characterController.transform:Find("TextCanvas")
                textCanvas.gameObject:SetActive(true)

        --            local nameTxt = characterController.transform:Find("TextCanvas/Name"):GetComponent("Text")
        --            nameTxt.text = nodeInfo.zoneId
                local stateTxt = characterController.transform:Find("TextCanvas/State"):GetComponent("Text")
                stateTxt.text = gridInfo.xIndex .. "," .. gridInfo.zIndex .. strSub
           end
        end

        local grid = Grid:New(self.cityId, gridInfo)
        if not self.girdGroups[grid.markerType] then
            self.girdGroups[grid.markerType] = List:New()
        end
        self.girdGroups[grid.markerType]:Add(grid)
        GridManager.AddGrid(self.cityId, grid)
    end
end

--加载当前地格
function MapItemData:LoadGridData()
    if not self.config.has_way then
        return
    end
    if not self:IsUnlock() then
        return
    end
    local nodeInfo = GridManager.GetNodeByZoneId(self.cityId, self.zoneId)
    if not nodeInfo then
        return
    end
    self.girdGroups = {}
    self.zoneCachePaths = {}
    self.assetLevel = self:GetBuildAssetsId()

    local mapCtrl = CityModule.getMapCtrl()

    self:LoadRoomMData(mapCtrl._roomMapDatas[self.zoneId] ,nodeInfo)
end


--更新当前地格
function MapItemData:UpdateGridData()
    if self.girdGroups then
        for type, gridList in pairs(self.girdGroups) do
            gridList:ForEach(
                function(grid)
                    GridManager.RemoveGrid(self.cityId, grid)
                end
            )
        end
        self.girdGroups = nil
    end
    if self.zoneCachePaths then
        for pathId, pathPoints in pairs(self.zoneCachePaths) do
            GridManager.RemoveCachePath(self.cityId, pathId)
        end
        self.zoneCachePaths = nil
    end
    self:LoadGridData()
    self:BindGridView()

    EventManager.Brocast(
        EventType.UPDATE_ZONE_GRID_DATA,
        self.cityId,
        self.zoneId,
        self.config.zone_type,
        self.zoneData.level
    )
end

--更新当前地格Ex
function MapItemData:UpdateGridDataEx()
    -- if self.girdGroups then
    --     for type, gridList in pairs(self.girdGroups) do
    --         gridList:ForEach(
    --             function(grid)
    --                 GridManager.RemoveGrid(self.cityId, grid)
    --             end
    --         )
    --     end
    --     self.girdGroups = nil
    -- end
    -- if self.zoneCachePaths then
    --     for pathId, pathPoints in pairs(self.zoneCachePaths) do
    --         GridManager.RemoveCachePath(self.cityId, pathId)
    --     end
    --     self.zoneCachePaths = nil
    -- end
    -- self:LoadGridData()
    self:BindGridView()

    EventManager.Brocast(
        EventType.UPDATE_ZONE_GRID_DATA,
        self.cityId,
        self.zoneId,
        self.config.zone_type,
        self.zoneData.level
    )
end

--绑定格子显示
function MapItemData:BindGridView()
    if not self.girdGroups then
        return
    end
    for type, gridList in pairs(self.girdGroups) do
        if type ~= GridMarker.None then
            gridList:ForEach(
                function(grid)
                    grid:CreateProductionUI()
                end
            )
        end
    end
end

function MapItemData:UpdateGridView()
    if self.girdGroups then
        for type, gridList in pairs(self.girdGroups) do
            gridList:ForEach(
                function(grid)
                    grid:UpdateCardLevelUp()
                end
            )
        end
    end
end

--更新地格Product显示
---@param checkFunc function(furnitureId, index):boolean
function MapItemData:UpdateGridProductView(checkFunc)
    if not self.girdGroups then
        return
    end
    for type, gridList in pairs(self.girdGroups) do
        if type ~= GridMarker.None then
            gridList:ForEach(
                function(grid)
                    if grid == nil or grid.furnitureConfig == nil then
                        return
                    end
                    if checkFunc(grid.furnitureConfig.id, grid.markerIndex) then
                        grid:UpdateProductView()
                    end
                end
            )
        end
    end
end

--解绑格子显示
function MapItemData:UnBindGridView()
    if not self.girdGroups then
        return
    end
    for type, gridList in pairs(self.girdGroups) do
        if type ~= GridMarker.None then
            gridList:ForEach(
                function(grid)
                    grid:ClearProductView()
                end
            )
        end
    end
end

-- 音频位置变更事件
function MapItemData:AudioPositionChangeFunc(position)
    self.audioPosition = position
    self:Check3DSound()
end

-- 音效切换事件
function MapItemData:AudioEffectSwitchFunc()
    self:Check3DSound()
end

function MapItemData:Check3DSound()
    if not self.isShowView or not self:IsUnlock() or not AudioManager.effectSwitch then
        self:Stop3DSound()
    else
        local zonePoint = self:GetZonePoint()
        if zonePoint == nil then
            return
        end
        local distance = Vector3.Distance(self.audioPosition, zonePoint)
        -- if self.config.zone_type == ZoneType.Generator then
        -- end
        if distance > 60 then
            self:Stop3DSound()
        else
            self:Play3DSound()
        end
    end
end

function MapItemData:Play3DSound()
    if not self.akGameObj then
        return
    end
    local eventName = self:Get3DSoundName()
    if nil == eventName then
        return
    end
    if self.akPlaying then
        return
    end
    self.akPlaying = true
    AudioManager.PlayEffect(eventName, self.akGameObj)
end

function MapItemData:Stop3DSound()
    if not self.akGameObj then
        return
    end
    if not self.akPlaying then
        return
    end
    self.akPlaying = false
    AudioManager.PostEvent("building_stopall", self.akGameObj)
end

--绑定view
function MapItemData:BindView(view)
    self.view = view
    self.isShowView = true
    self:BindGridView()
    -- self.akGameObj = self.view:GetAkGameObj()
    -- self.akPlaying = false
end

--解除view
function MapItemData:UnBindView()
    self.view = nil
    self.isShowView = false
    self:UnBindGridView()
    self:Stop3DSound()
end

--显示toast
function MapItemData:ShowGameToast(msg)
    -- if not self.isShowView then
    --     return
    -- end
    -- GameToast.Instance:Show(msg, Color.red)
end

function MapItemData:ShowListToast(msg, color, icon, sfxName, config)
    if not self.isShowView then
        return
    end
    -- GameToastList.Instance:Show(msg, color, icon, sfxName, config)
end

--模拟建筑点击状态
function MapItemData:MouseUp()
    if self.isShowView then
        self.view:MouseUp()
    end
end

--获取建筑的位置
function MapItemData:GetZonePoint()
    if self.isShowView then
        return self.view:GetPoint()
    end
    return nil
end

--获取没有建筑时的聚焦中心点
function MapItemData:GetFocusPointWithoutBuilding()
    if self.isShowView then
        -- return self.view:GetFocusPointWithoutBuilding()
    end
    return nil
end

--获取建筑的聚焦位置
function MapItemData:GetFocusPoint()
    if self.isShowView then
        -- return self.view:GetFocusPoint()
    end
    return nil
end

function MapItemData:GetFocusPreview()
    if self.isShowView then
        -- return self.view:GetFocusPreview()
    end
    return nil
end

--获取建筑名字key
function MapItemData:GetName()
    if type(self.config.name_key) == "string" then
        return GetLang(self.config.name_key)
    else
        local level = 1
        if self:IsUnlock() then
            level = self:GetLevel()
        end
        if #self.config.name_key >= level then
            return GetLang(self.config.name_key[level])
        else
            return GetLang(self.config.name_key[#self.config.name_key])
        end
    end
end

function MapItemData:GetNameKey()
    return self.config.name_key
end

--获取建筑介绍key
function MapItemData:GetDesc()
    if type(self.config.desc_key) == "string" then
        return GetLang(self.config.desc_key)
    else
        return GetLang(self.config.desc_key[1])
    end
end

function MapItemData:GetDescKey()
    return self.config.desc_key
end

function MapItemData:GetSortQueue()
    return self.config.sort_queue
end

--获取建筑生产类型
function MapItemData:GetProductorType()
    return self.config.productor_type
end

--获取区域类型
function MapItemData:GetZoneType()
    return self.config.zone_type
end

--获取3d音效
function MapItemData:Get3DSoundName()
    local ret
    if self:IsUnlock() then
        ret = self.config.sound[self.zoneData.level]
    end
    return ret
end

function MapItemData:GetHeatLevel()
    return self.config.heat_level[self:GetLevel()]
end

function MapItemData:GetNextHeatLevel()
    return self.config.heat_level[self:GetLevel() + 1]
end

function MapItemData:GetZoneBonus()
    return self.config.zone_bonus
end

--获取家具的位置
function MapItemData:GetFurniturePoint(furnitureType, index)
    if self.isShowView then
        return self.view:GetFurniturePoint(furnitureType, index)
    end
    return nil
end

function MapItemData:OpenRoof()
    if self.isShowView then
        self.view.upgradeCloseRoof = false
        -- self.view:OpenRoof()
    end
end

function MapItemData:CheckRoof()
    if self.isShowView then
        -- self.view:CheckRoof()
    end
end

function MapItemData:RefreshRoofView(event)
    if self.isShowView then
        -- self.view:RefreshRoofView(event)
    end
end

--检查是否建造完成
function MapItemData:CheckBuildComplete()
    if self.zoneData and self.zoneData.finished == false and
            (TimeManager.GameTime() - self.zoneData.buildTime) >= self:GetBuildDuration()
    then
        -- AudioManager.PlayEffect("ui_builing_done")
        self:BuildComplete()
    elseif self:IsUpgrading() and
            (TimeManager.GameTime() - self.zoneData.buildTime) >= self:GetBuildDuration()
    then
        -- AudioManager.PlayEffect("ui_builing_done")
        self:UpgradeComplete()
    end
end

--获取当前建筑状态
function MapItemData:GetBuildStatus()
    if not self.zoneData then
        return BuildingStatus.Empty
    end

    if self.zoneData.finished then
        return BuildingStatus.Complete
    end

    return BuildingStatus.Building
end

--判断区域是否解锁
function MapItemData:IsUnlock()
    return self:GetBuildStatus() == BuildingStatus.Complete
end

--获取当前建筑的资源id
function MapItemData:GetBuildAssetsId()
    return self.config.assets_id[self.zoneData.level]
end

function MapItemData:HasBuildLevelAssets(level)
    return self.config.assets_id[level] ~= nil
end

function MapItemData:GetBuildLevelAssets(level)
    return self.config.assets_id[level]
end

--获取当前建筑的资源路径
function MapItemData:GetBuildAssetsPath(level)
    local assets_name = self.config.assets_name
    local buildAssetsPath = nil
    local status = self:GetBuildStatus()
    if level ~= nil then
        if level <= 0 then
            buildAssetsPath = self.config.empty_id
        else
            local assets_id = self.config.assets_id[level]
            buildAssetsPath = assets_name .. "_Lv" .. assets_id
        end
    elseif status == BuildingStatus.Complete then
        level = self.zoneData.level
        local assets_id = self.config.assets_id[level]
        buildAssetsPath = assets_name .. "_Lv" .. assets_id
    elseif status == BuildingStatus.Building then
        buildAssetsPath = assets_name .. "_Building"
    else
        buildAssetsPath = self.config.empty_id
    end
    return buildAssetsPath
end

--获得当前建筑空场地资源
function MapItemData:GetBuildEmptyAssetsPath()
    return "prefab/zone/" .. self.config.assets_name .. "/" .. self.config.assets_name .. "_Empty_" .. self.cityId
end

function MapItemData:GetBuildPreviewAssetsPath()
    local assets_name = self.config.assets_name
    local buildAssetsPath = nil
    local status = self:GetBuildStatus()
    local assets_id = self.config.assets_id[1]
    buildAssetsPath =
        "prefab/zone/" .. assets_name .. "/" .. "Preview/" .. assets_name .. "_Pre_Metal" .. "_Lv" .. assets_id
    return buildAssetsPath
end

function MapItemData:GetBuildFenceAssetsPath()
    local assets_name = self.config.assets_name
    local buildAssetsPath = nil
    local status = self:GetBuildStatus()
    local level = self:GetLevel() + 1
    level = Mathf.Min(self.config.max_level, Mathf.Max(1, level))
    if level > #self.config.assets_id then
        level = #self.config.assets_id
    end
    local assets_id = self.config.assets_id[level]
    buildAssetsPath =
        "prefab/zone/" .. assets_name .. "/" .. "Fence/" .. assets_name .. "_Fence_Metal" .. "_Lv" .. assets_id
    return buildAssetsPath
end

--获取当前家居列表
function MapItemData:GetFurnitureList()
    local ret = {}
    if self.furnitureMilestoneConfig ~= nil then
        if self:IsHaveToolFurniture() then
            local toolList = self:GetToolFurnitureList()
            for furnitureId, count in pairs(toolList) do
                ret[furnitureId] = count
            end
        end
        if self:IsHaveBoostFurniture() then
            local boostList = self:GetBoostFurnitureList()
            for furnitureId, count in pairs(boostList) do
                ret[furnitureId] = count
            end
        end
    else
        local list = ConfigManager.GetFurnituresList(self.cityId, self.config.zone_type)
        for ix, furniture in pairs(list) do
            local count_in_room = furniture.count_in_room[self.zoneData.level]
            if count_in_room ~= nil and count_in_room > 0 then
                ret[furniture.id] = count_in_room
            end
        end
    end

    return ret
end

--获取建造剩余时间
function MapItemData:GetBuildLeftTime()
    return self:GetBuildDuration() - (TimeManager.GameTime() - self.zoneData.buildTime), self:GetBuildDuration()
end

function MapItemData:GetBuildLeftRealTime()
    return self:GetBuildDuration() - (GameManager.Realtime() - self.zoneData.buildTime), self:GetBuildDuration()
end

--获取升级建造时间
function MapItemData:GetBuildDuration()
    local duration = 0
    if self:IsUnlock() then
        duration = self.config.build_duration[self.zoneData.level + 1] or 0
    else
        duration = self.config.build_duration[1]
    end
    duration = math.ceil(duration / BoostManager.GetCommonBoosterFactor(self.cityId, CommonBoostType.ConstructionSpeed))
    return duration / TestManager.GetTest(self.cityId).aiGameSpeed.value
end

--建造完成
function MapItemData:BuildComplete()
    self.zoneData.finished = true
    self.zoneData.isShowUpgradeComplete = true
    Audio.PlayAudio(DefaultAudioID.BuildComplete)
    self.zoneData.product = self.zoneData.product or {}
    self.zoneData.toolLevel = 1
    self.zoneData.boostLevel = 1
    self.zoneData.v = ConfigManager.ZoneDataVersion
    self:FixFurnitureData()
    self:CacheAllExp()
    self:CacheAllBoost()
    MapManager.UpdateBoost(self.cityId)
    -- MapManager.UpdateExp(self.cityId)
    self:UpdateGridData()
    self:SetHasClick(false)
    if self.isShowView then
        self.view:UpdateBuildView()
        self.view:InitFurnituresView()
        self.view:UpdateBuildIcon()

        self:SetDefaultCardData()
    end
    -- MapManager.UpdateEnergy()
    MapManager.CacheUnlockZoneList(self.cityId)
    MapManager.UpdateUnlockZone(self.cityId)
    local selectStage = 0
    if self.config.stage ~= nil and self.zoneData.level <= #self.config.stage then
        selectStage = self.config.stage[self.zoneData.level]
    end
    Analytics.Event("UpgradeZoneComplete", {zoneId = self.zoneId, zoneLevel = self.zoneData.level, stage = selectStage})
    EventManager.Brocast(EventDefine.ShowMainUITip, "toast_building_completed", ToastListIconType.BuildingWhite, false, 3)
    -- self:ShowListToast("toast_building_completed", ToastListColor.Green, ToastListIconType.BuildingWhite)
    self:SaveData()
    EventManager.Brocast(EventType.UPGRADE_ZONE, self.cityId, self.zoneId, self.config.zone_type, self.zoneData.level)
    local list = self:GetFurnitureList()
    for furnitureId, count in pairs(list) do
        local furniture = ConfigManager.GetFurnitureById(furnitureId)
        EventManager.Brocast(
                EventType.UPGRADE_FURNITURE,
                self.cityId,
                self.zoneId,
                self.config.zone_type,
                furniture.furniture_type,
                1,
                1
        )
    end
    if CityManager.IsEventScene(EventCityType.Water) then
        AudioManager.PlayEffect("ui_building_1002_done")
    end
    return true
end

--解锁区域
---@param cb fun(success:boolean)
function MapItemData:UnlockZone(cb, silence)
    local costConfig = self:GetUnlockLevelCost()

    local checkStock = function()
        if MapManager.GetBuildQueueIsFull() then
            --GameToast.Instance:Show(GetLang("toast_reach_max_queue"), ToastIconType.Warning)
            -- PopupManager.Instance:OpenPanel(PanelType.BuildWaitingListPanel)
            ShowUI(UINames.UIBuildWaitingList)
            return false
        end

        if not DataManager.CheckMaterials(self.cityId, costConfig) then
            self:ShowGameToast(GetLang("insufficient_materials"))
            return false
        end

        return true
    end

    if not checkStock() then
        cb(false)
        return
    end

  
    if not checkStock() then
        cb(false)
        return
    end

    for costItem, count in pairs(costConfig) do
        DataManager.UseMaterial(self.cityId, costItem, count, "BuildZone", self.zoneId)
    end
    self.zoneData = {furnitures = {}, level = 1}
    MapManager.SetZoneData(self.cityId, self.zoneId, self.zoneData)
    EventManager.Brocast(EventType.UPGRADE_ZONE_BEGIN, self.cityId, self.zoneId, self.config.zone_type)
    local selectStage = 0
    if self.config.stage ~= nil and self.zoneData.level <= #self.config.stage then
        selectStage = self.config.stage[self.zoneData.level]
    end
    -- Analytics.Event("UpgradeZone", {zoneId = self.zoneId, zoneLevel = 0, stage = selectStage})
    if self.config.build_duration[self.zoneData.level] > 0 then
        self.zoneData.finished = false
        self.zoneData.buildTime = TimeManager.GameTime()
        self.zoneData.v = ConfigManager.ZoneDataVersion
        if self.isShowView then
            -- self.view:InitFurnituresView()
            -- self.view:UpdateBuildView()
            self.view:CheckStartBuild()
            self.view:UpdateBuildIcon()
        end
        self:SaveData()
    else
        self:BuildComplete()
    end

    cb(true)
       
end

--区域建造加速完成
function MapItemData:GetSpeedCost()
    local ret = 0
    local lfTime = self:GetBuildLeftTime()
    local times = math.ceil((lfTime / 60) / ConfigManager.GetMiscConfig("time_wrap_min"))
    ret = times * ConfigManager.GetMiscConfig("time_wrap_diamonds_count")
    ret = math.ceil(math.abs(ret))
    ret = math.max(ret, 1)
    return ret
end

--区域建造加速完成
function MapItemData:SpeedBuildComplete(completeFunc)
    if self:GetBuildLeftTime() <= 1 then
        --self:ShowGameToast(GetLang("toast_gem_not_enough"))
        return
    end

    local rt =
        Utils.ShowDiamondConfirmBox(
        function()
            return self:GetSpeedCost()
        end,
        function()
            if self:GetBuildLeftTime() <= 1 then
                return
            end

            DataManager.UseMaterial(self.cityId, ItemType.Gem, self:GetSpeedCost(), "SpeedUpUpgrading", self.zoneId)
            self:BuildComplete()
            -- AudioManager.PlayEffect("ui_builing_done")
            if self.isShowView then
                self.view:UpdateBuildLeftTimeView()
            end
            self:SaveData()

            completeFunc()
        end,
        self:GetBuildLeftTime(),
        nil
    )

    if not rt then
        self:ShowGameToast(GetLang("toast_gem_not_enough"))
        return false
    end

    return true
end

--区域建造加速完成
function MapItemData:UseTicketSpeedBuildUpgradeComplete()
    if DataManager.GetMaterialCount(self.cityId, ItemType.BuildTicket) < 1 then
        self:ShowGameToast(GetLangFormat("toast_build_resource_not_enough", ItemType.BuildTicket))
        return false
    end
    DataManager.UseMaterial(self.cityId, ItemType.BuildTicket, 1, "SpeedUpUpgrading", self.zoneId)
    self.zoneData.buildTime = self.zoneData.buildTime - ConfigManager.GetMiscConfig("build_ticket_time") * 60
    self:CheckBuildComplete()
    if self.isShowView then
        self.view:UpdateBuildLeftTimeView()
    end
    self:SaveData()
    return true
end

--减少建筑升级时间
function MapItemData:DecreaseUpgradeTime(sec)
    self.zoneData.buildTime = self.zoneData.buildTime - sec
    self:CheckBuildComplete()
    if (TimeManager.GameTime() - self.zoneData.buildTime) >= self:GetBuildDuration() and self.isShowView then
        self.view:UpdateBuildLeftTimeView()
    end
    self:SaveData()
end

--升级建筑
---@param cb fun(success:boolean)
function MapItemData:UpgradeZoneLevel(cb, silence)
    local isBlackCoin = false
    local costConfig = self:GetUnlockLevelCost()

    local checkStock = function()
        if MapManager.GetBuildQueueIsFull() then
            --GameToast.Instance:Show(GetLang("toast_reach_max_queue"), ToastIconType.Warning)
            -- PopupManager.Instance:OpenPanel(PanelType.BuildWaitingListPanel)
            ShowUI(UINames.UIBuildWaitingList)
            return false
        end
        if self:GetExp() < self:GetUpgradeExp() then
            return false
        end

        if not DataManager.CheckMaterials(self.cityId, costConfig) then
            self:ShowGameToast(GetLang("insufficient_materials"))
            return false
        end

        return true
    end

    if not checkStock() then
        cb(false)
        return
    end

    for costItem, count in pairs(costConfig) do
        DataManager.UseMaterial(self.cityId, costItem, count, "UpgradeZone", self.zoneId)
        if costItem == ItemType.BlackCoin then
            isBlackCoin = true
        end
    end

    self:UpgradeZoneLevelInData()

    cb(true)
end

--- 升级建筑，不做任何条件判断
function MapItemData:UpgradeZoneLevelInData()
    self.zoneData.upgrading = true
    self.zoneData.buildTime = TimeManager.GameTime()
    if self.isShowView then
        -- self.view:CloseRoof()
        self.view:CheckStartBuild()
    end
    local selectStage = 0
    if self.zoneData.level <= #self.config.stage then
        selectStage = self.config.stage[self.zoneData.level]
    end
    Analytics.Event("UpgradeZone", {zoneId = self.zoneId, zoneLevel = self.zoneData.level, stage = selectStage})

    self:SaveData()
end

function MapItemData:IsBuilding()
    return self:GetBuildStatus() == BuildingStatus.Building
end

--是否正在升级
function MapItemData:IsUpgrading()
    return self:GetBuildStatus() == BuildingStatus.Complete and self.zoneData.upgrading
end

function MapItemData:IsDeveloping()
    if self:IsBuilding() then
        return true
    end

    if self:IsUpgrading() then
        return true
    end

    return false
end

function MapItemData:SetHasClick(click)
    if self.zoneData ~= nil then
        self.zoneData.hasClick = click
        self:SaveData()
    end
end

function MapItemData:GetHasClick()
    if self.zoneData ~= nil then
        return self.zoneData.hasClick
    end
    return nil
end

--升级完成
function MapItemData:UpgradeComplete()
    self.zoneData.upgrading = false
    self.zoneData.isShowUpgradeComplete = true
    Audio.PlayAudio(DefaultAudioID.BuildComplete)
    self.zoneData.level = self.zoneData.level + 1
    self:CacheAllExp()
    self:CacheAllBoost()
    self:SetHasClick(false)
    MapManager.UpdateBoost(self.cityId)
    -- MapManager.UpdateExp(self.cityId)
    self:UpdateGridDataEx()
    if self.isShowView then
        self.view:UpdateBuildView()
        self.view:ClearFurnitureView()
        self.view:InitFurnituresView()
    end
    --火炉升级后刷新状态
    if self.config.zone_type == ZoneType.Generator then
        if self.isShowView then
            self.view:UpdateCampfireView()
            self.view:RefreshStatus("initfresh")
        end
        if self.cityId == DataManager.GetMaxCityId() then
            DataManager.SetGlobalDataByKey(DataKey.MaxGenId, self.zoneData.level)
        end
        -- if self.cityId == DataManager.GetCityId() then
        --     GeneratorManager.CloseOverload(self.cityId)
        -- end
        if FunctionsManager.IsOpen(self.cityId, FunctionsType.Cards) then
            local cardFarmDetail = CardManager.GetUpdateCardFarm()
            Analytics.Event("UpdateCardFarm", {cardFarmDetail = cardFarmDetail})
        end
    end
    EventManager.Brocast(EventType.UPGRADE_ZONE, self.cityId, self.zoneId, self.config.zone_type, self.zoneData.level)
    local selectStage = 0
    if self.zoneData.level <= #self.config.stage then
        selectStage = self.config.stage[self.zoneData.level]
    end
    -- Analytics.Event("UpgradeZoneComplete", {zoneId = self.zoneId, zoneLevel = self.zoneData.level, stage = selectStage})
    MapManager.CacheUnlockZoneList(self.cityId)
    MapManager.UpdateUnlockZone(self.cityId)
    if CityManager.IsEventScene(EventCityType.Water) then
        AudioManager.PlayEffect("ui_building_1002_done")
    end

    -- 净化器升级，同步数据至服务端（致物质援助等级变化）
    if self.config.zone_type == ZoneType.Generator then
        PlayerModule.c2sSyncCityAndGenerator(self.cityId, self.zoneData.level)
    end

    self:SaveData()
    return true
end

--区域升级加速完成
function MapItemData:SpeedUpgradeComplete(completeFunc)
    if self:GetBuildLeftTime() <= 1 then
        --self:ShowGameToast(GetLang("toast_gem_not_enough"))
        return
    end

    local rt =
        Utils.ShowDiamondConfirmBox(
        function()
            return self:GetSpeedCost()
        end,
        function()
            if self:GetBuildLeftTime() <= 1 then
                return
            end

            DataManager.UseMaterial(self.cityId, ItemType.Gem, self:GetSpeedCost(), "SpeedUpgrade", self.zoneId)
            self:UpgradeComplete()
            if self.isShowView then
                self.view:UpdateBuildLeftTimeView()
            end
            self:SaveData()

            completeFunc()
        end,
        self:GetBuildLeftTime(),
        nil --这个nil不能省略，因为GetBuildLeftTime返回的是2个参数
    )

    if not rt then
        self:ShowGameToast(GetLang("toast_gem_not_enough"))
        return false
    end

    return true
end

--获取区域等级 0代表未解锁
function MapItemData:GetLevel()
    local ret = 0
    if self:IsUnlock() then
        ret = self.zoneData.level
    end
    return ret
end

--获取家具等级 0代表未解锁
function MapItemData:GetFurnitureLevel(furnitureId, index)
    local ret = 0
    if self:IsUnlock() then
        if self.zoneData.furnitures[furnitureId] then
            ret = self.zoneData.furnitures[furnitureId]["ix_" .. index] or 0
        end
    end
    return ret
end

--获取家具当前最大等级
function MapItemData:GetFurnitureMaxLevel(furnitureId)
    local ret = 0
    if self:IsUnlock() then
        local fconfig = ConfigManager.GetFurnitureById(furnitureId)
        ret = fconfig.max_level[self.zoneData.level]
    end
    return ret
end

--升级家具等级
---@param cb fun(success:boolean, popup:boolean)
function MapItemData:UpgradeFurnitureLevel(furnitureId, index, cb, silence)
    local lv = self:GetFurnitureLevel(furnitureId, index)
    local fconfig = ConfigManager.GetFurnitureById(furnitureId)
    local costConfig = self:GetFurnituresUnlockLevelCost(furnitureId, index)

    local checkStock = function()
        if lv >= self:GetFurnitureMaxLevel(furnitureId) then
            self:ShowGameToast(GetLang("toast_reach_max_level"))
            return false
        end

        if not DataManager.CheckMaterials(self.cityId, costConfig) then
            self:ShowGameToast(GetLang("insufficient_materials"))
            return false
        end

        return true
    end

    if not checkStock() then
        cb(false)
        return
    end

    AlertPanelManager.ShowFuelAlertPanel(
        self.zoneId,
        furnitureId,
        costConfig,
        function(popup)
            -- 警告以后，也要检查一遍
            if not checkStock() then
                cb(false, popup)
                return
            end

            for costItem, count in pairs(costConfig) do
                DataManager.UseMaterial(self.cityId, costItem, count, "UpgradeFurniture", furnitureId)
            end
            if not self.zoneData.furnitures[furnitureId] then
                self.zoneData.furnitures[furnitureId] = {}
            end
            self.zoneData.furnitures[furnitureId]["ix_" .. index] = lv + 1
            self:CacheAllExp()
            self:CacheAllBoost()
            MapManager.UpdateBoost(self.cityId)
            -- MapManager.UpdateExp(self.cityId)

            local zoneType = fconfig.zone_type
            local furnitureType = fconfig.furniture_type
            EventManager.Brocast(
                EventType.UPGRADE_FURNITURE,
                self.cityId,
                self.zoneId,
                zoneType,
                furnitureType,
                index,
                lv + 1
            )
            self:ResetProductData(furnitureId, index)
            -- Map.Instance:ActionItemEvent(zoneId, "UpgradeFurniture", {furnitureId = furnitureId, index = index})
            if self.isShowView then
                self.view:UpdateFurnitureView(furnitureId, index)
            end
            -- MapManager.UpdateEnergy()
            Analytics.Event(
                "UpgradeFurniture",
                {
                    zoneId = self.zoneId,
                    zoneLevel = self:GetLevel(),
                    furnitureId = furnitureId,
                    furnitureLevel = self:GetFurnitureLevel(furnitureId, index)
                }
            )
            self:SaveData()

            if CityManager.IsEventScene(EventCityType.Water) then
                AudioManager.PlayEffect("ui_furniture_1002_upgrade")
            else
                AudioManager.PlayEffect("ui_furniture_upgrade")
            end
            cb(true, popup)
        end,
        silence
    )
end

--获取当前区域产生的电力
function MapItemData:GetEnergyReward()
    local ret = 0
    if self:IsUnlock() then
        local list = self:GetFurnitureList()
        for furnitureId, count in pairs(list) do
            local furniture = ConfigManager.GetFurnitureById(furnitureId)
            for index = 1, count, 1 do
                local lv = self:GetFurnitureLevel(furnitureId, index)
                if lv and lv > 0 and #furniture.energy_reward > 0 then
                    ret = ret + furniture.energy_reward[lv]
                end
            end
        end
    end
    return ret
end


--获取建造或者升级的条件
function MapItemData:GetUnlockLevelConfig()
    local ret = {}
    --区域等级条件
    if self.config.unlock_zone_level then
        if self:IsUnlock() then
            ret["ZoneLevel"] = self.config.unlock_zone_level[self.zoneData.level + 1]
        else
            ret["ZoneLevel"] = self.config.unlock_zone_level[1]
        end
    end

    return ret
end

--判断建造或者升级条件是否满足
function MapItemData:GetUnlockLevelIsReady()
    local ret = {}
    ret["AllReady"] = true
    local unlockConfig = self:GetUnlockLevelConfig()
    if unlockConfig["ZoneLevel"] then
        ret["ZoneLevel"] = {}
        for zoneId, level in pairs(unlockConfig["ZoneLevel"]) do
            ret["ZoneLevel"][zoneId] = true
            if MapManager.GetZoneLevel(self.cityId, zoneId) < level then
                ret["ZoneLevel"][zoneId] = false
                ret["AllReady"] = false
            end
        end
    end
    -- if unlockConfig["DormLevelCount"] then
    --     ret["DormLevelCount"] = true
    --     if
    --         MapManager.GetZoneCount(ZoneType.Dorm, unlockConfig["DormLevelCount"].level) <
    --             unlockConfig["DormLevelCount"].count
    --      then
    --         ret["DormLevelCount"] = false
    --         ret["AllReady"] = false
    --     end
    -- end
    -- if unlockConfig["EnergyCost"] then
    --     ret["EnergyCost"] = true
    --     if DataManager.energy.value < unlockConfig["EnergyCost"] then
    --         ret["EnergyCost"] = false
    --         ret["AllReady"] = false
    --     end
    -- end
    return ret
end

--获取建造或者升级的消费（与净化器材质相同的消费）
function MapItemData:GetUnlockLevelConsume()
    local result = {itemId = GeneratorManager.GetConsumptionItemId(self.cityId), count = 0}

    local cost = {}
    if self.config.build_cost then
        if self:IsUnlock() then
            cost = self.config.build_cost[self.zoneData.level + 1]
        else
            cost = self.config.build_cost[1]
        end
    end

    local booster = 1
    if CityManager.GetIsEventScene() then
        booster = BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.BuildCost)
    end


    for item, count in pairs(cost) do
        if item == result.itemId then
            result.count = count * booster
        end
    end

    return result
end

--获取建造或者升级的资源花费
function MapItemData:GetUnlockLevelCost()
    local cost = {}
    if self.config.build_cost then
        if self:IsUnlock() then
            cost = self.config.build_cost[self.zoneData.level + 1]
        else
            cost = self.config.build_cost[1]
        end
    end
    local booster = 1
    if CityManager.GetIsEventScene() then
        booster = BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.BuildCost)
    end
    local ret = {}
    for item, count in pairs(cost) do
        ret[item] = count * booster
    end
    return ret
end

--获取建造或者升级的资源花费是否足够
function MapItemData:GetUnlockLevelCostIsReady()
    local ret = true
    local needMat = {}
    local buildCost = self:GetUnlockLevelCost()
    for costItem, count in pairs(buildCost) do
        if math.floor(DataManager.GetMaterialCount(self.cityId, costItem)) < math.floor(count) then
            needMat[costItem] = count
            ret = false
        end
    end
    return ret, needMat
end

--获取家具建造或者升级的条件是否满足
function MapItemData:GetFurnitureUnlockLevelIsReady(furnitureId, index)
    local lv = self:GetFurnitureLevel(furnitureId, index)
    local fconfig = ConfigManager.GetFurnitureById(furnitureId)
    if lv >= self:GetFurnitureMaxLevel(furnitureId) then
        return false
    end
    return true
end

--获取家具建造或者升级的资源花费
function MapItemData:GetFurnituresUnlockLevelCost(furnitureId, index)
    local lv = self:GetFurnitureLevel(furnitureId, index)
    local fconfig = ConfigManager.GetFurnitureById(furnitureId)
    local key = self.zoneId .. "_" .. fconfig.furniture_type .. "_" .. index
    local fBuildCost = ConfigManager.GetFurnituresBuildCostConfig(key)
    local cost = {}
    if fBuildCost.build_cost then
        cost = fBuildCost.build_cost[lv + 1]
    end
    local booster = 1
    if CityManager.GetIsEventScene() then
        booster = BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.BuildCost)
    end
    local ret = {}
    for item, count in pairs(cost) do
        ret[item] = Utils.RoundCount(count * booster)
    end
    -- local ret = {}
    -- ret["Wood"] = 1
    return ret
end

--获取家具建造或者升级的资源花费(单个物品和数量
function MapItemData:GetFurnituresUnlockLevelCostItemData(furnitureId, index)
    local ret = {}
    local buildCost = self:GetFurnituresUnlockLevelCost(furnitureId, index)
    for costItem, count in pairs(buildCost) do
        ret.itemId = costItem
        ret.count = count
        break
    end
    return ret
end

--获取家具建造或者升级的资源花费是否足够
function MapItemData:GetFurnituresCostIsReady(furnitureId, index)
    local ret = true
    if self:GetFurnitureLevel(furnitureId, index) >= self:GetFurnitureMaxLevel(furnitureId) then
        ret = false
    else
        local buildCost = self:GetFurnituresUnlockLevelCost(furnitureId, index)
        for costItem, count in pairs(buildCost) do
            if DataManager.GetMaterialCount(self.cityId, costItem) < count then
                ret = false
                break
            end
        end
    end
    return ret
end

--获取区域升级所需经验
function MapItemData:GetUpgradeExp()
    local ret = 0
    if self:IsUnlock() then
        ret = self.config.upgrade_exp[self.zoneData.level] - self:GetAgoUpgradeExp()
    end
    return ret
end

--获取之前等级升级所需经验
function MapItemData:GetAgoUpgradeExp()
    local ret = 0
    if self.zoneData.level > 1 then
        -- ret = self.upgrade_exp[self.zoneData.level - 1]
        ret = self.config.upgrade_exp[self.zoneData.level - 1]
    end
    return ret
end

--获取当前获得的经验
function MapItemData:GetExp()
    local ret = 0
    if self:IsUnlock() then
        local list = self:GetFurnitureList()
        for furnitureId, count in pairs(list) do
            local furniture = ConfigManager.GetFurnitureById(furnitureId)
            if furniture == nil then
                print("[error]" .. "zone: " .. self.zoneId .. ", not found furniture: " .. furnitureId)
                return
            end

            local length = Utils.GetTableLength(furniture.building_exp)
            for index = 1, count, 1 do
                local lv = self:GetFurnitureLevel(furnitureId, index)
                if lv and lv > 0 then
                    for ix = 1, lv, 1 do
                        if ix <= length then
                            ret = ret + furniture.building_exp[ix]
                        else
                            print("[error]" ..
                                    "furnitureId level is error:" ..
                                            furnitureId .. "," .. Utils.GetTableLength(furniture.building_exp) .. "," .. ix
                            )
                        end
                    end
                end
            end
        end
    end
    ret = ret - self:GetAgoUpgradeExp()
    return ret
end

--获取当前区域的温度
function MapItemData:GetTemperature()
    local ret = 0
    if self:IsUnlock() then
        ret = self.config.room_temperature[self.zoneData.level]
        if self.config.zone_type == ZoneType.Generator then
            if not GeneratorManager.GetIsEnable(self.cityId) then
                ret = 0
            elseif GeneratorManager.GetIsOverload(self.cityId) then
                -- ret = ret * ConfigManager.GetMiscConfig("generator_overload_temp_buff")
                ret = ret + ConfigManager.GetFormulaConfigById("bodyTemp").constant_b
            end
        -- ret = ret * BoostManager.GetCommonBoosterFactor(self.cityId, CommonBoostType.GeneratorEnergy)
        end
    end
    return ret
end

--获取当前区域衰减系数
function MapItemData:GetDeltaFactorByType(type)
    local ret = 1
    if self:IsUnlock() then
        if self.config.delta_factor[self.zoneData.level] and self.config.delta_factor[self.zoneData.level][type] then
            ret = self.config.delta_factor[self.zoneData.level][type]
        end
    end
    return ret
end

function MapItemData:GetFurnitureUsageDuration(fconfig, level)
    local ret = 0
    if level > 0 and #fconfig.usage_duration > 0 and level <= #fconfig.usage_duration then
        ret = fconfig.usage_duration[level]
    end
    return ret
end

--获取工具使用时间
function MapItemData:GetUsageDuration(furnitureId, index, level)
    level = level or self:GetFurnitureLevel(furnitureId, index)
    local fconfig = ConfigManager.GetFurnitureById(furnitureId)
    local ret = self:GetFurnitureUsageDuration(fconfig, level)
    --linked_furniture的时间加成
    if fconfig.linked_furnitures ~= nil and #fconfig.linked_furnitures > 0 then
        for index, linkedFid in pairs(fconfig.linked_furnitures) do
            local linkedFconfig = ConfigManager.GetFurnitureById(linkedFid)
            if nil == linkedFconfig then
            else
                local count_in_room = linkedFconfig.count_in_room[self.zoneData.level]
                if count_in_room ~= nil and count_in_room > 0 then
                    for ix = 1, count_in_room, 1 do
                        if self:IsFurnitureCanUse(linkedFid, ix) then
                            ret =
                                ret +
                                self:GetFurnitureUsageDuration(linkedFconfig, self:GetFurnitureLevel(linkedFid, ix))
                        end
                    end
                end
            end
        end
    end
    --boost的时间加成
    -- if fconfig.productor_type == 3 or fconfig.productor_type == 4 then
    --     local output = self:GetFurnitureOutput(fconfig, level)
    --     local resourceType = -1
    --     for itemId, count in pairs(output) do
    --         resourceType = ConfigManager.GetItemConfig(itemId).resource_type
    --         break
    --     end
    --     if resourceType > 0 then
    --         ret = ret * BoostManager.GetProductTimeBoostFactor(self.cityId, resourceType)
    --     end
    -- end
    return ret
end

function MapItemData:GetFurnitureNecessitiesReward(fconfig, level)
    local ret = {}
    local necessities_reward = fconfig.necessities_reward[level]
    if necessities_reward then
        for key, value in pairs(necessities_reward) do
            if not ret[key] then
                ret[key] = 0
            end
            ret[key] = ret[key] + value
        end
    end
    return ret
end

--获取属性加成
function MapItemData:GetNecessitiesReward(furnitureId, index, level)
    level = level or self:GetFurnitureLevel(furnitureId, index)
    local fconfig = ConfigManager.GetFurnitureById(furnitureId)
    local baseRet = self:GetFurnitureNecessitiesReward(fconfig, level)
    --linked_furniture的时间加成
    if fconfig.linked_furnitures ~= nil and #fconfig.linked_furnitures > 0 then
        for index, linkedFid in pairs(fconfig.linked_furnitures) do
            local linkedFconfig = ConfigManager.GetFurnitureById(linkedFid)
            if nil == linkedFconfig then
            else
                local count_in_room = linkedFconfig.count_in_room[self.zoneData.level]
                if count_in_room ~= nil and count_in_room > 0 then
                    for ix = 1, count_in_room, 1 do
                        if self:IsFurnitureCanUse(linkedFid, ix) then
                            local addRet =
                                self:GetFurnitureNecessitiesReward(linkedFconfig, self:GetFurnitureLevel(linkedFid, ix))
                            for key, value in pairs(addRet) do
                                if baseRet[key] then
                                    baseRet[key] = baseRet[key] + value
                                else
                                    baseRet[key] = value
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return baseRet
end

function MapItemData:GetFurnitureNecessitiesRewardSick(fconfig, level)
    local ret = {}
    local necessities_reward = fconfig.necessities_reward_sick[level]
    if necessities_reward then
        for key, value in pairs(necessities_reward) do
            if not ret[key] then
                ret[key] = 0
            end
            ret[key] = ret[key] + value
        end
    end
    return ret
end

--获取生病交互奖励
function MapItemData:GetNecessitiesRewardSick(furnitureId, index, level)
    level = level or self:GetFurnitureLevel(furnitureId, index)
    local fconfig = ConfigManager.GetFurnitureById(furnitureId)
    local baseRet = self:GetFurnitureNecessitiesRewardSick(fconfig, level)
    --linked_furnitureSick的加成
    if fconfig.linked_furnitures ~= nil and #fconfig.linked_furnitures > 0 then
        for index, linkedFid in pairs(fconfig.linked_furnitures) do
            local linkedFconfig = ConfigManager.GetFurnitureById(linkedFid)
            if nil == linkedFconfig then
            else
                local count_in_room = linkedFconfig.count_in_room[self.zoneData.level]
                if count_in_room ~= nil and count_in_room > 0 then
                    for ix = 1, count_in_room, 1 do
                        if self:IsFurnitureCanUse(linkedFid, ix) then
                            local addRet =
                                self:GetFurnitureNecessitiesRewardSick(
                                linkedFconfig,
                                self:GetFurnitureLevel(linkedFid, ix)
                            )
                            for key, value in pairs(addRet) do
                                if baseRet[key] then
                                    baseRet[key] = baseRet[key] + value
                                else
                                    baseRet[key] = value
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return baseRet
end

function MapItemData:GetFurnitureOutput(fconfig, level)
    local ret = {}
    if level > 0 and #fconfig.usage_output > 0 and level <= #fconfig.usage_output then
        for key, value in pairs(fconfig.usage_output[level]) do
            ret[key] = value * TestManager.GetTest(self.cityId).aiGameSpeed.value
        end
    end
    return ret
end

--获取产出
function MapItemData:GetOutput(furnitureId, index, level)
    level = level or self:GetFurnitureLevel(furnitureId, index)
    local fconfig = ConfigManager.GetFurnitureById(furnitureId)
    if fconfig == nil then
        error(debug.traceback())
    end
    --正常产出
    local baseRet = self:GetFurnitureOutput(fconfig, level)
    --linked_furnitures影响的产出
    if fconfig.linked_furnitures ~= nil and #fconfig.linked_furnitures > 0 then
        for index, linkedFid in pairs(fconfig.linked_furnitures) do
            local linkedFconfig = ConfigManager.GetFurnitureById(linkedFid)
            local count_in_room = linkedFconfig.count_in_room[self.zoneData.level]
            if count_in_room ~= nil and count_in_room > 0 then
                for ix = 1, count_in_room, 1 do
                    if self:IsFurnitureCanUse(linkedFid, ix) then
                        local addRet = self:GetFurnitureOutput(linkedFconfig, self:GetFurnitureLevel(linkedFid, ix))
                        for key, value in pairs(addRet) do
                            if baseRet[key] then
                                baseRet[key] = baseRet[key] + value
                            else
                                baseRet[key] = value
                            end
                        end
                    end
                end
            end
        end
    end

    --Boost影响的产出
    local realRet = {}
    for itemId, count in pairs(baseRet) do
        -- if fconfig.productor_type ~= 0 then
        realRet[itemId] = baseRet[itemId] * BoostManager.GetMaterialBoostFactor(self.cityId, itemId)
        -- else
        --     realRet[itemId] = baseRet[itemId]
        -- end
    end

    return realRet, baseRet
end

--获取产出单个ItemData
function MapItemData:GetOutputItemData(furnitureId, index, level)
    local ret = {}
    local output = self:GetOutput(furnitureId, index, level)
    for itemId, count in pairs(output) do
        ret.itemId = itemId
        ret.count = count
        break
    end
    return ret
end

function MapItemData:GetFurnitureRecoverReward(fconfig, level)
    local ret = {}
    local recover_reward = fconfig.recover_reward[level]
    if recover_reward then
        for key, value in pairs(recover_reward) do
            if not ret[key] then
                ret[key] = 0
            end
            ret[key] = ret[key] + value
        end
    end
    return ret
end

--获取小人交互概率影响
function MapItemData:GetRecoverReward(furnitureId, index, level)
    level = level or self:GetFurnitureLevel(furnitureId, index)
    local fconfig = ConfigManager.GetFurnitureById(furnitureId)
    local baseRet = self:GetFurnitureRecoverReward(fconfig, level)
    --linked_furniture的时间加成
    if fconfig.linked_furnitures ~= nil and #fconfig.linked_furnitures > 0 then
        for index, linkedFid in pairs(fconfig.linked_furnitures) do
            local linkedFconfig = ConfigManager.GetFurnitureById(linkedFid)
            local count_in_room = linkedFconfig.count_in_room[self.zoneData.level]
            if count_in_room ~= nil and count_in_room > 0 then
                for ix = 1, count_in_room, 1 do
                    if self:IsFurnitureCanUse(linkedFid, ix) then
                        local addRet =
                            self:GetFurnitureRecoverReward(linkedFconfig, self:GetFurnitureLevel(linkedFid, ix))
                        for key, value in pairs(addRet) do
                            if baseRet[key] then
                                baseRet[key] = baseRet[key] + value
                            else
                                baseRet[key] = value
                            end
                        end
                    end
                end
            end
        end
    end
    return baseRet
end

--获取火炉的资源消耗
function MapItemData:GetConsumption(level)
    local ret = {}
    level = level or self:GetLevel()
    if self:IsUnlock() then
        return self.config.consumption[level]
    end
    return ret
end

--获取火炉的资源消耗
function MapItemData:UpdateCanUnlock()
    if self.isShowView then
        self.view:UpdateBuildIcon()
    end
end

--返回已经解锁的家具列表
function MapItemData:GetUnlockFurnitureIndexs(furnitureId)
    local ret = List:New()
    if self:IsUnlock() then
        local furniture = ConfigManager.GetFurnitureById(furnitureId)
        local count_in_room = furniture.count_in_room[self.zoneData.level]
        if count_in_room ~= nil and count_in_room > 0 then
            for ix = 1, count_in_room, 1 do
                -- if self:GetFurnitureLevel(furniture.id, ix) >= 1 then
                if self:IsUnlockFurniture(furniture.id, ix) then
                    ret:Add(ix)
                end
            end
        end
    end
    return ret
end

--返回指定解锁家具的数量
function MapItemData:GetUnlockFurnitureCountById(furnitureId, level)
    level = level or 1
    local count = 0
    if self:IsUnlock() then
        local furniture = ConfigManager.GetFurnitureById(furnitureId)
        local count_in_room = furniture.count_in_room[self.zoneData.level]
        if count_in_room ~= nil and count_in_room > 0 then
            for ix = 1, count_in_room, 1 do
                -- if self:GetFurnitureLevel(furniture.id, ix) >= level then
                if self:IsUnlockFurniture(furniture.id, ix) then
                    count = count + 1
                end
            end
        end
    end
    return count
end

--返回家具是否解锁
function MapItemData:IsUnlockFurniture(furnitureId, index)
    local ret = false
    if self:GetFurnitureLevel(furnitureId, index) >= 1 then
        local list = self:GetFurnitureList()
        if list[furnitureId] ~= nil and list[furnitureId] >= index then
            ret = true
        end
    end
    return ret
end

--是否是生产建筑
function MapItemData:IsProdutcionsItem()
    if self:IsUnlock() then
        if self.config.productor_type == 3 or self.config.productor_type == 4 then
            for furnitureId, data in pairs(self.zoneData.furnitures) do
                local output = self:GetFurnitureOutput(ConfigManager.GetFurnitureById(furnitureId), 1)
                for key, value in pairs(output) do
                    return true, output
                end
            end
        end
    end
    return false
end

--返回是否可以生产
function MapItemData:IsCanProduct(furnitureId, index)
    local ret = false
    local lackMaterials = false
    if self:IsUnlock() then
        local level = self:GetFurnitureLevel(furnitureId, index)
        if level > 0 and self:IsFurnitureCanUse(furnitureId, index) then
            local fconfig = ConfigManager.GetFurnitureById(furnitureId)
            if fconfig.productor_type == 1 then
                local result, isFull = FoodSystemManager.IsCanCook(self.cityId)
                ret = result
            elseif fconfig.productor_type == 2 then
                ret = FoodSystemManager.IsCanUseTool(self.cityId, furnitureId, index)
            elseif fconfig.productor_type == 3 then
                ret = true
                local productData = self:GetProductData(furnitureId, index)
                if productData == nil or productData.finished then
                    self:CreatProductData(furnitureId, index)
                end
            elseif fconfig.productor_type == 4 then
                local productData = self:GetProductData(furnitureId, index)
                if productData == nil or productData.finished then
                    local output = self:GetOutput(furnitureId, index, level)
                    local input = ConfigManager.GetInputByOutput(output)
                    ret = DataManager.CheckMaterials(self.cityId, input)
                    if ret then
                        self:CreatProductData(furnitureId, index)
                    else
                        lackMaterials = true
                        FloatIconManager.AddProductLackEvent({output = output})
                    end
                else
                    ret = true
                end
            end
        end
    end
    return ret, lackMaterials
end

--返回生产逻辑的数据 如果没有返回空
function MapItemData:GetProductData(furnitureId, index)
    if not furnitureId or not index then
        return nil
    end
    return self.zoneData.product[furnitureId .. "_" .. index]
end

--创建生产逻辑 返回false 原材料不够
function MapItemData:CreatProductData(furnitureId, index)
    local fconfig = ConfigManager.GetFurnitureById(furnitureId)
    local level = self:GetFurnitureLevel(furnitureId, index)
    local key = furnitureId .. "_" .. index
    --根据家具id 索引和等级 返回真实产出和基础产出
    local realOutput, baseOutput = self:GetOutput(furnitureId, index, level)
    --真实的消耗资源
    if fconfig.productor_type == 4 then
        DataManager.UseMaterials(self.cityId, ConfigManager.GetInputByOutput(realOutput), "Production", furnitureId)
    end
    --添加统计
    StatisticalManager.AddOutputProductions(self.cityId, self.zoneId, baseOutput)

    local pdata = {}
    pdata.furnitureId = furnitureId
    pdata.index = index
    pdata.output = realOutput
    pdata.start = false
    pdata.finished = false
    pdata.duration = self:GetUsageDuration(furnitureId, index)
    pdata.time = 0
    pdata.cost = 0
    self.zoneData.product[key] = pdata
    self:SaveData()

    self:UpdateGridProductView(
        function(id, markerIndex)
            return furnitureId == id and index == markerIndex
        end
    )
    return pdata
end

--获取生产数据进度
function MapItemData:GetProductDataProgress(furnitureId, index)
    local productData = self:GetProductData(furnitureId, index)
    if productData then
        for id, count in pairs(productData.output) do
            return id, math.min(productData.time / productData.duration, 1)
        end
    end
    return -1, 0
end

--刷新生产数据
function MapItemData:ResetProductData(furnitureId, index)
    local key = furnitureId .. "_" .. index
    local pdata = self.zoneData.product[key]
    if pdata then
        local duration = self:GetUsageDuration(furnitureId, index)
        pdata.time = math.floor((pdata.time / pdata.duration) * duration)
        pdata.duration = duration
    end
end

--刷新生产信息
function MapItemData:UpdateProductData(furnitureId, index, time)
    local productData = self:GetProductData(furnitureId, index)
    if nil == productData then
        return nil
    end
    if productData.finished then
        return productData
    end
    if not productData.start then
        productData.start = true
    end
    productData.time = productData.time + time

    local isComplete = false
    local viewTips = nil
    --生产完成
    if productData.time >= productData.duration then
        productData.finished = true
        DataManager.AddMaterials(self.cityId, productData.output, "Production", furnitureId)
        self:SaveData()

        local baseHeart, realHeart = MapManager.GetHeartProductCount(self.cityId, furnitureId)
        if baseHeart > 0 then
            --EventSceneManager.AddHeart(baseHeart, realHeart, "Production", furnitureId)
        end
        --生产显示
        local viewTips = List:New()
        for itemType, itemValue in pairs(productData.output) do
            local info = {}
            info.type = itemType
            info.sprite = Utils.GetItemIcon(itemType)
            info.selectIndex = 3
            info.value = itemValue
            viewTips:Add(info)
        end
        --爱心显示
        if realHeart > 0 then
            local info = {}
            info.type = ItemType.Heart
            info.sprite = Utils.GetItemIcon(ConfigManager.GetEventHeartItemId(self.cityId))
            info.selectIndex = 3
            info.value = realHeart
            viewTips:Add(info)
        end
        isComplete = true
    end
    return productData, isComplete, viewTips
end

--刷新所有家具生产数据
function MapItemData:UpdateAllProductData()
    if self:IsUnlock() then
        local pdata = self.zoneData.product
        if pdata then
            for key, pItemData in pairs(pdata) do
                if not pItemData.finished then
                    local duration = self:GetUsageDuration(pItemData.furnitureId, pItemData.index)
                    if pItemData.duration ~= duration then
                        pItemData.time = math.floor((pItemData.time / pItemData.duration) * duration)
                        pItemData.duration = duration
                    end
                end
            end
        end
    end
end

--获取当前解锁的区域
function MapItemData:GetUnlockZoneList()
    local unlockList = List:New()
    if self:IsUnlock() then
        local zones_unlocked = self.config.zones_unlocked
        local level = self:GetLevel()
        for i = 1, level, 1 do
            if i > #zones_unlocked then
                break
            end
            local lc = zones_unlocked[i]
            for key, value in pairs(lc) do
                unlockList:Add(key)
            end
        end
    end
    return unlockList
end

function MapItemData:GetNextUnlockZoneList()
    local unlockList = List:New()
    if self:IsUnlock() then
        local zones_unlocked = self.config.zones_unlocked
        local level = self:GetLevel() + 1
        if zones_unlocked[level] ~= nil then
            local lc = zones_unlocked[level]
            for key, value in pairs(lc) do
                unlockList:Add(key)
            end
        end
    end
    return unlockList
end

function MapItemData:GetUpgradeCanUnlockList()
    return MapManager.GetUpgradeCanUnlockList(self.cityId, self.zoneId, self:GetLevel() + 1)
end

--获取当前解锁的区域
function MapItemData:GetCapacity()
    local ret = 0
    if self:IsUnlock() then
        local list = ConfigManager.GetFurnituresList(self.cityId, self.config.zone_type)
        for ix, furniture in pairs(list) do
            local count = self:GetUnlockFurnitureCountById(furniture.id)
            ret = ret + count * furniture.capacity
        end
    end
    return ret
end

--清除数据
function MapItemData:Clear()
    self = nil
end

function MapItemData:GetUpgradeLevelName()
    if type(self.config.name_key) == "string" then
        return GetLang(self.config.name_key)
    else
        local lv = self:GetLevel()
        lv = math.max(1, lv)
        if (lv > #self.config.name_key) then
            lv = 1
        end
        return GetLang(self.config.name_key[lv])
    end
end

function MapItemData:GetLevelName(lv)
    if type(self.config.name_key) == "string" then
        return GetLang(self.config.name_key)
    else
        lv = math.max(1, lv)
        if (lv > #self.config.name_key) then
            lv = 1
        end
        return GetLang(self.config.name_key[lv])
    end
end

--返回升级或者建造的介绍
function MapItemData:GetUpgradeLevelDesc()
    local lv = self:GetLevel()
    lv = math.max(1, lv)
    if (lv > #self.config.desc_key) then
        lv = 1
    end
    return GetLang(self.config.desc_key[lv])
end

--返回建筑和家具的所有Exp
function MapItemData:GetAllExp()
    return self.allExp
end

--缓存建筑和家具的所有Exp
function MapItemData:CacheAllExp()
    local ret = 0
    if self:IsUnlock() then
        local level = self:GetLevel()
        for i = 1, level, 1 do
            ret = ret + (self.config.upgrade_generated_exp[i] or 0)
        end
        ret = ret + self:GetExp()
    end
    self.allExp = ret
end

--获取区域boost奖励
function MapItemData:GetAllBoost()
    return self.allBoost
end

function MapItemData:CacheAllBoost()
    local ret = {}
    if self:IsUnlock() then
        local list = self:GetFurnitureList()
        for furnitureId, count in pairs(list) do
            for index = 1, count, 1 do
                for key, value in pairs(self:GetFurnitureBoostReward(furnitureId, index)) do
                    if not ret[key] then
                        ret[key] = 0
                    end
                    ret[key] = ret[key] + value
                end
            end
        end
    end
    self.allBoost = ret
end

--获取属性加成
function MapItemData:GetFurnitureBoostReward(furnitureId, index, level)
    level = level or self:GetFurnitureLevel(furnitureId, index)
    local fconfig = ConfigManager.GetFurnitureById(furnitureId)
    local ret = {}
    local boost_reward = fconfig.boost_reward[level]
    if boost_reward then
        for key, value in pairs(boost_reward) do
            if not ret[key] then
                ret[key] = 0
            end
            ret[key] = ret[key] + value
        end
    end
    if fconfig.linked_furnitures ~= nil and #fconfig.linked_furnitures > 0 then
        for index, linkedFid in pairs(fconfig.linked_furnitures) do
            local linkedFconfig = ConfigManager.GetFurnitureById(linkedFid)
            if nil ~= linkedFconfig then
                local count_in_room = linkedFconfig.count_in_room[self.zoneData.level] or 0
                for ix = 1, count_in_room, 1 do
                    for key, value in pairs(self:GetFurnitureBoostReward(linkedFid, ix)) do
                        if ret[key] then
                            ret[key] = ret[key] + value
                        else
                            ret[key] = value
                        end
                    end
                end
            else
            end
        end
    end
    return ret
end

--获取产物Id
function MapItemData:GetProductId()
    local list = ConfigManager.GetFurnituresList(self.cityId, self.config.zone_type)
    local ret
    for ix, furniture in pairs(list) do
        local fconfig = ConfigManager.GetFurnitureById(furniture.id)
        if fconfig.productor_type ~= nil and fconfig.productor_type > 0 then
            local output = self:GetFurnitureOutput(fconfig, 1)
            for key, value in pairs(output) do
                ret = key
                break
            end
        end
    end
    return ret
end

--设置卡牌
function MapItemData:SetCardId(cardId, dontShowToast, from)
    if self.zoneData.cardId == nil then
        self.zoneData.cardId = 0
    end

    local toastCardId = 0
    local oldCardId = 0
    local cardAction = "Up"

    local logRecallCardId = 0
    --下卡
    if self.zoneData.cardId == cardId then
        oldCardId = self.zoneData.cardId
        toastCardId = cardId
        cardAction = "Down"
        logRecallCardId = cardId
        BoostManager.RemoveBoostById(self.cityId, self.zoneId)
        cardId = 0
        self.zoneData.cardId = cardId
    elseif self.zoneData.cardId ~= 0 and cardId ~= 0 and self.zoneData.cardId ~= cardId then
        oldCardId = self.zoneData.cardId
        logRecallCardId = oldCardId
        cardAction = "Change"
        BoostManager.RemoveBoostById(self.cityId, self.zoneId)
    end
    if logRecallCardId > 0 then
        local recallLogObj = {
            cardId = logRecallCardId,
            bornColor = ConfigManager.GetCardConfig(logRecallCardId).color,
            cardLevel = CardManager.GetCardItemData(logRecallCardId):GetLevel(),
            cardStar = CardManager.GetCardItemData(logRecallCardId):GetStarLevel(),
            cardEffect = CardManager.GetCardItemData(logRecallCardId):GetCardBoostEffect(),
            zoneId = self.zoneId,
            zoneLevel = self:GetLevel(),
            recallfrom = from
        }
        Analytics.Event("CardRecall", recallLogObj)
    end
    --上卡
    if cardId ~= 0 then
        if MapManager.IsHasCardId(self.cityId, cardId) then
            local otherZoneId = MapManager.GetZoneIdByCardId(self.cityId, cardId)
            if otherZoneId ~= self.zoneId then
                MapManager.GetMapItemData(self.cityId, otherZoneId):SetCardId(cardId, true, from)
            end
        end
        self.zoneData.cardId = cardId
        toastCardId = cardId
        BoostManager.AddCardBoost(self.cityId, self.zoneId, cardId)
        local assignLogObj = {
            cardId = cardId,
            bornColor = ConfigManager.GetCardConfig(cardId).color,
            cardLevel = CardManager.GetCardItemData(cardId):GetLevel(),
            cardStar = CardManager.GetCardItemData(cardId):GetStarLevel(),
            cardEffect = CardManager.GetCardItemData(cardId):GetCardBoostEffect(),
            zoneId = self.zoneId,
            zoneLevel = self:GetLevel(),
            assignfrom = from
        }
        Analytics.Event("CardAssign", assignLogObj)
    end
    --火炉
    if self.config.zone_type == ZoneType.Generator then
        EventManager.Brocast(EventType.REFRESH_GENERATOR, self.cityId)
        GeneratorManager.RefreshConsumptionCount(self.cityId)
    end
    if not dontShowToast then
        local cardConfig = ConfigManager.GetCardConfig(toastCardId)
        local cardLevel = CardManager.GetCardItemData(toastCardId):GetLevel()
        local boostEffectLevel = CardManager.GetCardItemData(toastCardId):GetCardBoostLevel()
        local boostConfig = ConfigManager.GetBoostConfig(cardConfig.boost)
        local effect = boostConfig.boost_effects[boostEffectLevel]
        local tip1 = GetLang(boostConfig.effect_icon_tip1_short)
        local tip2 = GetLang(boostConfig.effect_icon_tip2_short)
        local icon1_1 = boostConfig.effect_icon_1
        local icon1_2 = nil
        local icon1_3 = nil
        local icon2_1 = boostConfig.effect_icon_2
        local icon2_2 = nil
        local icon2_3 = nil
        local msg1_1 = nil
        local msg1_2 = nil
        local msg2_1 = nil
        local msg2_2 = nil
        local toastType1 = "Add"
        local toastType2 = "Add"
        local showToast1 = true
        local showToast2 = true

        local oldVal1 = 0
        local oldVal2 = 0
        local newVal1 = 0
        local newVal2 = 0
        if cardAction == "Change" or cardAction == "Down" then
            local oldCardConfig = ConfigManager.GetCardConfig(oldCardId)
            local oldCardLevel = CardManager.GetCardItemData(oldCardId):GetLevel()
            local oldBoostEffectLevel = CardManager.GetCardItemData(oldCardId):GetCardBoostLevel()
            local oldBoostConfig = ConfigManager.GetBoostConfig(oldCardConfig.boost)
            local oldEffect = oldBoostConfig.boost_effects[oldBoostEffectLevel]
            oldVal2 = oldEffect
            if string.find(cardConfig.boost_type, "resource", 0) == 1 then
                oldVal1 = self:GetCardUnlockFurnitureCount(oldCardLevel)
            elseif cardConfig.boost_type == "generator" then
                oldVal1 = 1
            elseif cardConfig.boost_type == "medical" then
                oldVal1 = tonumber(oldBoostConfig.boost_params.cureRate)
            elseif cardConfig.boost_type == "cook" then
                icon1_2 = Utils.GetItemIcon(oldBoostConfig.item_icon)
                icon1_3 = Utils.GetItemIcon(FoodSystemManager.GetFoodType(self.cityId))
            elseif cardConfig.boost_type == "protest" then
                oldVal1 = tonumber(oldBoostConfig.boost_params.count)
            end
        end
        if cardAction == "Change" or cardAction == "Up" then
            newVal2 = effect
            if string.find(cardConfig.boost_type, "resource", 0) == 1 then
                newVal1 = self:GetCardUnlockFurnitureCount(cardLevel)
            elseif cardConfig.boost_type == "generator" then
                newVal1 = 1
            elseif cardConfig.boost_type == "medical" then
                newVal1 = tonumber(boostConfig.boost_params.cureRate)
            elseif cardConfig.boost_type == "cook" then
                if icon1_2 == nil then
                    icon1_2 = Utils.GetItemIcon(FoodSystemManager.GetFoodType(self.cityId))
                end
                icon1_3 = Utils.GetItemIcon(boostConfig.item_icon)
            elseif cardConfig.boost_type == "protest" then
                newVal1 = tonumber(boostConfig.boost_params.count)
            end
        end
        if string.find(cardConfig.boost_type, "resource", 0) == 1 then
            if newVal1 > oldVal1 then
                toastType1 = "Add"
            elseif newVal1 < oldVal1 then
                toastType1 = "Del"
            else
                showToast1 = false
            end
            msg1_1 = "+" .. oldVal1
            msg1_2 = "+" .. newVal1
            if newVal2 > oldVal2 then
                toastType2 = "Add"
            elseif newVal2 < oldVal2 then
                toastType2 = "Del"
            else
                showToast2 = false
            end
            msg2_1 = "x" .. oldVal2
            msg2_2 = "x" .. newVal2
        elseif cardConfig.boost_type == "generator" then
            if newVal1 > oldVal1 then
                toastType1 = "Add"
                msg1_1 = GetLang("Ui_Setting_Button_Off")
                msg1_2 = GetLang("UI_Setting_Button_On")
            elseif newVal1 < oldVal1 then
                toastType1 = "Del"
                msg1_1 = GetLang("UI_Setting_Button_On")
                msg1_2 = GetLang("Ui_Setting_Button_Off")
            else
                showToast1 = false
            end
            if newVal2 > oldVal2 then
                toastType2 = "Add"
            elseif newVal2 < oldVal2 then
                toastType2 = "Del"
            else
                showToast2 = false
            end
            msg2_1 = "-" .. (oldVal2 * 100) .. "%"
            msg2_2 = "-" .. (newVal2 * 100) .. "%"
        elseif cardConfig.boost_type == "medical" then
            if newVal1 > oldVal1 then
                toastType1 = "Add"
            elseif newVal1 < oldVal1 then
                toastType1 = "Del"
            else
                showToast1 = false
            end
            msg1_1 = "+" .. (oldVal1 * 100) .. "%"
            msg1_2 = "+" .. (newVal1 * 100) .. "%"
            if newVal2 > oldVal2 then
                toastType2 = "Add"
            elseif newVal2 < oldVal2 then
                toastType2 = "Del"
            else
                showToast2 = false
            end
            msg2_1 = "+" .. oldVal2
            msg2_2 = "+" .. newVal2
        elseif cardConfig.boost_type == "cook" then
            if newVal2 > oldVal2 then
                toastType1 = "Add"
                toastType2 = "Add"
            elseif newVal2 < oldVal2 then
                toastType1 = "Del"
                toastType2 = "Del"
            else
                showToast2 = false
            end
            msg2_1 = "+" .. (oldVal2 * 100) .. "%"
            msg2_2 = "+" .. (newVal2 * 100) .. "%"
        elseif cardConfig.boost_type == "protest" then
            if newVal1 > oldVal1 then
                toastType1 = "Add"
            elseif newVal1 < oldVal1 then
                toastType1 = "Del"
            else
                showToast1 = false
            end
            msg1_1 = "+" .. oldVal1
            msg1_2 = "+" .. newVal1
            if newVal2 > oldVal2 then
                toastType2 = "Add"
            elseif newVal2 < oldVal2 then
                toastType2 = "Del"
            else
                showToast2 = false
            end
            msg2_1 = "+" .. oldVal2
            msg2_2 = "+" .. newVal2
        end
        if showToast1 then
            GameToast.Instance:ShowBoost(toastType1, tip1, msg1_1, msg1_2, icon1_1, icon1_2, icon1_3, 200)
        end
        if showToast2 then
            GameToast.Instance:ShowBoost(toastType2, tip2, msg2_1, msg2_2, icon2_1, icon2_2, icon2_3, 100)
        end
    end

    self:UpdateGridProductView(
        function(id, markerIndex)
            return true
        end
    )
    EventManager.Brocast(EventType.ZONE_CARD_CHANGE, self.cityId, self.zoneId)
    self:SaveData()
end

--获取卡牌id
function MapItemData:GetCardId()
    if not self:IsUnlock() then
        return 0
    end
    if self:CanSetMultipleCardIds() then
        local cardIds = self:GetCardIds()
        if cardIds:Count() > 0 then
            if not CardManager.IsUnlock(cardIds[1]) then
                return 0
            end
            return cardIds[1]
        else
            return 0
        end
    else
        if self.zoneData.cardId ~= nil and CardManager.IsUnlock(self.zoneData.cardId) then
            return self.zoneData.cardId
        else
            return 0
        end
    end
end

--获取可上多个卡牌的ids
---@return List<number>
function MapItemData:GetCardIds()
    local cardIds = List:New()
    if not self:IsUnlock() or self.zoneData.cardIds == nil then
        return cardIds
    end

    for i, v in pairs(self.zoneData.cardIds) do
        if CardManager.IsUnlock(v) then
            cardIds:Add(v)
        end
    end

    return cardIds
end

--获取默认卡牌
function MapItemData:GetDefaultCardId()
    -- if not self:IsUnlock() then
    --     return 0
    -- end
    if #self.config.card_id > 0 then
        return self.config.card_id[1]
    end
    return 0
end

--获取默认所有卡牌（1002建筑可上多个卡牌）
---@return List<number>
function MapItemData:GetDefaultCardIds()
    local cardIds = List:New()
    if not self:IsUnlock() or self.config.card_id == nil then
        return cardIds
    end

    for i, v in ipairs(self.config.card_id) do
        cardIds:Add(v)
    end

    return cardIds
end

--是否可上多可卡牌
---@return boolean
function MapItemData:CanSetMultipleCardIds()
    return #self.config.card_id > 1
end

--家具是否可用
function MapItemData:IsFurnitureCanUse(furnitureId, index)
    if not self:IsUnlock() then
        return false
    end
    if nil == furnitureId then
        return false
    end
    if self:GetFurnitureLevel(furnitureId, index) <= 0 then
        return false
    end
    if self:GetCardLevel() < self:GetFurnitureNeedCardLevel(furnitureId, index) then
       -- print("ID_-家具是否可用-IsFurnitureCanUse,CardLevel",self:GetCardLevel(),"NeedCardLevel",self:GetFurnitureNeedCardLevel(furnitureId, index))
        return false
    end
    return true
end

--获取卡牌Boost类型
function MapItemData:GetCardBoostType()
    return self.config.card_boost_type
end

--获取家具所需卡牌等级
function MapItemData:GetFurnitureCardLevel(furnitureId, index)
    local ret = 0
    local fconfig = ConfigManager.GetFurnitureById(furnitureId)
    if fconfig.card_level_require ~= nil and #fconfig.card_level_require > 0 then
        if index > #fconfig.card_level_require then
            index = #fconfig.card_level_require
        end
        ret = fconfig.card_level_require[index]
    end
    return ret
end

--获取此建筑是否需要卡牌
function MapItemData:GetIsNeedCard()
    if self.zoneData == nil then
        return false
    end
    local ret = false
    local list = self:GetFurnitureList()
    for furnitureId, count_in_room in pairs(list) do
        local furniture = ConfigManager.GetFurnitureById(furnitureId)
        for i = 1, count_in_room, 1 do
            if furniture.card_level_require ~= nil and #furniture.card_level_require > 0 then
                if furniture.card_level_require[count_in_room] >= 0 then
                    ret = true
                    break
                end
            end
        end
    end
    if self.config.zone_type == ZoneType.Generator then
        local cityCondition = true
        if self.cityId == 2 then
            cityCondition = self.zoneData.level >= 2
        end
        local unlockCondition = FunctionsManager.IsOpen(self.cityId, FunctionsType.Cards)
        ret = cityCondition and unlockCondition
    end
    return ret
end

--获取家具卡牌需求等级
function MapItemData:GetFurnitureNeedCardLevel(furnitureId, index)
    local ret = 0
    if self:IsUnlock() then
        local fconfig = ConfigManager.GetFurnitureById(furnitureId)
        ret = fconfig.card_level_require[index]
    end
    return ret
end

--获取家具卡牌需求等级
function MapItemData:GetCardLevel()
    local ret = 0
    if self:GetCardId() > 0 then
        ret = CardManager.GetCardItemData(self:GetCardId()):GetLevel()
    end
    return ret
end

--获取家具卡牌需求是否最大等级
function MapItemData:GetIsMaxCard()
    local ret = false
    local unlockIds = CardManager.GetRedPointCardListByBoostType(self.config.card_boost_type)
    if self:GetCardId() > 0 and unlockIds:Count() > 0 then
        if unlockIds[1]:GetLevel() > CardManager.GetCardItemData(self:GetCardId()):GetLevel() then
            ret = true
        end
    end
    return ret
end

--获取家具是否有卡牌可以添加
function MapItemData:GetCanAddCard()
    local ret = false
    if self:IsUnlock() and self:GetIsNeedCard() then
        local unlockIds = CardManager.GetRedPointCardListByBoostType(self.config.card_boost_type)
        ret = unlockIds:Count() > 0
    end
    return ret
end

--根据卡牌等级返回能解锁多少个家具
function MapItemData:GetCardUnlockFurnitureCount(cardLevel)
    local ret = 0
    local list = self:GetFurnitureList()
    for furnitureId, count_in_room in pairs(list) do
        local furniture = ConfigManager.GetFurnitureById(furnitureId)
        if furniture.card_level_require ~= nil and #furniture.card_level_require > 0 then
            for i = 1, count_in_room, 1 do
                if furniture.card_level_require[i] > 0 and furniture.card_level_require[i] <= cardLevel then
                    ret = ret + 1
                end
            end
        end
    end
    return ret
end

--获得生产物品
function MapItemData:GetProductItem()
    local ret = nil
    if self:IsUnlock() then
        local list = self:GetFurnitureList()
        for furnitureId, count_in_room in pairs(list) do
            local furniture = ConfigManager.GetFurnitureById(furnitureId)
            if furniture.productor_type == 3 or furniture.productor_type == 4 then
                local output = self:GetFurnitureOutput(ConfigManager.GetFurnitureById(furnitureId), 1)
                for key, value in pairs(output) do
                    ret = key
                    break
                end
            end
        end
    end
    return ret
end

--获取卡车数量
function MapItemData:GetVanCount()
    local ret = 0
    if self:IsUnlock() then
        local list = self:GetFurnitureList()
        for furnitureId, count in pairs(list) do
            local furniture = ConfigManager.GetFurnitureById(furnitureId)
            if nil ~= furniture.van_count and #furniture.van_count > 0 then
                for index = 1, count, 1 do
                    local lv = self:GetFurnitureLevel(furnitureId, index)
                    if lv and lv > 0 then
                        ret = ret + furniture.van_count[lv]
                    end
                end
            end
        end
    end
    return ret
end

--获得卡车的CD时间
function MapItemData:GetVanDeliveringTime()
    local ret = 0
    if self:IsUnlock() then
        local list = self:GetFurnitureList()
        for furnitureId, count in pairs(list) do
            local furniture = ConfigManager.GetFurnitureById(furnitureId)
            if nil ~= furniture.van_count and #furniture.van_count > 0 then
                ret = self:GetFurnitureUsageDuration(furniture, 1)
                return true
            end
        end
    end
    return ret
end

--  获取装载数量
function MapItemData:GetLoadLimit(furnitureId, index, level)
    level = level or self:GetFurnitureLevel(furnitureId, index)
    local fconfig = ConfigManager.GetFurnitureById(furnitureId)
    return self:GetFurnitureLoadLimit(fconfig, level)
end

--获取装载家具加载限制
function MapItemData:GetFurnitureLoadLimit(fconfig, level)
    local ret = {}
    local load_limit = fconfig.load_limit[level]
    if load_limit then
        local boostFactor = BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.VanSpeed)
        for key, value in pairs(load_limit) do
            if not ret[key] then
                ret[key] = 0
            end
            ret[key] = ret[key] + 1.0 * value * boostFactor
        end
    end
    return ret
end

--获取stage
function MapItemData:GetMaxStage()
    local ret = 0
    if self:IsUnlock() then
        ret = self.config.stage[self:GetLevel()]
        local list = self:GetFurnitureList()
        for furnitureId, count in pairs(list) do
            local furniture = ConfigManager.GetFurnitureById(furnitureId)
            for index = 1, count, 1 do
                local lv = self:GetFurnitureLevel(furnitureId, index)
                if lv and lv > 0 then
                    if furniture.stage[lv] > ret then
                        ret = furniture.stage[lv]
                    end
                end
            end
        end
    end
    return ret
end

--[[
######################################################################
######################################################################
######################################################################
######################################################################
######################################################################
######################################################################
######################################################################
######################################################################
######################################################################
######################################################################
######################################################################
######################################################################
]]
--获取工作台等级
function MapItemData:GetToolLevel()
    if nil == self.zoneData then
        print("[error]" .. debug.traceback())
    end
    if self.zoneData.toolLevel == nil then
        self.zoneData.toolLevel = 1
    end
    return self.zoneData.toolLevel
end

--获取是否有工作台
function MapItemData:IsHaveToolFurniture()
    return self.furnitureMilestoneConfig ~= nil and self.furnitureMilestoneConfig.Tool ~= nil
end

--获取工作台家具列表
function MapItemData:GetToolFurnitureList(level)
    local ret = {}
    if self:IsHaveToolFurniture() then
        local toolCfg = self.furnitureMilestoneConfig.Tool
        if toolCfg then
            local toolMs = self:GetToolMilestone(level)
            for i = 1, toolMs do
                local item = toolCfg.furnitures_unlock[i]
                for furnitureId, addCount in pairs(item) do
                    local count = ret[furnitureId] or 0
                    ret[furnitureId] = count + addCount
                end
            end
        end
    end
    return ret
end

--获取工作台milestone等级
function MapItemData:GetToolMilestone(toolLevel)
    local ret = 1
    local minLv = nil
    local maxLv = nil
    local toolCfg = self.furnitureMilestoneConfig.Tool
    if toolCfg then
        toolLevel = toolLevel or self:GetToolLevel()
        for index, lv in pairs(toolCfg.milestone_cut) do
            if toolLevel >= lv then
                ret = index
                minLv = lv
            else
                maxLv = lv
                break
            end
        end
    end
    return ret, minLv, maxLv
end

--获取下一级解锁
function MapItemData:GetToolMilestoneNextReward()
    local ret = {}
    local toolCfg = self.furnitureMilestoneConfig.Tool
    local unlockToolList = toolCfg.furnitures_unlock
    local toolMs, minLv, maxLv = self:GetToolMilestone()
    if maxLv ~= nil then
        local item = unlockToolList[toolMs + 1]
        local len = Utils.GetTableLength(item)
        if len > 0 then
            ret.type = "UnlockFurniture"
            for furnitureId, addCount in pairs(item) do
                ret.furnitureId = furnitureId
                ret.count = addCount
                break
            end
        else
            if self:IsProductType() then
                ret.type = "AddOutput"
                local offs = 0
                local output = self:GetToolOutput(maxLv - 1)
                if (maxLv - 2) > 0 then
                    local prevOutput = self:GetToolOutput(maxLv - 2)
                    offs = output.count - prevOutput.count
                end
                local nextOutput = self:GetToolOutput(maxLv)
                ret.count = string.format("%.1f", nextOutput.count / (output.count + offs))
            else
                ret = nil
            end
        end
    else
        ret = nil
    end
    return ret
end

--判断是否生产类建筑
function MapItemData:IsProductType()
    return self.config.productor_type == 2 or self.config.productor_type == 3 or self.config.productor_type == 4
end

--获取工作台最大等级
function MapItemData:GetToolMaxLevel(zoneLevel)
    local ret = 0
    local toolCfg = self.furnitureMilestoneConfig.Tool
    if toolCfg then
        zoneLevel = zoneLevel or self:GetLevel()
        ret = toolCfg.zone_level_unlock[zoneLevel]
    end
    return ret
end

--获取工具台下级所需建筑等级
function MapItemData:GetToolNeedLevel()
    local ret = 0
    local toolCfg = self.furnitureMilestoneConfig.Tool
    if toolCfg then
        local level = self:GetToolLevel()
        for index, lv in pairs(toolCfg.zone_level_unlock) do
            if lv > level then
                ret = index
                break
            end
        end
    end
    return ret
end

--获取工作台消耗
function MapItemData:GetToolUpgradeCost()
    local ret = {}
    local toolCfg = self.furnitureMilestoneConfig.Tool
    if toolCfg then
        local toolLevel = self:GetToolLevel()
        local buildCost = toolCfg.build_cost[toolLevel]
        for costItem, count in pairs(buildCost) do
            ret.itemId = costItem
            local booster = 1
            if CityManager.GetIsEventScene() then
                booster = BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.BuildCost)
            end
            ret.count = count * booster
            break
        end
    end
    return ret
end

--获取工作台升级材料是否足够
function MapItemData:GetToolUpgradeCostIsReady()
    local buildCost = self:GetToolUpgradeCost()
    return DataManager.GetMaterialCount(self.cityId, buildCost.itemId) >= buildCost.count
end

--获取产出
function MapItemData:GetToolOutput(level)
    level = level or self:GetToolLevel()
    local ret = {}
    local flist = self:GetToolFurnitureList()
    for furnitureId, count_in_room in pairs(flist) do
        local baseRet = self:GetFurnitureOutput(ConfigManager.GetFurnitureById(furnitureId), level)
        for key, value in pairs(baseRet) do
            ret.itemId = key
            ret.count = value * count_in_room
        end
    end
    ret.count = ret.count * BoostManager.GetMaterialBoostFactor(self.cityId, ret.itemId)
    return ret
end

-- 获取升级工作台所需要消费的数据
function MapItemData:GetToolConsume()
    local result = {itemId = 0, count = 0}

    local cfg = self.furnitureMilestoneConfig.Tool
    local buildCost = cfg.build_cost[self.zoneData.toolLevel]

    for itemId, count in pairs(buildCost) do

        local booster = 1
        if CityManager.GetIsEventScene() then
            booster = BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.BuildCost)
        end
        count = count * booster

        result.itemId = itemId
        result.count = count
    end

    return result
end

--升级工作台
function MapItemData:UpgradeToolLevel()
    local cfg = self.furnitureMilestoneConfig.Tool
    local buildCost = cfg.build_cost[self.zoneData.toolLevel]

    for itemId, count in pairs(buildCost) do
        local booster = 1
        if CityManager.GetIsEventScene() then
            booster = BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.BuildCost)
        end
        count = count * booster
        if DataManager.GetMaterialCount(self.cityId, itemId) < count then
            self:ShowGameToast(GetLang("insufficient_materials"))
            return false
        end
    end
    --if not DataManager.CheckMaterials(self.cityId, buildCost) then
    --    self:ShowGameToast(GetLang("insufficient_materials"))
    --    return false
    --end
    for costItem, count in pairs(buildCost) do
        local booster = 1
        if CityManager.GetIsEventScene() then
            booster = BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.BuildCost)
        end
        count = count * booster
        DataManager.UseMaterial(self.cityId, costItem, count, "UpgradeFurnitureNew", self.zoneId)
    end
    local lastfId, lastfIndex = self:GetToolLastFurnitureId()
    self.zoneData.toolLevel = self.zoneData.toolLevel + 1
    if self.isShowView and self.view.RefreshLevelView then
        self.view:RefreshLevelView()
    end
    local ms = self:GetToolMilestone()
    local flist = self:GetToolFurnitureList()
    local toolLevel = self:GetToolLevel()

    for furnitureId, count_in_room in pairs(flist) do
        self.toolFurnitureCount = count_in_room
        for i = 1, count_in_room, 1 do
            if not self.zoneData.furnitures[furnitureId] then
                self.zoneData.furnitures[furnitureId] = {}
            end
            self.zoneData.furnitures[furnitureId]["ix_" .. i] = toolLevel
            if self.isShowView and self.view.UpdateFurnitureView then
                self.view:UpdateFurnitureView(furnitureId, i)
            end
            local fconfig = ConfigManager.GetFurnitureById(furnitureId)
            EventManager.Brocast(
                    EventType.UPGRADE_FURNITURE,
                    self.cityId,
                    self.zoneId,
                    fconfig.zone_type,
                    fconfig.furniture_type,
                    i,
                    toolLevel
            )
            self:ResetProductData(furnitureId, i)
        end
    end
    self:CacheAllExp()
    -- MapManager.UpdateExp(self.cityId)
    self:CacheAllBoost()
    MapManager.UpdateBoost(self.cityId)
    local selectfId, selectfIndex = self:GetToolLastFurnitureId()
    if lastfId ~= selectfId or lastfIndex ~= selectfIndex then
        self:UpdateGridDataEx()
    end
    local selectFLevel = self:GetFurnitureLevel(selectfId, selectfIndex)
    local selectFurnitureConfig = ConfigManager.GetFurnitureById(selectfId)
    local selectStage = 0
    if selectFLevel <= #selectFurnitureConfig.stage then
        selectStage = selectFurnitureConfig.stage[selectFLevel]
    end
    Analytics.Event(
        "UpgradeFurnitureNew",
        {
            zoneId = self.zoneId,
            zoneLevel = self:GetLevel(),
            furnitureIndex = 1,
            MilestoneLevel = self.zoneData.toolLevel,
            stage = selectStage
        }
    )

    if CityManager.IsEventScene(EventCityType.Water) then
        -- AudioManager.PlayEffect("ui_furniture_1002_upgrade")
    else
        -- AudioManager.PlayEffect("ui_furniture_upgrade")
    end
    self:SetDefaultCardData()
    self:SaveData()
end

function MapItemData:FixFurnitureData()
    if self.zoneData ~= nil then
        if self:IsHaveToolFurniture() then
            local toolLevel = self:GetToolLevel()
            local toolCfg = self.furnitureMilestoneConfig.Tool
            if toolCfg.zone_level_unlock ~= nil and #toolCfg.zone_level_unlock > 0 then
                local maxLevel = toolCfg.zone_level_unlock[#toolCfg.zone_level_unlock]
                if toolLevel > maxLevel then
                    self.zoneData.toolLevel = maxLevel
                end
            end
            toolLevel = self:GetToolLevel()
            local flist = self:GetToolFurnitureList()

            for furnitureId, count_in_room in pairs(flist) do
                self.toolFurnitureId = furnitureId
                self.toolFurnitureCount = count_in_room
                for i = 1, count_in_room, 1 do
                    if not self.zoneData.furnitures[furnitureId] then
                        self.zoneData.furnitures[furnitureId] = {}
                    end
                    self.zoneData.furnitures[furnitureId]["ix_" .. i] = toolLevel
                end
            end
        end
        if self:IsHaveBoostFurniture() then
            local boostLevel = self:GetBoostLevel()
            local boostCfg = self.furnitureMilestoneConfig.Boost
            if boostCfg.zone_level_unlock ~= nil and #boostCfg.zone_level_unlock > 0 then
                local maxLevel = boostCfg.zone_level_unlock[#boostCfg.zone_level_unlock]
                if boostLevel > maxLevel then
                    self.zoneData.boostLevel = maxLevel
                end
            end
            boostLevel = self:GetBoostLevel()
            local bflist = self:GetBoostFurnitureList()
            for furnitureId, count_in_room in pairs(bflist) do
                for i = 1, count_in_room, 1 do
                    if not self.zoneData.furnitures[furnitureId] then
                        self.zoneData.furnitures[furnitureId] = {}
                    end
                    self.zoneData.furnitures[furnitureId]["ix_" .. i] = boostLevel
                end
            end
        end
    end
end

--获得辅助家具等级
function MapItemData:GetBoostLevel()
    if self.zoneData.boostLevel == nil then
        self.zoneData.boostLevel = 1
    end
    return self.zoneData.boostLevel
end

--获取是否有辅助家具
function MapItemData:IsHaveBoostFurniture()
    return self.furnitureMilestoneConfig ~= nil and self.furnitureMilestoneConfig.Boost ~= nil
end

--获取辅助家具列表
function MapItemData:GetBoostFurnitureList(boostLevel)
    local ret = {}
    if self:IsHaveBoostFurniture() then
        local boostCfg = self.furnitureMilestoneConfig.Boost
        if boostCfg then
            local boostMs = self:GetBoostMilestone(boostLevel)
            for i = 1, boostMs do
                local item = boostCfg.furnitures_unlock[i]
                for furnitureId, addCount in pairs(item) do
                    local count = ret[furnitureId] or 0
                    ret[furnitureId] = count + addCount
                end
            end
        end
    end
    return ret
end

--获得辅助家具milestone等级
function MapItemData:GetBoostMilestone(boostLevel)
    local boostCfg = self.furnitureMilestoneConfig.Boost
    local ret = 1
    local minLv = nil
    local maxLv = nil
    if boostCfg then
        boostLevel = boostLevel or self:GetBoostLevel()
        for index, lv in pairs(boostCfg.milestone_cut) do
            if boostLevel >= lv then
                ret = index
                minLv = lv
            else
                maxLv = lv
                break
            end
        end
    end
    return ret, minLv, maxLv
end

--获得辅助家具最大等级
function MapItemData:GetBoostMaxLevel(zoneLevel)
    zoneLevel = zoneLevel or self:GetLevel()
    local cfg = self.furnitureMilestoneConfig.Boost
    local ret = cfg.zone_level_unlock[zoneLevel]
    return ret
end

--获取辅助家具下级所需建筑等级
function MapItemData:GetBoostNeedLevel()
    local level = self:GetBoostLevel()
    local cfg = self.furnitureMilestoneConfig.Boost
    local ret = 0
    for index, lv in pairs(cfg.zone_level_unlock) do
        if lv > level then
            ret = index
            break
        end
    end
    return ret
end

--获取辅助家具消耗
function MapItemData:GetBoostUpgradeCost()
    local cfg = self.furnitureMilestoneConfig.Boost
    local boostLevel = self:GetBoostLevel()
    local buildCost = cfg.build_cost[boostLevel]
    local ret = {}
    for costItem, count in pairs(buildCost) do
        ret.itemId = costItem
        local booster = 1
        if CityManager.GetIsEventScene() then
            booster = BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.BuildCost)
        end
        ret.count = count * booster
        break
    end
    return ret
end

--获取辅助家具升级材料是否足够
function MapItemData:GetBoostUpgradeCostIsReady()
    local buildCost = self:GetBoostUpgradeCost()
    return DataManager.GetMaterialCount(self.cityId, buildCost.itemId) >= buildCost.count
end

--获取Boost时间加成
function MapItemData:GetBoostUsageDuration(level)
    level = level or self:GetBoostLevel()
    local ret = 0
    local flist = self:GetBoostFurnitureList()
    for furnitureId, count_in_room in pairs(flist) do
        local fconfig = ConfigManager.GetFurnitureById(furnitureId)
        ret = ret + (self:GetFurnitureUsageDuration(fconfig, level) * count_in_room)
    end
    return ret
end

--获取下一级解锁
function MapItemData:GetBoostMilestoneNextReward()
    local ret = {}
    local boostCfg = self.furnitureMilestoneConfig.Boost
    local unlockBoostList = boostCfg.furnitures_unlock
    local boostMs, minLv, maxLv = self:GetBoostMilestone()
    if maxLv ~= nil then
        local item = unlockBoostList[boostMs + 1]
        local len = Utils.GetTableLength(item)
        if len > 0 then
            ret.type = "UnlockFurniture"
            for furnitureId, addCount in pairs(item) do
                ret.furnitureId = furnitureId
                ret.count = addCount
                break
            end
            local flag = true
            local flist = self:GetBoostFurnitureList()
            for furnitureId, count in pairs(flist) do
                if furnitureId == ret.furnitureId then
                    flag = false
                    break
                end
            end
            if flag then
                ret.type = "AddFurniture"
            end
        else
            ret = nil
        end
    else
        ret = nil
    end
    return ret
end

-- 获取升级辅助家具所需要消费的数据
function MapItemData:GetBoostConsume()
    local result = {itemId = 0, count = 0}

    local cfg = self.furnitureMilestoneConfig.Boost
    local buildCost = cfg.build_cost[self.zoneData.boostLevel]
    for itemId, count in pairs(buildCost) do
        local booster = 1
        if CityManager.GetIsEventScene() then
            booster = BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.BuildCost)
        end
        count = count * booster

        result.itemId = itemId
        result.count = count
    end

    return result
end

--升级辅助家具
function MapItemData:UpgradeBoostLevel()
    local cfg = self.furnitureMilestoneConfig.Boost
    local buildCost = cfg.build_cost[self.zoneData.boostLevel]
    for itemId, count in pairs(buildCost) do
        local booster = 1
        if CityManager.GetIsEventScene() then
            booster = BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.BuildCost)
        end
        count = count * booster
        if DataManager.GetMaterialCount(self.cityId, itemId) < count then
            self:ShowGameToast(GetLang("insufficient_materials"))
            return false
        end
    end
    --if not DataManager.CheckMaterials(self.cityId, buildCost) then
    --    self:ShowGameToast(GetLang("insufficient_materials"))
    --    return false
    --end
    for costItem, count in pairs(buildCost) do
        local booster = 1
        if CityManager.GetIsEventScene() then
            booster = BoostManager.GetEventBoosterValue(self.cityId, EventBoostType.BuildCost)
        end
        count = count * booster
        DataManager.UseMaterial(self.cityId, costItem, count, "UpgradeFurnitureNew", self.zoneId)
    end
    local lastfId, lastfIndex = self:GetBoostLastFurnitureId()
    self.zoneData.boostLevel = self.zoneData.boostLevel + 1
    if self.isShowView and self.view.RefreshLevelView then
        self.view:RefreshLevelView()
    end
    local flist = self:GetBoostFurnitureList()
    local boostLevel = self:GetBoostLevel()
    local selectFurnitureId, findex = self:GetBoostLastFurnitureId()
    for furnitureId, count_in_room in pairs(flist) do
        for i = 1, count_in_room, 1 do
            if not self.zoneData.furnitures[furnitureId] then
                self.zoneData.furnitures[furnitureId] = {}
            end
            self.zoneData.furnitures[furnitureId]["ix_" .. i] = boostLevel
            if self.isShowView and self.view.UpdateFurnitureView then
                self.view:UpdateFurnitureView(furnitureId, i, selectFurnitureId)
            end
            local fconfig = ConfigManager.GetFurnitureById(furnitureId)
            EventManager.Brocast(
                    EventType.UPGRADE_FURNITURE,
                    self.cityId,
                    self.zoneId,
                    fconfig.zone_type,
                    fconfig.furniture_type,
                    i,
                    boostLevel
            )
        end
    end

    self:CacheAllExp()
    -- MapManager.UpdateExp(self.cityId)
    self:CacheAllBoost()
    MapManager.UpdateBoost(self.cityId)
    local selectfId, selectfIndex = self:GetBoostLastFurnitureId()
    if lastfId ~= selectfId and lastfIndex ~= selectfIndex then
        self:UpdateGridData()
    end
    local selectFLevel = self:GetFurnitureLevel(selectfId, selectfIndex)
    local selectFurnitureConfig = ConfigManager.GetFurnitureById(selectfId)
    local selectStage = 0
    if selectFLevel <= #selectFurnitureConfig.stage then
        selectStage = selectFurnitureConfig.stage[selectFLevel]
    end

    Analytics.Event(
        "UpgradeFurnitureNew",
        {
            zoneId = self.zoneId,
            zoneLevel = self:GetLevel(),
            furnitureIndex = 2,
            MilestoneLevel = self.zoneData.boostLevel,
            stage = selectStage
        }
    )
    if CityManager.IsEventScene(EventCityType.Water) then
        -- AudioManager.PlayEffect("ui_furniture_1002_upgrade")
    else
        -- AudioManager.PlayEffect("ui_furniture_upgrade")
    end
    self:SetDefaultCardData()
    self:SaveData()
end

--获取默认聚焦家具
function MapItemData:GetSelectFurniture()
    if self.config.zone_type == ZoneType.Watchtower then
        local ret = 1
        local flist = self:GetFurnitureList()
        for furnitureId, count in pairs(flist) do
            ret = furnitureId
            return true
        end
        return ret, 1
    else
        return self:GetToolLastFurnitureId()
    end
end

--获取工作台家具Id
function MapItemData:GetToolFurnitureId()
    if self.toolFurnitureId == nil then
        local flist = self:GetToolFurnitureList()
        for furnitureId, count_in_room in pairs(flist) do
            self.toolFurnitureId = furnitureId
        end
    end
    return self.toolFurnitureId
end

--获取工作台家具数量
function MapItemData:GetToolFurnitureCount()
    if self.toolFurnitureCount == nil then
        local flist = self:GetToolFurnitureList()
        for furnitureId, count_in_room in pairs(flist) do
            self.toolFurnitureCount = count_in_room
        end
    end
    return self.toolFurnitureCount
end

--获取生产时间
function MapItemData:GetToolUsageDuration(toolLevel)
    toolLevel = toolLevel or self:GetToolLevel()
    local furnitureId = self:GetToolFurnitureId()
    local usageDuration = self:GetUsageDuration(furnitureId, 1, toolLevel)
    return usageDuration
end

--获取产出
function MapItemData:GetOutputInfo()
    local furnitureId = self:GetToolFurnitureId()
    local furnitureCount = self:GetCanWorkTool()
    local toolLevel = self:GetToolLevel()
    local outputItemData = self:GetOutputItemData(furnitureId, 1, toolLevel)
    outputItemData.count = outputItemData.count * furnitureCount
    return outputItemData
end

--获得消耗
function MapItemData:GetInputInfo()
    local furnitureId = self:GetToolFurnitureId()
    local furnitureCount = self:GetCanWorkTool()
    local toolLevel = self:GetToolLevel()
    local output = self:GetOutput(furnitureId, 1, toolLevel)
    local input = ConfigManager.GetInputByOutput(output)
    local ret = {}
    for itemId, count in pairs(input) do
        ret[itemId] = count * furnitureCount
    end
    return ret
end

-- 原材料是否够生产一个
function MapItemData:IsEnoughForOneOutput()
    -- 厨房规则不一样
    if self.config.zone_type == ZoneType.Kitchen then
        local input = self:GetOneKitchenIngredients()
        return DataManager.CheckMaterials(self.cityId, input) == false
    else
        local furnitureId = self:GetToolFurnitureId()
        if furnitureId == nil then
            return false
        end
        local _, baseOutput = self:GetOutput(furnitureId, 1, 1)
        if Utils.GetTableLength(baseOutput) == 0 then
            -- 不能生产
            return false
        end
        for key, value in pairs(baseOutput) do
            baseOutput[key] = 1
        end
        local input = ConfigManager.GetInputByOutput(baseOutput)
        return DataManager.CheckMaterials(self.cityId, input) == false
    end
end

-- 是否存在空岗位
function MapItemData:HasEmptyPost()
    local peopleConfig = ConfigManager.GetPeopleConfigByZoneType(self.cityId, self.config.zone_type)
    if peopleConfig == nil then
        return false
    end
    local furnitureId = peopleConfig.furniture_id

    local canUseToolCount = self:GetCanUseToolCount()
    local unlockIndexs = MapManager.GetUnlockFurnitureIndexs(self.cityId, self.config.zone_type, furnitureId)
    local maxCount = math.min(unlockIndexs:Count(), canUseToolCount)

    local peopleStateCount = CharacterManager.GetPeopleStateCount(self.cityId, peopleConfig.type)
    local normalCount = peopleStateCount[EnumState.Normal] or 0
    local sickCount = peopleStateCount[EnumState.Sick] or 0
    local protestCount = peopleStateCount[EnumState.Protest] or 0
    local totalCount = normalCount + sickCount + protestCount

    return maxCount > totalCount
end

-- 当存在新岗位，且该建筑物的英雄等级未满足解锁该岗位时
function MapItemData:IsPostLockByHeroLevel()
    -- 英雄系统未解锁
    if FunctionsManager.IsUnlock(FunctionsType.Cards) == false then
        return false
    end
    -- 没有英雄 
    if self.config.card_id and #self.config.card_id == 0 then
        return false
    end
    -- 英雄未解锁
    if CardManager.IsUnlock(self.config.card_id[1]) == false then
        return false
    end

    local peopleConfig = ConfigManager.GetPeopleConfigByZoneType(self.cityId, self.config.zone_type)
    if peopleConfig == nil then
        return false
    end

    local furnitureId = peopleConfig.furniture_id
    local canUseToolCount = self:GetCanUseToolCount()
    local unlockIndexs = MapManager.GetUnlockFurnitureIndexs(self.cityId, self.config.zone_type, furnitureId)
    return canUseToolCount < unlockIndexs:Count()
end

function MapItemData:Log(...)
    local isShowLog = self.config.zone_type == ZoneType.Carpentry
    if isShowLog then
        print("zhkxin ", ...)
    end
end

-- 需要英雄但未拥有
function MapItemData:NeedAndLockHero()
    -- 英雄系统未解锁
    if FunctionsManager.IsUnlock(FunctionsType.Cards) == false then
        return false
    end
    -- 没有英雄 
    if self.config.card_id and #self.config.card_id == 0 then
        return false
    end

    -- 英雄未解锁
    local cardUnlockType, _ = CardManager.GetCardUnlockState(self.config.card_id[1], self.cityId)
    return cardUnlockType ~= CardUnlockType.Own
end

--获得属性加成比如 安全屋
function MapItemData:GetBoostRewardInfo(boostLevel)
    local ret = 0
    local flist = self:GetBoostFurnitureList()
    boostLevel = boostLevel or self:GetBoostLevel()
    local ret = {}

    for furnitureId, count in pairs(flist) do
        local boosts = self:GetFurnitureBoostReward(furnitureId, 1, boostLevel)
        for type, val in pairs(boosts) do
            if ret[type] == nil then
                ret[type] = 0
            end
            ret[type] = val * count
        end
    end
    return ret
end

--获得解锁的工作台
function MapItemData:GetCanUseToolCount()
    local ret = 0
    local furnitureId = self:GetToolFurnitureId()
    local furnitureCount = self:GetToolFurnitureCount()
    for index = 1, furnitureCount, 1 do
        if self:IsFurnitureCanUse(furnitureId, index) then
            ret = ret + 1
        end
    end
    return ret
end

--获得工作的人数
function MapItemData:GetNormalPeople()
    local peopleConfig = ConfigManager.GetPeopleConfigByZoneType(self.cityId, self.config.zone_type)
    local peopleWorkState = CharacterManager.GetPeopleStateCount(self.cityId, peopleConfig.type)
    local normalCount = peopleWorkState[EnumState.Normal] or 0
    return normalCount
end

--获得可工作的工作台
function MapItemData:GetCanWorkTool()
    return math.min(self:GetCanUseToolCount(), self:GetNormalPeople())
end

--获得宿舍最大人数
function MapItemData:GetDormMaxPeople()
    local maxBed = 1
    local ret = 2
    local list = ConfigManager.GetFurnituresList(self.cityId, self.config.zone_type)
    for ix, furniture in pairs(list) do
        if furniture.furniture_type == GridMarker.Bed then
            for ix2, count_in_room in pairs(furniture.count_in_room) do
                if count_in_room >= maxBed then
                    maxBed = count_in_room
                end
            end
            ret = maxBed * furniture.capacity
            break
        end
    end
    return ret
end

--获得宿舍当前人数
function MapItemData:GetDormPeople()
    local ret = 0
    if self:IsUnlock() then
        local list = ConfigManager.GetFurnituresList(self.cityId, self.config.zone_type)
        for ix, furniture in pairs(list) do
            if furniture.furniture_type == GridMarker.Bed then
                local count = self:GetUnlockFurnitureCountById(furniture.id)
                ret = ret + count * furniture.capacity
            end
        end
    end
    return ret
end

--获得单个Tool属性
function MapItemData:GetSingleNecessitiesInfo()
    local ret = {}
    local furnitureId = self:GetToolFurnitureId()
    local toolLevel = self:GetToolLevel()
    ret = self:GetNecessitiesReward(furnitureId, 1, toolLevel)
    return ret
end

--获得单个Tool属性Sick
function MapItemData:GetSingleNecessitiesSickInfo()
    local ret = {}
    local furnitureId = self:GetToolFurnitureId()
    local toolLevel = self:GetToolLevel()
    ret = self:GetNecessitiesRewardSick(furnitureId, 1, toolLevel)
    return ret
end

--获得单个Tool属性RecoverReward
function MapItemData:GetSingleRecoverRewardInfo()
    local ret = {}
    local furnitureId = self:GetToolFurnitureId()
    local toolLevel = self:GetToolLevel()
    ret = self:GetRecoverReward(furnitureId, 1, toolLevel)
    return ret
end

--获得厨房消耗
function MapItemData:GetKitchenIngredients()
    local ret = {}
    local furnitureCount = self:GetCanWorkTool()
    local foodType = FoodSystemManager.GetFoodType(self.cityId)
    local foodConfig = ConfigManager.GetFoodConfigByType(foodType)
    local ingredients = foodConfig.ingredients[1]
    for itemId, count in pairs(ingredients) do
        ret[itemId] = count * furnitureCount
    end
    return ret
end

--获得厨房消耗
function MapItemData:GetOneKitchenIngredients()
    local ret = {}
    local foodType = FoodSystemManager.GetFoodType(self.cityId)
    local foodConfig = ConfigManager.GetFoodConfigByType(foodType)
    local ingredients = foodConfig.ingredients[1]
    for itemId, count in pairs(ingredients) do
        ret[itemId] = count * 1
    end
    return ret
end

--获得厨房属性
function MapItemData:GetKitchenNecessitiesInfo()
    local ret = {}
    local foodType = FoodSystemManager.GetFoodType(self.cityId)
    local foodConfig = ConfigManager.GetFoodConfigByType(foodType)
    for nectItem, count in pairs(foodConfig.necesities_reward) do
        ret[nectItem] = count
    end
    local flist = self:GetBoostFurnitureList()
    local boostLevel = self:GetBoostLevel()
    for furnitureId, count in pairs(flist) do
        if ConfigManager.GetFurnitureById(furnitureId).capacity == 0 then
            local boosts = self:GetNecessitiesReward(furnitureId, 1, boostLevel)
            for type, val in pairs(boosts) do
                if ret[type] == nil then
                    ret[type] = 0
                end
                ret[type] = ret[type] + (val * count)
            end
        end
    end
    return ret
end

--获得所有Tool家具的属性
function MapItemData:GetToolNecessitiesInfo(toolLevel)
    local ret = {}
    local flist = self:GetToolFurnitureList()
    toolLevel = toolLevel or self:GetToolLevel()
    for furnitureId, count in pairs(flist) do
        local boosts = self:GetNecessitiesReward(furnitureId, 1, toolLevel)
        for type, val in pairs(boosts) do
            if ret[type] == nil then
                ret[type] = 0
            end
            ret[type] = ret[type] + (val * count)
        end
    end
    return ret
end

--获得所有Tool家具的sick属性
function MapItemData:GetToolNecessitiesSickInfo(toolLevel)
    local ret = {}
    local flist = self:GetToolFurnitureList()
    toolLevel = toolLevel or self:GetToolLevel()
    for furnitureId, count in pairs(flist) do
        local boosts = self:GetNecessitiesRewardSick(furnitureId, 1, toolLevel)
        for type, val in pairs(boosts) do
            if ret[type] == nil then
                ret[type] = 0
            end
            ret[type] = ret[type] + (val * count)
        end
    end
    return ret
end

--获得所有Tool家具的RecoverReward属性
function MapItemData:GetToolRecoverRewardInfo(toolLevel)
    local ret = {}
    local flist = self:GetToolFurnitureList()
    toolLevel = toolLevel or self:GetToolLevel()
    for furnitureId, count in pairs(flist) do
        local boosts = self:GetRecoverReward(furnitureId, 1, toolLevel)
        for type, val in pairs(boosts) do
            if ret[type] == nil then
                ret[type] = 0
            end
            ret[type] = ret[type] + (val * count)
        end
    end
    return ret
end

--获得所有Boost家具的属性
function MapItemData:GetBoostNecessitiesInfo(boostLevel)
    local ret = {}
    local flist = self:GetBoostFurnitureList()
    boostLevel = boostLevel or self:GetBoostLevel()
    for furnitureId, count in pairs(flist) do
        if ConfigManager.GetFurnitureById(furnitureId).capacity == 0 then
            local boosts = self:GetNecessitiesReward(furnitureId, 1, boostLevel)
            for type, val in pairs(boosts) do
                if ret[type] == nil then
                    ret[type] = 0
                end
                ret[type] = ret[type] + (val * count)
            end
        end
    end
    return ret
end

--获得所有Boost家具的sick属性
function MapItemData:GetBoostNecessitiesSickInfo(boostLevel)
    local ret = {}
    local flist = self:GetBoostFurnitureList()
    boostLevel = boostLevel or self:GetBoostLevel()
    for furnitureId, count in pairs(flist) do
        local boosts = self:GetNecessitiesRewardSick(furnitureId, 1, boostLevel)
        for type, val in pairs(boosts) do
            if ret[type] == nil then
                ret[type] = 0
            end
            ret[type] = ret[type] + (val * count)
        end
    end
    return ret
end

--获得所有Boost家具的RecoverReward属性
function MapItemData:GetBoostRecoverRewardInfo(boostLevel)
    local ret = {}
    local flist = self:GetBoostFurnitureList()
    boostLevel = boostLevel or self:GetBoostLevel()
    for furnitureId, count in pairs(flist) do
        local boosts = self:GetRecoverReward(furnitureId, 1, boostLevel)
        for type, val in pairs(boosts) do
            if ret[type] == nil then
                ret[type] = 0
            end
            ret[type] = ret[type] + (val * count)
        end
    end
    return ret
end

--获取Boost产出
function MapItemData:GetBoostOutput(level)
    level = level or self:GetBoostLevel()
    local ret = {}
    local flist = self:GetBoostFurnitureList()
    for furnitureId, count_in_room in pairs(flist) do
        local baseRet = self:GetFurnitureOutput(ConfigManager.GetFurnitureById(furnitureId), level)
        for key, value in pairs(baseRet) do
            ret.itemId = key
            ret.count = value * count_in_room
        end
    end
    ret.count = ret.count * BoostManager.GetMaterialBoostFactor(self.cityId, ret.itemId)
    return ret
end

--获取Tool的图标
function MapItemData:GetToolFurnitureIconName(level)
    level = level or self:GetToolLevel()
    local config = ConfigManager.GetFurnitureById(self:GetToolFurnitureId())
    local assets_id = config.assets_id[level] or 1
    -- 临时1级
    local fpath = config.assets_name .. "_Lv" .. 1
    return string.lower(fpath)
end

--获取最后一个Tool解锁的家具
function MapItemData:GetToolLastFurnitureId(level)
    level = level or self:GetToolLevel()
    local toolMs = self:GetToolMilestone(level)
    local toolCfg = self.furnitureMilestoneConfig.Tool
    local ret = nil
    local fdic = Dictionary:New()
    for i = 1, toolMs do
        local item = toolCfg.furnitures_unlock[i]
        for furnitureId, addCount in pairs(item) do
            if fdic[furnitureId] == nil then
                fdic:Add(furnitureId, 0)
            end
            fdic[furnitureId] = fdic[furnitureId] + addCount
            ret = furnitureId
        end
    end
    return ret, fdic[ret]
end

--获取最后一个Boost解锁的家具
function MapItemData:GetBoostLastFurnitureId(level)
    level = level or self:GetBoostLevel()
    local boostMs = self:GetBoostMilestone(level)
    local boostCfg = self.furnitureMilestoneConfig.Boost
    local ret = nil
    local fdic = Dictionary:New()
    for i = 1, boostMs do
        local item = boostCfg.furnitures_unlock[i]
        local retSort = 100000
        for furnitureId, addCount in pairs(item) do
            if fdic[furnitureId] == nil then
                fdic:Add(furnitureId, 0)
            end
            fdic[furnitureId] = fdic[furnitureId] + addCount
            if ConfigManager.GetFurnitureById(furnitureId).sort < retSort then
                ret = furnitureId
                retSort = ConfigManager.GetFurnitureById(furnitureId).sort
            end
        end
    end
    return ret, fdic[ret]
end

--获取Boost的图标
function MapItemData:GetBoostFurnitureIconName(level)
    level = level or self:GetBoostLevel()
    local furnitureId = self:GetBoostLastFurnitureId(level)
    local config = ConfigManager.GetFurnitureById(furnitureId)
    local assets_id = config.assets_id[level] or 1
    local fpath = config.assets_name .. "_Lv" .. 1
    return string.lower(fpath)
end

--限时场景获取爱心产出
function MapItemData:GetHeartInfo()
    local furnitureId = self:GetToolFurnitureId()
    local baseHeart, realHeart = MapManager.GetHeartProductCount(self.cityId, furnitureId)
    local furnitureCount = self:GetCanWorkTool()
    local outputItemData = {}
    outputItemData.itemId =0-- EventSceneManager.heartItem
    outputItemData.count = realHeart * furnitureCount
    return outputItemData
end

--是否show卡
function MapItemData:ShowCardState()
    return self.zoneData.showCard == true
end

--show卡
function MapItemData:SetShowCard()
    self.zoneData.showCard = true
    self:SaveData()
end

function MapItemData:GetShowUpgradeComplete()
    return self.zoneData.isShowUpgradeComplete
end

function MapItemData:DisableShowUpgradeComplete()
    if self.zoneData then
        self.zoneData.isShowUpgradeComplete = false
    end
end

--保存数据
function MapItemData:SaveData()
    MapManager.SaveData(self.cityId)
end
