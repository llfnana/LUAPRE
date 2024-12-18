
--封装时间相关操作

TimeMgr = class("TimeMgr")

function TimeMgr:ctor()
	self.servertime = 0      --服务器时间戳



		self.serverTimeZone = 8;

	self.recvServTimeMsgTick = 0;
	self:SetServerTime(os.time());
end

function TimeMgr:Inst()
	if nil == self.instance then
		self.instance = TimeMgr.New();
	end
	return self.instance;
end


function TimeMgr:SyncUnityTime()
	Time:SyncUnityTime();
	GameManagerMgr:OnSyncTime();
end


function TimeMgr:GetCurTick()
	return math.floor(Time.realtimeSinceStartup*1000);
end

function TimeMgr:SetServerTime( servertime )
	self:SyncUnityTime();
	self.servertime = servertime
	self.recvServTimeMsgTick = self:GetCurTick();
end

 
function TimeMgr:GetServerTime()
	if self.servertime == 0 then
		return 0;
	end
	
	local offsetTick = self:GetCurTick() - self.recvServTimeMsgTick;
	local curtime = self.servertime + (offsetTick*0.001);
	return curtime;
end

function TimeMgr:GetLocalTime()
	return os.time();
end


function TimeMgr:GetGameTimeByServerTimeStamp( _serverTime )
	local curServerTime = GetServerTime()
	if curServerTime == 0 then
		return 0;
	end

	local curGameTime = Time.realtimeSinceStartup;
	local gameTime = curGameTime - (curServerTime - _serverTime);

	--error("_serverTime=".._serverTime..";curServerTime="..curServerTime..";curGameTime="..curGameTime..";gameTime="..gameTime);

	return gameTime;
end

function TimeMgr:GetCurrentServerShowTime(format,utcTimeStamp)
	if not format then
		format = "%b.%d %H:%M:%S";
	end

	if not utcTimeStamp then
		utcTimeStamp = self:GetServerTime();
	end

	utcTimeStamp = utcTimeStamp + self.serverTimeZone*3600;

	if format[1]~="!" then
		format = "!"..format;
	end

	return os.date(format,utcTimeStamp);
end


--注：传入的两个时间戳必须都是utc时间戳， 因为服务器时间 GetServerTime() 就是utc时间戳
function TimeMgr:GetIntervalTimeStamp(targetTimeStamp,currentTimeStamp)
	if not currentTimeStamp then
		currentTimeStamp = self:GetServerTime();
	end
	return targetTimeStamp-currentTimeStamp;
end