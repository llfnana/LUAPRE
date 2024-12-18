CityGrid = Clone(CityBase)
CityGrid.__cname = "CityGrid"

--初始化
function CityGrid:OnInitOld()

    local mapCtrl = CityModule.getMapCtrl()
    local mapData = mapCtrl:getMapData()
    local size = mapData.size --地图大小
    local map = ConfigManager.GetMapGrid(self.cityId)
    map.mapId = self.cityId
    map.mapWidth = size.x* CityDefine.MapCellSize[1] 
    map.mapHeight = size.y* CityDefine.MapCellSize[2] 
    map.gridWidth = CityDefine.MapCellSize[1] 
    map.gridHeight =  CityDefine.MapCellSize[2] 

   -- self.map ={} --map
    self.map =map

    self.mapWidth = map.mapWidth--map.mapWidth / 1000
    self.mapHeight = map.mapHeight--map.mapHeight / 1000
    self.gridWidth =map.gridWidth --map.gridWidth / 1000
    self.gridHeight = map.gridHeight--map.gridHeight / 1000

    self.mapWidthHalf = self.mapWidth / 2
    self.mapHeightHalf = self.mapHeight / 2
    self.gridWidthHalf = self.gridWidth / 2
    self.gridHeightHalf = self.gridHeight / 2


    --初始化Grid
    self.grids = {}
    self.gridGroups = {}
    --遍历GridInfos
    for i = 1, #map.gridInfos do
        self:AddGrid(Grid:New(self.cityId, map.gridInfos[i]))
    end

