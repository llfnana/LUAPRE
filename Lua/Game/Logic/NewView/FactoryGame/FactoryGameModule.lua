------------------------------------------------------------------------
--- @desc 扭蛋机
--- @author hanabi
------------------------------------------------------------------------
--region -------------引入模块-------------
local FactoryGameDefine = require("Game/Logic/NewView/FactoryGame/FactoryGameDefine")
local LampType = FactoryGameDefine.LampType ---@type GashaponLampType
local GridType = FactoryGameDefine.GridType ---@type GashaponGridType
--endregion

--region -------------数据定义-------------
---@class SvrGashapon 英雄属性
---@field free number 是否免费（0=否，1=是）
---@field luck number 幸运值
---@field position number 位置

---@class SvrDraw
---@field position number 抽奖结果-位置
---@field electricities number 抽奖结果-电池奖励列表

---@class LampData
---@field type GashaponLampType  跑马灯类型
---@field start number 起始点
---@field stop number 结束点

--endregion

--region -------------私有变量-------------
local module = {}
local fn = {}

local free = 0
local luck = 0
local position = 0
local UIFactoryGameInfo = {
    level = 1,          --等级
    refreshTime = 0,    --次数下次刷新时间点
    adCnt = 0,          --广告次数
    exp = 0,            --经验值
    freeCnt = 0,        --免费次数
    customId = 0,       --游戏关卡id
}
--endregion

--region -------------导出函数-------------

function module.init()
    fn.init()
    makergetFn(Sc(), "gameMachine"):addEvent("info", fn.s2c_Gashapon)
    makergetFn(Sc(), "gameMachine"):addEventUpdate("info", fn.s2c_OnGashaponUpdate)
    makergetFn(Sc(), "gameMachine"):addEvent("results", fn.s2c_Draw)
end

--抽奖
function module.c2s_Draw(ad, times, cb)
    local vo = NewCs("gameMachine")
    vo.info.gameMachine.draw.ad = ad
    vo.info.gameMachine.draw.times = times
    vo:add(cb, true)
    vo:send()
end

--获工厂游戏基本信息
function module.c2s_getInfo(id,cb)
    local vo = NewCs("gameMachine")
    vo.info.gameMachine.getInfo.customId = id
    vo:add(cb, true)
    vo:send()
end
function module.c2s_GameMachine(id, cb)
    local vo = NewCs("gm")
    vo.info.gm.drawGameMachine.order = id
    vo:add(cb, true)
    vo:send()
end

--获工厂游戏基本信息
function module.GM_AddNum()
    local vo = NewCs("gm")
    vo.info.gm.addGameMachineCnt = ""
    vo:send()
end


---@return number 获取幸运值
function module.getLuckValue()
    return luck or 0
end

function module.isFree()
    return free == 1
end

--获取工厂游戏机信息
function module.getUIFactoryGameInfo()
    return UIFactoryGameInfo
end

function module.getDrawInfo()
    if fn.trainpos_list ~= nil then
        for index, value in ipairs(fn.trainpos_list) do
            table.insert(fn.pos_list,value)
        end
    end
    return fn.pos_list 
end

function module.isRed()
    
end

