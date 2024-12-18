require "Table/Table"
EnumTableID =
{
	TabStaticStr = 2,
	TabStrDic = 3,
	UITable = 4,
	TabModelID = 5,
	TabObjectMenu = 6,
	TabSoldierInfo = 7,
	TabBattleMap = 8,
	--TabClientSkill_Deprecated = 9,
	TabBuff = 10,
	TabBullet = 11,
	TabEffect = 12,
	TabSkill = 13,
	TabHomeBuilding = 14,
	TabMonster = 15,
	TabResMine = 16,
	TabBattleData = 17,
	TabHomeDeploy = 18,
	TabMoney = 19,
	TabBuildingSoldier = 20,
	TabBuildingProduce = 21,
	TabItem = 22,
	TabIcon = 23,
	TabGeneral = 24,
	TabGameConfig = 25,
	TabErrorCode  = 26,
	TabGeneralGrowUp = 27,
	TabMoneyExChange = 28,
	TabMission = 29,
	TabSkillModelParam = 30,
	TabBigMapBuilding = 31,
	TabGeneralLevel = 32,
	TabGeneralStarLv = 33,
	TabEquip = 34,
	TabEquipSuite = 35,
	TabSkillEffect = 36,
	TabPlayerBox = 37,
	TabOnlineBox = 38,
	TabFightingCalc = 40,
	CastleLevelParam = 41,
	TabTalent = 42,
	TabTalentLevel = 43,
	TabFuWen = 44,
	TabFuWenSlotParam = 45,
	TabPhyicalBuyCost = 46,
	TabHomeAreaOpen = 47,
	TabBuildingWare = 48,
	TabAudio = 49,
	Task = 50,
	TabWareStore = 51,
	TabBuildingHospital = 52,
	TabFunOpen = 53,
	ActivityBox = 54,
	TabVitality = 55,
	TabCopyZone = 56,
	TabCopyScene = 57,
	TabCopyNpcGroup = 58,
	TabCopySceneMarch = 59,
	TabStrDialouge = 60,
	TabDialogue = 61,
	TabFixedBonusView = 62,
	TabAllianceBuilding = 63,
	TableAllianceDuty = 64,
	TabSuperMine = 65,
	TabBuildingWarHall=66,
	TabItemSwitch = 67,
	TabFlagIcon = 68,
	TabModelAnims = 69,
	TabBusinessData = 70,
	TabPromotion = 71,
	TabAllianceGradeTask = 72,
	TabGuide = 73,
	TabGuideEventTrigger = 74,
	TabAllianceGrade = 75,
	TabDropGradeTask = 76,
	TabStrNotification= 77,
	TabAllianceActivityTask = 78,
	TabAllianceActivityBox = 79,
	TabDropAllianceActivityBox = 80,
	TabCastleDecorate = 81,
	TabMarchSpeedUp = 82,
	TabRecharge = 83,
	TabPlayerLv = 84,
	TabDropBaoXiang = 85,
	TabDropHuoYueDuXiangZi = 86,
	TabDropLiBao = 87,
	TabDropRenWu = 88,
	TabDropYeGuai = 89,
	TabDropZiYuanXiang = 90,
	TabHeadIcon = 91,
	TabAllianceTask = 92,
	TabGrowthFund 	= 93,
	TabEquipShop = 94,
	TabConvertItem 	= 95,
	TabAllianceSkill = 96,
	TabVipPrivilege = 97,
	TabVipShop = 98,
	TabVipLv = 99,
	TabTechnology = 100,
	TabTargetSeven  = 101,
	TabTargetSevenPro  = 102,
	TabGeneralPYX = 103,
	TabSpyTower = 104,
	TabSignIn = 105,
	TabSignInCon = 106,
	TabBuildingCityWall = 107,
	TabMilitaryLv = 108,
	TabAllianceLevel = 109,
	TabCommercial 	 = 110,
	TabAllianceMain  = 111,
	TabMainBuff 	 = 112,
	TabTechnologyBuff = 113, --得读取科技类型用于提示
	TabTimingEffect   = 114, --增益类型
	TabMainBuffDefault= 115,
	TabBuildingMainCity = 116,
	TabDragonBones = 117,
	TabNotify=118,
	TabLoadingTips = 119,
	TabRandomNames = 120,
	TabPurchDiamond = 121,
	TabSensitiveWord = 122,
	TabCityProsper = 123,
	TabCity = 124,
	TabCityLevel = 125,
	TabCityOfficer = 126,

	TabMonsterGroup = 127,
	TabBattleEvent  = 128,
	TabWorldBossReward  = 129,
	TabMassArmyParam 	= 130,
	TabSceneCityShop = 131,
	TabDragonMine = 132, --龙矿
	TabArena 	  = 133,
	TabHeroFetter 	  = 134, --英雄羁绊
	TabEverydayRankTask 	  = 135, --每日排行

	--临时表格临时用，最终不需要
	TabStrDic_ChineseSimplified = 500,
	TabStaticStr_ChineseSimplified = 501,
	TabStrDialouge_ChineseSimplified = 502,
	TabStrNotification_ChineseSimplified = 503,
	TabErrorCode_ChineseSimplified = 504,
	TabRandomNames_ChineseSimplified = 505,
}

