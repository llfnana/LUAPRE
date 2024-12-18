--针对脚本里经常出现的nil异常等问题提供一些安全的函数，牺牲一点效率，保障代码的安全性
--代码中报错常见问题：
--1. 界面里 this.uidata  或  this.cachedata 为 nil!
--2. 界面和代码不匹配导致查找不到控件，即控件为nil
--3. string.format 参数有nil或数据类型不匹配，此问题可能导致程序直接崩溃。



local _funStack = _funStack or {}


--当前进入的函数，用于后面出错时打印调试日志时能打印出当前函数堆栈，必须和SafeLeaveFunc成对调用
function SafeEnterFunc(_funcName)
    if _funcName == nil or type(_funcName) ~= "string" then
        error("SafeEnterFunc invalid param!")
        return;
    end
    table.insert(_funStack, _funcName);
end

--离开函数
function SafeLeaveFunc(_funcName)
    if _funcName == nil or type(_funcName) ~= "string" then
        error("SafeLeaveFunc invalid param!")
        return;
    end

    local topfun, funIdx = GetTopFuncName();
    if topfun == nil then
        warn("SafeLeaveFunc topfun is nil! _funcName=" .. _funcName)
        return;
    end

    if topfun ~= _funcName then
        warn("SafeLeaveFunc stack error!" .. topfun .. "~=" .. _funcName)
        _funStack = {} --clear fun stack
        return;
    end

    table.remove(_funStack, funIdx)
end

--取当前函数名称
function GetTopFuncName()
    local cnt = #_funStack;
    if cnt > 0 then
        return _funStack[cnt], cnt
    else
        return nil;
    end
end

--打印当前函数堆栈信息
function PrintFuncStack()
    return debug.traceback()
    -- local text = ";stack:";
    -- for i = 1, #_funStack do
    --     if i == #_funStack then
    --         text = text .. _funStack[i]
    --     else
    --         text = text .. _funStack[i] .. "->"
    --     end
    -- end
    -- return text;
end

---@return UnityEngine.Transform
function SafeGetTransform(_uithis, _uiControlPath, _compomentName)
    if _uithis.transform == nil then
        error("[SafeGetUIControl]_uithis.transform is nil!" .. _uiControlPath .. PrintFuncStack());
        return nil;
    end

    local node = _uithis.transform:Find(_uiControlPath)
    if node == nil then
        error("[SafeGetUIControl]not find node:" .. _uiControlPath .. PrintFuncStack())
        return nil;
    end

    if _compomentName == nil then
        return node;
    end

    local com = node:GetComponent(_compomentName)
    if com == nil then
        error(string.format("[SafeGetUIControl.getc]GetComponent Failed: %s - %s", node.name, _compomentName) ..
        PrintFuncStack())
    end
    return com;
end

--取ui控件操作：
--替换：this.uidata.lbPlayerPower = this.transform:Find("UIMainBaner/LablePower"):GetComponent("Text");
--为：this.uidata.lbPlayerPower = SafeGetUIControl( this, "UIMainBaner/LablePower", "Text" )
-- _compomentName 不填默认为取 gameObject
function SafeGetUIControl(_uithis, _uiControlPath, _compomentName)
    if isNil(_uithis.transform) then
        error("[SafeGetUIControl]_uithis.transform is nil!" .. _uiControlPath, debug.traceback());
        return nil;
    else
        local node = _uithis.transform:Find(_uiControlPath)
        if isNil(node) then
            error("[SafeGetUIControl]not find node:" .. _uiControlPath , debug.traceback())
            return nil;
        else
            if _compomentName == nil then
                return node.gameObject;
            else
                local com = node:GetComponent(_compomentName)
                if com == nil then
                    error(string.format("[SafeGetUIControl.getc]GetComponent Failed: %s - %s", node.name, _compomentName) ..
                    PrintFuncStack())
                end
                --微信小游戏输入框适配
                if BaseConfig.IsMiniSdkEnable and _compomentName == Define.Component.InputField then
                    node.gameObject:AddComponent(typeof(WxExtends.Inputs))
                end

                return com;
            end
        end
    end
