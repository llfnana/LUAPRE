------------------------------------------------------------------------
--- @desc 数据定义
--- @author chenyl
------------------------------------------------------------------------
local Define = {
    InvisiblePos = Vector3.New(-100000, -100000, 0), --不可见位置
}

---事件类型
Define.EventType = {
    OnClick = "onClick",
    OnDown = "onDown",
    OnUp = "onUp",
    OnLongPress = "onLongPress",
    OnLongPressing = "onLongPressing",
    OnDragBegin = "onDragBegin",
    OnDrag = "onDrag",
    OnDragEnd = "onDragEnd",
    OnEnter = "onEnter",
    OnExit = "onExit",
}

Define.Component = {
    InputField = "InputField", --输入框
}

---@class UnlockType 事件类型
Define.UnlockType = {
    None = 1, --无
    HomeBuildingLv = 4, --家园建筑等级
    HomeBuildingConsume = 5, --家园建筑消耗解锁
    HomeHeroSlotConsume = 6, --家园生产派遣槽位消耗解锁
}

return Define