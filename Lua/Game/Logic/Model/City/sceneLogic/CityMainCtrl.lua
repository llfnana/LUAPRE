------------------------------------------------------------------------
--- @desc 关卡核心控制器
--- @author sakuya
------------------------------------------------------------------------
-- region -------------引入模块-------------
 local CityMonster = require "Game/Logic/Model/City/sceneLogic/CityMonster"
-- local FsmMachine = require "Logic/Fsm/FsmMachine"
local CityMapZoneBuild =
    require "Game/Logic/Model/City/sceneLogic/CityMapZoneBuild"
-- local CityState_None = require "Game/Logic/Model/City/sceneLogic/State/CityState_None"
-- local CityState_Idle = require "Game/Logic/Model/City/sceneLogic/State/CityState_Idle"
-- local CityState_PauseMove = require "Game/Logic/Model/City/sceneLogic/State/CityState_PauseMove"
-- local CityState_Move = require "Game/Logic/Model/City/sceneLogic/State/CityState_Move"
-- local CityState_Trigger = require "Game/Logic/Model/City/sceneLogic/State/CityState_Trigger"
-- local FsmMachine = require "Logic/Fsm/FsmMachine"
-- endregion


-- region -------------数据定义-------------

---@class City.CtrlParam
---@field isPreview boolean 是否预览模式
---@field stageId number 关卡配置id
---@field pathIdx number 路径索引

-- endregion

---@class City.MainCtrl 核心控制器
local Ctrl = class('CityMainCtrl')

---@param param City.CtrlParam
function Ctrl:ctor(mapid)
    mapid = mapid or 1
    self.camera = nil ---@type City.Camera
    self._cameraFollowPlayer = false

    self.pathIdx = 1 -- param.pathIdx

    self._diceRollNum = nil
    self.player = nil -- 玩家角色

    self.moveType = CityDefine.MoveType.Run

    self.mapid = mapid

    --self.mapbkres = string.format("mrmap_img_bg_%d.jpg", mapid)
    self.mapbkres = string.format("map_%dbg.jpg", mapid)
    self.zonePbs = string.format("layer_zone_map_%d", mapid)
    self.buildDict = {} -- 建筑字典 
    self.buildNightMask = {} -- 夜间建筑遮罩

    self:onCtor()
end

---构造方法时
function Ctrl:onCtor()
    -- 初始化相机
    local _cameraGo = GameObject.Find("CityCamera")
    self.camera = CityMapCamera.new()
    self.camera:bind(_cameraGo)
end

---初始化
function Ctrl:init()
    local mapTr = GameObject.Find("Map").transform
    self._rootMap = mapTr
    self._rootCells = mapTr:Find("Cells")
    self._rootBuildings = mapTr:Find("Buildings")
    self._rootChars = mapTr:Find("Chars")
    self._rootMapUI = mapTr:Find("MapUI")
    -- if self.mapid == 1 then
    --     -- body
    --     self._rootChars.transform.position = Vector3.New(0.54, -0.21, 0)
    -- elseif self.mapid == 2 then
        -- body    
        -- self._rootChars.transform.position = Vector3.New(1.11, -0.42, 0)
    -- elseif self.mapid == 3 then
    --     -- body    
    --     self._rootChars.transform.position = Vector3.New(0.54, -0.21, 0)
    -- end

    self:_initSceneResEx()
    self:initEvent() -- 事件注册

    --场景帧数初始化
    self.CheckQuality = function ()
        
    end
    EventManager.AddListener(EventDefine.QualityChange, self.CheckQuality)
    self:CheckQuality()

    ShowUI(UINames.UIMain)

    --self:_initPlayer() --创建角色
    --self:_initNpc() --创建NPC
    --音乐音效添加
    -- Audio.PlayAudio(DefaultAudioID.BaiTianScene)
    -- Audio.PlayAudio(DefaultAudioID.YeWanScene)
end

