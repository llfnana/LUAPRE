---@class UIGashaponPanel : UIPanelBase
local Panel = UIPanelBaseMake()
UIGashaponPanel = Panel
local this = Panel

local UIGashaponItem = require("Module/Gashapon/View/UIGashaponItem")
local UIShowcaseItem = require("Module/Gashapon/View/UIShowcaseItem")
local FactoryGameDefine = require("Module/Gashapon/FactoryGameDefine")
local LampType = FactoryGameDefine.LampType ---@type GashaponLampType
local GridType = FactoryGameDefine.GridType ---@type GashaponGridType

-- region 跑马灯变量

local turntable_items = {}  -- 转盘的items
local outer_item_count = 20 -- 外圈item数量
local inner_item_count = 4  -- 内圈item数量
local all_item_count = 24   -- 所有item的数量

-- Note 移除跑马灯 通过turntable_items remove 不能使用stop_pos == cur_pos
local isWaitNextTrigger = false    -- 等待触发下一次

local isPoolActive = false         -- 池子是否存活
local isPoolPause = false          -- 是否暂停跑马灯
local isWaitEffect = false         -- 是否等待特效播放完成
local lamp_pool = {}               -- 跑马灯的池子

local draw_result_list = {}        -- 抽取结果列表 下发的是格子坐标
local draw_result_count = 0        -- 跑马灯的数量
local draw_electricity_map = {}    -- 抽到电池的列表
local electricity_effect_pool = {} -- 电池表现的特效池

local timer_recorder = {}          -- 记录计时器

local luckySize = 150              ---幸运瓶实际大小
local luckOffset = -45             ---幸运瓶特效偏移量
-- endregion

-- region 橱窗
local showcase_items = {}

-- endregion
function Panel.OnAwake()
    this.GenerateGoods()
    this.GenerateTurntable()

    this.InitEvent()

    this.inDraw = false

    this.leftPosition = this.goleft.transform.position
    -- 通用关闭按钮
    this.LoadBtnClose("left", this.HideUI)
end

function Panel.OnShow()
    UpdateBeat:Add(this.Tick, this)

    this.AddEventListener(EventDefine.OnDrawSuccess, this.OnDrawSuccess)
    -- this.AddEventListener(EventDefine.OnGashaponUpdate, this.RefreshLuck)
    -- this.AddEventListener(EventDefine.OnGashaponUpdate, this.RefreshDrawOne)
    -- this.AddEventListener(EventDefine.OnBlinkBoxExchange, this.UpdateToken)

    this.ClearTurntable()
    this.RefreshView()
    this.animUIGashapon:Rewind()
    this.animUIGashapon:Play()
    -- this.HorseRaceLamp(LampType.Outer, 0)
    ----------本地化-------------
    this.rectText.text = GetLang("UI_lottery_picture")
    --------------进入放动画----------------
    this.ShowIdleAnimation()
    this.HideShowEffect()

    this.AddEventListener(EventDefine.OnItemChange, function(id)
        if id == EItem.GoldToken or id == EItem.SilverToken then
            this.UpdateToken()
        end
    end)
end

function Panel.ShowIdleAnimation()
    local curindex = 0
    local _callback = function()
        local item = turntable_items[curindex + 1]
        item:OnMove({
            type = LampType.BeginAni
        }, curindex)
        curindex = (curindex + 1) % outer_item_count
    end
    this.show = TimeModule.addRepeat(0.15, _callback)
end

function Panel.HideShowEffect()
    for i, v in ipairs(turntable_items) do
        v:ShowClick(false)
    end
end

-- 跑马灯的一次滴答
-- 1.从某个位置出来,所以当前tick就是该次的表现
-- 2.清理无效的跑马灯
-- 3.做一次移动逻辑
local timer = 0
function Panel.Tick(owner, deltaTime, _)
    -- 池子未激活或者暂停了，直接返回
    if not isPoolActive or isPoolPause then
        return
    end

    if isWaitEffect then
        this.DoInInnerEffect()
        return
    end

    timer = timer + deltaTime
    if timer < 0.02 then
        return
    end

    timer = 0
    this.DoMoveEffect()
    this.DoClear()
    this.DoMove()

    if isPoolActive == false and isPoolPause == false then
        this.OnDrawComplete()
    end
end

function Panel.OnHide()
    if isPoolActive then
        return
    end
    SafeSetActive(this.btn_one_effect.gameObject, false)
    UpdateBeat:Remove(this.Tick, this)
    TimeModule.removeTimer(this.show)
    this.show = nil
    if this.iconPool then
        this.iconPool:clear()
    end
    this.iconPool = nil
    Event.Brocast(EventDefine.OnStageTriggerComplete)
    this.ClearTurntable()

    this.base.OnHide()
