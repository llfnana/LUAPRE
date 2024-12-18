
--region -------------默认参数-------------
local module = {}    --导出函数
local fn = {} --私有函数

local SEC_MILLS = 1000 --每秒多少毫秒
local MIN_SEC = 60 --每分多少秒
local HOUR_MIN = 60 --每小时多少分
local HOUR_SEC = HOUR_MIN * MIN_SEC
local DAY_SEC = 24 * HOUR_SEC
local DAYS_OF_WEEK = 7 --每周天数

module.SEC_MILLS = SEC_MILLS
module.MIN_SEC = MIN_SEC
module.HOUR_MIN = HOUR_MIN
module.HOUR_SEC = HOUR_SEC
module.DAY_SEC = DAY_SEC
module.DAYS_OF_WEEK = DAYS_OF_WEEK

--region -------------导出函数-------------

--endregion
---大于等于一天显示（X天X时）
---小于1天显示(HH:mm:ss)
function module.format(time, showSec)
    if time < 0 then
        time = 0
    end
    local day = math.floor(time / DAY_SEC)
    local daySec = day * DAY_SEC
    local hour = math.floor((time - daySec) / HOUR_SEC)
    if day >= 1 and not showSec then
        return StringUtil.concat(day, "天", hour, "时")
    end

    local hourSec = hour * HOUR_SEC
    local min = math.floor((time - daySec - hourSec) / MIN_SEC)
    local sec = time % MIN_SEC
    return string.format("%02d:%02d:%02d", hour, min, sec)
end

---时间转换 格式 xx:xx:xx
function module.format2(time)
    return module.format(time, true)
end

---时间转换 格式 天 时 分 秒
function module.format3(time, showSec)
    if time < 0 then
        time = 0
    end
    local day = math.floor(time / DAY_SEC)
    local daySec = day * DAY_SEC
    local hour = math.floor((time - daySec) / HOUR_SEC)
    local hourSec = hour * HOUR_SEC
    local min = math.floor((time - daySec - hourSec) / MIN_SEC)
    if day >= 1 then
        return day .. "天"
    elseif hour >= 1 then
        return hour .. "小时"
    else
        if min < 1 then
            min = 1
        end
        return min .. "分钟"
    end
end

---大于等于一天显示（X天X时）
---小于1天显示(HH:mm:ss)
function module.format4(time)
    if time < 0 then
        time = 0
    end
    local day = math.floor(time / DAY_SEC)
    local daySec = day * DAY_SEC
    local hour = math.floor((time - daySec) / HOUR_SEC)
    local hourSec = hour * HOUR_SEC
    local min = math.floor((time - daySec - hourSec) / MIN_SEC)
    local sec = time % MIN_SEC
    
    if day >= 1 then
        return string.format("%02ddays:%02dh", day, hour)
    end
    return string.format("%02dh:%02dm:%02ds", hour, min, sec)
end

---判断时间是否同一周
---@param t1 number
---@param t2 number
function module.sameWeek(t1, t2)
    local d1 = os.date("*t", t1)
    local d2 = os.date("*t", t2)
    --天数间隔超过一周
    if math.abs(d1.yday - d2.yday) >= DAYS_OF_WEEK then
        return false
    end

    if d1.day < d2.day then
        return fn.getDayOfWeek(d1) < fn.getDayOfWeek(d2)
    end

    return fn.getDayOfWeek(d1) >= fn.getDayOfWeek(d2)
end

--- 1-7=周一-周日
function module.getBJCurWeek(time)
    local weekStr = os.date("!%w", time + 28800)
    local week = tonumber(weekStr)
    if week == 0 then
        week = 7
    end
    return week
end

---秒 转 分钟
function module.secToMin(val)
    return math.floor(val / MIN_SEC)
end

---毫秒 转 秒（浮点数）
function module.millsToSec(val)
    return val / SEC_MILLS
end

---时间戳(单位秒)转成 年 月 日 时 分 秒 
function module.formatDate(time)
    return os.date("%Y-%m-%d %H:%M:%S", time)
end


--endregion

--region -------------私有函数-------------

function fn.getDayOfWeek(date)
    --[1-7 = Sun-Sat] -> [1-7 Mon-Sun]
    local wday = date.wday
    if wday == 1 then
        return DAYS_OF_WEEK
    end
    return wday - 1
end

--endregion

return module