------------------------------------------------------------------------
--- @desc 关卡核心控制器

--region -------------引入模块-------------
local CityPosition = require "Game/Logic/Model/City/sceneLogic/CityPosition"
local json = require 'cjson'
local AStarPath2dFinder = require "Game/Logic/Path/AStarPath2dFinder"
local CityMapCell = require "Game/Logic/Model/City/sceneLogic/CityMapCell"
local Pool = require "Logic/Pool/Pool"
local LuaEvent = require "Logic/LuaEvent"
--endregion

--region -------------数据定义-------------
--local OffsetX = 236 / 200 / 9 --格子X的偏移
--local OffsetY = 107.141758 / 200 / 9 --格子Y的偏移
local CellSpace = 0 --格子间距
local MapHeight = 900 --地图高度（TODO 根据地图的高度生成）
--endregion

local OffsetX = CityDefine.MapCellSize[1] / 2 --格子X的偏移
local OffsetY = CityDefine.MapCellSize[2] / 2 --格子Y的偏移

---@class City.MapCtrl 地图控制器
local Ctrl = class('CityMapCtrl')

function Ctrl:ctor(param)
    self.gameObject = nil
    self.transform = nil
    self._rootBlocks = nil
    self._rootCells = nil
    self._rootBuildings = nil

    ---@type table<number, City.MapCell>   -- 格子字典
    self._cellDict = {}
    ---@type table<number, City.MapItem>   -- Item字典
    self._itemDict = {}

        ---@type table<number, Home.MapCellObj>
    self._cellObjDict = {}
    self._cellObjPool = nil ---@type Pool

    self.cellShowEvt = nil ---@type LuaEvent 地图格子可见事件
    self.cellHideEvt = nil ---@type LuaEvent 地图格子不可见事件

    ---@type Home.MapCell[] 建造预览格子
    self._buildingPreviewCells = {}

    self._pathFinder = nil ---@type AStar.PathFinder 寻路

    self._mapData = nil ---@type MapData

    self.mapId = param

    self:onCtor()
end

---构造方法时
function Ctrl:onCtor() end

---初始化
function Ctrl:init(cbInitFun)
    self.gameObject = GameObject.Find("Map")
    self.transform = self.gameObject.transform

    local backTr = GameObject.Find("SR_Back").transform

    self._rootBlocks = backTr:Find("Blocks")
    self._rootCells = self.transform:Find("Cells")
    self._rootBuildings = self.transform:Find("Buildings")

    self.cellShowEvt = LuaEvent.new()
    self.cellHideEvt = LuaEvent.new()

    self._pathFinder = AStarPath2dFinder.new(self)

    self._LoadroomCount = 0 --室外大建筑个数
    self._asyncLoadCount = 0 --异步加载完成个数
    self.initFuncCallback = function()
        self._asyncLoadCount = self._asyncLoadCount + 1
        if self._asyncLoadCount == self._LoadroomCount+1 then 
            if cbInitFun then
                cbInitFun()
            end
        end
    end

   -- self:_initMapCnf() ---移到加载大地图数据后处理小地图

     local mapdatafile = string.format("MRMap_%dData",DataManager.userData.global.cityId)
     ResInterface.LoadTextSync(mapdatafile, function (str)
        self._mapData = json.decode(str)
        self:_initMap()
        --设置背景偏移
        local offset = self._mapData.mapOffset
        backTr.position = Vector3.New(offset.x, offset.y)
        --self.initFuncCallback() --暂时移到_initMap后面处理
    end, ".json")
end


