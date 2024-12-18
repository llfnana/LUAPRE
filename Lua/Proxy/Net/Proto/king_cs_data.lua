local zd = require("Proxy.NetBase.Data.Data")
local function GetKingDataRequire(flag, inputTarget)
    local makerSC = {}
    local makerCS = {}
    makerSC = require("Proxy.Net.Proto.king_sc_data")
    makerCS = flag and require("Proxy.Net.Proto.king_cs_data")
    return makerSC, makerCS
end
local makerSC,_ = GetKingDataRequire(false)
----------------------------SplitByYuki---------------------------------

local _KeyMaps = {
	shop="CST_CS_Shop",
	map="CST_CS_Map",
	story="CST_CS_Story",
	hero="CST_CS_Hero",
	gm="CST_CS_GM",
	order="CST_CS_Order",
	item="CST_CS_Item",
	gameMachine="CST_CS_GameMachine",
	user="CST_CS_User",
	recode="CST_CS_Code",
	mail="CST_CS_Mail",
	login="CST_CS_Login",
	guide="CST_CS_Guide",
}

local maker = {}
maker.CST_SC_Ranking = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"beast",zd.makeLiteArray(makerSC.SCT_fUserInfo()))
	zd.initLiteSet(obj,"clubKua",zd.makeLiteArray(makerSC.SCT_SClubList()))
	zd.initLiteSet(obj,"clubKuaYueMyScore",maker.CST_SC_RankComMyClub())
	zd.initLiteSet(obj,"clubKuaYueMyScoreLast",maker.CST_SC_RankComMyClub())
	zd.initLiteSet(obj,"clubKuaYueScore",zd.makeLiteArray(makerSC.SCT_SC_RankComClub()))
	zd.initLiteSet(obj,"clubKuaYueScoreLast",zd.makeLiteArray(makerSC.SCT_SC_RankComClub()))
	zd.initLiteSet(obj,"clubkuajf",zd.makeLiteArray(makerSC.SCT_SCclubkuajf()))
	zd.initLiteSet(obj,"country",zd.makeLiteArray("RankCountry"))
	zd.initLiteSet(obj,"guanka",zd.makeLiteArray(makerSC.SCT_fUserInfo()))
	zd.initLiteSet(obj,"heroKua",zd.makeLiteArray(makerSC.SCT_fHeroData()))
	zd.initLiteSet(obj,"huali",zd.makeLiteArray("ComUserEasyDataRank"))
	zd.initLiteSet(obj,"liangchen",zd.makeLiteArray(makerSC.SCT_LiangchenInfo()))
	zd.initLiteSet(obj,"love",zd.makeLiteArray(makerSC.SCT_fUserInfo()))
	zd.initLiteSet(obj,"mobai",maker.CST_MoBaiMsg())
	zd.initLiteSet(obj,"myHuali",maker.CST_ComMyRank())
	zd.initLiteSet(obj,"myclubkuaRid",maker.CST_SCclubkuajf())
	zd.initLiteSet(obj,"selfRid",maker.CST_SelfRids())
	zd.initLiteSet(obj,"shili",zd.makeLiteArray(makerSC.SCT_fUserInfo()))
	zd.initLiteSet(obj,"shiliKua",zd.makeLiteArray(makerSC.SCT_fUserInfo()))
	zd.initLiteSet(obj,"showListNum",maker.CST_RankShowListNum())
	zd.initLiteSet(obj,"win",maker.CST_RankingWin())
	return obj
end

maker.CST_GameMachineResult = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"position",0)
	zd.initLiteSet(obj,"train",zd.makeLiteArray(makerSC.SCT_GameMachineTrain()))
	return obj
end

maker.CST_hd748ExchangeParams = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_ScLjzxRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_IDCOUNT()))
	zd.initLiteSet(obj,"need",0)
	return obj
end

maker.CST_Sc2048Score = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_CS_Hd786Count = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	return obj
end

maker.CST_CS_Code = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"exchange",maker.CST_CodeMsg())
	return obj
end

maker.CST_JdymGetRank = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",1)
	return obj
end

maker.CST_CS_Hd760Sevid = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"sevid",0)
	return obj
end

maker.CST_SC_Hdxxl = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"XxlDayRwd",maker.CST_ScXxlDayRwd())
	zd.initLiteSet(obj,"XxlExchange",zd.makeLiteArray(makerSC.SCT_ScXxlShop()))
	zd.initLiteSet(obj,"XxlRank",zd.makeLiteArray(makerSC.SCT_Scblist()))
	zd.initLiteSet(obj,"XxlShop",zd.makeLiteArray(makerSC.SCT_ScXxlShop()))
	zd.initLiteSet(obj,"XxlTi",maker.CST_ScXxlTi())
	zd.initLiteSet(obj,"info",maker.CST_ScXxlInfo())
	zd.initLiteSet(obj,"myXxlRid",maker.CST_Scbrid())
	return obj
end

maker.CST_Srorder = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"age_default","")
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"payflag","")
	zd.initLiteSet(obj,"recharge",1)
	zd.initLiteSet(obj,"servid",0)
	zd.initLiteSet(obj,"set_age",0)
	return obj
end

maker.CST_SevenSignRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_ScXxlTi = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"label",0)
	zd.initLiteSet(obj,"rTime",0)
	zd.initLiteSet(obj,"st",0)
	return obj
end

maker.CST_HeroSkinNews = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"ghs",0)
	zd.initLiteSet(obj,"hid",0)
	zd.initLiteSet(obj,"skills",0)
	return obj
end

maker.CST_ModifyPwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"acc","")
	zd.initLiteSet(obj,"new","")
	zd.initLiteSet(obj,"old","")
	return obj
end

maker.CST_MyKuaYamenRank = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"isHe",0)
	zd.initLiteSet(obj,"myName","")
	zd.initLiteSet(obj,"myScore",0)
	zd.initLiteSet(obj,"myScorerank",0)
	zd.initLiteSet(obj,"sid",0)
	return obj
end

maker.CST_CS_Hd390ScoreRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"pos",0)
	return obj
end

maker.CST_DxUser = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"lq",0)
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_SC_RandWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"win",maker.CST_WinRandWin())
	return obj
end

maker.CST_labelId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"label","")
	zd.initLiteSet(obj,"ver",0)
	return obj
end

maker.CST_ScKuom = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cpneed",zd.makeLiteArray(makerSC.SCT_cqcp()))
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"jstype",0)
	zd.initLiteSet(obj,"neednum",0)
	return obj
end

maker.CST_XianShiAct = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"begintime",0)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"endtime",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_XianShiRwd()))
	zd.initLiteSet(obj,"rwdid",0)
	return obj
end

maker.CST_fUserInfo2 = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"beijing",0)
	zd.initLiteSet(obj,"chenghao",0)
	zd.initLiteSet(obj,"dress",0)
	zd.initLiteSet(obj,"dress_state",0)
	zd.initLiteSet(obj,"duanwei",0)
	zd.initLiteSet(obj,"extra_ch","")
	zd.initLiteSet(obj,"guajian",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"job",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"maxmap",0)
	zd.initLiteSet(obj,"mingrenchenghao",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"num2",0)
	zd.initLiteSet(obj,"num3",0)
	zd.initLiteSet(obj,"password","")
	zd.initLiteSet(obj,"pet_addi",0)
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"riskexp",0)
	zd.initLiteSet(obj,"risklevel",0)
	zd.initLiteSet(obj,"savelimit",0)
	zd.initLiteSet(obj,"sex",0)
	zd.initLiteSet(obj,"signName","")
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"suoding",0)
	zd.initLiteSet(obj,"uid",0)
	zd.initLiteSet(obj,"vip",0)
	return obj
end

maker.CST_SCSevenDaySign = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_SCSevenDaySignList()))
	zd.initLiteSet(obj,"state",2)
	return obj
end

maker.CST_SC_Chat = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"backDetailList",zd.makeLiteArray(makerSC.SCT_FuserData()))
	zd.initLiteSet(obj,"blacklist",zd.makeLiteArray(makerSC.SCT_FuserData()))
	zd.initLiteSet(obj,"club",zd.makeLiteArray(makerSC.SCT_ChatMsgInfo()))
	zd.initLiteSet(obj,"country",zd.makeLiteArray(makerSC.SCT_ChatMsgInfo()))
	zd.initLiteSet(obj,"kuafu",zd.makeLiteArray(makerSC.SCT_ChatMsgInfo()))
	zd.initLiteSet(obj,"mjds_club_chat",zd.makeLiteArray(makerSC.SCT_ChatMsgInfo()))
	zd.initLiteSet(obj,"mjds_huodong_chat",zd.makeLiteArray(makerSC.SCT_ChatMsgInfo()))
	zd.initLiteSet(obj,"pao",zd.makeLiteArray(makerSC.SCT_PaoMsgInfo()))
	zd.initLiteSet(obj,"punish",zd.makeLiteArray(makerSC.SCT_ChatPunish()))
	zd.initLiteSet(obj,"sev",zd.makeLiteArray(makerSC.SCT_ChatMsgInfo()))
	zd.initLiteSet(obj,"targetLanguage",maker.CST_targetLanguageCode())
	return obj
end

maker.CST_ScXxlDayRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day_integ",0)
	zd.initLiteSet(obj,"isGet",zd.makeLiteArray(makerSC.SCT_ScXxlDayRwdID()))
	return obj
end

maker.CST_cqcp = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_RankingWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"heromobai",maker.CST_fHeroInfo())
	zd.initLiteSet(obj,"liangchen",maker.CST_LiangchenInfo())
	zd.initLiteSet(obj,"mobai",maker.CST_FuserData())
	return obj
end

maker.CST_Cshd407All = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",maker.CST_Null())
	return obj
end

maker.CST_Scbosspkwin1 = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"gx",0)
	zd.initLiteSet(obj,"hit",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_MingWang = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"eday",0)
	zd.initLiteSet(obj,"maxmw",0)
	zd.initLiteSet(obj,"mw",0)
	return obj
end

maker.CST_ScRankUpInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"aRankId",0)
	zd.initLiteSet(obj,"bRankId",0)
	return obj
end

maker.CST_QxWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"gift",maker.CST_CShd434Play())
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"lamp",maker.CST_QxWinLamp())
	return obj
end

maker.CST_Hd263getRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_hd238ChatParams = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"msg","")
	return obj
end

maker.CST_SsetUSocialDress = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type","")
	return obj
end

maker.CST_CShd334Set = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",1)
	return obj
end

maker.CST_sc_sevendaytask_list = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"pro",0)
	zd.initLiteSet(obj,"status",0)
	return obj
end

maker.CST_CSLjzxRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CsRiskGetBaozang = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"x",0)
	zd.initLiteSet(obj,"y",0)
	return obj
end

maker.CST_BlackId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buid",0)
	return obj
end

maker.CST_CS_hd595Get = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CS_StoryClickBtn = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"btnId",0)
	zd.initLiteSet(obj,"storyId",0)
	zd.initLiteSet(obj,"storyZid",0)
	return obj
end

maker.CST_CS_WordBoss = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"comebackg2d",maker.CST_heroId())
	zd.initLiteSet(obj,"comebackg2dBatch",maker.CST_Null())
	zd.initLiteSet(obj,"comebackmg",maker.CST_heroId())
	zd.initLiteSet(obj,"comebackmgBatch",maker.CST_Null())
	zd.initLiteSet(obj,"g2dHitRank",maker.CST_Null())
	zd.initLiteSet(obj,"goFightg2d",maker.CST_Null())
	zd.initLiteSet(obj,"goFightmg",maker.CST_Null())
	zd.initLiteSet(obj,"hitgeerdan",maker.CST_heroId())
	zd.initLiteSet(obj,"hitmenggu",maker.CST_heroId())
	zd.initLiteSet(obj,"oneKeymenggu",maker.CST_Null())
	zd.initLiteSet(obj,"scoreRank",maker.CST_Null())
	zd.initLiteSet(obj,"shopBuy",maker.CST_WordShopId())
	zd.initLiteSet(obj,"wordboss",maker.CST_Null())
	return obj
end

maker.CST_SCSystemNotice = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"m","")
	zd.initLiteSet(obj,"s",1)
	zd.initLiteSet(obj,"t",1)
	return obj
end

maker.CST_HitMgwinWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bo",1)
	zd.initLiteSet(obj,"damage",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"score2",0)
	return obj
end

maker.CST_Svipexp = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"recharge",0)
	return obj
end

maker.CST_CShd365Pre = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dc",0)
	return obj
end

maker.CST_SCclubKualooklog = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid",0)
	zd.initLiteSet(obj,"fcid",0)
	zd.initLiteSet(obj,"fname","")
	zd.initLiteSet(obj,"fpower",0)
	zd.initLiteSet(obj,"fservid",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"pktime",0)
	zd.initLiteSet(obj,"power",0)
	zd.initLiteSet(obj,"servid",0)
	zd.initLiteSet(obj,"win",0)
	return obj
end

maker.CST_sc_newcjyxexchange_list = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"is_limit",0)
	zd.initLiteSet(obj,"items",maker.CST_ItemInfo())
	zd.initLiteSet(obj,"limit",0)
	zd.initLiteSet(obj,"need",0)
	return obj
end

maker.CST_SC_RISK = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"baozang",zd.makeLiteArray(makerSC.SCT_RiskBaoZang()))
	zd.initLiteSet(obj,"biaoxian",maker.CST_RiskBiaoxian())
	zd.initLiteSet(obj,"bossinfo",maker.CST_Riskbossinfo())
	zd.initLiteSet(obj,"bosslist",zd.makeLiteArray(makerSC.SCT_RiskBosslist()))
	zd.initLiteSet(obj,"createNpc",zd.makeLiteArray(makerSC.SCT_RiskCreateNpc()))
	zd.initLiteSet(obj,"darts",zd.makeLiteArray(makerSC.SCT_RiskDartsList()))
	zd.initLiteSet(obj,"exchange",maker.CST_RiskExchange())
	zd.initLiteSet(obj,"finished_task",zd.makeLiteArray(makerSC.SCT_RiskFinishedTaskList()))
	zd.initLiteSet(obj,"follow",zd.makeLiteArray(makerSC.SCT_RiskFollow()))
	zd.initLiteSet(obj,"hadeClean",zd.makeLiteArray(makerSC.SCT_RiskMap()))
	zd.initLiteSet(obj,"info",maker.CST_riskLevelInfo())
	zd.initLiteSet(obj,"jiguan",zd.makeLiteArray(makerSC.SCT_RiskJiguan()))
	zd.initLiteSet(obj,"map",zd.makeLiteArray(makerSC.SCT_RiskMap()))
	zd.initLiteSet(obj,"map_cd",zd.makeLiteArray(makerSC.SCT_RiskMapCd()))
	zd.initLiteSet(obj,"mid",maker.CST_RiskMapid())
	zd.initLiteSet(obj,"mwlist",zd.makeLiteArray(makerSC.SCT_RiskMwlist()))
	zd.initLiteSet(obj,"mysteryShop",maker.CST_MysteryShop())
	zd.initLiteSet(obj,"nowXy",maker.CST_RiskMapNow())
	zd.initLiteSet(obj,"npcFavorability",zd.makeLiteArray(makerSC.SCT_NpcFavorability()))
	zd.initLiteSet(obj,"play",maker.CST_RiskBossDetail())
	zd.initLiteSet(obj,"playStory",maker.CST_RiskStory())
	zd.initLiteSet(obj,"power",maker.CST_RiskPower())
	zd.initLiteSet(obj,"shoplist",zd.makeLiteArray(makerSC.SCT_RiskShoplist()))
	zd.initLiteSet(obj,"suiji_item",zd.makeLiteArray(makerSC.SCT_Risksuiji_item()))
	zd.initLiteSet(obj,"task",zd.makeLiteArray(makerSC.SCT_RiskTaskList()))
	zd.initLiteSet(obj,"texiao",zd.makeLiteArray(makerSC.SCT_Risktexiaolist()))
	zd.initLiteSet(obj,"unlock",maker.CST_riskUnlock())
	zd.initLiteSet(obj,"up_baozang",maker.CST_RiskUpBaoZang())
	zd.initLiteSet(obj,"up_map",zd.makeLiteArray(makerSC.SCT_RiskMap()))
	zd.initLiteSet(obj,"up_task",zd.makeLiteArray(makerSC.SCT_RiskTaskList()))
	zd.initLiteSet(obj,"win",maker.CST_Riskbossxianqing())
	return obj
end

maker.CST_CclubPwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"password","")
	return obj
end

maker.CST_SC_FourGoodNoticeContent = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"content","")
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_BHCZHDCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_Shdrwd1()))
	return obj
end

maker.CST_ParamType = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CsriskgetBossInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bossid",0)
	return obj
end

maker.CST_khero = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_Risksuiji_item = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"kind",0)
	zd.initLiteSet(obj,"zb",0)
	return obj
end

maker.CST_RiskMwlist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"mtype",0)
	zd.initLiteSet(obj,"x",0)
	zd.initLiteSet(obj,"y",0)
	return obj
end

maker.CST_ScLjzxInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"gRwd","")
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_ScLjzxRwd()))
	return obj
end

maker.CST_ClubCZHDLog = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"time",0)
	return obj
end

maker.CST_changePostCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg","")
	zd.initLiteSet(obj,"key",0)
	return obj
end

maker.CST_SSetubacktx = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_cs_getSkin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"key",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_survey_id = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_WordShopItem = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_CSkuaPKBack = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hid",maker.CST_Null())
	return obj
end

maker.CST_SsetUFrame = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CS_PlayModuleStory = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_hd699RefuseToTeam = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"tmid",0)
	return obj
end

maker.CST_skinShopInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"sshop",zd.makeLiteArray(makerSC.SCT_ScskinshopInfo()))
	return obj
end

maker.CST_CYhFind = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid","0")
	return obj
end

maker.CST_survey_cfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"headline","")
	zd.initLiteSet(obj,"imgurl",0)
	zd.initLiteSet(obj,"isshow",1)
	zd.initLiteSet(obj,"outline","")
	zd.initLiteSet(obj,"question",zd.makeLiteArray(makerSC.SCT_survey_question()))
	return obj
end

maker.CST_CMemberPost = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid",0)
	zd.initLiteSet(obj,"postid",0)
	return obj
end

maker.CST_jxhschat = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_WBGe2Dan = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"allhp",0)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"damage",0)
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_Pvb2Date = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"label","")
	zd.initLiteSet(obj,"next",0)
	return obj
end

maker.CST_SC_sevendtask = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"task",zd.makeLiteArray(makerSC.SCT_sevendtaskcfg()))
	return obj
end

maker.CST_BHCZHDInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"eTime",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"kg",0)
	zd.initLiteSet(obj,"no",0)
	zd.initLiteSet(obj,"sTime",0)
	zd.initLiteSet(obj,"title","")
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SCcslist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"heroid",0)
	zd.initLiteSet(obj,"hname","")
	zd.initLiteSet(obj,"hpower",0)
	zd.initLiteSet(obj,"jnid",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"post",0)
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_CxghdPaihang = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CS_hd922Rwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dc",0)
	zd.initLiteSet(obj,"typeId",0)
	return obj
end

maker.CST_CSBagNum = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_TurnInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_Syrwlist()))
	return obj
end

maker.CST_yhnewlist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"ep",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"u_credit",0)
	zd.initLiteSet(obj,"u_score",0)
	return obj
end

maker.CST_SC_panan = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"pananId",0)
	return obj
end

maker.CST_CsRiskSubmitTask = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_Shdrwdlc = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"jiazhi",0)
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"need",0)
	return obj
end

maker.CST_LanFangUnlock = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"unlock",0)
	return obj
end

maker.CST_CHinfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bjlist",zd.makeLiteArray(makerSC.SCT_CHlist()))
	zd.initLiteSet(obj,"gjlist",zd.makeLiteArray(makerSC.SCT_CHlist()))
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_CHlist()))
	zd.initLiteSet(obj,"mklist",zd.makeLiteArray(makerSC.SCT_CHlist()))
	zd.initLiteSet(obj,"setFid",0)
	zd.initLiteSet(obj,"set_ids","")
	zd.initLiteSet(obj,"setbj",0)
	zd.initLiteSet(obj,"setgj",0)
	zd.initLiteSet(obj,"setid",0)
	zd.initLiteSet(obj,"setmk",0)
	return obj
end

maker.CST_Pay_rewards = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"isshow",0)
	zd.initLiteSet(obj,"item",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"need",0)
	zd.initLiteSet(obj,"status",0)
	return obj
end

maker.CST_blesschange = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"newId",0)
	zd.initLiteSet(obj,"oldId",0)
	return obj
end

maker.CST_LiangchenInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"chenghao",0)
	zd.initLiteSet(obj,"date","")
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"dress",0)
	zd.initLiteSet(obj,"endTime","")
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"job",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"saiji",0)
	zd.initLiteSet(obj,"sex",0)
	zd.initLiteSet(obj,"shiceid",0)
	zd.initLiteSet(obj,"sid",0)
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_Flist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_fUserInfo()))
	zd.initLiteSet(obj,"refuse_apply",0)
	return obj
end

maker.CST_SyhOld = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bad",0)
	zd.initLiteSet(obj,"ctime",0)
	zd.initLiteSet(obj,"ep",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"score",0)
	return obj
end

maker.CST_SC_ClubExtendDailyInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cyCountDaily",zd.makeLiteArray(makerSC.SCT_SC_ClubExtendDailyInfoCyCountDaily()))
	return obj
end

maker.CST_CSsetAge = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"d",0)
	zd.initLiteSet(obj,"m",0)
	zd.initLiteSet(obj,"y",0)
	return obj
end

maker.CST_SCvipexp = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"vip",0)
	return obj
end

maker.CST_BanishDeskCashList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cash",1)
	zd.initLiteSet(obj,"id",1)
	return obj
end

maker.CST_itemHeroBase = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"heroid",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_dailyrwditemlist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"itemid",0)
	zd.initLiteSet(obj,"kind",0)
	return obj
end

maker.CST_CS_UserTranslate = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"text","")
	return obj
end

maker.CST_SC_guideConsumeInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"reward",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"status",0)
	zd.initLiteSet(obj,"time",0)
	return obj
end

maker.CST_UserModelWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"onekeypvewin",maker.CST_OnekeyPveWin())
	zd.initLiteSet(obj,"pvb2win",maker.CST_UserPvb2Win())
	zd.initLiteSet(obj,"pvbwin",maker.CST_UserPvbWin())
	zd.initLiteSet(obj,"pvewin",maker.CST_UserPveWin())
	return obj
end

maker.CST_zj_list = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",1)
	zd.initLiteSet(obj,"state",1)
	return obj
end

maker.CST_SC_Cj0Bhuodong = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg",maker.CST_cjoldPlayerBackCfg())
	return obj
end

maker.CST_CShopList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid",maker.CST_Null())
	return obj
end

maker.CST_CityInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"document","")
	return obj
end

maker.CST_SkinInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dt",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SCclubkuajf = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cname","")
	zd.initLiteSet(obj,"mzname","")
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"servid",0)
	return obj
end

maker.CST_SbossInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"hp",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"ltime",maker.CST_CdLabel())
	zd.initLiteSet(obj,"money",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_UserId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CsCourtyardShop = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",1)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",1)
	return obj
end

maker.CST_SheroLog = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"heroname","")
	zd.initLiteSet(obj,"hit",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"time",0)
	return obj
end

maker.CST_CsCourtyardHarvest = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_Sfllist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"chatFrame",0)
	zd.initLiteSet(obj,"frame",0)
	zd.initLiteSet(obj,"head",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"job",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"sllist",zd.makeLiteArray(makerSC.SCT_Ssllist()))
	return obj
end

maker.CST_Getrwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_Shdinfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"eTime",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"news",0)
	zd.initLiteSet(obj,"pindex",0)
	zd.initLiteSet(obj,"sTime",0)
	zd.initLiteSet(obj,"showTime",0)
	zd.initLiteSet(obj,"title","")
	zd.initLiteSet(obj,"type",1)
	return obj
end

maker.CST_SCUserDressListBase = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"yj",0)
	return obj
end

maker.CST_SmyYhRid = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"score",0)
	return obj
end

maker.CST_cznhlallrwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray("czhlrwd"))
	return obj
end

maker.CST_fHeroData = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hid","")
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_firstHeroList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dt",0)
	zd.initLiteSet(obj,"epskill",zd.makeLiteArray(makerSC.SCT_SkilInfo()))
	zd.initLiteSet(obj,"ghskill",zd.makeLiteArray(makerSC.SCT_SkilInfo()))
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"scorerank",0)
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_SCShopHefa = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_Cshd401All = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",maker.CST_Null())
	return obj
end

maker.CST_onKeyUp = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"defated",0)
	zd.initLiteSet(obj,"success",0)
	zd.initLiteSet(obj,"upexp",0)
	return obj
end

maker.CST_Null = function()
	local obj = {}
	zd.makeLiteTable(obj)
	return obj
end

maker.CST_ladder_mingrenlist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"beijing",0)
	zd.initLiteSet(obj,"chatFrame",0)
	zd.initLiteSet(obj,"chenghao",0)
	zd.initLiteSet(obj,"dress",0)
	zd.initLiteSet(obj,"duanwei",0)
	zd.initLiteSet(obj,"extra_ch","")
	zd.initLiteSet(obj,"frame",0)
	zd.initLiteSet(obj,"head",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"isHe",0)
	zd.initLiteSet(obj,"jie",1)
	zd.initLiteSet(obj,"job",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"mingrenchenghao",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"num2",0)
	zd.initLiteSet(obj,"num3",0)
	zd.initLiteSet(obj,"num4","")
	zd.initLiteSet(obj,"offlineCh","")
	zd.initLiteSet(obj,"pet_addi",0)
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"sevid",0)
	zd.initLiteSet(obj,"sex",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"uid",0)
	zd.initLiteSet(obj,"vip",0)
	zd.initLiteSet(obj,"vipStatus",1)
	return obj
end

maker.CST_SuidLog = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"kill","")
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_jslist()))
	return obj
end

maker.CST_ScXxlShop = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"t",0)
	return obj
end

maker.CST_ClubCZHDUserCz = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	return obj
end

maker.CST_s_onlineTime = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"onlineTime",0)
	return obj
end

maker.CST_ChrUser = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	return obj
end

maker.CST_jqInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fsn","")
	zd.initLiteSet(obj,"mysn","")
	zd.initLiteSet(obj,"t",0)
	zd.initLiteSet(obj,"tar",0)
	return obj
end

maker.CST_SC_loginMod = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"error",maker.CST_SC_loginModError())
	zd.initLiteSet(obj,"loginAccount",maker.CST_SC_LoginAccount())
	return obj
end

maker.CST_CS_GuideSpecialGuide = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_inheritUser = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id","")
	zd.initLiteSet(obj,"openid","")
	zd.initLiteSet(obj,"openkey","")
	zd.initLiteSet(obj,"platform","")
	zd.initLiteSet(obj,"pwd","")
	return obj
end

maker.CST_SC_FourGoodBuyRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"get",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CApply = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid",0)
	zd.initLiteSet(obj,"msg","")
	return obj
end

maker.CST_CS_huodong2 = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hd1005Cut",maker.CST_ParamNum())
	zd.initLiteSet(obj,"hd1005Done",maker.CST_Null())
	zd.initLiteSet(obj,"hd1005Info",maker.CST_Null())
	zd.initLiteSet(obj,"hd1005Open",maker.CST_ParamWid())
	zd.initLiteSet(obj,"hd1005RwdBox",maker.CST_ParamId())
	zd.initLiteSet(obj,"hd1005RwdDaily",maker.CST_Null())
	zd.initLiteSet(obj,"hd1005RwdTask",maker.CST_ParamId())
	zd.initLiteSet(obj,"hd237Draw",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd237GetCzRwd",maker.CST_idBase())
	zd.initLiteSet(obj,"hd237Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd237Rank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd238Buy",maker.CST_hd238BuyParams())
	zd.initLiteSet(obj,"hd238Get","")
	zd.initLiteSet(obj,"hd238Info","")
	zd.initLiteSet(obj,"hd238chat",maker.CST_hd238ChatParams())
	zd.initLiteSet(obj,"hd238checkChat","")
	zd.initLiteSet(obj,"hd239Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd239Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd327Get","CxzcGet")
	zd.initLiteSet(obj,"hd327Info","CxzcInfo")
	zd.initLiteSet(obj,"hd327Rwd",maker.CST_NULL())
	zd.initLiteSet(obj,"hd327Set","CxzcSet")
	zd.initLiteSet(obj,"hd327Zao","CxzcZao")
	zd.initLiteSet(obj,"hd327exchange","CxzcGet")
	zd.initLiteSet(obj,"hd328Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd540Exchange",maker.CST_idBase())
	zd.initLiteSet(obj,"hd540GetBox",maker.CST_idBase())
	zd.initLiteSet(obj,"hd540GetRank","")
	zd.initLiteSet(obj,"hd540Info","")
	zd.initLiteSet(obj,"hd540Play",maker.CST_CSplayNum())
	zd.initLiteSet(obj,"hd540SetOpt","CS_ShenBingsetoptional")
	zd.initLiteSet(obj,"hd549Info","")
	zd.initLiteSet(obj,"hd549buy",maker.CST_idBase())
	zd.initLiteSet(obj,"hd552AllLog",maker.CST_NULL())
	zd.initLiteSet(obj,"hd552Back",maker.CST_idBase())
	zd.initLiteSet(obj,"hd552City",maker.CST_idBase())
	zd.initLiteSet(obj,"hd552ComeIn",maker.CST_NULL())
	zd.initLiteSet(obj,"hd552Dispatch",maker.CST_CS_hd552Dispatch())
	zd.initLiteSet(obj,"hd552Get",maker.CST_NULL())
	zd.initLiteSet(obj,"hd552GetZhen",maker.CST_CS_hd552GetZhen())
	zd.initLiteSet(obj,"hd552Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd552Rank",maker.CST_idBase())
	zd.initLiteSet(obj,"hd552SelfLog",maker.CST_NULL())
	zd.initLiteSet(obj,"hd580Info","")
	zd.initLiteSet(obj,"hd580Rwd",maker.CST_NULL())
	zd.initLiteSet(obj,"hd593Fan",maker.CST_Cx591fan())
	zd.initLiteSet(obj,"hd593Get",maker.CST_CShd336Up())
	zd.initLiteSet(obj,"hd593Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd593Task",maker.CST_CxslchdRwd())
	zd.initLiteSet(obj,"hd595Info","")
	zd.initLiteSet(obj,"hd595Rwd",maker.CST_CS_hd595Get())
	zd.initLiteSet(obj,"hd630Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd678Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd678Rwd","CjghdRwd")
	zd.initLiteSet(obj,"hd684Info","")
	zd.initLiteSet(obj,"hd684Play","jxhsplay")
	zd.initLiteSet(obj,"hd684Rank","")
	zd.initLiteSet(obj,"hd684agree","jxhsuid")
	zd.initLiteSet(obj,"hd684allRefuse","")
	zd.initLiteSet(obj,"hd684autoTalk","")
	zd.initLiteSet(obj,"hd684breakClub","")
	zd.initLiteSet(obj,"hd684buy","jxhsbuy")
	zd.initLiteSet(obj,"hd684buyEventGift","jxhsbuygift")
	zd.initLiteSet(obj,"hd684chat",maker.CST_jxhschat())
	zd.initLiteSet(obj,"hd684checkChat",maker.CST_jxhscheckchat())
	zd.initLiteSet(obj,"hd684createTeam","jxhscreateclub")
	zd.initLiteSet(obj,"hd684exchange","jxhsid")
	zd.initLiteSet(obj,"hd684getEventRwd","jxhsid")
	zd.initLiteSet(obj,"hd684getRechargeRwd","jxhsid")
	zd.initLiteSet(obj,"hd684getScenicRwd","jxhsid")
	zd.initLiteSet(obj,"hd684join","jxhsclubid")
	zd.initLiteSet(obj,"hd684kickout","jxhsuid")
	zd.initLiteSet(obj,"hd684logs","")
	zd.initLiteSet(obj,"hd684outClub","jxhsclubid")
	zd.initLiteSet(obj,"hd684rand","jxhschangeRand")
	zd.initLiteSet(obj,"hd684randEvent","jxhsid")
	zd.initLiteSet(obj,"hd684randJoin","")
	zd.initLiteSet(obj,"hd684refuse","jxhsuid")
	zd.initLiteSet(obj,"hd684result","jxhsrecord")
	zd.initLiteSet(obj,"hd684teamInfo","jxhsid")
	zd.initLiteSet(obj,"hd684use","jxhsbuy")
	zd.initLiteSet(obj,"hd695Check","")
	zd.initLiteSet(obj,"hd695History",maker.CST_ParamId())
	zd.initLiteSet(obj,"hd695Info","")
	zd.initLiteSet(obj,"hd695Play","")
	zd.initLiteSet(obj,"hd697Buy","hd697BuyParams")
	zd.initLiteSet(obj,"hd697DoubleBackFlop",maker.CST_NULL())
	zd.initLiteSet(obj,"hd697Exchange","hd697ExchangeParams")
	zd.initLiteSet(obj,"hd697Get","hd697GetParams")
	zd.initLiteSet(obj,"hd697Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd697Play","hd697PlayParams")
	zd.initLiteSet(obj,"hd697Rank",maker.CST_NULL())
	zd.initLiteSet(obj,"hd698Get",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd698Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd699Info","")
	zd.initLiteSet(obj,"hd699agree",maker.CST_hd699AgreeToTeam())
	zd.initLiteSet(obj,"hd699allRefuse","")
	zd.initLiteSet(obj,"hd699applyList","")
	zd.initLiteSet(obj,"hd699autoTalk","")
	zd.initLiteSet(obj,"hd699chat",maker.CST_hd699ChatByType())
	zd.initLiteSet(obj,"hd699chatHistory",maker.CST_hd699ChatHisByType())
	zd.initLiteSet(obj,"hd699checkChat",maker.CST_hd699checkChatByType())
	zd.initLiteSet(obj,"hd699getReward",maker.CST_hd699Reward())
	zd.initLiteSet(obj,"hd699joinTeam",maker.CST_hd699TeammateId())
	zd.initLiteSet(obj,"hd699myTeam","")
	zd.initLiteSet(obj,"hd699refuse",maker.CST_hd699RefuseToTeam())
	zd.initLiteSet(obj,"hd699toggle","")
	zd.initLiteSet(obj,"hd709Buy",maker.CST_hd709Num())
	zd.initLiteSet(obj,"hd709Exchange",maker.CST_hd709ExchangeParams())
	zd.initLiteSet(obj,"hd709GetBox",maker.CST_hd709GetBoxParams())
	zd.initLiteSet(obj,"hd709GetRecharge",maker.CST_hd709GetRechargeParams())
	zd.initLiteSet(obj,"hd709Info","")
	zd.initLiteSet(obj,"hd709Play",maker.CST_hd709Num())
	zd.initLiteSet(obj,"hd709Rank","")
	zd.initLiteSet(obj,"hd745Info","")
	zd.initLiteSet(obj,"hd745blessRwd",maker.CST_CS_hd745Rwd())
	zd.initLiteSet(obj,"hd745comRwd","")
	zd.initLiteSet(obj,"hd745dragonRwd","")
	zd.initLiteSet(obj,"hd745play",maker.CST_CS_hd745play())
	zd.initLiteSet(obj,"hd745taskRwd",maker.CST_CS_hd745Rwd())
	zd.initLiteSet(obj,"hd748Buy",maker.CST_hd748Num())
	zd.initLiteSet(obj,"hd748Exchange",maker.CST_hd748ExchangeParams())
	zd.initLiteSet(obj,"hd748GetBox",maker.CST_hd748GetBoxParams())
	zd.initLiteSet(obj,"hd748GetRecharge",maker.CST_hd748GetRechargeParams())
	zd.initLiteSet(obj,"hd748Info","")
	zd.initLiteSet(obj,"hd748Play",maker.CST_hd748Num())
	zd.initLiteSet(obj,"hd748Rank","")
	zd.initLiteSet(obj,"hd792Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd804Gplay",maker.CST_NULL())
	zd.initLiteSet(obj,"hd804Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd804Play",maker.CST_NULL())
	zd.initLiteSet(obj,"hd805Buy","hd697BuyParams")
	zd.initLiteSet(obj,"hd805DoubleBackFlop","hd805DoubleBackFlopParams")
	zd.initLiteSet(obj,"hd805Exchange","hd697ExchangeParams")
	zd.initLiteSet(obj,"hd805Get","hd697GetParams")
	zd.initLiteSet(obj,"hd805Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd805Play","hd697PlayParams")
	zd.initLiteSet(obj,"hd805Rank",maker.CST_NULL())
	zd.initLiteSet(obj,"hd806Buy","hd697BuyParams")
	zd.initLiteSet(obj,"hd806Czz","hd806CzzParams")
	zd.initLiteSet(obj,"hd806Exchange","hd697ExchangeParams")
	zd.initLiteSet(obj,"hd806Get","hd697GetParams")
	zd.initLiteSet(obj,"hd806Help","hd806HelpParams")
	zd.initLiteSet(obj,"hd806Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd806Play","hd697PlayParams")
	zd.initLiteSet(obj,"hd806Rank",maker.CST_NULL())
	zd.initLiteSet(obj,"hd806Task",maker.CST_CxslchdRwd())
	zd.initLiteSet(obj,"hd806UserInfo",maker.CST_UserId())
	zd.initLiteSet(obj,"hd816Info",maker.CST_Null())
	zd.initLiteSet(obj,"hd816getMyzy",maker.CST_Null())
	zd.initLiteSet(obj,"hd816getQuan",maker.CST_Null())
	zd.initLiteSet(obj,"hd816getwzw",maker.CST_Null())
	zd.initLiteSet(obj,"hd816play",maker.CST_ParamNum())
	zd.initLiteSet(obj,"hd816shisq",maker.CST_Null())
	zd.initLiteSet(obj,"hd817Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd817buy","wglcbuy")
	zd.initLiteSet(obj,"hd817exchange","wglcexchange")
	zd.initLiteSet(obj,"hd817getPaihang","CxzcInfo")
	zd.initLiteSet(obj,"hd817getrwd","CxghdExchange")
	zd.initLiteSet(obj,"hd817lingqu","")
	zd.initLiteSet(obj,"hd817play","wglcplay")
	zd.initLiteSet(obj,"hd820Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd850Answer",maker.CST_hd850AnswerInfo())
	zd.initLiteSet(obj,"hd850History",maker.CST_Null())
	zd.initLiteSet(obj,"hd850Info",maker.CST_Null())
	zd.initLiteSet(obj,"hd850Question",maker.CST_Null())
	zd.initLiteSet(obj,"hd850Rank",maker.CST_Null())
	zd.initLiteSet(obj,"hd850Taskinfo",maker.CST_Null())
	zd.initLiteSet(obj,"hd850Taskreward",maker.CST_hd850TaskrewardInfo())
	zd.initLiteSet(obj,"hd850UseItem",maker.CST_hd850UseItmeInfo())
	zd.initLiteSet(obj,"hd912Buy",maker.CST_CShd912Buy())
	zd.initLiteSet(obj,"hd912Exchange","hd697ExchangeParams")
	zd.initLiteSet(obj,"hd912Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd912Pay",maker.CST_CxslchdRwd())
	zd.initLiteSet(obj,"hd912Task",maker.CST_CxslchdRwd())
	zd.initLiteSet(obj,"hd913Check","CShd913Check")
	zd.initLiteSet(obj,"hd913Exchange","hd697ExchangeParams")
	zd.initLiteSet(obj,"hd913Get",maker.CST_CShd336Up())
	zd.initLiteSet(obj,"hd913Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd913Open","Cx913Open")
	zd.initLiteSet(obj,"hd913Recharge",maker.CST_CxslchdRwd())
	zd.initLiteSet(obj,"hd913Reset",maker.CST_CShd913type())
	zd.initLiteSet(obj,"hd914Archery","Cxhd914Archery")
	zd.initLiteSet(obj,"hd914DailyBx",maker.CST_NULL())
	zd.initLiteSet(obj,"hd914Get",maker.CST_CShd336Up())
	zd.initLiteSet(obj,"hd914Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd914Pick","Cxhd914Pick")
	zd.initLiteSet(obj,"hd914Task",maker.CST_CxslchdRwd())
	zd.initLiteSet(obj,"hd915Buy",maker.CST_idBase())
	zd.initLiteSet(obj,"hd915Chat",maker.CST_ChatMsg())
	zd.initLiteSet(obj,"hd915Check",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd915Get",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd915Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd915Log",maker.CST_ChatId())
	zd.initLiteSet(obj,"hd915UserRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd917Draw","")
	zd.initLiteSet(obj,"hd917Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd917Pray","Cxhd917Pray")
	zd.initLiteSet(obj,"hd917Wishing","Cxhd917Wishing")
	return obj
end

maker.CST_QxRwdLog = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"itemid",0)
	zd.initLiteSet(obj,"name","")
	return obj
end

maker.CST_CdNumOpen = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"isopen",0)
	zd.initLiteSet(obj,"label","")
	zd.initLiteSet(obj,"next",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_CShd344Send = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"phone",0)
	return obj
