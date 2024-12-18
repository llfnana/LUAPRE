------------------------------------------------------------------------
--- @desc 网络模块
--- @author Sakuya
------------------------------------------------------------------------

local config = {}
config.serverInfo = {}
config.serverInfo.zoneUrl = "http://10.1.71.172/zonelist.php" -- "http://111.230.240.62:81/zonelist.php" https://metropolis-2047-game-2.qiyuanyouyou.com
config.serverInfo.serverUrl = "http://192.168.87.177/servers/sapi.php"
config.serverInfo.id = 1
config.serverInfo.name = ""
config.serverInfo.ver = "1.0"
config.serverInfo.uid = ""
config.serverInfo.token = ""
config.serverInfo.backurl = ""
config.serverInfo.gamename = ""
config.serverInfo.parm1 = ""
config.serverInfo.ip = ""

local module = {}
local fn = {}
module.SCUpType = "a"

local heartConsole = false --心跳控制台输出开关
local _isTestServer = false -- 是否是体能服

-- 更新当前的大区列表
-- 根据配置来决定用哪个服务器
local isInitZoneUrl = false
function module.initZoneUrl(callback)
    if UnityEngine.Application.isEditor then 
        isInitZoneUrl = true
        config.serverInfo.zoneUrl = "http://10.1.71.172/zonelist.php"
        if callback then 
            callback()
        end
    else
        local cdnPath = UnityEngine.Application.streamingAssetsPath
        local key = "none"
        if string.find(cdnPath, "/test/") then 
            key = "test"
            _isTestServer = true
        elseif string.find(cdnPath, "/release/") then 
            key = "release"
        elseif string.find(cdnPath, "/release2/") then 
            key = "release2"
        end

        -- 如果获取不到文件，则进不了游戏
        print("zhkxin key: " .. key)
        module.requestVersionConfig(function(jsonData)
            isInitZoneUrl = true
            local isRelease = jsonData[key] == "release"
            if isRelease then 
                config.serverInfo.zoneUrl = "https://metropolis-2047-game-2.qiyuanyouyou.com/zonelist.php"
            else 

                config.serverInfo.zoneUrl = "https://metropolis-2047-game.qiyuanyouyou.com/zonelist.php"
            end

            print("zhkxin requestVersionConfig url: " .. config.serverInfo.zoneUrl)

            -- 日志处理
            local isLog = jsonData["isLog"] ~= nil
            SDKAnalytics.InitConfig(isLog, key)

            if callback then 
                callback()
            end
        end)
    end
end

---请求大区列表
function module.requestVersionConfig(callback)
    local url = 'https://metropolis-2047.qiyuanyouyou.com/mrscVersionMgr.json'
    HttpAgent:HttpGet( url, function(jsonData)
        local json = require 'cjson'
        if json == nil then
            return;
        end

        if jsonData == nil then
            print("[error] jsonData = nil")
            return;
        end

        if jsonData == "" then
            print("[error] jsonData = empty")
            return;
        end

        local isValidJson = Util.CheckJsonString(jsonData);
        if not isValidJson then
            print("[error] jsonData is invalid ", jsonData)
            return;			
        end	

        print("zhkxin jsonData", jsonData)
        local data = json.decode(jsonData)
        if data == nil then
            return;
        end

        if callback then 
            callback(data)
        end
    end, false )
end

function module.init()
    makergetFn(Sc(), "system"):addEvent("error", module.s2cNetTip)

    Event.AddListener(EventDefine.OnNetworkRequest, fn.onNetworkRequest)
    Event.AddListener(EventDefine.OnNetworkReceive, fn.onNetworkReceive)
end

function module.release()
end

function module.setServerUrl(url)
    config.serverInfo.serverUrl = url
end

function module.getServerUrl()
    local url = config.serverInfo.serverUrl
        .. "?servid=" .. config.serverInfo.id
        .. "&ver=" .. config.serverInfo.ver
        .. "&uid=" .. config.serverInfo.uid
        .. "&token=" .. config.serverInfo.token
        .. "&platform=" .. (platformType or "local")
        .. "&lang=" .. (LANGUAGE or "zh")
    return url
end

function module.setServerInfo(servid, ver)
    config.serverInfo.id = servid
    config.serverInfo.ver = ver or config.serverInfo.ver
end

function module.setRequestUidAndToken(uid, token)
    config.serverInfo.uid = uid or config.serverInfo.uid
    config.serverInfo.token = token or config.serverInfo.token
end

function module.getServerInfo()
    return config.serverInfo
end

function module.getServerId()
    return config.serverInfo.id
end

function module.getHeartConsoleSwitch()
    return heartConsole
end

function module.s2cNetTip(vo)
    module.netTip(vo.msg, vo.type)
end

local isShowServerDisconnectTip = false
function module.netTip(tip, type)
    print("zhkxin netTip msg: ", tip, "type:", type)
    if type == 9997 then -- "在其他地方登录了" 有弹窗了，不再弹提示文本
        -- 踢人下线。目前直接踢下线。
        Utils.ReLoginDailogWithoutNoButton("login_offsite_warning")
    elseif type == 9996 then 
        -- 服务器维护中
        Utils.ReloginByServicePause("server_disconnect_1")
        -- 同时弹出提示，提示只弹一次
        if isShowServerDisconnectTip == false then 
            isShowServerDisconnectTip = true
            UIUtil.showText(GetLang("server_disconnect"))
        end
    else
        UIUtil.showText(tip, function()
        end)
    end 
end

---请求大区列表
function module.c2sRequestZonelist()
    local c2sRequestZonelist = function()
        print("zhkxin c2sRequestZonelist", config.serverInfo.zoneUrl)
        local url = config.serverInfo.zoneUrl
        local vo = require("Proxy.Net.HttpUrlVo"):new(url)
        require("Proxy.Net.ClientToServer").httpNet:load(vo)
    end

    if isInitZoneUrl == false then 
        print("zhkxin retry initZoneUrl")
        -- 如果失败了再请求一次(不一定是失败，也可能是网络差)
        module.initZoneUrl(function()
            c2sRequestZonelist()
        end)
    else
        c2sRequestZonelist()
    end
end

---请求大区下面的服务器列表
function module.c2sRequestServerlist(url)
    local vo = require("Proxy.Net.HttpUrlVo"):new(url)
    require("Proxy.Net.ClientToServer").httpNet:load(vo)
end


---@param urlVo HttpUrlVo
function fn.onNetworkRequest(urlVo)
    if urlVo:hasInfo("map.setDocument") then --是否是心跳
        return
    end

    UIUtil.showWaitTip()
end

---@param urlVo HttpUrlVo
function fn.onNetworkReceive(urlVo)
    if urlVo:hasInfo("map.setDocument") then --是否是心跳
        return
    end

    UIUtil.hideWaitTip()
end


-- 是否是体验服
function module.isTestServer()
    return _isTestServer
end

return module
