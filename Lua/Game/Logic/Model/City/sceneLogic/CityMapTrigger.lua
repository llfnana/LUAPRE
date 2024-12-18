------------------------------------------------------------------------
--- @desc 关卡地图触发器
--- @author chenyl
------------------------------------------------------------------------

--region -------------引入模块-------------

--endregion

---@class City.MapTrigger 地图触发器
local Trigger = class('CityMapTrigger', CityMapItem)

function Trigger:ctor(tid)
    CityMapItem.ctor(self, tid)

    self._groundBgSr = nil
    self._groundItemSr = nil

    self.effects = {} --特效列表

    self.paramX = nil;
    self.paramY = nil;

    self.cell = nil ---@type City.MapCell 触发格
end

function Trigger:bind(go)
    CityMapItem.bind(self, go)

    self._groundBgSr = self.transform:Find("Ground"):GetComponent(typeof(SpriteRenderer))
    self._groundItemSr = self.transform:Find("Ground/Item"):GetComponent(typeof(SpriteRenderer))

    --赋值名称
    go.name = string.format("Trigger_%s_%s", self.type, self.tid)

    local tbItem = TbCityItem[self.tid]
    --物品和资源使用地贴
    if self:isGround() then
        if tbItem.ResGround == nil then
            return
        end
        Utils.SetIcon(self._groundBgSr, tbItem.ResGround[1])
        Utils.SetIcon(self._groundItemSr, tbItem.ResGround[2])
    end
end

function Trigger:init()
    -- self:initItem()
    self:initEvent()
end

-- 刷新Buff建筑样式
function Trigger:refreshBuildingStyle()
    -- 建筑需要根据等级初始化样式
    local buildInfo = CityModule.getBuffBuildingInfos(self.position.x, self.position.y)
    if not buildInfo then
        return
    end
    if buildInfo.level == 0 then
        -- 施工状态
        if not self.constructionSp then
            ResInterface.SyncLoadCommon("building_0_jsdk1_SkeletonData.asset", function (dataAsset)
                -- 骨骼加载成功
                local go = GameObject("construction")
                go.transform:SetParent(self.transform)
                self.constructionSp = go:AddComponent(typeof(SkeletonAnimation))
                self.constructionSp.skeletonDataAsset = dataAsset
                self.constructionSp:Initialize(true)
                self.constructionSp.transform.localPosition = Vector3(0, 0, 0)
                local meshRenderer = go:GetComponent(typeof(MeshRenderer))
                meshRenderer.sortingLayerName = "Building"
            end)
        end
        -- self.constructionSp.state:SetAnimation(0, "idle", true)
    end
    if self.constructionSp then
        self.constructionSp.transform.gameObject:SetActive(buildInfo.level == 0)
    end
    self._animation.transform.gameObject:SetActive(not (buildInfo.level == 0))

    local cell = self.cell
    if cell.transform.position.x < self.transform.position.x and  cell.transform.position.y < self.transform.position.y then
        self._animation.skeleton.ScaleX = -1
    end
    self:playAnim("idle" .. buildInfo.level, true)
end

function Trigger:initEvent()
    -- 触发器点击事件
    Util.SetEvent(self.gameObject, function (data)
        local triggerCell = self.cell
        local openBubble = true
        local callback = nil
        if CityModule.getMainCtrl().player.cell == triggerCell then
            if self.type == CityItemType.BuffBuilding or self.type == CityItemType.JumpTo then
                openBubble = false   
                if CityModule.getMainCtrl().stateMachine:getState().key == CityState.Idle then
                    -- 状态机 当前状态为Idle时，才能执行触发器
                    callback = function ()
                        self:doTrigger()
                    end
                end
            end
        end
        Event.Brocast(EventDefine.OnCityTriggerClick, openBubble, self.position, callback)
    end, "onClick")
    -- 拖拽事件做一个穿透处理
    Util.SetEvent(self.gameObject, function (data)
        Util.PassDragEvent(self.gameObject, data) --事件渗透
    end, Define.EventType.OnDrag)
end

