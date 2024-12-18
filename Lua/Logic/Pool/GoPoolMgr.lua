------------------------------------------------------------------------
--- @desc 通用GameObject对象池
--- @author chenyl
------------------------------------------------------------------------

--region -------------引入模块-------------
local GoPool = require "Logic/Pool/GoPool"
--endregion

--region -------------私有变量-------------
local module = {}

local poolMap = {} ---@type table<string, Pool>
--endregion

--region -------------导出函数-------------

function module.createPool(go, size)
    return GoPool.new(go, size)
end

---@param resName string
---@param onLoadGo fun(g: UnityEngine.GameObject)
function module.getGo(resName, onLoadGo)
    local pool = poolMap[resName]
    if pool == nil then
        local _go = nil
        ResInterface.SyncLoadGameObject(resName, function (obj)
            _go = GOInstantiate(obj)

            if onLoadGo then onLoadGo(_go) end
        end)

        pool = GoPool.new(_go)
        poolMap[resName] = pool
    end
    local go = pool:get()
    go.name = resName
    return go
end

function module.free(go)
    local resName = go.name
    local pool = poolMap[resName]
    if not pool then
        GODestroy(go)
        return
    end

    pool:free(go)
end

function module.freeList(goList)
    for _, go in ipairs(goList) do
        module.free(go)
    end
end

--endregion

return module