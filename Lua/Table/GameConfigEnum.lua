----------------------------------------------
-- 统一的游戏配置表枚举
----------------------------------------------

GameConfigEnum = 
{
	eHatreRoundParam	= 1,
	eHatreDamageParam	= 2,
	eHatreSoldierNumberParam = 3,
	eHatreSkillParam		 = 4,	
	eHatreSoldierTypeParam_1 = 5,
	eHatreSoldierTypeParam_2 = 6,
	eHatreSoldierTypeParam_3 = 7,

	eRandShop_InitConsumeValue = 8,
	eRandShop_IncrementConsumeValue = 9,
	eRandShop_Range = 10,
	
	ePveMarchParam = 11,
	ePvpMarchParam = 12,
	ePvpMarchMinTime = 13,
	ePveMarchMaxTime = 14,
	eScoutSpeed = 15,
	eScoutMinTime = 16,
	ePveInitSpeed = 17,
	ePvpInitSpeed = 18,
	eSoliderSpeedParam = 19,
	
	eGeneralLevelOffset = 59,
	eCommonGeneralSoulResId = 60,
	eGeneralMaxLevel = 61,
	ePlayerMaxLevel = 62,

	OpenBoxCostDiamondParams = 69,

	eUnlockBoxSlot4CostDiamond = 70,
	
	ePhyRecySecs = 71,
	ePhyRecyLimit = 72,
	ePhyDrawCountPerDay = 73,
	ePhyDrawIntervalSecs = 74,
	eBuyPhyCountLimit = 75,
	eBuyPhyAdd = 76,
	eDrawPhyAdd = 77,
	eAttackMonsterCostTili = 78,

	eFoodWeightRate=79, --粮食负重比
	eWoodWeightRate=80,--木材负重比
	eStoneWeightRate=81,--石头负重比
	eIronWeightRate=82,--铁负重比
	
	
	eRelivePtCoolDownTime = 101, -- '锡安' 使用冷确时间

	eCopyScenePointBuyPrice = 107,
	eCopyScenePointBuyCount = 108,
	eCopyScenePointRecoverInterval = 109,
	eCopyScenePointRecoverCount = 110,
	eCopyScenePointRecoverMax = 111,
	eCopyScenePointBuyMax = 112,

	eSkillInTime = 114,
	eSkillStayTime = 115,
	eSkillOutTime = 116,
	eHeroIconScaleTime = 117,
	eEquipShopRefreshCost = 126,
	eEquipShopRefreshTime = 127,
	eYunyouExchangeRefreshCost = 128,
	eYunyouExchangeRefreshTime = 129,
	eMaxVipLv = 130,
	eTimingMarchItemId = 131,
	eTimingMarchMoney  = 132,

	eOutFireMoney = 162, --城墙灭火要的钻石
	eRecoveryCityDefPer = 163, --恢复城防每k需要钻石数
	eNameEditItemId 			   = 169,  --修改名称道具id

	eActivityExp     = 170,
	eActivityCount   = 171,
	eMoneyExp        = 172,
	eMoneyCount      = 173,
	eMoneyReward     = 174,
	eContributeCnt   = 175,
	eDailyReward     = 177,
	eActivityReward  = 178,

	eHuntRewardKeep = 135,--寻访奖励物品保持时间
	eHuntExchangePrice = 136, --快捷兑换价格
	eHuntNum = 137, --快捷寻访次数
	eTalentResetDiamond = 140, --重置天赋的钻石数量

	eAllianceDefenseOpenFunction = 190,
	eAllianceDefenseClearCD 	 = 191,

	eAlliancePutOnFireMoney        = 162,  --灭火
	eAllianceBuildingRecoveryMoney = 163,  --恢复

	eAllianceTaskMinMemberCount    = 192,  --开启联盟任务需要的最小人数
	eAllianceCreateAllianceMoneyCnt  = 193, --创建联盟花费的钻石数量
	eAllianceChangeFlagMoneyCnt      = 194, --修改旗帜花费的钻石数量
	eAllianceTaskPersonalPercent     = 195, --联盟任务单人进度上限（百分比）

	eAllianceSkillOpenTime   = 230,
	eAllianceSkillCloseTime = 231,

	eDefenceNumBaseOnBattleCount = 270,

	eAllianceCityOpenDay   = 271,
	eAllianceCityOpenTime  = 272,
	eAllianceCityCloseTime = 273,

	eGlobalBossOpenDay 	   = 290,
	eGlobalBossOpenTime    = 291,
	eGlobalBossCloseTime   = 292,
	eGlobalBossDropId 	   = 293,

	eArenaChallengeLimitCount = 305,
	eArenaPurchaseLimitCount  = 306,
	eArenaChanllengeCost 	  = 307,
	eArenaRefreshItemId 	  = 308,
	eArenaRefreshCost 		  = 309,
	eArenaChallengeInterval   = 310,
	
}

--某些不太确定的
GameConfigScript =
{
	
}