--    --遍历地图默认路径
--    self.cachePaths = {}
--    --加载地图缓存路径
--    for i = 1, #map.pathInfos do
--        local pathInfo = map.pathInfos[i]
--        local startId = Utils.PositionToGridId(pathInfo.pathStart.x, pathInfo.pathStart.y, pathInfo.pathStart.z)
--        local endId = Utils.PositionToGridId(pathInfo.pathEnd.x, pathInfo.pathEnd.y, pathInfo.pathEnd.z)
--        local pathPoints1 = List:New()
--        local pathPoints2 = List:New()
--        local pointCount = #pathInfo.pathPoints
--        for i = 1, pointCount do
--            local j = pointCount - i + 1
--            pathPoints1:Add(pathInfo.pathPoints[i])
--            pathPoints2:Add(pathInfo.pathPoints[j])
--        end
--        self:AddCachePath(startId .. "_" .. endId, pathPoints1)
--        self:AddCachePath(endId .. "_" .. startId, pathPoints2)
--    end
--    self.stairsPaths = {}
--    self.pathFinder = PathFinder:New()
--    self.pathFinder:Init(self.cityId)
end
--初始化
function CityGrid:OnInit()
    print("[CityGrid]", Time.frameCount)
    local mapCtrl = CityModule.getMapCtrl()
    local mapData = mapCtrl:getMapData()
    local size = mapData.size --地图大小
    --local map = ConfigManager.GetMapGrid(self.cityId)
    self.map ={}
    self.map.mapId = self.cityId
    self.map.mapWidth = size.x* CityDefine.MapCellSize[1] 
    self.map.mapHeight = size.y* CityDefine.MapCellSize[2] 
    self.map.gridWidth = CityDefine.MapCellSize[1] 
    self.map.gridHeight =  CityDefine.MapCellSize[2] 

    --self.map ={} --map
    -- self.map =map

    self.mapWidth = self.map.mapWidth--map.mapWidth / 1000
    self.mapHeight = self.map.mapHeight--map.mapHeight / 1000
    self.gridWidth =self.map.gridWidth --map.gridWidth / 1000
    self.gridHeight = self.map.gridHeight--map.gridHeight / 1000

    self.mapWidthHalf = self.mapWidth / 2
    self.mapHeightHalf = self.mapHeight / 2
    self.gridWidthHalf = self.gridWidth / 2
    self.gridHeightHalf = self.gridHeight / 2
    
    -- self.map.nodeInfos={}
    self.map.nodeInfos={}
    local values = mapData.facilities
    for i=1, #values, 8 do
        local fctId, fctType,fctlevel = values[i+2], values[i+3],values[i+7]  
        --values[i+7] 这个参数在作为外建筑的时候，当做建筑ID，如宿舍ID。当作为内建筑的时候这个参数作为方向。
        local x,y = values[i], values[i+1]
        local index = (i + 3) / 8
        if fctType == 1  then  --(室内建筑)


        elseif fctType == 2  then --室外功能建筑
           local tbBuilding = TbSceneBuilding[fctId]
           local tbname =tbBuilding.Name 
           local nodeInfo ={}
           nodeInfo.zoneType =tbname
           nodeInfo.zoneId = "C" .. self.cityId.. "_" .. tbname .. "_" .. fctlevel
           nodeInfo.xIndex = x -- +3
           nodeInfo.zIndex = y
            self.map.nodeInfos[nodeInfo.zoneId]= nodeInfo
           --self.map.nodeInfos[nodeInfo.zoneId]= nodeInfo
            if CityDefine.debug then
                local data ={}
                data.id = nodeInfo.zoneId
                data.res_id = 60009
                local characterController = CharacterController.new(data)
                local mapTr = GameObject.Find("Map").transform
                local rootChars = mapTr:Find("Chars")
                local obj = rootChars:Find("CityChar").gameObject
                local playerGo = GOInstantiate(obj, rootChars)
                playerGo:SetActive(true)
                local mapCtrl = CityModule.getMapCtrl()
                local initCell =mapCtrl:getCellByXY(x,y)
                characterController:bind(playerGo,data.res_id)  --暂时在这里设置小人spine 资源id =0
                characterController:SetAnim(AnimationType.Idle)
                characterController:playAnim("idle",1) --朝下
                --  characterController:playAnim("sleeping",CityPosition.Dir.Right)
                characterController:setSortingOrder(2010)       
                characterController:setCell(initCell)
                characterController.gameObject.name =nodeInfo.zoneId
                --local Animation = characterController.transform:Find("Animation")
                -- textCanvas.gameObject:SetActive(false)
                local textCanvas =  characterController.transform:Find("TextCanvas")
                textCanvas.gameObject:SetActive(true) 
                local nameTxt = characterController.transform:Find("TextCanvas/Name"):GetComponent("Text")
               -- nameTxt.text = nodeInfo.zoneId
                nameTxt.text =  nodeInfo.zoneId .. "(" ..  characterController.cell.realpos.x .. "," .. characterController.cell.realpos.y .. ")" 
                local stateTxt = characterController.transform:Find("TextCanvas/State"):GetComponent("Text")
                stateTxt.text ="(" ..  x .. "," .. y .. ")"
            end

        elseif fctType == 3  then  --格子标记

        end

    end

    local cellTypeDict = {} --格子类型字典  --类型：1=道路(可寻走点)，2=墙壁(阻挡点),3=
    local cellGDTypeDict = {} --格子拐点类型字典 
    local mCells = mapData.cells
    local roadindex = 0
    self.map.gridInfos ={}

    for i=1, #mCells, 4 do
        --cellTypeDict[CityPosition.gHash(mCells[i], mCells[i+1])] = mCells[i+2]
       -- cellGDTypeDict[CityPosition.gHash(mCells[i], mCells[i+1])] = mCells[i+3]
        local gridInfo={}
         if(mCells[i+2] ==1) then --当前格子类型 道路(可寻走点)

             gridInfo.xIndex =mCells[i] -- +3
             gridInfo.yIndex =0
             gridInfo.zIndex =mCells[i+1]
             gridInfo.zoneId =""
             gridInfo.zoneType ="MainRoad"
             gridInfo.effectType =1
             gridInfo.markerIndex =  -1
             gridInfo.serialNumber = -1
             gridInfo.cs ={}
             local protestDir = 4
             if self.cityId ==3 then
                protestDir = 2
             end

             if mCells[i+3] >9 and  mCells[i+3] < 25 then
                 if  mCells[i+3] ==10  then
                     gridInfo.markerType ="Hunt"
                 elseif  mCells[i+3] ==11  then
                     gridInfo.markerType ="Speech"
                     gridInfo.yIndex =protestDir
                 elseif  mCells[i+3] ==12  then
                     gridInfo.markerType ="Protest"
                     gridInfo.yIndex =protestDir
                 elseif  mCells[i+3] ==13  then
                     gridInfo.markerType ="Protest2"
                     gridInfo.yIndex =protestDir
                 elseif  mCells[i+3] ==14  then
                     gridInfo.markerType ="Idle"

                 elseif  mCells[i+3] ==15  then
                     gridInfo.markerType ="VanDestroy"

                 elseif  mCells[i+3] ==16  then
                     gridInfo.markerType ="VanQueue"

                 elseif  mCells[i+3] ==17  then
                     gridInfo.markerType ="TutorialBorn"

                 elseif  mCells[i+3] ==18  then
                     gridInfo.markerType ="TutorialVanBorn"

                 elseif  mCells[i+3] ==19  then
                     gridInfo.markerType ="Born"
                     CityDefine.NpcPos.x= gridInfo.xIndex
                     CityDefine.NpcPos.y= gridInfo.zIndex
                 elseif  mCells[i+3] ==20  then
                     gridInfo.markerType ="Born2"
                 elseif  mCells[i+3] ==21  then
                     gridInfo.markerType ="TutorialPatientBorn"
                 elseif  mCells[i+3] ==22  then
                     gridInfo.markerType ="TutorialPatientDelete"
                 elseif  mCells[i+3] ==23  then
                     gridInfo.markerType ="OfficeBorn"
                 elseif  mCells[i+3] ==24  then
                    
                     gridInfo.markerType ="Occlusion"  ---- 遮挡区所在位
                 end

             else
                 gridInfo.markerType ="None"
                 --拐点主路径还没想好暂时先不弄,先直接用A*替代
                 local cs={}
