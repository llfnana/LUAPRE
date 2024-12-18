local json = require 'cjson'

local Panel = {};
local this = Panel;
UILoginNewPanel = Panel;

---登陆状态
local LoginState = {
    ---等待登陆
    WaitLogin = 0,
    ---已登陆
    Logged = 1,
    ---进入游戏
    EnterGame = 2
}

function Panel.Awake(obj, behaviour)
    this.gameObject = obj;
    this.transform = obj.transform;
    this.behaviour = behaviour;
    this.isShowManual = true
end

function Panel.InitData()
    this.zoneList = {}      -- 区列表
    this.serverList = {}    -- 服务器列表
    this.hisServerList = {} -- 历史服务器列表
    this.curState = LoginState.WaitLogin
end

function Panel.InitPanel()
    -- 通知GameManager登录场景加载完成
    GameManagerMgr:OnReadyToLogin()

    this.InitLocalize()

    this.uidata = {}
    this.Tables = {} -- table of tab button
    this.data = {}   -- data about serverlist
    this.data[1] = {}
    this.data[2] = {}
    this.data[3] = {}
    this.currentServer = {}

    this.isLogin = false -- determine whether to login
    this.uidata.accountBox = SafeGetUIControl(this, "Account")
    this.uidata.btnLogin = SafeGetUIControl(this, "Account/BtnLogin", "Button")
    this.uidata.accountCloseBtn = SafeGetUIControl(this, "Account/BtnClose", "Button")
    -- button
    this.uidata.TabBtn = SafeGetUIControl(this, "TabBtn")
    SetMenuOffset(this.uidata.TabBtn.transform)

    this.uidata.Account = SafeGetUIControl(this, "TabBtn/Account/ImgAccount")
    this.uidata.Notice = SafeGetUIControl(this, "TabBtn/Notice/ImgNotice")
    this.uidata.Login = SafeGetUIControl(this, "BtnLogin")

    this.uidata.Server = SafeGetUIControl(this, "Server")
    -- temporary
    this.uidata.InputAccount = SafeGetUIControl(this, "Account/AccountInput", "InputField")
    this.uidata.InputPassword = SafeGetUIControl(this, "Account/PasswordInput", "InputField")
    -- server choosen panel
    this.uidata.ServerIdle = SafeGetUIControl(this, "Server/ServerStatus/ServerIdle")
    this.uidata.ServerFull = SafeGetUIControl(this, "Server/ServerStatus/ServerFull")
    this.uidata.ServerMaintenance = SafeGetUIControl(this, "Server/ServerStatus/ServerMaintenance")
    this.uidata.ServerName = SafeGetUIControl(this, "Server/TxtServerName", "Text")
    -- server list panel
    this.uidata.ServerList = SafeGetUIControl(this, "ServerList")
    this.uidata.ReturnServerList = SafeGetUIControl(this, "ServerList/BtnClose")
    this.uidata.Table = SafeGetUIControl(this, "ServerList/Tab/Scroll View/Viewport/Content")
    --适龄图标
    this.uidata.Img_Age = SafeGetUIControl(this, "Img_Age", "Image")
    this.uidata.TextVersion = SafeGetUIControl(this, "Img_Age/TextVersion", "Text")
    this.uidata.TextVersion.text = "V" .. Core.Instance.AppVersion  -- Application.version

    this.currentIndex = -1
    this.DefineIndex = 1
    for i = 1, this.uidata.Table.transform.childCount do
        local go = this.uidata.Table.transform:GetChild(i - 1)
        table.insert(this.Tables, go)
        SafeAddClickEvent(this.behaviour, go.gameObject, function()
            this.OnClickButton(i)
        end)
    end
    this.uidata.LastLoginServerName = SafeGetUIControl(this, "ServerList/ImgLastLoginServer/TxtServerName", "Text")
    this.uidata.LastLoginServerIdle = SafeGetUIControl(this, "ServerList/ImgLastLoginServer/ImgServerIdle", "Image")
    this.uidata.LastLoginServerFull = SafeGetUIControl(this, "ServerList/ImgLastLoginServer/ImgServerFull", "Image")
    this.uidata.LastLoginServerMaintenance = SafeGetUIControl(this,
        "ServerList/ImgLastLoginServer/ImgServerMaintenance", "Image")
    this.uidata.ServerListDetail = SafeGetUIControl(this, "ServerList/Tab/ServerDetail", "ItemWrap")

    local token = PlayerPrefs.GetInt("token");
    if token <= 0 then
        token = tonumber(os.time());
        PlayerPrefs.SetInt("token", token);
    end

    this.initLoginMemory()
    UIUtil.showWaitTip()
    NetModule.c2sRequestZonelist()
    makergetFn(Sc(), "system"):addEvent("zone_list", function(vo)
        --- 获取大区列表并存入zoneList
        this.zoneList = vo
        local accountNameStr = this.uidata.InputAccount.text or ""
        local url = this.zoneList[1].url .. "?openid=" .. accountNameStr -- 拼接一下
        PlayerModule.SetPayAreaId(tonumber(this.zoneList[1].zid))
        NetModule.c2sRequestServerlist(url)
        --体验服可以切换大区
        if NetModule.isTestServer() then 
            this.ShowSelectZoneList()
        end
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

        this.CheckAutoSelect()
        this.CheckAutoLogin()

        UIUtil.hideWaitTip()
    end)
    -- makergetFn(Sc(), "system"):addEvent("his_server_list", function(vo)
    --     this.hisServerList = vo
    -- end)
    ----------公告-------------------------微信自动登录，不需要弹出公告
    
    makergetFn(Sc(), "system"):addEvent("intro", function(vo)
        this.Notice = vo
        PlayerModule.notice = vo
        if PlayerModule.getSdkPlatform() ~= "wx" then
            ShowUI(UINames.UINotice,this.Notice)
        end
    end)
    
