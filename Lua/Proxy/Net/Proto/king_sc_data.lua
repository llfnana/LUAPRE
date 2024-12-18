local zd = require("Proxy.NetBase.Data.Data")
----------------------------SplitByYuki---------------------------------

local maker = {}
local _KeyMaps = {
	shop="SCT_SC_Shop",
	map="SCT_SC_Map",
	notice="SCT_SC_Notice",
	hero="SCT_SC_Hero",
	sdk="SCT_SC_sdk",
	msgWin2="SCT_SC_MsgWin",
	randWin="SCT_SC_RandWin",
	system="SCT_SC_System",
	guide="SCT_SC_Guide",
	loginMod="SCT_SC_loginMod",
	gameMachine="SCT_SC_GameMachine",
	user="SCT_SC_User",
	mail="SCT_SC_Mail",
	msgWin="SCT_SC_MsgWin",
	story="SCT_SC_Story",
	order="SCT_SC_Order",
	derail="SCT_SC_Derail",
}

function makergetFn(obj,key)
	if not obj then
		print( "makergetFn obj is nil ")
		obj = maker.SCT_SC_NEW()
		end
	if obj[key] then
		return obj[key]
	else
		zd.initSet(obj,key,maker[_KeyMaps[key]]())
	end
	return obj[key]
end
maker.SCT_SC_NEW = function()
	local obj = {}
	zd.makeDataTable(obj)
	return obj
end
maker.SCT_SC_Ranking = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"beast",zd.makeDataArray(maker.SCT_fUserInfo(),"id"))
	zd.initSet(obj,"clubKua",zd.makeDataArray(maker.SCT_SClubList(),"id"))
	zd.initSet(obj,"clubKuaYueMyScore",maker.SCT_SC_RankComMyClub())
	zd.initSet(obj,"clubKuaYueMyScoreLast",maker.SCT_SC_RankComMyClub())
	zd.initSet(obj,"clubKuaYueScore",zd.makeDataArray(maker.SCT_SC_RankComClub()))
	zd.initSet(obj,"clubKuaYueScoreLast",zd.makeDataArray(maker.SCT_SC_RankComClub()))
	zd.initSet(obj,"clubkuajf",zd.makeDataArray(maker.SCT_SCclubkuajf(),"id"))
	zd.initSet(obj,"country",zd.makeDataArray("RankCountry","id"))
	zd.initSet(obj,"guanka",zd.makeDataArray(maker.SCT_fUserInfo(),"id"))
	zd.initSet(obj,"heroKua",zd.makeDataArray(maker.SCT_fHeroData()))
	zd.initSet(obj,"huali",zd.makeDataArray("ComUserEasyDataRank"))
	zd.initSet(obj,"liangchen",zd.makeDataArray(maker.SCT_LiangchenInfo(),"id"))
	zd.initSet(obj,"love",zd.makeDataArray(maker.SCT_fUserInfo(),"id"))
	zd.initSet(obj,"mobai",maker.SCT_MoBaiMsg())
	zd.initSet(obj,"myHuali",maker.SCT_ComMyRank())
	zd.initSet(obj,"myclubkuaRid",maker.SCT_SCclubkuajf())
	zd.initSet(obj,"selfRid",maker.SCT_SelfRids())
	zd.initSet(obj,"shili",zd.makeDataArray(maker.SCT_fUserInfo(),"id"))
	zd.initSet(obj,"shiliKua",zd.makeDataArray(maker.SCT_fUserInfo(),"id"))
	zd.initSet(obj,"showListNum",maker.SCT_RankShowListNum())
	zd.initSet(obj,"win",maker.SCT_RankingWin())
	return obj
end

maker.SCT_GameMachineResult = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"position",0)
	zd.initSet(obj,"train",zd.makeDataArray(maker.SCT_GameMachineTrain()))
	return obj
end

maker.SCT_hd748ExchangeParams = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_ScLjzxRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_IDCOUNT()))
	zd.initSet(obj,"need",0)
	return obj
end

maker.SCT_Sc2048Score = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_CS_Hd786Count = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	return obj
end

maker.SCT_CS_Code = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"exchange",maker.SCT_CodeMsg())
	return obj
end

maker.SCT_JdymGetRank = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",1)
	return obj
end

maker.SCT_CS_Hd760Sevid = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"sevid",0)
	return obj
end

maker.SCT_SC_Hdxxl = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"XxlDayRwd",maker.SCT_ScXxlDayRwd())
	zd.initSet(obj,"XxlExchange",zd.makeDataArray(maker.SCT_ScXxlShop()))
	zd.initSet(obj,"XxlRank",zd.makeDataArray(maker.SCT_Scblist(),"id"))
	zd.initSet(obj,"XxlShop",zd.makeDataArray(maker.SCT_ScXxlShop()))
	zd.initSet(obj,"XxlTi",maker.SCT_ScXxlTi())
	zd.initSet(obj,"info",maker.SCT_ScXxlInfo())
	zd.initSet(obj,"myXxlRid",maker.SCT_Scbrid())
	return obj
end

maker.SCT_Srorder = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"age_default","")
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"payflag","")
	zd.initSet(obj,"recharge",1)
	zd.initSet(obj,"servid",0)
	zd.initSet(obj,"set_age",0)
	return obj
end

maker.SCT_SevenSignRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_ScXxlTi = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"label",0)
	zd.initSet(obj,"rTime",0)
	zd.initSet(obj,"st",0)
	return obj
end

maker.SCT_HeroSkinNews = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"ghs",0)
	zd.initSet(obj,"hid",0)
	zd.initSet(obj,"skills",0)
	return obj
end

maker.SCT_ModifyPwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"acc","")
	zd.initSet(obj,"new","")
	zd.initSet(obj,"old","")
	return obj
end

maker.SCT_MyKuaYamenRank = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"isHe",0)
	zd.initSet(obj,"myName","")
	zd.initSet(obj,"myScore",0)
	zd.initSet(obj,"myScorerank",0)
	zd.initSet(obj,"sid",0)
	return obj
end

maker.SCT_CS_Hd390ScoreRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"pos",0)
	return obj
end

maker.SCT_DxUser = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"lq",0)
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_SC_RandWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"win",maker.SCT_WinRandWin())
	return obj
end

maker.SCT_labelId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"label","")
	zd.initSet(obj,"ver",0)
	return obj
end

maker.SCT_ScKuom = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cpneed",zd.makeDataArray(maker.SCT_cqcp()))
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"jstype",0)
	zd.initSet(obj,"neednum",0)
	return obj
end

maker.SCT_XianShiAct = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"begintime",0)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"endtime",0)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_XianShiRwd(),"id"))
	zd.initSet(obj,"rwdid",0)
	return obj
end

maker.SCT_fUserInfo2 = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"beijing",0)
	zd.initSet(obj,"chenghao",0)
	zd.initSet(obj,"dress",0)
	zd.initSet(obj,"dress_state",0)
	zd.initSet(obj,"duanwei",0)
	zd.initSet(obj,"extra_ch","")
	zd.initSet(obj,"guajian",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"job",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"maxmap",0)
	zd.initSet(obj,"mingrenchenghao",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"num2",0)
	zd.initSet(obj,"num3",0)
	zd.initSet(obj,"password","")
	zd.initSet(obj,"pet_addi",0)
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"riskexp",0)
	zd.initSet(obj,"risklevel",0)
	zd.initSet(obj,"savelimit",0)
	zd.initSet(obj,"sex",0)
	zd.initSet(obj,"signName","")
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"suoding",0)
	zd.initSet(obj,"uid",0)
	zd.initSet(obj,"vip",0)
	return obj
end

maker.SCT_SCSevenDaySign = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_SCSevenDaySignList()))
	zd.initSet(obj,"state",2)
	return obj
end

maker.SCT_SC_Chat = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"backDetailList",zd.makeDataArray(maker.SCT_FuserData()))
	zd.initSet(obj,"blacklist",zd.makeDataArray(maker.SCT_FuserData()))
	zd.initSet(obj,"club",zd.makeDataArray(maker.SCT_ChatMsgInfo(),"id"))
	zd.initSet(obj,"country",zd.makeDataArray(maker.SCT_ChatMsgInfo(),"id"))
	zd.initSet(obj,"kuafu",zd.makeDataArray(maker.SCT_ChatMsgInfo(),"id"))
	zd.initSet(obj,"mjds_club_chat",zd.makeDataArray(maker.SCT_ChatMsgInfo(),"id"))
	zd.initSet(obj,"mjds_huodong_chat",zd.makeDataArray(maker.SCT_ChatMsgInfo(),"id"))
	zd.initSet(obj,"pao",zd.makeDataArray(maker.SCT_PaoMsgInfo(),"id"))
	zd.initSet(obj,"punish",zd.makeDataArray(maker.SCT_ChatPunish(),"id"))
	zd.initSet(obj,"sev",zd.makeDataArray(maker.SCT_ChatMsgInfo(),"id"))
	zd.initSet(obj,"targetLanguage",maker.SCT_targetLanguageCode())
	return obj
end

maker.SCT_ScXxlDayRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day_integ",0)
	zd.initSet(obj,"isGet",zd.makeDataArray(maker.SCT_ScXxlDayRwdID()))
	return obj
end

maker.SCT_cqcp = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_RankingWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"heromobai",maker.SCT_fHeroInfo())
	zd.initSet(obj,"liangchen",maker.SCT_LiangchenInfo())
	zd.initSet(obj,"mobai",maker.SCT_FuserData())
	return obj
end

maker.SCT_Cshd407All = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",maker.SCT_Null())
	return obj
end

maker.SCT_Scbosspkwin1 = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"gx",0)
	zd.initSet(obj,"hit",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_MingWang = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"eday",0)
	zd.initSet(obj,"maxmw",0)
	zd.initSet(obj,"mw",0)
	return obj
end

maker.SCT_ScRankUpInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"aRankId",0)
	zd.initSet(obj,"bRankId",0)
	return obj
end

maker.SCT_QxWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"gift",maker.SCT_CShd434Play())
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"lamp",maker.SCT_QxWinLamp())
	return obj
end

maker.SCT_Hd263getRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_hd238ChatParams = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"msg","")
	return obj
end

maker.SCT_SsetUSocialDress = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type","")
	return obj
end

maker.SCT_CShd334Set = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",1)
	return obj
end

maker.SCT_sc_sevendaytask_list = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"pro",0)
	zd.initSet(obj,"status",0)
	return obj
end

maker.SCT_CSLjzxRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CsRiskGetBaozang = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"x",0)
	zd.initSet(obj,"y",0)
	return obj
end

maker.SCT_BlackId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buid",0)
	return obj
end

maker.SCT_CS_hd595Get = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CS_StoryClickBtn = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"btnId",0)
	zd.initSet(obj,"storyId",0)
	zd.initSet(obj,"storyZid",0)
	return obj
end

maker.SCT_CS_WordBoss = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"comebackg2d",maker.SCT_heroId())
	zd.initSet(obj,"comebackg2dBatch",maker.SCT_Null())
	zd.initSet(obj,"comebackmg",maker.SCT_heroId())
	zd.initSet(obj,"comebackmgBatch",maker.SCT_Null())
	zd.initSet(obj,"g2dHitRank",maker.SCT_Null())
	zd.initSet(obj,"goFightg2d",maker.SCT_Null())
	zd.initSet(obj,"goFightmg",maker.SCT_Null())
	zd.initSet(obj,"hitgeerdan",maker.SCT_heroId())
	zd.initSet(obj,"hitmenggu",maker.SCT_heroId())
	zd.initSet(obj,"oneKeymenggu",maker.SCT_Null())
	zd.initSet(obj,"scoreRank",maker.SCT_Null())
	zd.initSet(obj,"shopBuy",maker.SCT_WordShopId())
	zd.initSet(obj,"wordboss",maker.SCT_Null())
	return obj
end

maker.SCT_SCSystemNotice = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"m","")
	zd.initSet(obj,"s",1)
	zd.initSet(obj,"t",1)
	return obj
end

maker.SCT_HitMgwinWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bo",1)
	zd.initSet(obj,"damage",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"score2",0)
	return obj
end

maker.SCT_Svipexp = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"recharge",0)
	return obj
end

maker.SCT_CShd365Pre = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dc",0)
	return obj
end

maker.SCT_SCclubKualooklog = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid",0)
	zd.initSet(obj,"fcid",0)
	zd.initSet(obj,"fname","")
	zd.initSet(obj,"fpower",0)
	zd.initSet(obj,"fservid",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"pktime",0)
	zd.initSet(obj,"power",0)
	zd.initSet(obj,"servid",0)
	zd.initSet(obj,"win",0)
	return obj
end

maker.SCT_sc_newcjyxexchange_list = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"is_limit",0)
	zd.initSet(obj,"items",maker.SCT_ItemInfo())
	zd.initSet(obj,"limit",0)
	zd.initSet(obj,"need",0)
	return obj
end

maker.SCT_SC_RISK = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"baozang",zd.makeDataArray(maker.SCT_RiskBaoZang()))
	zd.initSet(obj,"biaoxian",maker.SCT_RiskBiaoxian())
	zd.initSet(obj,"bossinfo",maker.SCT_Riskbossinfo())
	zd.initSet(obj,"bosslist",zd.makeDataArray(maker.SCT_RiskBosslist()))
	zd.initSet(obj,"createNpc",zd.makeDataArray(maker.SCT_RiskCreateNpc()))
	zd.initSet(obj,"darts",zd.makeDataArray(maker.SCT_RiskDartsList()))
	zd.initSet(obj,"exchange",maker.SCT_RiskExchange())
	zd.initSet(obj,"finished_task",zd.makeDataArray(maker.SCT_RiskFinishedTaskList()))
	zd.initSet(obj,"follow",zd.makeDataArray(maker.SCT_RiskFollow()))
	zd.initSet(obj,"hadeClean",zd.makeDataArray(maker.SCT_RiskMap()))
	zd.initSet(obj,"info",maker.SCT_riskLevelInfo())
	zd.initSet(obj,"jiguan",zd.makeDataArray(maker.SCT_RiskJiguan()))
	zd.initSet(obj,"map",zd.makeDataArray(maker.SCT_RiskMap()))
	zd.initSet(obj,"map_cd",zd.makeDataArray(maker.SCT_RiskMapCd()))
	zd.initSet(obj,"mid",maker.SCT_RiskMapid())
	zd.initSet(obj,"mwlist",zd.makeDataArray(maker.SCT_RiskMwlist()))
	zd.initSet(obj,"mysteryShop",maker.SCT_MysteryShop())
	zd.initSet(obj,"nowXy",maker.SCT_RiskMapNow())
	zd.initSet(obj,"npcFavorability",zd.makeDataArray(maker.SCT_NpcFavorability()))
	zd.initSet(obj,"play",maker.SCT_RiskBossDetail())
	zd.initSet(obj,"playStory",maker.SCT_RiskStory())
	zd.initSet(obj,"power",maker.SCT_RiskPower())
	zd.initSet(obj,"shoplist",zd.makeDataArray(maker.SCT_RiskShoplist()))
	zd.initSet(obj,"suiji_item",zd.makeDataArray(maker.SCT_Risksuiji_item()))
	zd.initSet(obj,"task",zd.makeDataArray(maker.SCT_RiskTaskList()))
	zd.initSet(obj,"texiao",zd.makeDataArray(maker.SCT_Risktexiaolist()))
	zd.initSet(obj,"unlock",maker.SCT_riskUnlock())
	zd.initSet(obj,"up_baozang",maker.SCT_RiskUpBaoZang())
	zd.initSet(obj,"up_map",zd.makeDataArray(maker.SCT_RiskMap()))
	zd.initSet(obj,"up_task",zd.makeDataArray(maker.SCT_RiskTaskList()))
	zd.initSet(obj,"win",maker.SCT_Riskbossxianqing())
	return obj
end

maker.SCT_CclubPwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"password","")
	return obj
end

maker.SCT_SC_FourGoodNoticeContent = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"content","")
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_BHCZHDCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_Shdrwd1()))
	return obj
end

maker.SCT_ParamType = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CsriskgetBossInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bossid",0)
	return obj
end

maker.SCT_khero = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_Risksuiji_item = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"kind",0)
	zd.initSet(obj,"zb",0)
	return obj
end

maker.SCT_RiskMwlist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"mtype",0)
	zd.initSet(obj,"x",0)
	zd.initSet(obj,"y",0)
	return obj
end

maker.SCT_ScLjzxInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"gRwd","")
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_ScLjzxRwd(),"id"))
	return obj
end

maker.SCT_ClubCZHDLog = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"time",0)
	return obj
end

maker.SCT_changePostCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg","")
	zd.initSet(obj,"key",0)
	return obj
end

maker.SCT_SSetubacktx = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_cs_getSkin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"key",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_survey_id = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_WordShopItem = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_CSkuaPKBack = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hid",maker.SCT_Null())
	return obj
end

maker.SCT_SsetUFrame = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CS_PlayModuleStory = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_hd699RefuseToTeam = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"tmid",0)
	return obj
end

maker.SCT_skinShopInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"sshop",zd.makeDataArray(maker.SCT_ScskinshopInfo(),"id"))
	return obj
end

maker.SCT_CYhFind = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid","0")
	return obj
end

maker.SCT_survey_cfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"headline","")
	zd.initSet(obj,"imgurl",0)
	zd.initSet(obj,"isshow",1)
	zd.initSet(obj,"outline","")
	zd.initSet(obj,"question",zd.makeDataArray(maker.SCT_survey_question()))
	return obj
end

maker.SCT_CMemberPost = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid",0)
	zd.initSet(obj,"postid",0)
	return obj
end

maker.SCT_jxhschat = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_WBGe2Dan = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"allhp",0)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"damage",0)
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_Pvb2Date = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"label","")
	zd.initSet(obj,"next",0)
	return obj
end

maker.SCT_SC_sevendtask = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"task",zd.makeDataArray(maker.SCT_sevendtaskcfg(),"id"))
	return obj
end

maker.SCT_BHCZHDInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"eTime",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"kg",0)
	zd.initSet(obj,"no",0)
	zd.initSet(obj,"sTime",0)
	zd.initSet(obj,"title","")
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SCcslist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"heroid",0)
	zd.initSet(obj,"hname","")
	zd.initSet(obj,"hpower",0)
	zd.initSet(obj,"jnid",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"post",0)
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_CxghdPaihang = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CS_hd922Rwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dc",0)
	zd.initSet(obj,"typeId",0)
	return obj
end

maker.SCT_CSBagNum = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_TurnInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_Syrwlist(),"id"))
	return obj
end

maker.SCT_yhnewlist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"ep",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"u_credit",0)
	zd.initSet(obj,"u_score",0)
	return obj
end

maker.SCT_SC_panan = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"pananId",0)
	return obj
end

maker.SCT_CsRiskSubmitTask = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_Shdrwdlc = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"jiazhi",0)
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"need",0)
	return obj
end

maker.SCT_LanFangUnlock = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"unlock",0)
	return obj
end

maker.SCT_CHinfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bjlist",zd.makeDataArray(maker.SCT_CHlist(),"id"))
	zd.initSet(obj,"gjlist",zd.makeDataArray(maker.SCT_CHlist(),"id"))
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_CHlist(),"id"))
	zd.initSet(obj,"mklist",zd.makeDataArray(maker.SCT_CHlist(),"id"))
	zd.initSet(obj,"setFid",0)
	zd.initSet(obj,"set_ids","")
	zd.initSet(obj,"setbj",0)
	zd.initSet(obj,"setgj",0)
	zd.initSet(obj,"setid",0)
	zd.initSet(obj,"setmk",0)
	return obj
end

maker.SCT_Pay_rewards = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"isshow",0)
	zd.initSet(obj,"item",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"need",0)
	zd.initSet(obj,"status",0)
	return obj
end

maker.SCT_blesschange = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"newId",0)
	zd.initSet(obj,"oldId",0)
	return obj
end

maker.SCT_LiangchenInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"chenghao",0)
	zd.initSet(obj,"date","")
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"dress",0)
	zd.initSet(obj,"endTime","")
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"job",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"name","")
	zd.initSet(obj,"saiji",0)
	zd.initSet(obj,"sex",0)
	zd.initSet(obj,"shiceid",0)
	zd.initSet(obj,"sid",0)
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_Flist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_fUserInfo(),"id"))
	zd.initSet(obj,"refuse_apply",0)
	return obj
end

maker.SCT_SyhOld = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bad",0)
	zd.initSet(obj,"ctime",0)
	zd.initSet(obj,"ep",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"score",0)
	return obj
end

maker.SCT_SC_ClubExtendDailyInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cyCountDaily",zd.makeDataArray(maker.SCT_SC_ClubExtendDailyInfoCyCountDaily()))
	return obj
end

maker.SCT_CSsetAge = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"d",0)
	zd.initSet(obj,"m",0)
	zd.initSet(obj,"y",0)
	return obj
end

maker.SCT_SCvipexp = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"vip",0)
	return obj
end

maker.SCT_BanishDeskCashList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cash",1)
	zd.initSet(obj,"id",1)
	return obj
end

maker.SCT_itemHeroBase = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"heroid",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_dailyrwditemlist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"itemid",0)
	zd.initSet(obj,"kind",0)
	return obj
end

maker.SCT_CS_UserTranslate = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"text","")
	return obj
end

maker.SCT_SC_guideConsumeInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"reward",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"status",0)
	zd.initSet(obj,"time",0)
	return obj
end

maker.SCT_UserModelWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"onekeypvewin",maker.SCT_OnekeyPveWin())
	zd.initSet(obj,"pvb2win",maker.SCT_UserPvb2Win())
	zd.initSet(obj,"pvbwin",maker.SCT_UserPvbWin())
	zd.initSet(obj,"pvewin",maker.SCT_UserPveWin())
	return obj
end

maker.SCT_zj_list = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",1)
	zd.initSet(obj,"state",1)
	return obj
end

maker.SCT_SC_Cj0Bhuodong = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg",maker.SCT_cjoldPlayerBackCfg())
	return obj
end

maker.SCT_CShopList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid",maker.SCT_Null())
	return obj
end

maker.SCT_CityInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"document","")
	return obj
end

maker.SCT_SkinInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dt",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SCclubkuajf = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cname","")
	zd.initSet(obj,"mzname","")
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"servid",0)
	return obj
end

maker.SCT_SbossInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"hp",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"ltime",maker.SCT_CdLabel())
	zd.initSet(obj,"money",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_UserId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CsCourtyardShop = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",1)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",1)
	return obj
end

maker.SCT_SheroLog = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"heroname","")
	zd.initSet(obj,"hit",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"time",0)
	return obj
end

maker.SCT_CsCourtyardHarvest = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_Sfllist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"chatFrame",0)
	zd.initSet(obj,"frame",0)
	zd.initSet(obj,"head",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"job",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"sllist",zd.makeDataArray(maker.SCT_Ssllist(),"id"))
	return obj
end

maker.SCT_Getrwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_Shdinfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"eTime",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"news",0)
	zd.initSet(obj,"pindex",0)
	zd.initSet(obj,"sTime",0)
	zd.initSet(obj,"showTime",0)
	zd.initSet(obj,"title","")
	zd.initSet(obj,"type",1)
	return obj
end

maker.SCT_SCUserDressListBase = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"yj",0)
	return obj
end

maker.SCT_SmyYhRid = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"score",0)
	return obj
end

maker.SCT_cznhlallrwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"rwd",zd.makeDataArray("czhlrwd"))
	return obj
end

maker.SCT_fHeroData = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hid","")
	zd.initSet(obj,"name","")
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_firstHeroList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dt",0)
	zd.initSet(obj,"epskill",zd.makeDataArray(maker.SCT_SkilInfo(),"id"))
	zd.initSet(obj,"ghskill",zd.makeDataArray(maker.SCT_SkilInfo(),"id"))
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"scorerank",0)
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_SCShopHefa = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_Cshd401All = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",maker.SCT_Null())
	return obj
end

maker.SCT_onKeyUp = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"defated",0)
	zd.initSet(obj,"success",0)
	zd.initSet(obj,"upexp",0)
	return obj
end

maker.SCT_Null = function()
	local obj = {}
	zd.makeDataTable(obj)
	return obj
end

maker.SCT_ladder_mingrenlist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"beijing",0)
	zd.initSet(obj,"chatFrame",0)
	zd.initSet(obj,"chenghao",0)
	zd.initSet(obj,"dress",0)
	zd.initSet(obj,"duanwei",0)
	zd.initSet(obj,"extra_ch","")
	zd.initSet(obj,"frame",0)
	zd.initSet(obj,"head",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"isHe",0)
	zd.initSet(obj,"jie",1)
	zd.initSet(obj,"job",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"mingrenchenghao",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"num2",0)
	zd.initSet(obj,"num3",0)
	zd.initSet(obj,"num4","")
	zd.initSet(obj,"offlineCh","")
	zd.initSet(obj,"pet_addi",0)
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"sevid",0)
	zd.initSet(obj,"sex",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"uid",0)
	zd.initSet(obj,"vip",0)
	zd.initSet(obj,"vipStatus",1)
	return obj
end

maker.SCT_SuidLog = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"kill","")
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_jslist()))
	return obj
end

maker.SCT_ScXxlShop = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"t",0)
	return obj
end

maker.SCT_ClubCZHDUserCz = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	return obj
end

maker.SCT_s_onlineTime = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"onlineTime",0)
	return obj
end

maker.SCT_ChrUser = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	return obj
end

maker.SCT_jqInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fsn","")
	zd.initSet(obj,"mysn","")
	zd.initSet(obj,"t",0)
	zd.initSet(obj,"tar",0)
	return obj
end

maker.SCT_SC_loginMod = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"error",maker.SCT_SC_loginModError())
	zd.initSet(obj,"loginAccount",maker.SCT_SC_LoginAccount())
	return obj
end

maker.SCT_CS_GuideSpecialGuide = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_inheritUser = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id","")
	zd.initSet(obj,"openid","")
	zd.initSet(obj,"openkey","")
	zd.initSet(obj,"platform","")
	zd.initSet(obj,"pwd","")
	return obj
end

maker.SCT_SC_FourGoodBuyRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"get",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CApply = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid",0)
	zd.initSet(obj,"msg","")
	return obj
end

maker.SCT_CS_huodong2 = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hd1005Cut",maker.SCT_ParamNum())
	zd.initSet(obj,"hd1005Done",maker.SCT_Null())
	zd.initSet(obj,"hd1005Info",maker.SCT_Null())
	zd.initSet(obj,"hd1005Open",maker.SCT_ParamWid())
	zd.initSet(obj,"hd1005RwdBox",maker.SCT_ParamId())
	zd.initSet(obj,"hd1005RwdDaily",maker.SCT_Null())
	zd.initSet(obj,"hd1005RwdTask",maker.SCT_ParamId())
	zd.initSet(obj,"hd237Draw",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd237GetCzRwd",maker.SCT_idBase())
	zd.initSet(obj,"hd237Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd237Rank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd238Buy",maker.SCT_hd238BuyParams())
	zd.initSet(obj,"hd238Get","")
	zd.initSet(obj,"hd238Info","")
	zd.initSet(obj,"hd238chat",maker.SCT_hd238ChatParams())
	zd.initSet(obj,"hd238checkChat","")
	zd.initSet(obj,"hd239Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd239Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd327Get","CxzcGet")
	zd.initSet(obj,"hd327Info","CxzcInfo")
	zd.initSet(obj,"hd327Rwd",maker.SCT_NULL())
	zd.initSet(obj,"hd327Set","CxzcSet")
	zd.initSet(obj,"hd327Zao","CxzcZao")
	zd.initSet(obj,"hd327exchange","CxzcGet")
	zd.initSet(obj,"hd328Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd540Exchange",maker.SCT_idBase())
	zd.initSet(obj,"hd540GetBox",maker.SCT_idBase())
	zd.initSet(obj,"hd540GetRank","")
	zd.initSet(obj,"hd540Info","")
	zd.initSet(obj,"hd540Play",maker.SCT_CSplayNum())
	zd.initSet(obj,"hd540SetOpt","CS_ShenBingsetoptional")
	zd.initSet(obj,"hd549Info","")
	zd.initSet(obj,"hd549buy",maker.SCT_idBase())
	zd.initSet(obj,"hd552AllLog",maker.SCT_NULL())
	zd.initSet(obj,"hd552Back",maker.SCT_idBase())
	zd.initSet(obj,"hd552City",maker.SCT_idBase())
	zd.initSet(obj,"hd552ComeIn",maker.SCT_NULL())
	zd.initSet(obj,"hd552Dispatch",maker.SCT_CS_hd552Dispatch())
	zd.initSet(obj,"hd552Get",maker.SCT_NULL())
	zd.initSet(obj,"hd552GetZhen",maker.SCT_CS_hd552GetZhen())
	zd.initSet(obj,"hd552Info",maker.SCT_NULL())
	zd.initSet(obj,"hd552Rank",maker.SCT_idBase())
	zd.initSet(obj,"hd552SelfLog",maker.SCT_NULL())
	zd.initSet(obj,"hd580Info","")
	zd.initSet(obj,"hd580Rwd",maker.SCT_NULL())
	zd.initSet(obj,"hd593Fan",maker.SCT_Cx591fan())
	zd.initSet(obj,"hd593Get",maker.SCT_CShd336Up())
	zd.initSet(obj,"hd593Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd593Task",maker.SCT_CxslchdRwd())
	zd.initSet(obj,"hd595Info","")
	zd.initSet(obj,"hd595Rwd",maker.SCT_CS_hd595Get())
	zd.initSet(obj,"hd630Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd678Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd678Rwd","CjghdRwd")
	zd.initSet(obj,"hd684Info","")
	zd.initSet(obj,"hd684Play","jxhsplay")
	zd.initSet(obj,"hd684Rank","")
	zd.initSet(obj,"hd684agree","jxhsuid")
	zd.initSet(obj,"hd684allRefuse","")
	zd.initSet(obj,"hd684autoTalk","")
	zd.initSet(obj,"hd684breakClub","")
	zd.initSet(obj,"hd684buy","jxhsbuy")
	zd.initSet(obj,"hd684buyEventGift","jxhsbuygift")
	zd.initSet(obj,"hd684chat",maker.SCT_jxhschat())
	zd.initSet(obj,"hd684checkChat",maker.SCT_jxhscheckchat())
	zd.initSet(obj,"hd684createTeam","jxhscreateclub")
	zd.initSet(obj,"hd684exchange","jxhsid")
	zd.initSet(obj,"hd684getEventRwd","jxhsid")
	zd.initSet(obj,"hd684getRechargeRwd","jxhsid")
	zd.initSet(obj,"hd684getScenicRwd","jxhsid")
	zd.initSet(obj,"hd684join","jxhsclubid")
	zd.initSet(obj,"hd684kickout","jxhsuid")
	zd.initSet(obj,"hd684logs","")
	zd.initSet(obj,"hd684outClub","jxhsclubid")
	zd.initSet(obj,"hd684rand","jxhschangeRand")
	zd.initSet(obj,"hd684randEvent","jxhsid")
	zd.initSet(obj,"hd684randJoin","")
	zd.initSet(obj,"hd684refuse","jxhsuid")
	zd.initSet(obj,"hd684result","jxhsrecord")
	zd.initSet(obj,"hd684teamInfo","jxhsid")
	zd.initSet(obj,"hd684use","jxhsbuy")
	zd.initSet(obj,"hd695Check","")
	zd.initSet(obj,"hd695History",maker.SCT_ParamId())
	zd.initSet(obj,"hd695Info","")
	zd.initSet(obj,"hd695Play","")
	zd.initSet(obj,"hd697Buy","hd697BuyParams")
	zd.initSet(obj,"hd697DoubleBackFlop",maker.SCT_NULL())
	zd.initSet(obj,"hd697Exchange","hd697ExchangeParams")
	zd.initSet(obj,"hd697Get","hd697GetParams")
	zd.initSet(obj,"hd697Info",maker.SCT_NULL())
	zd.initSet(obj,"hd697Play","hd697PlayParams")
	zd.initSet(obj,"hd697Rank",maker.SCT_NULL())
	zd.initSet(obj,"hd698Get",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd698Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd699Info","")
	zd.initSet(obj,"hd699agree",maker.SCT_hd699AgreeToTeam())
	zd.initSet(obj,"hd699allRefuse","")
	zd.initSet(obj,"hd699applyList","")
	zd.initSet(obj,"hd699autoTalk","")
	zd.initSet(obj,"hd699chat",maker.SCT_hd699ChatByType())
	zd.initSet(obj,"hd699chatHistory",maker.SCT_hd699ChatHisByType())
	zd.initSet(obj,"hd699checkChat",maker.SCT_hd699checkChatByType())
	zd.initSet(obj,"hd699getReward",maker.SCT_hd699Reward())
	zd.initSet(obj,"hd699joinTeam",maker.SCT_hd699TeammateId())
	zd.initSet(obj,"hd699myTeam","")
	zd.initSet(obj,"hd699refuse",maker.SCT_hd699RefuseToTeam())
	zd.initSet(obj,"hd699toggle","")
	zd.initSet(obj,"hd709Buy",maker.SCT_hd709Num())
	zd.initSet(obj,"hd709Exchange",maker.SCT_hd709ExchangeParams())
	zd.initSet(obj,"hd709GetBox",maker.SCT_hd709GetBoxParams())
	zd.initSet(obj,"hd709GetRecharge",maker.SCT_hd709GetRechargeParams())
	zd.initSet(obj,"hd709Info","")
	zd.initSet(obj,"hd709Play",maker.SCT_hd709Num())
	zd.initSet(obj,"hd709Rank","")
	zd.initSet(obj,"hd745Info","")
	zd.initSet(obj,"hd745blessRwd",maker.SCT_CS_hd745Rwd())
	zd.initSet(obj,"hd745comRwd","")
	zd.initSet(obj,"hd745dragonRwd","")
	zd.initSet(obj,"hd745play",maker.SCT_CS_hd745play())
	zd.initSet(obj,"hd745taskRwd",maker.SCT_CS_hd745Rwd())
	zd.initSet(obj,"hd748Buy",maker.SCT_hd748Num())
	zd.initSet(obj,"hd748Exchange",maker.SCT_hd748ExchangeParams())
	zd.initSet(obj,"hd748GetBox",maker.SCT_hd748GetBoxParams())
	zd.initSet(obj,"hd748GetRecharge",maker.SCT_hd748GetRechargeParams())
	zd.initSet(obj,"hd748Info","")
	zd.initSet(obj,"hd748Play",maker.SCT_hd748Num())
	zd.initSet(obj,"hd748Rank","")
	zd.initSet(obj,"hd792Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd804Gplay",maker.SCT_NULL())
	zd.initSet(obj,"hd804Info",maker.SCT_NULL())
	zd.initSet(obj,"hd804Play",maker.SCT_NULL())
	zd.initSet(obj,"hd805Buy","hd697BuyParams")
	zd.initSet(obj,"hd805DoubleBackFlop","hd805DoubleBackFlopParams")
	zd.initSet(obj,"hd805Exchange","hd697ExchangeParams")
	zd.initSet(obj,"hd805Get","hd697GetParams")
	zd.initSet(obj,"hd805Info",maker.SCT_NULL())
	zd.initSet(obj,"hd805Play","hd697PlayParams")
	zd.initSet(obj,"hd805Rank",maker.SCT_NULL())
	zd.initSet(obj,"hd806Buy","hd697BuyParams")
	zd.initSet(obj,"hd806Czz","hd806CzzParams")
	zd.initSet(obj,"hd806Exchange","hd697ExchangeParams")
	zd.initSet(obj,"hd806Get","hd697GetParams")
	zd.initSet(obj,"hd806Help","hd806HelpParams")
	zd.initSet(obj,"hd806Info",maker.SCT_NULL())
	zd.initSet(obj,"hd806Play","hd697PlayParams")
	zd.initSet(obj,"hd806Rank",maker.SCT_NULL())
	zd.initSet(obj,"hd806Task",maker.SCT_CxslchdRwd())
	zd.initSet(obj,"hd806UserInfo",maker.SCT_UserId())
	zd.initSet(obj,"hd816Info",maker.SCT_Null())
	zd.initSet(obj,"hd816getMyzy",maker.SCT_Null())
	zd.initSet(obj,"hd816getQuan",maker.SCT_Null())
	zd.initSet(obj,"hd816getwzw",maker.SCT_Null())
	zd.initSet(obj,"hd816play",maker.SCT_ParamNum())
	zd.initSet(obj,"hd816shisq",maker.SCT_Null())
	zd.initSet(obj,"hd817Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd817buy","wglcbuy")
	zd.initSet(obj,"hd817exchange","wglcexchange")
	zd.initSet(obj,"hd817getPaihang","CxzcInfo")
	zd.initSet(obj,"hd817getrwd","CxghdExchange")
	zd.initSet(obj,"hd817lingqu","")
	zd.initSet(obj,"hd817play","wglcplay")
	zd.initSet(obj,"hd820Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd850Answer",maker.SCT_hd850AnswerInfo())
	zd.initSet(obj,"hd850History",maker.SCT_Null())
	zd.initSet(obj,"hd850Info",maker.SCT_Null())
	zd.initSet(obj,"hd850Question",maker.SCT_Null())
	zd.initSet(obj,"hd850Rank",maker.SCT_Null())
	zd.initSet(obj,"hd850Taskinfo",maker.SCT_Null())
	zd.initSet(obj,"hd850Taskreward",maker.SCT_hd850TaskrewardInfo())
	zd.initSet(obj,"hd850UseItem",maker.SCT_hd850UseItmeInfo())
	zd.initSet(obj,"hd912Buy",maker.SCT_CShd912Buy())
	zd.initSet(obj,"hd912Exchange","hd697ExchangeParams")
	zd.initSet(obj,"hd912Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd912Pay",maker.SCT_CxslchdRwd())
	zd.initSet(obj,"hd912Task",maker.SCT_CxslchdRwd())
	zd.initSet(obj,"hd913Check","CShd913Check")
	zd.initSet(obj,"hd913Exchange","hd697ExchangeParams")
	zd.initSet(obj,"hd913Get",maker.SCT_CShd336Up())
	zd.initSet(obj,"hd913Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd913Open","Cx913Open")
	zd.initSet(obj,"hd913Recharge",maker.SCT_CxslchdRwd())
	zd.initSet(obj,"hd913Reset",maker.SCT_CShd913type())
	zd.initSet(obj,"hd914Archery","Cxhd914Archery")
	zd.initSet(obj,"hd914DailyBx",maker.SCT_NULL())
	zd.initSet(obj,"hd914Get",maker.SCT_CShd336Up())
	zd.initSet(obj,"hd914Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd914Pick","Cxhd914Pick")
	zd.initSet(obj,"hd914Task",maker.SCT_CxslchdRwd())
	zd.initSet(obj,"hd915Buy",maker.SCT_idBase())
	zd.initSet(obj,"hd915Chat",maker.SCT_ChatMsg())
	zd.initSet(obj,"hd915Check",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd915Get",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd915Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd915Log",maker.SCT_ChatId())
	zd.initSet(obj,"hd915UserRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd917Draw","")
	zd.initSet(obj,"hd917Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd917Pray","Cxhd917Pray")
	zd.initSet(obj,"hd917Wishing","Cxhd917Wishing")
	return obj
end

maker.SCT_QxRwdLog = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"itemid",0)
	zd.initSet(obj,"name","")
	return obj
end

maker.SCT_CdNumOpen = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"isopen",0)
	zd.initSet(obj,"label","")
	zd.initSet(obj,"next",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_CShd344Send = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"phone",0)
	return obj
