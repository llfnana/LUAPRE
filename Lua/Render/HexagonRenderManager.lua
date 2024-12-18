require ("Logic/Battle/HexagonLogic")

HexagonRenderManager = class("HexagonRenderManager")

function HexagonRenderManager:ctor( ... )
	self.gameObjectRoot = nil;
	self.tabHexagonObject = nil;
	self.tabBattleUnitHexagon = nil;
	self.hexagonObject = nil;
	self.tabActiveHexagon = nil;
	self.tabActionHexagon = nil;
end

function HexagonRenderManager:Inst( ... )
	if self.inst == nil then
		self.inst = HexagonRenderManager.New()
	end
	return self.inst;
end

function HexagonRenderManager:Init()

	ResInterface.SyncLoadGameObject( "Hexagon", function(_prefab) 
		self.hexagonObject = _prefab;
		if self.hexagonObject == nil then
			error("self.hexagonObject is nil!")
			return
		end
		self.matWhite = self.hexagonObject:GetComponent("SpriteRenderer").sharedMaterial;
		
		local matBlue0 = Material.New( self.matWhite );
		matBlue0.name = "matBlue0";
		matBlue0:SetColor("_Color", Color.New( 43/255, 127/255, 255/255, 255/255 ));
		matBlue0:SetFloat("_ColorScale", 1)

		local matBlue1 = Material.New( self.matWhite );
		matBlue1.name = "matBlue1";
		matBlue1:SetColor("_Color", Color.New( 43/255, 127/255, 230/255, 255/255 ));
		matBlue1:SetFloat("_ColorScale", 2)

		local matRed0 = Material.New(self.matWhite);
		matRed0.name = "matRed0";
		matRed0:SetColor("_Color", Color.New( 255/255, 79/255, 57/255, 255/255 ));
		matRed0:SetFloat("_ColorScale", 1)

		local matRed1 = Material.New(self.matWhite);
		matRed1.name = "matRed1";		
		matRed1:SetColor("_Color", Color.New( 230/255, 79/255, 57/255, 255/255  ));
		matRed1:SetFloat("_ColorScale", 2)
		
		local matGreen0 = Material.New(self.matWhite);
		matGreen0.name = "matGreen0";
		matGreen0:SetColor("_Color", Color.New( 43/255, 255/255, 57/255, 255/255 ));
		matGreen0:SetFloat("_ColorScale", 1)

		local matGreen1 = Material.New(self.matWhite);
		matGreen1.name = "matGreen1";		
		matGreen1:SetColor("_Color", Color.New( 43/255, 240/255, 57/255, 255/255  ));
		matGreen1:SetFloat("_ColorScale", 2)		
		
		self.mats = {};
		self.mats[HexagonRender_Red] = matRed0;
		self.mats[HexagonRender_Green] = matGreen0;
		self.mats[HexagonRender_Blue] = matBlue0;
		
		self.selectMats = {};
		self.selectMats[HexagonRender_Red] = matRed1;
		self.selectMats[HexagonRender_Green] = matGreen1;
		self.selectMats[HexagonRender_Blue] = matBlue1;

		self.tabHexagonObject = {};
		self.tabBattleUnitHexagon = {};
		self.tabActiveHexagon = {};
		self.tabActionHexagon = {};

		local HexGridChanged = function( hexIndex, colorType, objectId, isStop )
			self.tabActiveHexagon[ objectId ] = {hexIndex=hexIndex, colorType=colorType};
			self:OnBattleUnitHexGridChanged( hexIndex, colorType, objectId, isStop );
		end
		Event.AddListener( EventDefine.OnBattleUnitHexGridChanged, HexGridChanged )
		
		local BattleUnitActionStatus = function ( hexIndex, colorType, objectId, isStop, isAction )
			self:OnBattleUnitActionStatus( hexIndex, colorType, objectId, isStop, isAction );
		end
		Event.AddListener(EventDefine.OnBattleUnitActionStatus, BattleUnitActionStatus)

		local BattleUnitDestroy = function ( objectId )
			self:OnBattleUnitDestroy( objectId );
		end
		Event.AddListener(EventDefine.OnBattleUnitDestroy, BattleUnitDestroy)

		local BattleUnitActionEnd = function (  )
			self:OnBattleUnitActionEnd(  );
		end
		Event.AddListener(EventDefine.OnBattleUnitActionEnd, BattleUnitActionEnd)		
	end);	
	
