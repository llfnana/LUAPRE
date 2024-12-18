
require("Render/RenderObject")


RenderObjTipsWildLand = class("RenderObjTipsWildLand", RenderObject)


function RenderObjTipsWildLand:ctor()
	RenderObject.ctor( self )
	self.labelLevel = nil;
	self.lv = nil;
end

function RenderObjTipsWildLand:Destroy()
	RenderObject.Destroy(self);
	self.labelLevel = nil;
	self.lv = nil;
end


function RenderObjTipsWildLand:Create()
	
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
	self.state = RenderObjectState_Loading;

	if self.initParams.PoolName ~= nil then
		GoPoolMgr.CurrentPool():GetObject( self.initParams.PoolName, modelResName, f );
	else
		self.resId = ResInterface.CreateModel( modelResName, f );
	end	
	

	return true;
end


function RenderObjTipsWildLand:OnModelLoaded( _go )

	if not self:CheckStateOnResourceLoaded( _go ) then
		return;
	end			

	_go:SetActive( true );
	self.mainObject = _go;
	self.mainTransform = self.mainObject.transform;
	RenderObject.Init( self );
	self.state = RenderObjectState_Loaded

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


function RenderObjTipsWildLand:SetShowLevel( _lv )
	if isNil(self.mainObject) then
		--not load ok
		self.lv = _lv
		return; 
	end

	if isNil( self.labelLevel ) then
		self.labelLevel = self.mainObject.transform:Find("Info/label_level"):GetComponent("UILabel")
		if isNil(self.labelLevel) then
			error("SetShowLevel failed! labelLevel is null!")
			return;
		end
	end
	self.labelLevel.text = tostring(_lv);
end