end

--初始化本地化
function Panel.InitLocalize()
    local components = this.transform:GetComponentsInChildren(typeof(Text))
    for i = 0, components.Length - 1 do
        local component = components[i]
        local textLocalize = component:GetComponent("TextLocalize")
        if textLocalize then
            component.text = GetLang(textLocalize.key)
        end
    end
end

function Panel.InitEvent()
    SafeAddClickEvent(this.behaviour, this.uidata.Account.gameObject, function()
        SafeSetActive(this.uidata.accountBox, true)
        TouchUtil.onOnceTap(this.Hide)
        this.Refresh()
        this.curState = LoginState.WaitLogin
        this.InitLocalize()
    end)
    
    SafeAddClickEvent(this.behaviour, this.uidata.Notice.gameObject, function()
        ShowUI(UINames.UINotice,this.Notice)
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.Login.gameObject, function ()
        if this.curState == LoginState.Logged then
            this.EnterGame()
            return
        else
            this.uidata.accountBox:SetActive(true)
            this.InitLocalize()
        end
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.btnLogin.gameObject, this.OnClickLogin)
    SafeAddClickEvent(this.behaviour, this.uidata.Server, this.OnClickOpenServerList)
    SafeAddClickEvent(this.behaviour, this.uidata.ReturnServerList.gameObject, function()
        SafeSetActive(this.uidata.ServerList, false)
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.accountCloseBtn.gameObject, function()
        SafeSetActive(this.uidata.accountBox, false)
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.Img_Age.gameObject, function()
        ---适龄弹窗
        -- UIUtil.showText('适龄弹窗')
        ShowUI(UINames.UIClauseInfo,3)
    end)
end

-- temporary
function Panel.Hide()
    local mousePos = Input.mousePosition
    if isNil(this.uidata.InputAccount) == false then 
        if UIUtil.isClickTarget(mousePos, this.uidata.InputAccount.gameObject) then
            TouchUtil.onOnceTap(this.Hide) -- 继续监听
            return
        end
    end

    if isNil(this.uidata.InputPassword) == false then
        if UIUtil.isClickTarget(mousePos, this.uidata.InputPassword.gameObject) then
            TouchUtil.onOnceTap(this.Hide) -- 继续监听
            return
        end
    end

    if isNil(this.uidata.accountBox) == false then
        SafeSetActive(this.uidata.accountBox, false)
    end
end

-- 抵制不良游戏，拒绝盗版游戏。注意自我保护，谨防上当受骗。
-- 适度游戏益脑，沉迷游戏伤身。合理安排时间，享受健康生活。
-- 著作权人：杭州守序网络有限公司 软著登记号：2018SR290165
-- 审批文号：国新出审[2020]1894号 出版物号：ISBN 978-7-498-08023-3
-- 出版单位：杭州电魂网络科技股份有限公司 

