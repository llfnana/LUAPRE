-- 因为内存不足而重启小游戏的，不再弹登录成功界面，直接进到游戏 
local json = require 'cjson'

RestartEnterGame = {}
local this = RestartEnterGame

function RestartEnterGame.StartGame()
    MiniGame.DHWXSDK.Instance:SetLoginCallback(this.LoginCallBack)
    MiniGame.DHWXSDK.Instance:Login("test")
end

function RestartEnterGame.LoginCallBack(sdkInfo)
    this.data = {{},{},{}}   -- data about serverlist
    this.currentServer = {}

    this.sdkInfo = json.decode(sdkInfo)

    NetModule.c2sRequestZonelist()
    makergetFn(Sc(), "system"):addEvent("zone_list", function(vo)
        --- 获取大区列表并存入zoneList
        this.zoneList = vo
        local url = this.zoneList[1].url .. "?openid=" .. this.GetOpenId() -- 拼接一下
        NetModule.c2sRequestServerlist(url)
    end)

    makergetFn(Sc(), "system"):addEvent("server_list", function(vo)
        this.serverList = vo
        local data = vo
        for k, v in pairs(data) do
            table.sort(data, function(a, b)
                if a.showtime ~= b.showtime then
                    return a.showtime > b.showtime
                end
            end)
            table.insert(this.data[3], data[k])
        end
        for k, v in pairs(data) do
            if data[k].state == 2 then
                table.insert(this.data[2], data[k])
            end
        end

        this.SelectServer()
        this.Login()
    end)
end

---自动选服
function RestartEnterGame.SelectServer()
    local serverId = this.serverList[1].id
    for k, v in ipairs(this.serverList) do
        if v.id == serverId then
            this.currentServer = v
        end
    end
end

function RestartEnterGame.Login()
    print("zhkxin Login")
    -- 游戏客户端开始请求登录游戏服
    MiniGame.DHWXSDK.Instance:AnalyticsLog("420000::GAME_CLIENT_LOGIN_START", "0", "hh")

    NetModule.setServerUrl(this.currentServer.url)
    NetModule.setServerInfo(this.currentServer.id)
    local vo = NewCs("login")
    
    vo.info.login.loginAccount.dh_token = this.sdkInfo.data.token;
    vo.info.login.loginAccount.platform = "dianhun"
    vo.info.login.loginAccount.openid = this.sdkInfo.data.accountId
    vo.info.login.loginAccount.logintype = "LoginType_Quick_Visitor"
    vo:add(function (vo)
        print("zhkxin Login callback")
        -- 游戏客户端登录成功
        MiniGame.DHWXSDK.Instance:AnalyticsLog("450000::GAME_CLIENT_LOGIN_SUCCESS", "0", "hh")
        this.LoginComplete(vo)
        this.EnterGame()
    end, true)
    vo:send()                      
end

function RestartEnterGame.LoginComplete(vo)
    print("zhkxin LoginComplete")
    local _vo = vo.a.loginMod.loginAccount
    -- 游戏客户端创角成功
    MiniGame.DHWXSDK.Instance:AnalyticsLog("450001::GAME_CLIENT_CREATING_A_ROLE", "0", "hh")
    print("登录信息拿到>>>>>>>>>>>>>>>>>>", _vo.uid)
    NetModule.setRequestUidAndToken(_vo.uid, _vo.token)
end

function RestartEnterGame.EnterGame()
    print("zhkxin EnterGame")
    local vo = NewCs("guide")
    vo.info.guide.login.platform = "dianhun"
    vo:add(function(vo)
        -- 旧方案
        -- local uid = vo.a.user.user.uid
        -- GameManager.SetGameTime(os.time())
        -- DataManager.SetData(uid)

        -- 服务器有问题 暂时屏蔽
        -- -- 数据存储方案
        local retData = vo.a.map.city.document
        GameManager.SetGameTime(os.time())
        local uid = vo.a.user.user.uid
        local lastLogin = vo.a.user.user.lastLogin
        if lastLogin == 0 then
            if PlayerModule.getSdkPlatform() == "wx" then
                MiniGame.DHWXSDK.Instance:AnalyticsLog("analyticsRegister", "0", "hh")
            end
        end
        PlayerModule.SetUid(uid)
        print("UID: ", uid)
        retData = JSON.decode(retData)
        DataManager.SetData(uid, retData)

        local mapid = retData.global and retData.global.cityId or 1
        CityModule.openScene(mapid)
        if PlayerModule.getSdkPlatform() == "wx" then
            AdManager.Init()
        end
    end, true)
    vo:send()
end

---获取本地储存登录记忆缓存
function RestartEnterGame.GetOpenId()
    local loginMemory = StorageModule.get(StorageModule.enum.LOGIN_MEMORY)
    return loginMemory and loginMemory.openid or ""
end