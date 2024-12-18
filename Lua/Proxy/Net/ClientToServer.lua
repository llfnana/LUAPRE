local http = require("Proxy.Net.NetHttp")                 -- http请求模块
local httpUrlVo = require("Proxy.Net.HttpUrlVo")       -- http数据结构模块
local protoData = require("Proxy.Net.Proto.king_data") -- 协议获取模块（用来获取请求协议结构）
local tools = require("Proxy.NetBase.Utils.DataTools")   -- 数据工具模块
local json = require 'cjson'

local CS = {}

local mse = 0 -- 数据加密开关
local httpNet = http:new()

local setSCforAll
local setSCArrayforAll
local setSCforUp
local setSCArrayforUp
local setSCforDelete
local setSCArrayforDelete
local function setEnum(t, k, v)
    t[k] = v + 1
end
setSCforAll = function(obj, val, path)
    obj:revert(false)
    for k, v in pairs(val) do
        if obj[k] ~= nil then
            if protoData.metaType(obj[k]) == protoData.TYPE.HASH then
                if type(v) == "table" then
                    setSCforAll(obj[k], v, path .. "." .. k);
                else
                    print("[error]" .. "协议格式出错:" .. path .. "." .. k)
                end
            elseif protoData.metaType(obj[k]) == protoData.TYPE.ARRAY then
                if type(v) == "table" then
                    setSCArrayforAll(obj[k], v, path .. "." .. k);
                else
                    print("[error]" .. "协议格式出错:" .. path .. "." .. k)
                end
            elseif protoData.metaType(obj[k]) == protoData.TYPE.ENUM then
                setEnum(obj, k, v)
            else
                obj[k] = v
            end

        end
    end
end
setSCArrayforAll = function(obj, val, path)
    obj:revert(false)
    for k, v in ipairs(val) do
        obj:add()
        if protoData.metaType(obj[k]) == protoData.TYPE.HASH then
            setSCforAll(obj[k], v, path .. "." .. k);
        elseif protoData.metaType(obj[k]) == protoData.TYPE.ARRAY then
            setSCArrayforAll(obj[k], v, path .. "." .. k);
        elseif protoData.metaType(obj[k]) == protoData.TYPE.ENUM then
            setEnum(obj, k, v)
        else
            obj[k] = v
        end
    end
end

setSCforUp = function(obj, val, path)
    if type(val) ~= "table" then
        print("[error]" .. "协议格式出错:" .. path)
    else
        for k, v in pairs(val) do
            if obj[k] ~= nil then
                if protoData.metaType(obj[k]) == protoData.TYPE.HASH then
                    setSCforUp(obj[k], v, path .. "." .. k);
                elseif protoData.metaType(obj[k]) == protoData.TYPE.ARRAY then
                    setSCArrayforUp(obj[k], v, path .. "." .. k);
                elseif protoData.metaType(obj[k]) == protoData.TYPE.ENUM then
                    setEnum(obj, k, v)
                else
                    obj[k] = v
                end

            end
        end
    end
end
setSCArrayforUp = function(obj, val, path)
    for k, v in ipairs(val) do
        if type(v) ~= "table" then
            --print("[error]" .. "方法u只有更新table为子项的数组")
        else
            v.id = v.id or k --如果没有id则默认为数组下标

            local item = v.idx ~= nil and obj:getBy("idx", v.idx) or obj:getBy("id", v.id)
            if item == nil then
                item = obj:add()
            end
            setSCforUp(item, v, path .. "." .. k);

        end
    end
end

setSCforDelete = function(obj, val, path)
    if type(val) ~= "table" then
        print("[error]" .. "协议格式出错:" .. path)
    else
        for k, v in pairs(val) do
            if obj[k] ~= nil then
                if protoData.metaType(obj[k]) == protoData.TYPE.HASH then
                    setSCforDelete(obj[k], v, path .. "." .. k)
                elseif protoData.metaType(obj[k]) == protoData.TYPE.ARRAY then
                    setSCArrayforDelete(obj[k], v, path .. "." .. k)
                else
                    obj:removeItem(k)
                end
            end
        end
    end
end
setSCArrayforDelete = function(obj, val, path)
    for k, v in ipairs(val) do
        if type(v) ~= "table" or v.id == nil then
            print("[error]" .. "方法d只有更新带有id的table为子项的数组")
        else
            local item = v.idx ~= nil and obj:getBy("idx", v.idx) or obj:getBy("id", v.id)
            if item == nil then
                print("[error]" .. "错误！找不到要删除的项！！")
            end
            setSCforDelete(item, v, path .. "." .. k);
        end
    end
