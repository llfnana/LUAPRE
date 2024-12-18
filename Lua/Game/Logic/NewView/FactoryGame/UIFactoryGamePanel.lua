---@class UIFactoryGamePanel : UIPanelBase
local Panel = UIPanelBaseMake()
local this = Panel
UIFactoryGamePanel = Panel
local UIFactoryGameItem = require("Game/Logic/NewView/FactoryGame/UIFactoryGameItem")
local FactoryGameDefine = require("Game/Logic/NewView/FactoryGame/FactoryGameDefine")
local LampType = FactoryGameDefine.LampType ---@type GashaponLampType
local GridType = FactoryGameDefine.GridType ---@type GashaponGridType
local turntable_items = {}  -- 转盘的items
local outer_item_count = 12 -- 外圈item数量
local inner_item_count = 0  -- 内圈item数量
local all_item_count = 12   -- 所有item的数量

local isWaitNextTrigger = false    -- 等待触发下一次

local isPoolActive = false         -- 池子是否存活
local isPoolPause = false          -- 是否暂停跑马灯
local isWaitEffect = false         -- 是否等待特效播放完成
local lamp_pool = {}               -- 跑马灯的池子

local draw_result_list = {}        -- 抽取结果列表 下发的是格子坐标
local draw_result_count = 0        -- 跑马灯的数量

local timer_recorder = {}          -- 记录计时器
local AddGameRewards = {}
local drawNum = 0

-- this.config = {}                   --游戏机数据
local cityId = 1

this.fillAmount = 0


function Panel.OnAwake()
    this.InitPanel()
    this.InitEvent()
    this.leftPosition = this.btnClose.transform.position
end