end

function HexagonRenderManager:SetHexagonObjectRoot( _root )
	self.gameObjectRoot = _root;
end

function HexagonRenderManager:CreateAllHexagon( _mapData )
	local go = nil;
	local sr = nil;
	local cellType = nil;
	local cellArgs = nil;
	for k,v in pairs(_mapData.grids) do
		if not isNil(self.gameObjectRoot) then
			if not isNil(self.hexagonObject) then
				go = GOInstantiate( self.hexagonObject );
				go.name = k;
				go.transform:SetParent(self.gameObjectRoot.transform);
				go.transform.localPosition = Vector3.New(v.worldpos.x, BattleHexagonHeight, v.worldpos.z);
				go.transform.localEulerAngles = Vector3.New(90, 0, 0);
				go.transform.localScale = Vector3.New(4, 4.2, 1);
				sr = go.transform:GetComponent("SpriteRenderer");

				cellType = tonumber( v.type );
				if cellType == 0 then
					cellArgs = stringsplit(v.args,"|");
					self:SetHexagonColorByType( go, cellType, cellArgs );
				end

				if self.tabHexagonObject[k] == nil then
					--3D格子预制体, SpriteRenderer组件, 计算出来的Key值
					self.tabHexagonObject[k] = {};
					self.tabHexagonObject[k].go = go;
					self.tabHexagonObject[k].render = sr;
					self.tabHexagonObject[k].key = k;
				end
			else
				error("self.hexagonObject is not loaded!")
			end
		end
	end	
end


function HexagonRenderManager:SetHexagonColorByType( go, cellType, cellArgs )
	if go == nil or cellArgs == nil or cellType == nil then
		return;
	end

	local argsType = tonumber(cellArgs[1]);
	if argsType == 1 then
		-- spriteRenderer.color = Color.New(1,1,1,0);
		go:SetActive(false);
	end
end

function HexagonRenderManager:OnBattleUnitActionEnd( objectId )
	if objectId == nil then
		for k,v in pairs( self.tabActionHexagon ) do
			if not v.isStop then
	 			v.render.material = self.mats[v.colorType];
	 		end
		end
		self.tabActionHexagon = {};		
	else
		local v = self.tabActionHexagon[objectId];
		if v ~= nil then
			if not v.isStop then
	 			v.render.material = self.mats[v.colorType];
	 		end	
			self.tabActionHexagon[objectId] = nil;	
		end
	end	
end

function HexagonRenderManager:OnBattleUnitHexGridChanged( hexIndex, colorType, objectId, isStop, isAction )
	local hexagon = self.tabHexagonObject[ hexIndex ];
	if hexagon == nil then
		hexagon = self.tabBattleUnitHexagon[ objectId ].curHexagon;
	end
	if( hexagon ~= nil ) then
		self:SetHexagonColor( hexagon, colorType, objectId, isStop, isAction );
	end
end

function HexagonRenderManager:OnBattleUnitActionStatus( hexIndex, colorType, objectId, isStop, isAction )
	self:OnBattleUnitHexGridChanged( hexIndex, colorType, objectId, isStop, isAction);
end

