UILoadingPanel = {};
local this = UILoadingPanel;

this.UpdateInterval = 0.03;

--启动事件--
function UILoadingPanel.Awake(obj, behaviour)
	this.gameobject = obj;
	this.transform = obj.transform;
	this.behaviour = behaviour;
	this.InitPanel();
end

--初始化面板--
function UILoadingPanel.InitPanel()
	this.uidata = {};
	this.uidata.bgParent = this.transform:Find("BG").transform;
	this.uidata.progressLoading = this.transform:Find("Slider"):GetComponent("Slider")	
	this.uidata.progressImageFill = this.transform:Find("Slider/Bar"):GetComponent("Image")	
	this.uidata.effectBar = this.transform:Find("Slider/EffectBar"):GetComponent("SkeletonGraphic")	
	this.uidata.labelTips = this.transform:Find("LableTips"):GetComponent("Text");
	this.uidata.labelTips.text = "";
	--this.uidata.progressLoading.value = 0.2; --从0.2开始
	--this.uidata.progressImageFill.fillAmount = 0.2;

	--this.behaviour:SetUpdateInterval(0.01); --设置更新频率

	--设置它为最上层结点
	this.transform:SetAsLastSibling();  

	Event.AddListener( EventDefine.OnSceneLoadingProgress, this.OnSceneLoadingProgress )
	Event.AddListener( EventDefine.OnSceneLoadingComplete, this.OnSceneLoadingComplete )
	
	this.uidata.bgRes = {"UILoadingBg1", "UILoadingBg2", "UILoadingBg3"};
end

--刷新界面--
function UILoadingPanel.OnShow(sceneParam)
	this.sceneParam = sceneParam
	this.uidata.trueProgress = 0.2
	this.uidata.showProgress = 0.2;	

	this.uidata.progressLoading.value = this.uidata.showProgress;
	this.uidata.progressImageFill.fillAmount = this.uidata.showProgress;
	this.uidata.effectBar.transform.pivot = Vector2(this.uidata.showProgress, 0.5)
	this.uidata.effectBar:Initialize(true)
	this.uidata.effectBar.AnimationState:SetAnimation(0, "animation", true)

	this.isHide = false
	--设置超时时间
	this.behaviour:RemoveTimerEvent("AutoHide");
	this.behaviour:AddTimerEvent("UpdateLoadingProgress", this.UpdateInterval, this.Update, true);
	this.behaviour:AddTimerEvent("LoadingTimeOut", 5, this.OnWaitTimeOut, false );

	--random tips
	-- this.uidata.tipsList = {}
	-- TableManager:Inst():LoopTable( EnumTableID.TabLoadingTips, function(_row)
	-- 		if _row.StrID ~= nil and _row.IsLoadingTips ~= nil and _row.IsLoadingTips == 1 then
	-- 			local str = GetStaticStr( _row.StrID );
	-- 			if str ~= nil and str ~= "" then
	-- 				table.insert( this.uidata.tipsList, str );
	-- 			end
	-- 		end
	-- 	end)	
	
	-- local maxLine = #this.uidata.tipsList;
	-- local tabId  = math.random( 1, maxLine );
	-- local text = this.uidata.tipsList[tabId]
	-- if text ~= nil then
	-- 	this.uidata.labelTips.text = text;
	-- end
	StartCoroutine(function()
		Yield(nil)
		if this.sceneParam and this.sceneParam.callback then 
			this.sceneParam.callback()
		end
	end)
end

--关闭界面
function UILoadingPanel.OnHide()
	this.uidata.tipsList = nil;
	this.behaviour:RemoveTimerEvent("LoadingTimeOut");
	this.behaviour:RemoveTimerEvent("UpdateLoadingProgress");
	this.behaviour:RemoveTimerEvent("CheckSceneLoadedState");
	this.behaviour:RemoveTimerEvent("AutoHide");

	if this.uidata.bg ~= nil then
		GameObject.Destroy( this.uidata.bg );
		this.uidata.bg = nil;
	end
end

--
function UILoadingPanel.OnSceneLoadingProgress( _progress )
	if _progress < 0.5 then
	 	_progress = 0.5
	end
	if _progress > this.uidata.trueProgress then
		this.uidata.trueProgress = _progress;
	end
