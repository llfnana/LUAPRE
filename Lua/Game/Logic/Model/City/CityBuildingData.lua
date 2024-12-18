--region -------------引入模块-------------
local PrdSlotStatus = HomeDefine.PrdSlotStatus
--endregion

--region -------------数据定义-------------

---@class HomeProduceSlot 生产插槽数据
---@field uid number 插槽UID
---@field tid number 产物配置ID
---@field startTime number 开始生产时间

--endregion

---@class HomeBuildingData 家园建筑数据
local Building = class('HomeBuildingData')

---@param vo SvrHomeBuildingVo 数据
function Building:ctor(vo)
    self.uid = vo.id
    self.flipVal = 1 --翻转值

    self._buildingTimer = nil --建造定时器

    self.produceSlots = {} ---@type HomeProduceSlot[] 生产插槽

    self:assign(vo)
end

---赋值vo数据
---@param vo SvrHomeBuildingVo 数据
function Building:assign(vo)
    if vo.buildCId == nil then
        return
    end

    self.tid = vo.buildCId
    self.lv = vo.lv
    self.pos = { vo.x, vo.y }
    self.endTime = vo.completeTime --建造结束时间
    self._autoPrd = vo.autoProduct == 1 --自动生产开关
    self._heroSlot = vo.dispatchUnlock --英雄槽位解锁数据，二进制

    local tbBuilding = TbHomeBuilding[self.tid]
    self.type = tbBuilding.Type ---@type HomeBuildingType 类型
    self.camp = HomeModule.getBuildingCamp(self.tid) --势力

    --判断是否需要触发完成事件
    if self:getStatus() == HomeBuildingStatus.Doing then --建造中
        if self._buildingTimer == nil then
            local leftTime = self:getLeftTime(nil, true)
            self._buildingTimer = TimeModule.addDelay(leftTime, function ()
                self:_clearTimer()

                Event.Brocast(EventDefine.OnHomeBuildingUpdate, self)
            end)
        end
    else
        self:_clearTimer()
    end

    Event.Brocast(EventDefine.OnHomeBuildingUpdate, self)
end

---@private
function Building:_clearTimer()
    if self._buildingTimer ~= nil then
        TimeModule.removeTimer(self._buildingTimer)
        self._buildingTimer = nil
    end
end

---获取建筑状态
---@param time number 截至时间
---@return HomeBuildingStatus
function Building:getStatus(time)
    if self.endTime == nil then
        return HomeBuildingStatus.None
    elseif self:getLeftTime(time) > 0 then
        return HomeBuildingStatus.Doing
    --elseif self:isFunctional() and self.buildTime ~= 0 then
    --    return HomeBuildingStatus.UnChecked
    end
    return HomeBuildingStatus.Done
end

---获取状态动画名
function Building:getStatusAni()
    local status = self:getStatus()

    local animName = HomeDefine.BuildingAnim.Idle --生产中
    if self:isRepairable() then --可修复（有废墟动作）
        if status == HomeBuildingStatus.None then --未建造
            animName = HomeDefine.BuildingAnim.Broke
        elseif status == HomeBuildingStatus.Doing then --建造中
            if self:isRepairable() and self.lv == 1 then --可修复 且 非升级
                animName = HomeDefine.BuildingAnim.Broke
            end
        else
            --生产型建筑不在生产中
            if self:isProduction() and not self:isProducing() then
                animName = HomeDefine.BuildingAnim.Free
            end
        end
    end

    return animName
end

---是否建造完成
---@param time number 截至时间
function Building:isBuildDone(time)
    return self:getStatus(time) == HomeBuildingStatus.Done
end

---是否未建造（废墟）
---@param time number 截至时间
function Building:isBuildNone(time)
    return self:getStatus(time) == HomeBuildingStatus.None
end

---获取建造完成时间
function Building:getEndTime()
    --local tbLevel = TbHomeBuildingLevel[self.lv]
    --return self.buildTime + tbLevel.Time --用时
    return self.endTime or 0
end

---获取剩余建造时间
---@param time number 截止时间【默认服务器时间】
---@param isSec boolean 是否返回秒数
function Building:getLeftTime(time, isSec)
    time = time or TimeModule.getServerTime(isSec)
    return self:getEndTime() - time
end

