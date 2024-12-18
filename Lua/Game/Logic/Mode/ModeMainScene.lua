ModeMainScene = Clone(ModeNormal)
ModeMainScene.__cname = "ModeMainScene"

---模式进入
function ModeMainScene:OnEnter()
    if GameManager.ColdStart then
        self.isStartUp = true
        self:InitManager()
        
        -- 临时
        self:InitView()
        -- CharacterManager.InitView()
        TaskManager.InitView()
        GameManager.ColdStart = false
        GameManager.GamePause = false
    else
        self:InitManager()
        -- 临时
        -- FoodSystemManager.InitView()
        self:InitView()
        GameManager.ColdStart = false
        GameManager.GamePause = false
        CharacterManager.InitView()
        TaskManager.InitView()
    end

    CharacterManager.InitView()
    self:AfterAllInit()

    self.OnHideLoadingUI = function(param)
        GameManager.LoadStart = false         
        self:InitSceneBatch(GameManager.OfflineAction.value)
    end
    Event.AddListener(EventDefine.HideLoadingUI, self.OnHideLoadingUI)

    self.OnOfflineOver = function()
        self:InitSceneBatch(GameManager.OfflineAction.value)
    end 
    Event.AddListener(EventDefine.OnOfflineOver, self.OnOfflineOver)
    -- self.offlineActionRx =
    --     GameManager.OfflineAction:subscribe(
    --         function(action)
    --             self:InitSceneBatch(action)
    --         end,
    --         false
    --     )
end

--初始化数据
function ModeMainScene:InitManager()
    --Analytics.LoadingStep("DataManagerInit")
    -- CameraManager.Init()
    --DataManager.Init()--暂时转移到CityMapCtrl 初始化  zhangzh 20230731
    --    PersistManager.Init()
    --   -- GridManager.Init()暂时转移到CityMapCtrl 初始化  zhangzh 20230729
    --    --ObjectPoolManager.Init()
    --    TestManager.Init()
    --    --Analytics.LoadingStep("MapManagerInit")
    --    PostStationManager.Init() --必须放到所有可能添加reward奖励的Manager之前
    --    DailyShoutManager.Init()
    --    DailyBagManager.Init()
    --    --ProfileManager.Init()
    --    TutorialManager.Init()
    --CameraEffectManager.Init()
    --MapManager.Init() ----暂时转移到CityModule 初始化  zhangzh 20230721
    TimeManager.Init()
    FunctionsManager.Init()
    OverTimeProductionManager.Init()
    StatisticalManager.Init()
    --Analytics.LoadingStep("CardManagerInit")
    CardManager.Init()
    FoodSystemManager.Init()
   -- LeaderboardManager.Init()
    --EventSceneManager.Init()
    ---Boost的开始时间依托于payment中存储的特权开始时间
    ---所以把PaymentManager.Init()放在BoostManager.Init()之前
    ---原先逻辑中PaymentManager.Init()会刷新BoostManager.RefreshSubscriptionBoost()
    ---将BoostManager.Init()放在PaymentManager.Init()之前会导致BoostManager.RefreshSubscriptionBoost()无法刷新
    ---所以将BoostManager.RefreshSubscriptionBoost()放到PaymentManager.InitSubscription()中
    ---并在BoostManager.Init()后调用
    PaymentManager.Init()
    BoostManager.Init()
    PaymentManager.InitSubscription()
    GeneratorManager.Init()
    TaskManager.Init()
    CityPassManager.Init()
    DiyCardManager.Init()
    FloatIconManager.Init()
    DiscordTipManager.Init()
    BoxManager.Init()
   -- AdventureContManager.Init()
    --AudioManager.Init()
    MailManager.Init()
    HaloManager.Init()
    SurveyManager.Init()
    DissolveCardManager.Init()
    OfflineManager.Init()
    CharacterManager.Init()
    ProtestManager.Init()
    WeatherManager.Init()
    WorkOverTimeManager.Init()
    SchedulesManager.Init()
    --ShopManager.Init()
    --RoguelikeLogicManager.Init()
    --ResAddEffectManager.Init()
    StoryBookManager.Init()
    --PushNotifyManager.Init()
    PlayerRatingManager.Init()
    --UpdateCompensateManager.Init() --发奖用，放最后
    --Analytics.LoadingStep("ManagerInitComplete")


    UpdateCompensateManager.Init() --发奖用，放最后

    --帧率调整：时间间隔、最大帧率、最小帧率、调整步长
    -- AppCenter.ins:SetFrameRateConfig(30, 60, 30, 10)