-- 关卡buff建筑升级
function Trigger:upgradeBuilding()
    if not ResInterface.IsExist("5001_SkeletonData.asset") then
        self:refreshBuildingStyle()
        return
    end
    ResInterface.SyncLoadCommon("5001_SkeletonData.asset", function (dataAsset)
        -- 骨骼加载成功
        local go = GameObject("box")
        go.transform:SetParent(self.transform)
        self.buildBoxAni = go:AddComponent(typeof(SkeletonAnimation))
        self.buildBoxAni.skeletonDataAsset = dataAsset
        self.buildBoxAni:Initialize(true)
        self.buildBoxAni.transform.localPosition = Vector3(0, 0, 0)
        local meshRenderer = go:GetComponent(typeof(MeshRenderer))
        meshRenderer.sortingLayerName = "Building"
        meshRenderer.sortingOrder = self.cell:getSortingOrder()

        if self.constructionSp then
            Util.TweenTo(1, 0, 0.4, function (value)
                self.constructionSp.skeleton.A = value
            end)
        end
        self:playAnimOfSp(self.buildBoxAni, "idle", false, function ()
            self:refreshBuildingStyle()
        end)
    end)
end

---是否是地贴（资源或道具）
function Trigger:isGround()
    -- return self.type  == CityItemType.Item
    --         or self.type == CityItemType.Resource
end

function Trigger:setParams(info)
    self.paramX = info.paramX
    self.paramY = info.paramY
end
function Trigger:getParamsXy()
    return self.paramX, self.paramY
end

function Trigger:setSortingOrder(order)
    --self.spriteRenderer.sortingOrder = order

    if self:isGround() then
        self._groundBgSr.sortingOrder = order + 1
        self._groundItemSr.sortingOrder = order + 2
    end
end

function Trigger:doTrigger()
    local tbItem = TbCityItem[self.tid]
    ---触发器触发的时候将触发器透明度设置为0.2
    if self:isTriCellSame() then
        self:setOpacity(0.35)
    end

    if self.type == CityItemType.Item then --获得道具
        -- CityModule.addItem()
    elseif self.type == CityItemType.Fight then --战斗
        self:_doTriggerFight()
    elseif self.type == CityItemType.JumpTo then --跳转
        self:playEffect("E_ui_gk_jihuo", function (go)
            Util.SetRendererLayer(go, "Building", 20)
            go:SetActive(true)
            TimeModule.addDelay(1, function ()
                go:SetActive(false)
                JumpUtil.JumpTo(tbItem.Content[1].Array[1])
                -- if tbItem.Content[1].Array[1] == 3 then
                --     ShowUI(UINames.UICityStation)
                -- end
            end)
        end)
    elseif self.type == CityItemType.Boss then --BOSS
        ShowUI(UINames.UIBossInfo)
    elseif self.type == CityItemType.Slide then -- 滑道
        CityModule.getMainCtrl().player:slide(self.paramX, self.paramY)
    elseif self.type == CityItemType.God then -- 神灵
        self.transform:DOScale(0, 0.3):OnComplete(function ()
            local rounds = TbCityGod[tbItem.Content[1].Array[1]].Rounds
            CityModule.getMainCtrl():addGod(tbItem.Content[1].Array[1], rounds)
            CityModule.switchCityState(CityState.Move)
        end)
    elseif self.type == CityItemType.TurnTo then -- 转向器
        CityModule.getMainCtrl().player:forking()
    elseif self.type == CityItemType.Portal then -- 管道传送
        local function callback()
            CityModule.getMainCtrl().player:executeCell()
        end
        CityModule.getMainCtrl().player:portal(self.paramX, self.paramY, callback)
    elseif self.type == CityItemType.EggMachine then -- 扭蛋机
        self:playEffect("E_ui_gk_jihuo", function (go)
            Util.SetRendererLayer(go, "Building", 20)
            go:SetActive(true)
            TimeModule.addDelay(1, function ()
                go:SetActive(false)
                PlayerModule.c2sRequestEggData(function ()
                    PlayerModule.showUIPlayerLotteryDraw()
                end)
                -- ShowUI(UINames.UICityEgg, { tid = self.tid })
            end)
        end)
    elseif self.type == CityItemType.BuffBuilding then -- Buff建筑
        ShowUI(UINames.UICityBuildingDetail, self.cell)
    elseif self.type == CityItemType.Prickle then -- 地刺
        CityModule.getMainCtrl():changePlayNum(-1)
    elseif self.type == CityItemType.Bomb then -- 炸弹
        self:playEffect("E_ui_gk_zhadan", function (go)
            Util.SetRendererLayer(go, "Building", 20)
            go:SetActive(true)
            TimeModule.addDelay(2, function ()
                go:SetActive(false)
                CityModule.getMainCtrl():changePlayNum(-1)
            end)
        end)
    elseif self.type == CityItemType.Bkb then -- 免疫状态
        CityModule.getMainCtrl().player:immune()
    elseif self.type == CityItemType.WorldBoss then -- 世界boss
        ShowUI(UINames.UIWorldBoss)
    end

    if not self.stopMove then
        Event.Brocast(EventDefine.OnCityTriggerComplete)
    end
