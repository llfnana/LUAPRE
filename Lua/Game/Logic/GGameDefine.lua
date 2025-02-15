---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- DateTime: 2019/9/6 15:26
---
GameDefine = {}
GameDefine.DefaultHeight = 1920
GameDefine.DefaultWidth = 1080

--数据key
DataKey = {
    NewUser = "newUser",
    TutorialData = "tutorialData",
    FristInit = "fristInit",
    Bag = "bag",
    FunctionsUnlockData = "functionsUnlockData",
    FoodType = "foodType",
    FoodBag = "foodBag",
    Day = "day",
    Clock = "clock",
    OnlineTime = "onlineTime",
    CharacterData = "characterData",
    PartId = "partId",
    TaskData = "tasks",
    ProtestData = "protestData",
    WorkOverTimeData = "workOverTimeData",
    RewardBoostData = "rewardBoostData",
    CardData = "cardData",
    FunctionsData = "functionsData",
    Hope = "hope",
    Security = "security",
    Despair = "despair",
    GenEnable = "genEnable",
    GenOverload = "genOverload",
    Zones = "zones",
    OfficeData = "officeData",
    BoxData = "boxData",
    StatisticalData = "statisticalData",
    MaxGenId = "maxGenId",
    Pay = "pay",
    MailData = "mailData",
    CloseMusic = "closeMusic",
    CloseEffect = "closeEffect",
    UseFahrenheit = "useFahrenheit",
    DiscordShown = "discordShown",
    Survey = "survey",
    RegisterTS = "reg",
    ShopDaily = "shopDaily",
    Shop = "shop",
    OverTimeProduction = "overTimeProduction",
    LoginInfo = "loginInfo",
    HappyMail = "happyMail",
    DailyShout = "dailyShout",
    DailyBag = "dailyBag",
    EventData = "eventData",
    Roguelike = "Roguelike",
    RoguelikeConstant = "RoguelikeConstant",
    CityPass = "cityPass",
    Profile = "profile",
    FuelAlertTodayNoTips = "FuelAlertTodayNoTips",
    HasClickPanel = "HasClickPanel",
    PostStation = "postStation",
    StoryBook = "StoryBook",
    WeatherData = "WeatherData",
    UpdateCompensate = "updateCompensate"
}

--城市模块key
CityKey = {
    Test = "Test",
    Data = "Data",
    Clock = "Clock",
    FoodSystem = "FoodSystem",
    Functions = "Functions",
    Schedules = "Schedules",
    Grid = "Grid",
    Character = "Character"
}

--格子状态
GridStatus = {
    None = 0,
    Lock = 1,
    Unlock = 2,
    CanUse = 3
}

--格子功能
GridEffect = {
    None = 0,
    Path_1 = 1,
    Path_2 = 2
}

