------------------------------------------------------------------------
--- @desc 数字工具
--- @author chenyl
------------------------------------------------------------------------

--region -------------引入模块-------------
--endregion

--region -------------默认参数-------------
---导出函数
local module = {}

local TEN = 10 --十
local HUNDRED = 100 --百
local KILO = 1000 --千
local MEGA = KILO * KILO --百万
local GIGA = MEGA * KILO --十亿
local TERA = GIGA * KILO --万亿

module.TEN = TEN
module.HUNDRED = HUNDRED
module.KILO = KILO
module.maxinteger = 99999999999999
--module.MAX_VAL = 99999999999999
--endregion

--region -------------私有变量-------------
--endregion

--region -------------导出函数-------------

---随机概率（百分比）
function module.inRand(prob)
	return math.random(HUNDRED) <= prob
end

---随机概率（千分比）
function module.inRandMil(prob)
    return math.random(KILO) <= prob
end

---随机从数组取一个
---@generic T
---@param list T[]
---@return T
function module.rand(list)
	local idx = module.randIdx(list)
	if idx == nil then
		return
	end
	return list[idx]
end

---数组随机索引
---@return number
function module.randIdx(list)
	if list == nil or #list == 0 then
		return
	end
	return math.random(1, #list)
end

---计算占百分比（eg. v1=20, v2=50 -> 40%）
---@return number
function module.calcPercent(v1, v2)
    return v1 / v2 * HUNDRED
end

---乘以百分比（向上取整）
function module.ceilPercent(v, p)
	v = module.mulPercent(v, p)
    return math.ceil(v)
end

---乘以百分比
function module.mulPercent(v, p)
    return v * p / HUNDRED
end

---转换成比例（eg. 30 -> 0.3）
function module.toScale(val)
	return val / HUNDRED
end

---计算比例
---@param v1 number 数值
---@param v2 number 百分比
function module.calcScale(v1, v2)
	return v1 * module.toScale(v2)
end

---计算千分比加成
---@return number
function module.calcAddPmg(v, p)
	return v * (KILO + p) / KILO
end

---相乘
function module.mulFloor(v1, v2)
	if v1 == nil or v2 == nil then
		return v1
	end
	return math.floor(v1 * v2)
end

---乘以千分比
---@return number
function module.mulPermil(v, p)
    return v * p / KILO;
end

---乘以千分比（向下取整）
function module.mulPermilF(v, p)
    return math.floor(module.mulPermil(v, p))
end

---计算千分比
function module.calcPermil(v1, v2)
    return v1 / v2 * KILO;
end

---转换成千分值（eg. 300 -> 0.3）
function module.toPermil(v)
	if v == nil then
		return
	end
    return v / KILO
end

---保留三位小数，向下取整
function module.floor3(v)
	if v == nil then
		return
	end
	return math.floor(v * KILO) / KILO
end

---二进制与 是否满足
function module.isAnd(v1, v2)
	return bit.band(v1, v2) ~= 0
end

---取整数部分
function module.getIntPart(x)
	if x <= 0 then
		return math.ceil(x)
	end
	return math.floor(x)
end

---取整（eg. d=1 523 -> 520）
---@param d number 位数
function module.floor(v, d)
	local dv = 10 ^ d
	return math.floor(v / dv) * dv
end

---数值单位格式化（K,M,B,T）
function module.format(v)
	if v  < KILO then
		return tostring(v)
	end

	local suffixes = {'K', 'M', 'B', 'T'}
	local suffix = ''
	if v >= TERA then
		v = v / TERA
		suffix = suffixes[4]
	elseif v >= GIGA then
		v = v / GIGA
		suffix = suffixes[3]
	elseif v >= MEGA then
		v = v / MEGA
		suffix = suffixes[2]
	elseif v >= KILO then
		v = v / KILO
		suffix = suffixes[1]
	end
	-- 将小数向下取整到两位，防止四舍五入，例如9.995变成10
	v = math.floor(v * HUNDRED) / HUNDRED
	return string.format("%.2f", v):gsub("%.?0+$", "") .. suffix --
end

--endregion

--region -------------私有函数-------------

--endregion

return module