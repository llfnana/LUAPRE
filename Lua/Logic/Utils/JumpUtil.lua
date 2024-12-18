
--region -------------默认参数-------------
local module = {}

local Enum = {
    Chat = 2005, --聊天
    SonList = 2006, --子嗣列表
} -- 枚举
module.enum = Enum
--endregion

--region -------------私有变量-------------
local fn = {}

--local beforeJump = {} ---@type table<number, fun()> 跳转前置函数
--endregion

--region -------------导出函数-------------

---根据跳转ID进行界面跳转
function module.JumpTo(id)
    local jump = TbJump[id]
    if not jump then
        error("[JumpUtil.JumpTo]: 未找到该jumpid = " .. id)
        return
    end
    local unlock = true -- 模块是否解锁
    local UI = jump.UI

    if unlock then
        local UIName = UI
        if UI == "" then
            UIName = ""
        end
        ShowUI(UIName)
    end
end

---根据跳转ID进行界面跳转
---@param tid number 跳转配置ID
---@param param any 参数
function module.jump(tid, param)
    local tbJump = TbJump[tid]
    if not tbJump then
        error("[JumpUtil.JumpTo]: 未找到该jumpid = " .. tid)
        return
    end

    --local beforeFun = beforeJump[tid]
    --if beforeFun ~= nil then
    --    local _arg = { tid=tid, param=param }
    --    local took = beforeFun(_arg) --接管
    --    if took then
    --        return
    --    end
    --end

    UIUtil.backTo(UINames.UIMain) --回退到主界面

    ShowUI(tbJump.UI, param) --打开界面
end

--endregion

--region -------------私有函数-------------

---添加跳转前置函数
---@param id number 跳转配置ID
---@param beforeCb fun(a: JumpBeforeData):boolean
--function fn.addBefore(id, beforeCb)
--    if id == nil then
--        return
--    end
--
--    if beforeCb ~= nil then
--        beforeJump[id] = beforeCb
--    end
--end

--endregion

return module
