FSMEat = Clone(FSMSystem)
FSMEat.__cname = "FSMEat"

function FSMEat:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.EatExit, StateId.ExitState)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.EatNoKitchen, StateId.RunWithEatStop)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.EatMoveToKitchenDoor, StateId.MoveToKitchenDoor)
    self:AddState(entryState)

    local moveToDoor = MoveState:New(StateId.MoveToKitchenDoor)
    moveToDoor:AddTransition(CheckType.Process, FSMTransitionType.EatExit, StateId.ExitState)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.EatStop, StateId.RunWithEatStop)
    moveToDoor:AddTransition(CheckType.Complete, FSMTransitionType.EatMoveToKitchenQueue, StateId.MoveToKitchenQueue)
    self:AddState(moveToDoor)

    local moveToQueue = MoveState:New(StateId.MoveToKitchenQueue)
    moveToQueue:AddTransition(CheckType.Process, FSMTransitionType.EatExit, StateId.ExitState)
    moveToQueue:AddTransition(CheckType.Process, FSMTransitionType.EatNoFood, StateId.RunWithEatStop)
    moveToQueue:AddTransition(CheckType.Complete, FSMTransitionType.EatMoveToKitchenQueue, StateId.MoveToKitchenQueue)
    moveToQueue:AddTransition(CheckType.Complete, FSMTransitionType.EatMoveToServingTable, StateId.MoveToServingTable)
    moveToQueue:AddTransition(CheckType.Complete, FSMTransitionType.EatRunWithQueueWait, StateId.RunWithQueueWait)
    self:AddState(moveToQueue)

    local moveServingTable = MoveState:New(StateId.MoveToServingTable)
    moveServingTable:AddTransition(CheckType.Process, FSMTransitionType.EatExit, StateId.ExitState)
    moveServingTable:AddTransition(CheckType.Process, FSMTransitionType.EatNoFood, StateId.RunWithEatStop)
    moveServingTable:AddTransition(CheckType.Complete, FSMTransitionType.EatNoFood, StateId.RunWithEatStop)
    moveServingTable:AddTransition(CheckType.Complete, FSMTransitionType.EatRunWithServingTable, StateId.RunWithServingTable)
    self:AddState(moveServingTable)

    local waitQueue = WaitState:New(StateId.RunWithQueueWait)
    waitQueue:AddTransition(CheckType.Process, FSMTransitionType.EatExit, StateId.ExitState)
    waitQueue:AddTransition(CheckType.Process, FSMTransitionType.EatNoFood, StateId.RunWithEatStop)
    waitQueue:AddTransition(CheckType.Process, FSMTransitionType.EatMoveToKitchenQueue, StateId.MoveToKitchenQueue)
    waitQueue:AddTransition(CheckType.Process, FSMTransitionType.EatMoveToServingTable, StateId.MoveToServingTable)
    self:AddState(waitQueue)

    local runServingTable = EatActionState:New(StateId.RunWithServingTable)
    runServingTable:AddTransition(CheckType.Complete, FSMTransitionType.EatMoveToKitchenTable, StateId.MoveToKitchenTable)
    runServingTable:AddTransition(CheckType.Complete, FSMTransitionType.EatServingTableWait, StateId.RunWithServingTableWait)
    self:AddState(runServingTable)

    local waitServingTable = WaitState:New(StateId.RunWithServingTableWait)
    waitServingTable:AddTransition(CheckType.Process, FSMTransitionType.EatMoveToKitchenTable, StateId.MoveToKitchenTable)
    self:AddState(waitServingTable)

    local moveToTable = MoveState:New(StateId.MoveToKitchenTable)
    moveToTable:AddTransition(CheckType.Complete, FSMTransitionType.EatRunWithTable, StateId.RunWithKitchenTable)
    self:AddState(moveToTable)

    local runWithTable = EatActionState:New(StateId.RunWithKitchenTable)
    runWithTable:AddTransition(CheckType.Complete, FSMTransitionType.EatExit, StateId.ExitState)
    self:AddState(runWithTable)

    local eatStop = EatActionState:New(StateId.RunWithEatStop)
    eatStop:AddTransition(CheckType.Process, FSMTransitionType.EatExit, StateId.ExitState)
    self:AddState(eatStop)

    local exitState = ExitState:New()
    self:AddState(exitState)
end

-----------------------------------------
---是否可退出吃饭状态
-----------------------------------------
TransitionHandles[FSMTransitionType.EatExit] = function(fsm)
    if fsm.owner:GetState() ~= EnumState.Normal then
        return true
    end
    if not SchedulesManager.IsSchdulesActive(fsm.cityId, SchedulesType.Eat) then
        return true
    end
    if fsm.owner:GetSchedulesStatus(SchedulesType.Eat) == SchedulesStatus.Stop then
        return true
    end
    return false
end
-----------------------------------------
---是否没有厨房
-----------------------------------------
TransitionHandles[FSMTransitionType.EatNoKitchen] = function(fsm)
    local zoneId = ConfigManager.GetZoneIdByZoneType(fsm.cityId, ZoneType.Kitchen)
    if nil == zoneId then
        return true
    end
    local mapItemData = MapManager.GetMapItemData(fsm.cityId, zoneId)
    if nil == mapItemData then
        return true
    end
    return not mapItemData:IsUnlock()