function Ctrl:_initPlayer()
    -- 创建玩家角色
    -- Debug.Log("MainCtrl 创建角色：" + PathIdx)
        local data ={}
    data.id ="IDGenerator1"
    data.res_id = 60009
    local curPos = { x=89, y=55 }
    local xd =10
    local yd = 10
    local x = 143+3
    local y = 134
    local characterController = CharacterController.new(data)
    ResInterface.SyncLoadGameObject('CityChar', function (obj)
        local playerGo = GOInstantiate(obj, self._rootChars)
        local mapCtrl = CityModule.getMapCtrl()
        local initCell =mapCtrl:getCellByXY(x,y)
        characterController:bind(playerGo,data.res_id)  --暂时在这里设置小人spine 资源id =0
        characterController:SetAnim(AnimationType.Idle)
        characterController:playAnim("idle",1) --朝下
        characterController:setSortingOrder(1010)       
        characterController:setCell(initCell)
         characterController.gameObject.name ="IDGenerator1"
    end)

    data.id ="IDCapentry2"
    data.res_id = 60009

     xd =11
     yd = 12
     x = 126+3
     y = 109
    local characterController2 = CharacterController.new(data)
    ResInterface.SyncLoadGameObject('CityChar', function (obj)
        local playerGo = GOInstantiate(obj, self._rootChars)
        local mapCtrl = CityModule.getMapCtrl()
        local initCell =mapCtrl:getCellByXY(x,y)
        characterController2:bind(playerGo,data.res_id)  --暂时在这里设置小人spine 资源id =0
        characterController2:SetAnim(AnimationType.Idle)
        characterController2:playAnim("idle",2) --朝下
        characterController2:setSortingOrder(1010)       
        characterController2:setCell(initCell)
        characterController2.gameObject.name ="IDCapentry2"
    end)


    data.id ="IDSawmill3"
    data.res_id = 60009

    xd =12
    yd = 13
     x = 164+3
     y = 104
    local characterController3 = CharacterController.new(data)
    ResInterface.SyncLoadGameObject('CityChar', function (obj)
        local playerGo = GOInstantiate(obj, self._rootChars)
        local mapCtrl = CityModule.getMapCtrl()
        local initCell =mapCtrl:getCellByXY(x,y)
        characterController3:bind(playerGo,data.res_id)  --暂时在这里设置小人spine 资源id =0
        characterController3:SetAnim(AnimationType.Idle)
        characterController3:playAnim("idle",3) --朝下
        characterController3:setSortingOrder(1010)       
        characterController3:setCell(initCell)
        characterController3.gameObject.name ="IDSawmill3"
    end)

    data.id ="IDDoom1-4"
    data.res_id = 60009
     x =176+3
     y = 136

    local characterController4 = CharacterController.new(data)
    ResInterface.SyncLoadGameObject('CityChar', function (obj)
        local playerGo = GOInstantiate(obj, self._rootChars)
        local mapCtrl = CityModule.getMapCtrl()
        local initCell =mapCtrl:getCellByXY(x,y)
        characterController4:bind(playerGo,data.res_id)  --暂时在这里设置小人spine 资源id =0
        characterController4:SetAnim(AnimationType.Idle)
        characterController4:playAnim("idle",4) --朝下
        characterController4:setSortingOrder(1010)       
        characterController4:setCell(initCell)
        characterController4.gameObject.name ="IDDoom1"
    end)

        data.id ="IDKitchen1"
    data.res_id = 60009
     x =134+3
     y = 166

    local characterController5 = CharacterController.new(data)
    ResInterface.SyncLoadGameObject('CityChar', function (obj)
        local playerGo = GOInstantiate(obj, self._rootChars)
        local mapCtrl = CityModule.getMapCtrl()
        local initCell =mapCtrl:getCellByXY(x,y)
        characterController5:bind(playerGo,data.res_id)  --暂时在这里设置小人spine 资源id =0
        characterController5:SetAnim(AnimationType.Idle)
        characterController5:playAnim("idle",0) --朝下
        characterController5:setSortingOrder(1010)       
        characterController5:setCell(initCell)
        characterController5.gameObject.name ="IDKitchen1"
    end)

   -- self.player = characterController
end


function Ctrl:_initNpc()
    local data ={}
    data.id =2000
    data.res_id = 0
    local npc = CityChar.new(data)
    ResInterface.SyncLoadGameObject('CityChar', function (obj)
        local npcGo = GOInstantiate(obj, self._rootChars)
        --设置位置
        local mapCtrl = CityModule.getMapCtrl()
        local NpcPos = { x=89, y=55 }--{ x=0, y=0 } 
        local pos =NpcPos-- CityDefine.NpcPos
        local initCell = mapCtrl:getCellByXY(pos.x, pos.y)
        npcGo.name = string.format("NPC_%s_%s", pos.x, pos.y)
        npc:bind(npcGo,data.res_id)
        npc:setSortingOrder(10)    
        npc:setCell(initCell)

        npc:playAnim(CityPlayerAnim.Idle, CityPosition.Dir.Left) --朝左
    end)

   -- self.Npc = npc
end
---刷新主角身上的buff状态
function Ctrl:refreshPlayerBuff()
    local bkbCnt = CityModule.getCityInfo().bkbRound
    if CityModule.getCityInfo().bkbRound > 0 then
        self.player:immune()
    else
        self.player:removeImmune()
    end
