CelebrateActionState = Clone(FSMState)
CelebrateActionState.__cname = "CelebrateActionState"
CelebrateActionState.playAnimation = false

function CelebrateActionState:OnEnter(fsm)
    fsm.owner:OpenWaringView(false)
    fsm.owner:StopMove()

    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Protest, ZoneType.MainRoad)
    if nil == target then
        target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Protest2, ZoneType.MainRoad)
    end
    if nil ~= target then
        fsm.owner:ChangeTargeGrid(target)
        fsm.owner:ChangeCurrGrid(target, true)
    else
        print("[error]" .. "缺少暴动格子点")
    end
    fsm.owner:PlayAnimEx(AnimationType.Protest)
end

function CelebrateActionState:OnExit(fsm)
    fsm.owner:OpenWaringView(true)
end
