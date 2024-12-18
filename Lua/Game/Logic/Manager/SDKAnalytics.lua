SDKAnalytics = {}
SDKAnalytics.__cname = "SDKAnalytics"
local this = SDKAnalytics
local errorLogUrl_test = "https://metropolis-2047-game.qiyuanyouyou.com/api/front_log.php"
local errorLogUrl_release = "https://metropolis-2047-game-2.qiyuanyouyou.com/api/front_log.php"
local errorLogUrl = errorLogUrl_test

--电魂打点
function SDKAnalytics.TraceEvent(eventID)
    -- error("eventID--- " .. eventID)
    pcall(function()
            local ubt = ConfigManager.GetAnalyticsById(eventID)
            if PlayerModule.getSdkPlatform() == "wx" then
                MiniGame.DHWXSDK.Instance:AnalyticsLog(ubt.point, "0", "hh")
            end
        end)
end

function SDKAnalytics.InitConfig(isLog, key)
    if isLog == false then 
        Application.logMessageReceived = Application.logMessageReceived + SDKAnalytics.ErrorLog
    end

    if key == "release" or key == "release2" then 
        errorLogUrl = errorLogUrl_release
    end
end

function SDKAnalytics.ErrorLog(condition, stackTrace, type)
    if type == UnityEngine.LogType.Error then 
        -- 上传报错日志
        local msg = "[Error]: " .. condition .. ", stack: " .. stackTrace
        HttpAgent:HttpPostString(errorLogUrl, "frontString=" .. msg, function(msg, num, HttpResult, msg2) 
        end, true, 1)
    elseif type == UnityEngine.LogType.Assert then
    elseif type == UnityEngine.LogType.Warning then
    elseif type == UnityEngine.LogType.Log then
    elseif type == UnityEngine.LogType.Exception then
    end
end