function Panel.InitPanel()
    this.uidata = {}
    this.uidata.top = SafeGetUIControl(this, "Top")
    this.uidata.bottom = SafeGetUIControl(this, "Bottom")
    this.uidata.main = SafeGetUIControl(this, "Main")        
    this.uidata.Gift = SafeGetUIControl(this, "Main/Gift")   --满级礼包
    this.uidata.Btn = SafeGetUIControl(this, "Main/Btn")     --抽奖按钮
    this.uidata.rectOuter = SafeGetUIControl(this, "Main/rectOuter") --转盘
    this.uidata.UIFactoryGameItem = SafeGetUIControl(this, "Main/UIFactoryGameItem") --转盘物品
    this.uidata.DrawBtnOne = SafeGetUIControl(this, "Main/Btn/Btn_2/Btn") --转盘
    this.uidata.Btn_com_bt_help = SafeGetUIControl(this, "Main/GameLevel/com_bt_help") --

    this.uidata.Top_Text = SafeGetUIControl(this, "Main/Top_Text", "Text") --标题
    this.uidata.GameLevel_Text = SafeGetUIControl(this, "Main/GameLevel/Text", "Text") --等级信息
    this.uidata.exp = SafeGetUIControl(this, "Main/yxj_img_line/exp", "Text") --经验
    this.uidata.img_line = SafeGetUIControl(this, "Main/yxj_img_line", "Image") --经验条
    this.uidata.Gift_Title = SafeGetUIControl(this, "Main/Gift/Top_Text_1", "Text") --礼包标题
    this.uidata.des_Text = SafeGetUIControl(this, "Main/Gift/des_Text", "Text") --礼包标题
    this.uidata.Gift = SafeGetUIControl(this, "Main/Gift") --礼包
    this.uidata.Btn_Gift = SafeGetUIControl(this, "Main/Gift/Btn") --礼包
    --------------按钮----------------
    this.uidata.Btn_AdvNum = SafeGetUIControl(this, "Main/Btn/Btn_1/com_img_title_b_1/Text_1", "Text") --广告按钮次数
    this.uidata.Btn_OneDrawNum = SafeGetUIControl(this, "Main/Btn/Btn_2/com_img_title_b_1/Text_1", "Text") --广告按钮次数
    this.uidata.Btn_MultiDrawNum = SafeGetUIControl(this, "Main/Btn/Btn_3/com_img_title_b_1/Text_1", "Text") --广告按钮次数
    this.uidata.Btn3_Text = SafeGetUIControl(this, "Main/Btn/Btn_3/Btn/Text_1", "Text") --多次抽奖
    --------------时间----------------
    this.uidata.text_time = SafeGetUIControl(this, "Main/Time/time_Text", "Text") --刷新时间
    this.uidata.time = SafeGetUIControl(this, "Main/Time") --刷新时间
    --------------特效----------------
    this.uidata.exp_up = SafeGetUIControl(this, "Main/yxj_img_line/exp_up", "SkeletonGraphic") --经验
    -- this.uidata.exp_top = SafeGetUIControl(this, "Main/yxj_img_line/exp_top", "SkeletonGraphic") --经验
    this.uidata.game_up = SafeGetUIControl(this, "Main/effect/game_up", "SkeletonGraphic") --整体升级
    this.uidata.Nun_up = SafeGetUIControl(this, "Main/effect/Nun_up", "SkeletonGraphic") --次数刷新
    this.uidata.Num_lz = SafeGetUIControl(this, "Main/effect/Num_lz", "SkeletonGraphic") --飞入例子
    this.uidata.exp_up_Node = SafeGetUIControl(this, "Main/yxj_img_line/exp_up")
    this.BtnList = {}
    for i = 1, this.uidata.Btn.transform.childCount do
        local go = this.uidata.Btn.transform:Find("Btn_" .. i).gameObject
        this.BtnList[i] = go
    end
    
    this.btnClose = this.BindUIControl("BtnClose", this.HideUI)
    this.btn_one = this.BindUIControl("Main/Btn/Btn_2/Btn", function ()
        this.OneDraw(0)
        -- if isPoolActive or isPoolPause then
        --     return
        -- end
        -- this.resItem = {
        --     [1] = Utils.FormatCount(DataManager.GetMaterialCount(cityId, "Coal" .. cityId)) ,
        --     [2] = this.Playerinfos.Hunger  or 0,
        --     [3] = Utils.FormatCount(DataManager.GetMaterialCount(cityId, ItemType.Gem)),
        --     [4] = this.Playerinfos.Rest or 0,
        -- }
        -- AddGameRewards = {}
        -- FactoryGameModule.c2s_GameMachine(9,function ()
        --     AddGameRewards = FactoryGameModule.AddGameRewards()
        -- end)
    end)
    this.btn_adv = this.BindUIControl("Main/Btn/Btn_1/Btn", function ()
        local watchCount, maxCount, remainCount = AdManager.GetCount(AdSourceType.UIOfflineReward)
        if this.config.adCnt == 0 then 
            ShowTips(GetLang("ad_day_limit_tip2"))
            return
        end
        if ShopManager.IsFreeAd() then
            this.OneDraw(1)
        else 
            AdManager.Show(function()
                this.OneDraw(1)
            end)
        end

        -- this.playLevelAni()
    end)
    this.btn_multi = this.BindUIControl("Main/Btn/Btn_3/Btn", function ()
        this.MultiDraw()
    end)
    this.btn_bt_help = this.BindUIControl("Main/GameLevel/com_bt_help", function ()
        ShowUI(UINames.UIFactoryGameAwd,this.config.level)
    end)

    this.uidata.Btn_Gift = this.BindUIControl("Main/Gift/Btn", function ()
        ShopManager.Buy(cityId, 400 + cityId - 3, function(reward, errCode)
                if errCode == 0 then
                    -- 购买成功
                    FactoryGameModule.c2s_getInfo(cityId, function ()
                        this.uidata.Gift:SetActive(false)
                        this.playLevelAni()
                    end)
                else
                    -- 购买失败
                    ShopManager.ShowErrCode(errCode)
                end
            end
        )
    end)
    this.btn_pos = {
        Gamecoins1 = this.btn_multi.transform.position,
        Gamecoins2 = this.btn_adv.transform.position,
    }
end

function Panel.InitEvent()
    -- this.AddListener(EventDefine.OnFactoryGameDraw, this.OnDrawSuccess)
    -- SafeAddClickEvent(this.behaviour, this.uidata.Button, function()
        
    -- end)
end

function Panel.OnShow()
    this.speeld = 0.01
    this.isOneDraw = true
    UpdateBeat:Add(this.Tick, this)
    this.GenerateTurntable()
    this.RefreshView()
    --------------进入放动画----------------
    -- this.ShowIdleAnimation()
    this.HideShowEffect()
    this.Update()  
    this.AddListener(EventDefine.OnFactoryGameDraw, this.OnDrawSuccess)
