require("Render/RenderObject")

RenderBullet = class("RenderBullet", RenderObject)

function RenderBullet:ctor()
	RenderObject.ctor(self)
end

function RenderBullet:Create()

	if( self.initParams == nil ) then
		error( "Create:self.initParams is nil!" )
		return;
	end
	if( self.state ~= RenderObjectState_None ) then
		error("Create: self.stat is not none!")
		return;
	end

	if self.initParams.EffectName == nil then
		error("[RenderBullet]EffectName is nil!")
		return false;
	end 
	local f = function(go,particleId)
		self:OnResourceLoaded(go,particleId)
	end

	self.state = RenderObjectState_Loading;

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
			self.particleObjId = ParticleMgr:PlayEffect(effectRes, parent, pos, scale, f, false, Quaternion.identity);			
		else
			self.resId = ResInterface.CreateEffect( self.initParams.EffectName, f )
		end
	end
	return true;
end

function RenderBullet:OnResourceLoaded(go, particleId)
	
	if self.state == RenderObjectState_Destroyed then
		self:Destroy();
		return;
	end

	--check params
	if self.initParams == nil then
		error("RenderBullet:OnResourceLoaded init params is nil!")
		return;
	end
	
	if( self.initParams.StartPos == nil ) then
		error("RenderBullet:OnResourceLoaded StartPos is nil!")
		return;
	end
	
	if( self.initParams.TargetPos == nil ) then
		error("RenderBullet:OnResourceLoaded TargetPos is nil!")
		return;
	end
	
	if( self.initParams.FlyTime == nil ) then
		error("RenderBullet:OnResourceLoaded FlyTime is nil!")
		return;
	end
	
	if( self.initParams.InitAngle == nil ) then
		error("RenderBullet:OnResourceLoaded InitAngle is nil!")
		return;
	end
	
	
	
	go:SetActive( true );

	local trailRenderer = go:GetComponentInChildren(typeof(TrailRenderer), true)
	if trailRenderer then
		trailRenderer:Clear()
	end

	self.mainObject = go;
	self.mainTransform = self.mainObject.transform;
	RenderObject.Init( self );
	self.state = RenderObjectState_Loaded
	
	--start fly
	local _callback = function(...)
		self:OnHit(...);
	end
	
	if self.initParams.FlyMode == BulletFlyMode_None then
		self.moveControl = nil;
		LuaTimer:Add( _callback, self.initParams.FlyTime, 0, true)
		
	elseif self.initParams.FlyMode == BulletFlyMode_Straight then
		self.moveControl = self:AddComponent( MoveObjectControl, true );

		self.moveControl:Begin( true )
		self.moveControl:AddPos( self.initParams.StartPos.x, self.initParams.StartPos.y, self.initParams.StartPos.z );		
		self.moveControl:AddPos( self.initParams.TargetPos.x, self.initParams.TargetPos.y, self.initParams.TargetPos.z );	
		self.moveControl:End( _callback )
		self.moveControl:GoTimeMode(self.initParams.FlyTime, self.initParams.FlyTime);		

		--log("RenderBullet StartMove:".. tostring(self.initParams.StartPos)..";"..tostring(self.initParams.TargetPos)..";"..tostring(self.initParams.FlyTime))

		
	elseif self.initParams.FlyMode == BulletFlyMode_Parabola then
		
		self.moveControl = self:AddComponent( ParabolaMove2, true );
		self.moveControl:StartFly(self.initParams.StartPos,self.initParams.TargetPos, self.initParams.FlyTime, 
							self.initParams.InitAngle, _callback )
		
	else
		error("[RenderBullet:OnResourceLoaded]Unknown FlyMode="..self.initParams.FlyMode)
	end
	
	
	
	if self.initParams.OnLoadFinshCallback ~= nil then
		self.initParams.OnLoadFinshCallback()
	end

end

function RenderBullet:Destroy()

	if self.moveControl ~= nil then
		Object.Destroy(self.moveControl);
		self.moveControl = nil;
	end

	if self.initParams == nil then
		return;
	end

	if self.initParams.UseParticleMgr then
		if  self.particleObjId ~= nil then
			ParticleMgr:StopEffect(self.particleObjId)
			self.particleObjId = nil;
			self.initParams = nil;
			self.mainObject = nil;
			self.mainTransform = nil;
			self.state = RenderObjectState_Destroyed;
		end
	else
		RenderObject.Destroy(self)
	end

end



function RenderBullet:OnHit(...)
	if self.state == RenderObjectState_Destroyed then
		-- 已经销毁了。
		return;
	end
	
	if self.initParams.FlyOverCallback ~= nil then
		self.initParams.FlyOverCallback()
	end
	self:Destroy();
end


function RenderBullet:GetRemainDistance()
	
	if self.state == RenderObjectState_Destroyed then
		return 0;
	end	

	local curPos = self:GetWorldPosition();
	if curPos ~= nil and self.initParams.TargetPos ~= nil then
		return Vector3.Distance(curPos, self.initParams.TargetPos);
    end
    return -1;
end













