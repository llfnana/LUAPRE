------------------------------------------------------------------------
--- @desc 模块描述
--- @author chenyl
------------------------------------------------------------------------

----------------------------- 引入模块 ------------------------------------

----------------------------- 默认参数 ------------------------------------
local module = {}    --导出函数

----------------------------- 私有变量 ------------------------------------

----------------------------- 导出函数 ------------------------------------

---将一个数限制在01内
---@param val number
---@return number
function module.clamp01(val)
	return math.max(math.min(val, 1), 0)
	--return GameUtilCS.clamp011(val)
end

---将一个数限制在范围内
---@return number
function module.clamp(val, min, max)
	if val < min then
		return min
	elseif val > max then
		return max
	else
		return val
	end
end

function module.ve3Lerp(v1, v2, t)
	t = module.clamp(t, 0, 1)
	local x = v1.x + (v2.x - v1.x) * t
	local y = v1.y + (v2.y - v1.y) * t
	local z = v1.z + (v2.z - v1.z) * t
	return x, y, z
end

---贝塞尔曲线公式
---@param sp Vector3 起点坐标
---@param ep Vector3 终点坐标
---@param t number 插值
--function module.getBezierPoint(sp, ep, t, cp)
--	local v1 = (1 - t) * (1 - t) --* sp
--	local v2 = 2 * t * (1 - t) --* cp
--	local v3 = t * t --* ep
--	--return v1 + v2 + v3
--
--	local x = v1 * sp.x + v2 * cp.x + v3 * ep.x
--	local y = v1 * sp.y + v2 * cp.y + v3 * ep.y
--	local z = v1 * sp.z + v2 * cp.z + v3 * ep.z
--
--	return x, y , z
--end

---贝塞尔二阶曲线
---@param p0 Vector3 起点
---@param p1 Vector3 控制点
---@param p2 Vector3 终点
---@param t number [0, 1]
---@return Vector3
function module.getBezierPoint(p0, p1, p2, t)
	t = math.max(math.min(t, 1), 0)
	return p0 * (1 - t) * (1 - t) + p1 * 2 * t * (1 - t) + p2 * t * t
end

---@param sp Vector3 起点
---@param ep Vector3 终点
function module.getBezierPath(sp, ep, degree)
	local dir = Vector3.Normalize(ep - sp)
	local vert = Vector3.Cross(Vector3.forward, dir)
	--local rd = math.random(0, 1) == 0 and -1 or 1
	degree = degree or 1 --曲线程度（正负表示上下）
	local ctrlPos = (sp + ep) / 2 + vert * degree

	local pointCount = 20
	local path = {}
	for i=1, pointCount do
		local t = i / pointCount
		table.insert(path, module.getBezierPoint(sp, ctrlPos, ep, t))
	end

	return path
end

function module.isFunction(obj)
	return type(obj) == StringUtil.FUNCTION
end

function module.isNumber(obj)
	return type(obj) == StringUtil.NUMBER
end

function module.isString(obj)
	return type(obj) == StringUtil.STRING
end

function module.isTable(obj)
	return type(obj) == StringUtil.TABLE
end

function module.isClass(obj)
	if not module.isTable(obj) then
		return false
	end
	return obj.__cname ~= nil
end

function module.isBoolean(obj)
	return type(obj) == StringUtil.BOOLEAN
end

function module.isInScreen(screenPos)
	return screenPos.x > 0 and screenPos.x < Screen.width
			and screenPos.y > 0 and screenPos.y < Screen.height
end

---计算源点到目标点的屏幕交点
---@param sourceX number 源点坐标X
---@param sourceY number 源点坐标Y
---@param target Vector3 目标点坐标
---@param offset number 向内偏移的距离
function module.calcScreenIntersection(sourceX, sourceY, target, offset)
	offset = offset or 0
	local screenWidth, screenHeight = Screen.width, Screen.height

	-- 计算到目标位置的向量
	local dirX, dirY = target.x - sourceX, target.y - sourceY
	-- 如果dirX为0，取一个很小的值
	dirX = dirX == 0 and Mathf.Epsilon or dirX
	-- 计算直线的斜率
	local slope = dirY / dirX

	--local edgePoint = Vector3.zero
	-- 检查与屏幕左边相交
	local leftIntersectY = sourceY + (-sourceX + offset) * slope
	--print('sol:', leftIntersectY, rightIntersectY, topIntersectX, bottomIntersectX)
	if dirX < 0 and leftIntersectY >= offset and leftIntersectY <= screenHeight - offset then
		return Vector3.New(offset, leftIntersectY, 0)
	end

	-- 检查与屏幕右边相交
	local rightIntersectY = sourceY + (screenWidth - sourceX - offset) * slope
	--print('sol:', rightIntersectY, dirX, offsetY)
	if dirX >= 0 and rightIntersectY >= offset and rightIntersectY <= screenHeight - offset then
		return Vector3.New(screenWidth - offset, rightIntersectY, 0)
	end

	-- 检查与屏幕上边相交
	local topIntersectX = sourceX + (screenHeight - sourceY - offset) / slope
	--print('sol2:', topIntersectX, dirY, offsetY)
	if dirY >= 0 and topIntersectX >= offset and topIntersectX <= screenWidth - offset then
		return Vector3.New(topIntersectX, screenHeight - offset, 0)
	end

	-- 检查与屏幕下边相交
	local bottomIntersectX = sourceX + (offset - sourceY) / slope
	if dirY < 0 and bottomIntersectX >= 0 and bottomIntersectX <= screenWidth then
		return Vector3.New(bottomIntersectX, offset, 0)
	end
end

---计算屏幕中点到目标的直线与屏幕边缘的交点
---@param offsetX number 向内偏移X的距离
function module.calcScreenIntersectionCenter(target, offsetX)
	local centerX, centerY = Screen.width / 2, Screen.height / 2
	return module.calcScreenIntersection(centerX, centerY, target, offsetX)
end

return module