--格子标记
GridMarker = {
    None = "None",
    Door = "Door", --门
    Bed = "Bed",  --床
    Tool2ForDorm = "Tool2ForDorm", --宿舍家具2
    Tool3ForDorm = "Tool3ForDorm", --宿舍家具3
    Tool4ForDorm = "Tool4ForDorm",--宿舍家具4
    Tool5ForDorm = "Tool5ForDorm",--宿舍家具5
    Tool6ForDorm = "Tool6ForDorm",--宿舍家具6
    Table = "Table", --桌子
    ServingTable = "ServingTable", --服务台
    Washer = "Washer", --洗衣机
    Burner = "Burner", --炉子
    Tool1ForHunterCabin = "Tool1ForHunterCabin", --猎人小屋工具
    Tool = "Tool",--工具
    Axe = "Axe",  --斧头
    Pickaxe = "Pickaxe", --采掘用的镐
    Idle = "Idle",  --空闲的;
    OfficeIdle = "OfficeIdle",--空闲办公
    Queue = "Queue",  --排队; 列队等待
    Born = "Born",--出生点
    TutorialBorn = "TutorialBorn",  --辅助出生点
    TutorialVanBorn = "TutorialVanBorn",--厢式货车辅助出生点
    TutorialCardBorn = "TutorialCardBorn",--辅助卡片出生点
    TutorialCardDelete = "TutorialCardDelete",--辅助卡片删除点
    OfficeBorn = "OfficeBorn",  --办公室出生点
    Items = "Items",  --项目道具
    Hunt = "Hunt",  --打猎
    DoctorTable = "DoctorTable", --手术台
    MedicalBed = "MedicalBed",  --医疗床; 病床;
    Doctor = "Doctor", --医生
    PickaxeForIron = "PickaxeForIron", --铁镐
    ToolForMetal = "ToolForMetal", --金属工具1
    ToolForMetal2 = "ToolForMetal2", --金属工具2
    PickaxeForCopper = "ToolForMetal2", --铜镐
    ToolForMotor = "ToolForMotor", --维修工具
    Stairs = "Stairs",  ---楼梯
    Tool1ForSawmill = "Tool1ForSawmill",--锯木工具
    Tool1ForOffice = "Tool1ForOffice", --办公工具1
    Tool2ForOffice = "Tool2ForOffice",--办公工具2
    Speech = "Speech",  --演讲
    Protest = "Protest",  --抗议1
    Protest2 = "Protest2",---抗议2
    Special1ForIdle = "Special1ForIdle", --专门待机点1
    Special2ForIdle = "Special2ForIdle",--专门待机点2
    Special3ForIdle = "Special3ForIdle",--专门待机点3
    Boost1ForWarehouse = "Boost1ForWarehouse", ---仓库Boost1
    VanBorn = "VanBorn", ---厢式货车出生点
    VanDestroy = "VanDestroy",--厢式货车消失点
    VanQueue = "VanQueue",--厢式货车排队点
    Tool1ForWarehouse = "Tool1ForWarehouse",  --仓库工具1
    Tool2ForWarehouse = "Tool2ForWarehouse",--仓库工具2
    Tool3ForWarehouse = "Tool3ForWarehouse",--仓库工具3
    Tool4ForWarehouse = "Tool4ForWarehouse",--仓库工具4
    Tool5ForWarehouse = "Tool5ForWarehouse",--仓库工具5
    Tool6ForWarehouse = "Tool6ForWarehouse",--仓库工具6
    Tool7ForWarehouse = "Tool7ForWarehouse",--仓库工具7
    Tool1ForCollectionStation = "Tool1ForCollectionStation",--
    Tool1ForCarpentry2 = "Tool1ForCarpentry2",--
    Tool1ForMachineryFactory = "Tool1ForMachineryFactory",--
    Tool1ForIronMine = "Tool1ForIronMine",
    Occlusion = "Occlusion",-- 遮挡区所在位
}

--区域类型
---@class ZoneType
ZoneType = {
    None = "None",
    MainRoad = "MainRoad",  --干道; 主要公路;
    Generator = "Generator",  --发电机(火炉)
    Sawmill = "Sawmill",  --锯木厂;
    HunterCabin = "HunterCabin",  ---猎人小屋
    Kitchen = "Kitchen",  --厨房
    CoalMine = "CoalMine",  --煤矿
    Carpentry = "Carpentry", ---加工厂
    Carpentry2 = "Carpentry2", ---木工
    Dorm = "Dorm",  --宿舍
    Infirmary = "Infirmary", --医务室
    Office = "Office",  --办公室
    Watchtower = "Watchtower", --瞭望塔
    Warehouse = "Warehouse",  --仓库
    GoldenGrandpa = "GoldenGrandpa",  --金老爷
    GoldenMermaid = "GoldenMermaid"  --金鱼
}

--职业类型
ProfessionType = {
    None = "None",
    FarmerWood = "FarmerWood",--伐木工人
    Hunter = "Hunter",--猎人
    Chef = "Chef",--厨师
    Coalman = "Coalman",--煤矿工人
    Worker = "Worker", --工人
    FreeMan = "Freeman", --自由职业
    Ironman = "Ironman",--铁矿工人
    Metalman = "Metalman",--金矿工人 作坊1
    Metalman2 = "Metalman2",--金矿2工人 作坊2
    Doctor = "Doctor",--医生
    Guard = "Guard",--警卫
    Boilerman = "Boilerman"  --锅炉工
}

FoodStatus = {
    None = 0,
    InKitchen = 1,
    InSelect = 2,
    InDelivering = 3,
    InCanteen = 4
}

