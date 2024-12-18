---@class LuaEvent
local Event = {}

-- 创建事件
function Event:ctor()
    self.listeners = {}
end

-- 注册事件监听器
function Event:register(listener, obj)
    if not listener then return end
    if not self.listeners then self.listeners = {} end
    table.insert(self.listeners, { listener = listener, obj = obj })
end

-- 触发事件
function Event:trigger(...)
    if not self.listeners then return end
    for _, listener in ipairs(self.listeners) do
        if listener.obj then
            listener.listener(listener.obj, ...)
        else
            listener.listener(...)
        end
    end
end

-- 移除事件监听器
function Event:unregister(listener)
    if not listener or not self.listeners then return end
    for i, l in ipairs(self.listeners) do
        if l.listener == listener then
            table.remove(self.listeners, i)
            return
        end
    end
end

function Event.new()
    local instance = setmetatable({}, { __index = Event })
    instance:ctor()
    return instance
end

return Event