end

maker.SCT_CdNum = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"label","")
	zd.initSet(obj,"next",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_targetLanguage = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"targetLanguage","")
	return obj
end

maker.SCT_ParamKey = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"key",0)
	return obj
end

maker.SCT_SourceTextInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"SourceText","")
	zd.initSet(obj,"id","")
	return obj
end

maker.SCT_SC_ChengJiu = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cjlist",zd.makeDataArray(maker.SCT_ChenhJiulist(),"id"))
	return obj
end

maker.SCT_CS_Login = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"authen",maker.SCT_IdAuthen())
	zd.initSet(obj,"getHistory",maker.SCT_CS_Login_getHistory())
	zd.initSet(obj,"inheritUser",maker.SCT_inheritUser())
	zd.initSet(obj,"intro",maker.SCT_LoginIntro())
	zd.initSet(obj,"loginAccount",maker.SCT_LoginAccount())
	zd.initSet(obj,"notice",maker.SCT_GuideNotic())
	zd.initSet(obj,"verify",maker.SCT_LoginAccount())
	return obj
end

maker.SCT_SchoolStart = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hid",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SchoolDate = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"desk",1)
	return obj
end

maker.SCT_ScskinshopInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"discount",0)
	zd.initSet(obj,"eTime",0)
	zd.initSet(obj,"ids","")
	zd.initSet(obj,"sTime",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_ErrorCode = zd.Enum:new("king.ErrorCode","noNum","noFood")
maker.SCT_ScXxlCfgShop = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cost",0)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"kind",0)
	zd.initSet(obj,"limit",0)
	return obj
end

maker.SCT_SC_centralattackinfofbscorelist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bei",0)
	zd.initSet(obj,"time","")
	zd.initSet(obj,"timestamp",0)
	return obj
end

maker.SCT_SCldjcbkhdCfgRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"need",0)
	return obj
end

maker.SCT_CS_HD496BuyRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SCclubheroinfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"add",0)
	zd.initSet(obj,"dt",0)
	zd.initSet(obj,"dx",0)
	zd.initSet(obj,"gjadd",0)
	zd.initSet(obj,"hid",0)
	zd.initSet(obj,"huihe",0)
	zd.initSet(obj,"is_win",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"out",0)
	zd.initSet(obj,"padd",0)
	zd.initSet(obj,"post",0)
	zd.initSet(obj,"power",0)
	zd.initSet(obj,"skin",0)
	zd.initSet(obj,"uid",0)
	zd.initSet(obj,"ur",0)
	zd.initSet(obj,"use",0)
	return obj
end

maker.SCT_hd709GetRechargeParams = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_HeChengList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"itemid",0)
	zd.initSet(obj,"need",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"outtime",0)
	zd.initSet(obj,"times",0)
	zd.initSet(obj,"totonum",0)
	return obj
end

maker.SCT_SCsocialdressedall = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"userchatframe",zd.makeDataArray(maker.SCT_SCsocialdressedlist(),"id"))
	zd.initSet(obj,"userframe",zd.makeDataArray(maker.SCT_SCsocialdressedlist(),"id"))
	zd.initSet(obj,"userhead",zd.makeDataArray(maker.SCT_SCsocialdressedlist(),"id"))
	return obj
end

maker.SCT_WBMengGu = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bo",1)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"damage",0)
	zd.initSet(obj,"heroft",zd.makeDataArray(maker.SCT_FightList(),"id"))
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_FchoFuli = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"time",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SC_zglb = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg",maker.SCT_ScgInfoDirect())
	return obj
end

maker.SCT_csBuildOccupy = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buildingId",0)
	zd.initSet(obj,"buildingLevel",0)
	zd.initSet(obj,"chanllengeId",0)
	zd.initSet(obj,"heros",zd.makeDataArray(maker.SCT_KuaMineOccupyHero()))
	zd.initSet(obj,"locationId",0)
	return obj
end

maker.SCT_SurveyInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg",maker.SCT_survey_cfg())
	zd.initSet(obj,"info",maker.SCT_Shdinfo())
	zd.initSet(obj,"must",zd.makeDataArray(maker.SCT_survey_id()))
	return obj
end

maker.SCT_wannengInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buyTime",0)
	return obj
end

maker.SCT_Stmain = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",1)
	zd.initSet(obj,"max",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_ScKitchenMenu = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cpnum",0)
	zd.initSet(obj,"opmenu",zd.makeDataArray(maker.SCT_ScKom()))
	zd.initSet(obj,"plv",0)
	zd.initSet(obj,"uopmenu",zd.makeDataArray(maker.SCT_ScKuom()))
	return obj
end

maker.SCT_CClubList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid",0)
	return obj
end

maker.SCT_CXxbad = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",maker.SCT_Null())
	return obj
end

maker.SCT_CS_ChooseStory = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"chooseid",0)
	zd.initSet(obj,"storyid",0)
	return obj
end

maker.SCT_rwdItems = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"kind",0)
	return obj
end

maker.SCT_fbshareInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_xsRankWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"myName","")
	zd.initSet(obj,"myNum",0)
	zd.initSet(obj,"myRid",0)
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"xsRank",zd.makeDataArray(maker.SCT_Scblist(),"id"))
	return obj
end

maker.SCT_SC_ChengHao = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"chInfo",maker.SCT_CHinfo())
	zd.initSet(obj,"wyrwd","Cswyrwd")
	return obj
end

maker.SCT_itemId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_QzAiMin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"max",0)
	zd.initSet(obj,"now",0)
	return obj
end

maker.SCT_CClubBossHitList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SC_zhuchenghint = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_zhuchenginfo())
	return obj
end

maker.SCT_SC_Ladder = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cslist",zd.makeDataArray(maker.SCT_FightList(),"id"))
	zd.initSet(obj,"deflog",zd.makeDataArray("YamenDefInfo","id"))
	zd.initSet(obj,"enymsg",zd.makeDataArray("YamenEnymsg","id"))
	zd.initSet(obj,"exchange","SjlShop")
	zd.initSet(obj,"fclist",zd.makeDataArray(maker.SCT_FightList(),"id"))
	zd.initSet(obj,"fight","ladderPVP_fight")
	zd.initSet(obj,"firstScoreRank",maker.SCT_FirstYamenData())
	zd.initSet(obj,"gongxun",maker.SCT_ladder_gongxun())
	zd.initSet(obj,"hastz",zd.makeDataArray("Yamenhastz","id"))
	zd.initSet(obj,"hdinfo",maker.SCT_KuattInfo())
	zd.initSet(obj,"info",maker.SCT_PVP_Info_ladder())
	zd.initSet(obj,"kill20log",zd.makeDataArray("Yamen20log","id"))
	zd.initSet(obj,"ladderShopfresh",maker.SCT_SjlShopfresh())
	zd.initSet(obj,"mingrenlist",zd.makeDataArray(maker.SCT_ladder_mingrenlist(),"id"))
	zd.initSet(obj,"mrchenghao",maker.SCT_ladder_chenghao())
	zd.initSet(obj,"myScore",maker.SCT_ladder_myscore())
	zd.initSet(obj,"onekey","YamenOnekey")
	zd.initSet(obj,"scoreRank",zd.makeDataArray(maker.SCT_ladder_fUserInfo(),"id"))
	zd.initSet(obj,"severRank",zd.makeDataArray(maker.SCT_SeverInfo(),"id"))
	zd.initSet(obj,"severScore",maker.SCT_MyKuaYamenRank())
	zd.initSet(obj,"win","YamenWin")
	zd.initSet(obj,"yuxuan","KuaYamenState")
	zd.initSet(obj,"zhuisha","ladderFind")
	return obj
end

maker.SCT_Fsendlist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_fUserInfo(),"id"))
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_CsMysteryUnlock = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",2)
	return obj
end

maker.SCT_Fuid = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid",0)
	return obj
end

maker.SCT_sevendtaskcfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"isGet",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_SCpost = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cy",0)
	zd.initSet(obj,"fmz",0)
	zd.initSet(obj,"jy",0)
	zd.initSet(obj,"mz",0)
	return obj
end

maker.SCT_SyhType = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"iskua",0)
	zd.initSet(obj,"over",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SC = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"derail",maker.SCT_SC_Derail())
	zd.initSet(obj,"gameMachine",maker.SCT_SC_GameMachine())
	zd.initSet(obj,"guide",maker.SCT_SC_Guide())
	zd.initSet(obj,"hero",maker.SCT_SC_Hero())
	zd.initSet(obj,"loginMod",maker.SCT_SC_loginMod())
	zd.initSet(obj,"mail",maker.SCT_SC_Mail())
	zd.initSet(obj,"map",maker.SCT_SC_Map())
	zd.initSet(obj,"msgWin",maker.SCT_SC_MsgWin())
	zd.initSet(obj,"msgWin2",maker.SCT_SC_MsgWin())
	zd.initSet(obj,"notice",maker.SCT_SC_Notice())
	zd.initSet(obj,"order",maker.SCT_SC_Order())
	zd.initSet(obj,"randWin",maker.SCT_SC_RandWin())
	zd.initSet(obj,"sdk",maker.SCT_SC_sdk())
	zd.initSet(obj,"shop",maker.SCT_SC_Shop())
	zd.initSet(obj,"story",maker.SCT_SC_Story())
	zd.initSet(obj,"system",maker.SCT_SC_System())
	zd.initSet(obj,"user",maker.SCT_SC_User())
	return obj
end

maker.SCT_CS_GM = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"addGameMachineCnt","")
	zd.initSet(obj,"drawGameMachine",maker.SCT_CommonOrder())
	return obj
end

maker.SCT_SC_FourGoodRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_SC_FourGoodRwdLevel(),"id"))
	return obj
end

maker.SCT_Fnum = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"f_num",0)
	return obj
end

maker.SCT_ChatId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CYhHold = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"isOpen",0)
	zd.initSet(obj,"kuaOpen",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_FuLiShenJi = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"times",0)
	return obj
end

maker.SCT_Cxsdnd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_RiskTaskList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"get_rwd",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"isNew",0)
	zd.initSet(obj,"jindu",zd.makeDataArray(maker.SCT_RiskJindu()))
	return obj
end

maker.SCT_SC_Map = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"city",maker.SCT_CityInfo())
	return obj
end

maker.SCT_Szcjbcfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_Shdcfg())
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"need",maker.SCT_Sneedcfg())
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_Srwdcfg(),"id"))
	return obj
end

maker.SCT_SC_All_butler = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"butler_dispos",maker.SCT_Sc_dispos())
	zd.initSet(obj,"butler_do",zd.makeDataArray(maker.SCT_Sc_butler_do(),"id"))
	zd.initSet(obj,"butler_info",maker.SCT_Sc_butler_info())
	zd.initSet(obj,"butler_logs",zd.makeDataArray("Sc_butlerlogs","id"))
	zd.initSet(obj,"do_all","Sc_do_dispos")
	zd.initSet(obj,"shoplist","Sc_butlershop")
	return obj
end

maker.SCT_CSCzhl = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"money",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_ActNoticePic = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"actid","")
	zd.initSet(obj,"gid","")
	zd.initSet(obj,"picid","")
	zd.initSet(obj,"pictype","")
	zd.initSet(obj,"showtime","")
	zd.initSet(obj,"stime","")
	return obj
end

maker.SCT_WordG2dMyDmgRk = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"g2dallman",0)
	zd.initSet(obj,"g2dmydamage",0)
	zd.initSet(obj,"g2dmyrank",0)
	return obj
end

maker.SCT_mseInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"s",0)
	zd.initSet(obj,"st",0)
	return obj
end

maker.SCT_SCUserVerify = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"day","")
	return obj
end

maker.SCT_SCUserDressNList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cFrame",0)
	zd.initSet(obj,"frame",0)
	zd.initSet(obj,"head",0)
	return obj
end

maker.SCT_SC_FuLi = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"coupon",zd.makeDataArray(maker.SCT_couponIngo(),"id"))
	zd.initSet(obj,"fbdc",maker.SCT_FuLiFBDC())
	zd.initSet(obj,"fbshare",maker.SCT_fbshareInfo())
	zd.initSet(obj,"fchofuli",zd.makeDataArray(maker.SCT_FchoFuli()))
	zd.initSet(obj,"fchofuliwin",maker.SCT_FchoFuliGuide())
	zd.initSet(obj,"fulifund",maker.SCT_FuliFundInfo())
	zd.initSet(obj,"guanqun",maker.SCT_QQNum())
	zd.initSet(obj,"mooncard",zd.makeDataArray(maker.SCT_CardType(),"id"))
	zd.initSet(obj,"moonclubfuli",maker.SCT_MoonClubFuli())
	zd.initSet(obj,"qiandao",maker.SCT_QianDaoDay())
	zd.initSet(obj,"sevenDaySign",maker.SCT_SCSevenDaySign())
	zd.initSet(obj,"shenji",zd.makeDataArray(maker.SCT_FuLiShenJi(),"id"))
	zd.initSet(obj,"vipfuli",zd.makeDataArray(maker.SCT_VipFuLiType(),"id"))
	zd.initSet(obj,"win",maker.SCT_FuLiWin())
	zd.initSet(obj,"wxqq",maker.SCT_FuLiWXQQ())
	return obj
end

maker.SCT_SMemberInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"allgx",0)
	zd.initSet(obj,"cid",0)
	zd.initSet(obj,"cyBan",0)
	zd.initSet(obj,"dcid",0)
	zd.initSet(obj,"fdicd",0)
	zd.initSet(obj,"leftgx",0)
	zd.initSet(obj,"ltime",maker.SCT_CdLabel())
	zd.initSet(obj,"material",0)
	zd.initSet(obj,"noteNews1",0)
	zd.initSet(obj,"noteNews2",0)
	zd.initSet(obj,"noteNews3",0)
	zd.initSet(obj,"post",0)
	return obj
end

maker.SCT_Sc_OrderTest = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dc",0)
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_FuserData = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"beijing",0)
	zd.initSet(obj,"bmap",0)
	zd.initSet(obj,"chatFrame",0)
	zd.initSet(obj,"chenghao",0)
	zd.initSet(obj,"chlist",zd.makeDataArray(maker.SCT_Schlist(),"id"))
	zd.initSet(obj,"clubid",0)
	zd.initSet(obj,"clubname","")
	zd.initSet(obj,"dress",0)
	zd.initSet(obj,"duanwei",0)
	zd.initSet(obj,"ep","FourEp")
	zd.initSet(obj,"exp",0)
	zd.initSet(obj,"extra_ch","")
	zd.initSet(obj,"guajian",0)
	zd.initSet(obj,"head",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"job",1)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"love",0)
	zd.initSet(obj,"maxmap",0)
	zd.initSet(obj,"mingrenchenghao",0)
	zd.initSet(obj,"mmap",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"riskexp",0)
	zd.initSet(obj,"risklevel",0)
	zd.initSet(obj,"set",0)
	zd.initSet(obj,"setFrame",0)
	zd.initSet(obj,"setcar",0)
	zd.initSet(obj,"sex",1)
	zd.initSet(obj,"shice",maker.SCT_SC_shice())
	zd.initSet(obj,"shili",0)
	zd.initSet(obj,"signName","")
	zd.initSet(obj,"smap",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"vip",0)
	zd.initSet(obj,"vipStatus",1)
	zd.initSet(obj,"xuanyan","")
	zd.initSet(obj,"yh",1)
	return obj
end

maker.SCT_CS_hd745play = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"offer",zd.makeDataArray(maker.SCT_hd745playparams(),"id"))
	return obj
end

maker.SCT_CxshdInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",maker.SCT_Null())
	return obj
end

maker.SCT_ParamId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SC_houseHoldReset = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_KuaMineOccupy = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"heros",zd.makeDataArray(maker.SCT_KuaMineOccupyHero()))
	zd.initSet(obj,"key",0)
	return obj
end

maker.SCT_VipRwdInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"is_recieve",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"tiptype",0)
	return obj
end

maker.SCT_CSselectBuild = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"build",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_ScTansuoLog = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"eid",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_rwdItems()))
	return obj
end

maker.SCT_SystemIntro = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"text","")
	return obj
end

maker.SCT_SbossInfo1 = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hp",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"ltime",maker.SCT_CdLabel())
	zd.initSet(obj,"money",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SchoolOver = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_HbmyRedList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"stime",0)
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_CS_Ranking = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"heroMobai",maker.SCT_Hid())
	zd.initSet(obj,"heroPaihang",maker.SCT_Hid())
	zd.initSet(obj,"mobai",maker.SCT_MoBai())
	zd.initSet(obj,"paihang",maker.SCT_RfPaiHang())
	return obj
end

maker.SCT_SC_FourGoodBuyLevelCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"accu",0)
	zd.initSet(obj,"lv",0)
	zd.initSet(obj,"max",0)
	zd.initSet(obj,"price",0)
	return obj
end

maker.SCT_FuserDataHeroWife = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hero",zd.makeDataArray(maker.SCT_FuserDataHero()))
	zd.initSet(obj,"wife",zd.makeDataArray("FuserDataWife"))
	return obj
end

maker.SCT_MoBaiMsg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"clubKua",0)
	zd.initSet(obj,"diwang",0)
	zd.initSet(obj,"guanka",0)
	zd.initSet(obj,"heroKua",0)
	zd.initSet(obj,"jiangxiang",0)
	zd.initSet(obj,"liangchen",0)
	zd.initSet(obj,"love",0)
	zd.initSet(obj,"shili",0)
	zd.initSet(obj,"shiliKua",0)
	return obj
end

maker.SCT_Clogin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"lang","")
	zd.initSet(obj,"platform","")
	return obj
end

maker.SCT_MsmyScore = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"myScore",0)
	zd.initSet(obj,"myScorerank",0)
	zd.initSet(obj,"myZj",0)
	return obj
end

maker.SCT_ShopGiftList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"image",0)
	zd.initSet(obj,"islimit",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"limit",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"need",0)
	zd.initSet(obj,"price",0)
	zd.initSet(obj,"vip",0)
	return obj
end

maker.SCT_pt_list = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type","")
	return obj
end

maker.SCT_FundFuliRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CS_User = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"adok",maker.SCT_labelId())
	zd.initSet(obj,"backJob",maker.SCT_Null())
	zd.initSet(obj,"bpve",maker.SCT_Null())
	zd.initSet(obj,"buildAllPai",maker.SCT_CSbuildAllPai())
	zd.initSet(obj,"buildInfo",maker.SCT_CSbuildUnlock())
	zd.initSet(obj,"buildPai",maker.SCT_CSbuildPai())
	zd.initSet(obj,"buildShou",maker.SCT_CSbuildShou())
	zd.initSet(obj,"buildUnlock",maker.SCT_CSbuildUnlock())
	zd.initSet(obj,"buildUnlockAll",maker.SCT_Null())
	zd.initSet(obj,"buildUp",maker.SCT_CSbuildUp())
	zd.initSet(obj,"callBackHero",maker.SCT_CScallBackHero())
	zd.initSet(obj,"changeHuodongState",maker.SCT_CS_PlayModuleStory())
	zd.initSet(obj,"changeState",maker.SCT_CS_PlayModuleStory())
	zd.initSet(obj,"cityNews",maker.SCT_Null())
	zd.initSet(obj,"cleanDressNews",maker.SCT_cleanDressNewsType())
	zd.initSet(obj,"clearBigEmojiNews",maker.SCT_CS_clearBigEmojiNews())
	zd.initSet(obj,"clearNewsChatFrame",maker.SCT_SclearNewsChatFrame())
	zd.initSet(obj,"comeBatchBack",maker.SCT_Null())
	zd.initSet(obj,"comeback",maker.SCT_heroId())
	zd.initSet(obj,"entergk",maker.SCT_Null())
	zd.initSet(obj,"getChatFrame",maker.SCT_Null())
	zd.initSet(obj,"getFuserBeast",maker.SCT_UserId())
	zd.initSet(obj,"getFuserHero",maker.SCT_FuidHid())
	zd.initSet(obj,"getFuserHeroWife",maker.SCT_UserId())
	zd.initSet(obj,"getFuserHeros",maker.SCT_UserId())
	zd.initSet(obj,"getFuserMember",maker.SCT_UserId())
	zd.initSet(obj,"getFuserWifes",maker.SCT_UserId())
	zd.initSet(obj,"getGuideRwd",maker.SCT_CS_getGuideRwd())
	zd.initSet(obj,"getInheritID",maker.SCT_Null())
	zd.initSet(obj,"getOfflineProfit","")
	zd.initSet(obj,"getSocialDress",maker.SCT_Null())
	zd.initSet(obj,"getUFrame",maker.SCT_Null())
	zd.initSet(obj,"get_cj",maker.SCT_SSetuback())
	zd.initSet(obj,"getcarback",maker.SCT_Null())
	zd.initSet(obj,"getfcmTips",maker.SCT_Null())
	zd.initSet(obj,"getuback",maker.SCT_Null())
	zd.initSet(obj,"getucityscene",maker.SCT_Null())
	zd.initSet(obj,"jingYing",maker.SCT_jingYingId())
	zd.initSet(obj,"jingYingAll",maker.SCT_Null())
	zd.initSet(obj,"jingYingLing",maker.SCT_jingYingIdCount())
	zd.initSet(obj,"maxmap",0)
	zd.initSet(obj,"modifyPwd",maker.SCT_ModifyPwd())
	zd.initSet(obj,"onekey_msg",maker.SCT_Null())
	zd.initSet(obj,"onekey_pve",maker.SCT_Null())
	zd.initSet(obj,"onekey_pve_h5",maker.SCT_Null())
	zd.initSet(obj,"pvb",maker.SCT_heroId())
	zd.initSet(obj,"pvb2",maker.SCT_Null())
	zd.initSet(obj,"pve",maker.SCT_Null())
	zd.initSet(obj,"qzam",maker.SCT_Null())
	zd.initSet(obj,"randName",maker.SCT_Null())
	zd.initSet(obj,"receiveOfflineProfit","")
	zd.initSet(obj,"refjingying",maker.SCT_Null())
	zd.initSet(obj,"refson",maker.SCT_Null())
	zd.initSet(obj,"refwife",maker.SCT_Null())
	zd.initSet(obj,"refxunfang",maker.SCT_Null())
	zd.initSet(obj,"resetImage",maker.SCT_UserImage())
	zd.initSet(obj,"resetName",maker.SCT_UserName())
	zd.initSet(obj,"setChatFrame",maker.SCT_SsetChatFrame())
	zd.initSet(obj,"setDress","CxghdPlay")
	zd.initSet(obj,"setFcmTime",maker.SCT_Null())
	zd.initSet(obj,"setFuserHwStatus",maker.SCT_Null())
	zd.initSet(obj,"setGuidePass",maker.SCT_CSSetGuidePass())
	zd.initSet(obj,"setInheritPwd",maker.SCT_setInheritPwd())
	zd.initSet(obj,"setJmSwitch",maker.SCT_idBase())
	zd.initSet(obj,"setLang",maker.SCT_CS_setLang())
	zd.initSet(obj,"setPanAn",maker.SCT_SetPanAn())
	zd.initSet(obj,"setSignName",maker.SCT_CS_setSignName())
	zd.initSet(obj,"setSocialDress",maker.SCT_SsetUSocialDress())
	zd.initSet(obj,"setUFrame",maker.SCT_SsetUFrame())
	zd.initSet(obj,"setUnNotify",maker.SCT_idBase())
	zd.initSet(obj,"setUserDress",maker.SCT_CSSetUserDress())
	zd.initSet(obj,"setUserInTime",maker.SCT_Null())
	zd.initSet(obj,"setUserInTime2",maker.SCT_Null())
	zd.initSet(obj,"setVipStatus",maker.SCT_idBase())
	zd.initSet(obj,"setcarback",maker.SCT_SSetuback())
	zd.initSet(obj,"setuback",maker.SCT_SSetuback())
	zd.initSet(obj,"setucityscene",maker.SCT_SSetuback())
	zd.initSet(obj,"setucityscenetx",maker.SCT_SSetubacktx())
	zd.initSet(obj,"shengguan",maker.SCT_Null())
	zd.initSet(obj,"syncCityAndGenerator",maker.SCT_cityAndGenId())
	zd.initSet(obj,"translate",maker.SCT_CS_UserTranslate())
	zd.initSet(obj,"unlockOfflineProfit","")
	zd.initSet(obj,"unsetDress",maker.SCT_Null())
	zd.initSet(obj,"vipExp",maker.SCT_Null())
	zd.initSet(obj,"yjZhengWu",maker.SCT_zhengWuAct())
	zd.initSet(obj,"zg_yjZhengWu",maker.SCT_zg_yjZhengWuAct())
	zd.initSet(obj,"zhengWu",maker.SCT_zhengWuAct())
	zd.initSet(obj,"zhengWuLing",maker.SCT_ItemCount())
	return obj
end

maker.SCT_CSplayNum = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_SC_MonthTaskInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"need",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"taskId",0)
	return obj
end

maker.SCT_ScTansuoMapList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cur",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_ChdList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",maker.SCT_Null())
	return obj
end

maker.SCT_CsTsType = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_Hbhblist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"exite",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"job",0)
	zd.initSet(obj,"lq_list",zd.makeDataArray(maker.SCT_HbGetHbList()))
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"name","")
	zd.initSet(obj,"sex",0)
	zd.initSet(obj,"stime",0)
	zd.initSet(obj,"total",0)
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_FuLiFchoDay = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	return obj
end

maker.SCT_FuidHid = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid",0)
	zd.initSet(obj,"hid",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_Sjjuser = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"regtime",0)
	zd.initSet(obj,"rwd",0)
	zd.initSet(obj,"tzstate",0)
	zd.initSet(obj,"tztime",0)
	return obj
end

maker.SCT_ClubCZHDUserRwdList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SbossList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",1)
	zd.initSet(obj,"gid",1)
	return obj
end

maker.SCT_RiskBosshp = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"damage",0)
	zd.initSet(obj,"heroid",0)
	return obj
end

maker.SCT_ParamHid = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hid",0)
	return obj
end

maker.SCT_GetTzrwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_giftInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dc",0)
	zd.initSet(obj,"gift_id",0)
	zd.initSet(obj,"is_free",0)
	zd.initSet(obj,"is_limit",0)
	zd.initSet(obj,"limit_num",0)
	zd.initSet(obj,"profit_percent",0)
	zd.initSet(obj,"rwd_items",zd.makeDataArray(maker.SCT_rwdItems()))
	zd.initSet(obj,"surplus_num",0)
	zd.initSet(obj,"title","")
	return obj
end

maker.SCT_QxUserFlower = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fid",0)
	return obj
end

maker.SCT_DailyRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"rwd",0)
	return obj
end

maker.SCT_Skuacbchat = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"gid",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"time",0)
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"user",maker.SCT_fUserInfo())
	return obj
end

maker.SCT_CShd912Buy = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_ancestralhallsonlist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"add",0)
	zd.initSet(obj,"honor",0)
	zd.initSet(obj,"jq",zd.makeDataArray(maker.SCT_jqInfo(),"id"))
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_Scbosspkwin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"gx",0)
	zd.initSet(obj,"hit",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	return obj
end

maker.SCT_hd709Num = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_SC_GameMachine = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_GameMachineInfo())
	zd.initSet(obj,"results",zd.makeDataArray(maker.SCT_GameMachineResult()))
	return obj
end

maker.SCT_ScKeatcp = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fhero",zd.makeDataArray(maker.SCT_khero()))
	zd.initSet(obj,"fwife",zd.makeDataArray(maker.SCT_kwife()))
	return obj
end

maker.SCT_OneBuyInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"islimit",0)
	zd.initSet(obj,"item",maker.SCT_ItemInfo())
	zd.initSet(obj,"limit",0)
	zd.initSet(obj,"need",0)
	zd.initSet(obj,"price",0)
	zd.initSet(obj,"vip",0)
	return obj
end

maker.SCT_jxhscheckchat = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_MineId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"mineId",0)
	return obj
end

maker.SCT_FuserStatus = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"status",0)
	return obj
end

maker.SCT_LaoFangZombie = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"skill",zd.makeDataArray(maker.SCT_ZombieSkill()))
	return obj
end

maker.SCT_SC_redpackethuodonginfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"heaven",zd.makeDataArray("SC_redpacketheaven","id"))
	zd.initSet(obj,"info",maker.SCT_Shdinfo())
	zd.initSet(obj,"jindu",zd.makeDataArray("SC_redpacketfuka","id"))
	return obj
end

maker.SCT_CsRiskNpcarriveCoord = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"mx",0)
	zd.initSet(obj,"my",0)
	zd.initSet(obj,"resID",0)
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"x",0)
	zd.initSet(obj,"y",0)
	return obj
end

maker.SCT_UserPvbWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bmid",0)
	zd.initSet(obj,"damage",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	return obj
end

maker.SCT_SCDllhdCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"need",maker.SCT_ItemInfo())
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_SCDllhdCfgRwd()))
	return obj
end

maker.SCT_ChatIdJingcheng = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_KuaMineOccupyHero = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fbHid",0)
	zd.initSet(obj,"hid",0)
	zd.initSet(obj,"itemId",0)
	zd.initSet(obj,"no",0)
	return obj
end

maker.SCT_WinRandWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"items",maker.SCT_RandWin())
	return obj
end

maker.SCT_fbshareinfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"get",0)
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	return obj
end

maker.SCT_CSqxzbHero = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"heroId",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"turn",0)
	return obj
end

maker.SCT_CShd431Get = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_bossHp = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hp",0)
	return obj
end

maker.SCT_CsRiskjumpSpecialMap = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"mid",0)
	return obj
end

maker.SCT_NewYearFight = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hurt",0)
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_MyRedTicketList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"etime",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"money",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"stime",0)
	return obj
end

maker.SCT_SC_LlbkCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_Shdinfo())
	return obj
end

maker.SCT_SC_System = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cp",maker.SCT_SC_System_cp())
	zd.initSet(obj,"error",maker.SCT_errMsg())
	zd.initSet(obj,"history_server_list",zd.makeDataArray(maker.SCT_hisServerInfo(),"id"))
	zd.initSet(obj,"intro",maker.SCT_SystemIntro())
	zd.initSet(obj,"itemLack",maker.SCT_SC_itemLack())
	zd.initSet(obj,"mse",maker.SCT_mseInfo())
	zd.initSet(obj,"notice",zd.makeDataArray(maker.SCT_NoticeMsg()))
	zd.initSet(obj,"randName",maker.SCT_RandName())
	zd.initSet(obj,"recommend_list",zd.makeDataArray(0))
	zd.initSet(obj,"server_info",zd.makeDataArray(maker.SCT_ServerInfo(),"id"))
	zd.initSet(obj,"server_list",zd.makeDataArray(maker.SCT_Server(),"id"))
	zd.initSet(obj,"sys",maker.SCT_SysDate())
	zd.initSet(obj,"time_zone",0)
	zd.initSet(obj,"version","")
	zd.initSet(obj,"white",0)
	zd.initSet(obj,"window",maker.SCT_SCSystemNotice())
	zd.initSet(obj,"zone_list",zd.makeDataArray(maker.SCT_zoneInfo()))
	return obj
