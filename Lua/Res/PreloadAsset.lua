

--封装资源预加载调用 



PreloadAsset = PreloadAsset or {}
local this = PreloadAsset;

--启动后Loading时调用
function PreloadAsset.PreloadOnGameLoading()
	if this.PreloadOnGameLoadingDone then
		return;
	end
	this.PreloadOnGameLoadingDone = true;

	log("PreloadAsset.PreloadOnGameLoading")
	ResInterface.PreLoadShader("init.shadervariants");
end


--登录场景可以提前预加载一些资源
function PreloadAsset.PreloadOnLoginSceneIdle()
	if this.PreloadOnLoginSceneIdleDone then
		return;
	end
	this.PreloadOnLoginSceneIdleDone = true;

	--比较大的表格，在这里提前加载避免用时加载卡顿
	-- TableManager:Inst():LoadTable( EnumTableID.TabSoldierInfo )
	-- TableManager:Inst():LoadTable( EnumTableID.TabGeneral )
	-- TableManager:Inst():LoadTable( EnumTableID.Task )
	-- TableManager:Inst():LoadTable( EnumTableID.TabHomeBuilding )
	-- TableManager:Inst():LoadTable( EnumTableID.TabTechnology )
	-- TableManager:Inst():LoadTable( EnumTableID.TabGeneralStarLv )
	-- TableManager:Inst():LoadTable( EnumTableID.TabGeneralLevel )
	-- TableManager:Inst():LoadTable( EnumTableID.TabIcon )

	--预加载主界面
	ResInterface.PreloadAsset(nil, "UIMain.prefab", true, 0 );

	--预加载主界面场景图标
	-- local mainUIIcons = { "home_10_bg.png", "UIActivity_icon_tuijianhuodong2.png", "UIActivity_icon_ziyuanzhigou2.png" };
	-- for i = 1, #mainUIIcons do
	-- 	ResInterface.PreloadAsset( nil, mainUIIcons[i], false, 0 );
	-- end

	collectgarbage("collect")
end


--启动后首次进入主场景时调用
function PreloadAsset.PreloadOnEnterMain()
	if this.PreloadOnEnterMainDone then
		return;
	end		
	this.PreloadOnEnterMainDone = true;

	--预加载玩家头像
	-- local headId = PlayerData:Inst():GetHeadIconId() 
	-- local tabHead = TableManager:Inst():GetTabData(EnumTableID.TabHeadIcon, headId);
	-- local iconTab = TableManager:Inst():GetTabData(EnumTableID.TabIcon, tabHead.IconID)
	-- ResInterface.PreloadAsset(nil, iconTab.IconName..".png", false, 0)
	

	--家园建筑预加载

end








