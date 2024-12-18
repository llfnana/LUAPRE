------------------------------------------------------------------------
--- @desc 状态-无状态
--- @author sakuya
------------------------------------------------------------------------

--region -------------引入模块-------------
local FsmState = require "Logic/Fsm/FsmState"
--endregion

local State = class('CityState_None', FsmState)

return State