end

maker.SCT_SC_MonthTaskRwdType = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_SC_XianShi = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"clubbossdmg",maker.SCT_XianShiAct())
	zd.initSet(obj,"clubbosskill",maker.SCT_XianShiAct())
	zd.initSet(obj,"goeat",maker.SCT_XianShiAct())
	zd.initSet(obj,"killg2d",maker.SCT_XianShiAct())
	zd.initSet(obj,"loginday",maker.SCT_XianShiAct())
	zd.initSet(obj,"shiliup",maker.SCT_XianShiAct())
	zd.initSet(obj,"usebook",maker.SCT_XianShiAct())
	zd.initSet(obj,"usecash",maker.SCT_XianShiAct())
	return obj
end

maker.SCT_CHlist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"checked",0)
	zd.initSet(obj,"chid",0)
	zd.initSet(obj,"endT",0)
	zd.initSet(obj,"getT",0)
	return obj
end

maker.SCT_FBshareGetrwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_HbmyRedTicket = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_MyRedTicketList(),"id"))
	zd.initSet(obj,"money",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_ItemInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",1)
	zd.initSet(obj,"id","")
	zd.initSet(obj,"label",0)
	return obj
end

maker.SCT_SC_centralattackwarlog = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"city",0)
	zd.initSet(obj,"fname","")
	zd.initSet(obj,"fuid",0)
	zd.initSet(obj,"keng",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"time",0)
	zd.initSet(obj,"uid",0)
	zd.initSet(obj,"win",0)
	return obj
end

maker.SCT_CS_clearBigEmojiNews = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CS_HerobindHero = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bindhid",0)
	zd.initSet(obj,"hid",0)
	return obj
end

maker.SCT_Hid = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hid",0)
	return obj
end

maker.SCT_SC_Story = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"heroFavor",zd.makeDataArray("SC_StoryHeroFavor"))
	zd.initSet(obj,"npcFavor",zd.makeDataArray("SC_StoryNpcFavor"))
	zd.initSet(obj,"storyBtn",zd.makeDataArray("SC_StoryStoryBtn"))
	zd.initSet(obj,"storyUnlock","SC_StoryStoryUnlock")
	zd.initSet(obj,"wifeFavor",zd.makeDataArray("SC_StoryWifeFavor"))
	return obj
end

maker.SCT_CYhChi = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid",0)
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"xwid",0)
	return obj
end

maker.SCT_SC_hbhuodong = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hbInfo",maker.SCT_Hbhblist())
	zd.initSet(obj,"hblist",zd.makeDataArray(maker.SCT_Hbhblist()))
	zd.initSet(obj,"lastHb",maker.SCT_HblastHb())
	zd.initSet(obj,"mobai",maker.SCT_Hbmobai())
	zd.initSet(obj,"myRedList",zd.makeDataArray(maker.SCT_HbmyRedList()))
	zd.initSet(obj,"myRedTicket",maker.SCT_HbmyRedTicket())
	zd.initSet(obj,"myScore","XgMyScore")
	zd.initSet(obj,"rankList",zd.makeDataArray(maker.SCT_fUserInfo(),"id"))
	zd.initSet(obj,"receiveRedList",zd.makeDataArray(maker.SCT_HbreceiveRedList()))
	return obj
end

maker.SCT_CS_sevendaytask = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_Null())
	zd.initSet(obj,"rwd",maker.SCT_cs_sevendaytask_rwd())
	zd.initSet(obj,"rwd_final",maker.SCT_Null())
	return obj
end

maker.SCT_GuideNotic = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"platform","")
	return obj
end

maker.SCT_CsRiskOperate = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"reserve",0)
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"x",0)
	zd.initSet(obj,"y",0)
	return obj
end

maker.SCT_heroId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_ryqdShopAndList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"list",zd.makeDataArray("ExchangeList","id"))
	zd.initSet(obj,"shop",zd.makeDataArray(maker.SCT_ryqdShop(),"id"))
	return obj
end

maker.SCT_survey_question = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"A","")
	zd.initSet(obj,"B","")
	zd.initSet(obj,"C","")
	zd.initSet(obj,"D","")
	zd.initSet(obj,"have",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"must",0)
	zd.initSet(obj,"problem","")
	return obj
end

maker.SCT_Shdrwd1 = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"need",0)
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_WordShopId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_KefuInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"body","")
	return obj
end

maker.SCT_SetPanAn = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"win",0)
	return obj
end

maker.SCT_SC_LlbkStarLog = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"itemid",0)
	zd.initSet(obj,"kind",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_CDelClub = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"password",0)
	return obj
end

maker.SCT_CShd332Buy = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_Csczhlinfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"allmoney",0)
	zd.initSet(obj,"allrwd",zd.makeDataArray(maker.SCT_cznhlallrwd()))
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"chongzhi",zd.makeDataArray(maker.SCT_CSCzhl()))
	zd.initSet(obj,"eTime",0)
	zd.initSet(obj,"endtime",0)
	zd.initSet(obj,"rwd",zd.makeDataArray("czhlrwd"))
	zd.initSet(obj,"sTime",0)
	return obj
end

maker.SCT_IDNUM = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",1)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_ParamWid = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"wid",0)
	return obj
end

maker.SCT_CS_GuideButton = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"opt","")
	return obj
end

maker.SCT_CS_BeiJing = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"checkBeiJing",maker.SCT_ChHaoId())
	zd.initSet(obj,"offBeiJing",maker.SCT_ChHaoId())
	zd.initSet(obj,"setBeiJing",maker.SCT_ChHaoId())
	return obj
end

maker.SCT_ZQCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cz_money",0)
	zd.initSet(obj,"exchange",zd.makeDataArray("ExchangeList","id"))
	zd.initSet(obj,"rand_get",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"recover_money",0)
	zd.initSet(obj,"rwd","NewYearrwdType")
	zd.initSet(obj,"seek_need",0)
	zd.initSet(obj,"seek_prob_rand",zd.makeDataArray(maker.SCT_ZQCfgUseSeekRrobRand(),"id"))
	zd.initSet(obj,"seek_rwd",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"shop",zd.makeDataArray("Shopxg","id"))
	zd.initSet(obj,"today",maker.SCT_CdLabel())
	zd.initSet(obj,"use",zd.makeDataArray(maker.SCT_ZQCfgUse(),"id"))
	return obj
end

maker.SCT_ZQUser = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cz_money",0)
	zd.initSet(obj,"cz_rwd",0)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"exchange",zd.makeDataArray(maker.SCT_QxUserExchange(),"id"))
	zd.initSet(obj,"hd_score",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_QxUserExchange(),"id"))
	zd.initSet(obj,"login",0)
	zd.initSet(obj,"lq",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"rabbit",0)
	zd.initSet(obj,"recharge",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"shop",zd.makeDataArray(maker.SCT_QxUserExchange(),"id"))
	zd.initSet(obj,"wife",0)
	return obj
end

maker.SCT_SC_centralattackherolist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"add",0)
	zd.initSet(obj,"addshili",0)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"hid",0)
	zd.initSet(obj,"shili",0)
	return obj
end

maker.SCT_ScHunting = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"cnum",0)
	zd.initSet(obj,"free",0)
	zd.initSet(obj,"hnum",0)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_HuntList(),"id"))
	zd.initSet(obj,"need",0)
	zd.initSet(obj,"rwd",maker.SCT_HuntRwd())
	return obj
end

maker.SCT_Ssltip = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid",0)
	return obj
end

maker.SCT_CsRiskStory = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_riskLevelInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"exp",0)
	zd.initSet(obj,"level",0)
	return obj
end

maker.SCT_SCclubKuapkzr = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"diclub",maker.SCT_SCclubKuaCszr())
	zd.initSet(obj,"myclub",maker.SCT_SCclubKuaCszr())
	return obj
end

maker.SCT_cleanDressNewsType = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CS_Share = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"shared",maker.SCT_NULL())
	return obj
end

maker.SCT_SC_guideConsume = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_SC_guideConsumeInfo())
	return obj
end

maker.SCT_ryqdShop = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"is_limit",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"limit",0)
	zd.initSet(obj,"need",maker.SCT_ItemInfo())
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"sevid",0)
	return obj
end

maker.SCT_SCChatFramelist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdNum())
	zd.initSet(obj,"get",1)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"news",0)
	return obj
end

maker.SCT_CSkuaPKCszr = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid",maker.SCT_Null())
	return obj
end

maker.SCT_CardType = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"days",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CsTsGiveup = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"gid",0)
	return obj
end

maker.SCT_ItemCount = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"num",1)
	return obj
end

maker.SCT_SC_FourGoodRwdLevel = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_RiskFollow = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_idBase = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_BanishHeroList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hid",0)
	return obj
end

maker.SCT_CtestOrderBack = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",maker.SCT_Null())
	return obj
end

maker.SCT_CJlInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",maker.SCT_Null())
	return obj
end

maker.SCT_cs_sevendaytask_rwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_sc_sevendaytask_info = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_sc_sevendaytask_list(),"新角色七天任务数据列表"))
	zd.initSet(obj,"over",0)
	zd.initSet(obj,"rwd_final",0)
	zd.initSet(obj,"tip",0)
	return obj
end

maker.SCT_CS_hd552Dispatch = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"city",0)
	zd.initSet(obj,"fuid",0)
	zd.initSet(obj,"heros","")
	zd.initSet(obj,"keng",0)
	zd.initSet(obj,"team",0)
	return obj
end

maker.SCT_CS_HD496BuyLv = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"lv",0)
	return obj
end

maker.SCT_ChHaoId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"chid",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CShd344Validate = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"code",0)
	zd.initSet(obj,"phone",0)
	return obj
end

maker.SCT_fUserqjlist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"chatFrame",0)
	zd.initSet(obj,"chenghao",0)
	zd.initSet(obj,"dress",0)
	zd.initSet(obj,"frame",0)
	zd.initSet(obj,"head",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"job",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"num2",0)
	zd.initSet(obj,"num3",0)
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"sex",0)
	zd.initSet(obj,"signName","")
	zd.initSet(obj,"tip",0)
	zd.initSet(obj,"uid",0)
	zd.initSet(obj,"vip",0)
	zd.initSet(obj,"vipStatus",1)
	return obj
end

maker.SCT_SkinId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CS_Hd760Rank = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CS_Login_getHistory = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"openid","")
	zd.initSet(obj,"platform","")
	return obj
end

maker.SCT_CRand = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"CRand",maker.SCT_Null())
	return obj
end

maker.SCT_CSqxzbCszr = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"turn",0)
	return obj
end

maker.SCT_InviteCfgInvite = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"limit",0)
	zd.initSet(obj,"link","")
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_ItemInfo()))
	return obj
end

maker.SCT_SC_opentip = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"open",0)
	zd.initSet(obj,"unlock",0)
	return obj
end

maker.SCT_SC_Mail = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"mailList",zd.makeDataArray(maker.SCT_MailInfo(),"id"))
	return obj
end

maker.SCT_CsTsGetRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_zhuchenginfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"boite",0)
	zd.initSet(obj,"cabinet",0)
	zd.initSet(obj,"club",0)
	zd.initSet(obj,"courtyard",0)
	zd.initSet(obj,"hanlin",0)
	zd.initSet(obj,"laofang",0)
	zd.initSet(obj,"wordboss",0)
	zd.initSet(obj,"yamen",0)
	return obj
end

maker.SCT_RandName = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"name","")
	return obj
end

maker.SCT_heroSkillIdType = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"sid",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_scqian = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"valid",0)
	return obj
end

maker.SCT_FuLiFChoClose = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"noShow",0)
	return obj
end

maker.SCT_RiskMap = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"x",0)
	zd.initSet(obj,"y",0)
	return obj
end

maker.SCT_MailInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"content","")
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfox(),"idx"))
	zd.initSet(obj,"sendTime",0)
	zd.initSet(obj,"status",0)
	zd.initSet(obj,"title","")
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SC_itemLack = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"kind",0)
	return obj
end

maker.SCT_SeverInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"isHe",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"sid",0)
	return obj
end

maker.SCT_CsCourtyardExchange = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_makeSkin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"makeHeroList",zd.makeDataArray(maker.SCT_makeSkinList(),"id"))
	zd.initSet(obj,"makeWifeList",zd.makeDataArray(maker.SCT_makeSkinList(),"id"))
	return obj
end

maker.SCT_SCmyClubRid = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cName","")
	zd.initSet(obj,"cRid",0)
	return obj
end

maker.SCT_SC_fbhuodong = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fbshareinfo",maker.SCT_fbshareinfo())
	return obj
end

maker.SCT_SysDate = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"nextday",0)
	zd.initSet(obj,"time",0)
	return obj
end

maker.SCT_SCJhlist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdNum())
	zd.initSet(obj,"get",1)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_MapInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bgimg",1)
	zd.initSet(obj,"title","")
	return obj
end

maker.SCT_SC_MsgWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fight",maker.SCT_FightWin())
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"newnpc",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"pet","PetInfo")
	zd.initSet(obj,"vip",0)
	return obj
end

maker.SCT_ClubCZHDCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_Shdrwd()))
	return obj
end

maker.SCT_ItemInfox = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",1)
	zd.initSet(obj,"id","")
	zd.initSet(obj,"idx","")
	return obj
end

maker.SCT_autumnuser = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bag",maker.SCT_ItemInfo())
	zd.initSet(obj,"buynum",0)
	zd.initSet(obj,"curhdscore",0)
	zd.initSet(obj,"hdscore",0)
	return obj
end

maker.SCT_fUserInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"beijing",0)
	zd.initSet(obj,"chatFrame",0)
	zd.initSet(obj,"chenghao",0)
	zd.initSet(obj,"clubname","")
	zd.initSet(obj,"dress",0)
	zd.initSet(obj,"duanwei",0)
	zd.initSet(obj,"extra_ch","")
	zd.initSet(obj,"frame",0)
	zd.initSet(obj,"guajian",0)
	zd.initSet(obj,"head",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"isHe",0)
	zd.initSet(obj,"job",0)
	zd.initSet(obj,"lastlogin",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"maxmap",0)
	zd.initSet(obj,"mingrenchenghao",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"num2",0)
	zd.initSet(obj,"num3",0)
	zd.initSet(obj,"num4","")
	zd.initSet(obj,"offlineCh","")
	zd.initSet(obj,"password","")
	zd.initSet(obj,"pet_addi",0)
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"riskexp",0)
	zd.initSet(obj,"risklevel",0)
	zd.initSet(obj,"sex",0)
	zd.initSet(obj,"shili",0)
	zd.initSet(obj,"signName","")
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"uid",0)
	zd.initSet(obj,"vip",0)
	zd.initSet(obj,"vipStatus",1)
	return obj
end

maker.SCT_OldPlayerBackRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_scfashionpreviewCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"shizhuang","")
	zd.initSet(obj,"touxiang","")
	return obj
end

maker.SCT_RiskUpBaoZang = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"x",0)
	zd.initSet(obj,"y",0)
	return obj
end

maker.SCT_SC_ComRankRange = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"re",0)
	zd.initSet(obj,"rs",0)
	return obj
end

maker.SCT_PlatGiftNotice = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"result",0)
	zd.initSet(obj,"win",maker.SCT_SC_Windows())
	return obj
end

maker.SCT_hd238BuyParams = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_ClubCZHDClub = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_SC_WifePk = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day","SC_WifePk_Day")
	zd.initSet(obj,"finfo",maker.SCT_SC_WifePk_wife_finfo())
	zd.initSet(obj,"flist",zd.makeDataArray("SC_WifePk_wife_list","id"))
	zd.initSet(obj,"info","SC_WifePk_Info")
	zd.initSet(obj,"killlog",zd.makeDataArray("Sc_WifePk_killlog","id"))
	zd.initSet(obj,"myRid",maker.SCT_Scbrid())
	zd.initSet(obj,"rank",zd.makeDataArray(maker.SCT_Scblist(),"id"))
	zd.initSet(obj,"result",maker.SCT_Scwifepkresult())
	zd.initSet(obj,"shop","SC_WifePk_Shop")
	return obj
end

maker.SCT_CSkuaPKusejn = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"heroid",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CS_setSignName = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"text","")
	return obj
end

maker.SCT_CDayGongXian = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dcid",0)
	zd.initSet(obj,"free",0)
	return obj
end

maker.SCT_csBuildGivup = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buildingId",0)
	zd.initSet(obj,"buildingLevel",0)
	zd.initSet(obj,"locationId",0)
	return obj
end

maker.SCT_HuntList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"baseRwd",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"eTime",0)
	zd.initSet(obj,"heroes",zd.makeDataArray("cabinetHeroes","id"))
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"nature",0)
	zd.initSet(obj,"randRwd",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"require",0)
	zd.initSet(obj,"sTime",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"time",0)
	zd.initSet(obj,"use",maker.SCT_ItemInfo())
	return obj
end

maker.SCT_csBuildRevenge = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buildingId",0)
	zd.initSet(obj,"buildingLevel",0)
	zd.initSet(obj,"heros",zd.makeDataArray(maker.SCT_KuaMineOccupyHero()))
	zd.initSet(obj,"locationId",0)
	zd.initSet(obj,"logId",0)
	return obj
end

maker.SCT_SC_LlbkInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cardID",0)
	zd.initSet(obj,"luckyDraw",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_RandWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	return obj
end

maker.SCT_SCclubKuaWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid",0)
	zd.initSet(obj,"fcid",0)
	zd.initSet(obj,"fname","")
	zd.initSet(obj,"gejifen",0)
	zd.initSet(obj,"isWin",0)
	zd.initSet(obj,"name","")
	return obj
end

maker.SCT_Sc_survey = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"SurveyInfo",maker.SCT_SurveyInfo())
	return obj
end

maker.SCT_SyhInfo2 = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cashFyNum",0)
	zd.initSet(obj,"credit",0)
	zd.initSet(obj,"dress",0)
	zd.initSet(obj,"ep",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"invite",0)
	zd.initSet(obj,"job",1)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"list",zd.makeDataArray("xwInfo2","id"))
	zd.initSet(obj,"lockTime",maker.SCT_CdLabel())
	zd.initSet(obj,"ltime",maker.SCT_CdLabel())
	zd.initSet(obj,"maxnum",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"sex",1)
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_SConekeybmap = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"need",0)
	zd.initSet(obj,"time",0)
	zd.initSet(obj,"yub",0)
	return obj
end

maker.SCT_CShd913type = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_UserInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cash",0)
	zd.initSet(obj,"exp",0)
	zd.initSet(obj,"guide",0)
	zd.initSet(obj,"guideSub",0)
	zd.initSet(obj,"language","")
	zd.initSet(obj,"lastLogin",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"music",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"regTime",0)
	zd.initSet(obj,"step",0)
	zd.initSet(obj,"uid",0)
	zd.initSet(obj,"vip",0)
	zd.initSet(obj,"vipExp",0)
	zd.initSet(obj,"voice",0)
	return obj
end

maker.SCT_CShd434AddBless = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bless","")
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SC_System_cp = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"force",0)
	zd.initSet(obj,"link","")
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"tag","")
	return obj
end

maker.SCT_GerdanRankRwdWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"kill",3)
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"score2",0)
	return obj
end

maker.SCT_SC_bigEmojiidlist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_Hd331getPaghang = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",1)
	return obj
end

maker.SCT_SC_fashionpreview = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fashionpreviewCfg",maker.SCT_scfashionpreviewCfg())
	return obj
end

maker.SCT_SCPoolHuodongCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"base","SCDrawHuodongCfgBase")
	zd.initSet(obj,"card",zd.makeDataArray("SCDrawHuodongCfgCard"))
	zd.initSet(obj,"money",0)
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"recharge",zd.makeDataArray("SCDrawHuodongCfgRecharge"))
	return obj
end

maker.SCT_FightMember = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"army",1000)
	zd.initSet(obj,"army_max",10000)
	zd.initSet(obj,"army_type","npc1")
	zd.initSet(obj,"coin",100)
	zd.initSet(obj,"die",1000)
	zd.initSet(obj,"e1",100)
	zd.initSet(obj,"e2",100)
	zd.initSet(obj,"index",1)
	zd.initSet(obj,"itype",1)
	zd.initSet(obj,"level",1)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"user",maker.SCT_fUserInfo())
	return obj
end

maker.SCT_joinInfos = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"credit",0)
	zd.initSet(obj,"fuid",0)
	zd.initSet(obj,"score",0)
	return obj
end

maker.SCT_SSetuback = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CYhGo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid",0)
	return obj
end

maker.SCT_hd850AnswerInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"option",0)
	return obj
end

maker.SCT_ItemInfoTip = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"kind",0)
	zd.initSet(obj,"tip",0)
	return obj
end

maker.SCT_BHCZHDUser = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cz",zd.makeDataArray(maker.SCT_BHCZHDUserCz()))
	zd.initSet(obj,"inday",0)
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_BHCZHDUserRwd()))
	zd.initSet(obj,"today",0)
	return obj
end

maker.SCT_SC_Translate = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"result",maker.SCT_SC_TranslateResult())
	return obj
end

maker.SCT_CS_Story = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"chooseStory",maker.SCT_CS_ChooseStory())
	zd.initSet(obj,"clickBtn",maker.SCT_CS_StoryClickBtn())
	zd.initSet(obj,"readStory",maker.SCT_CS_StoryReadStory())
	return obj
end

maker.SCT_CdjyNum = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"label","")
	zd.initSet(obj,"max",0)
	zd.initSet(obj,"next",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_CS_Hd650fGroupBuy = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SC_sevendaytask = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_sc_sevendaytask_info())
	return obj
end

maker.SCT_SReadJfStory = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"chapter",0)
	zd.initSet(obj,"middle",0)
	zd.initSet(obj,"point",0)
	return obj
end

maker.SCT_CClubBosslog = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_WordMyScore = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"myScore",0)
	zd.initSet(obj,"myScorerank",0)
	return obj
end

maker.SCT_SC_wannengShop = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_wannengInfo())
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_wannengShopList(),"id"))
	return obj
end

maker.SCT_CClubBossPK = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cbid",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_hd709ExchangeParams = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CRandomChi = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SC_WordBoss = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"g2dft",zd.makeDataArray(maker.SCT_FightList(),"id"))
	zd.initSet(obj,"g2dkill",zd.makeDataArray(maker.SCT_fUserInfo(),"id"))
	zd.initSet(obj,"ge2dan",maker.SCT_WBGe2Dan())
	zd.initSet(obj,"ge2danMyDmg",maker.SCT_WordG2dMyDmgRk())
	zd.initSet(obj,"hurtRank",zd.makeDataArray(maker.SCT_fUserInfo(),"id"))
	zd.initSet(obj,"menggu",maker.SCT_WBMengGu())
	zd.initSet(obj,"mgft",zd.makeDataArray(maker.SCT_FightList(),"id"))
	zd.initSet(obj,"myScore",maker.SCT_WordMyScore())
	zd.initSet(obj,"root",maker.SCT_WordBossRoot())
	zd.initSet(obj,"rwdLog",zd.makeDataArray(maker.SCT_fUserInfo(),"id"))
	zd.initSet(obj,"scoreRank",zd.makeDataArray(maker.SCT_fUserInfo(),"id"))
	zd.initSet(obj,"shop",maker.SCT_WordShop())
	zd.initSet(obj,"win",maker.SCT_WordBossWin())
	return obj
end

maker.SCT_HitgerdanWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"damage",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"score2",0)
	return obj
end

maker.SCT_RfPaiHang = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CS_hd552GetZhen = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"city",0)
	zd.initSet(obj,"keng",0)
	return obj
end

maker.SCT_IdAuthen = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cardid","")
	zd.initSet(obj,"name","")
	zd.initSet(obj,"openid","")
	zd.initSet(obj,"platform","")
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_BHCZUIDINFO = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cons",0)
	zd.initSet(obj,"cztime",0)
	zd.initSet(obj,"post",4)
	zd.initSet(obj,"username","")
	return obj
end

maker.SCT_ladder_gongxun = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hdscore",0)
	zd.initSet(obj,"jifen",0)
	zd.initSet(obj,"score",0)
	return obj
end

maker.SCT_CsRiskRecover = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_hd745playparams = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_QxWinLamp = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"content","")
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_SCjuece = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"content","")
	return obj
end

maker.SCT_ScTansuoSJList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"eid",0)
	zd.initSet(obj,"gid","")
	zd.initSet(obj,"hitTime",0)
	zd.initSet(obj,"hp",0)
	zd.initSet(obj,"time",0)
	return obj
end

maker.SCT_mobiles = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg",maker.SCT_mobilelist())
	return obj
end

maker.SCT_hd699checkChatByType = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_zpfluser = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"isdraw",1)
	zd.initSet(obj,"isswitch",2)
	zd.initSet(obj,"pt_last",maker.SCT_pt_list())
	zd.initSet(obj,"pt_num",0)
	zd.initSet(obj,"zj_prize",zd.makeDataArray(maker.SCT_zj_list()))
	return obj
end

maker.SCT_CxxlMove = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"map","")
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"score",0)
	return obj
end

maker.SCT_Scbrid = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cname","")
	zd.initSet(obj,"name","")
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"vip",0)
	return obj
end

maker.SCT_CXxInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",maker.SCT_Null())
	return obj
end

maker.SCT_CsRischoiceMakeTask = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"choice",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_UserJob = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"job",0)
	zd.initSet(obj,"sex",0)
	return obj
end

maker.SCT_zoneInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"down_url","")
	zd.initSet(obj,"name","")
	zd.initSet(obj,"test_tag",0)
	zd.initSet(obj,"time_zone",0)
	zd.initSet(obj,"url","")
	zd.initSet(obj,"zid",0)
	return obj
end

maker.SCT_ScTansuoCJ = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"rwd",0)
	return obj
end

maker.SCT_CsRiskBaoZangList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"zb",0)
	return obj
end

maker.SCT_CSbuildAllPai = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CsRiskDarts = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"mid",0)
	zd.initSet(obj,"x",0)
	zd.initSet(obj,"y",0)
	return obj
end

maker.SCT_KuaMineRevenge = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"heros",zd.makeDataArray(maker.SCT_KuaMineOccupyHero()))
	zd.initSet(obj,"logId",0)
	zd.initSet(obj,"mineId",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SC_Windows = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"content","")
	zd.initSet(obj,"foot","")
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"tiptype",0)
	zd.initSet(obj,"title","")
	return obj
end

maker.SCT_Shdrwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"jiazhi",0)
	zd.initSet(obj,"need",0)
	return obj
end

maker.SCT_SC_dxhuodong = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"user",maker.SCT_DxUser())
	return obj
end

maker.SCT_SCclubKuahit = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cname","")
	zd.initSet(obj,"isWin",0)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_SChitlist(),"id"))
	zd.initSet(obj,"servid",0)
	return obj
end

maker.SCT_all_answer = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id","")
	return obj
end

maker.SCT_CSbeamingBag = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_cs_getSkinshop = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"kind",0)
	zd.initSet(obj,"price",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_jdFuidHid = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid",0)
	zd.initSet(obj,"hid",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SC_Discord = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"status",0)
	zd.initSet(obj,"url","")
	return obj
end

maker.SCT_Chd297Guid = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid",0)
	return obj
end

maker.SCT_CxshdRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",maker.SCT_Null())
	return obj
end

maker.SCT_CS_HD496TaskWeek = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"week",0)
	return obj
end

maker.SCT_CSbuildPai = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"heroid",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"slot",0)
	return obj
end

maker.SCT_FuLiAddwxqq = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"host",maker.SCT_ItemInfo())
	zd.initSet(obj,"index",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"num","")
	return obj
end

maker.SCT_SCldjcbkhdUser = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_idBase()))
	zd.initSet(obj,"sign",0)
	return obj
end

maker.SCT_ChengJiuRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CS_ImgUploadFace = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"base64code","")
	return obj
end

maker.SCT_shopBuyNew = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_GameMachineTrain = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"position",0)
	return obj
end

maker.SCT_hd850TaskrewardInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_RiskCreateNpc = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"resID",0)
	zd.initSet(obj,"x",0)
	zd.initSet(obj,"y",0)
	return obj
end

maker.SCT_RiskDartsList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"gid",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"kind",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"win",0)
	return obj
end

maker.SCT_abcestralhallinto = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"honor",0)
	return obj
end

maker.SCT_HitG2dWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	return obj
end

maker.SCT_SC_ClubKuaYueInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cyzg",maker.SCT_SC_clubKuaYueCyzg())
	zd.initSet(obj,"isCy",0)
	zd.initSet(obj,"mobai",0)
	zd.initSet(obj,"mobaiMax",0)
	zd.initSet(obj,"next",0)
	zd.initSet(obj,"rwd",0)
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_MysteryOrder = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"exchangeCnt",0)
	zd.initSet(obj,"gid",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_jingYingIdCount = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"jyid",0)
	zd.initSet(obj,"num",1)
	return obj
end

maker.SCT_CInfoSaveNote = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"note","")
	zd.initSet(obj,"noteTitle","")
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_VerifySwitch = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"status",1)
	return obj
end

maker.SCT_CS_GameMachine = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"draw",maker.SCT_GameMachineDraw())
	zd.initSet(obj,"getInfo",maker.SCT_CustomId())
	return obj
end

maker.SCT_UserImage = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"job",1)
	zd.initSet(obj,"sex",1)
	return obj
end

maker.SCT_SCOffline = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"beforeDuration",zd.makeDataArray(maker.SCT_Duration()))
	zd.initSet(obj,"lastRewardTime",0)
	zd.initSet(obj,"privilege",0)
	zd.initSet(obj,"receiveDuration",zd.makeDataArray(maker.SCT_Duration()))
	zd.initSet(obj,"todayDuration",zd.makeDataArray(maker.SCT_Duration()))
	zd.initSet(obj,"todayGetDuration",0)
	zd.initSet(obj,"unlock",0)
	return obj
end

maker.SCT_Sxslchuodong = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg",maker.SCT_Scfglc())
	zd.initSet(obj,"cons",0)
	zd.initSet(obj,"has_rwd","")
	zd.initSet(obj,"rwd",0)
	return obj
end

maker.SCT_SCBuildHero = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"heroid",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SC_Daily = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dailysore_rwd",zd.makeDataArray(maker.SCT_Scdailysore_rwd()))
	zd.initSet(obj,"rwds",zd.makeDataArray(maker.SCT_DailyRwd(),"id"))
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"tasks",zd.makeDataArray(maker.SCT_DTask(),"id"))
	return obj
end

maker.SCT_ryqdCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_Shdinfo())
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_Scbhdrwd()))
	return obj
end

maker.SCT_errMsg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_FuLiTest_buy_decimal = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"rmb",0)
	return obj
end

maker.SCT_SC_chat_frame = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_SCChatFramelist(),"id"))
	zd.initSet(obj,"news",0)
	zd.initSet(obj,"set",0)
	return obj
end

maker.SCT_Riskbossinfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bosshp",0)
	zd.initSet(obj,"zhanli",0)
	return obj
end

maker.SCT_CSkuaPKinfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid",maker.SCT_Null())
	return obj
end

maker.SCT_Sjlcfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SC_FourGoodTaskInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"has",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"need",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"taskId",0)
	return obj
end

maker.SCT_CS_Img = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"uploadFace",maker.SCT_CS_ImgUploadFace())
	return obj
end

maker.SCT_csBuildInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buildingId",0)
	zd.initSet(obj,"buildingLevel",0)
	return obj
end

maker.SCT_SC_PlatGift = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"daily",maker.SCT_PlatGiftNotice())
	zd.initSet(obj,"festival",maker.SCT_PlatGiftNotice())
	zd.initSet(obj,"novice",maker.SCT_PlatGiftNotice())
	return obj
end

maker.SCT_HeroInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"aep",maker.SCT_fourEps())
	zd.initSet(obj,"banish",0)
	zd.initSet(obj,"bindhid",0)
	zd.initSet(obj,"btep",maker.SCT_fourEps())
	zd.initSet(obj,"epskill",zd.makeDataArray(maker.SCT_EpSkilInfo(),"id"))
	zd.initSet(obj,"exp",0)
	zd.initSet(obj,"gep",maker.SCT_fourEps())
	zd.initSet(obj,"ghskill",zd.makeDataArray(maker.SCT_ghSkilInfo(),"id"))
	zd.initSet(obj,"hep",maker.SCT_fourEps())
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"level",1)
	zd.initSet(obj,"mount",0)
	zd.initSet(obj,"pkexp",0)
	zd.initSet(obj,"pkskill",zd.makeDataArray(maker.SCT_SkilInfo(),"id"))
	zd.initSet(obj,"sbep",maker.SCT_fourEps())
	zd.initSet(obj,"senior",1)
	zd.initSet(obj,"ur",0)
	zd.initSet(obj,"urfree",0)
	zd.initSet(obj,"wep",maker.SCT_fourEps())
	zd.initSet(obj,"whep",maker.SCT_fourEps())
	zd.initSet(obj,"whgep",maker.SCT_fourEps())
	zd.initSet(obj,"zcbei",0)
	zd.initSet(obj,"zcep",maker.SCT_fourEps())
	zd.initSet(obj,"zep",maker.SCT_fourEps())
	zd.initSet(obj,"zz",maker.SCT_fourEps())
	zd.initSet(obj,"zzexp",0)
	return obj
end

maker.SCT_SCguanKaRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"etime",0)
	zd.initSet(obj,"stime",0)
	return obj
end

maker.SCT_ScXxlCfgStrength = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"init",0)
	zd.initSet(obj,"max",0)
	zd.initSet(obj,"recure",0)
	return obj
end

maker.SCT_SC_MonthTaskBase = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"days",0)
	zd.initSet(obj,"eTime",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"maxRebate",0)
	zd.initSet(obj,"news",0)
	zd.initSet(obj,"refresh_count",0)
	zd.initSet(obj,"refresh_free",0)
	zd.initSet(obj,"refresh_price",0)
	zd.initSet(obj,"reset_time",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"scoreEach",0)
	zd.initSet(obj,"scorePrice",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"wife",0)
	zd.initSet(obj,"word","")
	return obj
end

maker.SCT_SC_Shop = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"firstRecharge",maker.SCT_SC_firstRecharge())
	zd.initSet(obj,"giftlist",maker.SCT_ShopGiftInfo())
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_OneBuyInfo(),"id"))
	zd.initSet(obj,"skinlist",maker.SCT_ScSkinShop())
	zd.initSet(obj,"vipgiftlist",maker.SCT_ShopGiftInfo())
	return obj
