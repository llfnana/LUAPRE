ModeLoading = Clone(ModeNormal)
ModeLoading.__cname = "ModeLoading"

---模式进入
function ModeLoading:OnEnter()
    --这个地方初始化 SDK 加载配置 与 加载用户数据
--    self.Preloader = GameObject.Find("Preloader").gameObject:GetComponent(TypePreloader)
--    ResourceManager.Load("spriteatlas/ui", TypeSpriteAtlas)
    ConfigManager.Init()
    --AudioManager.LoadSoundBank()
   -- NetManager.Init()
--    self.Preloader.PrivacyEvent = function(action)
--        self:OnPrivacyEventFun(action)
--    end
--    self:InitSDK()

--这里  临时处理  zhangzhihong 20230705
      self:InitOtherEx()
end

---模式刷新
function ModeLoading:OnUpdate()
    -- LogWarningFormat("ModeLoading:OnUpdate time = {0}", TimerFunction.deltaTime)
end

---模式停止
function ModeLoading:OnExit()
    -- CS.FrozenCity.GameEntry.UI:CloseWindow("Preloader", true)
end

--登录SDK
function ModeLoading:InitSDK()
    -- self.Preloader:SetProgress(45, 1)
    -- self.loginCount = 0
    -- SDKManager.Init(
    --     function(method, message)
    --         if method == "SDKSuccess" then
    --             self.Preloader:SetFpid("id " .. SDKManager.fpid)
    --             if Application.platform == RuntimePlatform.IPhonePlayer then
    --                 self:GetGMRemoteConfig()
    --             else
    --                 self:GetFirebaseConfig()
    --             end
    --         elseif method == "NetError" then
    --             self.Preloader:ShowMessagePanel(
    --                 "",
    --                 GetLang("ui_check_net_notice"),
    --                 function()
    --                     SDKManager.AgainInit()
    --                 end
    --             )
    --         elseif method == "SDKError" then
    --             self.Preloader:ShowMessagePanel(
    --                 "SDK Error",
    --                 message,
    --                 function()
    --                     SDKManager.AgainInit()
    --                 end
    --             )
    --         else
    --             self.Preloader:ShowMessagePanel(method, message)
    --         end
    --     end
    -- )
end

--获取FirebaseConfig
function ModeLoading:GetFirebaseConfig()
    -- self.Preloader:SetProgress(50, 1)
    -- Analytics.LoadingStep("GetFirebaseConfig")
    -- FirebaseManager.Init(
    --     function(status)
    --         if status == "Success" then
    --             local remoteMiscConfig = JSON.decode(FirebaseManager.GetAllConfigParams(0))
    --             ConfigManager.SetFirebaseMiscConfig(remoteMiscConfig)
    --         else
    --             Analytics.Error("GetFirebaseConfigError")
    --         end
    --         self:GetGMRemoteConfig()
    --     end
    -- )
end

--获取后端配置
function ModeLoading:GetGMRemoteConfig()
    self.Preloader:SetProgress(60, 1)
    Analytics.LoadingStep("LoadRemoteConfig")
    local url = "https://frozencity-cdn.akamaized.net/prod/remote-config/"
    if GameManager.isDebug then
        url = "https://frozencity-cdn.akamaized.net/dev/remote-config/"
    end
    url = url .. GameManager.version .. ".misc.json?" .. os.time()
    NetManager.GetCDNConfig(
        url,
        3,
        function(txt, err)
            if err == nil then
                Log("remoteConfig:" .. txt)
                local remoteMiscConfig = JSON.decode(txt)
                ConfigManager.SetGMRemoteMiscConfig(remoteMiscConfig)
                Analytics.LoadingStep("LoadRemoteConfigSuccess")
            else
                Analytics.Error("RemoteConfigError")
            end
            self:InitOther()
            self:Login()
        end
    )
end

--初始化其他SDK
function ModeLoading:InitOther()
    if Application.platform ~= RuntimePlatform.IPhonePlayer then
        ConfigManager.TraceABTestKeys()
    end
    ConfigManager.RequireConfig()
    FunctionHandles.LoadConfig()
    NetManager.InitConfig()
    AdManager.Init()
    -- PaymentManager.AddEvent()
    --SurveyManager.AddEvent()
  --  HelpShiftManager.AddEvent()
   -- AppRateManager.Init()
   -- Analytics.TraceEvent("luaStart", {patchversion = AppCenter.version})
    -- self.Preloader:SetVersionText("v" .. GameManager.version .. "-" .. GameManager.buildVerion)
end