function Ctrl:_initMap(mapData)
--    self:_initGrounds(mapData)
--    self:_initItems(mapData) 
    --地图格子
    --local grids = self._mapData.grids
    --for i=1, #grids, 2 do
    --    self:_createCell(grids[i], grids[i+1])
    --end

    local cellTypeDict = {} --格子类型字典  --类型：1=道路(可寻走点)，2=墙壁(阻挡点),7=怪物点
    local cellGDTypeDict = {} --格子拐点类型字典

    local mCells = self._mapData.cells
    local size = self._mapData.size --地图大小
    --self._mapData.player.x
    for i=1, #mCells, 4 do
        local grid_id = mCells[i]*size.x + mCells[i+1] -- x * width + y
        cellTypeDict[grid_id] = mCells[i+2]
        cellGDTypeDict[grid_id] = mCells[i+3]
    end
    local offsetS = self._mapData.player
    local offsetE = self._mapData.player2
    if offsetS.x<64 and offsetS.y<59 then
        offsetS.x =64
        offsetS.y =59
    end
    if offsetE.x<64 and offsetE.y<59 then
        offsetE.x =300
        offsetE.y =300
    end
  -- print("CityMapCtrl----sx1:".. offsetS.x .. ",sy1:" .. offsetS.y .. ",ex2:" .. offsetE.x .. ",ey2" .. offsetE.y)
    for i=offsetS.x, offsetE.x do
        for j=offsetS.y, offsetE.y do
            local grid_id = i * size.x + j
            local _cell = self:_createCell(i, j)
            _cell.type = cellTypeDict[grid_id] or CityCellType.Ground
            _cell.gdtype = cellGDTypeDict[grid_id] or CityCellGDType.None
        end
    end

    -- self:_initFC()
    self._roomMapDatas={}
    local values = self._mapData.facilities
    for i=1, #values, 8 do
        local fctId, fctType,fctlevel = values[i+2], values[i+3],values[i+7]  
        --values[i+7] 这个参数在作为外建筑的时候，当做建筑ID，如宿舍ID。当作为内建筑的时候这个参数作为方向。
        local x,y = values[i], values[i+1]
        local index = (i + 3) / 8
        if fctType == 2  then --室外功能建筑
           self._LoadroomCount= self._LoadroomCount+1
           local tbBuilding = TbSceneBuilding[fctId]
           local tbname =tbBuilding.Name 
           local mpCnfData = tbname .. "Data"

           local zoneId = "C" .. DataManager.userData.global.cityId .. "_" .. tbname .. "_" .. fctlevel
           ---加载室内地图配置信息
           ResInterface.LoadTextSync(mpCnfData, function (str)
                self._roomMapDatas[zoneId] = json.decode(str)
                self.initFuncCallback()
           end, ".json")
        end
    end
    self.initFuncCallback()
end

function Ctrl:_LoadRoomMapCnf(name,callfun)

    -- ResInterface.LoadTextSync(name,callfun, ".json")

    ResInterface.LoadTextSync(name, function (str)
        local tempMData = json.decode(str)
        self.initFuncCallback()
    end, ".json")

end

---监听格子显示事件
---@param onCellShow fun(c:Home.MapCell)
---@param obj any
function Ctrl:addOnCellShow(onCellShow, obj)
    self.cellShowEvt:register(onCellShow, obj)
end

---移除格子显示事件
---@param onCellShow fun(c:Home.MapCell)
function Ctrl:rmOnCellShow(onCellShow)
    self.cellShowEvt:unregister(onCellShow)
end

---@return Home.MapCell
function Ctrl:_createCell(x, y)
    local position = CityPosition.new(x, y)
    local realpos = self:calcRealPosition(x, y)
    --local _order = self:calcPositionLayerOrder(x, y)
    local _cell = CityMapCell.new()
    _cell.position = position
    _cell.realpos = realpos
    local grid_id = x * self._mapData.size.x + y
    self._cellDict[grid_id] = _cell
    return _cell
end


function Ctrl:_initGrounds(mapData)
    --初始化地块

end
function Ctrl:_initItems(mapData)
  
end

---@return City.MapData
function Ctrl:getMapData()
    return self._mapData
end

---（虚）update更新方法
function Ctrl:update(dt) end

--（编辑器）坐标转换
function Ctrl:_translatePosition(x, y)
    return x, y
    -- return x, MapHeight - y
end

---计算真实（局部）坐标
function Ctrl:calcRealPosition(x, y)
    --左上角为零点
    local size = self._mapData.size
    x=x-size.x * 0.5
    y=y-size.y * 0.5
    local _posX = (x + y) * OffsetX * (1 + CellSpace)
    local _posY = (-x + y) * OffsetY * (1 + CellSpace)
    return Vector3.New(_posX + 0.54, _posY -0.21, 0)
end

---计算真实坐标
function Ctrl:calcRealPositionEx(x, y)
    
    local _posX = (x + y) * OffsetX * (1 + CellSpace)
    local _posY = (-x + y) * OffsetY * (1 + CellSpace)
    return Vector3.New(_posX, _posY, 0)
end

---根据真实坐标x和y，计算所在的格子坐标
---@return City.Position
function Ctrl:calcCellPosition(x, y)
    local _posX = math.floor((x / OffsetX - y / OffsetY) / 2)
    local _posY = math.floor((x / OffsetX + y / OffsetY) / 2)
    return _posX, _posY
end


---根据坐标位置计算层级排序
function Ctrl:calcPositionLayerOrder(x, y)
    return x + MapHeight - y
end

--function Ctrl:createCellByTile(tile)
--    local x, y = self:_translatePosition(tile.x, tile.y)
--    return self:createCell(x, y, tile.id);
--end



---@return number
function Ctrl:_calCellKey(x, y)
    return x * 1000 + y
end


---通过x,y坐标获得item
---@return City.MapItem
function Ctrl:getItem(x, y)
    return self._itemDict[self:_calCellKey(x, y)]
end

---通过x, y获取格子的排序层级
function Ctrl:getSortingOrder(x, y)
    return (x - y) * 2 + CityDefine.MapSizeMaxHeight