end

maker.SCT_cjoldPlayerBackCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"lastrwd",zd.makeDataArray("oldPlayerRwd"))
	zd.initSet(obj,"rwd",zd.makeDataArray("oldPlayerRwd"))
	zd.initSet(obj,"sign",0)
	return obj
end

maker.SCT_Sjlfy = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fymax",0)
	zd.initSet(obj,"fynum",0)
	return obj
end

maker.SCT_SClubInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cyBan",0)
	zd.initSet(obj,"exp",0)
	zd.initSet(obj,"fund",0)
	zd.initSet(obj,"goldLimit",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"isJoin",0)
	zd.initSet(obj,"job",0)
	zd.initSet(obj,"laoma","")
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"members",zd.makeDataArray(maker.SCT_membersInfo(),"id"))
	zd.initSet(obj,"money",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"note1","")
	zd.initSet(obj,"note2","")
	zd.initSet(obj,"note3","")
	zd.initSet(obj,"noteTitle1","")
	zd.initSet(obj,"noteTitle2","")
	zd.initSet(obj,"noteTitle3","")
	zd.initSet(obj,"notice","")
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"outmsg","")
	zd.initSet(obj,"password","")
	zd.initSet(obj,"pwdTip",0)
	zd.initSet(obj,"qq","")
	zd.initSet(obj,"sex",0)
	zd.initSet(obj,"vip",0)
	return obj
end

maker.SCT_ancestralhallmy = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"news",zd.makeDataArray("ancestralhallnews","id"))
	return obj
end

maker.SCT_ScgInfoDirectDetail = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"endTime","")
	zd.initSet(obj,"gift_attr",zd.makeDataArray(maker.SCT_giftInfo()))
	zd.initSet(obj,"lang_key","")
	zd.initSet(obj,"startTime","")
	zd.initSet(obj,"title","")
	zd.initSet(obj,"type_id",0)
	return obj
end

maker.SCT_hd786Exchange = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SC_bigEmojiredtype = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CS_hd760Buy = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CS_risk = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"add_qianduan",maker.SCT_CsRiskQianduan())
	zd.initSet(obj,"changeNpcState",maker.SCT_CsRiskChangeNpcState())
	zd.initSet(obj,"changeTexiao",maker.SCT_CsRiskchangeTexiao())
	zd.initSet(obj,"choiceMakeTask",maker.SCT_CsRischoiceMakeTask())
	zd.initSet(obj,"choiceOperate",maker.SCT_CsRiskOperate())
	zd.initSet(obj,"clickProtectTask",maker.SCT_CsRiskclickProtectTask())
	zd.initSet(obj,"comeback",maker.SCT_heroId())
	zd.initSet(obj,"darts",maker.SCT_CsRiskDarts())
	zd.initSet(obj,"exchange",maker.SCT_CsRiskExchange())
	zd.initSet(obj,"fightBoss",maker.SCT_CsFightBoss())
	zd.initSet(obj,"follow",maker.SCT_CsRiskFollow())
	zd.initSet(obj,"getAllrwd",maker.SCT_CxshdInfo())
	zd.initSet(obj,"getBaozang",maker.SCT_CsRiskGetBaozang())
	zd.initSet(obj,"getBossInfo",maker.SCT_CsriskgetBossInfo())
	zd.initSet(obj,"getExchangeInfo","")
	zd.initSet(obj,"getInNewMap",maker.SCT_CRiskgetinNewMap())
	zd.initSet(obj,"getInRisk",maker.SCT_CxshdInfo())
	zd.initSet(obj,"getPowerInfo","")
	zd.initSet(obj,"getTaskRwd",maker.SCT_CsRiskGetRwd())
	zd.initSet(obj,"jumpSpecialMap",maker.SCT_CsRiskjumpSpecialMap())
	zd.initSet(obj,"moveCoord",maker.SCT_CsRiskMove())
	zd.initSet(obj,"mysteryOrderExchange",maker.SCT_CsMysteryExchange())
	zd.initSet(obj,"npcarriveCoord",maker.SCT_CsRiskNpcarriveCoord())
	zd.initSet(obj,"orderRefresh","")
	zd.initSet(obj,"play",maker.SCT_CxshdInfo())
	zd.initSet(obj,"playStory",maker.SCT_CsRiskStory())
	zd.initSet(obj,"randBaoZang",maker.SCT_CsRiskRandBaoZang())
	zd.initSet(obj,"recoverPower",maker.SCT_CsRiskRecover())
	zd.initSet(obj,"resetCd",maker.SCT_CsRiskResetCd())
	zd.initSet(obj,"shop",maker.SCT_CsRiskShop())
	zd.initSet(obj,"submitTask",maker.SCT_CsRiskSubmitTask())
	zd.initSet(obj,"unlock",maker.SCT_CsRiskchangeUnlock())
	zd.initSet(obj,"unlockMysteryOrder",maker.SCT_CsMysteryUnlock())
	zd.initSet(obj,"unlockNpcOrder",maker.SCT_CsUnlockNpcOrder())
	zd.initSet(obj,"upLevel","")
	zd.initSet(obj,"workbench",maker.SCT_CsRiskworkbench())
	return obj
end

maker.SCT_SC_TanSuo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"onekeywin",zd.makeDataArray(maker.SCT_ScTansuoWin()))
	zd.initSet(obj,"tsCJ",zd.makeDataArray(maker.SCT_ScTansuoCJ(),"id"))
	zd.initSet(obj,"tsInfo",maker.SCT_CdNumOpen())
	zd.initSet(obj,"tsMap",zd.makeDataArray(maker.SCT_ScTansuoMapList(),"id"))
	zd.initSet(obj,"tsSJList",zd.makeDataArray(maker.SCT_ScTansuoSJList()))
	zd.initSet(obj,"tsSJLog",zd.makeDataArray(maker.SCT_ScTansuoLog(),"id"))
	zd.initSet(obj,"tsWife",zd.makeDataArray(maker.SCT_ScTansuoWife(),"id"))
	zd.initSet(obj,"win",zd.makeDataArray(maker.SCT_ScTansuoWin()))
	return obj
end

maker.SCT_CS_System = function()
	local obj = {}
	zd.makeDataTable(obj)
	return obj
end

maker.SCT_SC_czjjhuodong = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg",maker.SCT_Sczcfg())
	zd.initSet(obj,"user",maker.SCT_Sjjuser())
	return obj
end

maker.SCT_CSkuaPKrwdinfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",maker.SCT_Null())
	return obj
end

maker.SCT_Szcjjuser = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"longtime",0)
	zd.initSet(obj,"regtime",0)
	zd.initSet(obj,"rwd",0)
	zd.initSet(obj,"tzstate",0)
	zd.initSet(obj,"tztime",0)
	return obj
end

maker.SCT_CS_Hd786Id = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_hd748Num = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_CSkuaLookWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid",0)
	return obj
end

maker.SCT_CsRiskRandBaoZang = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"x",0)
	zd.initSet(obj,"y",0)
	zd.initSet(obj,"zb_list",zd.makeDataArray(maker.SCT_CsRiskBaoZangList()))
	return obj
end

maker.SCT_CS_ChengHao = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"check",maker.SCT_ChHaoId())
	zd.initSet(obj,"offChengHao",maker.SCT_ChHaoId())
	zd.initSet(obj,"setChengHao",maker.SCT_ChHaoId())
	zd.initSet(obj,"wyrwd",maker.SCT_Cwyrwd())
	return obj
end

maker.SCT_CS_Platvip = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"daily_info",maker.SCT_Null())
	zd.initSet(obj,"daily_rwd",maker.SCT_PlatvipParam())
	zd.initSet(obj,"tequan_info",maker.SCT_Null())
	zd.initSet(obj,"tequan_rwd",maker.SCT_PlatvipParam())
	return obj
end

maker.SCT_XShdGetRank = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CS_getGuideRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_ShopGift = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SC_Skin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"collect",zd.makeDataArray(maker.SCT_idBase()))
	zd.initSet(obj,"firstHeroList",zd.makeDataArray(maker.SCT_firstHeroList()))
	zd.initSet(obj,"firstWifeList",zd.makeDataArray(maker.SCT_skinList()))
	zd.initSet(obj,"heroList",zd.makeDataArray(maker.SCT_skinList()))
	zd.initSet(obj,"heroshop",maker.SCT_skinShopInfo())
	zd.initSet(obj,"make",maker.SCT_makeSkin())
	zd.initSet(obj,"myScore","XgMyScore")
	zd.initSet(obj,"wifeList",zd.makeDataArray(maker.SCT_skinList()))
	zd.initSet(obj,"wifeshop",maker.SCT_skinShopInfo())
	return obj
end

maker.SCT_SsetChatFrame = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CsRiskExchange = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"gid",0)
	return obj
end

maker.SCT_hisServerInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"time",0)
	return obj
end

maker.SCT_heroSkillId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"sid",0)
	return obj
end

maker.SCT_CS_Building = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buildingInfo",maker.SCT_csBuildInfo())
	zd.initSet(obj,"exchange","CxghdExchange")
	zd.initSet(obj,"fightLos",maker.SCT_ParamId())
	zd.initSet(obj,"getGrabRwd",0)
	zd.initSet(obj,"grab",maker.SCT_csBuildOccupy())
	zd.initSet(obj,"grabRwdInfo",0)
	zd.initSet(obj,"info",maker.SCT_Null())
	zd.initSet(obj,"myLogs",maker.SCT_Null())
	zd.initSet(obj,"occupy",maker.SCT_csBuildOccupy())
	zd.initSet(obj,"recover",maker.SCT_Null())
	zd.initSet(obj,"recoverHero",maker.SCT_ParamId())
	zd.initSet(obj,"revenge",maker.SCT_csBuildRevenge())
	return obj
end

maker.SCT_CxxlSetMap = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"map","")
	return obj
end

maker.SCT_CsCourtyardPlantFarm = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"zid",0)
	return obj
end

maker.SCT_FirstYamenData = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"isHe",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"scorerank",0)
	zd.initSet(obj,"sid",0)
	return obj
end

maker.SCT_SC_Guide = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"special_guide",zd.makeDataArray("SC_GuideSpecialGuide"))
	return obj
end

maker.SCT_SC_zpfl = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg",maker.SCT_zpflcfg())
	zd.initSet(obj,"pmd",zd.makeDataArray(maker.SCT_pmdlist()))
	zd.initSet(obj,"user",maker.SCT_zpfluser())
	return obj
end

maker.SCT_ItemId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_ScXxlDayRwdID = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_PlatvipParam = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"pfvipgiftid",0)
	return obj
end

maker.SCT_SC_signName = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"time",0)
	return obj
end

maker.SCT_JyngYingWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"haoshi",zd.makeDataArray(maker.SCT_JyngYingWinHaoShiWin(),"id"))
	return obj
end

maker.SCT_TaskNum = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"item",maker.SCT_UseItemInfo())
	zd.initSet(obj,"type","")
	return obj
end

maker.SCT_RiskShoplist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buyCnt",0)
	zd.initSet(obj,"icon","")
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"limit",0)
	zd.initSet(obj,"price",0)
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_UseItemInfo()))
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SC_antiAddiction = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"onlineTime",maker.SCT_s_onlineTime())
	return obj
end

maker.SCT_Sc_dispos = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bhdh","Sc_butlerpz")
	zd.initSet(obj,"ch","Sc_butlerpz")
	zd.initSet(obj,"jy","Sc_butlerpz")
	zd.initSet(obj,"ld","Sc_butlerpz")
	zd.initSet(obj,"school","Sc_butlerpz")
	zd.initSet(obj,"sl","Sc_butlerpz")
	zd.initSet(obj,"son","Sc_butlerpz")
	zd.initSet(obj,"xunfang","Sc_butlerpz")
	zd.initSet(obj,"zcdh","Sc_butlerpz")
	zd.initSet(obj,"zw","Sc_butlerpz")
	return obj
end

maker.SCT_ScCourtyardBase = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"get",0)
	zd.initSet(obj,"kc",0)
	zd.initSet(obj,"limit",zd.makeDataArray(maker.SCT_IDNUM(),"id"))
	zd.initSet(obj,"lv",1)
	zd.initSet(obj,"mc",0)
	zd.initSet(obj,"sp",0)
	return obj
end

maker.SCT_ScCourtyardFarmList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"zid",0)
	zd.initSet(obj,"zt",0)
	return obj
end

maker.SCT_SC_redpackethuodong = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"allinfo",maker.SCT_SC_redpackethuodonginfo())
	zd.initSet(obj,"rwdLog",zd.makeDataArray("redLog"))
	return obj
end

maker.SCT_mobilelist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_mobileInfo())
	return obj
end

maker.SCT_CS_Shop = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"directGiftList",maker.SCT_NULL())
	zd.initSet(obj,"shopBuy",maker.SCT_shopBuyNew())
	zd.initSet(obj,"shopGift",maker.SCT_ShopGift())
	zd.initSet(obj,"shopLimit",maker.SCT_ShopLimit())
	zd.initSet(obj,"shoplist",maker.SCT_NULL())
	zd.initSet(obj,"skinBuy",maker.SCT_ShopLimit())
	zd.initSet(obj,"skinShop",maker.SCT_NULL())
	zd.initSet(obj,"vipShopGift",maker.SCT_ShopGift())
	return obj
end

maker.SCT_RiskBaoZang = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"kind",0)
	zd.initSet(obj,"x",0)
	zd.initSet(obj,"y",0)
	return obj
end

maker.SCT_CxHbget = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SCclubKuahitmyf = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"f",maker.SCT_SCclubKuahit())
	zd.initSet(obj,"my",maker.SCT_SCclubKuahit())
	return obj
end

maker.SCT_CSkuaLookHit = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid",0)
	return obj
end

maker.SCT_CS_Hd760Id = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_ShopLimit = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CInfoClearNoteNews = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_RiskOrder = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"gid",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"npc_id",0)
	return obj
end

maker.SCT_hd699TeammateId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"tmid",0)
	return obj
end

maker.SCT_CSbuildUnlock = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CxxlUseItem = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"map","")
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"score",0)
	return obj
end

maker.SCT_ClubCZHDUser = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"cz",zd.makeDataArray(maker.SCT_ClubCZHDUserCz()))
	zd.initSet(obj,"inday",0)
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_ClubCZHDUserRwd()))
	zd.initSet(obj,"today",0)
	return obj
end

maker.SCT_SSonshili = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_fHeroInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"aep",maker.SCT_fourEps())
	zd.initSet(obj,"banish",0)
	zd.initSet(obj,"bindhid",0)
	zd.initSet(obj,"btep",maker.SCT_fourEps())
	zd.initSet(obj,"dt",0)
	zd.initSet(obj,"epskill",zd.makeDataArray(maker.SCT_EpSkilInfo(),"id"))
	zd.initSet(obj,"exp",0)
	zd.initSet(obj,"gep",maker.SCT_fourEps())
	zd.initSet(obj,"ghskill",zd.makeDataArray(maker.SCT_SkilInfo(),"id"))
	zd.initSet(obj,"hep",maker.SCT_fourEps())
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"level",1)
	zd.initSet(obj,"mount",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"pkexp",0)
	zd.initSet(obj,"pkskill",zd.makeDataArray(maker.SCT_SkilInfo(),"id"))
	zd.initSet(obj,"senior",1)
	zd.initSet(obj,"skin",0)
	zd.initSet(obj,"uid",0)
	zd.initSet(obj,"ur",0)
	zd.initSet(obj,"vip",0)
	zd.initSet(obj,"wep",maker.SCT_fourEps())
	zd.initSet(obj,"zep",maker.SCT_fourEps())
	zd.initSet(obj,"zz",maker.SCT_fourEps())
	zd.initSet(obj,"zzexp",0)
	return obj
end

maker.SCT_Scbhdrwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"member",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"rand",maker.SCT_srand())
	return obj
end

maker.SCT_FightWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"map",maker.SCT_MapInfo())
	zd.initSet(obj,"members",zd.makeDataArray(maker.SCT_FightMember(),"id"))
	zd.initSet(obj,"win",1)
	return obj
end

maker.SCT_CS_Banish = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"addDesk","")
	zd.initSet(obj,"banish",maker.SCT_BanishHero())
	zd.initSet(obj,"getrwd",maker.SCT_idBase())
	zd.initSet(obj,"info","")
	zd.initSet(obj,"recall",maker.SCT_BanishRecall())
	zd.initSet(obj,"reduce",maker.SCT_Banishreduce())
	return obj
end

maker.SCT_CS_hd491SevInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CName = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SC_FourGoodWeekTask = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_SC_FourGoodTaskInfo(),"id"))
	return obj
end

maker.SCT_SC_Code = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"exchange",maker.SCT_SC_MsgWin())
	return obj
end

maker.SCT_CS_FuLi = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"draw_gift",maker.SCT_drawGift())
	zd.initSet(obj,"fChoV2",maker.SCT_ChoiceId())
	zd.initSet(obj,"fbShare","")
	zd.initSet(obj,"fcho",maker.SCT_FuLiFchoDay())
	zd.initSet(obj,"fchoclose",maker.SCT_FuLiFChoClose())
	zd.initSet(obj,"fulifund",maker.SCT_Null())
	zd.initSet(obj,"getSevenDaySignRwd",maker.SCT_idBase())
	zd.initSet(obj,"getclubrwd",maker.SCT_FundFuliRwd())
	zd.initSet(obj,"getcrossrwd",maker.SCT_FundFuliRwd())
	zd.initSet(obj,"getlevelrwd",maker.SCT_FundFuliRwd())
	zd.initSet(obj,"mooncard",maker.SCT_FuLiCardId())
	zd.initSet(obj,"qiandao",maker.SCT_Null())
	zd.initSet(obj,"test_buy_decimal",maker.SCT_FuLiTest_buy_decimal())
	zd.initSet(obj,"vip",maker.SCT_FuLiVipId())
	return obj
end

maker.SCT_GameMachineInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"adCnt",0)
	zd.initSet(obj,"customId",0)
	zd.initSet(obj,"exp",0)
	zd.initSet(obj,"freeCnt",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"refreshTime",0)
	return obj
end

maker.SCT_G2dKillWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	return obj
end

maker.SCT_Sc_butler_info = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"ld",0)
	zd.initSet(obj,"sl",0)
	return obj
end

maker.SCT_SC_wutonghuser = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"chatFrame",0)
	zd.initSet(obj,"chenghao",0)
	zd.initSet(obj,"czz",0)
	zd.initSet(obj,"frame",0)
	zd.initSet(obj,"head",0)
	zd.initSet(obj,"job",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"sex",0)
	return obj
end

maker.SCT_ladder_fUserInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"duanwei",0)
	zd.initSet(obj,"mingrenchenghao",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"quname","")
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_SC_JyngYing = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"army",maker.SCT_CdjyNum())
	zd.initSet(obj,"build",zd.makeDataArray(maker.SCT_SCbuild()))
	zd.initSet(obj,"coin",maker.SCT_CdjyNum())
	zd.initSet(obj,"exp",maker.SCT_zwCdNum())
	zd.initSet(obj,"food",maker.SCT_CdjyNum())
	zd.initSet(obj,"qzam",maker.SCT_QzAiMin())
	zd.initSet(obj,"win",maker.SCT_JyngYingWin())
	return obj
end

maker.SCT_Syrwlist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"items",maker.SCT_ItemInfo())
	return obj
end

maker.SCT_JyngYingWinHaoShiWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bas",0)
	zd.initSet(obj,"zyid",0)
	return obj
end

maker.SCT_DTask = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"rwd",0)
	return obj
end

maker.SCT_SC_centralattackpkresult = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fherolist",zd.makeDataArray(maker.SCT_SC_centralattackpkresulthero(),"id"))
	zd.initSet(obj,"herolist",zd.makeDataArray(maker.SCT_SC_centralattackpkresulthero(),"id"))
	zd.initSet(obj,"win",0)
	return obj
end

maker.SCT_SC_sdk = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"translateGeneral",maker.SCT_translateGeneral())
	return obj
end

maker.SCT_CS_setLang = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"lang","")
	return obj
end

maker.SCT_newcjyxrecharge_get = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"can",0)
	zd.initSet(obj,"had",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"need",0)
	return obj
end

maker.SCT_RiskFinishedTaskList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_skinList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dt",0)
	zd.initSet(obj,"flower",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"scorerank",0)
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_BqUser = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"paiqian",zd.makeDataArray(maker.SCT_HeroInfo1()))
	zd.initSet(obj,"rwd","NewYearrwdType")
	zd.initSet(obj,"shili",0)
	return obj
end

maker.SCT_RiskHerolist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"f",0)
	zd.initSet(obj,"h",0)
	zd.initSet(obj,"hid",0)
	return obj
end

maker.SCT_SC_ButlerLixianResIdNum = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_riskUnlock = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"exchange",0)
	zd.initSet(obj,"power",0)
	zd.initSet(obj,"show",0)
	return obj
end

maker.SCT_LoginIntro = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"t",0)
	return obj
end

maker.SCT_Sjchdrwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"itemid",0)
	zd.initSet(obj,"need",0)
	return obj
end

maker.SCT_CustomId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"customId",0)
	return obj
end

maker.SCT_CsRiskchangeUnlock = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_wannengShopList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"islimit",0)
	zd.initSet(obj,"item",maker.SCT_ItemInfo())
	zd.initSet(obj,"limit",0)
	zd.initSet(obj,"need",0)
	zd.initSet(obj,"old",0)
	zd.initSet(obj,"price",0)
	zd.initSet(obj,"tip",0)
	zd.initSet(obj,"vip",0)
	return obj
end

maker.SCT_CShopRefresh = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",maker.SCT_Null())
	return obj
end

maker.SCT_drawGift = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_hd748GetBoxParams = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_WordBossWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"g2dHit",maker.SCT_HitgerdanWin())
	zd.initSet(obj,"g2dKill",maker.SCT_GerdanKillWin())
	zd.initSet(obj,"g2dRank",maker.SCT_GerdanRankRwdWin())
	zd.initSet(obj,"mghitfail",maker.SCT_HitMgfailWin())
	zd.initSet(obj,"mghitwin",maker.SCT_HitMgwinWin())
	return obj
end

maker.SCT_InviteCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"invite",maker.SCT_InviteCfgInvite())
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_Shdrwd1()))
	return obj
end

maker.SCT_CS_QianDao = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"rwd",maker.SCT_Null())
	return obj
end

maker.SCT_SC_ClubExtendDailyInfoCyCountDaily = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CsUnlockNpcOrder = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"npc_id",0)
	return obj
end

maker.SCT_fUserInfo3 = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"beijing",0)
	zd.initSet(obj,"chenghao",0)
	zd.initSet(obj,"dress",0)
	zd.initSet(obj,"dress_state",0)
	zd.initSet(obj,"duanwei",0)
	zd.initSet(obj,"extra_ch","")
	zd.initSet(obj,"guajian",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"job",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"mingrenchenghao",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"num2",0)
	zd.initSet(obj,"num3",0)
	zd.initSet(obj,"pet_addi",0)
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"savelimit",0)
	zd.initSet(obj,"sex",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"uid",0)
	zd.initSet(obj,"vip",0)
	return obj
end

maker.SCT_Sczcfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_Shdcfg())
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"need",maker.SCT_Sneedcfg())
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_Srwdcfg(),"id"))
	return obj
end

maker.SCT_CsRiskQianduan = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"index",0)
	zd.initSet(obj,"step",0)
	return obj
end

maker.SCT_CShopChange = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_RiskBoss = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bossname","")
	zd.initSet(obj,"hp",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SC_FourGoodNoticeType = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"contents",zd.makeDataArray(maker.SCT_SC_FourGoodNoticeContent()))
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_cityAndGenId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cityId",0)
	zd.initSet(obj,"gid",0)
	return obj
end

maker.SCT_FRefuseApply = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"refuse",0)
	return obj
end

maker.SCT_heroCjRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dc",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_hd699AgreeToTeam = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"tmid",0)
	return obj
end

maker.SCT_SC_clubKuaYueCyzg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cName","")
	zd.initSet(obj,"cid",0)
	zd.initSet(obj,"eTime",0)
	zd.initSet(obj,"isNow",0)
	zd.initSet(obj,"mz",maker.SCT_UserEasyData())
	zd.initSet(obj,"sTime",0)
	return obj
end

maker.SCT_Householdcj = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"user",maker.SCT_UserInfo())
	return obj
end

maker.SCT_pmdList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"ef",1)
	zd.initSet(obj,"id",1)
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"ob",1)
	zd.initSet(obj,"reflection","")
	zd.initSet(obj,"time",0)
	zd.initSet(obj,"type",1)
	return obj
end

maker.SCT_ScXxlInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"allinteg",0)
	zd.initSet(obj,"cfg",maker.SCT_ScXxlCfg())
	zd.initSet(obj,"chongpai",0)
	zd.initSet(obj,"hengpai",0)
	zd.initSet(obj,"integ",0)
	zd.initSet(obj,"map","")
	zd.initSet(obj,"rwd",0)
	zd.initSet(obj,"shupai",0)
	zd.initSet(obj,"yangshen",0)
	return obj
end

maker.SCT_SclubLog = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fname","")
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"name","")
	zd.initSet(obj,"num1",0)
	zd.initSet(obj,"num2",0)
	zd.initSet(obj,"other",0)
	zd.initSet(obj,"time",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_zwCdNum = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdNum())
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"itemid",2)
	zd.initSet(obj,"type",1)
	return obj
end

maker.SCT_FuliFundInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buy",0)
	zd.initSet(obj,"club_buy_num",0)
	zd.initSet(obj,"club_rwd",zd.makeDataArray(maker.SCT_GrowFundInfoLevel(),"id"))
	zd.initSet(obj,"cross_buy_num",0)
	zd.initSet(obj,"cross_rwd",zd.makeDataArray(maker.SCT_GrowFundInfoLevel(),"id"))
	zd.initSet(obj,"level_rwd",zd.makeDataArray(maker.SCT_GrowFundInfoLevel(),"id"))
	zd.initSet(obj,"news",0)
	return obj
end

maker.SCT_RankShowListNum = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"club",10)
	zd.initSet(obj,"hero",100)
	zd.initSet(obj,"shili",100)
	zd.initSet(obj,"skin",100)
	return obj
end

maker.SCT_CS_StoryReadStory = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"storyZid",0)
	return obj
end

maker.SCT_hd709GetBoxParams = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_Cx591fan = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SC_WifePk_wife_finfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"name","")
	return obj
end

maker.SCT_Sc2048RewardDaily = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"dc",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"rwd",maker.SCT_items_list())
	zd.initSet(obj,"target",0)
	return obj
end

maker.SCT_Cx591History = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"historyview",0)
	return obj
end

maker.SCT_hd699ChatHisByType = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SC_TranslateResult = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"original","")
	zd.initSet(obj,"translate","")
	return obj
end

maker.SCT_CS_WifePk_study = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_hd608Buy = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",1)
	return obj
end

maker.SCT_SkinWd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"wid",0)
	return obj
end

maker.SCT_Cshd402All = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",maker.SCT_Null())
	return obj
end

maker.SCT_CIsJoin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"join",0)
	return obj
end

maker.SCT_Srshop = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"beishu",1)
	zd.initSet(obj,"currency","")
	zd.initSet(obj,"dc",0)
	zd.initSet(obj,"diamond",0)
	zd.initSet(obj,"dollar",0)
	zd.initSet(obj,"productid","")
	zd.initSet(obj,"productname","")
	zd.initSet(obj,"rate",0)
	zd.initSet(obj,"rmb",0)
	zd.initSet(obj,"selbs",0)
	zd.initSet(obj,"type",1)
	return obj
end

maker.SCT_ZombieSkill = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"exp",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"sid",0)
	zd.initSet(obj,"skill_id",0)
	zd.initSet(obj,"stage",0)
	zd.initSet(obj,"unlock",0)
	zd.initSet(obj,"upexp",0)
	zd.initSet(obj,"zid",0)
	return obj
end

maker.SCT_VipStatuss = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"status",1)
	return obj
end

maker.SCT_OnekeyPveWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"deil",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"kill",0)
	zd.initSet(obj,"kill_num",0)
	zd.initSet(obj,"win",0)
	return obj
end