--                 if  mCells[i+3] ==1  then  --LEFT_UP_RIGHT301,//3-0-1
--                 elseif  mCells[i+3] ==2  then --UP_RIGHT_DOWN012,//0-1-2

--                 elseif  mCells[i+3] ==3  then -- RIGHT_UP_LEFT123,//1-2-3

--                 elseif  mCells[i+3] ==4  then -- DOWN_LEFT_UP230,//2-3-0

--                 elseif  mCells[i+3] ==5  then --UP_LEFT_DOWN_RIGHT0123,//0-1-2-3  

--                 end
             end


             roadindex= roadindex+1
             self.map.gridInfos[roadindex] = clone(gridInfo)
            -- self.map.gridInfos[roadindex] = gridInfo
         end

    end

    --self.map =map
  
   --初始化Grid
    self.grids = {}
    self.gridGroups = {}
    --遍历GridInfos
    for i = 1, #self.map.gridInfos do
       self:AddGrid(Grid:New(self.cityId, self.map.gridInfos[i]))
         -- self:AddGrid(Grid:New(self.cityId, map.gridInfos[i]))
   end
--    --遍历地图默认路径
--    self.cachePaths = {}
--    --加载地图缓存路径
--    for i = 1, #map.pathInfos do
--        local pathInfo = map.pathInfos[i]
--        local startId = Utils.PositionToGridId(pathInfo.pathStart.x, pathInfo.pathStart.y, pathInfo.pathStart.z)
--        local endId = Utils.PositionToGridId(pathInfo.pathEnd.x, pathInfo.pathEnd.y, pathInfo.pathEnd.z)
--        local pathPoints1 = List:New()
--        local pathPoints2 = List:New()
--        local pointCount = #pathInfo.pathPoints
--        for i = 1, pointCount do
--            local j = pointCount - i + 1
--            pathPoints1:Add(pathInfo.pathPoints[i])
--            pathPoints2:Add(pathInfo.pathPoints[j])
--        end
--        self:AddCachePath(startId .. "_" .. endId, pathPoints1)
--        self:AddCachePath(endId .. "_" .. startId, pathPoints2)
--    end
--    self.stairsPaths = {}
--    self.pathFinder = PathFinder:New()
--    self.pathFinder:Init(self.cityId)
end

--根据等级区域格子配置
function CityGrid.LoadZoneGridsCnf(zoneName)
    local configData = string.format("%sData", zoneName)
    ResInterface.LoadTextSync(configData, function (str)
        local roomData = json.decode(str)

        local values = roomData.facilities
        for i=1, #values, 8 do
            local fctId, fctType = values[i+2], values[i+3]
            local index = (i + 3) / 8
            local tbBuilding = TbSceneBuilding[self.tid]
            --tbBuilding.Name 

        end
    end, ".json")
end

function CityGrid:OnClear()
    self = nil
end

---------------------------------
---事件响应
---------------------------------
--修改格子数据
function CityGrid:UpgradeFurnitureFunc(zoneId, zoneType, markerType, markerIndex, level)
    local grid = self:GetGridByZoneId(zoneId, markerType, markerIndex)
    if grid then
        grid:CreateProductionUI()
    end
end

---------------------------------
---方法
---------------------------------
-- 添加缓存路径
function CityGrid:AddCachePath(pathId, pathPoints)
    self.cachePaths[pathId] = pathPoints
end

