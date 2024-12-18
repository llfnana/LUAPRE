
--登录场景--
LoginScene = class(SceneNames.LoginScene,SceneBase)

function LoginScene:ctor()
	self.sceneName = SceneNames.LoginScene
end

--准备进入
function LoginScene:PreEnter( _lastSceneName,_afterCall, _isAutoLogin )
	self.super:PreEnter(_lastSceneName,_afterCall)
	self.isAutoLogin = _isAutoLogin;


	Audio.Stop();

	--加载场景资源
	self:LoadScene();
end


-------------------------------------------------------------------------------------
--预加载资源
function LoginScene:PrepareBeforeSceneLoaded()

end


--场景加载完成
function LoginScene:OnSceneLoaded()	
	--error("LoginScene:OnSceneLoaded")

	ShowUISync(UINames.UILoginNew, self.isAutoLogin)	
	-- ShowUI(UINames.UIWaitMsg)

	--清理可能的引导
	--GuideBhvGroup.CancelBhv();
	
	self.super:OnSceneLoaded(self.sceneName)
	Audio.PlayAudio( DefaultAudioID.LoginScene )

	if GameStateData.isGameLogicRunning then
		Game.OnExitGameLogic();
		GameStateData.isGameLogicRunning = false;
	end	

	PreloadAsset.PreloadOnLoginSceneIdle()

     ---暂时把末日生存的登陆初始化放在这里  zhangzhihong 20230705
     GameManager.LoadMode(ModeType.Loading)
end

--销毁--
function LoginScene:Unload( _nextSceneName )
	if GameStateData.isFirstEnterLoginScene then
	
	end
	
	GameStateData.isFirstEnterLoginScene = false;

	if _nextSceneName ~= SceneNames.NewPlotScene then
		HideUI(UINames.UILoginNew)	
	end
	self:ReleaseRes()
	log(">>> Unload LoginScene");
end