function Panel.Refresh()
    this.data[1] = {}
    if this.hisServerList ~= nil then
        for k, vv in pairs(this.hisServerList) do
            for kk, v in pairs(this.data) do
                if kk == 3 then
                    for k, _ in pairs(v) do
                        if vv.id == v[k].id then
                            table.insert(this.data[1], v[k])
                        end
                    end
                end
            end
        end
    end
    if this.data[1] ~= nil then
        table.sort(this.data[1], function(a, b)
            if a.showtime ~= b.showtime then
                return a.showtime > b.showtime
            end
        end)
        this.lastServer = this.currentServer
        if this.lastServer ~= nil then
            this.currentServer = this.lastServer
            this.uidata.ServerName.text = this.currentServer.name
            SafeSetActive(this.uidata.ServerIdle.gameObject,
                this.currentServer.state == 1 or this.currentServer.state == 2)
            SafeSetActive(this.uidata.ServerFull.gameObject, this.currentServer.state == 3)
            SafeSetActive(this.uidata.ServerMaintenance.gameObject, this.currentServer.state == 4)
        end
    end
end

-- SDK登录
function Panel.InitSDKLogin()
    if PlayerModule.getSdkPlatform() == "wx" then
        -- 微信登录，不需要创建账号
        SafeGetUIControl(this, "TabBtn/Account"):SetActive(false)
        this.isShowManual = false -- 跳过手动登录
        MiniGame.DHWXSDK.Instance:SetLoginCallback(function (sdkInfo)
            this.sdkInfo = json.decode(sdkInfo)
            this.InitLogin()
        end)
        MiniGame.DHWXSDK.Instance:Login("test")
    else
        this.InitLogin()
    end
end

function Panel.OnShow(_reconnect)
    this.InitSDKLogin()
end

function Panel.InitLogin()
    this.ShowManualLogin()
    
    this.InitData()
    this.InitPanel()
    this.InitEvent()

    -- 检查资源更新
    this.StartCheckResUpdate()

    -- todo: 临时
    this.Refresh()
end

---初始化登录记忆缓存
function Panel.initLoginMemory()
    local loginMemory = this.GetLoginMemoryStorage()
    if next(loginMemory) then
        this.uidata.InputAccount.text = loginMemory.openid
        this.uidata.InputAccount:ForceLabelUpdate()
    end
end

function Panel.OnClickOpenServerList()
    this.Refresh()
    SafeSetActive(this.uidata.ServerList, true)
    this.InitLocalize()
    if this.lastServer ~= nil then
        this.uidata.LastLoginServerName.text = this.lastServer.name
        SafeSetActive(this.uidata.LastLoginServerIdle.gameObject,
            this.lastServer.state == 1 or this.lastServer.state == 2)
        SafeSetActive(this.uidata.LastLoginServerFull.gameObject, this.lastServer.state == 3)
        SafeSetActive(this.uidata.LastLoginServerMaintenance.gameObject, this.lastServer.state == 4)
    end
    if #this.data[1] == 0 then
        SafeSetActive(this.Tables[1].gameObject, false)
        ForceRebuildLayoutImmediate(this.uidata.Table.gameObject)
        this.OnClickButton(2)
    else
        SafeSetActive(this.Tables[1].gameObject, true)
        this.OnClickButton(this.DefineIndex)
    end
end

function Panel.OnClickButton(index)
    if this.currentIndex == index then
        return
    end
    this.uidata.ServerListDetail:RemoveFilterFlag("all")
    this.ChangeTabStyle(this.currentIndex, false)
    this.ChangeTabStyle(index, true)
    this.currentIndex = index
    this.InitLocalize()

    for k, v in pairs(this.data[index]) do
        this.uidata.ServerListDetail:AddFilterData("all", k, 0, true)
    end
    -- 绑定刷新方法
    this.uidata.ServerListDetail:SetWrapCall(this.Init);

    -- 列表刷新数据
    this.uidata.ServerListDetail:ShowContent("all", true)
end

function Panel.ChangeTabStyle(index, isSelect)
    if this.Tables[index] == nil then
        return
    end
    local go = this.Tables[index]
    local select = go.transform:Find("ImgSelect")
    SafeSetActive(select.gameObject, isSelect)
end

