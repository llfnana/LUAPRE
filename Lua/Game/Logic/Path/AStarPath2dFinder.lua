------------------------------------------------------------------------
--- @desc A星算法寻路
--- @author chenyl
------------------------------------------------------------------------

--region -------------引入模块-------------
local AStarPathNode = require "Game/Logic/Path/AStarPath2dNode"
--endregion

--region -------------数据定义-------------
--endregion
local PathCache = require "Game/Logic/Path/PathCache"

---@class AStar.PathFinder A星算法寻路
local Finder = class('AStarPath2dFinder')

function Finder:ctor(map)
    self._openSet = nil ---@type Home.MapCell[] 未处理的节点
    self._closedSet = nil ---@type table<Home.MapCell, boolean> 已处理的节点
    self._costSoFar = nil ---@type table<Home.MapCell, number> 从起点到当前节点的代价

    self._map = map ---@type City.MapCtrl
end

---启发函数
---@param start Home.MapCell
---@param goals Home.MapCell|Home.MapCell[]
---@return number
function Finder:_heuristic(start, goals)
    if ListUtil.isArray(goals) then
        local _min = nil
        for _, goal in ipairs(goals) do
            local _h = start.position:distance(goal.position)
            if _min == nil or _h < _min then
                _min = _h
            end
        end
        return _min
    else
        return start.position:distance(goals.position)
    end
end


---find the shortest path between the start and end nodes using the A* algorithm
---@param start Home.MapCell
---@param goal Home.MapCell|Home.MapCell[]
---@param range number @default 0
---@param isAddCache bool 是否写到缓存
---@return Home.MapCell[]
---
local count = 0
function Finder:findPath(start, goal, range, isAddCache, isGetCache)
    local path
    local cityId = DataManager.GetCityId()
    if isGetCache then 
        path = PathCache.GetCache(start, goal, cityId)
        if path ~= nil then 
            return path
        end
    end

    range = range or 0
    self._openSet = { start }
    self._closedSet = {}
    self._costSoFar = { [start] = 0 }
    local cameFrom = {} --对于每个节点，跟踪其父节点

    -- add the start node to the open set
    --self:_openInsert(start, 0, self:_heuristic(start, goal))

    ---@param nc Home.MapCell
    ---@param current Home.MapCell
    local doEachNeighbor = function (nc, current)
        -- 判断格子是否阻挡或者已经处理过
        if nc:isBlock() or self._closedSet[nc] then
            return
        end

        local currentG = self._costSoFar[current]
        if self:_openInsert(nc, currentG+1, goal) then
            cameFrom[nc] = current
        end
    end

    local reachCell = nil ---@type Home.MapCell 到达格子

    while #self._openSet > 0 do
        local current = self:_openPop()

        -- 如果当前节点到目标节点的距离小于等于指定的距离，则认为到达目标节点
        -- 注：这里的距离可以使用启发值
        if self:_heuristic(current, goal) <= range then
            reachCell = current
            break
        end
        -- if the current node is the goal node, then we have found the path
        --if current.cell == endCell then
        --    return self:reconstructPath(cameFrom, current)
        --end

        -- 添加到已处理列表
        self._closedSet[current] = true

        self._map:eachNeighbor(current, doEachNeighbor)
    end

    self._openSet = nil
    self._closedSet = nil
    self._costSoFar = nil

    if reachCell ~= nil then
        path = self:reconstructPath(cameFrom, reachCell)
        if isAddCache then 
            local positions = PathCache.AddCache(start, goal, cityId, path)

            count = count + (positions and #positions or 0)
            if count % 50 == 0 then 
                print("[path] position count =  " .. count)
            end
        end
    end

    return path
end

---@param cell Home.MapCell
---@param g number 起始节点到当前节点的代价
---@return boolean
function Finder:_openInsert(cell, g, goal)
    local _size = #self._openSet --数组大小
    local insertIdx = nil --插入位置
    local currentF = g + self:_heuristic(cell, goal)
    for i=1, _size do
        local _inCell = self._openSet[i]
        local _inCellG = self._costSoFar[_inCell]
        if _inCell == cell then
            --如果在nodes中，并且G权重没有更小 直接返回
            if g >= _inCellG then
                return false
            end
            table.remove(self._openSet, i) --移除，重新插入
            insertIdx = i
            break
        end
        --判断插入位置的索引, 只取第一次满足条件的值
        local insertF = _inCellG + self:_heuristic(_inCell, goal)
        if insertIdx == nil and currentF <= insertF then
            if currentF < insertF or g >= _inCellG then
                insertIdx = i
            end
        end
    end

    insertIdx = insertIdx or (_size + 1) --插在最后面
    table.insert(self._openSet, insertIdx, cell) --数组插入
    self._costSoFar[cell] = g

    return true
end

---@return Home.MapCell
function Finder:_openPop()
    return table.remove(self._openSet, 1)
end

---@param cameFrom table<Home.MapCell, Home.MapCell>
---@param current Home.MapCell
---@return Home.MapCell[]
function Finder:reconstructPath(cameFrom, current)
    -- create a table to store the path from the end node to the start node
    local path = {}

    -- loop through the parent nodes from the end node to the start node, adding each node to the path
    while current do
        --第一个节点不用当成路径
        if not cameFrom[current] then
            break
        end
        table.insert(path, 1, current)
        current = cameFrom[current]
    end

    -- return the path
    return path
end

return Finder