end

function Panel.OnDestroy()
    this.BaseCall('OnDestroy')
    turntable_items = {}
    showcase_items = {}
    electricity_effect_pool = {}
    this.btn_one:RemoveAllListeners()
    -- this.btn_multi:RemoveAllListeners()
    this.btn_illustrated:RemoveAllListeners()
end

-- 初始化面板--
function Panel.RefreshView()
    this.RefreshExchangeView()
    this.RefreshTurntableView()

    this.RefreshDrawOne()
    this.RefreshLuck()
end

function Panel.InitEvent()
    this.btn_one:AddListener(this.OneDraw)
    -- this.btn_multi:AddListener(this.MultiDraw)
    this.btn_illustrated:AddListener(this.OnIllustratedBtnClick)
end

-- 单抽
function Panel.OneDraw()
    -- this.DoInInnerEffect()
    if isPoolActive or isPoolPause then
        return
    end
    local isFree = GashaponModule.isFree()
    local times = 1
    if not isFree then
        return
    end
    this.HideBtn(true)
    TimeModule.removeTimer(this.show)
    this.show = nil
    Audio.PlayAudio(213)
    this.ClearTurntable()
    this.HorseRaceLamp(LampType.Outer, 0)
    GashaponModule.c2s_Draw(times)
    this.inDraw = true
    SafeSetActive(this.btn_one_effect.gameObject, true)
    this.btn_one_effect:Play()
    -- GashaponModule.PlayTest()
end

-- 5连抽
function Panel.MultiDraw()
    if isPoolActive or isPoolPause then
        return
    end
    TimeModule.removeTimer(this.show)
    this.show = nil
    local times = 5
    if not this.IsDiamondEnough(times) then
        UIUtil.showText("道具不足")
        return
    end
    Audio.PlayAudio(213)
    this.ClearTurntable()

    this.HorseRaceLamp(LampType.Outer, 0)  -- 左上角
    this.HorseRaceLamp(LampType.Outer, 5)  -- 右上角
    this.HorseRaceLamp(LampType.Outer, 10) -- 右下角
    GashaponModule.c2s_Draw(times)
    this.inDraw = true
end

function Panel.HideBtn(hide)
    local offset = hide and this.leftPosition + Vector3(-10, 0, 0) or this.leftPosition
    this.goleft.transform:DOMove(offset, 1)
end

function Panel.IsDiamondEnough(times)
    local diamond = EItem.Diamond
    local one = TbGashaponConfig[7].Param -- 单次数量
    return UIUtil.checkGetItem(diamond, one * times)
end

-- 打开图鉴界面
function Panel.OnIllustratedBtnClick()
    ShowUI(UINames.UIBlindBoxIllustrated)
end

---region 协议消息处理

---@param pos_list table 命中的格子id
function Panel.OnDrawSuccess(pos_list, electricities, items)
    draw_result_list = pos_list
    draw_result_count = #pos_list
    draw_electricity_map = electricities
    this.reward_items = items
    this.SetStopPos()
end

---endregion

---region 橱窗
-- 生成橱窗的商品
function Panel.GenerateGoods()
    for i = 1, #TbGashaponShowcase do
        local go = GOInstantiate(this.UIShowcaseItem, this.rectContent)
        local item = UIShowcaseItem.new(this.behaviour, go)
        table.insert(showcase_items, item)
    end
end

-- 兑换橱窗
function Panel.RefreshExchangeView()
    -- item list
    for i, item in ipairs(showcase_items) do
        item:Init(TbGashaponShowcase[i])
    end
    this.list_showcase.verticalNormalizedPosition = 0
    this.UpdateToken()
end

function Panel.UpdateToken()
    if this.inDraw then
        return
    end
    this.txt_res1.text = BagModule.getItemNum(EItem.GoldToken)
    this.txt_res2.text = BagModule.getItemNum(EItem.SilverToken)
end

---endregion

-- region  转盘

function Panel.RefreshTurntableView()
    for i, v in ipairs(turntable_items) do
        v:Init(TbGashapon[i])
    end
end

function Panel.RefreshDrawOne()
    local isFree = GashaponModule.isFree()
    SafeSetActive(this.gofree.gameObject, isFree)
    SafeSetActive(this.goover.gameObject, not isFree)
end

