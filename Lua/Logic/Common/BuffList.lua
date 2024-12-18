

Buff = class("Buff")
function Buff:ctor()
	self.buffGUID = -1;
	self.buffId = -1;
	self.buffNum = 0;
end


BuffList = class("BuffList")
function BuffList:ctor()
	self.buffList = {}
end

---------------------------------------------------------------------
function BuffList:AddBuff( _buffGUID, _buffId, _buffNum )
	if self:IsBuffExistByGUID( _buffGUID ) then
		self:RefreshNum( _buffGUID, _buffNum );
		return false;
	end	
	local buff = Buff.New();
	buff.buffGUID = _buffGUID;
	buff.buffId= _buffId;
	buff.buffNum = _buffNum;
	table.insert(self.buffList, buff);
	return true;
end


function BuffList:RemoveBuffByGUID( _buffGUID )
	for i = 1, #self.buffList do
		if self.buffList[i].buffGUID == _buffGUID then
			local buffId = self.buffList[i].buffId;
			table.remove( self.buffList, i)
			return buffId;
		end
	end
	return nil;
end


function BuffList:RemoveBuffById( _buffId )
	for i = #self.buffList, 1, -1 do
		if self.buffList[i].buffId == _buffId then
			table.remove( self.buffList, i)
		end
	end
end

function BuffList:IsBuffExistById( _buffId )
	for i = 1, #self.buffList do
		if self.buffList[i].buffId == _buffId then
			return true;
		end
	end
	return false;
end


function BuffList:IsBuffExistByGUID( _buffGUID )
	for i = 1, #self.buffList do
		if self.buffList[i].buffGUID == _buffGUID then
			return true;
		end
	end
	return false;
end

function BuffList:RefreshNum( _buffGUID, _buffNum )
	for i = 1, #self.buffList do
		if self.buffList[i].buffGUID == _buffGUID then
			self.buffList[i].buffNum = _buffNum;
			break;
		end
	end
end

function BuffList:GetBuff( _indexs )
	if _indexs > #self.buffList then
		return {0, 0};
	end

	return {self.buffList[_indexs].buffId, self.buffList[_indexs].buffNum};
end


function BuffList:Clear()
	self.buffList = {}
end