function HexagonRenderManager:SetHexagonColor( hexagon, colorType, objectId, isStop, isAction )
	isStop = isStop or false;
	isAction = isAction or false;
	
	if colorType < HexagonRender_Red or colorType > HexagonRender_Blue then
		error("HexagonRenderManager:SetHexagonColor::colorType")
		return;
	end
	
	if self.tabBattleUnitHexagon[objectId] == nil then
		self.tabBattleUnitHexagon[objectId] = {};
		self.tabBattleUnitHexagon[objectId].curHexagon = nil;
		self.tabBattleUnitHexagon[objectId].colorType = HexagonRender_Red;
		self.tabBattleUnitHexagon[objectId].isStop = false;

	elseif self.tabBattleUnitHexagon[objectId].curHexagon ~= nil then
	 	if BattleMgr.Inst().__temp_enter_ani then
			self.tabBattleUnitHexagon[objectId].curHexagon.render.material = self.matWhite;
	 	else
			local isActive, accolortype, oldId = self:HexagonIsActive(self.tabBattleUnitHexagon[objectId].curHexagon.key, objectId);
	 		if not isActive then
	 			self.tabBattleUnitHexagon[objectId].curHexagon.render.material = self.matWhite;
	 		else
	 			if self.tabBattleUnitHexagon[objectId].isStop then
					self.tabBattleUnitHexagon[objectId].curHexagon.render.material = self.mats[self.tabBattleUnitHexagon[objectId].colorType];
				else
	 				self.tabBattleUnitHexagon[objectId].curHexagon.render.material = self.mats[accolortype];
	 			end
	 		end
			
			if oldId ~= nil then
				local oldobj = BattleMgr:Inst():GetBattleHeadObj(oldId);
				if oldobj ~= nil then
					self.tabBattleUnitHexagon[oldobj:GetObjectId()].curHexagon.render.material = self.mats[self.tabBattleUnitHexagon[oldobj:GetObjectId()].colorType];
				end
			end			
	 	end
	 	self.tabBattleUnitHexagon[objectId].curHexagon = {};
	 end
	
	if isStop then
		hexagon.render.material = self.mats[colorType];
	else
		hexagon.render.material = self.selectMats[colorType];
	end
		
	self.tabBattleUnitHexagon[objectId].curHexagon = hexagon;
	self.tabBattleUnitHexagon[objectId].colorType = colorType;
	self.tabBattleUnitHexagon[objectId].isStop = isStop;
	
	if isAction then
		self.tabActionHexagon[objectId] = {};
		self.tabActionHexagon[objectId].render = hexagon.render;
		self.tabActionHexagon[objectId].colorType = colorType;
		self.tabActionHexagon[objectId].isStop = isStop;
	end	
end

function HexagonRenderManager:OnBattleUnitDestroy( objectId )
	if objectId ~= nil then
		local battleUnitHexagon = self.tabBattleUnitHexagon[objectId].curHexagon;
		if battleUnitHexagon ~= nil then
			self.tabActiveHexagon[ objectId ] = nil;
			local isActive, accolortype = self:HexagonIsActive(battleUnitHexagon.key, objectId);
			if not isActive then
				battleUnitHexagon.render.material = self.matWhite;
			else
				battleUnitHexagon.render.material = self.mats[accolortype];
			end
		end
	end
end

function HexagonRenderManager:HexagonIsActive( key, objectId )
	if self.tabActiveHexagon == nil then
		return;
	end
	local isActive = false;
	local ct = HexagonRender_White;
	local curobjid = nil;
	for k,v in pairs( self.tabActiveHexagon ) do
		if v.hexIndex == key and k ~= objectId then
			isActive = true;
			ct = v.colorType;
			curobjid = k;
			break;
		end
	end
	return isActive, ct, curobjid;
end

function HexagonRenderManager:Clear()
	Event.RemoveListener( EventDefine.OnBattleUnitHexGridChanged );
	Event.RemoveListener( EventDefine.OnBattleUnitActionStatus );
	Event.RemoveListener( EventDefine.OnBattleUnitDestroy );
	Event.RemoveListener( EventDefine.OnBattleUnitActionEnd );

	if self.mats ~= nil then
		for i = 1, #self.mats do
			Object.Destroy( self.mats[i] )
		end
		self.mats = nil;
	end

	if self.selectMats ~= nil then
		for i = 1, #self.selectMats do
			Object.Destroy( self.selectMats[i] )
		end
		self.selectMats = nil;
	end

	if self.tabHexagonObject ~= nil then
		for k,v in pairs( self.tabHexagonObject ) do
			GameObject.Destroy( v.go ); 
		end
		self.tabHexagonObject = nil 
	end
	if self.hexagonObject ~= nil then
		--GameObject.Destroy( self.hexagonObject );
		self.hexagonObject = nil;
	end
	self.tabHexagonObject = nil;
	self.tabBattleUnitHexagon = nil;
	self.tabActiveHexagon = nil;
	self.tabActionHexagon = nil;
end
