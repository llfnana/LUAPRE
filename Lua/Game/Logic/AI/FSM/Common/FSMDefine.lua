FSMConst = {}
FSMConst.TRANSITION_TIME = 1
FSMConst.TUTORIAL_MOVE_SPEED_PERCENT = 2

--状态id
StateId = {
    None = "None",
    EntryState = "EntryState",  --进入状态
    ExitState = "ExitState",
    --FreeMan Home   --荣誉市民; 自由民(非奴隶); 家
    MoveToDormDoor = "MoveToDormDoor",  --宿舍
    MoveToDormTool2 = "MoveToDormTool2",
    MoveToDormTool3 = "MoveToDormTool3",
    MoveToDormTool4 = "MoveToDormTool4",
    MoveToDormTool5 = "MoveToDormTool5",
    MoveToDormTool6 = "MoveToDormTool6",
    MoveToDormIdle = "MoveToDormIdle",
    RunWithDormTool2 = "RunWithDormTool2",
    RunWithDormTool3 = "RunWithDormTool3",
    RunWithDormTool4 = "RunWithDormTool4",
    RunWithDormTool5 = "RunWithDormTool5",
    RunWithDormTool6 = "RunWithDormTool6",
    RunWithDormIdle = "RunWithDormIdle",
    --Cooking
    MoveToKitchenBurner = "MoveToKitchenBurner",
    MoveToKitchenSpecial1 = "MoveToKitchenSpecial1",
    MoveToKitchenIdle = "MoveToKitchenIdle",
    RunWithKitchenBurner = "RunWithKitchenBurner",
    RunWithKitchenSpecial1 = "RunWithKitchenSpecial1",
    RunWithKitchenIdle = "RunWithKitchenIdle",
    --Hunting
    MoveToHunterCabinDoor = "MoveToHunterCabinDoor",
    MoveToHunterCabinTool = "MoveToHunterCabinTool",
    MoveToHunt = "MoveToHunt",
    MoveToKitchenItems = "MoveToKitchenItems",
    MoveToHunterCabinItems = "MoveToHunterCabinItems",
    MoveToHunterCabinSpecial1 = "MoveToHunterCabinSpecial1",
    MoveToHunterCabinIdle = "MoveToHunterCabinIdle",
    RunWithHunterCabinTool = "RunWithHunterCabinTool",
    RunWithHunt = "RunWithHunt",
    RunWithItems = "RunWithItems",
    RunWithHunterCabinSpecial1 = "RunWithHunterCabinSpecial1",
    RunWithHunterCabinIdle = "RunWithHunterCabinIdle",
    --Arbeit 劳动; 打工;
    MoveToArbeitDoor = "MoveToArbeitDoor",
    MoveToArbeitTool = "MoveToArbeitTool",
    MoveToArbeitIdle = "MoveToArbeitIdle",
    RunWithArbeitTool = "RunWithArbeitTool",
    RunWithArbeitIdle = "RunWithArbeitIdle",
    --Eat
    MoveToKitchenDoor = "MoveToKitchenDoor",
    MoveToKitchenQueue = "MoveToKitchenQueue",
    MoveToServingTable = "MoveToServingTable",
    MoveToKitchenTable = "MoveToKitchenTable",
    RunWithQueueWait = "RunWithQueueWait",
    RunWithServingTable = "RunWithServingTable",
    RunWithServingTableWait = "RunWithServingTableWait",
    RunWithKitchenTable = "RunWithKitchenTable",
    RunWithEatStop = "RunWithEatStop",
    --Sleep
    MoveToDormBed = "MoveToDormBed",
    RunWithDormBed = "RunWithDormBed",
    --Severe 严峻的; 严厉的; 极为恶劣的
    MoveToMedicalBed = "MoveToMedicalBed",
    RunWithSevereAction = "RunWithSevereAction",
    --Protest 抗议
    MoveToProtest = "MoveToProtest",
    RunWithProtest = "RunWithProtest",
    --Strike  罢工
    MoveToBorn = "MoveToBorn",
    RunWithStrikeAction = "RunWithStrikeAction",
    --RunAway 逃跑的
    RunWithRunAwayAction = "RunWithRunAwayAction",
    --Death
    RunWithDeathAction = "RunWithDeathAction",
    --Celebrate  庆祝
    RunWithCelebrateAction = "RunWithCelebrateAction",
    --Sick 生病的
    RunWithSickAction = "RunWithSickAction",
    RunWithSevereChange = "RunWithSevereChange",
    --Doctor 医生
    MoveToDoctor = "MoveToDoctor",
    MoveToInfirmaryIdle = "MoveToInfirmaryIdle",
    RunWithDoctor = "RunWithDoctor",
    RunWithInfirmaryIdle = "RunWithInfirmaryIdle",
    --Guard 警卫
    MoveToSpeech = "MoveToSpeech",
    MoveToMainRoadIdle = "MoveToMainRoadIdle",
    RunWithSpeech = "RunWithSpeech",
    RunWithMainRoadIdle = "RunWithMainRoadIdle",
    --Boilerman 锅炉工
    MoveToGeneratorSpecial1 = "MoveToGeneratorSpecial1",
    MoveToGeneratorSpecial2 = "MoveToGeneratorSpecial2",
    MoveToGeneratorSpecial3 = "MoveToGeneratorSpecial3",
    MoveToGeneratorIdle = "MoveToGeneratorIdle",
    RunWithGeneratorSpecial1 = "RunWithGeneratorSpecial1",
    RunWithGeneratorSpecial2 = "RunWithGeneratorSpecial2",
    RunWithGeneratorSpecial3 = "RunWithGeneratorSpecial3",
    RunWithGeneratorIdle = "RunWithGeneratorIdle",
    --Hero
    MoveToHeroIdle = "MoveToHeroIdle",
    RunWithHeroIdle = "RunWithHeroIdle",
    --Van  厢式货车
    MoveToVanQueue = "MoveToVanQueue",
    MoveToWarehouseQueue = "MoveToWarehouseQueue",
    MoveToWarehouseTool = "MoveToWarehouseTool",
    MoveToVanDestroy = "MoveToVanDestroy",
    RunWithVanQueueWait = "RunWithVanQueueWait",
    RunWithWarehouseTool = "RunWithWarehouseTool",
    RunWithVanBorn = "RunWithVanBorn",
    RunWithVanBornWait = "RunWithVanBornWait"
}