-- 状态机枚举
EnumState = {
    None = "None",
    --正常
    Normal = "Normal",
    --低健康
    HealthLow = "HealthLow",
    --严重
    Severe = "Severe",
    --生病
    Sick = "Sick",
    --死亡
    Dead = "Dead",
    --暴动
    Protest = "Protest",
    --庆祝
    Celebrate = "Celebrate",
    --活动罢工
    EventStrike = "EventStrike",
    --逃跑
    RunAway = "RunAway"
}

-- 标记状态
EnumMarkState = {
    None = 0,
    Talk = 1,
    DeathFromSick = 2,
    DeathFromHunger = 3
}

-- 命令类型
CommandType = {
    NONE = 0,
    STATE_INIT = 1,
    STATE_ENTER = 2,
    STATE_UPDATE = 3,
    STATE_DONE = 4,
    STATE_FINISH = 5,
    STATE_QUIT = 6
}

--日程类型
SchedulesType = {
    None = "None",
    Sleep = "Sleep", --睡觉
    Home = "Home", --宿舍休息
    Arbeit = "Arbeit", --劳动
    Cooking = "Cooking", --做饭
    Hunting = "Hunting", --狩猎
    Heal = "Heal", --医治
    BackHome = "BackHome", --回家
    Eat = "Eat", --吃饭
    Arbeit_OverTime = "Arbeit_OverTime", --加班
    Speech = "Speech",  --演讲
    Protest = "Protest", --抗议
    Boilerman = "Boilerman", --锅炉工
    Celebrate = "Celebrate", --庆祝
    Van = "Van", --厢式货车(选（矿）；用车搬运（货物）; 搭货车旅行;)
    EventStrike = "EventStrike"  --事件罢工
}

--日程状态
SchedulesStatus = {
    Completed = "Completed",
    Stop = "Stop"
}

--条件类型
ConditionType = {
    None = 0,
    Equal = 1,
    NotEqual = 2
}

--属性类型
AttributeType = {
    Warm = "Warm", --温暖的
    Hunger = "Hunger", --饥饿
    Rest = "Rest", --休息
    SurfaceTemperature = "SurfaceTemperature", --表面温度
    Hope = "Hope", --希望
    Health = "Health",  --健康
    Comfort = "Comfort",--安逸; 舒服
    Fun = "Fun", --享乐
    Security = "Security",  --安全
    Happness = "Happness",  --幸福
    EventStrike = "EventStrike"  --事件罢工
}

--Item类型
ItemType = {
    Unknown = "Unknown",
    Gem = "Gem",
    Heart = "Heart",
    BlackCoin = "BlackCoin",
    Cash = "Cash",
    HeroCoin = "HeroCoin",
    Food = "Food",
    Wood = "Wood",
    Iron = "Iron",
    Meat = "Meat",
    FoodLow = "FoodLow",
    FoodMid = "FoodMid",
    FoodHigh = "FoodHigh",
    WoodenBoard = "WoodenBoard",
    Coal = "Coal",
    IronBar = "IronBar",
    Hammer = "Hammer",
    GearWheel = "GearWheel",
    FoodLow2 = "FoodLow2",
    FoodMid2 = "FoodMid2",
    FoodHigh2 = "FoodHigh2",
    Copper = "Copper",
    CopperBar = "CopperBar",
    CopperWire = "CopperWire",
    Magnet = "Magnet",
    Motor = "Motor",
    FoodLow3 = "FoodLow3",
    FoodMid3 = "FoodMid3",
    FoodHigh3 = "FoodHigh3",
    Oil = "Oil",
    Plastic = "Plastic",
    Component = "Component",
    FoodLow4 = "FoodLow4",
    FoodMid4 = "FoodMid4",
    FoodHigh4 = "FoodHigh4",
    ADTicket = "ADTicket",
    BuildTicket = "BuildTicket",
    PlayCoin = "PlayCoin",
    Trick = "Trick",
    TimeSkip15 = "TimeSkip15",
    TimeSkip60 = "TimeSkip60",
    TimeSkip120 = "TimeSkip120"
}

--Item用途类型
ItemUseType = {
    Food = "Food",
    Material = "Material",
    Gem = "Gem"
}

--UI类型
ViewType = {
    Production = "SceneViewProduction",
    Progress = "SceneViewProgress",
    Slider = "SceneViewSlider",
    Tips = "SceneViewTips",
    Warning = "SceneViewWarning",
    Display = "SceneViewDisplay",
    Protest = "SceneViewProtest",
    Sick = "SceneViewSick"
}

