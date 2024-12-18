
require("Render/UIModelToTexture")


RenderUIModel = class("RenderUIModel", RenderObject)


function RenderUIModel:ctor()
	RenderObject.ctor( self )
	self.helper = nil;
end

function RenderUIModel:Destroy()
	if self.helper ~= nil then
		self.helper:Release();
	end	
	self.anims = nil;
	RenderObject.Destroy(self);
end


function RenderUIModel:Create()
	
	if( self.initParams == nil ) then
		error( "Create:self.initParams is nil!" )
		return;
	end
	if( self.state ~= RenderObjectState_None ) then
		error("Create: self.stat is not none!")
		return;
	end	
	
	--查询模型信息
	local modelResName = GetModelResName(self.initParams.ModelId)--TableManager:Inst():GetTableDataByKey( EnumTableID.TabModelID, self.initParams.ModelId, "ResName" );
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


function RenderUIModel:OnModelLoaded( _go )
	
	if not self:CheckStateOnResourceLoaded( _go ) then
		return;
	end

	_go:SetActive( true );
	self.mainObject =  _go;
	self.mainTransform = self.mainObject.transform;
	RenderObject.Init( self );
	self.state = RenderObjectState_Loaded

	self:PlayAnimation( Anims.Idle );
	
	--create impl
	local modelHeight = Util.GetModelHeight( _go );
	local camOffset = Vector3.New( 0, modelHeight*0.5, 0 )
	if self.initParams.CameraOffset ~= nil then
		camOffset = camOffset + self.initParams.CameraOffset
	end
	local baseCameraSize = ( modelHeight + 0.5 ) * 0.5;
	local helperParams = UIModel_Texture_Param.New( self.mainObject, self.initParams.BindUITexture,baseCameraSize, 
														self.initParams.TextureWidth, camOffset );
	self.helper = UIModel_Texture.New();
	self.helper:Create( helperParams );

end


function RenderUIModel:PlayAnimation( _anim )
	self.anims = self.mainObject:GetComponent("Animation");
	if isNil(self.anims) then
		error("RenderUIModel PlayAnimation failed! Animation is null!")
		return;
	end	
	self.anims:Play( _anim )
end








