------------------------------------------------------------------------
--- @desc 关卡地图格子
--- @author chenyl
------------------------------------------------------------------------

--region -------------引入模块-------------

--endregion

---@class City.MapCell 地图格子
local Cell = class('CityMapCell')

function Cell:ctor()
    self._obj = nil ---@type City.MapCellObj

    self.type = CityCellType.Ground --格子类型：1=道路(可寻走点)，2=墙壁(阻挡点),3=
    self.gdtype = CityCellGDType.None --格子类型：无拐点 1
    self._status = CityCellStatus.None

    self.position = nil ---@type City.Position 坐标

    self.realpos = nil ---@type City.realpos 坐标
    self.player = nil ---@type City.Player 玩家
    self.char = nil ---@type City.Char 角色
    self.facility = nil ---@type City.Facility 设施
    self.fog = nil ---@type City.Fog 云雾

    self._isDragging = false
end

---@param obj City.MapCellObj
function Cell:bindObj(obj)
    self._obj = obj
    obj.cell = self

    obj.transform.position = self:getRealPos()
    obj.gameObject.name = string.format("Cell_%s_%s", self.position.x, self.position.y)

    self:_refreshObjColor()
end

function Cell:getGameObject()
    if self._obj ~= nil then
        return self._obj.gameObject
    end
end

---获取格子的真实坐标
---@param offsetX number 偏移X
---@return UnityEngine.Vector3
function Cell:getRealPos(offsetX)
    local mapCtrl = CityModule.getMapCtrl()
    local x = self.position.x + (offsetX or 0)
    return mapCtrl:calcRealPosition(x, self.position.y)
end

---获取格子的排序层级
function Cell:getSortingOrder()
    local pos = self.position
    return pos.x - pos.y + CityDefine.MapSizeMaxHeight
end

--function Cell:setSortingOrder(order)
--    if self._obj ~= nil then
--        self._obj._spriteRenderer.sortingOrder = order
--    end
--end

function Cell:onPointerDragBegin()
    self._isDragging = true
end

function Cell:onPointerDragEnd()
    self._isDragging = false
end

function Cell:onPointerLongPress()
    --拖拽中不触发长按
    if self._isDragging then
        return
    end

    if self.facility == nil
            or not self.facility:isBuilding() then
        return
    end

    ---@type City.Building
    local building = self.facility
    if not building:isChecked() then --未验收
        return
    end

    CityModule.getMainCtrl():buildPreviewMove(self.facility)
end

function Cell:onPointerClick(eventData)
    if eventData.dragging then
        return
    end

    if self:isFogging() then
        UIUtil.showText("该区域尚未开放")
        return
    end

    local mainCtrl = CityModule.getMainCtrl()
    if mainCtrl:isFsmState(CityFsmState.Ready) then
        if self.facility ~= nil and self.facility:canInteract() then
            self.facility:interact(self)
        elseif self.char ~= nil then --角色交互
            self.char:interact()
        else --玩家移动
            mainCtrl:playerMove(self)
        end
    elseif mainCtrl:isFsmState(CityFsmState.Building) then --建造
        mainCtrl:buildPreviewSetup(self) --移动建筑
    end
end

function Cell:onPointerEnter()
    local mainCtrl = CityModule.getMainCtrl()
    if mainCtrl:isFsmState(CityFsmState.Ready) then
        self:setStatus(CityCellStatus.Move)
    --elseif mainCtrl:isFsmState(CityFsmState.Building) then
    --    local mapCtrl = CityModule.getMapCtrl()
    --    mapCtrl:buildPreviewEnter(self)
    end
end

function Cell:onPointerExit()
    local mainCtrl = CityModule.getMainCtrl()
    if mainCtrl:isFsmState(CityFsmState.Ready) then
        self:setStatus(CityCellStatus.None)
    --elseif mainCtrl:isFsmState(CityFsmState.Building) then
    --    local mapCtrl = CityModule.getMapCtrl()
    --    mapCtrl:buildPreviewExit()
    end
end

---获取和目标格子的距离
---@param cell City.MapCell
---@return number
function Cell:distance(cell)
    return self.position:distance(cell.position)
end

---获取和目标格子的朝向
---@param cell City.MapCell
---@return City.PositionDir
function Cell:direction(cell)
    return (cell.position - self.position):toDir()
end

function Cell:setStatus(status)
    if self._status == status then
        return
    end

    self._status = status

    self:_refreshObjColor()
end

function Cell:_refreshObjColor()
    if self._obj == nil or self._status == nil then
        return
    end

    local statusColor = {
        [CityCellStatus.None] = Color.clear,
        [CityCellStatus.Move] = Color.green,
        [CityCellStatus.Build] = Color.blue,
        [CityCellStatus.Disable] = Color.red,
    }

    local color = statusColor[self._status]
    --if self.type == CityCellType.Wall then
    --    color = Color.red
    --end
    self._obj:setColor(color)
end

---是否有阻碍效果
---@return boolean
function Cell:isBlock()
    if self.type == CityCellType.Wall then
        return true
    end

    return self.facility ~= nil or self.player ~= nil
end

---是否可建造
---@return boolean
function Cell:isBuildable()
    if self:isBlock() then
        return false
    end
    return self.type == CityCellType.Ground
end

---云雾笼罩
function Cell:isFogging()
    return self.fog ~= nil
end

---解锁云雾
function Cell:unlockFog()
    if self.fog == nil then
        return
    end

    self.fog:destroy()
end

function Cell:canFree()
    --拖拽移动相机时不能释放
    return not self._isDragging
end

return Cell