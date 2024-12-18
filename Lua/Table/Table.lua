-- Table.lua
-- 表格读取基础类，有需求继承
require "Common/cm_functions"

------------------
TableTempData = {};
TableTempData.AllTableCount = 0;
TableTempData.TableLoadCount = 0;

------------------

BaseTable = class("BaseTable")
function BaseTable:ctor(szFileName)
	self.tabFileName = szFileName;
    --self:loadFile(szFileName);
    if not IsTableLazyLoad then
    	self:CheckLoad();
    end
end


function BaseTable:GetFileName()
	return self.tabFileName;
end

function BaseTable:CheckLoad()
	if not self.isLoad then
		self:loadFile(self.tabFileName);
		self.isLoad = true
	end	
end


-- 获取数据
function BaseTable:GetTable()
	self:CheckLoad();
	return self.TableData;
end

function BaseTable:GetMaxLine()
	self:CheckLoad();
	return self.MaxLine;
end

function BaseTable:GetMaxID()
	self:CheckLoad();
	return self.MaxID;
end

-- 获取一行数据
function BaseTable:GetTabData(id)
	self:CheckLoad();
	local data = self.TableData[tonumber(id)];	
	return data;
end

-- 遍历table callBack(item)
function BaseTable:LoopTable(callBack)
	self:CheckLoad();
	--因为我的现在存的table都是按number[]形式的有可能不连续
	--只能pairs方式，但无法保证顺序，因为我们在添加后Table不再改变，顺序得到了保证，所以目前看来使用pairs应该没有问题
	--todo如果有问题，可以加新的table进行排序再遍历
	if self.TableData == nil then
		error("[BaseTable:LoopTable] self.TableData is nil!"..self.tabFileName)
		return;
	end

	for k, v in pairs(self.TableData) do 
		callBack(v);
	end
end


-- 获取数据（根据ID获取数据）
-- TabName 表的名字
-- id 数据ID
-- des 字段描述
function BaseTable:GetTableDataByKey(id, name)	
	self:CheckLoad();
	if nil == self.TableData[tonumber(id)] or nil == self.TableData[tonumber(id)][name] then
		return nil;
	end
	
	return self.TableData[tonumber(id)][name];
end

function BaseTable:GetTableDataByKeyMuti(id, ...)	
	self:CheckLoad();	
	if nil == self.TableData[tonumber(id)] then
		return nil;
	end

	local args = { ... }
	local argCount = tableSize(args);
	if(argCount == 1) then
		return self.TableData[tonumber(id)][args[1]];
	elseif(argCount == 2) then						
		return self.TableData[tonumber(id)][args[1]], self.TableData[tonumber(id)][args[2]];
	elseif(argCount == 3) then						
		return self.TableData[tonumber(id)][args[1]], self.TableData[tonumber(id)][args[2]], self.TableData[tonumber(id)][args[3]];
	elseif(argCount == 4) then						
		return self.TableData[tonumber(id)][args[1]], self.TableData[tonumber(id)][args[2]], self.TableData[tonumber(id)][args[3]], self.TableData[tonumber(id)][args[4]];
	elseif(argCount == 5) then						
		return self.TableData[tonumber(id)][args[1]], self.TableData[tonumber(id)][args[2]], self.TableData[tonumber(id)][args[3]], self.TableData[tonumber(id)][args[4]], self.TableData[tonumber(id)][args[5]];
	elseif(argCount == 6) then						
		return self.TableData[tonumber(id)][args[1]], self.TableData[tonumber(id)][args[2]], self.TableData[tonumber(id)][args[3]], self.TableData[tonumber(id)][args[4]], self.TableData[tonumber(id)][args[5]], self.TableData[tonumber(id)][args[6]];
	elseif(argCount == 7) then						
		return self.TableData[tonumber(id)][args[1]], self.TableData[tonumber(id)][args[2]], self.TableData[tonumber(id)][args[3]], self.TableData[tonumber(id)][args[4]], self.TableData[tonumber(id)][args[5]], self.TableData[tonumber(id)][args[6]], self.TableData[tonumber(id)][args[7]];
	elseif(argCount == 8) then						
		return self.TableData[tonumber(id)][args[1]], self.TableData[tonumber(id)][args[2]], self.TableData[tonumber(id)][args[3]], self.TableData[tonumber(id)][args[4]], self.TableData[tonumber(id)][args[5]], self.TableData[tonumber(id)][args[6]], self.TableData[tonumber(id)][args[7]], self.TableData[tonumber(id)][args[8]];
	elseif(argCount == 9) then						
		return self.TableData[tonumber(id)][args[1]], self.TableData[tonumber(id)][args[2]], self.TableData[tonumber(id)][args[3]], self.TableData[tonumber(id)][args[4]], self.TableData[tonumber(id)][args[5]], self.TableData[tonumber(id)][args[6]], self.TableData[tonumber(id)][args[7]], self.TableData[tonumber(id)][args[8]], self.TableData[tonumber(id)][args[9]];
	elseif(argCount == 10) then						
		return self.TableData[tonumber(id)][args[1]], self.TableData[tonumber(id)][args[2]], self.TableData[tonumber(id)][args[3]], self.TableData[tonumber(id)][args[4]], self.TableData[tonumber(id)][args[5]], self.TableData[tonumber(id)][args[6]], self.TableData[tonumber(id)][args[7]], self.TableData[tonumber(id)][args[8]], self.TableData[tonumber(id)][args[9]], self.TableData[tonumber(id)][args[10]];
	end
