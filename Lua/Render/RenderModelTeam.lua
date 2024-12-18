RenderModelTeam = class("RenderModelTeam",RenderModelMovable)
TeamModel = class("TeamModel")
function TeamModel:ctor()
	self.renderObj = nil;
	self.isDead = false;
	--self.i = nil;
	--self.j = nil;
	self.index = nil;
end

function TeamModel:PlayDead()
	self.isDead = true;
	self.renderObj:PlayAnimation( Anims.Dead );
	local f = function()
		self:OnDeadAnimEnd();
	end
	LuaTimer:Add( f, 2, 0, true )
end

function TeamModel:OnDeadAnimEnd()
	if self.renderObj ~= nil then
		self.renderObj:Destroy();
		self.renderObj = nil;
	end
end

function TeamModel:IsDead()
	return self.isDead;
end

function TeamModel:IsValid()
   return not self.isDead and self.renderObj ~= nil;
end

function TeamModel:Destroy()
	if self.renderObj ~= nil then
		self.renderObj:Destroy();
		self.renderObj = nil;
	end
end


-----------------------------------------------------------------------

local ModelColDist = 1;
local ModelRowDist = 1;
local ModelDistOffset = 0.3;

------------------------------------------
function RenderModelTeam:ctor()
	RenderModelMovable.ctor(self);
	--self.initRowSize = 0
	--self.initColSize = {}
	--self.maxColSize = 0
	self.subobjects = {}
	self.subCount = 0;
	self.createdSubCount = 0;
	self.effects = {}
end


------------------------------------------
function RenderModelTeam:Create()
	
	if( self.initParams == nil ) then
		error( "Create:self.initParams is nil!" )
		return;
	end
	if( self.state ~= RenderObjectState_None ) then
		error("Create: self.stat is not none!")
		return;
	end
		
	self.mainObject = GameObject.New();
	self.mainTransform = self.mainObject.transform;
	RenderObject.Init( self );
	
	--模型编队设置子节点（也就是实际模型）自动朝向
	self:RotateOn( true )	
	
	
	--create child model
	-- local modelMatrix = self.initParams.ModelIdMatrix;
	-- self.maxColSize = 0;
	-- self.initRowSize = #modelMatrix
	-- self.initColSize = {}
	-- for i = 1, self.initRowSize do
	-- 	self.initColSize[i] = #modelMatrix[i]
	-- 	if self.initColSize[i] > self.maxColSize then
	-- 		self.maxColSize = self.initColSize[i];
	-- 	end
	-- 	self.subCount = self.subCount + self.initColSize[i]
	-- end
	self.createdSubCount = 0
	self.subobjects = {}
	self.state = RenderObjectState_Loading
	
	local _call = function()
		self:OnSubObjectsLoaded();
	end
		

	local forward = nil;
	if self.initParams.WorldPos ~= nil and self.initParams.LookAtPos ~= nil then
		forward = self.initParams.WorldPos - self.initParams.LookAtPos
		forward:SetNormalize();
	end
	
	self.subCount = #self.initParams.ModelInfoArray;
	for i = 1, self.subCount do
		local modelInfo = self.initParams.ModelInfoArray[i]

		local modelCreateParams = RenderModelInitParams.New()
		modelCreateParams.ModelId = modelInfo.modelId
		modelCreateParams.OnLoadFinshCallback = _call
		modelCreateParams.Parent = self.mainObject;
		modelCreateParams.LocalPos = self:FixedLocalPos(modelInfo.localPos, forward); --self:GetLocalPos(i,j, forward);
		modelCreateParams.Layer = self.initParams.Layer
		modelCreateParams.colorType = self.initParams.colorType;
		modelCreateParams.Scale = self.initParams.Scale;
		modelCreateParams.IsAsyncLoad = self.initParams.IsAsyncLoad;

		if self.initParams.LookAtPos ~= nil  then
			modelCreateParams.LookAtPos = self.initParams.LookAtPos
		end
		local ro = RenderSystem.GetInstance():CreateRenderObject(modelCreateParams);

		--提前放到数组里
		local item = TeamModel.New();
		item.renderObj = ro;
		item.index = i;
		--add to mgr
		table.insert( self.subobjects, item );			

		--再创建
		if not ro:Create() then
			error( "[RenderModelTeam:Create]CreateRenderObject failed!" )
			break;
		end

	end
	
	

	
	return true;

end

------------------------------------------
function RenderModelTeam:OnSubObjectsLoaded()
	self.createdSubCount  = self.createdSubCount + 1
	if self.createdSubCount == self.subCount then
		self.state = RenderObjectState_Loaded
		if self.initParams.OnLoadFinshCallback ~= nil then
			self.initParams.OnLoadFinshCallback()
		end
	end
