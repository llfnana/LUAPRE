------------------------------------------------------------------------
--- @desc 背包系统
------------------------------------------------------------------------

--region -------------引入模块-------------

--endregion

--region -------------数据定义-------------




--endregion

--region -------------私有变量-------------
local module = {}
local fn = {}

local itemMap = {} ---@type table<number, SvrItemVo> 物品数据
local FactoryGameItem = {}
local msgItems = nil ---@type SvrItemVo[] 消息中的道具列表
--endregion

--region -------------导出函数-------------

function module.init()
    makergetFn(Sc(), "msgWin"):addEvent("items", fn.s2cMsgWinItems)
end

function module.exit()
    itemMap = {} --清空数据
end

-- function module.getItemMap()
--     return itemMap --这里面存着道具的数值，是最新的
-- end

-- function module.getItemNum(tid)
--     local vo = itemMap[tid]
--     return vo and vo.count or 0
-- end

function module.getMsgItems()
    return msgItems or {}
end
--游戏工厂次数道具添加
function module.useItem(id, count, cb)
    local vo = NewCs("item")
    vo.info.item.useitem.id = id
    vo.info.item.useitem.count = count
    vo:add(cb, true)
    vo:send()
end

function module.getFactoryGameItem()
    return FactoryGameItem
end

--region -------------私有函数-------------

---@param vos SvrItemVo[]
---@param urlVo HttpUrlVo
function fn.s2cMsgWinItems(vos, urlVo)
    msgItems = vos
    FactoryGameItem = {}
    for index, value in ipairs(vos) do
        if "Gamecoins1" == value.id or "Gamecoins2" == value.id then
            if FactoryGameItem[value.id] then
                FactoryGameItem[value.id].count = value.count + FactoryGameItem[value.id].count
            else
                FactoryGameItem[value.id] = value
            end
        end
    end
end

function fn.getItemTotal()
    local Item = {}
    local itemList = {}
    local itemdata = module.popMsgItems()
    if itemdata then
        for i, v in ipairs(itemdata) do
            local id = v.id
            local quantity = v.count
            if Item[id] then
                Item[id].count = Item[id].count + quantity
            else
                Item[id] = { id = id, count = quantity }
            end
            Item[id].fromId = v.from.id
        end
        for i, v in pairs(Item) do
            table.insert(itemList, v)
        end
        return itemList
    end
end

--endregion

return module