end

-- 根据数据名称获取数据(取colName列等于colData的这行对应的wentName这个列的值)
function BaseTable:GetTableDataByCol(colName, colData, wantColname)	
	self:CheckLoad();	
	for id, info in pairs(self.TableData) do
		for title, data in pairs(info) do
			if(title == colName and data == colData) then				
				if nil == self.TableData[tonumber(id)] or nil == self.TableData[tonumber(id)][wantColname] then
					return nil;
				else
					return self.TableData[tonumber(id)][wantColname];
				end
			end
		end
	end
	return nil;
end

function BaseTable:GetTableDataByColMuti(colName, colData, ...)		
	self:CheckLoad();
	local args = { ... }
	local argCount = tableSize(args);
	for id, info in pairs(self.TableData) do
		for title, data in pairs(info) do
			if(title == colName and data == colData) then
				if(argCount == 1) then
					return self.TableData[tonumber(id)][args[1]];
				elseif(argCount == 2) then						
					return self.TableData[tonumber(id)][args[1]], self.TableData[tonumber(id)][args[2]];
				elseif(argCount == 3) then						
					return self.TableData[tonumber(id)][args[1]], self.TableData[tonumber(id)][args[2]], self.TableData[tonumber(id)][args[3]];
				elseif(argCount == 4) then						
					return self.TableData[tonumber(id)][args[1]], self.TableData[tonumber(id)][args[2]], self.TableData[tonumber(id)][args[3]], self.TableData[tonumber(id)][args[4]];
				elseif(argCount == 5) then						
					return self.TableData[tonumber(id)][args[1]], self.TableData[tonumber(id)][args[2]], self.TableData[tonumber(id)][args[3]], self.TableData[tonumber(id)][args[4]], self.TableData[tonumber(id)][args[5]];
				elseif(argCount == 6) then						
					return self.TableData[tonumber(id)][args[1]], self.TableData[tonumber(id)][args[2]], self.TableData[tonumber(id)][args[3]], self.TableData[tonumber(id)][args[4]], self.TableData[tonumber(id)][args[5]], self.TableData[tonumber(id)][args[6]];
				elseif(argCount == 7) then
					return self.TableData[tonumber(id)][args[1]], self.TableData[tonumber(id)][args[2]], self.TableData[tonumber(id)][args[3]], self.TableData[tonumber(id)][args[4]], self.TableData[tonumber(id)][args[5]], self.TableData[tonumber(id)][args[6]], self.TableData[tonumber(id)][args[7]];
				end
			end
		end
	end
	return nil;
end

