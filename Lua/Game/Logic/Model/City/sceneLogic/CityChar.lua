--region -------------引入模块-------------
local LuaEvent = require "Logic/LuaEvent"
--endregion

--region -------------数据定义-------------
--endregion

---@class City.Char 角色
local Char = class('CityChar')

function Char:ctor(data)

    self.id = data.id
    self.res_id = data.res_id
    self.gameObject = nil
    self.transform = nil
    self.animation = nil
    self.animationState = nil
    self.animationSke = nil
    self.meshRenderer = nil
    self.initPosition = nil

    self._initScaleX = nil --初始X比例
    self._isFlip = false --是否翻转


    self.isDestroy = false --是否回收

    self.cell = nil ---@type City.MapCell 当前站位格

    self._curAnim = nil ---@type CityCharAnim 当前动画
    self._curDir = nil ---@type City.PositionDir 当前朝向
    self.interactEvt = LuaEvent.new() ---@type LuaEvent 交互事件

end

function Char:bind(go,resid)
  self.gameObject = go
    self.transform = go.transform
    self.initPosition = go.transform.position

    self.animation = go:GetComponentInChildren(typeof(SkeletonAnimation))
    self.meshRenderer = go:GetComponentInChildren(typeof(MeshRenderer))
    self.meshRenderer.sortingLayerName = "Building"
    --加载Spine DataAsset
    ResInterface.SyncLoadCommon(resid .. '_a_SkeletonData.asset', function (dataAsset)
        self.animation.skeletonDataAsset = dataAsset
        self.animation:Initialize(true)
    end)

    self.animationState = self.animation.state
    self.animationSke = self.animation.skeleton

    --根据站位设置比例大小
    local scale = CityDefine.CharScale
    local scaleX =  scale --朝向

    self.animationSke.ScaleX = scaleX
    self.animationSke.ScaleY = scale
    self._initScaleX = scaleX
    --根据站位设置层级
    --self:resetSortingOrder()

    --self.animationState.Complete = self.animationState.Complete + function(entry)
    --    local aniName = entry.Animation.Name
    --    --播放完受击动画，还原状态
    --    if aniName == "hit" then
    --        --Log.info('[PveChar]受击还原：', self.mid, self._hitStates[1], #self._hitStates)
    --        --if #self._hitStates == 1 then
    --        --    self:setState(self._hitStates[1])
    --        --end
    --    end
    --end

    self:playAnimEx1("idle", true)
    --self:playAnimEx("stand", true)
     --self:playAnimEx("idel_down", true)
end

function Char:setSortingOrder(order)
    self.meshRenderer.sortingOrder = order
end

---@param cell Home.MapCell
---@param notPos boolean 是否不改变位置
function Char:setCell(cell, notPos)
    if self.cell ~= nil then
        self.cell.char = nil
    end

    if not notPos then
        --self.transform.position = cell.transform.position
        self.transform.position = cell:getRealPos()
    end

    self.cell = cell
    cell.char = self

    --设置层级
    -- self:setSortingOrder(cell:getSortingOrder())
end

---设置翻转（角色朝向）
function Char:flip(isFlip)
    isFlip = isFlip or false
    if isFlip == self._isFlip then
        return
    end
    self.animationSke.ScaleX = isFlip and -self._initScaleX or self._initScaleX
    self._isFlip = isFlip
end

function Char:isFlip()
    return self._isFlip
end

--播放动画（0通道，强制播放，不循环）
---@param name string|SkeletonAnimation 动画名
---@param loop boolean 是否循环（默认false）

---播放动画和朝向
---@param anim HomeCharAnim 动画
---@param dir Home.PositionDir
function Char:playAnim(anim, dir)
    dir = dir or self._curDir
    --相同动画和朝向不重复播放
    if self._curAnim == anim and self._curDir == dir then
        return
    end

    local name, isFlip = self:_getAnimNameAndFlip(anim, dir)
    if name ~= self.animation.AnimationName then
        self.animation.state:SetAnimation(0, name, true)
    end
    self.animation.skeleton.ScaleX = isFlip and -1 or 1

    self._curAnim = anim
    self._curDir = dir
end

---@private
---@param anim HomeCharAnim 动画
---@param dir Home.PositionDir 朝向
---@return string, boolean 动画名，是否翻转
function Char:_getAnimNameAndFlip(anim, dir)

    --判断是否需要翻转（上下翻转为左右）
    local isFlip = dir == CityPosition.Dir.Up or dir == CityPosition.Dir.Down

--    local isFlip  = dir > 4 and -1 or 1
--    local _dir = dir
--    if dir == CityPosition.Dir.DownLeft then
--        _dir = CityPosition.Dir.DownRight
--    elseif dir == CityPosition.Dir.Left then
--        _dir = CityPosition.Dir.Right
--    elseif dir == Actor.UpLeft then
--        _dir = CityPosition.Dir.UpRight
--    end

--    local state = 1
--    local animName = nil
--    if anim == CityPlayerAnim.idle then
--        animName = "idle"
--        state =1
--    elseif anim == CityPlayerAnim.walk then
--        animName = "walk"
--        state =2

--    elseif anim == CityPlayerAnim.run then
--        animName = "run"
--        state =3

--    elseif anim == CityPlayerAnim.bed then
--        animName = "bed"
--        state =4
--    elseif anim == CityPlayerAnim.sleeping then
--        animName = "sleeping"
--        state = 5
--    elseif anim == CityPlayerAnim.sicksleep then
--        animName = "sicksleep"
--        state = 6
--    elseif anim == CityPlayerAnim.dropsleep then
--        animName = "dropsleep"
--        state = 7

--    elseif anim == CityPlayerAnim.eat then
--        animName = "eat"
--        state = 8

--    elseif anim == CityPlayerAnim.eatwalk then
--        animName = "eatwalk"
--        state = 9

--    elseif anim == CityPlayerAnim.eatsit then
--        animName = "eatsit"
--        state = 10

--    elseif anim == CityPlayerAnim.cooking then
--        animName = "cooking"
--        state = 11
--    elseif anim == CityPlayerAnim.breed then
--        animName = "breed"
--         state = 12
--   elseif anim == CityPlayerAnim.logging then
--        animName = "logging"
--          state = 13
--  elseif anim == CityPlayerAnim.cutTree then
--        animName = "cutTree"
--         state = 14
--   elseif anim == CityPlayerAnim.hammerwork then
--        animName = "hammerwork"
--        state = 15
--   end

--    local _action = CityDefine.ACTION_LIST_PLAYER[state * 10 + _dir] 

    local animName = nil
    if anim == CityPlayerAnim.Idle then
        animName = "stand"
    elseif anim ==CityPlayerAnim.Run then
        animName = "run"
    end
--    --上和左的动作朝后
    if dir == CityPosition.Dir.Up
            or dir == CityPosition.Dir.Left then
        animName = animName .. "_back"
    end


    return animName, isFlip
end

function Char:interact()
    local mapCtrl = CityModule.getMapCtrl()
    local player = CityModule.getMainCtrl().player
    if player == self then --自己
        return
    end

    --判断玩家是否在邻居格子
    local isNeighbor = player.cell:distance(self.cell) == 1
    if not isNeighbor then
        --移动到邻居格子
        local path = mapCtrl:findPath(player.cell, self.cell)
        if path ~= nil then
            player:move(path)
        end
        return
    end

    if self.interactEvt ~= nil then
        self.interactEvt:trigger()
    end
end

--播放动画（0通道，强制播放，不循环）
---@param name string|SkeletonAnimation 动画名
---@param loop boolean 是否循环（默认false）
function Char:playAnimEx1(name, loop)
    loop = loop or false --默认不循环播放
    return self.animationState:SetAnimation(0, name, loop)
    --self.animationSke.ScaleX = isFlip and -1 or 1
end

---添加动画队列
---@param name string 动画名
---@param loop boolean 是否循环（默认false）
---@param delay number 延迟（默认无）
---@return TrackEntry
function Char:addAniEx(name, loop, delay)
    loop = loop or false --默认不循环播放
    delay = delay or 0 --默认无延迟
    return self.animationState:AddAnimation(0, name, loop, delay)
end

function Char:destroy()
    if self.cell ~= nil then
        self.cell.char = nil
    end
    if self.isDestroy then
        return
    end
    GODestroy(self.gameObject)
    self.gameObject = nil
    self.transform = nil

    self.isDestroy = true
end

return Char