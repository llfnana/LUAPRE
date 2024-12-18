Audio = Audio or {}
local this = Audio;

this.enableSound = true --是否开启音效
this.enableMusic = true --是否开启音乐

--默认系统AudioID定义
DefaultAudioID = 
{
	ButtonClick = 0,
	LoginScene = 1,
	BaiTianScene = 2,
	YeWanScene = 3,
	NotSatisfied = 57, --罢工音乐
	-- BattleScene = 4,
	-- ClickCampQi = 5, --骑兵营
	UiTip = 6,        --通用提示
	UIResAdd = 7,       --获得奖励
	ZhuanChang = 8,     --云雾转场
	-- BuildingFinish = 9,
	-- ClickCityWall = 10,
	Duqi = 9,             --毒气
	ZiBao = 10,            --丧尸自爆

	openTask = 11,       --打开任务界面
	RcvTaskTipe = 12,    --任务完成提示
	
	OpenGenerator = 14,   --打开净化器
	OpenMaxGenerator = 15, --打开最高净化器
	HideGenerator = 16,    --关闭净化器



	-- Generator  = 13,    --净化器
	-- Dorm = 17,            --宿舍
	-- Carpentry = 18,       --加工厂
	-- Kitchen = 19,          --厨房
	-- Infirmary = 20,   --急救站
	-- Metal = 21,             --金属
	-- HunterCabin = 22,      --养殖场
	-- CoalMine = 23,			--煤矿厂
	-- CollectionStation = 24,  --回收站
	-- IronMine= 25,           --铁矿厂
	-- Watchtower = 26,         --瞭望塔
	-- MachineryFactory= 27,    --机械厂
	-- Metal2= 21,         	--金属
	-- Carpentry2 = 18,		--加工厂
	-- Sawmill = 100,,     --伐木场(无)
	

	BuildConstruction = 28,     --建造中
	BuildComplete = 29,         --建造完成

	ToolUpgrade = 30,          --家具升级

	HeroLevelUp = 31,       --英雄升级
	HeroStarUp = 32,		--英雄升星

	PlayerSick = 33, 		--生病提示
	PlayerDead = 34, 		--死亡提示
	Playerrecovered = 35, 	--恢复健康提示
	PlayerEscape = 36, 		--逃跑提示
	PlayerNotSatisfied = 37, --罢工提示
	jiemiandakai = 38,     --宝箱界面打开
	BoxHuangdong = 39,     --宝箱晃动
	openBox = 40, 		--宝箱打开
	jiangliTanChu = 41, --宝箱奖励弹出
	jianglizhanshi = 42, --宝箱奖励全部展示
	HomeResGather = 43,	
	JingHuaFeng = 44,    --净化器的风
	HuanHu =45,         --小人欢呼
	-- HeroWearEquip = 45,
	-- HeroRelive = 45, --英雄复活
	YanHua = 46, --烟花
	OpenSummary = 47, --打开结算面板
	KaiChe = 49,
	JieSuo = 50, --解锁
	OpenUI = 55, --打开ui
	HideUI = 56, --关闭ui
	GetHero = 58 --获得音效

	-- BuildingClickGoldLand = 48, --主城钻石矿
	-- BuildingLibrary = 49, --点击图书馆
	-- BuildingWareStore = 50, --点击贸易站
	-- BuildingDipHall = 51,--点击外交大厅
	-- BuildingWarHall = 52,--点击军事大厅
	-- MainCityLevelUp = 53,--主城升级成功
	-- GetItemAward = 54,--获得奖励
	-- BuildingSpyTower = 55,--点击哨塔
	-- UICommonClose = 56, --通用关闭
	-- UICommonBack = 57, --通用返回
	-- PowerAdd =  58, --战力增加
	-- UseExpItem =  59, --使用经验道具
	-- ChapterOpen = 60, --章节开启
	-- HomeSomethingUnLock	= 61, -- 功能/兵种/建筑解锁
	-- UseItemSpeedUp	= 62, --使用加速道具
	-- OpenBox			= 63, --宝箱开启音效
	-- GatherSoldierBu = 64, --步兵训练完毕
	-- GatherSoldierQi = 65, --骑兵训练完毕
	-- GatherSoldierFa = 66, --法兵训练完毕
	-- GatherSoldierGong = 67, --弓兵训练完毕
	-- TechnologyFinish = 68, --科技研究完毕
}
ClickBuildAudio = {
	["Generator"]  = 13,    --净化器
	["Dorm"] = 17,            --宿舍
	["Carpentry"] = 18,       --加工厂
	["Kitchen"] = 19,          --厨房
	["Infirmary"] = 20,   --急救站
	["Metal"] = 21,             --金属
	["HunterCabin"] = 22,      --养殖场
	["CoalMine"] = 23,			--煤矿厂
	["CollectionStation"] = 24,  --回收站
	["IronMine"]= 25,           --铁矿厂
	["Watchtower"] = 26,         --瞭望塔
	["MachineryFactory"]= 27,    --机械厂
	["Metal2"]= 21,         	--金属
	["Carpentry2"] = 18,		--加工厂
	["Sawmill"] = 54,           --伐木场
}






function Audio.PlayAudio( audioId )
	if audioId == nil then
		return;
	end
	
	local audioInfo = TbTabAudio[audioId]
	if audioInfo == nil then
		error("not find audio in table! audioId="..audioId);
		return;
	end
	if audioInfo.AudioType == 0 then
		if this.enableSound then
			
			AudioManager:PlaySound( audioInfo.ResName, audioInfo.Volume)
			if audioInfo.loopCount and audioInfo.loopCount > 1 then
				-- 循环播放音效
				for i = 2, audioInfo.loopCount do
					TimeModule.addDelay((i-1) * 1, function()
						AudioManager:PlaySound( audioInfo.ResName, audioInfo.Volume)
					end)
				end
			end
		end
	else
		this.curMusicRes = audioInfo.ResName;
		this.curMusicVolume = audioInfo.Volume;
		if this.enableMusic then
			AudioManager:PlayMusic( audioInfo.ResName, audioInfo.Volume )
			
		end
	end
end

-- 播放开场动画
function Audio.PlayOpeningMovie()
	ShowUISync( UINames.UIBlack )
	AudioManager:PlayVideo("movie.mp4", nil, function()
		HideUI( UINames.UIBlack )
	end, 1920, 1080, 1)
end

--播放新角色开场视频
function Audio.PlayNewPlayerMovie( _finishCallback )
	local ret = AudioManager:PlayVideo("newplotmovie.mp4", nil, _finishCallback, 1920, 822, 2)
	if not ret then
		if _finishCallback ~= nil then
			_finishCallback();
			_finishCallback = nil;
		end
	end
end

function Audio.Stop()
	AudioManager:StopMusic();
end

function Audio.Pause()
	AudioManager:PauseMusic();
end

function Audio.Resume()
	AudioManager:ResumeMusic(this.curMusicRes, this.curMusicVolume);
end

function Audio.SetEnableMusic(_enable)
	if this.enableMusic == _enable then
		return
	end

	this.enableMusic = _enable
	if _enable then
		this.Resume()
	else
		this.Pause()
	end
end

function Audio.SetEnableSound(_enable)
	this.enableSound = _enable
end

function Audio.OnCommonButtonClicked()
	this.PlayAudio( DefaultAudioID.ButtonClick )
	-- this.PlayAudio( DefaultAudioID.LoginScene )
	
end

