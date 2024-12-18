
--region -------------引入模块-------------
local cjson = require "cjson"
--endregion

--region -------------默认参数-------------
local module = {}

module.DEFAULT = setmetatable({}, {
	__newindex = function ()
		error('禁止向 default table 写入数据')
	end
})

--endregion

--region -------------私有变量-------------
local fn = {}
--endregion

--region -------------导出函数-------------

function module.default(list)
    return list or module.DEFAULT
end

---查询数组有效长度
function module.length(list)
	local length = 0
	for _, v in pairs(list) do
		if v ~= nil then
			length = length + 1
		end
	end
	return length
end

---table赋值（t2 -> t1）
function module.assign(t1, t2)
	for k, v in pairs(t2) do
		--if GameUtil.isTable() then
		--	t1[k] = t1[k] or {}
		--	module.assign(t1[k], v)
		--else
			t1[k] = v
		--end
	end
	return t1
end

---遍历数组，对每个元素进行操作
---@generic T
---@param list T[]
---@param func fun(data: T, index: number)
function module.foreach(list, func, ...)
	if list == nil then
		return
	end
	for i, v in ipairs(list) do
		func(v, i, ...)
	end
end

---反向遍历数组，对每个元素进行操作（适用于涉及到数组操作之后就删除元素的情况）
---@generic T
---@param list T[]
---@param func fun(data: T, index: number)
function module.reverseForeach(list, func, ...)
	for i = #list, 1, -1 do
		if list[i] then
			func(list[i], i, ...)
		end
	end
end

---遍历数组，对每个元素进行操作并返回新的数组
---@generic T
---@param list T[]
---@param func fun(data: T, index: number)
---@return table
function module.map(list, func)
	local result = {}
	for i, v in ipairs(list) do
		if v ~= nil then
			table.insert(result, i, func(v, i))
		end
	end
	return result
end

---删除数组里指定范围的对象
---@generic T
---@param list T[]
---@param startIndex number
---@param endIndex number
function module.deleteRange(list, startIndex, endIndex)
	if list == nil then
		return
	end

	endIndex = endIndex or #list
	local count = math.abs(endIndex - startIndex) + 1
	for _ = 1, count do
		table.remove(list, startIndex)
	end
end

---删除数组里面某个项
---@generic T
---@param list T[]
---@param element any
---@return boolean
function module.delete(list, element)
	for i, v in ipairs(list) do
		if v == element then
			table.remove(list, i)
			return true
		end
	end
	return false
end

---删除数组中指定属性值的第一个元素
---@generic T
---@param list T[]
---@param attr string
---@param value any
---@return boolean
function module.deleteByAttr(list, attr, value)
	for i, v in ipairs(list) do
		if v[attr] and v[attr] == value then
			table.remove(list, i)
			return true
		end
	end
	return false
end

---唯一性增加:不存在才增加
---@generic T
---@param list T[]
---@param obj any
---@return boolean
function module.uniqueInsert(list, obj)
	if list == nil then
		error('list can not be nil')
		return false
	end
	for _, v in ipairs(list) do
		if v == obj then
			return false
		end
	end
	table.insert(list, obj)
	return true
end

---克隆Table
---@generic T, T2
---@param tab table<T, T2>
---@return table<T, T2>
function module.clone(tab)
	if not GameUtil.isTable(tab) then
		error('clone data is not a table')
		return tab
	end

	local result = {}
	for k, v in pairs(tab) do
		result[k] = v
	end
	return result
end

function module.cloneEx(list)
	if not GameUtil.isTable(list) then
		error('clone data is not a table')
		return list
	end

	local result = {}
	for k, v in pairs(list) do
		if GameUtil.isTable(v) then
			result[k] = module.cloneEx(v)
		else
			result[k] = v
		end
	end
	return result
end

---深度克隆
function module.cloneDeep(obj)
	local lookup_table = {}
	local function _copy(_obj)
		if type(_obj) ~= "table" then
			return _obj
		elseif lookup_table[_obj] then
			return lookup_table[_obj]
		end
		local new_table = {}
		lookup_table[_obj] = new_table
		for key, value in pairs(_obj) do
			new_table[_copy(key)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(_obj))
	end
	return _copy(obj)
