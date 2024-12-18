------------------------------------------------------------------------
--- @desc GM模块
--- @author sakuya
------------------------------------------------------------------------

--region -------------引入模块-------------
local GMCtrl = require "Module/GM/Ctrl/GMCtrl"
--endregion

--region -------------数据定义-------------

--endregion

--region -------------私有变量-------------
local module = {}
local fn = {}

-- 命令集
fn.commands = {
    ["DiceRoll"] = { func = function(params)
        StageModule.getMainCtrl():diceRoll(tonumber(params[1]) or 0)
    end, description = "投掷骰子到点数N[仅限关卡模式中]", defaultParam = { 1 } },
    ["ShowDrawPanel"] = { func = function(params)
        PlayerModule.c2sRequestEggData(function()
            PlayerModule.showUIPlayerLotteryDraw()
        end)
    end, description = "打开抽卡", defaultParam = { "" } },
    ["ShowUI2"] = { func = function(params)
        local uiName = params[1]
        if uiName then
            ShowUI(uiName)
        end
    end, description = "打开神庙", defaultParam = { "UIStageStatue" } },
    ["ShowUI3"] = { func = function(params)
        StageModule.c2sStageArena(function()
            ShowUI("UIStageArena")
        end)
    end, description = "打开竞技场", defaultParam = {} },
    ["ShowUISlot"] = { func = function(params)
        StageModule.c2sStageArena(function()
            ShowUI("UIMiniGameSlotMachine")
        end)
    end, description = "打开拉霸机", defaultParam = {} },
    ["ShowWorldBoss"] = { func = function(params)
        ShowUI(UINames.UIWorldBoss)
    end, description = "打开世界Boss界面", defaultParam = {} },
    ["ShowUI4"] = { func = function(params)
        local uiName = params[1]
        if uiName then
            ShowUI(uiName)
        end
    end, description = "打开布阵", defaultParam = { "UIFightDeploy" } },
    ["ShowUI5"] = { func = function(params)
        local uiName = params[1]
        if uiName then
            ShowUI(uiName)
        end
    end, description = "打开关卡车站", defaultParam = { "UIStageStation" } },
    ["ShowUI6"] = { func = function(params)
        local uiName = params[1]
        if uiName then
            ShowUI(uiName)
        end
    end, description = "打开关卡商店", defaultParam = { "UIStageShop" } },
    ["PartyAddNpc"] = { func = function()
        local vo = fn.newC2sVo()
        vo.info.gm.partyNpcAdd = StringUtil.EMPTY
        vo:send()
    end, description = "宴会添加NPC", defaultParam = { 1 } },
    ["PartyJoinRandom"] = { func = function(params)
        local vo = fn.newC2sVo()
        vo.info.gm.partyJoinRandom.giftCId = params[1]
        vo:send()
    end, description = "宴会随机被赴宴", defaultParam = { 4 } },
    ["ItemAdd"] = { func = function(params)
        local vo = fn.newC2sVo()
        vo.info.gm.itemAdd.cid = params[2]
        vo.info.gm.itemAdd.count = params[1]
        vo:add(function()
            BagModule.playMsgItems()
        end, true)
        vo:send()
    end, description = "道具添加", defaultParam = { 10000, 1000 } },
    ["addTitle"] = { func = function(params)
        local vo = fn.newC2sVo()
        vo.info.gm.addTitle.titleCId = params[1]
        vo:add(function()
            BagModule.playMsgItems()
        end, true)
        vo:send()
    end, description = "添加称号,称号id", defaultParam = { 90400 } },
    ["addHeadFrame"] = { func = function(params)
        local vo = fn.newC2sVo()
        vo.info.gm.addHeadFrame.headFrameCId = params[1]
        vo:add(function()
            BagModule.playMsgItems()
        end, true)
        vo:send()
    end, description = "添加头像框,头像框id", defaultParam = { 70101 } },
    ["addBubble"] = { func = function(params)
        local vo = fn.newC2sVo()
        vo.info.gm.addBubble.bubbleCId = params[1]
        vo:add(function()
            BagModule.playMsgItems()
        end, true)
        vo:send()
    end, description = "添加聊天气泡,气泡id", defaultParam = { 80301 } },
    ["HomeExploreAll"] = { func = function(params)
        local vo = fn.newC2sVo()
        vo.info.gm.homeExploreAll = StringUtil.EMPTY
        vo:send()
    end, description = "家园探索全部", defaultParam = { 10000 } },
}

local gmCtrl = nil
--endregion

--region -------------导出函数-------------

function module.init()
    gmCtrl = GMCtrl.New()
    gmCtrl:init()
end

function module.release()
end

function module.getGMCtrl()
    return gmCtrl
end

function module.getCommands()
    return fn.commands
end

function module.DoCommand(cmd, params)
    local command = fn.commands[cmd]
    if command then
        command.func(params)
    else
        print("GM命令不存在：" .. cmd)
    end
end

--endregion

--region -------------私有函数-------------

function fn.update()

end

function fn.newC2sVo()
    return NewCs("gm")
end

--endregion

return module
