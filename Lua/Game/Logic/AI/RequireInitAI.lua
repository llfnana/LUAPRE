--具体逻辑
local aiLogic = {
    "FunctionHandles",
    "CharacterController",
 --   "HeroController",
 --   "VanController"--,
  --  "ObjectPoolManager"
}

local LogicPaths = {
    "Manager/GridManager",
    "Manager/CharacterManager",
    "Path/PathFinder",
    "Path/Grid"
}
for i = 1, #aiLogic do
    require("Game.Logic.AI." .. aiLogic[i])
end

for i = 1, #LogicPaths do
    require("Game/Logic/" .. LogicPaths[i])
end

local newAIPaths = {
    "Common.FSMDefine",
    "State.FSMState",
    "State.EntryState",
    "State.ExitState",
    "State.IdleState",
    "State.MoveState",
    "State.WaitState",
    "State.FreemanActionState",
    "State.HuntingActionState",
    "State.CookingActionState",
    "State.ArbeitActionState",
    "State.EatActionState",
    "State.SleepActionState",
    "State.HomeActionState",
    "State.ProtestActionState",
    "State.SevereActionState",
    "State.StrikeActionState",
    "State.RunAwayActionState",
    "State.DeathActionState",
    "State.CelebrateActionState",
    "State.SickActionState",
    "State.DoctorActionState",
    "State.GuardActionState",
    "State.BoilermanActionState",
    "State.VanActionState",
    "System.FSMSystem",
    "System.FSMFreeman",
    "System.FSMCooking",
    "System.FSMArbeit",
    "System.FSMEat",
    "System.FSMHunting",
    "System.FSMSleep",
    "System.FSMHome",
    "System.FSMProtest",
    "System.FSMSevere",
    "System.FSMStrike",
    "System.FSMRunAway",
    "System.FSMDeath",
    "System.FSMCelebrate",
    "System.FSMSick",
    "System.FSMDoctor",
    "System.FSMGuard",
    "System.FSMBoilerman",
    "System.FSMHeroNormal",
    "System.FSMVan",
    "FSMSystemAgent"
}

for i = 1, #newAIPaths do
    require("Game.Logic.AI.FSM." .. newAIPaths[i])
end
