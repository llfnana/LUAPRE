
require("Render/RenderObject")


RenderObjTipsBuilding = class("RenderObjTipsBuilding", RenderObject)


function RenderObjTipsBuilding:ctor()
	RenderObject.ctor( self )
	self.labelLevel = nil;
	self.lv = nil;
end

function RenderObjTipsBuilding:Destroy()
	RenderObject.Destroy(self);
	self.labelLevel = nil;
	self.lv = nil;
end


function RenderObjTipsBuilding:Create()
	
	if( self.initParams == nil ) then
		error( "Create:self.initParams is nil!" )
		return;
	end
	if( self.state ~= RenderObjectState_None ) then
		error("Create: self.stat is not none!")
		return;
	end		
	
	
	--查询模型信息
	local modelResName = self.initParams.ModelName
	if( modelResName == nil ) then
		error("cant't find model name: modeid="..self.initParams.ModelId)
		return false
	end
	
	self.name = modelResName.."_"..self.initParams.Id
	
	local f = function( _go )
		self:OnModelLoaded(_go)
	end

	self.state = RenderObjectState_Loading;
	if self.initParams.PoolName ~= nil then
		GoPoolMgr.CurrentPool():GetObject( self.initParams.PoolName, modelResName, f );
	else
		self.resId = ResInterface.CreateModel( modelResName, f );
	end	

	return true;
end


function RenderObjTipsBuilding:OnModelLoaded( _go )

	if not self:CheckStateOnResourceLoaded( _go ) then
		return;
	end			


	_go:SetActive( true );
	self.mainObject = _go;
	self.mainTransform = self.mainObject.transform;
	RenderObject.Init( self );
	self.state = RenderObjectState_Loaded

	self.mainObject.transform.localPosition = Vector3.zero
	self.mainObject.transform.localRotation = Vector3.zero
	self.mainObject.transform.localScale = Vector3.one

	if self.name ~= nil then
		_go.name = self.name;
	end

	if self.labelLevel ~= nil then
		self:SetShowLevel(self.lv)
		self.lv = nil;
	end

	if self.initParams.OnLoadFinshCallback ~= nil then
		self.initParams.OnLoadFinshCallback()
	end
end

function RenderObjTipsBuilding:SetShowLevel( _lv )
	if isNil(self.mainObject) then
		--not load ok
		self.lv = _lv
		return; 
	end

	--if(1 == 1 )then
	--	return;
	--end

	if(1 == 1) then
		return;
	end


	if isNil( self.labelLevel ) then
		self.labelLevel = self.mainObject.transform:Find("LabelInfo"):GetComponent("UILabel")
		if isNil(self.labelLevel) then
			error("SetShowLevel failed! labelLevel is null!")
			return;
		end
	end
	self.labelLevel.text = tostring(_lv);
end