--动画状态
AnimationType = {
    Idle = "idle",
    Idle2 = "idle_2",
    Idle3 = "idle3",
    --
    Walk = "walk",
    Walk1 = "walk1", --  牛腿行走19
    ColdWalk = "coldwalk",
    SickWalk = "sickwalk", --lesionrun 病变行走18
    CarryWalk = "carrywalk",
    CarryFoodWalk = "carryfoodwalk",  --eatwalk 端着行走吃饭6
    StrikeWalk = "sttrikemarch",--sttrikemarch  罢工行走14
    Run = "run",
    --
    Sleep = "sleeping",
    SickSleep = "sicksleep",
    --
    Protest = "protest",
    Death = "death_2"
}

--节点类型
NodeType = {
    HandLeft = "Node_Hand_Left",
    HandRight = "Node_Hand_Right"
}

--计数类型
StepType = {
    Current = "Current",
    Count = "Count"
}

--任务状态
TaskStatus = {
    --未激活
    Inactive = 1,
    --未完成
    Unfinished = 2,
    --未领奖
    NotAccept = 3,
    --已完成
    Completed = 4
}

TaskType = {
    UpgradeZone = "UPGRADE_ZONE",
    CollectItem = "COLLECT_ITEM",
    UpgradeFurniture = "UPGRADE_FURNITURE",
    ChangeProfession = "CHARACTER_PROFESSION_CHANGE"
}

TaskMilestoneStatus = {
    NoFinished = 1,
    Finished = 2,
    Claimed = 3
}

--红点类型
RedPointType = {
    Task = 1
}

--概率类型
RateType = {
    CureRate = "CureRate",
    DeadRate = "DeadRate",
    SickRate = "SickRate"
}

--功能类型
FunctionsType = {
    Tasks = "Tasks",
    Schedules = "Schedules",
    Setting = "Setting",
    Shop = "Shop",
    ShopBox = "ShopBox",
    ShopGem = "ShopGem",
    ShopPack = "ShopPack",
    Attributes = "Attributes",
    Map = "Map",
    WorkerManagement = "WorkerManagement",
    Statistical = "Statistical",
    Office = "Office",
    Fight = "Fight",
    HeartGeneration = "HeartGeneration",
    Cards = "Cards",
    WorkOverTime = "WorkOverTime",
    Protest = "Protest",
    BlackMarket = "BlackMarket",
    Ads = "Ads",
    SurvivorSick = "SurvivorSick",
    BuildingManagement = "BuildingManagement",
    ResourceAlertTips = "ResourceAlertTips",
    EventCity = "EventCity",
    RogueLikeBattle = "RogueLikeBattle",
    PushNotify = "PushNotify",
    Storm = "Storm",
    FirstCharge = "FirstCharge",
    Assist = "Assist", -- 物资净化
    FactoryGame = "FactoryGame", --工厂游戏
}

--升级解锁新建筑类型
UnlockZoneType = {
    Unlock = "Unlock",
    Upgrade = "Upgrade"
}

--暴走状态
ProtestStatus = {
    None = "None",
    Talk = "Talk",
    Run = "Run",
    CoolDown = "CoolDown"
}

--加班状态
WorkOvertimeState = {
    None = 1,
    Wait = 2,
    Run = 3
}

--角色填充类型
FillType = {
    Build = "Build",
    Dead = "Dead"
}

--通用boost类型
CommonBoostType = {
    Speed = 1,
    OfflineReward = 2,
    ConstructionSpeed = 3,
    IdleBattleReward = 4,
    ProtestEffect = 5,
    GeneratorResource = 6,
    CookSpeed = 7,
    EventCashExpDouble = 8
}

--Rx boost类型
RxBoostType = {
    ConstructionQueue = 1,
    AutoGeneratorOverload = 2,
    IdleBattleCapacity = 3,
    OfflineTime = 4,
    MedicalTime = 5,
    MedicalValue = 6,
    ProtestPeopleCount = 7,
    ProtestPeopleValue = 8,
    MedicalCureRate = 9,
    BattleSpeed = 10,
    OfflineBattleTime = 11,
    PeopleFastCome = 12,
    EventOfflineTime = 13
}

--活动场景boost类型
EventBoostType = {
    VanSpeed = 1,
    BuildCost = 2,
    HeartBuff = 3
}