end

maker.CST_CdNum = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"label","")
	zd.initLiteSet(obj,"next",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_targetLanguage = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"targetLanguage","")
	return obj
end

maker.CST_ParamKey = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"key",0)
	return obj
end

maker.CST_SourceTextInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"SourceText","")
	zd.initLiteSet(obj,"id","")
	return obj
end

maker.CST_SC_ChengJiu = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cjlist",zd.makeLiteArray(makerSC.SCT_ChenhJiulist()))
	return obj
end

maker.CST_CS_Login = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"authen",maker.CST_IdAuthen())
	zd.initLiteSet(obj,"getHistory",maker.CST_CS_Login_getHistory())
	zd.initLiteSet(obj,"inheritUser",maker.CST_inheritUser())
	zd.initLiteSet(obj,"intro",maker.CST_LoginIntro())
	zd.initLiteSet(obj,"loginAccount",maker.CST_LoginAccount())
	zd.initLiteSet(obj,"notice",maker.CST_GuideNotic())
	zd.initLiteSet(obj,"verify",maker.CST_LoginAccount())
	return obj
end

maker.CST_SchoolStart = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hid",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SchoolDate = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"desk",1)
	return obj
end

maker.CST_ScskinshopInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"discount",0)
	zd.initLiteSet(obj,"eTime",0)
	zd.initLiteSet(obj,"ids","")
	zd.initLiteSet(obj,"sTime",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_ErrorCode = makerSC.SCT_ErrorCode
maker.CST_ScXxlCfgShop = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cost",0)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"kind",0)
	zd.initLiteSet(obj,"limit",0)
	return obj
end

maker.CST_SC_centralattackinfofbscorelist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bei",0)
	zd.initLiteSet(obj,"time","")
	zd.initLiteSet(obj,"timestamp",0)
	return obj
end

maker.CST_SCldjcbkhdCfgRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"need",0)
	return obj
end

maker.CST_CS_HD496BuyRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SCclubheroinfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"add",0)
	zd.initLiteSet(obj,"dt",0)
	zd.initLiteSet(obj,"dx",0)
	zd.initLiteSet(obj,"gjadd",0)
	zd.initLiteSet(obj,"hid",0)
	zd.initLiteSet(obj,"huihe",0)
	zd.initLiteSet(obj,"is_win",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"out",0)
	zd.initLiteSet(obj,"padd",0)
	zd.initLiteSet(obj,"post",0)
	zd.initLiteSet(obj,"power",0)
	zd.initLiteSet(obj,"skin",0)
	zd.initLiteSet(obj,"uid",0)
	zd.initLiteSet(obj,"ur",0)
	zd.initLiteSet(obj,"use",0)
	return obj
end

maker.CST_hd709GetRechargeParams = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_HeChengList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"itemid",0)
	zd.initLiteSet(obj,"need",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"outtime",0)
	zd.initLiteSet(obj,"times",0)
	zd.initLiteSet(obj,"totonum",0)
	return obj
end

maker.CST_SCsocialdressedall = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"userchatframe",zd.makeLiteArray(makerSC.SCT_SCsocialdressedlist()))
	zd.initLiteSet(obj,"userframe",zd.makeLiteArray(makerSC.SCT_SCsocialdressedlist()))
	zd.initLiteSet(obj,"userhead",zd.makeLiteArray(makerSC.SCT_SCsocialdressedlist()))
	return obj
end

maker.CST_WBMengGu = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bo",1)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"damage",0)
	zd.initLiteSet(obj,"heroft",zd.makeLiteArray(makerSC.SCT_FightList()))
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_FchoFuli = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"time",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SC_zglb = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg",maker.CST_ScgInfoDirect())
	return obj
end

maker.CST_csBuildOccupy = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buildingId",0)
	zd.initLiteSet(obj,"buildingLevel",0)
	zd.initLiteSet(obj,"chanllengeId",0)
	zd.initLiteSet(obj,"heros",zd.makeLiteArray(makerSC.SCT_KuaMineOccupyHero()))
	zd.initLiteSet(obj,"locationId",0)
	return obj
end

maker.CST_SurveyInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg",maker.CST_survey_cfg())
	zd.initLiteSet(obj,"info",maker.CST_Shdinfo())
	zd.initLiteSet(obj,"must",zd.makeLiteArray(makerSC.SCT_survey_id()))
	return obj
end

maker.CST_wannengInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buyTime",0)
	return obj
end

maker.CST_Stmain = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",1)
	zd.initLiteSet(obj,"max",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_ScKitchenMenu = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cpnum",0)
	zd.initLiteSet(obj,"opmenu",zd.makeLiteArray(makerSC.SCT_ScKom()))
	zd.initLiteSet(obj,"plv",0)
	zd.initLiteSet(obj,"uopmenu",zd.makeLiteArray(makerSC.SCT_ScKuom()))
	return obj
end

maker.CST_CClubList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid",0)
	return obj
end

maker.CST_CXxbad = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",maker.CST_Null())
	return obj
end

maker.CST_CS_ChooseStory = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"chooseid",0)
	zd.initLiteSet(obj,"storyid",0)
	return obj
end

maker.CST_rwdItems = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"kind",0)
	return obj
end

maker.CST_fbshareInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_xsRankWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"myName","")
	zd.initLiteSet(obj,"myNum",0)
	zd.initLiteSet(obj,"myRid",0)
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"xsRank",zd.makeLiteArray(makerSC.SCT_Scblist()))
	return obj
end

maker.CST_SC_ChengHao = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"chInfo",maker.CST_CHinfo())
	zd.initLiteSet(obj,"wyrwd","Cswyrwd")
	return obj
end

maker.CST_itemId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_QzAiMin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"max",0)
	zd.initLiteSet(obj,"now",0)
	return obj
end

maker.CST_CClubBossHitList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SC_zhuchenghint = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_zhuchenginfo())
	return obj
end

maker.CST_SC_Ladder = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cslist",zd.makeLiteArray(makerSC.SCT_FightList()))
	zd.initLiteSet(obj,"deflog",zd.makeLiteArray("YamenDefInfo"))
	zd.initLiteSet(obj,"enymsg",zd.makeLiteArray("YamenEnymsg"))
	zd.initLiteSet(obj,"exchange","SjlShop")
	zd.initLiteSet(obj,"fclist",zd.makeLiteArray(makerSC.SCT_FightList()))
	zd.initLiteSet(obj,"fight","ladderPVP_fight")
	zd.initLiteSet(obj,"firstScoreRank",maker.CST_FirstYamenData())
	zd.initLiteSet(obj,"gongxun",maker.CST_ladder_gongxun())
	zd.initLiteSet(obj,"hastz",zd.makeLiteArray("Yamenhastz"))
	zd.initLiteSet(obj,"hdinfo",maker.CST_KuattInfo())
	zd.initLiteSet(obj,"info",maker.CST_PVP_Info_ladder())
	zd.initLiteSet(obj,"kill20log",zd.makeLiteArray("Yamen20log"))
	zd.initLiteSet(obj,"ladderShopfresh",maker.CST_SjlShopfresh())
	zd.initLiteSet(obj,"mingrenlist",zd.makeLiteArray(makerSC.SCT_ladder_mingrenlist()))
	zd.initLiteSet(obj,"mrchenghao",maker.CST_ladder_chenghao())
	zd.initLiteSet(obj,"myScore",maker.CST_ladder_myscore())
	zd.initLiteSet(obj,"onekey","YamenOnekey")
	zd.initLiteSet(obj,"scoreRank",zd.makeLiteArray(makerSC.SCT_ladder_fUserInfo()))
	zd.initLiteSet(obj,"severRank",zd.makeLiteArray(makerSC.SCT_SeverInfo()))
	zd.initLiteSet(obj,"severScore",maker.CST_MyKuaYamenRank())
	zd.initLiteSet(obj,"win","YamenWin")
	zd.initLiteSet(obj,"yuxuan","KuaYamenState")
	zd.initLiteSet(obj,"zhuisha","ladderFind")
	return obj
end

maker.CST_Fsendlist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_fUserInfo()))
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_CsMysteryUnlock = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",2)
	return obj
end

maker.CST_Fuid = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid",0)
	return obj
end

maker.CST_sevendtaskcfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"isGet",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_SCpost = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cy",0)
	zd.initLiteSet(obj,"fmz",0)
	zd.initLiteSet(obj,"jy",0)
	zd.initLiteSet(obj,"mz",0)
	return obj
end

maker.CST_SyhType = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"iskua",0)
	zd.initLiteSet(obj,"over",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SC = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"derail",maker.CST_SC_Derail())
	zd.initLiteSet(obj,"gameMachine",maker.CST_SC_GameMachine())
	zd.initLiteSet(obj,"guide",maker.CST_SC_Guide())
	zd.initLiteSet(obj,"hero",maker.CST_SC_Hero())
	zd.initLiteSet(obj,"loginMod",maker.CST_SC_loginMod())
	zd.initLiteSet(obj,"mail",maker.CST_SC_Mail())
	zd.initLiteSet(obj,"map",maker.CST_SC_Map())
	zd.initLiteSet(obj,"msgWin",maker.CST_SC_MsgWin())
	zd.initLiteSet(obj,"msgWin2",maker.CST_SC_MsgWin())
	zd.initLiteSet(obj,"notice",maker.CST_SC_Notice())
	zd.initLiteSet(obj,"order",maker.CST_SC_Order())
	zd.initLiteSet(obj,"randWin",maker.CST_SC_RandWin())
	zd.initLiteSet(obj,"sdk",maker.CST_SC_sdk())
	zd.initLiteSet(obj,"shop",maker.CST_SC_Shop())
	zd.initLiteSet(obj,"story",maker.CST_SC_Story())
	zd.initLiteSet(obj,"system",maker.CST_SC_System())
	zd.initLiteSet(obj,"user",maker.CST_SC_User())
	return obj
end

maker.CST_CS_GM = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"addGameMachineCnt","")
	zd.initLiteSet(obj,"drawGameMachine",maker.CST_CommonOrder())
	return obj
end

maker.CST_SC_FourGoodRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_SC_FourGoodRwdLevel()))
	return obj
end

maker.CST_Fnum = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"f_num",0)
	return obj
end

maker.CST_ChatId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CYhHold = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"isOpen",0)
	zd.initLiteSet(obj,"kuaOpen",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_FuLiShenJi = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"times",0)
	return obj
end

maker.CST_Cxsdnd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_RiskTaskList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"get_rwd",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"isNew",0)
	zd.initLiteSet(obj,"jindu",zd.makeLiteArray(makerSC.SCT_RiskJindu()))
	return obj
end

maker.CST_SC_Map = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"city",maker.CST_CityInfo())
	return obj
end

maker.CST_Szcjbcfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_Shdcfg())
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"need",maker.CST_Sneedcfg())
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_Srwdcfg()))
	return obj
end

maker.CST_SC_All_butler = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"butler_dispos",maker.CST_Sc_dispos())
	zd.initLiteSet(obj,"butler_do",zd.makeLiteArray(makerSC.SCT_Sc_butler_do()))
	zd.initLiteSet(obj,"butler_info",maker.CST_Sc_butler_info())
	zd.initLiteSet(obj,"butler_logs",zd.makeLiteArray("Sc_butlerlogs"))
	zd.initLiteSet(obj,"do_all","Sc_do_dispos")
	zd.initLiteSet(obj,"shoplist","Sc_butlershop")
	return obj
end

maker.CST_CSCzhl = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"money",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_ActNoticePic = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"actid","")
	zd.initLiteSet(obj,"gid","")
	zd.initLiteSet(obj,"picid","")
	zd.initLiteSet(obj,"pictype","")
	zd.initLiteSet(obj,"showtime","")
	zd.initLiteSet(obj,"stime","")
	return obj
end

maker.CST_WordG2dMyDmgRk = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"g2dallman",0)
	zd.initLiteSet(obj,"g2dmydamage",0)
	zd.initLiteSet(obj,"g2dmyrank",0)
	return obj
end

maker.CST_mseInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"s",0)
	zd.initLiteSet(obj,"st",0)
	return obj
end

maker.CST_SCUserVerify = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"day","")
	return obj
end

maker.CST_SCUserDressNList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cFrame",0)
	zd.initLiteSet(obj,"frame",0)
	zd.initLiteSet(obj,"head",0)
	return obj
end

maker.CST_SC_FuLi = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"coupon",zd.makeLiteArray(makerSC.SCT_couponIngo()))
	zd.initLiteSet(obj,"fbdc",maker.CST_FuLiFBDC())
	zd.initLiteSet(obj,"fbshare",maker.CST_fbshareInfo())
	zd.initLiteSet(obj,"fchofuli",zd.makeLiteArray(makerSC.SCT_FchoFuli()))
	zd.initLiteSet(obj,"fchofuliwin",maker.CST_FchoFuliGuide())
	zd.initLiteSet(obj,"fulifund",maker.CST_FuliFundInfo())
	zd.initLiteSet(obj,"guanqun",maker.CST_QQNum())
	zd.initLiteSet(obj,"mooncard",zd.makeLiteArray(makerSC.SCT_CardType()))
	zd.initLiteSet(obj,"moonclubfuli",maker.CST_MoonClubFuli())
	zd.initLiteSet(obj,"qiandao",maker.CST_QianDaoDay())
	zd.initLiteSet(obj,"sevenDaySign",maker.CST_SCSevenDaySign())
	zd.initLiteSet(obj,"shenji",zd.makeLiteArray(makerSC.SCT_FuLiShenJi()))
	zd.initLiteSet(obj,"vipfuli",zd.makeLiteArray(makerSC.SCT_VipFuLiType()))
	zd.initLiteSet(obj,"win",maker.CST_FuLiWin())
	zd.initLiteSet(obj,"wxqq",maker.CST_FuLiWXQQ())
	return obj
end

maker.CST_SMemberInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"allgx",0)
	zd.initLiteSet(obj,"cid",0)
	zd.initLiteSet(obj,"cyBan",0)
	zd.initLiteSet(obj,"dcid",0)
	zd.initLiteSet(obj,"fdicd",0)
	zd.initLiteSet(obj,"leftgx",0)
	zd.initLiteSet(obj,"ltime",maker.CST_CdLabel())
	zd.initLiteSet(obj,"material",0)
	zd.initLiteSet(obj,"noteNews1",0)
	zd.initLiteSet(obj,"noteNews2",0)
	zd.initLiteSet(obj,"noteNews3",0)
	zd.initLiteSet(obj,"post",0)
	return obj
end

maker.CST_Sc_OrderTest = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dc",0)
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_FuserData = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"beijing",0)
	zd.initLiteSet(obj,"bmap",0)
	zd.initLiteSet(obj,"chatFrame",0)
	zd.initLiteSet(obj,"chenghao",0)
	zd.initLiteSet(obj,"chlist",zd.makeLiteArray(makerSC.SCT_Schlist()))
	zd.initLiteSet(obj,"clubid",0)
	zd.initLiteSet(obj,"clubname","")
	zd.initLiteSet(obj,"dress",0)
	zd.initLiteSet(obj,"duanwei",0)
	zd.initLiteSet(obj,"ep","FourEp")
	zd.initLiteSet(obj,"exp",0)
	zd.initLiteSet(obj,"extra_ch","")
	zd.initLiteSet(obj,"guajian",0)
	zd.initLiteSet(obj,"head",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"job",1)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"love",0)
	zd.initLiteSet(obj,"maxmap",0)
	zd.initLiteSet(obj,"mingrenchenghao",0)
	zd.initLiteSet(obj,"mmap",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"riskexp",0)
	zd.initLiteSet(obj,"risklevel",0)
	zd.initLiteSet(obj,"set",0)
	zd.initLiteSet(obj,"setFrame",0)
	zd.initLiteSet(obj,"setcar",0)
	zd.initLiteSet(obj,"sex",1)
	zd.initLiteSet(obj,"shice",maker.CST_SC_shice())
	zd.initLiteSet(obj,"shili",0)
	zd.initLiteSet(obj,"signName","")
	zd.initLiteSet(obj,"smap",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"vip",0)
	zd.initLiteSet(obj,"vipStatus",1)
	zd.initLiteSet(obj,"xuanyan","")
	zd.initLiteSet(obj,"yh",1)
	return obj
end

maker.CST_CS_hd745play = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"offer",zd.makeLiteArray(makerSC.SCT_hd745playparams()))
	return obj
end

maker.CST_CxshdInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",maker.CST_Null())
	return obj
end

maker.CST_ParamId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SC_houseHoldReset = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_KuaMineOccupy = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"heros",zd.makeLiteArray(makerSC.SCT_KuaMineOccupyHero()))
	zd.initLiteSet(obj,"key",0)
	return obj
end

maker.CST_VipRwdInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"is_recieve",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"tiptype",0)
	return obj
end

maker.CST_CSselectBuild = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"build",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_ScTansuoLog = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"eid",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_rwdItems()))
	return obj
end

maker.CST_SystemIntro = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"text","")
	return obj
end

maker.CST_SbossInfo1 = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hp",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"ltime",maker.CST_CdLabel())
	zd.initLiteSet(obj,"money",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SchoolOver = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_HbmyRedList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"stime",0)
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_CS_Ranking = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"heroMobai",maker.CST_Hid())
	zd.initLiteSet(obj,"heroPaihang",maker.CST_Hid())
	zd.initLiteSet(obj,"mobai",maker.CST_MoBai())
	zd.initLiteSet(obj,"paihang",maker.CST_RfPaiHang())
	return obj
end

maker.CST_SC_FourGoodBuyLevelCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"accu",0)
	zd.initLiteSet(obj,"lv",0)
	zd.initLiteSet(obj,"max",0)
	zd.initLiteSet(obj,"price",0)
	return obj
end

maker.CST_FuserDataHeroWife = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hero",zd.makeLiteArray(makerSC.SCT_FuserDataHero()))
	zd.initLiteSet(obj,"wife",zd.makeLiteArray("FuserDataWife"))
	return obj
end

maker.CST_MoBaiMsg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"clubKua",0)
	zd.initLiteSet(obj,"diwang",0)
	zd.initLiteSet(obj,"guanka",0)
	zd.initLiteSet(obj,"heroKua",0)
	zd.initLiteSet(obj,"jiangxiang",0)
	zd.initLiteSet(obj,"liangchen",0)
	zd.initLiteSet(obj,"love",0)
	zd.initLiteSet(obj,"shili",0)
	zd.initLiteSet(obj,"shiliKua",0)
	return obj
end

maker.CST_Clogin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"lang","")
	zd.initLiteSet(obj,"platform","")
	return obj
end

maker.CST_MsmyScore = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"myScore",0)
	zd.initLiteSet(obj,"myScorerank",0)
	zd.initLiteSet(obj,"myZj",0)
	return obj
end

maker.CST_ShopGiftList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"image",0)
	zd.initLiteSet(obj,"islimit",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"limit",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"need",0)
	zd.initLiteSet(obj,"price",0)
	zd.initLiteSet(obj,"vip",0)
	return obj
end

maker.CST_pt_list = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type","")
	return obj
end

maker.CST_FundFuliRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CS_User = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"adok",maker.CST_labelId())
	zd.initLiteSet(obj,"backJob",maker.CST_Null())
	zd.initLiteSet(obj,"bpve",maker.CST_Null())
	zd.initLiteSet(obj,"buildAllPai",maker.CST_CSbuildAllPai())
	zd.initLiteSet(obj,"buildInfo",maker.CST_CSbuildUnlock())
	zd.initLiteSet(obj,"buildPai",maker.CST_CSbuildPai())
	zd.initLiteSet(obj,"buildShou",maker.CST_CSbuildShou())
	zd.initLiteSet(obj,"buildUnlock",maker.CST_CSbuildUnlock())
	zd.initLiteSet(obj,"buildUnlockAll",maker.CST_Null())
	zd.initLiteSet(obj,"buildUp",maker.CST_CSbuildUp())
	zd.initLiteSet(obj,"callBackHero",maker.CST_CScallBackHero())
	zd.initLiteSet(obj,"changeHuodongState",maker.CST_CS_PlayModuleStory())
	zd.initLiteSet(obj,"changeState",maker.CST_CS_PlayModuleStory())
	zd.initLiteSet(obj,"cityNews",maker.CST_Null())
	zd.initLiteSet(obj,"cleanDressNews",maker.CST_cleanDressNewsType())
	zd.initLiteSet(obj,"clearBigEmojiNews",maker.CST_CS_clearBigEmojiNews())
	zd.initLiteSet(obj,"clearNewsChatFrame",maker.CST_SclearNewsChatFrame())
	zd.initLiteSet(obj,"comeBatchBack",maker.CST_Null())
	zd.initLiteSet(obj,"comeback",maker.CST_heroId())
	zd.initLiteSet(obj,"entergk",maker.CST_Null())
	zd.initLiteSet(obj,"getChatFrame",maker.CST_Null())
	zd.initLiteSet(obj,"getFuserBeast",maker.CST_UserId())
	zd.initLiteSet(obj,"getFuserHero",maker.CST_FuidHid())
	zd.initLiteSet(obj,"getFuserHeroWife",maker.CST_UserId())
	zd.initLiteSet(obj,"getFuserHeros",maker.CST_UserId())
	zd.initLiteSet(obj,"getFuserMember",maker.CST_UserId())
	zd.initLiteSet(obj,"getFuserWifes",maker.CST_UserId())
	zd.initLiteSet(obj,"getGuideRwd",maker.CST_CS_getGuideRwd())
	zd.initLiteSet(obj,"getInheritID",maker.CST_Null())
	zd.initLiteSet(obj,"getOfflineProfit","")
	zd.initLiteSet(obj,"getSocialDress",maker.CST_Null())
	zd.initLiteSet(obj,"getUFrame",maker.CST_Null())
	zd.initLiteSet(obj,"get_cj",maker.CST_SSetuback())
	zd.initLiteSet(obj,"getcarback",maker.CST_Null())
	zd.initLiteSet(obj,"getfcmTips",maker.CST_Null())
	zd.initLiteSet(obj,"getuback",maker.CST_Null())
	zd.initLiteSet(obj,"getucityscene",maker.CST_Null())
	zd.initLiteSet(obj,"jingYing",maker.CST_jingYingId())
	zd.initLiteSet(obj,"jingYingAll",maker.CST_Null())
	zd.initLiteSet(obj,"jingYingLing",maker.CST_jingYingIdCount())
	zd.initLiteSet(obj,"maxmap",0)
	zd.initLiteSet(obj,"modifyPwd",maker.CST_ModifyPwd())
	zd.initLiteSet(obj,"onekey_msg",maker.CST_Null())
	zd.initLiteSet(obj,"onekey_pve",maker.CST_Null())
	zd.initLiteSet(obj,"onekey_pve_h5",maker.CST_Null())
	zd.initLiteSet(obj,"pvb",maker.CST_heroId())
	zd.initLiteSet(obj,"pvb2",maker.CST_Null())
	zd.initLiteSet(obj,"pve",maker.CST_Null())
	zd.initLiteSet(obj,"qzam",maker.CST_Null())
	zd.initLiteSet(obj,"randName",maker.CST_Null())
	zd.initLiteSet(obj,"receiveOfflineProfit","")
	zd.initLiteSet(obj,"refjingying",maker.CST_Null())
	zd.initLiteSet(obj,"refson",maker.CST_Null())
	zd.initLiteSet(obj,"refwife",maker.CST_Null())
	zd.initLiteSet(obj,"refxunfang",maker.CST_Null())
	zd.initLiteSet(obj,"resetImage",maker.CST_UserImage())
	zd.initLiteSet(obj,"resetName",maker.CST_UserName())
	zd.initLiteSet(obj,"setChatFrame",maker.CST_SsetChatFrame())
	zd.initLiteSet(obj,"setDress","CxghdPlay")
	zd.initLiteSet(obj,"setFcmTime",maker.CST_Null())
	zd.initLiteSet(obj,"setFuserHwStatus",maker.CST_Null())
	zd.initLiteSet(obj,"setGuidePass",maker.CST_CSSetGuidePass())
	zd.initLiteSet(obj,"setInheritPwd",maker.CST_setInheritPwd())
	zd.initLiteSet(obj,"setJmSwitch",maker.CST_idBase())
	zd.initLiteSet(obj,"setLang",maker.CST_CS_setLang())
	zd.initLiteSet(obj,"setPanAn",maker.CST_SetPanAn())
	zd.initLiteSet(obj,"setSignName",maker.CST_CS_setSignName())
	zd.initLiteSet(obj,"setSocialDress",maker.CST_SsetUSocialDress())
	zd.initLiteSet(obj,"setUFrame",maker.CST_SsetUFrame())
	zd.initLiteSet(obj,"setUnNotify",maker.CST_idBase())
	zd.initLiteSet(obj,"setUserDress",maker.CST_CSSetUserDress())
	zd.initLiteSet(obj,"setUserInTime",maker.CST_Null())
	zd.initLiteSet(obj,"setUserInTime2",maker.CST_Null())
	zd.initLiteSet(obj,"setVipStatus",maker.CST_idBase())
	zd.initLiteSet(obj,"setcarback",maker.CST_SSetuback())
	zd.initLiteSet(obj,"setuback",maker.CST_SSetuback())
	zd.initLiteSet(obj,"setucityscene",maker.CST_SSetuback())
	zd.initLiteSet(obj,"setucityscenetx",maker.CST_SSetubacktx())
	zd.initLiteSet(obj,"shengguan",maker.CST_Null())
	zd.initLiteSet(obj,"syncCityAndGenerator",maker.CST_cityAndGenId())
	zd.initLiteSet(obj,"translate",maker.CST_CS_UserTranslate())
	zd.initLiteSet(obj,"unlockOfflineProfit","")
	zd.initLiteSet(obj,"unsetDress",maker.CST_Null())
	zd.initLiteSet(obj,"vipExp",maker.CST_Null())
	zd.initLiteSet(obj,"yjZhengWu",maker.CST_zhengWuAct())
	zd.initLiteSet(obj,"zg_yjZhengWu",maker.CST_zg_yjZhengWuAct())
	zd.initLiteSet(obj,"zhengWu",maker.CST_zhengWuAct())
	zd.initLiteSet(obj,"zhengWuLing",maker.CST_ItemCount())
	return obj
end

maker.CST_CSplayNum = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_SC_MonthTaskInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"need",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"taskId",0)
	return obj
end

maker.CST_ScTansuoMapList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cur",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_ChdList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",maker.CST_Null())
	return obj
end

maker.CST_CsTsType = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_Hbhblist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"exite",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"job",0)
	zd.initLiteSet(obj,"lq_list",zd.makeLiteArray(makerSC.SCT_HbGetHbList()))
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"sex",0)
	zd.initLiteSet(obj,"stime",0)
	zd.initLiteSet(obj,"total",0)
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_FuLiFchoDay = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	return obj
end

maker.CST_FuidHid = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid",0)
	zd.initLiteSet(obj,"hid",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_Sjjuser = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"regtime",0)
	zd.initLiteSet(obj,"rwd",0)
	zd.initLiteSet(obj,"tzstate",0)
	zd.initLiteSet(obj,"tztime",0)
	return obj
end

maker.CST_ClubCZHDUserRwdList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SbossList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",1)
	zd.initLiteSet(obj,"gid",1)
	return obj
end

maker.CST_RiskBosshp = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"damage",0)
	zd.initLiteSet(obj,"heroid",0)
	return obj
end

maker.CST_ParamHid = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hid",0)
	return obj
end

maker.CST_GetTzrwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_giftInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dc",0)
	zd.initLiteSet(obj,"gift_id",0)
	zd.initLiteSet(obj,"is_free",0)
	zd.initLiteSet(obj,"is_limit",0)
	zd.initLiteSet(obj,"limit_num",0)
	zd.initLiteSet(obj,"profit_percent",0)
	zd.initLiteSet(obj,"rwd_items",zd.makeLiteArray(makerSC.SCT_rwdItems()))
	zd.initLiteSet(obj,"surplus_num",0)
	zd.initLiteSet(obj,"title","")
	return obj
end

maker.CST_QxUserFlower = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fid",0)
	return obj
end

maker.CST_DailyRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"rwd",0)
	return obj
end

maker.CST_Skuacbchat = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"gid",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"time",0)
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"user",maker.CST_fUserInfo())
	return obj
end

maker.CST_CShd912Buy = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_ancestralhallsonlist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"add",0)
	zd.initLiteSet(obj,"honor",0)
	zd.initLiteSet(obj,"jq",zd.makeLiteArray(makerSC.SCT_jqInfo()))
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_Scbosspkwin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"gx",0)
	zd.initLiteSet(obj,"hit",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	return obj
end

maker.CST_hd709Num = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_SC_GameMachine = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_GameMachineInfo())
	zd.initLiteSet(obj,"results",zd.makeLiteArray(makerSC.SCT_GameMachineResult()))
	return obj
end

maker.CST_ScKeatcp = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fhero",zd.makeLiteArray(makerSC.SCT_khero()))
	zd.initLiteSet(obj,"fwife",zd.makeLiteArray(makerSC.SCT_kwife()))
	return obj
end

maker.CST_OneBuyInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"islimit",0)
	zd.initLiteSet(obj,"item",maker.CST_ItemInfo())
	zd.initLiteSet(obj,"limit",0)
	zd.initLiteSet(obj,"need",0)
	zd.initLiteSet(obj,"price",0)
	zd.initLiteSet(obj,"vip",0)
	return obj
end

maker.CST_jxhscheckchat = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_MineId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"mineId",0)
	return obj
end

maker.CST_FuserStatus = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"status",0)
	return obj
end

maker.CST_LaoFangZombie = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"skill",zd.makeLiteArray(makerSC.SCT_ZombieSkill()))
	return obj
end

maker.CST_SC_redpackethuodonginfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"heaven",zd.makeLiteArray("SC_redpacketheaven"))
	zd.initLiteSet(obj,"info",maker.CST_Shdinfo())
	zd.initLiteSet(obj,"jindu",zd.makeLiteArray("SC_redpacketfuka"))
	return obj
end

maker.CST_CsRiskNpcarriveCoord = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"mx",0)
	zd.initLiteSet(obj,"my",0)
	zd.initLiteSet(obj,"resID",0)
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"x",0)
	zd.initLiteSet(obj,"y",0)
	return obj
end

maker.CST_UserPvbWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bmid",0)
	zd.initLiteSet(obj,"damage",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	return obj
end

maker.CST_SCDllhdCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"need",maker.CST_ItemInfo())
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_SCDllhdCfgRwd()))
	return obj
end

maker.CST_ChatIdJingcheng = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_KuaMineOccupyHero = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fbHid",0)
	zd.initLiteSet(obj,"hid",0)
	zd.initLiteSet(obj,"itemId",0)
	zd.initLiteSet(obj,"no",0)
	return obj
end

maker.CST_WinRandWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"items",maker.CST_RandWin())
	return obj
end

maker.CST_fbshareinfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"get",0)
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	return obj
end

maker.CST_CSqxzbHero = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"heroId",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"turn",0)
	return obj
end

maker.CST_CShd431Get = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_bossHp = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hp",0)
	return obj
end

maker.CST_CsRiskjumpSpecialMap = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"mid",0)
	return obj
end

maker.CST_NewYearFight = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hurt",0)
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_MyRedTicketList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"etime",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"money",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"stime",0)
	return obj
end

maker.CST_SC_LlbkCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_Shdinfo())
	return obj
end

