

--require("Render/GoPoolMgr")
require("Render/RenderModel")
require("Render/RenderModelMovable")
--require("Render/RenderModelTeam")
require("Render/RenderHealthBar")
require("Render/RenderEffect")
require("Render/RenderBullet")
require("Render/RenderUIModel")

RenderSystem = class("RenderSystem");
local g_RenderSystem = nil;

function RenderSystem.GetInstance()
	if (g_RenderSystem == nil) then
		g_RenderSystem = RenderSystem.New();
	end
	return g_RenderSystem;
end

---------------------------------------------------------------------------
function RenderSystem:ctor()
	self.mIdGeneral = 1;
	self.mRenderObjects = {};
	GoPoolMgr.CurrentPool():Init();
end


---------------------------------------------------------------------------
function RenderSystem:GeneralId()
	local id = self.mIdGeneral;
	self.mIdGeneral = self.mIdGeneral + 1;
	return id;
end


---------------------------------------------------------------------------
--创建对象
function RenderSystem:CreateRenderObject( _createParams )
	local objType = _createParams.ObjectType;
	local obj = nil;
	if objType == RenderObjectType_Model then
		obj = RenderModel.New();
	elseif objType == RenderObjectType_ModelMovable then
		obj = RenderModelMovable.New();
	-- elseif objType == RenderObjectType_ModelTeam then
	-- 	obj = RenderModelTeam.New();
	elseif objType == RenderObjectType_HealthBar then
		obj = RenderHealthBar.New();		
	elseif objType == RenderObjectType_Effect then
		obj = RenderEffect.New();
	elseif objType == RenderObjectType_Bullet then
		obj = RenderBullet.New();
	elseif objType == RenderObjectType_BattleState then
		obj = RenderBattleState.New();	
	elseif objType == RenderObjectType_UIModel then
		obj = RenderUIModel.New();	
	else
		error("[RenderSystem:CreateRenderObject]Unsupport type!objType="..objType)
		return;
	end
	
	--id赋值
	_createParams.Id = self:GeneralId();
	obj:SetCreateParams( _createParams );
	
	--存储
	self.mRenderObjects[obj:GetId()] = obj;
	return obj;
end

---------------------------------------------------------------------------
--删除对象
function RenderSystem:DestroyRenderObject(obj)
	if(obj == nil) then
		return;
	end
	local id = obj:GetId()
	if(id == nil) then
		return;
	end
	self.mRenderObjects[id] = nil;
	obj:Destroy();
end

---------------------------------------------------------------------------
--获取对象
function RenderSystem:GetRenderObject(id)
	return self.mRenderObjects[id]
end



---------------------------------------------------------------------------
--清空对象
function RenderSystem:Clear()
	for id, obj in pairs(self.mRenderObjects) do 
		obj:Destroy();
	end
	self.mRenderObjects = {}
end




