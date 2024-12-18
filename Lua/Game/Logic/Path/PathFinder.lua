local SearchDirection = {}
SearchDirection[1] = {x = 0, z = 1}
SearchDirection[2] = {x = 0, z = -1}
SearchDirection[3] = {x = -1, z = 0}
SearchDirection[4] = {x = 1, z = 0}

--计算格子G Cost
local function CalculateGridCostCostG(g, sg)
    if sg.parent then
        if sg.xIndex == g.xIndex or sg.zIndex == g.zIndex then
            return sg.gCost + 10
        else
            return sg.gCost + 14
        end
    end
    return 0
end

--计算格子H Cost
local function CalculateGridCostH(g, eg)
    return math.abs(g.xIndex - eg.xIndex) + math.abs(g.zIndex - eg.zIndex)
end

--计算额外消耗(解决多拐点问题)
local function CalculateGridExtraCost(currNode, nextNode, endNode)
    if nil == currNode.parent or nextNode.xIndex == currNode.parent.xIndex or nextNode.zIndex == currNode.parent.zIndex then
        return 0
    end
    if nextNode.xIndex == endNode.xIndex or nextNode.zIndex == endNode.zIndex then
        return 1
    end
    return 2
end

local function CompareFunc(o1, o2)
    if o1.fCost == o2.fCost then
        return false
    end
    return o1.fCost < o2.fCost
end

PathFinder = {}

function PathFinder:New()
    return Clone(self)
end

function PathFinder:Init(cityId)
    self.cityId = cityId
    self.openList = List:New()
    self.cachePaths = {}
end

--创建缓存路径
function PathFinder:CreateCachPath(startGrid, endGrid, isNormal)
    local pathId = startGrid.id .. "_" .. endGrid.id
    local pathPoints = self:GetPathByGrid(startGrid, endGrid, isNormal)
    self.cachePaths[pathId] = pathPoints
    return pathPoints
end

--从缓存中获取路径
function PathFinder:GetCachePath(startGrid, endGrid, isNormal)
    local pathId = startGrid.id .. "_" .. endGrid.id
    local points = GridManager.GetCachePath(self.cityId, pathId)
    if nil ~= points then
        return points
    elseif self.cachePaths[pathId] then
        return self.cachePaths[pathId]
    else
        return self:CreateCachPath(startGrid, endGrid, isNormal)
    end
end

--获取区域内路径
function PathFinder:GetZonePath(grid, isOut, isNormal)
    local ret = false
    local door = nil
    local pathPoints = nil
    local doors = GridManager.GetGridsByZoneId(self.cityId, grid.zoneId, GridMarker.Door)
    --先判断是否有缓存
    for i = 1, #doors do
        local paths = nil
        local pathId = nil
        if isOut then
            pathId = grid.id .. "_" .. doors[i].id
        else
            pathId = doors[i].id .. "_" .. grid.id
        end
        paths = GridManager.GetCachePath(self.cityId, pathId)
        if paths then
            if pathPoints then
                if pathPoints:Count() > paths:Count() then
                    pathPoints = paths
                    door = doors[i]
                end
            else
                pathPoints = paths
                door = doors[i]
            end
        end
    end
    --没有缓存在A星计算
    if nil == door then
        for i = 1, #doors do
            local paths = nil
            if isOut then
                paths = self:CreateCachPath(grid, doors[i], isNormal)
            else
                paths = self:CreateCachPath(doors[i], grid, isNormal)
            end
            if paths then
                if pathPoints then
                    if pathPoints:Count() > paths:Count() then
                        pathPoints = paths
                        door = doors[i]
                    end
                else
                    pathPoints = paths
                    door = doors[i]
                end
            end
        end
    end
    if door then
        ret = true
    end
    return ret, door, pathPoints
end

function PathFinder:GetPath(startGrid, endGrid, isNormal)
    if isNormal then
        if nil == startGrid or nil == endGrid then
            print("[error]" .. debug.traceback())
        end
        if startGrid.zoneId ~= endGrid.zoneId then
            local startPathPoints = nil
            local endPathPoints = nil
            local startDoor, endDoor = nil, nil
            if Utils.IsCacheGrid(startGrid.markerType) then
                startDoor = startGrid
            elseif startGrid.zoneId ~= "" then
                local ret, door, pathPoints = self:GetZonePath(startGrid, true, isNormal)
                if ret then
                    startDoor = door
                    startPathPoints = pathPoints
                end
            else
                startDoor = startGrid
            end
            if Utils.IsCacheGrid(endGrid.markerType) then
                endDoor = endGrid
            elseif endGrid.zoneId ~= "" then
                local ret, door, pathPoints = self:GetZonePath(endGrid, false, isNormal)
                if ret then
                    endDoor = door
                    endPathPoints = pathPoints
                end
            else
                endDoor = endGrid
            end
            if startDoor and endDoor then
                local pathPoints = List:New()
                if startPathPoints then
                    pathPoints:AddRange(startPathPoints)
                end
                local points = self:GetCachePath(startDoor, endDoor, isNormal)
                if nil == points then
                    points = self:GetCachePath(startDoor, endDoor, isNormal)
                end
                pathPoints:AddRange(points)
                if endPathPoints then
                    pathPoints:AddRange(endPathPoints)
                end
                return pathPoints
            end
        end
    end
    return self:GetCachePath(startGrid, endGrid, isNormal)