maker.CST_SC_System = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cp",maker.CST_SC_System_cp())
	zd.initLiteSet(obj,"error",maker.CST_errMsg())
	zd.initLiteSet(obj,"history_server_list",zd.makeLiteArray(makerSC.SCT_hisServerInfo()))
	zd.initLiteSet(obj,"intro",maker.CST_SystemIntro())
	zd.initLiteSet(obj,"itemLack",maker.CST_SC_itemLack())
	zd.initLiteSet(obj,"mse",maker.CST_mseInfo())
	zd.initLiteSet(obj,"notice",zd.makeLiteArray(makerSC.SCT_NoticeMsg()))
	zd.initLiteSet(obj,"randName",maker.CST_RandName())
	zd.initLiteSet(obj,"recommend_list",zd.makeLiteArray(0))
	zd.initLiteSet(obj,"server_info",zd.makeLiteArray(makerSC.SCT_ServerInfo()))
	zd.initLiteSet(obj,"server_list",zd.makeLiteArray(makerSC.SCT_Server()))
	zd.initLiteSet(obj,"sys",maker.CST_SysDate())
	zd.initLiteSet(obj,"time_zone",0)
	zd.initLiteSet(obj,"version","")
	zd.initLiteSet(obj,"white",0)
	zd.initLiteSet(obj,"window",maker.CST_SCSystemNotice())
	zd.initLiteSet(obj,"zone_list",zd.makeLiteArray(makerSC.SCT_zoneInfo()))
	return obj
end

maker.CST_SC_MonthTaskRwdType = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_SC_XianShi = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"clubbossdmg",maker.CST_XianShiAct())
	zd.initLiteSet(obj,"clubbosskill",maker.CST_XianShiAct())
	zd.initLiteSet(obj,"goeat",maker.CST_XianShiAct())
	zd.initLiteSet(obj,"killg2d",maker.CST_XianShiAct())
	zd.initLiteSet(obj,"loginday",maker.CST_XianShiAct())
	zd.initLiteSet(obj,"shiliup",maker.CST_XianShiAct())
	zd.initLiteSet(obj,"usebook",maker.CST_XianShiAct())
	zd.initLiteSet(obj,"usecash",maker.CST_XianShiAct())
	return obj
end

maker.CST_CHlist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"checked",0)
	zd.initLiteSet(obj,"chid",0)
	zd.initLiteSet(obj,"endT",0)
	zd.initLiteSet(obj,"getT",0)
	return obj
end

maker.CST_FBshareGetrwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_HbmyRedTicket = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_MyRedTicketList()))
	zd.initLiteSet(obj,"money",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_ItemInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",1)
	zd.initLiteSet(obj,"id","")
	zd.initLiteSet(obj,"label",0)
	return obj
end

maker.CST_SC_centralattackwarlog = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"city",0)
	zd.initLiteSet(obj,"fname","")
	zd.initLiteSet(obj,"fuid",0)
	zd.initLiteSet(obj,"keng",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"time",0)
	zd.initLiteSet(obj,"uid",0)
	zd.initLiteSet(obj,"win",0)
	return obj
end

maker.CST_CS_clearBigEmojiNews = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CS_HerobindHero = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bindhid",0)
	zd.initLiteSet(obj,"hid",0)
	return obj
end

maker.CST_Hid = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hid",0)
	return obj
end

maker.CST_SC_Story = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"heroFavor",zd.makeLiteArray("SC_StoryHeroFavor"))
	zd.initLiteSet(obj,"npcFavor",zd.makeLiteArray("SC_StoryNpcFavor"))
	zd.initLiteSet(obj,"storyBtn",zd.makeLiteArray("SC_StoryStoryBtn"))
	zd.initLiteSet(obj,"storyUnlock","SC_StoryStoryUnlock")
	zd.initLiteSet(obj,"wifeFavor",zd.makeLiteArray("SC_StoryWifeFavor"))
	return obj
end

maker.CST_CYhChi = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid",0)
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"xwid",0)
	return obj
end

maker.CST_SC_hbhuodong = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hbInfo",maker.CST_Hbhblist())
	zd.initLiteSet(obj,"hblist",zd.makeLiteArray(makerSC.SCT_Hbhblist()))
	zd.initLiteSet(obj,"lastHb",maker.CST_HblastHb())
	zd.initLiteSet(obj,"mobai",maker.CST_Hbmobai())
	zd.initLiteSet(obj,"myRedList",zd.makeLiteArray(makerSC.SCT_HbmyRedList()))
	zd.initLiteSet(obj,"myRedTicket",maker.CST_HbmyRedTicket())
	zd.initLiteSet(obj,"myScore","XgMyScore")
	zd.initLiteSet(obj,"rankList",zd.makeLiteArray(makerSC.SCT_fUserInfo()))
	zd.initLiteSet(obj,"receiveRedList",zd.makeLiteArray(makerSC.SCT_HbreceiveRedList()))
	return obj
end

maker.CST_CS_sevendaytask = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_Null())
	zd.initLiteSet(obj,"rwd",maker.CST_cs_sevendaytask_rwd())
	zd.initLiteSet(obj,"rwd_final",maker.CST_Null())
	return obj
end

maker.CST_GuideNotic = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"platform","")
	return obj
end

maker.CST_CsRiskOperate = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"reserve",0)
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"x",0)
	zd.initLiteSet(obj,"y",0)
	return obj
end

maker.CST_heroId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_ryqdShopAndList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"list",zd.makeLiteArray("ExchangeList"))
	zd.initLiteSet(obj,"shop",zd.makeLiteArray(makerSC.SCT_ryqdShop()))
	return obj
end

maker.CST_survey_question = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"A","")
	zd.initLiteSet(obj,"B","")
	zd.initLiteSet(obj,"C","")
	zd.initLiteSet(obj,"D","")
	zd.initLiteSet(obj,"have",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"must",0)
	zd.initLiteSet(obj,"problem","")
	return obj
end

maker.CST_Shdrwd1 = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"need",0)
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_WordShopId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_KefuInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"body","")
	return obj
end

maker.CST_SetPanAn = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"win",0)
	return obj
end

maker.CST_SC_LlbkStarLog = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"itemid",0)
	zd.initLiteSet(obj,"kind",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_CDelClub = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"password",0)
	return obj
end

maker.CST_CShd332Buy = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_Csczhlinfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"allmoney",0)
	zd.initLiteSet(obj,"allrwd",zd.makeLiteArray(makerSC.SCT_cznhlallrwd()))
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"chongzhi",zd.makeLiteArray(makerSC.SCT_CSCzhl()))
	zd.initLiteSet(obj,"eTime",0)
	zd.initLiteSet(obj,"endtime",0)
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray("czhlrwd"))
	zd.initLiteSet(obj,"sTime",0)
	return obj
end

maker.CST_IDNUM = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",1)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_ParamWid = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"wid",0)
	return obj
end

maker.CST_CS_GuideButton = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"opt","")
	return obj
end

maker.CST_CS_BeiJing = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"checkBeiJing",maker.CST_ChHaoId())
	zd.initLiteSet(obj,"offBeiJing",maker.CST_ChHaoId())
	zd.initLiteSet(obj,"setBeiJing",maker.CST_ChHaoId())
	return obj
end

maker.CST_ZQCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cz_money",0)
	zd.initLiteSet(obj,"exchange",zd.makeLiteArray("ExchangeList"))
	zd.initLiteSet(obj,"rand_get",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"recover_money",0)
	zd.initLiteSet(obj,"rwd","NewYearrwdType")
	zd.initLiteSet(obj,"seek_need",0)
	zd.initLiteSet(obj,"seek_prob_rand",zd.makeLiteArray(makerSC.SCT_ZQCfgUseSeekRrobRand()))
	zd.initLiteSet(obj,"seek_rwd",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"shop",zd.makeLiteArray("Shopxg"))
	zd.initLiteSet(obj,"today",maker.CST_CdLabel())
	zd.initLiteSet(obj,"use",zd.makeLiteArray(makerSC.SCT_ZQCfgUse()))
	return obj
end

maker.CST_ZQUser = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cz_money",0)
	zd.initLiteSet(obj,"cz_rwd",0)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"exchange",zd.makeLiteArray(makerSC.SCT_QxUserExchange()))
	zd.initLiteSet(obj,"hd_score",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_QxUserExchange()))
	zd.initLiteSet(obj,"login",0)
	zd.initLiteSet(obj,"lq",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"rabbit",0)
	zd.initLiteSet(obj,"recharge",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"shop",zd.makeLiteArray(makerSC.SCT_QxUserExchange()))
	zd.initLiteSet(obj,"wife",0)
	return obj
end

maker.CST_SC_centralattackherolist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"add",0)
	zd.initLiteSet(obj,"addshili",0)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"hid",0)
	zd.initLiteSet(obj,"shili",0)
	return obj
end

maker.CST_ScHunting = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"cnum",0)
	zd.initLiteSet(obj,"free",0)
	zd.initLiteSet(obj,"hnum",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_HuntList()))
	zd.initLiteSet(obj,"need",0)
	zd.initLiteSet(obj,"rwd",maker.CST_HuntRwd())
	return obj
end

maker.CST_Ssltip = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid",0)
	return obj
end

maker.CST_CsRiskStory = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_riskLevelInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"exp",0)
	zd.initLiteSet(obj,"level",0)
	return obj
end

maker.CST_SCclubKuapkzr = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"diclub",maker.CST_SCclubKuaCszr())
	zd.initLiteSet(obj,"myclub",maker.CST_SCclubKuaCszr())
	return obj
end

maker.CST_cleanDressNewsType = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CS_Share = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"shared",maker.CST_NULL())
	return obj
end

maker.CST_SC_guideConsume = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_SC_guideConsumeInfo())
	return obj
end

maker.CST_ryqdShop = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"is_limit",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"limit",0)
	zd.initLiteSet(obj,"need",maker.CST_ItemInfo())
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"sevid",0)
	return obj
end

maker.CST_SCChatFramelist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdNum())
	zd.initLiteSet(obj,"get",1)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"news",0)
	return obj
end

maker.CST_CSkuaPKCszr = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid",maker.CST_Null())
	return obj
end

maker.CST_CardType = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"days",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CsTsGiveup = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"gid",0)
	return obj
end

maker.CST_ItemCount = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"num",1)
	return obj
end

maker.CST_SC_FourGoodRwdLevel = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_RiskFollow = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_idBase = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_BanishHeroList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hid",0)
	return obj
end

maker.CST_CtestOrderBack = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",maker.CST_Null())
	return obj
end

maker.CST_CJlInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",maker.CST_Null())
	return obj
end

maker.CST_cs_sevendaytask_rwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_sc_sevendaytask_info = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_sc_sevendaytask_list()))
	zd.initLiteSet(obj,"over",0)
	zd.initLiteSet(obj,"rwd_final",0)
	zd.initLiteSet(obj,"tip",0)
	return obj
end

maker.CST_CS_hd552Dispatch = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"city",0)
	zd.initLiteSet(obj,"fuid",0)
	zd.initLiteSet(obj,"heros","")
	zd.initLiteSet(obj,"keng",0)
	zd.initLiteSet(obj,"team",0)
	return obj
end

maker.CST_CS_HD496BuyLv = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"lv",0)
	return obj
end

maker.CST_ChHaoId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"chid",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CShd344Validate = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"code",0)
	zd.initLiteSet(obj,"phone",0)
	return obj
end

maker.CST_fUserqjlist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"chatFrame",0)
	zd.initLiteSet(obj,"chenghao",0)
	zd.initLiteSet(obj,"dress",0)
	zd.initLiteSet(obj,"frame",0)
	zd.initLiteSet(obj,"head",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"job",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"num2",0)
	zd.initLiteSet(obj,"num3",0)
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"sex",0)
	zd.initLiteSet(obj,"signName","")
	zd.initLiteSet(obj,"tip",0)
	zd.initLiteSet(obj,"uid",0)
	zd.initLiteSet(obj,"vip",0)
	zd.initLiteSet(obj,"vipStatus",1)
	return obj
end

maker.CST_SkinId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CS_Hd760Rank = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CS_Login_getHistory = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"openid","")
	zd.initLiteSet(obj,"platform","")
	return obj
end

maker.CST_CRand = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"CRand",maker.CST_Null())
	return obj
end

maker.CST_CSqxzbCszr = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"turn",0)
	return obj
end

maker.CST_InviteCfgInvite = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"limit",0)
	zd.initLiteSet(obj,"link","")
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	return obj
end

maker.CST_SC_opentip = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"open",0)
	zd.initLiteSet(obj,"unlock",0)
	return obj
end

maker.CST_SC_Mail = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"mailList",zd.makeLiteArray(makerSC.SCT_MailInfo()))
	return obj
end

maker.CST_CsTsGetRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_zhuchenginfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"boite",0)
	zd.initLiteSet(obj,"cabinet",0)
	zd.initLiteSet(obj,"club",0)
	zd.initLiteSet(obj,"courtyard",0)
	zd.initLiteSet(obj,"hanlin",0)
	zd.initLiteSet(obj,"laofang",0)
	zd.initLiteSet(obj,"wordboss",0)
	zd.initLiteSet(obj,"yamen",0)
	return obj
end

maker.CST_RandName = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"name","")
	return obj
end

maker.CST_heroSkillIdType = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"sid",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_scqian = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"valid",0)
	return obj
end

maker.CST_FuLiFChoClose = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"noShow",0)
	return obj
end

maker.CST_RiskMap = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"x",0)
	zd.initLiteSet(obj,"y",0)
	return obj
end

maker.CST_MailInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"content","")
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfox()))
	zd.initLiteSet(obj,"sendTime",0)
	zd.initLiteSet(obj,"status",0)
	zd.initLiteSet(obj,"title","")
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SC_itemLack = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"kind",0)
	return obj
end

maker.CST_SeverInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"isHe",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"sid",0)
	return obj
end

maker.CST_CsCourtyardExchange = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_makeSkin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"makeHeroList",zd.makeLiteArray(makerSC.SCT_makeSkinList()))
	zd.initLiteSet(obj,"makeWifeList",zd.makeLiteArray(makerSC.SCT_makeSkinList()))
	return obj
end

maker.CST_SCmyClubRid = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cName","")
	zd.initLiteSet(obj,"cRid",0)
	return obj
end

maker.CST_SC_fbhuodong = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fbshareinfo",maker.CST_fbshareinfo())
	return obj
end

maker.CST_SysDate = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"nextday",0)
	zd.initLiteSet(obj,"time",0)
	return obj
end

maker.CST_SCJhlist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdNum())
	zd.initLiteSet(obj,"get",1)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_MapInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bgimg",1)
	zd.initLiteSet(obj,"title","")
	return obj
end

maker.CST_SC_MsgWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fight",maker.CST_FightWin())
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"newnpc",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"pet","PetInfo")
	zd.initLiteSet(obj,"vip",0)
	return obj
end

maker.CST_ClubCZHDCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_Shdrwd()))
	return obj
end

maker.CST_ItemInfox = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",1)
	zd.initLiteSet(obj,"id","")
	zd.initLiteSet(obj,"idx","")
	return obj
end

maker.CST_autumnuser = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bag",maker.CST_ItemInfo())
	zd.initLiteSet(obj,"buynum",0)
	zd.initLiteSet(obj,"curhdscore",0)
	zd.initLiteSet(obj,"hdscore",0)
	return obj
end

maker.CST_fUserInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"beijing",0)
	zd.initLiteSet(obj,"chatFrame",0)
	zd.initLiteSet(obj,"chenghao",0)
	zd.initLiteSet(obj,"clubname","")
	zd.initLiteSet(obj,"dress",0)
	zd.initLiteSet(obj,"duanwei",0)
	zd.initLiteSet(obj,"extra_ch","")
	zd.initLiteSet(obj,"frame",0)
	zd.initLiteSet(obj,"guajian",0)
	zd.initLiteSet(obj,"head",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"isHe",0)
	zd.initLiteSet(obj,"job",0)
	zd.initLiteSet(obj,"lastlogin",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"maxmap",0)
	zd.initLiteSet(obj,"mingrenchenghao",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"num2",0)
	zd.initLiteSet(obj,"num3",0)
	zd.initLiteSet(obj,"num4","")
	zd.initLiteSet(obj,"offlineCh","")
	zd.initLiteSet(obj,"password","")
	zd.initLiteSet(obj,"pet_addi",0)
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"riskexp",0)
	zd.initLiteSet(obj,"risklevel",0)
	zd.initLiteSet(obj,"sex",0)
	zd.initLiteSet(obj,"shili",0)
	zd.initLiteSet(obj,"signName","")
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"uid",0)
	zd.initLiteSet(obj,"vip",0)
	zd.initLiteSet(obj,"vipStatus",1)
	return obj
end

maker.CST_OldPlayerBackRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_scfashionpreviewCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"shizhuang","")
	zd.initLiteSet(obj,"touxiang","")
	return obj
end

maker.CST_RiskUpBaoZang = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"x",0)
	zd.initLiteSet(obj,"y",0)
	return obj
end

maker.CST_SC_ComRankRange = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"re",0)
	zd.initLiteSet(obj,"rs",0)
	return obj
end

maker.CST_PlatGiftNotice = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"result",0)
	zd.initLiteSet(obj,"win",maker.CST_SC_Windows())
	return obj
end

maker.CST_hd238BuyParams = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_ClubCZHDClub = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_SC_WifePk = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day","SC_WifePk_Day")
	zd.initLiteSet(obj,"finfo",maker.CST_SC_WifePk_wife_finfo())
	zd.initLiteSet(obj,"flist",zd.makeLiteArray("SC_WifePk_wife_list"))
	zd.initLiteSet(obj,"info","SC_WifePk_Info")
	zd.initLiteSet(obj,"killlog",zd.makeLiteArray("Sc_WifePk_killlog"))
	zd.initLiteSet(obj,"myRid",maker.CST_Scbrid())
	zd.initLiteSet(obj,"rank",zd.makeLiteArray(makerSC.SCT_Scblist()))
	zd.initLiteSet(obj,"result",maker.CST_Scwifepkresult())
	zd.initLiteSet(obj,"shop","SC_WifePk_Shop")
	return obj
end

maker.CST_CSkuaPKusejn = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"heroid",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CS_setSignName = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"text","")
	return obj
end

maker.CST_CDayGongXian = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dcid",0)
	zd.initLiteSet(obj,"free",0)
	return obj
end

maker.CST_csBuildGivup = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buildingId",0)
	zd.initLiteSet(obj,"buildingLevel",0)
	zd.initLiteSet(obj,"locationId",0)
	return obj
end

maker.CST_HuntList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"baseRwd",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"eTime",0)
	zd.initLiteSet(obj,"heroes",zd.makeLiteArray("cabinetHeroes"))
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"nature",0)
	zd.initLiteSet(obj,"randRwd",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"require",0)
	zd.initLiteSet(obj,"sTime",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"time",0)
	zd.initLiteSet(obj,"use",maker.CST_ItemInfo())
	return obj
end

maker.CST_csBuildRevenge = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buildingId",0)
	zd.initLiteSet(obj,"buildingLevel",0)
	zd.initLiteSet(obj,"heros",zd.makeLiteArray(makerSC.SCT_KuaMineOccupyHero()))
	zd.initLiteSet(obj,"locationId",0)
	zd.initLiteSet(obj,"logId",0)
	return obj
end

maker.CST_SC_LlbkInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cardID",0)
	zd.initLiteSet(obj,"luckyDraw",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_RandWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	return obj
end

maker.CST_SCclubKuaWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid",0)
	zd.initLiteSet(obj,"fcid",0)
	zd.initLiteSet(obj,"fname","")
	zd.initLiteSet(obj,"gejifen",0)
	zd.initLiteSet(obj,"isWin",0)
	zd.initLiteSet(obj,"name","")
	return obj
end

maker.CST_Sc_survey = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"SurveyInfo",maker.CST_SurveyInfo())
	return obj
end

maker.CST_SyhInfo2 = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cashFyNum",0)
	zd.initLiteSet(obj,"credit",0)
	zd.initLiteSet(obj,"dress",0)
	zd.initLiteSet(obj,"ep",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"invite",0)
	zd.initLiteSet(obj,"job",1)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray("xwInfo2"))
	zd.initLiteSet(obj,"lockTime",maker.CST_CdLabel())
	zd.initLiteSet(obj,"ltime",maker.CST_CdLabel())
	zd.initLiteSet(obj,"maxnum",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"sex",1)
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_SConekeybmap = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"need",0)
	zd.initLiteSet(obj,"time",0)
	zd.initLiteSet(obj,"yub",0)
	return obj
end

maker.CST_CShd913type = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_UserInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cash",0)
	zd.initLiteSet(obj,"exp",0)
	zd.initLiteSet(obj,"guide",0)
	zd.initLiteSet(obj,"guideSub",0)
	zd.initLiteSet(obj,"language","")
	zd.initLiteSet(obj,"lastLogin",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"music",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"regTime",0)
	zd.initLiteSet(obj,"step",0)
	zd.initLiteSet(obj,"uid",0)
	zd.initLiteSet(obj,"vip",0)
	zd.initLiteSet(obj,"vipExp",0)
	zd.initLiteSet(obj,"voice",0)
	return obj
end

maker.CST_CShd434AddBless = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bless","")
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SC_System_cp = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"force",0)
	zd.initLiteSet(obj,"link","")
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"tag","")
	return obj
end

maker.CST_GerdanRankRwdWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"kill",3)
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"score2",0)
	return obj
end

maker.CST_SC_bigEmojiidlist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_Hd331getPaghang = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",1)
	return obj
end

maker.CST_SC_fashionpreview = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fashionpreviewCfg",maker.CST_scfashionpreviewCfg())
	return obj
end

maker.CST_SCPoolHuodongCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"base","SCDrawHuodongCfgBase")
	zd.initLiteSet(obj,"card",zd.makeLiteArray("SCDrawHuodongCfgCard"))
	zd.initLiteSet(obj,"money",0)
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"recharge",zd.makeLiteArray("SCDrawHuodongCfgRecharge"))
	return obj
end

maker.CST_FightMember = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"army",1000)
	zd.initLiteSet(obj,"army_max",10000)
	zd.initLiteSet(obj,"army_type","npc1")
	zd.initLiteSet(obj,"coin",100)
	zd.initLiteSet(obj,"die",1000)
	zd.initLiteSet(obj,"e1",100)
	zd.initLiteSet(obj,"e2",100)
	zd.initLiteSet(obj,"index",1)
	zd.initLiteSet(obj,"itype",1)
	zd.initLiteSet(obj,"level",1)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"user",maker.CST_fUserInfo())
	return obj
end

maker.CST_joinInfos = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"credit",0)
	zd.initLiteSet(obj,"fuid",0)
	zd.initLiteSet(obj,"score",0)
	return obj
end

maker.CST_SSetuback = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CYhGo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid",0)
	return obj
end

maker.CST_hd850AnswerInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"option",0)
	return obj
end

maker.CST_ItemInfoTip = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"kind",0)
	zd.initLiteSet(obj,"tip",0)
	return obj
end

maker.CST_BHCZHDUser = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cz",zd.makeLiteArray(makerSC.SCT_BHCZHDUserCz()))
	zd.initLiteSet(obj,"inday",0)
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_BHCZHDUserRwd()))
	zd.initLiteSet(obj,"today",0)
	return obj
end

maker.CST_SC_Translate = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"result",maker.CST_SC_TranslateResult())
	return obj
end

maker.CST_CS_Story = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"chooseStory",maker.CST_CS_ChooseStory())
	zd.initLiteSet(obj,"clickBtn",maker.CST_CS_StoryClickBtn())
	zd.initLiteSet(obj,"readStory",maker.CST_CS_StoryReadStory())
	return obj
end

maker.CST_CdjyNum = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"label","")
	zd.initLiteSet(obj,"max",0)
	zd.initLiteSet(obj,"next",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_CS_Hd650fGroupBuy = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SC_sevendaytask = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_sc_sevendaytask_info())
	return obj
end

maker.CST_SReadJfStory = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"chapter",0)
	zd.initLiteSet(obj,"middle",0)
	zd.initLiteSet(obj,"point",0)
	return obj
end

maker.CST_CClubBosslog = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_WordMyScore = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"myScore",0)
	zd.initLiteSet(obj,"myScorerank",0)
	return obj
end

maker.CST_SC_wannengShop = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_wannengInfo())
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_wannengShopList()))
	return obj
end

maker.CST_CClubBossPK = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cbid",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_hd709ExchangeParams = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CRandomChi = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SC_WordBoss = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"g2dft",zd.makeLiteArray(makerSC.SCT_FightList()))
	zd.initLiteSet(obj,"g2dkill",zd.makeLiteArray(makerSC.SCT_fUserInfo()))
	zd.initLiteSet(obj,"ge2dan",maker.CST_WBGe2Dan())
	zd.initLiteSet(obj,"ge2danMyDmg",maker.CST_WordG2dMyDmgRk())
	zd.initLiteSet(obj,"hurtRank",zd.makeLiteArray(makerSC.SCT_fUserInfo()))
	zd.initLiteSet(obj,"menggu",maker.CST_WBMengGu())
	zd.initLiteSet(obj,"mgft",zd.makeLiteArray(makerSC.SCT_FightList()))
	zd.initLiteSet(obj,"myScore",maker.CST_WordMyScore())
	zd.initLiteSet(obj,"root",maker.CST_WordBossRoot())
	zd.initLiteSet(obj,"rwdLog",zd.makeLiteArray(makerSC.SCT_fUserInfo()))
	zd.initLiteSet(obj,"scoreRank",zd.makeLiteArray(makerSC.SCT_fUserInfo()))
	zd.initLiteSet(obj,"shop",maker.CST_WordShop())
	zd.initLiteSet(obj,"win",maker.CST_WordBossWin())
	return obj
end

maker.CST_HitgerdanWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"damage",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"score2",0)
	return obj
end

maker.CST_RfPaiHang = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CS_hd552GetZhen = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"city",0)
	zd.initLiteSet(obj,"keng",0)
	return obj
end

maker.CST_IdAuthen = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cardid","")
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"openid","")
	zd.initLiteSet(obj,"platform","")
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_BHCZUIDINFO = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cons",0)
	zd.initLiteSet(obj,"cztime",0)
	zd.initLiteSet(obj,"post",4)
	zd.initLiteSet(obj,"username","")
	return obj
end

maker.CST_ladder_gongxun = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hdscore",0)
	zd.initLiteSet(obj,"jifen",0)
	zd.initLiteSet(obj,"score",0)
	return obj
end

maker.CST_CsRiskRecover = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_hd745playparams = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_QxWinLamp = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"content","")
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_SCjuece = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"content","")
	return obj
end

maker.CST_ScTansuoSJList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"eid",0)
	zd.initLiteSet(obj,"gid","")
	zd.initLiteSet(obj,"hitTime",0)
	zd.initLiteSet(obj,"hp",0)
	zd.initLiteSet(obj,"time",0)
	return obj
end

maker.CST_mobiles = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg",maker.CST_mobilelist())
	return obj
end

maker.CST_hd699checkChatByType = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_zpfluser = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"isdraw",1)
	zd.initLiteSet(obj,"isswitch",2)
	zd.initLiteSet(obj,"pt_last",maker.CST_pt_list())
	zd.initLiteSet(obj,"pt_num",0)
	zd.initLiteSet(obj,"zj_prize",zd.makeLiteArray(makerSC.SCT_zj_list()))
	return obj
end

maker.CST_CxxlMove = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"map","")
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"score",0)
	return obj
end

maker.CST_Scbrid = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cname","")
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"vip",0)
	return obj
end

maker.CST_CXxInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",maker.CST_Null())
	return obj
end

maker.CST_CsRischoiceMakeTask = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"choice",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_UserJob = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"job",0)
	zd.initLiteSet(obj,"sex",0)
	return obj
end

maker.CST_zoneInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"down_url","")
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"test_tag",0)
	zd.initLiteSet(obj,"time_zone",0)
	zd.initLiteSet(obj,"url","")
	zd.initLiteSet(obj,"zid",0)
	return obj
end

maker.CST_ScTansuoCJ = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"rwd",0)
	return obj
end

maker.CST_CsRiskBaoZangList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"zb",0)
	return obj
end

maker.CST_CSbuildAllPai = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CsRiskDarts = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"mid",0)
	zd.initLiteSet(obj,"x",0)
	zd.initLiteSet(obj,"y",0)
	return obj
end

maker.CST_KuaMineRevenge = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"heros",zd.makeLiteArray(makerSC.SCT_KuaMineOccupyHero()))
	zd.initLiteSet(obj,"logId",0)
	zd.initLiteSet(obj,"mineId",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SC_Windows = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"content","")
	zd.initLiteSet(obj,"foot","")
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"tiptype",0)
	zd.initLiteSet(obj,"title","")
	return obj
end

maker.CST_Shdrwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"jiazhi",0)
	zd.initLiteSet(obj,"need",0)
	return obj
end

maker.CST_SC_dxhuodong = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"user",maker.CST_DxUser())
	return obj
end

maker.CST_SCclubKuahit = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cname","")
	zd.initLiteSet(obj,"isWin",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_SChitlist()))
	zd.initLiteSet(obj,"servid",0)
	return obj
end

maker.CST_all_answer = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id","")
	return obj
end

maker.CST_CSbeamingBag = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_cs_getSkinshop = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"kind",0)
	zd.initLiteSet(obj,"price",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_jdFuidHid = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid",0)
	zd.initLiteSet(obj,"hid",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SC_Discord = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"status",0)
	zd.initLiteSet(obj,"url","")
	return obj
end

maker.CST_Chd297Guid = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid",0)
	return obj
end

maker.CST_CxshdRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",maker.CST_Null())
	return obj
end

maker.CST_CS_HD496TaskWeek = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"week",0)
	return obj
end

maker.CST_CSbuildPai = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"heroid",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"slot",0)
	return obj
end

maker.CST_FuLiAddwxqq = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"host",maker.CST_ItemInfo())
	zd.initLiteSet(obj,"index",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"num","")
	return obj
end

maker.CST_SCldjcbkhdUser = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_idBase()))
	zd.initLiteSet(obj,"sign",0)
	return obj
end

maker.CST_ChengJiuRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CS_ImgUploadFace = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"base64code","")
	return obj
end

maker.CST_shopBuyNew = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_GameMachineTrain = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"position",0)
	return obj
end

maker.CST_hd850TaskrewardInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_RiskCreateNpc = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"resID",0)
	zd.initLiteSet(obj,"x",0)
	zd.initLiteSet(obj,"y",0)
	return obj
end

maker.CST_RiskDartsList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"gid",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"kind",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"win",0)
	return obj
end

maker.CST_abcestralhallinto = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"honor",0)
	return obj
end

maker.CST_HitG2dWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	return obj
end

maker.CST_SC_ClubKuaYueInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cyzg",maker.CST_SC_clubKuaYueCyzg())
	zd.initLiteSet(obj,"isCy",0)
	zd.initLiteSet(obj,"mobai",0)
	zd.initLiteSet(obj,"mobaiMax",0)
	zd.initLiteSet(obj,"next",0)
	zd.initLiteSet(obj,"rwd",0)
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_MysteryOrder = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"exchangeCnt",0)
	zd.initLiteSet(obj,"gid",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_jingYingIdCount = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"jyid",0)
	zd.initLiteSet(obj,"num",1)
	return obj
end

maker.CST_CInfoSaveNote = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"note","")
	zd.initLiteSet(obj,"noteTitle","")
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_VerifySwitch = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"status",1)
	return obj
end

maker.CST_CS_GameMachine = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"draw",maker.CST_GameMachineDraw())
	zd.initLiteSet(obj,"getInfo",maker.CST_CustomId())
	return obj
end

maker.CST_UserImage = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"job",1)
	zd.initLiteSet(obj,"sex",1)
	return obj
end

maker.CST_SCOffline = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"beforeDuration",zd.makeLiteArray(makerSC.SCT_Duration()))
	zd.initLiteSet(obj,"lastRewardTime",0)
	zd.initLiteSet(obj,"privilege",0)
	zd.initLiteSet(obj,"receiveDuration",zd.makeLiteArray(makerSC.SCT_Duration()))
	zd.initLiteSet(obj,"todayDuration",zd.makeLiteArray(makerSC.SCT_Duration()))
	zd.initLiteSet(obj,"todayGetDuration",0)
	zd.initLiteSet(obj,"unlock",0)
	return obj
end

maker.CST_Sxslchuodong = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg",maker.CST_Scfglc())
	zd.initLiteSet(obj,"cons",0)
	zd.initLiteSet(obj,"has_rwd","")
	zd.initLiteSet(obj,"rwd",0)
	return obj
end

maker.CST_SCBuildHero = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"heroid",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SC_Daily = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dailysore_rwd",zd.makeLiteArray(makerSC.SCT_Scdailysore_rwd()))
	zd.initLiteSet(obj,"rwds",zd.makeLiteArray(makerSC.SCT_DailyRwd()))
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"tasks",zd.makeLiteArray(makerSC.SCT_DTask()))
	return obj
end

maker.CST_ryqdCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_Shdinfo())
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_Scbhdrwd()))
	return obj
end

maker.CST_errMsg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_FuLiTest_buy_decimal = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"rmb",0)
	return obj
end

maker.CST_SC_chat_frame = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_SCChatFramelist()))
	zd.initLiteSet(obj,"news",0)
	zd.initLiteSet(obj,"set",0)
	return obj
end

maker.CST_Riskbossinfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bosshp",0)
	zd.initLiteSet(obj,"zhanli",0)
	return obj
end

maker.CST_CSkuaPKinfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid",maker.CST_Null())
	return obj
end

maker.CST_Sjlcfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SC_FourGoodTaskInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"has",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"need",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"taskId",0)
	return obj
end

maker.CST_CS_Img = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"uploadFace",maker.CST_CS_ImgUploadFace())
	return obj
end

maker.CST_csBuildInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buildingId",0)
	zd.initLiteSet(obj,"buildingLevel",0)
	return obj
end

maker.CST_SC_PlatGift = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"daily",maker.CST_PlatGiftNotice())
	zd.initLiteSet(obj,"festival",maker.CST_PlatGiftNotice())
	zd.initLiteSet(obj,"novice",maker.CST_PlatGiftNotice())
	return obj
end

maker.CST_HeroInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"aep",maker.CST_fourEps())
	zd.initLiteSet(obj,"banish",0)
	zd.initLiteSet(obj,"bindhid",0)
	zd.initLiteSet(obj,"btep",maker.CST_fourEps())
	zd.initLiteSet(obj,"epskill",zd.makeLiteArray(makerSC.SCT_EpSkilInfo()))
	zd.initLiteSet(obj,"exp",0)
	zd.initLiteSet(obj,"gep",maker.CST_fourEps())
	zd.initLiteSet(obj,"ghskill",zd.makeLiteArray(makerSC.SCT_ghSkilInfo()))
	zd.initLiteSet(obj,"hep",maker.CST_fourEps())
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"level",1)
	zd.initLiteSet(obj,"mount",0)
	zd.initLiteSet(obj,"pkexp",0)
	zd.initLiteSet(obj,"pkskill",zd.makeLiteArray(makerSC.SCT_SkilInfo()))
	zd.initLiteSet(obj,"sbep",maker.CST_fourEps())
	zd.initLiteSet(obj,"senior",1)
	zd.initLiteSet(obj,"ur",0)
	zd.initLiteSet(obj,"urfree",0)
	zd.initLiteSet(obj,"wep",maker.CST_fourEps())
	zd.initLiteSet(obj,"whep",maker.CST_fourEps())
	zd.initLiteSet(obj,"whgep",maker.CST_fourEps())
	zd.initLiteSet(obj,"zcbei",0)
	zd.initLiteSet(obj,"zcep",maker.CST_fourEps())
	zd.initLiteSet(obj,"zep",maker.CST_fourEps())
	zd.initLiteSet(obj,"zz",maker.CST_fourEps())
	zd.initLiteSet(obj,"zzexp",0)
	return obj
end

maker.CST_SCguanKaRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"etime",0)
	zd.initLiteSet(obj,"stime",0)
	return obj
end

maker.CST_ScXxlCfgStrength = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"init",0)
	zd.initLiteSet(obj,"max",0)
	zd.initLiteSet(obj,"recure",0)
	return obj
end

maker.CST_SC_MonthTaskBase = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"days",0)
	zd.initLiteSet(obj,"eTime",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"maxRebate",0)
	zd.initLiteSet(obj,"news",0)
	zd.initLiteSet(obj,"refresh_count",0)
	zd.initLiteSet(obj,"refresh_free",0)
	zd.initLiteSet(obj,"refresh_price",0)
	zd.initLiteSet(obj,"reset_time",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"scoreEach",0)
	zd.initLiteSet(obj,"scorePrice",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"wife",0)
	zd.initLiteSet(obj,"word","")
	return obj
end