end

---@private
---触发战斗
function Trigger:_doTriggerFight()
    CityModule.c2sGetTriggerInfo(function (vo)
        ---@type SvrCityFightVo
        local fightVo = ListUtil.getByPath(vo, "a.stage.fight")
        if fightVo.openbox == 1 then
            ShowUI(UINames.UICityFightBox, fightVo)
        else --不能开宝箱，进入战斗
            local id = 1 ---TODO获取当前关卡战斗ID
            local lineup = {} ---@type EnemyLineupData[]
            local config = TbCityFight[id]
            for _, v in ipairs(config.Monsters) do
                local enemyLineupData = {
                    loc = v.Value1,
                    tid = v.Value2,
                    lv = v.Value3,
                    power = config.Power,
                }
                table.insert(lineup, enemyLineupData)
            end
            ShowUI(UINames.UIFightDeploy, {
                enemyLineup = lineup,
                optional = { fightType = FightType.City }
            })
        end
    end)
end

function Trigger:execute()
    Event.Brocast(EventDefine.OnCityTriggerExecute, self.tid)
    local tbItem = TbCityItem[self.tid]

    -- 如果该触发器需要停止移动，等待触发器完成的话，就将当前的状态设置为触发器状态
    -- 反之，如果不需要停止移动，就将当前的状态保持不变（因为触发器逻辑在一瞬间完成，不占用帧长）
    if self:checkStopMove() then
        CityModule.switchCityState(CityState.Trigger)
    end

    -- 检查特效和动画，有些触发器需要特效动画播完才能启动
    self:checkEffAndAni(Handler(self, self.doTrigger))
    
    --是否触发隐藏（地贴 or 战斗格）
    if self:isGround()
            or self.type == CityItemType.Fight then
        self:doHide()
    end

    --地贴播放气泡特效
    if self:isGround() then
        ResInterface.SyncLoadGameObject('E_qipao_all', function (obj)
            local _efGo = GOInstantiate(obj) --, self.transform)
            _efGo.transform.position = self.transform.position

            local _efAnimTr = _efGo.transform:Find("eff/qipao_anim")
            local _efAnimator = _efAnimTr:GetComponent(typeof(Animator))

            local _itemIcon = _efAnimTr:Find("qipao_daoju/icon")
            local _itemSr = _itemIcon:GetComponent(typeof(SpriteRenderer))

            ResInterface.AsyncSetSpritePng(tbItem.Res, _itemSr)

            Util.SetRendererLayer(_efGo, "Building", 10)
            --播放动画
            _efAnimator:Play("qipao_die_anim")
            TimeModule.addDelay(2, function ()
                _efGo:SetActive(false) --气泡特效隐藏

                --self:doHide()
            end)
        end)
    end

    -- Event.Brocast(EventDefine.OnCityTriggerExecute, self.tid)

    -- local function movePlayerNext()
    --     CityModule.getMainCtrl().player:move()
    -- end

    -- local stateMachine = CityModule.getMainCtrl().stateMachine
    -- --检查当前触发器类型，是否中断移动逻辑
    -- if self:checkStopMove() then
    --     CityModule.getMainCtrl().stateMachine:setState(CityState.Trigger)
    -- elseif stateMachine:getState().key ~= CityState.Trigger then
    --     movePlayerNext()
    -- end
