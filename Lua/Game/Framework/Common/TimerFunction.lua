TimerFunction = {}
TimerFunction.__cname = "TimerFunction"
TimerFunction.deltaTime = 0
TimerFunction.battledeltaTime = 0 --战斗用的，在战斗的时候调用支付面板，timeScale = 0, 战斗过程应该暂停，支付面板，计时继续
local this = TimerFunction

function TimerFunction.Init()
    this.list = {}
    this.deltaTime = Time.deltaTime
    this.battledeltaTime = Time.deltaTime
    this.shortUuid = 0
end

function TimerFunction.Update()
    TimerFunction.battledeltaTime = Time.deltaTime
    -- if BattleUIManager.IsExistBattleScene() == true then
    --     if BattleUIManager.isOpenSubscriptionPanel() == true then
    --         TimerFunction.deltaTime = Time.unscaledDeltaTime
    --     else
    --         TimerFunction.deltaTime = Time.deltaTime
    --     end
    -- else
         TimerFunction.deltaTime = Time.deltaTime
    -- end

    local index = 1
    local deltaTime = TimerFunction.deltaTime * 1000
    while index <= #this.list do
        local item = this.list[index]
        item.delay = item.delay - deltaTime
        if item.remove == true then
            table.remove(this.list, index)
        elseif item.delay <= 0 then
            local ret, errMessage =
                pcall(
                function()
                    --item.fun(table.unpack(item.params))
                    item.fun(unpack(item.params))
                end
            )
            if item.isInterval == true then
                if ret == false then
                    print("[error]" .. errMessage)
                    table.remove(this.list, index)
                else
                    item.delay = item.ms - item.delay
                    index = index + 1
                end
            else
                if ret == false then
                    print("[error]" .. errMessage)
                end
                table.remove(this.list, index)
            end
        else
            index = index + 1
        end
    end
end

function TimerFunction.AddTimeout(fun, delay, ...)
    if delay < 0 then
        delay = 0
    end
    --local uuid = Utils.GetShortUUID()
    this.shortUuid = this.shortUuid + 1
    local uuid = this.shortUuid
    local item = {}
    item.id = uuid
    item.fun = fun
    item.delay = delay
    item.params = {...}
    table.insert(this.list, item)
    return uuid
end

function TimerFunction.ClearTimeout(uuid)
    local index = 1
    while index <= #this.list do
        local item = this.list[index]
        if item.id == uuid then
            -- table.remove(this.list, index)
            item.remove = true
        end
        index = index + 1
    end
end

function setTimeout(fun, delay, ...)
    return TimerFunction.AddTimeout(fun, delay, ...)
end

function clearTimeout(uuid)
    TimerFunction.ClearTimeout(uuid)
end

function setInterval(fun, delay, ...)
    if delay < 0 then
        return
    end
    this.shortUuid = this.shortUuid + 1
    local uuid = this.shortUuid
    --local uuid = Utils.GetShortUUID()
    local item = {}
    item.id = uuid
    item.fun = fun
    item.isInterval = true
    item.ms = delay
    item.delay = delay
    item.params = {...}
    table.insert(this.list, item)
    return uuid
end

function clearInterval(uuid)
    TimerFunction.ClearTimeout(uuid)
end

function TimerFunction.LogCache()
    local index = 1
    while index <= #this.list do
        local item = this.list[index]
        if item.isInterval == true then
            print("[error]" .. "isInterval:" .. item.ms)
        else
            print("[error]" .. "isTimeout:" .. item.delay)
        end
        index = index + 1
    end
end
