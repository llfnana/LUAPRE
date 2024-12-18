-------------------------------------------------
Max_BuildingLevel = 60;

--建筑类型
eBuildingType = 
{
	MainTower = 1, --主城
	BuCamp = 2, --步兵营InfantryCamp
	QiCamp = 3, --骑兵营CavalryCamp
	GongCamp = 4, --弓兵营ArcherCamp
	FaCamp = 5, --法师塔MasterTower
	FoodLand = 6, --农场	
	WoodLand = 7, --伐木场
	StoneLand = 8, --采石
	IronLand = 9, --铁矿
	TrainingCamp = 10, --士兵训练营(现在把它当雇佣兵营用了)
	GoldLand = 11, --钻石矿		
	WarHall = 12, --军事大厅
	SpyTower = 13, --侦查塔
	Hospital = 14, --教堂（医院）
	Library = 15, --图书馆（科技）
	EventHall = 16, --活动大厅
	DipHall = 17, -- 外交大厅
	Vendor = 18, --游商
	WareHouse = 19, --仓库 
	CityWall = 20, --城墙
	GuYongBing = 21, --雇佣兵营
	--如果增加类型，请查找其它地方可能有更多的枚举使用更改
	MaxType = 22,
}

---------------------------------------------
--- 光环加成类型
--- 和服务器的ePlayerHaloAddition要对应
---------------------------------------------
ePlayerHaloAddition =
{
	HaloAddition_Building_Ware_Protect = 0,			---仓库保护量加成
	HaloAddition_Building_Hospital_CureNum = 1,		---医院上限加成
	HaloAddition_Building_Produce_Speed_AllRes = 2,	---所有资源生产速度加成
	HaloAddition_BigMap_Gather_Speed_AllRes = 3,	---所有大地图采集资源速度加成
	HaloAddition_Building_Create_LevelUp = 4,	--- 建筑建造和升级时间
}

---------------------------------------------
--- 功能开启ID定义
---------------------------------------------
eFunOpenType = 
{
	FunOpen_HeroTalent = 1; --英雄天赋（英雄等级）
	FunOpen_Alliance = 2; --联盟章节
	FunOpen_FuBen = 3; --副本章节
	FunOpen_Friend = 4; --社交章节
	FunOpen_DragonHoard = 5; --巨龙宝库章节
	FunOpen_Achieve = 6; --成就任务章节
	FunOpen_HeroPxy = 7;--神器开放（英雄等级）
	FunOpen_HeroFuWen = 8;--英雄符文（英雄等级）
	
}

---------------------------------------------
--- 二次确认功能项定义
---------------------------------------------
eEnsureAgainType =
{
	Normal = 1,
	DiscardMine = 2, --舍弃矿区
}


---------------------------------------------
--- 目的地的图标ID
---------------------------------------------
eTargetImgId =
{
	Food 		= 630, --粮田
	Wood 		= 631, --木材	
	Stone 		= 632, --采石
	Iron 		= 633, --铁矿	
	Diamond 	= 634, --钻石
}

eSuperMineImgId =
{
	Food 		= 640, --粮田
	Wood 		= 641, --木材
	Stone 		= 642, --采石
	Iron 		= 643, --铁矿
}

