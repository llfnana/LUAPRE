------------------------------------------------------------------------
--- @desc 状态-移动
--- @author sakuya
------------------------------------------------------------------------

--region -------------引入模块-------------
local FsmState = require "Logic/Fsm/FsmState"
--endregion

local State = class('CityState_Move', FsmState)

function State:check(toKey)
    if toKey == CityState.Move then
        return true
    elseif toKey == CityState.Trigger then
        return true
    elseif toKey == CityState.Idle then
        return true
    end
end

function State:enter(fromKey, ...)
    
end

function State:update()
    -- 状态机update逻辑
    local mainCtrl = CityModule.getMainCtrl()
    mainCtrl.player:move()
end

return State