maker.SCT_CS_huodong = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cbFirstInfo","")
	zd.initSet(obj,"hd108GetRwd","Cxhd457Rwd")
	zd.initSet(obj,"hd108Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd108Invited","hd108InvitedNo")
	zd.initSet(obj,"hd201Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd201Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd202Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd202Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd203Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd203Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd204Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd204Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd205Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd205Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd206Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd206Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd207Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd207Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd208Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd208Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd209Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd209Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd210Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd210Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd211Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd211Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd212Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd212Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd213Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd213Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd214Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd214Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd215Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd215Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd216Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd216Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd217Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd217Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd218Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd218Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd219Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd219Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd220Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd220Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd221Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd221Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd222Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd222Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd223Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd223Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd224Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd224Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd225Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd225Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd226Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd226Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd227Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd227Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd228Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd228Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd229Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd229Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd235Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd235Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd236Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd236Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd237Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd237Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd250Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd251Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd252Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd253Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd254Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd255Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd256Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd257Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd258Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd259Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd260Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd260Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd261Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd261Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd262Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd262Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd263Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd263Rwd",maker.SCT_Hd263getRwd())
	zd.initSet(obj,"hd264Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd265Info",maker.SCT_NULL())
	zd.initSet(obj,"hd266Chat",maker.SCT_ChatMsg())
	zd.initSet(obj,"hd266Check",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd266Get",maker.SCT_NULL())
	zd.initSet(obj,"hd266Info",maker.SCT_NULL())
	zd.initSet(obj,"hd266Log",maker.SCT_ChatId())
	zd.initSet(obj,"hd266UserRank",maker.SCT_NULL())
	zd.initSet(obj,"hd266YXRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd267Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd268Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd270Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd270Rwd","CjchdRwd")
	zd.initSet(obj,"hd271Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd271Rwd","CjghdRwd")
	zd.initSet(obj,"hd272Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd272Rwd","CjghdRwd")
	zd.initSet(obj,"hd273Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd273Rwd","CjghdRwd")
	zd.initSet(obj,"hd274Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd274Rwd","CjghdRwd")
	zd.initSet(obj,"hd275Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd275Rwd","CjghdRwd")
	zd.initSet(obj,"hd276Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd276Rwd","CjghdRwd")
	zd.initSet(obj,"hd280Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd280Rwd","")
	zd.initSet(obj,"hd280buy","CxghdBuy")
	zd.initSet(obj,"hd280exchange","CxghdExchange")
	zd.initSet(obj,"hd280paihang","")
	zd.initSet(obj,"hd280play","CxghdPlay")
	zd.initSet(obj,"hd281Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd281Rwd","")
	zd.initSet(obj,"hd281buy","CxghdBuy")
	zd.initSet(obj,"hd281exchange","CxghdExchange")
	zd.initSet(obj,"hd281getRwd","DnGetRecharge")
	zd.initSet(obj,"hd281paihang","")
	zd.initSet(obj,"hd281play","CxghdPlay")
	zd.initSet(obj,"hd282Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd282Rwd","")
	zd.initSet(obj,"hd282buy","CxghdBuy")
	zd.initSet(obj,"hd282exchange","CxghdExchange")
	zd.initSet(obj,"hd282paihang","")
	zd.initSet(obj,"hd282play","CxghdPlay")
	zd.initSet(obj,"hd283Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd283Rwd","")
	zd.initSet(obj,"hd283buy","CxghdBuy")
	zd.initSet(obj,"hd283exchange",maker.SCT_IDCOUNT())
	zd.initSet(obj,"hd283paihang","")
	zd.initSet(obj,"hd283play","CxghdPlay")
	zd.initSet(obj,"hd284Check","")
	zd.initSet(obj,"hd284Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd284Rwd","")
	zd.initSet(obj,"hd284buy","CxghdBuy")
	zd.initSet(obj,"hd284exchange",maker.SCT_IDCOUNT())
	zd.initSet(obj,"hd284getRwd","DnGetRecharge")
	zd.initSet(obj,"hd284paihang","")
	zd.initSet(obj,"hd284play","CxghdPlay")
	zd.initSet(obj,"hd285Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd285buy","CxghdBuy")
	zd.initSet(obj,"hd285buyGift","CxghdBuy")
	zd.initSet(obj,"hd285getRwd","DnGetRecharge")
	zd.initSet(obj,"hd286Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd286Rwd","")
	zd.initSet(obj,"hd286buy","CxghdBuy")
	zd.initSet(obj,"hd286exchange","CxghdExchange")
	zd.initSet(obj,"hd286getRwd","DnGetRecharge")
	zd.initSet(obj,"hd286paihang","")
	zd.initSet(obj,"hd286play","CxghdPlay")
	zd.initSet(obj,"hd287Get",maker.SCT_SevenSignRwd())
	zd.initSet(obj,"hd287Info","")
	zd.initSet(obj,"hd288Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd288Rwd","")
	zd.initSet(obj,"hd288buy","CxghdBuy")
	zd.initSet(obj,"hd288exchange","CxghdExchange")
	zd.initSet(obj,"hd288getRwd","DnGetRecharge")
	zd.initSet(obj,"hd288paihang","")
	zd.initSet(obj,"hd288play","CxghdPlay")
	zd.initSet(obj,"hd289Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd289Rwd","")
	zd.initSet(obj,"hd289buy","CxghdBuy")
	zd.initSet(obj,"hd289exchange","CxghdExchange")
	zd.initSet(obj,"hd289getRwd","DnGetRecharge")
	zd.initSet(obj,"hd289paihang","")
	zd.initSet(obj,"hd289play","CxghdPlay")
	zd.initSet(obj,"hd290Buy","Cxzpbuy")
	zd.initSet(obj,"hd290Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd290Yao","Cxzpyao")
	zd.initSet(obj,"hd290exchange",maker.SCT_IDCOUNT())
	zd.initSet(obj,"hd290log","Cxzplog")
	zd.initSet(obj,"hd2912Buy","Cxsdbuy")
	zd.initSet(obj,"hd2912Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd2912SRwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd2912Set","CxsdSet")
	zd.initSet(obj,"hd2912Task","Cxzpdui")
	zd.initSet(obj,"hd2912Zadan",maker.SCT_Cxsdnd())
	zd.initSet(obj,"hd2915AddBless",maker.SCT_CShd434AddBless())
	zd.initSet(obj,"hd2915Get",maker.SCT_CShd332Up())
	zd.initSet(obj,"hd2915Info","CxzcInfo")
	zd.initSet(obj,"hd2915Paihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd2915Task","CxghdBuy")
	zd.initSet(obj,"hd2915exchange","CxghdExchange")
	zd.initSet(obj,"hd2915play",maker.SCT_CShd434Play())
	zd.initSet(obj,"hd291Buy","Cxsdbuy")
	zd.initSet(obj,"hd291Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd291Set","CxsdSet")
	zd.initSet(obj,"hd291Zadan","Cxsdzd")
	zd.initSet(obj,"hd292exchange","Cxzpdui")
	zd.initSet(obj,"hd293Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd293Run",maker.SCT_ChdList())
	zd.initSet(obj,"hd293Rwd","Cxzpdui")
	zd.initSet(obj,"hd293Task","Cxzpdui")
	zd.initSet(obj,"hd294Get","CxzcGet")
	zd.initSet(obj,"hd294Info","CxzcInfo")
	zd.initSet(obj,"hd294Set","CxzcSet")
	zd.initSet(obj,"hd294Zao","CxzcZao")
	zd.initSet(obj,"hd294exchange","CxzcGet")
	zd.initSet(obj,"hd294log","Cxzclog")
	zd.initSet(obj,"hd294paihang","")
	zd.initSet(obj,"hd295Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd295Paihang","")
	zd.initSet(obj,"hd295getHb",maker.SCT_CxHbget())
	zd.initSet(obj,"hd295getHbInfo",maker.SCT_CxHbget())
	zd.initSet(obj,"hd295mobai","")
	zd.initSet(obj,"hd295sendHb",maker.SCT_CxHbSend())
	zd.initSet(obj,"hd296Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd296Rwd","Cxzpdui")
	zd.initSet(obj,"hd296Task","Cxzpdui")
	zd.initSet(obj,"hd296Wa",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd297Buy","Chd297Buy")
	zd.initSet(obj,"hd297DstwYao","Chd297DstwYao")
	zd.initSet(obj,"hd297GRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd297Gget","Chd297cans")
	zd.initSet(obj,"hd297Guid",maker.SCT_Chd297Guid())
	zd.initSet(obj,"hd297Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd297Log",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd297SRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd297Send","Chd297Send")
	zd.initSet(obj,"hd297Sget","Chd297cans")
	zd.initSet(obj,"hd297Yao","Chd297Yao")
	zd.initSet(obj,"hd298Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd298buy","NewyearhdBuy")
	zd.initSet(obj,"hd298exchange","CxghdExchange")
	zd.initSet(obj,"hd298paihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd298play","NewyearhdPlay")
	zd.initSet(obj,"hd309Info","CxzcInfo")
	zd.initSet(obj,"hd310Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd311Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd312Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd313Chat",maker.SCT_ChatMsg())
	zd.initSet(obj,"hd313Check",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd313Get",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd313Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd313Log",maker.SCT_ChatId())
	zd.initSet(obj,"hd313QuRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd313UserRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd313YXRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd314Chat",maker.SCT_ChatMsg())
	zd.initSet(obj,"hd314Check",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd314Get",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd314Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd314Log",maker.SCT_ChatId())
	zd.initSet(obj,"hd314QuRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd314UserRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd314YXRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd315Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd315Rank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd316Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd317Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd317Rwd",maker.SCT_GetTzrwd())
	zd.initSet(obj,"hd317invest",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd318Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd318Rwd",maker.SCT_GetTzrwd())
	zd.initSet(obj,"hd318invest",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd330Buy","Cxyxbuy")
	zd.initSet(obj,"hd330Get",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd330Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd330Up","Cxzpup")
	zd.initSet(obj,"hd330exchange","Cxzpdui")
	zd.initSet(obj,"hd331Info","")
	zd.initSet(obj,"hd331Paihang",maker.SCT_Hd331getPaghang())
	zd.initSet(obj,"hd331Rwd","")
	zd.initSet(obj,"hd332Buy",maker.SCT_CShd332Buy())
	zd.initSet(obj,"hd332Get",maker.SCT_CShd332Up())
	zd.initSet(obj,"hd332Info","CxzcInfo")
	zd.initSet(obj,"hd332Rank","CxzcInfo")
	zd.initSet(obj,"hd332Ranking","CxzcInfo")
	zd.initSet(obj,"hd332Up",maker.SCT_CShd332Up())
	zd.initSet(obj,"hd332Zou","CShd332Zou")
	zd.initSet(obj,"hd332exchange",maker.SCT_CShd332Up())
	zd.initSet(obj,"hd332shop","CxzcInfo")
	zd.initSet(obj,"hd333Buy","CShd333Buy")
	zd.initSet(obj,"hd333Get","CShd333Up")
	zd.initSet(obj,"hd333Info","CxzcInfo")
	zd.initSet(obj,"hd333Zou","CShd333Zou")
	zd.initSet(obj,"hd333exchange","CShd333Up")
	zd.initSet(obj,"hd333shop","CxzcInfo")
	zd.initSet(obj,"hd334Info","CxzcInfo")
	zd.initSet(obj,"hd334SetHide",maker.SCT_CShd334Set())
	zd.initSet(obj,"hd336Buy",maker.SCT_CShd336Buy())
	zd.initSet(obj,"hd336Get",maker.SCT_CShd336Up())
	zd.initSet(obj,"hd336Info","CxzcInfo")
	zd.initSet(obj,"hd336Rank","CxzcInfo")
	zd.initSet(obj,"hd336Ranking","CxzcInfo")
	zd.initSet(obj,"hd336Up",maker.SCT_CShd336Up())
	zd.initSet(obj,"hd336Zou","CShd336Zou")
	zd.initSet(obj,"hd336exchange",maker.SCT_IDCOUNT())
	zd.initSet(obj,"hd336shop","CxzcInfo")
	zd.initSet(obj,"hd337Get","CShd337Get")
	zd.initSet(obj,"hd337Info","CxzcInfo")
	zd.initSet(obj,"hd337Zhao","CShd337Zhao")
	zd.initSet(obj,"hd339Buy","CS_hd339Buy")
	zd.initSet(obj,"hd339Get","CShd339Get")
	zd.initSet(obj,"hd339Hua","CShd339Hua")
	zd.initSet(obj,"hd339Info","CxzcInfo")
	zd.initSet(obj,"hd339exchange",maker.SCT_IDCOUNT())
	zd.initSet(obj,"hd339shop","CxzcInfo")
	zd.initSet(obj,"hd340Info","CxzcInfo")
	zd.initSet(obj,"hd340Ticket","CShd340Ticket")
	zd.initSet(obj,"hd342Chat",maker.SCT_ChatMsg())
	zd.initSet(obj,"hd342Check",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd342Goto","CxzcInfo")
	zd.initSet(obj,"hd342Info","CxzcInfo")
	zd.initSet(obj,"hd342Log",maker.SCT_ChatId())
	zd.initSet(obj,"hd342Rewards","CxzcInfo")
	zd.initSet(obj,"hd342Rwd","CxzcInfo")
	zd.initSet(obj,"hd342Send","CShd342Send")
	zd.initSet(obj,"hd343AddBless",maker.SCT_CShd434AddBless())
	zd.initSet(obj,"hd343GetGift","CxzcInfo")
	zd.initSet(obj,"hd343GetRwd","CxzcInfo")
	zd.initSet(obj,"hd343Info","CxzcInfo")
	zd.initSet(obj,"hd343Paihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd343exchange","CxghdExchange")
	zd.initSet(obj,"hd343getLantern",maker.SCT_CShd434Lantern())
	zd.initSet(obj,"hd343play",maker.SCT_CShd434Play())
	zd.initSet(obj,"hd344GetRwd","CxzcInfo")
	zd.initSet(obj,"hd344Info","CxzcInfo")
	zd.initSet(obj,"hd344Validate",maker.SCT_CShd344Validate())
	zd.initSet(obj,"hd344send",maker.SCT_CShd344Send())
	zd.initSet(obj,"hd345Get","CSDsRedBagGet")
	zd.initSet(obj,"hd345History",maker.SCT_ChatId())
	zd.initSet(obj,"hd345Info",maker.SCT_NULL())
	zd.initSet(obj,"hd345RbInfo","CSDsRedBagInfo")
	zd.initSet(obj,"hd345Send","CSDsRedBag")
	zd.initSet(obj,"hd346DstwPlay","zqdstwzgwy")
	zd.initSet(obj,"hd346GetRwd","CxzcInfo")
	zd.initSet(obj,"hd346GetSeekRwd","CxzcInfo")
	zd.initSet(obj,"hd346Info","CxzcInfo")
	zd.initSet(obj,"hd346Paihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd346SeekRabbit",maker.SCT_CShd434Lantern())
	zd.initSet(obj,"hd346SetWife","Xq_wife")
	zd.initSet(obj,"hd346buy","NewyearhdBuy")
	zd.initSet(obj,"hd346exchange","CxghdExchange")
	zd.initSet(obj,"hd346play",maker.SCT_CShd434Play())
	zd.initSet(obj,"hd347Info","CxzcInfo")
	zd.initSet(obj,"hd349AddBless",maker.SCT_CShd434AddBless())
	zd.initSet(obj,"hd349GetGift","CxzcInfo")
	zd.initSet(obj,"hd349GetRwd","CxzcInfo")
	zd.initSet(obj,"hd349Info","CxzcInfo")
	zd.initSet(obj,"hd349Paihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd349exchange","CxghdExchange")
	zd.initSet(obj,"hd349getLantern",maker.SCT_CShd434Lantern())
	zd.initSet(obj,"hd349play",maker.SCT_CShd434Play())
	zd.initSet(obj,"hd350Buy",maker.SCT_CShd336Buy())
	zd.initSet(obj,"hd350Get",maker.SCT_CShd336Up())
	zd.initSet(obj,"hd350Info","CxzcInfo")
	zd.initSet(obj,"hd350Rank","CxzcInfo")
	zd.initSet(obj,"hd350Ranking","CxzcInfo")
	zd.initSet(obj,"hd350Up",maker.SCT_CShd336Up())
	zd.initSet(obj,"hd350Zou","CShd336Zou")
	zd.initSet(obj,"hd350exchange",maker.SCT_CShd336Up())
	zd.initSet(obj,"hd350shop","CxzcInfo")
	zd.initSet(obj,"hd351Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd351Yao","Cxzpyao")
	zd.initSet(obj,"hd351exchange","Cxzpdui")
	zd.initSet(obj,"hd351log","Cxzplog")
	zd.initSet(obj,"hd352Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd352Run",maker.SCT_ChdList())
	zd.initSet(obj,"hd352Rwd","Cxzpdui")
	zd.initSet(obj,"hd352Task","Cxzpdui")
	zd.initSet(obj,"hd356Check","CxyyRwd")
	zd.initSet(obj,"hd356Info",maker.SCT_NULL())
	zd.initSet(obj,"hd356Rwd","CxyyRwd")
	zd.initSet(obj,"hd358Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd358Rwd","Cxzpdui")
	zd.initSet(obj,"hd358Task","Cxzpdui")
	zd.initSet(obj,"hd358Wa",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd364Rwd","")
	zd.initSet(obj,"hd365Info","")
	zd.initSet(obj,"hd365Pre",maker.SCT_CShd365Pre())
	zd.initSet(obj,"hd365Rwd",maker.SCT_CShd365Rwd())
	zd.initSet(obj,"hd387Info",maker.SCT_Null())
	zd.initSet(obj,"hd387Rwd",maker.SCT_Null())
	zd.initSet(obj,"hd388Buy","CS_Shuang11QdscBuy")
	zd.initSet(obj,"hd388Flop",maker.SCT_Null())
	zd.initSet(obj,"hd388Info",maker.SCT_Null())
	zd.initSet(obj,"hd388Label",maker.SCT_ParamType())
	zd.initSet(obj,"hd388Mobai",maker.SCT_Null())
	zd.initSet(obj,"hd389Info",maker.SCT_Null())
	zd.initSet(obj,"hd390LevelRwd",maker.SCT_CS_Hd390LevelRwd())
	zd.initSet(obj,"hd390LevelRwdAll",maker.SCT_Null())
	zd.initSet(obj,"hd390Refresh",maker.SCT_Null())
	zd.initSet(obj,"hd390ScoreRwd",maker.SCT_CS_Hd390ScoreRwd())
	zd.initSet(obj,"hd390UpLevel",maker.SCT_CS_Hd390UpLevel())
	zd.initSet(obj,"hd390WifeRwd",maker.SCT_Null())
	zd.initSet(obj,"hd395GetRwd",maker.SCT_idBase())
	zd.initSet(obj,"hd395Info",maker.SCT_NULL())
	zd.initSet(obj,"hd396GetRwd",maker.SCT_idBase())
	zd.initSet(obj,"hd396Info",maker.SCT_NULL())
	zd.initSet(obj,"hd397Info",maker.SCT_NULL())
	zd.initSet(obj,"hd397Rwd","CxyyRwd")
	zd.initSet(obj,"hd401Info",maker.SCT_Cshd401All())
	zd.initSet(obj,"hd401Rwd",maker.SCT_Cshd401All())
	zd.initSet(obj,"hd402Info",maker.SCT_Cshd402All())
	zd.initSet(obj,"hd402Rwd",maker.SCT_Cshd402All())
	zd.initSet(obj,"hd407Info",maker.SCT_Cshd407All())
	zd.initSet(obj,"hd407Rwd",maker.SCT_Cshd407All())
	zd.initSet(obj,"hd413Rwd",maker.SCT_Cshd413All())
	zd.initSet(obj,"hd422Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd422buy","NewyearhdBuy")
	zd.initSet(obj,"hd422exchange","CxghdExchange")
	zd.initSet(obj,"hd422paihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd422play","TreasurehdPlay")
	zd.initSet(obj,"hd427Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd428Info","")
	zd.initSet(obj,"hd428Rwd",maker.SCT_OldPlayerBackRwd())
	zd.initSet(obj,"hd429Info","")
	zd.initSet(obj,"hd429Rwd",maker.SCT_NULL())
	zd.initSet(obj,"hd430Info","")
	zd.initSet(obj,"hd430Rwd","Cshd430Rwd")
	zd.initSet(obj,"hd430Yao","Cshd430Yao")
	zd.initSet(obj,"hd431Buy","CShd431Buy")
	zd.initSet(obj,"hd431Get",maker.SCT_CShd431Get())
	zd.initSet(obj,"hd431Info","CxzcInfo")
	zd.initSet(obj,"hd431Rank","CxzcInfo")
	zd.initSet(obj,"hd431Ranking","CxzcInfo")
	zd.initSet(obj,"hd431Recharge",maker.SCT_CShd431Get())
	zd.initSet(obj,"hd431Zou","CShd431Zou")
	zd.initSet(obj,"hd431exchange",maker.SCT_CShd431Get())
	zd.initSet(obj,"hd431shop","CxzcInfo")
	zd.initSet(obj,"hd435Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd437Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd437Rwd","")
	zd.initSet(obj,"hd437buy","CxghdBuy")
	zd.initSet(obj,"hd437exchange",maker.SCT_IDCOUNT())
	zd.initSet(obj,"hd437getRwd","DnGetRecharge")
	zd.initSet(obj,"hd437paihang","")
	zd.initSet(obj,"hd437play","CxghdPlay")
	zd.initSet(obj,"hd444Follow",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd444Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd444Rwd",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd445Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd445Rwd",maker.SCT_Hd445getRwd())
	zd.initSet(obj,"hd456Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd456Rwd","")
	zd.initSet(obj,"hd456buy","CxghdBuy")
	zd.initSet(obj,"hd456exchange","CxghdExchange")
	zd.initSet(obj,"hd456getRwd","DnGetRecharge")
	zd.initSet(obj,"hd456paihang","")
	zd.initSet(obj,"hd456play","CxghdPlay")
	zd.initSet(obj,"hd457Info",maker.SCT_NULL())
	zd.initSet(obj,"hd457Rwd","Cxhd457Rwd")
	zd.initSet(obj,"hd458Info",maker.SCT_NULL())
	zd.initSet(obj,"hd458Rwd","Cxhd458Rwd")
	zd.initSet(obj,"hd459Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd459buy","NewyearhdBuy")
	zd.initSet(obj,"hd459exchange","CxghdExchange")
	zd.initSet(obj,"hd459getmyrwd","Jtgetmyrwd")
	zd.initSet(obj,"hd459paihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd459play","TreasurehdPlay")
	zd.initSet(obj,"hd464Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd464Jieqian",maker.SCT_Null())
	zd.initSet(obj,"hd464Qiuqian",maker.SCT_Null())
	zd.initSet(obj,"hd465Getrwd",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd465Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd466Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd468Buy","NewyearhdBuy")
	zd.initSet(obj,"hd468Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd471Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd471Paihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd471Paiqian","Cxhd471Paiqian")
	zd.initSet(obj,"hd472Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd472buy","NewyearhdBuy")
	zd.initSet(obj,"hd472exchange","CxghdExchange")
	zd.initSet(obj,"hd472paihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd472play","TreasurehdPlay")
	zd.initSet(obj,"hd477Get","CShd339Get")
	zd.initSet(obj,"hd477Hua","CShd339Hua")
	zd.initSet(obj,"hd477Info","CxzcInfo")
	zd.initSet(obj,"hd477exchange","CShd339Get")
	zd.initSet(obj,"hd477paihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd477shop","CxzcInfo")
	zd.initSet(obj,"hd478Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd478getrwd","NewyearhdPlay")
	zd.initSet(obj,"hd479Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd479getrwd","CS_fbAndlink")
	zd.initSet(obj,"hd480Info","")
	zd.initSet(obj,"hd481Info","")
	zd.initSet(obj,"hd481Rwd","CS_647openBox")
	zd.initSet(obj,"hd487Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd487buy","NewyearhdBuy")
	zd.initSet(obj,"hd487getmyrwd","CxghdExchange")
	zd.initSet(obj,"hd487turn","Syturn")
	zd.initSet(obj,"hd491Buy",maker.SCT_ShopLimit())
	zd.initSet(obj,"hd491Details",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd491GetRwd",maker.SCT_CS_hd491GetRwd())
	zd.initSet(obj,"hd491Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd491MvpRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd491SevInfo",maker.SCT_CS_hd491SevInfo())
	zd.initSet(obj,"hd491SevRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd491Shop",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd492Chat",maker.SCT_ChatMsg())
	zd.initSet(obj,"hd492Check",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd492Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd492Log",maker.SCT_ChatId())
	zd.initSet(obj,"hd492QuRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd492UserRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd493Chat",maker.SCT_ChatMsg())
	zd.initSet(obj,"hd493Check",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd493Get",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd493Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd493Log",maker.SCT_ChatId())
	zd.initSet(obj,"hd493QuRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd493UserRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd495Chat",maker.SCT_ChatMsg())
	zd.initSet(obj,"hd495Check",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd495Info",maker.SCT_NULL())
	zd.initSet(obj,"hd495Log",maker.SCT_ChatId())
	zd.initSet(obj,"hd495UserRank",maker.SCT_NULL())
	zd.initSet(obj,"hd496BuyLv",maker.SCT_CS_HD496BuyLv())
	zd.initSet(obj,"hd496BuyRwd",maker.SCT_CS_HD496BuyRwd())
	zd.initSet(obj,"hd496Info",maker.SCT_Null())
	zd.initSet(obj,"hd496Rwd",maker.SCT_CS_HD496Rwd())
	zd.initSet(obj,"hd496RwdAll",maker.SCT_Null())
	zd.initSet(obj,"hd496TaskAll",maker.SCT_Null())
	zd.initSet(obj,"hd496TaskDaily",maker.SCT_CS_HD496TaskDaily())
	zd.initSet(obj,"hd496TaskWeek",maker.SCT_CS_HD496TaskWeek())
	zd.initSet(obj,"hd508Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd508buy","NewyearhdBuy")
	zd.initSet(obj,"hd508exchange","CxghdExchange")
	zd.initSet(obj,"hd508getGif","CxzcInfo")
	zd.initSet(obj,"hd508getPaihang","")
	zd.initSet(obj,"hd508play","NewyearhdPlay")
	zd.initSet(obj,"hd513Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd513getRwd","DnGetRecharge")
	zd.initSet(obj,"hd514Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd514buy","NewyearhdBuy")
	zd.initSet(obj,"hd514exchange","CxghdExchange")
	zd.initSet(obj,"hd514getKoi",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd514getPaihang","ChrhdPaihang")
	zd.initSet(obj,"hd514play","CShd514play")
	zd.initSet(obj,"hd519Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd519Look",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd519getrwd","DnGetRecharge")
	zd.initSet(obj,"hd522Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd522buy","NewyearhdBuy")
	zd.initSet(obj,"hd522exchange","CxghdExchange")
	zd.initSet(obj,"hd522getPaihang","")
	zd.initSet(obj,"hd522lingqu","CxzcInfo")
	zd.initSet(obj,"hd522play","NewyearhdPlay")
	zd.initSet(obj,"hd526DstwPlay","zqdstwzgwy")
	zd.initSet(obj,"hd526GetLe",maker.SCT_CShd332Up())
	zd.initSet(obj,"hd526GetLo",maker.SCT_CShd332Up())
	zd.initSet(obj,"hd526GetRe",maker.SCT_CShd332Up())
	zd.initSet(obj,"hd526GetRwd","CxzcInfo")
	zd.initSet(obj,"hd526GetSeekRwd","CxzcInfo")
	zd.initSet(obj,"hd526Info","CxzcInfo")
	zd.initSet(obj,"hd526Paihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd526SeekRabbit",maker.SCT_CShd434Lantern())
	zd.initSet(obj,"hd526SetWife","Xq_wife")
	zd.initSet(obj,"hd526buy","NewyearhdBuy")
	zd.initSet(obj,"hd526exchange","CxghdExchange")
	zd.initSet(obj,"hd526play",maker.SCT_CShd434Play())
	zd.initSet(obj,"hd528Get","CShd339Get")
	zd.initSet(obj,"hd528GetChip","CxzcInfo")
	zd.initSet(obj,"hd528Hua","CShd339Hua")
	zd.initSet(obj,"hd528Info","CxzcInfo")
	zd.initSet(obj,"hd528Rank","CxzcInfo")
	zd.initSet(obj,"hd528RwdChip","CxzcInfo")
	zd.initSet(obj,"hd528exchange","CShd339Get")
	zd.initSet(obj,"hd528shop","CxzcInfo")
	zd.initSet(obj,"hd530Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd530Tribute",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd531Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd532Info","")
	zd.initSet(obj,"hd532Rwd",maker.SCT_NULL())
	zd.initSet(obj,"hd533Info","")
	zd.initSet(obj,"hd533Rwd",maker.SCT_OldPlayerBackRwd())
	zd.initSet(obj,"hd534Get","CShd339Get")
	zd.initSet(obj,"hd534Hua","CShd339Hua")
	zd.initSet(obj,"hd534Info","CxzcInfo")
	zd.initSet(obj,"hd534Wife","CxghdSetWife")
	zd.initSet(obj,"hd534exchange","CShd339Get")
	zd.initSet(obj,"hd534paihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd534shop","CxzcInfo")
	zd.initSet(obj,"hd535Draw",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd535GetCzRwd",maker.SCT_idBase())
	zd.initSet(obj,"hd535Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd535Rank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd536Chat",maker.SCT_ChatMsg())
	zd.initSet(obj,"hd536Check",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd536Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd536Log",maker.SCT_ChatId())
	zd.initSet(obj,"hd536UserRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd538Buy","hd538BuyParams")
	zd.initSet(obj,"hd538Exchange","hd538ExchangeParams")
	zd.initSet(obj,"hd538Info",maker.SCT_NULL())
	zd.initSet(obj,"hd538Lingqu",maker.SCT_NULL())
	zd.initSet(obj,"hd538Play","hd538PlayParams")
	zd.initSet(obj,"hd538Rank","hd538RankParams")
	zd.initSet(obj,"hd538Rwd","hd538RwdParams")
	zd.initSet(obj,"hd538Skin","hd538SkinParams")
	zd.initSet(obj,"hd541Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd541buy","NewyearhdBuy")
	zd.initSet(obj,"hd541exchange","CxghdExchange")
	zd.initSet(obj,"hd541getPaihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd541getmyrwd","Jtgetmyrwd")
	zd.initSet(obj,"hd541lingqu","CxzcInfo")
	zd.initSet(obj,"hd541play","NewyearhdPlay")
	zd.initSet(obj,"hd544Info","")
	zd.initSet(obj,"hd544Light","CS_hd544Light")
	zd.initSet(obj,"hd544OpenBox","CS_hd544OpenBox")
	zd.initSet(obj,"hd544TaskRwd","CS_hd544TaskRwd")
	zd.initSet(obj,"hd545Info","")
	zd.initSet(obj,"hd545buy","CS_647openBox")
	zd.initSet(obj,"hd546Info","")
	zd.initSet(obj,"hd546buy","CS_647openBox")
	zd.initSet(obj,"hd546getGift","")
	zd.initSet(obj,"hd550Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd550RedBagNum",maker.SCT_CSBagNum())
	zd.initSet(obj,"hd550baoxiang",maker.SCT_CSBoxRwd())
	zd.initSet(obj,"hd550day",maker.SCT_NULL())
	zd.initSet(obj,"hd550open",maker.SCT_CSbeamingBag())
	zd.initSet(obj,"hd555Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd555Rwd","")
	zd.initSet(obj,"hd555buy","CxghdBuy")
	zd.initSet(obj,"hd555exchange","CxghdExchange")
	zd.initSet(obj,"hd555getRwd","DnGetRecharge")
	zd.initSet(obj,"hd555paihang","")
	zd.initSet(obj,"hd555play","CxghdPlay")
	zd.initSet(obj,"hd561Add","CxzcInfo")
	zd.initSet(obj,"hd561Burn","CxzcInfo")
	zd.initSet(obj,"hd561Info","CxzcInfo")
	zd.initSet(obj,"hd561Rwd","CxzcGet")
	zd.initSet(obj,"hd562Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd563Buy","Jtgetmyrwd")
	zd.initSet(obj,"hd563Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd563Rwd","Jtgetmyrwd")
	zd.initSet(obj,"hd565Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd565Rwd","")
	zd.initSet(obj,"hd565buy","CxghdBuy")
	zd.initSet(obj,"hd565exchange","CxghdExchange")
	zd.initSet(obj,"hd565getRwd","DnGetRecharge")
	zd.initSet(obj,"hd565paihang","")
	zd.initSet(obj,"hd565play","CxghdPlay")
	zd.initSet(obj,"hd572AddBless",maker.SCT_CShd434AddBless())
	zd.initSet(obj,"hd572GetGift","CxzcInfo")
	zd.initSet(obj,"hd572GetRwd","CxzcInfo")
	zd.initSet(obj,"hd572Info","CxzcInfo")
	zd.initSet(obj,"hd572Paihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd572exchange","CxghdExchange")
	zd.initSet(obj,"hd572getLantern",maker.SCT_CShd434Lantern())
	zd.initSet(obj,"hd572play",maker.SCT_CShd434Play())
	zd.initSet(obj,"hd573GetBox",maker.SCT_CSBoxRwd())
	zd.initSet(obj,"hd573Info","")
	zd.initSet(obj,"hd573Paihang","")
	zd.initSet(obj,"hd573buy","NewyearhdBuy")
	zd.initSet(obj,"hd573exchange","CxghdExchange")
	zd.initSet(obj,"hd573getSevRwd","")
	zd.initSet(obj,"hd573play","CShd514play")
	zd.initSet(obj,"hd576Buy",maker.SCT_CShd332Buy())
	zd.initSet(obj,"hd576Get",maker.SCT_CShd332Up())
	zd.initSet(obj,"hd576GetLe",maker.SCT_CShd332Up())
	zd.initSet(obj,"hd576GetLo",maker.SCT_CShd332Up())
	zd.initSet(obj,"hd576GetRe",maker.SCT_CShd332Up())
	zd.initSet(obj,"hd576Info","CxzcInfo")
	zd.initSet(obj,"hd576Rank","CxzcInfo")
	zd.initSet(obj,"hd576Ranking","CxzcInfo")
	zd.initSet(obj,"hd576Zou","CShd332Zou")
	zd.initSet(obj,"hd576exchange",maker.SCT_CShd332Up())
	zd.initSet(obj,"hd576shop","CxzcInfo")
	zd.initSet(obj,"hd577Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd577exchange","CxghdExchange")
	zd.initSet(obj,"hd577getdayrwd","Jtgetmyrwd")
	zd.initSet(obj,"hd577paihang","")
	zd.initSet(obj,"hd577play","NewyearhdPlay")
	zd.initSet(obj,"hd579Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd57Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd581Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd581exchange","CxghdExchange")
	zd.initSet(obj,"hd581paihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd581play","NewyearhdPlay")
	zd.initSet(obj,"hd583Info","")
	zd.initSet(obj,"hd583Rwd","")
	zd.initSet(obj,"hd583Tao","CxsdSet")
	zd.initSet(obj,"hd583Task","CxghdBuy")
	zd.initSet(obj,"hd584Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd585Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd585get_rwd","CxznflGetrwd")
	zd.initSet(obj,"hd586GetRwd",maker.SCT_FBshareGetrwd())
	zd.initSet(obj,"hd587First",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd587GetBoxRwd",maker.SCT_CSBoxRwd())
	zd.initSet(obj,"hd587GetHistory",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd587GetRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd587GetRwd",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd587Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd587YaZhu",maker.SCT_IDCOUNT())
	zd.initSet(obj,"hd587ZhuanPan",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd587buy",maker.SCT_IDCOUNT())
	zd.initSet(obj,"hd590Buy",maker.SCT_CxslchdRwd())
	zd.initSet(obj,"hd590Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd591Fan",maker.SCT_Cx591fan())
	zd.initSet(obj,"hd591Get",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd591History",maker.SCT_Cx591History())
	zd.initSet(obj,"hd591Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd591Task",maker.SCT_CxslchdRwd())
	zd.initSet(obj,"hd596Buy",maker.SCT_ryqdUseAndBuy())
	zd.initSet(obj,"hd596Exchange","CxghdExchange")
	zd.initSet(obj,"hd596Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd596Paihang","")
	zd.initSet(obj,"hd596Use",maker.SCT_ryqdUseAndBuy())
	zd.initSet(obj,"hd598Info","CxzcInfo")
	zd.initSet(obj,"hd608DayRwd","")
	zd.initSet(obj,"hd608Exchange","CxghdExchange")
	zd.initSet(obj,"hd608Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd608Rank","")
	zd.initSet(obj,"hd608Rwd","CxGetReward")
	zd.initSet(obj,"hd608Send","CxSendInfo")
	zd.initSet(obj,"hd608WifeList","")
	zd.initSet(obj,"hd608buy",maker.SCT_hd608Buy())
	zd.initSet(obj,"hd623Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd623Rwd","CjghdRwd")
	zd.initSet(obj,"hd624Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd624buy","zqdstwzgwy")
	zd.initSet(obj,"hd624exchange","hd780ExchangeParams")
	zd.initSet(obj,"hd624play","CxzhujiuPlay")
	zd.initSet(obj,"hd624recharge_rwd","CxghdBuy")
	zd.initSet(obj,"hd638Chat",maker.SCT_ChatMsg())
	zd.initSet(obj,"hd638Check",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd638First",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd638GetBoxRwd",maker.SCT_CSBoxRwd())
	zd.initSet(obj,"hd638GetHistory",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd638GetRank",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd638GetRwd",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd638Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd638Log",maker.SCT_ChatId())
	zd.initSet(obj,"hd638Quan","ParamCount")
	zd.initSet(obj,"hd638YaZhu",maker.SCT_IDCOUNT())
	zd.initSet(obj,"hd638ZhuanPan",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd638buy",maker.SCT_IDCOUNT())
	zd.initSet(obj,"hd642Refresh","")
	zd.initSet(obj,"hd643Info","")
	zd.initSet(obj,"hd643Rwd","SC_LimitHero_Heros")
	zd.initSet(obj,"hd644Info","")
	zd.initSet(obj,"hd644Rwd","DnGetRecharge")
	zd.initSet(obj,"hd646Info","")
	zd.initSet(obj,"hd646Mobai","")
	zd.initSet(obj,"hd646PayTail","")
	zd.initSet(obj,"hd646Reserve","")
	zd.initSet(obj,"hd647BuyCandy","CS_647buy")
	zd.initSet(obj,"hd647Info","")
	zd.initSet(obj,"hd647OpenBox","CS_647openBox")
	zd.initSet(obj,"hd647Reset","")
	zd.initSet(obj,"hd647SetJackpot","CS_647jackpot")
	zd.initSet(obj,"hd647TreasureHunt","")
	zd.initSet(obj,"hd647exchange","CS_647exchange")
	zd.initSet(obj,"hd648Buy","CS_hd648Buy")
	zd.initSet(obj,"hd648Info","")
	zd.initSet(obj,"hd648Paihang","CS_hd648Paihang")
	zd.initSet(obj,"hd648Play","CS_hd648Play")
	zd.initSet(obj,"hd648exchange","CS_hd648exchange")
	zd.initSet(obj,"hd650Info",maker.SCT_NULL())
	zd.initSet(obj,"hd650cGroupBuy",maker.SCT_CS_Hd650cGroupBuy())
	zd.initSet(obj,"hd650delemyOrder",maker.SCT_CS_hd650delemyOrder())
	zd.initSet(obj,"hd650fGroupBuy",maker.SCT_CS_Hd650fGroupBuy())
	zd.initSet(obj,"hd650getInfoById",maker.SCT_CS_Hd650cGroupBuy())
	zd.initSet(obj,"hd650singleBuy",maker.SCT_NULL())
	zd.initSet(obj,"hd651Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd651buy","newcjyxbuy")
	zd.initSet(obj,"hd651exchange","newcjyxexchange")
	zd.initSet(obj,"hd651getPaihang","CxzcInfo")
	zd.initSet(obj,"hd651getrwd","CxghdExchange")
	zd.initSet(obj,"hd651lingqu","")
	zd.initSet(obj,"hd651play","newcjyxplay")
	zd.initSet(obj,"hd654Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd654getHeaven",maker.SCT_redpacket())
	zd.initSet(obj,"hd654openHeaven",maker.SCT_redpacket())
	zd.initSet(obj,"hd654openRedPacket","CxghdExchange")
	zd.initSet(obj,"hd655Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd656Buy",maker.SCT_CShd336Buy())
	zd.initSet(obj,"hd656Get",maker.SCT_CShd336Up())
	zd.initSet(obj,"hd656Info","CxzcInfo")
	zd.initSet(obj,"hd656Rank","656hdPaihang")
	zd.initSet(obj,"hd656exchange","hd780ExchangeParams")
	zd.initSet(obj,"hd656play","CShd336Zou")
	zd.initSet(obj,"hd657Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd657Rwd","CjghdRwd")
	zd.initSet(obj,"hd658Buy",maker.SCT_CShd336Buy())
	zd.initSet(obj,"hd658Get",maker.SCT_CShd336Up())
	zd.initSet(obj,"hd658GetSev","CxzcInfo")
	zd.initSet(obj,"hd658Info","CxzcInfo")
	zd.initSet(obj,"hd658Rank","658hdPaihang")
	zd.initSet(obj,"hd658exchange",maker.SCT_idBase())
	zd.initSet(obj,"hd658play","CShd333Buy")
	zd.initSet(obj,"hd668Info","")
	zd.initSet(obj,"hd668Rwd","SL_wife")
	zd.initSet(obj,"hd674Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd680FirstRwd",maker.SCT_CSSevenTaskFirstRwd())
	zd.initSet(obj,"hd680Info","")
	zd.initSet(obj,"hd680SevenRwd",maker.SCT_CSSevenTaskRwd())
	zd.initSet(obj,"hd680buy",maker.SCT_CSSevenTaskRwd())
	zd.initSet(obj,"hd681Info",maker.SCT_NULL())
	zd.initSet(obj,"hd682Check","CS_hd682Params")
	zd.initSet(obj,"hd682Info",maker.SCT_NULL())
	zd.initSet(obj,"hd682Trigger","CS_hd682Params")
	zd.initSet(obj,"hd683Info","")
	zd.initSet(obj,"hd683bb","683hdplay")
	zd.initSet(obj,"hd683buy","683hdbuy")
	zd.initSet(obj,"hd683exchange","CxghdExchange")
	zd.initSet(obj,"hd683log","")
	zd.initSet(obj,"hd683paihang","683hdPaihang")
	zd.initSet(obj,"hd683sq","")
	zd.initSet(obj,"hd685Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd685Paihang","")
	zd.initSet(obj,"hd685agree","mjagree")
	zd.initSet(obj,"hd685breakClub","")
	zd.initSet(obj,"hd685buy","NewyearhdBuy")
	zd.initSet(obj,"hd685chageRand","mjchangeRand")
	zd.initSet(obj,"hd685checkApplication","")
	zd.initSet(obj,"hd685createClub","mjcreateclub")
	zd.initSet(obj,"hd685endGame","mjendGame")
	zd.initSet(obj,"hd685exchange","NewyearhdBuy")
	zd.initSet(obj,"hd685findTeam","mjclubid")
	zd.initSet(obj,"hd685joinForId","mjclubid")
	zd.initSet(obj,"hd685kickout","mjagree")
	zd.initSet(obj,"hd685outClub","mjclubid")
	zd.initSet(obj,"hd685randJoy","")
	zd.initSet(obj,"hd685refuseAll","")
	zd.initSet(obj,"hd685refuseOne","mjagree")
	zd.initSet(obj,"hd685startGame","mjstartGame")
	zd.initSet(obj,"hd687Buy",maker.SCT_CShd336Buy())
	zd.initSet(obj,"hd687Get",maker.SCT_CShd336Up())
	zd.initSet(obj,"hd687Info","CxzcInfo")
	zd.initSet(obj,"hd687Rank","CxzcInfo")
	zd.initSet(obj,"hd687Ranking",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd687Zou","CShd336Zou")
	zd.initSet(obj,"hd687exchange",maker.SCT_CShd336Up())
	zd.initSet(obj,"hd687shop","CxzcInfo")
	zd.initSet(obj,"hd688Check","CS_hd688Params")
	zd.initSet(obj,"hd688Get","CS_hd688Params")
	zd.initSet(obj,"hd688Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd688Trigger","CS_hd688Params")
	zd.initSet(obj,"hd689Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd689buy","NewyearhdBuy")
	zd.initSet(obj,"hd689exchange","CxghdExchange")
	zd.initSet(obj,"hd689paihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd689play","TreasurehdPlay")
	zd.initSet(obj,"hd694DstwPlay","zqdstwzgwy")
	zd.initSet(obj,"hd694GetRwd","CxzcInfo")
	zd.initSet(obj,"hd694GetSeekRwd","CxzcInfo")
	zd.initSet(obj,"hd694Info","CxzcInfo")
	zd.initSet(obj,"hd694Paihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd694SeekRabbit",maker.SCT_CShd434Lantern())
	zd.initSet(obj,"hd694SetWife","Xq_wife")
	zd.initSet(obj,"hd694buy","NewyearhdBuy")
	zd.initSet(obj,"hd694exchange","CxghdExchange")
	zd.initSet(obj,"hd694play",maker.SCT_CShd434Play())
	zd.initSet(obj,"hd700Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd701Chi","CS_hd701chi")
	zd.initSet(obj,"hd701Info","CS_hd701Params")
	zd.initSet(obj,"hd701bflist","CS_hd701Params")
	zd.initSet(obj,"hd701gchi","CS_hd701chig")
	zd.initSet(obj,"hd701go","CS_hd701open")
	zd.initSet(obj,"hd701gogf","")
	zd.initSet(obj,"hd701open","CS_hd701Params")
	zd.initSet(obj,"hd701selfin","CS_hd701Params")
	zd.initSet(obj,"hd711Info","")
	zd.initSet(obj,"hd712Bk",maker.SCT_idBase())
	zd.initSet(obj,"hd712Get",maker.SCT_idBase())
	zd.initSet(obj,"hd712Info","")
	zd.initSet(obj,"hd713Get","")
	zd.initSet(obj,"hd713Info","")
	zd.initSet(obj,"hd714Get",maker.SCT_idBase())
	zd.initSet(obj,"hd714Info","")
	zd.initSet(obj,"hd715Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd715Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd716Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd716Rwd",maker.SCT_CxshdRwd())
	zd.initSet(obj,"hd750Info",maker.SCT_Null())
	zd.initSet(obj,"hd750Rwd",maker.SCT_Null())
	zd.initSet(obj,"hd760Baohu","CS_hd760Baohu")
	zd.initSet(obj,"hd760Buy",maker.SCT_CS_hd760Buy())
	zd.initSet(obj,"hd760Chat","CS_hd760Chat")
	zd.initSet(obj,"hd760ChatCheck","CS_hd760ChatCheck")
	zd.initSet(obj,"hd760ChatLog","CS_hd760ChatLog")
	zd.initSet(obj,"hd760Chushi",maker.SCT_Null())
	zd.initSet(obj,"hd760CityHurt",maker.SCT_CS_Hd760Sevid())
	zd.initSet(obj,"hd760CityInfo",maker.SCT_CS_Hd760Sevid())
	zd.initSet(obj,"hd760Fight",maker.SCT_heroId())
	zd.initSet(obj,"hd760FightYj",maker.SCT_Null())
	zd.initSet(obj,"hd760FindZhuiSha","CS_Hd760FindZhuiSha")
	zd.initSet(obj,"hd760FuChou","CS_Hd760FuChou")
	zd.initSet(obj,"hd760Fuhuo",maker.SCT_Null())
	zd.initSet(obj,"hd760Getrwd",maker.SCT_Null())
	zd.initSet(obj,"hd760Info",maker.SCT_Null())
	zd.initSet(obj,"hd760Log","CS_hd760Log")
	zd.initSet(obj,"hd760OneKeyPlay",maker.SCT_idBase())
	zd.initSet(obj,"hd760PiZhun","CS_Hd760Heroid")
	zd.initSet(obj,"hd760Rank",maker.SCT_CS_Hd760Rank())
	zd.initSet(obj,"hd760Rwd",maker.SCT_CS_hd760Rwd())
	zd.initSet(obj,"hd760Seladd",maker.SCT_CS_Hd760Id())
	zd.initSet(obj,"hd760SetName",maker.SCT_CS_Hd760Id())
	zd.initSet(obj,"hd760Sjtz",maker.SCT_Null())
	zd.initSet(obj,"hd760TiaoZhan","CS_Hd760TiaoZhan")
	zd.initSet(obj,"hd760ZhuiSha","CS_Hd760ZhuiSha")
	zd.initSet(obj,"hd760paiQian",maker.SCT_CS_Hd760Sevid())
	zd.initSet(obj,"hd760yxInfo",maker.SCT_Null())
	zd.initSet(obj,"hd770Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd771Buy","hd771BuyParams")
	zd.initSet(obj,"hd771Exchange","hd771ExchangeParams")
	zd.initSet(obj,"hd771HbRwd","hd771HbRwdParams")
	zd.initSet(obj,"hd771Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd771Light","hd771LightParams")
	zd.initSet(obj,"hd771Play","hd771PlayParams")
	zd.initSet(obj,"hd771Task","hd771TaskParams")
	zd.initSet(obj,"hd772Extract","hd772ExtractParams")
	zd.initSet(obj,"hd772He","hd772HeParams")
	zd.initSet(obj,"hd772Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd772Rwd","hd772RwdParams")
	zd.initSet(obj,"hd777Draw","hd777DrawParams")
	zd.initSet(obj,"hd777Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd777Reset","hd777ResetParams")
	zd.initSet(obj,"hd777Rwd","hd777RwdParams")
	zd.initSet(obj,"hd777Task","hd777TaskParams")
	zd.initSet(obj,"hd780BoxRwd","hd780BoxRwdParams")
	zd.initSet(obj,"hd780Buy","hd780BuyParams")
	zd.initSet(obj,"hd780Chat",maker.SCT_ChatMsg())
	zd.initSet(obj,"hd780ChatCheck",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd780ChatLog",maker.SCT_ChatId())
	zd.initSet(obj,"hd780Exchange","hd780ExchangeParams")
	zd.initSet(obj,"hd780Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd780Play","hd780PlayParams")
	zd.initSet(obj,"hd780Rank","hd780RankParams")
	zd.initSet(obj,"hd780SevRwd","hd780SevRwdParams")
	zd.initSet(obj,"hd780Task","hd780TaskParams")
	zd.initSet(obj,"hd782Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd782Rwd","hd782RwdParams")
	zd.initSet(obj,"hd786Buy",maker.SCT_CS_Hd786Count())
	zd.initSet(obj,"hd786Exchange",maker.SCT_hd786Exchange())
	zd.initSet(obj,"hd786Info",maker.SCT_Null())
	zd.initSet(obj,"hd786Play",maker.SCT_CS_Hd786Count())
	zd.initSet(obj,"hd786RwdBox",maker.SCT_CS_Hd786Id())
	zd.initSet(obj,"hd786RwdTask",maker.SCT_CS_Hd786Id())
	zd.initSet(obj,"hd786SetNoAd",maker.SCT_Null())
	zd.initSet(obj,"hd790Info",maker.SCT_NULL())
	zd.initSet(obj,"hd790Rwd",maker.SCT_NULL())
	zd.initSet(obj,"hd798Info","")
	zd.initSet(obj,"hd799Answer",maker.SCT_survey_answer())
	zd.initSet(obj,"hd799Info","")
	zd.initSet(obj,"hd799get_rwd",maker.SCT_survey_getrwd())
	zd.initSet(obj,"hd800Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd800Rwd",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd801Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd801Rwd","C801Rwd")
	zd.initSet(obj,"hd802Info","")
	zd.initSet(obj,"hd802get",maker.SCT_CS_hd802touch())
	zd.initSet(obj,"hd802getRwd",maker.SCT_CS_hd802touch())
	zd.initSet(obj,"hd802touch",maker.SCT_CS_hd802touch())
	zd.initSet(obj,"hd872Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd872Rwd","CjghdRwd")
	zd.initSet(obj,"hd873Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd873Rwd",maker.SCT_CShdRwd())
	zd.initSet(obj,"hd876GetWife","")
	zd.initSet(obj,"hd876Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd876Rank","CxzcInfo")
	zd.initSet(obj,"hd876Ranking","CxzcInfo")
	zd.initSet(obj,"hd876Rwd","C891Rwd")
	zd.initSet(obj,"hd887Info","")
	zd.initSet(obj,"hd890Info","")
	zd.initSet(obj,"hd891Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd891Rwd","C891Rwd")
	zd.initSet(obj,"hd892Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd892Rwd","C892Rwd")
	zd.initSet(obj,"hd892Smash","C892Smash")
	zd.initSet(obj,"hd893Info","")
	zd.initSet(obj,"hd894Address","hdAddress")
	zd.initSet(obj,"hd894Info","")
	zd.initSet(obj,"hd894Rank","")
	zd.initSet(obj,"hd894Rwd","")
	zd.initSet(obj,"hd895Buy",maker.SCT_CShd336Buy())
	zd.initSet(obj,"hd895Get",maker.SCT_CShd336Up())
	zd.initSet(obj,"hd895Info","CxzcInfo")
	zd.initSet(obj,"hd895Rank","CxzcInfo")
	zd.initSet(obj,"hd895Ranking","CxzcInfo")
	zd.initSet(obj,"hd895Up",maker.SCT_CShd336Up())
	zd.initSet(obj,"hd895Zou","CShd336Zou")
	zd.initSet(obj,"hd895exchange",maker.SCT_CShd336Up())
	zd.initSet(obj,"hd895shop","CxzcInfo")
	zd.initSet(obj,"hd896GetHero","")
	zd.initSet(obj,"hd896Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd896Rank","CxzcInfo")
	zd.initSet(obj,"hd896Ranking","CxzcInfo")
	zd.initSet(obj,"hd896Rwd","C891Rwd")
	zd.initSet(obj,"hd898Info","")
	zd.initSet(obj,"hd899Rwd","DnGetRecharge")
	zd.initSet(obj,"hd900Wife","")
	zd.initSet(obj,"hd901Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd901Rwd","")
	zd.initSet(obj,"hd901buy","CxghdBuy")
	zd.initSet(obj,"hd901exchange","CxghdExchange")
	zd.initSet(obj,"hd901getRwd","DnGetRecharge")
	zd.initSet(obj,"hd901paihang","")
	zd.initSet(obj,"hd901play","CxghdPlay")
	zd.initSet(obj,"hd907AddBless",maker.SCT_CShd434AddBless())
	zd.initSet(obj,"hd907GetGift","CxzcInfo")
	zd.initSet(obj,"hd907GetRwd","CxzcInfo")
	zd.initSet(obj,"hd907Info","CxzcInfo")
	zd.initSet(obj,"hd907Paihang",maker.SCT_CxghdPaihang())
	zd.initSet(obj,"hd907exchange","CxghdExchange")
	zd.initSet(obj,"hd907getLantern",maker.SCT_CShd434Lantern())
	zd.initSet(obj,"hd907play",maker.SCT_CShd434Play())
	zd.initSet(obj,"hd910Info","")
	zd.initSet(obj,"hd922Info",maker.SCT_Null())
	zd.initSet(obj,"hd922Rwd",maker.SCT_CS_hd922Rwd())
	zd.initSet(obj,"hd924GivpUp","")
	zd.initSet(obj,"hd924Info","")
	zd.initSet(obj,"hd924Play","C2048Play")
	zd.initSet(obj,"hd924RefPower","")
	zd.initSet(obj,"hd924SetSkill","C2048Skill")
	zd.initSet(obj,"hd924UseGameItem","C2048GameItem")
	zd.initSet(obj,"hd924UsePowerItem",maker.SCT_IDCOUNT())
	zd.initSet(obj,"hd924buy",maker.SCT_IDCOUNT())
	zd.initSet(obj,"hd924exchange",maker.SCT_IDCOUNT())
	zd.initSet(obj,"hd924paihang","")
	zd.initSet(obj,"hd928Info",maker.SCT_Null())
	zd.initSet(obj,"hd928cj","CS_hd928cj")
	zd.initSet(obj,"hd928exchange",maker.SCT_CS_hdExchange())
	zd.initSet(obj,"hd931DailyBox",maker.SCT_CxxlDailyBox())
	zd.initSet(obj,"hd931Info","")
	zd.initSet(obj,"hd931Move",maker.SCT_CxxlMove())
	zd.initSet(obj,"hd931RankRwd","")
	zd.initSet(obj,"hd931SetMap",maker.SCT_CxxlSetMap())
	zd.initSet(obj,"hd931UseItem",maker.SCT_CxxlUseItem())
	zd.initSet(obj,"hd931buy",maker.SCT_IDCOUNT())
	zd.initSet(obj,"hd931exchange",maker.SCT_IDCOUNT())
	zd.initSet(obj,"hd931paihang","")
	zd.initSet(obj,"hd949Info",maker.SCT_CxshdInfo())
	zd.initSet(obj,"hd949Rwd",maker.SCT_CSLjzxRwd())
	zd.initSet(obj,"hdGetXSRank",maker.SCT_XShdGetRank())
	zd.initSet(obj,"hdList",maker.SCT_ChdList())
	zd.initSet(obj,"titleGo",maker.SCT_CS_hd802touch())
	return obj
end

maker.SCT_Scblessing = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buy_num",0)
	zd.initSet(obj,"qian",zd.makeDataArray(maker.SCT_scqian(),"id"))
	zd.initSet(obj,"sy_num",0)
	return obj
end

maker.SCT_jslist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"gx",0)
	zd.initSet(obj,"hit",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_NpcFavorability = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"favorability",0)
	zd.initSet(obj,"lv",0)
	zd.initSet(obj,"npc_id",0)
	return obj
end

maker.SCT_Scfglc = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_Shdinfo())
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_Shdrwdlc(),"id"))
	return obj
end

maker.SCT_RiskJindu = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"success",0)
	return obj
end

maker.SCT_FchoFuliGuide = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_SC_ClubKuaYueCfgBuff = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"herozzskill",0)
	zd.initSet(obj,"jingying",0)
	return obj
end

maker.SCT_SC_RankComClub = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cname","")
	zd.initSet(obj,"mzname","")
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"servid",0)
	return obj
end

maker.SCT_MapDoc = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"document","")
	return obj
end

maker.SCT_clubbosswin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cbosspkwin",maker.SCT_Scbosspkwin())
	return obj
end

maker.SCT_pmdlist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"items",maker.SCT_items_list())
	zd.initSet(obj,"name","")
	zd.initSet(obj,"rebate",20)
	return obj
end

maker.SCT_SC_cityNews = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hanLinNews",0)
	zd.initSet(obj,"wifePKNews",0)
	return obj
end

maker.SCT_IDCOUNT = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SC_ClubExtendInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cyScoreRwd",0)
	return obj
end

maker.SCT_BHCZHDUserRwdList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CS_ChengJiu = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"do_work",maker.SCT_doWork())
	zd.initSet(obj,"rwd",maker.SCT_ChengJiuRwd())
	return obj
end

maker.SCT_KuattInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"eTime",maker.SCT_KuaHdCdTime())
	zd.initSet(obj,"hd_status",0)
	zd.initSet(obj,"isopen",0)
	zd.initSet(obj,"jie",0)
	zd.initSet(obj,"limit",0)
	zd.initSet(obj,"newSTime",maker.SCT_KuaHdCdTime())
	zd.initSet(obj,"num",100)
	zd.initSet(obj,"rank",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"showTime",0)
	zd.initSet(obj,"yueGao",maker.SCT_KuaHdCdTime())
	zd.initSet(obj,"yushowTime",maker.SCT_KuaHdCdTime())
	return obj
end

maker.SCT_SbossInfoList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_SbossList()))
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_FuserDataHero = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dt",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"senior",0)
	zd.initSet(obj,"shili",0)
	zd.initSet(obj,"skin",0)
	zd.initSet(obj,"zz",0)
	return obj
end

maker.SCT_Server = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"full",0)
	zd.initSet(obj,"he",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"showtime",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"url","")
	return obj
end

maker.SCT_SCSevenDaySignList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"st",0)
	return obj
end

maker.SCT_SC_centralattackzhen = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fshili",0)
	return obj
end

maker.SCT_SC_Bag = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bagList1",zd.makeDataArray(maker.SCT_Thing(),"id"))
	zd.initSet(obj,"bagList2",zd.makeDataArray(maker.SCT_Thing(),"id"))
	zd.initSet(obj,"bag_list",zd.makeDataArray(maker.SCT_Thing(),"id"))
	return obj
end

maker.SCT_cs_skinClearNews = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"skin_type",1)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CS_Guide = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"add_guide",maker.SCT_CS_GuideSpecialGuide())
	zd.initSet(obj,"chooseWife",maker.SCT_CS_GuideChooseWife())
	zd.initSet(obj,"clock",maker.SCT_CS_GuideClock())
	zd.initSet(obj,"getChangePackRwd","")
	zd.initSet(obj,"guide",maker.SCT_UserGuide())
	zd.initSet(obj,"guideHero",maker.SCT_Null())
	zd.initSet(obj,"guideUpguan",maker.SCT_Null())
	zd.initSet(obj,"guideWife",maker.SCT_Null())
	zd.initSet(obj,"kefu",maker.SCT_Null())
	zd.initSet(obj,"login",maker.SCT_Clogin())
	zd.initSet(obj,"mainWife",maker.SCT_CS_GuideChooseWife())
	zd.initSet(obj,"modulePlayStory",maker.SCT_CS_PlayModuleStory())
	zd.initSet(obj,"opt_button",maker.SCT_CS_GuideButton())
	zd.initSet(obj,"opt_button_real",maker.SCT_CS_GuideButtonReal())
	zd.initSet(obj,"randName",maker.SCT_CS_setLang())
	zd.initSet(obj,"setUInfo",maker.SCT_ClearUser())
	zd.initSet(obj,"shuaZhucheng",maker.SCT_Null())
	zd.initSet(obj,"special_guide",maker.SCT_CS_GuideSpecialGuide())
	zd.initSet(obj,"yzApiLog","yzApiLog")
	return obj
end

maker.SCT_SCsocialdressedlist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdNum())
	zd.initSet(obj,"get",1)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_itemBase = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"id","")
	return obj
end

maker.SCT_UserPvb2Win = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bmid",0)
	zd.initSet(obj,"damagelist",zd.makeDataArray(maker.SCT_Pvb2Herodamage(),"id"))
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	return obj
end

maker.SCT_PVP_Info_ladder = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buynum",0)
	zd.initSet(obj,"buynummax",0)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"chumax",0)
	zd.initSet(obj,"chunum",0)
	zd.initSet(obj,"day_cd",maker.SCT_CdLabel())
	zd.initSet(obj,"f_list",zd.makeDataArray(maker.SCT_ladder_list(),"id"))
	zd.initSet(obj,"fitnum",0)
	zd.initSet(obj,"fuser",maker.SCT_ladder_list())
	zd.initSet(obj,"qhid",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"tz_fuid",zd.makeDataArray(maker.SCT_ladder_list(),"id"))
	return obj
end

maker.SCT_SChitlist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hh",0)
	zd.initSet(obj,"hit",0)
	zd.initSet(obj,"name","")
	return obj
end

maker.SCT_CClubBossOpen = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cbid",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CApplyList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid",maker.SCT_Null())
	return obj
end

maker.SCT_RiskStory = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_SCUserDress = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cFrame",0)
	zd.initSet(obj,"frame",0)
	zd.initSet(obj,"head",0)
	zd.initSet(obj,"list",maker.SCT_SCUserDressList())
	zd.initSet(obj,"news",0)
	zd.initSet(obj,"nlist",maker.SCT_SCUserDressNList())
	return obj
end

maker.SCT_SCUserGuide = function()
	local obj = {}
	zd.makeDataTable(obj)
	return obj
end

maker.SCT_SC_frame = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_SCFramelist(),"id"))
	zd.initSet(obj,"news",0)
	zd.initSet(obj,"set",0)
	return obj
end

maker.SCT_KuaMineGrab = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"heros",zd.makeDataArray(maker.SCT_KuaMineOccupyHero()))
	zd.initSet(obj,"key",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_couponIngo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"diamond",0)
	zd.initSet(obj,"expireTime",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"needDiamond",0)
	zd.initSet(obj,"status",0)
	zd.initSet(obj,"time",0)
	return obj
end

maker.SCT_SC_LLBK = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"StarLog",zd.makeDataArray(maker.SCT_SC_LlbkStarLog(),"id"))
	zd.initSet(obj,"cfg",maker.SCT_SC_LlbkCfg())
	zd.initSet(obj,"exchange","ExchangeShop")
	zd.initSet(obj,"info",maker.SCT_SC_LlbkInfo())
	zd.initSet(obj,"need",zd.makeDataArray(maker.SCT_UseItemInfo(),"id"))
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_UseItemInfo()))
	return obj