--过度条件检测类型
CheckType = {
    None = 0,
    Process = 1,
    Complete = 2
}

--转换条件id
FSMTransitionType = {
    StayAtIdle = "StayAtIdle",
    StayAtBed = "StayAtBed",
    StayAtMedicalBed = "StayAtMedicalBed",
    StayAtSpecial1 = "StayAtSpecial1",
    --FreeMan
    FreemanExit = "FreemanExit",
    FreemanMoveToDormDoor = "FreemanMoveToDormDoor",
    FreemanMoveToDormTool2 = "FreemanMoveToDormTool2",
    FreemanMoveToDormTool3 = "FreemanMoveToDormTool3",
    FreemanMoveToDormTool4 = "FreemanMoveToDormTool4",
    FreemanMoveToDormTool5 = "FreemanMoveToDormTool5",
    FreemanMoveToDormTool6 = "FreemanMoveToDormTool6",
    FreemanMoveToDormIdle = "FreemanMoveToDormIdle",
    FreemanRunWithDormTool2 = "FreemanRunWithDormTool2",
    FreemanRunWithDormTool3 = "FreemanRunWithDormTool3",
    FreemanRunWithDormTool4 = "FreemanRunWithDormTool4",
    FreemanRunWithDormTool5 = "FreemanRunWithDormTool5",
    FreemanRunWithDormTool6 = "FreemanRunWithDormTool6",
    --Beer
    BeerExit = "BeerExit",
    BeerMoveToDoor = "BeerMoveToDoor",
    BeerMoveToBurner = "BeerMoveToBurner",
    BeerMoveToSpe = "BeerMoveToSpe",
    BearMoveToIdle = "BearMoveToIdle",
    BearRunWithBurner = "BearRunWithBurner",
    --Animal
    AnimalExit = "AnimalExit",
    AnimalMoveToDoor = "AnimalMoveToDoor",
    AnimalMoveToTool = "AnimalMoveToTool",
    AnimalMoveToHunt = "AnimalMoveToHunt",
    AnimalMoveToKitchenItems = "AnimalMoveToKitchenItems",
    AnimalMoveToHunterItems = "AnimalMoveToHunterItems",
    AnimalMoveToSpe = "AnimalMoveToSpe",
    AnimalMoveToIdle = "AnimalMoveToIdle",
    AnimalRunWithTool = "AnimalRunWithTool",
    AnimalRunWithHunt = "AnimalRunWithHunt",
    AnimalRunWithItems = "AnimalRunWithItems",
    --Arbeit
    ArbeitExit = "ArbeitExit",
    ArbeitMoveToDoor = "ArbeitMoveToDoor",
    ArbeitMoveToTool = "ArbeitMoveToTool",
    ArbeitMoveToIdle = "ArbeitMoveToIdle",
    ArbeitRunWithTool = "ArbeitRunWithTool",
    --Eat
    EatExit = "EatExit",
    EatNoKitchen = "EatNoKitchen",
    EatStop = "EatStop",
    EatNoFood = "EatNoFood",
    EatMoveToKitchenDoor = "EatMoveToKitchenDoor",
    EatMoveToKitchenQueue = "EatMoveToKitchenQueue",
    EatMoveToServingTable = "EatMoveToServingTable",
    EatMoveToKitchenTable = "EatMoveToKitchenTable",
    EatRunWithKitchenDoor = "EatRunWithKitchenDoor",
    EatRunWithQueueWait = "EatRunWithQueueWait",
    EatRunWithServingTable = "EatRunWithServingTable",
    EatServingTableWait = "EatServingTableWait",
    EatRunWithTable = "EatRunWithTable",
    --Sleep
    SleepExit = "SleepExit",
    SleepMoveToDormDoor = "SleepMoveToDormDoor",
    SleepMoveToDormBed = "SleepMoveToDormBed",
    SleepRunWithDormBed = "SleepRunWithDormBed",
    --Home
    HomeExit = "HomeExit",
    HomeMoveToDormDoor = "HomeMoveToDormDoor",
    HomeMoveToDormTool2 = "HomeMoveToDormTool2",
    HomeMoveToDormTool3 = "HomeMoveToDormTool3",
    HomeMoveToDormTool4 = "HomeMoveToDormTool4",
    HomeMoveToDormTool5 = "HomeMoveToDormTool5",
    HomeMoveToDormTool6 = "HomeMoveToDormTool6",
    HomeMoveToDormIdle = "HomeMoveToDormIdle",
    HomeRunWithDormTool2 = "HomeRunWithDormTool2",
    HomeRunWithDormTool3 = "HomeRunWithDormTool3",
    HomeRunWithDormTool4 = "HomeRunWithDormTool4",
    HomeRunWithDormTool5 = "HomeRunWithDormTool5",
    HomeRunWithDormTool6 = "HomeRunWithDormTool6",
    --Severe
    SevereExit = "SevereExit",
    SevereMoveToMedicalBed = "SevereMoveToMedicalBed",
    SevereMoveToDormBed = "SevereMoveToDormBed",
    --Protest
    ProtestExit = "ProtestExit",
    ProtestMoveToTool = "ProtestMoveToTool",
    ProtestRunWithTool = "ProtestRunWithTool",
    --Strike
    StrikeExit = "StrikeExit",
    StrikeMoveToBorn = "StrikeMoveToBorn",
    StrikeRunWithAction = "StrikeRunWithAction",
    --RunAway
    RunAwayExit = "RunAwayExit",
    RunAwayMoveToBorn = "RunAwayMoveToBorn",
    RunAwayRunWithAction = "RunAwayRunWithAction",
    --Death
    DeathExit = "DeathExit",
    DeathRunWithAction = "DeathRunWithAction",
    --Celebrate
    CelebrateExit = "CelebrateExit",
    CelebrateRunWithAction = "CelebrateRunWithAction",
    --Sick
    SickExit = "SickExit",
    SickRunWithAction = "SickRunWithAction",
    SickChangeToSevere = "SickChangeToSevere",
    --Doctor
    DoctorExit = "DoctorExit",
    DoctorMoveToDoctor = "DoctorMoveToDoctor",
    DoctorMoveToInfirmaryIdle = "DoctorMoveToInfirmaryIdle",
    DoctorRunWithDoctor = "HealRunWithDoctor",
    --Guard
    GuardExit = "GuardExit",
    GuardMoveToSpeech = "GuardMoveToSpeech",
    GuardMoveToMainRoadIdle = "GuardMoveToMainRoadIdle",
    GuardRunWithSpeeh = "GuardRunWithSpeeh",
    --Boilerman
    BoilermanExit = "BoilermanExit",
    BoilermanMoveToSpecial1 = "BoilermanMoveToSpecial1",
    BoilermanMoveToSpecial2 = "BoilermanMoveToSpecial2",
    BoilermanMoveToSpecial3 = "BoilermanMoveToSpecial3",
    BoilermanMoveToIdle = "BoilermanMoveToIdle",
    BoilermanRunWithSpecial1 = "BoilermanRunWithSpecial1",
    BoilermanRunWithSpecial2 = "BoilermanRunWithSpecial2",
    BoilermanRunWithSpecial3 = "BoilermanRunWithSpecial3",
    --Hero
    HeroExit = "HeroExit",
    HeroMoveToIdle = "HeroMoveToIdle",
    --Van
    VanMoveToVanQueue = "VanMoveToVanQueue",
    VanMoveToWarehouseQueue = "VanMoveToWarehouseQueue",
    VanMoveToWarehouseTool = "VanMoveToWarehouseTool",
    VanMoveToVanDestroy = "VanMoveToVanDestroy",
    VanRunWithVanQueueWait = "VanRunWithVanQueueWait",
    VanRunWithWarehouseQueueWait = "VanRunWithWarehouseQueueWait",
    VanRunWithWarehouseTool = "VanRunWithWarehouseTool",
    VanRunWithVanBorn = "VanRunWithVanBorn",
    VanRunWithVanBornWait = "VanRunWithVanBornWait"
}

--转换事件 全局唯一
TransitionHandles = {}
-----------------------------------------
---是否在Idle点
-----------------------------------------
TransitionHandles[FSMTransitionType.StayAtIdle] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Idle
end
-----------------------------------------
---是否在Bed点
-----------------------------------------
TransitionHandles[FSMTransitionType.StayAtBed] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Bed
end
-----------------------------------------
---是否在MedicalBed点
-----------------------------------------
TransitionHandles[FSMTransitionType.StayAtMedicalBed] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.MedicalBed
end
-----------------------------------------
---是否在Special点
-----------------------------------------
TransitionHandles[FSMTransitionType.StayAtSpecial1] = function(fsm)
    if nil == fsm.owner.currGrid then
        return false
    end
    return fsm.owner.currGrid.markerType == GridMarker.Special1ForIdle
end
