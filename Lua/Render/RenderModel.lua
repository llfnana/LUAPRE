
require("Render/RenderObject")


RenderModel = class("RenderModel", RenderObject)


function RenderModel:ctor()
	RenderObject.ctor( self )
	self.anims = nil;
	self.animName = nil;
	self.lookAtPos = nil;
	self.effects = nil;
	self.bindPosCache = {}
	--self.shadow = nil;
end

function RenderModel:Destroy()
	
	if self.effects ~= nil then
		for _, v in pairs(self.effects) do
			v:Destroy();
		end
		self.effects = nil;
	end
	
	--if self.shadow ~= nil then
	--	ShareResPool:ReleaseShadow( self.shadow );
	--	self.shadow = nil;
	--end

	RenderObject.Destroy(self);
	self.anims = nil;
	self.animName = nil;
	self.modelHeight = nil;
	--self.highlighter = nil;

	if self.matResId ~= nil then
		ResInterface.ReleaseRes( self.matResId )
		self.matResId = nil;
	end	
	self.bindPosCache = nil
	
	if self.instanceId then
		AnimationManager:RemoveObjectById(self.instanceId)
		self.instanceId = nil
	end
end


function RenderModel:Create()

	if( self.initParams == nil ) then
		error( "Create:self.initParams is nil!" )
		return;
	end
	if( self.state ~= RenderObjectState_None ) then
		error("Create: self.stat is not none!")
		return;
	end
	
	local modelResName = GetModelResName(self.initParams.ModelId) --TableManager:Inst():GetTableDataByKey( EnumTableID.TabModelID, self.initParams.ModelId, "ResName" );
	if( modelResName == nil ) then
		error("cant't find model name: modeid="..self.initParams.ModelId)
		return false
	end

	--需要使用蓝色模型
	if self.initParams.colorType == HexagonRender_Blue then
		modelResName = string.gsub( modelResName, "_red", "_blue" );
	elseif self.initParams.colorType == HexagonRender_Green then		
		modelResName = string.gsub( modelResName, "_red", "_blue" );
	end
	
	self.name = modelResName.."_"..self.initParams.Id
	
	local f = function( _go )
		self:OnModelLoaded(_go)
	end

	self.state = RenderObjectState_Loading;
	
	if self.initParams.PoolName ~= nil then
		GoPoolMgr.CurrentPool():GetObject( self.initParams.PoolName, modelResName, f );
	else
		self.resId = ResInterface.CreateModel( modelResName, f, 0, self.initParams.IsAsyncLoad );
		--ResLoader:CreateModel( modelResName, f, "" );
	end	
	
	return true;
end


function RenderModel:OnModelLoaded( _go )
	
	if not self:CheckStateOnResourceLoaded( _go ) then
		return;
	end
	_go:SetActive( true );
	
	local instanceId = AnimationManager:AddObject(_go, 1)
	if instanceId ~= 0 then
		self.instanceId = instanceId
	end
	
	self.mainObject =  _go;
	self.mainTransform = self.mainObject.transform;
	if self.name ~= nil then
		_go.name = self.name;
	end
	RenderObject.Init( self );
	self.state = RenderObjectState_Loaded

	self:PlayAnimation(self.animName and self.animName or Anims.Idle)
	self.animName = nil;

	--self.shadow = ShareResPool:ShowShadow(self.mainObject, self.initParams.ModelId )

	if self.lookAtPos ~= nil then
		self:LookAt( self.lookAtPos );
		self.lookAtPos = nil;
	end
	if self.initParams.OnLoadFinshCallback ~= nil then
		self.initParams.OnLoadFinshCallback( _go )
	end
end


PlayAnimParams = class("PlayAnimParams")
function PlayAnimParams:ctor( isUpSet, isLoop, isCrossFade, isQueued, isPlayIdleAfter )
	self.isUpset = isUpSet						--是否随机播放起始时间
	self.isLoop = isLoop						--是否循环
	self.isCrossFade = isCrossFade				--是否动作过渡
	self.isQueued = isQueued           			--是否排队
	self.isPlayIdleAfter = isPlayIdleAfter		--是否在本动作结束后自动播放休闲动作