--获取默认缓存路径
function CityGrid:GetCachePath(pathId)
    if self.cachePaths[pathId] then
        return self.cachePaths[pathId]
    end
    return nil
end

--移除缓存路径
function CityGrid:RemoveCachePath(pathId)
    self.cachePaths[pathId] = nil
end

-- 根据Key从格子组中获取格子列表
function CityGrid:GetGridIdsFromGroup(mainKey, subKey)
    local gridIds = List:New()
    if not self.gridGroups[mainKey] then
        return gridIds
    end
    if subKey then
        local gridDic = self.gridGroups[mainKey]
        if not gridDic[subKey] then
            return gridIds
        else
            return gridDic[subKey]
        end
    else
        for key, value in pairs(self.gridGroups[mainKey]) do
            gridIds:AddRange(value)
        end
        return gridIds
    end
end

-- 根据区域id获取结点对象
function CityGrid:GetNodeByZoneId(zoneId)
    return self.map.nodeInfos[zoneId]
end

-- 添加格子
function CityGrid:AddGrid(grid)
    --填充Grid
    grid.position = self:GridToPosition(grid.xIndex, grid.zIndex, grid.yIndex / 1000)
    self.grids[grid.id] = grid
    --填充标记类型格子
    if grid.markerType ~= GridMarker.None then
        if not self.gridGroups[grid.markerType] then
            self.gridGroups[grid.markerType] = {}
        end
        local gridDic = self.gridGroups[grid.markerType]
        if not gridDic[grid.zoneType] then
            gridDic[grid.zoneType] = List:New()
        end
        gridDic[grid.zoneType]:Add(grid.id)
    end
    --填充有zoneId的格子
    if grid.zoneId ~= "" then
        if not self.gridGroups[grid.zoneId] then
            self.gridGroups[grid.zoneId] = {}
        end
        local gridDic = self.gridGroups[grid.zoneId]
        if grid.markerType ~= GridMarker.None then
            if not gridDic[grid.markerType] then
                gridDic[grid.markerType] = List:New()
            end
            gridDic[grid.markerType]:Add(grid.id)
        end
    end
    --填充有furnitureId的格子
    if grid.furnitureId ~= nil then
        if not self.gridGroups[grid.furnitureId] then
            self.gridGroups[grid.furnitureId] = List:New()
        end
        self.gridGroups[grid.furnitureId]:Add(grid.id)
    end
end

-- 删除格子
function CityGrid:RemoveGrid(grid)
    self.grids[grid.id] = nil
    local gridDic = {}
    --删除标记类型格子
    if grid.markerType ~= GridMarker.None then
        if self.gridGroups[grid.markerType] then
            gridDic = self.gridGroups[grid.markerType]
            if gridDic[grid.zoneType] then
                gridDic[grid.zoneType]:Remove(grid.id)
            end
        end
    end
    --删除zoneId的格子
    if grid.zoneId ~= "" then
        if self.gridGroups[grid.zoneId] then
            gridDic = self.gridGroups[grid.zoneId]
            if gridDic[grid.markerType] then
                gridDic[grid.markerType]:Remove(grid.id)
            end
        end
    end
    grid:Clear()
end

-- 添加区域格子列表
function CityGrid:AddZoneGrids(gridInfos)
    for i = 1, #gridInfos do
        self:AddGrid(Grid:New(self.cityId, gridInfos[i]))
    end
end

-- 移除区域格子列表
function CityGrid:RemoveZoneGrids(gridInfos)
    for i = 1, #gridInfos do
        local grid = self:GetGridById(string.format("%d_%d", gridInfos[i].xIndex, gridInfos[i].zIndex))
        if grid then
            self:RemoveGrid(grid)
        end
    end
end

---计算真实（局部）坐标
function CityGrid:calcRealPosition(x, y)
    --//右下角为零点
    --//var _poxX = (pos.x - pos.y) * m_offsetX;
    --//var _poyX = (pos.x + pos.y) * offsetY;
    --左上角为零点（格子往右居中）
    local OffsetX = CityDefine.MapCellSize[1] / 2 --格子X的偏移
    local OffsetY = CityDefine.MapCellSize[2] / 2 --格子Y的偏移

    local _posX = (x + y + 1) * OffsetX
    local _posY = (-x + y) * OffsetY
    return Vector3.New(_posX, _posY, 0)
end

