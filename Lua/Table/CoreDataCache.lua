

CoreDataCache = CoreDataCache or {}
local this = CoreDataCache


--把一些C#层面需要用到的Lua数据，存入到C#的D类里面, 这样做的主要用意是
--1）因为所有逻辑代码都是Lua负责，表格数据和一些配置都是在Lua层面管理，C#层面只是做一些渲染编程便利，所以从Lua把数据传输给C#里面只是一种优化，而不破坏这两者的职责。
--2) 如何优化：比如模型表格，在C#编码中大量用到，我们Lua层面读取表格后存入C#里， Lua层面只要传递模型id参数，在C#编码中通过ID也能拿到模型配置，达到优化参数传输
--和编程便利的目的




CustomResNameIndex = CustomResNameIndex or {}
BigMapUIResIndex = BigMapUIResIndex or {}





function CoreDataCache.Init()

	local D = TableDataCache;

	--传入一些Object定义
	D.ObjectType_Buildings = ObjectType_Buildings;
	D.ObjectType_MarchLine = ObjectType_MarchLine;
	D.ObjectType_ResMine = ObjectType_ResMine;
	D.ObjectType_BattleState = ObjectType_BattleState;
	D.ObjectType_OccupyState = ObjectType_OccupyState;	
	D.ObjectType_DungeonLevel = ObjectType_DungeonLevel;

	--初始化颜色表
	D.AddColor(ColorIndex_White, 0.859, 0.855, 0.855 )
	D.AddColor(ColorIndex_Red, 0.914, 0.098, 0.067)
	D.AddColor(ColorIndex_Green, 0.686, 0.965, 0.247)
	D.AddColor(ColorIndex_Yellow, 1, 0.808, 0.047)
	D.AddColor(ColorIndex_Blue, 0.247, 0.767, 0.965)	

	--初始化资源索引
	CustomResNameIndex.MarchLine_White = D.AddResName("marchline_white.prefab")
	CustomResNameIndex.MarchLine_Red = D.AddResName("marchline_red.prefab")
	CustomResNameIndex.MarchLine_Green = D.AddResName("marchline_green.prefab")
	CustomResNameIndex.MarchLine_Yellow = D.AddResName("marchline_yellow.prefab")
	CustomResNameIndex.MarchLine_Blue = D.AddResName("marchline_blue.prefab")
	CustomResNameIndex.TerritoryLine = D.AddResName("AllianceTerritory.prefab")
	
	this.BuildingBattleEffectIndex = D.AddEffectInfo("UIZhandouRed.prefab", "bind_battleflag", ObjectType_BattleState, 1)
	this.NPCBattleEffectIndex = D.AddEffectInfo("UIZhandouGreen.prefab", "bind_head", ObjectType_BattleState, 1)
	this.MineBattleEffectIndex = D.AddEffectInfo("UIZhandouRed.prefab", "bind_battleflag", ObjectType_BattleState, 1)	
	this.EffectProtectIndex = D.AddEffectInfo("Effect_Protect.prefab", "bind_protect", -1)
	this.EffectFireIndex = D.AddEffectInfo("ui_fireburn1.prefab", "bind_effectfire", -1)
	this.EffectAllianceBuildingMain = D.AddEffectInfo("Effect_CJ_B_League_01Build.prefab", "", -1);
	this.EffectAllianceBuildingFlag = D.AddEffectInfo("Effect_CJ_B_TowerBuild.prefab","",-1);
	this.EffectWarFoge = D.AddEffectInfo("EffectWarFoge.prefab", "bind_protect", -1);


	this.BlueOccupyIndex = D.AddEffectInfo("UIBigMapZiyuanPlayerColorBlue.prefab", "bind_occupy", -1, 0, true)
	this.GrayOccupyIndex = D.AddEffectInfo("UIBigMapZiyuanPlayerColorGray.prefab", "bind_occupy", -1, 0, true)
	this.GreenOccupyIndex = D.AddEffectInfo("UIBigMapZiyuanPlayerColorGreen.prefab", "bind_occupy", -1, 0, true)
	this.RedOccupyIndex = D.AddEffectInfo("UIBigMapZiyuanPlayerColorRed.prefab", "bind_occupy", -1, 0, true)
	this.YellowOccupyIndex = D.AddEffectInfo("UIBigMapZiyuanPlayerColorYellow.prefab", "bind_occupy", -1, 0, true)

	--初始化模型表
	local func = function(modelInfo)
		if modelInfo["ResLod0"] ~= nil then
			local res1, res2, resShow;
			if modelInfo["ResLod1"] ~= nil then
				res1 = modelInfo["ResLod1"]..".prefab";
			end
			if modelInfo["ResLod2"] ~= nil then
				res2 = modelInfo["ResLod2"]..".prefab";
			end
			if modelInfo["ResShow"] ~= nil then
				resShow = modelInfo["ResShow"];
			end

			D.AddModelInfo( modelInfo["ID"], modelInfo["ModelType"],
				modelInfo["ResLod0"]..".prefab", res1, res2, resShow,
				modelInfo["BigMapScale"], modelInfo["GridSize"], 
				modelInfo["SizeType"], modelInfo["Model3DSize"] )
		end
	end
	TableManager:Inst():LoopTable(EnumTableID.TabModelID,func)	


	--初始化模型动作表
	local func = function(modelAnimInfo)
		D.SetModelAnimNames(modelAnimInfo.ModelID, modelAnimInfo.AnimMove, modelAnimInfo.AnimIdle, modelAnimInfo.AnimDead,
			modelAnimInfo.AnimAttack, modelAnimInfo.AnimHurt, modelAnimInfo.AnimDefend, modelAnimInfo.AnimMarch, 
			modelAnimInfo.AnimShow, modelAnimInfo.AnimWalk, modelAnimInfo.AnimShowIdle);
	end
	TableManager:Inst():LoopTable( EnumTableID.TabModelAnims, func);

	--初始化大地图UI控件信息
	BigMapUIResIndex.MyCastle = D.AddUIControlInfo("ObjTipsBigMapNpcNew1.prefab","bind_name",eBigMapUIType_eBuildingNameUI) 
	BigMapUIResIndex.OtherCastle = D.AddUIControlInfo("ObjTipsBigMapNpcNew3.prefab","bind_name",eBigMapUIType_eBuildingNameUI)
	BigMapUIResIndex.Mine =  D.AddUIControlInfo("ObjTipsBigMapNpcNew2.prefab","bind_name",eBigMapUIType_eBuildingNameUI) 
	BigMapUIResIndex.NPC =  D.AddUIControlInfo("ObjTipsBigMapNpcNew2.prefab","bind_feet",eBigMapUIType_eNPCNameUI)
	BigMapUIResIndex.March = D.AddUIControlInfo("MarchArmyHeadIcon.prefab", "", eBigMapUIType_eMarchArmyHeadUI)
	BigMapUIResIndex.OnlyName = D.AddUIControlInfo("ObjTipsBigMapNpcNew4.prefab","bind_name",eBigMapUIType_eBuildingNameUI)
	BigMapUIResIndex.GroupMonster =  D.AddUIControlInfo("ObjTipsBigMapNpcNew2.prefab","bind_feet",eBigMapUIType_eNPCNameUI)
	BigMapUIResIndex.City = D.AddUIControlInfo("ObjTipsBigMapNpcNew5.prefab","bind_name",eBigMapUIType_eAllianceCityUI)
end