end

function SafeGetUIControlTPC(_uithis_transform, _uiControlPath, _compomentName)
    if isNil(_uithis_transform) then
        error("[SafeGetUIControl]_uithis.transform is nil!" .. _uiControlPath .. PrintFuncStack());
        return nil;
    else
        local node = _uithis_transform:Find(_uiControlPath)
        if isNil(node) then
            error("[SafeGetUIControl]not find node:" .. _uiControlPath .. PrintFuncStack())
            return nil;
        else
            if _compomentName == nil then
                return node.gameObject;
            else
                local com = node:GetComponent(_compomentName)
                if com == nil then
                    error(string.format("[SafeGetUIControl.getc]GetComponent Failed: %s - %s", node.name, _compomentName) ..
                    PrintFuncStack())
                end
                return com;
            end
        end
    end
end

--替换ui里面的this.behaviour:AddClickEvent()
function SafeAddClickEvent(_bhv, _button, _clickFunc, _exErrLog, _param)
    if _bhv == nil then
        local err = "[SafeAddClickEvent] _bhv is nil!" .. PrintFuncStack()
        if _exErrLog ~= nil then
            err = err .. ";" .. _exErrLog
        end
        error(err)
        return;
    end

    if _button == nil then
        local err = "[SafeAddClickEvent] _button is nil!" .. PrintFuncStack()
        if _exErrLog ~= nil then
            err = err .. ";" .. _exErrLog
        end
        error(err)
        return;
    end

    if _clickFunc == nil then
        local err = "[SafeAddClickEvent] _clickFunc is nil!" .. PrintFuncStack()
        if _exErrLog ~= nil then
            err = err .. ";" .. _exErrLog
        end
        error(err)
        return;
    end
    _bhv:AddClickEvent(_button, _clickFunc, _param)
end

--替换ui里面的this.behaviour:AddLongPressEvent()
function SafeAddLongPressEvent(_bhv, _button, _pressFunc, _upFunc, _clickFunc, _duration, _exErrLog, _param)
    if _bhv == nil then
        local err = "[SafeAddLongPressEvent] _bhv is nil!" .. PrintFuncStack()
        if _exErrLog ~= nil then
            err = err .. ";" .. _exErrLog
        end
        error(err)
        return;
    end

    if _button == nil then
        local err = "[SafeAddLongPressEvent] _button is nil!" .. PrintFuncStack()
        if _exErrLog ~= nil then
            err = err .. ";" .. _exErrLog
        end
        error(err)
        return;
    end

    if _clickFunc == nil then
        local err = "[SafeAddLongPressEvent] _clickFunc is nil!" .. PrintFuncStack()
        if _exErrLog ~= nil then
            err = err .. ";" .. _exErrLog
        end
        error(err)
        return;
    end
    _bhv:AddLongPressEvent(_button, _pressFunc, _upFunc, _clickFunc, _duration, _param)
end

--替换 _gameobject:SetActive(false)
function SafeSetActive(_obj, _active, _exErrLog)
    if isNil(_obj) then
        local err = "[SafeSetActive: _obj is nil!]" .. PrintFuncStack()
        if _exErrLog ~= nil then
            err = err .. _exErrLog;
        end
        error(err)
        return;
    end
    local activeSelf = _obj.activeSelf;
    if activeSelf ~= _active then
        _obj:SetActive(_active)
    end
end

--替换_gameObject.activeSelf
function SafeGetActiveSelf(_obj, _exErrLog)
    if isNil(_obj) then
        local err = "[SafeGetActiveSelf: _obj is nil!]" .. PrintFuncStack()
        if _exErrLog ~= nil then
            err = err .. _exErrLog;
        end
        error(err)
        return;
    end
    return _obj.activeSelf;
end

