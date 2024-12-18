--封装Unity Vector3方法
local math = math
local acos = math.acos
local sqrt = math.sqrt
local max = math.max
local min = math.min
local clamp = math.clamp
local cos = math.cos
local sin = math.sin
local abs = math.abs
local sign = math.sign
local rad2Deg = 57.295779513082
local deg2Rad = 0.017453292519943

local Vector3 = {}
Vector3.__index = Vector3

function Vector3.New(x, y, z)
    local t = {x = x or 0, y = y or 0, z = z or 0}
    setmetatable(t, Vector3)
    return t
end

local _new = Vector3.New

Vector3.Up = function()
    return _new(0, 1, 0)
end
Vector3.Down = function()
    return _new(0, -1, 0)
end
Vector3.Right = function()
    return _new(1, 0, 0)
end
Vector3.Left = function()
    return _new(-1, 0, 0)
end
Vector3.Forward = function()
    return _new(0, 0, 1)
end
Vector3.Back = function()
    return _new(0, 0, -1)
end
Vector3.Zero = function()
    return _new(0, 0, 0)
end
Vector3.One = function()
    return _new(1, 1, 1)
end

function Vector3.Normalize(v)
    local x, y, z = v.x, v.y, v.z
    local num = sqrt(x * x + y * y + z * z)
    if num > 1e-5 then
        return setmetatable({x = x / num, y = y / num, z = z / num}, Vector3)
    end
    return setmetatable({x = 0, y = 0, z = 0}, Vector3)
end

function Vector3.Dot(lhs, rhs)
    return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
end

function Vector3.Copy(other)
    return _new(other.x, other.y, other.z)
end

function Vector3.Get(v)
    return v.x, v.y, v.z
end

function Vector3.AddFrom(v1, v2)
    local x = v1.x + v2.x
    local y = v1.y + v2.y
    local z = v1.z + v2.z
    return _new(x, y, z)
end

function Vector3.SubFrom(v1, v2)
    local x = v1.x - v2.x
    local y = v1.y - v2.y
    local z = v1.z - v2.z
    return _new(x, y, z)
end

function Vector3.Angle(from, to)
    return acos(clamp(Vector3.Dot(from:Normalize(), to:Normalize()), -1, 1)) * rad2Deg
end

function Vector3.Distance(va, vb)
    return sqrt((va.x - vb.x) ^ 2 + (va.y - vb.y) ^ 2 + (va.z - vb.z) ^ 2)
end

function Vector3.Lerp(from, to, t)
    t = clamp(t, 0, 1)
    return _new(from.x + (to.x - from.x) * t, from.y + (to.y - from.y) * t, from.z + (to.z - from.z) * t)
end

function Vector3.Scale(a, b)
    local x = a.x * b.x
    local y = a.y * b.y
    local z = a.z * b.z
    return _new(x, y, z)
end

function Vector3:Set(x, y, z)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    return self
end

function Vector3:Add(v)
    self.x = self.x + v.x
    self.y = self.y + v.y
    self.z = self.z + v.z
    return self
end

function Vector3:Sub(v)
    self.x = self.x - v.x
    self.y = self.y - v.y
    self.z = self.z - v.z
    return self
end

function Vector3.Cross(lhs, rhs)
    local x = lhs.y * rhs.z - lhs.z * rhs.y
    local y = lhs.z * rhs.x - lhs.x * rhs.z
    local z = lhs.x * rhs.y - lhs.y * rhs.x
    return _new(x, y, z)
end

function Vector3:Equals(other)
    return self.x == other.x and self.y == other.y and self.z == other.z
end

function Vector3:SetNormalize()
    local num = sqrt(self.x * self.x + self.y * self.y + self.z * self.z)

    if num > 1e-5 then
        self.x = self.x / num
        self.y = self.y / num
        self.z = self.z / num
    else
        self.x = 0
        self.y = 0
        self.z = 0
    end

    return self
end

function Vector3:SqrMagnitude()
    return self.x * self.x + self.y * self.y + self.z * self.z
end

function Vector3:MulQuat(quat)
    local num = quat.x * 2
    local num2 = quat.y * 2
    local num3 = quat.z * 2
    local num4 = quat.x * num
    local num5 = quat.y * num2
    local num6 = quat.z * num3
    local num7 = quat.x * num2
    local num8 = quat.x * num3
    local num9 = quat.y * num3
    local num10 = quat.w * num
    local num11 = quat.w * num2
    local num12 = quat.w * num3

    local x = (((1 - (num5 + num6)) * self.x) + ((num7 - num12) * self.y)) + ((num8 + num11) * self.z)
    local y = (((num7 + num12) * self.x) + ((1 - (num4 + num6)) * self.y)) + ((num9 - num10) * self.z)
    local z = (((num8 - num11) * self.x) + ((num9 + num10) * self.y)) + ((1 - (num4 + num5)) * self.z)

    self:Set(x, y, z)
    return self
end

return Vector3