-- 解析扩展数据
function BaseTable:ParseTabStr(id, name)	
	self:CheckLoad();
	local data = self.TableData[tonumber(id)][name];
	if data == nil or data == "" then
		return nil;
	end
	return stringsplit(data, "|");
end

-- 读取表格数据解析, 现在必须是同步读取解析
function BaseTable:loadFile(str)
	ResInterface.LoadTextSync(str, function(_content)
		self:loadFileCallBack(str, _content)
	end)
end

function BaseTable:loadFileCallBack(szName, szData)
	if szData == nil or szData == "" then
		error("load table text failed:"..szName);
		return;
	end

    -- 按行划分
    local lineStr = stringsplit(szData, '\r\n');
  	
	--[[    
			从第3行开始保存（第一行是数据类型，服务器使用，第二行是标题（客户端使用），第三行是注释，后面的行才是内容）             
            用二维数组保存：arr[ID][属性标题字符串]
            如果是int这里读取出来的是string,所以如果标示int，则转成int
            注意：如果是空，则无论是什么，都统一转成nil处理
	--]]
	local types = stringsplit(lineStr[1], "\t");
    local titles = stringsplit(lineStr[2], "\t");
	local ID = 1;
	local lastID = 1;
	local MaxLine = 0;
	self.TableData = {};
    for i = 3, #lineStr, 1 do
		-- 这里还要处理一次，如果第一个字符是#，则不处理这一行数据
		local temp = string.sub(lineStr[i], 1, 1);
		if temp ~= "#" then
			MaxLine = MaxLine + 1;
			-- 一行中，每一列的内容
			local content = splitLine(lineStr[i], "\t");

			-- 以标题作为索引，保存每一列的内容，取值的时候这样取：arrs[1].Title	
			lastID = ID;
			ID = tonumber(content[1]);			
			
			if (nil == ID) then
				error("Table Err!szName=" .. szName .. ", After ID= " .. lastID .. ",lineStr[i]=" .. lineStr[i])
			end
			
			self.TableData[ID] = {};
			
			for j = 1, #titles, 1 do
				if types[j] == "INT" or types[j] == "FLOAT" then
					if(content[j] == "") then
						content[j] = nil;
					else
						self.TableData[ID][titles[j]] = tonumber(content[j]);	
					end		

				else
					
					if(content[j] == "") then
						content[j] = nil;
					else
						self.TableData[ID][titles[j]] = content[j];						
					end
				end				
			end			
		end
    end
	
	self.MaxID = ID; --最后一记录
	self.MaxLine = MaxLine; --有多少有效的行		

	--error(">>> " .. szName .. " LastID : " .. ID)
	--error(">>> " .. szName .." MaxLine : " .. MaxLine)
	TableManager:Inst():OnSingleTableLoad(szName)
    return true;
end


----------------------------------------------------------------------------------------------------------------------------------------------------------
UITable =  class("UITable", BaseTable) -- UI表
-- TabModel =  class("TabModel", BaseTable) --模型表
-- TabObjectMenu =  class("TabObjectMenu", BaseTable) --菜单表
 TabStrDic =  class("TabStrDic", BaseTable) --提示字符串
