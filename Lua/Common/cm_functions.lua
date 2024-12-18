--[[
	全局工具函数
--]]

unpack = unpack or table.unpack()

Mathf.RoundToInt = Mathf.RoundToInt or function (f)
	--银行家算法
	local i = math.floor(f)
	local f1 = f - i
	if f1 > 0.5 then
		return i + 1
	elseif f1 < 0.5 then
		return i
	else
		if i % 2 == 0 then
			return i
		else
			return i + 1
		end
	end
end

-- 加载一个场景
function CreateScene(name)
    SceneManager:Inst():ChangeScene(name)
end

--得到一个字符串名称
function GetFieldName(nameID)
    return TableManager:Inst():GetTableDataByKey(EnumTableID.TabStaticStr, nameID, "Str");
end

function Handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

--获取模型资源名称
function GetModelResName( _modelId )
	local curQualityLevel = GameQuality.QualityLevel;
	local modelInfo = TableManager:Inst():GetTabData(EnumTableID.TabModelID, _modelId);
	if modelInfo ~= nil then
		local resName = nil;
		if curQualityLevel == QualityLevel_High then
			resName = modelInfo.ResLod0;
		elseif curQualityLevel == QualityLevel_Medium then
			resName = modelInfo.ResLod1;
		elseif curQualityLevel == QualityLevel_Low or
			   curQualityLevel == QualityLevel_Lowest then
			resName = modelInfo.ResLod2;
		end
		if resName == nil then
			resName = modelInfo.ResLod0;
		end
		return resName;
	else
		return nil;
	end
end


-- function stringsplit_deprecated(str, reps)
--     local resultStrsList = {};
--     local fun = function(w) table.insert(resultStrsList, w) end
--     local pat = string.format("[^%s]+", reps);
--     string.gsub(str, pat, fun );
--     return resultStrsList;
-- end

function stringsplit(szFullString, szSeparator)
	if szFullString == nil then
		error("stringsplit: szFullString is nil")
		return {}
	end

	if szSeparator == nil then
		error("stringsplit: szSeparator is nil")
		return {szFullString}
	end


	local nFindStartIndex = 1
	local nSplitIndex = 1
	local retArray = {}
	local sepLen = string.len(szSeparator);
	local totalLen = string.len(szFullString);
	local findFunc = string.find;
	local subFunc = string.sub;
	while true do
	   local nFindLastIndex = findFunc(szFullString, szSeparator, nFindStartIndex,true)
	   if not nFindLastIndex then
	   		local lastStr = subFunc(szFullString, nFindStartIndex, totalLen)
	   		if lastStr ~= "" then
	   			retArray[nSplitIndex] = lastStr
	   		end
	   		break
	   end
	   retArray[nSplitIndex] = subFunc(szFullString, nFindStartIndex, nFindLastIndex-1);
	   nSplitIndex = nSplitIndex + 1;
	   nFindStartIndex = nFindLastIndex + sepLen;
	   -- if nFindStartIndex >= totalLen then
	   -- 		break;
	   -- end
	end
	return retArray;
end


--按添加顺序，之后使用ipairs遍历
function stringsplit_order(str, sep)
	 str = str or "";
	 sep = sep or "\t";
	-- local t, i = {}, 1;
	-- local pat = string.format("([^%s]+)", sep)
	-- for s in string.gmatch(str, pat) do
	-- 	t[i] = s;
	-- 	i = i + 1
	-- end
	-- return t
	return stringsplit(str,sep);
end

-- 字符串拆分成数字
function numberSplit(str, reps)
	str = str or "";
	reps = reps or "|";
	-- local resultStrsList = {};
	-- local fun = function(w) table.insert(resultStrsList, tonumber(w)) end
	-- local pat = string.format("[^%s]+", reps);
	-- string.gsub(str, pat, fun );
	-- return resultStrsList;
	local astr = stringsplit( str, reps );
	local an = {}
	for i = 1, #astr do
		table.insert(an, tonumber(astr[i]));
	end
	return an;
end

--按添加顺序，之后使用ipairs遍历
function numberSplit_order(str, sep)
	str = str or "";
	sep = sep or "\t";
	-- local t, i = {}, 1;
	-- local pat = string.format("([^%s]+)", sep)
	-- for s in string.gmatch(str, pat) do
	-- 	t[i] = tonumber(s)
	-- 	i = i + 1
	-- end
	-- return t
	return numberSplit( str, sep );
