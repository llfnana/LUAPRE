------------------------------------------------------------------------
--- @desc 条件分析器
--- @author chenyl
------------------------------------------------------------------------

--region -------------引入模块-------------
--endregion

--region -------------数据定义-------------

--endregion

--region -------------私有变量-------------
local module = {}

local fn = {}

local analyseMap = {} ---@type table<number, fun> 分析器
local msgFormatMap = {} ---@type table<number, fun> 未解锁提示信息
--endregion

--region -------------导出函数-------------

function module.init()
    module.addAnalyse(Define.UnlockType.None, fn.checkNone)
end

function module.release()
end

---添加分析器
---@param tid number
---@param analyse fun(c:any)
---@param msgFormat fun(c:any):string
function module.addAnalyse(tid, analyse, msgFormat)
    if tid == nil then
        return
    end
    analyseMap[tid] = analyse
    msgFormatMap[tid] = msgFormat
end

---获取分析器
---@param tid number
---@return fun(c:any)
function module.getAnalyse(tid)
    return analyseMap[tid]
end

---是否满足条件
---@param tid number 解锁配置id
---@param param any 解锁配置参数
---@param retMsg boolean 是否返回未解锁提示
function module.isSatisfy(tid, param, retMsg)
    if tid == nil then --没有条件，默认满足
        return true
    end

    local analyse = module.getAnalyse(tid)
    if analyse == nil then --找不到分析函数
        return false
    end

    local suc = analyse(param)
    local format = msgFormatMap[tid]

    if suc or format == nil
            or not retMsg then
        return suc
    end

    return suc, format(param)
end

--endregion

--region -------------私有函数-------------

function fn.checkNone()
    return true
end

--endregion

return module