maker.CST_SC_Shop = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"firstRecharge",maker.CST_SC_firstRecharge())
	zd.initLiteSet(obj,"giftlist",maker.CST_ShopGiftInfo())
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_OneBuyInfo()))
	zd.initLiteSet(obj,"skinlist",maker.CST_ScSkinShop())
	zd.initLiteSet(obj,"vipgiftlist",maker.CST_ShopGiftInfo())
	return obj
end

maker.CST_cjoldPlayerBackCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"lastrwd",zd.makeLiteArray("oldPlayerRwd"))
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray("oldPlayerRwd"))
	zd.initLiteSet(obj,"sign",0)
	return obj
end

maker.CST_Sjlfy = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fymax",0)
	zd.initLiteSet(obj,"fynum",0)
	return obj
end

maker.CST_SClubInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cyBan",0)
	zd.initLiteSet(obj,"exp",0)
	zd.initLiteSet(obj,"fund",0)
	zd.initLiteSet(obj,"goldLimit",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"isJoin",0)
	zd.initLiteSet(obj,"job",0)
	zd.initLiteSet(obj,"laoma","")
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"members",zd.makeLiteArray(makerSC.SCT_membersInfo()))
	zd.initLiteSet(obj,"money",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"note1","")
	zd.initLiteSet(obj,"note2","")
	zd.initLiteSet(obj,"note3","")
	zd.initLiteSet(obj,"noteTitle1","")
	zd.initLiteSet(obj,"noteTitle2","")
	zd.initLiteSet(obj,"noteTitle3","")
	zd.initLiteSet(obj,"notice","")
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"outmsg","")
	zd.initLiteSet(obj,"password","")
	zd.initLiteSet(obj,"pwdTip",0)
	zd.initLiteSet(obj,"qq","")
	zd.initLiteSet(obj,"sex",0)
	zd.initLiteSet(obj,"vip",0)
	return obj
end

maker.CST_ancestralhallmy = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"news",zd.makeLiteArray("ancestralhallnews"))
	return obj
end

maker.CST_ScgInfoDirectDetail = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"endTime","")
	zd.initLiteSet(obj,"gift_attr",zd.makeLiteArray(makerSC.SCT_giftInfo()))
	zd.initLiteSet(obj,"lang_key","")
	zd.initLiteSet(obj,"startTime","")
	zd.initLiteSet(obj,"title","")
	zd.initLiteSet(obj,"type_id",0)
	return obj
end

maker.CST_hd786Exchange = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SC_bigEmojiredtype = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CS_hd760Buy = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CS_risk = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"add_qianduan",maker.CST_CsRiskQianduan())
	zd.initLiteSet(obj,"changeNpcState",maker.CST_CsRiskChangeNpcState())
	zd.initLiteSet(obj,"changeTexiao",maker.CST_CsRiskchangeTexiao())
	zd.initLiteSet(obj,"choiceMakeTask",maker.CST_CsRischoiceMakeTask())
	zd.initLiteSet(obj,"choiceOperate",maker.CST_CsRiskOperate())
	zd.initLiteSet(obj,"clickProtectTask",maker.CST_CsRiskclickProtectTask())
	zd.initLiteSet(obj,"comeback",maker.CST_heroId())
	zd.initLiteSet(obj,"darts",maker.CST_CsRiskDarts())
	zd.initLiteSet(obj,"exchange",maker.CST_CsRiskExchange())
	zd.initLiteSet(obj,"fightBoss",maker.CST_CsFightBoss())
	zd.initLiteSet(obj,"follow",maker.CST_CsRiskFollow())
	zd.initLiteSet(obj,"getAllrwd",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"getBaozang",maker.CST_CsRiskGetBaozang())
	zd.initLiteSet(obj,"getBossInfo",maker.CST_CsriskgetBossInfo())
	zd.initLiteSet(obj,"getExchangeInfo","")
	zd.initLiteSet(obj,"getInNewMap",maker.CST_CRiskgetinNewMap())
	zd.initLiteSet(obj,"getInRisk",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"getPowerInfo","")
	zd.initLiteSet(obj,"getTaskRwd",maker.CST_CsRiskGetRwd())
	zd.initLiteSet(obj,"jumpSpecialMap",maker.CST_CsRiskjumpSpecialMap())
	zd.initLiteSet(obj,"moveCoord",maker.CST_CsRiskMove())
	zd.initLiteSet(obj,"mysteryOrderExchange",maker.CST_CsMysteryExchange())
	zd.initLiteSet(obj,"npcarriveCoord",maker.CST_CsRiskNpcarriveCoord())
	zd.initLiteSet(obj,"orderRefresh","")
	zd.initLiteSet(obj,"play",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"playStory",maker.CST_CsRiskStory())
	zd.initLiteSet(obj,"randBaoZang",maker.CST_CsRiskRandBaoZang())
	zd.initLiteSet(obj,"recoverPower",maker.CST_CsRiskRecover())
	zd.initLiteSet(obj,"resetCd",maker.CST_CsRiskResetCd())
	zd.initLiteSet(obj,"shop",maker.CST_CsRiskShop())
	zd.initLiteSet(obj,"submitTask",maker.CST_CsRiskSubmitTask())
	zd.initLiteSet(obj,"unlock",maker.CST_CsRiskchangeUnlock())
	zd.initLiteSet(obj,"unlockMysteryOrder",maker.CST_CsMysteryUnlock())
	zd.initLiteSet(obj,"unlockNpcOrder",maker.CST_CsUnlockNpcOrder())
	zd.initLiteSet(obj,"upLevel","")
	zd.initLiteSet(obj,"workbench",maker.CST_CsRiskworkbench())
	return obj
end

maker.CST_SC_TanSuo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"onekeywin",zd.makeLiteArray(makerSC.SCT_ScTansuoWin()))
	zd.initLiteSet(obj,"tsCJ",zd.makeLiteArray(makerSC.SCT_ScTansuoCJ()))
	zd.initLiteSet(obj,"tsInfo",maker.CST_CdNumOpen())
	zd.initLiteSet(obj,"tsMap",zd.makeLiteArray(makerSC.SCT_ScTansuoMapList()))
	zd.initLiteSet(obj,"tsSJList",zd.makeLiteArray(makerSC.SCT_ScTansuoSJList()))
	zd.initLiteSet(obj,"tsSJLog",zd.makeLiteArray(makerSC.SCT_ScTansuoLog()))
	zd.initLiteSet(obj,"tsWife",zd.makeLiteArray(makerSC.SCT_ScTansuoWife()))
	zd.initLiteSet(obj,"win",zd.makeLiteArray(makerSC.SCT_ScTansuoWin()))
	return obj
end

maker.CST_CS_System = function()
	local obj = {}
	zd.makeLiteTable(obj)
	return obj
end

maker.CST_SC_czjjhuodong = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg",maker.CST_Sczcfg())
	zd.initLiteSet(obj,"user",maker.CST_Sjjuser())
	return obj
end

maker.CST_CSkuaPKrwdinfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",maker.CST_Null())
	return obj
end

maker.CST_Szcjjuser = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"longtime",0)
	zd.initLiteSet(obj,"regtime",0)
	zd.initLiteSet(obj,"rwd",0)
	zd.initLiteSet(obj,"tzstate",0)
	zd.initLiteSet(obj,"tztime",0)
	return obj
end

maker.CST_CS_Hd786Id = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_hd748Num = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_CSkuaLookWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid",0)
	return obj
end

maker.CST_CsRiskRandBaoZang = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"x",0)
	zd.initLiteSet(obj,"y",0)
	zd.initLiteSet(obj,"zb_list",zd.makeLiteArray(makerSC.SCT_CsRiskBaoZangList()))
	return obj
end

maker.CST_CS_ChengHao = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"check",maker.CST_ChHaoId())
	zd.initLiteSet(obj,"offChengHao",maker.CST_ChHaoId())
	zd.initLiteSet(obj,"setChengHao",maker.CST_ChHaoId())
	zd.initLiteSet(obj,"wyrwd",maker.CST_Cwyrwd())
	return obj
end

maker.CST_CS_Platvip = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"daily_info",maker.CST_Null())
	zd.initLiteSet(obj,"daily_rwd",maker.CST_PlatvipParam())
	zd.initLiteSet(obj,"tequan_info",maker.CST_Null())
	zd.initLiteSet(obj,"tequan_rwd",maker.CST_PlatvipParam())
	return obj
end

maker.CST_XShdGetRank = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CS_getGuideRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_ShopGift = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SC_Skin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"collect",zd.makeLiteArray(makerSC.SCT_idBase()))
	zd.initLiteSet(obj,"firstHeroList",zd.makeLiteArray(makerSC.SCT_firstHeroList()))
	zd.initLiteSet(obj,"firstWifeList",zd.makeLiteArray(makerSC.SCT_skinList()))
	zd.initLiteSet(obj,"heroList",zd.makeLiteArray(makerSC.SCT_skinList()))
	zd.initLiteSet(obj,"heroshop",maker.CST_skinShopInfo())
	zd.initLiteSet(obj,"make",maker.CST_makeSkin())
	zd.initLiteSet(obj,"myScore","XgMyScore")
	zd.initLiteSet(obj,"wifeList",zd.makeLiteArray(makerSC.SCT_skinList()))
	zd.initLiteSet(obj,"wifeshop",maker.CST_skinShopInfo())
	return obj
end

maker.CST_SsetChatFrame = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CsRiskExchange = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"gid",0)
	return obj
end

maker.CST_hisServerInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"time",0)
	return obj
end

maker.CST_heroSkillId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"sid",0)
	return obj
end

maker.CST_CS_Building = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buildingInfo",maker.CST_csBuildInfo())
	zd.initLiteSet(obj,"exchange","CxghdExchange")
	zd.initLiteSet(obj,"fightLos",maker.CST_ParamId())
	zd.initLiteSet(obj,"getGrabRwd",0)
	zd.initLiteSet(obj,"grab",maker.CST_csBuildOccupy())
	zd.initLiteSet(obj,"grabRwdInfo",0)
	zd.initLiteSet(obj,"info",maker.CST_Null())
	zd.initLiteSet(obj,"myLogs",maker.CST_Null())
	zd.initLiteSet(obj,"occupy",maker.CST_csBuildOccupy())
	zd.initLiteSet(obj,"recover",maker.CST_Null())
	zd.initLiteSet(obj,"recoverHero",maker.CST_ParamId())
	zd.initLiteSet(obj,"revenge",maker.CST_csBuildRevenge())
	return obj
end

maker.CST_CxxlSetMap = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"map","")
	return obj
end

maker.CST_CsCourtyardPlantFarm = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"zid",0)
	return obj
end

maker.CST_FirstYamenData = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"isHe",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"scorerank",0)
	zd.initLiteSet(obj,"sid",0)
	return obj
end

maker.CST_SC_Guide = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"special_guide",zd.makeLiteArray("SC_GuideSpecialGuide"))
	return obj
end

maker.CST_SC_zpfl = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg",maker.CST_zpflcfg())
	zd.initLiteSet(obj,"pmd",zd.makeLiteArray(makerSC.SCT_pmdlist()))
	zd.initLiteSet(obj,"user",maker.CST_zpfluser())
	return obj
end

maker.CST_ItemId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_ScXxlDayRwdID = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_PlatvipParam = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"pfvipgiftid",0)
	return obj
end

maker.CST_SC_signName = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"time",0)
	return obj
end

maker.CST_JyngYingWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"haoshi",zd.makeLiteArray(makerSC.SCT_JyngYingWinHaoShiWin()))
	return obj
end

maker.CST_TaskNum = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"item",maker.CST_UseItemInfo())
	zd.initLiteSet(obj,"type","")
	return obj
end

maker.CST_RiskShoplist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buyCnt",0)
	zd.initLiteSet(obj,"icon","")
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"limit",0)
	zd.initLiteSet(obj,"price",0)
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_UseItemInfo()))
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SC_antiAddiction = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"onlineTime",maker.CST_s_onlineTime())
	return obj
end

maker.CST_Sc_dispos = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bhdh","Sc_butlerpz")
	zd.initLiteSet(obj,"ch","Sc_butlerpz")
	zd.initLiteSet(obj,"jy","Sc_butlerpz")
	zd.initLiteSet(obj,"ld","Sc_butlerpz")
	zd.initLiteSet(obj,"school","Sc_butlerpz")
	zd.initLiteSet(obj,"sl","Sc_butlerpz")
	zd.initLiteSet(obj,"son","Sc_butlerpz")
	zd.initLiteSet(obj,"xunfang","Sc_butlerpz")
	zd.initLiteSet(obj,"zcdh","Sc_butlerpz")
	zd.initLiteSet(obj,"zw","Sc_butlerpz")
	return obj
end

maker.CST_ScCourtyardBase = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"get",0)
	zd.initLiteSet(obj,"kc",0)
	zd.initLiteSet(obj,"limit",zd.makeLiteArray(makerSC.SCT_IDNUM()))
	zd.initLiteSet(obj,"lv",1)
	zd.initLiteSet(obj,"mc",0)
	zd.initLiteSet(obj,"sp",0)
	return obj
end

maker.CST_ScCourtyardFarmList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"zid",0)
	zd.initLiteSet(obj,"zt",0)
	return obj
end

maker.CST_SC_redpackethuodong = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"allinfo",maker.CST_SC_redpackethuodonginfo())
	zd.initLiteSet(obj,"rwdLog",zd.makeLiteArray("redLog"))
	return obj
end

maker.CST_mobilelist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_mobileInfo())
	return obj
end

maker.CST_CS_Shop = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"directGiftList",maker.CST_NULL())
	zd.initLiteSet(obj,"shopBuy",maker.CST_shopBuyNew())
	zd.initLiteSet(obj,"shopGift",maker.CST_ShopGift())
	zd.initLiteSet(obj,"shopLimit",maker.CST_ShopLimit())
	zd.initLiteSet(obj,"shoplist",maker.CST_NULL())
	zd.initLiteSet(obj,"skinBuy",maker.CST_ShopLimit())
	zd.initLiteSet(obj,"skinShop",maker.CST_NULL())
	zd.initLiteSet(obj,"vipShopGift",maker.CST_ShopGift())
	return obj
end

maker.CST_RiskBaoZang = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"kind",0)
	zd.initLiteSet(obj,"x",0)
	zd.initLiteSet(obj,"y",0)
	return obj
end

maker.CST_CxHbget = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SCclubKuahitmyf = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"f",maker.CST_SCclubKuahit())
	zd.initLiteSet(obj,"my",maker.CST_SCclubKuahit())
	return obj
end

maker.CST_CSkuaLookHit = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid",0)
	return obj
end

maker.CST_CS_Hd760Id = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_ShopLimit = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CInfoClearNoteNews = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_RiskOrder = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"gid",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"npc_id",0)
	return obj
end

maker.CST_hd699TeammateId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"tmid",0)
	return obj
end

maker.CST_CSbuildUnlock = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CxxlUseItem = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"map","")
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"score",0)
	return obj
end

maker.CST_ClubCZHDUser = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"cz",zd.makeLiteArray(makerSC.SCT_ClubCZHDUserCz()))
	zd.initLiteSet(obj,"inday",0)
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_ClubCZHDUserRwd()))
	zd.initLiteSet(obj,"today",0)
	return obj
end

maker.CST_SSonshili = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_fHeroInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"aep",maker.CST_fourEps())
	zd.initLiteSet(obj,"banish",0)
	zd.initLiteSet(obj,"bindhid",0)
	zd.initLiteSet(obj,"btep",maker.CST_fourEps())
	zd.initLiteSet(obj,"dt",0)
	zd.initLiteSet(obj,"epskill",zd.makeLiteArray(makerSC.SCT_EpSkilInfo()))
	zd.initLiteSet(obj,"exp",0)
	zd.initLiteSet(obj,"gep",maker.CST_fourEps())
	zd.initLiteSet(obj,"ghskill",zd.makeLiteArray(makerSC.SCT_SkilInfo()))
	zd.initLiteSet(obj,"hep",maker.CST_fourEps())
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"level",1)
	zd.initLiteSet(obj,"mount",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"pkexp",0)
	zd.initLiteSet(obj,"pkskill",zd.makeLiteArray(makerSC.SCT_SkilInfo()))
	zd.initLiteSet(obj,"senior",1)
	zd.initLiteSet(obj,"skin",0)
	zd.initLiteSet(obj,"uid",0)
	zd.initLiteSet(obj,"ur",0)
	zd.initLiteSet(obj,"vip",0)
	zd.initLiteSet(obj,"wep",maker.CST_fourEps())
	zd.initLiteSet(obj,"zep",maker.CST_fourEps())
	zd.initLiteSet(obj,"zz",maker.CST_fourEps())
	zd.initLiteSet(obj,"zzexp",0)
	return obj
end

maker.CST_Scbhdrwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"member",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"rand",maker.CST_srand())
	return obj
end

maker.CST_FightWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"map",maker.CST_MapInfo())
	zd.initLiteSet(obj,"members",zd.makeLiteArray(makerSC.SCT_FightMember()))
	zd.initLiteSet(obj,"win",1)
	return obj
end

maker.CST_CS_Banish = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"addDesk","")
	zd.initLiteSet(obj,"banish",maker.CST_BanishHero())
	zd.initLiteSet(obj,"getrwd",maker.CST_idBase())
	zd.initLiteSet(obj,"info","")
	zd.initLiteSet(obj,"recall",maker.CST_BanishRecall())
	zd.initLiteSet(obj,"reduce",maker.CST_Banishreduce())
	return obj
end

maker.CST_CS_hd491SevInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CName = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SC_FourGoodWeekTask = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_SC_FourGoodTaskInfo()))
	return obj
end

maker.CST_SC_Code = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"exchange",maker.CST_SC_MsgWin())
	return obj
end

maker.CST_CS_FuLi = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"draw_gift",maker.CST_drawGift())
	zd.initLiteSet(obj,"fChoV2",maker.CST_ChoiceId())
	zd.initLiteSet(obj,"fbShare","")
	zd.initLiteSet(obj,"fcho",maker.CST_FuLiFchoDay())
	zd.initLiteSet(obj,"fchoclose",maker.CST_FuLiFChoClose())
	zd.initLiteSet(obj,"fulifund",maker.CST_Null())
	zd.initLiteSet(obj,"getSevenDaySignRwd",maker.CST_idBase())
	zd.initLiteSet(obj,"getclubrwd",maker.CST_FundFuliRwd())
	zd.initLiteSet(obj,"getcrossrwd",maker.CST_FundFuliRwd())
	zd.initLiteSet(obj,"getlevelrwd",maker.CST_FundFuliRwd())
	zd.initLiteSet(obj,"mooncard",maker.CST_FuLiCardId())
	zd.initLiteSet(obj,"qiandao",maker.CST_Null())
	zd.initLiteSet(obj,"test_buy_decimal",maker.CST_FuLiTest_buy_decimal())
	zd.initLiteSet(obj,"vip",maker.CST_FuLiVipId())
	return obj
end

maker.CST_GameMachineInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"adCnt",0)
	zd.initLiteSet(obj,"customId",0)
	zd.initLiteSet(obj,"exp",0)
	zd.initLiteSet(obj,"freeCnt",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"refreshTime",0)
	return obj
end

maker.CST_G2dKillWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	return obj
end

maker.CST_Sc_butler_info = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"ld",0)
	zd.initLiteSet(obj,"sl",0)
	return obj
end

maker.CST_SC_wutonghuser = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"chatFrame",0)
	zd.initLiteSet(obj,"chenghao",0)
	zd.initLiteSet(obj,"czz",0)
	zd.initLiteSet(obj,"frame",0)
	zd.initLiteSet(obj,"head",0)
	zd.initLiteSet(obj,"job",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"sex",0)
	return obj
end

maker.CST_ladder_fUserInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"duanwei",0)
	zd.initLiteSet(obj,"mingrenchenghao",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"quname","")
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_SC_JyngYing = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"army",maker.CST_CdjyNum())
	zd.initLiteSet(obj,"build",zd.makeLiteArray(makerSC.SCT_SCbuild()))
	zd.initLiteSet(obj,"coin",maker.CST_CdjyNum())
	zd.initLiteSet(obj,"exp",maker.CST_zwCdNum())
	zd.initLiteSet(obj,"food",maker.CST_CdjyNum())
	zd.initLiteSet(obj,"qzam",maker.CST_QzAiMin())
	zd.initLiteSet(obj,"win",maker.CST_JyngYingWin())
	return obj
end

maker.CST_Syrwlist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"items",maker.CST_ItemInfo())
	return obj
end

maker.CST_JyngYingWinHaoShiWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bas",0)
	zd.initLiteSet(obj,"zyid",0)
	return obj
end

maker.CST_DTask = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"rwd",0)
	return obj
end

maker.CST_SC_centralattackpkresult = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fherolist",zd.makeLiteArray(makerSC.SCT_SC_centralattackpkresulthero()))
	zd.initLiteSet(obj,"herolist",zd.makeLiteArray(makerSC.SCT_SC_centralattackpkresulthero()))
	zd.initLiteSet(obj,"win",0)
	return obj
end

maker.CST_SC_sdk = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"translateGeneral",maker.CST_translateGeneral())
	return obj
end

maker.CST_CS_setLang = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"lang","")
	return obj
end

maker.CST_newcjyxrecharge_get = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"can",0)
	zd.initLiteSet(obj,"had",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"need",0)
	return obj
end

maker.CST_RiskFinishedTaskList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_skinList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dt",0)
	zd.initLiteSet(obj,"flower",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"scorerank",0)
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_BqUser = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"paiqian",zd.makeLiteArray(makerSC.SCT_HeroInfo1()))
	zd.initLiteSet(obj,"rwd","NewYearrwdType")
	zd.initLiteSet(obj,"shili",0)
	return obj
end

maker.CST_RiskHerolist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"f",0)
	zd.initLiteSet(obj,"h",0)
	zd.initLiteSet(obj,"hid",0)
	return obj
end

maker.CST_SC_ButlerLixianResIdNum = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_riskUnlock = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"exchange",0)
	zd.initLiteSet(obj,"power",0)
	zd.initLiteSet(obj,"show",0)
	return obj
end

maker.CST_LoginIntro = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"t",0)
	return obj
end

maker.CST_Sjchdrwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"itemid",0)
	zd.initLiteSet(obj,"need",0)
	return obj
end

maker.CST_CustomId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"customId",0)
	return obj
end

maker.CST_CsRiskchangeUnlock = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_wannengShopList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"islimit",0)
	zd.initLiteSet(obj,"item",maker.CST_ItemInfo())
	zd.initLiteSet(obj,"limit",0)
	zd.initLiteSet(obj,"need",0)
	zd.initLiteSet(obj,"old",0)
	zd.initLiteSet(obj,"price",0)
	zd.initLiteSet(obj,"tip",0)
	zd.initLiteSet(obj,"vip",0)
	return obj
end

maker.CST_CShopRefresh = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",maker.CST_Null())
	return obj
end

maker.CST_drawGift = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_hd748GetBoxParams = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_WordBossWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"g2dHit",maker.CST_HitgerdanWin())
	zd.initLiteSet(obj,"g2dKill",maker.CST_GerdanKillWin())
	zd.initLiteSet(obj,"g2dRank",maker.CST_GerdanRankRwdWin())
	zd.initLiteSet(obj,"mghitfail",maker.CST_HitMgfailWin())
	zd.initLiteSet(obj,"mghitwin",maker.CST_HitMgwinWin())
	return obj
end

maker.CST_InviteCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"invite",maker.CST_InviteCfgInvite())
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_Shdrwd1()))
	return obj
end

maker.CST_CS_QianDao = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"rwd",maker.CST_Null())
	return obj
end

maker.CST_SC_ClubExtendDailyInfoCyCountDaily = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CsUnlockNpcOrder = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"npc_id",0)
	return obj
end

maker.CST_fUserInfo3 = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"beijing",0)
	zd.initLiteSet(obj,"chenghao",0)
	zd.initLiteSet(obj,"dress",0)
	zd.initLiteSet(obj,"dress_state",0)
	zd.initLiteSet(obj,"duanwei",0)
	zd.initLiteSet(obj,"extra_ch","")
	zd.initLiteSet(obj,"guajian",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"job",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"mingrenchenghao",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"num2",0)
	zd.initLiteSet(obj,"num3",0)
	zd.initLiteSet(obj,"pet_addi",0)
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"savelimit",0)
	zd.initLiteSet(obj,"sex",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"uid",0)
	zd.initLiteSet(obj,"vip",0)
	return obj
end

maker.CST_Sczcfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_Shdcfg())
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"need",maker.CST_Sneedcfg())
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_Srwdcfg()))
	return obj
end

maker.CST_CsRiskQianduan = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"index",0)
	zd.initLiteSet(obj,"step",0)
	return obj
end

maker.CST_CShopChange = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_RiskBoss = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bossname","")
	zd.initLiteSet(obj,"hp",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SC_FourGoodNoticeType = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"contents",zd.makeLiteArray(makerSC.SCT_SC_FourGoodNoticeContent()))
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_cityAndGenId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cityId",0)
	zd.initLiteSet(obj,"gid",0)
	return obj
end

maker.CST_FRefuseApply = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"refuse",0)
	return obj
end

maker.CST_heroCjRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dc",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_hd699AgreeToTeam = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"tmid",0)
	return obj
end

maker.CST_SC_clubKuaYueCyzg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cName","")
	zd.initLiteSet(obj,"cid",0)
	zd.initLiteSet(obj,"eTime",0)
	zd.initLiteSet(obj,"isNow",0)
	zd.initLiteSet(obj,"mz",maker.CST_UserEasyData())
	zd.initLiteSet(obj,"sTime",0)
	return obj
end

maker.CST_Householdcj = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"user",maker.CST_UserInfo())
	return obj
end

maker.CST_pmdList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"ef",1)
	zd.initLiteSet(obj,"id",1)
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"ob",1)
	zd.initLiteSet(obj,"reflection","")
	zd.initLiteSet(obj,"time",0)
	zd.initLiteSet(obj,"type",1)
	return obj
end

maker.CST_ScXxlInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"allinteg",0)
	zd.initLiteSet(obj,"cfg",maker.CST_ScXxlCfg())
	zd.initLiteSet(obj,"chongpai",0)
	zd.initLiteSet(obj,"hengpai",0)
	zd.initLiteSet(obj,"integ",0)
	zd.initLiteSet(obj,"map","")
	zd.initLiteSet(obj,"rwd",0)
	zd.initLiteSet(obj,"shupai",0)
	zd.initLiteSet(obj,"yangshen",0)
	return obj
end

maker.CST_SclubLog = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fname","")
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"num1",0)
	zd.initLiteSet(obj,"num2",0)
	zd.initLiteSet(obj,"other",0)
	zd.initLiteSet(obj,"time",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_zwCdNum = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdNum())
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"itemid",2)
	zd.initLiteSet(obj,"type",1)
	return obj
end

maker.CST_FuliFundInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buy",0)
	zd.initLiteSet(obj,"club_buy_num",0)
	zd.initLiteSet(obj,"club_rwd",zd.makeLiteArray(makerSC.SCT_GrowFundInfoLevel()))
	zd.initLiteSet(obj,"cross_buy_num",0)
	zd.initLiteSet(obj,"cross_rwd",zd.makeLiteArray(makerSC.SCT_GrowFundInfoLevel()))
	zd.initLiteSet(obj,"level_rwd",zd.makeLiteArray(makerSC.SCT_GrowFundInfoLevel()))
	zd.initLiteSet(obj,"news",0)
	return obj
end

maker.CST_RankShowListNum = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"club",10)
	zd.initLiteSet(obj,"hero",100)
	zd.initLiteSet(obj,"shili",100)
	zd.initLiteSet(obj,"skin",100)
	return obj
end

maker.CST_CS_StoryReadStory = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"storyZid",0)
	return obj
end

maker.CST_hd709GetBoxParams = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_Cx591fan = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SC_WifePk_wife_finfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"name","")
	return obj
end

maker.CST_Sc2048RewardDaily = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"dc",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"rwd",maker.CST_items_list())
	zd.initLiteSet(obj,"target",0)
	return obj
end

maker.CST_Cx591History = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"historyview",0)
	return obj
end

maker.CST_hd699ChatHisByType = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SC_TranslateResult = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"original","")
	zd.initLiteSet(obj,"translate","")
	return obj
end

maker.CST_CS_WifePk_study = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_hd608Buy = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",1)
	return obj
end

maker.CST_SkinWd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"wid",0)
	return obj
end

maker.CST_Cshd402All = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",maker.CST_Null())
	return obj
end

maker.CST_CIsJoin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"join",0)
	return obj
end

maker.CST_Srshop = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"beishu",1)
	zd.initLiteSet(obj,"currency","")
	zd.initLiteSet(obj,"dc",0)
	zd.initLiteSet(obj,"diamond",0)
	zd.initLiteSet(obj,"dollar",0)
	zd.initLiteSet(obj,"productid","")
	zd.initLiteSet(obj,"productname","")
	zd.initLiteSet(obj,"rate",0)
	zd.initLiteSet(obj,"rmb",0)
	zd.initLiteSet(obj,"selbs",0)
	zd.initLiteSet(obj,"type",1)
	return obj
end

maker.CST_ZombieSkill = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"exp",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"sid",0)
	zd.initLiteSet(obj,"skill_id",0)
	zd.initLiteSet(obj,"stage",0)
	zd.initLiteSet(obj,"unlock",0)
	zd.initLiteSet(obj,"upexp",0)
	zd.initLiteSet(obj,"zid",0)
	return obj
end

maker.CST_VipStatuss = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"status",1)
	return obj
end

maker.CST_OnekeyPveWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"deil",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"kill",0)
	zd.initLiteSet(obj,"kill_num",0)
	zd.initLiteSet(obj,"win",0)
	return obj
end