--Boost.from_type
---@class BoostFromType
BoostFromType = {
    Card = "Card",
    Subscription = "Subscription",
    Trick = "Trick",
    Reward = "Reward"
}

--教程对象
TutorialTarget = {
    UI = "UI",
    MapItem = "MapItem"
}

--教程遮罩类型
TutorialMaskType = {
    None = "None",
    Circle = "Circle",
    Rect = "Rect"
}

--教程步骤
TutorialStep = {
    None = 0,
    FirstEnterCity = 2,
    BuildGenerator = 3,
    BuildSawmill = 4,
    BuildKitchen = 5,
    SchedulesEat = 6,
    BuildHunterCabin = 7,
    OverloadOpen = 8,
    OverloadClose = 9,
    FirstEnterCity2 = 10,
    OpenBox = 14,
    NightTalk = 18,
    ToCity2 = 19,
    SurvivorSick = 20,
    ProtestTalks = 33,
    ProtestRiots = 34,
    TaskGetCard = 41,
    FactoryGame = 50,
}

TutorialTalkType = {
    None = "None",
    Left = "Left",
    Right = "Right"
}

AdRandType = {
    burning_material = "burning_material",
    food_material = "food_material",
    product_material = "product_material",
    building_material = "building_material",
    BlackCoin = "BlackCoin",
    Heart = "Heart",
    PlayCoin = "PlayCoin",
    Cash = "Cash",
    HeartByBuilding = "HeartByBuilding"
}

---@class ToolTipDir
ToolTipDir = {
    Left = 1,
    Right = 2,
    Down = 3,
    Up = 4,
}

--事件类型
GameAction = {
    None = 0,
    OfflineInit = 1,
    OfflineNo = 2,
    OfflineShow = 3,
    OfflineClose = 4
}

DiscordFromType = {
    TaskComplete = "TaskComplete",
    cityComplete = "cityComplete",
    fightComplete = "fightComplete"
}

RewardAddType = {
    Item = "addToItem",
    Card = "addToCard",
    Box = "addToBox",
    ItemOverTime = "addToItemOverTime", --当前场景所有产出的秒产
    OverTime = "addToOverTime", --指定物品产出的秒产（不包含material，目前只支持heart, cash）
    OverTimeResType = "addToOverTimeResType", --指定资源类型的产出秒产，取指定rand数量的资源（目前用于战斗奖励）
    OpenBox = "addToOpenBox",
    DailyItem = "addToDailyItem",
    Boost = "addToBoost",
    ZoneTime = "addToZoneTime", --增加建筑升级时间
    ItemType = "addToItemType", --指定物品类型，这个类型在当前场景只能有一种
    ProtestPeople = "addToProtestPeople"
}

RewardType = {
    Item = "Item",
    Card = "Card",
    Box = "Box"
}

---@class Reward
---@field id string
---@field count number
---@field addType string       --RewardAddType

FoodLevelType = {
    FoodLow = "FoodLow",
    FoodMid = "FoodMid",
    FoodHigh = "FoodHigh"
}

--分配状态
WorkStateType = {
    None = 0,
    Work = 1,
    Pause = 2,
    Disable = 3,
    Sick = 4,
    Protest = 5
}

--手指朝向
FingerToward = {
    Right = 1,
    Down = 2,
    Left = 3
}

--角色boost
BoostName = {
    EatFood = 1
}

--部分预警属性
WarningMainSceneAttributes = {
    AttributeType.Warm,
    AttributeType.Hunger,
    AttributeType.Rest
}

--活动场景预警属性
WarningEventSceneAttributes = {
    AttributeType.Fun,
    AttributeType.Hunger,
    AttributeType.Rest
}

--全部预警属性
WarningAllAttributes = {
    AttributeType.Warm,
    AttributeType.Hunger,
    AttributeType.Rest,
    AttributeType.Comfort,
    AttributeType.Fun,
    AttributeType.Security
}
-- *** 修改名字需要和服务器同步修改 ***
MailEventName = {
    PendingSubscription = "PendingSubscription"
}

--卡牌城市类型
---@class CityType
CityType = {
    None = "None",
    City = "City",
    Event = "Event"
}

--活动城市类型
---@class EventCityType
EventCityType = {
    None = "None",
    Club = "Event1001",
    Water = "Event1002"
}

