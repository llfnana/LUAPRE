DailyBagManager = {}
DailyBagManager.__cname = "DailyBagManager"
local this = DailyBagManager

---@class DailyBagItem
---@field name string
---@field maxLine number
---@field line table<string, number>
---@field sort number[]

function DailyBagManager.Init()
    if this.initialized then
        return
    end

    this.initialized = true
    ---@type table<string, DailyBagItem>
    this.data = DataManager.GetGlobalDataByKey(DataKey.DailyBag) or {}
    -- this.CleanItem(GameManager.GameTime())
end

function DailyBagManager.ClearData()
    this.data = {}
    this.SaveData()
end

---@param name string
---@param count number
---@param ts number
function DailyBagManager.AddItem(name, count, ts, from, fromId)
    if count <= 0 then
        print("[error]" .. "invalid count")
        return
    end

    local stock = this.GetItem(name, ts)
    this.SetItem(name, count + stock, ts)
    local csObj = {
        currency = name,
        value = count,
        balance = count + stock,
        from = from,
        fromId = fromId,
        bagType = "daily"
    }

    Analytics.CurrencySource(csObj)
end

---@param name string
---@param count number
---@param ts number nil表示当前天有效
function DailyBagManager.SetItem(name, count, ts)
    local dateTime = this.GetTime2(ts)

    local item = this.data[name] or this.NewItem(name, 1)
    local day, iDay = this.GetDay(dateTime)

    if item.line[day] == nil then
        table.insert(item.sort, iDay)
        table.sort(
            item.sort,
            function(a, b)
                return a > b
            end
        )
    end

    item.line[day] = count
    this.data[name] = item
    this.SaveData()
end

---清除无用数据
---@param item DailyBagItem
function DailyBagManager.CleanItem(ts)
    local t = Time2:New(ts)
    for k, item in pairs(this.data) do
        for i = #item.sort, 1, -1 do
            local day = item.sort[i]
            if day < t:GetToday() then
                table.remove(item.sort, i)
                item.line[tostring(day)] = nil
            end
        end

        -- if #item.sort == 0 then
        --     this.data[k] = nil
        -- end
    end

    this.SaveData()
end

function DailyBagManager.SetMax(name, max)
    local item = this.data[name] or this.NewItem(name, max)
    item.maxLine = max
    this.data[name] = item
    this.SaveData()
end

---@param name string
---@param ts number  希望获取某一天的ts
function DailyBagManager.GetItem(name, ts)
    local dateTime = this.GetTime2(ts)

    local item = this.data[name]
    if item == nil then
        return 0
    end

    local day = this.GetDay(dateTime)
    return item.line[day] or 0
end

---判断当天是否设置过，可用于判断是否有相应特权
---@param name string
---@param ts number  希望获取某一天的ts
function DailyBagManager.HasItem(name, ts)
    local dateTime = this.GetTime2(ts)

    local item = this.data[name]
    if item == nil then
        return nil
    end

    local day = this.GetDay(dateTime)
    return item.line[day] or nil
end

---消耗item
---@param name string
---@param count number
---@param ts number nil表示当前天有效
---@return boolean
function DailyBagManager.UseItem(name, count, ts, to, toId)
    local stock = this.GetItem(name, ts)
    if stock == 0 then
        return false
    end

    if stock < count then
        return false
    end

    this.SetItem(name, stock - count)
    this.data[name].count = this.data[name].count + 1
    this.SaveData()

    local csObj = {
        currency = name,
        value = count,
        balance = stock - count,
        to = to,
        totoId = toId,
        bagType = "daily"
    }
    Analytics.CurrencySink(csObj)
    return true
end

---是否能领取
function DailyBagManager.CanUseItem(name, count, ts)
    local stock = this.GetItem(name, ts)
    if stock == 0 then
        return false
    end

    if stock < count then
        return false
    end

    return true
end

---已领取多少天
function DailyBagManager.GetItemDay(name)
    return this.data[name] and this.data[name].count or 0
end

---@return Time2
function DailyBagManager.GetTime2(ts)
    if ts == nil then
        return Time2:New(GameManager.GameTime())
    end

    return Time2:New(ts)
end

---@param t Time2
---@return string, number
function DailyBagManager.GetDay(t)
    return tostring(t:GetToday()), t:GetToday()
end

---@param name string
---@param max number
---@return DailyBagItem
function DailyBagManager.NewItem(name, max)
    local item = {
        name = name,
        maxLine = max,
        line = {},
        sort = {},
        count = 0
    }

    return item
end

function DailyBagManager.SaveData()
    DataManager.SetGlobalDataByKey(DataKey.DailyBag, this.data)
end

--切换帐号重置数据
function DailyBagManager.Reset()
    this.initialized = nil
end