end


DefaultAnimParams = DefaultAnimParams or {}
DefaultAnimParams[Anims.Move] = PlayAnimParams.New(true,true,true,false,true)
DefaultAnimParams[Anims.Idle] = PlayAnimParams.New(true,true,true,false,false)
DefaultAnimParams[Anims.Dead] = PlayAnimParams.New(false,false,true,false,false)
DefaultAnimParams[Anims.Attack] = PlayAnimParams.New(false,false,true,false,true)
DefaultAnimParams[Anims.Hurt] =  PlayAnimParams.New(false,false,true,false,true)
DefaultAnimParams[Anims.Defend] = PlayAnimParams.New(false,false,true,false,true)


function RenderModel:PlayAnimation( _animName, _animParams, _speed, _arg1IsClipName )
	if _animName == nil then
		return;
	end

	local clipName = nil;
	if _arg1IsClipName then
		clipName = _animName;
	else
		clipName = GetRealAnimClipName( _animName, self.initParams.ModelId );
	end
	if clipName == nil then
		error("@youkai:PlayAnimation failed! not find clipname for ".._animName..";modelId="..self.initParams.ModelId)
		return;
	end
	
	if not self.instanceId or self.instanceId == 0 then
		-- error("PlayAnimation failed! self.instanceId  is nil!")
		self.tempState = {};
		self.tempState._animName = _animName;
		self.tempState._animParams = _animParams;
		self.tempState._speed = _speed;
	else
		if self.tempState ~= nil then
			local animParams = self.tempState._animParams
			if animParams == nil then
				animParams = DefaultAnimParams[self.tempState._animName]
			end
			
			if animParams == nil then
				AnimationManager:Play(self.instanceId, clipName, 1.0, false, false, false, '')
				return;
			end

			--error("play animation.."..self.instanceId..";".._animName..";"..clipName)

			local postName = ''
			if animParams.isPlayIdleAfter and self.tempState._animName ~= Anims.Idle then
				postName = GetRealAnimClipName(Anims.Idle, self.initParams.ModelId)
			end	
			
			if self.tempState._speed == nil then
				self.tempState._speed = 1.0;
			end

			AnimationManager:Play(self.instanceId, clipName, self.tempState._speed, animParams.isUpset, animParams.isLoop and true or false,
				animParams.isCrossFade, postName)
			self.tempState = nil;
		end
		
		local animParams = _animParams
		if animParams == nil then
			animParams = DefaultAnimParams[_animName]
		end
		
		if animParams == nil then
			AnimationManager:Play(self.instanceId, clipName, 1.0, false, false, false, '')
			return;
		end

		--error("play animation.."..self.instanceId..";".._animName..";"..clipName)

		local postName = ''
		if animParams.isPlayIdleAfter and _animName ~= Anims.Idle then
			postName = GetRealAnimClipName(Anims.Idle, self.initParams.ModelId)
		end	
		
		if _speed == nil then
			_speed = 1.0;
		end

		AnimationManager:Play(self.instanceId, clipName, _speed, animParams.isUpset, animParams.isLoop and true or false,
			animParams.isCrossFade, postName)
	end
	--[[if _animName == nil  then
		return;
	end

	if isNil(self.mainObject) then
		--not load ok
		self.animName = _animName
		return; 
	end
	if isNil( self.anims ) then
		self.anims = self.mainObject:GetComponentsInChildren( typeof(UnityEngine.Animation) ) --self.mainObject:GetComponent("Animation");
		if isNil(self.anims) then
			error("PlayAnimation failed! Animation is null!")
			return;
		end
	end

	local clipName = self:GetRealAnimClipName( _animName );
	if clipName == nil then
		error("PlayAnimation failed! not find clipname for ".._animName)
		return;
	end


	local animLen = self.anims.Length;
	for i = 0, animLen-1 do
		local anim = self.anims[i];

		if anim:GetClip(clipName) == nil then
			error("[RenderModel:PlayAnimation]"..self.name.." not found clip: "..clipName);
			return;
		end

		local animParams = _animParams

		if animParams == nil then
			animParams = DefaultAnimParams[_animName]
		end
		if animParams == nil then
			anim:Play(clipName)
			return;
		end

		local queueMode = QueueMode.PlayNow
		if animParams.isQueued then
			queueMode = QueueMode.CompleteOthers
		end

		local animState = nil;
		if animParams.isCrossFade then
			animState = anim:CrossFadeQueued(clipName, 0.3, queueMode)
		else
			animState = anim:PlayQueued(clipName, queueMode)
		end
		
		if animState  == nil then
			error("[RenderModel:PlayAnimation]animState is nil! clipname="..clipName)
			return
		end

		if animParams.isUpset then
			animState.time = animState.length * math.random();
		end		

		if animParams.isLoop then
			animState.wrapMode = UnityEngine.WrapMode.Loop;
		else
			animState.wrapMode = UnityEngine.WrapMode.Default;	
		end

		if animParams.isPlayIdleAfter and _animName ~= Anims.Idle then
			local idleClipName = self:GetRealAnimClipName( Anims.Idle );
			anim:CrossFadeQueued( idleClipName, 0.3, QueueMode.CompleteOthers );	
		end			

	end]]

	
