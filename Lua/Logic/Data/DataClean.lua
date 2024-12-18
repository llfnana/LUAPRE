
DataClean = DataClean or {}

--清理客户端老数据， 登录前调用，用于清理前一个账号的老数据

function DataClean.CleanAllData()

	--清理玩家数据
	--PlayerData:Inst():Clear();
	
	--清理聊天数据
	ChatModule:Inst():Clear();
	
	GeneralLogic.Inst():Clear();

	--GameLogicUtils.Clear();

	--AlarmLogic:Inst():Clear();

	--邮件缓存清理
	MailCommonLogic.ClearCacheData();

	--清理大地图数据
	if SceneManager:Inst():GetCurrentSceneName() ~= SceneNames.BigMapScene then
		BigMapCellDataMgr.Clear();
	end	
	
	--AllianceModule:Inst():Clear();
	
	StoreModule.ClearTecData()
	StoreModule.CleanCityShopData()
	--清理上次的事件缓存
	Event.Reset();
	
	Event.Brocast(EventDefine.OnLotteryDrawClear);
	Event.Brocast(EventDefine.OnPromotionExchangeClear);
	--AssembleModule.ClearCache();
	
	log(">>> DataClean.CleanAllData, Old Data Clear...");
end