------------------------------------------------------------------------
--- @desc 扭蛋机定义
--- @author chenyl
------------------------------------------------------------------------
local Define = {}
---@class GashaponGridType
Define.GridType = {
    Item = 1,
    Electricity = 2,
    Inner_Circle = 3,
    Train = 4,
    Hero = 5
}
---@class GashaponLampType
Define.LampType = {
    Outer = 1,
    Inner = 2,
    Train   = 3,
    BeginAni=4,--开始动画模式
}
return Define