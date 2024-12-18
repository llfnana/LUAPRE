--region -------------引入模块-------------
--endregion

--region -------------数据定义-------------

---@class UIPanelListDItem 纯数据元素
---@field gameObject UnityEngine.GameObject
---@field transform UnityEngine.Transform

--endregion

---@class UIPanelList : UIElementBase
local List = class("UIPanelList", UIElementBase)

function List:OnCtor()
    self._items = nil ---@type UIPanelListDItem[]|UIPanelListItem[]
    self._itemInit = nil ---@type fun(g: UnityEngine.GameObject)|table
    self._isClass = nil ---@type boolean
end

function List:OnInitPanel(itemInit)
    self._items = {}

    local parent = self.transform
    self._isClass = GameUtil.isClass(itemInit)
    self._itemInit = itemInit

    for i=1, parent.childCount do
        local _go = parent:GetChild(i-1).gameObject
        self:_NewItem(_go)
    end
end

---绑定列表
---@param items UIPanelListDItem[]|UIPanelListItem[]
---@param itemNew fun(g: UnityEngine.GameObject)
function List:Bind(items, itemNew)
    self._items = items
    self._itemInit = itemNew
    self._isClass = GameUtil.isClass(itemNew)
end

function List:_NewItem(go)
    local item
    if self._isClass then
        item = self._itemInit.new() ---@type UIPanelListItem
        item:InitPanel(self.behaviour, go)
    else
        item = {} ---@type UIPanelListDItem
        item.gameObject = go
        item.transform = go.transform
        self._itemInit(item)
    end
    table.insert(self._items, item)
end

---刷新显示
---@generic T
---@param dataList T[]
---@param itemShow fun(t: UIPanelListDItem, d: T)|UIPanelListItem 刷新显示函数【可选】
function List:Refresh(dataList, itemShow)
    --补齐Item
    for _=#self._items + 1, #dataList do
        local _temp = self._items[1] --模板
        local _go = GOInstantiate(_temp.gameObject, self.transform)
        self:_NewItem(_go)
    end
    for i=1, #self._items do
        local item = self._items[i]
        local data = dataList[i]
        SafeSetActive(item.gameObject, data ~= nil)
        if data then
            if itemShow ~= nil then
                itemShow(item, dataList[i])
            elseif item.Refresh ~= nil then
                item:Refresh(dataList[i])
            end
        end
    end
end

return List