maker.CST_CS_huodong = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cbFirstInfo","")
	zd.initLiteSet(obj,"hd108GetRwd","Cxhd457Rwd")
	zd.initLiteSet(obj,"hd108Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd108Invited","hd108InvitedNo")
	zd.initLiteSet(obj,"hd201Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd201Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd202Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd202Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd203Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd203Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd204Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd204Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd205Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd205Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd206Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd206Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd207Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd207Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd208Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd208Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd209Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd209Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd210Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd210Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd211Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd211Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd212Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd212Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd213Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd213Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd214Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd214Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd215Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd215Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd216Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd216Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd217Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd217Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd218Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd218Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd219Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd219Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd220Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd220Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd221Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd221Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd222Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd222Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd223Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd223Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd224Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd224Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd225Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd225Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd226Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd226Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd227Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd227Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd228Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd228Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd229Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd229Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd235Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd235Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd236Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd236Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd237Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd237Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd250Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd251Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd252Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd253Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd254Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd255Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd256Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd257Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd258Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd259Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd260Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd260Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd261Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd261Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd262Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd262Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd263Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd263Rwd",maker.CST_Hd263getRwd())
	zd.initLiteSet(obj,"hd264Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd265Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd266Chat",maker.CST_ChatMsg())
	zd.initLiteSet(obj,"hd266Check",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd266Get",maker.CST_NULL())
	zd.initLiteSet(obj,"hd266Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd266Log",maker.CST_ChatId())
	zd.initLiteSet(obj,"hd266UserRank",maker.CST_NULL())
	zd.initLiteSet(obj,"hd266YXRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd267Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd268Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd270Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd270Rwd","CjchdRwd")
	zd.initLiteSet(obj,"hd271Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd271Rwd","CjghdRwd")
	zd.initLiteSet(obj,"hd272Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd272Rwd","CjghdRwd")
	zd.initLiteSet(obj,"hd273Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd273Rwd","CjghdRwd")
	zd.initLiteSet(obj,"hd274Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd274Rwd","CjghdRwd")
	zd.initLiteSet(obj,"hd275Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd275Rwd","CjghdRwd")
	zd.initLiteSet(obj,"hd276Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd276Rwd","CjghdRwd")
	zd.initLiteSet(obj,"hd280Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd280Rwd","")
	zd.initLiteSet(obj,"hd280buy","CxghdBuy")
	zd.initLiteSet(obj,"hd280exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd280paihang","")
	zd.initLiteSet(obj,"hd280play","CxghdPlay")
	zd.initLiteSet(obj,"hd281Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd281Rwd","")
	zd.initLiteSet(obj,"hd281buy","CxghdBuy")
	zd.initLiteSet(obj,"hd281exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd281getRwd","DnGetRecharge")
	zd.initLiteSet(obj,"hd281paihang","")
	zd.initLiteSet(obj,"hd281play","CxghdPlay")
	zd.initLiteSet(obj,"hd282Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd282Rwd","")
	zd.initLiteSet(obj,"hd282buy","CxghdBuy")
	zd.initLiteSet(obj,"hd282exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd282paihang","")
	zd.initLiteSet(obj,"hd282play","CxghdPlay")
	zd.initLiteSet(obj,"hd283Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd283Rwd","")
	zd.initLiteSet(obj,"hd283buy","CxghdBuy")
	zd.initLiteSet(obj,"hd283exchange",maker.CST_IDCOUNT())
	zd.initLiteSet(obj,"hd283paihang","")
	zd.initLiteSet(obj,"hd283play","CxghdPlay")
	zd.initLiteSet(obj,"hd284Check","")
	zd.initLiteSet(obj,"hd284Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd284Rwd","")
	zd.initLiteSet(obj,"hd284buy","CxghdBuy")
	zd.initLiteSet(obj,"hd284exchange",maker.CST_IDCOUNT())
	zd.initLiteSet(obj,"hd284getRwd","DnGetRecharge")
	zd.initLiteSet(obj,"hd284paihang","")
	zd.initLiteSet(obj,"hd284play","CxghdPlay")
	zd.initLiteSet(obj,"hd285Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd285buy","CxghdBuy")
	zd.initLiteSet(obj,"hd285buyGift","CxghdBuy")
	zd.initLiteSet(obj,"hd285getRwd","DnGetRecharge")
	zd.initLiteSet(obj,"hd286Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd286Rwd","")
	zd.initLiteSet(obj,"hd286buy","CxghdBuy")
	zd.initLiteSet(obj,"hd286exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd286getRwd","DnGetRecharge")
	zd.initLiteSet(obj,"hd286paihang","")
	zd.initLiteSet(obj,"hd286play","CxghdPlay")
	zd.initLiteSet(obj,"hd287Get",maker.CST_SevenSignRwd())
	zd.initLiteSet(obj,"hd287Info","")
	zd.initLiteSet(obj,"hd288Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd288Rwd","")
	zd.initLiteSet(obj,"hd288buy","CxghdBuy")
	zd.initLiteSet(obj,"hd288exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd288getRwd","DnGetRecharge")
	zd.initLiteSet(obj,"hd288paihang","")
	zd.initLiteSet(obj,"hd288play","CxghdPlay")
	zd.initLiteSet(obj,"hd289Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd289Rwd","")
	zd.initLiteSet(obj,"hd289buy","CxghdBuy")
	zd.initLiteSet(obj,"hd289exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd289getRwd","DnGetRecharge")
	zd.initLiteSet(obj,"hd289paihang","")
	zd.initLiteSet(obj,"hd289play","CxghdPlay")
	zd.initLiteSet(obj,"hd290Buy","Cxzpbuy")
	zd.initLiteSet(obj,"hd290Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd290Yao","Cxzpyao")
	zd.initLiteSet(obj,"hd290exchange",maker.CST_IDCOUNT())
	zd.initLiteSet(obj,"hd290log","Cxzplog")
	zd.initLiteSet(obj,"hd2912Buy","Cxsdbuy")
	zd.initLiteSet(obj,"hd2912Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd2912SRwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd2912Set","CxsdSet")
	zd.initLiteSet(obj,"hd2912Task","Cxzpdui")
	zd.initLiteSet(obj,"hd2912Zadan",maker.CST_Cxsdnd())
	zd.initLiteSet(obj,"hd2915AddBless",maker.CST_CShd434AddBless())
	zd.initLiteSet(obj,"hd2915Get",maker.CST_CShd332Up())
	zd.initLiteSet(obj,"hd2915Info","CxzcInfo")
	zd.initLiteSet(obj,"hd2915Paihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd2915Task","CxghdBuy")
	zd.initLiteSet(obj,"hd2915exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd2915play",maker.CST_CShd434Play())
	zd.initLiteSet(obj,"hd291Buy","Cxsdbuy")
	zd.initLiteSet(obj,"hd291Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd291Set","CxsdSet")
	zd.initLiteSet(obj,"hd291Zadan","Cxsdzd")
	zd.initLiteSet(obj,"hd292exchange","Cxzpdui")
	zd.initLiteSet(obj,"hd293Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd293Run",maker.CST_ChdList())
	zd.initLiteSet(obj,"hd293Rwd","Cxzpdui")
	zd.initLiteSet(obj,"hd293Task","Cxzpdui")
	zd.initLiteSet(obj,"hd294Get","CxzcGet")
	zd.initLiteSet(obj,"hd294Info","CxzcInfo")
	zd.initLiteSet(obj,"hd294Set","CxzcSet")
	zd.initLiteSet(obj,"hd294Zao","CxzcZao")
	zd.initLiteSet(obj,"hd294exchange","CxzcGet")
	zd.initLiteSet(obj,"hd294log","Cxzclog")
	zd.initLiteSet(obj,"hd294paihang","")
	zd.initLiteSet(obj,"hd295Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd295Paihang","")
	zd.initLiteSet(obj,"hd295getHb",maker.CST_CxHbget())
	zd.initLiteSet(obj,"hd295getHbInfo",maker.CST_CxHbget())
	zd.initLiteSet(obj,"hd295mobai","")
	zd.initLiteSet(obj,"hd295sendHb",maker.CST_CxHbSend())
	zd.initLiteSet(obj,"hd296Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd296Rwd","Cxzpdui")
	zd.initLiteSet(obj,"hd296Task","Cxzpdui")
	zd.initLiteSet(obj,"hd296Wa",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd297Buy","Chd297Buy")
	zd.initLiteSet(obj,"hd297DstwYao","Chd297DstwYao")
	zd.initLiteSet(obj,"hd297GRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd297Gget","Chd297cans")
	zd.initLiteSet(obj,"hd297Guid",maker.CST_Chd297Guid())
	zd.initLiteSet(obj,"hd297Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd297Log",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd297SRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd297Send","Chd297Send")
	zd.initLiteSet(obj,"hd297Sget","Chd297cans")
	zd.initLiteSet(obj,"hd297Yao","Chd297Yao")
	zd.initLiteSet(obj,"hd298Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd298buy","NewyearhdBuy")
	zd.initLiteSet(obj,"hd298exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd298paihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd298play","NewyearhdPlay")
	zd.initLiteSet(obj,"hd309Info","CxzcInfo")
	zd.initLiteSet(obj,"hd310Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd311Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd312Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd313Chat",maker.CST_ChatMsg())
	zd.initLiteSet(obj,"hd313Check",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd313Get",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd313Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd313Log",maker.CST_ChatId())
	zd.initLiteSet(obj,"hd313QuRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd313UserRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd313YXRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd314Chat",maker.CST_ChatMsg())
	zd.initLiteSet(obj,"hd314Check",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd314Get",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd314Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd314Log",maker.CST_ChatId())
	zd.initLiteSet(obj,"hd314QuRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd314UserRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd314YXRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd315Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd315Rank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd316Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd317Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd317Rwd",maker.CST_GetTzrwd())
	zd.initLiteSet(obj,"hd317invest",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd318Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd318Rwd",maker.CST_GetTzrwd())
	zd.initLiteSet(obj,"hd318invest",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd330Buy","Cxyxbuy")
	zd.initLiteSet(obj,"hd330Get",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd330Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd330Up","Cxzpup")
	zd.initLiteSet(obj,"hd330exchange","Cxzpdui")
	zd.initLiteSet(obj,"hd331Info","")
	zd.initLiteSet(obj,"hd331Paihang",maker.CST_Hd331getPaghang())
	zd.initLiteSet(obj,"hd331Rwd","")
	zd.initLiteSet(obj,"hd332Buy",maker.CST_CShd332Buy())
	zd.initLiteSet(obj,"hd332Get",maker.CST_CShd332Up())
	zd.initLiteSet(obj,"hd332Info","CxzcInfo")
	zd.initLiteSet(obj,"hd332Rank","CxzcInfo")
	zd.initLiteSet(obj,"hd332Ranking","CxzcInfo")
	zd.initLiteSet(obj,"hd332Up",maker.CST_CShd332Up())
	zd.initLiteSet(obj,"hd332Zou","CShd332Zou")
	zd.initLiteSet(obj,"hd332exchange",maker.CST_CShd332Up())
	zd.initLiteSet(obj,"hd332shop","CxzcInfo")
	zd.initLiteSet(obj,"hd333Buy","CShd333Buy")
	zd.initLiteSet(obj,"hd333Get","CShd333Up")
	zd.initLiteSet(obj,"hd333Info","CxzcInfo")
	zd.initLiteSet(obj,"hd333Zou","CShd333Zou")
	zd.initLiteSet(obj,"hd333exchange","CShd333Up")
	zd.initLiteSet(obj,"hd333shop","CxzcInfo")
	zd.initLiteSet(obj,"hd334Info","CxzcInfo")
	zd.initLiteSet(obj,"hd334SetHide",maker.CST_CShd334Set())
	zd.initLiteSet(obj,"hd336Buy",maker.CST_CShd336Buy())
	zd.initLiteSet(obj,"hd336Get",maker.CST_CShd336Up())
	zd.initLiteSet(obj,"hd336Info","CxzcInfo")
	zd.initLiteSet(obj,"hd336Rank","CxzcInfo")
	zd.initLiteSet(obj,"hd336Ranking","CxzcInfo")
	zd.initLiteSet(obj,"hd336Up",maker.CST_CShd336Up())
	zd.initLiteSet(obj,"hd336Zou","CShd336Zou")
	zd.initLiteSet(obj,"hd336exchange",maker.CST_IDCOUNT())
	zd.initLiteSet(obj,"hd336shop","CxzcInfo")
	zd.initLiteSet(obj,"hd337Get","CShd337Get")
	zd.initLiteSet(obj,"hd337Info","CxzcInfo")
	zd.initLiteSet(obj,"hd337Zhao","CShd337Zhao")
	zd.initLiteSet(obj,"hd339Buy","CS_hd339Buy")
	zd.initLiteSet(obj,"hd339Get","CShd339Get")
	zd.initLiteSet(obj,"hd339Hua","CShd339Hua")
	zd.initLiteSet(obj,"hd339Info","CxzcInfo")
	zd.initLiteSet(obj,"hd339exchange",maker.CST_IDCOUNT())
	zd.initLiteSet(obj,"hd339shop","CxzcInfo")
	zd.initLiteSet(obj,"hd340Info","CxzcInfo")
	zd.initLiteSet(obj,"hd340Ticket","CShd340Ticket")
	zd.initLiteSet(obj,"hd342Chat",maker.CST_ChatMsg())
	zd.initLiteSet(obj,"hd342Check",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd342Goto","CxzcInfo")
	zd.initLiteSet(obj,"hd342Info","CxzcInfo")
	zd.initLiteSet(obj,"hd342Log",maker.CST_ChatId())
	zd.initLiteSet(obj,"hd342Rewards","CxzcInfo")
	zd.initLiteSet(obj,"hd342Rwd","CxzcInfo")
	zd.initLiteSet(obj,"hd342Send","CShd342Send")
	zd.initLiteSet(obj,"hd343AddBless",maker.CST_CShd434AddBless())
	zd.initLiteSet(obj,"hd343GetGift","CxzcInfo")
	zd.initLiteSet(obj,"hd343GetRwd","CxzcInfo")
	zd.initLiteSet(obj,"hd343Info","CxzcInfo")
	zd.initLiteSet(obj,"hd343Paihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd343exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd343getLantern",maker.CST_CShd434Lantern())
	zd.initLiteSet(obj,"hd343play",maker.CST_CShd434Play())
	zd.initLiteSet(obj,"hd344GetRwd","CxzcInfo")
	zd.initLiteSet(obj,"hd344Info","CxzcInfo")
	zd.initLiteSet(obj,"hd344Validate",maker.CST_CShd344Validate())
	zd.initLiteSet(obj,"hd344send",maker.CST_CShd344Send())
	zd.initLiteSet(obj,"hd345Get","CSDsRedBagGet")
	zd.initLiteSet(obj,"hd345History",maker.CST_ChatId())
	zd.initLiteSet(obj,"hd345Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd345RbInfo","CSDsRedBagInfo")
	zd.initLiteSet(obj,"hd345Send","CSDsRedBag")
	zd.initLiteSet(obj,"hd346DstwPlay","zqdstwzgwy")
	zd.initLiteSet(obj,"hd346GetRwd","CxzcInfo")
	zd.initLiteSet(obj,"hd346GetSeekRwd","CxzcInfo")
	zd.initLiteSet(obj,"hd346Info","CxzcInfo")
	zd.initLiteSet(obj,"hd346Paihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd346SeekRabbit",maker.CST_CShd434Lantern())
	zd.initLiteSet(obj,"hd346SetWife","Xq_wife")
	zd.initLiteSet(obj,"hd346buy","NewyearhdBuy")
	zd.initLiteSet(obj,"hd346exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd346play",maker.CST_CShd434Play())
	zd.initLiteSet(obj,"hd347Info","CxzcInfo")
	zd.initLiteSet(obj,"hd349AddBless",maker.CST_CShd434AddBless())
	zd.initLiteSet(obj,"hd349GetGift","CxzcInfo")
	zd.initLiteSet(obj,"hd349GetRwd","CxzcInfo")
	zd.initLiteSet(obj,"hd349Info","CxzcInfo")
	zd.initLiteSet(obj,"hd349Paihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd349exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd349getLantern",maker.CST_CShd434Lantern())
	zd.initLiteSet(obj,"hd349play",maker.CST_CShd434Play())
	zd.initLiteSet(obj,"hd350Buy",maker.CST_CShd336Buy())
	zd.initLiteSet(obj,"hd350Get",maker.CST_CShd336Up())
	zd.initLiteSet(obj,"hd350Info","CxzcInfo")
	zd.initLiteSet(obj,"hd350Rank","CxzcInfo")
	zd.initLiteSet(obj,"hd350Ranking","CxzcInfo")
	zd.initLiteSet(obj,"hd350Up",maker.CST_CShd336Up())
	zd.initLiteSet(obj,"hd350Zou","CShd336Zou")
	zd.initLiteSet(obj,"hd350exchange",maker.CST_CShd336Up())
	zd.initLiteSet(obj,"hd350shop","CxzcInfo")
	zd.initLiteSet(obj,"hd351Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd351Yao","Cxzpyao")
	zd.initLiteSet(obj,"hd351exchange","Cxzpdui")
	zd.initLiteSet(obj,"hd351log","Cxzplog")
	zd.initLiteSet(obj,"hd352Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd352Run",maker.CST_ChdList())
	zd.initLiteSet(obj,"hd352Rwd","Cxzpdui")
	zd.initLiteSet(obj,"hd352Task","Cxzpdui")
	zd.initLiteSet(obj,"hd356Check","CxyyRwd")
	zd.initLiteSet(obj,"hd356Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd356Rwd","CxyyRwd")
	zd.initLiteSet(obj,"hd358Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd358Rwd","Cxzpdui")
	zd.initLiteSet(obj,"hd358Task","Cxzpdui")
	zd.initLiteSet(obj,"hd358Wa",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd364Rwd","")
	zd.initLiteSet(obj,"hd365Info","")
	zd.initLiteSet(obj,"hd365Pre",maker.CST_CShd365Pre())
	zd.initLiteSet(obj,"hd365Rwd",maker.CST_CShd365Rwd())
	zd.initLiteSet(obj,"hd387Info",maker.CST_Null())
	zd.initLiteSet(obj,"hd387Rwd",maker.CST_Null())
	zd.initLiteSet(obj,"hd388Buy","CS_Shuang11QdscBuy")
	zd.initLiteSet(obj,"hd388Flop",maker.CST_Null())
	zd.initLiteSet(obj,"hd388Info",maker.CST_Null())
	zd.initLiteSet(obj,"hd388Label",maker.CST_ParamType())
	zd.initLiteSet(obj,"hd388Mobai",maker.CST_Null())
	zd.initLiteSet(obj,"hd389Info",maker.CST_Null())
	zd.initLiteSet(obj,"hd390LevelRwd",maker.CST_CS_Hd390LevelRwd())
	zd.initLiteSet(obj,"hd390LevelRwdAll",maker.CST_Null())
	zd.initLiteSet(obj,"hd390Refresh",maker.CST_Null())
	zd.initLiteSet(obj,"hd390ScoreRwd",maker.CST_CS_Hd390ScoreRwd())
	zd.initLiteSet(obj,"hd390UpLevel",maker.CST_CS_Hd390UpLevel())
	zd.initLiteSet(obj,"hd390WifeRwd",maker.CST_Null())
	zd.initLiteSet(obj,"hd395GetRwd",maker.CST_idBase())
	zd.initLiteSet(obj,"hd395Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd396GetRwd",maker.CST_idBase())
	zd.initLiteSet(obj,"hd396Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd397Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd397Rwd","CxyyRwd")
	zd.initLiteSet(obj,"hd401Info",maker.CST_Cshd401All())
	zd.initLiteSet(obj,"hd401Rwd",maker.CST_Cshd401All())
	zd.initLiteSet(obj,"hd402Info",maker.CST_Cshd402All())
	zd.initLiteSet(obj,"hd402Rwd",maker.CST_Cshd402All())
	zd.initLiteSet(obj,"hd407Info",maker.CST_Cshd407All())
	zd.initLiteSet(obj,"hd407Rwd",maker.CST_Cshd407All())
	zd.initLiteSet(obj,"hd413Rwd",maker.CST_Cshd413All())
	zd.initLiteSet(obj,"hd422Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd422buy","NewyearhdBuy")
	zd.initLiteSet(obj,"hd422exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd422paihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd422play","TreasurehdPlay")
	zd.initLiteSet(obj,"hd427Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd428Info","")
	zd.initLiteSet(obj,"hd428Rwd",maker.CST_OldPlayerBackRwd())
	zd.initLiteSet(obj,"hd429Info","")
	zd.initLiteSet(obj,"hd429Rwd",maker.CST_NULL())
	zd.initLiteSet(obj,"hd430Info","")
	zd.initLiteSet(obj,"hd430Rwd","Cshd430Rwd")
	zd.initLiteSet(obj,"hd430Yao","Cshd430Yao")
	zd.initLiteSet(obj,"hd431Buy","CShd431Buy")
	zd.initLiteSet(obj,"hd431Get",maker.CST_CShd431Get())
	zd.initLiteSet(obj,"hd431Info","CxzcInfo")
	zd.initLiteSet(obj,"hd431Rank","CxzcInfo")
	zd.initLiteSet(obj,"hd431Ranking","CxzcInfo")
	zd.initLiteSet(obj,"hd431Recharge",maker.CST_CShd431Get())
	zd.initLiteSet(obj,"hd431Zou","CShd431Zou")
	zd.initLiteSet(obj,"hd431exchange",maker.CST_CShd431Get())
	zd.initLiteSet(obj,"hd431shop","CxzcInfo")
	zd.initLiteSet(obj,"hd435Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd437Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd437Rwd","")
	zd.initLiteSet(obj,"hd437buy","CxghdBuy")
	zd.initLiteSet(obj,"hd437exchange",maker.CST_IDCOUNT())
	zd.initLiteSet(obj,"hd437getRwd","DnGetRecharge")
	zd.initLiteSet(obj,"hd437paihang","")
	zd.initLiteSet(obj,"hd437play","CxghdPlay")
	zd.initLiteSet(obj,"hd444Follow",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd444Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd444Rwd",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd445Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd445Rwd",maker.CST_Hd445getRwd())
	zd.initLiteSet(obj,"hd456Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd456Rwd","")
	zd.initLiteSet(obj,"hd456buy","CxghdBuy")
	zd.initLiteSet(obj,"hd456exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd456getRwd","DnGetRecharge")
	zd.initLiteSet(obj,"hd456paihang","")
	zd.initLiteSet(obj,"hd456play","CxghdPlay")
	zd.initLiteSet(obj,"hd457Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd457Rwd","Cxhd457Rwd")
	zd.initLiteSet(obj,"hd458Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd458Rwd","Cxhd458Rwd")
	zd.initLiteSet(obj,"hd459Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd459buy","NewyearhdBuy")
	zd.initLiteSet(obj,"hd459exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd459getmyrwd","Jtgetmyrwd")
	zd.initLiteSet(obj,"hd459paihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd459play","TreasurehdPlay")
	zd.initLiteSet(obj,"hd464Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd464Jieqian",maker.CST_Null())
	zd.initLiteSet(obj,"hd464Qiuqian",maker.CST_Null())
	zd.initLiteSet(obj,"hd465Getrwd",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd465Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd466Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd468Buy","NewyearhdBuy")
	zd.initLiteSet(obj,"hd468Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd471Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd471Paihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd471Paiqian","Cxhd471Paiqian")
	zd.initLiteSet(obj,"hd472Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd472buy","NewyearhdBuy")
	zd.initLiteSet(obj,"hd472exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd472paihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd472play","TreasurehdPlay")
	zd.initLiteSet(obj,"hd477Get","CShd339Get")
	zd.initLiteSet(obj,"hd477Hua","CShd339Hua")
	zd.initLiteSet(obj,"hd477Info","CxzcInfo")
	zd.initLiteSet(obj,"hd477exchange","CShd339Get")
	zd.initLiteSet(obj,"hd477paihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd477shop","CxzcInfo")
	zd.initLiteSet(obj,"hd478Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd478getrwd","NewyearhdPlay")
	zd.initLiteSet(obj,"hd479Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd479getrwd","CS_fbAndlink")
	zd.initLiteSet(obj,"hd480Info","")
	zd.initLiteSet(obj,"hd481Info","")
	zd.initLiteSet(obj,"hd481Rwd","CS_647openBox")
	zd.initLiteSet(obj,"hd487Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd487buy","NewyearhdBuy")
	zd.initLiteSet(obj,"hd487getmyrwd","CxghdExchange")
	zd.initLiteSet(obj,"hd487turn","Syturn")
	zd.initLiteSet(obj,"hd491Buy",maker.CST_ShopLimit())
	zd.initLiteSet(obj,"hd491Details",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd491GetRwd",maker.CST_CS_hd491GetRwd())
	zd.initLiteSet(obj,"hd491Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd491MvpRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd491SevInfo",maker.CST_CS_hd491SevInfo())
	zd.initLiteSet(obj,"hd491SevRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd491Shop",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd492Chat",maker.CST_ChatMsg())
	zd.initLiteSet(obj,"hd492Check",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd492Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd492Log",maker.CST_ChatId())
	zd.initLiteSet(obj,"hd492QuRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd492UserRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd493Chat",maker.CST_ChatMsg())
	zd.initLiteSet(obj,"hd493Check",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd493Get",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd493Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd493Log",maker.CST_ChatId())
	zd.initLiteSet(obj,"hd493QuRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd493UserRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd495Chat",maker.CST_ChatMsg())
	zd.initLiteSet(obj,"hd495Check",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd495Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd495Log",maker.CST_ChatId())
	zd.initLiteSet(obj,"hd495UserRank",maker.CST_NULL())
	zd.initLiteSet(obj,"hd496BuyLv",maker.CST_CS_HD496BuyLv())
	zd.initLiteSet(obj,"hd496BuyRwd",maker.CST_CS_HD496BuyRwd())
	zd.initLiteSet(obj,"hd496Info",maker.CST_Null())
	zd.initLiteSet(obj,"hd496Rwd",maker.CST_CS_HD496Rwd())
	zd.initLiteSet(obj,"hd496RwdAll",maker.CST_Null())
	zd.initLiteSet(obj,"hd496TaskAll",maker.CST_Null())
	zd.initLiteSet(obj,"hd496TaskDaily",maker.CST_CS_HD496TaskDaily())
	zd.initLiteSet(obj,"hd496TaskWeek",maker.CST_CS_HD496TaskWeek())
	zd.initLiteSet(obj,"hd508Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd508buy","NewyearhdBuy")
	zd.initLiteSet(obj,"hd508exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd508getGif","CxzcInfo")
	zd.initLiteSet(obj,"hd508getPaihang","")
	zd.initLiteSet(obj,"hd508play","NewyearhdPlay")
	zd.initLiteSet(obj,"hd513Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd513getRwd","DnGetRecharge")
	zd.initLiteSet(obj,"hd514Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd514buy","NewyearhdBuy")
	zd.initLiteSet(obj,"hd514exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd514getKoi",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd514getPaihang","ChrhdPaihang")
	zd.initLiteSet(obj,"hd514play","CShd514play")
	zd.initLiteSet(obj,"hd519Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd519Look",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd519getrwd","DnGetRecharge")
	zd.initLiteSet(obj,"hd522Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd522buy","NewyearhdBuy")
	zd.initLiteSet(obj,"hd522exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd522getPaihang","")
	zd.initLiteSet(obj,"hd522lingqu","CxzcInfo")
	zd.initLiteSet(obj,"hd522play","NewyearhdPlay")
	zd.initLiteSet(obj,"hd526DstwPlay","zqdstwzgwy")
	zd.initLiteSet(obj,"hd526GetLe",maker.CST_CShd332Up())
	zd.initLiteSet(obj,"hd526GetLo",maker.CST_CShd332Up())
	zd.initLiteSet(obj,"hd526GetRe",maker.CST_CShd332Up())
	zd.initLiteSet(obj,"hd526GetRwd","CxzcInfo")
	zd.initLiteSet(obj,"hd526GetSeekRwd","CxzcInfo")
	zd.initLiteSet(obj,"hd526Info","CxzcInfo")
	zd.initLiteSet(obj,"hd526Paihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd526SeekRabbit",maker.CST_CShd434Lantern())
	zd.initLiteSet(obj,"hd526SetWife","Xq_wife")
	zd.initLiteSet(obj,"hd526buy","NewyearhdBuy")
	zd.initLiteSet(obj,"hd526exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd526play",maker.CST_CShd434Play())
	zd.initLiteSet(obj,"hd528Get","CShd339Get")
	zd.initLiteSet(obj,"hd528GetChip","CxzcInfo")
	zd.initLiteSet(obj,"hd528Hua","CShd339Hua")
	zd.initLiteSet(obj,"hd528Info","CxzcInfo")
	zd.initLiteSet(obj,"hd528Rank","CxzcInfo")
	zd.initLiteSet(obj,"hd528RwdChip","CxzcInfo")
	zd.initLiteSet(obj,"hd528exchange","CShd339Get")
	zd.initLiteSet(obj,"hd528shop","CxzcInfo")
	zd.initLiteSet(obj,"hd530Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd530Tribute",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd531Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd532Info","")
	zd.initLiteSet(obj,"hd532Rwd",maker.CST_NULL())
	zd.initLiteSet(obj,"hd533Info","")
	zd.initLiteSet(obj,"hd533Rwd",maker.CST_OldPlayerBackRwd())
	zd.initLiteSet(obj,"hd534Get","CShd339Get")
	zd.initLiteSet(obj,"hd534Hua","CShd339Hua")
	zd.initLiteSet(obj,"hd534Info","CxzcInfo")
	zd.initLiteSet(obj,"hd534Wife","CxghdSetWife")
	zd.initLiteSet(obj,"hd534exchange","CShd339Get")
	zd.initLiteSet(obj,"hd534paihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd534shop","CxzcInfo")
	zd.initLiteSet(obj,"hd535Draw",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd535GetCzRwd",maker.CST_idBase())
	zd.initLiteSet(obj,"hd535Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd535Rank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd536Chat",maker.CST_ChatMsg())
	zd.initLiteSet(obj,"hd536Check",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd536Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd536Log",maker.CST_ChatId())
	zd.initLiteSet(obj,"hd536UserRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd538Buy","hd538BuyParams")
	zd.initLiteSet(obj,"hd538Exchange","hd538ExchangeParams")
	zd.initLiteSet(obj,"hd538Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd538Lingqu",maker.CST_NULL())
	zd.initLiteSet(obj,"hd538Play","hd538PlayParams")
	zd.initLiteSet(obj,"hd538Rank","hd538RankParams")
	zd.initLiteSet(obj,"hd538Rwd","hd538RwdParams")
	zd.initLiteSet(obj,"hd538Skin","hd538SkinParams")
	zd.initLiteSet(obj,"hd541Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd541buy","NewyearhdBuy")
	zd.initLiteSet(obj,"hd541exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd541getPaihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd541getmyrwd","Jtgetmyrwd")
	zd.initLiteSet(obj,"hd541lingqu","CxzcInfo")
	zd.initLiteSet(obj,"hd541play","NewyearhdPlay")
	zd.initLiteSet(obj,"hd544Info","")
	zd.initLiteSet(obj,"hd544Light","CS_hd544Light")
	zd.initLiteSet(obj,"hd544OpenBox","CS_hd544OpenBox")
	zd.initLiteSet(obj,"hd544TaskRwd","CS_hd544TaskRwd")
	zd.initLiteSet(obj,"hd545Info","")
	zd.initLiteSet(obj,"hd545buy","CS_647openBox")
	zd.initLiteSet(obj,"hd546Info","")
	zd.initLiteSet(obj,"hd546buy","CS_647openBox")
	zd.initLiteSet(obj,"hd546getGift","")
	zd.initLiteSet(obj,"hd550Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd550RedBagNum",maker.CST_CSBagNum())
	zd.initLiteSet(obj,"hd550baoxiang",maker.CST_CSBoxRwd())
	zd.initLiteSet(obj,"hd550day",maker.CST_NULL())
	zd.initLiteSet(obj,"hd550open",maker.CST_CSbeamingBag())
	zd.initLiteSet(obj,"hd555Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd555Rwd","")
	zd.initLiteSet(obj,"hd555buy","CxghdBuy")
	zd.initLiteSet(obj,"hd555exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd555getRwd","DnGetRecharge")
	zd.initLiteSet(obj,"hd555paihang","")
	zd.initLiteSet(obj,"hd555play","CxghdPlay")
	zd.initLiteSet(obj,"hd561Add","CxzcInfo")
	zd.initLiteSet(obj,"hd561Burn","CxzcInfo")
	zd.initLiteSet(obj,"hd561Info","CxzcInfo")
	zd.initLiteSet(obj,"hd561Rwd","CxzcGet")
	zd.initLiteSet(obj,"hd562Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd563Buy","Jtgetmyrwd")
	zd.initLiteSet(obj,"hd563Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd563Rwd","Jtgetmyrwd")
	zd.initLiteSet(obj,"hd565Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd565Rwd","")
	zd.initLiteSet(obj,"hd565buy","CxghdBuy")
	zd.initLiteSet(obj,"hd565exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd565getRwd","DnGetRecharge")
	zd.initLiteSet(obj,"hd565paihang","")
	zd.initLiteSet(obj,"hd565play","CxghdPlay")
	zd.initLiteSet(obj,"hd572AddBless",maker.CST_CShd434AddBless())
	zd.initLiteSet(obj,"hd572GetGift","CxzcInfo")
	zd.initLiteSet(obj,"hd572GetRwd","CxzcInfo")
	zd.initLiteSet(obj,"hd572Info","CxzcInfo")
	zd.initLiteSet(obj,"hd572Paihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd572exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd572getLantern",maker.CST_CShd434Lantern())
	zd.initLiteSet(obj,"hd572play",maker.CST_CShd434Play())
	zd.initLiteSet(obj,"hd573GetBox",maker.CST_CSBoxRwd())
	zd.initLiteSet(obj,"hd573Info","")
	zd.initLiteSet(obj,"hd573Paihang","")
	zd.initLiteSet(obj,"hd573buy","NewyearhdBuy")
	zd.initLiteSet(obj,"hd573exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd573getSevRwd","")
	zd.initLiteSet(obj,"hd573play","CShd514play")
	zd.initLiteSet(obj,"hd576Buy",maker.CST_CShd332Buy())
	zd.initLiteSet(obj,"hd576Get",maker.CST_CShd332Up())
	zd.initLiteSet(obj,"hd576GetLe",maker.CST_CShd332Up())
	zd.initLiteSet(obj,"hd576GetLo",maker.CST_CShd332Up())
	zd.initLiteSet(obj,"hd576GetRe",maker.CST_CShd332Up())
	zd.initLiteSet(obj,"hd576Info","CxzcInfo")
	zd.initLiteSet(obj,"hd576Rank","CxzcInfo")
	zd.initLiteSet(obj,"hd576Ranking","CxzcInfo")
	zd.initLiteSet(obj,"hd576Zou","CShd332Zou")
	zd.initLiteSet(obj,"hd576exchange",maker.CST_CShd332Up())
	zd.initLiteSet(obj,"hd576shop","CxzcInfo")
	zd.initLiteSet(obj,"hd577Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd577exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd577getdayrwd","Jtgetmyrwd")
	zd.initLiteSet(obj,"hd577paihang","")
	zd.initLiteSet(obj,"hd577play","NewyearhdPlay")
	zd.initLiteSet(obj,"hd579Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd57Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd581Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd581exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd581paihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd581play","NewyearhdPlay")
	zd.initLiteSet(obj,"hd583Info","")
	zd.initLiteSet(obj,"hd583Rwd","")
	zd.initLiteSet(obj,"hd583Tao","CxsdSet")
	zd.initLiteSet(obj,"hd583Task","CxghdBuy")
	zd.initLiteSet(obj,"hd584Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd585Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd585get_rwd","CxznflGetrwd")
	zd.initLiteSet(obj,"hd586GetRwd",maker.CST_FBshareGetrwd())
	zd.initLiteSet(obj,"hd587First",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd587GetBoxRwd",maker.CST_CSBoxRwd())
	zd.initLiteSet(obj,"hd587GetHistory",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd587GetRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd587GetRwd",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd587Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd587YaZhu",maker.CST_IDCOUNT())
	zd.initLiteSet(obj,"hd587ZhuanPan",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd587buy",maker.CST_IDCOUNT())
	zd.initLiteSet(obj,"hd590Buy",maker.CST_CxslchdRwd())
	zd.initLiteSet(obj,"hd590Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd591Fan",maker.CST_Cx591fan())
	zd.initLiteSet(obj,"hd591Get",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd591History",maker.CST_Cx591History())
	zd.initLiteSet(obj,"hd591Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd591Task",maker.CST_CxslchdRwd())
	zd.initLiteSet(obj,"hd596Buy",maker.CST_ryqdUseAndBuy())
	zd.initLiteSet(obj,"hd596Exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd596Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd596Paihang","")
	zd.initLiteSet(obj,"hd596Use",maker.CST_ryqdUseAndBuy())
	zd.initLiteSet(obj,"hd598Info","CxzcInfo")
	zd.initLiteSet(obj,"hd608DayRwd","")
	zd.initLiteSet(obj,"hd608Exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd608Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd608Rank","")
	zd.initLiteSet(obj,"hd608Rwd","CxGetReward")
	zd.initLiteSet(obj,"hd608Send","CxSendInfo")
	zd.initLiteSet(obj,"hd608WifeList","")
	zd.initLiteSet(obj,"hd608buy",maker.CST_hd608Buy())
	zd.initLiteSet(obj,"hd623Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd623Rwd","CjghdRwd")
	zd.initLiteSet(obj,"hd624Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd624buy","zqdstwzgwy")
	zd.initLiteSet(obj,"hd624exchange","hd780ExchangeParams")
	zd.initLiteSet(obj,"hd624play","CxzhujiuPlay")
	zd.initLiteSet(obj,"hd624recharge_rwd","CxghdBuy")
	zd.initLiteSet(obj,"hd638Chat",maker.CST_ChatMsg())
	zd.initLiteSet(obj,"hd638Check",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd638First",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd638GetBoxRwd",maker.CST_CSBoxRwd())
	zd.initLiteSet(obj,"hd638GetHistory",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd638GetRank",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd638GetRwd",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd638Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd638Log",maker.CST_ChatId())
	zd.initLiteSet(obj,"hd638Quan","ParamCount")
	zd.initLiteSet(obj,"hd638YaZhu",maker.CST_IDCOUNT())
	zd.initLiteSet(obj,"hd638ZhuanPan",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd638buy",maker.CST_IDCOUNT())
	zd.initLiteSet(obj,"hd642Refresh","")
	zd.initLiteSet(obj,"hd643Info","")
	zd.initLiteSet(obj,"hd643Rwd","SC_LimitHero_Heros")
	zd.initLiteSet(obj,"hd644Info","")
	zd.initLiteSet(obj,"hd644Rwd","DnGetRecharge")
	zd.initLiteSet(obj,"hd646Info","")
	zd.initLiteSet(obj,"hd646Mobai","")
	zd.initLiteSet(obj,"hd646PayTail","")
	zd.initLiteSet(obj,"hd646Reserve","")
	zd.initLiteSet(obj,"hd647BuyCandy","CS_647buy")
	zd.initLiteSet(obj,"hd647Info","")
	zd.initLiteSet(obj,"hd647OpenBox","CS_647openBox")
	zd.initLiteSet(obj,"hd647Reset","")
	zd.initLiteSet(obj,"hd647SetJackpot","CS_647jackpot")
	zd.initLiteSet(obj,"hd647TreasureHunt","")
	zd.initLiteSet(obj,"hd647exchange","CS_647exchange")
	zd.initLiteSet(obj,"hd648Buy","CS_hd648Buy")
	zd.initLiteSet(obj,"hd648Info","")
	zd.initLiteSet(obj,"hd648Paihang","CS_hd648Paihang")
	zd.initLiteSet(obj,"hd648Play","CS_hd648Play")
	zd.initLiteSet(obj,"hd648exchange","CS_hd648exchange")
	zd.initLiteSet(obj,"hd650Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd650cGroupBuy",maker.CST_CS_Hd650cGroupBuy())
	zd.initLiteSet(obj,"hd650delemyOrder",maker.CST_CS_hd650delemyOrder())
	zd.initLiteSet(obj,"hd650fGroupBuy",maker.CST_CS_Hd650fGroupBuy())
	zd.initLiteSet(obj,"hd650getInfoById",maker.CST_CS_Hd650cGroupBuy())
	zd.initLiteSet(obj,"hd650singleBuy",maker.CST_NULL())
	zd.initLiteSet(obj,"hd651Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd651buy","newcjyxbuy")
	zd.initLiteSet(obj,"hd651exchange","newcjyxexchange")
	zd.initLiteSet(obj,"hd651getPaihang","CxzcInfo")
	zd.initLiteSet(obj,"hd651getrwd","CxghdExchange")
	zd.initLiteSet(obj,"hd651lingqu","")
	zd.initLiteSet(obj,"hd651play","newcjyxplay")
	zd.initLiteSet(obj,"hd654Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd654getHeaven",maker.CST_redpacket())
	zd.initLiteSet(obj,"hd654openHeaven",maker.CST_redpacket())
	zd.initLiteSet(obj,"hd654openRedPacket","CxghdExchange")
	zd.initLiteSet(obj,"hd655Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd656Buy",maker.CST_CShd336Buy())
	zd.initLiteSet(obj,"hd656Get",maker.CST_CShd336Up())
	zd.initLiteSet(obj,"hd656Info","CxzcInfo")
	zd.initLiteSet(obj,"hd656Rank","656hdPaihang")
	zd.initLiteSet(obj,"hd656exchange","hd780ExchangeParams")
	zd.initLiteSet(obj,"hd656play","CShd336Zou")
	zd.initLiteSet(obj,"hd657Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd657Rwd","CjghdRwd")
	zd.initLiteSet(obj,"hd658Buy",maker.CST_CShd336Buy())
	zd.initLiteSet(obj,"hd658Get",maker.CST_CShd336Up())
	zd.initLiteSet(obj,"hd658GetSev","CxzcInfo")
	zd.initLiteSet(obj,"hd658Info","CxzcInfo")
	zd.initLiteSet(obj,"hd658Rank","658hdPaihang")
	zd.initLiteSet(obj,"hd658exchange",maker.CST_idBase())
	zd.initLiteSet(obj,"hd658play","CShd333Buy")
	zd.initLiteSet(obj,"hd668Info","")
	zd.initLiteSet(obj,"hd668Rwd","SL_wife")
	zd.initLiteSet(obj,"hd674Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd680FirstRwd",maker.CST_CSSevenTaskFirstRwd())
	zd.initLiteSet(obj,"hd680Info","")
	zd.initLiteSet(obj,"hd680SevenRwd",maker.CST_CSSevenTaskRwd())
	zd.initLiteSet(obj,"hd680buy",maker.CST_CSSevenTaskRwd())
	zd.initLiteSet(obj,"hd681Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd682Check","CS_hd682Params")
	zd.initLiteSet(obj,"hd682Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd682Trigger","CS_hd682Params")
	zd.initLiteSet(obj,"hd683Info","")
	zd.initLiteSet(obj,"hd683bb","683hdplay")
	zd.initLiteSet(obj,"hd683buy","683hdbuy")
	zd.initLiteSet(obj,"hd683exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd683log","")
	zd.initLiteSet(obj,"hd683paihang","683hdPaihang")
	zd.initLiteSet(obj,"hd683sq","")
	zd.initLiteSet(obj,"hd685Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd685Paihang","")
	zd.initLiteSet(obj,"hd685agree","mjagree")
	zd.initLiteSet(obj,"hd685breakClub","")
	zd.initLiteSet(obj,"hd685buy","NewyearhdBuy")
	zd.initLiteSet(obj,"hd685chageRand","mjchangeRand")
	zd.initLiteSet(obj,"hd685checkApplication","")
	zd.initLiteSet(obj,"hd685createClub","mjcreateclub")
	zd.initLiteSet(obj,"hd685endGame","mjendGame")
	zd.initLiteSet(obj,"hd685exchange","NewyearhdBuy")
	zd.initLiteSet(obj,"hd685findTeam","mjclubid")
	zd.initLiteSet(obj,"hd685joinForId","mjclubid")
	zd.initLiteSet(obj,"hd685kickout","mjagree")
	zd.initLiteSet(obj,"hd685outClub","mjclubid")
	zd.initLiteSet(obj,"hd685randJoy","")
	zd.initLiteSet(obj,"hd685refuseAll","")
	zd.initLiteSet(obj,"hd685refuseOne","mjagree")
	zd.initLiteSet(obj,"hd685startGame","mjstartGame")
	zd.initLiteSet(obj,"hd687Buy",maker.CST_CShd336Buy())
	zd.initLiteSet(obj,"hd687Get",maker.CST_CShd336Up())
	zd.initLiteSet(obj,"hd687Info","CxzcInfo")
	zd.initLiteSet(obj,"hd687Rank","CxzcInfo")
	zd.initLiteSet(obj,"hd687Ranking",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd687Zou","CShd336Zou")
	zd.initLiteSet(obj,"hd687exchange",maker.CST_CShd336Up())
	zd.initLiteSet(obj,"hd687shop","CxzcInfo")
	zd.initLiteSet(obj,"hd688Check","CS_hd688Params")
	zd.initLiteSet(obj,"hd688Get","CS_hd688Params")
	zd.initLiteSet(obj,"hd688Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd688Trigger","CS_hd688Params")
	zd.initLiteSet(obj,"hd689Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd689buy","NewyearhdBuy")
	zd.initLiteSet(obj,"hd689exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd689paihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd689play","TreasurehdPlay")
	zd.initLiteSet(obj,"hd694DstwPlay","zqdstwzgwy")
	zd.initLiteSet(obj,"hd694GetRwd","CxzcInfo")
	zd.initLiteSet(obj,"hd694GetSeekRwd","CxzcInfo")
	zd.initLiteSet(obj,"hd694Info","CxzcInfo")
	zd.initLiteSet(obj,"hd694Paihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd694SeekRabbit",maker.CST_CShd434Lantern())
	zd.initLiteSet(obj,"hd694SetWife","Xq_wife")
	zd.initLiteSet(obj,"hd694buy","NewyearhdBuy")
	zd.initLiteSet(obj,"hd694exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd694play",maker.CST_CShd434Play())
	zd.initLiteSet(obj,"hd700Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd701Chi","CS_hd701chi")
	zd.initLiteSet(obj,"hd701Info","CS_hd701Params")
	zd.initLiteSet(obj,"hd701bflist","CS_hd701Params")
	zd.initLiteSet(obj,"hd701gchi","CS_hd701chig")
	zd.initLiteSet(obj,"hd701go","CS_hd701open")
	zd.initLiteSet(obj,"hd701gogf","")
	zd.initLiteSet(obj,"hd701open","CS_hd701Params")
	zd.initLiteSet(obj,"hd701selfin","CS_hd701Params")
	zd.initLiteSet(obj,"hd711Info","")
	zd.initLiteSet(obj,"hd712Bk",maker.CST_idBase())
	zd.initLiteSet(obj,"hd712Get",maker.CST_idBase())
	zd.initLiteSet(obj,"hd712Info","")
	zd.initLiteSet(obj,"hd713Get","")
	zd.initLiteSet(obj,"hd713Info","")
	zd.initLiteSet(obj,"hd714Get",maker.CST_idBase())
	zd.initLiteSet(obj,"hd714Info","")
	zd.initLiteSet(obj,"hd715Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd715Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd716Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd716Rwd",maker.CST_CxshdRwd())
	zd.initLiteSet(obj,"hd750Info",maker.CST_Null())
	zd.initLiteSet(obj,"hd750Rwd",maker.CST_Null())
	zd.initLiteSet(obj,"hd760Baohu","CS_hd760Baohu")
	zd.initLiteSet(obj,"hd760Buy",maker.CST_CS_hd760Buy())
	zd.initLiteSet(obj,"hd760Chat","CS_hd760Chat")
	zd.initLiteSet(obj,"hd760ChatCheck","CS_hd760ChatCheck")
	zd.initLiteSet(obj,"hd760ChatLog","CS_hd760ChatLog")
	zd.initLiteSet(obj,"hd760Chushi",maker.CST_Null())
	zd.initLiteSet(obj,"hd760CityHurt",maker.CST_CS_Hd760Sevid())
	zd.initLiteSet(obj,"hd760CityInfo",maker.CST_CS_Hd760Sevid())
	zd.initLiteSet(obj,"hd760Fight",maker.CST_heroId())
	zd.initLiteSet(obj,"hd760FightYj",maker.CST_Null())
	zd.initLiteSet(obj,"hd760FindZhuiSha","CS_Hd760FindZhuiSha")
	zd.initLiteSet(obj,"hd760FuChou","CS_Hd760FuChou")
	zd.initLiteSet(obj,"hd760Fuhuo",maker.CST_Null())
	zd.initLiteSet(obj,"hd760Getrwd",maker.CST_Null())
	zd.initLiteSet(obj,"hd760Info",maker.CST_Null())
	zd.initLiteSet(obj,"hd760Log","CS_hd760Log")
	zd.initLiteSet(obj,"hd760OneKeyPlay",maker.CST_idBase())
	zd.initLiteSet(obj,"hd760PiZhun","CS_Hd760Heroid")
	zd.initLiteSet(obj,"hd760Rank",maker.CST_CS_Hd760Rank())
	zd.initLiteSet(obj,"hd760Rwd",maker.CST_CS_hd760Rwd())
	zd.initLiteSet(obj,"hd760Seladd",maker.CST_CS_Hd760Id())
	zd.initLiteSet(obj,"hd760SetName",maker.CST_CS_Hd760Id())
	zd.initLiteSet(obj,"hd760Sjtz",maker.CST_Null())
	zd.initLiteSet(obj,"hd760TiaoZhan","CS_Hd760TiaoZhan")
	zd.initLiteSet(obj,"hd760ZhuiSha","CS_Hd760ZhuiSha")
	zd.initLiteSet(obj,"hd760paiQian",maker.CST_CS_Hd760Sevid())
	zd.initLiteSet(obj,"hd760yxInfo",maker.CST_Null())
	zd.initLiteSet(obj,"hd770Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd771Buy","hd771BuyParams")
	zd.initLiteSet(obj,"hd771Exchange","hd771ExchangeParams")
	zd.initLiteSet(obj,"hd771HbRwd","hd771HbRwdParams")
	zd.initLiteSet(obj,"hd771Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd771Light","hd771LightParams")
	zd.initLiteSet(obj,"hd771Play","hd771PlayParams")
	zd.initLiteSet(obj,"hd771Task","hd771TaskParams")
	zd.initLiteSet(obj,"hd772Extract","hd772ExtractParams")
	zd.initLiteSet(obj,"hd772He","hd772HeParams")
	zd.initLiteSet(obj,"hd772Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd772Rwd","hd772RwdParams")
	zd.initLiteSet(obj,"hd777Draw","hd777DrawParams")
	zd.initLiteSet(obj,"hd777Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd777Reset","hd777ResetParams")
	zd.initLiteSet(obj,"hd777Rwd","hd777RwdParams")
	zd.initLiteSet(obj,"hd777Task","hd777TaskParams")
	zd.initLiteSet(obj,"hd780BoxRwd","hd780BoxRwdParams")
	zd.initLiteSet(obj,"hd780Buy","hd780BuyParams")
	zd.initLiteSet(obj,"hd780Chat",maker.CST_ChatMsg())
	zd.initLiteSet(obj,"hd780ChatCheck",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd780ChatLog",maker.CST_ChatId())
	zd.initLiteSet(obj,"hd780Exchange","hd780ExchangeParams")
	zd.initLiteSet(obj,"hd780Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd780Play","hd780PlayParams")
	zd.initLiteSet(obj,"hd780Rank","hd780RankParams")
	zd.initLiteSet(obj,"hd780SevRwd","hd780SevRwdParams")
	zd.initLiteSet(obj,"hd780Task","hd780TaskParams")
	zd.initLiteSet(obj,"hd782Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd782Rwd","hd782RwdParams")
	zd.initLiteSet(obj,"hd786Buy",maker.CST_CS_Hd786Count())
	zd.initLiteSet(obj,"hd786Exchange",maker.CST_hd786Exchange())
	zd.initLiteSet(obj,"hd786Info",maker.CST_Null())
	zd.initLiteSet(obj,"hd786Play",maker.CST_CS_Hd786Count())
	zd.initLiteSet(obj,"hd786RwdBox",maker.CST_CS_Hd786Id())
	zd.initLiteSet(obj,"hd786RwdTask",maker.CST_CS_Hd786Id())
	zd.initLiteSet(obj,"hd786SetNoAd",maker.CST_Null())
	zd.initLiteSet(obj,"hd790Info",maker.CST_NULL())
	zd.initLiteSet(obj,"hd790Rwd",maker.CST_NULL())
	zd.initLiteSet(obj,"hd798Info","")
	zd.initLiteSet(obj,"hd799Answer",maker.CST_survey_answer())
	zd.initLiteSet(obj,"hd799Info","")
	zd.initLiteSet(obj,"hd799get_rwd",maker.CST_survey_getrwd())
	zd.initLiteSet(obj,"hd800Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd800Rwd",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd801Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd801Rwd","C801Rwd")
	zd.initLiteSet(obj,"hd802Info","")
	zd.initLiteSet(obj,"hd802get",maker.CST_CS_hd802touch())
	zd.initLiteSet(obj,"hd802getRwd",maker.CST_CS_hd802touch())
	zd.initLiteSet(obj,"hd802touch",maker.CST_CS_hd802touch())
	zd.initLiteSet(obj,"hd872Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd872Rwd","CjghdRwd")
	zd.initLiteSet(obj,"hd873Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd873Rwd",maker.CST_CShdRwd())
	zd.initLiteSet(obj,"hd876GetWife","")
	zd.initLiteSet(obj,"hd876Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd876Rank","CxzcInfo")
	zd.initLiteSet(obj,"hd876Ranking","CxzcInfo")
	zd.initLiteSet(obj,"hd876Rwd","C891Rwd")
	zd.initLiteSet(obj,"hd887Info","")
	zd.initLiteSet(obj,"hd890Info","")
	zd.initLiteSet(obj,"hd891Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd891Rwd","C891Rwd")
	zd.initLiteSet(obj,"hd892Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd892Rwd","C892Rwd")
	zd.initLiteSet(obj,"hd892Smash","C892Smash")
	zd.initLiteSet(obj,"hd893Info","")
	zd.initLiteSet(obj,"hd894Address","hdAddress")
	zd.initLiteSet(obj,"hd894Info","")
	zd.initLiteSet(obj,"hd894Rank","")
	zd.initLiteSet(obj,"hd894Rwd","")
	zd.initLiteSet(obj,"hd895Buy",maker.CST_CShd336Buy())
	zd.initLiteSet(obj,"hd895Get",maker.CST_CShd336Up())
	zd.initLiteSet(obj,"hd895Info","CxzcInfo")
	zd.initLiteSet(obj,"hd895Rank","CxzcInfo")
	zd.initLiteSet(obj,"hd895Ranking","CxzcInfo")
	zd.initLiteSet(obj,"hd895Up",maker.CST_CShd336Up())
	zd.initLiteSet(obj,"hd895Zou","CShd336Zou")
	zd.initLiteSet(obj,"hd895exchange",maker.CST_CShd336Up())
	zd.initLiteSet(obj,"hd895shop","CxzcInfo")
	zd.initLiteSet(obj,"hd896GetHero","")
	zd.initLiteSet(obj,"hd896Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd896Rank","CxzcInfo")
	zd.initLiteSet(obj,"hd896Ranking","CxzcInfo")
	zd.initLiteSet(obj,"hd896Rwd","C891Rwd")
	zd.initLiteSet(obj,"hd898Info","")
	zd.initLiteSet(obj,"hd899Rwd","DnGetRecharge")
	zd.initLiteSet(obj,"hd900Wife","")
	zd.initLiteSet(obj,"hd901Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd901Rwd","")
	zd.initLiteSet(obj,"hd901buy","CxghdBuy")
	zd.initLiteSet(obj,"hd901exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd901getRwd","DnGetRecharge")
	zd.initLiteSet(obj,"hd901paihang","")
	zd.initLiteSet(obj,"hd901play","CxghdPlay")
	zd.initLiteSet(obj,"hd907AddBless",maker.CST_CShd434AddBless())
	zd.initLiteSet(obj,"hd907GetGift","CxzcInfo")
	zd.initLiteSet(obj,"hd907GetRwd","CxzcInfo")
	zd.initLiteSet(obj,"hd907Info","CxzcInfo")
	zd.initLiteSet(obj,"hd907Paihang",maker.CST_CxghdPaihang())
	zd.initLiteSet(obj,"hd907exchange","CxghdExchange")
	zd.initLiteSet(obj,"hd907getLantern",maker.CST_CShd434Lantern())
	zd.initLiteSet(obj,"hd907play",maker.CST_CShd434Play())
	zd.initLiteSet(obj,"hd910Info","")
	zd.initLiteSet(obj,"hd922Info",maker.CST_Null())
	zd.initLiteSet(obj,"hd922Rwd",maker.CST_CS_hd922Rwd())
	zd.initLiteSet(obj,"hd924GivpUp","")
	zd.initLiteSet(obj,"hd924Info","")
	zd.initLiteSet(obj,"hd924Play","C2048Play")
	zd.initLiteSet(obj,"hd924RefPower","")
	zd.initLiteSet(obj,"hd924SetSkill","C2048Skill")
	zd.initLiteSet(obj,"hd924UseGameItem","C2048GameItem")
	zd.initLiteSet(obj,"hd924UsePowerItem",maker.CST_IDCOUNT())
	zd.initLiteSet(obj,"hd924buy",maker.CST_IDCOUNT())
	zd.initLiteSet(obj,"hd924exchange",maker.CST_IDCOUNT())
	zd.initLiteSet(obj,"hd924paihang","")
	zd.initLiteSet(obj,"hd928Info",maker.CST_Null())
	zd.initLiteSet(obj,"hd928cj","CS_hd928cj")
	zd.initLiteSet(obj,"hd928exchange",maker.CST_CS_hdExchange())
	zd.initLiteSet(obj,"hd931DailyBox",maker.CST_CxxlDailyBox())
	zd.initLiteSet(obj,"hd931Info","")
	zd.initLiteSet(obj,"hd931Move",maker.CST_CxxlMove())
	zd.initLiteSet(obj,"hd931RankRwd","")
	zd.initLiteSet(obj,"hd931SetMap",maker.CST_CxxlSetMap())
	zd.initLiteSet(obj,"hd931UseItem",maker.CST_CxxlUseItem())
	zd.initLiteSet(obj,"hd931buy",maker.CST_IDCOUNT())
	zd.initLiteSet(obj,"hd931exchange",maker.CST_IDCOUNT())
	zd.initLiteSet(obj,"hd931paihang","")
	zd.initLiteSet(obj,"hd949Info",maker.CST_CxshdInfo())
	zd.initLiteSet(obj,"hd949Rwd",maker.CST_CSLjzxRwd())
	zd.initLiteSet(obj,"hdGetXSRank",maker.CST_XShdGetRank())
	zd.initLiteSet(obj,"hdList",maker.CST_ChdList())
	zd.initLiteSet(obj,"titleGo",maker.CST_CS_hd802touch())
	return obj
end

maker.CST_Scblessing = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buy_num",0)
	zd.initLiteSet(obj,"qian",zd.makeLiteArray(makerSC.SCT_scqian()))
	zd.initLiteSet(obj,"sy_num",0)
	return obj
end

maker.CST_jslist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"gx",0)
	zd.initLiteSet(obj,"hit",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_NpcFavorability = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"favorability",0)
	zd.initLiteSet(obj,"lv",0)
	zd.initLiteSet(obj,"npc_id",0)
	return obj
end

maker.CST_Scfglc = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_Shdinfo())
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_Shdrwdlc()))
	return obj
end

maker.CST_RiskJindu = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"success",0)
	return obj
end

maker.CST_FchoFuliGuide = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_SC_ClubKuaYueCfgBuff = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"herozzskill",0)
	zd.initLiteSet(obj,"jingying",0)
	return obj
end

maker.CST_SC_RankComClub = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cname","")
	zd.initLiteSet(obj,"mzname","")
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"servid",0)
	return obj
end

maker.CST_MapDoc = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"document","")
	return obj
end

maker.CST_clubbosswin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cbosspkwin",maker.CST_Scbosspkwin())
	return obj
end

maker.CST_pmdlist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"items",maker.CST_items_list())
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"rebate",20)
	return obj
end

maker.CST_SC_cityNews = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hanLinNews",0)
	zd.initLiteSet(obj,"wifePKNews",0)
	return obj
end

maker.CST_IDCOUNT = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SC_ClubExtendInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cyScoreRwd",0)
	return obj
end

maker.CST_BHCZHDUserRwdList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CS_ChengJiu = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"do_work",maker.CST_doWork())
	zd.initLiteSet(obj,"rwd",maker.CST_ChengJiuRwd())
	return obj
end

maker.CST_KuattInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"eTime",maker.CST_KuaHdCdTime())
	zd.initLiteSet(obj,"hd_status",0)
	zd.initLiteSet(obj,"isopen",0)
	zd.initLiteSet(obj,"jie",0)
	zd.initLiteSet(obj,"limit",0)
	zd.initLiteSet(obj,"newSTime",maker.CST_KuaHdCdTime())
	zd.initLiteSet(obj,"num",100)
	zd.initLiteSet(obj,"rank",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"showTime",0)
	zd.initLiteSet(obj,"yueGao",maker.CST_KuaHdCdTime())
	zd.initLiteSet(obj,"yushowTime",maker.CST_KuaHdCdTime())
	return obj
end

maker.CST_SbossInfoList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_SbossList()))
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_FuserDataHero = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dt",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"senior",0)
	zd.initLiteSet(obj,"shili",0)
	zd.initLiteSet(obj,"skin",0)
	zd.initLiteSet(obj,"zz",0)
	return obj
end

maker.CST_Server = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"full",0)
	zd.initLiteSet(obj,"he",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"showtime",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"url","")
	return obj
end

maker.CST_SCSevenDaySignList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"st",0)
	return obj
end

maker.CST_SC_centralattackzhen = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fshili",0)
	return obj
end

maker.CST_SC_Bag = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bagList1",zd.makeLiteArray(makerSC.SCT_Thing()))
	zd.initLiteSet(obj,"bagList2",zd.makeLiteArray(makerSC.SCT_Thing()))
	zd.initLiteSet(obj,"bag_list",zd.makeLiteArray(makerSC.SCT_Thing()))
	return obj
end

maker.CST_cs_skinClearNews = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"skin_type",1)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CS_Guide = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"add_guide",maker.CST_CS_GuideSpecialGuide())
	zd.initLiteSet(obj,"chooseWife",maker.CST_CS_GuideChooseWife())
	zd.initLiteSet(obj,"clock",maker.CST_CS_GuideClock())
	zd.initLiteSet(obj,"getChangePackRwd","")
	zd.initLiteSet(obj,"guide",maker.CST_UserGuide())
	zd.initLiteSet(obj,"guideHero",maker.CST_Null())
	zd.initLiteSet(obj,"guideUpguan",maker.CST_Null())
	zd.initLiteSet(obj,"guideWife",maker.CST_Null())
	zd.initLiteSet(obj,"kefu",maker.CST_Null())
	zd.initLiteSet(obj,"login",maker.CST_Clogin())
	zd.initLiteSet(obj,"mainWife",maker.CST_CS_GuideChooseWife())
	zd.initLiteSet(obj,"modulePlayStory",maker.CST_CS_PlayModuleStory())
	zd.initLiteSet(obj,"opt_button",maker.CST_CS_GuideButton())
	zd.initLiteSet(obj,"opt_button_real",maker.CST_CS_GuideButtonReal())
	zd.initLiteSet(obj,"randName",maker.CST_CS_setLang())
	zd.initLiteSet(obj,"setUInfo",maker.CST_ClearUser())
	zd.initLiteSet(obj,"shuaZhucheng",maker.CST_Null())
	zd.initLiteSet(obj,"special_guide",maker.CST_CS_GuideSpecialGuide())
	zd.initLiteSet(obj,"yzApiLog","yzApiLog")
	return obj
end

maker.CST_SCsocialdressedlist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdNum())
	zd.initLiteSet(obj,"get",1)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_itemBase = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"id","")
	return obj
end

maker.CST_UserPvb2Win = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bmid",0)
	zd.initLiteSet(obj,"damagelist",zd.makeLiteArray(makerSC.SCT_Pvb2Herodamage()))
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	return obj
end

maker.CST_PVP_Info_ladder = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buynum",0)
	zd.initLiteSet(obj,"buynummax",0)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"chumax",0)
	zd.initLiteSet(obj,"chunum",0)
	zd.initLiteSet(obj,"day_cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"f_list",zd.makeLiteArray(makerSC.SCT_ladder_list()))
	zd.initLiteSet(obj,"fitnum",0)
	zd.initLiteSet(obj,"fuser",maker.CST_ladder_list())
	zd.initLiteSet(obj,"qhid",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"tz_fuid",zd.makeLiteArray(makerSC.SCT_ladder_list()))
	return obj
end

maker.CST_SChitlist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hh",0)
	zd.initLiteSet(obj,"hit",0)
	zd.initLiteSet(obj,"name","")
	return obj
end

maker.CST_CClubBossOpen = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cbid",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CApplyList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid",maker.CST_Null())
	return obj
end

maker.CST_RiskStory = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_SCUserDress = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cFrame",0)
	zd.initLiteSet(obj,"frame",0)
	zd.initLiteSet(obj,"head",0)
	zd.initLiteSet(obj,"list",maker.CST_SCUserDressList())
	zd.initLiteSet(obj,"news",0)
	zd.initLiteSet(obj,"nlist",maker.CST_SCUserDressNList())
	return obj
end

maker.CST_SCUserGuide = function()
	local obj = {}
	zd.makeLiteTable(obj)
	return obj
end

maker.CST_SC_frame = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_SCFramelist()))
	zd.initLiteSet(obj,"news",0)
	zd.initLiteSet(obj,"set",0)
	return obj
end

maker.CST_KuaMineGrab = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"heros",zd.makeLiteArray(makerSC.SCT_KuaMineOccupyHero()))
	zd.initLiteSet(obj,"key",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_couponIngo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"diamond",0)
	zd.initLiteSet(obj,"expireTime",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"needDiamond",0)
	zd.initLiteSet(obj,"status",0)
	zd.initLiteSet(obj,"time",0)
	return obj
end

maker.CST_SC_LLBK = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"StarLog",zd.makeLiteArray(makerSC.SCT_SC_LlbkStarLog()))
	zd.initLiteSet(obj,"cfg",maker.CST_SC_LlbkCfg())
	zd.initLiteSet(obj,"exchange","ExchangeShop")
	zd.initLiteSet(obj,"info",maker.CST_SC_LlbkInfo())
	zd.initLiteSet(obj,"need",zd.makeLiteArray(makerSC.SCT_UseItemInfo()))
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_UseItemInfo()))
	return obj
