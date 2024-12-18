MonoEvent = {}
--MonoEvent.event = Event:New()

local this = MonoEvent

function MonoEvent.AddListener(event, handler)
--    if this.event then
--        this.event:AddListener(event, handler)
--    end
end

function MonoEvent.Brocast(event, ...)
--    if this.event then
--        this.event:Brocast(event, ...)
--    end
      Event.Brocast(event, ...)
end

function MonoEvent.RemoveListener(event, handler)
--    if this.event then
--        this.event:RemoveListener(event, handler)
--    end
end

--逻辑update
function MonoEvent.Update()
    -- LogWarning("Update")
    this.Brocast(MonoEventType.Update)
end

function MonoEvent.LateUpdate()
    -- LogWarning("LateUpdate")
    this.Brocast(MonoEventType.LateUpdate)
end

--物理update
function MonoEvent.FixedUpdate()
    -- LogWarning("FixedUpdate")
    this.Brocast(MonoEventType.FixedUpdate)
end

function MonoEvent.OnApplicationFocus(focus)
    -- LogWarningFormat("OnApplicationFocus focus = {0}", focus)
    this.Brocast(MonoEventType.OnApplicationFocus, focus)
end

function MonoEvent.OnApplicationPause(pause)
    -- LogWarningFormat("OnApplicationPause pause = {0}", pause)
    this.Brocast(MonoEventType.OnApplicationPause, pause)
end

function MonoEvent.OnApplicationQuit()
    -- LogWarning("OnApplicationQuit")
    this.Brocast(MonoEventType.OnApplicationQuit)
end

function MonoEvent.OnPressEsc()
    -- LogWarning("OnPressEsc")
    this.Brocast(MonoEventType.OnPressEsc)
end

function MonoEvent.OnMouseDown()
    -- LogWarning("OnMouseDown")
    this.Brocast(MonoEventType.OnMouseDown)
end

function MonoEvent.OnScreenResize()
    -- LogWarning("OnScreenResize")
    this.Brocast(MonoEventType.OnScreenResize)
end

function MonoEvent.AnimationEvent(result)
    this.Brocast(MonoEventType.AnimationEvent, result)
end

function MonoEvent.SetBattleLogEvent(result)
    HeroBattleDataManager.SetBattleSwitch(result)
end