end

---检查关卡是否触发触发器中
function Ctrl:checkCityTrigging()
    if CityModule.getCityInfo().banStep then
        self.player.cell:execute(2, self.player:isImmune())
    end
end

function Ctrl:initCityFsm()
    self.stateMachine = FsmMachine.new()
    self.stateMachine:addState(CityState.None, CityState_None)
    self.stateMachine:addState(CityState.Idle, CityState_Idle)
    self.stateMachine:addState(CityState.Move, CityState_Move)
    self.stateMachine:addState(CityState.PauseMove, CityState_PauseMove)
    self.stateMachine:addState(CityState.Trigger, CityState_Trigger)
    CityModule.switchCityState(CityState.Idle)
end

function Ctrl:initEvent()
    self.eventList = {}
    self:eventOnSelf(EventDefine.OnClickCityBuild, self.onClickCityBuild)
    self:eventOnSelf(EventDefine.OnClickExitCityBuild, self.onClickExitCityBuild)

    self:eventOnSelf(EventDefine.onSelectZone, self.onSelectZone)
    
    
    -- if PlayerModule.getSdkPlatform() == "wx" and  Core.Instance.IsIOSPlatform and Core.Instance.IsPhoneLow then 
        self:eventOnSelf(EventDefine.OnNightChange, self.UpdateNightMask)
        self:eventOnSelf(EventType.UPGRADE_ZONE, self.UpdateBuildCompleteNightMask)
    -- end

   -- UpdateBeat:Add(self.update, self)
end

-- 建筑缩放
function Ctrl:onSelectZone(zoneId)
    local build = self.buildDict[zoneId].gameObject
    local floor = build.transform:Find("Outside/floor")
    self.buildDict[zoneId]:ShowOrnaments()
    self.camera:zoomTo(floor, 2.5)
end

function Ctrl:ShowBuildViewNoAction(data)
    -- 城市ID
    local cityId = DataManager.GetCityId()
    local characterNum = CharacterManager.GetCharacterCount(cityId)
    -- 区域ID
    local zoneId = data.zoneId-- ConfigManager.GetZoneIdByZoneType(cityId, data.type)
    -- 区域数据
    local mapItemData = MapManager.GetMapItemData(cityId, zoneId)
    local build = self.buildDict[zoneId].gameObject
    local floor = build.transform:Find("Outside/floor")
    
    self.buildDict[zoneId]:ShowOrnaments()
    if not mapItemData:IsUnlock() then
        self.camera:zoomTo(floor, 1.2, 1.2, true)
        ShowUI(UINames.UIBuildUnlock, {zoneId = zoneId, from = "scene"})
        local status = mapItemData:GetBuildStatus()
        if status ~= "Building" then
            self.buildDict[zoneId]:SetBuildPreShadow(true)
        end
        self.buildDict[zoneId]:SetBuildCursor(false)
        return
    end
    if data.type == ZoneType.Generator then
        self.camera:zoomTo(floor, 1.3, 0, true)
        if mapItemData:IsUpgrading() then
            ShowUI(UINames.UIBuildGenerator)
            ShowUI(UINames.UIBuildGeneratorUpgrade)
        else
            ShowUI(UINames.UIBuildGenerator)
        end
    else
        self.camera:zoomTo(floor, 2.5, 1.2, true)
        ShowUI(UINames.UIBuild, {zoneType = data.type, zoneId = zoneId, noAction = true})
    end
end

function Ctrl:ShowBuildView(data, from, extented)
    CityModule.getMainCtrl().camera.roofActiveDirtyFlag = nil
    -- 城市ID
    local cityId = DataManager.GetCityId()
    local characterNum = CharacterManager.GetCharacterCount(cityId)
    -- 区域ID
    local zoneId = data.zoneId-- ConfigManager.GetZoneIdByZoneType(cityId, data.type)
    -- 区域数据
    local mapItemData = MapManager.GetMapItemData(cityId, zoneId)

    local build = self.buildDict[zoneId].gameObject
    local floor = build.transform:Find("Outside/floor")
    
    self.buildDict[zoneId]:ShowOrnaments()
    if not mapItemData:IsUnlock() then
        self.camera:zoomTo(floor, 1.2, 1.2)
        ShowUI(UINames.UIBuildUnlock, {zoneId = zoneId, from = from or "scene", extented = extented})
        local status = mapItemData:GetBuildStatus()
        if status ~= "Building" then
            self.buildDict[zoneId]:SetBuildPreShadow(true)
        end
        self.buildDict[zoneId]:SetBuildCursor(false)
        return
    end
    self:PlayBuildAudio(data.type)
    mapItemData:DisableShowUpgradeComplete()
    mapItemData:SetHasClick(true)
    self.buildDict[zoneId]:refreshTitleUI()
    if data.type == ZoneType.Generator then
        self.camera:zoomTo(floor, 1.3)
        if mapItemData:IsUpgrading() then
            ShowUI(UINames["UIBuild" .. ZoneType.Generator])
            ShowUI(UINames.UIBuildGeneratorUpgrade)
        else
            ShowUI(UINames["UIBuild" .. ZoneType.Generator])
        end
    else
        self.camera:zoomTo(floor, 2.2, 1.2)
        ShowUI(UINames.UIBuild, {zoneType = data.type, zoneId = zoneId, from = from or "scene", extented = extented})
    end