function Panel.Init(go, flagValue)
    local data = this.data[this.currentIndex][flagValue]
    local ServerName = go.transform:Find("TxtServerName"):GetComponent("Text")
    local ServerRecommend = go.transform:Find("TxtRecommend")
    local ServerIdle = go.transform:Find("ImgServerIdle")
    local ServerFull = go.transform:Find("ImgServerFull")
    local ServerMaintenance = go.transform:Find("ImgServerMaintenance")
    local NewServer = go.transform:Find("ImgNewServer")
    ServerName.text = data.name
    ServerName.color = CreateColorFromHex(52, 52, 57, 255)
    if data.state == 4 then
        ServerName.color = Color.gray
    end
    SafeSetActive(ServerRecommend.gameObject, data.state == 2)
    SafeSetActive(ServerIdle.gameObject, data.state == 1 or data.state == 2)
    SafeSetActive(ServerFull.gameObject, data.state == 3)
    SafeSetActive(ServerMaintenance.gameObject, data.state == 4)
    SafeSetActive(NewServer.gameObject, data.state == 2)
    SafeAddClickEvent(this.behaviour, go, function()
        this.OnClickServer(data)
        this.uidata.ServerName.text = data.name
        SafeSetActive(this.uidata.ServerIdle.gameObject, data.state == 1 or data.state == 2)
        SafeSetActive(this.uidata.ServerFull.gameObject, data.state == 3)
        SafeSetActive(this.uidata.ServerMaintenance.gameObject, data.state == 4)
        this.curState = LoginState.WaitLogin
        this.uidata.accountBox:SetActive(true)
        this.InitLocalize()
    end)
end

function Panel.OnClickServer(Serverdata)
    SafeSetActive(this.uidata.ServerList, false)
    this.currentServer = Serverdata
end

---自动选服
function Panel.CheckAutoSelect()
    local his = this.hisServerList[1]
    local hisServerId = his and his.id or this.serverList[1].id
    local data = nil
    for k, v in ipairs(this.serverList) do
        if v.id == hisServerId then
            data = v
        end
    end

    this.OnClickServer(data)
    this.uidata.ServerName.text = data.name
    SafeSetActive(this.uidata.ServerIdle.gameObject, data.state == 1 or data.state == 2)
    SafeSetActive(this.uidata.ServerFull.gameObject, data.state == 3)
    SafeSetActive(this.uidata.ServerMaintenance.gameObject, data.state == 4)
end

--- 自动登录
function Panel.CheckAutoLogin()
    this.OnClickLogin()
end

function Panel.OnHide()
    this.behaviour:RemoveTimerEvent("AutoLogin");
    this.behaviour:RemoveTimerEvent("AutoConnect");
    -- 确保公告界面一并隐藏
    -- HideUI( UINames.UINotice )
    GlobalBehaviour.waitShowNotice = false;
    this.waitResVersionCallback = false;

    this.behaviour:RemoveTimerEvent("RefreshServerList");
end

---点击登陆
function Panel.OnClickLogin()
    local bBenji = false
    if bBenji then --单机测试版本
        local mapid = 1
        CityModule.openScene(mapid)
        GameManager.SetGameTime(os.time())
        DataManager.uid = 10000001
        DataManager.SetData(DataManager.uid)
        return
    end

    if PlayerModule.getSdkPlatform() == "wx" then
        this.loginAccount_DHWx()
    else
        NetModule.setServerUrl(this.currentServer.url)
        NetModule.setServerInfo(this.currentServer.id)
        this.SaveLoginMemoryStorage()
        local vo = NewCs("login")
        vo.info.login.loginAccount.openid = this.uidata.InputAccount.text
        vo.info.login.loginAccount.platform = "local"
        vo:add(this.LoginCompleted, true) -- 添加请求回调，true为请求结束以后回调
        vo:send()                         -- 发送请求
    end
end

function Panel.loginAccount_DHWx()
    MiniGame.DHWXSDK.Instance:AnalyticsLog("420000::GAME_CLIENT_LOGIN_START", "0", "hh")
    NetModule.setServerUrl(this.currentServer.url)
    NetModule.setServerInfo(this.currentServer.id)
    local vo = NewCs("login")
    vo.info.login.loginAccount.dh_token = this.sdkInfo.data.token;
    vo.info.login.loginAccount.platform = "dianhun"
    vo.info.login.loginAccount.openid = this.sdkInfo.data.accountId
    vo.info.login.loginAccount.logintype = "LoginType_Quick_Visitor"
    vo:add(function (vo)
        MiniGame.DHWXSDK.Instance:AnalyticsLog("450000::GAME_CLIENT_LOGIN_SUCCESS", "0", "hh")
        this.LoginCompleted(vo)
        if this.isShowManual == false and NetModule.isTestServer() == false then 
            this.EnterGame()
        end
    end, true)
    vo:send()