end

maker.SCT_SC_HDljzx = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_ScLjzxInfo())
	return obj
end

maker.SCT_itemYard = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"roleid",0)
	return obj
end

maker.SCT_BanishDesk = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"desk",1)
	zd.initSet(obj,"deskrwd",zd.makeDataArray(maker.SCT_BanishDeskRwd(),"id"))
	return obj
end

maker.SCT_QianDaoDay = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"days",1)
	zd.initSet(obj,"qiandao",0)
	return obj
end

maker.SCT_SCVersion = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"ver",1)
	return obj
end

maker.SCT_UserName = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"wxOpenid","")
	return obj
end

maker.SCT_CsTsRecover = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_SC_Club = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"applyList",zd.makeDataArray(maker.SCT_SapplyList(),"id"))
	zd.initSet(obj,"bigBossInfo",zd.makeDataArray(maker.SCT_SbossInfo1(),"id"))
	zd.initSet(obj,"bigHeroLog",zd.makeDataArray(maker.SCT_SheroLog(),"id"))
	zd.initSet(obj,"bigWin",maker.SCT_clubbosswin1())
	zd.initSet(obj,"bossInfo",zd.makeDataArray(maker.SCT_SbossInfo(),"id"))
	zd.initSet(obj,"bossInfoList",maker.SCT_SbossInfoList())
	zd.initSet(obj,"bossft",zd.makeDataArray(maker.SCT_FightList(),"id"))
	zd.initSet(obj,"clubExtendDailyInfo",maker.SCT_SC_ClubExtendDailyInfo())
	zd.initSet(obj,"clubExtendInfo",maker.SCT_SC_ClubExtendInfo())
	zd.initSet(obj,"clubInfo",maker.SCT_SClubInfo())
	zd.initSet(obj,"clubKuaCszr",maker.SCT_SCclubKuaCszr())
	zd.initSet(obj,"clubKuaInfo",maker.SCT_SCclubKuaInfo())
	zd.initSet(obj,"clubKuaMsg",maker.SCT_SCclubKuaMsg())
	zd.initSet(obj,"clubKuaWin",maker.SCT_SCclubKuaWin())
	zd.initSet(obj,"clubKuaYueCfg",maker.SCT_SC_ClubKuaYueCfg())
	zd.initSet(obj,"clubKuaYueInfo",maker.SCT_SC_ClubKuaYueInfo())
	zd.initSet(obj,"clubKuahit",maker.SCT_SCclubKuahitmyf())
	zd.initSet(obj,"clubKualooklog",zd.makeDataArray(maker.SCT_SCclubKualooklog(),"id"))
	zd.initSet(obj,"clubKuapklog",zd.makeDataArray(maker.SCT_SCclubKualog(),"id"))
	zd.initSet(obj,"clubKuapkrwd",maker.SCT_SCclubKuapkrwd())
	zd.initSet(obj,"clubKuapkzr",maker.SCT_SCclubKuapkzr())
	zd.initSet(obj,"clubList",zd.makeDataArray(maker.SCT_SClubList(),"id"))
	zd.initSet(obj,"clubLog",zd.makeDataArray(maker.SCT_SclubLog(),"id"))
	zd.initSet(obj,"heroLog",zd.makeDataArray(maker.SCT_SheroLog(),"id"))
	zd.initSet(obj,"hitRank",zd.makeDataArray(maker.SCT_jslist()))
	zd.initSet(obj,"houseHoldReset",maker.SCT_SC_houseHoldReset())
	zd.initSet(obj,"householdInfo",zd.makeDataArray(maker.SCT_HmembersInfo(),"id"))
	zd.initSet(obj,"householdcj",zd.makeDataArray(maker.SCT_Householdcj(),"id"))
	zd.initSet(obj,"householdft",zd.makeDataArray(maker.SCT_FightList(),"id"))
	zd.initSet(obj,"kuaHeroList",zd.makeDataArray(maker.SCT_FightList(),"id"))
	zd.initSet(obj,"memberInfo",maker.SCT_SMemberInfo())
	zd.initSet(obj,"msmyScore",maker.SCT_MsmyScore())
	zd.initSet(obj,"msscoreRank",zd.makeDataArray(maker.SCT_fUserInfo(),"id"))
	zd.initSet(obj,"myClubRid",maker.SCT_SCmyClubRid())
	zd.initSet(obj,"selectBuild",zd.makeDataArray(maker.SCT_SCselectBuild(),"id"))
	zd.initSet(obj,"shareCD",maker.SCT_SCclubShareCD())
	zd.initSet(obj,"shopList",zd.makeDataArray(maker.SCT_SShopList(),"id"))
	zd.initSet(obj,"transInfo",zd.makeDataArray(maker.SCT_membersInfo(),"id"))
	zd.initSet(obj,"uidLog",maker.SCT_SuidLog())
	zd.initSet(obj,"win",maker.SCT_clubbosswin())
	return obj
end

maker.SCT_SC_zcjbhuodong = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg",maker.SCT_Szcjbcfg())
	zd.initSet(obj,"user",maker.SCT_Szcjjuser())
	return obj
end

maker.SCT_LaoFangWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"shouyawin","ShouYaWin")
	return obj
end

maker.SCT_deskData = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"hid",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_Shdcfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"eTime",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"news",0)
	zd.initSet(obj,"pindex",0)
	zd.initSet(obj,"sTime",0)
	zd.initSet(obj,"showTime",0)
	zd.initSet(obj,"title","")
	zd.initSet(obj,"type",1)
	return obj
end

maker.SCT_zpflcfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"award",zd.makeDataArray(maker.SCT_award_list()))
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"payyb",0)
	zd.initSet(obj,"preview",zd.makeDataArray(maker.SCT_award_list()))
	zd.initSet(obj,"preview2",zd.makeDataArray(maker.SCT_award_list()))
	zd.initSet(obj,"times",3)
	return obj
end

maker.SCT_SapplyList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"chatFrame",0)
	zd.initSet(obj,"chenghao",0)
	zd.initSet(obj,"dress",0)
	zd.initSet(obj,"frame",0)
	zd.initSet(obj,"head",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"job",1)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"name","")
	zd.initSet(obj,"sex",1)
	zd.initSet(obj,"shili",0)
	return obj
end

maker.SCT_CsRiskchangeTexiao = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_CS_getskin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dc",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"itemid",0)
	return obj
end

maker.SCT_CxxlDailyBox = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_NoticeMsg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"body","")
	zd.initSet(obj,"dateInfo","")
	zd.initSet(obj,"gid","")
	zd.initSet(obj,"header","")
	zd.initSet(obj,"pid","")
	zd.initSet(obj,"title","")
	return obj
end

maker.SCT_blessVaild = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_QxCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"change_bless_use",0)
	zd.initSet(obj,"cz_money",0)
	zd.initSet(obj,"exchange",zd.makeDataArray("ExchangeList","id"))
	zd.initSet(obj,"rand_get",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"recover_money",0)
	zd.initSet(obj,"rwd","NewYearrwdType")
	zd.initSet(obj,"shenmi",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"shop",zd.makeDataArray(maker.SCT_QxCfgShop()))
	zd.initSet(obj,"today",maker.SCT_CdLabel())
	return obj
end

maker.SCT_UseItemInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",1)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"kind",1)
	return obj
end

maker.SCT_SC_centralattackcityinfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"shili",0)
	zd.initSet(obj,"user",maker.SCT_UserEasyData())
	return obj
end

maker.SCT_FuLiWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"shenji",zd.makeDataArray(maker.SCT_ShenJiWin(),"id"))
	return obj
end

maker.SCT_MoonClubFuli = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"first_build",0)
	zd.initSet(obj,"is_moon",0)
	zd.initSet(obj,"less_num",0)
	zd.initSet(obj,"second_build",0)
	return obj
end

maker.SCT_VipFuLiType = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CS_GuideClock = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"no",0)
	return obj
end

maker.SCT_CS_ladder = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buyfight",maker.SCT_Null())
	zd.initSet(obj,"chushi",maker.SCT_Null())
	zd.initSet(obj,"come",maker.SCT_Null())
	zd.initSet(obj,"exchange",maker.SCT_CShopChange())
	zd.initSet(obj,"fight",maker.SCT_heroId())
	zd.initSet(obj,"findzhuisha",maker.SCT_Fuid())
	zd.initSet(obj,"fuchou",maker.SCT_FuidHid())
	zd.initSet(obj,"getMingren","")
	zd.initSet(obj,"getMyRank",maker.SCT_NULL())
	zd.initSet(obj,"getRank",maker.SCT_Null())
	zd.initSet(obj,"getYxRank",maker.SCT_NULL())
	zd.initSet(obj,"getrwd",maker.SCT_Null())
	zd.initSet(obj,"ladder",maker.SCT_Null())
	zd.initSet(obj,"oneKeyPlay",maker.SCT_idBase())
	zd.initSet(obj,"pizun",maker.SCT_Null())
	zd.initSet(obj,"seladd","YaMenAddId")
	zd.initSet(obj,"shopRefresh",maker.SCT_CShopRefresh())
	zd.initSet(obj,"tiaozhan",maker.SCT_FuidHid2())
	zd.initSet(obj,"yamenhistory",maker.SCT_ChatId())
	zd.initSet(obj,"zhuisha",maker.SCT_FuidHid2())
	return obj
end

maker.SCT_CxHbSend = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CSqxzbCid = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid",0)
	return obj
end

maker.SCT_SkilInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"level",1)
	return obj
end

maker.SCT_BHCZHDUserCz = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	return obj
end

maker.SCT_zhengWuAct = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"act",0)
	return obj
end

maker.SCT_Risktexiaolist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_CSkuaPKrwdget = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_HuntRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"baseRwd",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"heroes",zd.makeDataArray("cabinetHeroes","id"))
	zd.initSet(obj,"randRwd",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	return obj
end

maker.SCT_RiskPower = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",0)
	zd.initSet(obj,"jindu",0)
	zd.initSet(obj,"max",0)
	zd.initSet(obj,"new",0)
	zd.initSet(obj,"power",0)
	zd.initSet(obj,"tired",0)
	return obj
end

maker.SCT_CS_Discord = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"jump",maker.SCT_NULL())
	zd.initSet(obj,"receive",maker.SCT_NULL())
	return obj
end

maker.SCT_HeroSkinList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hid",0)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_SkinInfo(),"id"))
	return obj
end

maker.SCT_CS_HD496TaskDaily = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SC_centralattackherozhen = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"city",0)
	zd.initSet(obj,"heros","")
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"keng",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"shili",0)
	return obj
end

maker.SCT_FuLiFBDC = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dc",maker.SCT_FuLiAddfbdc())
	zd.initSet(obj,"fb",maker.SCT_FuLiAddfbdc())
	return obj
end

maker.SCT_BanishDays = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",100)
	return obj
end

maker.SCT_SC_Order = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"back",maker.SCT_Sback())
	zd.initSet(obj,"orderstate",zd.makeDataArray(maker.SCT_Sc_OrderTest()))
	zd.initSet(obj,"rorder",maker.SCT_Srorder())
	zd.initSet(obj,"rshop",zd.makeDataArray(maker.SCT_Srshop(),"id"))
	zd.initSet(obj,"vipexp",zd.makeDataArray(maker.SCT_Svipexp(),"id"))
	return obj
end

maker.SCT_SC_Notice = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"actPics",zd.makeDataArray(maker.SCT_ActNoticePic()))
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_NoticeMsg()))
	zd.initSet(obj,"listNew",zd.makeDataArray(maker.SCT_NoticeMsg()))
	return obj
end

maker.SCT_SkinHd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hid",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_ScountryMemberList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"chatFrame",0)
	zd.initSet(obj,"chenghao",0)
	zd.initSet(obj,"dress",0)
	zd.initSet(obj,"frame",0)
	zd.initSet(obj,"head",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"job",1)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"post",0)
	zd.initSet(obj,"sex",1)
	zd.initSet(obj,"shili",0)
	return obj
end

maker.SCT_SC_firstRecharge = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buy",0)
	return obj
end

