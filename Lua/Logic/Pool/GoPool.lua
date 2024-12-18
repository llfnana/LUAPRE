
local Parent = require "Logic/Pool/Pool"

---@class Pool.GoPool : Pool GameObject池
local Pool = class('GoPoll', Parent)

---@param go GameObject
---@param size number 池大小
function Pool:ctor(go, size)
    self.mainGO = go --主对象
    self.parentTran = go.transform.parent
    --self.isGoInPool = false

    SafeSetActive(go, false) --隐藏

    Parent.ctor(self, function ()
        --if not self.isGoInPool then
        --    self.isGoInPool = true
        --    return go
        --end

        return GOInstantiate(go, self.parentTran)
    end, size)
end

function Pool:get()
    local go = Parent.get(self)
    SafeSetActive(go, true)
    return go
end

function Pool:free(go)
    SafeSetActive(go, false)

    Parent.free(self, go)
end

function Pool:destroy(go)
    Parent.destroy(self, go)

    --if go ~= self.mainGO then
        GODestroy(go)
    --else
    --    self.isGoInPool = false
    --end
end

function Pool:clear()
    Parent.clear(self)

    SafeSetActive(self.mainGO, false) --隐藏主对象
end

return Pool