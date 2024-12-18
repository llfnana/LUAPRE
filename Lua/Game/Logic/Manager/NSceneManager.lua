NSceneManager = {}
NSceneManager._name = "NSceneManager"
this = NSceneManager

function NSceneManager.Init()
end

function NSceneManager.SwichScene()
    --ResourceManager.Destroy(GameObject.Find("MainUI(Clone)").gameObject)
    local Challenge = ResourceManager.Instantiate("UI/ChallengePanel")
    UnityEngine.Object.DontDestroyOnLoad(Challenge)
    local uicameraObj = GameObject.Find("UICamera")
    UnityEngine.Object.DontDestroyOnLoad(uicameraObj)
    AssetBundleManager.LoadScene("FrozenCity_Battle")
end

function NSceneManager.GetPlayData()
    local posList = {}
    for index = 1, 1 do
        local pos = GameObject.Find("Pos_Player").transform.position
        table.insert(posList, pos)
    end
    local name = {"Shiquan"}
    local hp = {2000}
    local list = {}
    for index = 1, 1 do
        local data = {}
        data.pos = posList[index]
        data.name = name[index]
        data.hp = hp[index]
        data.dir = Vector3(-1, 0, 0)
        table.insert(list, index, data)
    end
    return list
end

function NSceneManager.GetEnemyData()
    local posList = {}
    for index = 1, 1 do
        local pos = GameObject.Find("Pos_Enemy").transform.position
        table.insert(posList, pos)
    end
    local name = {"kelaier"}
    local hp = {1500}
    local list = {}
    for index = 1, 1 do
        local data = {}
        data.pos = posList[index]
        data.name = name[index]
        data.hp = hp[index]
        data.dir = Vector3(1, 0, 0)
        table.insert(list, index, data)
    end
    return list
end

function NSceneManager.CreatePlay()
    --创建场景
    local sceneEntity, sceneComp = SceneEntity.Create(100001) --sceneid 100001

    local data = NSceneManager.GetPlayData()
    for index = 1, 1 do
        local spriteEntity = SpriteEntity.Create(0, 100001, 1, data[index].pos, data[index].dir, data[index].name)
        sceneComp:AddPlayerEntity(spriteEntity)
        local hpcom = spriteEntity:GetComponent(HpComponent)
        hpcom.current = data[index].hp
        local AIComp = RoleAiComponent.new()
        spriteEntity:AddComponent(AIComp)
        AIComp:InitAiComp(false)
        ECS.monsterAISystem:AddEntity(spriteEntity)
        spriteEntity:BindUObject()
    end
end

function NSceneManager.CreateEnemy()
    local sceneEntity = SceneEntity.currentScene
    local sceneComp = sceneEntity:GetComponent(SceneComponent)
    local data = NSceneManager.GetEnemyData()
    for index = 1, 1 do
        local spriteEntity = SpriteEntity.Create(1, 100002, 1, data[index].pos, data[index].dir, data[index].name)
        sceneComp:AddMonsterEntity(spriteEntity)
        local hpcom = spriteEntity:GetComponent(HpComponent)
        hpcom.current = data[index].hp
        local AIComp = RoleAiComponent.new()
        spriteEntity:AddComponent(AIComp)
        AIComp:InitAiComp(false)
        ECS.monsterAISystem:AddEntity(spriteEntity)
        spriteEntity:BindUObject()
    end
end

function NSceneManager.CreateTeam()
    NSceneManager.CreatePlay()
    NSceneManager.CreateEnemy()
end

function NSceneManager.OnBeginBattle()
    local sceneEntity = SceneEntity.currentScene
    local sceneComp = sceneEntity:GetComponent(SceneComponent)
    for i, v in pairs(sceneComp.playerEntities) do
        local roleAi = v:GetComponent(RoleAiComponent)
        roleAi.BeginBattle = true
    end

    for i, v in pairs(sceneComp.monsterEntities) do
        local roleAi = v:GetComponent(RoleAiComponent)
        roleAi.BeginBattle = true
    end
end