end

--初始化显示
function ModeMainScene:InitView()
    -- temp
    --     --Analytics.LoadingStep("InitView")
    --     if CityManager.GetIsEventScene() then
    --         if CityManager.IsEventScene(EventCityType.Water) then
    -- --            AudioManager.RefeshEventSceneWater()
    -- --            AudioManager.SwitchWaterMusic()
    --         else
    -- --            AudioManager.SwitchFarmMusic()
    -- --            AudioManager.RefeshEventSceneFarm()
    --         end
    -- --        AudioManager.StopPlayWind()
    -- --        self.mainUI = ResourceManager.Instantiate("UI/EventMainUI")
    --     else
    -- --        AudioManager.SwitchMainMusic()
    -- --        AudioManager.StopEventScene()
    -- --        AudioManager.RefeshPlayWind()
    -- --        self.mainUI = ResourceManager.Instantiate("UI/MainUI")
    --     end
    -- PostStationManager.InitView() --需要放到场景加载之前，将奖励数据准备好
    -- --    self.map = ResourceManager.Instantiate("prefab/map/Map")
    --     MapManager.InitView()--暂时转移到CityModule 初始化  zhangzh 20230721
    --     CharacterManager.InitView()
    --     FoodSystemManager.InitView()
    --     EventSceneManager.InitView()
        OfflineManager.InitView()
    --     TaskManager.InitView()
    -- FunctionsManager.InitView()
    ProtestManager.InitView()
    WeatherManager.InitView()
    -- --    ToolTipManager.Init(self.mainUI.transform:Find("ToolTip"))
    -- --    ResAddEffectManager.InitView(self.mainUI.transform:Find("ResAddEffect"))
    -- --    self:RemovePreloader()
    -- --    Analytics.LoadingStep("LoadingComplete")
    -- --    if GameManager.ColdStart then
    -- --        Analytics.Event("LoadingComplete", {accountType = SDKManager.accountType})
    -- --    end
    --     HelpShiftManager.Init()
    --     GameManager.ColdStart = false
    --     GameManager.GamePause = false
    --     EventSceneManager.CheckEventReward()
    --     CardManager.LogUpdateCardFarm()
    --     ShopManager.InitView()

    -- FoodSystemManager.InitView()
end

function ModeMainScene:AfterAllInit()
    MapManager.AfterAllInit() --暂时转移到CityModule 初始化  zhangzh 20230721
    StoryBookManager.AfterAllInit()
end

--处理进入游戏或者切换场景的执行队列
function ModeMainScene:InitSceneBatch(action)
    local zoomSize = ConfigManager.GetMiscConfig("default_camera_size")
    if
        CityManager.IsEventScene(EventCityType.Water) and
        not DataManager.GetCityDataByKey(DataManager.GetCityId(), DataKey.FristInit)
    then
        zoomSize = 55
    end

    local zoomZ = -55
    if action == GameAction.OfflineInit then
        self.zoomCamera = true
    elseif action == GameAction.OfflineNo then
        if TutorialManager.IsExistTutorial() then
            -- TutorialManager.CheckTutorial()
        else
            CityModule.getMainCtrl().camera:setZoomMin()
            CityModule.getMainCtrl().camera:DoCameraSize(zoomZ, 0.5, 1)
            self.zoomCamera = false
            self:PlayCameraEffect()
        end
    elseif action == GameAction.OfflineShow then
        -- if self.zoomCamera and not TutorialManager.IsExistTutorial() then
        -- if self.zoomCamera then
            CityModule.getMainCtrl().camera:setZoomMin()
        -- end
    elseif action == GameAction.OfflineClose then
        -- if self.zoomCamera and not TutorialManager.IsExistTutorial() then
        -- if self.zoomCamera then
            CityModule.getMainCtrl().camera:setZoomMax()
            CityModule.getMainCtrl().camera:DoCameraSize(zoomZ, 0.5, 1)
            self.zoomCamera = false
            self:PlayCameraEffect()
        -- end
    end
end