end

-- 登陆完成回调
function Panel.LoginCompleted(vo)
    UIUtil.showText(GetLang("ui_login_notice_1"))
    SafeSetActive(this.uidata.accountBox, false)
    this.isLogin = true
    local _vo = vo.a.loginMod.loginAccount
    this.announcementData = vo.a.notice

    -- 游戏客户端创角成功
    MiniGame.DHWXSDK.Instance:AnalyticsLog("450001::GAME_CLIENT_CREATING_A_ROLE", "0", "hh")

    NetModule.setRequestUidAndToken(_vo.uid, _vo.token)
    this.curState = LoginState.Logged
    -- this.EnterGame()
end

---本地储存登录记忆缓存
function Panel.SaveLoginMemoryStorage()
    local loginMemory = StorageModule.get(StorageModule.enum.LOGIN_MEMORY)
    loginMemory.openid = this.uidata.InputAccount.text or ""
    StorageModule.set(StorageModule.enum.LOGIN_MEMORY, loginMemory)
end

---获取本地储存登录记忆缓存
function Panel.GetLoginMemoryStorage()
    local loginMemory = StorageModule.get(StorageModule.enum.LOGIN_MEMORY)
    return loginMemory
end

function Panel.EnterGame()
    local vo = NewCs("guide")
    vo.info.guide.login.platform = "dianhun"
    vo:add(function(vo)
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

-- 开始检查资源更新
function Panel.StartCheckResUpdate()
    -- 第一次不用检查
    if GameStateData.isFirstEnterLoginScene then
        return;
    end

    this.waitResVersionCallback = true;
    HotfixModule.StartCheckResVersion(this.OnResUpdateCallback)
end

-- 资源更新回掉
function Panel.OnResUpdateCallback(_hasNew)
    if _hasNew and this.waitResVersionCallback then
        ShowUI(UINames.UICommonEnsure, GetStrDic(StrEnum.ExitForUpdateResTips), function()
            if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.Android then
                AndroidUtil.RestartApplication();
            else
                Application.Quit();
            end
        end)
    end
    this.waitResVersionCallback = false;
end

-- 显示手动登录
function Panel.ShowManualLogin()
    SafeGetUIControl(this, "TabBtn"):SetActive(this.isShowManual)
    SafeGetUIControl(this, "BtnLogin"):SetActive(this.isShowManual)
    SafeGetUIControl(this, "Server"):SetActive(this.isShowManual)
end

-- 添加可以选择大区(只有体能服有这个功能)
function Panel.ShowSelectZoneList()
    SafeGetUIControl(this, "BtnLogin"):SetActive(true)
    SafeGetUIControl(this, "ZoneList"):SetActive(true)

    local onClickZoneItem = function(index) 
        local accountNameStr = this.uidata.InputAccount.text or ""
        local url = this.zoneList[index].url .. "?openid=" .. "accountNameStr" -- 拼接一下
        PlayerModule.SetPayAreaId(tonumber(this.zoneList[index].zid))
        NetModule.c2sRequestServerlist(url)
    end

    this.uidata.btn_zone_1 = SafeGetUIControl(this, "ZoneList/btn_zone_1", "Button")
    this.uidata.btn_zone_2 = SafeGetUIControl(this, "ZoneList/btn_zone_2", "Button")
    SafeAddClickEvent(this.behaviour, this.uidata.btn_zone_1.gameObject, function()
        onClickZoneItem(1)
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.btn_zone_2.gameObject, function()
        onClickZoneItem(2)
    end)

    this.uidata.txt_zone_1 = SafeGetUIControl(this, "ZoneList/btn_zone_1/Text", "Text")
    this.uidata.txt_zone_2 = SafeGetUIControl(this, "ZoneList/btn_zone_2/Text", "Text")

    this.uidata.txt_zone_1.text = this.zoneList[1].name
    this.uidata.txt_zone_2.text = this.zoneList[2].name
end
