	

--一些不需要删除的Listener的hanlder逻辑放在这里


GlobalEventHandler = {}
local this = GlobalEventHandler;


function GlobalEventHandler.Init()
	Event.AddListener( EventDefine.OnBattleServerConnectSuccess, this.OnBattleServerConnectSuccess )
	Event.AddListener( EventDefine.OnBattleServerConnectFail, this.OnBattleServerConnectFail )
	Event.AddListener( EventDefine.OnBattleServerDisconnect, this.OnBattleServerDisconnect )
	Event.AddListener( EventDefine.OnFightBeginNotify, this.OnFightBeginNotify )
	Event.AddListener( EventDefine.OnFightEndNotify, this.OnFightEndNotify )
	Event.AddListener( EventDefine.OnCastleMoved, this.OnCastleMoved )

	this.SetAutoExitBattleScene( true )
end



--------------------------------------------------------------BattleServer连接成功
function GlobalEventHandler.OnBattleServerConnectSuccess()
	local handshakeKey = "haha"

end


--------------------------------------------------------------BattleServer连接失败
function GlobalEventHandler.OnBattleServerConnectFail()
	ShowErrorTips( GetStrDic(StrEnum.ServerConnectErr) );
end


--------------------------------------------------------------BattleServer断开连接
function GlobalEventHandler.SetAutoExitBattleScene( _isAutoExit )
	this.autoExitBattleScene = _isAutoExit
end


function GlobalEventHandler.OnBattleServerDisconnect()
	if not this.autoExitBattleScene then
		return;
	end
	--GameLogicUtils.ExitBattleScene();
end


--------------------------------------------------------------战斗开始提示
function GlobalEventHandler.OnFightBeginNotify(...)
	local args = { ... };
	--error( "OnFightBeginNotify;type="..args[1]..";argCount="..#args-1)
end

--------------------------------------------------------------战斗结束提示
function GlobalEventHandler.OnFightEndNotify(...)

	--todo

end


--------------------------------------------------------------城堡位置移动了
function GlobalEventHandler.OnCastleMoved()
	BigMapDataModel.PlayCityMoveEffect();
end
