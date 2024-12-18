require "Common/require_main"

--游戏主要入口--
Game = {};
local this = Game;
this.hasLoseFocus = nil; --就否失去焦点在后面
this.loseFocusTime = 0

local modules = {} --所有逻辑模块

function Game.InitViewPanels()
	local viewTab = require("TableSpec/ViewTable")
	for _, v in ipairs(viewTab) do
		require (v)
	end
end

--初始化完成，资源都已经更新完毕，可以开始相关初始化和登录了--
function Game.OnInitOK()  
	if LuaJitMode ~= nil then
		warn("LuaJitMode = "..LuaJitMode)
	else
		warn("LuaJitMode = nil");
	end

	log("Game.OnInitOK..time="..Time.time)

	-- 电脑上不会因为失去焦点而停止，方便测试
	if UnityEngine.Application.isEditor then 
		Application.runInBackground = true
	end

	--注册LuaView--
    this.InitViewPanels();

	SceneManager:Inst():Init()	--场景管理器初始化

	LuaManager:SetLuaUpdateInterval(0.02) --设置LuaUpdate默认刷新频率, 即UpdateBeat频率
	Layer.Init();
	
	--执行预加载
	PreloadAsset.PreloadOnGameLoading();

	--加载配表
	require("TableSpec/ConfigTable")

	this.InitModules() --初始化逻辑模块

	--读取表格
	local isLazyLoadTable = true;
	TableManager:Inst():InitAllTable(isLazyLoadTable)
	if isLazyLoadTable then
		this.OnAllTableLoad();
	end

	Utils.SetFrameTarget()

	if UnityEngine.Application.isEditor == false then 
		-- 错误日志管理 
		Application.logMessageReceived = Application.logMessageReceived + SDKAnalytics.ErrorLog
	end
	
	Language.addLang()

	GameManager.StartGame(true)

	this.ReadyLogin()
end

function Game.VersionCheck()
	GameUpdate.Update()
end

---初始化模块
function Game.InitModules()
	-- Replace the built-in require function with the custom function
	local originalRequire = require
	local function myRequire(modName)
		require = originalRequire

		local mod = originalRequire(modName)
		table.insert(modules, mod)

		require = myRequire
		return mod
	end
	require = myRequire

	TimeModule = require("Module/TimeModule")
	NetModule = require("Module/Net/NetModule")
	NetModule.initZoneUrl()
	
	AnalyseModule = require("Module/Analyse/AnalyseModule")
	StorageModule = require("Module/StorageModule")
	BagModule = require("Module/BagModule")
	-- GMModule = require("Module/GM/GMModule")

	PlayerModule = require("Module/Player/PlayerModule") -- 玩家模块在其他业务模块之前初始化
	CityModule = require("Game/Logic/Model/City/CityModule")
	FactoryGameModule = require("Game/Logic/NewView/FactoryGame/FactoryGameModule")

	--模块初始化
	for _, v in ipairs(modules) do
		v.init()
	end

	require = originalRequire

	makergetFn(Sc(), "loginMod"):addEvent("loginAccount", function ()
		--模块开启
		for _, v in ipairs(modules) do
			if v.start then v.start() end
		end
	end)
end

function Game.OnAllTableLoad()
	InitUIFunctions();
	GlobalBehaviour.Init();
	require "Game/RequireInit"
end

function Game.ReadyLogin()
	ShowUISync(UINames.UILoginNew)
	Audio.PlayAudio( DefaultAudioID.LoginScene)

	---暂时把末日生存的登陆初始化放在这里  zhangzhihong 20230705
	GameManager.LoadMode(ModeType.Loading)
end

function Game.Logout()
	--模块退出
	for _, v in ipairs(modules) do
		if v.exit then v.exit() end
	end

	SceneManager:Inst():ChangeScene(SceneNames.LoginScene)
end

--重置语言
function Game.OnLanguageChanged(language)
	
end

function Game.OnApplicationFocus( focus )
	if not focus then
		--失去焦点
		this.loseFocusTime = os.time();
	else
		if this.loseFocusTime ~= nil then
			--恢复焦点
			SceneManager:Inst():OnResume();
			local locsFoucsDuration =  os.time() - this.loseFocusTime
			if  locsFoucsDuration >= 600  then --后台驻留时间过长
				if GameStateData.isGameLogicRunning then --，返回时退回登录界面
					SceneManager:Inst():ChangeScene( SceneNames.LoginScene, nil, false );
				else
					--检测更新
					HotfixModule.StartCheckResVersion()
				end
			else 
				if GameStateData.isGameLogicRunning then
					local nowGameTime = Time.realtimeSinceStartup;
					GameStateData.waitHeartBeatWhenFocus = true;

					--尝试处理BUG: 从后台切换回来, 小米Max3出现屏幕下半部分无法点击
					--如果在强制引导中，不处理，走原来的东西
					--如果在非强制引导中，关闭当前的引导
					if locsFoucsDuration >= 120 then
						local bReShow = true
						if bReShow then
							local curSceneName = SceneManager:Inst():GetCurrentSceneName();
							if curSceneName == SceneNames.HomeScene or curSceneName == SceneNames.BigMapScene then
								HideUIAll();
								this.ResetMainCamera();
							elseif curSceneName == SceneNames.DungeonScene then
								local curScene = SceneManager:Inst():GetCurrentScene();
								if curScene ~= nil then
									if curScene.chapterId ~= nil and curScene.chapterId > 0 then
										HideUIAll();
										ShowUI(UINames.UIDungeonMain, curScene.chapterId);
										this.ResetMainCamera();
									end
								end
							end
						end	
					end				
				end
			end
			this.loseFocusTime = nil;
		end
	end

	this.hasLoseFocus = not focus;