maker.SCT_RiskBosslist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bossname","")
	zd.initSet(obj,"hp",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"x",0)
	zd.initSet(obj,"y",0)
	return obj
end

maker.SCT_JiuLouWinYhNew = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"allcredit",0)
	zd.initSet(obj,"allep",0)
	zd.initSet(obj,"allscore",0)
	zd.initSet(obj,"bad",0)
	zd.initSet(obj,"isover",0)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_yhnewlist(),"id"))
	zd.initSet(obj,"maxnum",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"oldtype",0)
	return obj
end

maker.SCT_CS = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"gameMachine",maker.SCT_CS_GameMachine())
	zd.initSet(obj,"gm",maker.SCT_CS_GM())
	zd.initSet(obj,"guide",maker.SCT_CS_Guide())
	zd.initSet(obj,"hero",maker.SCT_CS_Hero())
	zd.initSet(obj,"item",maker.SCT_CS_Item())
	zd.initSet(obj,"login",maker.SCT_CS_Login())
	zd.initSet(obj,"mail",maker.SCT_CS_Mail())
	zd.initSet(obj,"map",maker.SCT_CS_Map())
	zd.initSet(obj,"order",maker.SCT_CS_Order())
	zd.initSet(obj,"recode",maker.SCT_CS_Code())
	zd.initSet(obj,"shop",maker.SCT_CS_Shop())
	zd.initSet(obj,"story",maker.SCT_CS_Story())
	zd.initSet(obj,"task",maker.SCT_CS_Task())
	zd.initSet(obj,"user",maker.SCT_CS_User())
	return obj
end

maker.SCT_CClubBossInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid",maker.SCT_Null())
	return obj
end

maker.SCT_SjlShopfresh = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fcost",0)
	zd.initSet(obj,"fmax",0)
	zd.initSet(obj,"fnum",0)
	return obj
end

maker.SCT_jingYingId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"jyid",0)
	return obj
end

maker.SCT_CS_Friends = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fRefuseApply",maker.SCT_FRefuseApply())
	zd.initSet(obj,"fapply",maker.SCT_Fuid())
	zd.initSet(obj,"fapplylist",maker.SCT_Null())
	zd.initSet(obj,"ffchat",maker.SCT_Fuid())
	zd.initSet(obj,"fhistory",maker.SCT_CFhistory())
	zd.initSet(obj,"flist",maker.SCT_Null())
	zd.initSet(obj,"fllist",maker.SCT_Null())
	zd.initSet(obj,"fno",maker.SCT_Fuid())
	zd.initSet(obj,"fok",maker.SCT_Fuid())
	zd.initSet(obj,"frchat",maker.SCT_Fuid())
	zd.initSet(obj,"fschat",maker.SCT_Sfschat())
	zd.initSet(obj,"fssub",maker.SCT_Fuid())
	zd.initSet(obj,"fsub",maker.SCT_Fuid())
	zd.initSet(obj,"getAllJl",maker.SCT_Null())
	zd.initSet(obj,"getJl",maker.SCT_Fuid())
	zd.initSet(obj,"getNew",maker.SCT_Null())
	zd.initSet(obj,"jlList",maker.SCT_Null())
	zd.initSet(obj,"qjlist",maker.SCT_Null())
	zd.initSet(obj,"qjvisit",maker.SCT_Fuid())
	zd.initSet(obj,"sendAllJl",maker.SCT_Null())
	zd.initSet(obj,"sendJl",maker.SCT_Fuid())
	return obj
end

maker.SCT_SkinGetRank = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SC_Task = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"tmain",maker.SCT_Stmain())
	return obj
end

maker.SCT_SC_Hero = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"heroCj",zd.makeDataArray(maker.SCT_HeroChengjiu(),"id"))
	zd.initSet(obj,"heroFigure",zd.makeDataArray(maker.SCT_HeroFigure(),"id"))
	zd.initSet(obj,"heroList",zd.makeDataArray(maker.SCT_HeroInfo(),"id"))
	zd.initSet(obj,"onekey",maker.SCT_onKeyUp())
	zd.initSet(obj,"skin",maker.SCT_HeroSkin())
	return obj
end

maker.SCT_BanishRecall = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"did",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CS_Map = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"setAllDocument",maker.SCT_MapDoc())
	zd.initSet(obj,"setDocument",maker.SCT_MapDoc())
	return obj
end

maker.SCT_CS_Chat = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"addblacklist",maker.SCT_BlackId())
	zd.initSet(obj,"club",maker.SCT_ChatMsg())
	zd.initSet(obj,"clubhistory",maker.SCT_ChatId())
	zd.initSet(obj,"country",maker.SCT_ChatMsg())
	zd.initSet(obj,"countryHistory",maker.SCT_ChatId())
	zd.initSet(obj,"getBackDetailList","")
	zd.initSet(obj,"getTargetLanguage",maker.SCT_NULL())
	zd.initSet(obj,"kuafu",maker.SCT_ChatMsg())
	zd.initSet(obj,"kuafuhistory",maker.SCT_ChatId())
	zd.initSet(obj,"mjClubChatCheck","")
	zd.initSet(obj,"mjHuodongChatCheck","")
	zd.initSet(obj,"mjdsClubChat",maker.SCT_ChatMsg())
	zd.initSet(obj,"mjdsClubHistory",maker.SCT_ChatId())
	zd.initSet(obj,"mjdsHuodongChat",maker.SCT_ChatMsg())
	zd.initSet(obj,"mjdsHuodongHistory",maker.SCT_ChatId())
	zd.initSet(obj,"setTargetLanguage",maker.SCT_targetLanguage())
	zd.initSet(obj,"sev",maker.SCT_ChatMsg())
	zd.initSet(obj,"sevhistory",maker.SCT_ChatId())
	zd.initSet(obj,"subblacklist",maker.SCT_BlackId())
	zd.initSet(obj,"translateGeneral",maker.SCT_SourceTextInfo())
	return obj
end

maker.SCT_CSSetUserDress = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CShd336Buy = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_FuLiAddfbdc = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"host",maker.SCT_ItemInfo())
	zd.initSet(obj,"index",0)
	zd.initSet(obj,"link","")
	zd.initSet(obj,"link2","")
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"name","")
	return obj
end

maker.SCT_zg_yjZhengWuAct = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"act",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_ClubCZHDUserRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_ClubCZHDUserRwdList()))
	return obj
end

maker.SCT_ChatPunish = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"t","")
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_SC_DrawHuodong = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg","SCDrawHuodongCfg")
	zd.initSet(obj,"myRankRid","XgMyScore")
	zd.initSet(obj,"sRank",zd.makeDataArray("SCDrawHuodongSRank"))
	zd.initSet(obj,"user","SCDrawHuodongUser")
	zd.initSet(obj,"win","SCDrawHuodongWin")
	zd.initSet(obj,"winyb","SCDrawHuodongWin")
	return obj
end

maker.SCT_HhMake = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"heroid",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_UserGuide = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bmap",0)
	zd.initSet(obj,"gnew",0)
	zd.initSet(obj,"gnew_child",0)
	zd.initSet(obj,"mmap",0)
	zd.initSet(obj,"smap",0)
	return obj
end

maker.SCT_Sneedcfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"price",0)
	zd.initSet(obj,"vip","0")
	return obj
end

maker.SCT_ShenJiWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_WordBossRoot = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"status",0)
	return obj
end

maker.SCT_ScXxlCfgRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_IDCOUNT()))
	zd.initSet(obj,"rand",maker.SCT_SC_ComRankRange())
	return obj
end

maker.SCT_Sjccfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_Shdinfo())
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_Sjchdrwd(),"id"))
	return obj
end

maker.SCT_items_list = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",1)
	zd.initSet(obj,"id",1)
	zd.initSet(obj,"kind",1)
	return obj
end

maker.SCT_ChatMsgInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"gid","")
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"isGM",0)
	zd.initSet(obj,"lang_code","")
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"rm",0)
	zd.initSet(obj,"t",0)
	zd.initSet(obj,"time",0)
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"user",maker.SCT_fUserInfo())
	zd.initSet(obj,"v","")
	return obj
end

maker.SCT_ryqdUseAndBuy = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"sevid",0)
	return obj
end

maker.SCT_ZQCfgUse = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"get",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"limit",0)
	zd.initSet(obj,"need",0)
	return obj
end

maker.SCT_newcjyxfyh = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"need",maker.SCT_ItemInfo())
	zd.initSet(obj,"xqz",maker.SCT_ItemInfo())
	return obj
end

maker.SCT_CClubInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid",maker.SCT_Null())
	return obj
end

maker.SCT_srand = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"re",0)
	zd.initSet(obj,"rs",0)
	return obj
end

maker.SCT_ScTansuoWife = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_GerdanKillWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"score2",0)
	return obj
end

maker.SCT_SC_BeiJing = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bjInfo",maker.SCT_CHinfo())
	return obj
end

maker.SCT_HeroChengjiuDcInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dc",0)
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_CorderBack = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",maker.SCT_Null())
	return obj
end

maker.SCT_SkinShopList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"islimit",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"limit",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"need",maker.SCT_ItemInfo())
	zd.initSet(obj,"vip",0)
	return obj
end

maker.SCT_SCclubKuaCszr = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"allnum",0)
	zd.initSet(obj,"allshili",0)
	zd.initSet(obj,"clevel",0)
	zd.initSet(obj,"cname","")
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_SCcslist(),"id"))
	zd.initSet(obj,"mzpic",maker.SCT_SCmzpic())
	zd.initSet(obj,"post",maker.SCT_SCpost())
	zd.initSet(obj,"servid",0)
	return obj
end

maker.SCT_HblastHb = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"stime",0)
	return obj
end

maker.SCT_Sc2048Hero = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"epskill",0)
	zd.initSet(obj,"hero_id",0)
	zd.initSet(obj,"maxSingScore",0)
	zd.initSet(obj,"rank_score",0)
	zd.initSet(obj,"skill_id",0)
	return obj
end

maker.SCT_NewYearBag = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"baozu",0)
	zd.initSet(obj,"yanhua",0)
	return obj
end

maker.SCT_CShopInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",maker.SCT_Null())
	return obj
end

maker.SCT_MoBai = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_HbreceiveRedList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_SC_FourGoodBase = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bought",0)
	zd.initSet(obj,"buyLvCfg",maker.SCT_SC_FourGoodBuyLevelCfg())
	zd.initSet(obj,"each",0)
	zd.initSet(obj,"exp",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"max",0)
	zd.initSet(obj,"reset",0)
	zd.initSet(obj,"rule","")
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"week",0)
	zd.initSet(obj,"weeks",0)
	return obj
end

maker.SCT_CS_tansuo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"getInfo",maker.SCT_CsTsMap())
	zd.initSet(obj,"getRwd",maker.SCT_CsTsGetRwd())
	zd.initSet(obj,"giveupEvent",maker.SCT_CsTsGiveup())
	zd.initSet(obj,"processEvent",maker.SCT_CsTsProcess())
	zd.initSet(obj,"recover",maker.SCT_CsTsRecover())
	zd.initSet(obj,"tansuo",maker.SCT_CsTsType())
	return obj
end

maker.SCT_HeroChengjiu = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dc_list",zd.makeDataArray(maker.SCT_HeroChengjiuDcInfo()))
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_RiskMapid = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"mapmid",0)
	zd.initSet(obj,"maxmap",0)
	return obj
end

maker.SCT_CS_useSkinSelect = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"sid",0)
	return obj
end

maker.SCT_PlatVipGiftNotice = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"result",0)
	zd.initSet(obj,"win",maker.SCT_SC_Windows())
	return obj
end

maker.SCT_Sc2048GameData = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"map","")
	zd.initSet(obj,"seed",0)
	return obj
end

maker.SCT_Sc_butler_do = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"check",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CShdRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_ScSkinShop = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_SkinShopList(),"id"))
	return obj
end

maker.SCT_SC_centralattackinfofbscore = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_SC_centralattackinfofbscorelist()))
	return obj
end

maker.SCT_UserEasyData = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"chatFrame",0)
	zd.initSet(obj,"chenghao",0)
	zd.initSet(obj,"dress",0)
	zd.initSet(obj,"exp",0)
	zd.initSet(obj,"frame",0)
	zd.initSet(obj,"head",0)
	zd.initSet(obj,"job",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"maxmap",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"num1",0)
	zd.initSet(obj,"num2",0)
	zd.initSet(obj,"num3",0)
	zd.initSet(obj,"sevid",0)
	zd.initSet(obj,"sex",0)
	zd.initSet(obj,"shili",0)
	zd.initSet(obj,"signName","")
	zd.initSet(obj,"uid",0)
	zd.initSet(obj,"vip",0)
	return obj
end

maker.SCT_HeroInfo1 = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hero_allep",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CS_Task = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"taskdo",maker.SCT_Cdo())
	return obj
end

maker.SCT_CS_Hero = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bindHero",maker.SCT_CS_HerobindHero())
	zd.initSet(obj,"getBindHero",maker.SCT_Null())
	zd.initSet(obj,"heroCjInfo",maker.SCT_Null())
	zd.initSet(obj,"heroCjRwd",maker.SCT_heroCjRwd())
	zd.initSet(obj,"upghskill",maker.SCT_heroGhkillId())
	zd.initSet(obj,"upgrade",maker.SCT_heroId())
	zd.initSet(obj,"upgradeTen",maker.SCT_heroId())
	zd.initSet(obj,"uppkskill",maker.SCT_heroSkillId())
	zd.initSet(obj,"upsenior",maker.SCT_heroId())
	zd.initSet(obj,"upzzskill",maker.SCT_heroSkillIdType())
	return obj
end

maker.SCT_QxUserExchange = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_ChatMsg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"msg","")
	return obj
end

maker.SCT_CsTsProcess = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"gid",0)
	zd.initSet(obj,"param",0)
	return obj
end

maker.SCT_CsFightBoss = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bossid",0)
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"x",0)
	zd.initSet(obj,"y",0)
	return obj
end

maker.SCT_CRiskgetinNewMap = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"mid",0)
	return obj
end

maker.SCT_Schlist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SC_Banish = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"base",maker.SCT_BanishDesk())
	zd.initSet(obj,"days",maker.SCT_BanishDays())
	zd.initSet(obj,"deskCashList",zd.makeDataArray(maker.SCT_BanishDeskCashList()))
	zd.initSet(obj,"herolist",zd.makeDataArray(maker.SCT_BanishHeroList()))
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_BanishList(),"id"))
	return obj
end

maker.SCT_CXxGuest = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",maker.SCT_Null())
	return obj
end

maker.SCT_membersInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"allGx",0)
	zd.initSet(obj,"chatFrame",0)
	zd.initSet(obj,"chenghao",0)
	zd.initSet(obj,"cyBan",0)
	zd.initSet(obj,"dress",0)
	zd.initSet(obj,"fjianshe",0)
	zd.initSet(obj,"frame",0)
	zd.initSet(obj,"gx",0)
	zd.initSet(obj,"head",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"inTime",maker.SCT_CdLabel())
	zd.initSet(obj,"jianshe",0)
	zd.initSet(obj,"job",0)
	zd.initSet(obj,"lessBoosNum",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"loginTime",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"nianka",0)
	zd.initSet(obj,"post",0)
	zd.initSet(obj,"sex",0)
	zd.initSet(obj,"shili",0)
	zd.initSet(obj,"yueka",0)
	return obj
end

maker.SCT_Riskbossxianqing = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"pvewin",maker.SCT_Riskdamage())
	return obj
end

maker.SCT_RiskBiaoxian = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"index",0)
	zd.initSet(obj,"step",0)
	return obj
end

maker.SCT_ScKitchen = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cpid",0)
	zd.initSet(obj,"cpnum",0)
	zd.initSet(obj,"cpnuming",0)
	zd.initSet(obj,"cptotal",0)
	zd.initSet(obj,"kc",0)
	zd.initSet(obj,"makeing",0)
	zd.initSet(obj,"ncpnum",0)
	zd.initSet(obj,"plv",0)
	zd.initSet(obj,"zylv",0)
	return obj
end

maker.SCT_CS_Hd390UpLevel = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SC_PlatVipGift = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"daily_info",maker.SCT_PlatVipGiftReturn())
	zd.initSet(obj,"daily_rwd",maker.SCT_PlatVipGiftNotice())
	zd.initSet(obj,"tequan_info",maker.SCT_PlatVipGiftReturn())
	zd.initSet(obj,"tequan_rwd",maker.SCT_PlatVipGiftNotice())
	return obj
end

maker.SCT_Ssllist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"gid","")
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"lang_code","")
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"name","")
	zd.initSet(obj,"time",0)
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_Cdo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SC_Anniversary = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",zd.makeDataArray("AnniversaryInfoDetail","id"))
	zd.initSet(obj,"leiji","AnniversaryInfoLeiji")
	return obj
end

maker.SCT_Cwyrwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"chid",maker.SCT_Null())
	return obj
end

maker.SCT_survey_answer = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"answer",zd.makeDataArray(maker.SCT_all_answer()))
	return obj
end

maker.SCT_Banishreduce = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"did",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_newCjyxCp = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"zi",zd.makeDataArray("GesyUserWz"))
	return obj
end

maker.SCT_Duration = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"lv",0)
	zd.initSet(obj,"time",0)
	return obj
end

maker.SCT_newcjyxlibao = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"xqz",maker.SCT_ItemInfo())
	return obj
end

maker.SCT_CShd336Up = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_LoginAccount = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"account_name","")
	zd.initSet(obj,"account_type","")
	zd.initSet(obj,"ad_channel","")
	zd.initSet(obj,"ad_subchannel","")
	zd.initSet(obj,"app_ver","")
	zd.initSet(obj,"dev_brand","")
	zd.initSet(obj,"dev_imei","")
	zd.initSet(obj,"dev_lat","")
	zd.initSet(obj,"dev_lon","")
	zd.initSet(obj,"dev_mac","")
	zd.initSet(obj,"dev_model","")
	zd.initSet(obj,"dev_os","")
	zd.initSet(obj,"dev_osver","")
	zd.initSet(obj,"dev_res","")
	zd.initSet(obj,"dev_uuid","")
	zd.initSet(obj,"dh_token","")
	zd.initSet(obj,"from_ch","")
	zd.initSet(obj,"lang","")
	zd.initSet(obj,"logintype","")
	zd.initSet(obj,"nation","")
	zd.initSet(obj,"network_type","")
	zd.initSet(obj,"openid","")
	zd.initSet(obj,"pkg_name","")
	zd.initSet(obj,"platform","")
	zd.initSet(obj,"timestamp","")
	return obj
end

maker.SCT_hd748GetRechargeParams = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CS_Mail = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"delAllMails",maker.SCT_NULL())
	zd.initSet(obj,"delMail",maker.SCT_MailIdParam())
	zd.initSet(obj,"getMail",maker.SCT_Null())
	zd.initSet(obj,"openMail",maker.SCT_MailIdParam())
	zd.initSet(obj,"receiveAllItems",maker.SCT_NULL())
	zd.initSet(obj,"receiveItem",maker.SCT_MailIdParam())
	return obj
end

maker.SCT_SC_zdzd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_ZdzdInfo())
	return obj
end

maker.SCT_SCselectBuild = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"build",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_redpacket = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hid",0)
	return obj
end

maker.SCT_Verify = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"status",1)
	return obj
end

maker.SCT_SC_socialdressed = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"list",maker.SCT_SCsocialdressedall())
	zd.initSet(obj,"news",0)
	zd.initSet(obj,"setChatFrame",0)
	zd.initSet(obj,"setFrame",0)
	zd.initSet(obj,"setHead",0)
	return obj
end

maker.SCT_ScXxlCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dayRwd",zd.makeDataArray(maker.SCT_ScXxlCfgDayRwd()))
	zd.initSet(obj,"exchange",zd.makeDataArray(maker.SCT_ScXxlCfgShop()))
	zd.initSet(obj,"info",maker.SCT_Shdinfo())
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_ScXxlCfgRwd()))
	zd.initSet(obj,"shop",zd.makeDataArray(maker.SCT_ScXxlCfgShop()))
	zd.initSet(obj,"strength",maker.SCT_ScXxlCfgStrength())
	return obj
end

maker.SCT_CS_GuideChooseWife = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"wifeId",0)
	return obj
end

maker.SCT_CShd332Up = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CS_getSelectItem = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"itemid",0)
	return obj
end

maker.SCT_CsMysteryExchange = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"gid",0)
	return obj
end

maker.SCT_SC_longzhoujdbox_Rwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"get",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"need",0)
	return obj
end

maker.SCT_SC_loginModError = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"msg","")
	return obj
end

maker.SCT_SC_ldjcbkhuodong = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg",maker.SCT_SCldjcbkhdCfg())
	zd.initSet(obj,"user",maker.SCT_SCldjcbkhdUser())
	return obj
end

maker.SCT_QxUser = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bless","")
	zd.initSet(obj,"cz",maker.SCT_QxUserCz())
	zd.initSet(obj,"exchange",zd.makeDataArray(maker.SCT_QxUserExchange()))
	zd.initSet(obj,"flower",zd.makeDataArray(maker.SCT_QxUserFlower()))
	zd.initSet(obj,"hd_score",0)
	zd.initSet(obj,"lq",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"score",0)
	return obj
end

maker.SCT_ZQCfgUseSeekRrobRand = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"item",maker.SCT_ItemInfo())
	return obj
end

maker.SCT_GrowFundInfoLevel = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CSSevenTaskFirstRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"wid",0)
	return obj
end

maker.SCT_TransWang = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid",0)
	zd.initSet(obj,"password",0)
	return obj
end

maker.SCT_survey_getrwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"success",0)
	return obj
end

maker.SCT_DerailList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"blacklist",1)
	zd.initSet(obj,"status",1)
	zd.initSet(obj,"switch","")
	return obj
end

maker.SCT_SC_Derail = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"list",maker.SCT_DerailList())
	return obj
end

maker.SCT_ladder_list = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"beijing",0)
	zd.initSet(obj,"chatFrame",0)
	zd.initSet(obj,"chenghao",0)
	zd.initSet(obj,"dress",0)
	zd.initSet(obj,"duanwei",0)
	zd.initSet(obj,"extra_ch","")
	zd.initSet(obj,"frame",0)
	zd.initSet(obj,"guajian",0)
	zd.initSet(obj,"head",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"isHe",0)
	zd.initSet(obj,"job",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"mingrenchenghao",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"num2",0)
	zd.initSet(obj,"num3",0)
	zd.initSet(obj,"num4","")
	zd.initSet(obj,"offlineCh","")
	zd.initSet(obj,"pet_addi",0)
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"sex",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"uid",0)
	zd.initSet(obj,"vip",0)
	zd.initSet(obj,"vipStatus",1)
	return obj
end

maker.SCT_SC_viphuodong = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"service",maker.SCT_Sservice())
	return obj
end

maker.SCT_SC_followGift = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg","FollowGiftCfg")
	zd.initSet(obj,"user","FollowGiftUser")
	return obj
end

maker.SCT_Hd445getRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CJlRanking = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",maker.SCT_Null())
	return obj
end

maker.SCT_FuidHid3 = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid",0)
	zd.initSet(obj,"hid",0)
	zd.initSet(obj,"time",0)
	return obj
end

maker.SCT_FuidHid2 = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid",0)
	zd.initSet(obj,"hid",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_Sservice = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg","Svshdcfg")
	zd.initSet(obj,"recharge",0)
	return obj
end

maker.SCT_newcjyxrecharge = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"get",zd.makeDataArray(maker.SCT_newcjyxrecharge_get(),"id"))
	zd.initSet(obj,"money",0)
	return obj
end

maker.SCT_SC_centralattackinfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"addscore",0)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"fbscore",zd.makeDataArray(maker.SCT_SC_centralattackinfofbscore(),"id"))
	zd.initSet(obj,"freehero",0)
	zd.initSet(obj,"get",0)
	zd.initSet(obj,"money",0)
	zd.initSet(obj,"mycity",maker.SCT_SC_centralattackcity())
	zd.initSet(obj,"qrwd",zd.makeDataArray(maker.SCT_Scbhdrwd(),"id"))
	zd.initSet(obj,"qua",0)
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_Scbhdrwd(),"id"))
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_kwife = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_FightList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"f",0)
	zd.initSet(obj,"h",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CSSevenTaskRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CS_Courtyard = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buy",maker.SCT_Null())
	zd.initSet(obj,"buyShop",maker.SCT_CsCourtyardShop())
	zd.initSet(obj,"change_qian",maker.SCT_blesschange())
	zd.initSet(obj,"comeCourtyard",maker.SCT_Null())
	zd.initSet(obj,"comeFarm",maker.SCT_Null())
	zd.initSet(obj,"comeHunting",maker.SCT_Null())
	zd.initSet(obj,"comeKitchen",maker.SCT_Null())
	zd.initSet(obj,"cpScore",maker.SCT_CscpScore())
	zd.initSet(obj,"enterbless",maker.SCT_Null())
	zd.initSet(obj,"exchange",maker.SCT_CsCourtyardExchange())
	zd.initSet(obj,"getBag",maker.SCT_Null())
	zd.initSet(obj,"getCourtyardDayRwd",maker.SCT_Null())
	zd.initSet(obj,"getRwd",maker.SCT_ParamId())
	zd.initSet(obj,"harvest",maker.SCT_CsCourtyardHarvest())
	zd.initSet(obj,"hunting",maker.SCT_huntDispatchInfo())
	zd.initSet(obj,"is_valid",maker.SCT_blessVaild())
	zd.initSet(obj,"kMenu",maker.SCT_Null())
	zd.initSet(obj,"madeMenu",maker.SCT_CsMadeMenu())
	zd.initSet(obj,"openFarm",maker.SCT_idBase())
	zd.initSet(obj,"plantFarm",maker.SCT_CsCourtyardPlantFarm())
	zd.initSet(obj,"refreshTask",maker.SCT_Null())
	zd.initSet(obj,"seeRwd",maker.SCT_ParamId())
	zd.initSet(obj,"upPan",maker.SCT_Null())
	zd.initSet(obj,"upgradeCourtyard",maker.SCT_Null())
	zd.initSet(obj,"yao",maker.SCT_blessYao())
	return obj
end

maker.SCT_CSSetGuidePass = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_PaoMsgInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"outtime",0)
	return obj
end

maker.SCT_SCclubKuaMsg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"msg","")
	return obj
end

maker.SCT_SC_CourtyardFishing = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"auto",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"my",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"predict",0)
	zd.initSet(obj,"scRwd",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"time",0)
	zd.initSet(obj,"yr",0)
	return obj
end

maker.SCT_RiskMapNow = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"x",0)
	zd.initSet(obj,"y",0)
	return obj
end

maker.SCT_HeroFigure = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"figure",1)
	zd.initSet(obj,"id",1)
	return obj
end

maker.SCT_ScTansuoWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"eid",0)
	zd.initSet(obj,"gid","")
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_rwdItems()))
	return obj
end

maker.SCT_CsRiskGetRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_Shdverinfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"ver",0)
	return obj
end

maker.SCT_CScallBackHero = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hid",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CS_Hd390LevelRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_RiskMapCd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"mid",0)
	zd.initSet(obj,"time",0)
	return obj
end

maker.SCT_SC_centralattackhero = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_SC_centralattackherolist()))
	zd.initSet(obj,"shiliexp",0)
	zd.initSet(obj,"shililv",0)
	return obj
end

maker.SCT_SC_bhczhuodong = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg",zd.makeDataArray(maker.SCT_BHCZHDCfg()))
	zd.initSet(obj,"clubczinfo",zd.makeDataArray(maker.SCT_BHCZHDClub()))
	zd.initSet(obj,"info",maker.SCT_BHCZHDInfo())
	zd.initSet(obj,"user",maker.SCT_BHCZHDUser())
	return obj
end

maker.SCT_SC_Courtyard = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bag",zd.makeDataArray(maker.SCT_IDNUM(),"id"))
	zd.initSet(obj,"base",maker.SCT_ScCourtyardBase())
	zd.initSet(obj,"blessing",maker.SCT_Scblessing())
	zd.initSet(obj,"eatcp",maker.SCT_ScKeatcp())
	zd.initSet(obj,"exchange",zd.makeDataArray(maker.SCT_IDNUM(),"id"))
	zd.initSet(obj,"farm",maker.SCT_ScCourtyardFarm())
	zd.initSet(obj,"fishing",maker.SCT_SC_CourtyardFishing())
	zd.initSet(obj,"fishing_res",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"ft",zd.makeDataArray("Cxhd631Paiqian","id"))
	zd.initSet(obj,"hunting",maker.SCT_ScHunting())
	zd.initSet(obj,"kitchen",maker.SCT_ScKitchen())
	zd.initSet(obj,"menu",maker.SCT_ScKitchenMenu())
	return obj
end

maker.SCT_CgetOrderId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"diamond",0)
	zd.initSet(obj,"id",maker.SCT_Null())
	zd.initSet(obj,"onlinetime",0)
	zd.initSet(obj,"platform",maker.SCT_Null())
	return obj
end

maker.SCT_SCDllhdUserList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"st",0)
	return obj
end

maker.SCT_Scdailysore_rwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_dailyrwditemlist()))
	return obj
end

maker.SCT_CS_Club = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"applyList",maker.SCT_CApplyList())
	zd.initSet(obj,"checkVip",maker.SCT_NULL())
	zd.initSet(obj,"clubApply",maker.SCT_CApply())
	zd.initSet(obj,"clubBigBossHitList",maker.SCT_CClubBossHitList())
	zd.initSet(obj,"clubBigBossInfo",maker.SCT_CClubBossInfo())
	zd.initSet(obj,"clubBigBossOpen",maker.SCT_CClubBossOpen())
	zd.initSet(obj,"clubBigBossPK",maker.SCT_CClubBossPK())
	zd.initSet(obj,"clubBigBossPK_yj",maker.SCT_CClubBossPK())
	zd.initSet(obj,"clubBigBosslog",maker.SCT_CClubBosslog())
	zd.initSet(obj,"clubBossHitList",maker.SCT_CClubBossHitList())
	zd.initSet(obj,"clubBossInfo",maker.SCT_CClubBossInfo())
	zd.initSet(obj,"clubBossOpen",maker.SCT_CClubBossOpen())
	zd.initSet(obj,"clubBossPK",maker.SCT_CClubBossPK())
	zd.initSet(obj,"clubBosslog",maker.SCT_CClubBosslog())
	zd.initSet(obj,"clubCreate",maker.SCT_CCreate())
	zd.initSet(obj,"clubFind",maker.SCT_CFind())
	zd.initSet(obj,"clubHeroBatchCone",maker.SCT_NULL())
	zd.initSet(obj,"clubHeroCone",maker.SCT_CClubHeroCone())
	zd.initSet(obj,"clubInfo",maker.SCT_CClubInfo())
	zd.initSet(obj,"clubInfoClearNoteNews",maker.SCT_CInfoClearNoteNews())
	zd.initSet(obj,"clubInfoSave",maker.SCT_CInfoSave())
	zd.initSet(obj,"clubInfoSaveNote",maker.SCT_CInfoSaveNote())
	zd.initSet(obj,"clubList",maker.SCT_CClubList())
	zd.initSet(obj,"clubMsHeroCone",maker.SCT_CClubHeroCone())
	zd.initSet(obj,"clubName",maker.SCT_CName())
	zd.initSet(obj,"clubPwd",maker.SCT_CclubPwd())
	zd.initSet(obj,"clubRand",maker.SCT_CRand())
	zd.initSet(obj,"dayGongXian",maker.SCT_CDayGongXian())
	zd.initSet(obj,"dayGongXianNum",maker.SCT_NULL())
	zd.initSet(obj,"delClub",maker.SCT_CDelClub())
	zd.initSet(obj,"getClubPwd","")
	zd.initSet(obj,"houseHoldReset",maker.SCT_NULL())
	zd.initSet(obj,"householdCjInfo",maker.SCT_NULL())
	zd.initSet(obj,"householdInfo",maker.SCT_NULL())
	zd.initSet(obj,"householdMake",maker.SCT_HhMake())
	zd.initSet(obj,"householdRankInfo",maker.SCT_CChousehold())
	zd.initSet(obj,"householdRwd",maker.SCT_CChousehold())
	zd.initSet(obj,"isJoin",maker.SCT_CIsJoin())
	zd.initSet(obj,"kuaLookHit",maker.SCT_CSkuaLookHit())
	zd.initSet(obj,"kuaLookWin",maker.SCT_CSkuaLookWin())
	zd.initSet(obj,"kuaPKAdd",maker.SCT_CSkuaPKAdd())
	zd.initSet(obj,"kuaPKBack",maker.SCT_CSkuaPKBack())
	zd.initSet(obj,"kuaPKCszr",maker.SCT_CSkuaPKCszr())
	zd.initSet(obj,"kuaPKMonthMobai",maker.SCT_NULL())
	zd.initSet(obj,"kuaPKbflog",maker.SCT_CSkuaPKbflog())
	zd.initSet(obj,"kuaPKinfo",maker.SCT_CSkuaPKinfo())
	zd.initSet(obj,"kuaPKrwdget",maker.SCT_CSkuaPKrwdget())
	zd.initSet(obj,"kuaPKrwdinfo",maker.SCT_CSkuaPKrwdinfo())
	zd.initSet(obj,"kuaPKusejn",maker.SCT_CSkuaPKusejn())
	zd.initSet(obj,"kuaPKzr",maker.SCT_CSkuaPKBack())
	zd.initSet(obj,"kuaPkMonthInfo",maker.SCT_NULL())
	zd.initSet(obj,"kuaPkMonthRwd",maker.SCT_NULL())
	zd.initSet(obj,"memberPost",maker.SCT_CMemberPost())
	zd.initSet(obj,"noJoin",maker.SCT_CNoJoin())
	zd.initSet(obj,"outClub",maker.SCT_COutClub())
	zd.initSet(obj,"rwdWaterTransStartScore",maker.SCT_NULL())
	zd.initSet(obj,"selectBuild",maker.SCT_CSselectBuild())
	zd.initSet(obj,"sendChat",maker.SCT_NULL())
	zd.initSet(obj,"shopBuy",maker.SCT_CShopBuy())
	zd.initSet(obj,"shopList",maker.SCT_CShopList())
	zd.initSet(obj,"transList",maker.SCT_NULL())
	zd.initSet(obj,"transWang",maker.SCT_TransWang())
	zd.initSet(obj,"yesJoin",maker.SCT_CYesJoin())
	return obj
end

maker.SCT_SC_User = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"guide",maker.SCT_SCUserGuide())
	zd.initSet(obj,"inherit",maker.SCT_SCinherit())
	zd.initSet(obj,"offline",maker.SCT_SCOffline())
	zd.initSet(obj,"paomadeng",zd.makeDataArray(maker.SCT_pmdList(),"id"))
	zd.initSet(obj,"pvb",zd.makeDataArray(maker.SCT_FightList(),"id"))
	zd.initSet(obj,"user",maker.SCT_UserInfo())
	zd.initSet(obj,"verify",maker.SCT_SCUserVerify())
	zd.initSet(obj,"version",maker.SCT_SCVersion())
	return obj