end

---点击建筑事件
function Ctrl:onClickCityBuild(data)
    self:ShowBuildView(data)
end

function Ctrl:onClickExitCityBuild()
    for key, value in pairs(self.buildDict) do
        value:HideOrnaments()
    end
    self.camera:zoomRecover()
end

-- 初始化建筑
function Ctrl:initBuffBuilding()
    local buffBuildings = CityModule.getMapCtrl():getItemsByType(
                              CityItemType.BuffBuilding)
    local stageInfo = CityModule.getCityInfo()
    local buffList = {}
    for k, item in ipairs(buffBuildings) do
        local posx, posy = item.position.x, item.position.y
        local buildInfo = CityModule.getBuffBuildingInfos(posx, posy)
        -- 没有building信息就创建一个，防止报错
        if buildInfo == nil then
            buildInfo = {id = 999, level = 0, x = posx, y = posy}
            CityModule.addBuffBuildingInfo(posx, posy, buildInfo)
        end

        self:updateBuildingByXy(posx, posy, buildInfo.level)

        local curCityId = CityModule.getCityId()
        local buildType = CityModule.getBuffBuildingType(curCityId, posx, posy)
        local buildCfg = CityModule.getBuildingCfgById(buildType)
        local buildBuffId = buildCfg.BuffID
        local param = buildCfg.Contents[buildInfo.level] or 0
        if buffList[buildBuffId] then
            buffList[buildBuffId].level =
                buffList[buildBuffId].level + buildInfo.level
            buffList[buildBuffId].param = buffList[buildBuffId].param + param
        else
            buffList[buildBuffId] = {}
            buffList[buildBuffId].level = buildInfo.level
            buffList[buildBuffId].param = param
            buffList[buildBuffId].buffId = buildBuffId
        end
    end

    for k, v in pairs(buffList) do
        if v.level ~= 0 then
            self:upBuildBuff(v.buffId, v.param, 1, v.level)
        end
    end
end
-- 升级建筑
function Ctrl:upgradeBuilding(x, y)
    CityModule.setBuffBuildingLevel(x, y, CityModule.getBuffBuildingInfos(x, y)
                                        .level + 1)
    local buffId = CityModule.getBuildingBuffId(CityModule.getCityId(), x, y)
    BuffModule.addValue(buffId, 1) -- 全局Buff模块数据更新
    local buffBuilding = CityModule.getMapCtrl():getItem(x, y)
    buffBuilding:upgradeBuilding()
    Event.Brocast(EventDefine.OnCityBuffBuildingUpgrade, x, y) -- 通知一下升级了建筑

    local param = CityModule.getTotalBuffParamByBuffId(buffId)
    self:upBuildBuff(buffId, param, 1, 1)
end
-- 刷新建筑显示
function Ctrl:updateBuildingByXy(x, y)
    CityModule.getMapCtrl():getItem(x, y):refreshBuildingStyle()
end
function Ctrl:upBuildBuff(buffId, param, rounds, level)
    local buff = BuffManager:Inst():CreateBuff(buffId, param, rounds)
    Event.Brocast(EventDefine.OnCityBuffChange, buff, level)
end

---触发器结束
function Ctrl:TriggerCompleted()
    -- local state = self.player:getMoveNum() > 0 and CityState.Move or CityState.Idle
    CityModule.switchCityState(CityState.Move)
end

---检查当前的地图游玩状态
function Ctrl:initCityCtrlState()
    -- 检查是否岔路中
    local state
    local isFork = CityModule.getMapCtrl():checkIsFork(self.player.cell,
                                                       self.player._curDir)
    local leftMove = self.player:getMoveNum()
    if isFork and leftMove > 0 then
        state = CityState.Fork
    else
        state = CityState.Idle
    end
    return self.stageCtrlState
end

