-------------------------------------------------
-- Http请求模块
-------------------------------------------------
local NetEvent = require("Proxy.NetBase.NetEvent")
local ZeroHttp = {}
ZeroHttp.version = "ZeroHttp 1.0"
-- 请求状态信息
ZeroHttp.TIMEOUT = "timeout"
ZeroHttp.SUCCESS = "success"
ZeroHttp.SEND = "send"
ZeroHttp.FAIL = "fail"
-- 请求内容类型
local contentTypes = {}
contentTypes["string"] = 0
contentTypes["buffer"] = 1
contentTypes["blob"] = 2
contentTypes["document"] = 3
contentTypes["json"] = 4

local tools = require("Proxy.NetBase.Utils.DataTools")-- 数据工具模块
--服务端返回的json解密
function decode(response)
    -- if Config.appHide == "1" and mse == 0 then
    --     -- 针对审核服的服务器列表进行加密
    --     mse = tonumber(Config.mse) > 0 and tonumber(Config.mse) or 4 -- kings下审核服没有在config特别赋值的话，默认加密方式是4
    -- end
    local mse = 0

    if mse < 4 then
        --mse值为0,1，2，3的时候不加密
        return response
    elseif mse == 4 then
        return mime.unb64(response)
    elseif mse == 5 then
        -- 下面解析太长，占用带宽弃用
        local str = response
        local key = #Platform.platformType > 0 and Platform.platformType .. "123" or "123123"
        local keyLen = #key
        local len = #str
        local bStr = ""

        for m = 1, len do
            local s1 = string.sub(str, m, m) -- str单个字符
            local n = (m - 1) % keyLen + 1
            local s2 = string.sub(key, n, n) -- sKey单个字符
            local b = (bit.bxor(string.byte(s1), string.byte(s2))) % 256--s1,s2分别取ASCII进行异或处理
            bStr = bStr .. "~" .. b
        end
        allStr = string.sub(bStr, 2, #bStr) --去掉第一个~字符
        local bArr = string.split(allStr, "~")
        local decodeStr = ""
        for k, v in pairs(bArr) do
            decodeStr = decodeStr .. string.char(v) --再还原为字符
        end

        local ss = mime.unb64(decodeStr)
        return ss
    end
end

-- http请求
local function load(self, URLVo)
    Event.Brocast(EventDefine.OnNetworkRequest, URLVo)
    local function callback(vo, paramNum, result)
        Event.Brocast(EventDefine.OnNetworkReceive, URLVo)
        -- print('cal:', vo)
        if self == nil or vo == nil or result == nil then
            print("__________________________[网络出错 未知错误]_______________________________")
        else
            if result == 0 then
                if not URLVo:hasInfo("user.heartbeat") or NetModule.getHeartConsoleSwitch() then --不是心跳包的情况下才打印
                    local json = require 'cjson'
                    local _vo = json.decode(vo)
                   -- NetOutPut("[HTTP.Server]: vo.info." .. URLVo:getInfoPath(), _vo)
                end
                self:event(ZeroHttp.SUCCESS, URLVo, result, decode(vo))
                -- if URLVo.behindFn and URLVo.behindFn[info.s] and type(URLVo.behindFn[info.s]) == "function" then
                --     -- 请求成功回调
                --     local cb = URLVo.behindFn[info.s]
                --     cb(info.a)
                -- end
            else
                --print("_____________________onReadyStateChange___ else.status _____________________________")
            end
        end
    end
    -- C#层请求
    Core.Instance.Http:HttpPostOnlyString(URLVo.url, URLVo.data, callback, false, 1)
end

local function newZeroHttp(prototype)
    local self = NetEvent:new()
    self.load = load
    return self
end

ZeroHttp.new = newZeroHttp
return ZeroHttp