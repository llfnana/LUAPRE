

--Render对象类型定义
RenderObjectType_Invalid = -1
RenderObjectType_Model = 1;
RenderObjectType_ModelMovable = 2;
RenderObjectType_ModelTeam = 3;
RenderObjectType_HealthBar = 4;
RenderObjectType_TipsBigMapPlayerBuilding = 5;
RenderObjectTypeTipsBigMapPve = 6;
RenderObjectType_Effect = 7;
RenderObjectType_Bullet = 8;
RenderObjectType_BattleState = 9;
RenderObjectType_UIModel = 10;

--基础对象创建参数
RenderObjectInitParams = class("RenderObjectInitParams")
function RenderObjectInitParams:ctor()
	self.ObjectType = RenderObjectType_Invalid
	self.Id       = nil;					--编号
	self.WorldPos = nil;					--当前世界坐标v3
	self.LocalPos = nil;					--当前本地坐标v3
	self.Dir = nil;							--朝向绕Y轴旋转角度float
	self.LookAtPos = nil;                   --朝向
	self.Scale = nil;                       --缩放float
	self.Layer = nil;                       --分层int
	self.Parent = nil;                      --父节点
	self.name = nil;                        --名字
	self.PoolName = nil;					--对象池名称
	self.NameAppend = nil;                  --对象名称添加信息
	self.IsActive = nil;				    --是否可见
	self.Material = nil;					--使用的材质
	self.IsAsyncLoad = true;                --是否异步加载
end

--基础模型对象创建参数
RenderModelInitParams = class("RenderModelInitParams", RenderObjectInitParams)
function RenderModelInitParams:ctor()
	RenderObjectInitParams.ctor(self);
	self.ObjectType = RenderObjectType_Model;
	self.ModelId = nil;						--模型id
	self.colorType = false; 				--角色模型涉及到一个阵营问题， 由这个参数控制使用颜色
	self.OnLoadFinshCallback = nil;			--加载完成回掉
end


--可移动模型对象创建参数
RenderModelMovableParams = class("RenderModelMovableParams", RenderModelInitParams)
function RenderModelMovableParams:ctor()
	RenderModelInitParams.ctor(self);
	self.ObjectType = RenderObjectType_ModelMovable
	self.Speed = 1;							--移动速度
	self.TargetPos = nil;					--移动目标
end


-- --模型编队创建参数
-- RenderModelTeamCreateParams = class("RenderModelTeamCreateParams", RenderModelMovableParams)
-- function RenderModelTeamCreateParams:ctor()
-- 	RenderModelMovableParams.ctor(self);
-- 	self.ObjectType = RenderObjectType_ModelTeam
-- 	--self.ModelIdMatrix = nil;   --模型id二维数组
-- 	--self.OffsetModelPos = true; --模型位置是否偏移一点，否则就是很整齐
-- 	self.ModelInfoArray = nil;    --模型信息
-- end

--血条类创建参数
RenderHealthBarCreateParams = class("RenderHealthBarCreateParams", RenderModelInitParams)
function RenderHealthBarCreateParams:ctor()
	RenderModelInitParams.ctor(self);
	self.ObjectType = RenderObjectType_HealthBar;
	self.Layer = Layer.UI;
	self.ModelName = nil;	
	self.BindObj = nil;
	self.BindOffset = nil;
	self.BindBestDistance = nil;
	self.BindScaleFactor = nil;
	self.BindMaxScale = nil;
	self.BindMinScale = nil;
	self.OnLoadFinshCallback = nil;			--加载完成回掉
end

--战争状态显示
RenderBattleStateCreateParams = class("RenderBattleStateCreateParams", RenderModelInitParams)
function RenderBattleStateCreateParams:ctor()
	RenderModelInitParams.ctor(self);
	self.ObjectType = RenderObjectType_BattleState;
	self.Layer = Layer.Buildings;
	self.ModelId = nil;	
	self.BindObj = nil;
	self.BindOffset = nil;
	self.BindBestDistance = nil;
	self.BindScaleFactor = nil;
	self.BindMaxScale = nil;
	self.BindMinScale = nil;
	self.OnLoadFinshCallback = nil;			--加载完成回掉
end

--基础特效创建参数
RenderEffectCreateParams = class("RenderEffectCreateParams", RenderObjectInitParams)
function RenderEffectCreateParams:ctor()
	RenderObjectInitParams.ctor(self);
	self.ObjectType = RenderObjectType_Effect;
	self.Layer =  Layer.Effect;
	self.EffectName = "";             		--特效名称
	self.OnLoadFinshCallback = nil;			--加载完成回掉
	self.UseParticleMgr = true;				--是否使用ParticleMgr来加载和管理
	self.WorldRotation = nil;
end


--子弹创建参数
RenderBulletCreateParams = class("RenderBulletCreateParams", RenderObjectInitParams)
function RenderBulletCreateParams:ctor()
	RenderObjectInitParams.ctor(self);
	self.ObjectType = RenderObjectType_Bullet;
	self.Layer = Layer.Effect;
	self.EffectName = "";             --特效名称
	self.TargetPos = nil;			  --目标位置
	self.TargetTransform = nil;		  --目标对象
	self.StartPos = nil; 			  --起始位置
	self.FlyMode = BulletFlyMode_Straight; --飞行方式
	self.FlyTime = nil;				  --飞行时间
	self.FlyOverCallback = nil;		  --飞行结束回掉
	self.InitAngle = nil;             --起始角度
	self.UseParticleMgr = true;		  --是否使用ParticleMgr来加载和管理
end



--UIModel创建参数
RenderUIModelCreateParams = class("RenderUIModelCreateParams", RenderObjectInitParams)
function RenderUIModelCreateParams:ctor()
	RenderObjectInitParams.ctor(self);
	self.ObjectType = RenderObjectType_UIModel;	
	self.Layer = Layer.UIModel;
	self.ModelId = nil;
	self.BindUITexture = nil;
	self.TextureWidth = 1024
	self.CameraOffset = nil;
end