end

--还原主摄像机
function Game.ResetMainCamera()
	local mainCamera = Util.GetMainCamera();
	if isNil(mainCamera) == false  then
		mainCamera.enabled = true;
	end
	UnityEngine.RenderSettings.fog = true;	
end

function Game.OnApplicationQuit()	
	Application.logMessageReceived = Application.logMessageReceived - SDKAnalytics.ErrorLog
	log("Game.OnApplicationQuit")
	this.OnGameRoleLogout();
end

function Game.OnLowMemory()
	print("[Warning] LowMemory")
end

function Game.OnActiveSceneChanged( _newSceneName )
	
end

--进入游戏场景
function Game.OnEnterGameLogic()
	
	UpdateBeat:Add(this.LogicTick, this);
	GlobalBehaviour.OnGamePlayerLogin();
	this.tick5Time = 0;

	logInfo("Game.OnEnterGameLogic")
end

--退出游戏场景，也就是回到了登录场景
function Game.OnExitGameLogic()
	
	UpdateBeat:Remove(this.LogicTick, this);
	
	GlobalBehaviour.OnGamePlayerLogout();
	this.OnGameRoleLogout();

	logInfo("Game.OnExitGameLogic")
end

--游戏心跳，调用频率需要控制>=1s
function Game.LogicTick()
	if Time.time - this.tick5Time > 5 then
		this.Tick5s();
		this.tick5Time = Time.time;
	end
end

--5秒心跳
function Game.Tick5s()
	
	--检测跨天
	this.CheckDayChanged();	

end

--检测服务器跨天
function Game.CheckDayChanged()
	local now = GetCurrentServerShowTime("*t"); 
	if this.yday == nil then
		this.yday = now.yday;
	elseif this.yday ~= now.yday then		
		LuaTimer:Add(this.OnDayChanged, 3, 0, true)
		--this.OnDayChanged();
		this.yday = now.yday;
	end	
	
end

--跨天事件
function Game.OnDayChanged()
	--全局逻辑检查
	GlobalBehaviour.CheckReFreshTime(GetServerTime());
	
	logInfo("Game.OnDayChanged")
end

--获取当前服务器版本号
function Game.GetServerVersion()
	if GIsEdit then
		return "1.1.13"
	else
		local buildInfo = require 'Common/buildgen'
		if buildInfo ~= nil then
			return buildInfo.ServerVersion or "";
		else
			return "";
		end
	end
end

--获取当前应用版本号
function Game.GetAppVersion()
	return GameManagerMgr.GetAppVersion();
end

--获取当前资源版本号
function Game.GetResVersion()
	local ver = GameManagerMgr.GetResVersion();
	local arr = stringsplit( ver, "." );
	if #arr < 4 then
		for i = #arr, 4 do
			ver = ver .. ".0"
		end
	end
	return ver;
end


--获取当前Build版本号
function Game.GetBuildVersion()
	return GameManagerMgr.GetBuildVersion();
end

--获取渲染API类型
function Game.GetGraphicsDeviceTypeShort()
	return GameManagerMgr.GetGraphicsDeviceTypeShort();
end

--UI发生错误时处理
function Game.OnUIExcpetion( _uiname, _funcName, _exception )
	
end

--游戏画质改变回调
function Game.OnQualityChanged(_qualityNum)
	
end

--创角事件，主要给统计用
function Game.OnGameRoleCreateEvent()

end

--角色登录游戏事件， 主要给统计用
function Game.OnWMGameLoginEvent()

end

--账号首次登录游戏事件，主要给统计用
function Game.OnFirstGameLoginEvent()

end

--账号登录游戏事件， 主要给统计用
function Game.OnGameLoginEvent()

end

--角色升级事件，主要给统计用
function Game.OnGameRoleUpdateEvent()

end

--角色退出事件，主要给打点用
function Game.OnGameRoleLogout()

end

function Game.OnGameTrackEvent( eventName )

end

function Game.OnGameTrackCustomEvent( eventName, paramData )

end

--获取当前userid
function Game.GetUID()
	return PlayerPrefs.GetString("defaultuserid", "unknown");
end
