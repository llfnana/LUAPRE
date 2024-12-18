------------------------------------------------------------------------
--- @desc 状态-暂停移动
--- @author sakuya
------------------------------------------------------------------------

--region -------------引入模块-------------
local FsmState = require "Logic/Fsm/FsmState"
--endregion

local State = class('CityState_PauseMove', FsmState)

return State