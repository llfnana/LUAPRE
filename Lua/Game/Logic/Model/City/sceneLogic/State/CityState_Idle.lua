------------------------------------------------------------------------
--- @desc 状态-待机
--- @author sakuya
------------------------------------------------------------------------

--region -------------引入模块-------------
local FsmState = require "Logic/Fsm/FsmState"
--endregion

local State = class('CityState_Idle', FsmState)

function State:check(toKey)
    if toKey == CityState.Move then
        return true
    end
end

function State:enter(fromKey, ...)
    CityModule.getMainCtrl().player:Idle()
end

function State:update()
    CityModule.getMainCtrl():cameraSetFollow(false) --取消跟随
end

return State