end

--根据起始格子点获取行走路线
function PathFinder:GetPathByGrid(_startGrid, _endGrid, isNormal)
    self.openList:Clear()
    self.closeList = {}
    self.canUseSet = {}
    self.canUseStairs = true
    self.change_pos = _startGrid.xIndex < _endGrid.xIndex or _startGrid.zIndex < _endGrid.zIndex
    local startGrid, endGrid = nil, nil
    if self.change_pos then
        startGrid, endGrid = _endGrid, _startGrid
    else
        startGrid, endGrid = _startGrid, _endGrid
    end
    self.isNormal = isNormal
    local priorityMainRoad = _startGrid.zoneId ~= _endGrid.zoneId and _endGrid.markerType == GridMarker.Door

    self.canUseSet[ZoneType.MainRoad] = 1
    if not self.canUseSet[_startGrid.zoneType] then
        self.canUseSet[_startGrid.zoneType] = 1
    end
    if not self.canUseSet[_endGrid.zoneType] then
        self.canUseSet[_endGrid.zoneType] = 1
    end

    self.openList:Add(startGrid)

    local currGrid = nil
    local function EachNeighborGrid(nextGrid)
        local gCost = 0
        if priorityMainRoad then
            gCost =
                CalculateGridCostCostG(nextGrid, currGrid) + currGrid.pCost +
                CalculateGridExtraCost(currGrid, nextGrid, endGrid)
        else
            gCost = CalculateGridCostCostG(nextGrid, currGrid) + CalculateGridExtraCost(currGrid, nextGrid, endGrid)
        end
        if self.openList:Contains(nextGrid) then
            if gCost < nextGrid.gCost then
                nextGrid.parent = currGrid
                nextGrid.gCost = gCost
                nextGrid.fCost = nextGrid.gCost + nextGrid.hCost
            end
        else
            nextGrid.parent = currGrid
            nextGrid.gCost = gCost
            nextGrid.hCost = CalculateGridCostH(nextGrid, endGrid)
            nextGrid.fCost = nextGrid.gCost + nextGrid.hCost
            self.openList:Add(nextGrid)
        end
    end
    --循环遍历
    while self.openList:Count() > 0 and not self.closeList[endGrid.id] do
        currGrid = self.openList[1]
        self.openList:Remove(currGrid)
        self.closeList[currGrid.id] = currGrid
        for key, value in pairs(self:FindNeighborGrids(currGrid)) do
            EachNeighborGrid(value)
            self.openList:Sort(CompareFunc)
        end
    end
    
    --print("[error]" .. "from:" .. _startGrid.xIndex .. "," .. _startGrid.zIndex .. "|" .. "from:" .. _endGrid.xIndex .. "," .. _endGrid.zIndex)
    return self:GetPathList(endGrid)
end

--按照4方向搜索周围
function PathFinder:FindNeighborGrids(currGrid)
    local neighborGrids = {}
    if currGrid.markerType == GridMarker.Stairs and self.canUseStairs then
        local grid = nil
        if currGrid.serialNumber == 1 then
            grid = GridManager.GetGridByZoneId(self.cityId, currGrid.zoneId, GridMarker.Stairs, -1, 2)
        else
            grid = GridManager.GetGridByZoneId(self.cityId, currGrid.zoneId, GridMarker.Stairs, -1, 1)
        end
        neighborGrids[grid.id] = grid
        self.canUseStairs = false
    else
        if currGrid.cs == nil or #currGrid.cs == 1 then
            for key, value in pairs(SearchDirection) do
                --local gridKey = Utils.PositionToGridId(currGrid.xIndex + value.x, currGrid.yIndex, currGrid.zIndex + value.z)
                local gridKey = Utils.PositionToGridId(currGrid.xIndex + value.x, 0, currGrid.zIndex + value.z)
                self:EachDirection(gridKey, neighborGrids)
            end
        else
            for key, value in pairs(currGrid.cs) do
                self:EachDirection(value, neighborGrids)
            end
        end
    end
    return neighborGrids
end

function PathFinder:EachDirection(key, neighborGrids)
    if self.closeList[key] then
        return
    end
    local grid = GridManager.GetGridById(self.cityId, key)
    if not grid then
        return
    end
    if not self.canUseSet[grid.zoneType] then
        return
    end
    if not grid:IsUnlock() then
        return
    end
    if self.isNormal and grid.effectType ~= GridEffect.Path_1 then
        return
    end
    neighborGrids[grid.id] = grid
end

function PathFinder:GetPathList(parent)
    local pathPoints = List:New()
    while parent do
        if parent.markerType == GridMarker.Stairs then
            local nextStairs = parent.parent
            if nextStairs.markerType == GridMarker.Stairs then
                pathPoints:AddRange(self:GetCachePath(parent, nextStairs, true))
            else
                pathPoints:Add(parent.position)
            end
            parent = nextStairs.parent
        else
            pathPoints:Add(parent.position)
            parent = parent.parent
        end
    end
    for k, v in pairs(self.openList) do
        v:ResetGrid()
    end
    self.openList:Clear()
    for k, v in pairs(self.closeList) do
        v:ResetGrid()
    end
    self.closeList = {}
    if self.change_pos then
        return pathPoints
    else
        return pathPoints:Reverse()
    end
end