function Panel.RefreshLuck()
    local value = GashaponModule.getLuckValue()
    local maxValue = TbGashaponConfig[1].Param -- 幸运值满值
    this.txt_luck.text = string.format("%s/%s", value, maxValue)
    this.img_process.fillAmount = value / maxValue
    local pos = this.effect_lucky.transform.anchoredPosition
    pos.y = (value / maxValue - 1) * luckySize + luckOffset
    this.effect_lucky.transform.anchoredPosition = pos
end

-- 生成扭蛋机转盘
function Panel.GenerateTurntable()
    local row, col = 6, 6
    local width, height = 495, 495
    local space = 7 -- 间距

    local half_size = 38.5
    local size = half_size * 2
    local x = -(half_size + space)
    local y = height - half_size

    this.item_pos = 0
    for i = 1, row do
        x = x + size + space
        this.GenerateTurntableItem(x, y)
    end
    col = col - 1

    for i = 1, col do
        y = y - size - space
        this.GenerateTurntableItem(x, y)
    end
    row = row - 1

    for i = 1, row do
        x = x - size - space
        this.GenerateTurntableItem(x, y)
    end
    col = col - 1

    for i = 1, col do
        y = y + size + space
        this.GenerateTurntableItem(x, y)
    end
    row = row - 1

    for i = 0, this.rectInner.childCount - 1 do
        local go = this.rectInner:GetChild(i).gameObject
        local item = UIGashaponItem.new(this.behaviour, go, i)
        table.insert(turntable_items, item)
    end
end

-- 生成扭蛋机外圈转盘的item
function Panel.GenerateTurntableItem(x, y)
    local go = GOInstantiate(this.UIGashaponItem, this.rectOuter)
    go:SetAnchoredPositionEx(x, y);
    local item = UIGashaponItem.new(this.behaviour, go, this.item_pos)
    table.insert(turntable_items, item)
    this.item_pos = this.item_pos + 1
end

-- 从某个位置开启顺时针跑马灯
---@param lamp_type number 跑马灯类型
---@param start number 跑马灯起始位置  从0开始
function Panel.HorseRaceLamp(lamp_type, start)
    start = this.TranslateOuterPosition(start)
    isPoolActive = true
    -- Application.targetFrameRate = 20;
    -- 跑马灯数据
    ---@class lamp
    local lamp = {
        type = lamp_type,
        start_pos = start,
        cur_pos = start,
        stop_pos = nil, -- 这两个需要通过SetLampStopPos计算
        translate_stop = nil
    }

    table.insert(lamp_pool, lamp)
    return lamp
end

-- 轮盘清理
function Panel.ClearTurntable()
    this.reward_items = nil
    for _, v in ipairs(turntable_items) do
        v:Clear()
    end
    -- 计时器
    for _, v in ipairs(timer_recorder) do
        TimeModule.removeTimer(v)
    end
    timer_recorder = {}
    lamp_pool = {}
    isPoolPause = false
    isPoolActive = false
end

-- 设置停止坐标
function Panel.SetStopPos()
    local count = #lamp_pool

    if count == 0 then
        return
    end

    -- 只留一个跑马灯进行抽奖
    for i = count, 2, -1 do
        table.remove(lamp_pool, i)
    end
    ---@type LampData
    local target = table.remove(draw_result_list, 1)
    this.SetOuterLampStopPos(lamp_pool[1], target.stop)
end

---@param stop number 停止的格子坐标  0-20
function Panel.SetOuterLampStopPos(lamp, stop)
    -- 移动的数量 = 两个目标点的差 + 一圈的数量
    local translate_pos = this.TranslateOuterPosition(lamp.cur_pos)
    local move_pos = stop - translate_pos + outer_item_count * 3 -- 多转几圈
    lamp.stop_pos = lamp.cur_pos + move_pos
    lamp.translate_stop = this.TranslateOuterPosition(lamp.stop_pos),
        print("LH", "外圈当前->", lamp.cur_pos, "移动->", move_pos, "目标", stop)
end

function Panel.SetInnerLampStopPos(lamp, stop)
    -- 移动的数量 = 两个目标点的差 + 一圈的数量
    local translate_pos = this.TranslateInterPosition(lamp.cur_pos)
    local move_pos = stop - translate_pos + inner_item_count * 2 -- 多转几圈
    lamp.stop_pos = lamp.cur_pos + move_pos
    lamp.translate_stop = this.TranslateInterPosition(lamp.stop_pos) + outer_item_count,
        print("LH", "内圈当前->", lamp.cur_pos, "移动->", move_pos, "目标", stop)
