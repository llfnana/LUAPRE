GameManager = {}
GameManager.__cname = "GameManager"

local this = GameManager
---------------------------------------
---开始游戏
---------------------------------------
function GameManager.StartGame(isDebug)
    print("GameManager.StartGame")
    this.version = Game.GetServerVersion() -- AppCenter.version
    this.buildVerion = "localEditor"
    this.dbVersion = 1
    print("Version: " .. this.version)
    -- this.ReadBuildVersion()
    this.ColdStart = true
    this.LoadStart = true
    this.gameTime = TimeModule.getServerTime()
    this.offsetTime = Time.realtimeSinceStartup
    this.isDebug = isDebug
    this.isEditor = Util.InUnityEditor() --Application.platform ~=UnityEngine.RuntimePlatform.Android and Application.platform ~= UnityEngine.RuntimePlatform.IPhonePlayer
    --    local luaEvent = GameObject("LuaEvent")
    --    luaEvent:AddComponent(TypeLuaEventBehaviour)
    this.modeController = ModeController:New()
    --    this.skillBulletManager = SkillBulletManager:New()
    this.GameSpeed = NumberRx:New(1)
    this.OfflineAction = NumberRx:New(GameAction.None)
    this.GamePause = false
    this.DontReload = false
    this.TutorialOpen = false
    this.TeQuanAuto = false
    TimerFunction.Init()
    --    this.LoadMode(ModeType.Loading)
end

---------------------------------------
---游戏刷新
---------------------------------------

local ECSUpdate = {
    main = function()
        --ECS.world:Execute()
    end,
    catch = function(errors)
        print("[error]" .. "【Ecs Execute Errors】:" .. errors)
    end
}
--读取打包Version
function GameManager.ReadBuildVersion()
    Utils.LoadStreamingAssetsText(
        "version.txt",
        function(buildVersion, errFlag)
            if errFlag == nil then
                this.buildVerion = buildVersion
                Log("buildVerion: " .. this.buildVerion)
            end
        end
    )
end

function GameManager.Update()
    if GameStateData.isGameLogicRunning == false then
        return
    end
    if not this.GamePause then
        -- ECSUpdate.main()
        LTimerManager.Update()
        TimerFunction.Update()
        if this.modeController then
            this.modeController:Update()
        end
    end
    if this.modeController then
        this.modeController:ForceUpdate()
    end
end

function GameManager.SetGameTime(tm)
    this.gameTime = tm
    this.offsetTime = Time.realtimeSinceStartup
end

function GameManager.GameTime()
    this.gameTime = TimeModule.getServerTime()
    return math.floor(this.gameTime)
end

function GameManager.Realtime()
    return this.gameTime + (Time.realtimeSinceStartup - this.offsetTime)
end

--用于调试指定特殊时间
function GameManager.DebugGameTime()
    local now = math.floor(this.gameTime + (Time.realtimeSinceStartup - this.offsetTime))
    if this.debugOffsetTime == nil then
        local wantTime =
            os.time(
                {
                    year = 2022,
                    month = 7,
                    day = 14,
                    hour = 7,
                    min = 58,
                    sec = 30
                }
            )
        this.debugOffsetTime = wantTime - now
    end

    return now + this.debugOffsetTime
end

function GameManager.OnApplicationPause(pause)
    Log("OnApplicationPause:" .. tostring(pause))
    if not DataManager.firstInit then
        if pause == true then
            Log("主动保存")
            this.PauseTime = this.GameTime()
            PushNotifyManager.LeaveGame() -- 要放到保存数据请求前

            EventManager.Brocast(EventType.APPLICATION_LEAVE_GAME)

            DataManager.SaveAll()
            DataManager.CheckSaveToLocalByModule()
            DataManager.CheckSaveToServer()
            NetManager.SendQueue()
        else
            PushNotifyManager.JoinGame()

            local backTime = this.GameTime() - this.PauseTime
            LogWarning("小退:" .. backTime .. "秒")
            --LogWarning("this.DontReload:" .. tostring(this.DontReload))
            if backTime >= ConfigManager.GetOfflineTime() and this.DontReload == false and not GameManager.TutorialOpen then
                PopupManager.ForceClosePanel()
                --AdventureContManager.CleartimerData()
                DataManager.CheckCityId()
                GameManager.LoadMode(ModeType.RebootScene, true)

                EventManager.Brocast(EventType.APPLICATION_JOIN_GAME, true)
            else
                LogWarning("处理离线:" .. backTime .. "秒")
                DailyShoutManager.OnAppFocus()
                OfflineManager.OnCalculate(backTime, this.PauseTime)
               -- EventSceneManager.LogTime()
                PaymentManager.OnAppFocus(true)

                EventManager.Brocast(EventType.APPLICATION_JOIN_GAME, false)
            end
            this.DontReload = false
        end
    end
end

function GameManager.OnPressEsc()
    if nil ~= PopupManager.Instance and Utils.NotNull(PopupManager.Instance.transform) then
        PopupManager.Instance:OnPressEsc()
    end
    --ToolTipManager.HideToolTip()
end

function GameManager.SetOfflineAction(value)
    if this.OfflineAction.value ~= value then
        this.OfflineAction.value = value
    end
end

function GameManager.OnMouseDown()
   -- ToolTipManager.HideToolTip()
    ResAddEffectManager.AddClickEffectOnScreen(Input.mousePosition)
end

function GameManager.OnScreenResizeFun()
    if nil ~= MainUI.Instance and Utils.NotNull(MainUI.Instance.transform) then
        HudHandles.ScreenResize(MainUI.Instance)
    end
end

---------------------------------------
---加载制定模式类型的模式
---------------------------------------
function GameManager.LoadMode(modeType, forceClear)
    this.modeController:SetNextMode(modeType, forceClear)
end

function GameManager.RebootGame()
    this.modeController:ResetMode()
    this.LoadMode(ModeType.BindAccountScene, true)
end

function GameManager.GetPreModeType()
    return this.modeController:GetPreModeType()
end

function GameManager.GetModeType()
    return this.modeController:GetModeType()
end

function GameManager.DebugTraceBack()
    if GameManager.isDebug then
        print("[error]" .. "LuaTraceBack:" .. debug.traceback())
    end
end

function GameManager.IsCardNew()
    return true
end

function GameManager.ExitMainScene()
    --UpdateBeat:Remove(this.update, this)
    GameManager.LoadStart = true
    DataManager.SaveAll()
    CharacterManager.ClearView()
    FoodSystemManager.ClearView()
    ProtestManager.ClearView()
    WeatherManager.ClearView()
    MapManager.ClearView() --暂时转移到CityModule 初始化  zhangzh 20230721

    local forceClear = true
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
end

UpdateBeat:Add(this.Update, this)
--MonoEvent.AddListener(MonoEventType.Update, this.Update)
MonoEvent.AddListener(MonoEventType.OnApplicationPause, this.OnApplicationPause)
MonoEvent.AddListener(MonoEventType.OnPressEsc, this.OnPressEsc)
MonoEvent.AddListener(MonoEventType.OnMouseDown, this.OnMouseDown)
MonoEvent.AddListener(MonoEventType.OnScreenResize, this.OnScreenResizeFun)
