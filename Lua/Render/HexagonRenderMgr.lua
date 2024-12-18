
require ("Logic/Battle/HexagonLogic")


--画六边形格子接口
HexagonRenderMgr = class("HexagonRenderMgr")


local lineWidth = 0.03

function HexagonRenderMgr:ctor()
	self.lineRenderPool = {}
	self.cells = {}
	self.gameObjectRoot = nil;
	self.mat = nil;
end


function HexagonRenderMgr:Inst()
	if self.inst == nil then
		self.inst = HexagonRenderMgr.New()
	end
	return self.inst;
end


function HexagonRenderMgr:Init()

	self.lineRenderPool = {}
	self.cells = {}
	
	if self.mat == nil then
		local f = function( _matObj )
			self.mat = _matObj
			self:OnMatLoaded();
		end
		ResInterface.LoadMaterial( "armypathline", f )
	end
	
	local f = function( ... )
		
		self:OnBattleUnitHexGridChanged( ... );
	
	end
	Event.AddListener(EventDefine.OnBattleUnitHexGridChanged, f)
end



function HexagonRenderMgr:Clear()
	
	Event.RemoveListener( EventDefine.OnBattleUnitHexGridChanged );
	
	if( self.lineRenderPool ~= nil ) then
		for i = 1, #self.lineRenderPool do
			GameObject.Destroy( self.lineRenderPool[i].gameObject ); 
		end
		self.lineRenderPool = nil;
	end
	
	if self.cells ~= nil then
		for k, v in pairs(self.cells) do
			GameObject.Destroy( v.gameObject ); 
		end
		self.cells = nil;
	end
	
	self.mat = nil;
	self.colors = nil;
end


function HexagonRenderMgr:OnBattleUnitHexGridChanged( ... )
	
	--[[local args = { ... }
	local newHexX = args[1]
	local newHexY = args[2]
	local oldHexX = args[3]
	local oldHexY = args[4]
	if newHexX ~= nil and newHexY ~= nil then
		
		self:SetColor( newHexX, newHexY, Color.yellow );
	end
	
	if oldHexX ~= nil and oldHexY ~= nil then
		self:SetColor( oldHexX, oldHexY, Color.white );
	end--]]
end


function HexagonRenderMgr:OnMatLoaded()
	if not isNil( self.mat ) then
		for k, v in pairs(self.cells) do
			v.material = self.mat;	
				
			if self.colors ~= nil and self.colors[k] ~= nil then
				v.material.color = self.colors[k]
				self.colors[k] = nil;
			end
			
			v.gameObject:SetActive( true );
		end
	end
end



function HexagonRenderMgr:DrawGridByInfo( _hexGridInfo )
	
	local cellid = HexagonLogic.HexPosToId2( _hexGridInfo.col, _hexGridInfo.row )
	if self.cells[cellid] ~= nil then
		return;
	end
	local name = "HexGrid(".._hexGridInfo.col..";".._hexGridInfo.row..")"
	self:drawGrid( name, cellid, _hexGridInfo.worldpos );
end


function HexagonRenderMgr:RemoveGridByInfo( _hexGridInfo )

	local cellid = HexagonLogic.HexPosToId2( _hexGridInfo.col, _hexGridInfo.row )
	if self.cells[cellid] ~= nil then
		self:ReleaseLineRender( self.cells[cellid] )
		self.cells[cellid] = nil;
	end

end


function HexagonRenderMgr:DrawGridByPos( _hexPos )
	
	local cellid = HexagonLogic.HexPosToId(_hexPos)
	if self.cells[cellid] ~= nil then
		return;
	end
	
	local worldPos = HexagonLogic.HexPosToWorldPos( _hexPos );
	--如果不在第一象限，就不画了
	if worldPos.z < 0 then
		return;
	end
	local name = "HexGrid(".._hexPos.x..";".._hexPos.y..")"
	self:drawGrid( name, cellid, worldPos );
end

function HexagonRenderMgr:drawGrid( name, cellid, worldpos )
	local corners = HexagonLogic.WorldPosToHexCornersWorldPos(worldpos)
	corners[7] = corners[1]
	local lr = self:GetLineRender( name );
	if isNil(lr) then
		return;
	end
	lr.startWidth = lineWidth;
	lr.endWidth = lineWidth;
	lr.positionCount = 7;
	lr.receiveShadows = false;
	lr:SetPositions(corners)
	if isNil( self.mat ) then
		lr.gameObject:SetActive( false );
	else
		lr.material = self.mat;
		if self.colors ~= nil and self.colors[cellid] ~= nil then
			lr.material.color = self.colors[cellid]
			self.colors[cellid] = nil;
		end
		lr.gameObject:SetActive( true );
	end
	self.cells[cellid] = lr;
end


function HexagonRenderMgr:SetColor( _x, _y , _color )
	local cellid = HexagonLogic.HexPosToId2(_x, _y )
	if self.cells[cellid] ~= nil then
		self.cells[cellid].lr.material.color = _color;
	else
		if self.colors == nil then
			self.colors = {}
		end
	    self.colors[cellid] = _color
	end
end


function HexagonRenderMgr:RemoveAll()
	if self.cells ~= nil then
		for k, v in pairs(self.cells) do
			self:ReleaseLineRender( v )
			self.cells[k] = nil;
		end
	end
end


function HexagonRenderMgr:RemoveGrid( _hexPos )
	local cellid =  HexagonLogic.HexPosToId(_hexPos )
	if self.cells[cellid] ~= nil then
		self:ReleaseLineRender( self.cells[cellid] )
		self.cells[cellid] = nil;
	end
end


function HexagonRenderMgr:SetLineObjectRoot( _root )
	self.gameObjectRoot = _root;
end



function HexagonRenderMgr:CreateLineRender( name )
	local obj = GameObject.New(name);
	if not isNil(self.gameObjectRoot) then
		AddChild( self.gameObjectRoot, obj )
	end
	local com = obj:AddComponent(typeof(LineRenderer));
	if isNil(com) then
		error("AddCompoment LineRender Failed!")
		GameObject.Destroy( obj );
		obj = nill;
		return nil;
	end
	return com;
end

function HexagonRenderMgr:ReleaseLineRender( _lineRender )
	_lineRender.gameObject:SetActive( false );
	table.insert( self.lineRenderPool, _lineRender ); 
end


function HexagonRenderMgr:GetLineRender( name )
	local com = nil;
	local freeSize = #self.lineRenderPool;
	if freeSize > 0 then
		com = self.lineRenderPool[freeSize]
		table.remove( self.lineRenderPool, freeSize );
	else
		com = self:CreateLineRender( name );
	end
	return com;
end
