---英雄插槽是否激活
---@return boolean
function Building:isHeroSlotActive(idx)
    if self:isProduction() then
        --local tbBuilding = TbHomeBuilding[self.tid]
        return bit.band(self._heroSlot, bit.lshift(1, idx - 1)) ~= 0
    else --根据等级派遣位置
        local tbLevel = TbHomeBuildingLevel[self.lv]
        return idx <= tbLevel.Seat
    end
end

---是否是可翻修（存在废墟）的建筑（生产或议会）
function Building:isRepairable()
    return self:isProduction()
            or self.type == HomeBuildingType.Parliament
end

--region =================== 生产型建筑相关 ===================

---@param vo SvrHomeProductVo
function Building:addProductSlot(vo)
    local slot = {} ---@type HomeProduceSlot
    slot.uid = vo.id
    --slot.buildingUid = vo.buildId
    slot.tid = vo.productCId
    slot.startTime = TimeUtil.millsToSec(vo.roundStartTime)
    table.insert(self.produceSlots, slot)
end

---添加或更新产品插槽数据
---@param vo SvrHomeProductVo
function Building:assignProductSlot(vo)
    local slot = self.produceSlots[vo.position]
    if slot == nil then
        slot = {} ---@type HomeProduceSlot
        self.produceSlots[vo.position] = slot
    end

    slot.uid = vo.id
    slot.tid = vo.productCId
    slot.startTime = TimeUtil.millsToSec(vo.roundStartTime)
end

---是否是生产型建筑
function Building:isProduction()
    return self.type == HomeBuildingType.Production
end

---是否验收
function Building:isChecked()
    if not self:isBuildDone() then --未建造完成
        return false
    end

    if self:isBusiness() then --生产型建筑一级需要验收
        if self.lv > 1 then
            return true
        end
    elseif not self:isProduction() then --非生产型建筑不用验收
        return true
    end

    return self.endTime == 0
end

---生产型建筑验收
--function Building:check()
--    self.endTime = 0
--end

---是否允许自动生产
function Building:isAutoEnable()
    if not self:isAutoActive() then
        return false
    end

    return self._autoPrd
end

---自动生产是否已激活
function Building:isAutoActive()
    if not self:isProduction() --非生产型
            or not self:isChecked() then --未验收
        return false
    end
    --第一个派遣位是否激活
    return self:isHeroSlotActive(1)
end

function Building:setAutoProduce(isAuto)
    self._autoPrd = isAuto
end

--function Building:switchAuto()
--    self._autoPrd = not self._autoPrd
--end

---是否自动生产（开启）
function Building:isAuto()
    return self._autoPrd
end

---获取生产插槽状态
---@param slot HomeProduceSlot|number 插槽
---@return HomePrdSlotStatus
function Building:getPrdSlotStatus(slot)
    if GameUtil.isNumber(slot) then
        slot = self.produceSlots[slot]
    end

    if slot == nil then --未解锁
        return PrdSlotStatus.LOCK
    end

    if slot.tid == 0 then --空闲
        return PrdSlotStatus.FREE
    end

    -- 是否正在生产
    local leftTime = self:calcPrdSlotLeftTime(slot)
    return leftTime > 0 and PrdSlotStatus.DOING or PrdSlotStatus.DONE
end

---产品插槽是否成熟（完成）
function Building:isPrdSlotRipe(slot)
    return self:getPrdSlotStatus(slot) == PrdSlotStatus.DONE
end

---产品插槽是否空闲
function Building:isPrdSlotFree(idx)
    return self:getPrdSlotStatus(idx) == PrdSlotStatus.FREE
end

---是否在生产中
function Building:isProducing()
    for _, slot in ipairs(self.produceSlots) do
        if self:getPrdSlotStatus(slot) == PrdSlotStatus.DOING then
            return true
        end
    end
    return false
end

---获取时间最近（开始生产）插槽
---@return HomeProduceSlot
function Building:getRecentSlot()
    local serverTime = TimeModule.getServerTime()
    local minLeftTime, slot = nil, nil
    for _, _slot in ipairs(self.produceSlots) do
        local prdTime = self:getProductTime(_slot.tid)
        if prdTime ~= nil then
            local leftTime = _slot.startTime + prdTime - serverTime
            if minLeftTime == nil or leftTime < minLeftTime then
                minLeftTime, slot = leftTime, _slot
            end
        end
    end
    return slot
end