end

-----------------------------------------
function RenderModel:LookAt( v3 )

	if not isNil(self.mainTransform) then
		self.mainTransform:LookAt( v3 );
	else
		self.lookAtPos = v3;
	end
end


-----------------------------------------
function RenderModel:GetBindPos( _bindPos, _space )

	local nodeTransform = nil;
	if _bindPos == ModelBindPosType_Feet then
		nodeTransform = self:GetBindPosTransform("bind_feet");
	elseif _bindPos == ModelBindPosType_Head or _bindPos == ModelBindPosType_HeadUp then
		nodeTransform = self:GetBindPosTransform("bind_head");
	elseif _bindPos == ModelBindPosType_Center then		--这里center实际代表受击点
		nodeTransform = self:GetBindPosTransform("bind_hit");
	elseif _bindPos == ModelBindPosType_LeftHand then
		nodeTransform = self:GetBindPosTransform("bind_lefthand");
	elseif _bindPos == ModelBindPosType_RightHand then
		nodeTransform = self:GetBindPosTransform("bind_righthand");
	else
		error("[RenderModel:GetBindPos]Unsupport BindPos=".._bindPos);
	end

	if isNil(nodeTransform) then
		error("RenderModel:GetBindPos failed! BindPos=".._bindPos)
		if _space == nil or  _space == Space_World then
			return self:GetWorldPosition();
		else
			return Vector3.zero;
		end
	else
		if _space == nil or  _space == Space_World then
			return nodeTransform.position;
		else
			return nodeTransform.localPosition;
		end		
	end




	-- local h = self:GetHeight();
	-- local feetPos = Vector3.New( 0, 0.1, 0);
	-- if _space == nil or _space == Space_World then
	-- 	feetPos = self:GetWorldPosition();
	-- end
	-- if _bindPos == ModelBindPosType_Center then
	-- 	return feetPos + Vector3.New( 0, h*0.7, 0);
	-- elseif _bindPos == ModelBindPosType_Feet then
	-- 	return feetPos;
	-- elseif _bindPos == ModelBindPosType_Head then
	-- 	return feetPos + Vector3.New( 0, h, 0);
	-- elseif _bindPos == ModelBindPosType_HeadUp then
	-- 	return feetPos + Vector3.New( 0, h, 0);
	-- elseif _bindPos == ModelBindPosType_LeftHand then
	-- 	return feetPos + Vector3.New( 0, h*0.7, 0);
	-- elseif _bindPos == ModelBindPosType_RightHand then
	-- 	return feetPos + Vector3.New( 0, h*0.7, 0);
	-- else
	-- 	error("[RenderModel:GetBindPos]return nil! _bindPos=".._bindPos);
	-- end