---初始化场景资源
function Ctrl:_initSceneRes()
    local stageId = self.mapid
    local tbCity = TbCity[stageId]

    local backPTr = GameObject.Find("SR_Back").transform
    local frontTr = GameObject.Find("SR_Front").transform
    local speedIdx = 1

    local addSceneSr = function(res, parent)
        local _srGo = GameObject(res)
        _srGo.transform:SetParent(parent)
        -- 临时设置背景缩放
        _srGo.transform.localScale = Vector3(1, 1, 1)
        local _sr = _srGo:AddComponent(typeof(SpriteRenderer))
        -- local sortingOrder = speedIdx
        local _speedIdx = speedIdx
        local speed = tbCity.MvSpeed[speedIdx]

        if StringUtil.isEmpty(res) then return end

        ResInterface.SyncLoadSprite(res, function(_sprite)
            _sr.sprite = _sprite
            -- _sr.sortingOrder = sortingOrder --层级
            self.camera:addSceneSr(_sr, speed, _speedIdx == 1)
        end)

        speedIdx = speedIdx + 1

        return _sr
    end

    -- 加载背景资源
    for _, v in ipairs(tbCity.ResBack) do
        local _sr = addSceneSr(v .. ".png", backPTr)
        _sr.sortingOrder = speedIdx
    end
    -- 加载背景特效
    for i, v in ipairs(tbCity.ResBackEf) do
        local sortingOrder = speedIdx + i

        ResInterface.SyncLoadGameObject(v, function(obj)
            local efGo = GOInstantiate(obj, backPTr)
            Util.SetRendererLayer(efGo, nil, sortingOrder)
        end)
    end
    -- 加载前景资源
    if tbCity.ResFront ~= nil then
        local _sr = addSceneSr(tbCity.ResFront .. ".png", frontTr)
        if _sr ~= nil then
            _sr.sortingLayerName = "Building" -- 建筑层
            _sr.sortingOrder = speedIdx + 1000 -- 1000往上，在最前面
        end
    end
end


---初始化场景资源
function Ctrl:_initSceneResEx()

    local stageId = self.mapid
    -- local tbCity = TbCity[stageId]

    local backPTr = GameObject.Find("SR_Back").transform
    local frontTr = GameObject.Find("SR_Front").transform
    local map = GameObject.Find("Map").transform

    local speedIdx = 1
    local addSceneSr = function(res, parent)
        local _srGo = GameObject(res)
        _srGo.transform:SetParent(parent)
        -- 临时设置背景缩放
        _srGo.transform.localScale = Vector3(1, 1, 1)
        local _sr = _srGo:AddComponent(typeof(SpriteRenderer))
        -- local sortingOrder = speedIdx
        local _speedIdx = speedIdx
        local speed = 1 -- tbCity.MvSpeed[speedIdx]

        if StringUtil.isEmpty(res) then return end

        ResInterface.SyncLoadSprite(res, function(_sprite)
            _sr.sprite = _sprite
            -- _sr.sortingOrder = sortingOrder --层级
            self.camera:addSceneSr(_sr, speed, _speedIdx == 1)
        end)

        speedIdx = speedIdx + 1

        return _sr
    end

    self.camera:setBgEdge(CityDefine["Map" .. self.mapid .. "EdgeSize"])
    -- 加载背景资源

    -- local _sr = addSceneSr(self.mapbkres, backPTr)
    -- -- local _sr = addSceneSr("img_1_1a.png", backPTr)
    -- _sr.sortingOrder = speedIdx

    -- 加载zone区域建筑地图
    self.zonePrefabs = nil
    self.zonePrefabs = map.transform:Find(self.zonePbs)
    -- Util.SetRendererLayer(zonePrefabs, nil, sortingOrder)

    self:bindAllZoneObj(self.zonePrefabs.transform)
    self:bindFactoryGame(self.zonePrefabs.transform)
    self:InitView()
    --             --Generator
    --        local generatorPrb =zonePrefabs.transform:Find("Generator")

    --        if generatorPrb then

    --            local data ={}
    --            data.tid =GridMarker.Generator
    --            local _trg = CityMapZoneBuild.new(data)
    --            _trg:bind(generatorPrb.gameObject)
    --            _trg:init()
    --        end

    -- 初始化夜间遮罩
    self:InitNightMask()
end

function Ctrl:InitNightMask(trans)
    self:UpdateBuildNightMask()
    self:UpdateNightMask()
end

-- 更新建筑的夜晚遮罩，那建造建筑才有灯光
function Ctrl:UpdateBuildNightMask() 
    local cityId = DataManager.GetCityId()
    local mapItems = MapManager.GetMap(cityId)
    for key, value in pairs(self.buildNightMask) do
        local mapItemData = mapItems.mapItemDataList[value.zoneId]
        if mapItemData then
            if mapItemData:GetLevel() > 0 then 
                if value.gameObject then 
                    value.gameObject:SetActive(true)
                end
            end
        end
    end
