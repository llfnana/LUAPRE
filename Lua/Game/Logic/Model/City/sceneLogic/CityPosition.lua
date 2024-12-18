---@class City.Position 地图的坐标
local Position = { x = nil, y = nil }
Position.__index = Position

Position.__add = function(src, dst)
    return Position.new(src.x + dst.x, src.y + dst.y)
end

--- 从一个Position对象中减去另一个Position对象
---@param src Home.Position 被减数的Position对象
---@param dst Home.Position 减数的Position对象
---@return Home.Position 两个Position对象坐标差值的新Position对象
Position.__sub = function(src, dst)
    return Position.new(src.x - dst.x, src.y - dst.y)
end

--重写 == 的比较方法
Position.__eq = function(lhs, rhs)
    return lhs.x == rhs.x --列相等
        and lhs.y == rhs.y --行相等
end

function Position.new(x, y)
    local instance = { x = x, y = y }
    setmetatable(instance, Position)
    return instance
end


----坐标方向
--local Dir = {
----    Right = 1,
----    Up = 2,
----    Left = 3,
----    Down = 4,
--      Up =   1,
--      UpRight =  2,
--      Right =  3,
--      DownRight = 4 ,
--      Down = 5,
--      DownLeft =  6,
--      Left =  7 ,
--      UpLeft =  8
--}
local Dir = {
    Up = 1,
    Right = 2,
    Down = 3,
    Left = 4,
}
Position.Dir = Dir
--所有方向
--Position.AllDirs = { 
----    [Dir.Right] = Position.Right,
----    [Dir.Up] = Position.Up,
----    [Dir.Left] = Position.Left,
----    [Dir.Down] = Position.Down 
--      [Dir.Up] =   Position.Up ,
--      [Dir.UpRight] =  Position.UpRight ,
--      [Dir.Right] =   Position.Right,
--      [Dir.DownRight] =  Position.DownRight ,
--      [Dir.Down] =   Position.Down,
--      [Dir.DownLeft] =   Position.DownLeft,
--      [Dir.Left] =  Position.Left ,
--      [Dir.UpLeft] =  Position.UpLeft 
--}
---所有方向（枚举）
Position.AllDirs = { Dir.Up, Dir.Right, Dir.Down, Dir.Left }

--方向常量
Position.None = Position.new(0, 0)
Position.Up = Position.new(0, 1)
Position.UpRight = Position.new(1, 1)
Position.Right = Position.new(1, 0)
Position.DownRight = Position.new(1, -1)
Position.Down = Position.new(0, -1)
Position.DownLeft = Position.new(-1, -1)
Position.Left = Position.new(-1, 0)
Position.UpLeft = Position.new(-1, 1)


Position.DirPositions = { Position.Up, Position.Right, Position.Down, Position.Left }

function Position:distance(pos)
    return math.abs(self.x - pos.x) + math.abs(self.y - pos.y)
end

function Position:flip()
    self.x = -self.x
    self.y = -self.y
end

function Position:normalize()
    self.x = self.x == 0 and 0 or self.x / math.abs(self.x)
    self.y = self.y == 0 and 0 or self.y / math.abs(self.y)

    return self
end

---转换成方向枚举
---@return City.PositionDir
function Position:toDir()
    if self.y >= math.abs(self.x) then
        return Dir.Up
    elseif self.x > math.abs(self.y) then
        return Dir.Right
    elseif -self.y >= math.abs(self.x) then
        return Dir.Down
    elseif -self.x > math.abs(self.y) then
        return Dir.Left
    end
end

--根据两点位置返回游戏逻辑方向 上0，右上1，右2，右下3，下4，左下5，左6，左上7
function Position:GetLogicDirection(sx,sy,tx,ty)
    local dx = tx - sx
    local dy = ty - sy
    if(dy == 0)then
        if(dx > 0)then
            return 2 --右
        else
            return 6 --左
        end
    end

    local _dir = nil
    local dir = dx/dy
    if(dy > 0) then
        if dir < -2.414 then
            _dir = 6 --左
        elseif(dir < -0.414) then
            _dir = 7 --左上
        elseif(dir <= 0.414) then
            _dir = 0 --上
        elseif(dir <= 2.414)then
            _dir = 1--右上
        else
            _dir = 2--右
        end   
    else
        if dir < -2.414 then
            _dir = 2--右
        elseif(dir < -0.414) then
            _dir = 3--右下
        elseif(dir <= 0.414) then
            _dir = 4--下
        elseif(dir <= 2.414)then
            _dir = 5--左下
        else
            _dir = 6--左
        end   
    end
    return _dir
end

---@return number
function Position:hash()
    return Position.gHash(self.x, self.y)
end

function Position:toList()
    return { self.x, self.y }
end

function Position:toString()
    return string.format("{x:%s, y:%s}", self.x, self.y)
end

--region 静态方法

function Position.getDirPos(dir)
    if dir == Dir.Up then
        return Position.Up
    elseif dir == Dir.UpRight then
        return Position.UpRight
    elseif dir == Dir.Right then
        return Position.Right
    elseif dir == Dir.DownRight then
        return Position.DownRight
    elseif dir == Dir.Down then
        return Position.Down
    elseif dir == Dir.DownLeft then
        return Position.DownLeft
    elseif dir == Dir.Left then
        return Position.Left
    elseif dir == Dir.UpLeft then
        return Position.UpLeft

    end
    return Position.None
end

local HASH_BASE = 1000 --取决于最大的宽高值

function Position.gHash(x, y)
    --return HASH_BASE * (x - 1) + y
    return HASH_BASE * x + y

end

---反Hash，转换成坐标
---@return number, number
function Position.rePos(hash)
    --local x = math.floor(hash / HASH_BASE) + 1
    local x = math.floor(hash / HASH_BASE) 
    local y = hash % HASH_BASE
    return x, y
end

-----@return number
--function Position:hashKey()
--    return self.x * 10 + self.y
--end

return Position