end

-- 跑马灯做一次移动 逻辑
-- 已经到终点 跑马灯拖尾消逝
local move_times = 0
function Panel.DoMove()
    for _, lamp in ipairs(lamp_pool) do
        if lamp.type == LampType.Inner then
            -- 减缓内圈的节奏
            if move_times == 0 then
                if not lamp.stop_pos or lamp.stop_pos > lamp.cur_pos then
                    lamp.cur_pos = lamp.cur_pos + 1
                end
            end
        else
            if not lamp.stop_pos or lamp.stop_pos > lamp.cur_pos then
                lamp.cur_pos = lamp.cur_pos + 1
            end
        end
    end
    move_times = move_times + 1
    move_times = move_times % 4
end

-- 跑马灯做一次移动表现
-- 遍历pool的lamp items
function Panel.DoMoveEffect()
    for _, lamp in ipairs(lamp_pool) do
        local begin_index = 1
        local end_index = outer_item_count ---20个
        local translate_cur_pos = lamp.type == LampType.Inner and this.TranslateInterPosition(lamp.cur_pos) or
            this.TranslateOuterPosition(lamp.cur_pos)

        if lamp.type == LampType.Inner then ---如果是内圈
            begin_index = outer_item_count + 1
            end_index = all_item_count
        end

        for i = begin_index, end_index do
            local item = turntable_items[i]
            item:OnMove(lamp, translate_cur_pos)
            if i == lamp.translate_stop and lamp.cur_pos == lamp.stop_pos then
                local endItem = turntable_items[i + 1]
                if endItem.config.Type == GridType.Inner_Circle then
                    isWaitEffect = true
                end

                if endItem.config.ID == lamp.translate_stop + 1 then
                    endItem:OnReachStop()
                    this.DoStopEffect(endItem)
                end
            end
        end
    end
end

function Panel.DoStopEffect(target)
    if target.config.Type == GridType.Item then
        if this.iconPool == nil then
            this.iconPool = GoPoolMgr.createPool(this.item_icon)
        end
        local num = target.config.Params[2] or 1
        local effectNum = num > 5 and math.random(6, 10) or num
        local twSeq = DOTween.Sequence()
        local iconItems = {}
        for i = 1, effectNum do
            local go = this.iconPool:get()
            local icon = go:GetComponent("Image")
            SetImage(this.behaviour, icon, target.config.Res)
            table.insert(iconItems, go)

            go.transform.position = target.gameObject.transform.position
        end
        twSeq:AppendCallback(function()
            for i, v in ipairs(iconItems) do
                SafeSetActive(v.gameObject, true)
                local randV = math.random(0, 360)
                local randVec = UnityEngine.Quaternion.Euler(0, 0, randV) * Vector3.up
                local randOffset = math.random(4, 6)
                local position = randVec * 0.1 * randOffset + v.transform.position

                v.transform:DOMove(position, 0.2)
                    :SetEase(Ease.OutQuad):OnComplete(function()
                    local icon = v:GetComponent("Image")
                    icon:DOFade(0, 1):SetEase(Ease.Linear):OnComplete(function()
                        this.iconPool:free(v)
                    end)
                end)
            end
        end)
    end
end

function Panel.DoInInnerEffect()
    isPoolPause = true -- 进入内圈效果 暂停跑马灯池子
    isWaitEffect = false
    local target
    for i, v in ipairs(turntable_items) do
        if v.config.Type == GridType.Inner_Circle then
            target = v.gameObject
            break
        end
    end
    if target then
        ---箭头指向
        this.effect_arrow.transform.position = target.transform.position
        local direction = target.transform.position - this.img_process.transform.position;
        local rotation = 90 - Mathf.Atan2(direction.y, direction.x) * Mathf.Rad2Deg
        this.effect_arrow.transform.rotation = Quaternion.Euler(Vector3(0, 0, rotation))

        ---箭头移动
        this.effect_arrow:SetActive(true)
        this.effect_arrow:Play()
        this.effect_arrow.transform:DOMove(this.img_process.transform.position, 0.5):SetEase(Ease.Linear):OnComplete(function()
            this.effect_arrow:SetActive(false)
            ---内圈爆炸
            SafeSetActive(this.effect_inner.gameObject, true)
            this.effect_inner:Play()
            isPoolPause = false
        end)
    end
end