end

function UILoadingPanel.OnSceneLoadingComplete()
	this.uidata.trueProgress = 1.1;
end


function UILoadingPanel.OnWaitTimeOut()
	this.uidata.waitTime = 0;
	this.uidata.loadingStateCache = LoadingSceneState_Loading;
	this.behaviour:AddTimerEvent("CheckSceneLoadedState", 1, this.CheckSceneLoadedState, true);
end


function UILoadingPanel.CheckSceneLoadedState()

	--error("UILoadingPanel.CheckSceneLoadedState.."..Time.time)
	
	local curState = GameStateData.loadingSceneState;
	if curState == this.uidata.loadingStateCache then
		this.uidata.waitTime = this.uidata.waitTime + 1;
	else
		this.uidata.waitTime = 0;
		this.uidata.loadingStateCache = curState;
	end


	--根据状态进行超时处理
	if curState == LoadingSceneState_Loading then
		if this.uidata.waitTime > 30 then
			this.ErrorFinalResolution();
		end
	elseif curState == LoadingSceneState_Loaded then
		if this.uidata.waitTime > 10 then
			this.ErrorFinalResolution();
		end
	elseif curState == LoadingSceneState_LoadedAndPrepared then
		if this.uidata.waitTime > 10 then
			this.ErrorFinalResolution();
		end		
	elseif curState == LoadingSceneState_LoadedAndInited then
		this.uidata.trueProgress = 1.1;	
		this.behaviour:AddTimerEvent("AutoHide", 1, function() HideUI( UINames.UILoading ) end, false );
	end

end


--出错最终处理
function UILoadingPanel.ErrorFinalResolution()
	
	this.behaviour:RemoveTimerEvent("CheckSceneLoadedState");
	local curScene = SceneManager:Inst():GetCurrentSceneName();
	error("UILoadingPanel.ErrorFinalResolution: curScene="..curScene.." state="..this.uidata.loadingStateCache.." waitTime="..this.uidata.waitTime)


	--尝试恢复场景因为脚本出错导致未调用链中断
	local scene = SceneManager:Inst():GetCurrentScene();
	local state = GameStateData.loadingSceneState;

	if state == LoadingSceneState_Loading then

	elseif state == LoadingSceneState_Loaded then

		scene:PrepareBeforeSceneLoaded();
		Util.ClearMemory();
		scene:OnSceneLoaded();
		GameStateData.loadingSceneState = LoadingSceneState_LoadedAndInited;	

	elseif state == LoadingSceneState_LoadedAndPrepared then

		scene:OnSceneLoaded();
		GameStateData.loadingSceneState = LoadingSceneState_LoadedAndInited;

	end
end

--销毁界面--
function UILoadingPanel.OnDestroy()
	this.uidata = nil;
	this.gameobject = nil;
	this.transform = nil;
	this.behaviour = nil;
	Event.RemoveListener( EventDefine.OnSceneLoadingProgress, this.OnSceneLoadingProgress )
	Event.RemoveListener( EventDefine.OnSceneLoadingComplete, this.OnSceneLoadingComplete )	
	
end

------------------------------------------------------------------
function UILoadingPanel.Update() 
	if this.isHide then 
		HideUI(UINames.UILoading)
		return
	end
	if this.uidata.showProgress < this.uidata.trueProgress then
		local offset = (this.uidata.trueProgress - this.uidata.showProgress)*0.1;
		if offset < this.UpdateInterval then
			offset = this.UpdateInterval
		end
		this.uidata.showProgress = this.uidata.showProgress + offset;
	end
	this.uidata.progressLoading.value = this.uidata.showProgress;
	this.uidata.progressImageFill.fillAmount = this.uidata.showProgress;
	this.uidata.effectBar.transform.pivot = Vector2(this.uidata.showProgress, 0.5)
	if this.uidata.showProgress >= 1 then
		this.isHide = true
		Event.Brocast(EventDefine.HideLoadingUI, this.sceneParam.sceneName)
		HideUI(UINames.UILoading)
	end
end