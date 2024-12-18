---CityModule替代MapManager
-- region -------------引入模块-------------
CityDefine = require "Game/Logic/Model/City/CityDefine" -- 关卡的一些类型定义
CityCellType = CityDefine.CellType
CityCellGDType = CityDefine.CellGDType
CityCellStatus = CityDefine.CellStatus
CityFsmState = CityDefine.FsmState
CityPlayerAnim = CityDefine.PlayerAnim
CityBuildingStatus = CityDefine.BuildingStatus
CityBuildingType = CityDefine.BuildingType

CityPosition = require "Game/Logic/Model/City/sceneLogic/CityPosition"
CityChar = require "Game/Logic/Model/City/sceneLogic/CityChar"
-- CityPlayer = require "Game/Logic/Model/City/sceneLogic/CityPlayer"

CityMapCamera = require "Game/Logic/Model/City/sceneLogic/CityMapCamera"
local CityMapCtrl = require "Game/Logic/Model/City/sceneLogic/CityMapCtrl"
local CityMainCtrl = require "Game/Logic/Model/City/sceneLogic/CityMainCtrl"

require "Game/Logic/Model/City/sceneLogic/CityProductionUI"
require "Game/Logic/Model/City/sceneLogic/CityFoodUI"
require "Game/Logic/Model/City/sceneLogic/CityFoodCostUI"
require "Game/Logic/Model/City/sceneLogic/CityCharacterSlider"
require "Game/Logic/Model/City/sceneLogic/CityCharacterProgress"
require "Game/Logic/Model/City/sceneLogic/CityCharacterWarningUI"
require "Game/Logic/Model/City/sceneLogic/CityCharacterTips"

local json = require 'cjson'

-- region -------------私有变量-------------
local module = {}

local fn = {}

---@class CfgMapDatas 关卡地图数据
local CfgmapDatas = {}
local MapId = 1

---@class CityInfo 关卡数据
---@field position CityPosition 当前位置
local scene = nil ---@type CityScene
local mainCtrl = nil ---@type City.MainCtrl
local mapCtrl = nil ---@type City.MapCtrl

local isPreLoad = false

function module.init()

    -- module.initMapData()
end

---初始化关卡地图数据
function module.initMapData()
    ResInterface.LoadTextSync("MRMap_" .. MapId .. "Data" .. MapId,
                              function(str)
        local md = json.decode(str)

        CfgmapDatas[MapId] = md

        local cellTypeDict = {} -- 格子类型字典
        local mCells = md.cells

        for i = 1, #mCells, 3 do
            cellTypeDict[CityPosition.gHash(mCells[i], mCells[i + 1])] =
                mCells[i + 2]
        end

        local values = md.facilities
        for i = 1, #values, 8 do
            local fctId, fctType, fctdir = values[i + 2], values[i + 3],
                                           values[i + 4]
            local x, y = values[i], values[i + 1]
            local index = (i + 3) / 8
            local tbBuilding = TbSceneBuilding[fctId]
            -- tbBuilding.Name 

        end
    end, ".json")

end
---初始化Room地图数据
function module.initMapAllRoomData() end

-- 根据等级区域格子配置
function module.GetZoneGridsConfig(assetsName, zoneType)
    --    local configKey = string.format("zone_%s_%s", assetsName, zoneType)
    --    if not this.allConfig[configKey] then
    --       -- this.allConfig[configKey] = load(ResourceManager.Load("mapconfig/" .. configKey, TypeTextAsset).text)()
    --        this.allConfig[configKey] = require("Game/Config/" .. configKey)
    --    end
    --    return this.allConfig[configKey]
end
function module._initFC()
    CityCharUI.Init()

    DataManager.Init()
    PersistManager.Init()
    GridManager.Init()

    TestManager.Init()
    PostStationManager.Init() -- 必须放到所有可能添加reward奖励的Manager之前
    DailyShoutManager.Init()
    DailyBagManager.Init()
    TutorialManager.Init()
    MapManager.Init()
    DataManager.CheckCityId()

    FactoryGameData.Init() -- 独立的数据管理

    GameManager.LoadMode(ModeType.MainScene, nil)