-- TabSoldierInfo = class("TabSoldierInfo", BaseTable) --士兵表格
-- TabBattleMap = class("TabBattleMap", BaseTable) --地图资源
-- TabBattleData = class("TabBattleData",BaseTable)
-- TabClientSkill_Deprecated = class("TabClientSkill_Deprecated", BaseTable) --技能表格
-- TabBuff = class("BuffTab", BaseTable) --Buff表格
-- TabBullet = class("TabBullet", BaseTable) --子弹表格
-- TabEffect = class("TabEffect", BaseTable) --特效表格
-- TabSkill = class("TabSkill", BaseTable)   --技能表格
-- TabHomeBuilding = class("TabHomeBuilding", BaseTable)   --家园建筑
-- TabStaticStr = class("TabStaticStr", BaseTable)   --家园建筑
-- TabMonster = class("TabMonster", BaseTable) --NPC
-- TabResMine = class("TabResMine", BaseTable) --大地图矿表
-- TabHomeDeploy = class("TabHomeDeploy", BaseTable) --家园部署表
-- TabMoney = class("TabMoney", BaseTable) --钱表
-- TabBuildingSoldier = class("TabBuildingSoldier", BaseTable) --兵营招募配置表
-- TabBuildingProduce = class("TabBuildingProduce", BaseTable) --资源生产表
-- TabItem = class("TabItem", BaseTable) --道具表格
TabIcon = class("TabIcon", BaseTable) --图标表格
-- TabGeneral = class("TabGeneral", BaseTable)  --武将表格
-- TabGameConfig = class("TabGameConfig", BaseTable)  --游戏配置表
-- TabErrorCode  = class("TabErrorCode", BaseTable)   --错误提示表
-- TabGeneralGrowUp = class("TabGeneralGrowUp", BaseTable)  --游戏配置表
-- TabMoneyExChange = class("TabMoneyExChange", BaseTable)  --游戏汇率表
-- TabMission = class("TabMission", BaseTable)  --任务表
-- TabSkillModelParam = class("TabSkillModelParam", BaseTable) -- SkillModelParam.txt
-- TabBigMapBuilding = class("TabBigMapBuilding", BaseTable) -- 大地图城堡客户端显示配置
-- TabGeneralLevel = class("TabBigMapBuilding", BaseTable)
-- TabGeneralStarLv = class("TabGeneralStarLv", BaseTable)
-- TabEquip = class("TabEquip", BaseTable)
-- TabEquipSuite = class("TabEquipSuite", BaseTable)
-- TabSkillEffect = class("SkillEffect", BaseTable)
-- TabPlayerBox = class("TabPlayerBox", BaseTable)
-- TabOnlineBox = class("TabOnlineBox", BaseTable)
-- TabFightingCalc = class("TabFightingCalc", BaseTable)	-- 兵种战力参数表
-- CastleLevelParam = class("CastleLevelParam", BaseTable)
-- TabTalent = class("TabTalent", BaseTable);
-- TabTalentLevel = class("TabTalentLevel", BaseTable);
-- TabFuWen = class("TabFuWen", BaseTable);
-- TabFuWenSlotParam = class("TabFuWenSlotParam", BaseTable);
-- PhyicalBuyCost = class("PhyicalBuyCost", BaseTable);
-- TabHomeAreaOpen = class("TabHomeAreaOpen", BaseTable);
-- TabBuildingWare = class("TabBuildingWare", BaseTable);
-- TabWareStore = class("TabWareStore", BaseTable);
TabAudio = class("TabAudio", BaseTable);
-- Task = class("Task", BaseTable);
-- TabBuildingHospital = class("TabBuildingHospital", BaseTable);
-- TabFunOpen = class("TabFunOpen", BaseTable);
-- ActivityBox = class("ActivityBox", BaseTable);
-- TabVitality = class("TabVitality", BaseTable);
-- TabCopyZone = class("CopyZone", BaseTable);
-- TabCopyScene = class("CopyZone", BaseTable);
-- TabCopyNpcGroup = class("CopyNpcGroup", BaseTable);
-- TabCopySceneMarch = class("CopySceneMarch", BaseTable);
 TabStrDialouge = class("TabStrDialouge", BaseTable);
 TabDialogue = class("TabDialogue", BaseTable);
