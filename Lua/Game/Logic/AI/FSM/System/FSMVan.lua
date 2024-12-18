FSMVan = Clone(FSMSystem)
FSMVan.__cname = "FSMVan"
FSMVan.LastMoveToQueueTime = 0
FSMVan.BornGapTime = 2.0

function FSMVan:ConfigAI()
    local entryState = EntryState:New()
    entryState:AddTransition(CheckType.Process, FSMTransitionType.VanMoveToVanQueue, StateId.MoveToVanQueue)
    entryState:AddTransition(CheckType.Process, FSMTransitionType.VanRunWithVanBornWait, StateId.RunWithVanBornWait)
    self:AddState(entryState)

    local moveVanQueue = MoveState:New(StateId.MoveToVanQueue)
    moveVanQueue:AddTransition(CheckType.Complete, FSMTransitionType.VanMoveToWarehouseQueue, StateId.MoveToWarehouseQueue)
    moveVanQueue:AddTransition(CheckType.Complete, FSMTransitionType.VanMoveToVanQueue, StateId.MoveToVanQueue)
    moveVanQueue:AddTransition(CheckType.Complete, FSMTransitionType.VanRunWithVanQueueWait, StateId.RunWithVanQueueWait)
    self:AddState(moveVanQueue)

    local waitVanQueue = WaitState:New(StateId.RunWithVanQueueWait)
    waitVanQueue:AddTransition(CheckType.Process, FSMTransitionType.VanMoveToWarehouseQueue, StateId.MoveToWarehouseQueue)
    waitVanQueue:AddTransition(CheckType.Process, FSMTransitionType.VanMoveToVanQueue, StateId.MoveToVanQueue)
    self:AddState(waitVanQueue)

    local moveQueue = MoveState:New(StateId.MoveToWarehouseQueue)
    moveQueue:AddTransition(CheckType.Complete, FSMTransitionType.VanMoveToWarehouseTool, StateId.MoveToWarehouseTool)
    moveQueue:AddTransition(CheckType.Complete, FSMTransitionType.VanRunWithWarehouseQueueWait, StateId.RunWithQueueWait)
    self:AddState(moveQueue)

    local waitQueue = WaitState:New(StateId.RunWithQueueWait)
    waitQueue:AddTransition(CheckType.Process, FSMTransitionType.VanMoveToWarehouseTool, StateId.MoveToWarehouseTool)
    self:AddState(waitQueue)

    local moveTool = MoveState:New(StateId.MoveToWarehouseTool)
    moveTool:AddTransition(CheckType.Complete, FSMTransitionType.VanRunWithWarehouseTool, StateId.RunWithWarehouseTool)
    moveTool:AddTransition(CheckType.Complete, FSMTransitionType.VanMoveToVanDestroy, StateId.MoveToVanDestroy)
    self:AddState(moveTool)

    local runTool = VanActionState:New(StateId.RunWithWarehouseTool)
    runTool:AddTransition(CheckType.Complete, FSMTransitionType.VanMoveToVanDestroy, StateId.MoveToVanDestroy)
    self:AddState(runTool)

    local moveVanDestory = MoveState:New(StateId.MoveToVanDestroy)
    moveVanDestory:AddTransition(CheckType.Complete, FSMTransitionType.VanRunWithVanBorn, StateId.RunWithVanBorn)
    self:AddState(moveVanDestory)

    local runVanBorn = VanActionState:New(StateId.RunWithVanBorn)
    runVanBorn:AddTransition(CheckType.Complete, FSMTransitionType.VanMoveToVanQueue, StateId.MoveToVanQueue)
    runVanBorn:AddTransition(CheckType.Complete, FSMTransitionType.VanRunWithVanBornWait, StateId.RunWithVanBornWait)
    self:AddState(runVanBorn)

    local waitVanBorn = WaitState:New(StateId.RunWithVanBornWait)
    waitVanBorn:AddTransition(CheckType.Process, FSMTransitionType.VanMoveToVanQueue, StateId.MoveToVanQueue)
    self:AddState(waitVanBorn)
end

