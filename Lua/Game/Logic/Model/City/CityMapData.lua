--region -------------引入模块-------------
--endregion

--region -------------数据定义-------------

---@class Home._Position
---@field x number 坐标X
---@field y number 坐标Y

--endregion

---@class HomeData 家园数据
local Data = class('HomeData')

function Data:ctor()
    self.playerUid = nil ---@type number 玩家UID
    self.playerPos = nil ---@type Home._Position 玩家位置
    self._buildings = {} ---@type HomeBuildingData[] 建筑数据

    self._sweptObstacles = nil ---@type SvrHomeObstacleVo[] 已清除障碍物列表

    self.party = nil ---@type PartyData 宴会数据
end

function Data:setPlayerPos(pos)
    self.playerPos = pos
end

function Data:setPlayerUid(uid)
    self.playerUid = uid
end

---是否是自己的家园
function Data:isSelf()
    return self.playerUid == PlayerModule.getPlayerUid()
end

---是否是其他玩家的家园
function Data:isOther()
    return not self:isSelf()
end

function Data:setBuildings(buildings)
    self._buildings = buildings
end

function Data:getBuildings()
    return self._buildings or ListUtil.DEFAULT
end

function Data:addBuilding(building)
    if self._buildings == nil then
        self._buildings = {}
    end
    table.insert(self._buildings, building)
end

function Data:getBuilding(uid)
    if self._buildings == nil then
        return nil
    end
    for _, building in ipairs(self._buildings) do
        if building.uid == uid then
            return building
        end
    end
end

function Data:getBuildingByTid(tid)
    if self._buildings == nil then
        return nil
    end
    for _, building in ipairs(self._buildings) do
        if building.tid == tid then
            return building
        end
    end
end

function Data:deleteBuilding(uid)
    if self._buildings == nil then
        return
    end
    for i, building in ipairs(self._buildings) do
        if building.uid == uid then
            table.remove(self._buildings, i)
            break
        end
    end
end

function Data:setSweptObstacles(sweptObstacles)
    self._sweptObstacles = sweptObstacles
end

function Data:getSweptObstacles()
    return self._sweptObstacles or ListUtil.DEFAULT
end

function Data:addSweptObstacle(obstacle)
    if self._sweptObstacles == nil then
        self._sweptObstacles = {}
    end
    table.insert(self._sweptObstacles, obstacle)
end

function Data:setParty(party)
    self.party = party

    self.party:setPlayerUid(self.playerUid)
end

---宴会是否在举办中
function Data:isPartyDoing()
    return self.party ~= nil and self.party:isDoing()
end

return Data
