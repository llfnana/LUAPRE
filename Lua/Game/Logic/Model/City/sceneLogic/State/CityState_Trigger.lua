------------------------------------------------------------------------
--- @desc 状态-触发触发器
--- @author sakuya
------------------------------------------------------------------------

--region -------------引入模块-------------
local FsmState = require "Logic/Fsm/FsmState"
--endregion

local State = class('CityState_Trigger', FsmState)

function State:check(toKey)
    if toKey == CityState.Move then
        return true
    elseif toKey == CityState.Idle then
        return true
    end
end

function State:enter(fromKey, ...)
    CityModule.getMainCtrl().player:playAnim(CityPlayerAnim.Idle)
end

function State:exit()
   
end

return State