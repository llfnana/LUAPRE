local FrameworkPths = {
    "Common/DefineEx",
    "Common/Function",
    "Common/ClassEx",
    --    "Common/EventLib",
    --    "Common/Event",
    "Common/MonoEvent",
    "Common/Mono",
    "Common/MonoFunction",
    "Common/TimerFunction",
    "Common/NumberRx",
    "Struct/Dictionary",
    "Struct/InvokeRepeating",
    "Struct/ListEx",
    "Struct/Queue",
    "Struct/PriorityQueue",
    "Struct/Stack",
    "StateMachine/StateMachine",
    "Mode/ModeNormal",
    "Time/LTimer",
    "Time/LTimerManager"
}

for i = 1, #FrameworkPths do
    require("Game/Framework/" .. FrameworkPths[i])
end

local LogicPaths = {
    "GGameDefine",
    "Tool/Utils",
    "Tool/Time2",
    "Mode/ModeLoading",
    "Mode/ModeMainScene",
    "Mode/ModeChangeScene",
    -- "Mode/ModeBattleScene",
    -- "Mode/DiyModeBattleScene",
    -- "Mode/RoguelikeScene",
    -- "Mode/ModeRebootScene",
    -- "Mode/ModeBindAccountScene",
    "Model/City/CityCharUI",
    "Model/City/CityUtils",
    "Model/City/CityBase",
    "Model/City/CityTest",
    "Model/City/CityData",
    "Model/City/CityMap",
    "Model/City/CityClock",
    "Model/City/CityProtest",
    "Model/City/CityWorkOverTime",
    "Model/City/CityFoodSystem",
    "Model/City/CitySchedules",
    "Model/City/CityTask",
    "Model/City/CityBoost",
    "Model/City/CityGrid",
    "Model/City/CityCharacter",
    "Model/City/CityGenerator",
    "Model/City/CityStatistical",
    "Model/City/CityOverTimeProduction",
    "Model/City/CityWeather",
    "Controller/ModeController",
    "Model/MapItemData",
    "Model/CardItemData",
    "Model/Task/TaskBase",
    "Model/Boost/BoostBase",
    "Model/Boost/BoostFactor",
    "Model/Tutorial/TutorialBase",
    "Model/Functions/FunctionsBase",
    "Model/Push/PushBase",
    "Manager/ResourceManager",
    "Manager/ConfigManager",
    "Manager/EventManager",
    --"Manager/NetManager",
   -- "Manager/SDKManager",
    "Manager/AdManager",
    "Manager/PaymentManager",
    -- "Manager/AudioManager",
    "Manager/GameManager",
    "Manager/DataManager",
    "Manager/CityManager",
    "Manager/MapManager",
    "Manager/TimeManager",
   -- "Manager/SkillBulletManager",
    "Manager/SchedulesManager",
    "Manager/FoodSystemManager",
    "Manager/GeneratorManager",
    "Manager/FloatIconManager",
    "Manager/CardManager",
    "Manager/DiyCardManager",
    "Manager/TaskManager",
   "Manager/HeroBattleDataManager",
    --"Manager/SkillManager",
   -- "Manager/PassiveSkillManager",
    "Manager/FunctionsManager",
    "Manager/ProtestManager",
    "Manager/WeatherManager",
    "Manager/WorkOverTimeManager",
    "Manager/TestManager",
    "Manager/BoostManager",
    "Manager/BoxManager",
   -- "Manager/AppRateManager",
   -- "Manager/AdventureContManager",
    "Manager/StatisticalManager",
   -- "Manager/ToolTipManager",
    "Manager/SurveyManager",
    "Manager/OfflineManager",
    "Manager/TutorialManager",
    "Manager/ResAddEffectManager",
    "Manager/DiscordTipManager",
    "Manager/Analytics",
    "Manager/SDKAnalytics",
    "Manager/MailManager",
    "Manager/HaloManager",
    --"Manager/HelpShiftManager",
    --"Manager/BattleUIManager",
    "Manager/TroopsComponentManager",
    "Manager/DissolveCardManager",
    "Manager/ShopManager",
    "Manager/OverTimeProductionManager",
    "Manager/HappyMailManager",
   -- "Manager/CameraManager",
    --"Manager/FirebaseManager",
    "Manager/DailyShoutManager",
    "Manager/DailyBagManager",
    "Manager/CityPassManager",
   -- "Manager/EventSceneManager",
    --"Manager/SceneUtil",
   -- "Manager/CameraEffectManager",
   -- "Manager/RoguelikeDataManager",
  --  "Manager/RoguelikeLogicManager",
   -- "Manager/RoguelikeSkillManager",
   -- "Manager/ProfileManager",
   -- "Manager/LeaderboardManager",
    "Manager/PersistManager",
    "Manager/AlertPanelManager",
    "Manager/PostStationManager",
    "Manager/PushNotifyManager",
    "Manager/PlayerRatingManager",
    "Manager/MapUIManager",
    "Manager/UserTypeManager",
    "Manager/UpdateCompensateManager",
    "Manager/PopupManager",
    "Model/StoryBook/StoryBookManager",
    "Tutorial/TutorialHelper",
}

