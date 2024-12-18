local unpack = table.unpack
local move_end = {}
local generator_mt = {
    __index = {
        MoveNext = function(self)
            self.Current = self.co()
            if self.Current == move_end then
                self.Current = nil
                return false
            else
                return true
            end
        end,
        Reset = function(self)
            self.co = coroutine.wrap(self.w_func)
        end
    }
}

local function cs_generator(func, ...)
    local params = {...}
    local generator =
        setmetatable(
        {
            w_func = function()
                func(unpack(params))
                return move_end
            end
        },
        generator_mt
    )
    generator:Reset()
    return generator
end

local gameobject = UnityEngine.GameObject("Coroutine_Runner")
UnityEngine.Object.DontDestroyOnLoad(gameobject)
local cs_coroutine_runner = gameobject:AddComponent(typeof(Coroutine_Runner))

UnityEngine = {}
UnityEngine.__index = UnityEngine

function UnityEngine.StartCoroutine(func)
    return cs_coroutine_runner:StartCoroutine(cs_generator(func))
end

function UnityEngine.YieldReturn(...)
    coroutine.yield(...)
end

function UnityEngine.StopCoroutine(coroutine)
    if not cs_coroutine_runner then
        return
    end
    cs_coroutine_runner:StopCoroutine(coroutine)
end

return UnityEngine