end

---通过x, y获取该坐标点方块的可行走方块列表
---@param x int 逻辑坐标x
---@param y int 逻辑坐标y
---@param dir CityPosition 方向
function Ctrl:getPathingListByXy(x, y, dir)
--    local curCell = self:getCell(x, y)
--    if not curCell then
--        return
--    end

--    local tarList = {}
--    local function checkCell(_x, _y)
--        local cell = self:getCell(_x, _y)
--        -- 如果该格子存在并且没被禁用
--        if cell and cell.mute == 0 then
--            if dir then
--                local excludePathingX = x + -dir.x
--                local excludePathingY = y + -dir.y

--                if not (excludePathingX == _x and excludePathingY == _y) then
--                    tarList[_x.."_".._y] = cell
--                end   
--            else
--                tarList[_x.."_".._y] = cell
--            end  
--        end
--    end

--    if curCell.nextCell then
--        local nextCell = self:getCell(curCell.nextCell.x, curCell.nextCell.y)
--        tarList[curCell.nextCell.x.."_"..curCell.nextCell.y] = nextCell
--    elseif curCell.nextSpCell then
--        local nextSpCell = self:getCell(curCell.nextSpCell.x, curCell.nextSpCell.y)
--        tarList[curCell.nextSpCell.x.."_"..curCell.nextSpCell.y] = nextSpCell
--    else
--        checkCell(x - 1, y)
--        checkCell(x + 1, y)
--        checkCell(x, y + 1)
--        checkCell(x, y - 1)
--    end

    return tarList
end

function Ctrl:getBoss()
    for k, item in pairs(self._itemDict) do
        if item.type == CityItemType.Boss then
            return item
        end
    end
end

---通过触发器类型获取触发器Item列表
function Ctrl:getItemsByType(type)
    local list = {}
    for k, item in pairs(self._itemDict) do
        if item.type == type then
            table.insert(list, item)
        end
    end
    return list
end

--- 检查当前是否岔路
function Ctrl:checkIsFork(cell, dir)
    local pathingList = self:getPathingListByXy(cell.position.x, cell.position.y, dir)
    if ListUtil.length(pathingList) <= 1 then
        return false
    end
    return true
end

---检查是否是相邻的格子
function Ctrl:isAdjacentCell(cell1, cell2)
    local xDistance = math.abs(cell2.position.x - cell1.position.x)
    local yDistance = math.abs(cell2.position.y - cell1.position.y)
    if xDistance + yDistance > 1 then
        return false
    end
    return true
end

---@param pos City.Position
function Ctrl:getCell(pos)
    local grid_id = pos.x * self._mapData.size.x + pos.y
    return self._cellDict[grid_id]
end

function Ctrl:getCellByXY(x, y)
    local grid_id = x * self._mapData.size.x + y
    return self._cellDict[grid_id]
end

---遍历回调所有格子
---@param fun fun(n:Home.MapCell)
function Ctrl:eachCell(fun)
    for _, v in pairs(self._cellDict) do
        fun(v)
    end
end


---遍历回调每个相邻格子
---@param cell Home.MapCell
---@param fun fun(n:Home.MapCell, c:Home.MapCell):(boolean|nil)
function Ctrl:eachNeighbor(cell, fun)
    for _, dirPos in ipairs(CityPosition.DirPositions) do
        local _nx = cell.position.x + dirPos.x
        local _ny = cell.position.y + dirPos.y
        local nc = self:getCellByXY(_nx, _ny)
        if nc ~= nil then
            local hasFind = fun(nc, cell)
            if hasFind then break end
        end
    end
end

---遍历获取（占据）区域邻居格子
---@param cells Home.MapCell[]
---@param fun fun(n:Home.MapCell):(boolean|nil)
function Ctrl:eachAreaNeighbor(cells, fun)
    local visited = {}
    for _, cell in ipairs(cells) do
        visited[cell] = true
    end
    for _, cell in ipairs(cells) do
        local hasFind = false
        self:eachNeighbor(cell, function (nc)
            if not visited[nc] then
                hasFind = fun(nc)
                return hasFind
            end
        end)
        if hasFind then break end
    end
end

---遍历占据的所有格子（按xy轴顺序）
---@param cell Home.MapCell 起始格
---@param ocTid number
---@param fun fun(n:Home.MapCell):(boolean|nil)
---@param willNil boolean 是否包含空值[False]
function Ctrl:eachOccupyCell(cell, ocTid, fun, willNil)
    local tbOccupy = TbHomeOccupy[ocTid]
    local hasFind = false
    for y=1, tbOccupy.Y do
        for x =1, tbOccupy.X do
            --坐标点从0开始，所以减1
            local posX = cell.position.x + x - 1
            local posY = cell.position.y + y - 1
            local _oc = self:getCellByXY(posX, posY)
            if willNil or _oc ~= nil then
                hasFind = fun(_oc) or false
                if hasFind then break end
            end
        end
        if hasFind then break end
    end
