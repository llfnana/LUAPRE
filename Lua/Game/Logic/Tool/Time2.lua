---@class Time2
Time2 = {}
Time2.__index = Time2

Time2.WeekEnum = {
    "Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"
}

Time2.Minute = 60
Time2.Hour = 60 * Time2.Minute
Time2.Day = 24 * Time2.Hour
Time2.Week = 7 * Time2.Day


---UTC时间
---@return Time2
function Time2:New(ts)
    local hour = 0
    if ts <= 0 then
        -- 由于windows下正时区使用1970-1-1返回时间戳会导致报错，所以这里统一加上12小时避免报错
        -- mac下会返回负时间戳，加上时区正好还是0
        hour = Time2.Hour * 12
    end
    local now = os.time()
    local localDate = os.date("*t", now)
    -- 本地时间要计算夏令时
    localDate.isdst = false
    local tzInSec = math.floor(os.difftime(os.time(localDate), os.time(os.date("!*t", now))))
    local tz = math.floor(tzInSec / Time2.Hour)
    local date = os.date('!*t', ts)
    local today = os.time({
        year = date.year,
        month = date.month,
        day = date.day,
        hour = hour,
        min = 0,
        sec = 0,
    }) + tzInSec
    local monthFirstDay = os.time({
        year = date.year,
        month = date.month,
        day = 1,
        hour = hour,
    }) + tzInSec
    local monthLastDay = os.time({
        year = date.year,
        month = date.month + 1,
        day = 1,
        hour = hour,
    }) + tzInSec
    local o = {
        ts = ts or 0,
        tz = tz,
        tzInSec = tzInSec,
        date = date,
        today = today,
        monthFirstDay = monthFirstDay,
        monthLastDay = monthLastDay,
    }
    setmetatable(o, self)
    return o
end

---返回当前用户时区
---@return number
function Time2:GetTimeZone()
    return self.tz
end

---返回时间戳对应的UTC Date对象
---@return table
function Time2:Date()
    return self.date
end

function Time2:LocalDate()
    return os.date('*t', self:Timestamp())
end

---返回时间戳
---@return number
function Time2:Timestamp()
    return self.ts
end

---返回当天0点时间戳
---@return number
function Time2:GetToday()
    return self.today
end

---返回当月第一天0点时间戳
---@return number
function Time2:GetMonthFirstDay()
    return self.monthFirstDay
end

---返回当月最后一天24点时间戳
---@return number
function Time2:GetMonthLastDay()
    return self.monthLastDay
end

---返回周一的0点时间戳
---@return number
function Time2:GetMonday()
    if self:Date().wday == 1 then
        -- sunday
        return self:GetToday() - Time2.Day * 6
    end
    -- wday = 1是周日
    return self:GetToday() - (self:Date().wday - 2) * Time2.Day
end

---返回星期
---@return string
function Time2:GetWeekday()
    return Time2.WeekEnum[self:Date().wday]
end

---返回月
---@return number
function Time2:GetMonth()
    local d = self:Date()
    return d.month
end

---返回日
---@return number
function Time2:GetDay()
    local d = self:Date()
    return d.day
end

---返回年
---@return number
function Time2:GetYear()
    local d = self:Date()
    return d.year
end

---返回UTC时间字符串
---@return string
function Time2:ToString()
    return string.format("%d-%02d-%02d %02d:%02d:%02d UTC",
            self:Date().year, self:Date().month, self:Date().day,
            self:Date().hour, self:Date().min, self:Date().sec)
end

---返回本地时间字符串
---@return string
function Time2:ToLocalString()
    return string.format("%d-%02d-%02d %02d:%02d:%02d %+02d",
            self:LocalDate().year, self:LocalDate().month, self:LocalDate().day,
            self:LocalDate().hour, self:LocalDate().min, self:LocalDate().sec,
            self:GetTimeZone())
end
