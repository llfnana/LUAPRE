------------------------------------------------------------------------
--- @desc 字符串工具
--- @author chenyl
------------------------------------------------------------------------

--region -------------引入模块-------------
--endregion

--region -------------默认参数-------------
---导出函数
local module = {}

module.EMPTY = "" --空字符串
module.NIL = "nil"
module.STRING = "string"
module.NUMBER = "number"
module.BOOLEAN = "boolean"
module.USERDATA = "userdata"
module.FUNCTION = "function"
module.TABLE = "table"
module.PLUS = "+" --加号
--endregion

--region -------------私有变量-------------
local I18N = "i18n_"
local PATTERN_GSUB = "($%b{})"
local PATTERN_FORMULA = "($F%b())"
local PATTERN_GSUB2 = "($[T]*[%d]*%b{})"
local PATTERN_COLOR = "($C[%d]%b<>)"
--endregion

--region -------------导出函数-------------

---字符串是否为空
---@param str string 字符串
---@return boolean
function module.isEmpty(str)
    return str == nil or str == module.EMPTY
end

function module.notEmpty(str)
    return not module.isEmpty(str)
end

---字符串拼接
function module.concat(...)
    local tmp = module.EMPTY
    local args = { ... }
    for i = 1, #args do
        tmp = tmp .. args[i]
    end
    return tmp
end

---去除前后的空格
---@param str string
function module.trim(str)
    if not GameUtil.isString(str) then
        return str
    end
    return (string.gsub(str, "^%s*(.-)%s*$", "%1"))
end

---格式化字符串
---格式：测试${1}字符${2}串, "a", 100 -> 测试a字符100串
---@param str string
function module.format(str, ...)
    local args = { ... }

    str = str:gsub('($%b{})', function(w)
        local idx = tonumber(w:sub(3, -2))
        return args[idx] or w
    end)

    return string.format(str, ...)
end

---格式化 方式2
---格式：测试${key1}字符${key2}串, { key1="a", key2=100 } -> 测试a字符100串
function module.format2(str, arg)
    str = string.gsub(str, PATTERN_GSUB, function(w)
        local key = string.sub(w, 3, -2)
        return arg[key] or w
    end)

    return str
end

---格式化方式
---格式1，${} 替换字符串：测试${key1}字符${key2}串, { key1="a", key2=100 } -> 测试a字符100串
---格式2，$T*{}，千分替换：测试$T1{key1}%字符$T{key2}串, { key1=840, key2=100 } -> 测试84%字符10串
---@param cb fun(s: string):string 匹配回调函数
function module.format3(str, arg, cb)
    return string.gsub(str, PATTERN_GSUB2, function(w)
        local sign = module.EMPTY --标识
        local keyIdx = 3
        for i = 2, string.len(w) do
            local s = string.sub(w, i, i)
            if s == "{" then
                break
            end

            sign = sign .. s
            keyIdx = keyIdx + 1
        end

        local key = string.sub(w, keyIdx, -2)
        local val = arg[key] or w

        --没有标识，直接返回
        if sign == module.EMPTY then
            return val
        end

        val = tonumber(val)
        if val == nil then
            return w
        end

        if sign == "T2" then --取反，除10
            val = -val / MathUtil.TEN
        else
            val = val / MathUtil.TEN
        end

        return cb ~= nil and cb(val) or val
    end)
end

---格式化字符串
---格式：测试{0}字符{1}串, "a", 100 -> 测试a字符100串
---@param str string
function module.format4(str, ...)
    local args = { ... }

    str = str:gsub('{(%d+)}', function(match)
        local idx = tonumber(match)
        return args[idx + 1] or match
    end)

    --return string.format(str, ...)
    return str
end

---颜色格式化
function module.fmtColor(str)
    return string.gsub(str, PATTERN_COLOR, function(w)
        local idx = tonumber(string.sub(w, 3, 3))
        local str = string.sub(w, 5, -2)
        local color = GlobalConfig.COMMON_COLORS[idx]
        --Log.info('fmtColor:', idx, color, ListUtil.dump(GlobalConfig.COMMON_COLORS))
        if color == nil then
            return str
        end

        return "<color=#" .. color .. ">" .. str .. "</color>"
    end)
end

---字符串公式化处理
---标识D，十分化，eg. 测试$F(D,100)%字符串 -> 测试10%字符串
function module.formula(str)
    return string.gsub(str, PATTERN_FORMULA, function(w)
        local sign = string.sub(w, 4, 4)
        local val = string.sub(w, 6, -2)
        --Log.info('Formula：', w, sign, val)
        if sign == "D" then --除以10
            val = tonumber(val) / MathUtil.TEN
        end

        return val
    end)
end

--获取字符串的长度
function module.getStringLength(inputStr)
    if not inputStr or type(inputStr) ~= "string" or #inputStr <= 0 then
        return 0
    end

    local lenInByte = #inputStr
    local length = 0
    local i = 1
    while (i <= lenInByte) do
        local curByte = string.byte(inputStr, i)
        local byteCount = 1
        local addLength = 1
        if curByte > 0 and curByte <= 127 then
            byteCount = 1 --1字节字符
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2 --双字节字符
        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3 --汉字
            addLength = 2
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4 --4字节字符
        end

        i = i + byteCount           -- 重置下一字节的索引
        length = length + addLength -- 字符的个数（长度）
    end
    return length
end

---获取字符串字节长度
---@param str string
---@return number
function module.byteLen(str)
    local sections = { 0, 0xc0, 0xe0, 0xf0 }
    local totalLen = 0
    for i = 1, #str do
        local byte = string.byte(str, i)
        local charLen = 1
        for j = #sections, 1, -1 do
            if byte >= sections[j] then
                charLen = j
                break
            end
        end
        totalLen = totalLen + charLen
    end
    return totalLen
end

---数字星期转汉字星期
---@param number weekNum
---@return string
function module.weekNum2WeekCN(weekNum)
    local weekCN = ""
    if weekNum == 1 then
        weekCN = "一"
    elseif weekNum == 2 then
        weekCN = "二"
    elseif weekNum == 3 then
        weekCN = "三"
    elseif weekNum == 4 then
        weekCN = "四"
    elseif weekNum == 5 then
        weekCN = "五"
    elseif weekNum == 6 then
        weekCN = "六"
    elseif weekNum == 7 then
        weekCN = "日"
    end
    return weekCN
end

---@param str string 字符串
---@param sub string 字符串
function module.startWith(str, sub)
    return str:sub(1, string.len(sub)) == sub
end

---计算千分比
---@param val number 数字
function module.calcPermillage(val)
    if type(val) == "number" then
        local permillageVal = val * 0.1
        local permillageStr = 0
        if math.floor(permillageVal) < permillageVal then
            permillageStr = module.format("%.1f%%", permillageVal)
        else
            permillageStr = module.format("%d%%", permillageVal)
        end
        return permillageStr
    end
    return nil
end

--endregion

--region -------------私有函数-------------

--endregion

return module