end

---计算占据格子（按xy轴顺序）
---@param cell Home.MapCell 起始格
---@param ocTid number
---@return Home.MapCell[]
function Ctrl:listOccupyCells(cell, ocTid)
    local cells = {}
    self:eachOccupyCell(cell, ocTid, function (_oc)
        table.insert(cells, _oc)
    end)
    return cells
end
---@param start Home.MapCell
---@param goal Home.MapCell|Home.MapCell[]
---@param range number 范围
--- 寻路优化
--- 1.找到出发点门口，寻路 (出发点, 出发点门口）
--- 2.找到目标点门口，寻路（目标点门口，目标点）
--- 3.寻路（出发点门口，目标点门口）（这部分做成缓存）
function Ctrl:findPath(start, goal, markerIndex, serialNumber)
    if false then 
        return self._pathFinder:findPath(start, goal, 0, false, false)
    end

    -- 特殊情况
    -- 1.没有门
    -- 2.多个门（厨房两个门）
    -- 3.在房间内
    local startDoorCell = self:GetDoorCellByCell(start, markerIndex, serialNumber)
    local targetDoorCell = self:GetDoorCellByCell(goal, markerIndex, serialNumber)

    if startDoorCell == nil or targetDoorCell == nil or startDoorCell == targetDoorCell then 
        return self._pathFinder:findPath(start, goal, 0, false, false)
    end

    local path1 = self._pathFinder:findPath(start, startDoorCell, 0, false, false)
    local path2 = self._pathFinder:findPath(startDoorCell, targetDoorCell, 0, true, true)
    local path3 = self._pathFinder:findPath(targetDoorCell, goal, 0, false, false)

    if not path1 or not path2 or not path3 then 
        if Application.isEditor then 
            local msg = ""
            if path1 == nil then 
                local grid1 = Utils.GetGridByCell(start)
                local grid2 = Utils.GetGridByCell(startDoorCell)
                msg = string.format("from start%s(%s, %s) to start door%s(%s, %s)", (grid1.zoneId or ""), start.position.x, start.position.y, (grid2.zoneId or ""), startDoorCell.position.x, startDoorCell.position.y)
            end
            if path2 == nil then 
                local grid1 = Utils.GetGridByCell(startDoorCell)
                local grid2 = Utils.GetGridByCell(targetDoorCell)
                msg = string.format("from start door%s(%s, %s) to target door%s(%s, %s)", (grid1.zoneId or ""), startDoorCell.position.x, startDoorCell.position.y, (grid2.zoneId or ""), targetDoorCell.position.x, targetDoorCell.position.y)
            end
            if path3 == nil then 
                local grid1 = Utils.GetGridByCell(targetDoorCell)
                local grid2 = Utils.GetGridByCell(goal)
                msg = string.format("from target door%s(%s, %s) to target%s(%s, %s)", (grid1.zoneId or ""), targetDoorCell.position.x, targetDoorCell.position.y, (grid2.zoneId or ""), goal.position.x, goal.position.y)
            end
            local cityId = DataManager.userData.global.cityId
            print("[Error]Path is nil. city = " .. cityId .. ", " .. msg)
        end
        return self._pathFinder:findPath(start, goal, 0, false, false)
    end

    for index, value in ipairs(path2) do
        table.insert(path1, value)
    end

    for index, value in ipairs(path3) do
        table.insert(path1, value)
    end

    return path1

end

function Ctrl:destroy()

end

--- 获取门格子
--- @param grid any
--- @return unknown
function Ctrl:GetDoorCellByGrid(grid, markerIndex, serialNumber)
    local door = GridManager.GetGridByZoneId(DataManager.userData.global.cityId, grid.zoneId, GridMarker.Door, markerIndex, serialNumber)
    if door == nil then 
        print("[Error][GetDoor] 没有找到门", DataManager.userData.global.cityId, grid.zoneType, grid.xIndex, grid.zIndex, markerIndex, serialNumber)
        return nil
    end

    return self:getCellByXY(door.xIndex, door.zIndex)
end


--- 获取目标格子对应的门
--- @param cell any
--- @return unknown
function Ctrl:GetDoorCellByCell(cell, markerIndex, serialNumber)
    local grid_id = Utils.PositionToGridId(cell.position.x, 0, cell.position.y)
    local grid = GridManager.GetGridById(DataManager.userData.global.cityId, grid_id)
    if grid == nil then 
        return nil 
    end

    if grid.zoneType == ZoneType.MainRoad then 
        return nil 
    end

    return self:GetDoorCellByGrid(grid, markerIndex, serialNumber)
end

return Ctrl