---------------------------------
TableLoadState = {}
TableLoadState.AllCnt = 0;
TableLoadState.LoadedCnt = 0;
---------------------------------

-- 表格管理器
TableManager = class("TableManager")

function TableManager:ctor()
	self.TableDic = {}	

end

function TableManager:Inst()
	if nil == self.instance then
		self.instance = TableManager.New();
	end
	
	return self.instance;
end

--获取某个表格对象实例
function TableManager:GetTableInst(TabEnumID)
	return self.TableDic[TabEnumID];
end

--获取某个表格
function TableManager:GetTable(TabEnumID)

	local tab = self.TableDic[TabEnumID];
	local data = tab:GetTable();
	if nil == data then
		error("TableManager:GetTable TabEnumName="..TabEnumID);
	end
	
	return data;
end

-- 是否有某个表格
function TableManager:IsHasTab(TabEnumID)
	local tab = self.TableDic[TabEnumID];
	local data = tab:GetTable();
	return nil ~= data
end

-- 获取一行数据
function TableManager:GetTabData(TabEnumID, id, _ignoreError)
	if TabEnumID == nil then
		error("TableManager:GetTabData TabEnumName is nil");
		return nil;
	end
	
	if id == nil then
		if not _ignoreError then
			local tabFileName = self:GetTableFileNameByTableID(TabEnumID);
			error("[TableManager:GetTabData]获取表格"..tabFileName.."数据失败！数据id=nil");
		end
		return nil;
	end
	
	local tab = self.TableDic[TabEnumID];
	local data = tab:GetTabData(id);
	if nil == data then
		if not _ignoreError then
			local tabFileName = self:GetTableFileNameByTableID(TabEnumID);
			error("[TableManager:GetTabData]获取表格"..tabFileName.."数据失败！数据id="..id);
		end
	end
	return data;
end

-- 获取数据
-- TabName 表的名字
-- id 数据ID
-- des 字段描述
function TableManager:GetTableDataByKey(TabEnumID, id, name)	

	if id == nil then
		local tabFileName = self:GetTableFileNameByTableID(TabEnumID);
		error("[TableManager:GetTableDataByKey] param id is nil! table="..tabFileName)
		return nil;
	end

	if name == nil then
		local tabFileName = self:GetTableFileNameByTableID(TabEnumID);
		error("[TableManager:GetTableDataByKey] param name is nil! table="..tabFileName)
		return nil;		
	end

	local tab = self.TableDic[TabEnumID];
	local data = tab:GetTableDataByKey(id, name);
	if nil == data then
		local tabFileName = self:GetTableFileNameByTableID(TabEnumID);
		error("[TableManager:GetTableDataByKey]获取表格"..tabFileName.."数据失败！数据id="..id.."字段名="..tostring(name));		
	end
	
	return data;
end

-- 根据ID获取多个数据段
function TableManager:GetTableDataByKeyMuti(TabEnumID, id, ...)	
	local tab = self.TableDic[TabEnumID];
	return tab:GetTableDataByKeyMuti(id, ...);
end

-- TabEnumID 表的名字
-- colName 等于此数据名
-- colData 等于此数据的
-- wantColName 这一列的数据
function TableManager:GetTableDataByCol(TabEnumID, colName, colData, wantColName)	
	local tab = self.TableDic[TabEnumID];
	local data = tab:GetTableDataByCol(colName, colData, wantColName);

	if nil == data then
		error("TableManager:GetTabData TabEnumName="..TabEnumID.."  colName=".. colName .." colData="..colData .. " wantColName=" .. wantColName);
	end	
	return data;