function module.AddGameRewards(isAddItem)
    local rewards = BagModule.getMsgItems()
    local cityId = DataManager.GetCityId()
    local allReward = {}
    for k, v in ipairs(rewards) do
        local itemdata = ConfigManager.GetItemConfig(v.id)
        if itemdata and itemdata.duration > 0 then
            if v.id == "Resources10" or v.id == "Resources30" or v.id == "Resources60" then
                for i = 1, v.count do
                    local Itemrewards = OverTimeProductionManager.Get(cityId):GetItemOverTime(itemdata.duration)
                    local item = {}
                    for index, value in pairs(Itemrewards) do
                        table.insert(item, {id = index, count = value})
                    end
                    local index = math.random(1, #item)
                    for i, value in ipairs(item) do
                        if i == index then
                            table.insert(allReward, Utils.ConvertAttachment2Rewards(value.id, value.count, RewardAddType.Item))
                        end
                    end
                end
            else
                table.insert(allReward, Utils.ConvertAttachment2Rewards(v.id, v.count, RewardAddType.Item))
            end
        elseif v.id == "Gamecoins1" or v.id == "Gamecoins2" then
            BagModule.useItem(v.id,v.count)
            table.insert(allReward, Utils.ConvertAttachment2Rewards(v.id, v.count, RewardAddType.Item))
        elseif v.id == "Hunger" or v.id == "Sleep" then
            local type = v.id == "Hunger" and AttributeType.Hunger or AttributeType.Rest
            CharacterManager.AddMaxAttribute(cityId, type, v.count)
            table.insert(allReward, Utils.ConvertAttachment2Rewards(v.id, v.count, RewardAddType.Item))
        else
            table.insert(allReward, Utils.ConvertAttachment2Rewards(v.id, v.count, RewardAddType.Item))
        end
    end
    if not isAddItem then
        for index, value in ipairs(allReward) do
            if value.id ~= "Gamecoins1" or value.id ~= "Gamecoins2" then
                DataManager.AddMaterial(cityId, value.id, value.count)  
            end
        end
    end
    return allReward
end

--endregion

--region -------------私有函数-------------

function fn.init()
end

function fn.s2c_Gashapon(vo)
    print('s2c_Gashapon', ListUtil.dump(vo))
    UIFactoryGameInfo.level = vo.level
    UIFactoryGameInfo.refreshTime = vo.refreshTime
    UIFactoryGameInfo.adCnt = vo.adCnt
    UIFactoryGameInfo.exp = vo.exp
    UIFactoryGameInfo.freeCnt = vo.freeCnt
    UIFactoryGameInfo.customId = vo.customId
end

function fn.s2c_OnGashaponUpdate(vo)
    print('s2c_OnGashaponUpdate', ListUtil.dump(vo))
    UIFactoryGameInfo.level = vo.level or UIFactoryGameInfo.level
    UIFactoryGameInfo.refreshTime = vo.refreshTime or UIFactoryGameInfo.refreshTime
    UIFactoryGameInfo.adCnt = vo.adCnt or UIFactoryGameInfo.adCnt
    UIFactoryGameInfo.exp = vo.exp or UIFactoryGameInfo.exp
    UIFactoryGameInfo.freeCnt = vo.freeCnt or UIFactoryGameInfo.freeCnt
    UIFactoryGameInfo.customId = vo.customId or UIFactoryGameInfo.customId
    Event.Brocast(EventDefine.OnGashaponUpdate)
end

function fn.s2c_Draw(vo)
    fn.rewardMap = {}
    fn.pos_list = {}        --跑马灯表现需要的位置信息 {LampData}
    fn.trainpos_list = {}
    fn.electricity_map = {} --电池
    fn.next_start_pos = 0

    for i, v in ipairs(vo) do
        print("后端下发外圈数据",v.position)
        fn.handleData(v, fn.next_start_pos, false, i) -- 这里的0无意义 跑马灯已经运行了
    end
    Event.Brocast(EventDefine.OnFactoryGameDraw, fn.pos_list)
end

--递归遍历数据
---@param node table 服务器的嵌套数据
---@param next_start_pos table 下个一个跑马灯的起始点
---@param isManual boolean 当前位置是否通过手动摇奖到达 只有服务端下发的最外层为true
function fn.handleData(node, next_start_pos, istrain, i)
    -- local tabel = tabel or 
    fn.next_start_pos = next_start_pos --为下一轮手抽设置起始点
    if not istrain then
        table.insert(fn.pos_list, { type = LampType.Outer, start = next_start_pos, stop = node.position, id = i})
    else
        table.insert(fn.trainpos_list, { type = LampType.Outer, start = next_start_pos, stop = node.position})
    end
    if node and node.train ~= nil then
        for index, value in ipairs(node.train) do
            fn.handleData(value, index == 1 and node.position or fn.next_start_pos, true)
        end
    end
end

--递归奖励
function fn.handleReward(node)
    local cfg = TbGashapon[node.position + 1]
    if cfg.Type == GridType.Item then
        fn.recordReward(cfg.Params[1], cfg.Params[2])
    end

    -- if node.inner and node.inner ~= '' then
    --     fn.handleReward(node.inner)
    -- end

    if node.train and node.train ~= '' then
        for _, n in ipairs(node.train) do
            fn.handleReward(n)
        end
    end

    if node.electricities and #node.electricities > 0 then
        for _, n in ipairs(node.electricities) do
            fn.handleReward(n)
        end
    end
end

--记录奖励
function fn.recordReward(id, count)
    fn.rewardMap[id] = fn.rewardMap[id] and fn.rewardMap[id] + count or count
end

--endregion


return module