end

maker.CST_SC_HDljzx = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_ScLjzxInfo())
	return obj
end

maker.CST_itemYard = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"roleid",0)
	return obj
end

maker.CST_BanishDesk = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"desk",1)
	zd.initLiteSet(obj,"deskrwd",zd.makeLiteArray(makerSC.SCT_BanishDeskRwd()))
	return obj
end

maker.CST_QianDaoDay = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"days",1)
	zd.initLiteSet(obj,"qiandao",0)
	return obj
end

maker.CST_SCVersion = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"ver",1)
	return obj
end

maker.CST_UserName = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"wxOpenid","")
	return obj
end

maker.CST_CsTsRecover = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_SC_Club = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"applyList",zd.makeLiteArray(makerSC.SCT_SapplyList()))
	zd.initLiteSet(obj,"bigBossInfo",zd.makeLiteArray(makerSC.SCT_SbossInfo1()))
	zd.initLiteSet(obj,"bigHeroLog",zd.makeLiteArray(makerSC.SCT_SheroLog()))
	zd.initLiteSet(obj,"bigWin",maker.CST_clubbosswin1())
	zd.initLiteSet(obj,"bossInfo",zd.makeLiteArray(makerSC.SCT_SbossInfo()))
	zd.initLiteSet(obj,"bossInfoList",maker.CST_SbossInfoList())
	zd.initLiteSet(obj,"bossft",zd.makeLiteArray(makerSC.SCT_FightList()))
	zd.initLiteSet(obj,"clubExtendDailyInfo",maker.CST_SC_ClubExtendDailyInfo())
	zd.initLiteSet(obj,"clubExtendInfo",maker.CST_SC_ClubExtendInfo())
	zd.initLiteSet(obj,"clubInfo",maker.CST_SClubInfo())
	zd.initLiteSet(obj,"clubKuaCszr",maker.CST_SCclubKuaCszr())
	zd.initLiteSet(obj,"clubKuaInfo",maker.CST_SCclubKuaInfo())
	zd.initLiteSet(obj,"clubKuaMsg",maker.CST_SCclubKuaMsg())
	zd.initLiteSet(obj,"clubKuaWin",maker.CST_SCclubKuaWin())
	zd.initLiteSet(obj,"clubKuaYueCfg",maker.CST_SC_ClubKuaYueCfg())
	zd.initLiteSet(obj,"clubKuaYueInfo",maker.CST_SC_ClubKuaYueInfo())
	zd.initLiteSet(obj,"clubKuahit",maker.CST_SCclubKuahitmyf())
	zd.initLiteSet(obj,"clubKualooklog",zd.makeLiteArray(makerSC.SCT_SCclubKualooklog()))
	zd.initLiteSet(obj,"clubKuapklog",zd.makeLiteArray(makerSC.SCT_SCclubKualog()))
	zd.initLiteSet(obj,"clubKuapkrwd",maker.CST_SCclubKuapkrwd())
	zd.initLiteSet(obj,"clubKuapkzr",maker.CST_SCclubKuapkzr())
	zd.initLiteSet(obj,"clubList",zd.makeLiteArray(makerSC.SCT_SClubList()))
	zd.initLiteSet(obj,"clubLog",zd.makeLiteArray(makerSC.SCT_SclubLog()))
	zd.initLiteSet(obj,"heroLog",zd.makeLiteArray(makerSC.SCT_SheroLog()))
	zd.initLiteSet(obj,"hitRank",zd.makeLiteArray(makerSC.SCT_jslist()))
	zd.initLiteSet(obj,"houseHoldReset",maker.CST_SC_houseHoldReset())
	zd.initLiteSet(obj,"householdInfo",zd.makeLiteArray(makerSC.SCT_HmembersInfo()))
	zd.initLiteSet(obj,"householdcj",zd.makeLiteArray(makerSC.SCT_Householdcj()))
	zd.initLiteSet(obj,"householdft",zd.makeLiteArray(makerSC.SCT_FightList()))
	zd.initLiteSet(obj,"kuaHeroList",zd.makeLiteArray(makerSC.SCT_FightList()))
	zd.initLiteSet(obj,"memberInfo",maker.CST_SMemberInfo())
	zd.initLiteSet(obj,"msmyScore",maker.CST_MsmyScore())
	zd.initLiteSet(obj,"msscoreRank",zd.makeLiteArray(makerSC.SCT_fUserInfo()))
	zd.initLiteSet(obj,"myClubRid",maker.CST_SCmyClubRid())
	zd.initLiteSet(obj,"selectBuild",zd.makeLiteArray(makerSC.SCT_SCselectBuild()))
	zd.initLiteSet(obj,"shareCD",maker.CST_SCclubShareCD())
	zd.initLiteSet(obj,"shopList",zd.makeLiteArray(makerSC.SCT_SShopList()))
	zd.initLiteSet(obj,"transInfo",zd.makeLiteArray(makerSC.SCT_membersInfo()))
	zd.initLiteSet(obj,"uidLog",maker.CST_SuidLog())
	zd.initLiteSet(obj,"win",maker.CST_clubbosswin())
	return obj
end

maker.CST_SC_zcjbhuodong = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg",maker.CST_Szcjbcfg())
	zd.initLiteSet(obj,"user",maker.CST_Szcjjuser())
	return obj
end

maker.CST_LaoFangWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"shouyawin","ShouYaWin")
	return obj
end

maker.CST_deskData = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"hid",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_Shdcfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"eTime",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"news",0)
	zd.initLiteSet(obj,"pindex",0)
	zd.initLiteSet(obj,"sTime",0)
	zd.initLiteSet(obj,"showTime",0)
	zd.initLiteSet(obj,"title","")
	zd.initLiteSet(obj,"type",1)
	return obj
end

maker.CST_zpflcfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"award",zd.makeLiteArray(makerSC.SCT_award_list()))
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"payyb",0)
	zd.initLiteSet(obj,"preview",zd.makeLiteArray(makerSC.SCT_award_list()))
	zd.initLiteSet(obj,"preview2",zd.makeLiteArray(makerSC.SCT_award_list()))
	zd.initLiteSet(obj,"times",3)
	return obj
end

maker.CST_SapplyList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"chatFrame",0)
	zd.initLiteSet(obj,"chenghao",0)
	zd.initLiteSet(obj,"dress",0)
	zd.initLiteSet(obj,"frame",0)
	zd.initLiteSet(obj,"head",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"job",1)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"sex",1)
	zd.initLiteSet(obj,"shili",0)
	return obj
end

maker.CST_CsRiskchangeTexiao = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_CS_getskin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dc",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"itemid",0)
	return obj
end

maker.CST_CxxlDailyBox = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_NoticeMsg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"body","")
	zd.initLiteSet(obj,"dateInfo","")
	zd.initLiteSet(obj,"gid","")
	zd.initLiteSet(obj,"header","")
	zd.initLiteSet(obj,"pid","")
	zd.initLiteSet(obj,"title","")
	return obj
end

maker.CST_blessVaild = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_QxCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"change_bless_use",0)
	zd.initLiteSet(obj,"cz_money",0)
	zd.initLiteSet(obj,"exchange",zd.makeLiteArray("ExchangeList"))
	zd.initLiteSet(obj,"rand_get",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"recover_money",0)
	zd.initLiteSet(obj,"rwd","NewYearrwdType")
	zd.initLiteSet(obj,"shenmi",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"shop",zd.makeLiteArray(makerSC.SCT_QxCfgShop()))
	zd.initLiteSet(obj,"today",maker.CST_CdLabel())
	return obj
end

maker.CST_UseItemInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",1)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"kind",1)
	return obj
end

maker.CST_SC_centralattackcityinfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"shili",0)
	zd.initLiteSet(obj,"user",maker.CST_UserEasyData())
	return obj
end

maker.CST_FuLiWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"shenji",zd.makeLiteArray(makerSC.SCT_ShenJiWin()))
	return obj
end

maker.CST_MoonClubFuli = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"first_build",0)
	zd.initLiteSet(obj,"is_moon",0)
	zd.initLiteSet(obj,"less_num",0)
	zd.initLiteSet(obj,"second_build",0)
	return obj
end

maker.CST_VipFuLiType = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CS_GuideClock = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"no",0)
	return obj
end

maker.CST_CS_ladder = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buyfight",maker.CST_Null())
	zd.initLiteSet(obj,"chushi",maker.CST_Null())
	zd.initLiteSet(obj,"come",maker.CST_Null())
	zd.initLiteSet(obj,"exchange",maker.CST_CShopChange())
	zd.initLiteSet(obj,"fight",maker.CST_heroId())
	zd.initLiteSet(obj,"findzhuisha",maker.CST_Fuid())
	zd.initLiteSet(obj,"fuchou",maker.CST_FuidHid())
	zd.initLiteSet(obj,"getMingren","")
	zd.initLiteSet(obj,"getMyRank",maker.CST_NULL())
	zd.initLiteSet(obj,"getRank",maker.CST_Null())
	zd.initLiteSet(obj,"getYxRank",maker.CST_NULL())
	zd.initLiteSet(obj,"getrwd",maker.CST_Null())
	zd.initLiteSet(obj,"ladder",maker.CST_Null())
	zd.initLiteSet(obj,"oneKeyPlay",maker.CST_idBase())
	zd.initLiteSet(obj,"pizun",maker.CST_Null())
	zd.initLiteSet(obj,"seladd","YaMenAddId")
	zd.initLiteSet(obj,"shopRefresh",maker.CST_CShopRefresh())
	zd.initLiteSet(obj,"tiaozhan",maker.CST_FuidHid2())
	zd.initLiteSet(obj,"yamenhistory",maker.CST_ChatId())
	zd.initLiteSet(obj,"zhuisha",maker.CST_FuidHid2())
	return obj
end

maker.CST_CxHbSend = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CSqxzbCid = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid",0)
	return obj
end

maker.CST_SkilInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"level",1)
	return obj
end

maker.CST_BHCZHDUserCz = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	return obj
end

maker.CST_zhengWuAct = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"act",0)
	return obj
end

maker.CST_Risktexiaolist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_CSkuaPKrwdget = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_HuntRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"baseRwd",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"heroes",zd.makeLiteArray("cabinetHeroes"))
	zd.initLiteSet(obj,"randRwd",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	return obj
end

maker.CST_RiskPower = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",0)
	zd.initLiteSet(obj,"jindu",0)
	zd.initLiteSet(obj,"max",0)
	zd.initLiteSet(obj,"new",0)
	zd.initLiteSet(obj,"power",0)
	zd.initLiteSet(obj,"tired",0)
	return obj
end

maker.CST_CS_Discord = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"jump",maker.CST_NULL())
	zd.initLiteSet(obj,"receive",maker.CST_NULL())
	return obj
end

maker.CST_HeroSkinList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hid",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_SkinInfo()))
	return obj
end

maker.CST_CS_HD496TaskDaily = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SC_centralattackherozhen = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"city",0)
	zd.initLiteSet(obj,"heros","")
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"keng",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"shili",0)
	return obj
end

maker.CST_FuLiFBDC = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dc",maker.CST_FuLiAddfbdc())
	zd.initLiteSet(obj,"fb",maker.CST_FuLiAddfbdc())
	return obj
end

maker.CST_BanishDays = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",100)
	return obj
end

maker.CST_SC_Order = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"back",maker.CST_Sback())
	zd.initLiteSet(obj,"orderstate",zd.makeLiteArray(makerSC.SCT_Sc_OrderTest()))
	zd.initLiteSet(obj,"rorder",maker.CST_Srorder())
	zd.initLiteSet(obj,"rshop",zd.makeLiteArray(makerSC.SCT_Srshop()))
	zd.initLiteSet(obj,"vipexp",zd.makeLiteArray(makerSC.SCT_Svipexp()))
	return obj
end

maker.CST_SC_Notice = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"actPics",zd.makeLiteArray(makerSC.SCT_ActNoticePic()))
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_NoticeMsg()))
	zd.initLiteSet(obj,"listNew",zd.makeLiteArray(makerSC.SCT_NoticeMsg()))
	return obj
end

maker.CST_SkinHd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hid",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_ScountryMemberList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"chatFrame",0)
	zd.initLiteSet(obj,"chenghao",0)
	zd.initLiteSet(obj,"dress",0)
	zd.initLiteSet(obj,"frame",0)
	zd.initLiteSet(obj,"head",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"job",1)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"post",0)
	zd.initLiteSet(obj,"sex",1)
	zd.initLiteSet(obj,"shili",0)
	return obj
end

maker.CST_SC_firstRecharge = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buy",0)
	return obj
end

maker.CST_RiskBosslist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bossname","")
	zd.initLiteSet(obj,"hp",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"x",0)
	zd.initLiteSet(obj,"y",0)
	return obj
end

