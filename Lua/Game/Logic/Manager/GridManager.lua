GridManager = {}
GridManager.__cname = "GridManager"

local this = GridManager

--初始化
function GridManager.Init()
    this.cityId = DataManager.GetCityId()
    if not this.gridItems then
        this.gridItems = Dictionary:New()
    end
    if not this.gridItems:ContainsKey(this.cityId) then
        this.gridItems:Add(this.cityId, CityGrid:New(this.cityId))
        if this.gridItems:Count() == 1 then
            EventManager.AddListener(EventType.UPGRADE_FURNITURE, this.UpgradeFurnitureFunc)
        end
    end
end

--清理
function GridManager.Clear(force)
    Utils.SwitchSceneClear(this.cityId, this.gridItems, force)
    if this.gridItems:Count() == 0 then
        EventManager.RemoveListener(EventType.UPGRADE_FURNITURE, this.UpgradeFurnitureFunc)
    end
end

---------------------------------
---事件响应
---------------------------------
function GridManager.UpgradeFurnitureFunc(cityId, zoneId, zoneType, furnitureType, index, level)
    this.gridItems[cityId]:UpgradeFurnitureFunc(zoneId, zoneType, furnitureType, index, level)
end

------------------------------------
---方法响应
---------------------------------
function GridManager.GetGrid(cityId)
    return this.gridItems[cityId]
end

-- 根据区域id获取结点对象
function GridManager.GetNodeByZoneId(cityId, zoneId)
    return this.GetGrid(cityId):GetNodeByZoneId(zoneId)
end

--添加缓存路径
function GridManager.AddCachePath(cityId, pathId, pathPoints)
    this.GetGrid(cityId):AddCachePath(pathId, pathPoints)
end

--获取默认缓存路径
function GridManager.GetCachePath(cityId, pathId)
    return this.GetGrid(cityId):GetCachePath(pathId)
end

--移除缓存路径
function GridManager.RemoveCachePath(cityId, pathId)
    this.GetGrid(cityId):RemoveCachePath(pathId)
end

-- 添加格子
function GridManager.AddGrid(cityId, grid)
    this.GetGrid(cityId):AddGrid(grid)
end

-- 删除格子
function GridManager.RemoveGrid(cityId, grid)
    this.GetGrid(cityId):RemoveGrid(grid)
end

--根据格子位置获取世界坐标
function GridManager.GridToPosition(cityId, x, z, y)
    return this.GetGrid(cityId):GridToPosition(x, z, y)
end

---根据世界坐标转化为格子id
function GridManager.PositionToGridId(cityId, position)
    return this.GetGrid(cityId):PositionToGridId(position)
end

--获取路径点
function GridManager.GetPath(cityId, startGrid, endGrid, isNormal)
    return this.GetGrid(cityId):GetPath(startGrid, endGrid, isNormal)
end

--根据Key获取格子信息
function GridManager.GetGridById(cityId, girdId)
    return this.GetGrid(cityId):GetGridById(girdId)
end

--根据标记类型获取格子列表
function GridManager.GetGridsByMarkerType(cityId, markerType, zoneType, findType)
    return this.GetGrid(cityId):GetGridsByMarkerType(markerType, zoneType, findType)
end

--根据zoneId 获取格子列表
function GridManager.GetGridsByZoneId(cityId, zoneId, markerType, findType)
    return this.gridItems[cityId]:GetGridsByZoneId(zoneId, markerType, findType)
end

--根据标记类型获取格子
function GridManager.GetGridByMarkerType(cityId, markerType, zoneType, markerIndex, serialNumber, findType)
    return this.GetGrid(cityId):GetGridByMarkerType(markerType, zoneType, markerIndex, serialNumber, findType)
end

--根据zoneId获取格子
function GridManager.GetGridByZoneId(cityId, zoneId, markerType, markerIndex, serialNumber, findType)
    return this.GetGrid(cityId):GetGridByZoneId(zoneId, markerType, markerIndex, serialNumber, findType)
end

--获取区域排队格子
function GridManager.GetGridQueue(cityId, markerType, zoneType, serialNumber, findType)
    return this.GetGrid(cityId):GetGridQueue(markerType, zoneType, serialNumber, findType)
end

--获取区域排队格子
function GridManager.GetGridByFurnitureId(cityId, furnitureId, furnitureIndex, findType)
    return this.GetGrid(cityId):GetGridByFurnitureId(furnitureId, furnitureIndex, findType)
end

---计算真实（局部）坐标
function GridManager.GetRealPosition(x, y)
    local OffsetX = CityDefine.MapCellSize[1] / 2 --格子X的偏移
    local OffsetY = CityDefine.MapCellSize[2] / 2 --格子Y的偏移
    --//右下角为零点
    --//var _poxX = (pos.x - pos.y) * m_offsetX;
    --//var _poyX = (pos.x + pos.y) * offsetY;
    --左上角为零点（格子往右居中）
    local _posX = (x + y + 1) * OffsetX
    local _posY = (-x + y) * OffsetY
    return Vector3.New(_posX, _posY, 0)
end

---根据真实坐标x和y，计算所在的格子坐标
---@return City.Position
function GridManager.GetCellPosition(x, y)
    local OffsetX = CityDefine.MapCellSize[1] / 2 --格子X的偏移
    local OffsetY = CityDefine.MapCellSize[2] / 2 --格子Y的偏移

    local _posX = math.floor((x / OffsetX - y / OffsetY) / 2)
    local _posY = math.floor((x / OffsetX + y / OffsetY) / 2)
    return _posX, _posY
end

