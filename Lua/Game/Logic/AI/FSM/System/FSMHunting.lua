FSMHunting = Clone(FSMSystem)
FSMHunting.__cname = "FSMHunting"

function FSMHunting:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.AnimalExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.AnimalMoveToDoor, StateId.MoveToHunterCabinDoor)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.AnimalMoveToTool, StateId.MoveToHunterCabinTool)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.AnimalMoveToSpe, StateId.MoveToHunterCabinSpecial1)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.AnimalMoveToIdle, StateId.MoveToHunterCabinIdle)
    self:AddState(entryState)

    local moveToDoor = MoveState:New(StateId.MoveToHunterCabinDoor)
    moveToDoor:AddTransition(CheckType.Process, FSMTransitionType.AnimalExit, StateId.ExitState)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.AnimalMoveToTool, StateId.MoveToHunterCabinTool)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.AnimalMoveToSpe, StateId.MoveToHunterCabinSpecial1)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.AnimalMoveToIdle, StateId.MoveToHunterCabinIdle)
    self:AddState(moveToDoor)

    local moveToTool = MoveState:New(StateId.MoveToHunterCabinTool)
    moveToTool:AddTransition(CheckType.Process, FSMTransitionType.AnimalExit, StateId.ExitState)
    moveToTool:AddTransition(CheckType.Complete, FSMTransitionType.AnimalRunWithTool, StateId.RunWithHunterCabinTool)
    moveToTool:AddTransition(CheckType.Complete, FSMTransitionType.AnimalMoveToSpe, StateId.MoveToHunterCabinSpecial1)
    moveToTool:AddTransition(CheckType.Complete, FSMTransitionType.AnimalMoveToIdle, StateId.MoveToHunterCabinIdle)
    self:AddState(moveToTool)

    local runTool = HuntingActionState:New(StateId.RunWithHunterCabinTool)
    runTool:AddTransition(CheckType.Complete, FSMTransitionType.AnimalMoveToHunt, StateId.MoveToHunt)
    self:AddState(runTool)

    local moveToHunt = MoveState:New(StateId.MoveToHunt)
    moveToHunt:AddTransition(CheckType.Complete, FSMTransitionType.AnimalRunWithHunt, StateId.RunWithHunt)
    self:AddState(moveToHunt)

    local runHunt = HuntingActionState:New(StateId.RunWithHunt)
    runHunt:AddTransition(CheckType.Complete, FSMTransitionType.AnimalMoveToKitchenItems, StateId.MoveToKitchenItems)
    runHunt:AddTransition(CheckType.Complete, FSMTransitionType.AnimalMoveToHunterItems, StateId.MoveToHunterCabinItems)
    self:AddState(runHunt)

    local moveKitchenItems = MoveState:New(StateId.MoveToKitchenItems)
    moveKitchenItems:AddTransition(CheckType.Complete, FSMTransitionType.AnimalRunWithItems, StateId.RunWithItems)
    self:AddState(moveKitchenItems)

    local moveHunterItems = MoveState:New(StateId.MoveToHunterCabinItems)
    moveHunterItems:AddTransition(CheckType.Complete, FSMTransitionType.AnimalRunWithItems, StateId.RunWithItems)
    self:AddState(moveHunterItems)

    local runItems = HuntingActionState:New(StateId.RunWithItems)
    runItems:AddTransition(CheckType.Process, FSMTransitionType.AnimalExit, StateId.ExitState)
    runItems:AddTransition(CheckType.Process, FSMTransitionType.AnimalMoveToSpe, StateId.MoveToHunterCabinSpecial1)
    runItems:AddTransition(CheckType.Process, FSMTransitionType.AnimalMoveToIdle, StateId.MoveToHunterCabinIdle)
    self:AddState(runItems)

    local moveToIdle = MoveState:New(StateId.MoveToHunterCabinIdle)
    moveToIdle:AddTransition(CheckType.Process, FSMTransitionType.AnimalExit, StateId.ExitState)
    moveToIdle:AddTransition(CheckType.Process, FSMTransitionType.AnimalMoveToTool, StateId.MoveToHunterCabinTool)
    moveToIdle:AddTransition(CheckType.Complete, FSMTransitionType.AnimalMoveToTool, StateId.MoveToHunterCabinTool)
    moveToIdle:AddTransition(CheckType.Complete, FSMTransitionType.StayAtIdle, StateId.RunWithHunterCabinIdle)
    self:AddState(moveToIdle)

    local runIdle = IdleState:New(StateId.RunWithHunterCabinIdle)
    runIdle:AddTransition(CheckType.Process, FSMTransitionType.AnimalExit, StateId.ExitState)
    runIdle:AddTransition(CheckType.Process, FSMTransitionType.AnimalMoveToTool, StateId.MoveToHunterCabinTool)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.AnimalMoveToSpe, StateId.MoveToHunterCabinSpecial1)
    runIdle:AddTransition(CheckType.Complete, FSMTransitionType.AnimalMoveToIdle, StateId.MoveToHunterCabinIdle)
    self:AddState(runIdle)

    local moveToSpecial1 = MoveState:New(StateId.MoveToHunterCabinSpecial1)
    moveToSpecial1:AddTransition(CheckType.Process, FSMTransitionType.AnimalExit, StateId.ExitState)
    moveToSpecial1:AddTransition(CheckType.Process, FSMTransitionType.AnimalMoveToTool, StateId.MoveToHunterCabinTool)
    moveToSpecial1:AddTransition(CheckType.Complete, FSMTransitionType.AnimalMoveToTool, StateId.MoveToHunterCabinTool)
    moveToSpecial1:AddTransition(CheckType.Complete, FSMTransitionType.StayAtSpecial1, StateId.RunWithHunterCabinSpecial1)
    self:AddState(moveToSpecial1)

    local runSpecial1 = HuntingActionState:New(StateId.RunWithHunterCabinSpecial1)
    runSpecial1:AddTransition(CheckType.Process, FSMTransitionType.AnimalExit, StateId.ExitState)
    runSpecial1:AddTransition(CheckType.Process, FSMTransitionType.AnimalMoveToTool, StateId.MoveToHunterCabinTool)
    runSpecial1:AddTransition(CheckType.Complete, FSMTransitionType.AnimalMoveToSpe, StateId.MoveToHunterCabinSpecial1)
    runSpecial1:AddTransition(CheckType.Complete, FSMTransitionType.AnimalMoveToIdle, StateId.MoveToHunterCabinIdle)
    self:AddState(runSpecial1)

    local exitState = ExitState:New()
    self:AddState(exitState)
