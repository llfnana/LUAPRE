

BonusList = class("BonusList")

function BonusList:ctor()
	self.moneyList = nil;
	self.itemList = nil;
	self.bonusInfo = nil;
	self.equipList = nil;
	self.generalList = nil;
	self.soldierList = nil;
	self.fuwenList = nil;
end


function BonusList:AddMoney(_moneyId, _moneyCount)
	if _moneyId == nil or _moneyCount == nil or _moneyCount <= 0 then
		return;
	end
	if self.moneyList == nil then
		self.moneyList = {}
	end
	local ele = { _moneyId, _moneyCount };
	table.insert( self.moneyList, ele )
end

function BonusList:AddItem(_itemId, _itemCount)
	if _itemId == nil or _itemCount == nil or _itemCount <= 0 then
		return;
	end
	if self.itemList == nil then
		self.itemList = {}
	end
	local ele = { _itemId, _itemCount };
	table.insert( self.itemList, ele );
end


function BonusList:AddEquip( _equipId )
	if _equipId == nil or _equipId <= 0 then
		return;
	end
	if self.equipList == nil then
		self.equipList = {}
	end
	table.insert( self.equipList, _equipId )
end


function BonusList:AddGeneral( _generalId )
	if _generalId == nil or _generalId <= 0 then
		return;
	end
	if self.generalList == nil then
		self.generalList = {}
	end
	table.insert( self.generalList, _generalId )
end

function BonusList:AddSoldier( _soldierId, _soldierCount )
	if _soldierId == nil or _soldierId <= 0 then
		return;
	end

	if _soldierCount == nil or _soldierCount <= 0 then
		return;
	end
	
	if self.soldierList == nil then
		self.soldierList = {}
	end
	local ele = { _soldierId, _soldierCount };
	table.insert( self.soldierList, ele )
end


function BonusList:AddFuWen( _fwId, _fwCount)
	if _fwId == nil or _fwId <= 0 then
		return;
	end

	if _fwCount == nil or _fwCount <= 0 then
		return;
	end

	if self.fuwenList == nil then
		self.fuwenList = {}
	end
	local ele = { _fwId, _fwCount };
	table.insert( self.fuwenList, ele )
end


function BonusList:IsEmpty()
	if self.moneyList == nil and self.itemList == nil and self.generalList == nil and self.equipList==nil and self.soldierList==nil and self.fuwenList == nil then
		return true;
	else
		return false;
	end	
end


function BonusList:InitBonusInfo()

	if self.bonusInfo ~= nil then
		return;
	end

	self.bonusInfo = {}

	--提取货币显示信息
	if self.moneyList ~= nil then
		for i = 1, #self.moneyList do
			local uiInfo = GetCommonItemUIInfo(self.moneyList[i][1]);
			if uiInfo ~= nil then
				uiInfo.count = self.moneyList[i][2]
				table.insert( self.bonusInfo, uiInfo );
			end
		end
	end

	--提取道具显示信息
	if self.itemList ~= nil then
		for i = 1, #self.itemList do
			local uiInfo = GetCommonItemUIInfo(self.itemList[i][1]);
			if uiInfo ~= nil then
				uiInfo.count = self.itemList[i][2]
				table.insert( self.bonusInfo, uiInfo );				
			end
		end
	end

	--提取装备显示信息
	if self.equipList ~= nil then
		for i = 1, #self.equipList do
			local uiInfo = GetCommonItemUIInfo( self.equipList[i] )
			if uiInfo ~= nil then
				uiInfo.count = 1;
				table.insert( self.bonusInfo, uiInfo );
			end
		end
	end

	--提取武将显示信息
	if self.generalList ~= nil then
		for i = 1, #self.generalList do
			local tabInfo = TableManager:Inst():GetTabData(EnumTableID.TabGeneral, self.generalList[i] );
			if tabInfo ~= nil then
				local uiInfo = {}
				uiInfo.isGeneral = true;
				uiInfo.id = self.generalList[i];
				uiInfo.count = 1;
				uiInfo.name = GetStaticStr(tabInfo.NameID);
				uiInfo.iconId = tabInfo.IconID;
				uiInfo.quality = tabInfo.Quality;
				uiInfo.level = tabInfo.Level;
				uiInfo.field = tabInfo;
				table.insert( self.bonusInfo, 1, uiInfo );						
			end
		end
	end

	--提取道具显示信息
	if self.soldierList ~= nil then
		for i = 1, #self.soldierList do
			local tabInfo = TableManager:Inst():GetTabData(EnumTableID.TabSoldierInfo, self.soldierList[i][1]);			
			if tabInfo ~= nil then
				
				local uiInfo = {}
				uiInfo.isSoldier = true;
				uiInfo.id = self.soldierList[i][1];
				uiInfo.count = self.soldierList[i][2];				
				uiInfo.name = GetStaticStr(tabInfo.NameID);
				uiInfo.iconId = tabInfo.IconID;
				uiInfo.quality = eQualityBlue; --没有目前
				uiInfo.level = tabInfo.ShowLevel;
				uiInfo.field = tabInfo;
				table.insert( self.bonusInfo, uiInfo );
			end
		end
	end

	--提取符文
	if self.fuwenList ~= nil then
		for i = 1, #self.fuwenList do
			local tabInfo = TableManager:Inst():GetTabData(EnumTableID.TabFuWen, self.fuwenList[i][1]);
			if tabInfo ~= nil then

				local uiInfo = {}
				uiInfo.isFuWen = true;
				uiInfo.id = self.fuwenList[i][1];
				uiInfo.count = self.fuwenList[i][2];
				uiInfo.name = GetStaticStr(tabInfo.NameID);
				uiInfo.iconId = tabInfo.IconID;
				uiInfo.quality = tabInfo.Type; --红绿蓝
				uiInfo.level = tabInfo.ShowLevel;
				uiInfo.field = tabInfo;
				table.insert( self.bonusInfo, uiInfo );
			end
		end
	end
end

function BonusList:GetBonusInfoCount()
	if self.bonusInfo == nil then
		self:InitBonusInfo();
	end
	return #self.bonusInfo;
end

function BonusList:GetMoneyInfo( _index )
	if nil == self.moneyList then
		return nil;
	end
	
	return self.moneyList[ _index ];
end

function BonusList:GetBonusInfo( _index )
	return self.bonusInfo[ _index ];
end

function BonusList:GetGeneralInfoList()
	local generalInfoList;
	for i = #self.bonusInfo, 1, -1 do
		local info = self.bonusInfo[i];
		if info.isGeneral then
			if generalInfoList == nil then
				generalInfoList = {}
			end
			table.insert( generalInfoList, info );
		end
	end
	return generalInfoList;
end