end
-----------------------------------------
---是否可退出吃饭状态
-----------------------------------------
TransitionHandles[FSMTransitionType.EatMoveToKitchenDoor] = function(fsm)
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Door, ZoneType.Kitchen, -1, 1)
    if not target then
        return false
    end
    fsm:SetMoveInfo(target, fsm:GetSpeedPercent(SchedulesType.Eat))
    return true
end
-----------------------------------------
---吃饭是否需要停止
-----------------------------------------
TransitionHandles[FSMTransitionType.EatStop] = function(fsm)
    --是否有食物
    if FoodSystemManager.GetFoodCount(fsm.cityId) <= 0 then
        return true
    end
    --是否有服务餐桌
    local servingTable =
        GridManager.GetGridByMarkerType(
        fsm.cityId,
        GridMarker.ServingTable,
        ZoneType.Kitchen,
        nil,
        nil,
        GridStatus.Unlock
    )
    if not servingTable then
        return true
    end
    --是否有就餐椅子
    local canteenChair =
        GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Table, ZoneType.Kitchen, nil, nil, GridStatus.Unlock)
    if not canteenChair then
        return true
    end
    --是否能排队
    local canteenQueue = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Queue, ZoneType.Kitchen)
    if not canteenQueue then
        return true
    end
    return false
end
-----------------------------------------
---是否没有食物
-----------------------------------------
TransitionHandles[FSMTransitionType.EatNoFood] = function(fsm)
    return FoodSystemManager.GetFoodCount(fsm.cityId) <= 0
end
-----------------------------------------
---是否可以去厨房Queue
-----------------------------------------
TransitionHandles[FSMTransitionType.EatMoveToKitchenQueue] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    if fsm.owner.currGrid.markerType == GridMarker.Queue and fsm.owner.currGrid.serialNumber == 1 then
        return false
    end
    local serialNumber = nil
    if fsm.owner.targetGrid.markerType == GridMarker.Queue then
        serialNumber = fsm.owner.targetGrid.serialNumber - 1
    end
    local target = GridManager.GetGridQueue(fsm.cityId, GridMarker.Queue, ZoneType.Kitchen, serialNumber)
    if not target then
        fsm.owner:SetPlayAniIdle()
        return false
    end
    fsm:SetMoveInfo(target, fsm:GetTutorialSpeedPercent())
    return true
end
-----------------------------------------
---是否可以运行QueueWait
-----------------------------------------
TransitionHandles[FSMTransitionType.EatRunWithQueueWait] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Queue
end
-----------------------------------------
---是否可以去厨房ServingTable
-----------------------------------------
TransitionHandles[FSMTransitionType.EatMoveToServingTable] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    if fsm.owner.currGrid.markerType == GridMarker.Queue and fsm.owner.currGrid.serialNumber <= 2 then
        local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.ServingTable, ZoneType.Kitchen)
        if not target then
            fsm.owner:SetPlayAniIdle()
            return false
        end
        fsm:SetMoveInfo(target, fsm:GetTutorialSpeedPercent())
        return true
    end

   if fsm.owner.targetGrid.markerType == GridMarker.Queue then
        serialNumber = fsm.owner.targetGrid.serialNumber - 1
        local target = GridManager.GetGridQueue(fsm.cityId, GridMarker.Queue, ZoneType.Kitchen, serialNumber)
        if not target then
            fsm.owner:SetPlayAniIdle()
            return false
        end
        fsm:SetMoveInfo(target, fsm:GetTutorialSpeedPercent())  
         return true
     end
    return false
  
end
-----------------------------------------
---是否可以运行ServingTable等待
-----------------------------------------
TransitionHandles[FSMTransitionType.EatServingTableWait] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.ServingTable
end
-----------------------------------------
---是否可以去厨房Table
-----------------------------------------
TransitionHandles[FSMTransitionType.EatMoveToKitchenTable] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    if fsm.owner.currGrid.markerType ~= GridMarker.ServingTable then
        return false
    end
    local serialNumber = nil
    if TutorialManager.CurrentStep.value == TutorialStep.SchedulesEat then
        if fsm.owner:GetProfessionType() == ProfessionType.Chef then
            serialNumber = 1
        end
        if fsm.owner:GetProfessionType() == ProfessionType.FreeMan then
            serialNumber = 2
        end
    end
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Table, ZoneType.Kitchen, nil, serialNumber)
    if not target then
        fsm.owner:SetPlayAniIdle()
        return false
    end
    fsm:SetMoveInfo(target, 1, AnimationType.CarryFoodWalk)

    return true
end
-----------------------------------------
---是否可以和tool3交互
-----------------------------------------
TransitionHandles[FSMTransitionType.EatRunWithServingTable] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.ServingTable
end
-----------------------------------------
---是否可以和tool3交互
-----------------------------------------
TransitionHandles[FSMTransitionType.EatRunWithTable] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Table
end
