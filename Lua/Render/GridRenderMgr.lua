

--画格子接口
GridRenderMgr = class("GridRenderMgr")

local gridHalfWidth = 0.45
local lineWidth = 0.03

function GridRenderMgr:ctor()
	self.lineRenderPool = {}
	self.cells = {}
	self.gameObjectRoot = nil;
end


function GridRenderMgr:Inst()
	if self.inst == nil then
		self.inst = GridRenderMgr.New()
	end
	return self.inst;
end

function GridRenderMgr:DrawGrid( _gridPos )
	
	local cellid = MapLogic.GetCellIdByGridPos( _gridPos.x, _gridPos.y )
	if self.cells[cellid] ~= nil then
		return;
	end
	
	local lr = self:GetLineRender( "Grid_"..tostring(cellid) );
	if isNil(lr) then
		return;
	end
	
	local worldPos = MapLogic.GridPosToU3DWorldPos( _gridPos );
		
	--外观设置
	lr.startWidth = lineWidth;
	lr.endWidth = lineWidth;
	lr.numPositions = 5;
	lr.receiveShadows = false;
	lr:SetPosition( 0, Vector3.New(worldPos.x - gridHalfWidth, LineRenderHeight, worldPos.z - gridHalfWidth ) )
	lr:SetPosition( 1, Vector3.New(worldPos.x + gridHalfWidth, LineRenderHeight, worldPos.z - gridHalfWidth) )
	lr:SetPosition( 2, Vector3.New(worldPos.x + gridHalfWidth, LineRenderHeight, worldPos.z + gridHalfWidth) )
	lr:SetPosition( 3, Vector3.New(worldPos.x - gridHalfWidth, LineRenderHeight, worldPos.z + gridHalfWidth) )
	lr:SetPosition( 4, Vector3.New(worldPos.x - gridHalfWidth, LineRenderHeight, worldPos.z - gridHalfWidth ) )
	lr.gameObject:SetActive( true );
	
	
	self.cells[cellid] = lr;
		
end


function GridRenderMgr:RemoveGrid( _gridPos )
	local cellid = MapLogic.GetCellIdByGridPos( _gridPos.x, _gridPos.y )
	if self.cells[cellid] ~= nil then
		self:ReleaseLineRender( self.cells[cellid] )
		self.cells[cellid] = nil;
	end
end


function GridRenderMgr:SetLineObjectRoot( _root )
	self.gameObjectRoot = _root;
end



function GridRenderMgr:CreateLineRender( name )
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

function GridRenderMgr:ReleaseLineRender( _lineRender )
	_lineRender.gameObject:SetActive( false );
	table.insert( self.lineRenderPool, _lineRender ); 
end


function GridRenderMgr:GetLineRender( id )
	local com = nil;
	local freeSize = #self.lineRenderPool;
	if freeSize > 0 then
		com = self.lineRenderPool[freeSize]
		table.remove( self.lineRenderPool, freeSize );
	else
		com = self:CreateLineRender("LineRender"..id );
	end
	return com;
end


function GridRenderMgr:Clear()
	for i = 1, #self.lineRenderPool do
		GameObject.Destroy( self.lineRenderPool[i].gameObject ); 
	end
	for k, v in pairs(self.cells) do
		GameObject.Destroy( v.gameObject ); 
	end
	self.lineRenderPool = {}
	self.cells = {}
end





















