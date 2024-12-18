

--GameObject Layer 定义, 缓存Unity里定义的Layer, 减少和C#交互
LayerMask = UnityEngine.LayerMask;
Layer = Layer or {}

function Layer.Init()
	Layer.Default = LayerMask.NameToLayer( ConstDefine.Layer_Default );
	Layer.Water = LayerMask.NameToLayer( ConstDefine.Layer_Water );
	Layer.UI = LayerMask.NameToLayer( ConstDefine.Layer_UI );
	Layer.Ground = LayerMask.NameToLayer( ConstDefine.Layer_Ground );
	Layer.Buildings = LayerMask.NameToLayer( ConstDefine.Layer_Buildings );
	Layer.NPC = LayerMask.NameToLayer( ConstDefine.Layer_NPC );
	Layer.Army = LayerMask.NameToLayer( ConstDefine.Layer_Army );
	Layer.UI3D = LayerMask.NameToLayer( ConstDefine.Layer_UI3D );
	Layer.Line = LayerMask.NameToLayer( ConstDefine.Layer_Line );
	Layer.Effect = LayerMask.NameToLayer( ConstDefine.Layer_Effect );
	Layer.FightObj = LayerMask.NameToLayer( ConstDefine.Layer_FightObj );
	Layer.UIModel = LayerMask.NameToLayer( ConstDefine.Layer_UIModel );
	Layer.EffectCanClick = LayerMask.NameToLayer( ConstDefine.Layer_EffectCanClick );
	Layer.Additional = LayerMask.NameToLayer( ConstDefine.Layer_Additional );
	Layer.StaticObj = LayerMask.NameToLayer( ConstDefine.Layer_StaticObj );
	Layer.MarchLine = LayerMask.NameToLayer( ConstDefine.Layer_MarchLine );
	Layer.WaterGrab = LayerMask.NameToLayer( ConstDefine.Layer_WaterGrab );
	Layer.StaticObjSmall = LayerMask.NameToLayer( ConstDefine.Layer_StaticObjSmall );
	Layer.DragableObject = LayerMask.NameToLayer( ConstDefine.Layer_DragableObject );
	Layer.UIEffect = LayerMask.NameToLayer( ConstDefine.Layer_UIEffect );
	Layer.RealtimeLight = LayerMask.NameToLayer( ConstDefine.Layer_RealtimeLight );
	Layer.Hide = LayerMask.NameToLayer( ConstDefine.Layer_Hide );
end

function Layer.GetMask(...)
	local arg = {...}
	local value = 0	
	for i = 1, #arg do		
		local n = arg[i];
		if n ~= nil then
			value = value + 2 ^ n				
		end
	end	
	return value
end




-- Layer_Ground = "Ground";                  --地面
-- Layer_Buildings = "Buildings";            --建筑
-- Layer_NPC = "NPC";                        --怪物
-- Layer_Army = "Army";                      --军队
-- Layer_UI3D = "UI3D";                      --3DUI
-- Layer_Line = "Line";                      --地面上的辅助线
-- Layer_Effect = "Effect";                  --特效
-- Layer_FightObj = "FightObj";              --战斗对象
-- Layer_UIModel = "UIModel";                --UI模型
-- Layer_EffectCanClick = "EffectCanClick";  --可点击的特效
-- Layer_Additional = "Additional";          --特殊渲染效果处理所用的层
-- Layer_StaticObj = "StaticObj";            --静态模型， 树，山，石头， 占用格子阻挡，坐标x, z必须是整数， 包围盒size, x, z也必须是整数（即占用格子大小)
-- Layer_MarchLine = "MarchLine";            --行军线
-- Layer_WaterGrab = "WaterGrab";            --水特效需要提前渲染到RTT的对象
-- Layer_StaticObjSmall = "StaticObjSmall";  --静态模型小（小石头，花草）， 和StaticObj区别是不用计算格子阻挡，坐标x,z不用是整数
-- Layer_DragableObject = "DragableObject";  --可拖动的物体（迁城时玩家城堡）