end
---@param param City.CtrlParam
function module.openScene(mapid)
    mapid = mapid or 1

    local sceneName = SceneManager:Inst():GetCitySceneName(mapid)
    SceneManager:Inst():ChangeScene(sceneName, function(_scene)
        scene = _scene
        
        mainCtrl = CityMainCtrl.new(mapid)

        mapCtrl = CityMapCtrl.new(mapid)
        mapCtrl:init(function()
            CityModule._initFC()
            mainCtrl:init()
        end)
        if mapid >= 2 and isPreLoad == false then 
            isPreLoad = true
            ResInterface.PreloadAsset(nil, "UIShop.prefab", true)
            -- ResInterface.PreloadAsset(nil, "UIDataPreview.prefab", true)
        end
    end)
end

function module.SelectScene(mapid)
    mapid = mapid or 1
    DataManager.userData.global.cityId = mapid
    local sceneName = SceneManager:Inst():GetCitySceneName(mapid)
    SceneManager:Inst():ChangeScene(sceneName, function(_scene)
        scene = _scene

        HideUI(UINames.UIMap)
        if mainCtrl then
            mainCtrl:destroy()
            mainCtrl = nil
        end
        if mapCtrl then
            mapCtrl:destroy()
            mapCtrl = nil
        end
        mainCtrl = CityMainCtrl.new(mapid)
        -- mainCtrl:init()

        mapCtrl = CityMapCtrl.new(mapid)
        mapCtrl:init(function()
            CityModule._initFC()
            mainCtrl:init()
        end)
    end, "city")

end

function module.showCityUI()
    --    ShowUISync(UINames.UIStageMain)                --显示关卡主界面
    --    ShowUISync(UINames.UIMain, { isHome = false }) --显示主界面
end

function module.closeScene()
    if mainCtrl == nil then return end

    scene = nil

    mainCtrl:destroy()
    mapCtrl:destroy()

    mainCtrl = nil
    mapCtrl = nil
end

---切换状态机状态
---@param state CityState 状态
function module.switchCityState(state)
    mainCtrl.stateMachine:setState(state)
    mainCtrl.stateMachine:update()
end

function module.getScene() return scene end

function module.getMainCtrl() return mainCtrl end

function module.getMapCtrl() return mapCtrl end

function module.changeCityId(id)
    stageInfo.stageId = id
end

---获取角色的UI坐标
function module.getPlayerUiPos()
    if mainCtrl == nil then return end

    local pos = mainCtrl.player.transform.position
    return module.sceneToUiPos(pos)
end

---获取某个触发器的UI坐标
---@param x number Item的X坐标
---@param y number Item的X坐标
function module.getItemUiPos(x, y)
    if mainCtrl == nil then return end

    local pos = mapCtrl:getItem(x, y).transform.position
    return module.sceneToUiPos(pos)
end

function module.sceneToUiPos(pos)
    if mainCtrl == nil then return end

    return mainCtrl.camera:sceneToUiPos(pos)
end

---获取关卡数据信息
---@return CityInfo
function module.getCityInfo() return clone(stageInfo) end

---获取地图数据
function module.getMapData(mapId) return CfgmapDatas[mapId] end

---替代MapManager开始
-- 初始化地图管理器
function module.InitEx() MapManager.Init() end

function module.InitView() MapManager.InitView() end

function module.ClearView() MapManager.ClearView() end

function module.AfterAllInit() MapManager.AfterAllInit() end

-- 清除数据
function module.Clear(force) MapManager.Clear(force) end

function module.OnUpdate() end

function module.exitScene()
    if mainCtrl == nil then return end

    mapCtrl:destroy()
    mainCtrl:destroy()

    mapCtrl = nil
    mainCtrl = nil
    scene = nil
end

return module