end

maker.SCT_CS_KuaMine = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"eventOpen",maker.SCT_ParamKey())
	zd.initSet(obj,"fMine",maker.SCT_ParamId())
	zd.initSet(obj,"fightLos",maker.SCT_ParamId())
	zd.initSet(obj,"giveup",maker.SCT_MineId())
	zd.initSet(obj,"grab",maker.SCT_KuaMineGrab())
	zd.initSet(obj,"mineInfo",maker.SCT_MineId())
	zd.initSet(obj,"myLogs",maker.SCT_Null())
	zd.initSet(obj,"myMine",maker.SCT_Null())
	zd.initSet(obj,"myResource",maker.SCT_Null())
	zd.initSet(obj,"occupy",maker.SCT_KuaMineOccupy())
	zd.initSet(obj,"probe",maker.SCT_Null())
	zd.initSet(obj,"receive",maker.SCT_ParamId())
	zd.initSet(obj,"receiveLast",maker.SCT_Null())
	zd.initSet(obj,"receive_onekey",maker.SCT_Null())
	zd.initSet(obj,"recovery",maker.SCT_ParamHid())
	zd.initSet(obj,"revenge",maker.SCT_KuaMineRevenge())
	return obj
end

maker.SCT_SCDllhdUser = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bu",0)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_SCDllhdUserList()))
	return obj
end

maker.SCT_Sc_newcjyxCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day_cd",maker.SCT_CdLabel())
	zd.initSet(obj,"fyh",maker.SCT_newcjyxfyh())
	zd.initSet(obj,"info",maker.SCT_Shdinfo())
	zd.initSet(obj,"libao",maker.SCT_newcjyxlibao())
	zd.initSet(obj,"need",0)
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_Scbhdrwd()))
	zd.initSet(obj,"shop",maker.SCT_newcjyxshop())
	return obj
end

maker.SCT_JiuLouWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"joinInfo",maker.SCT_joinInfos())
	zd.initSet(obj,"yhnew",maker.SCT_JiuLouWinYhNew())
	return obj
end

maker.SCT_targetLanguageCode = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"code","")
	return obj
end

maker.SCT_SShopList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"item",maker.SCT_ItemInfo())
	zd.initSet(obj,"lock",0)
	zd.initSet(obj,"maxlimit",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"payGX",0)
	return obj
end

maker.SCT_CS_hd650delemyOrder = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"ids","")
	return obj
end

maker.SCT_llbxrwdInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"getrwd",zd.makeDataArray(maker.SCT_llbxrwdGetrwd()))
	zd.initSet(obj,"time",0)
	return obj
end

maker.SCT_Sback = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cs",2)
	zd.initSet(obj,"currency","")
	zd.initSet(obj,"money",0)
	zd.initSet(obj,"orderid","")
	zd.initSet(obj,"platform","")
	zd.initSet(obj,"productid","")
	zd.initSet(obj,"reward","")
	zd.initSet(obj,"shopid","")
	return obj
end

maker.SCT_CsRiskChangeNpcState = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"x",0)
	zd.initSet(obj,"y",0)
	return obj
end

maker.SCT_VerOpenid = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"openid","")
	zd.initSet(obj,"platform","")
	return obj
end

maker.SCT_CsRiskworkbench = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"x",0)
	zd.initSet(obj,"y",0)
	return obj
end

maker.SCT_Sxshuodong = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg",maker.SCT_Scfg())
	zd.initSet(obj,"cons",0)
	zd.initSet(obj,"has_rwd","")
	zd.initSet(obj,"rwd",0)
	return obj
end

maker.SCT_SChangjing = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_SCJhlist(),"id"))
	zd.initSet(obj,"news",0)
	zd.initSet(obj,"set",0)
	zd.initSet(obj,"ver",1)
	return obj
end

maker.SCT_SC_MonthTask = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"base",maker.SCT_SC_MonthTaskBase())
	zd.initSet(obj,"levelMoreRwd",zd.makeDataArray(maker.SCT_SC_MonthTaskRwdType(),"id"))
	zd.initSet(obj,"levelRwd",zd.makeDataArray(maker.SCT_SC_MonthTaskRwdType(),"id"))
	zd.initSet(obj,"tasks",zd.makeDataArray(maker.SCT_SC_MonthTaskInfo(),"id"))
	return obj
end

maker.SCT_CFind = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid","0")
	return obj
end

maker.SCT_SC_RankComMyClub = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"sev",0)
	return obj
end

maker.SCT_SC_FourGoodPreview = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fashion",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"item",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"ornament",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	return obj
end

maker.SCT_BanishList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"hid",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_heroGhkillId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"sid",0)
	return obj
end

maker.SCT_CS_hd745Rwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_BHCZHDUserRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_BHCZHDUserRwdList()))
	return obj
end

maker.SCT_Pvb2Herodamage = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"damage",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SyhInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"chatFrame",0)
	zd.initSet(obj,"dress",0)
	zd.initSet(obj,"ep",0)
	zd.initSet(obj,"frame",0)
	zd.initSet(obj,"head",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"job",1)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"list",zd.makeDataArray("xwInfo","id"))
	zd.initSet(obj,"ltime",maker.SCT_CdLabel())
	zd.initSet(obj,"maxnum",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"sex",1)
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_QxCfgShop = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"get",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"need",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"sk",0)
	return obj
end

maker.SCT_DnRechange = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"money",0)
	return obj
end

maker.SCT_hd699Reward = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SC_huodonglist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"add",zd.makeDataArray(0))
	zd.initSet(obj,"all",zd.makeDataArray(maker.SCT_Shdallinfo(),"id"))
	zd.initSet(obj,"del",zd.makeDataArray(0))
	zd.initSet(obj,"info",maker.SCT_Shdverinfo())
	return obj
end

maker.SCT_CSkuaPKbflog = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid",0)
	return obj
end

maker.SCT_ScRankRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"rand",maker.SCT_srand())
	return obj
end

maker.SCT_SCldjcbkhdCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"lastrwd",zd.makeDataArray(maker.SCT_SCldjcbkhdCfgRwd()))
	return obj
end

maker.SCT_SC_centralattackpkresulthero = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dt",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"senior",0)
	zd.initSet(obj,"shili",0)
	zd.initSet(obj,"skin",0)
	zd.initSet(obj,"ur",0)
	return obj
end

maker.SCT_SC_dllhuodong = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg",maker.SCT_SCDllhdCfg())
	zd.initSet(obj,"user",maker.SCT_SCDllhdUser())
	return obj
end

maker.SCT_CChousehold = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SclearNewsChatFrame = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CsRiskResetCd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CodeMsg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"key","")
	return obj
end

maker.SCT_Shdallinfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"Hero","0")
	zd.initSet(obj,"bg",0)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"eTime",0)
	zd.initSet(obj,"freeWife","0")
	zd.initSet(obj,"heroSkin","0")
	zd.initSet(obj,"hz","")
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"introduce","")
	zd.initSet(obj,"link","")
	zd.initSet(obj,"news",0)
	zd.initSet(obj,"ntype",0)
	zd.initSet(obj,"pindex",0)
	zd.initSet(obj,"sTime",0)
	zd.initSet(obj,"showTime",0)
	zd.initSet(obj,"show_rwd",zd.makeDataArray(maker.SCT_UseItemInfo()))
	zd.initSet(obj,"switch",0)
	zd.initSet(obj,"title","")
	zd.initSet(obj,"type",1)
	zd.initSet(obj,"win",1)
	zd.initSet(obj,"wz","")
	zd.initSet(obj,"yueTime",0)
	zd.initSet(obj,"yushowTime",0)
	return obj
end

maker.SCT_CCreate = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"isJoin",0)
	zd.initSet(obj,"laoma","")
	zd.initSet(obj,"name","")
	zd.initSet(obj,"outmsg","")
	zd.initSet(obj,"password",0)
	zd.initSet(obj,"qq","")
	return obj
end

maker.SCT_CsRiskclickProtectTask = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"tid",0)
	return obj
end

maker.SCT_CsRiskShop = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_RiskJiguan = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"jiguanid",0)
	zd.initSet(obj,"jindu",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"succesed",0)
	return obj
end

maker.SCT_SCUserOldEp = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"ep",0)
	return obj
end

maker.SCT_XianShiRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"items",0)
	zd.initSet(obj,"sum",0)
	return obj
end

maker.SCT_Fnew = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"status",0)
	return obj
end

maker.SCT_SCbuild = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"harvests",0)
	zd.initSet(obj,"heroes",zd.makeDataArray(maker.SCT_SCBuildHero()))
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"last_time",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"max",0)
	zd.initSet(obj,"maxLevel",0)
	zd.initSet(obj,"next",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"state",0)
	zd.initSet(obj,"warehouse",0)
	return obj
end

maker.SCT_CS_Hd650cGroupBuy = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CxslchdRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_Sc2048Ti = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"label",0)
	zd.initSet(obj,"max_power",0)
	zd.initSet(obj,"next",0)
	zd.initSet(obj,"power",0)
	return obj
end

maker.SCT_ParamIdFuid = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_Thing = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_CS_GuideButtonReal = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"btnKey","")
	zd.initSet(obj,"opt","")
	return obj
end

maker.SCT_CPreyh = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"isOpen",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SC_centralattackcity = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"keng",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_Scfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_Shdinfo())
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_Shdrwd(),"id"))
	return obj
end

maker.SCT_CS_hd491GetRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SCDllhdCfgRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	return obj
end

maker.SCT_CSbuildShou = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_Svsmsg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"comment","")
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_BanishHero = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"did",0)
	zd.initSet(obj,"hid",0)
	return obj
end

maker.SCT_ghSkilInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"level",1)
	zd.initSet(obj,"use",zd.makeDataArray(maker.SCT_UseItemInfo(),"id"))
	return obj
end

maker.SCT_ScXxlCfgDayRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_IDCOUNT()))
	zd.initSet(obj,"need",0)
	return obj
end

maker.SCT_FuLiWXQQ = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"qq",maker.SCT_FuLiAddwxqq())
	zd.initSet(obj,"wx",maker.SCT_FuLiAddwxqq())
	return obj
end

maker.SCT_CShd434Play = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_ClearUser = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"wxOpenid","")
	return obj
end

maker.SCT_PlatVipGiftReturn = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg",zd.makeDataArray(maker.SCT_VipRwdInfo(),"id"))
	return obj
end

maker.SCT_ServerInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"he",1)
	zd.initSet(obj,"id",1)
	zd.initSet(obj,"kua",1)
	return obj
end

maker.SCT_CommonOrder = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"order",0)
	return obj
end

maker.SCT_Scblist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cname","")
	zd.initSet(obj,"name","")
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"uid",0)
	zd.initSet(obj,"vip",0)
	return obj
end

maker.SCT_CFhistory = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SC_Friends = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fapplylist",zd.makeDataArray(maker.SCT_fUserInfo(),"id"))
	zd.initSet(obj,"fapplynews",maker.SCT_Fnew())
	zd.initSet(obj,"flist",maker.SCT_Flist())
	zd.initSet(obj,"fllist",zd.makeDataArray(maker.SCT_Sfllist(),"id"))
	zd.initSet(obj,"fsendlist",maker.SCT_Fsendlist())
	zd.initSet(obj,"news",maker.SCT_Fnew())
	zd.initSet(obj,"qjlist",zd.makeDataArray(maker.SCT_fUserqjlist(),"id"))
	zd.initSet(obj,"sltip",zd.makeDataArray(maker.SCT_Ssltip(),"id"))
	zd.initSet(obj,"sonshili",maker.SCT_SSonshili())
	return obj
end

maker.SCT_hd699ChatByType = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_COutClub = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid",maker.SCT_Null())
	return obj
end

maker.SCT_HitMgfailWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bo",1)
	zd.initSet(obj,"damage",0)
	return obj
end

maker.SCT_SCinandpk = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"f",maker.SCT_SCclubheroinfo())
	zd.initSet(obj,"my",maker.SCT_SCclubheroinfo())
	return obj
end

maker.SCT_SCinherit = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id","")
	return obj
end

maker.SCT_ServerState = zd.Enum:new("king.ServerState","no","normal","crowded","full","line","new","bloken")
maker.SCT_SCUserVerifyRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"rwd",0)
	zd.initSet(obj,"rz",0)
	return obj
end

maker.SCT_SjyInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"isClub",0)
	zd.initSet(obj,"ltime",maker.SCT_CdLabel())
	zd.initSet(obj,"name","")
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_InviteList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"invite_rwd",0)
	zd.initSet(obj,"no","")
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_idBase()))
	zd.initSet(obj,"score",0)
	return obj
end

maker.SCT_SClubList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"allShiLi",0)
	zd.initSet(obj,"exp",0)
	zd.initSet(obj,"fund",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"isJoin",0)
	zd.initSet(obj,"job",0)
	zd.initSet(obj,"laoma","")
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"members",zd.makeDataArray(maker.SCT_membersInfo(),"id"))
	zd.initSet(obj,"mzName","")
	zd.initSet(obj,"name","")
	zd.initSet(obj,"notice","")
	zd.initSet(obj,"outmsg","")
	zd.initSet(obj,"qq","")
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"sex",0)
	zd.initSet(obj,"userNum",0)
	return obj
end

maker.SCT_CShd365Rwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dc",0)
	return obj
end

maker.SCT_CsRiskFollow = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_SC_LoginAccount = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"backUrl","")
	zd.initSet(obj,"gameName","")
	zd.initSet(obj,"ip","")
	zd.initSet(obj,"pftoken","")
	zd.initSet(obj,"thirdPUrl","")
	zd.initSet(obj,"token","")
	zd.initSet(obj,"uid",0)
	zd.initSet(obj,"userAccount","")
	return obj
end

maker.SCT_DSsdCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cz_money",0)
	zd.initSet(obj,"exchange",zd.makeDataArray("ExchangeList","id"))
	zd.initSet(obj,"login",zd.makeDataArray("Sqmcrwd","id"))
	zd.initSet(obj,"rand_get",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"reDay",zd.makeDataArray("Sqmcrwd","id"))
	zd.initSet(obj,"recharge",zd.makeDataArray("Sqmcrwd","id"))
	zd.initSet(obj,"recover_money",0)
	zd.initSet(obj,"rwd","NewYearrwdType")
	zd.initSet(obj,"seek_need",0)
	zd.initSet(obj,"seek_prob_rand",zd.makeDataArray(maker.SCT_ZQCfgUseSeekRrobRand(),"id"))
	zd.initSet(obj,"seek_rwd",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"set","Sdsmset")
	zd.initSet(obj,"shop",zd.makeDataArray("Shopxg","id"))
	zd.initSet(obj,"today",maker.SCT_CdLabel())
	zd.initSet(obj,"use",zd.makeDataArray(maker.SCT_ZQCfgUse(),"id"))
	return obj
end

maker.SCT_CS_hdExchange = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_BanishDeskRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"get",0)
	zd.initSet(obj,"id",1)
	zd.initSet(obj,"num",1)
	zd.initSet(obj,"rwd",0)
	return obj
end

maker.SCT_Sfschat = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid",0)
	zd.initSet(obj,"msg","")
	return obj
end

maker.SCT_SCclubKuaInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"allshili",0)
	zd.initSet(obj,"heroid",0)
	zd.initSet(obj,"hname","")
	zd.initSet(obj,"hpower",0)
	zd.initSet(obj,"ltime",maker.SCT_CdLabel())
	zd.initSet(obj,"mMz",maker.SCT_UserEasyData())
	zd.initSet(obj,"mName","")
	zd.initSet(obj,"mType",0)
	zd.initSet(obj,"msevid",0)
	zd.initSet(obj,"mytype",0)
	zd.initSet(obj,"rwdltime",maker.SCT_CdLabel())
	zd.initSet(obj,"rwdltype",0)
	zd.initSet(obj,"tType",0)
	zd.initSet(obj,"usejn",0)
	zd.initSet(obj,"usejnhid",0)
	return obj
end

maker.SCT_EpSkilInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hlv",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"level",1)
	zd.initSet(obj,"slv",0)
	return obj
end

maker.SCT_clubbosswin1 = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cbosspkwin1",maker.SCT_Scbosspkwin1())
	return obj
end

maker.SCT_Hbmobai = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"money",10)
	zd.initSet(obj,"state",0)
	return obj
end

maker.SCT_Sc2048Info = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_Shdinfo())
	zd.initSet(obj,"rwd","rwdType2048")
	return obj
end

maker.SCT_newcjyxshop = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"items",maker.SCT_ItemInfo())
	zd.initSet(obj,"need",maker.SCT_ItemInfo())
	return obj
end

maker.SCT_SC_ComRankRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"rand",maker.SCT_SC_ComRankRange())
	return obj
end

maker.SCT_CS_HD496Rwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_fourEps = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"e1",0)
	zd.initSet(obj,"e2",0)
	zd.initSet(obj,"e3",0)
	zd.initSet(obj,"e4",0)
	return obj
end

maker.SCT_llbxrwdGetrwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SC_ClubKuaYueCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buff",maker.SCT_SC_ClubKuaYueCfgBuff())
	zd.initSet(obj,"rule","")
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_SC_ComRankRwd()))
	return obj
end

maker.SCT_CS_Order = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"AppFailCallback",maker.SCT_CAppFailCallback())
	zd.initSet(obj,"getOrderId",maker.SCT_CgetOrderId())
	zd.initSet(obj,"orderBack","")
	zd.initSet(obj,"orderReady","")
	zd.initSet(obj,"orderTest",maker.SCT_CtestOrder())
	zd.initSet(obj,"setAge",maker.SCT_CSsetAge())
	return obj
end

maker.SCT_CNoJoin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid",0)
	return obj
end

maker.SCT_ChenhJiulist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"rwd",0)
	return obj
end

maker.SCT_CsTsMap = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"mid",0)
	return obj
end

maker.SCT_SC_centralattackselflog = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"city",0)
	zd.initSet(obj,"fherolist",zd.makeDataArray(maker.SCT_SC_centralattackpkresulthero(),"id"))
	zd.initSet(obj,"fname","")
	zd.initSet(obj,"fuid",0)
	zd.initSet(obj,"herolist",zd.makeDataArray(maker.SCT_SC_centralattackpkresulthero(),"id"))
	zd.initSet(obj,"keng",0)
	zd.initSet(obj,"long",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"team",0)
	zd.initSet(obj,"time",0)
	zd.initSet(obj,"type",0)
	zd.initSet(obj,"win",0)
	return obj
end

maker.SCT_CSkuaPKAdd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hid",0)
	return obj
end

maker.SCT_ScgInfoDirect = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"gift",maker.SCT_ScgInfoDirectType())
	zd.initSet(obj,"info",maker.SCT_CftInfo())
	return obj
end

maker.SCT_SC_czhlhuodong = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"czhlinfo",maker.SCT_Csczhlinfo())
	return obj
end

maker.SCT_ScCourtyardFarm = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_ScCourtyardFarmList(),"id"))
	return obj
end

maker.SCT_FuLiVipId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CS_hd802touch = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CSqxzbPKinfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cid",0)
	zd.initSet(obj,"turn",0)
	return obj
end

maker.SCT_SC_Item = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"itemLimitList",zd.makeDataArray(maker.SCT_limitList()))
	zd.initSet(obj,"itemList",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	return obj
end

maker.SCT_GameMachineDraw = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"ad",0)
	zd.initSet(obj,"times",0)
	return obj
end

maker.SCT_ParamNum = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_QQNum = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"qq","")
	zd.initSet(obj,"qq_rwd",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"status",1)
	zd.initSet(obj,"wx","")
	zd.initSet(obj,"wx_rwd",zd.makeDataArray(maker.SCT_ItemInfo(),"id"))
	zd.initSet(obj,"wx_status",1)
	return obj
end

maker.SCT_UserPveWin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"deil",0)
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"kill",0)
	return obj
end

maker.SCT_RiskExchange = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"finish_cnt",0)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_RiskOrder()))
	zd.initSet(obj,"show_cnt",0)
	zd.initSet(obj,"total_cnt",0)
	zd.initSet(obj,"use_diamond",0)
	zd.initSet(obj,"use_prop",0)
	return obj
end

maker.SCT_cjyxall_news = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"exchange",0)
	zd.initSet(obj,"lingqu",0)
	zd.initSet(obj,"recharge",0)
	return obj
end

maker.SCT_Scbcfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_Shdinfo())
	zd.initSet(obj,"msg","")
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_Scbhdrwd(),"id"))
	zd.initSet(obj,"showNeed","ShdshowNeed")
	return obj
end

maker.SCT_ShopGiftInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cft",maker.SCT_CftInfo())
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_ShopGiftList(),"id"))
	return obj
end

maker.SCT_HeroSkin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dressList",zd.makeDataArray(maker.SCT_SkinHd()))
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_HeroSkinList()))
	zd.initSet(obj,"news",zd.makeDataArray(maker.SCT_HeroSkinNews()))
	return obj
end

maker.SCT_mobileInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"eTime",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"news",0)
	zd.initSet(obj,"sTime",0)
	zd.initSet(obj,"showTime",0)
	zd.initSet(obj,"title","")
	zd.initSet(obj,"type",1)
	return obj
end

maker.SCT_CS_ButlerSetLixian = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"isLx",0)
	return obj
end

maker.SCT_RiskBossDetail = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"bosshp",zd.makeDataArray(maker.SCT_RiskBosshp()))
	zd.initSet(obj,"herolist",zd.makeDataArray(maker.SCT_RiskHerolist()))
	return obj
end

maker.SCT_ladder_myscore = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"duanwei",0)
	zd.initSet(obj,"jie",0)
	zd.initSet(obj,"myName","")
	zd.initSet(obj,"myScore",0)
	zd.initSet(obj,"myScorerank",0)
	zd.initSet(obj,"quname","")
	zd.initSet(obj,"sid",0)
	return obj
end

maker.SCT_FuLiCardId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_doWork = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SC_invitehuodong = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg",maker.SCT_InviteCfg())
	zd.initSet(obj,"user",maker.SCT_InviteList())
	return obj
end

maker.SCT_BHCZHDClub = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"constotal",0)
	zd.initSet(obj,"day",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"uidinfo",zd.makeDataArray(maker.SCT_BHCZUIDINFO()))
	return obj
end

maker.SCT_HbGetHbList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"lucky",0)
	zd.initSet(obj,"money",0)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"uid",0)
	return obj
end

maker.SCT_makeSkinList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"dt",0)
	zd.initSet(obj,"has",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"max",0)
	return obj
end

maker.SCT_SC_ButlerLixianRes = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"army",0)
	zd.initSet(obj,"ch",0)
	zd.initSet(obj,"coin",0)
	zd.initSet(obj,"exp",0)
	zd.initSet(obj,"food",0)
	zd.initSet(obj,"heroEpExp",zd.makeDataArray(maker.SCT_SC_ButlerLixianResIdNum()))
	zd.initSet(obj,"heroPkExp",zd.makeDataArray(maker.SCT_SC_ButlerLixianResIdNum()))
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"jy",0)
	zd.initSet(obj,"py",0)
	zd.initSet(obj,"son",zd.makeDataArray(maker.SCT_SC_ButlerLixianResIdNum()))
	zd.initSet(obj,"sy",0)
	zd.initSet(obj,"time",0)
	zd.initSet(obj,"wife",zd.makeDataArray(maker.SCT_SC_ButlerLixianResIdNum()))
	zd.initSet(obj,"wifeExp",zd.makeDataArray(maker.SCT_SC_ButlerLixianResIdNum()))
	zd.initSet(obj,"wifeLike",zd.makeDataArray(maker.SCT_SC_ButlerLixianResIdNum()))
	zd.initSet(obj,"wifeLove",zd.makeDataArray(maker.SCT_SC_ButlerLixianResIdNum()))
	zd.initSet(obj,"xf",0)
	zd.initSet(obj,"zw",0)
	return obj
end

maker.SCT_CS_abcestralhall = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"ancestralhallInfo",maker.SCT_abcestralhallinto())
	return obj
end

maker.SCT_JdyamenChatId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_HdOneBuyInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cft",maker.SCT_CftInfo())
	zd.initSet(obj,"items",zd.makeDataArray(maker.SCT_OneBuyInfo(),"id"))
	return obj
end

maker.SCT_CShopBuy = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_setInheritPwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"new","")
	zd.initSet(obj,"old","")
	return obj
end

maker.SCT_ladder_chenghao = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"mingren",0)
	return obj
end

maker.SCT_MailIdParam = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SCJmSwitch = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"switch","")
	return obj
end

maker.SCT_CAppFailCallback = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cs1","")
	zd.initSet(obj,"cs2","")
	zd.initSet(obj,"cs3","")
	zd.initSet(obj,"cs4","")
	zd.initSet(obj,"cs5","")
	zd.initSet(obj,"cs6","")
	zd.initSet(obj,"cs7","")
	zd.initSet(obj,"cs8","")
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SCmzpic = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"chenghao",0)
	zd.initSet(obj,"dress",0)
	zd.initSet(obj,"job",0)
	zd.initSet(obj,"level",0)
	zd.initSet(obj,"sex",0)
	return obj
end

maker.SCT_ScgInfoDirectType = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_ScgInfoDirectDetail()))
	return obj
end

maker.SCT_ZdzdInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	return obj
end

maker.SCT_CscpScore = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cpid",0)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"total",0)
	return obj
end

maker.SCT_NULL = function()
	local obj = {}
	zd.makeDataTable(obj)
	return obj
end

maker.SCT_huntDispatchInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hero",zd.makeDataArray("DispatchHeroes","id"))
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CSbuildUp = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_SCUserDressList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cFrame",zd.makeDataArray(maker.SCT_SCUserDressListBase(),"id"))
	zd.initSet(obj,"frame",zd.makeDataArray(maker.SCT_SCUserDressListBase(),"id"))
	zd.initSet(obj,"head",zd.makeDataArray(maker.SCT_SCUserDressListBase(),"id"))
	return obj
end

maker.SCT_QxUserCz = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"money",0)
	zd.initSet(obj,"rwd",0)
	return obj
end

maker.SCT_Scwifepkresult = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"addExp",0)
	zd.initSet(obj,"rankScore",0)
	zd.initSet(obj,"shopScore",0)
	zd.initSet(obj,"win",0)
	return obj
end

maker.SCT_Svsset = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"QQ",0)
	zd.initSet(obj,"line","")
	zd.initSet(obj,"msg",zd.makeDataArray(maker.SCT_Svsmsg()))
	zd.initSet(obj,"name","")
	zd.initSet(obj,"notice","")
	zd.initSet(obj,"qq_msg","")
	zd.initSet(obj,"recharge",0)
	zd.initSet(obj,"vip",0)
	return obj
end

maker.SCT_CS_Item = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buyLimitItem",maker.SCT_itemBase())
	zd.initSet(obj,"getSelectItem",maker.SCT_CS_getSelectItem())
	zd.initSet(obj,"getskin",maker.SCT_CS_getskin())
	zd.initSet(obj,"hecheng",maker.SCT_itemBase())
	zd.initSet(obj,"itemlist",maker.SCT_Null())
	zd.initSet(obj,"useBeast",maker.SCT_itemId())
	zd.initSet(obj,"useForWifes","itemWifeBase")
	zd.initSet(obj,"useSkin",maker.SCT_ItemId())
	zd.initSet(obj,"useSkinSelect",maker.SCT_CS_useSkinSelect())
	zd.initSet(obj,"useforhero",maker.SCT_itemHeroBase())
	zd.initSet(obj,"useforwife","itemWifeBase")
	zd.initSet(obj,"useitem",maker.SCT_itemBase())
	zd.initSet(obj,"userYard",maker.SCT_itemYard())
	return obj
end

maker.SCT_WordShop = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buys",zd.makeDataArray(maker.SCT_WordShopItem(),"id"))
	zd.initSet(obj,"score",0)
	return obj
end

maker.SCT_CsRiskMove = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"x",0)
	zd.initSet(obj,"y",0)
	return obj
end

maker.SCT_CS_Skin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"clearNews",maker.SCT_cs_skinClearNews())
	zd.initSet(obj,"collectBook",maker.SCT_NULL())
	zd.initSet(obj,"getCollectRwd",maker.SCT_idBase())
	zd.initSet(obj,"getRank",maker.SCT_SkinGetRank())
	zd.initSet(obj,"getSkin",maker.SCT_cs_getSkin())
	zd.initSet(obj,"getSkinById",maker.SCT_SkinGetRank())
	zd.initSet(obj,"heroDress",maker.SCT_SkinHd())
	zd.initSet(obj,"heroSkinInfo",maker.SCT_NULL())
	zd.initSet(obj,"inSkin",maker.SCT_NULL())
	zd.initSet(obj,"makeSkin",maker.SCT_NULL())
	zd.initSet(obj,"skin",maker.SCT_NULL())
	zd.initSet(obj,"skinBuy",maker.SCT_cs_getSkinshop())
	zd.initSet(obj,"skinCompose",maker.SCT_SkinGetRank())
	zd.initSet(obj,"upHeroDynamic",maker.SCT_SkinId())
	zd.initSet(obj,"upWifeDynamic",maker.SCT_SkinId())
	zd.initSet(obj,"wifeDress",maker.SCT_SkinWd())
	zd.initSet(obj,"wifeSkinInfo",maker.SCT_NULL())
	return obj
end

maker.SCT_CYesJoin = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"fuid",0)
	return obj
end

maker.SCT_CInfoSave = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"laoma","")
	zd.initSet(obj,"notice","")
	zd.initSet(obj,"outmsg","")
	zd.initSet(obj,"qq","")
	return obj
end

maker.SCT_ChoiceId = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",1)
	return obj
end

maker.SCT_changePackRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"status",0)
	zd.initSet(obj,"tag","")
	return obj
end

maker.SCT_BlackFriDayCfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"rwd",zd.makeDataArray(maker.SCT_Shdrwd(),"id"))
	return obj
end

maker.SCT_SC_shice = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"get",maker.SCT_LiangchenInfo())
	zd.initSet(obj,"liangchen",zd.makeDataArray(maker.SCT_LiangchenInfo(),"id"))
	return obj
end

maker.SCT_blessYao = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SCShopList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hefa",zd.makeDataArray(maker.SCT_SCShopHefa(),"id"))
	zd.initSet(obj,"xian",zd.makeDataArray(maker.SCT_IDNUM(),"id"))
	return obj
end

maker.SCT_KuaHdCdTime = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	return obj
end

maker.SCT_SC_llbxrwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"info",maker.SCT_llbxrwdInfo())
	zd.initSet(obj,"rwdlist",zd.makeDataArray("Gqjtdayrwd","id"))
	return obj
end

maker.SCT_CsMadeMenu = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cpid",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"num",0)
	return obj
end

maker.SCT_CS_hd760Rwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_ScKom = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"get",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"needitem",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"speed",0)
	return obj
end

maker.SCT_HmembersInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"hp",0)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_CtestOrder = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"goodsid","")
	zd.initSet(obj,"shopCid",0)
	return obj
end

maker.SCT_CdLabel = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"label","")
	zd.initSet(obj,"next",0)
	return obj
end

maker.SCT_SelfRids = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"beast",0)
	zd.initSet(obj,"country",0)
	zd.initSet(obj,"guanka",0)
	zd.initSet(obj,"love",0)
	zd.initSet(obj,"mylsshili",0)
	zd.initSet(obj,"shili",0)
	zd.initSet(obj,"shiliKua",0)
	return obj
end

maker.SCT_SCclubShareCD = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"m",0)
	zd.initSet(obj,"t",0)
	return obj
end

maker.SCT_CftInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdLabel())
	zd.initSet(obj,"eTime",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"sTime",0)
	zd.initSet(obj,"title","")
	return obj
end

maker.SCT_CClubHeroCone = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_Cshd413All = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_hd850UseItmeInfo = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"num",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_CSBoxRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_SC_ClubCZHD = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cfg",zd.makeDataArray(maker.SCT_ClubCZHDCfg()))
	zd.initSet(obj,"club",zd.makeDataArray(maker.SCT_ClubCZHDClub()))
	zd.initSet(obj,"log",zd.makeDataArray(maker.SCT_ClubCZHDLog()))
	zd.initSet(obj,"user",maker.SCT_ClubCZHDUser())
	return obj
end

maker.SCT_Srwdcfg = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"item",zd.makeDataArray(maker.SCT_itemBase(),"id"))
	zd.initSet(obj,"max",0)
	return obj
end

maker.SCT_translateGeneral = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id","")
	zd.initSet(obj,"translate_data","")
	return obj
end

maker.SCT_ComMyRank = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"name","")
	zd.initSet(obj,"rid",0)
	zd.initSet(obj,"score",0)
	zd.initSet(obj,"sev",0)
	return obj
end

maker.SCT_CShd434Lantern = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_award_list = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",1)
	zd.initSet(obj,"items",maker.SCT_items_list())
	zd.initSet(obj,"rebate",20)
	return obj
end

maker.SCT_SGetStoryRwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_limitList = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"count",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"limit",0)
	return obj
end

maker.SCT_apostleShop_list = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"buy",0)
	zd.initSet(obj,"id",0)
	zd.initSet(obj,"type",0)
	return obj
end

maker.SCT_SCFramelist = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"cd",maker.SCT_CdNum())
	zd.initSet(obj,"get",1)
	zd.initSet(obj,"id",0)
	return obj
end

maker.SCT_MysteryShop = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"exchange_cnt",0)
	zd.initSet(obj,"exchange_max",0)
	zd.initSet(obj,"list",zd.makeDataArray(maker.SCT_MysteryOrder()))
	zd.initSet(obj,"soup",0)
	zd.initSet(obj,"unlock",0)
	return obj
end

maker.SCT_SCclubKuapkrwd = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"club",zd.makeDataArray(maker.SCT_ItemInfo()))
	zd.initSet(obj,"fcid",0)
	zd.initSet(obj,"flevel",0)
	zd.initSet(obj,"fname","")
	zd.initSet(obj,"fservid",0)
	zd.initSet(obj,"getCname","")
	zd.initSet(obj,"getCuid",0)
	zd.initSet(obj,"isGet",0)
	zd.initSet(obj,"isSet",0)
	zd.initSet(obj,"isWin",0)
	zd.initSet(obj,"is_get",0)
	zd.initSet(obj,"member",zd.makeDataArray(maker.SCT_ItemInfo()))
	return obj
end

maker.SCT_SCclubKualog = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"in",maker.SCT_SCinandpk())
	zd.initSet(obj,"pk",maker.SCT_SCinandpk())
	return obj
end

maker.SCT_Riskdamage = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"damage",0)
	return obj
end

maker.SCT_SC_bigEmoji = function()
	local obj = {}
	zd.makeDataTable(obj)
	zd.initSet(obj,"idlist",zd.makeDataArray(maker.SCT_SC_bigEmojiidlist()))
	zd.initSet(obj,"redtype",zd.makeDataArray(maker.SCT_SC_bigEmojiredtype()))
	return obj
end

return maker
