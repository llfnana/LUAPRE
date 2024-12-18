---@class SceneBase
SceneBase = class("SceneBase")

function SceneBase:ctor(sname)
    self.sceneName = sname;
    self.resId = -1;
    self.afterCall = nil;
    self.loadTryTimes = 0;
end

function SceneBase:GetSceneName()
    return self.sceneName
end

---@param loadMode number 加载模式：0-单个 1-附加
function SceneBase:LoadScene(_unitySceneName, loadMode)
    if _unitySceneName == nil then
        _unitySceneName = self.sceneName
    end

    if GameStateData.loadingSceneState == LoadingSceneState_Loading then
        --保证只允许同时加载1个场景
        if GIsEdit or GIsDevelopment then
            local curLoadedSceneName = SceneManager:Inst():GetCurrentLoadSceneRes();
            print("[Error] 只允许同时加载一个场景，当前加载场景=" .. curLoadedSceneName .. ", 要调用的场景=" .. _unitySceneName)
        end
        return;
    end

    --防止重复加载同一场景
    if SceneManager:Inst():IsLoadingOrLoaded(_unitySceneName) and _unitySceneName ~= "city" then
        print("[Warn] SceneBase:LoadScene is loading2, so return!.." .. _unitySceneName)
        return;
    end

    local loadedCallback = function()
        self.loadTryTimes = 0;
        GameStateData.loadingSceneState = LoadingSceneState_Loaded;
        self:PrepareBeforeSceneLoaded();
        GameStateData.loadingSceneState = LoadingSceneState_LoadedAndPrepared;
        self:OnSceneLoaded();
        GameStateData.loadingSceneState = LoadingSceneState_LoadedAndInited;
    end

    local loadingCallback = function(_progress)
        self:OnSceneLoadingProgress(_progress)
    end

    local loadErrorCallback = function()
        self.loadTryTimes = self.loadTryTimes + 1;
        print("[Error][SceneBase:LoadScene] load " .. _unitySceneName .. " error! try again:" .. self.loadTryTimes);
        if self.loadTryTimes <= 3 then
            if self.resId ~= nil and self.resId > 0 then
                ResInterface.ReleaseRes( self.resId )
                self.resId = -1
            end
            LuaTimer:Add(function()
                self.resId = ResInterface.LoadSceneSwitch(_unitySceneName, loadedCallback, loadingCallback, loadErrorCallback);
            end, 3, 0, true)
        else
            --重试多次失败,todo
        end
    end

    print("[Scene] LoadScene : " .. _unitySceneName)
    SceneManager:Inst():SetCurrentLoadSceneRes(_unitySceneName);
    GameStateData.loadingSceneState = LoadingSceneState_Loading;

    self.loadTryTimes = 0
    self.resId = ResInterface.LoadSceneSwitch(_unitySceneName, loadedCallback, loadingCallback, loadErrorCallback, loadMode);
    if self.resId == nil then
        print("[Error][SceneBase:LoadScene] ResInterface.LoadSceneSwitch  return nil! _unitySceneName=" .. _unitySceneName);
    end
end

--可以在这个函数里执行进入场景前的预加载工作，因为这时候还是有Loading界面挡着的
function SceneBase:PrepareBeforeSceneLoaded()
    print("[Scene] SceneBase:PrepareBeforeSceneOpen")
end

function SceneBase:OnSceneLoaded(_logicSceneName)
    if _logicSceneName ~= nil then
        print("[Scene] SceneBase:OnSceneLoaded.." .. _logicSceneName)
    elseif self.sceneName ~= nil then
        print("[Scene] SceneBase:OnSceneLoaded.." .. self.sceneName)
    else
        print("[Scene] SceneBase:OnSceneLoaded..unknown")
    end

    SceneManager:Inst():SetCurrentLoadedScene(_logicSceneName or "unknown");

    if self.afterCall ~= nil then
        self.afterCall();
    end
   
    Event.Brocast(EventDefine.OnSceneLoadingComplete);
end

function SceneBase:OnBigMapSystemWorkDone()
    Event.Brocast(EventDefine.OnSceneLoadingComplete);
end

function SceneBase:OnSceneLoadingProgress(_progress)
    Event.Brocast(EventDefine.OnSceneLoadingProgress, _progress);
end

--准备进入
function SceneBase:PreEnter(_lastSceneName, _afterCall)
    self.afterCall = _afterCall
end

--卸载
function SceneBase:Unload(_nextSceneName)

end

--释放场景资源，在每个场景的Unload里调用
function SceneBase:ReleaseRes()
    if self.resId ~= nil and self.resId > 0 then
        ResInterface.ReleaseRes( self.resId )
        self.resId = -1
    end
end

function SceneBase:OnResume()

end
