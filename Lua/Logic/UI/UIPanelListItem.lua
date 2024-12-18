--region -------------数据定义-------------

--endregion

---@class UIPanelListItem : UIElementBase
local Item = class("UIPanelListItem", UIElementBase)

---刷新显示
---@param data any 数据
function Item:Refresh(data) end

return Item