end

------------------------------------------
function RenderModelTeam:PlayAnimation(_animName, _animParams, _speed, _arg1IsClipName)
	for i = 1, #self.subobjects do
		if self.subobjects[i]:IsValid() then
			self.subobjects[i].renderObj:PlayAnimation(_animName, _animParams, _speed, _arg1IsClipName)
		end
	end
end

-----------------------------------------
function RenderModelTeam:LookAt( v3 )

	for i = 1, #self.subobjects do
		if self.subobjects[i]:IsValid() then
			self.subobjects[i].renderObj:LookAt(v3)
		end
	end
end

------------------------------------------
function RenderModelTeam:RotateSubObjectY( rotY )
	for i = 1, #self.subobjects do
		if self.subobjects[i]:IsValid() then
			self.subobjects[i].renderObj:SetRotationY(rotY)
		end
	end
end


------------------------------------------废弃
function RenderModelTeam:GetLocalPos( _i, _j, _forward )
	local centerRow = (self.initRowSize+1)/2
	local centerCol = (self.maxColSize+1)/2;
	local offsetX = (self.maxColSize - self.initColSize[_i]) * ModelColDist * 0.5;
	local x =(_j-centerCol) * ModelColDist + offsetX;
	local z = (centerRow - _i) * ModelRowDist;
	if self.initParams.OffsetModelPos then
	 	x = x + (ModelDistOffset*math.random())
	 	z = z + (ModelDistOffset*math.random())
	end
	local pos = Vector3.New( x, ObjectHeight, z )
	if _forward ~= nil then
		--local rotAngle = Vector3.Angle( Vector3.forward, _forward )
		--local quat = Quaternion.LookRotation( _forward )
		--pos = quat*pos;
		local right = Vector3.Cross(_forward, Vector3.up)
		pos = (right*pos.x) + (_forward*pos.z);
		pos.y = ObjectHeight
	end
	return pos
end


function RenderModelTeam:FixedLocalPos( _localPos, _forward )
	if _forward ~= nil then
		local right = Vector3.Cross(_forward, Vector3.up)
		local pos = (right*_localPos.x) + (_forward*_localPos.z);
		pos.y = ObjectHeight
		return pos	
	else
		return _localPos;
	end
end


------------------------------------------ _index start form 1
function RenderModelTeam:GetObjByIndex( _index )
	return self.subobjects[ _index ];
end