end

-----------------------------------------
---是否可退出打猎状态
-----------------------------------------
TransitionHandles[FSMTransitionType.AnimalExit] = function(fsm)
    if fsm.owner:GetState() ~= EnumState.Normal then
        return true
    end
    if fsm.owner:GetProfessionType() ~= ProfessionType.Hunter then
        return true
    end
    if not SchedulesManager.IsSchdulesActive(fsm.cityId, SchedulesType.Hunting) then
        if not SchedulesManager.IsSchdulesActive(fsm.cityId, SchedulesType.Eat) then
            return true
        end
        if fsm.owner:GetSchedulesStatus(SchedulesType.Eat) ~= SchedulesStatus.Stop then
            return true
        end
    end
    return false
end
-----------------------------------------
---是否可以移动到猎人小屋door点
-----------------------------------------
TransitionHandles[FSMTransitionType.AnimalMoveToDoor] = function(fsm)
    if fsm.owner.currGrid.zoneType == ZoneType.HunterCabin then
        return false
    end
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Door, ZoneType.HunterCabin)
    if not target then
        return false
    end
    fsm:SetMoveInfo(target, fsm:GetSpeedPercent(SchedulesType.Hunting))
    return true
end
-----------------------------------------
---是否可以移动到猎人小屋tool点
-----------------------------------------
TransitionHandles[FSMTransitionType.AnimalMoveToTool] = function(fsm)
    if not SchedulesManager.IsSchdulesActive(fsm.cityId, SchedulesType.Hunting) then
        return false
    end
    if fsm.owner:GetSchedulesStatus(SchedulesType.Hunting) == SchedulesStatus.Completed then
        return false
    end
    local ret = false
    local target = fsm.owner:GetArbeitToolGrid()
    if target then
        fsm:SetMoveInfo(target)
        fsm.owner:SetWorkState(WorkStateType.Work)
        ret = true
    else
        fsm.owner:SetPlayAniHwork()
    end
    return ret
