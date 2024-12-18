-- 场景名称定义, 注：这里的场景是一种逻辑划分，并非都是实际的unity场景, 比如对于战斗场景来说，会从N个不同的实际美术制作战斗场中加载一个。
SceneNames = 
{
	LoginScene = "LoginScene",
	CityScene = "city",
}

require "Logic/Scene/SceneBase"
require "Logic/Scene/LoginScene"
require "Logic/Scene/CityScene"

---@class SceneManager 场景管理器
SceneManager = {}

function SceneManager:New(o)
	local o = o or {}
	setmetatable(o, self);
	self.__index = self;
	return o;
end

---@return SceneManager
function SceneManager:Inst()
	if nil == self.instance then
		self.instance = SceneManager:New()
	end
	return self.instance;
end

function SceneManager:Init()
	self.scenes = {} ---@type table<string, SceneBase>
	self.scenes[ SceneNames.LoginScene ] = LoginScene.New();

	local cityCount = 10 -- TODO

	for i = 1, cityCount, 1 do
		local cityScene = CityScene.New(i)
		self.scenes[ cityScene.sceneName ] = cityScene
	end
	
	self.curScene = nil ---@type SceneBase 当前场景
	self.currentLoadedScene = "main";
	self.isLoading = false;
	self.sceneflag = 1; --临时用于当前场景，某一个按钮的切换状态
end

function SceneManager:GetCitySceneName(cityId)
	return SceneNames.CityScene .. cityId
end

function SceneManager:GetScene( _logicSceneName )
	return self.scenes[_logicSceneName]
end

function SceneManager:IsScene(_logicSceneName)
	return self.currentLoadedScene == _logicSceneName
end

function SceneManager:ChangeScene( _logicSceneName, _afterCall, sceneParam )
	if self.currentLoadedScene ~= nil and self.currentLoadedScene == _logicSceneName and sceneParam~="city" then
		warn("SceneManager:ChangeScene same!!! _logicSceneName=".._logicSceneName)
		return 0;
	end

	-- 先打开loading再做切场景，否则会闪画面
	ShowUISync(UINames.UILoading, {sceneName = _logicSceneName, callback = function()
		self.currentLoadedScene = _logicSceneName;
		UIUtil.CloseAllPanelOutBy(UINames.UILoading)

		TutorialHelper.AttachRoot()
		
		if self.curScene ~= nil then
			--清理一次事件缓存防止被卡了切场景出错
			Event.ReleaseCacheEvent();
		end

		self.lastSceneName = nil;
		if self.curScene ~= nil then
			self.lastSceneName = self.curScene.sceneName
			self.curScene:Unload( _logicSceneName );
			self.curScene = nil
			--退出场景清理
			--VirtualColliderMgr:Clear()
			--清理动画
			AnimationManager:Clear()
			--清理场景特效
			ParticleMgr:ClearSceneEffect();
		end
		
		self.curScene = self.scenes[_logicSceneName]
		if self.curScene == nil then
			error("ChangeScene error:".._logicSceneName);
			return 0;
		end

		self.curScene:PreEnter( self.lastSceneName, _afterCall, sceneParam );
		return 1;
	end})
end

function SceneManager:BackToLastScene(_afterCall, sceneParam)
	if self.lastSceneName == SceneNames.DungeonScene then
		--DungeonMgr:Inst():EnterDungeon()
	elseif self.lastSceneName == SceneNames.StageScene then
		StageModule.c2sEnterStage()
	else
		self:ChangeScene(self.lastSceneName, _afterCall, sceneParam)
	end
end


function SceneManager:GetCurrentScene()
	return self.curScene;
end

function SceneManager:GetCurrentSceneName()
	if self.curScene ~= nil then
		return self.curScene.sceneName
	else
		return ""
	end
end

function SceneManager:GetLastSceneName()
	return self.lastSceneName;
end


--返回当前加载完成的场景名称，加载中返回nil
function SceneManager:GetCurrentLoadedSceneName()
	return self.currentLoadedScene;
end

function SceneManager:SetCurrentLoadedScene( _name )
	self.currentLoadedScene = _name or "unknown"
end

function SceneManager:GetBigScene()
	if( self.curScene == self.scenes[ SceneNames_BigMap ]) then
		return self.curScene;
	end
	
	return nil;
end

function SceneManager:OnResume()
	if self.curScene ~= nil then
		self.curScene:OnResume();
	end
end


function SceneManager:SetCurrentLoadSceneRes( _unitySceneName )
	self.currentLoadSceneRes = _unitySceneName;
end

function SceneManager:GetCurrentLoadSceneRes()
	return self.currentLoadSceneRes or "none";
end

function SceneManager:IsLoadingOrLoaded( _unitySceneName )
	if self.currentLoadSceneRes ~= nil and self.currentLoadSceneRes == _unitySceneName then
		return true;
	else
		return false;
	end
end


return SceneManager
