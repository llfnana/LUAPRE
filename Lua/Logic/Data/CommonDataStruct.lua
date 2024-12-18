
--常用数据结构

PlayerSimpleData = class("PlayerSimpleData")

function PlayerSimpleData:ctor()
	self:Init();
end

function PlayerSimpleData:Init()
	self.playerName = "";		--玩家名称
	self.guildName = "";		--玩家工会
	self.playerGUID = -1;		--玩家guid
	self.guildId = -1;			--玩家工会id
	self.playerLevel = 1;		--玩家等级
	self.castleLevel = 1;		--玩家城堡等级
end

-----------------------------------
-- 士兵信息
PlayerSoldierData = class("PlayerSoldierData")

function PlayerSoldierData:ctor()
	self:Init();
end

function PlayerSoldierData:Init()
	self.soldierId = 0;
	self.soldierCount = 0;
end

-----------------------------------
EquipData = class("EquipData")

function EquipData:ctor()
	self:Init();
end

function EquipData:Init()
end

-----------------------------------
-- 武将信息
PlayerGeneralData = class("PlayerGeneralData")

function PlayerGeneralData:ctor(slotIndex, generalId)
	self:Init(slotIndex, generalId);
end

function PlayerGeneralData:Init(slotIndex, generalId)
	
	self.slotIndex 	= slotIndex;
	self.generalId  = generalId;
	self.level = 1;
	self.exp 	= 0;
	self.talentPoint = 0;
	self.formationSoldierId 	= 0;
	self.formationSoldierCount = 0;
	self.generalState 	= 0;
	self.defendCity 	= false;
	self.starLv 	= 1;
	self.stepLv 	= 0;
	self.score 	= 0;
	self.fightingAbility = 0;
	self.equipList = {};
	self.quality = eQualityType_White;
	self.props	  = {};
	self.maxSoldierCount = 0;
	self.reliveTime = 0;
	self.lastItemReliveTime = 0;
	self.attackTalentData = {};
	self.defendTalentData = {};
	self.lastResetTalentTime = 0;
	self.talentSkills = {};
	self.attackFuWenData = {};
	self.defendFuWenData = {};
	self.talentfighting = 0; --天赋战力
	self.diamondReliveCount = 0; --今日复活次数
	self.diamondReliveResetTime = 0; --上次复活天
	
	
	local generalRes = TableManager:Inst():GetTabData(EnumTableID.TabGeneral, generalId);
	if not generalRes then
		error("error general quality. generalId = "..generalId);
		return;
	end
	
	self.quality = generalRes["Quality"]; 
end

function PlayerGeneralData:GetEquip(part)
	if part == nil then
		return;
	end
	
	return self.equipList[part];
end

-- 取英雄的指定套装的件数
function PlayerGeneralData:GetSuiteCount(suiteId)
	
	if suiteId == nil then
		return 0;
	end
	
	if self.equipList == nil then
		return 0;
	end

	local cnt = 0;
	for _, equipData in pairs(self.equipList) do
		if equipData:GetSuiteId() == suiteId then
			cnt = cnt + 1;
		end
	end
	
	return cnt;
end

function PlayerGeneralData:HasEquip(equipResId)
	
	if equipResId == nil then
		return false;
	end
	
	if self.equipList == nil then
		return false;
	end
	
	for _, equipData in pairs(self.equipList) do
		if equipData:GetResId() == equipResId then
			return true;
		end
	end
	
	return false;
end

function PlayerGeneralData:IsFighting()
	if self.generalState == PlayerGeneral_pb.eGeneralState_Free or self.generalState == PlayerGeneral_pb.eGeneralState_Dead then
		return false;
	end
	
	return true;
end

--得到比它更好的装备 slot, data
--目前只使用评分判断
function PlayerGeneralData:GetMoreGoodEquipSlotIndex(pos)	
	
end