end

-----------------------------------------
function RenderModel:GetBindGameObject( _bindName )
	if isNil( self.mainTransform ) then
		error("[RenderModel:GetBindGameObject] self.mainTransform is nil, _bindName=".._bindName);
		return nil;
	end
	if self.bindPosCache[_bindName] == nil then
		self.bindPosCache[_bindName] = Util.FindInAllChild( self.mainTransform, _bindName );
	end

	if  self.bindPosCache[ _bindName ] ~= nil then
		return self.bindPosCache[ _bindName ].gameObject;
	end
	return nil;
end

-----------------------------------------
function RenderModel:GetBindPosTransform( _bindName )
	if isNil( self.mainTransform ) then
		error("[RenderModel:GetBindPosTransform] self.mainTransform is nil, _bindName=".._bindName);
		return nil;
	end
	if self.bindPosCache[_bindName] == nil then
		self.bindPosCache[_bindName] = Util.FindInAllChild( self.mainTransform, _bindName );
	end
	return self.bindPosCache[_bindName];
end


-----------------------------------------
function RenderModel:GetHeight()

	if isNil(self.mainObject) then
		warn("[RenderModel:GetHeight] but mainObject is nil!") 
		return 2;
	end

	if self.modelHeight == nil then
		self.modelHeight = Util.GetModelHeight( self.mainObject );
	end
	return self.modelHeight;
end


-----------------------------------------
function RenderModel:AddEffect( _effectInfo, _bindPos, _loadedcallback, _localPosition, _loop, _autoDestroy)

	_autoDestroy = false; --由于都使用了特效管理器，老的删除特效的方式不再使用

	local _effectName = _effectInfo.ResName;
	if self.effects == nil then
		self.effects = {};
	else
		if self.effects[_effectName] ~= nil then
			--check if alread exist
			if self.effects[_effectName]:IsValidAndVisible() then
				return;
			end
		end
	end
	if isNil(self.mainObject) then
		--todo
		return;
	end
	--create effect
	if _loop == nil then
		_loop = true;
	end
	if _autoDestroy == nil then
		_autoDestroy = true;
	end
	local createParams = RenderEffectCreateParams.New();
	createParams.EffectName = _effectName;
	createParams.OnLoadFinshCallback = _loadedcallback;
	createParams.autoDestroy = _autoDestroy;
	if type(_bindPos) == "string" then
		createParams.Parent = self:GetBindGameObject( _bindPos );
		createParams.LocalPos = _localPosition or Vector3.zero;
	else
		createParams.Parent = self.mainObject;
		createParams.LocalPos = self:GetBindPos( _bindPos, Space_Local ) + (_localPosition or Vector3.zero);
	end
	createParams.audioId = _effectInfo["Audio"] or -1;
	createParams.audioTime = _effectInfo["AudioTime"] or 0;
	
	local effect = RenderSystem.GetInstance():CreateRenderObject( createParams );
	--if effect:Create() and _loop == false and _autoDestroy == false then
	if effect:Create() then
		self.effects[_effectName] = effect;
	end
end



-----------------------------------------
function RenderModel:RemoveEffect( _effectName )
	if self.effects == nil then
		return;
	end
	if self.effects[_effectName] == nil then
		return;
	end
	self.effects[_effectName]:Destroy();
	self.effects[_effectName] = nil;
end


-----------------------------------------设置模型边缘发光
function RenderModel:HighLightOn( _color )
	-- if isNil( self.highlighter ) then
	-- 	self.highlighter = self:AddComponent( Highlighter, true )
	-- 	if( isNil(self.highlighter) ) then
	-- 		return;
	-- 	end		
	-- end
	-- self.highlighter:ConstantOn( _color );
end


-----------------------------------------关闭模型边缘发光
function RenderModel:HighLightOff()
	-- if not isNil( self.highlighter ) then
	-- 	self.highlighter:ConstantOff();
	-- end
end











