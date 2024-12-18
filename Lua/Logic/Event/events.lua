--[[
Auth:Chiuan
like Unity Brocast Event System in lua.
]]

local EventLib = require "Logic/Event/eventlib"

Event = {}
local events = {}
local csEvent = {}

--可能重新登录等导致脚本未重新加载而未清除
function Event.Reset()
	Event.cacheEvents = nil;
end

--有一些事件必须不能加入cache的
function Event.AddCacheEvent(event)
	if Event.CacheEventList == nil then
		Event.CacheEventList = {};
	end
	table.insert(Event.CacheEventList, event);
end

--添加不广播的消息
function Event.AddUnBrocastEvent(event)
	if Event.UnBrocastEventList == nil then
		Event.UnBrocastEventList = {};
	end
	
	for _, v in ipairs(Event.UnBrocastEventList) do
		if v == event then
			return;
		end
	end
	table.insert(Event.UnBrocastEventList, event);
end

--移除不广播的消息（应该明确知道和AddUnBrocastEvent对应手动处理）
function Event.RemoveUnBrocastEvent(event)
	if Event.UnBrocastEventList == nil then
		return;
	end

	local index = 1;
	for _, v in ipairs(Event.UnBrocastEventList) do
		if v == event then
			table.remove(Event.UnBrocastEventList, index);
		end
		index = index + 1;
	end
end

function Event.AddListenerForCSharp(event, handler)
	local cb = function (...)
		if handler ~= nil then
			handler:Invoke(...)
		end
	end

	if not csEvent[event] then
		csEvent[event] = {}
	end
	csEvent[event][handler] = cb

	Event.AddListener(event, cb)
end

function Event.RemoveListenerForCSharp(event, handler)
	if not csEvent[event]
			or not csEvent[event][handler] then
		return
	end

	Event.RemoveListener(event, csEvent[event][handler])
end

function Event.AddListener(event, handler, obj)
	if not event or type(event) ~= "string" then
		error("event parameter in addlistener function has to be string, " .. type(event) .. " not right.")
	end
	if not handler or type(handler) ~= "function" then
		error("handler parameter in addlistener function has to be function, " .. type(handler) .. " not right")
	end

	if not events[event] then
		--create the Event with name
		events[event] = EventLib:new(event)
	end

	--conn this handler
	events[event]:connect(handler, obj)
end

function Event.AddListenerOnce(event, handler)
	local _handler = nil

	_handler = function (...)
		handler(...)

		events[event]:disconnect(_handler)
	end
	Event.AddListener(event, _handler)
end

function Event.Brocast(event,...)
	if not events[event] then
		-- warn("brocast " .. event .. " has no event.")
	else
		--
		if Event.UnBrocastEventList ~= nil then
			for _, e in ipairs(Event.UnBrocastEventList) do
				if e == event then
					return;
				end
			end
		end
		
		--排除列表
		if Event.cacheEvents ~= nil then
			local bUnCache = false;
			if nil ~= Event.CacheEventList then
				for k, v in ipairs(Event.CacheEventList) do
					if v == event then
						bUnCache = true;
						break;
					end
				end
			end
			
			if not bUnCache then
				events[event]:fire(...)
			else
				table.insert(Event.cacheEvents, {event = event, param = {...} });
			end
				
		else
			events[event]:fire(...)
		end
	end
end

function Event.RemoveListener(event, handler)
	if not events[event] then
		error("remove " .. event .. " has no event.")
	else
		events[event]:disconnect(handler)
	end
end


--可以多次start，但最后必须release
function Event.StartCacheEvent()
	if Event.cacheEvents == nil then
		Event.cacheEvents = {};
	end	
end

function Event.ReleaseCacheEvent()
	if nil == Event.cacheEvents then
		return;
	end

	for k, v in ipairs(Event.cacheEvents) do
		events[v.event]:fire(unpack(v.param))
	end
	
	Event.cacheEvents = nil;
end

return Event