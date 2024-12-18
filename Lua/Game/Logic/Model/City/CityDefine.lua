
local MapCellSize = { 0.39, 0.27 }  --{ 2.36, 1.08 } ---地图格子大小
local Define = {
    FogLayer = 2000, --云雾的层级
    InfoLayer = 3000, --信息层级
    BuildingOffsetY = MapCellSize[2] / 2, --建筑进入移动模式Y轴偏移（半个格子）
    BuildingCamViewSize = 4, --建筑表现镜头缩放视野大小
    --BuildingCamSpeed = 0.5, --建筑表现镜头缩放速度
    BlinkDistance = 25, --闪现的距离
    ProductOffset = math.pow(2, 3),  --产物配表键值偏移
    MapSizeMaxHeight = 1000, --地图最大高度
    MapCellSize = MapCellSize, --地图格子大小
    Map1EdgeSize = {x = 67.92 / 2, y = 62.81 / 2}, --地图1边界size
    Map2EdgeSize = {x = 81.92 / 2, y = 78.89 / 2}, --地图2边界size
    Map3EdgeSize = {x = 81.92 / 2, y = 73.50 / 2}, --地图3边界size
    Map4EdgeSize = {x = 81.92 / 2, y = 73.50 / 2}, --地图4边界size
    Map5EdgeSize = {x = 81.92 / 2, y = 73.50 / 2}, --地图5边界size
    Map6EdgeSize = {x = 81.92 / 2, y = 73.50 / 2}, --地图5边界size
    Map7EdgeSize = {x = 81.92 / 2, y = 73.50 / 2}, --地图5边界size
    Map8EdgeSize = {x = 81.92 / 2, y = 73.50 / 2}, --地图5边界size
    Map9EdgeSize = {x = 81.92 / 2, y = 73.50 / 2}, --地图5边界size
    Map10EdgeSize = {x = 81.92 / 2, y = 73.50 / 2}, --地图5边界size
    MapBlockSize = 10.24,--20.48, --地图块格子大小

    MapId =  1,
    CharScale= 1,-- 0.65,
    NpcPos = { x=89, y=55 }, --NPC站位
    debug = false,
}

---关卡角色动作
Define.PlayerAnim = {
--    Idle = 1, --挂机
--    Run = 2, --跑步
         idle = 1, --挂机 --idle = 1, --  待机1
        walk = 2, --  行走2
        run = 3, --跑步--  run = 3, --  跑步3
        bed = 4, -- 上床4
        sleeping = 5, --  睡觉 5
        sicksleep = 6, -- 平躺到趴着6
        dropsleep = 7, -- 趴着睡7
        eat = 8, -- 端着吃饭8
        eatwalk = 9, -- 端着行走吃饭9
        eatsit = 10, --  端着坐下吃饭10
        cooking = 11, --  吃饭循环11
        breed = 12, --  养殖12
        logging = 13, --  伐木拿去13
        cuttree = 14, --  伐木挥砍14
        hammerwork = 15, --  工作15

}

--动作 for monster  key=动作*10+方向  左方向的为右方向镜像，代码处理  attack2_up -> sit_up
Define.ACTION_LIST_PLAYER = {
	[10]="stand_up",[11]="stand_upright",[12]="stand_right",[13]="stand_downright",[14]="stand_down",
	[20]="walk_up",[21]="walk_upright",[22]="walk_right",[23]="walk_downright",[24]="walk_down",
	[30]="run_up",[31]="run_upright",[32]="run_right",[33]="run_downright",[34]="run_down",
	[40]="act4_up",[41]="act4_upright",[42]="act4_right",[43]="act4_downright",[44]="act4_down",
	[50]="act5_up",[51]="act5_upright",[52]="act5_right",[53]="act5_downright",[54]="act5_down",
	[60]="act6_up",[61]="act6_upright",[62]="act6_right",[63]="act6_downright",[64]="act6_down",
    [70]="act7_up",[71]="act7_upright",[72]="act7_right",[73]="act7_downright",[74]="act7_down",
    [80]="act8_up",[81]="act8_upright",[82]="act8_right",[83]="act8_downright",[84]="act8_down",
    [90]="act9_up",[91]="act9_upright",[92]="act9_right",[93]="act9_downright",[94]="act9_down",
	[100]="act10_up",[101]="act10_upright",[102]="act10_right",[103]="act10_downright",[104]="act10_down",
	[110]="act11_up",[111]="act11_upright",[112]="act11_right",[113]="act11_downright",[114]="act11_down",
	[120]="act12_up",[121]="act12_upright",[122]="act12_right",[123]="act12_downright",[124]="act12_down",
	[130]="act13_up",[131]="act13_upright",[132]="act13_right",[133]="act13_downright",[134]="act13_down",
	[140]="act14_up",[141]="act14_upright",[142]="act14_right",[143]="act14_downright",[144]="act14_down",
	[150]="act15_up",[151]="act15_upright",[152]="act15_right",[153]="act15_downright",[154]="act15_down",
}
---格子类型
Define.CellType = {
    Road = 1, --路
    Wall = 2, --墙
    Ground = 3, --地面（默认）
}

---格子拐点类型
Define.CellGDType = {
    None = 1,--无
    LEFT_UP_RIGHT301= 2,--3-0-1
    UP_RIGHT_DOWN012= 3,--0-1-2
    RIGHT_UP_LEFT123= 4,--1-2-3
    DOWN_LEFT_UP230= 5,--2-3-0
    UP_LEFT_DOWN_RIGHT0123= 6,--0-1-2-3
}

---格子状态
Define.CellStatus = {
    None = 1,--无
    Move = 2,--移动
    Build = 3,--建造预览
    Disable = 4,--不可用
}

---状态机-状态
Define.FsmState = {
    Ready = 1, --准备
    Building = 2, --建造中
}

---@class HomeBuildingStatus 建筑状态
Define.BuildingStatus = {
    None = 1, --废墟（未修复）
    Doing = 2, --建造（升级）中
    --UnChecked = 3, --建造完成，未验收
    Done = 4, --完成
}

---@class HomeBuildingType 建筑类型：1-经营，2-生产，3-议会，4-道路，5-装饰
Define.BuildingType = {
    Business = 1, --经营
    Production = 2, --生产
    Parliament = 3, --其他（议会、子嗣）
    Road = 4, --道路
    Decorate = 5, --装饰
}

---@class HomeBuildingAnim 建筑动画
Define.BuildingAnim = {
    Broke = "idle_broke", --废墟
    Idle = "idle", --运行
    Free = "idle_free", --空闲
}

---@class HomePrdSlotStatus 产品插槽状态
Define.PrdSlotStatus = {
    DOING = 1, --生产中
    FREE = 2, --空闲
    DONE = 3, --已完成
    LOCK = 4, --未解锁
}

---关卡状态
Define.StageState = {
    None = 0,       -- 无状态
    Idle = 1,       -- 待机
    Move = 2,       -- 移动中
    PauseMove = 3,  -- 暂停移动(暂时没有用)
    Trigger = 5,    -- 触发触发器
}

---角色行动方式
Define.MoveType = {
    Run = 1,
    Car = 2,
}

return Define