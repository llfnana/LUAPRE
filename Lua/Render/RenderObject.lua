
require("Logic/Map/MapLogic")

--封装u3d GameObject 基础操作

RenderObject = class("RenderObject")

--物体状态
RenderObjectState_None = 0
RenderObjectState_Loading = 1
RenderObjectState_Loaded = 2
RenderObjectState_Destroyed = 3

function RenderObject:ctor()
	self.name = nil;
	self.initParams = nil;
	self.mainObject = nil;          		--主 GameObject
	self.mainTransform = nil;				--主 Transform
	self.state = RenderObjectState_None;	--当前状态
end

function RenderObject:GetId()
	if self.initParams ~= nil then
		return self.initParams.Id;
	end
	return -1;
end

function RenderObject:Create()
	error("RenderObject:Create call");
	return nil;
end

function RenderObject:SetCreateParams( _initParams )
	self.initParams = _initParams
end


--初始化，创建后调用
function RenderObject:Init()
		
	if self.initParams == nil then
		error("RenderObject:Init params is nil!");
		return;
	end
	
	if isNil( self.mainObject ) then
		error("RenderObject:Init mainObject is nil!");
		return;
	end
	
	if isNil( self.mainTransform ) then
		error("RenderObject:Init mainTransform is nil!");
		return;
	end
	
	if not isNil(self.initParams.Parent) then
		AddChild( self.initParams.Parent, self.mainObject )
	end	
	
	if self.initParams.WorldPos ~= nil then
		self.mainTransform.position = self.initParams.WorldPos
	end
	
	if self.initParams.LocalPos ~= nil then
		self.mainTransform.localPosition = self.initParams.LocalPos
	end

	if self.initParams.Dir ~= nil then
		self.mainTransform.localRotation = Quaternion.Euler(0, self.initParams.Dir, 0)
	end

	if self.initParams.LookAtPos ~= nil then
		self:LookAt( self.initParams.LookAtPos )
	end
	
	if self.initParams.Scale ~= nil then
		self.mainTransform.localScale = Vector3.New( self.initParams.Scale, self.initParams.Scale, self.initParams.Scale );
	end
	
	if self.initParams.Layer ~= nil then
		---self.mainObject.layer = self.initParams.Layer
		SetLayer(self.mainObject, self.initParams.Layer)
	end
	
	if self.initParams.name ~= nil then
		self.mainObject.name = self.initParams.name;
	end

	if self.initParams.NameAppend ~= nil then
		self.mainObject.name = self.mainObject.name..self.initParams.NameAppend;
	end

	if self.initParams.IsActive ~= nil then
		self.mainObject:SetActive( self.initParams.IsActive  )
	end

	if self.initParams.Material ~= nil then
		self:SetMaterial( self.initParams.Material )
	end
end



function RenderObject:GetState()
	return self.state 
end
	
function RenderObject:GetMainObject()
	return self.mainObject;
end


function RenderObject:Destroy()
	if not isNil(self.mainObject) then
		if self.initParams.PoolName ~= nil then
			GoPoolMgr.CurrentPool():Release(self.initParams.PoolName,self.mainObject);
		else
			GameObject.Destroy( self.mainObject );
		end
	end
	self.initParams = nil;
	self.mainObject = nil;
	self.mainTransform = nil;
	self.state = RenderObjectState_Destroyed;

	if self.resId ~= nil and self.resId > 0 then
		ResInterface.ReleaseRes( self.resId )
		self.resId = nil
	end

end


function RenderObject:GetWorldPosition()
	if not isNil(self.mainTransform) then
		return self.mainTransform.position
	else 
		return self.initParams.WorldPos;
	end 
end

function RenderObject:GetForward()
	if not isNil(self.mainTransform) then
		return self.mainTransform.forward
	else 
		return nil;
	end 	
end


function RenderObject:SetWorldPosition( worldPos )
	if not isNil(self.mainTransform) then
		self.mainTransform.position = worldPos;
	end 
end


function RenderObject:SetLocalPosition( localPos )
	if not isNil(self.mainTransform) then
		self.mainTransform.localPosition = localPos;
	end 
end

function RenderObject:GetLocalPosition()
	if not isNil(self.mainTransform) then
		return self.mainTransform.localPosition;
	end 
end


function RenderObject:SetRotationY( rotY )
	if not isNil(self.mainTransform) then
		if self.tempLocalRotation ~= nil then
			self.mainTransform.localRotation = Quaternion.Euler(0, rotY, 0)
		end
		self.tempLocalRotation = nil;
		self.mainTransform.localRotation = Quaternion.Euler(0, rotY, 0)
	else
		self.tempLocalRotation = Quaternion.Euler(0, rotY, 0);
		-- error("[RenderObject:SetRotationY] mainTransform is nil!")
	end 
end

function RenderObject:SetRotation(quaternion)
	if quaternion == nil then
		return;
	end
	
	if not isNil(self.mainTransform) then
		self.mainTransform.localRotation = quaternion;
	else
		error("[RenderObject:SetRotation] mainTransform is nil!")
	end 
end


function RenderObject:SetScale( scale )
	if not isNil(self.mainTransform) then
		self.mainTransform.localScale = Vector3.New( scale, scale, scale )
	end
end

function RenderObject:SetLayer( layer )
	if not isNil( self.mainObject ) then
		self.mainObject.layer = layer
	end
end


function RenderObject:SetActive( isActive )
	if not isNil( self.mainObject ) then
		self.mainObject:SetActive( isActive )
	else
		self.initParams.IsActive = isActive;
	end
end


function RenderObject:SetMaterial( _matName )
	if not isNil(self.mainObject) then
		local func = function( _mat )
			if not isNil( self.mainObject ) then
				Util.SetModelMaterial( self.mainObject, _mat )
			end
		end
		if self.matResId ~= nil then
			ResInterface.ReleaseRes( self.matResId )
		end
		self.matResId = ResInterface.LoadMaterial( _matName,  func)
	else
		error("[RenderModel:SetMaterial]mainObject is nil!");
	end
end


function RenderObject:AddComponent( com, checkExist )
	if isNil(self.mainObject) then
		error("AddComponent error: gameobject is null! Compoment="..tostring(typeof(com)) );
		return nil
	else
		if checkExist then
			local s  = self.mainObject:GetComponent( typeof(com) )
			if not isNil(s) then
				return s;
			end
		end
		return self.mainObject:AddComponent( typeof(com) )
	end
end


function RenderObject:GetComponent( com )
	if isNil(self.mainObject) then
		error("GetComponent error: gameobject is null! Compoment="..tostring(typeof(com))  );
		return nil
	else
		return self.mainObject:GetComponent( typeof(com) )
	end
end


function RenderObject:CheckStateOnResourceLoaded( go )
	if self.state == RenderObjectState_Destroyed then
		if not isNil(go) then
			GameObject.Destroy( go );
			go = nil;
		end
		return false;
	end
	return true;
end