end

-- 获取数据
-- TabEnumID 表的名字
-- colName 等于此数据名
-- colData 等于此数据的
-- wantColName 这一列的数据可接多列数据
function TableManager:GetTableDataByColMuti(TabEnumID, colName, colData, ...)	
	local tab = self.TableDic[TabEnumID];
	return tab:GetTableDataByColMuti(colName, colData, ...);

end

-- 遍历table callBack(item)
function TableManager:LoopTable(TabEnumID, callBack)
	local tab = self.TableDic[TabEnumID];
	tab:LoopTable(callBack);
end


function TableManager:ParseTabStr(TabEnumID, id, name)
	
	local tab = self.TableDic[TabEnumID];
	
	local data = tab:GetTableData(id, name);
	
	if data == nil then
		error("TableManager:GetTabData TabEnumName="..TabEnumID.."  TableID="..id.."  Name="..name);
		return nil;
	end

	return stringsplit(data, "|");
end


function TableManager:InitAllTable(_lazyLaod)	

	IsTableLazyLoad = _lazyLaod or false;

	self.beginLoadTableTime = Time.time;
	TableLoadState.AllCnt = table.size(EnumTableID);
	TableLoadState.LoadedCnt = 0;	
	local language = Util.GetLanguage();
	
	log(">>> TableManager: Language=" .. language .. ", start load table...")

	-- self.TableDic[EnumTableID.TabStrDic] = TabStrDic.New("TabStrDic_"..language);
	-- self.TableDic[EnumTableID.TabStaticStr] = TabStaticStr.New("TabStaticStr_"..language);
	 self.TableDic[EnumTableID.TabStrDialouge] = TabStrDialouge.New("TabStrDialouge_"..language);
	-- self.TableDic[EnumTableID.TabRandomNames] = TabRandomNames.New("TabRandomNames_"..language)
	-- self.TableDic[EnumTableID.TabStrNotification] = TabStrNotification.New("TabStrNotification_"..language);
	-- self.TableDic[EnumTableID.TabErrorCode]  = TabErrorCode.New("TabErrorCode_"..language);


	
	self.TableDic[EnumTableID.UITable] = UITable.New("TabUI"); 
    --self.TableDic[EnumTableID.TabModelID] = TabModel.New("TabModel"); 
	-- self.TableDic[EnumTableID.TabObjectMenu] = TabObjectMenu.New("TabObjectMenu"); 	
	-- self.TableDic[EnumTableID.TabSoldierInfo] = TabSoldierInfo.New("SoldierInfo");
	-- self.TableDic[EnumTableID.TabBattleMap] = TabBattleMap.New("BattleMap");
	-- --self.TableDic[EnumTableID.TabClientSkill_Deprecated] = TabClientSkill_Deprecated.New("TabSkillClient");
	-- self.TableDic[EnumTableID.TabBuff] = TabBuff.New("BuffTab");
	-- self.TableDic[EnumTableID.TabBullet] = TabBullet.New("Bullet"); 
	-- self.TableDic[EnumTableID.TabEffect] = TabEffect.New("TabEffect"); 
	-- self.TableDic[EnumTableID.TabSkill] = TabSkill.New("SkillTab");
	-- self.TableDic[EnumTableID.TabHomeBuilding] = TabHomeBuilding.New("TabHomeBuilding"); 
	-- self.TableDic[EnumTableID.TabMonster] = TabMonster.New("monster"); 
	-- self.TableDic[EnumTableID.TabResMine] = TabResMine.New("resmine"); 
	-- self.TableDic[EnumTableID.TabBattleData] = TabBattleData.New("BattleData");
	-- self.TableDic[EnumTableID.TabHomeDeploy] = TabHomeDeploy.New("TabHomeDeploy");	
	-- self.TableDic[EnumTableID.TabMoney] = TabMoney.New("TabMoney");
	-- self.TableDic[EnumTableID.TabBuildingSoldier] = TabBuildingSoldier.New("TabBuildingSoldier");
	-- self.TableDic[EnumTableID.TabBuildingProduce] = TabBuildingProduce.New("TabBuildingProduce");
	-- self.TableDic[EnumTableID.TabItem] = TabItem.New("Item");
	self.TableDic[EnumTableID.TabIcon] = TabIcon.New("TabIcon");
	--self.TableDic[EnumTableID.TabGeneral] = TabGeneral.New("GeneralTab");
	--self.TableDic[EnumTableID.TabGameConfig] = TabGameConfig.New("GameConfig");
	
	-- self.TableDic[EnumTableID.TabGeneralGrowUp] = TabGeneralGrowUp.New("GeneralGrowUpTab");
	-- self.TableDic[EnumTableID.TabMoneyExChange] = TabMoneyExChange.New("TabMoneyExChange");
	-- self.TableDic[EnumTableID.TabMission] = TabMission.New("TabMission");
	-- self.TableDic[EnumTableID.TabSkillModelParam] = TabSkillModelParam.New("SkillModelParam");
	-- self.TableDic[EnumTableID.TabBigMapBuilding] = TabBigMapBuilding.New("TabBigMapBuilding");	
	-- self.TableDic[EnumTableID.TabGeneralLevel] = TabGeneralLevel.New("GeneralLevel");	
	-- self.TableDic[EnumTableID.TabGeneralStarLv] = TabGeneralStarLv.New("GeneralStarLv");
	-- self.TableDic[EnumTableID.TabEquip] = TabEquip.New("Equip");
	-- self.TableDic[EnumTableID.TabEquipSuite] = TabEquipSuite.New("EquipSuite");
	-- self.TableDic[EnumTableID.TabSkillEffect] = TabSkillEffect.New("SkillEffect");
	-- self.TableDic[EnumTableID.TabPlayerBox] = TabPlayerBox.New("PlayerBox");
	-- self.TableDic[EnumTableID.TabOnlineBox] = TabOnlineBox.New("OnlineBox");
	-- self.TableDic[EnumTableID.TabFightingCalc] = TabFightingCalc.New("FightingCalc");
	-- self.TableDic[EnumTableID.CastleLevelParam] = CastleLevelParam.New("CastleLevelParam");
	-- self.TableDic[EnumTableID.TabTalent] = TabTalent.New("Talent");
	-- self.TableDic[EnumTableID.TabTalentLevel] = TabTalentLevel.New("TalentLevel");
	-- self.TableDic[EnumTableID.TabFuWen] = TabFuWen.New("FuWen");
	-- self.TableDic[EnumTableID.TabFuWenSlotParam] = TabFuWenSlotParam.New("FuWenSlotParam");
	-- self.TableDic[EnumTableID.TabPhyicalBuyCost] = PhyicalBuyCost.New("PhyicalBuyCost");
	-- self.TableDic[EnumTableID.TabHomeAreaOpen] = TabHomeAreaOpen.New("TabHomeAreaOpen");
	-- self.TableDic[EnumTableID.TabBuildingWare] = TabBuildingWare.New("TabBuildingWare");
	self.TableDic[EnumTableID.TabAudio] = TabAudio.New("TabAudio");
	-- self.TableDic[EnumTableID.Task] = Task.New("Task");
	-- self.TableDic[EnumTableID.TabWareStore] = TabWareStore.New("TabWareStore");
	-- self.TableDic[EnumTableID.TabBuildingHospital] = TabWareStore.New("TabBuildingHospital");
	-- self.TableDic[EnumTableID.TabFunOpen] = TabFunOpen.New("TabFunOpen");
	-- self.TableDic[EnumTableID.ActivityBox] = ActivityBox.New("ActivityBox");
	-- self.TableDic[EnumTableID.TabVitality] = TabVitality.New("TabVitality");
	-- self.TableDic[EnumTableID.TabCopyZone] = TabCopyZone.New("CopyZone");
	--self.TableDic[EnumTableID.TabCopyScene] = TabCopyScene.New("CopyScene");
	-- self.TableDic[EnumTableID.TabCopyNpcGroup] = TabCopyNpcGroup.New("CopyNpcGroup");
	-- self.TableDic[EnumTableID.TabCopySceneMarch] = TabCopySceneMarch.New("CopySceneMarch");
	 self.TableDic[EnumTableID.TabDialogue] = TabDialogue.New("TabDialogue");
	-- self.TableDic[EnumTableID.TabFixedBonusView] = TabFixedBonusView.New("FixedBonusView");
	-- self.TableDic[EnumTableID.TabAllianceBuilding] = TabAllianceBuilding.New("AllianceBuilding")
	-- self.TableDic[EnumTableID.TableAllianceDuty] = TableAllianceDuty.New("AllianceDuty");
	-- self.TableDic[EnumTableID.TabSuperMine] = TabSuperMine.New("supermine")
	-- self.TableDic[EnumTableID.TabBuildingWarHall] = TabWareStore.New("TabBuildingWarHall");
	-- self.TableDic[EnumTableID.TabItemSwitch] = TabItemSwitch.New("ItemSwitch");
	-- self.TableDic[EnumTableID.TabFlagIcon] = TabFlagIcon.New("TabFlagIcon");
	-- self.TableDic[EnumTableID.TabModelAnims] = TabModelAnims.New("TabModelAnims");
	-- self.TableDic[EnumTableID.TabBusinessData] = TabBusinessData.New("BusinessData");
	-- self.TableDic[EnumTableID.TabPromotion] = TabPromotion.New("Promotion");
	-- self.TableDic[EnumTableID.TabAllianceGradeTask] = TabAllianceGradeTask.New("AllianceGradeTask");
	-- self.TableDic[EnumTableID.TabGuide] = TabGuide.New("TabGuide");
	-- self.TableDic[EnumTableID.TabGuideEventTrigger] = TabGuideEventTrigger.New("TabGuideEventTrigger");
	-- self.TableDic[EnumTableID.TabAllianceGrade] = TabAllianceGrade.New("AllianceGrade");   --TabDropGradeTask
	-- self.TableDic[EnumTableID.TabDropGradeTask] = TabDropGradeTask.New("DropGradeTask");
	
	-- self.TableDic[EnumTableID.TabAllianceActivityTask] = TabAllianceActivityTask.New("AllianceActivityTask");
	-- self.TableDic[EnumTableID.TabAllianceActivityBox] = TabAllianceActivityBox.New("AllianceActivityBox"); 
	-- self.TableDic[EnumTableID.TabDropAllianceActivityBox] = TabDropAllianceActivityBox.New("DropAllianceActivityBox");
	-- self.TableDic[EnumTableID.TabCastleDecorate] = TabCastleDecorate.New("CastleDecorate")
	-- self.TableDic[EnumTableID.TabMarchSpeedUp] = TabMarchSpeedUp.New("MarchSpeedUp")
	-- self.TableDic[EnumTableID.TabRecharge] = TabRecharge.New( self:GetRechargeTableFileName() )
	-- self.TableDic[EnumTableID.TabPlayerLv] = TabPlayerLv.New("PlayerLv")
	-- self.TableDic[EnumTableID.TabDropBaoXiang] = TabDropBaoXiang.New("DropBaoXiang")
	-- self.TableDic[EnumTableID.TabDropHuoYueDuXiangZi] = TabDropHuoYueDuXiangZi.New("DropHuoYueDuXiangZi")
	-- self.TableDic[EnumTableID.TabDropLiBao] = TabDropLiBao.New("DropLiBao")
	-- self.TableDic[EnumTableID.TabDropRenWu] = TabDropRenWu.New("DropRenWu")
	-- self.TableDic[EnumTableID.TabDropYeGuai] = TabDropYeGuai.New("DropYeGuai")
	-- self.TableDic[EnumTableID.TabDropZiYuanXiang] = TabDropZiYuanXiang.New("DropZiYuanXiang")
	-- self.TableDic[EnumTableID.TabHeadIcon] = TabHeadIcon.New("TabHeadIcon")
	-- self.TableDic[EnumTableID.TabAllianceTask] = TabAllianceTask.New("AllianceTask")
	-- self.TableDic[EnumTableID.TabEquipShop] = TabEquipShop.New("EquipShop")
	-- self.TableDic[EnumTableID.TabGrowthFund] = TabGrowthFund.New("GrowthFund")
	-- self.TableDic[EnumTableID.TabConvertItem] = TabConvertItem.New("ConvertItem")
	-- self.TableDic[EnumTableID.TabAllianceSkill] = TabAllianceSkill.New("AllianceSkill")
	-- self.TableDic[EnumTableID.TabVipPrivilege] = TabVipPrivilege.New("VipPrivilege")
	-- self.TableDic[EnumTableID.TabVipShop] = TabVipShop.New("VipShop")
	-- self.TableDic[EnumTableID.TabVipLv] = TabVipLv.New("VipLv")
	-- self.TableDic[EnumTableID.TabTechnology] = TabTechnology.New("Technology")
	-- self.TableDic[EnumTableID.TabTargetSeven] = TabTargetSeven.New("Target7")
    -- self.TableDic[EnumTableID.TabTargetSevenPro] = TabTargetSevenPro.New("Target7Pro")
    -- self.TableDic[EnumTableID.TabGeneralPYX] = TabGeneralPYX.New("GeneralPYX");
    -- self.TableDic[EnumTableID.TabSpyTower] = TabSpyTower.New("TabBuildingSpyTower");
    -- self.TableDic[EnumTableID.TabSignIn] = TabSpyTower.New("signin");
    -- self.TableDic[EnumTableID.TabSignInCon] = TabSpyTower.New("signincon");
	-- self.TableDic[EnumTableID.TabBuildingCityWall] = TabBuildingCityWall.New("TabBuildingCityWall");
	-- self.TableDic[EnumTableID.TabMilitaryLv] = TabMilitaryLv.New("MilitaryLv");
	-- self.TableDic[EnumTableID.TabAllianceLevel] = TabAllianceLevel.New("AllianceLevel");
	-- self.TableDic[EnumTableID.TabCommercial] = TabCommercial.New("TabCommercial");
	-- self.TableDic[EnumTableID.TabAllianceMain] = TabAllianceMain.New("AllianceMain");
	-- self.TableDic[EnumTableID.TabMainBuff] = TabMainBuff.New("TabMainBuff");
	-- self.TableDic[EnumTableID.TabTechnologyBuff] = TabTechnologyBuff.New("TechnologyBuff");
	-- self.TableDic[EnumTableID.TabTimingEffect] = TabTimingEffect.New("TimingEffect");
	-- self.TableDic[EnumTableID.TabMainBuffDefault] = TabMainBuffDefault.New("TabMainBuffDefault");
	-- self.TableDic[EnumTableID.TabBuildingMainCity] = TabBuildingMainCity.New("TabBuildingMainCity");	
	-- self.TableDic[EnumTableID.TabDragonBones] = TabDragonBones.New("TabDragonBones");
	-- self.TableDic[EnumTableID.TabNotify] = TabNotify.New("TabNotify");
	-- self.TableDic[EnumTableID.TabLoadingTips] = TabLoadingTips.New("TabLoadingTips");
	-- self.TableDic[EnumTableID.TabPurchDiamond] = TabPurchDiamond.New("PurchDiamond");
	-- self.TableDic[EnumTableID.TabSensitiveWord] = TabSensitiveWord.New("TabSensitiveWord");
	-- self.TableDic[EnumTableID.TabCityProsper] = TabCityProsper.New("SceneCityProsper");
	-- self.TableDic[EnumTableID.TabCity] = TabCity.New("SceneCityTab");
	-- self.TableDic[EnumTableID.TabCityLevel] = TabCityLevel.New("SceneCityLevel");
	-- self.TableDic[EnumTableID.TabMonsterGroup] = TabMonsterGroup.New("MonsterGroup");
	-- self.TableDic[EnumTableID.TabBattleEvent] = TabBattleEvent.New("BattleEvent");
	-- self.TableDic[EnumTableID.TabCityOfficer] = TabCityOfficer.New("SceneCityOfficer");
	-- self.TableDic[EnumTableID.TabWorldBossReward] = TabWorldBossReward.New("WorldBossReward");
	-- self.TableDic[EnumTableID.TabMassArmyParam] = TabMassArmyParam.New("MassArmyParam");
	-- self.TableDic[EnumTableID.TabSceneCityShop] = TabSceneCityShop.New("SceneCityShop");
	-- self.TableDic[EnumTableID.TabDragonMine] = TabDragonMine.New("dragonmine");
	-- self.TableDic[EnumTableID.TabArena] = TabArena.New("Arena");
	-- self.TableDic[EnumTableID.TabHeroFetter] = TabHeroFetter.New("HeroFetter");
	-- self.TableDic[EnumTableID.TabEverydayRankTask] = TabEverydayRankTask.New("EverydayRankTask");
	
	self:ReloadLanguageTab();

