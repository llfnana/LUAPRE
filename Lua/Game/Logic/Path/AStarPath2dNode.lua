------------------------------------------------------------------------
--- @desc A星算法寻路 - 路径节点
--- @author chenyl
------------------------------------------------------------------------

---@class AStar.PathNode 路径节点
local PathNode = {}
---重写 == 的比较方法
---@param lhs AStar.PathNode
---@param rhs AStar.PathNode
PathNode.__eq = function(lhs, rhs)
    return lhs.cell == rhs.cell
end
PathNode.__index = PathNode

function PathNode.new(...)
    ---@type AStar.PathNode
    local instance = setmetatable({}, PathNode)
    instance:ctor(...)
    return instance
end

function PathNode:ctor(cell, g, h)
    self.cell = cell ---@type Home.MapCell

    self.g = g
    self.h = h
end

function PathNode:calcF()
    return self.g + self.h
end

return PathNode