---获取英雄派遣加成减小耗时
function Building:getPrdHeroReduceTime()
    --派遣加成
    local baseTalent = TbHomeConfig[1].Value
    local manageTalent = 0 --经营资质
    local tbBuilding = TbHomeBuilding[self.tid]
    for i, slot in ipairs(tbBuilding.HeroSlots) do
        if self:isHeroSlotActive(i) then
            local hero = HeroModule.getHero(slot.Value1)
            manageTalent = manageTalent + hero.manageTalent
        end
    end
    --缩减生产时间 todo 公式先固定生产耗时
    return manageTalent / (manageTalent + baseTalent) * 3000000
end

---获取产品生产时间
---@param tid number 产品Tid
function Building:getProductTime(tid)
    local tbProduct = TbHomeProduct[tid]
    if not tbProduct then return end

    local reduceTime = 0 --减少时间
    --派遣加成缩减时间
    reduceTime = reduceTime + self:getPrdHeroReduceTime()
    --建筑等级加成
    reduceTime = reduceTime + TbHomeBuildingLevel[self.lv].ProductTime
    --Buff加成（缩减总时间百分比）
    local buffDown = BuffModule.getValue(BuffModule.enum.HOME_BUILDING_TIME_DOWN)
    reduceTime = reduceTime + MathUtil.mulPercent(buffDown, tbProduct.Time)

    local timeInMills = math.max(MathUtil.KILO, tbProduct.Time - reduceTime)
    return TimeUtil.millsToSec(timeInMills)
end

---获取产品插槽剩余生产时间
---@param slot HomeProduceSlot|number 插槽 or 索引
---@param serverTime number
---@return number, number 剩余时间, 剩余进度
function Building:calcPrdSlotLeftTime(slot, serverTime)
    if GameUtil.isNumber(slot) then
        slot = self.produceSlots[slot]
    end
    if slot == nil or slot.tid == 0 then
        return 0, 0
    end

    serverTime = serverTime or TimeModule.getServerTime()
    local prdTime = self:getProductTime(slot.tid)
    local leftTime = slot.startTime + prdTime - serverTime
    return leftTime, leftTime / prdTime
end

---获取空闲产品插槽
---@return HomeProduceSlot, number
function Building:getFreePrdSlot()
    for i, slot in ipairs(self.produceSlots) do
        if self:isPrdSlotFree(i) then
            return slot, i
        end
    end
end

--endregion

--region =================== 经营型建筑相关 ===================

---是否是经营型建筑
function Building:isBusiness()
    return self.type == HomeBuildingType.Business
end

---获取经营英雄派遣加成
function Building:getProfitHeroAdd()
    local tbBuilding = TbHomeBuilding[self.tid]
    local ratio = 0
    for i, hs in ipairs(tbBuilding.HeroSlots) do
        if not self:isHeroSlotActive(i) then
            break
        end
        local hero = HeroModule.getHero(hs.Value1)
        if hero then
            ratio = ratio + MathUtil.toScale(hero.manageTalent)
        end
    end
    return ratio
end

---获取总收益
function Building:getProfit()
    --非经营性建筑没有收益
    if not self:isBusiness()then
        return 0
    end

    local tbBuilding = TbHomeBuilding[self.tid]
    local ratio = tbBuilding.Ratio --基础系数
    --英雄派遣加成
    ratio = ratio + self:getProfitHeroAdd()
    --Buff加成
    ratio = ratio + BuffModule.getHomeCampUp(self.camp) --Buff势力加成
    ratio = ratio + BuffModule.getHomeBuildingUp(self.tid) --Buff建筑加成

    local tbLevel = TbHomeBuildingLevel[self.lv]
    return tbLevel.Profit * ratio
end

--endregion

---计算截至时间的收益
--function Building:calcTimeProfit(time, duration)
--    local endTime = self:getEndTime()
--    duration = math.min(duration, time - endTime)
--
--    return self:getProfit()
--end

--function Building:toString()
--    local str = "=== 英雄数据：\n"
--    str = str .. "=== 配置ID:" .. self.tid .. "\n"
--    str = str .. "=== 成长资质:" .. self.growTalent .. "\n"
--    str = str .. "=== 经营资质:" .. self.manageTalent .. "\n"
--    str = str .. "=== 战斗资质:" .. self.fightTalent .. "\n"
--
--    str = str .. "=== 世界之力:" .. self:calcWorldPower() .. "\n"
--    str = str .. "=== 承载之力:" .. self:_calcBearWorldPower() .. "\n"
--
--    return str
--end

return Building
