

GeneralLogic = 
{
	Inst = function()
	   if GeneralLogic.mInstance == nil then
			GeneralLogic.mInstance = GeneralLogic.New();
		end
		
		return GeneralLogic.mInstance;
	end,

	New = function()
		local obj = {};
		setmetatable(obj, {__index = GeneralLogic});
		
		obj:Clear();
		return obj;
	end,
	
	Destroy = function(self)
		self:StopUpdate();
	end,
	
	Clear = function(self)
		self.mHasUpdate = false;
		self.mReqReliveList = {};
		self.mTimerId = -1;
		
		self:StopUpdate();
	end,
	
	OnHeroDataUpdate = function(self, heroData)
		
		if heroData == nil then
			return;
		end
		
		if heroData.generalState ~= PlayerGeneral_pb.eGeneralState_Reliving then
			self.mReqReliveList[heroData.generalId] = nil;
			return;
		end
		
		self:StartUpdate();
		
	end,
	
	OnRelivePointUpdate = function(self, relivePointRecoveryTime)
			
		if self.mTimerId > 0 then
			LuaTimer:Remove(self.mTimerId);
			self.mTimerId = -1;
		end
		
		if relivePointRecoveryTime > 0 then
			local leftTime = relivePointRecoveryTime > GetServerTime() and relivePointRecoveryTime - GetServerTime() or 0;
			self.mTimerId = LuaTimer:Add(function() self:OnTimer() end, leftTime, 0, true);
		end
	end,
	
	OnTimer = function()
		GameService.ReqRelivePointRecovery();	
	end,

	Update = function(self)

		local bContinue = false;

		
		if not bContinue then
			self:StopUpdate();
		end
		
	end,
	
	StartUpdate = function(self)
		
		if self.mHasUpdate then
			return;
		end
		
		self.mHasUpdate = true;
		
		UpdateBeat:Add(self.Update, self);
		
	end,
	
	StopUpdate = function(self)
		
		if not self.mHasUpdate then
			return;
		end
		
		self.mHasUpdate = false;
		UpdateBeat:Remove(self.Update, self);
		
	end,
}
