SocketEventType = {
	NotInit = 0,
    OnConnectSuccess = 1,
	OnDisConnect = 2,
	OnConnectFail = 3,
}

Network = {};
local this = Network;

--连接服务器类型定义
ConnServerType = {
	GameServer = 0,			--主游戏逻辑服务器
	BattleServer = 1,		--战斗服务器
	Count = 2,
}

--网络状态枚举
SocketStateTypeDefine =
{
	eSTTD_NOT_CONNECT = 0,   --未连接状态,
	eSTTD_CONNECTING = 1,    --正在连接
	eSTTD_ESTABLISHED = 2,   --正常建立连接状态
	eSTTD_DIS_CONNECT = 3,   --服务器断开
}


--网络模块初始化
function Network.Start() 
	NetManager:InitConnectors( ConnServerType.Count );
	NetManager:RegisterLuaCallback( ConnServerType.GameServer, Network.OnData0, Network.OnDisConnect0, 
									Network.OnConnectSuccess0, Network.OnConnectFail0)
	
	NetManager:RegisterLuaCallback( ConnServerType.BattleServer, Network.OnData1, Network.OnDisConnect1, 
									Network.OnConnectSuccess1, Network.OnConnectFail1)
									
	this.connAddress = {}
	this.ticked = false;	
	this.reconnect = false;

	--是否检测超时设置
	if GIsEdit then
		--如果是Editor下，为了方便调试，可以设置不检测超时和自动重连
		this.CheckServerTimeout = true;

		--模拟网络不好情况测试
		--NetManager:SetMonitorBadNetWork(连接id, 发送数据延迟下限, 发送数据延迟上限, 收数据延迟下限, 收数据延迟上限, 每隔多少秒网络中断1次 );
		--NetManager:SetMonitorBadNetWork( ConnServerType.GameServer, 0.1, 2, 0.1, 2, 15 );
	else
		this.CheckServerTimeout = true;
	end
end

function Network.StartTick()
	if this.ticked then
		return;
	end
	UpdateBeat:Add( this.Tick, this );
	this.ticked = true;
	this.tickTimeCounter = 0;
	this.waitRefCount = 0;
	this.tickOffsetTime = 15; --发送心跳消息间隔
	this.timeOutNum = 3;
end

function Network.StopTick()
	if not this.ticked then
		return;
	end
	UpdateBeat:Remove( this.Tick, this);
	this.ticked = false;
end

--tick interval = 1s
function Network.Tick()
	--send heart beat
	this.tickTimeCounter = this.tickTimeCounter + Time.unscaledDeltaTime;
	if this.tickTimeCounter >= this.tickOffsetTime then
		local nowGameTime = Time.realtimeSinceStartup;
		--GameService.SendHeartBeat(nowGameTime*1000);
		this.waitRefCount = this.waitRefCount + 1;
		this.tickTimeCounter = 0;
	end

	--check if wait heartbeat response time out
	if this.CheckServerTimeout then
		if this.waitRefCount >= this.timeOutNum then  --this means have 45s no responsed
		  	this.CloseAllConnectAndReconnecting();
		  	return;
		end
		--msg wait response tick
		if MsgControl.CheckServicesTimeout(Time.unscaledDeltaTime) then
			this.CloseAllConnectAndReconnecting();
			return;		
		end		
	end
end


function Network.CloseAllConnectAndReconnecting()
	if this.startReconnectingTime ~= nil and Time.realtimeSinceStartup - this.startReconnectingTime < 5 then  
	    --防止短时间内重复调用 
		return;
	end
	this.startReconnectingTime = Time.realtimeSinceStartup;
	this.CloseAllConnect(true);
	this.ShowReconnecting();	
end


--自动重连进入游戏回调
function Network.OnReEnterGameServerResult( succeed )
	this.startReconnectingTime = nil;
	if succeed then
		this.waitRefCount = 0;
	end
end



--收到了服务器的心跳消息
function Network.OnHeartBeatResponsed()
	this.waitRefCount = 0;
end

--网络模块卸载
function Network.Unload()
	--MsgManager:Inst():Destroy();
end


--设置服务器连接地址和端口
function Network.SetConnInfo(  _connServerType, _addr, _port )
	if this.connAddress[_connServerType] == nil then
		this.connAddress[_connServerType] = {}
	end
	this.connAddress[_connServerType].addr = _addr;
	this.connAddress[_connServerType].port = _port;
end

--连接服务器
function Network.TryConnect(  _connServerType )
	local connInfo = this.connAddress[_connServerType]
	if connInfo == nil then
		error("server address not set! _connServerType=".._connServerType)
		return;
	end
	NetManager:TryConnect(_connServerType, connInfo.addr, connInfo.port );
	log(">>> Network.TryConnect.."..connInfo.addr..":"..connInfo.port);

end


function Network.TryReconnecting()
	Network.TryConnect(ConnServerType.GameServer)
	this.reconnect = true;
end


--主动断开连接接口
function Network.CloseConnect( _connServerType )
	NetManager:CloseConnect( _connServerType )
	if _connServerType == ConnServerType.GameServer then
		this.reconnect = false;
		this.StopTick();
	end
