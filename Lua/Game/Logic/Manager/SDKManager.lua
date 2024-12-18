SDKManager = {}
SDKManager.__cname = "SDKManager"

local this = SDKManager

--初始化SDK(Fpid)
function SDKManager.Init(cb)
    this.InitCallBack = cb
    if SDKWrap.IsLogined then
        this.SDKSuccess()
    else
        SDKWrap.AddLuaInitEvent(SDKManager.InitEvent)
    end
    SDKWrap.AddLuaCommonEvent(SDKManager.CommonEvent)
end

function SDKManager.InitEvent(method, message)
    Log("LUA:SDK " .. method .. " | " .. message)
    if method == "SDKSuccess" then
        this.SDKSuccess()
    elseif method == "NetError" then
        this.InitCallBack("NetError")
    elseif method == "SDKError" then
        this.InitCallBack("SDKError", message)
    end
end

function SDKManager.CommonEvent(method, message)
    Log("LUA:SDKCommon: " .. method .. " | " .. message)
    EventManager.Brocast(EventType.SDK_COMMON_EVENT, method, message)
end

function SDKManager.AgainInit()
    SDKWrap.StartLogin()
end

function SDKManager.SDKSuccess()
    this.fpid = SDKWrap.SDK_Fpid
    this.session = SDKWrap.SDK_FpSessionKey
    this.accountType = SDKWrap.SDK_AccountType
    this.InitCallBack("SDKSuccess")
end

function SDKManager.AgainLogin(cb)
    this.InitCallBack = cb
    SDKWrap.AddLuaInitEvent(SDKManager.InitEvent)
    SDKWrap.AgainLogin()
end

function SDKManager.LogUserInfoUpdate(serverId, userId, userName, userLevel, userVipLevel, isPaidUser)
    SDKWrap.LogUserInfoUpdate(serverId, userId, userName, userLevel, userVipLevel, isPaidUser)
end

function SDKManager.Bind(accountType, cb)
    this.BindCallBack = cb
    SDKWrap.Bind(accountType, SDKManager.BindEvent)
end

function SDKManager.UnBind(cb)
    this.BindCallBack = cb
    SDKWrap.UnBind(SDKManager.BindEvent)
end

function SDKManager.ClearBind()
    this.BindCallBack = nil
end

function SDKManager.BindEvent(method, message)
    Log("LUA:SDKBIND " .. method .. " | " .. message)
    if method == "BindSuccess" or method == "UnBindSuccess" then
        this.fpid = SDKWrap.SDK_Fpid
        this.session = SDKWrap.SDK_FpSessionKey
        this.accountType = SDKWrap.SDK_AccountType
    end
    if this.BindCallBack then
        this.BindCallBack(method, message)
    end
end

function SDKManager.ErrorLog(msg)
    SDKWrap.FirebaseErrorLog(msg)
end

function SDKManager.GetLanguage()
    return SDKWrap.GetLanguage()
end

function SDKManager.GetCountry()
    return SDKWrap.GetCountry()
end

function SDKManager.GetSeID()
    return SDKWrap.GetSeID()
end