-- TabFixedBonusView = class("TabFixedBonusView", BaseTable);
-- TabAllianceBuilding = class("TabAllianceBuilding", BaseTable);
-- TableAllianceDuty = class("TableAllianceDuty", BaseTable);
-- TabSuperMine= class("TabSuperMine", BaseTable)
-- TabItemSwitch= class("TabItemSwitch", BaseTable)
-- TabFlagIcon= class("TabFlagIcon", BaseTable)
-- TabModelAnims = class("TabModelAnims", BaseTable)
-- TabBusinessData = class("TabBusinessData", BaseTable)
-- TabPromotion = class("TabPromotion", BaseTable)
-- TabAllianceGradeTask = class("TabAllianceGradeTask", BaseTable)
-- TabGuide = class("TabGuide", BaseTable)
-- TabGuideEventTrigger = class("TabGuideEventTrigger", BaseTable)
-- TabAllianceGrade = class("TabAllianceGrade", BaseTable)
-- TabDropGradeTask = class("TabDropGradeTask", BaseTable)
-- TabStrNotification = class("TabStrNotification", BaseTable)
-- TabAllianceActivityTask = class("TabAllianceActivityTask", BaseTable)
-- TabAllianceActivityBox = class("TabAllianceActivityBox", BaseTable)
-- TabDropAllianceActivityBox = class("TabDropAllianceActivityBox", BaseTable)
-- TabCastleDecorate = class("TabCastleDecorate", BaseTable)
-- TabMarchSpeedUp = class("TabMarchSpeedUp", BaseTable)
-- TabRecharge = class("TabRecharge", BaseTable)
-- TabPlayerLv = class("TabPlayerLv", BaseTable)
-- TabPlayerLv = class("TabPlayerLv", BaseTable)
-- TabDropBaoXiang = class("TabDropBaoXiang", BaseTable)
-- TabDropFuBen = class("TabDropFuBen", BaseTable)
-- TabDropHuoYueDuXiangZi = class("TabDropHuoYueDuXiangZi", BaseTable)
-- TabDropLiBao = class("TabDropLiBao", BaseTable)
-- TabDropRenWu = class("TabDropRenWu", BaseTable)
-- TabDropYeGuai = class("TabDropYeGuai", BaseTable)
-- TabDropZiYuanXiang = class("TabDropZiYuanXiang", BaseTable)
-- TabHeadIcon = class("TabHeadIcon", BaseTable)
-- TabAllianceTask = class("TabAllianceTask", BaseTable)
-- TabEquipShop = class("TabEquipShop", BaseTable)
-- TabGrowthFund = class("TabGrowthFund", BaseTable)
-- TabConvertItem = class("TabConvertItem", BaseTable)
-- TabAllianceSkill = class("TabAllianceSkill",BaseTable)
-- TabVipPrivilege = class("TabVipPrivilege",BaseTable)
-- TabVipShop = class("TabVipShop",BaseTable)
-- TabVipLv = class("TabVipLv",BaseTable)
-- TabTechnology = class("Technology",BaseTable)
-- TabTargetSeven = class("TabTargetSeven",BaseTable)
-- TabTargetSevenPro = class("TabTargetSevenPro",BaseTable)
-- TabGeneralPYX = class("GeneralPYX",BaseTable)
-- TabSpyTower   = class("TabSpyTower",BaseTable)
-- TabSignIn     = class("TabSignIn",BaseTable);
-- TabSignInCon  = class("TabSignInCon",BaseTable);
-- TabBuildingCityWall  = class("TabBuildingCityWall",BaseTable);
-- TabMilitaryLv  = class("MilitaryLv",BaseTable);
-- TabAllianceLevel = class("AllianceLevel",BaseTable);
-- TabCommercial = class("TabCommercial",BaseTable);
-- TabAllianceMain = class("TabAllianceMain",BaseTable);
-- TabMainBuff = class("TabMainBuff",BaseTable);
-- TabTechnologyBuff = class("TabTechnologyBuff",BaseTable)
-- TabTimingEffect  = class("TimingEffect",BaseTable);
-- TabMainBuffDefault = class("TabMainBuffDefault",BaseTable);
-- TabBuildingMainCity = class("TabBuildingMainCity",BaseTable);
-- TabDragonBones = class("TabDragonBones", BaseTable);
-- TabNotify = class("TabNotify", BaseTable);
-- TabLoadingTips = class("TabLoadingTips", BaseTable);
-- TabRandomNames = class("TabRandomNames", BaseTable);
-- TabPromotionExchange = class("TabPromotionExchange",BaseTable);
-- TabPurchDiamond = class("TabPurchDiamond",BaseTable);
-- TabSensitiveWord = class("TabSensitiveWord",BaseTable);
-- TabCityProsper = class("SceneCityProsper", BaseTable);
-- TabCity = class("SceneCityTab",BaseTable);
-- TabCityLevel = class("SceneCityLevel",BaseTable);
-- TabMonsterGroup = class("MonsterGroup",BaseTable);
-- TabBattleEvent  = class("BattleEvent",BaseTable);
-- TabCityOfficer  = class("SceneCityOfficer",BaseTable);
-- TabWorldBossReward  = class("WorldBossReward",BaseTable);
-- TabMassArmyParam 	= class("MassArmyParam",BaseTable);
-- TabSceneCityShop 	= class("SceneCityShop",BaseTable);
-- TabDragonMine 	= class("TabDragonMine",BaseTable);
-- TabArena 		= class("Arena",BaseTable);
-- TabHeroFetter 		= class("HeroFetter",BaseTable);
-- TabEverydayRankTask 		= class("EverydayRankTask",BaseTable);