end

function Network.CloseAllConnect( _needReconnecting )
	this.reconnectAfterClose = _needReconnecting;  
	for k, v in pairs( this.connAddress ) do
		this.CloseConnect( k );
	end

	log("Network.CloseAllConnect--"..tostring(_needReconnecting))
end


--获取连接状态，参数connType=ConnServerType, 返回SocketStateTypeDefine
function Network.GetConnState( _connServerType )
	return NetManager:GetConnectState( _connServerType )
end

--数据事件
function Network.OnData0( dataId, dataBuffer )
	--MsgManager:Inst():RecvMsg(dataId,dataBuffer, ConnServerType.GameServer)
end


--断开事件， 注意：客户端调用CloseConnect主动断开不会走到这里
function Network.OnDisConnect0( _isManual )
	this.StopTick();
	Event.Brocast( EventDefine.OnServerDisconnect, _isManual );
	
	GlobalBehaviour.OnDisConnect0(_isManual);
	
	--尝试自动重连
	if not _isManual then
		this.ShowReconnecting()
	end	

	log("Network.OnDisConnect0 -- _isManual="..tostring(_isManual))
end


function Network.ShowReconnecting()
	
	if not this.reconnectAfterClose then 
		log("Network.ShowReconnecting---return 0")
 		return;
 	end

 	if( SceneManager:Inst():GetCurrentSceneName() == SceneNames.LoginScene ) then
 		log("Network.ShowReconnecting---return 1")
		return;
	end

	if IsUIVisible(UINames.UIReconnecting) then
		log("Network.ShowReconnecting---return 2")
		return;
	end

	-- if NewPlotMgr.IsRunning() then
	-- 	log("Network.ShowReconnecting---return 3")
	-- 	return;
	-- end

	log("Network.ShowReconnecting---ok")
	ShowUI( UINames.UIReconnecting );

end


--连接成功处理
function Network.OnConnectSuccess0()

	log("[LoginDebug] OnConnectSuccess0, time="..Time.time)

	this.reconnectAfterClose = true;

	--连接服务器后首先发送握手消息，握手回应后成功后才能发送其他消息
	--GameService.ReqHandShake( "", "", "" )	
	this.checkHandShakeTimeoutTimerId = LuaTimer:Add( function()
			if this.waitHandShake then
				--握手响应超时处理
				if this.checkHandShakeTimeoutTimerId then
					ShowTips( GetStrDic(StrEnum.ServerHandShakeTimeout) );
				end
				this.checkHandShakeTimeoutTimerId = nil;
			end
		end, ServicesResponseTimeOut, 0, true)

	Event.Brocast(EventDefine.OnServerConnectSuccess, this.reconnect)

end


--握手回应
function Network.OnHandleShake( _isOk )

	log("[LoginDebug] OnHandleShake ok="..tostring(_isOk)..";time="..Time.time );

	if this.checkHandShakeTimeoutTimerId then
		LuaTimer:Remove( this.checkHandShakeTimeoutTimerId )
		this.checkHandShakeTimeoutTimerId = nil;
	end

	if _isOk then

		--握手成功，开启心跳tick
		this.StartTick();

		--如果在游戏中中断，走自动重连流程
		if this.reconnect and GameStateData.isGameLogicRunning then
			-- local charguid = PlayerData:Inst():GetGUID();
			-- if charguid ~= nil and charguid ~= 0 then
			-- 	local userId = PlayerPrefs.GetString("defaultuserid", "");	
			-- 	local useSDK = PlayerPrefs.GetInt("useSDK");
			-- 	local token = PlayerPrefs.GetInt("token");
			-- 	if useSDK == 1 then
			-- 		userId = PlayerPrefs.GetString("uid");
			-- 	end
			-- 	--GameService.ReqReConnectGame(userId, charguid, token)	
			-- end	
	 	end
		this.reconnect = false;	

	else

		ShowTips( GetStrDic( StrEnum.ServerHandShakeFailed) );		
	end


	Event.Brocast( EventDefine.OnLoginHandShake, _isOk );

end


--连接失败
function Network.OnConnectFail0()
	Event.Brocast( EventDefine.OnServerConnectFail );
	GlobalBehaviour.OnConnectFail0(_isManual);
	
	--ShowErrorTips( GetStrDic(StrEnum.ServerConnectErr) );
end






----------------------------------------------------------------------------------战斗服务器事件
--数据事件
function Network.OnData1( dataId, dataBuffer )
	--MsgManager:Inst():RecvMsg(dataId, dataBuffer, ConnServerType.BattleServer)
end

--断开事件
function Network.OnDisConnect1(_isVoluntary)
	Event.Brocast( EventDefine.OnBattleServerDisconnect, _isVoluntary );
	logWarn("Network.OnDisConnect1")
end

--连接成功
function Network.OnConnectSuccess1()
	Event.Brocast( EventDefine.OnBattleServerConnectSuccess );
	log("Network.OnConnectSuccess1")
end

--连接失败
function Network.OnConnectFail1()
	Event.Brocast( EventDefine.OnBattleServerConnectFail );
	log("Network.OnConnectFail1")
end