end

local function parse(vo, data)
    if data ~= nil then
        local useData = json.decode(data)
        if UnityEngine.Application.isEditor or NetModule.isTestServer() then 
            local request = ""
            if vo.data ~= "" then 
                local data = json.decode(vo.data)
                for key, value in pairs(data) do
                    request = key
                end
            end
            -- 过滤心跳包
            if request ~= "map" then 
                print("[Http]", request, ListUtil.dump(useData))
            end
        end
        
        -- ss.helper.data.curSCData = useData
        if useData ~= nil and type(useData) == "table" then
            local callList = {
                ["a"] = false,
                ["d"] = false,
                ["u"] = false,
            }
            local infos = {}
            if useData.a ~= nil and next(useData.a) then
                NetModule.SCUpType = "a"
                setSCforAll(Sc(), useData.a, "root")
                callList["a"] = true
            end
            if useData.d ~= nil and next(useData.d) then
                NetModule.SCUpType = "d"
                setSCforDelete(Sc(), useData.d, "root")
                callList["d"] = true
                infos["d"] = useData.d
            end
            if useData.u ~= nil and next(useData.u) then
                NetModule.SCUpType = "u"
                setSCforUp(Sc(), useData.u, "root")
                callList["u"] = true
                infos["u"] = useData.u
            end
            local beforeFn = vo.beforeFn[useData.s or 1]
            if beforeFn ~= nil then
                beforeFn()
            end
            local beforeAllFn = vo.beforeFn["all"]
            if beforeAllFn ~= nil then
                beforeAllFn()
            end
            
            Sc():flush(callList, infos, vo)
            local behindFn = vo.behindFn[useData.s or 1]
            if behindFn ~= nil then
                behindFn(useData) --.a)
            end
            local behindAllFn = vo.behindFn["all"]
            if behindAllFn ~= nil then
                behindAllFn(useData.a)
            end
        else
            print("[error]" .. "json协议出错")
        end
    end
end

local function okHd(sender, type, vo, state, data)
    parse(vo, data)
end

httpNet:addEvent(http.SUCCESS, okHd)
-- httpNet:addEvent(http.FAIL, noHd)

function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

-- 客户端请求服务器的对象
local newCS = function (key)
    local vo = {}

    vo.urlVo = httpUrlVo.getUrlVo()   -- 获取基本的请求数据构造
    vo.urlVo.url = NetModule.getServerUrl()
    vo.urlVo.tag = key
    vo.info = protoData.cs.new(key) -- 构造协议

    -- 添加CS命令回调
    vo.add = function(vo, callback, isbehind, state)
        state = state or 1
        local callbackTable
        callbackTable = isbehind and vo.urlVo.behindFn or vo.urlVo.beforeFn
        if type(callback) == "function" then
            callbackTable[state] = callback
        end
    end

    -- CS请求发送
    vo.send = function(vo, noWaiting, notShowItem)
        -- print(debug.traceback())
        noWaiting = noWaiting == nil and true or false

        local dest = {}
        table.merge(dest, vo.info)
        if mse > 0 then
            dest.rsn = dest.rsn .. "~" .. math.random(10000000, 99999999)
        end
        vo.urlVo.info = vo.info
        vo.info = dest
        local data = mse > 0 and tools.encryptData(json.encode(vo.info), tonumber(mse)) or json.encode(vo.info)
        vo.urlVo.data = data
        vo.urlVo.isWaiting = isWaiting
        vo.urlVo.notShowItem = notShowItem or false
        -- vo.urlVo.index = vo.index

        -- tools.printTable(vo.urlVo)
        for kf, fn in pairs(vo.urlVo.beforeFn) do
            if type(fn) == "function" then
                fn()
            end
        end
        if not vo.urlVo:hasInfo("user.heartbeat") or NetModule.getHeartConsoleSwitch() then --不是心跳包的情况下才打印
            --NetOutPut("[HTTP.Send]: vo.info." .. vo.urlVo:getInfoPath(), vo.info)
        end
        httpNet:load(vo.urlVo)


        -- UIUtil.showWaitTip()
        if noWaiting then
            -- 如果
            -- self.zero:command(GameKey.WAITING, true, vo.index)
        end
    end
    -- tools.printTable(vo)
    -- print("vo")

    return vo
end

CS.newCS = newCS
CS.httpNet = httpNet
return CS