---根据真实坐标x和y，计算所在的格子坐标
---@return Home.Position
function CityGrid:calcCellPosition(x, y)
    local OffsetX = CityDefine.MapCellSize[1] / 2 --格子X的偏移
    local OffsetY = CityDefine.MapCellSize[2] / 2 --格子Y的偏移

    local _posX = math.floor((x / OffsetX - y / OffsetY) / 2)
    local _posY = math.floor((x / OffsetX + y / OffsetY) / 2)
    return _posX, _posY
end


--根据格子位置获取世界坐标
function CityGrid:GridToPosition(x, z, y)
--    local posX = x * self.gridWidth - self.mapWidthHalf + self.gridWidthHalf
--    local posZ = z * self.gridHeight - self.mapHeightHalf + self.gridHeightHalf
    --return Vector3(posX, y, posZ)
    return Vector3(x, y, y)
end

---根据世界坐标转化为格子id
function CityGrid:PositionToGridId(position)
--    local x = Utils.RoundToInt((position.x + self.mapWidthHalf - self.gridWidthHalf) / self.gridWidth)
--    local y = Utils.RoundToInt(position.y * 1000)
--    local z = Utils.RoundToInt((position.z + self.mapHeightHalf - self.gridHeightHalf) / self.gridHeight)
--    return Utils.PositionToGridId(x, y, z)
    return Utils.PositionToGridId(position.x, position.y, position.z)
end

---根据世界坐标转化为格子对象
function CityGrid:PositionToGrid(position)
    return self:GetGridById(self.PositionToGridId(position))
end

--获取路径点
function CityGrid:GetPath(startGrid, endGrid, isNormal)
    isNormal = isNormal or true
    return self.pathFinder:GetPath(startGrid, endGrid, isNormal)
end

--根据Key获取格子信息
function CityGrid:GetGridById(id)
    return self.grids[id]
end

--根据标记类型获取格子列表
function CityGrid:GetGridsByMarkerType(markerType, zoneType, findType)
    if findType == nil then
        findType = GridStatus.CanUse
    end
    local gridList = List:New()
    local gridIds = self:GetGridIdsFromGroup(markerType, zoneType)
    if gridIds:Count() > 0 then
        gridIds:ForEach(
            function(id)
                local grid = self:GetGridById(id)
                if not grid then
                    return
                end
                if findType == GridStatus.Lock and grid:IsUnlock() then
                    return
                end
                if findType == GridStatus.Unlock and not grid:IsUnlock() then
                    return
                end
                if findType == GridStatus.CanUse and not grid:IsCanUse() then
                    return
                end
                gridList:Add(grid)
            end
        )
        if markerType == GridMarker.Bed then
            gridList:Sort(Utils.SortGridByAscendingUseZoneNumber)
        elseif Utils.IsAscendingGrid(markerType) then
            gridList:Sort(Utils.SortGridByAscendingUseSerialNumber)
        end
    end
    return gridList
end

--根据zoneId 获取格子列表
function CityGrid:GetGridsByZoneId(zoneId, markerType, findType)
    if findType == nil then
        findType = GridStatus.CanUse
    end
    local gridList = List:New()
    local gridIds = self:GetGridIdsFromGroup(zoneId, markerType)
    if gridIds:Count() > 0 then
        gridIds:ForEach(
            function(id)
                local grid = self:GetGridById(id)
                if not grid then
                    return
                end
                if findType == GridStatus.Lock and grid:IsUnlock() then
                    return
                end
                if findType == GridStatus.Unlock and not grid:IsUnlock() then
                    return
                end
                if findType == GridStatus.CanUse and not grid:IsCanUse() then
                    return
                end
                if markerType and grid.markerType ~= markerType then
                    return
                end
                gridList:Add(grid)
            end
        )
        if Utils.IsAscendingGrid(markerType) then
            gridList:Sort(Utils.SortGridByAscendingUseSerialNumber)
        end
    end
    return gridList
end

--根据标记类型获取格子
function CityGrid:GetGridByMarkerType(markerType, zoneType, markerIndex, serialNumber, findType)
    local gridList = self:GetGridsByMarkerType(markerType, zoneType, findType)
    local gridCount = gridList:Count()
    if gridCount > 1 then
        if markerIndex then
            if serialNumber then
                for i = 1, gridCount do
                    if gridList[i].markerIndex == markerIndex and gridList[i].serialNumber == serialNumber then
                        return gridList[i]
                    end
                end
            else
                for i = 1, gridList:Count() do
                    if gridList[i].markerIndex == markerIndex then
                        return gridList[i]
                    end
                end
            end
        elseif serialNumber then
            for i = 1, gridList:Count() do
                if gridList[i].serialNumber == serialNumber then
                    return gridList[i]
                end
            end
        elseif Utils.IsSortGrid(markerType) then
            return gridList[1]
        else
            return gridList[math.random(gridCount)]
        end
    elseif gridCount > 0 then
        return gridList[1]
    end
    return nil