--初始化其他Ex-- 临时处理  zhangzhihong 20230705
--商城需要初始化支付的一些数据 daicongcong 2023/8/4
function ModeLoading:InitOtherEx()
--    if Application.platform ~= RuntimePlatform.IPhonePlayer then
--        ConfigManager.TraceABTestKeys()
--    end
    ConfigManager.RequireConfig()
    FunctionHandles.LoadConfig()
    --NetManager.InitConfig()
   -- AdManager.Init()
    PaymentManager.AddEvent()
    --SurveyManager.AddEvent()
    --HelpShiftManager.AddEvent()
    --AppRateManager.Init()
    --Analytics.TraceEvent("luaStart", {patchversion = AppCenter.version})
end

--重新登录SDK
function ModeLoading:AgainInitSDK()
    -- if self.loginCount >= 3 then
    --     Analytics.LoadingStep("LoginServerFaild")
    --     self.Preloader:ShowMessagePanel("Login Server Faild", "Login Server Faild")
    --     return
    -- end
    -- SDKManager.AgainLogin(
    --     function(method, message)
    --         if method == "SDKSuccess" then
    --             self:Login()
    --         elseif method == "SDKError" then
    --             self.Preloader:ShowMessagePanel(
    --                 "SDK Error",
    --                 message,
    --                 function()
    --                     SDKManager.StartLogin()
    --                 end
    --             )
    --         else
    --             self.Preloader:ShowMessagePanel(method, message)
    --         end
    --     end
    -- )
end

--登录后端服务器
function ModeLoading:Login()
    self.Preloader:SetProgress(70, 1)
    self.loginCount = self.loginCount + 1
    Analytics.LoadingStep("LoginServer")
    NetManager.Login(
        function(rep, err)
            if rep ~= nil then
                if rep.err_code ~= nil and rep.err_code == 0 then
                    --设置客户端时间戳
                    GameManager.SetGameTime(NetManager.timestamps)
                    setTimeout(
                        function()
                            self:GetUserData()
                        end,
                        0
                    )
                elseif rep.err_code == 1129 or rep.err_code == 1128 then
                    self:AgainInitSDK()
                else
                    Analytics.Error("LoginServerErrCode", rep.err_code .. "")
                    self.Preloader:ShowMessagePanel("Login Server Error", "ErrCode:" .. rep.err_code)
                end
            else
                local showErrString = err
                if err == NetManager.ErrMessage.ErrPlayerIsBanned then
                    showErrString = GetLang("ui_cheater_tips")
                end
                self.Preloader:ShowMessagePanel("Login Server Error", showErrString)
            end
        end,
        5
    )
end

--获取用户数据
function ModeLoading:GetUserData()
    self.Preloader:SetProgress(90, 1)
    Analytics.LoadingStep("GetUserData")
    NetManager.GetAllData(
        function(retData)
            if retData ~= nil then
                DataManager.SetData(NetManager.uid, retData)
                Analytics.TraceEvent("ads_switch", {ad_switch_status = ConfigManager.GetMiscConfig("ads_switch")})
                Log("广告开关:" .. tostring(ConfigManager.GetMiscConfig("ads_switch")))
                DataManager.CheckVerion()
                setTimeout(
                    function()
                        self:CheckPrivacy()
                    end,
                    0
                )
            else
                self.Preloader:ShowMessagePanel("GetUserData Failed", "GetUserData Failed")
            end
        end
    )
end

--检测隐私弹窗
function ModeLoading:CheckPrivacy()
    self.Preloader:SetProgress(100, 1)
    if PlayerPrefs.HasKey("FctPrivacy") then
        self:EnterMainScene()
    else
        self.Preloader:ShowPrivacyPanel()
    end
end

--隐私弹窗
function ModeLoading:OnPrivacyEventFun(action)
    if action == "OnClickPolicyFun" then
        Analytics.TraceEvent("ClickPolicyLink", {})
        Application.OpenURL(ConfigManager.GetMiscConfig("privacy_url"))
    elseif action == "OnAcceptPolicyFun" then
        Analytics.TraceEvent("AcceptPolicy", {})
        PlayerPrefs.SetString("FctPrivacy", "true")
        self.Preloader:HidePrivacyPanel()
        setTimeout(
            function()
                if Application.platform == RuntimePlatform.IPhonePlayer then
                    SDKWrap.ShowIdfaTrackingAuthorization()
                end
                self:EnterMainScene()
            end,
            200
        )
    end
end

--初始化游戏
function ModeLoading:EnterMainScene()
   -- Analytics.LoadingStep("EnterMainScene")
    DataManager.CheckCityId()
   -- GameManager.LoadMode(ModeType.MainScene, nil)
   -- DataManager.UpdateUserInfoToSDK()
   -- PushNotifyManager.JoinGame()
end