--替换 _abcdetext.text = _text
function SafeSetText(_textCompoment, _text, _exErrLog)
    if isNil(_textCompoment) then
        local err = "[SafeSetText: _textCompoment is nil!]" .. PrintFuncStack()
        if _exErrLog ~= nil then
            err = err .. _exErrLog;
        end
        error(err)
        return;
    end
    _textCompoment.text = _text;
end

--替换 _abcdtext.text
function SafeGetText(_textCompoment, _exErrLog)
    if isNil(_textCompoment) then
        local err = "[SafeSetText: _textCompoment is nil!]" .. PrintFuncStack()
        if _exErrLog ~= nil then
            err = err .. _exErrLog;
        end
        error(err)
        return;
    end
    return _textCompoment.text;
end

--替换 _toggleComponent.isOn = true
function SafeSetToggle(_toggleComponent, _isSelect, _exErrLog)
    if isNil(_toggleComponent) then
        local err = "[SafeSetToggle: _textCompoment is nil!]" .. PrintFuncStack()
        if _exErrLog ~= nil then
            err = err .. _exErrLog;
        end
        error(err)
        return;
    end
    _toggleComponent.isOn = _isSelect;
end

--替换 _toggleComponent.isOn
function SafeGetToggle(_toggleComponent, _exErrLog)
    if isNil(_toggleComponent) then
        local err = "[SafeGetToggle: _textCompoment is nil!]" .. PrintFuncStack()
        if _exErrLog ~= nil then
            err = err .. _exErrLog;
        end
        error(err)
        return;
    end
    return _toggleComponent.isOn
end

---替换原始string.format函数
local __orignal_stringformt = string.format;
function SafeStringFormat(_formatStr, ...)
    if _formatStr == nil or _formatStr == "" then
        error("string.format invalid param1!")
        return ""
    end
    return __orignal_stringformt(_formatStr, ...)
end

string.format = SafeStringFormat;


--替换string.format, 这个函数不太好处理，大家尽量对每个参数都验证
-- function SafeStringFormat( _formatStr, ... )
-- 	if _formatStr == nil then
-- 		return "nil"
-- 	end

-- 	-- local args = { ... }

-- 	-- --统计%个数
-- 	-- local fmtCount = 0
-- 	-- local nFindStartIndex = 1
-- 	-- local sepLen = 1
-- 	-- local szSeparator = '%'
-- 	-- local findFunc = string.find
-- 	-- while true do
-- 	--    local nFindLastIndex = findFunc(_formatStr, szSeparator, nFindStartIndex, true)
-- 	--    if not nFindLastIndex then
-- 	--    		break
-- 	--    end
-- 	--    if _formatStr[nFindLastIndex+1] ~= szSeparator then
-- 	--    	   fmtCount = fmtCount + 1;
-- 	--    end
-- 	--    nFindStartIndex = nFindLastIndex + sepLen;
-- 	-- end

-- 	-- if fmtCount ~= #args then
-- 	-- 	error("[SafeStringFormat] fmtCount="..fmtCount.." not equals args count="..#args..", str=".._formatStr);
-- 	-- 	return "nil";
-- 	-- end
-- 	local ret = string.format( _formatStr, ... )
-- 	return ret or "nil";
-- end


--替换table.insert( _tab, _val )
function SafeTableInsert(_table, _value, _exErrForLog)
    if _table == nil then
        local err = "[SafeInsertTable]_table is nil" .. PrintFuncStack()
        if _exErrForLog ~= nil then
            err = err .. _exErrForLog;
        end
        error(err)
        return;
    end
    table.insert(_table, _value);
end

--替换#_table
function SafeTableLen(_table, _exErrForLog)
    if _table == nil then
        local err = "[SafeTableLen]_table is nil" .. PrintFuncStack()
        if _exErrForLog ~= nil then
            err = err .. _exErrForLog;
        end
        error(err)
        return 0;
    end
    return #_table;
end