for i = 1, #LogicPaths do
    require("Game/Logic/" .. LogicPaths[i])
end

-- local EcsPaths = {
--     "Ecs/Core/UObject",
--     "Ecs/Core/ECSComponent",
--     "Ecs/Core/ECSEntity",
--     "Ecs/Core/ECSSystem",
--     "Ecs/Core/Token",
--     "Ecs/Entity/SceneEntity",
--     "Ecs/Entity/SpriteEntity",
--     "Ecs/Component/HpComponent",
--     "Ecs/Component/RoleAiComponent",
--     "Ecs/Component/SceneComponent",
--     "Ecs/Component/NaveMeshTagComponent",
--     "Ecs/Component/NavMeshAgentComponent",
--     "Ecs/Component/AnimatorComponent",
--     "Ecs/Component/SkillComponent",
--     "Ecs/Component/BuffComponent",
--     "Ecs/Component/TeamSeatComponent",
--     "Ecs/Component/RoguelikeSkillComponent",
--     "Ecs/System/MonsterAISystem",
--     "Ecs/System/NavMeshAgentSystem",
--     "Ecs/System/AnimatorSystem",
--     "Ecs/System/SkillRequestSystem",
--     "Ecs/System/SkillCDSystem",
--     "Ecs/System/SkillCDSystem",
--     "Ecs/System/SceneSystem",
--     "Ecs/System/InitBattleSceneSystem",
--     "Ecs/System/HangUpBattleSceneSystem",
--     "Ecs/System/BuffSystem",
--     "Ecs/System/DiyBattleSystem",
--     "Ecs/System/RoguelikeSceneSystem"
-- }

-- for i = 1, #EcsPaths do
--     require("Game/Logic/" .. EcsPaths[i])
-- end

--local world = ECSSystem.new(false, true)
--local monsterAISystem = MonsterAISystem.new()
--world:AddSystem(monsterAISystem)

--local navMeshAgentSystem = NavMeshAgentSystem.new()
--world:AddSystem(navMeshAgentSystem)

--local animatorSystem = AnimatorSystem.new()
--world:AddSystem(animatorSystem)

--local skillRequestSystem = SkillRequestSystem.new()
--world:AddSystem(skillRequestSystem)

--local skillCDSystem = SkillCDSystem.new(true)
--world:AddSystem(skillCDSystem)

--local buffSystem = BuffSystem.new()
--world:AddSystem(buffSystem)

--local initBattleSceneSystem = InitBattleSceneSystem.new()

--local hangUpBattleSceneSystem = HangUpBattleSceneSystem.new()

--local diyBattleSystem = DiyBattleSystem.new()

--local roguelikeSystem = RoguelikeSceneSystem.new()

---- world:AddSystem(initBattleSceneSystem)

--ECS = {
--    world = world,
--    monsterAISystem = monsterAISystem,
--    navMeshAgentSystem = navMeshAgentSystem,
--    animatorSystem = animatorSystem,
--    skillRequestSystem = skillRequestSystem,
--    skillCDSystem = skillCDSystem,
--    buffSystem = buffSystem,
--    initBattleSceneSystem = initBattleSceneSystem,
--    diyBattleSystem = diyBattleSystem,
--    hangUpBattleSceneSystem = hangUpBattleSceneSystem,
--    roguelikeSystem = roguelikeSystem
--}

require("Game/Logic/AI/RequireInitAI")

GM = require("Game/GM")

require("Common/version")
require("Game/Logic/Model/FactoryGameData")