end

--根据zoneId获取格子
function CityGrid:GetGridByZoneId(zoneId, markerType, markerIndex, serialNumber, findType)
    local gridList = self:GetGridsByZoneId(zoneId, markerType, findType)
    local gridCount = gridList:Count()
    if gridCount > 1 then
        if markerIndex then
            if serialNumber then
                for i = 1, gridCount do
                    if gridList[i].markerIndex == markerIndex and gridList[i].serialNumber == serialNumber then
                        return gridList[i]
                    end
                end
            else
                for i = 1, gridCount do
                    if gridList[i].markerIndex == markerIndex then
                        return gridList[i]
                    end
                end
            end
        elseif serialNumber then
            for i = 1, gridCount do
                if gridList[i].serialNumber == serialNumber then
                    return gridList[i]
                end
            end
        elseif Utils.IsSortGrid(markerType) then
            return gridList[1]
        else
            return gridList[math.random(gridCount)]
        end
    else
        return gridList[1]
    end
    return nil
end

--获取排队格子
function CityGrid:GetGridQueue(markerType, zoneType, serialNumber)
    local gridList = self:GetGridsByMarkerType(markerType, zoneType, GridStatus.Unlock)
    local gridCount = gridList:Count()
    local grid = nil
    if serialNumber then
        for i = serialNumber, 1, -1 do
            if gridList[i]:IsCanUse() then
                grid = gridList[i]
            else
                break
            end
        end
    else
        for i = gridCount, 1, -1 do
            if gridList[i]:IsCanUse() then
                grid = gridList[i]
            else
                break
            end
        end
    end
    return grid
end

--根据家具id获取格子对象
function CityGrid:GetGridByFurnitureId(furnitureId, furnitureIndex, findType)
    if not self.gridGroups[furnitureId] then
        return nil
    end
    local gridList = List:New()
    self.gridGroups[furnitureId]:ForEach(
        function(id)
            local grid = self:GetGridById(id)
            if not grid then
                return
            end
            if findType == GridStatus.Lock and grid:IsUnlock() then
                return
            end
            if findType == GridStatus.Unlock and not grid:IsUnlock() then
                return
            end
            if findType == GridStatus.CanUse and not grid:IsCanUse() then
                return
            end
            gridList:Add(grid)
        end
    )
    local gridCount = gridList:Count()
    if gridCount == 0 then
        return nil
    end
    if furnitureIndex then
        for i = 1, gridList:Count() do
            if gridList[i].markerIndex == furnitureIndex then
                return gridList[i]
            end
        end
        return nil
    else
        return gridList[math.random(gridCount)]
    end
end

---计算真实（局部）坐标
function CityGrid:GetRealPosition(x, y)
    local OffsetX = CityDefine.MapCellSize[1] / 2 --格子X的偏移
    local OffsetY = CityDefine.MapCellSize[2] / 2 --格子Y的偏移
    --//右下角为零点
    --//var _poxX = (pos.x - pos.y) * m_offsetX;
    --//var _poyX = (pos.x + pos.y) * offsetY;
    --左上角为零点（格子往右居中）
    local _posX = (x + y + 1) * OffsetX
    local _posY = (-x + y) * OffsetY
    return Vector3.New(_posX, _posY, 0)
end

---根据真实坐标x和y，计算所在的格子坐标
---@return City.Position
function CityGrid:GetCellPosition(x, y)
    local OffsetX = CityDefine.MapCellSize[1] / 2 --格子X的偏移
    local OffsetY = CityDefine.MapCellSize[2] / 2 --格子Y的偏移

    local _posX = math.floor((x / OffsetX - y / OffsetY) / 2)
    local _posY = math.floor((x / OffsetX + y / OffsetY) / 2)
    return _posX, _posY
end

---获取格子的真实坐标
---@param offsetX number 偏移X
---@return UnityEngine.Vector3
function CityGrid:getRealPos(offsetX)

    local x = self.position.x + (offsetX or 0)
    return self:GetRealPosition(x, self.position.y)
end

---获取格子的排序层级
function CityGrid:getSortingOrder()
    local pos = self.position
    return pos.x - pos.y + CityDefine.MapSizeMaxHeight
end