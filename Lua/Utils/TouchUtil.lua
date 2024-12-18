------------------------------------------------------------------------
--- @desc 手势工具
--- @author chenyl
------------------------------------------------------------------------

--region -------------引入模块-------------
--endregion

--region -------------默认参数-------------
local module = {}    --导出函数
local fn = {} --私有函数


local taps = {} ---@type fun[] 点击监听函数列表
local onceTaps = {} ---@type fun[]
local onceTapsLast = {} ---@type fun[]

local pinches = {} ---@type {callback:fun, obj:any}[] 捏合监听函数列表
local drags = {} ---@type {callback:fun, obj:any}[] 拖拽监听函数列表
--endregion

--region -------------导出函数-------------

function module.addTap(cb)
    ListUtil.uniqueInsert(taps, cb)
end

function module.removeTap(cb)
    ListUtil.delete(taps, cb)
end

---监听点击（生效一次）
---@warning 点击目标物体，可能会导致重复绑定，引发显示异常
function module.onOnceTap(cb)
    --Log.info('TouchUtil 111 onPointerReleased')
    ListUtil.uniqueInsert(onceTapsLast, cb)
end

function module.contains(cb)
    local res = ListUtil.containValue(taps, cb)
    if res then
        return true
    end
    res = ListUtil.containValue(onceTaps, cb)
    if res then
        return true
    end
    return ListUtil.containValue(onceTapsLast, cb)
end

function module.addPinch(cb, obj)
    table.insert(pinches, { callback = cb, obj = obj })
end

function module.removePinch(cb)
    for i, v in ipairs(pinches) do
        if v.callback == cb then
            table.remove(pinches, i)
            break
        end
    end
end

function module.addDrag(cb, obj)
    table.insert(drags, { callback = cb, obj = obj })
end

function module.removeDrag(cb)
    for i, v in ipairs(drags) do
        if v.callback == cb then
            table.remove(drags, i)
            break
        end
    end
end

--endregion

--region -------------私有函数-------------

function fn.lateUpdate()
    for k, v in pairs(onceTapsLast) do
        table.insert(onceTaps, v)
        onceTapsLast[k] = nil
    end
end

function fn.fingerTap(finger)
    --print('TouchUtil on fingerTap')
    for _, v in ipairs(onceTaps) do
        v(finger)
    end

    onceTaps = {}
end

function fn.fingerPinch(scale, isStartedOverGui)
    for _, v in ipairs(pinches) do
        if v.obj then
            v.callback(v.obj, scale, isStartedOverGui)
        else
            v.callback(scale, isStartedOverGui)
        end
    end
end

function fn.fingerDrag(delta, isStartedOverGui)
    for _, v in ipairs(drags) do
        if v.obj then
            v.callback(v.obj, delta, isStartedOverGui)
        else
            v.callback(delta, isStartedOverGui)
        end
    end
end

--endregion

--region 初始化函数
local function init()
    LeanTouchUtil.OnFingerTap(fn.fingerTap) --监听点击
    LeanTouchUtil.OnFingerPinch(fn.fingerPinch) --监听捏合
    LeanTouchUtil.OnFingerDrag(fn.fingerDrag) --监听拖拽

    LateUpdateBeat:Add(fn.lateUpdate)
end

init()
--endregion

return module