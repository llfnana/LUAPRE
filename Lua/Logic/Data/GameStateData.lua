  

  --记录一些游戏全局状态数据

GameStateData = GameStateData or {}


GameStateData.NewPlayerPlotMode = false;    --游戏是否在新手剧情引导模式下


GameStateData.isNewRole = false;  			--是否是新创建的角色
GameStateData.isFirstEnterHomeScene = true; --是否是游戏启动后第一次进入主城
GameStateData.isFirstEnterLoginScene = true;  --是否是游戏启动后第一次进入登录场景


GameStateData.isGameLogicRunning = false;   --是否在正常游戏中(进入游戏场景后为true, 在登陆场景为false)




--加载场景状态定义
LoadingSceneState_Loading = 0				--场景加载中
LoadingSceneState_Loaded = 1				--场景加载完成
LoadingSceneState_LoadedAndPrepared = 2  	--场景加载完成并且场景类的 PrepareBeforeSceneLoaded 调用后
LoadingSceneState_LoadedAndInited = 3    	--场景加载完成并且场景类的 OnSceneLoaded 调用后，走到这一步表示场景正常加载完成，没有脚本报错导致的中断

GameStateData.loadingSceneState = 3;  		--场景加载状态变量




GameStateData.IsChineseSimplified  = true;  --当前是否使用中文简体语言



--所有当前登录的账号数据(uid, token, ip等等)整理存放到这里， todo
CurrentClientLoginInfo = {
	uid = "",
	token = "",
	ip = "",
}