end
 -- 建筑建造完成，打开夜间灯光
function Ctrl:UpdateBuildCompleteNightMask(cityId, zoneId, zone_type, level)
    if self.mapid ~= cityId then 
        return 
    end

    for key, value in pairs(self.buildNightMask) do
        if value.zoneId == zoneId then 
            if value.gameObject then 
                value.gameObject:SetActive(true)
            end
        end
    end
end

-- 夜间特效
function Ctrl:UpdateNightMask() 
    if self.nightGO then 
        local cityClock = TimeManager.GetClock(self.mapid)
        self.nightGO:SetActive(cityClock.isNight)
    end
end

function Ctrl:bindFactoryGame(obj)
    local click = obj:Find("FactoryGame/FactoryGamePanelEntity")
    if click ~= nil then
        local isBuildComplete = FactoryGameData.IsBuildComplete()
        local click = obj:Find("FactoryGame/FactoryGamePanelEntity")
        local floor = click:Find("floor")
        local BuildCursor = click:Find("BuildCursor")
        local cityId = DataManager.GetCityId()
        local zoneLevel = FactoryGameData.IsGeneratorTwoLevel()
        BuildCursor.gameObject:SetActive(zoneLevel >= 2 and not isBuildComplete)
        floor.gameObject:SetActive(isBuildComplete)
        -- BuildCursor.gameObject:SetActive(not isBuildComplete)
        Util.SetEvent(click.gameObject, function()
            local isBuildComplete = FactoryGameData.IsBuildComplete()
            local zoneLevel = FactoryGameData.IsGeneratorTwoLevel()
            if isBuildComplete then
                FactoryGameModule.c2s_getInfo(cityId, function ()
                    ShowUI(UINames.UIFactoryGame)
                end)
            else
                if zoneLevel >= 2 then
                    self.camera:zoomTo(floor, 1, 1, true)
                    CityModule.getMainCtrl():ShowBuildFactoryGame()
                end
                
            end
        end,"onClick")
    end
end