maker.CST_JiuLouWinYhNew = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"allcredit",0)
	zd.initLiteSet(obj,"allep",0)
	zd.initLiteSet(obj,"allscore",0)
	zd.initLiteSet(obj,"bad",0)
	zd.initLiteSet(obj,"isover",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_yhnewlist()))
	zd.initLiteSet(obj,"maxnum",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"oldtype",0)
	return obj
end

maker.CST_CS = function(key)
	local obj = {}
	zd.makeLiteTable(obj)
	if key then
		zd.initLiteSet(obj, key, maker[_KeyMaps[key]]())
	else
		zd.initLiteSet(obj,"gameMachine",maker.CST_CS_GameMachine())
		zd.initLiteSet(obj,"gm",maker.CST_CS_GM())
		zd.initLiteSet(obj,"guide",maker.CST_CS_Guide())
		zd.initLiteSet(obj,"hero",maker.CST_CS_Hero())
		zd.initLiteSet(obj,"item",maker.CST_CS_Item())
		zd.initLiteSet(obj,"login",maker.CST_CS_Login())
		zd.initLiteSet(obj,"mail",maker.CST_CS_Mail())
		zd.initLiteSet(obj,"map",maker.CST_CS_Map())
		zd.initLiteSet(obj,"order",maker.CST_CS_Order())
		zd.initLiteSet(obj,"recode",maker.CST_CS_Code())
		zd.initLiteSet(obj,"shop",maker.CST_CS_Shop())
		zd.initLiteSet(obj,"story",maker.CST_CS_Story())
		zd.initLiteSet(obj,"task",maker.CST_CS_Task())
		zd.initLiteSet(obj,"user",maker.CST_CS_User())
	end
	return obj
end

maker.CST_CClubBossInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid",maker.CST_Null())
	return obj
end

maker.CST_SjlShopfresh = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fcost",0)
	zd.initLiteSet(obj,"fmax",0)
	zd.initLiteSet(obj,"fnum",0)
	return obj
end

maker.CST_jingYingId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"jyid",0)
	return obj
end

maker.CST_CS_Friends = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fRefuseApply",maker.CST_FRefuseApply())
	zd.initLiteSet(obj,"fapply",maker.CST_Fuid())
	zd.initLiteSet(obj,"fapplylist",maker.CST_Null())
	zd.initLiteSet(obj,"ffchat",maker.CST_Fuid())
	zd.initLiteSet(obj,"fhistory",maker.CST_CFhistory())
	zd.initLiteSet(obj,"flist",maker.CST_Null())
	zd.initLiteSet(obj,"fllist",maker.CST_Null())
	zd.initLiteSet(obj,"fno",maker.CST_Fuid())
	zd.initLiteSet(obj,"fok",maker.CST_Fuid())
	zd.initLiteSet(obj,"frchat",maker.CST_Fuid())
	zd.initLiteSet(obj,"fschat",maker.CST_Sfschat())
	zd.initLiteSet(obj,"fssub",maker.CST_Fuid())
	zd.initLiteSet(obj,"fsub",maker.CST_Fuid())
	zd.initLiteSet(obj,"getAllJl",maker.CST_Null())
	zd.initLiteSet(obj,"getJl",maker.CST_Fuid())
	zd.initLiteSet(obj,"getNew",maker.CST_Null())
	zd.initLiteSet(obj,"jlList",maker.CST_Null())
	zd.initLiteSet(obj,"qjlist",maker.CST_Null())
	zd.initLiteSet(obj,"qjvisit",maker.CST_Fuid())
	zd.initLiteSet(obj,"sendAllJl",maker.CST_Null())
	zd.initLiteSet(obj,"sendJl",maker.CST_Fuid())
	return obj
end

maker.CST_SkinGetRank = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SC_Task = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"tmain",maker.CST_Stmain())
	return obj
end

maker.CST_SC_Hero = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"heroCj",zd.makeLiteArray(makerSC.SCT_HeroChengjiu()))
	zd.initLiteSet(obj,"heroFigure",zd.makeLiteArray(makerSC.SCT_HeroFigure()))
	zd.initLiteSet(obj,"heroList",zd.makeLiteArray(makerSC.SCT_HeroInfo()))
	zd.initLiteSet(obj,"onekey",maker.CST_onKeyUp())
	zd.initLiteSet(obj,"skin",maker.CST_HeroSkin())
	return obj
end

maker.CST_BanishRecall = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"did",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CS_Map = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"setAllDocument",maker.CST_MapDoc())
	zd.initLiteSet(obj,"setDocument",maker.CST_MapDoc())
	return obj
end

maker.CST_CS_Chat = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"addblacklist",maker.CST_BlackId())
	zd.initLiteSet(obj,"club",maker.CST_ChatMsg())
	zd.initLiteSet(obj,"clubhistory",maker.CST_ChatId())
	zd.initLiteSet(obj,"country",maker.CST_ChatMsg())
	zd.initLiteSet(obj,"countryHistory",maker.CST_ChatId())
	zd.initLiteSet(obj,"getBackDetailList","")
	zd.initLiteSet(obj,"getTargetLanguage",maker.CST_NULL())
	zd.initLiteSet(obj,"kuafu",maker.CST_ChatMsg())
	zd.initLiteSet(obj,"kuafuhistory",maker.CST_ChatId())
	zd.initLiteSet(obj,"mjClubChatCheck","")
	zd.initLiteSet(obj,"mjHuodongChatCheck","")
	zd.initLiteSet(obj,"mjdsClubChat",maker.CST_ChatMsg())
	zd.initLiteSet(obj,"mjdsClubHistory",maker.CST_ChatId())
	zd.initLiteSet(obj,"mjdsHuodongChat",maker.CST_ChatMsg())
	zd.initLiteSet(obj,"mjdsHuodongHistory",maker.CST_ChatId())
	zd.initLiteSet(obj,"setTargetLanguage",maker.CST_targetLanguage())
	zd.initLiteSet(obj,"sev",maker.CST_ChatMsg())
	zd.initLiteSet(obj,"sevhistory",maker.CST_ChatId())
	zd.initLiteSet(obj,"subblacklist",maker.CST_BlackId())
	zd.initLiteSet(obj,"translateGeneral",maker.CST_SourceTextInfo())
	return obj
end

maker.CST_CSSetUserDress = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CShd336Buy = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_FuLiAddfbdc = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"host",maker.CST_ItemInfo())
	zd.initLiteSet(obj,"index",0)
	zd.initLiteSet(obj,"link","")
	zd.initLiteSet(obj,"link2","")
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"name","")
	return obj
end

maker.CST_zg_yjZhengWuAct = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"act",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_ClubCZHDUserRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_ClubCZHDUserRwdList()))
	return obj
end

maker.CST_ChatPunish = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"t","")
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_SC_DrawHuodong = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg","SCDrawHuodongCfg")
	zd.initLiteSet(obj,"myRankRid","XgMyScore")
	zd.initLiteSet(obj,"sRank",zd.makeLiteArray("SCDrawHuodongSRank"))
	zd.initLiteSet(obj,"user","SCDrawHuodongUser")
	zd.initLiteSet(obj,"win","SCDrawHuodongWin")
	zd.initLiteSet(obj,"winyb","SCDrawHuodongWin")
	return obj
end

maker.CST_HhMake = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"heroid",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_UserGuide = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bmap",0)
	zd.initLiteSet(obj,"gnew",0)
	zd.initLiteSet(obj,"gnew_child",0)
	zd.initLiteSet(obj,"mmap",0)
	zd.initLiteSet(obj,"smap",0)
	return obj
end

maker.CST_Sneedcfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"price",0)
	zd.initLiteSet(obj,"vip","0")
	return obj
end

maker.CST_ShenJiWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_WordBossRoot = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"status",0)
	return obj
end

maker.CST_ScXxlCfgRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_IDCOUNT()))
	zd.initLiteSet(obj,"rand",maker.CST_SC_ComRankRange())
	return obj
end

maker.CST_Sjccfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_Shdinfo())
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_Sjchdrwd()))
	return obj
end

maker.CST_items_list = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",1)
	zd.initLiteSet(obj,"id",1)
	zd.initLiteSet(obj,"kind",1)
	return obj
end

maker.CST_ChatMsgInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"gid","")
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"isGM",0)
	zd.initLiteSet(obj,"lang_code","")
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"rm",0)
	zd.initLiteSet(obj,"t",0)
	zd.initLiteSet(obj,"time",0)
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"user",maker.CST_fUserInfo())
	zd.initLiteSet(obj,"v","")
	return obj
end

maker.CST_ryqdUseAndBuy = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"sevid",0)
	return obj
end

maker.CST_ZQCfgUse = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"get",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"limit",0)
	zd.initLiteSet(obj,"need",0)
	return obj
end

maker.CST_newcjyxfyh = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"need",maker.CST_ItemInfo())
	zd.initLiteSet(obj,"xqz",maker.CST_ItemInfo())
	return obj
end

maker.CST_CClubInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid",maker.CST_Null())
	return obj
end

maker.CST_srand = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"re",0)
	zd.initLiteSet(obj,"rs",0)
	return obj
end

maker.CST_ScTansuoWife = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_GerdanKillWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"score2",0)
	return obj
end

maker.CST_SC_BeiJing = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bjInfo",maker.CST_CHinfo())
	return obj
end

maker.CST_HeroChengjiuDcInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dc",0)
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_CorderBack = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",maker.CST_Null())
	return obj
end

maker.CST_SkinShopList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"islimit",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"limit",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"need",maker.CST_ItemInfo())
	zd.initLiteSet(obj,"vip",0)
	return obj
end

maker.CST_SCclubKuaCszr = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"allnum",0)
	zd.initLiteSet(obj,"allshili",0)
	zd.initLiteSet(obj,"clevel",0)
	zd.initLiteSet(obj,"cname","")
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_SCcslist()))
	zd.initLiteSet(obj,"mzpic",maker.CST_SCmzpic())
	zd.initLiteSet(obj,"post",maker.CST_SCpost())
	zd.initLiteSet(obj,"servid",0)
	return obj
end

maker.CST_HblastHb = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"stime",0)
	return obj
end

maker.CST_Sc2048Hero = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"epskill",0)
	zd.initLiteSet(obj,"hero_id",0)
	zd.initLiteSet(obj,"maxSingScore",0)
	zd.initLiteSet(obj,"rank_score",0)
	zd.initLiteSet(obj,"skill_id",0)
	return obj
end

maker.CST_NewYearBag = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"baozu",0)
	zd.initLiteSet(obj,"yanhua",0)
	return obj
end

maker.CST_CShopInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",maker.CST_Null())
	return obj
end

maker.CST_MoBai = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_HbreceiveRedList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_SC_FourGoodBase = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bought",0)
	zd.initLiteSet(obj,"buyLvCfg",maker.CST_SC_FourGoodBuyLevelCfg())
	zd.initLiteSet(obj,"each",0)
	zd.initLiteSet(obj,"exp",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"max",0)
	zd.initLiteSet(obj,"reset",0)
	zd.initLiteSet(obj,"rule","")
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"week",0)
	zd.initLiteSet(obj,"weeks",0)
	return obj
end

maker.CST_CS_tansuo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"getInfo",maker.CST_CsTsMap())
	zd.initLiteSet(obj,"getRwd",maker.CST_CsTsGetRwd())
	zd.initLiteSet(obj,"giveupEvent",maker.CST_CsTsGiveup())
	zd.initLiteSet(obj,"processEvent",maker.CST_CsTsProcess())
	zd.initLiteSet(obj,"recover",maker.CST_CsTsRecover())
	zd.initLiteSet(obj,"tansuo",maker.CST_CsTsType())
	return obj
end

maker.CST_HeroChengjiu = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dc_list",zd.makeLiteArray(makerSC.SCT_HeroChengjiuDcInfo()))
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_RiskMapid = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"mapmid",0)
	zd.initLiteSet(obj,"maxmap",0)
	return obj
end

maker.CST_CS_useSkinSelect = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"sid",0)
	return obj
end

maker.CST_PlatVipGiftNotice = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"result",0)
	zd.initLiteSet(obj,"win",maker.CST_SC_Windows())
	return obj
end

maker.CST_Sc2048GameData = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"map","")
	zd.initLiteSet(obj,"seed",0)
	return obj
end

maker.CST_Sc_butler_do = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"check",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CShdRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_ScSkinShop = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_SkinShopList()))
	return obj
end

maker.CST_SC_centralattackinfofbscore = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_SC_centralattackinfofbscorelist()))
	return obj
end

maker.CST_UserEasyData = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"chatFrame",0)
	zd.initLiteSet(obj,"chenghao",0)
	zd.initLiteSet(obj,"dress",0)
	zd.initLiteSet(obj,"exp",0)
	zd.initLiteSet(obj,"frame",0)
	zd.initLiteSet(obj,"head",0)
	zd.initLiteSet(obj,"job",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"maxmap",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"num1",0)
	zd.initLiteSet(obj,"num2",0)
	zd.initLiteSet(obj,"num3",0)
	zd.initLiteSet(obj,"sevid",0)
	zd.initLiteSet(obj,"sex",0)
	zd.initLiteSet(obj,"shili",0)
	zd.initLiteSet(obj,"signName","")
	zd.initLiteSet(obj,"uid",0)
	zd.initLiteSet(obj,"vip",0)
	return obj
end

maker.CST_HeroInfo1 = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hero_allep",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CS_Task = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"taskdo",maker.CST_Cdo())
	return obj
end

maker.CST_CS_Hero = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bindHero",maker.CST_CS_HerobindHero())
	zd.initLiteSet(obj,"getBindHero",maker.CST_Null())
	zd.initLiteSet(obj,"heroCjInfo",maker.CST_Null())
	zd.initLiteSet(obj,"heroCjRwd",maker.CST_heroCjRwd())
	zd.initLiteSet(obj,"upghskill",maker.CST_heroGhkillId())
	zd.initLiteSet(obj,"upgrade",maker.CST_heroId())
	zd.initLiteSet(obj,"upgradeTen",maker.CST_heroId())
	zd.initLiteSet(obj,"uppkskill",maker.CST_heroSkillId())
	zd.initLiteSet(obj,"upsenior",maker.CST_heroId())
	zd.initLiteSet(obj,"upzzskill",maker.CST_heroSkillIdType())
	return obj
end

maker.CST_QxUserExchange = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_ChatMsg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"msg","")
	return obj
end

maker.CST_CsTsProcess = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"gid",0)
	zd.initLiteSet(obj,"param",0)
	return obj
end

maker.CST_CsFightBoss = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bossid",0)
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"x",0)
	zd.initLiteSet(obj,"y",0)
	return obj
end

maker.CST_CRiskgetinNewMap = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"mid",0)
	return obj
end

maker.CST_Schlist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SC_Banish = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"base",maker.CST_BanishDesk())
	zd.initLiteSet(obj,"days",maker.CST_BanishDays())
	zd.initLiteSet(obj,"deskCashList",zd.makeLiteArray(makerSC.SCT_BanishDeskCashList()))
	zd.initLiteSet(obj,"herolist",zd.makeLiteArray(makerSC.SCT_BanishHeroList()))
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_BanishList()))
	return obj
end

maker.CST_CXxGuest = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",maker.CST_Null())
	return obj
end

maker.CST_membersInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"allGx",0)
	zd.initLiteSet(obj,"chatFrame",0)
	zd.initLiteSet(obj,"chenghao",0)
	zd.initLiteSet(obj,"cyBan",0)
	zd.initLiteSet(obj,"dress",0)
	zd.initLiteSet(obj,"fjianshe",0)
	zd.initLiteSet(obj,"frame",0)
	zd.initLiteSet(obj,"gx",0)
	zd.initLiteSet(obj,"head",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"inTime",maker.CST_CdLabel())
	zd.initLiteSet(obj,"jianshe",0)
	zd.initLiteSet(obj,"job",0)
	zd.initLiteSet(obj,"lessBoosNum",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"loginTime",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"nianka",0)
	zd.initLiteSet(obj,"post",0)
	zd.initLiteSet(obj,"sex",0)
	zd.initLiteSet(obj,"shili",0)
	zd.initLiteSet(obj,"yueka",0)
	return obj
end

maker.CST_Riskbossxianqing = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"pvewin",maker.CST_Riskdamage())
	return obj
end

maker.CST_RiskBiaoxian = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"index",0)
	zd.initLiteSet(obj,"step",0)
	return obj
end

maker.CST_ScKitchen = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cpid",0)
	zd.initLiteSet(obj,"cpnum",0)
	zd.initLiteSet(obj,"cpnuming",0)
	zd.initLiteSet(obj,"cptotal",0)
	zd.initLiteSet(obj,"kc",0)
	zd.initLiteSet(obj,"makeing",0)
	zd.initLiteSet(obj,"ncpnum",0)
	zd.initLiteSet(obj,"plv",0)
	zd.initLiteSet(obj,"zylv",0)
	return obj
end

maker.CST_CS_Hd390UpLevel = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SC_PlatVipGift = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"daily_info",maker.CST_PlatVipGiftReturn())
	zd.initLiteSet(obj,"daily_rwd",maker.CST_PlatVipGiftNotice())
	zd.initLiteSet(obj,"tequan_info",maker.CST_PlatVipGiftReturn())
	zd.initLiteSet(obj,"tequan_rwd",maker.CST_PlatVipGiftNotice())
	return obj
end

maker.CST_Ssllist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"gid","")
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"lang_code","")
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"time",0)
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_Cdo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SC_Anniversary = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",zd.makeLiteArray("AnniversaryInfoDetail"))
	zd.initLiteSet(obj,"leiji","AnniversaryInfoLeiji")
	return obj
end

maker.CST_Cwyrwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"chid",maker.CST_Null())
	return obj
end

maker.CST_survey_answer = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"answer",zd.makeLiteArray(makerSC.SCT_all_answer()))
	return obj
end

maker.CST_Banishreduce = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"did",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_newCjyxCp = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"zi",zd.makeLiteArray("GesyUserWz"))
	return obj
end

maker.CST_Duration = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"lv",0)
	zd.initLiteSet(obj,"time",0)
	return obj
end

maker.CST_newcjyxlibao = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"xqz",maker.CST_ItemInfo())
	return obj
end

maker.CST_CShd336Up = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_LoginAccount = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"account_name","")
	zd.initLiteSet(obj,"account_type","")
	zd.initLiteSet(obj,"ad_channel","")
	zd.initLiteSet(obj,"ad_subchannel","")
	zd.initLiteSet(obj,"app_ver","")
	zd.initLiteSet(obj,"dev_brand","")
	zd.initLiteSet(obj,"dev_imei","")
	zd.initLiteSet(obj,"dev_lat","")
	zd.initLiteSet(obj,"dev_lon","")
	zd.initLiteSet(obj,"dev_mac","")
	zd.initLiteSet(obj,"dev_model","")
	zd.initLiteSet(obj,"dev_os","")
	zd.initLiteSet(obj,"dev_osver","")
	zd.initLiteSet(obj,"dev_res","")
	zd.initLiteSet(obj,"dev_uuid","")
	zd.initLiteSet(obj,"dh_token","")
	zd.initLiteSet(obj,"from_ch","")
	zd.initLiteSet(obj,"lang","")
	zd.initLiteSet(obj,"logintype","")
	zd.initLiteSet(obj,"nation","")
	zd.initLiteSet(obj,"network_type","")
	zd.initLiteSet(obj,"openid","")
	zd.initLiteSet(obj,"pkg_name","")
	zd.initLiteSet(obj,"platform","")
	zd.initLiteSet(obj,"timestamp","")
	return obj
end

maker.CST_hd748GetRechargeParams = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CS_Mail = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"delAllMails",maker.CST_NULL())
	zd.initLiteSet(obj,"delMail",maker.CST_MailIdParam())
	zd.initLiteSet(obj,"getMail",maker.CST_Null())
	zd.initLiteSet(obj,"openMail",maker.CST_MailIdParam())
	zd.initLiteSet(obj,"receiveAllItems",maker.CST_NULL())
	zd.initLiteSet(obj,"receiveItem",maker.CST_MailIdParam())
	return obj
end

maker.CST_SC_zdzd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_ZdzdInfo())
	return obj
end

maker.CST_SCselectBuild = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"build",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_redpacket = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hid",0)
	return obj
end

maker.CST_Verify = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"status",1)
	return obj
end

maker.CST_SC_socialdressed = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"list",maker.CST_SCsocialdressedall())
	zd.initLiteSet(obj,"news",0)
	zd.initLiteSet(obj,"setChatFrame",0)
	zd.initLiteSet(obj,"setFrame",0)
	zd.initLiteSet(obj,"setHead",0)
	return obj
end

maker.CST_ScXxlCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dayRwd",zd.makeLiteArray(makerSC.SCT_ScXxlCfgDayRwd()))
	zd.initLiteSet(obj,"exchange",zd.makeLiteArray(makerSC.SCT_ScXxlCfgShop()))
	zd.initLiteSet(obj,"info",maker.CST_Shdinfo())
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_ScXxlCfgRwd()))
	zd.initLiteSet(obj,"shop",zd.makeLiteArray(makerSC.SCT_ScXxlCfgShop()))
	zd.initLiteSet(obj,"strength",maker.CST_ScXxlCfgStrength())
	return obj
end

maker.CST_CS_GuideChooseWife = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"wifeId",0)
	return obj
end

maker.CST_CShd332Up = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CS_getSelectItem = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"itemid",0)
	return obj
end

maker.CST_CsMysteryExchange = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"gid",0)
	return obj
end

maker.CST_SC_longzhoujdbox_Rwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"get",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"need",0)
	return obj
end

maker.CST_SC_loginModError = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"msg","")
	return obj
end

maker.CST_SC_ldjcbkhuodong = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg",maker.CST_SCldjcbkhdCfg())
	zd.initLiteSet(obj,"user",maker.CST_SCldjcbkhdUser())
	return obj
end

maker.CST_QxUser = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bless","")
	zd.initLiteSet(obj,"cz",maker.CST_QxUserCz())
	zd.initLiteSet(obj,"exchange",zd.makeLiteArray(makerSC.SCT_QxUserExchange()))
	zd.initLiteSet(obj,"flower",zd.makeLiteArray(makerSC.SCT_QxUserFlower()))
	zd.initLiteSet(obj,"hd_score",0)
	zd.initLiteSet(obj,"lq",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"score",0)
	return obj
end

maker.CST_ZQCfgUseSeekRrobRand = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"item",maker.CST_ItemInfo())
	return obj
end

maker.CST_GrowFundInfoLevel = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CSSevenTaskFirstRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"wid",0)
	return obj
end

maker.CST_TransWang = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid",0)
	zd.initLiteSet(obj,"password",0)
	return obj
end

maker.CST_survey_getrwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"success",0)
	return obj
end

maker.CST_DerailList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"blacklist",1)
	zd.initLiteSet(obj,"status",1)
	zd.initLiteSet(obj,"switch","")
	return obj
end

maker.CST_SC_Derail = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"list",maker.CST_DerailList())
	return obj
end

maker.CST_ladder_list = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"beijing",0)
	zd.initLiteSet(obj,"chatFrame",0)
	zd.initLiteSet(obj,"chenghao",0)
	zd.initLiteSet(obj,"dress",0)
	zd.initLiteSet(obj,"duanwei",0)
	zd.initLiteSet(obj,"extra_ch","")
	zd.initLiteSet(obj,"frame",0)
	zd.initLiteSet(obj,"guajian",0)
	zd.initLiteSet(obj,"head",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"isHe",0)
	zd.initLiteSet(obj,"job",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"mingrenchenghao",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"num2",0)
	zd.initLiteSet(obj,"num3",0)
	zd.initLiteSet(obj,"num4","")
	zd.initLiteSet(obj,"offlineCh","")
	zd.initLiteSet(obj,"pet_addi",0)
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"sex",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"uid",0)
	zd.initLiteSet(obj,"vip",0)
	zd.initLiteSet(obj,"vipStatus",1)
	return obj
end

maker.CST_SC_viphuodong = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"service",maker.CST_Sservice())
	return obj
end

maker.CST_SC_followGift = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg","FollowGiftCfg")
	zd.initLiteSet(obj,"user","FollowGiftUser")
	return obj
end

maker.CST_Hd445getRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CJlRanking = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",maker.CST_Null())
	return obj
end

maker.CST_FuidHid3 = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid",0)
	zd.initLiteSet(obj,"hid",0)
	zd.initLiteSet(obj,"time",0)
	return obj
end

maker.CST_FuidHid2 = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid",0)
	zd.initLiteSet(obj,"hid",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_Sservice = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg","Svshdcfg")
	zd.initLiteSet(obj,"recharge",0)
	return obj
end

maker.CST_newcjyxrecharge = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"get",zd.makeLiteArray(makerSC.SCT_newcjyxrecharge_get()))
	zd.initLiteSet(obj,"money",0)
	return obj
end

maker.CST_SC_centralattackinfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"addscore",0)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"fbscore",zd.makeLiteArray(makerSC.SCT_SC_centralattackinfofbscore()))
	zd.initLiteSet(obj,"freehero",0)
	zd.initLiteSet(obj,"get",0)
	zd.initLiteSet(obj,"money",0)
	zd.initLiteSet(obj,"mycity",maker.CST_SC_centralattackcity())
	zd.initLiteSet(obj,"qrwd",zd.makeLiteArray(makerSC.SCT_Scbhdrwd()))
	zd.initLiteSet(obj,"qua",0)
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_Scbhdrwd()))
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_kwife = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_FightList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"f",0)
	zd.initLiteSet(obj,"h",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CSSevenTaskRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CS_Courtyard = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buy",maker.CST_Null())
	zd.initLiteSet(obj,"buyShop",maker.CST_CsCourtyardShop())
	zd.initLiteSet(obj,"change_qian",maker.CST_blesschange())
	zd.initLiteSet(obj,"comeCourtyard",maker.CST_Null())
	zd.initLiteSet(obj,"comeFarm",maker.CST_Null())
	zd.initLiteSet(obj,"comeHunting",maker.CST_Null())
	zd.initLiteSet(obj,"comeKitchen",maker.CST_Null())
	zd.initLiteSet(obj,"cpScore",maker.CST_CscpScore())
	zd.initLiteSet(obj,"enterbless",maker.CST_Null())
	zd.initLiteSet(obj,"exchange",maker.CST_CsCourtyardExchange())
	zd.initLiteSet(obj,"getBag",maker.CST_Null())
	zd.initLiteSet(obj,"getCourtyardDayRwd",maker.CST_Null())
	zd.initLiteSet(obj,"getRwd",maker.CST_ParamId())
	zd.initLiteSet(obj,"harvest",maker.CST_CsCourtyardHarvest())
	zd.initLiteSet(obj,"hunting",maker.CST_huntDispatchInfo())
	zd.initLiteSet(obj,"is_valid",maker.CST_blessVaild())
	zd.initLiteSet(obj,"kMenu",maker.CST_Null())
	zd.initLiteSet(obj,"madeMenu",maker.CST_CsMadeMenu())
	zd.initLiteSet(obj,"openFarm",maker.CST_idBase())
	zd.initLiteSet(obj,"plantFarm",maker.CST_CsCourtyardPlantFarm())
	zd.initLiteSet(obj,"refreshTask",maker.CST_Null())
	zd.initLiteSet(obj,"seeRwd",maker.CST_ParamId())
	zd.initLiteSet(obj,"upPan",maker.CST_Null())
	zd.initLiteSet(obj,"upgradeCourtyard",maker.CST_Null())
	zd.initLiteSet(obj,"yao",maker.CST_blessYao())
	return obj
end

maker.CST_CSSetGuidePass = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_PaoMsgInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"outtime",0)
	return obj
end

maker.CST_SCclubKuaMsg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"msg","")
	return obj
end

maker.CST_SC_CourtyardFishing = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"auto",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"my",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"predict",0)
	zd.initLiteSet(obj,"scRwd",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"time",0)
	zd.initLiteSet(obj,"yr",0)
	return obj
end

maker.CST_RiskMapNow = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"x",0)
	zd.initLiteSet(obj,"y",0)
	return obj
end

maker.CST_HeroFigure = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"figure",1)
	zd.initLiteSet(obj,"id",1)
	return obj
end

maker.CST_ScTansuoWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"eid",0)
	zd.initLiteSet(obj,"gid","")
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_rwdItems()))
	return obj
end

maker.CST_CsRiskGetRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_Shdverinfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"ver",0)
	return obj
end

maker.CST_CScallBackHero = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hid",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CS_Hd390LevelRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_RiskMapCd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"mid",0)
	zd.initLiteSet(obj,"time",0)
	return obj
end

maker.CST_SC_centralattackhero = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_SC_centralattackherolist()))
	zd.initLiteSet(obj,"shiliexp",0)
	zd.initLiteSet(obj,"shililv",0)
	return obj
end

maker.CST_SC_bhczhuodong = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg",zd.makeLiteArray(makerSC.SCT_BHCZHDCfg()))
	zd.initLiteSet(obj,"clubczinfo",zd.makeLiteArray(makerSC.SCT_BHCZHDClub()))
	zd.initLiteSet(obj,"info",maker.CST_BHCZHDInfo())
	zd.initLiteSet(obj,"user",maker.CST_BHCZHDUser())
	return obj
end

maker.CST_SC_Courtyard = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bag",zd.makeLiteArray(makerSC.SCT_IDNUM()))
	zd.initLiteSet(obj,"base",maker.CST_ScCourtyardBase())
	zd.initLiteSet(obj,"blessing",maker.CST_Scblessing())
	zd.initLiteSet(obj,"eatcp",maker.CST_ScKeatcp())
	zd.initLiteSet(obj,"exchange",zd.makeLiteArray(makerSC.SCT_IDNUM()))
	zd.initLiteSet(obj,"farm",maker.CST_ScCourtyardFarm())
	zd.initLiteSet(obj,"fishing",maker.CST_SC_CourtyardFishing())
	zd.initLiteSet(obj,"fishing_res",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"ft",zd.makeLiteArray("Cxhd631Paiqian"))
	zd.initLiteSet(obj,"hunting",maker.CST_ScHunting())
	zd.initLiteSet(obj,"kitchen",maker.CST_ScKitchen())
	zd.initLiteSet(obj,"menu",maker.CST_ScKitchenMenu())
	return obj
end

maker.CST_CgetOrderId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"diamond",0)
	zd.initLiteSet(obj,"id",maker.CST_Null())
	zd.initLiteSet(obj,"onlinetime",0)
	zd.initLiteSet(obj,"platform",maker.CST_Null())
	return obj
end

maker.CST_SCDllhdUserList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"st",0)
	return obj
end

maker.CST_Scdailysore_rwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_dailyrwditemlist()))
	return obj
end

maker.CST_CS_Club = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"applyList",maker.CST_CApplyList())
	zd.initLiteSet(obj,"checkVip",maker.CST_NULL())
	zd.initLiteSet(obj,"clubApply",maker.CST_CApply())
	zd.initLiteSet(obj,"clubBigBossHitList",maker.CST_CClubBossHitList())
	zd.initLiteSet(obj,"clubBigBossInfo",maker.CST_CClubBossInfo())
	zd.initLiteSet(obj,"clubBigBossOpen",maker.CST_CClubBossOpen())
	zd.initLiteSet(obj,"clubBigBossPK",maker.CST_CClubBossPK())
	zd.initLiteSet(obj,"clubBigBossPK_yj",maker.CST_CClubBossPK())
	zd.initLiteSet(obj,"clubBigBosslog",maker.CST_CClubBosslog())
	zd.initLiteSet(obj,"clubBossHitList",maker.CST_CClubBossHitList())
	zd.initLiteSet(obj,"clubBossInfo",maker.CST_CClubBossInfo())
	zd.initLiteSet(obj,"clubBossOpen",maker.CST_CClubBossOpen())
	zd.initLiteSet(obj,"clubBossPK",maker.CST_CClubBossPK())
	zd.initLiteSet(obj,"clubBosslog",maker.CST_CClubBosslog())
	zd.initLiteSet(obj,"clubCreate",maker.CST_CCreate())
	zd.initLiteSet(obj,"clubFind",maker.CST_CFind())
	zd.initLiteSet(obj,"clubHeroBatchCone",maker.CST_NULL())
	zd.initLiteSet(obj,"clubHeroCone",maker.CST_CClubHeroCone())
	zd.initLiteSet(obj,"clubInfo",maker.CST_CClubInfo())
	zd.initLiteSet(obj,"clubInfoClearNoteNews",maker.CST_CInfoClearNoteNews())
	zd.initLiteSet(obj,"clubInfoSave",maker.CST_CInfoSave())
	zd.initLiteSet(obj,"clubInfoSaveNote",maker.CST_CInfoSaveNote())
	zd.initLiteSet(obj,"clubList",maker.CST_CClubList())
	zd.initLiteSet(obj,"clubMsHeroCone",maker.CST_CClubHeroCone())
	zd.initLiteSet(obj,"clubName",maker.CST_CName())
	zd.initLiteSet(obj,"clubPwd",maker.CST_CclubPwd())
	zd.initLiteSet(obj,"clubRand",maker.CST_CRand())
	zd.initLiteSet(obj,"dayGongXian",maker.CST_CDayGongXian())
	zd.initLiteSet(obj,"dayGongXianNum",maker.CST_NULL())
	zd.initLiteSet(obj,"delClub",maker.CST_CDelClub())
	zd.initLiteSet(obj,"getClubPwd","")
	zd.initLiteSet(obj,"houseHoldReset",maker.CST_NULL())
	zd.initLiteSet(obj,"householdCjInfo",maker.CST_NULL())
	zd.initLiteSet(obj,"householdInfo",maker.CST_NULL())
	zd.initLiteSet(obj,"householdMake",maker.CST_HhMake())
	zd.initLiteSet(obj,"householdRankInfo",maker.CST_CChousehold())
	zd.initLiteSet(obj,"householdRwd",maker.CST_CChousehold())
	zd.initLiteSet(obj,"isJoin",maker.CST_CIsJoin())
	zd.initLiteSet(obj,"kuaLookHit",maker.CST_CSkuaLookHit())
	zd.initLiteSet(obj,"kuaLookWin",maker.CST_CSkuaLookWin())
	zd.initLiteSet(obj,"kuaPKAdd",maker.CST_CSkuaPKAdd())
	zd.initLiteSet(obj,"kuaPKBack",maker.CST_CSkuaPKBack())
	zd.initLiteSet(obj,"kuaPKCszr",maker.CST_CSkuaPKCszr())
	zd.initLiteSet(obj,"kuaPKMonthMobai",maker.CST_NULL())
	zd.initLiteSet(obj,"kuaPKbflog",maker.CST_CSkuaPKbflog())
	zd.initLiteSet(obj,"kuaPKinfo",maker.CST_CSkuaPKinfo())
	zd.initLiteSet(obj,"kuaPKrwdget",maker.CST_CSkuaPKrwdget())
	zd.initLiteSet(obj,"kuaPKrwdinfo",maker.CST_CSkuaPKrwdinfo())
	zd.initLiteSet(obj,"kuaPKusejn",maker.CST_CSkuaPKusejn())
	zd.initLiteSet(obj,"kuaPKzr",maker.CST_CSkuaPKBack())
	zd.initLiteSet(obj,"kuaPkMonthInfo",maker.CST_NULL())
	zd.initLiteSet(obj,"kuaPkMonthRwd",maker.CST_NULL())
	zd.initLiteSet(obj,"memberPost",maker.CST_CMemberPost())
	zd.initLiteSet(obj,"noJoin",maker.CST_CNoJoin())
	zd.initLiteSet(obj,"outClub",maker.CST_COutClub())
	zd.initLiteSet(obj,"rwdWaterTransStartScore",maker.CST_NULL())
	zd.initLiteSet(obj,"selectBuild",maker.CST_CSselectBuild())
	zd.initLiteSet(obj,"sendChat",maker.CST_NULL())
	zd.initLiteSet(obj,"shopBuy",maker.CST_CShopBuy())
	zd.initLiteSet(obj,"shopList",maker.CST_CShopList())
	zd.initLiteSet(obj,"transList",maker.CST_NULL())
	zd.initLiteSet(obj,"transWang",maker.CST_TransWang())
	zd.initLiteSet(obj,"yesJoin",maker.CST_CYesJoin())
	return obj
end

maker.CST_SC_User = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"guide",maker.CST_SCUserGuide())
	zd.initLiteSet(obj,"inherit",maker.CST_SCinherit())
	zd.initLiteSet(obj,"offline",maker.CST_SCOffline())
	zd.initLiteSet(obj,"paomadeng",zd.makeLiteArray(makerSC.SCT_pmdList()))
	zd.initLiteSet(obj,"pvb",zd.makeLiteArray(makerSC.SCT_FightList()))
	zd.initLiteSet(obj,"user",maker.CST_UserInfo())
	zd.initLiteSet(obj,"verify",maker.CST_SCUserVerify())
	zd.initLiteSet(obj,"version",maker.CST_SCVersion())
	return obj