end

---执行触发器触发失败
function Trigger:executeFail()
    -- if self:checkStopMove() then
    --     CityModule.switchCityState(CityState.Trigger)
    -- end
    Event.Brocast(EventDefine.OnCityTriggerComplete)
    local failedGo = self.transform:Find("Failed")
    local seq = DOTween.Sequence()
    seq:AppendCallback(function ()
        failedGo.gameObject:SetActive(true)
    end)
    seq:AppendInterval(0.5)
    seq:AppendCallback(function ()
        failedGo.gameObject:SetActive(false)
    end)
end

function Trigger:playEffect(effName, callback)
    if self.effects[effName] ~= nil then
        callback(self.effects[effName])
        return
    end
    ResInterface.SyncLoadGameObject(effName, function (obj)
        self.effects[effName] = GOInstantiate(obj, self.transform)
        self.effects[effName].transform.localPosition = Vector3.zero
        callback(self.effects[effName])
    end)
end

function Trigger:checkEffAndAni(callback)
    local tbItem = TbCityItem[self.tid]
    --播放触发特效
    local _efRunGo = nil
    if StringUtil.notEmpty(tbItem.ResEfRun) then
        ResInterface.SyncLoadGameObject(tbItem.ResEfRun, function (obj)
            local _efGo = GOInstantiate(obj, self.transform)

            Util.SetRendererLayer(_efGo, "Building", 10)
            
            _efRunGo = _efGo
            _efRunGo:SetActive(true)
        end)
    end
    --隐藏呼吸特效
    if self._efIdleGo ~= nil then
        self._efIdleGo:SetActive(false)
    end

    --播放触发动作（可能没有）
    self:playAnim("run", false, function ()
        --显示呼吸特效
        if self._efIdleGo ~= nil then
            self._efIdleGo:SetActive(true)
        end
        --隐藏触发特效
        if _efRunGo ~= nil then
            _efRunGo:SetActive(false)
        end

        self:playAnim("idle", true) --切回待机动作

        if callback then
            callback()
        end
    end)
end

---检查是否需要停止移动
function Trigger:checkStopMove()
    -- 需要停止的列表
    -- type为需要停止移动的类型，tidList如果存在，则只对tid在tidList中存在的触发事件做停止移动
    local StateList = {
        {type = CityItemType.Fight},
        {type = CityItemType.Portal},
        {type = CityItemType.TurnTo},
        {type = CityItemType.Boss},
        {type = CityItemType.Slide},
        {type = CityItemType.God},
    }

    for k, v in pairs(StateList) do
        if v.type == self.type then
            if v.tidList then
                for _k, _v in pairs(v.tidList) do
                    return _v == self.tid
                end
            else
                return true
            end 
        end
    end
    return false
end

---获取该触发器在格子上的站立点偏移
function Trigger:getStandOffset()
    if self.type == CityItemType.Portal then
        return Vector3.New(0, 0.5, 0)
    end
    return Vector3.zero
end

---获取该触发器的正负面
function Trigger:getFab()
    return TbCityItem[self.tid].Fab == 1
end

---获取该触发器是否可以被免疫状态触发
function Trigger:getIsTriggerByImmune()
    return TbCityItem[self.tid].Bkb == 1
end

---该触发器的坐标是否和触发格子的坐标相同
---@return boolean 是否相同
function Trigger:isTriCellSame()
    return self.position.x == self.cell.position.x and self.position.y == self.cell.position.y
end

---设置触发器透明度
function Trigger:setOpacity(value)
    if self._animation and self._animation.skeleton then
        self._animation.skeleton.A = value
    end
end

---处理隐藏逻辑
function Trigger:doHide()
    --//Cell.Trigger = null;
    --//Destroy(gameObject);
    self.gameObject:SetActive(false)
end

---恢复显示（角色移开触发器后）
function Trigger:resume()
    self.gameObject:SetActive(true)
end

return Trigger