-- 清理
function Panel.DoClear()
    isPoolActive = false
    for i = #lamp_pool, 1, -1 do
        if lamp_pool[i].cur_pos == lamp_pool[i].stop_pos then
            this.CheckEvent(lamp_pool[i].translate_stop)
            table.remove(lamp_pool, i)
        else
            isPoolActive = true
        end
    end

    if isWaitNextTrigger then
        isPoolActive = true
    end
end

-- 检测跑马灯事件触发
-- 如果触发事件  isPoolActive = true
-- [0,1,0,1]
---@param last_stop number 上一个停留的格子
function Panel.CheckEvent(last_stop)
    -- 触发下一次 isWaitTrigger
    if not isWaitNextTrigger and #draw_result_list > 0 then
        isWaitNextTrigger = true
        this.DoNext(last_stop)
    end

    -- 电池效果
    -- local lamp_index = draw_result_count - #draw_result_list -- 当前的跑马灯索引 总的-剩余
    -- local lightning_list = draw_electricity_map[lamp_index]
    -- if lightning_list then
    --     isPoolPause = true -- 播放电池的 暂停跑马灯池子
    --     this.spawn_count = 0
    --     for _, electricity in ipairs(lightning_list) do
    --         this.PlayLightning(electricity.start, electricity, 0)
    --     end
    -- end
end

-- 执行下一个跑马灯
function Panel.DoNext()
    this.AddDelay(0.1, function()
        ---@type LampData
        local data = table.remove(draw_result_list, 1)
        local lamp = this.HorseRaceLamp(data.type, data.start)
        if data.type == LampType.Inner then
            this.SetInnerLampStopPos(lamp, data.stop)
        else
            this.SetOuterLampStopPos(lamp, data.stop)
        end

        isWaitNextTrigger = false
    end)
end

-- 抽卡结束
function Panel.OnDrawComplete()
    this.AddDelay(0.5, function()
        this.HideBtn(false)
        -- BagModule.playMsgItems(function()
        --     this.ShowIdleAnimation()
        -- end)
        BagModule.playMsgItems()

        this.inDraw = false
        this.UpdateToken() -- 抽奖结束,才能更改货币
        this.ClearTurntable()
    end)
end

-- 轮盘坐标转换
function Panel.TranslateOuterPosition(pos)
    if pos then
        return pos % outer_item_count
    end
end

function Panel.TranslateInterPosition(pos)
    if pos then
        return pos % inner_item_count
    end
end

-----------------电池表现---------------------------
---@param parent number 电池的触发点格子坐标
---@param childes table 触发的电池树
function Panel.PlayLightning(parent, childes, delay)
    local parent_item = turntable_items[parent + 1]
    local origin = parent_item.gameObject:GetPosition()
    ---电池特效表现
    local effectDelay = 0
    if parent_item.config.Type == GridType.Electricity then
        effectDelay = parent_item:ShowElectricityEffect()
    end

    if childes then
        for i, child in ipairs(childes) do
            local child_item = turntable_items[child.position + 1]
            local target = child_item.gameObject:GetPosition()
            local distance = (origin.x - target.x) * (origin.x - target.x) + (origin.y - target.y) *
                (origin.y - target.y)
            local duration = distance * 0.02
            this.spawn_count = this.spawn_count + 1

            this.AddDelay(delay + effectDelay + i * 0.1, function()
                local effect = this.GetOrCreateEffect(origin)
                effect.transform:DOMove(target, duration):SetEase(Ease.Linear):OnComplete(function()
                    this.PlayLightning(child.position, child.electricities, 0)

                    if child_item.config.Type == GridType.Inner_Circle then
                        isWaitEffect = true
                    end
                    child_item:OnElectricity()
                    this.DoStopEffect(child_item)
                    TimeModule.addDelay(0.15, function()
                        effect:SetActive(false)
                        table.insert(electricity_effect_pool, effect)
                    end)
                    this.spawn_count = this.spawn_count - 1
                    if this.spawn_count == 0 then
                        isPoolPause = false

                        if isPoolActive == false then
                            this.OnDrawComplete()
                        end
                    end
                end)
            end)
        end
    end
end

-- 获取电池的特效
function Panel.GetOrCreateEffect(pos)
    local cacheCount = #electricity_effect_pool
    local go

    if cacheCount > 0 then
        go = table.remove(electricity_effect_pool) -- 从末尾删
    else
        go = GOInstantiate(this.fx, this.gameObject.transform)
    end

    go:SetActive(true)
    go.transform:SetPosition(pos)
    return go
end

function Panel.AddDelay(delay, action)
    local tId = TimeModule.addDelay(delay, action)
    table.insert(timer_recorder, tId)
end

-- endregion
