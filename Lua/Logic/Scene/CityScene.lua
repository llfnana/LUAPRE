---@class CityScene : SceneBase 主城场景
CityScene = class(SceneNames.CityScene, SceneBase);

function CityScene:ctor(cityId)
	self.cityId = cityId
	self.sceneName = SceneManager:Inst():GetCitySceneName(cityId)
	self.__cname = self.sceneName
end

function CityScene:Instance()
	return self;
end

-- 状态进入
function CityScene:PreEnter( _lastSceneName, _afterCall )
	self.super:PreEnter(_lastSceneName, _afterCall)
	Audio.Stop();
	self.lastSceneName = _lastSceneName;

	-- if GameStateData.isFirstEnterCityScene then
	-- 	ResInterface.PreLoadShader("preload.shadervariants");
	-- end

	self:LoadScene()
end

--预加载资源
function CityScene:PrepareBeforeSceneLoaded()
	if GameStateData.isFirstEnterCityScene then
		 PreloadAsset.PreloadOnEnterMain();
	end
end

function CityScene:OnSceneLoaded()
 	self.super:OnSceneLoaded(self.sceneName)

	if not GameStateData.isGameLogicRunning then
		Game.OnEnterGameLogic();
		GameStateData.isGameLogicRunning = true;
	end
end

-- 销毁--
function CityScene:Unload( _nextSceneName )
	HideUI(UINames.UIMain)
	CityModule.exitScene() --退出场景
	self:ReleaseRes()
end