--播放相机效果
function ModeMainScene:PlayCameraEffect()
    if self.isStartUp then
        -- CameraEffectManager.PlayFreezeAndSnowstorm()
        if UIMainPanel ~= nil and UIMainPanel.uidata ~= nil and UIMainPanel.UIDqFunc ~= nil then
            UIMainPanel.UIDqFunc(DataManager.GetCityId())
        end
    else
        -- CameraEffectManager.PlaysbigSnowEff()
    end
end

--删掉preloader
function ModeMainScene:RemovePreloader()
    setTimeout(
        function()
            -- AppAudio.SetCameraEnable(true)
            ResourceManager.Destroy(GameObject.Find("Preloader").gameObject)
            local progress = GameObject.Find("Preloader_Progress")
            if progress ~= nil then
                ResourceManager.Destroy(progress.gameObject)
            end
        end,
        500
    )
    if GameManager.changeSceneInfo ~= nil then
        local duration = os.clock() - GameManager.changeSceneInfo.ts
        local obj = {
            duration = duration,
            nextCityId = GameManager.changeSceneInfo.nextCityId,
            prevCityId = GameManager.changeSceneInfo.currentCityId
        }
        Analytics.Event("EnterCity", obj)
        GameManager.changeSceneInfo = nil
    end
end

---模式刷新
function ModeMainScene:OnUpdate()
    -- LogWarningFormat("ModeMainScene:OnUpdate time = {0}", TimerFunction.deltaTime)
    --Map.Instance:Update()
    --PopupManager.Instance:Update()
    DataManager.OnUpdate()
    TimeManager.OnUpdate()
    MapManager.OnUpdate() --暂时转移到CityModule 初始化  zhangzh 20230721
    CharacterManager.OnUpdate()
    WeatherManager.OnUpdate()

    CityModule.OnUpdate()
end

--清除显示
function ModeMainScene:ClearView()
    CharacterManager.ClearView()
    FoodSystemManager.ClearView()
    ProtestManager.ClearView()
    WeatherManager.ClearView()
    MapManager.ClearView() --暂时转移到CityModule 初始化  zhangzh 20230721
    ResourceManager.Destroy(self.mainUI)
    ResourceManager.Destroy(self.map)
end

---模式停止
function ModeMainScene:OnExit(forceClear)
    local forceClear = true
    -- self.offlineActionRx:unsubscribe()
    self:ClearView()
    TestManager.Clear(forceClear)
    TimeManager.Clear(forceClear)
    ProtestManager.Clear(forceClear)
    WeatherManager.Clear(forceClear)
    WorkOverTimeManager.Clear(forceClear)
    SchedulesManager.Clear(forceClear)
    TaskManager.Clear(forceClear)
    CharacterManager.Clear(forceClear)
    FoodSystemManager.Clear(forceClear)
    GridManager.Clear(forceClear)
    GeneratorManager.Clear(forceClear)
    DataManager.Clear(forceClear)
    DOTween.KillAll(false)
    MapManager.Clear(forceClear)
    FloatIconManager.Clear()
    BoostManager.Clear(forceClear)
    StatisticalManager.Clear(forceClear)
    --ToolTipManager.Clear()
    -- ResAddEffectManager.Clear()
    --HelpShiftManager.Clear()
    DiscordTipManager.Clear()
    --EventSceneManager.Clear()
    -- CameraEffectManager.ClearCityCameraEffect()
    OverTimeProductionManager.Clear(forceClear)
    StoryBookManager.Clear()
    -- ObjectPoolManager.Clear()

    Event.RemoveListener(EventDefine.HideLoadingUI, self.OnHideLoadingUI)
    Event.RemoveListener(EventDefine.OnOfflineOver, self.OnOfflineOver)
end

--切换帐号会重置一些数据
function ModeMainScene:OnReset()
    TaskManager.Reset()
    PostStationManager.Reset()
    DailyShoutManager.Reset()
    DailyBagManager.Reset()
   -- ProfileManager.Reset()
    CardManager.Reset()
    LeaderboardManager.Reset()
    MailManager.Reset()
    SurveyManager.Reset()
    DissolveCardManager.Reset()
    -- PaymentManager.Reset()
    PushNotifyManager.Reset()
    --AudioManager.Reset()
    --NetManager.Reset()
end