end

---创建初始化数组
---@param len number
---@param initData any
function module.initList(len, initData)
	local result = {}
	len = len or 0
	for i = 1, len do
		result[i] = initData
	end
	return result
end

---判断表中是否包含某key
---@param hash table
---@param target any
---@return boolean
function module.containKey(hash, target)
	if hash and target then
		for k, _ in pairs(hash) do
			if k == target then
				return true
			end
		end
	end
	return false
end

---判断表里是否包含某值
---@param hash table
---@param target any
---@return boolean
function module.containValue(hash, target)
	if hash and target then
		for _, v in pairs(hash) do
			if v == target then
				return true
			end
		end
	end
	return false
end

---取交集
function module.intersection(t1, t2)
	local r = {}
	for i in pairs(t1) do
		for j in pairs(t2) do
			if t2[j] == t1[i] then
				r[#r + 1] = t1[i]
			end
		end
	end
	return r
end

---取一个随机值
function module.getRandomVal(t)
	if #t > 0 then
		return t[math.random(1, #t)]
	end
end

---根据权重取随机值. 权重位于表项的 power 字段中, 需要列表式
---@param t table
function module.getRandomValWithPower(t)
	local sum = 0
	for _, v in ipairs(t) do
		sum = sum + v.power
	end
	local counter = 0
	local randomFlag = math.random(1, sum)
	for i, v in ipairs(t) do
		counter = counter + v.power
		if counter >= randomFlag then
			return i
		end
	end
	return 1
end

---搜索数组中位置
---@generic T
---@param list T[]
---@param target T
function module.indexOf(list, target)
	for i = 1, #list do
		if list[i] == target then
			return i
		end
	end
	return -1
end

---两个数组进行拼接
---@generic T
---@param list1 T[]
---@param list2 T[]
---@return T[]
function module.concat(list1, list2)
	if list2 == nil then
		return list1
	end

	local result = {}
	for _, v in ipairs(list1) do
		table.insert(result, v)
	end
	for _, v in ipairs(list2) do
		table.insert(result, v)
	end
	return result
end

---数组合并(list2合并到list1)
---@generic T
---@param list1 T[]
---@param list2 T[]
---@return T[]
function module.merge(list1, list2, list3)
	if list2 == nil then
		return list1
	end

	fn.merge(list1, list2)
	fn.merge(list1, list3)

	return list1
end

---列表倒序
---@generic T
---@param list T[]
---@return T[]
function module.reverse(list)
	local tmp = {}
	for i = #list, 1, -1 do
		tmp[#tmp + 1] = list[i]
	end

	return tmp
end

---得到list中不与filterList列表元素重复的数据
---@generic T
---@param list T[] @原列表
---@param filterList T[] @过滤列表
---@return T[]
function module.filterRepeatItem(list, filterList)
	local filterResultList = {}
	for i = 1, #list do
		if module.indexOf(filterList, list[i]) == -1 then
			table.insert(filterResultList, list[i])
		end
	end
	return filterResultList
end

---得到子列表
---@generic T
---@param list T[] @列表
---@param startIndex number @开始索引
---@param endIndex number @结束索引
---@return T[] list
function module.getSubList(list, startIndex, endIndex)
	local subList = {}
	if endIndex < startIndex then
		return subList
	end
	for i = startIndex, endIndex do
		if list[i] ~= nil then
			table.insert(subList, list[i])
		end
	end
	return subList
end

---取最后一个元素
function module.getLast(list)
	if list == nil then
		return
	end
	return list[#list]
end

---通过索引获取元素
function module.get(list, idx)
	if list == nil then
		return
	end
	return list[idx]
end

---获取数组中指定属性值的第一个元素
---@generic T
---@param list T[]
---@param attr string
---@param value any
---@return T, number
function module.getByAttr(list, attr, value)
	if not list then
		return
	end

	for i, v in pairs(list) do
		if v[attr] == value then
			return v, i
		end
	end
end

---根据路径获取表中的值（不存在返回nil）
---@param tab table
---@param path string 路径，以.分割，如：a.b.c
function module.getByPath(tab, path)
	local paths = string.split(path, ".")
	local result = tab
	for _, v in ipairs(paths) do
		result = result[v]
		if result == nil then
			return
		end
	end
	return result
end

function module.getByPathOrDefault(tab, path)
	local result = module.getByPath(tab, path)
	if result == nil then
		return module.DEFAULT
	end
	return result
end

---@generic T
---@param list T[]
---@param idx number
---@return T
function module.getOrDefault(list, idx)
    return module.get(list, idx) or module.DEFAULT
end

---获取元素（如果没有，取最后一个）
---@generic T
---@param list T[]|table<number, T> 数组
---@param idx1 number 索引1
---@param idx2 number 索引2
---@return T
function module.getOrLast(list, idx1, idx2)
	if list == nil then
		return list
	end

	local rt = list[idx1] or list[#list]
    if idx2 == nil then
        return rt
    end

    return rt[idx2] or rt[#list]
end

---加入一个元素
function module.append(list, obj)
	if list ~= nil then
		table.insert(list, obj)
	else
		error('追加列表元素失败，正在往空列表追加元素！')
	end
end

---列表过滤
---@generic T
---@param list T[]
---@param filterFunc fun(t: T): boolean
---@return T[]
function module.filter(list, filterFunc)
	local result = {}
	for i = 1, #list do
		if (filterFunc(list[i])) then
			table.insert(result, list[i])
		end
	end
	return result
end

--[[
	从from拷贝数据到to
	@param table from
	@param table to
--]]
function module.copy(from, to)
	for k, v in pairs(from) do
		to[k] = v
	end
end

---数据拼接
---@param list string[]
---@param tag string
---@return string
function module.join(list, tag)
	local result
	tag = tag or ','
	for _, v in ipairs(list) do
		if result == nil then
			result = v
		else
			result = StringUtil.format('%s%s%s', result, tag, v)
		end
	end
	return result
end

---生成递增的数组
function module.getIncreaseList(startValue, endValue)
	if startValue > endValue then
		return {}
	end
	local result = {}
	for i = startValue, endValue do
		result[startValue - i + 1] = startValue
	end
	return result
end

---从第一个元素开始对比两者的大小,要保证两者的数据的长度一致
function module.cmpList(a, b)
	for i, _ in ipairs(a) do
		if a[i] ~= b[i] then
			return a[i] < b[i]
		end
	end
	return true
end

---针对键值不是从1开始的数据，做到生成一个键值从1开始的表映射到对应的键值
function module.keyMap(list)
	if list == nil then
		return
	end
	local keyList = {}
	local index = 1
	for k, _ in pairs(list) do
		keyList[index] = k
		index = index + 1
	end

	---給到外部的key保证是顺序的
	table.sort(keyList, function(a, b)
		return a < b
	end)
	return keyList
end

--- 安全地取表格中的值, 防止数组越界
---@param tbl table
---@param ele string
---@param index number
function module.safeGet(tbl, ele, index)
	if tbl[index] == nil then
		return tbl[#tbl][ele]
	else
		return tbl[index][ele]
	end
end

--- 快速创建指定的数组
---@param start number 开始数值
---@param count number 多少数量
---@return number[]
function module.initNumList(start, count)
	local finish = start + count - 1
	local list = {}
	for i = start, finish do
		table.insert(list, i)
	end
	return list
end

---根据权重随机
---@generic T
---@param elementList T[]
---@param powerList number[] | nil
function module.randomList(elementList, powerList)
	if elementList == nil then
		error('数组随机错误，元素数组不能为空')
		return
	end

	if powerList == nil then
		local random = math.random(1, #elementList)
		return elementList[random]
	end

	if #elementList ~= #powerList then
		error('数组随机错误，元素数组和权重数组元素数量不同')
		return
	end

	local list = {}
	local total = 0
	for _, v in ipairs(powerList) do
		total = total + v
		table.insert(list, total)
	end

	local random = math.random(1, total)
	local targetIndex
	for k, v in ipairs(list) do
		if v >= random then
			targetIndex = k
			break
		end
	end
	return elementList[targetIndex]
end

---清空列表
function module.clear(list)
	if list then
		for i, _ in pairs(list) do
			list[i] = nil
		end
	end
end

---通过主键合并列表
---@param list1 table 列表1
---@param list2 table 列表2
---@return table
function module.mergeByKey(list1, list2)
	if list1 == nil or list2 == nil then
		return list1 or list2
	end
	local Clone = require('Clone')
	---避免改变原来的数据
	list1 = Clone.clone(list1)
	list2 = Clone.clone(list2)
	for k1, v1 in pairs(list1) do
		for k2, v2 in pairs(list2) do
			if k1 == k2 then
				list1[k1] = v1 + v2
				list2[k1] = nil
			end
		end
	end

	if list2 ~= nil then
		for k, v in pairs(list2) do
			list1[k] = v
		end
	end
	return list1
end

---累加KV的值
function module.sumKV(list, key, val)
	if key == nil or val == nil then
		return
	end

	local srcVal = list[key] or 0
	list[key] = srcVal + val
end

---累加：把map2的val累加到map1对应的key上
function module.sum(map1, map2)
	for k, v in pairs(map2) do
		local srcV = map1[k] or 0
		map1[k] = srcV + v
	end
end

---数据导出字符串
---@param t table|userdata
---@param maxDepth number 最大深度，限制递归的层次，默认值为20
function module.dump(t, maxDepth)
	return fn.dump(t, maxDepth or 20)
end

--[[
	存在指定内容
	@param table t
	@param * value
--]]
function module.exists(t, value)
	for _, v in pairs(t) do
		if v == value then
			return true
		end
	end

	return false
end

---table转字符串
---@param obj table
function module.serialize(obj)
	--webgl平台下，dump方法不支持，只能用cjson
	if Application.platform == UnityEngine.RuntimePlatform.WebGLPlayer then
		return cjson.encode(obj)
	end

	return fn.table2String(obj)
end

---字符串转table
function module.deserialize(str)
	if StringUtil.isEmpty(str) then
		return nil
	end

	--webgl平台下，load方法不支持，只能用cjson
	if Application.platform == UnityEngine.RuntimePlatform.WebGLPlayer then
		return cjson.decode(str)
	end

	local loadFun = load('return ' .. str, 't')
	if loadFun == nil then
		return nil
	end

	return loadFun()
end

---是否是数组{ [1]=?, [2]=?, ... }
---@return boolean
function module.isArray(t)
	if not GameUtil.isTable(t) then
		return false
	end

	local n = #t
	for i, _ in pairs(t) do
		if not GameUtil.isNumber(i) then
			return false
		end

		if i > n then
			return false
		end
	end

	return true
end

---pairs遵从指定规律f顺序遍历,时间复杂度O(nlogn)
---@param t table 要遍历的表
---@param f function 排序规则
function module.pairsByKey(t, f)
	local a = {}

    for n in pairs(t) do
        a[#a + 1] = n
    end

    table.sort(a, f or nil)

    local i = 0
        
    return function()
        i = i + 1
        return a[i], t[a[i]]
    end
end
-- 对比新增数据
function module:valueReplace(new, old)
    for k, v in pairs(new) do
        if type(v) == "table" then
            old[k] = old[k] or {}
            self:valueReplace(v, old[k])
        else
            old[k] = v
        end
    end
end

-- 对比删除数据
function module:valueDelete(new, old)
    for k, v in pairs(new) do
        if type(v) == "table" then
            old[k] = old[k] or {}
            self:valueDelete(v, old[k])
        else
            if v == 1 then old[k] = nil end
        end
    end
end
-- 对比数据是否发生变化
function module:checkDataChange(lastData, curData)
    -- dump(lastData)
    for k, v in pairs(lastData) do
        if curData == nil or curData[k] == nil then return false end
        if type(v) == "table" then
            if not self:checkDataChange(v, curData[k]) then
                return false
            end
        else
            if v ~= curData[k] then return false end
        end
    end

    for k, v in pairs(curData) do
        if lastData == nil or lastData[k] == nil then return false end
        if type(v) == "table" then
            if not self:checkDataChange(lastData[k], v) then
                return false
            end
        else
            if v ~= lastData[k] then return false end
        end
    end

    return true
end

--endregion

--region -------------私有函数-------------

function fn.merge(list1, list2)
	if list1 == nil or list2 == nil then
		return
	end

	for _, v in ipairs(list2) do
		table.insert(list1, v)
	end
end

---数据导出字符串
---@param t table|userdata
---@param maxDepth number 最大深度，限制递归的层次，默认值为20
---@param depth number 当前深度，初始0
function fn.dump(t, maxDepth, depth)
	depth = depth or 0

	if maxDepth > 0 and maxDepth < depth then
		return "\"{LimitLevel = ".. maxDepth .. "}\""
	end

	local typeStr = type(t)

	if typeStr == StringUtil.NIL then
		return StringUtil.NIL
	elseif typeStr == StringUtil.STRING then
		return '"' .. t .. '"'
	elseif typeStr == StringUtil.NUMBER then
		return tostring(t)
	elseif StringUtil == StringUtil.BOOLEAN then
		return tostring(t)
	elseif typeStr == StringUtil.USERDATA then
		return '"' .. tostring(t) .. '"'
	elseif typeStr == StringUtil.FUNCTION then
		return "[Function...]"
	elseif typeStr == "table" then
		local ks = {}
		local vs = {}
		local maxSpace = 0

		for k, v in pairs(t) do
			local index = #ks + 1
			if type(k) == StringUtil.STRING then
				ks[index] = "\"" .. k .. "\""
			elseif type(k) == StringUtil.NUMBER then
				ks[index] = k
			elseif type(k) == StringUtil.BOOLEAN then
				ks[index] = k
			elseif type(k) == StringUtil.USERDATA then
				ks[index] = k
			elseif type(k) == StringUtil.FUNCTION then
				ks[index] = "[Function]"
			elseif type(k) == StringUtil.TABLE then
				ks[index] = "{tab...}"
			--elseif type(k) == "thread" then
			else
				ks[index] = '"' .. tostring(k) .. '"'
			end

			ks[index] = "[" .. tostring(ks[index]) .. "]"
			vs[#vs + 1] = fn.dump(v, maxDepth, depth + 1)

			maxSpace = math.max(#ks[index], maxSpace)
		end

		local str = "{"
		for i = 1, #ks do
			if str ~= "" then
				str = str .. "\n"
			end

			local k = ks[i]

			str = str .. string.rep("\t", depth + 1)
					.. k .. string.rep(" ", maxSpace - #k)
					.. " = " .. vs[i] .. ","
		end
		return str .. "\n" .. string.rep("\t", depth) .. "}"
	--elseif type(t) == "thread" then
	--	return '"' .. tostring(t) .. '",'
	else
		return '"' .. tostring(t) .. '",'
	end
end

function fn.table2String(obj)
	local t = type(obj)
	if t == StringUtil.NUMBER then
		return obj
	elseif t == StringUtil.BOOLEAN then
		return tostring(obj)
	elseif t == StringUtil.STRING then
		--str = str .. string.format("%q", obj)
		return string.format("%q", obj) --"\"" .. obj .. "\""
	elseif t == StringUtil.TABLE then
		local str = "{"
		local isFirst = true
		for k, v in pairs(obj) do
			if isFirst then
				isFirst = false
			else
				str = str .. ","
			end
			str = str .. "[" .. fn.table2String(k) .. "]=" .. fn.table2String(v)
		end
		--local metatable = getmetatable(obj)
		--if metatable ~= nil and type(metatable.__index) == StringUtil.TABLE then
		--	for k, v in pairs(metatable.__index) do
		--		str = str .. "[" .. fn.table2String(k) .. "]=" .. fn.table2String(v) .. ",\n"
		--	end
		--end
		return str .. "}"
	elseif t == "nil" then
		return nil
	else
		Log.error("can not serialize a " .. t .. " type.")
		return StringUtil.EMPTY
	end
end

--endregion

return module