end
-----------------------------------------
---是否可以移动到Hunt点
-----------------------------------------
TransitionHandles[FSMTransitionType.AnimalMoveToHunt] = function(fsm)
    if fsm.owner:GetSchedulesStatus(SchedulesType.Hunting) == SchedulesStatus.Completed then
        return false
    end
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Hunt, ZoneType.MainRoad)
    if not target then
        return false
    end
    fsm:SetMoveInfo(target)
    return true
end
-----------------------------------------
---是否可以移动到厨房Items点
-----------------------------------------
TransitionHandles[FSMTransitionType.AnimalMoveToKitchenItems] = function(fsm)
    if fsm.owner:GetSchedulesStatus(SchedulesType.Hunting) == SchedulesStatus.Completed then
        return false
    end
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Items, ZoneType.Kitchen)
    if not target then
        return false
    end
   -- fsm:SetMoveInfo(target, 1, AnimationType.CarryWalk)
      fsm:SetMoveInfo(target, 1, AnimationType.Walk1)
    return true
end
-----------------------------------------
---是否可以移动到猎人小屋Items点
-----------------------------------------
TransitionHandles[FSMTransitionType.AnimalMoveToHunterItems] = function(fsm)
    if fsm.owner:GetSchedulesStatus(SchedulesType.Hunting) == SchedulesStatus.Completed then
        return false
    end
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Items, ZoneType.HunterCabin)
    if not target then
        fsm.owner:SetPlayAniHwork()
        return false
    end
   -- fsm:SetMoveInfo(target, 1, AnimationType.CarryWalk)
   fsm:SetMoveInfo(target, 1, AnimationType.Walk1)
    return true
end
-----------------------------------------
---是否可以移动到猎人小屋Special1点
-----------------------------------------
TransitionHandles[FSMTransitionType.AnimalMoveToSpe] = function(fsm)
    if math.random() > 0.5 then
        return false
    end
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Special1ForIdle, ZoneType.HunterCabin)
    if not target then
        fsm.owner:SetPlayAniHwork()
        return false
    end
    fsm:SetMoveInfo(target)
    return true
end
-----------------------------------------
---是否可以移动到猎人小屋Idle点
-----------------------------------------
TransitionHandles[FSMTransitionType.AnimalMoveToIdle] = function(fsm)
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Idle, ZoneType.HunterCabin)
    if not target then
        fsm.owner:SetPlayAniHwork()
        return false
    end
    fsm:SetMoveInfo(target)
    return true
end
-----------------------------------------
---是否可以运行tool
-----------------------------------------
TransitionHandles[FSMTransitionType.AnimalRunWithTool] = function(fsm)
    if fsm.owner:GetSchedulesStatus(SchedulesType.Hunting) == SchedulesStatus.Completed then
        return false
    end
    if nil == fsm.owner.currGrid then
        return false
    end
    local ret = false
    if fsm.owner.currGrid:IsFurnitureCanUse() then
        ret = true
    else
        fsm.owner:SetWorkState(WorkStateType.Disable)
    end
    return ret
end
-----------------------------------------
---是否可以运行Hunt
-----------------------------------------
TransitionHandles[FSMTransitionType.AnimalRunWithHunt] = function(fsm)
    if fsm.owner:GetSchedulesStatus(SchedulesType.Hunting) == SchedulesStatus.Completed then
        return false
    end
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Hunt
end
-----------------------------------------
---是否可以运行Items
-----------------------------------------
TransitionHandles[FSMTransitionType.AnimalRunWithItems] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Items
end