---------------------------------------------
--- 建筑建造/招募等 情况不足的条件
---------------------------------------------
BuildingLimitType =
{
	ItemLimit = 1, --达到最大数量 param( itemId
	BuildingLevelLimit = 2, --依赖建筑等级不够 param( buildingTrueType
	MoneyLimit = 3, --金钱不足  param( moneyType
}


----------------------------------------
EffName_UIMain_FightingValueFirst = "Effect_PowerUpTrail"; -- 主界面战力显示的战力增加特效前半部分
EffName_UIMain_FightingValueSecond = "Effect_MainPowerUp"; -- 主界面战力显示的战力增加特效后半部分
EffName_UIMain_PlayerExpFirst = "Effect_PowerUpTrail"; -- 主界面战力显示的经验增加特效前半部分
EffName_UIMain_PlayerExpSecond = "Effect_MainExp"; -- 主界面经验动画

EffName_UIMain_FirstBuy = "UI_Effect_FirstBuy"; -- 主界面首充

EffName_Home_LevelUp = "ui_CityBuildinglevelup"; -- 升级特效
EffName_Home_Hospital_Cureing = "Effect_Jiaotang_heal_Green"; --医院治疗中
EffName_Home_Hospital_Hurt = "Effect_Jiaotang_heal_redx"; --医院有伤兵 --
EffName_Home_Hospital_Full = "Effect_Jiaotang_heal_Normal"; --医院满兵状态 (如果填了就显示，如果不填就不显示)
--EffName_Home_Hospital_Normal = "Effect_Jiaotang_heal_Normal"; --医院正常状态 (暂时没用)

EffName_Home_Camp_Working_Bu = "Effect_CJ_Infantryman_01_Use"; --步兵营特效
EffName_Home_Camp_Working_Qi = "Effect_CJ_Cavalryman_01_Use"; --骑兵营特效
EffName_Home_Camp_Working_Gong = "Effect_CJ_Archer_01_Use"; --弓箭手营特效
EffName_Home_Camp_Working_Fa = "Effect_FaShiYing"; --法师营特效
EffName_UIHero_HeroRelive = "Effect_HeroFuhuo"; --英雄复活特效(非粒子)
EffName_HeroDetails_StarLevelUp = "ui_herodetail_starlvupBtn"; -- 英雄详情可升星
EffName_HeroDetails_OnStartLevelUp = "ui_herodetail_starlvup"; -- 英雄详情升星完成星星动画
EffName_HeroDetails_HeroLevelUp = "UI_HeroLvUp"; -- 英雄详情升级
EffName_HeroDetails_HeroLevelUpNumber = "UI_HeroLvupNum"; -- 英雄详情升级（字体闪烁一下）
EffName_HeroDetails_TelentLevelUp = "UI_HeroLvUp"; -- 天赋点升级
EffName_HeroDetails_FuWenLevel_3 = "UI_FuwwenLv3"; --符文3级 
EffName_HeroDetails_FuWenLevel_4 = "UI_FuwwenLv4"; --符文3级
EffName_HeroDetails_FuWenLevel_5 = "UI_FuwwenLv5"; --符文3级
EffName_HeroDetails_WearEquip = "UIEffect_ChangeEquip"; -- 更换装备
EffName_Home_OpenLockArea = "UICityFieldUnLockEffect"; --家园未开放土地锁特效
EffName_Home_UnLock_ExistBuilding = "Effect_BuildingLock"; --家园建筑锁定特效
EffName_UIMain_FunOpen = "ui_boxUnLock"; --主界面功能解锁特效

EffName_BtnGreen = "Effect_BtnGreen"; --按钮特效之绿
EffName_BtnBlue = "Effect_BtnBlue"; --按钮特效之蓝色
EffName_BtnYellow = "Effect_BtnYellow"; --按钮特效之黄色

ID_Model_HomeUnOpenLock = "UICityFieldUnLock"; --家园未开放土地锁
ID_Model_HomeGatherTips = "ObjTipsHomeGather"; --家园资源收获时的加多少的特效
ID_Model_HomeCampUnlockNewSoldier = "ObjTipsCampUnlockArmy"; --家园的兵营开启了新兵种

-------------------------------------------------------------
--- 查找路径
------------------------------------------------------------
HomeFindPathStatic = {
	PathGoldLandUnOpenEff = "Effect/Effect_Zhuanshikuang/Close"; --钻石矿未开启时的特效
	PathGoldLandTramcar = "BuildingPos/Building/CJ_zuanshikuang_01"; --钻石矿的小车车

	PathLibIdle = "Effect/Effect_TuShuGuan/Effect_TuShuGuanEmpty", --空闲图书馆
	PathLibBusy = "Effect/Effect_TuShuGuan/Effect_TuShuGuanStart", --工作图书馆
	PathLibFinish = "Effect/Effect_TuShuGuan/Effect_TuShuGuanFinsh", --完成图书馆
}



-------------------------------------------------------------
--- 菜单ID
------------------------------------------------------------
ConstDynamicMenuID = {
	Menu_GoldLand_WorkIng = 1301,--钻石矿详情，收获，续费（已经有卡）--工作状态，当前时间小于等于结束时间
	Menu_GoldLand_WorkEnd = 1302,--钻石矿详情，收获，激活（卡过期了）--工作状态，当前时间大于结束时间（领取完后变成非工作状态）
	Menu_GoldLand_Idle = 1303,--钻石矿详情，激活（没有过卡）--非工作状态
}

---------------------------------------------
--- 最小单位的资源包ID（TabWareStore.txt中每种最小的)，不然每次都要遍历表
---------------------------------------------
eWareStoreNormalPackID =
{
	Food = 250011, --粮食
	Wood = 250021, --木材	
	Stone = 250031, --采石
	Iron = 250041, --铁矿
}

---------------------------------------------
--- 固定的士兵表的ID
---------------------------------------------
ConstSoldierId = {
	SoldierId_Zhan_ShanLingJuRen = 1061, --山岭巨人
	SoldierId_Qi_MengMaQiBing = 2061, --猛犸骑兵
	SoldierId_Gong_FengXingZhe = 3061, --风行
	SoldierId_Fa_NvYao = 4061, --女妖
}

INVALID_ALLIANCE_ID = 0;
INVALID_CHARGUID = 4294967295;