--小人工作状态
---@class ArbeitStateType
ArbeitStateType = {
    Work = "Work",
    CannotWork = "CannotWork",
}

--MapItemData状态
MapItemDataStatus = {
    Lock = "lock",
    Unlock = "unlock",
    Building = "building",
    Normal = "normal",
    Upgrading = "upgrading",
    MaxLevel = "maxLevel"
}

--卡车加载口类型
VanLoadPortType = {
    Unlock = 1,
    CanUse = 2
}

--cash生产类型
CashProductionType = {
    Real = 1,
    Theory = 2
}

--登录类型
AccountType = {
    FPAccountTypeUnknown = -1,
    FPAccountTypeExpress = 0,
    FPAccountTypeEmail = 1,
    FPAccountTypeFacebook = 2,
    FPAccountTypeVK = 3,
    FPAccountTypeWechat = 4,
    FPAccountTypeGooglePlus = 5,
    FPAccountTypeGameCenter = 6,
    FPAccountTypeNotSpecified = 7,
    FPAccountTypeMobile = 8,
    FPAccountTypeNaver = 9,
    FPAccountTypeGoogle = 10,
    FPAccountTypeCache = 11,
    FPAccountTypeApple = 12,
    FPAccountTypeTwitter = 13,
    FPAccountTypePlatform = 14,
    FPAccountTypeHuawei = 15
}

--天气类型
WeatherType = {
    None = 0,
    Normal = 1,
    Storm = 2
}

--天气效果类型
WeatherEffectType = {
    None = 0,
    Snow_Moderate_Start = 4,
    Snow_Moderate_Loop = 5,
    Snow_Moderate_Over = 6,
    Snow_Heavy_Start = 7,
    Snow_Heavy_Loop = 8,
    Snow_Heavy_Over = 9
}

--提高类型
BoostType = {
    Speed = "Speed"
}

ToastIconType = {
    Warning = "warning",
    Complete = "complete",
    Upgrade = "upgrade",
    Null = nil
}

ToastListColor = {
    Red = "red",
    Green = "green",
    Blue = "blue",
    Yellow = "yellow",
    Gold = "gold"
}

ToastListIconType = {
    ResourceLow = "icon_toastListCell_resources_low",
    Heal = "icon_toastListCell_heal",
    HealthLow = "icon_toastListCell_health_low",
    Hunger = "icon_toastListCell_hunger",
    Dead = "icon_toastListCell_dead",
    RunAway = "icon_toastListCell_runaway",
    BuildingWhite = "icon_toastListCell_building_white",
    Staff = "icon_toastListCell_staff",
    StaffVIP = "icon_toastListCell_staffVIP",
    Night = "icon_toastListCell_night",
    Day = "icon_toastListCell_day",
    Riots = "icon_riots",
    RiotsWarning = "icon_toastListCell_riotsWarning",
    RiotsStart = "icon_toastListCell_riotsStart",
    FireWarning = "home_icon_tip",
    FireDisable = "icon_toastListCell_fire_disable",
}

TooltipType = {
    Text = "text",
    Item = "item",
    ItemOverTime = "itemOverTime",
    BigText = "bigText",
    Attribute = "attribute",
    ItemConsumption = "itemConsumption",
    Skill = "skill",
    SkillShort = "skillShort",
    TroopsContent = "troopsContent",
    RogueHeroContent = "rogueHeroContent",
    Zone = "zone",
    BoxReward = "boxReward",
    CardLevelRequire = "cardLevelRequire",
    BoostEffect = "boostEffect",
    BoostDesc = "boostDesc",
    BattleSpeedBtnDesc = "battleSpeedBtnDesc"
}

BuildStatus = {
    None = "None",
    AddCard = "home_icon_addcard",
    AddPeople = "home_icon_addpeople",
    NoWork = "home_icon_nowork",
    OK = "home_icon_ok",
    Post = "home_icon_post",
    Up = "home_icon_up",
}

BuildingStatus = {
    Empty = "Empty",
    Complete = "Complete",
    Building = "Building",
}


AdSourceType = {
    UIOffline = "UIOffline",
    UIBuildFoold = "UIBuildFoold",
    UIOfflineReward = "UIOfflineReward",
    UIShopBox = "UIShopBox",
}

LoadStatue = {
    None = 0,
    Loading = 1,
    Loaded = 2,
}