--获取仓库工具点
function FSMVan:GetWarehouseTool()
    local function CheckGridCanUse(grid)
        if nil == grid then
            return false
        end
        if not EventSceneManager.GetVanLoadPortSwitch(grid.furnitureId, grid.markerIndex) then
            return false
        end
        local itemId, itemCount = grid:GetLoadLimitInfo()
        if itemCount <= 0 then
            return false
        end
        return true
    end

    local target = GridManager.GetGridByMarkerType(self.cityId, GridMarker.Tool1ForWarehouse, ZoneType.Warehouse)
    if CheckGridCanUse(target) then
        return target
    end
    local target = GridManager.GetGridByMarkerType(self.cityId, GridMarker.Tool2ForWarehouse, ZoneType.Warehouse)
    if CheckGridCanUse(target) then
        return target
    end
    local target = GridManager.GetGridByMarkerType(self.cityId, GridMarker.Tool3ForWarehouse, ZoneType.Warehouse)
    if CheckGridCanUse(target) then
        return target
    end
    local target = GridManager.GetGridByMarkerType(self.cityId, GridMarker.Tool4ForWarehouse, ZoneType.Warehouse)
    if CheckGridCanUse(target) then
        return target
    end
    local target = GridManager.GetGridByMarkerType(self.cityId, GridMarker.Tool5ForWarehouse, ZoneType.Warehouse)
    if CheckGridCanUse(target) then
        return target
    end
    local target = GridManager.GetGridByMarkerType(self.cityId, GridMarker.Tool6ForWarehouse, ZoneType.Warehouse)
    if CheckGridCanUse(target) then
        return target
    end
    local target = GridManager.GetGridByMarkerType(self.cityId, GridMarker.Tool7ForWarehouse, ZoneType.Warehouse)
    if CheckGridCanUse(target) then
        return target
    end
    return nil
end

-----------------------------------------
---是否可以去卡车Queue
-----------------------------------------
TransitionHandles[FSMTransitionType.VanMoveToVanQueue] = function(fsm)
    local needCheckTime = fsm:IsRunning(StateId.EntryState) or fsm:IsRunning(StateId.RunWithVanBorn) or fsm:IsRunning(StateId.RunWithVanBornWait)
    if needCheckTime then
        local isNight = TimeManager.GetCityIsNight(DataManager.GetCityId())
        local gapTime = Time.realtimeSinceStartup - FSMVan.LastMoveToQueueTime
        if isNight then
            if gapTime < FSMVan.BornGapTime * 1.5 then
                return false
            end
        else
            if gapTime < FSMVan.BornGapTime then
                return false
            end
        end
    end
    
    if fsm.owner.currGrid.markerType == GridMarker.VanQueue and fsm.owner.currGrid.serialNumber == 1 then
        return false
    end
    local serialNumber = nil
    if nil ~= fsm.owner.targetGrid and fsm.owner.targetGrid.markerType == GridMarker.VanQueue then
        serialNumber = fsm.owner.targetGrid.serialNumber - 1
    end
    local target = GridManager.GetGridQueue(fsm.cityId, GridMarker.VanQueue, ZoneType.MainRoad, serialNumber)
    if not target then
        return false
    end
    fsm:SetMoveInfo(target)

    if needCheckTime then
        FSMVan.LastMoveToQueueTime = Time.realtimeSinceStartup 
    end
    return true
end
-----------------------------------------
---是否可以运行QueueWait
-----------------------------------------
TransitionHandles[FSMTransitionType.VanRunWithVanQueueWait] = function(fsm)
    return fsm.owner.currGrid.markerType == GridMarker.VanQueue
end
-----------------------------------------
---是否可以运行QueueWait
-----------------------------------------
TransitionHandles[FSMTransitionType.VanRunWithWarehouseQueueWait] = function(fsm)
    return fsm.owner.currGrid.markerType == GridMarker.Queue
end
-----------------------------------------
---是否可以去仓库Queue
-----------------------------------------
TransitionHandles[FSMTransitionType.VanMoveToWarehouseQueue] = function(fsm)
    if fsm.owner.currGrid.markerType == GridMarker.VanQueue and fsm.owner.currGrid.serialNumber == 1 then
        local tool = fsm:GetWarehouseTool()
        if nil == tool then
            return false
        end
        local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.Queue, ZoneType.Warehouse)
        if not target then
            return false
        end
        fsm:SetMoveInfo(target)
        return true
    end
    return false
end
-----------------------------------------
---是否可以移动到仓库卸载口
-----------------------------------------
TransitionHandles[FSMTransitionType.VanMoveToWarehouseTool] = function(fsm)
    local target = fsm:GetWarehouseTool()
    if not target then
        return false
    end
    fsm:SetMoveInfo(target)
    return true
end
-----------------------------------------
---是否可以执行加载
-----------------------------------------
TransitionHandles[FSMTransitionType.VanRunWithWarehouseTool] = function(fsm)
    local grid = fsm.owner.currGrid
    if not EventSceneManager.GetVanLoadPortSwitch(grid.furnitureId, grid.markerIndex) then
        return false
    end
    return true
end
-----------------------------------------
---是否可以移动到卡车销毁点
-----------------------------------------
TransitionHandles[FSMTransitionType.VanMoveToVanDestroy] = function(fsm)
    local target = GridManager.GetGridByMarkerType(fsm.cityId, GridMarker.VanDestroy, ZoneType.MainRoad)
    if not target then
        return false
    end
    fsm:SetMoveInfo(target)
    return true
end
-----------------------------------------
---是否可以在卡车出生点处理
-----------------------------------------
TransitionHandles[FSMTransitionType.VanRunWithVanBorn] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.VanDestroy
end
-----------------------------------------
---是否可以出生点等待
-----------------------------------------
TransitionHandles[FSMTransitionType.VanRunWithVanBornWait] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.VanBorn
end