end

maker.CST_CS_KuaMine = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"eventOpen",maker.CST_ParamKey())
	zd.initLiteSet(obj,"fMine",maker.CST_ParamId())
	zd.initLiteSet(obj,"fightLos",maker.CST_ParamId())
	zd.initLiteSet(obj,"giveup",maker.CST_MineId())
	zd.initLiteSet(obj,"grab",maker.CST_KuaMineGrab())
	zd.initLiteSet(obj,"mineInfo",maker.CST_MineId())
	zd.initLiteSet(obj,"myLogs",maker.CST_Null())
	zd.initLiteSet(obj,"myMine",maker.CST_Null())
	zd.initLiteSet(obj,"myResource",maker.CST_Null())
	zd.initLiteSet(obj,"occupy",maker.CST_KuaMineOccupy())
	zd.initLiteSet(obj,"probe",maker.CST_Null())
	zd.initLiteSet(obj,"receive",maker.CST_ParamId())
	zd.initLiteSet(obj,"receiveLast",maker.CST_Null())
	zd.initLiteSet(obj,"receive_onekey",maker.CST_Null())
	zd.initLiteSet(obj,"recovery",maker.CST_ParamHid())
	zd.initLiteSet(obj,"revenge",maker.CST_KuaMineRevenge())
	return obj
end

maker.CST_SCDllhdUser = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bu",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_SCDllhdUserList()))
	return obj
end

maker.CST_Sc_newcjyxCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day_cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"fyh",maker.CST_newcjyxfyh())
	zd.initLiteSet(obj,"info",maker.CST_Shdinfo())
	zd.initLiteSet(obj,"libao",maker.CST_newcjyxlibao())
	zd.initLiteSet(obj,"need",0)
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_Scbhdrwd()))
	zd.initLiteSet(obj,"shop",maker.CST_newcjyxshop())
	return obj
end

maker.CST_JiuLouWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"joinInfo",maker.CST_joinInfos())
	zd.initLiteSet(obj,"yhnew",maker.CST_JiuLouWinYhNew())
	return obj
end

maker.CST_targetLanguageCode = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"code","")
	return obj
end

maker.CST_SShopList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"item",maker.CST_ItemInfo())
	zd.initLiteSet(obj,"lock",0)
	zd.initLiteSet(obj,"maxlimit",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"payGX",0)
	return obj
end

maker.CST_CS_hd650delemyOrder = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"ids","")
	return obj
end

maker.CST_llbxrwdInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"getrwd",zd.makeLiteArray(makerSC.SCT_llbxrwdGetrwd()))
	zd.initLiteSet(obj,"time",0)
	return obj
end

maker.CST_Sback = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cs",2)
	zd.initLiteSet(obj,"currency","")
	zd.initLiteSet(obj,"money",0)
	zd.initLiteSet(obj,"orderid","")
	zd.initLiteSet(obj,"platform","")
	zd.initLiteSet(obj,"productid","")
	zd.initLiteSet(obj,"reward","")
	zd.initLiteSet(obj,"shopid","")
	return obj
end

maker.CST_CsRiskChangeNpcState = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"x",0)
	zd.initLiteSet(obj,"y",0)
	return obj
end

maker.CST_VerOpenid = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"openid","")
	zd.initLiteSet(obj,"platform","")
	return obj
end

maker.CST_CsRiskworkbench = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"x",0)
	zd.initLiteSet(obj,"y",0)
	return obj
end

maker.CST_Sxshuodong = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg",maker.CST_Scfg())
	zd.initLiteSet(obj,"cons",0)
	zd.initLiteSet(obj,"has_rwd","")
	zd.initLiteSet(obj,"rwd",0)
	return obj
end

maker.CST_SChangjing = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_SCJhlist()))
	zd.initLiteSet(obj,"news",0)
	zd.initLiteSet(obj,"set",0)
	zd.initLiteSet(obj,"ver",1)
	return obj
end

maker.CST_SC_MonthTask = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"base",maker.CST_SC_MonthTaskBase())
	zd.initLiteSet(obj,"levelMoreRwd",zd.makeLiteArray(makerSC.SCT_SC_MonthTaskRwdType()))
	zd.initLiteSet(obj,"levelRwd",zd.makeLiteArray(makerSC.SCT_SC_MonthTaskRwdType()))
	zd.initLiteSet(obj,"tasks",zd.makeLiteArray(makerSC.SCT_SC_MonthTaskInfo()))
	return obj
end

maker.CST_CFind = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid","0")
	return obj
end

maker.CST_SC_RankComMyClub = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"sev",0)
	return obj
end

maker.CST_SC_FourGoodPreview = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fashion",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"item",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"ornament",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	return obj
end

maker.CST_BanishList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"hid",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_heroGhkillId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"sid",0)
	return obj
end

maker.CST_CS_hd745Rwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_BHCZHDUserRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_BHCZHDUserRwdList()))
	return obj
end

maker.CST_Pvb2Herodamage = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"damage",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SyhInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"chatFrame",0)
	zd.initLiteSet(obj,"dress",0)
	zd.initLiteSet(obj,"ep",0)
	zd.initLiteSet(obj,"frame",0)
	zd.initLiteSet(obj,"head",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"job",1)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray("xwInfo"))
	zd.initLiteSet(obj,"ltime",maker.CST_CdLabel())
	zd.initLiteSet(obj,"maxnum",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"sex",1)
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_QxCfgShop = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"get",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"need",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"sk",0)
	return obj
end

maker.CST_DnRechange = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"money",0)
	return obj
end

maker.CST_hd699Reward = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SC_huodonglist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"add",zd.makeLiteArray(0))
	zd.initLiteSet(obj,"all",zd.makeLiteArray(makerSC.SCT_Shdallinfo()))
	zd.initLiteSet(obj,"del",zd.makeLiteArray(0))
	zd.initLiteSet(obj,"info",maker.CST_Shdverinfo())
	return obj
end

maker.CST_CSkuaPKbflog = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid",0)
	return obj
end

maker.CST_ScRankRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"rand",maker.CST_srand())
	return obj
end

maker.CST_SCldjcbkhdCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"lastrwd",zd.makeLiteArray(makerSC.SCT_SCldjcbkhdCfgRwd()))
	return obj
end

maker.CST_SC_centralattackpkresulthero = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dt",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"senior",0)
	zd.initLiteSet(obj,"shili",0)
	zd.initLiteSet(obj,"skin",0)
	zd.initLiteSet(obj,"ur",0)
	return obj
end

maker.CST_SC_dllhuodong = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg",maker.CST_SCDllhdCfg())
	zd.initLiteSet(obj,"user",maker.CST_SCDllhdUser())
	return obj
end

maker.CST_CChousehold = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SclearNewsChatFrame = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CsRiskResetCd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CodeMsg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"key","")
	return obj
end

maker.CST_Shdallinfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"Hero","0")
	zd.initLiteSet(obj,"bg",0)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"eTime",0)
	zd.initLiteSet(obj,"freeWife","0")
	zd.initLiteSet(obj,"heroSkin","0")
	zd.initLiteSet(obj,"hz","")
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"introduce","")
	zd.initLiteSet(obj,"link","")
	zd.initLiteSet(obj,"news",0)
	zd.initLiteSet(obj,"ntype",0)
	zd.initLiteSet(obj,"pindex",0)
	zd.initLiteSet(obj,"sTime",0)
	zd.initLiteSet(obj,"showTime",0)
	zd.initLiteSet(obj,"show_rwd",zd.makeLiteArray(makerSC.SCT_UseItemInfo()))
	zd.initLiteSet(obj,"switch",0)
	zd.initLiteSet(obj,"title","")
	zd.initLiteSet(obj,"type",1)
	zd.initLiteSet(obj,"win",1)
	zd.initLiteSet(obj,"wz","")
	zd.initLiteSet(obj,"yueTime",0)
	zd.initLiteSet(obj,"yushowTime",0)
	return obj
end

maker.CST_CCreate = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"isJoin",0)
	zd.initLiteSet(obj,"laoma","")
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"outmsg","")
	zd.initLiteSet(obj,"password",0)
	zd.initLiteSet(obj,"qq","")
	return obj
end

maker.CST_CsRiskclickProtectTask = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"tid",0)
	return obj
end

maker.CST_CsRiskShop = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_RiskJiguan = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"jiguanid",0)
	zd.initLiteSet(obj,"jindu",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"succesed",0)
	return obj
end

maker.CST_SCUserOldEp = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"ep",0)
	return obj
end

maker.CST_XianShiRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"items",0)
	zd.initLiteSet(obj,"sum",0)
	return obj
end

maker.CST_Fnew = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"status",0)
	return obj
end

maker.CST_SCbuild = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"harvests",0)
	zd.initLiteSet(obj,"heroes",zd.makeLiteArray(makerSC.SCT_SCBuildHero()))
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"last_time",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"max",0)
	zd.initLiteSet(obj,"maxLevel",0)
	zd.initLiteSet(obj,"next",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"state",0)
	zd.initLiteSet(obj,"warehouse",0)
	return obj
end

maker.CST_CS_Hd650cGroupBuy = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CxslchdRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_Sc2048Ti = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"label",0)
	zd.initLiteSet(obj,"max_power",0)
	zd.initLiteSet(obj,"next",0)
	zd.initLiteSet(obj,"power",0)
	return obj
end

maker.CST_ParamIdFuid = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_Thing = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_CS_GuideButtonReal = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"btnKey","")
	zd.initLiteSet(obj,"opt","")
	return obj
end

maker.CST_CPreyh = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"isOpen",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SC_centralattackcity = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"keng",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_Scfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_Shdinfo())
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_Shdrwd()))
	return obj
end

maker.CST_CS_hd491GetRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SCDllhdCfgRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	return obj
end

maker.CST_CSbuildShou = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_Svsmsg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"comment","")
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_BanishHero = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"did",0)
	zd.initLiteSet(obj,"hid",0)
	return obj
end

maker.CST_ghSkilInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"level",1)
	zd.initLiteSet(obj,"use",zd.makeLiteArray(makerSC.SCT_UseItemInfo()))
	return obj
end

maker.CST_ScXxlCfgDayRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_IDCOUNT()))
	zd.initLiteSet(obj,"need",0)
	return obj
end

maker.CST_FuLiWXQQ = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"qq",maker.CST_FuLiAddwxqq())
	zd.initLiteSet(obj,"wx",maker.CST_FuLiAddwxqq())
	return obj
end

maker.CST_CShd434Play = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_ClearUser = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"wxOpenid","")
	return obj
end

maker.CST_PlatVipGiftReturn = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg",zd.makeLiteArray(makerSC.SCT_VipRwdInfo()))
	return obj
end

maker.CST_ServerInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"he",1)
	zd.initLiteSet(obj,"id",1)
	zd.initLiteSet(obj,"kua",1)
	return obj
end

maker.CST_CommonOrder = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"order",0)
	return obj
end

maker.CST_Scblist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cname","")
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"uid",0)
	zd.initLiteSet(obj,"vip",0)
	return obj
end

maker.CST_CFhistory = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SC_Friends = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fapplylist",zd.makeLiteArray(makerSC.SCT_fUserInfo()))
	zd.initLiteSet(obj,"fapplynews",maker.CST_Fnew())
	zd.initLiteSet(obj,"flist",maker.CST_Flist())
	zd.initLiteSet(obj,"fllist",zd.makeLiteArray(makerSC.SCT_Sfllist()))
	zd.initLiteSet(obj,"fsendlist",maker.CST_Fsendlist())
	zd.initLiteSet(obj,"news",maker.CST_Fnew())
	zd.initLiteSet(obj,"qjlist",zd.makeLiteArray(makerSC.SCT_fUserqjlist()))
	zd.initLiteSet(obj,"sltip",zd.makeLiteArray(makerSC.SCT_Ssltip()))
	zd.initLiteSet(obj,"sonshili",maker.CST_SSonshili())
	return obj
end

maker.CST_hd699ChatByType = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_COutClub = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid",maker.CST_Null())
	return obj
end

maker.CST_HitMgfailWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bo",1)
	zd.initLiteSet(obj,"damage",0)
	return obj
end

maker.CST_SCinandpk = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"f",maker.CST_SCclubheroinfo())
	zd.initLiteSet(obj,"my",maker.CST_SCclubheroinfo())
	return obj
end

maker.CST_SCinherit = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id","")
	return obj
end

maker.CST_ServerState = makerSC.SCT_ServerState
maker.CST_SCUserVerifyRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"rwd",0)
	zd.initLiteSet(obj,"rz",0)
	return obj
end

maker.CST_SjyInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"isClub",0)
	zd.initLiteSet(obj,"ltime",maker.CST_CdLabel())
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_InviteList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"invite_rwd",0)
	zd.initLiteSet(obj,"no","")
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_idBase()))
	zd.initLiteSet(obj,"score",0)
	return obj
end

maker.CST_SClubList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"allShiLi",0)
	zd.initLiteSet(obj,"exp",0)
	zd.initLiteSet(obj,"fund",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"isJoin",0)
	zd.initLiteSet(obj,"job",0)
	zd.initLiteSet(obj,"laoma","")
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"members",zd.makeLiteArray(makerSC.SCT_membersInfo()))
	zd.initLiteSet(obj,"mzName","")
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"notice","")
	zd.initLiteSet(obj,"outmsg","")
	zd.initLiteSet(obj,"qq","")
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"sex",0)
	zd.initLiteSet(obj,"userNum",0)
	return obj
end

maker.CST_CShd365Rwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dc",0)
	return obj
end

maker.CST_CsRiskFollow = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_SC_LoginAccount = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"backUrl","")
	zd.initLiteSet(obj,"gameName","")
	zd.initLiteSet(obj,"ip","")
	zd.initLiteSet(obj,"pftoken","")
	zd.initLiteSet(obj,"thirdPUrl","")
	zd.initLiteSet(obj,"token","")
	zd.initLiteSet(obj,"uid",0)
	zd.initLiteSet(obj,"userAccount","")
	return obj
end

maker.CST_DSsdCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cz_money",0)
	zd.initLiteSet(obj,"exchange",zd.makeLiteArray("ExchangeList"))
	zd.initLiteSet(obj,"login",zd.makeLiteArray("Sqmcrwd"))
	zd.initLiteSet(obj,"rand_get",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"reDay",zd.makeLiteArray("Sqmcrwd"))
	zd.initLiteSet(obj,"recharge",zd.makeLiteArray("Sqmcrwd"))
	zd.initLiteSet(obj,"recover_money",0)
	zd.initLiteSet(obj,"rwd","NewYearrwdType")
	zd.initLiteSet(obj,"seek_need",0)
	zd.initLiteSet(obj,"seek_prob_rand",zd.makeLiteArray(makerSC.SCT_ZQCfgUseSeekRrobRand()))
	zd.initLiteSet(obj,"seek_rwd",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"set","Sdsmset")
	zd.initLiteSet(obj,"shop",zd.makeLiteArray("Shopxg"))
	zd.initLiteSet(obj,"today",maker.CST_CdLabel())
	zd.initLiteSet(obj,"use",zd.makeLiteArray(makerSC.SCT_ZQCfgUse()))
	return obj
end

maker.CST_CS_hdExchange = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_BanishDeskRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"get",0)
	zd.initLiteSet(obj,"id",1)
	zd.initLiteSet(obj,"num",1)
	zd.initLiteSet(obj,"rwd",0)
	return obj
end

maker.CST_Sfschat = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid",0)
	zd.initLiteSet(obj,"msg","")
	return obj
end

maker.CST_SCclubKuaInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"allshili",0)
	zd.initLiteSet(obj,"heroid",0)
	zd.initLiteSet(obj,"hname","")
	zd.initLiteSet(obj,"hpower",0)
	zd.initLiteSet(obj,"ltime",maker.CST_CdLabel())
	zd.initLiteSet(obj,"mMz",maker.CST_UserEasyData())
	zd.initLiteSet(obj,"mName","")
	zd.initLiteSet(obj,"mType",0)
	zd.initLiteSet(obj,"msevid",0)
	zd.initLiteSet(obj,"mytype",0)
	zd.initLiteSet(obj,"rwdltime",maker.CST_CdLabel())
	zd.initLiteSet(obj,"rwdltype",0)
	zd.initLiteSet(obj,"tType",0)
	zd.initLiteSet(obj,"usejn",0)
	zd.initLiteSet(obj,"usejnhid",0)
	return obj
end

maker.CST_EpSkilInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hlv",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"level",1)
	zd.initLiteSet(obj,"slv",0)
	return obj
end

maker.CST_clubbosswin1 = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cbosspkwin1",maker.CST_Scbosspkwin1())
	return obj
end

maker.CST_Hbmobai = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"money",10)
	zd.initLiteSet(obj,"state",0)
	return obj
end

maker.CST_Sc2048Info = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_Shdinfo())
	zd.initLiteSet(obj,"rwd","rwdType2048")
	return obj
end

maker.CST_newcjyxshop = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"items",maker.CST_ItemInfo())
	zd.initLiteSet(obj,"need",maker.CST_ItemInfo())
	return obj
end

maker.CST_SC_ComRankRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"rand",maker.CST_SC_ComRankRange())
	return obj
end

maker.CST_CS_HD496Rwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_fourEps = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"e1",0)
	zd.initLiteSet(obj,"e2",0)
	zd.initLiteSet(obj,"e3",0)
	zd.initLiteSet(obj,"e4",0)
	return obj
end

maker.CST_llbxrwdGetrwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SC_ClubKuaYueCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buff",maker.CST_SC_ClubKuaYueCfgBuff())
	zd.initLiteSet(obj,"rule","")
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_SC_ComRankRwd()))
	return obj
end

maker.CST_CS_Order = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"AppFailCallback",maker.CST_CAppFailCallback())
	zd.initLiteSet(obj,"getOrderId",maker.CST_CgetOrderId())
	zd.initLiteSet(obj,"orderBack","")
	zd.initLiteSet(obj,"orderReady","")
	zd.initLiteSet(obj,"orderTest",maker.CST_CtestOrder())
	zd.initLiteSet(obj,"setAge",maker.CST_CSsetAge())
	return obj
end

maker.CST_CNoJoin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid",0)
	return obj
end

maker.CST_ChenhJiulist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"rwd",0)
	return obj
end

maker.CST_CsTsMap = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"mid",0)
	return obj
end

maker.CST_SC_centralattackselflog = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"city",0)
	zd.initLiteSet(obj,"fherolist",zd.makeLiteArray(makerSC.SCT_SC_centralattackpkresulthero()))
	zd.initLiteSet(obj,"fname","")
	zd.initLiteSet(obj,"fuid",0)
	zd.initLiteSet(obj,"herolist",zd.makeLiteArray(makerSC.SCT_SC_centralattackpkresulthero()))
	zd.initLiteSet(obj,"keng",0)
	zd.initLiteSet(obj,"long",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"team",0)
	zd.initLiteSet(obj,"time",0)
	zd.initLiteSet(obj,"type",0)
	zd.initLiteSet(obj,"win",0)
	return obj
end

maker.CST_CSkuaPKAdd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hid",0)
	return obj
end

maker.CST_ScgInfoDirect = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"gift",maker.CST_ScgInfoDirectType())
	zd.initLiteSet(obj,"info",maker.CST_CftInfo())
	return obj
end

maker.CST_SC_czhlhuodong = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"czhlinfo",maker.CST_Csczhlinfo())
	return obj
end

maker.CST_ScCourtyardFarm = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_ScCourtyardFarmList()))
	return obj
end

maker.CST_FuLiVipId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CS_hd802touch = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CSqxzbPKinfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cid",0)
	zd.initLiteSet(obj,"turn",0)
	return obj
end

maker.CST_SC_Item = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"itemLimitList",zd.makeLiteArray(makerSC.SCT_limitList()))
	zd.initLiteSet(obj,"itemList",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	return obj
end

maker.CST_GameMachineDraw = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"ad",0)
	zd.initLiteSet(obj,"times",0)
	return obj
end

maker.CST_ParamNum = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_QQNum = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"qq","")
	zd.initLiteSet(obj,"qq_rwd",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"status",1)
	zd.initLiteSet(obj,"wx","")
	zd.initLiteSet(obj,"wx_rwd",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"wx_status",1)
	return obj
end

maker.CST_UserPveWin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"deil",0)
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"kill",0)
	return obj
end

maker.CST_RiskExchange = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"finish_cnt",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_RiskOrder()))
	zd.initLiteSet(obj,"show_cnt",0)
	zd.initLiteSet(obj,"total_cnt",0)
	zd.initLiteSet(obj,"use_diamond",0)
	zd.initLiteSet(obj,"use_prop",0)
	return obj
end

maker.CST_cjyxall_news = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"exchange",0)
	zd.initLiteSet(obj,"lingqu",0)
	zd.initLiteSet(obj,"recharge",0)
	return obj
end

maker.CST_Scbcfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_Shdinfo())
	zd.initLiteSet(obj,"msg","")
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_Scbhdrwd()))
	zd.initLiteSet(obj,"showNeed","ShdshowNeed")
	return obj
end

maker.CST_ShopGiftInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cft",maker.CST_CftInfo())
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_ShopGiftList()))
	return obj
end

maker.CST_HeroSkin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dressList",zd.makeLiteArray(makerSC.SCT_SkinHd()))
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_HeroSkinList()))
	zd.initLiteSet(obj,"news",zd.makeLiteArray(makerSC.SCT_HeroSkinNews()))
	return obj
end

maker.CST_mobileInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"eTime",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"news",0)
	zd.initLiteSet(obj,"sTime",0)
	zd.initLiteSet(obj,"showTime",0)
	zd.initLiteSet(obj,"title","")
	zd.initLiteSet(obj,"type",1)
	return obj
end

maker.CST_CS_ButlerSetLixian = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"isLx",0)
	return obj
end

maker.CST_RiskBossDetail = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"bosshp",zd.makeLiteArray(makerSC.SCT_RiskBosshp()))
	zd.initLiteSet(obj,"herolist",zd.makeLiteArray(makerSC.SCT_RiskHerolist()))
	return obj
end

maker.CST_ladder_myscore = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"duanwei",0)
	zd.initLiteSet(obj,"jie",0)
	zd.initLiteSet(obj,"myName","")
	zd.initLiteSet(obj,"myScore",0)
	zd.initLiteSet(obj,"myScorerank",0)
	zd.initLiteSet(obj,"quname","")
	zd.initLiteSet(obj,"sid",0)
	return obj
end

maker.CST_FuLiCardId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_doWork = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SC_invitehuodong = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg",maker.CST_InviteCfg())
	zd.initLiteSet(obj,"user",maker.CST_InviteList())
	return obj
end

maker.CST_BHCZHDClub = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"constotal",0)
	zd.initLiteSet(obj,"day",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"uidinfo",zd.makeLiteArray(makerSC.SCT_BHCZUIDINFO()))
	return obj
end

maker.CST_HbGetHbList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"lucky",0)
	zd.initLiteSet(obj,"money",0)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"uid",0)
	return obj
end

maker.CST_makeSkinList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"dt",0)
	zd.initLiteSet(obj,"has",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"max",0)
	return obj
end

maker.CST_SC_ButlerLixianRes = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"army",0)
	zd.initLiteSet(obj,"ch",0)
	zd.initLiteSet(obj,"coin",0)
	zd.initLiteSet(obj,"exp",0)
	zd.initLiteSet(obj,"food",0)
	zd.initLiteSet(obj,"heroEpExp",zd.makeLiteArray(makerSC.SCT_SC_ButlerLixianResIdNum()))
	zd.initLiteSet(obj,"heroPkExp",zd.makeLiteArray(makerSC.SCT_SC_ButlerLixianResIdNum()))
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"jy",0)
	zd.initLiteSet(obj,"py",0)
	zd.initLiteSet(obj,"son",zd.makeLiteArray(makerSC.SCT_SC_ButlerLixianResIdNum()))
	zd.initLiteSet(obj,"sy",0)
	zd.initLiteSet(obj,"time",0)
	zd.initLiteSet(obj,"wife",zd.makeLiteArray(makerSC.SCT_SC_ButlerLixianResIdNum()))
	zd.initLiteSet(obj,"wifeExp",zd.makeLiteArray(makerSC.SCT_SC_ButlerLixianResIdNum()))
	zd.initLiteSet(obj,"wifeLike",zd.makeLiteArray(makerSC.SCT_SC_ButlerLixianResIdNum()))
	zd.initLiteSet(obj,"wifeLove",zd.makeLiteArray(makerSC.SCT_SC_ButlerLixianResIdNum()))
	zd.initLiteSet(obj,"xf",0)
	zd.initLiteSet(obj,"zw",0)
	return obj
end

maker.CST_CS_abcestralhall = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"ancestralhallInfo",maker.CST_abcestralhallinto())
	return obj
end

maker.CST_JdyamenChatId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_HdOneBuyInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cft",maker.CST_CftInfo())
	zd.initLiteSet(obj,"items",zd.makeLiteArray(makerSC.SCT_OneBuyInfo()))
	return obj
end

maker.CST_CShopBuy = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_setInheritPwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"new","")
	zd.initLiteSet(obj,"old","")
	return obj
end

maker.CST_ladder_chenghao = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"mingren",0)
	return obj
end

maker.CST_MailIdParam = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SCJmSwitch = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"switch","")
	return obj
end

maker.CST_CAppFailCallback = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cs1","")
	zd.initLiteSet(obj,"cs2","")
	zd.initLiteSet(obj,"cs3","")
	zd.initLiteSet(obj,"cs4","")
	zd.initLiteSet(obj,"cs5","")
	zd.initLiteSet(obj,"cs6","")
	zd.initLiteSet(obj,"cs7","")
	zd.initLiteSet(obj,"cs8","")
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SCmzpic = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"chenghao",0)
	zd.initLiteSet(obj,"dress",0)
	zd.initLiteSet(obj,"job",0)
	zd.initLiteSet(obj,"level",0)
	zd.initLiteSet(obj,"sex",0)
	return obj
end

maker.CST_ScgInfoDirectType = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_ScgInfoDirectDetail()))
	return obj
end

maker.CST_ZdzdInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	return obj
end

maker.CST_CscpScore = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cpid",0)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"total",0)
	return obj
end

maker.CST_NULL = function()
	local obj = {}
	zd.makeLiteTable(obj)
	return obj
end

maker.CST_huntDispatchInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hero",zd.makeLiteArray("DispatchHeroes"))
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CSbuildUp = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_SCUserDressList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cFrame",zd.makeLiteArray(makerSC.SCT_SCUserDressListBase()))
	zd.initLiteSet(obj,"frame",zd.makeLiteArray(makerSC.SCT_SCUserDressListBase()))
	zd.initLiteSet(obj,"head",zd.makeLiteArray(makerSC.SCT_SCUserDressListBase()))
	return obj
end

maker.CST_QxUserCz = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"money",0)
	zd.initLiteSet(obj,"rwd",0)
	return obj
end

maker.CST_Scwifepkresult = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"addExp",0)
	zd.initLiteSet(obj,"rankScore",0)
	zd.initLiteSet(obj,"shopScore",0)
	zd.initLiteSet(obj,"win",0)
	return obj
end

maker.CST_Svsset = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"QQ",0)
	zd.initLiteSet(obj,"line","")
	zd.initLiteSet(obj,"msg",zd.makeLiteArray(makerSC.SCT_Svsmsg()))
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"notice","")
	zd.initLiteSet(obj,"qq_msg","")
	zd.initLiteSet(obj,"recharge",0)
	zd.initLiteSet(obj,"vip",0)
	return obj
end

maker.CST_CS_Item = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buyLimitItem",maker.CST_itemBase())
	zd.initLiteSet(obj,"getSelectItem",maker.CST_CS_getSelectItem())
	zd.initLiteSet(obj,"getskin",maker.CST_CS_getskin())
	zd.initLiteSet(obj,"hecheng",maker.CST_itemBase())
	zd.initLiteSet(obj,"itemlist",maker.CST_Null())
	zd.initLiteSet(obj,"useBeast",maker.CST_itemId())
	zd.initLiteSet(obj,"useForWifes","itemWifeBase")
	zd.initLiteSet(obj,"useSkin",maker.CST_ItemId())
	zd.initLiteSet(obj,"useSkinSelect",maker.CST_CS_useSkinSelect())
	zd.initLiteSet(obj,"useforhero",maker.CST_itemHeroBase())
	zd.initLiteSet(obj,"useforwife","itemWifeBase")
	zd.initLiteSet(obj,"useitem",maker.CST_itemBase())
	zd.initLiteSet(obj,"userYard",maker.CST_itemYard())
	return obj
end

maker.CST_WordShop = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buys",zd.makeLiteArray(makerSC.SCT_WordShopItem()))
	zd.initLiteSet(obj,"score",0)
	return obj
end

maker.CST_CsRiskMove = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"x",0)
	zd.initLiteSet(obj,"y",0)
	return obj
end

maker.CST_CS_Skin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"clearNews",maker.CST_cs_skinClearNews())
	zd.initLiteSet(obj,"collectBook",maker.CST_NULL())
	zd.initLiteSet(obj,"getCollectRwd",maker.CST_idBase())
	zd.initLiteSet(obj,"getRank",maker.CST_SkinGetRank())
	zd.initLiteSet(obj,"getSkin",maker.CST_cs_getSkin())
	zd.initLiteSet(obj,"getSkinById",maker.CST_SkinGetRank())
	zd.initLiteSet(obj,"heroDress",maker.CST_SkinHd())
	zd.initLiteSet(obj,"heroSkinInfo",maker.CST_NULL())
	zd.initLiteSet(obj,"inSkin",maker.CST_NULL())
	zd.initLiteSet(obj,"makeSkin",maker.CST_NULL())
	zd.initLiteSet(obj,"skin",maker.CST_NULL())
	zd.initLiteSet(obj,"skinBuy",maker.CST_cs_getSkinshop())
	zd.initLiteSet(obj,"skinCompose",maker.CST_SkinGetRank())
	zd.initLiteSet(obj,"upHeroDynamic",maker.CST_SkinId())
	zd.initLiteSet(obj,"upWifeDynamic",maker.CST_SkinId())
	zd.initLiteSet(obj,"wifeDress",maker.CST_SkinWd())
	zd.initLiteSet(obj,"wifeSkinInfo",maker.CST_NULL())
	return obj
end

maker.CST_CYesJoin = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"fuid",0)
	return obj
end

maker.CST_CInfoSave = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"laoma","")
	zd.initLiteSet(obj,"notice","")
	zd.initLiteSet(obj,"outmsg","")
	zd.initLiteSet(obj,"qq","")
	return obj
end

maker.CST_ChoiceId = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",1)
	return obj
end

maker.CST_changePackRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"status",0)
	zd.initLiteSet(obj,"tag","")
	return obj
end

maker.CST_BlackFriDayCfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"rwd",zd.makeLiteArray(makerSC.SCT_Shdrwd()))
	return obj
end

maker.CST_SC_shice = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"get",maker.CST_LiangchenInfo())
	zd.initLiteSet(obj,"liangchen",zd.makeLiteArray(makerSC.SCT_LiangchenInfo()))
	return obj
end

maker.CST_blessYao = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SCShopList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hefa",zd.makeLiteArray(makerSC.SCT_SCShopHefa()))
	zd.initLiteSet(obj,"xian",zd.makeLiteArray(makerSC.SCT_IDNUM()))
	return obj
end

maker.CST_KuaHdCdTime = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	return obj
end

maker.CST_SC_llbxrwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"info",maker.CST_llbxrwdInfo())
	zd.initLiteSet(obj,"rwdlist",zd.makeLiteArray("Gqjtdayrwd"))
	return obj
end

maker.CST_CsMadeMenu = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cpid",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"num",0)
	return obj
end

maker.CST_CS_hd760Rwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_ScKom = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"get",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"needitem",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"speed",0)
	return obj
end

maker.CST_HmembersInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"hp",0)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_CtestOrder = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"goodsid","")
	zd.initLiteSet(obj,"shopCid",0)
	return obj
end

maker.CST_CdLabel = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"label","")
	zd.initLiteSet(obj,"next",0)
	return obj
end

maker.CST_SelfRids = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"beast",0)
	zd.initLiteSet(obj,"country",0)
	zd.initLiteSet(obj,"guanka",0)
	zd.initLiteSet(obj,"love",0)
	zd.initLiteSet(obj,"mylsshili",0)
	zd.initLiteSet(obj,"shili",0)
	zd.initLiteSet(obj,"shiliKua",0)
	return obj
end

maker.CST_SCclubShareCD = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"m",0)
	zd.initLiteSet(obj,"t",0)
	return obj
end

maker.CST_CftInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdLabel())
	zd.initLiteSet(obj,"eTime",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"sTime",0)
	zd.initLiteSet(obj,"title","")
	return obj
end

maker.CST_CClubHeroCone = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_Cshd413All = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_hd850UseItmeInfo = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"num",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_CSBoxRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_SC_ClubCZHD = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cfg",zd.makeLiteArray(makerSC.SCT_ClubCZHDCfg()))
	zd.initLiteSet(obj,"club",zd.makeLiteArray(makerSC.SCT_ClubCZHDClub()))
	zd.initLiteSet(obj,"log",zd.makeLiteArray(makerSC.SCT_ClubCZHDLog()))
	zd.initLiteSet(obj,"user",maker.CST_ClubCZHDUser())
	return obj
end

maker.CST_Srwdcfg = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"item",zd.makeLiteArray(makerSC.SCT_itemBase()))
	zd.initLiteSet(obj,"max",0)
	return obj
end

maker.CST_translateGeneral = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id","")
	zd.initLiteSet(obj,"translate_data","")
	return obj
end

maker.CST_ComMyRank = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"name","")
	zd.initLiteSet(obj,"rid",0)
	zd.initLiteSet(obj,"score",0)
	zd.initLiteSet(obj,"sev",0)
	return obj
end

maker.CST_CShd434Lantern = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_award_list = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",1)
	zd.initLiteSet(obj,"items",maker.CST_items_list())
	zd.initLiteSet(obj,"rebate",20)
	return obj
end

maker.CST_SGetStoryRwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_limitList = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"count",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"limit",0)
	return obj
end

maker.CST_apostleShop_list = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"buy",0)
	zd.initLiteSet(obj,"id",0)
	zd.initLiteSet(obj,"type",0)
	return obj
end

maker.CST_SCFramelist = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"cd",maker.CST_CdNum())
	zd.initLiteSet(obj,"get",1)
	zd.initLiteSet(obj,"id",0)
	return obj
end

maker.CST_MysteryShop = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"exchange_cnt",0)
	zd.initLiteSet(obj,"exchange_max",0)
	zd.initLiteSet(obj,"list",zd.makeLiteArray(makerSC.SCT_MysteryOrder()))
	zd.initLiteSet(obj,"soup",0)
	zd.initLiteSet(obj,"unlock",0)
	return obj
end

maker.CST_SCclubKuapkrwd = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"club",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	zd.initLiteSet(obj,"fcid",0)
	zd.initLiteSet(obj,"flevel",0)
	zd.initLiteSet(obj,"fname","")
	zd.initLiteSet(obj,"fservid",0)
	zd.initLiteSet(obj,"getCname","")
	zd.initLiteSet(obj,"getCuid",0)
	zd.initLiteSet(obj,"isGet",0)
	zd.initLiteSet(obj,"isSet",0)
	zd.initLiteSet(obj,"isWin",0)
	zd.initLiteSet(obj,"is_get",0)
	zd.initLiteSet(obj,"member",zd.makeLiteArray(makerSC.SCT_ItemInfo()))
	return obj
end

maker.CST_SCclubKualog = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"in",maker.CST_SCinandpk())
	zd.initLiteSet(obj,"pk",maker.CST_SCinandpk())
	return obj
end

maker.CST_Riskdamage = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"damage",0)
	return obj
end

maker.CST_SC_bigEmoji = function()
	local obj = {}
	zd.makeLiteTable(obj)
	zd.initLiteSet(obj,"idlist",zd.makeLiteArray(makerSC.SCT_SC_bigEmojiidlist()))
	zd.initLiteSet(obj,"redtype",zd.makeLiteArray(makerSC.SCT_SC_bigEmojiredtype()))
	return obj
end

return maker
