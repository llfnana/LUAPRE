
require("Render/RenderObject")

RenderEffect = class("RenderEffect", RenderObject)

function RenderEffect:ctor()
	RenderObject.ctor( self )
	self.ps = nil;
end

function RenderEffect:Create()
	
	if( self.initParams == nil ) then
		error( "Create:self.initParams is nil!" )
		return;
	end
	if( self.state ~= RenderObjectState_None ) then
		error("Create: self.stat is not none!")
		return;
	end

	if self.initParams.EffectName == nil then
		-- print("[error]" .. PrintTable(self.initParams));
		error("[RenderEffect:Create]EffectName is nil!")
		return false;
	end

	self.autoDestroy = self.initParams.autoDestroy;
	self.state = RenderObjectState_Loading;

	local f = function( _go, _particleId )
		self:OnResourceLoaded(_go, _particleId)
	end
	if self.initParams.PoolName ~= nil then
	    GoPoolMgr.CurrentPool():GetObject( self.initParams.PoolName, self.initParams.EffectName, f );
	else
		if self.initParams.UseParticleMgr then

			local parent = nil;
			if self.initParams.Parent ~= nil then
				parent = self.initParams.Parent.transform
			end

			local pos = Vector3.zero;
			local scale = Vector3.one;
			if parent == nil then
				if self.initParams.WorldPos ~= nil then
					pos = self.initParams.WorldPos
				end
			else
				if self.initParams.LocalPos ~= nil then
					pos = self.initParams.LocalPos;
				end
			end
			if self.initParams.Scale ~= nil then
				scale = Vector3.New(self.initParams.Scale, self.initParams.Scale, self.initParams.Scale)
			end
			local effectRes = self.initParams.EffectName..".prefab";			
			local useWorldRotation = (self.initParams.WorldRotation ~= nil)
			local worldRotation = self.initParams.WorldRotation or Quaternion.identity;
			self.particleObjId = ParticleMgr:PlayEffect(effectRes, parent, pos, scale, f, 
						useWorldRotation, worldRotation);	

		else

			self.resId = ResInterface.CreateEffect( self.initParams.EffectName, f )
		end
	end
	
	return true;
end

function RenderEffect:OnResourceLoaded( _go, _particleId )

	--error("RenderEffect:OnResourceLoaded..".._particleId..";time="..Time.time)

	if self.state == RenderObjectState_Destroyed then
		self:Destroy();
		return;
	end	

	-- if not self:CheckStateOnResourceLoaded( _go ) then
	-- 	return;
	-- end	
	--check params
	if self.initParams == nil then
		error("RenderEffect:OnResourceLoaded init params is nil!")
		return;
	end	


	if self.initParams.UseParticleMgr then

		self.mainObject = _go;
		self.mainTransform = self.mainObject.transform;

	else

		self.mainObject = _go;
		self.mainTransform = self.mainObject.transform;
		RenderObject.Init( self );
		self.mainObject:SetActive( true );
		self.state = RenderObjectState_Loaded			

		if self.autoDestroy then
			self:SetAutoDestroy();
			self.autoDestroy = nil;
		end
	end

	if self.initParams ~= nil then
		local audioId = self.initParams.audioId or -1;
		local audioTime = self.initParams.audioTime or 0;
		if audioId ~= nil then
			if audioId ~= -1 then
				local func = function ( audioId )
					Audio.PlayAudio( audioId );
				end
				LuaTimer:Add(func, audioTime, audioId, true )
			end
		end
	end

	if self.initParams.OnLoadFinshCallback ~= nil then
		self.initParams.OnLoadFinshCallback( _go )
	end	



end

function RenderEffect:Destroy()
	
	if self.initParams == nil then
		return;
	end


	if self.initParams.UseParticleMgr then
		if self.particleObjId ~= nil then
			ParticleMgr:StopEffect(self.particleObjId)
			self.particleObjId = nil;
			self.initParams = nil;
			self.mainObject = nil;
			self.mainTransform = nil;
			self.state = RenderObjectState_Destroyed;
		end		
	else
		RenderObject.Destroy(self)
		self.ps = nil;		
	end

end



function RenderEffect:SetAutoDestroy()
	local delayTime = 3;
	if self.state == RenderObjectState_Loaded then
		if self.ps == nil then
			self.ps = self.mainObject:GetComponent(typeof(ParticleSystem));
			if self.ps ~= nil then
				local duration = self.ps.main.duration;
				--local startlifetime = self.ps.main.startLifetime
				delayTime = duration;
			end
		end
		local func = function() self:Destroy() end
		LuaTimer:Add(func, delayTime, 0, true )
	else
		self.autoDestroy = true;
	end
end


function RenderEffect:LookAt( v3 )
	if not isNil(self.mainTransform) then
		self.mainTransform:LookAt( v3 )
	end
end


function RenderEffect:IsValidAndVisible()
	if not isNil(self.mainObject) and self.mainObject.activeSelf then
		return true;
	else
		return false;
	end
end