end

-- 初始化面板--
function Panel.RefreshView()
    this.InitData()
    this.isShowGift()
    this.RefreshTurntableView()
    this.RefreshLuck()
end

function Panel.playLevelAni()
    local data = ConfigManager.GetCasino(this.config.level)
    local Gamelevel = ConfigManager.GetCasinoAll()
    local Num_lz = SafeGetUIControl(this, "Main/effect/Num_lz") --飞入例子
    local oldNum_lz = Num_lz.transform.position 
    local img_ironblock = SafeGetUIControl(this, "Main/Btn/Btn_3/com_img_title_b_1/icon_item_ironblock") --广告按钮次数
    local img_ironblockPos = img_ironblock.transform.position + Vector3(0.1, 0, 0)
    local sequence = DOTween.Sequence()
    Num_lz:SetActive(false)
    this.uidata.exp_up_Node:SetActive(false)
    local endfillAmount = this.isLevlUp() and 1 or this.config.exp / data.exp
    if this.isLevlUp() then
        sequence:Append(Util.TweenTo(this.fillAmount, 1, 0.5, function(value)
            this.uidata.img_line.fillAmount = value
        end))
        sequence:AppendCallback(function()
            this.uidata.exp_up_Node:SetActive(true)
            this.uidata.exp_up.AnimationState:SetAnimation(0, "animation", false)
        end)
        sequence:AppendInterval(0.8)
        sequence:AppendCallback(function()
            this.uidata.img_line.fillAmount = 0
            this.uidata.game_up.AnimationState:SetAnimation(0, "animation", false)
        end)
        if this.config.exp / data.exp > 0 then
            sequence:Append(Util.TweenTo(this.fillAmount, this.config.exp / data.exp, 0.5, function(value)
                this.uidata.img_line.fillAmount = value
            end))
        end
        sequence:AppendInterval(1.3)
        sequence:AppendCallback(function()
            Num_lz:SetActive(true)
            this.uidata.Num_lz.AnimationState:SetAnimation(0, "animation", true)
        end)
        sequence:Join(Num_lz.transform:DOMove(img_ironblockPos, 0.5))
        sequence:AppendCallback(function()
            this.uidata.Nun_up.AnimationState:SetAnimation(0, "animation", false)
            Num_lz:SetActive(false)
            Num_lz.transform.position = oldNum_lz
        end)
    else
        if this.config.level >= #Gamelevel then
            this.uidata.img_line.fillAmount = 1
        else
            sequence:Append(Util.TweenTo(this.fillAmount, this.config.exp / data.exp, 0.5, function(value)
                this.uidata.img_line.fillAmount = value
            end))
        end
    end
    sequence:AppendCallback(function()
        this.HideShowEffect()
        this.inDraw = false
        isPoolPause = false
        isPoolActive = false
        -- this.UpdateToken() -- 抽奖结束,才能更改货币
        this.RefreshView()
        this.ClearTurntable()
        this.speeld = 0.01
        this.RefreshBtn(true)
        this.HideBtn(false)
    end)
end

function Panel.isLevlUp()
    return this.oldLevel < this.config.level and this.config.level ~= 1
end

function Panel.InitData()
    cityId = DataManager.GetCityId()
    this.config = FactoryGameModule.getUIFactoryGameInfo()
    this.oldLevel = this.config.level
    this.Playerinfos = CharacterManager.GetAttributeDebuffCount(cityId)
end