end

-- 去除字符串两边的空格  
function stringTrim(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

--字符串替换
function StringReplace( str, oldstr, newstr )
	return string.gsub( str, oldstr, newstr );
end

function splitLine(str, reps)
 	if str == nil then
 		error("splitLine: str is nil")
 		return {}
 	end

    local resultStrsList = {};
   
    for match in (str..reps):gmatch("(.-)"..reps) do
        table.insert(resultStrsList, match)
    end
    
    return resultStrsList;    
end

--输出日志--

--设置日志等级
local LOG_LEVEL_DEBUG = 0
local LOG_LEVEL_INFO = 1
local LOG_LEVEL_WARNING = 2
local LOG_LEVEL_ERROR = 3
local CurLogLevel = LOG_LEVEL_DEBUG;
if GIsEdit or GIsDevelopment then
	CurLogLevel = LOG_LEVEL_DEBUG;
else
	CurLogLevel = LOG_LEVEL_INFO;
end



function log(str)
	if CurLogLevel > LOG_LEVEL_DEBUG then
		return;
	end
    Util.Log(str);
end

--消息类型的Debug日志
local logSwitchMsg = true;
function logMsg(str)
	if logSwitchMsg then
	    Util.Log(str);
	end
end

--打印字符串--
--function print(str)
--	if CurLogLevel > LOG_LEVEL_DEBUG then
--		return;
--	end
--	Util.Log(str);
--end

--错误日志--
function error(str)
	print('print error:', str, debug.traceback())
end

--重要信息日志
function info(str)
	if CurLogLevel > LOG_LEVEL_INFO then
		return;
	end	
	Util.LogInfo(str);
end

function logInfo(str)
	if CurLogLevel > LOG_LEVEL_INFO then
		return;
	end		
	Util.LogInfo(str);
end

--警告日志--
function warn(str) 
	if CurLogLevel > LOG_LEVEL_WARNING then
		return;
	end		
	Util.LogWarning(str);
end
function logWarn(str)
	if CurLogLevel > LOG_LEVEL_WARNING then
		return;
	end			
	Util.LogWarning(str);
end

function isNil(uobj)
	return uobj == nil or uobj:Equals(nil)
end

--查找对象--
function find(str)
	return GameObject.Find(str);
end

function destroy(obj)
	GameObject.Destroy(obj);
end

function newObject(prefab)
	return GameObject.Instantiate(prefab);
end

function get_go_path(_go, endPathGG)
	--把路径也打出来吧，不然也是个难找
	function string_starts(String,Start)
		return string.sub(String,1,string.len(Start))==Start
	end
	
	--function string_ends(String,End)
	--	return End=='' or string.sub(String,-string.len(End))==End
	--end
	
	local goName = ""
	repeat
		if _go == nil then  break; end
		if goName == "" then  goName=_go.name else goName = _go.name .. "/" .. goName end
		if endPathGG ~= nil and endPathGG ~= "" and string_starts(_go.name, endPathGG) then break end
		if _go.transform.parent == nil then break end
		_go = _go.transform.parent.gameObject
	until false
	return goName
end

-- --创建面板--
-- function createPanel(name)
-- 	panelMgr:CreatePanel(name);
-- end

-- function child(str)
-- 	return transform:Find(str);
-- end

-- function subGet(childNode, typeName)		
-- 	return child(childNode):GetComponent(typeName);
-- end



function findPanel(str) 
	local obj = find(str);
	if obj == nil then
		error(str.." is null");
		return nil;
	end
	return obj:GetComponent("BaseLua");
end


----------------------------------------------------------取table元素个数
function tableSize(tb)
	local count = 0
	if tb then
		for i, v in pairs(tb) do
			count = count + 1
		end
	end	
	return count;
end
table.size = tableSize


----------------------------------------------------------
function print_r( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end
table.print = print_r


---------------------添加子节点-------------------------------------
function AddChild( parent, go, localPosition)
	if parent == nil then
		return;
	end

	if nil == localPosition then
		localPosition =  Vector3.zero;
	end

    local parentTrans = parent.transform;
	local childtrans = go.transform;
	childtrans:SetParent(parentTrans);
	childtrans.localPosition = localPosition;
	--childtrans.localRotation = Quaternion.identity;
	childtrans.localScale = Vector3.one;
	go.layer = parent.layer;
end


---------------------设置层级-------------------------------------
function SetLayerName(obj,layerName)
	local layerNum = LayerMask.NameToLayer(layerName)
	SetLayer( obj, layerNum )
end

function SetLayer( obj, layer )
	-- obj.layer = layer
	-- for i = 0, obj.transform.childCount - 1 do
	-- 	local trans = obj.transform:GetChild(i)
	-- 	SetLayer(trans.gameObject,layer)
	-- end	
	Util.SetLayer( obj, layer )
end


-- 将时间分解为{天,时,分,秒}
function SpliteTime(uTime)
	local uD = math.floor( uTime / 86400 )
	local uH = math.floor( math.mod(uTime, 86400) / 3600 )
	local uM = math.floor( math.mod(uTime, 3600) / 60 )
	local uS = math.mod(uTime, 60)
	return {uD, uH, uM, uS}
end

-- 格式化成以分钟计时的时间字符串
function TimeToMinuteString(time)
	if time <= 0 then
		return "00:01";
	end
	local tempTime = time;
	local minute = 0;
	if (tempTime >= 60) then
		minute = math.floor(tempTime/60);
		tempTime = math.mod(tempTime, 60);
	end
	return string.format("%02d:%02d", minute, tempTime)
end

function TimeToSketchyString(varCTime)
	local nowCTime = TimeMgr:Inst():GetServerTime()
	local diffTime = nowCTime - varCTime
	local str = ""
	if (diffTime <= 60) then		-- 小于1分钟
		str = GetStrDic(StrEnum.JustMinute)
	elseif (diffTime <= 3600) then	-- 小于1小时
		str = string.format(GetStrDic(StrEnum.MinuteAgo), math.floor(diffTime / 60))
	elseif (diffTime <= 86400) then	-- 小于24小时
		str = string.format(GetStrDic(StrEnum.HoursAgo), math.floor(diffTime / 3600))
	else	-- 大于24小时
		str = GetCurrentServerShowTime("%m-%d %H:%M",varCTime); 
		--os.date("%m-%d %H:%M", varCTime)
	end
	
	return str
end

---------------------把秒数显示成00:00的格式，用于倒计时-----------
function TimeToMinuteStringEx( seconds )
	local tempTime = seconds;
	if tempTime <= 0 then
		return "00:01"
	else
		return string.format("%02d:%02d", math.floor(tempTime / 60), math.mod(tempTime, 60))
	end
end

---------------------把秒数显示成00:00:00的格式，用于倒计时-----------
function TimeToHourString(time)
	
	if time == 0 then
		return "00:00:00";
	elseif time < 0 then
		return "--:--:--";
	else
		local tempTime = math.floor(time);
	
		local day = 0;
		if (tempTime >= 3600 * 24) then
			day = math.floor(tempTime/ (3600 * 24));
			tempTime = math.floor(math.mod(tempTime, (3600 * 24)));
		end
		
		local hour = 0;
		if (tempTime >= 3600) then
			hour = math.floor(tempTime/3600);
			tempTime = math.floor(math.mod(tempTime, 3600));
		end
	
		local minute = 0;
		if (tempTime >= 60) then
			minute = math.floor(tempTime/60);
			tempTime = math.floor(math.mod(tempTime, 60));
		end

		if day > 0 then
			return string.format("%dd %02d:%02d:%02d", day, hour, minute, tempTime )
		else
			return string.format("%02d:%02d:%02d", hour, minute, tempTime )
		end
	end	
end

---
-- @function: 打印table的内容，递归
-- @param: tbl 要打印的table
-- @param: level 递归的开始到结束层数
-- @param: filteDefault 是否过滤打印构造函数，默认为是
-- @return: return
function printTable( tbl , beginlevel, endLevel, filteDefault)
	beginlevel = beginlevel or 1
	endLevel = endLevel or 1
	
  if(beginlevel > endLevel) then return end;

  local msg = ""
  if filteDefault == nil then
  	filteDefault = true;
  end
  
  local indent_str = ""
  for i = 1, beginlevel do
    indent_str = indent_str.."  "
  end

  print(indent_str .. "{")
  for k,v in pairs(tbl) do
    if filteDefault then
      if k ~= "_class_type" and k ~= "DeleteMe" then
        local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
        print(item_str)
        if type(v) == "table" then
          printTable(v, beginlevel + 1, endLevel)
        end
      end
    else
      local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
      print(item_str)
      if type(v) == "table" then
        printTable(v, beginlevel + 1, endLevel)
      end
    end
  end
  print(indent_str .. "}")

end

---------------------------------------------------
-- 一个Table遍历的迭代器, 这样能保证顺序便利所要的东西
-- 可以使用 for k, v in pairsByKeys(table, doSort) do 
-- 注意：doSort这个函数必须保证这个排序是稳定排序
-- bipairs 是否使用ipairs还是pairs的方式
-------------------------------------------------- 
function pairsByKeys(t, doSort, bipairs)
	local a = {}
	local b = {}
	local idx = 1

	if (bipairs == nil or (not bipairs)) then
		for k,v in pairs(t) do
			a[idx] = v;
			b[a[idx]] = k;
			idx = idx + 1;
		end
	else
		for k,v in ipairs(t) do
			a[idx] = v;
			b[a[idx]] = k;
			idx = idx + 1;
		end
	end
	
	if nil == doSort then
		table.sort(a)
	else
		table.sort(a, doSort)
	end

	local i = 0
	return function()
		i = i + 1
		if a[i] == nil then return nil
		else return b[a[i]], a[i]
		end
	end
end

---------------------------------------------------
function GetCurTick()
	return TimeMgr:Inst():GetCurTick();
end

---------------------------------------------------
function GetServerTime()
	return TimeMgr:Inst():GetServerTime();
end

--------------------------------------------------
function GetCurrentServerShowTime(format,time)
	return TimeMgr:Inst():GetCurrentServerShowTime(format,time);
end

function GetIntervalTimeStamp(targetTimeStamp,currentTimeStamp)
	return TimeMgr:Inst():GetIntervalTimeStamp(targetTimeStamp,currentTimeStamp);
end

--------------------------------------------------
---得到客户端手机时间戳（本地时间）
---os.time() 也是包含时区的当前本地时间
function GetZoneTime(uTime)
	if uTime == nil then
		return os.time();
	end
	
	--先记下这个格林尼治时间，返回本时区是这个时间table的时候的时间戳。
	--前面减去后面表示当前时区时间比格林尼治时间大的秒数
	local zone = os.difftime(uTime, os.time(os.date("!*t", uTime)))/3600;
	local localTime = uTime + zone * 3600;
	return localTime;
end

--------------------------------------------------
---得到时区
function GetCurrentTimeZone()
	--先记下这个格林尼治时间，返回本时区是这个时间table的时候的时间戳。
	--前面减去后面表示当前时区时间比格林尼治时间大的秒数
	local now = os.time()
	local zone = os.difftime(now, os.time(os.date("!*t", now)))/3600;
	return zone
end

---------------------------------------------------
function GetFileNameWithExt( _path )
	local rs = string.reverse( _path );
	local p1 = string.find( rs, "/");
	if p1 == nil then
		p1 = string.find( rs, "\\");
	end

	if p1 == nil then
		return _path;
	end

	local pos = string.len(rs) - p1 + 1
	return string.sub( _path, pos + 1 );
end

---------------------------------------------------
function GetFileNameWithoutExt( _path )
	local nameWithExt = GetFileNameWithExt( _path );
	local rs = string.reverse( nameWithExt );
	local p1 = string.find(rs, "%.");
	if p1 == nil then
		return nameWithExt;
	end
	local pos = string.len(rs) - p1 + 1
	return string.sub( nameWithExt, 1, pos-1 );
end

---------------------------------------------------
--通过id获得资产类型
function GetAssetType( _id )
	if _id <= 0 then
		return eAssetType_Invalid
	elseif( _id >= 1 and _id <= 100 ) then
		return eAssetType_Money;
	elseif( _id >= 20000 and _id <= 29999) then
		return eAssetType_FuWen;
	elseif(_id == 50000) then
		return eAssetType_Phyical;
	elseif( _id >= 100000 and _id <= 799999 ) then
		return eAssetType_Item;
	elseif( _id >= 800000 and _id <= 999999 ) then
		return eAssetType_Equip;
	else
		return eAssetType_Invalid;
	end
end

---------------------------------------------------
--获取货币，道具，装备名称
function GetAssetName( _id )
	local at = GetAssetType( _id )
	local strId = nil;
	if at == eAssetType_Money then
		local tabInfo =  TableManager:Inst():GetTabData( EnumTableID.TabMoney, _id );
		if tabInfo ~= nil then
			strId = tabInfo["Name"]
		end
	elseif at == eAssetType_Item then
		local tabInfo =  TableManager:Inst():GetTabData( EnumTableID.TabItem, _id );
		strId = tabInfo["NameID"]		
	elseif at == eAssetType_Equip then
		local tabInfo =  TableManager:Inst():GetTabData( EnumTableID.TabEquip, _id );
		strId = tabInfo["NameId"]
	end
	if strId ~= nil then
		return GetStaticStr( strId );
	end
end

---------------------------------------------------
--获取货币，道具，装备名称和描述
function GetAssetNameAndDesc( _id )
	local at = GetAssetType( _id )
	local nameId = nil;
	local descId = nil;
	if at == eAssetType_Money then
		local tabInfo =  TableManager:Inst():GetTabData( EnumTableID.TabMoney, _id );
		nameId = tabInfo["Name"]
		descId = tabInfo["Info"]
	elseif at == eAssetType_Item then
		local tabInfo =  TableManager:Inst():GetTabData( EnumTableID.TabItem, _id );
		nameId = tabInfo["NameID"]	
		descId = tabInfo["DescID"]	
	elseif at == eAssetType_Equip then
		--todo
	end

	local nameStr = nil;
	local descStr = nil;

	if nameId ~= nil then
		nameStr = GetStaticStr( nameId );
	end

	if descId ~= nil then
		descStr = GetStaticStr( descId );
	end

	return nameStr, descStr;
end


----------------------------------------------------------
--通过ID获取该物品（货币，道具，装备）的奖励显示信息：名称，品质，图标id等
function GetCommonItemUIInfo( _id )
	local at = GetAssetType( _id )
	if at == eAssetType_Money then
		local tabInfo = TableManager:Inst():GetTabData(EnumTableID.TabMoney, _id );
		if tabInfo ~= nil then
			local uiInfo = {}
			uiInfo.id = _id;
			uiInfo.name = GetStaticStr(tabInfo.Name)
			uiInfo.iconId = tabInfo.BigIcon;
			uiInfo.quality = 1
			uiInfo.field = tabInfo;
			return uiInfo;
		end		
	elseif at == eAssetType_Item then
		local tabInfo = TableManager:Inst():GetTabData(EnumTableID.TabItem, _id);
		if tabInfo ~= nil then
			local uiInfo = {}
			uiInfo.id = _id;
			uiInfo.name = GetStaticStr(tabInfo.NameID)
			uiInfo.iconId = tabInfo.IconID;
			uiInfo.quality = tabInfo.Quality
			uiInfo.tip = "";
			uiInfo.field = tabInfo;
			if tabInfo.TipStrID ~= nil and tabInfo.TipStrID > 0 then
				uiInfo.tip  = GetStaticStr(tabInfo.TipStrID);
			end		
			
			return uiInfo;
		end		
	elseif at == eAssetType_Equip then
		local tabInfo = TableManager:Inst():GetTabData(EnumTableID.TabEquip, _id);
		if tabInfo ~= nil then
			local uiInfo = {}
			uiInfo.id = _id;
			uiInfo.name = GetStaticStr(tabInfo.NameId)
			uiInfo.iconId = tabInfo.IconId;
			uiInfo.quality = tabInfo.Quality
			uiInfo.level = tabInfo.Level;
			uiInfo.field = tabInfo;
			return uiInfo;
		end		
	elseif at == eAssetType_FuWen then
		local tabInfo = TableManager:Inst():GetTabData(EnumTableID.TabFuWen, _id);
		if tabInfo ~= nil then
			local uiInfo = {}
			uiInfo.id = _id;
			uiInfo.name = GetStaticStr(tabInfo.NameID)
			uiInfo.iconId = tabInfo.IconID;
			uiInfo.quality = 0
			uiInfo.level = tabInfo.Level;
			uiInfo.field = tabInfo;
			return uiInfo;
		end
	end
	return nil;
end



--------------------------------------------------
--错误代码提示
function TipErrorCodeMsg(errorCodeId)
	if errorCodeId == nil or type(errorCodeId) ~= "number" then
		return;
	end
	
	local msg = TableManager:Inst():GetTableDataByKey(EnumTableID.TabErrorCode, errorCodeId, "Str");
	if msg == nil or msg == "" then
		if not GameStateData.IsChineseSimplified then
			msg = TryGetStringFromChineseSimplifiedTable(EnumTableID.TabErrorCode_ChineseSimplified, errorCodeId, "Str", nil)
			if msg == nil or msg == "" then
				return;
			end
		else
			return;
		end
	end
	
	ShowTips(msg);
end




----------------------------------------------------------------------
--获取平台
RuntimePaltform_Windows = 0
RuntimePaltform_Android = 1
RuntimePaltform_IOS = 2
RuntimePlatform_Mac = 3
RuntimePaltform_WindowsPhone = 4
RuntimePlatform_Linux = 5

local _runtimePlatformCache = _runtimePlatformCache or nil;

function GetRuntimePlatform()
	if _runtimePlatformCache ~= nil then
		return _runtimePlatformCache;
	end
	local enumPlatform = UnityEngine.Application.platform;
	--error( "111111111=".. tostring(enumPlatform) )
	if enumPlatform == UnityEngine.RuntimePlatform.WindowsPlayer or enumPlatform == UnityEngine.RuntimePlatform.WindowsEditor then
		_runtimePlatformCache = RuntimePaltform_Windows
	elseif enumPlatform == UnityEngine.RuntimePlatform.WSAPlayerX86 or enumPlatform ==  UnityEngine.RuntimePlatform.WSAPlayerX64 or
		 				enumPlatform == UnityEngine.RuntimePlatform.WSAPlayerARM or  enumPlatform == UnityEngine.RuntimePlatform.WP8Player then
		 _runtimePlatformCache = RuntimePaltform_WindowsPhone;
	elseif enumPlatform == UnityEngine.RuntimePlatform.Android then
		_runtimePlatformCache = RuntimePaltform_Android;
	elseif enumPlatform == UnityEngine.RuntimePlatform.IPhonePlayer then
		_runtimePlatformCache = RuntimePaltform_IOS;
	elseif enumPlatform == UnityEngine.RuntimePlatform.OSXPlayer or enumPlatform == UnityEngine.RuntimePlatform.OSXEditor  or
		   enumPlatform == UnityEngine.RuntimePlatform.OSXDashboardPlayer then
		_runtimePlatformCache = RuntimePlatform_Mac;
	elseif enumPlatform == UnityEngine.RuntimePlatform.LinuxPlayer or enumPlatform == UnityEngine.RuntimePlatform.LinuxEditor then
		_runtimePlatformCache = RuntimePlatform_Linux;
	end
	return _runtimePlatformCache
end

---------------------------------------------
--！！！！
function EquipType2CategoryType(equipType)
	if equipType == nil then
		error("function EquipType2CategoryType. equipType is nil");
		return EQUIP_CATEGORY_ARMORS;
	end
	
	if equipType == GENERAL_EQUIP_SLOT_WEAPON then
		return EQUIP_CATEGORY_ARMS;
	elseif equipType == GENERAL_EQUIP_SLOT_RING or equipType == GENERAL_EQUIP_SLOT_NECKLACE then
		return EQUIP_CATEGORY_ORNAMENTS;
	else
		return EQUIP_CATEGORY_ARMORS;
	end	
end

function GetCategoryNameFromEquipType(equipType)
	
	local categoryType = EquipType2CategoryType(equipType);
	if categoryType == EQUIP_CATEGORY_ARMORS then
		-- 盔甲
		return GetStrDic(StrEnum.EQUIP_CATEGORY_ARMORS);
	elseif categoryType == EQUIP_CATEGORY_ARMS then
		-- 武器
		return GetStrDic(StrEnum.EQUIP_CATEGORY_ARMS);
	elseif categoryType == EQUIP_CATEGORY_ORNAMENTS then
		-- 饰品
		return GetStrDic(StrEnum.EQUIP_CATEGORY_ORNAMENTS);
	end
	
	return "";
end

function CreateColorFromHex(r, g, b, a)
	return Color.New(r / 255, g / 255, b / 255, (a or 0xff) / 255);
end

function NewHexColor(hex)
	local r = bit.rshift(bit.band(hex, 0xff0000), 16) / 255
	local g = bit.rshift(bit.band(hex, 0x00ff00), 8) / 255
	local b = bit.band(hex, 0x0000ff) / 255
	return Color.New(r, g, b)
end

--方向定义：于z轴正方向的成角，顺时针为正[0, pi]，逆时针为负[0, -pi]
function CalculateVectorRadian(v, defaultRadian)

	local radian = 0.0;
	if v.z ~= 0.0 then
	
		radian = math.atan(v.x / v.z);
		if v.z < 0.0 then
			radian = radian + math.pi;
		end
	
	else
	
		if v.x == 0.0 then
			radian = defaultRadian;
		elseif v.x > 0.0 then
			radian = math.pi * 0.5;
		else
			radian = math.pi * 1.5;
		end
	end
			
	return radian;
end

function IsPlayer(objGuid)
	if type(objGuid) == "number" and objGuid > 2000000 then
		return true;
	end
	
	return false;
end

--这个是重生的，是所有星星没了，暂时没做
function GetHeroReliveNeedDiamondByLeftTime(leftTime, diamondReliveCount, diamondReliveResetTime)
	if leftTime == nil or diamondReliveCount == nil or diamondReliveResetTime == nil then
		return UINT_MAX;
	end
	
	--这是些老的代码
	--[[
	if leftTime <= 21000 then
		return math.floor(-0.0001 * math.pow(leftTime, 2) + 4.2 * leftTime);
	end


	if leftTime == nil then
		return UINT_MAX;
	end
	return math.floor((math.log(leftTime + 1027) - 9) * 44100);
	]]

	if diamondReliveCount < 0 then
		diamondReliveCount = 0
	end
	
	local curTime = GetServerTime()
	if diamondReliveResetTime < curTime then --已经过期了，则使用第一次
		diamondReliveCount = 0
	end
	
	--uint32 diamondCount = GeneralLogic::GetReliveNeedDiamondCount(pGeneral->level) * (pGeneral->GetDiamondReliveCount()  + 1);
	local needgold = TimeToGold(leftTime);
	needgold = math.ceil(needgold) --服务器取的这个是整数
	
	local diamondCount = needgold * (diamondReliveCount + 1)
	return diamondCount
end

--这个是复活的，好区分
function GetHeroReliveNeedDiamond(generalData)
	if nil == generalData then
		return UINT_MAX
	end
	
	local generalLv = generalData.level
	if generalLv == nil then
		return UINT_MAX;
	end

	local diamondReliveCount = generalData.diamondReliveCount
	if diamondReliveCount == nil then
		return UINT_MAX;
	end

	if diamondReliveCount < 0 then
		diamondReliveCount = 0
	end
		
	local diamondReliveResetTime = generalData.diamondReliveResetTime
	if nil == diamondReliveResetTime then
		return UINT_MAX
	end
	
	local generalLvRes = TableManager:Inst():GetTabData(EnumTableID.TabGeneralLevel, generalLv);
	if generalLvRes == nil then
		return UINT_MAX;
	end

	local leftTime = generalLvRes.ReliveTime;
	local needgold = GetHeroReliveNeedDiamondByLeftTime(leftTime, diamondReliveCount, diamondReliveResetTime);
	return needgold
end

--打印Table表--
function PrintTable(tab)
  	local str = {}
    local tabRecord = {}
    
    local function printTableImp(tab, tabRecord,space)

    local ret = ""
    if tab == nil then
    	return "nil"
    end

    if rawget(tabRecord,tab) ~= nil then
    	return rawget(tabRecord,tab) .. "\n"
    else
    	rawset(tabRecord,tab,tostring(tab))
    end

	local nextSpace = space .. "   "
    	if type(tab) == "table" then
            ret = ret .. tostring(tab)
            ret = ret .. "\n" .. space .. "{\n"
        	for k,v in pairs(tab) do
            	ret = ret .. nextSpace .. "[" .. toStringEx(k) .. "]" .. ":" .. printTableImp(v, tabRecord,nextSpace)
          	end
          	ret = ret .. space .. "}"
      	else
          	ret = ret .. toStringEx(tab)
      	end
      	return ret .. "\n"
    end
	
	local str = printTableImp(tab, tabRecord, "")
    tabRecord = nil
    
    return str
end

function toStringEx(value)
    if value ~= nil then
        if type(value) == "string" then
            return "'"..value.."'"
        end
    end
    return tostring(value)
end

function bit:tostring( tab )
    local str=""
    for i=1, 32 do
        str = str..tab[i]
    end
    return str
end

function string.utf8len(input)  
	if input == nil then
		return 0;
	end

    local len  = string.len(input)  
    local left = len  
    local cnt  = 0  
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}  
    local asciiCount = 0
    while left ~= 0 do  
    	local tmp = string.byte(input, -left)
        local i   = #arr  
        while arr[i] do  
            if tmp >= arr[i] then  
                left = left - i  
                break  
            end  
            i = i - 1  
        end  
        cnt = cnt + 1  
        if i == 1 then
        	asciiCount = asciiCount + 1
        end
    end  
    return cnt, asciiCount
end  

function GetDayLeftTime()
	-- 获取当前服务器时间
	local now = os.date("*t", TimeMgr:Inst():GetServerTime()); 
	-- 当天的最后时间
	local dayEnd = os.time { year = now.year, month = now.month, day = now.day, hour = 23, min = 59, sec = 59 }
	-- 当前时间与零点的时间差
	return dayEnd + 1
end

function GetWeekLeftTime()
	-- 获取当前服务器时间
	local nowDayIndex = os.date("%w", TimeMgr:Inst():GetServerTime())
	--获取今天是星期几
	if nowDayIndex == 0 then
		nowDayIndex = 7
	end
	return (7 - nowDayIndex) * 24 * 3600 + GetDayLeftTime()
end



function GetRealAnimClipName( _animName, _modelId )
	local tabAnims = TableManager:Inst():GetTabData(EnumTableID.TabModelAnims, _modelId)
	if tabAnims ~= nil then
		if _animName == Anims.Move then
			return tabAnims.AnimMove;
		elseif _animName == Anims.Idle then
			return tabAnims.AnimIdle;
		elseif _animName == Anims.ShowIdle then
			return tabAnims.AnimShowIdle;
		elseif _animName == Anims.Dead then
			return tabAnims.AnimDead;
		elseif _animName == Anims.Attack then
			return tabAnims.AnimAttack;
		elseif _animName == Anims.Hurt then
			return tabAnims.AnimHurt;
		elseif _animName == Anims.Defend then
			return tabAnims.Defend;
		elseif _animName == Anims.Show then
			return tabAnims.AnimShow;
		end
	end
	return nil;
end



function ParseVector3( _string )
	if _string == nil then
		return nil;
	end
	local arr = stringsplit( _string, "|" )
	if arr == nil or #arr ~= 3 then
		error("ParseVector3 failed! invalid format: ".._string);
		return nil;
	end
	return Vector3.New( tonumber(arr[1]), tonumber(arr[2]), tonumber(arr[3]) )
end


--获取设备内存大小
local __systemMemSize;
function GetSystemMemorySize()
	if __systemMemSize == nil then
		__systemMemSize = UnityEngine.SystemInfo.systemMemorySize;
	end
	--error("__systemMemSize="..__systemMemSize)
	return __systemMemSize or 0;
end


--是否是服务器支持的合法字符串
function IsServerValidString( _str )
	if _str == nil then
		return false;
	end
	local str = stringTrim(_str);
	if str == "" then
		return false;
	end

	local invalidChars = { '"', '\'', ',', '\\' };

	for i = 1, #invalidChars do
		if string.find(str, invalidChars[i] ) ~= nil then
			return false;
		end
	end 
	return true;
end

function IsContentValid(content)
	if Util.GetLanguage()=="ChineseSimplified" then
		local sensWrods = TableManager:Inst():GetTable(EnumTableID.TabSensitiveWord);
		for k,v in pairs(sensWrods) do
			if string.match(content,v.Str) then
			  return false;
			end
		end	
	end
	return true;
end
--- nNum 源数字
--- n 小数位数
--- 
FormatDecimalType = {
	type_floor = 1, --向下
	type_upper = 2, --向上
	type_round = 3, --四舍五入
}
function GetPreciseDecimal(nNum, n, typefmt)
	if type(nNum) ~= "number" then
		return nNum;
	end
	n = n or 0;
	n = math.floor(n)
	if n < 0 then
		n = 0;
	end

	--默认向下取整
	if typefmt == nil then
		typefmt = FormatDecimalType.type_floor;
	end
	
	--如果是四舍五入，直接格式化就是四舍五入	,不用再复杂
	if typefmt == FormatDecimalType.type_round then
		local fmt = '%.' .. n .. 'f'
		return string.format(fmt, nNum);	
	end
	
	local nDecimal = 10 ^ n
	local nTemp;
	local nRet;
	if typefmt == FormatDecimalType.type_floor then
		nTemp = math.floor(nNum * nDecimal);		
	elseif  typefmt == FormatDecimalType.type_upper then
		nTemp = math.ceil(nNum * nDecimal);
	elseif  typefmt == FormatDecimalType.type_round then
		nTemp = math.floor(nNum * nDecimal + 0.5);
	end

	if nil == nTemp then
		return nNum;
	end
	
	nRet = nTemp / nDecimal;
	return nRet;
end