end

function TableManager:GetTableFileNameByTableID( _tableId )
	local tableInst = self.TableDic[_tableId]
	if tableInst == nil then
		error("[TableManager:GetTableFileNameByTableID] invalid tableid=".._tableId);
		return "";
	end
	return tableInst:GetFileName();
end



function TableManager:OnSingleTableLoad( szName )
	TableLoadState.LoadedCnt = TableLoadState.LoadedCnt + 1;
	log("single table load : " .. szName .. " CurLoad=" .. TableLoadState.LoadedCnt.."/"..TableLoadState.AllCnt)

	--所有表格加载完毕
	if(TableLoadState.LoadedCnt == TableLoadState.AllCnt) then
		local costTime = Time.time - self.beginLoadTableTime;
		log(">>> TableManager: all single table load ok, count=" ..TableLoadState.AllCnt..",costtime="..costTime)

		if not IsTableLazyLoad then
			Game.OnAllTableLoad();
		end
	end
end

-- 所有语言相关表格放到这里加载
function TableManager:ReloadLanguageTab()
	
	local language = Util.GetLanguage();
	if language == nil or language == "" then
		return;
	end

	log("!>>> TableManager: ReloadLanguageTab, Language="..language);
	self.TableDic[EnumTableID.TabStrDic] = TabStrDic.New("TabStrDic_" .. language);
	--self.TableDic[EnumTableID.TabStaticStr] = TabStaticStr.New("TabStaticStr_" .. language);	
	 self.TableDic[EnumTableID.TabStrDialouge] = TabStrDialouge.New("TabStrDialouge_"..language);
	-- self.TableDic[EnumTableID.TabErrorCode] = TabErrorCode.New("TabErrorCode_"..language);
	-- self.TableDic[EnumTableID.TabStrNotification] = TabStrNotification.New("TabStrNotification_"..language);
	-- self.TableDic[EnumTableID.TabRandomNames] = TabRandomNames.New("TabRandomNames_"..language)

	-- if language == "ChineseSimplified" then
	-- 	GameStateData.IsChineseSimplified = true;

	-- 	self.TableDic[EnumTableID.TabStrDic_ChineseSimplified] = self.TableDic[EnumTableID.TabStrDic]
	 	self.TableDic[EnumTableID.TabStrDialouge_ChineseSimplified] = self.TableDic[EnumTableID.TabStrDialouge]
	-- 	self.TableDic[EnumTableID.TabStrNotification_ChineseSimplified] = self.TableDic[EnumTableID.TabStrNotification]
	-- 	self.TableDic[EnumTableID.TabStaticStr_ChineseSimplified] = self.TableDic[EnumTableID.TabStaticStr]
	-- 	self.TableDic[EnumTableID.TabErrorCode_ChineseSimplified] = self.TableDic[EnumTableID.TabErrorCode]
	-- 	self.TableDic[EnumTableID.TabRandomNames_ChineseSimplified] = self.TableDic[EnumTableID.TabRandomNames]
	
	-- else
	-- 	GameStateData.IsChineseSimplified = false;

	-- 	--临时解决方案: 当使用其他语言时，加载一份中文简体的表，如果在当前表里找不到字符串，使用中文简体表
	-- 	self.TableDic[EnumTableID.TabStrDic_ChineseSimplified] = TabStrDic_ChineseSimplified.New("TabStrDic_ChineseSimplified");
	 	self.TableDic[EnumTableID.TabStrDialouge_ChineseSimplified] = TabStrDialouge_ChineseSimplified.New("TabStrDialouge_ChineseSimplified");
	-- 	self.TableDic[EnumTableID.TabStrNotification_ChineseSimplified] = TabStrNotification_ChineseSimplified.New("TabStrNotification_ChineseSimplified");
	-- 	self.TableDic[EnumTableID.TabStaticStr_ChineseSimplified] = TabStaticStr_ChineseSimplified.New("TabStaticStr_ChineseSimplified");
	-- 	self.TableDic[EnumTableID.TabErrorCode_ChineseSimplified] = TabErrorCode_ChineseSimplified.New("TabErrorCode_ChineseSimplified");
	-- 	self.TableDic[EnumTableID.TabRandomNames_ChineseSimplified] = TabRandomNames_ChineseSimplified.New("TabRandomNames_ChineseSimplified");		
	-- 	self.TableDic[EnumTableID.TabRandomNames_ChineseSimplified] = TabRandomNames_ChineseSimplified.New("TabRandomNames_ChineseSimplified");							
	-- end
end



function TableManager:LoadTable( tabEnumId )
	self.TableDic[tabEnumId]:CheckLoad();
end

--不同包读取不同的充值表
function TableManager:GetRechargeTableFileName()

		return "Recharge";

end