-- --临时用字符串表
TabStrDic_ChineseSimplified = class("TabStrDic_ChineseSimplified", BaseTable);
TabStaticStr_ChineseSimplified = class("TabStaticStr_ChineseSimplified", BaseTable);
TabStrDialouge_ChineseSimplified = class("TabStrDialouge_ChineseSimplified", BaseTable);
TabStrNotification_ChineseSimplified = class("TabStrNotification_ChineseSimplified", BaseTable);
TabErrorCode_ChineseSimplified = class("TabErrorCode_ChineseSimplified", BaseTable);
TabRandomNames_ChineseSimplified = class("TabRandomNames_ChineseSimplified", BaseTable);		





---------------------------------------------------------------------------
-- function TabSkillModelParam:loadFileCallBack(szName, szData)
-- 	BaseTable.loadFileCallBack(self, szName, szData);

-- 	self.mContainer = {};
-- 	for _, lineValue in pairs(self.TableData) do
-- 		local key = lineValue["ModelId"].."-"..lineValue["SkillId"];
-- 		self.mContainer[key] = lineValue;
-- 	end
-- end

-- function TabSkillModelParam:GetSkillParam(modleId, skillId)
-- 	self:CheckLoad();
-- 	local key = modleId.."-"..skillId;
-- 	if not key then
-- 		return nil;
-- 	end
	
-- 	return self.mContainer[key];
-- end


-- function TabGeneralStarLv:loadFileCallBack(szName, szData)
-- 	BaseTable.loadFileCallBack(self, szName, szData);

-- 	self.mContainer = {};
-- 	for _, lineValue in pairs(self.TableData) do
-- 		local key = lineValue.GeneralId * 1000 + lineValue.StarLv * 10;
-- 		self.mContainer[key] = lineValue;
-- 	end
-- end

-- function TabGeneralStarLv:GetRes(generalId, starLv)
-- 	self:CheckLoad();
-- 	local key = generalId * 1000 + starLv * 10;
-- 	return self.mContainer[key];
-- end

-- function TabGuide:loadFileCallBack(szName, szData)
-- 	BaseTable.loadFileCallBack(self, szName, szData);

-- 	--目前生成一个连续的引导组吧
-- 	self.mGroup = {};
-- 	for _, lineValue in pairs(self.TableData) do
-- 		--error("lineValue=" .. tostring(lineValue.GroupID))
-- 		local group = lineValue["GroupID"];
-- 		if self.mGroup[group] == nil then
-- 			self.mGroup[group] = {};
-- 		end		
-- 		local index = #self.mGroup[group];
-- 		self.mGroup[group][index + 1] = lineValue;
-- 		--error(">>> " .. group  .. "[" .. index .. "]=" .. tostring(lineValue) )
-- 		index = index + 1;
-- 	end
-- end

-- function TabGuide:GetGroupFieldList(group)		
-- 	self:CheckLoad();
	
-- 	--说明：必须对引导组进行排序(目前就按ID排序)
-- 	local tList = self.mGroup[group] or {};
-- 	table.sort(tList, function (a, b) 
-- 		if a.ID < b.ID then return true; end
-- 	end)
	
-- 	return tList;
-- end