function Panel.RefreshLuck()
    
    local data = ConfigManager.GetCasino(this.config.level)
    local Gamelevel = ConfigManager.GetCasinoAll()
    local BtnNum = this.config.freeCnt >= 10 and 10 or this.config.freeCnt
    local AdvNumClorl = this.config.adCnt == 0 and "<color=#F42E29>" .. this.config.adCnt .. "</color>" or this.config.adCnt
    local freeCntClorl = this.config.freeCnt == 0 and "<color=#F42E29>" .. this.config.freeCnt .. "</color>" or this.config.freeCnt
    this.uidata.Top_Text.text = GetLang("ui_gamemachine_title") .. "(" .. GetLang(ConfigManager.GetCityById(cityId).city_name) .. ")"
    this.uidata.GameLevel_Text.text = GetLang("ui_gamemachine_level") .. "：" .. this.config.level .. "/" .. #Gamelevel  --等级信息
    this.uidata.exp.text = this.config.level >= #Gamelevel and "Max"or this.config.exp .. "/" .. data.exp --经验
    this.uidata.img_line.fillAmount = this.config.level >= #Gamelevel and 1 or this.config.exp / data.exp  --经验条
    this.uidata.Gift_Title.text = GetLang("ui_gamemachine_packname",GetLang(ConfigManager.GetCityById(cityId).city_name))  --礼包标题
    this.uidata.Btn_AdvNum.text = GetLang("ui_gamemachine_time") .. AdvNumClorl .. "/" .. data.times_max_ad  
    this.uidata.Btn_OneDrawNum.text = GetLang("ui_gamemachine_time") .. freeCntClorl .. "/" .. data.times_max
    this.uidata.Btn_MultiDrawNum.text = GetLang("ui_gamemachine_time") .. freeCntClorl .. "/" .. data.times_max
    this.uidata.Btn3_Text.text = GetLang("ui_gamemachine_button_go1",this.config.freeCnt > 0 and BtnNum or 10)
    this.fillAmount = this.config.exp / data.exp  --经验条
    local LevelList = ConfigManager.GetCasinoAll()
    local Timedata = ConfigManager.GetCasino(#LevelList)
    -- 娱乐城摆放位置
    local time_text = string.format("%0.2f",Timedata.frequency / 3600) .. "h"
    local num = this.getDrawNum()
    this.uidata.des_Text.text = GetLang("ui_gamemachine_packdec",num,time_text,1)
    local isShowBtn = this.config.freeCnt > data.times_max and this.config.adCnt > data.times_max_ad
    this.addTime()
end

function Panel.getDrawNum()
    local data = ConfigManager.GetCasinoAll()
    local num = 0
    for i = this.config.level, #data do
        local addNum = data[i] and data[i].rwd_times or 0
        num = num + addNum
    end
    return num
end

function Panel.isShowGift()
    local data = ConfigManager.GetCasinoAll()
    this.uidata.Gift:SetActive(this.config.level < #data)
end

function Panel.ShowIdleAnimation()
    local curindex = 0
    local _callback = function()
        local item = turntable_items[curindex + 1]
        -- item:setKuang()
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

function Panel.RefreshTurntableView()
    local level = this.config.level
    local list = ConfigManager.GetCasino_RwdConfig()  
    local config = list[level]
    for i, v in ipairs(turntable_items) do
        v:Init(config.rwd[i])
    end
end

-- 单抽
function Panel.OneDraw(isadv)
    -- this.DoInInnerEffect()
    if isPoolActive or isPoolPause then
        return
    end
    local isFree = 1
    local times = 1
    if not isFree then
        return
    end
    local num = isadv == 1 and this.config.adCnt or this.config.freeCnt
    if num == 0 then
        UIUtil.showText(GetLang("ui_gamemachine_tip_1"))
        return
    end
    TimeModule.removeTimer(this.show)
    this.show = nil
    this.isOneDraw = true
    this.HideBtn(true)
    this.RefreshBtn(false)
    AddGameRewards = {}
    this.resItem = {
        [1] = Utils.FormatCount(DataManager.GetMaterialCount(cityId, "Coal" .. cityId)) ,
        [2] = this.Playerinfos.Hunger  or 0,
        [3] = Utils.FormatCount(DataManager.GetMaterialCount(cityId, ItemType.Gem)),
        [4] = this.Playerinfos.Rest or 0,
    }
    FactoryGameModule.c2s_Draw(isadv,times,function ()
        AddGameRewards = FactoryGameModule.AddGameRewards()
    end)
end

-- 5连抽
function Panel.MultiDraw()
    if isPoolActive or isPoolPause then
        return
    end
    if this.config.freeCnt == 0 then
        UIUtil.showText(GetLang("ui_gamemachine_tip_1"))
        return
    end
    TimeModule.removeTimer(this.show)
    this.show = nil
    -- Audio.PlayAudio(213)
    this.isOneDraw = false
    this.HideBtn(true)
    this.RefreshBtn(false)
    AddGameRewards = {}
    this.resItem = {
        [1] = Utils.FormatCount(DataManager.GetMaterialCount(cityId, "Coal" .. cityId)) ,
        [2] = this.Playerinfos.Hunger  or 0,
        [3] = Utils.FormatCount(DataManager.GetMaterialCount(cityId, ItemType.Gem)),
        [4] = this.Playerinfos.Rest or 0,
    }
    FactoryGameModule.c2s_Draw(0,this.config.freeCnt > 10 and 10 or this.config.freeCnt,function ()
        AddGameRewards = FactoryGameModule.AddGameRewards()
    end)
end

function Panel.GenerateTurntable()
    local row, col = 4, 4
    local width, height = 590, 590
    local space = 15.2 -- 间距

    local half_size = 66
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
        y = y - size - (space + 2)
        this.GenerateTurntableItem(x, y)
    end
    row = row - 1

    for i = 1, row do
        x = x - size - space
        this.GenerateTurntableItem(x, y)
    end
    col = col - 1

    for i = 1, col do
        y = y + size + (space + 2)
        this.GenerateTurntableItem(x, y)
    end
    row = row - 1

    for i = 0, this.uidata.rectOuter.transform.childCount - 1 do
        local go = this.uidata.rectOuter.transform:GetChild(i).gameObject
        local item = UIFactoryGameItem.new()
        item:InitPanel(this.behaviour, go, i)
        table.insert(turntable_items, item)
    end
end

-- 生成转盘的item
function Panel.GenerateTurntableItem(x, y)
    local go = GOInstantiate(this.uidata.UIFactoryGameItem.transform ,this.uidata.rectOuter.transform)
    go:SetAnchoredPositionEx(x, y);
    local item = UIFactoryGameItem.new()
    item:InitPanel(this.behaviour, go, this.item_pos)
    table.insert(turntable_items, item)
    this.item_pos = this.item_pos + 1
end

-- 从某个位置开启顺时针跑马灯
---@param lamp_type number 跑马灯类型
---@param start number 跑马灯起始位置  从0开始
function Panel.HorseRaceLamp(lamp_type, start,id)
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
        translate_stop = nil,
        id = id
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
    -- local target = draw_result_list[1]
    this.SetOuterLampStopPos(lamp_pool[1], target.stop)
end

---@param stop number 停止的格子坐标  0-20
function Panel.SetOuterLampStopPos(lamp, stop)
    -- 移动的数量 = 两个目标点的差 + 一圈的数量
    local translate_pos = this.TranslateOuterPosition(lamp.cur_pos+1)
    local move_pos = stop - translate_pos + outer_item_count * 3  -- 多转几圈
    lamp.stop_pos = lamp.cur_pos + move_pos
    lamp.translate_stop = this.TranslateOuterPosition(lamp.stop_pos)
        -- print("LH", "外圈当前->", lamp.cur_pos, "移动->", move_pos, "目标", stop)
end

function Panel.SetInnerLampStopPos(lamp, stop)
    -- 移动的数量 = 两个目标点的差 + 一圈的数量
    local translate_pos = this.TranslateOuterPosition(lamp.cur_pos+1)
    local move_pos = stop - translate_pos + outer_item_count * 3  -- 多转几圈
    lamp.stop_pos = lamp.cur_pos + move_pos
    lamp.translate_stop = this.TranslateOuterPosition(lamp.stop_pos)
        -- print("LH", "外圈当前->", lamp.cur_pos, "移动->", move_pos, "目标", stop)
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
                if lamp.stop_pos - lamp.cur_pos < 10 and this.isOneDraw == true and lamp.id == 1 then
                    this.speeld = this.speeld + 0.01
                    -- print("this.speeld", this.speeld)
                else
                    this.speeld = 0.01
                end
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
        local end_index = outer_item_count ---12个
        local translate_cur_pos = lamp.type == LampType.Inner and this.TranslateInterPosition(lamp.cur_pos) or
            this.TranslateOuterPosition(lamp.cur_pos)
        local endItem = turntable_items[1]
        if lamp.type == LampType.Inner then ---如果是0个
            local item = turntable_items[i]
            item:OnMove(lamp, translate_cur_pos)
            endItem:OnReachStop()
        end
        
        for i = begin_index, end_index do
            local item = turntable_items[i]
            item:OnMove(lamp, translate_cur_pos)
            if i == lamp.translate_stop and lamp.cur_pos == lamp.stop_pos then
                endItem = turntable_items[i + 1]
                if endItem.config.order == lamp.translate_stop + 1 then
                    endItem:OnReachStop()
                end
            elseif endItem.config.order == lamp.translate_stop + 1 and lamp.cur_pos == lamp.stop_pos then
                if endItem.config.order == lamp.translate_stop + 1 then
                    endItem:OnReachStop()
                    break
                end
            end
        end
    end
end

function Panel.DoStopEffect(target)
    -- if target.config.Type == GridType.Item then
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
    -- end
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
            -- isPoolPause = false
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

end

-- 执行下一个跑马灯
function Panel.DoNext()
    this.AddDelay(0.1, function()
        ---@type LampData
        local data = table.remove(draw_result_list, 1)
        local lamp = this.HorseRaceLamp(data.type, data.start,data.id)
        if data.type == LampType.Inner or data.type == LampType.Outer then
            this.SetOuterLampStopPos(lamp, data.stop)
        end

        isWaitNextTrigger = false
    end)

end


function Panel.RefreshBtn(isEnable)
    GreyObject(this.btn_adv.gameObject, not isEnable, isEnable, isEnable)
    GreyObject(this.btn_one.gameObject, not isEnable, isEnable, isEnable)
    GreyObject(this.btn_multi.gameObject, not isEnable, isEnable, isEnable)
    GreyObject(this.uidata.Btn_Gift.gameObject, not isEnable, isEnable, isEnable)
    
end

function Panel.Update()
    -- FactoryGameModule.GM_AddNum()
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

    timer = timer + 0.01
    if timer < this.speeld then
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

---@param pos_list table 命中的格子id
function Panel.OnDrawSuccess(pos_list)
    this.ClearTurntable()
    this.HorseRaceLamp(LampType.Outer, 0,1)
    this.list = FactoryGameModule.getDrawInfo()
    draw_result_list = pos_list
    TimeModule.addDelay(0, function ()
        this.SetStopPos()
        this.inDraw = true
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

-- 抽卡结束
function Panel.OnDrawComplete()

    this.AddDelay(0.5, function()
        ShowUI(UINames.UIFactoryGameMsgItem, AddGameRewards, function ()
            this.playLevelAni()
        end, this.btn_pos, this.resItem)
    end)

end

function Panel.HideUI()
    HideUI(UINames.UIFactoryGame)
    if isPoolActive then
        return
    end
    UpdateBeat:Remove(this.Tick, this)
    TimeModule.removeTimer(this.show)
    TimeModule.removeTimer(this.timer)
    this.timer = nil
    this.show = nil
    if this.iconPool then
        this.iconPool:clear()
    end
    this.iconPool = nil
    this.ClearTurntable()
    turntable_items = {}
end
function Panel.OnDestroy()
    this.BaseCall('OnDestroy')
    turntable_items = {}
end
function Panel.AddDelay(delay, action)
    local tId = TimeModule.addDelay(delay, action)
    table.insert(timer_recorder, tId)
end

function Panel.addTime()
    this.uidata.time:SetActive(false)
    local data = ConfigManager.GetCasino(this.config.level)
    if this.config.freeCnt >= data.times_max and this.config.adCnt >= data.times_max_ad then
        return
    end
    this.uidata.time:SetActive(true)
    if this.timer == nil then 
        this.timer = TimeModule.addRepeatSec(function()
            local serveTime = TimeModule.getServerTime(true)
            local startTime = FactoryGameModule.getUIFactoryGameInfo().refreshTime
            local time = startTime - serveTime
            if time <= 0 then 
                FactoryGameModule.c2s_getInfo(cityId, function ()
                    this.RefreshLuck()
                end)
                TimeModule.removeTimer(this.timer)
                this.timer = nil
            else
                local num = "<color=#F42E29>" .. 1 .. "</color>"
                this.uidata.text_time.text = "<color=#F42E29>" .. TimeModule.format(time) .. "</color>"  .. GetLang("ui_gamemachine_tip_2", num)
            end
        end)
    end
end

function Panel.HideBtn(hide)
    local offset = hide and this.leftPosition + Vector3(-10, 0, 0) or this.leftPosition
    this.btnClose.transform:DOMove(offset, 1)
end
