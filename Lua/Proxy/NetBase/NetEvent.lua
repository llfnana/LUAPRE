local Event = {}
Event.version = "Event 1.0"

local function newWeakTable()
    -- local obj = {}
    -- setmetatable(obj, { __mode = "k" });
    -- return obj
    return {}
end

local function event(self, type, ...)
    if self._eventPool[type] ~= nil then
        for callBack, v in pairs(self._eventPool[type]) do
            callBack(self, type, ...)
        end
    end
end

local function hasEvent(self, type)
    if self._eventPool[type] ~= nil then
        for callBack, v in pairs(self._eventPool[type]) do
            out = v
            if v then
                return true
            end
        end
    end
    return false
end
local function addEvent(self, type, callBack)
    if self._eventPool[type] == nil then
        self._eventPool[type] = newWeakTable()
    end
    self._eventPool[type][callBack] = true
end

local function removeEvent(self, type, callBack)
    self._eventPool[type][callBack] = nil
end

local function clearEvent(self, type)
    self._eventPool[type] = newWeakTable()
end

local function newEvent(prototype, target)
    local self = target or {}
    self._eventPool = {}
    self.isEvent = true
    self.event = event
    self.addEvent = addEvent
    self.hasEvent = hasEvent
    self.removeEvent = removeEvent
    self.clearEvent = clearEvent
    return self
end

function Event.isEvent(obj)
    return obj.isEvent == true
end

Event.new = newEvent
return Event