-- 挂接所有Zone区域建筑对象
function Ctrl:bindAllZoneObj(obj)
    local nightTrans = obj:Find("mapnewbk/Night")
    local cloneItem = obj:Find("mapnewbk/Night/CloneItem")
    self.nightGO = nightTrans.gameObject

    local addBindObj = function(obj, data)
        local _trg = CityMapZoneBuild.new(data)
        _trg:bind(obj)
        _trg:init()
        self.buildDict[data.zoneId] = _trg
        self.buildNightMask[data.name] = {type = data.type, zoneId = data.zoneId, gameObject = self:CreateNightLigthMask(nightTrans, cloneItem, obj.transform)}
    end

    local cityId = DataManager.GetCityId()
    local mapItems = MapManager.GetMap(cityId)
    
    -- Generator
    local data = {}
    local zonePrb = obj:Find("Generator/GeneratorEntity")
    if zonePrb then
        data.name = "Generator"
        data.type = ZoneType.Generator
        data.zoneId = "C".. cityId.. "_".. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end

    zonePrb = obj:Find("Carpentry/CarpentryEntity")
    if zonePrb then
        data.name = "Carpentry"
        data.type = ZoneType.Carpentry
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Carpentry2/CarpentryEntity")
    if zonePrb then
        data.name = "Carpentry2"
        data.type = "Carpentry2"
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end

    zonePrb = obj:Find("Dorm/DormEntity")
    if zonePrb then
        data.name = "Dorm"
        data.type = ZoneType.Dorm
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Dorm2/DormEntity")
    if zonePrb then
        data.name = "Dorm2"
        data.type = ZoneType.Dorm
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_2"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Dorm3/DormEntity")
    if zonePrb then
        data.name = "Dorm3"
        data.type = ZoneType.Dorm
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_3"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Dorm4/DormEntity")
    if zonePrb then
        data.name = "Dorm4"
        data.type = ZoneType.Dorm
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_4"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Dorm5/DormEntity")
    if zonePrb then
        data.name = "Dorm5"
        data.type = ZoneType.Dorm
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_5"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Dorm6/DormEntity")
    if zonePrb then
        data.name = "Dorm6"
        data.type = ZoneType.Dorm
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_6"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Dorm7/DormEntity")
    if zonePrb then
        data.name = "Dorm7"
        data.type = ZoneType.Dorm
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_7"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Dorm8/DormEntity")
    if zonePrb then
        data.name = "Dorm8"
        data.type = ZoneType.Dorm
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_8"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Dorm9/DormEntity")
    if zonePrb then
        data.name = "Dorm9"
        data.type = ZoneType.Dorm
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_9"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Dorm10/DormEntity")
    if zonePrb then
        data.name = "Dorm10"
        data.type = ZoneType.Dorm
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_10"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Dorm11/DormEntity")
    if zonePrb then
        data.name = "Dorm11"
        data.type = ZoneType.Dorm
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_11"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Dorm12/DormEntity")
    if zonePrb then
        data.name = "Dorm12"
        data.type = ZoneType.Dorm
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_12"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Dorm13/DormEntity")
    if zonePrb then
        data.name = "Dorm13"
        data.type = ZoneType.Dorm
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_13"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Dorm14/DormEntity")
    if zonePrb then
        data.name = "Dorm14"
        data.type = ZoneType.Dorm
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_14"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end

    zonePrb = obj:Find("Kitchen/KitchenEntity")
    if zonePrb then
        data.name = "Kitchen"
        data.type = ZoneType.Kitchen
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end

    zonePrb = obj:Find("Sawmill/SawmillEntity")
    if zonePrb then
        data.name = "Sawmill"
        data.type = ZoneType.Sawmill
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end

    zonePrb = obj:Find("HunterCabin/HunterCabinEntity")
    if zonePrb then
        data.name = "HunterCabin"
        data.type = ZoneType.HunterCabin
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end

    zonePrb = obj:Find("Metal/MetalEntity")
    if zonePrb then
        data.name = "Metal"
        data.type = "Metal"
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Metal2/MetalEntity")
    if zonePrb then
        data.name = "Metal2"
        data.type = "Metal2"
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("CoalMine/CoalMineEntity")
    if zonePrb then
        data.name = "CoalMine"
        data.type = ZoneType.CoalMine
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end

    zonePrb = obj:Find("Infirmary/InfirmaryEntity")
    if zonePrb then
        data.name = "Infirmary"
        data.type = ZoneType.Infirmary
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end

    zonePrb = obj:Find("CollectionStation/CollectionStationEntity")
    if zonePrb then
        data.name = "CollectionStation"
        data.type = "CollectionStation"
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Watchtower/WatchtowerEntity")
    if zonePrb then
        data.name = "Watchtower"
        data.type = "Watchtower"
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("MachineryFactory/MachineryFactoryEntity")
    if zonePrb then
        data.name = "MachineryFactory"
        data.type = "MachineryFactory"
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("IronMine/IronMineEntity")
    if zonePrb then
        data.name = "IronMine"
        data.type = "IronMine"
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
----
    zonePrb = obj:Find("CopperMine/CopperMineEntity")
    if zonePrb then
        data.name = "CopperMine"
        data.type = "CopperMine"
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Greenhouse/GreenhouseEntity")
    if zonePrb then
        data.name = "Greenhouse"
        data.type = "Greenhouse"
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Greenhouse2/Greenhouse2Entity")
    if zonePrb then
        data.name = "Greenhouse2"
        data.type = "Greenhouse2"
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("MachineryFactory2/MachineryFactoryEntity")
    if zonePrb then
        data.name = "MachineryFactory2"
        data.type = "MachineryFactory2"
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
----
    zonePrb = obj:Find("Laboratory/LaboratoryEntity")
    if zonePrb then
        data.name = "Laboratory"
        data.type = "Laboratory"
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("FoodFactory/FoodFactoryEntity")
    if zonePrb then
        data.name = "FoodFactory"
        data.type = "FoodFactory"
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("OilWell/OilWellEntity")
    if zonePrb then
        data.name = "OilWell"
        data.type = "OilWell"
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end
    zonePrb = obj:Find("Laboratory2/LaboratoryEntity")
    if zonePrb then
        data.name = "Laboratory2"
        data.type = "Laboratory2"
        data.zoneId = "C".. cityId.. "_" .. data.type .. "_1"
        if mapItems.mapItemDataList[data.zoneId] then
            addBindObj(zonePrb.gameObject, clone(data))
        end
    end

    self:RefreshBuildingActive()
end

---  创建夜晚灯光
function Ctrl:CreateNightLigthMask(nightTrans, cloneItem, target)
    local item = GOInstantiate(cloneItem, nightTrans)
    item.name = target.parent.name
    item.transform:SetSiblingIndex(target:GetSiblingIndex() + 1)
    item.transform.localPosition = target.localPosition
    return item
end

