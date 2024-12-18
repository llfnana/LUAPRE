local json = require 'cjson'

--热更新模块，暂时只用检查是否有更新，返回登录界面时检查一下，本来这些代码应该都写在C#里，
--但是为了当前版本热更新，这种逻辑暂时先在这里用Lua写 【20190122】

HotfixModule = {}
local this = HotfixModule;


function HotfixModule.StartCheckResVersion( _callback )
	this.callback = _callback;

	local url = Util.GetVersionServiceUrl() --"http://pmversion-test.enjoyf.cn/php/getversion.php";

	if url == nil or url == "" then
		error("[HotfixModule.StartCheckResVersion] url is null!")
		return;
	end

	local p1 = "?deviceid="..(SystemInfo.deviceUniqueIdentifier or "");
	local p2 = "&appver="..Game.GetAppVersion();
	local p3 = "&resver="..Game.GetResVersion();	
	local p4 = "&channelid=1"---tostring(SDKManager:GetChannelId());

--	local strPlatform = string.lower( tostring(Application.platform) )
--	if strPlatform == "iphoneplayer" then --C#里用的ios, 这里统一一下
--		strPlatform = "ios"
--	elseif strPlatform == "windowsplayer" then 
--		strPlatform = "win";
--	end

	--local p5 = "&platform="..strPlatform;
	local p5 = "&platform=win"
	local fullurl = url .. p1 .. p2 .. p3 .. p4 .. p5;
	this.fullurl = fullurl;
	HttpAgent:HttpGet( fullurl, this.OnGetVersionCallback, false )
	
	local eventData = {};
	eventData["url"] = fullurl;
	local strEventData = json.encode(eventData);
	Game.OnGameTrackCustomEvent(WMTrackEventDefine.gameUpdateAssetBegin, strEventData);
	--error('StartCheckResVersion:'..fullurl)
end


function HotfixModule.OnGetVersionCallback(_jsonData)

	--error("HotfixModule.OnGetVersionCallback:".._jsonData)

	local json = require 'cjson'
	if json == nil then
		return;
	end

	if _jsonData == nil then
		error("[HotfixModule.OnGetVersionCallback] json is nil!")
		return;
	end

	if _jsonData == "" then
		error("[HotfixModule.OnGetVersionCallback] json is empty!")
		return;
	end

	local isValidJson = Util.CheckJsonString( _jsonData );
	if not isValidJson then
		error("[HotfixModule.OnGetVersionCallback]invalid json! json="+_jsonData);
		return;			
	end	

	local data = json.decode(_jsonData)
	if data == nil then
		return;
	end

	local VerInfos = data.VerInfos;
	if VerInfos == nil then
		return;
	end

	local cnt = #VerInfos;
	if cnt <= 0 then
		return;
	end

	local lastHotfixInfo = VerInfos[cnt];
	if lastHotfixInfo == nil then
		return;
	end

	local lastResVersion = lastHotfixInfo.ver;
	if lastResVersion == nil then
		return;
	end

	--error("lastResVersion="..lastResVersion)
	local curResVer = Game.GetResVersion();
	
	local hasNew = false;
	--[[
	local diff = VersionAdapter.CompareVersion( lastResVersion, curResVer, 3 )	
	if diff > 0 then
		hasNew = true;
	end
	--]]

	local eventData = {};
	eventData["url"] = this.fullurl;
	local strEventData = json.encode(eventData);
	Game.OnGameTrackCustomEvent(WMTrackEventDefine.gameUpdateAssetSuccess, strEventData);
	
	this.NotifyResult( hasNew );

end

function HotfixModule.NotifyResult(hasNewVersion)
	if this.callback ~= nil then
		
		this.callback( hasNewVersion );
		this.callback = nil;

	else

		if hasNewVersion then
			--default handler
			ShowUI( UINames.UICommonEnsure, GetStrDic(StrEnum.ExitForUpdateResTips), function()
				if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.Android then
					AndroidUtil.RestartApplication();
				else
					Application.Quit();
				end
			end )
		end

	end	
end