------------------------------------------
function RenderModelTeam:RandomDie( _count )
	
	local validIndex = {}
	for i= 1, #self.subobjects do
		if self.subobjects[i]:IsValid() then
			table.insert( validIndex, i);
		end
	end
		
	local cnt = math.min( _count, #validIndex )
	
	for i = 1, cnt do 
		local randomIndex = math.random( #validIndex );
		local objIndex = validIndex[randomIndex];
		self.subobjects[objIndex]:PlayDead();
		table.remove( validIndex, randomIndex );
	end
end



function RenderModelTeam:Die( _count )

	local validIndex = {}
	for i= 1, #self.subobjects do
		if self.subobjects[i]:IsValid() then
			table.insert( validIndex, i);
		end
	end	

	local cnt = math.min( _count, #validIndex )
	for i = cnt, 1, -1 do
		local idx = validIndex[i]
		self.subobjects[idx]:PlayDead();
	end

end



------------------------------------------get child model count
function RenderModelTeam:GetSubNodeCount()
	return self.subCount;
end


------------------------------------------get child node bind pos,  _index start from 1
function RenderModelTeam:GetSubNodeBindPos( _index, _bindPos )
	local obj = self:GetObjByIndex( _index )
	if obj ~= nil and obj:IsValid() then
		return obj.renderObj:GetBindPos( _bindPos )
	end
	error("[RenderModelTeam:GetSubNodeBindPos]_index beyond subobjects's size!");
	return nil;
end


------------------------------------------
function RenderModelTeam:GetRandomSubNodeBindPos(_bindPos)
	local idx = math.random( 1, #self.subobjects );
	if self.subobjects[idx]:IsValid() then
		return self.subobjects[idx].renderObj:GetBindPos(_bindPos)
	end
	for i = 1, #self.subobjects do
		if self.subobjects[i]:IsValid() then
			return self.subobjects[i].renderObj:GetBindPos( _bindPos );
		end
	end
	return  nil;
end


function RenderModelTeam:GetHeight()
	if self.modelHeight == nil then
		for i = 1, #self.subobjects do
			if self.subobjects[i]:IsValid() then
				 self.modelHeight = self.subobjects[i].renderObj:GetHeight()
				 break;
			end
		end		
	end
	return self.modelHeight;
end


------------------------------------------todo
function RenderModelTeam:GetBindPos( _bindPos, _space )
	local h = self:GetHeight();
	h = h or 0;
	local feetPos = Vector3.New( 0, 0.1, 0);
	if _space == nil or _space == Space_World then
		feetPos = self:GetWorldPosition();
	end
	if _bindPos == ModelBindPosType_Center then
		return feetPos + Vector3.New( 0, h*0.7, 0);
	elseif _bindPos == ModelBindPosType_Feet then
		return feetPos;
	elseif _bindPos == ModelBindPosType_Head then
		return feetPos + Vector3.New( 0, h, 0);
	elseif _bindPos == ModelBindPosType_HeadUp then
		return feetPos + Vector3.New( 0, h, 0);
	elseif _bindPos == ModelBindPosType_LeftHand then
		return feetPos + Vector3.New( 0, h*0.5, 0);
	elseif _bindPos == ModelBindPosType_RightHand then
		return feetPos + Vector3.New( 0, h*0.5, 0);
	else
		error("[RenderModelTeam:GetBindPos]return nil! _bindPos=".._bindPos);
	end
end


------------------------------------------
function RenderModelTeam:AddEffect( _effectInfo, _bindPos, _unit, _localPosition, _loop, _autoDestroy, _worldRotation )

	
	_autoDestroy = false; --由于都使用了特效管理器，老的删除特效的方式不再使用

	local _effectName = _effectInfo.ResName;
	if _unit == SkillActUnit_Model then
		if _loop == nil then
			_loop = true;
		end
		for i = 1, #self.subobjects do
			if self.subobjects[i]:IsValid() then
				self.subobjects[i].renderObj:AddEffect(_effectInfo,_bindPos,nil,_localPosition, _loop, _autoDestroy)
			end
		end
	elseif _unit == SkillActUnit_Team then
		if _loop == nil then
			_loop = true;
		end	
		if _autoDestroy == nil then
			_autoDestroy = true;
		end	
		if self.effects == nil then
			self.effects = {}
		elseif self.effects[_effectName] ~= nil then
			--check if alread exist
			if self.effects[_effectName]:IsValidAndVisible() then
				return;
			end
		end
		if isNil(self.mainObject) then
			--todo
			return;
		end
		--create effect
		local createParams = RenderEffectCreateParams.New();
		createParams.EffectName = _effectName;
		createParams.Parent = self.mainObject;
		createParams.autoDestroy = _autoDestroy;
		createParams.LocalPos = self:GetBindPos( _bindPos, Space_Local ) + (_localPosition or Vector3.zero);
		createParams.WorldRotation = _worldRotation;
		createParams.audioId = _effectInfo["Audio"] or -1;
		createParams.audioTime = _effectInfo["AudioTime"] or 0;
		local effect = RenderSystem.GetInstance():CreateRenderObject( createParams );
		--if effect:Create() and _loop == false and _autoDestroy == false then
		if effect:Create() then
			self.effects[_effectName] = effect;
		end
	end
end


------------------------------------------
function RenderModelTeam:RemoveEffect( _effectName, _unit )
	if _unit == SkillActUnit_Model then
		for i = 1, #self.subobjects do
			if self.subobjects[i]:IsValid() then
				self.subobjects[i].renderObj:RemoveEffect(_effectName)
			end
		end
	elseif _unit == SkillActUnit_Team then
		if self.effects == nil then
			return;
		end
		if self.effects[_effectName] == nil then
			return;
		end
		self.effects[_effectName]:Destroy();
		self.effects[_effectName] = nil;
	end
end

------------------------------------------
function RenderModelTeam:Destroy()
	if self.effects ~= nil then
		for _, v in pairs(self.effects) do
			v:Destroy();
		end
		self.effects = nil;
	end
	if self.subobjects ~= nil then
		for i = 1, #self.subobjects do
			self.subobjects[i]:Destroy();
		end
		self.subobjects = nil;
	end
	RenderObject.Destroy(self);
	self.modelHeight = nil;
	self.highlighter = nil;
end


----------------------------------------
function RenderModelTeam:HighLightOn( _color )
	if isNil( self.highlighter ) then
		self.highlighter = self:AddComponent( Highlighter, true )
		if( isNil(self.highlighter) ) then
			return;
		end		
	end
	self.highlighter:ConstantOn( _color );
end


-----------------------------------------
function RenderModelTeam:HighLightOff()
	if not isNil( self.highlighter ) then
		self.highlighter:ConstantOff();
	end
end









