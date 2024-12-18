------------------------------------------------------------------------
--- @desc 关卡怪物

------------------------------------------------------------------------

--region -------------引入模块-------------
local FsmState = CityDefine.FsmState
--endregion

---@class City.Monster 怪物

local Monster = class('CityMonster', CityChar)

local MonsterState = {
    Idle = 1,
    Moving = 2,
    MoveDone = 3,
}
--endregion


function Monster:ctor(id)
    CityChar.ctor(self,id)
    self.id = id
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
    self.cellTarget = nil ---@type City.MapCell 当前站位格

    self._curAnim = nil ---@type CityCharAnim 当前动画
    self._curDir = nil ---@type City.PositionDir 当前朝向

     self._state = MonsterState.Idle
    self._mvTargets = {} ---@type Home.MapCell[] 移动目标格子


    self.movecompletefunc = nil

end

function Monster:bind(go,resid)
    self.gameObject = go
    self.transform = go.transform
    self.initPosition = go.transform.position
    self.transform.localScale = Vector3.one * 0.65
    self.animation = go:GetComponentInChildren(typeof(SkeletonAnimation))
    self.meshRenderer = go:GetComponentInChildren(typeof(MeshRenderer))
    self.meshRenderer.sortingLayerName = "Building"
    --加载Spine DataAsset
    ResInterface.SyncLoadCommon(resid .. '_SkeletonData.asset', function (dataAsset)
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

     self:SetAnim(AnimationType.Idle)
    self:playAnim("idle",CityPosition.Dir.Down)


      
end

function Monster:update()
    if self._mvTargets and #self._mvTargets > 0 then
        if self._state ==MonsterState.Moving then
            return
        end
        local tarCell = table.remove(self._mvTargets, 1)


            ---@type City.Position 朝向向量
            local moveVec = tarCell.position - self.cell.position
            self:setCell(tarCell, true) --先设置格子，防止移动过程寻路错误
            self:playAnim(HomePlayerAnim.Run, moveVec:toDir())
            self._state =MonsterState.Moving

            self._mvTween = self.transform:DOMove(tarCell:getRealPos(), 0.5)
                :SetEase(Ease.Linear):OnComplete(function ()
                  if #self._mvTargets ==1  then
                       self.movecompletefunc()  
                    end
                self._state =MonsterState.MoveDone
            end)
    elseif self._state ==MonsterState.MoveDone then
        self:playAnim(HomePlayerAnim.Idle)
        self._state =MonsterState.Idle
    end
end
--设置动画播放
function Monster:SetAnim(animation)
    self.pervAnimation = self.currAnimation
    self.currAnimation = animation
end

---尝试设置动画朝向
---@param dir City.PositionDir
function Monster:trySetAnimDir(dir)
    --判断是否空闲状态
    if self._state ~=MonsterState.Idle then
        return
    end

    self:playAnim(self._curAnim, dir)
end

function Monster:setSortingOrder(order)
    CityChar.setSortingOrder(self, order)
end

---@param cell City.MapCell
---@param notPos boolean 是否不改变位置
function Monster:setCell(cell, notPos)
    CityChar.setCell(self, cell, notPos)
end

---@param path City.MapCell[]
function Monster:move(path)
    self._mvTargets = path
end

---停止移动（非强制）
function Monster:moveStop()
    self._mvTargets = nil
end

---停止在格子上
---@param cell City.MapCell
function Monster:stopAtCell(cell)
    self:moveStop()
    if self._state ==MonsterState.Moving then
        if self._mvTween ~= nil then
            self._mvTween:Kill(true)
            self._mvTween = nil
        end
    end
    self:setCell(cell)
end

---瞬移
---@param cell City.MapCell
function Monster:blink(cell)
    self._mvTargets = { cell }
    self._isBlink = true
end

---设置翻转（角色朝向）
function Monster:flip(isFlip)
    isFlip = isFlip or false
    if isFlip == self._isFlip then
        return
    end
    self.animationSke.ScaleX = isFlip and -self._initScaleX or self._initScaleX
    self._isFlip = isFlip
end

function Monster:isFlip()
    return self._isFlip
end

--播放动画（0通道，强制播放，不循环）
---@param name string|SkeletonAnimation 动画名
---@param loop boolean 是否循环（默认false）

---播放动画和朝向
---@param anim HomeCharAnim 动画
---@param dir Home.PositionDir
function Monster:playAnim(anim, dir,loop,callCBFun)
    dir = dir or self._curDir
    loop = loop or true
    --相同动画和朝向不重复播放
    if self._curAnim == anim and self._curDir == dir then
        return
    end 
  
    local name, isFlip = self:_getAnimNameAndFlip(anim, dir)
    if name ~= self.animation.AnimationName then
        local entry = self.animation.state:SetAnimation(0, name, loop)
        if callCBFun ~= nil then
            entry:AddOnComplete(callCBFun)
        end
    end
    self.animation.skeleton.ScaleX = isFlip and -1 or 1

    self._curAnim = anim
    self._curDir = dir
end


---@private
---@param anim HomeCharAnim 动画
---@param dir Home.PositionDir 朝向
---@return string, boolean 动画名，是否翻转
function Monster:_getAnimNameAndFlip(anim, dir)

    --判断是否需要翻转（上下翻转为左右）
    local isFlip = dir == CityPosition.Dir.Up or dir == CityPosition.Dir.Down

    local animName =anim-- nil

--    --上和左的动作朝后
    if dir == CityPosition.Dir.Up
            or dir == CityPosition.Dir.Left then
        animName = animName .. "_back"

    end

    return animName, isFlip
end

function Monster:mMoveTo(x, y, radio,completefunc)
  
    local mapCtrl = CityModule.getMapCtrl()
    local goal = mapCtrl:getCellByXY(x,y)
     self:setTargetCell(goal)
    self._mvTargets = {}
    local path = mapCtrl:findPath(self.cell, self.cellTarget)--self.cell
    if path == nil then
        --UIUtil.showText('无法到达目标点')
        self:SetAnim(AnimationType.Idle)  
        self.movetype=0
        self.isMoveRunning = false
        return
    end

    self.movecompletefunc = completefunc
    self:move(path) --移动

end

return Monster