---通过unity localPosition获得地图上的排序层级
function Ctrl:GetSortingByPosition(x, y)
    local function rotatePoint(x, y, angle)
        local angleRad = math.rad(angle)
        local cosAngle = math.cos(angleRad)
        local sinAngle = math.sin(angleRad)
    
        local newX = x * cosAngle - y * sinAngle
        local newY = x * sinAngle + y * cosAngle
    
        return newX, newY
    end

    local baseSortValue = 40
    local addLogicValue = 10
    local logicX = x + addLogicValue
    local logicY = y + addLogicValue
    local rotateX, rotateY = rotatePoint(logicX, logicY, 45)

    local sortValue = (rotateX - rotateY) * baseSortValue + 5000

    -- local floor = self.transform:Find("Outside/floor")
    -- floor:GetComponent(typeof(SpriteRenderer)).sortingOrder = self.sortValue
    
    return sortValue
end

function Ctrl:RefreshBuildingActive()
    local cityId = DataManager.GetCityId()
    local mapItems = MapManager.GetMap(cityId)
     
    for k, build in pairs(self.buildDict) do
        build:UpdateBuildIcon()
    end
end


function Ctrl:upgradeBuilding(cityId, zoneId)
    
end

function Ctrl:InitView()
    if self.buildDict ~= nil then
        for k, v in pairs(self.buildDict) do
            v:InitView()
        end
    end

    FoodSystemManager.InitView()
end

---（虚）update更新方法
function Ctrl:update()
    --    if self._cameraFollowPlayer then
    --        self:cameraFocusPlayer()
    --    end
    -- GameManager.Update()
end

function Ctrl:eventOnSelf(key, callback)
    local function func(...) callback(self, ...) end
    EventManager.AddListener(key, func)
    table.insert(self.eventList, {event = key, handler = func})
end

-- 移动回合结束！
function Ctrl:EndRound()
    -- 检查座驾
    self:checkCarRound()
    self:checkImmuneRound()
    CityModule.switchCityState(CityState.Idle)
end

function Ctrl:setCar(carId) CityModule.setCar(carId) end

function Ctrl:playerMove()
    local num = self._diceRollNum

    local mapCtrl = CityModule.getMapCtrl()
    -- 角色移动，并执行触发器等逻辑
    self.player:insertMoveNum(num)
    -- local curCell = self.player.cell
    -- local curDir = self.player._curDir
    -- -- 获取相邻的非负方向（相对于人物方向）格子
    -- local pathingList = mapCtrl:getPathingListByXy(curCell.position.x, curCell.position.y, curDir)

    self.moveType = CityModule.isCar() and CityDefine.MoveType.Car or
                        CityDefine.MoveType.Run
    self.isPlayingDice = false
    CityModule.switchCityState(CityState.Move)
end

---@param cell City.MapCell
function Ctrl:playerMoveEx(cell)
    local mapCtrl = HomeModule.getMapCtrl()
    local path = mapCtrl:findPath(self.player.cell, cell)
    if path == nil then
        --UIUtil.showText('无法到达目标点')
        return
    end

    self.player:move(path) --移动
end

function Ctrl:cameraFocusPlayer() self:cameraFocusTarget(self.player) end

function Ctrl:cameraFocusTarget(target)
    local pos = target.transform.position
    if pos then self.camera:setPosition(pos.x, pos.y, true) end
end

function Ctrl:cameraMoveToTarget(target)
    self:cameraSetFollow(false)
    local pos = target.transform.position
    if pos then
        self.camera:moveToPosition(pos.x, pos.y, function()
            -- 暂空
        end)
    end
end

function Ctrl:PlayBuildAudio(type)
    if not GeneratorManager.GetIsEnable(DataManager.GetCityId()) and type == "Generator" then
        return
    end
    Audio.PlayAudio(ClickBuildAudio[type])
end

function Ctrl:cameraSetFollow(isFollow)
    self._cameraFollowPlayer = isFollow
    local isMuteDrag = isFollow
    self.camera:setDragMute(isMuteDrag)

    if isFollow then self:cameraFocusPlayer() end
end

function Ctrl:RemoveEvent()
    EventManager.RemoveListener(EventDefine.QualityChange, self.CheckQuality)
    if self.eventList == nil then return end
    for _, v in ipairs(self.eventList) do
        Event.RemoveListener(v.event, v.handler)
    end
end

function Ctrl:destroy()
    for k, v in pairs(self.buildDict) do
        v:destroy()
    end
    self:RemoveEvent()
    --UpdateBeat:Remove(self.update, self)
    self.camera:unBind()
end

-- 显示建造工厂游戏机
function Ctrl:ShowBuildFactoryGame()
    ShowUI(UINames.UIBuildFactoryGame)
end

return Ctrl
