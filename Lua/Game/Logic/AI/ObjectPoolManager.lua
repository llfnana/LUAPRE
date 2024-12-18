ObjectPoolManager = {}
ObjectPoolManager.__cname = "ObjectPoolManager"

local this = ObjectPoolManager
local nofirst = false


function ObjectPoolManager.Init()
    if nofirst then
        return
    end
    nofirst = true
    ---@type Dictionary
    this.deadCaches = Dictionary:New()
    this.objectPool = GameObject("ObjectPool").transform
    UnityEngine.Object.DontDestroyOnLoad(this.objectPool)
end

function ObjectPoolManager.Clear()
    this.deadCaches:ForEachKeyValue(
        function(name, cache)
            if cache ~= nil then
                for i = 1, cache:Count() do
                    GameObject.Destroy(cache[i].gameObject)
                   
                end
            end
        end
    )
    this.deadCaches:Clear()
    -- GameObject.Destroy(this.objectPool.gameObject)
end

function ObjectPoolManager.GetController(name, parent)
    local go = GameObject(name)
    go.transform:SetParent(parent, false)
    return GetComponent(go, TypeLuaMonoBehaviour).LuaTable
end

function ObjectPoolManager.GetCharacterViewGpu()
    local poolName = "Skin_male_2_gpu"
    local objectView = nil
    local ret, value = this.deadCaches:TryGetValue(poolName)
    if ret and value ~= nil and value:Count() > 0 then
        objectView = value[1]
        value:RemoveAt(1)
    end

    if objectView then
        objectView.gameObject:SetActive(true)
    else
        local modelPath = "prefab/character/" .. poolName
        local model = ResourceManager.Instantiate(modelPath, this.objectPool)
        objectView = {}
        objectView.poolName = poolName
        objectView.gameObject = model
        objectView.animator = model
    end
    return objectView
end

--从缓存池中获取角色
function ObjectPoolManager.GetCharacterView(cityId, gender, skinId)
    local poolName = ""
    if CityManager.GetIsEventScene(cityId) then
        poolName = "Skin_" .. gender .. "_" .. cityId .. "_" .. skinId
    else
        poolName = "Skin_" .. gender .. "_" .. skinId
    end
    local objectView = nil
    local ret, value = this.deadCaches:TryGetValue(poolName)
    if ret and value ~= nil and value:Count() > 0 then
        objectView = value[1]
        value:RemoveAt(1)
    end

    if objectView then
        objectView.gameObject:SetActive(true)
    else
        local modelPath = "prefab/character/" .. poolName
        local model = ResourceManager.Instantiate(modelPath, this.objectPool)
        objectView = {}
        objectView.poolName = poolName
        objectView.gameObject = model
        objectView.animationAgent = AddComponment(model, TypeAnimatorAgent)
        objectView.animator = GetComponent(model, TypeAnimator)
    end
    return objectView
end

function ObjectPoolManager.GetHeroView(poolName)
    local objectView = nil
    local ret, value = this.deadCaches:TryGetValue(poolName)
    if ret and value ~= nil and value:Count() > 0 then
        objectView = value[1]
        value:RemoveAt(1)
    end
    if objectView then
        objectView.gameObject:SetActive(true)
    else
        local modelPath = "prefab/office/office_" .. poolName
        local model = ResourceManager.Instantiate(modelPath, this.objectPool)
        objectView = {}
        objectView.poolName = poolName
        objectView.gameObject = model
        objectView.animator = GetComponent(model, TypeAnimator)
    end
    return objectView
end

function ObjectPoolManager.GetTransportView(resourceName)
    local poolName = "Transport"
    local objectView = nil
    local ret, value = this.deadCaches:TryGetValue(poolName)
    if ret and value ~= nil and value:Count() > 0 then
        objectView = value[1]
        value:RemoveAt(1)
    end
    if objectView then
        objectView.gameObject:SetActive(true)
    else
        local model = ResourceManager.Instantiate("prefab/character/car/" .. resourceName, this.objectPool)
        objectView = {}
        objectView.poolName = poolName
        objectView.gameObject = model
        objectView.transform = model.transform
        objectView.animator = GetComponent(model, TypeAnimator)
    end
    return objectView
end

function ObjectPoolManager.GetSceneView(viewType)
    local objectView = nil
    local ret, value = this.deadCaches:TryGetValue(viewType)
    if ret and value ~= nil and value:Count() > 0 then
        objectView = value[1]
        value:RemoveAt(1)
    end
    if objectView then
        objectView.gameObject:SetActive(true)
    else
        require("Game/Logic/View/UI/" .. viewType)
        local modelPath = "ui/View/" .. viewType
        local model = ResourceManager.Instantiate(modelPath, this.objectPool)
        objectView = {}
        objectView.poolName = viewType
        objectView.gameObject = model
        objectView.transform = model.transform
        objectView.luaTable = GetTableFromGameobject(model)
    end
    return objectView
end

function ObjectPoolManager.BackToPool(objectView)
    objectView.gameObject.transform:SetParent(this.objectPool, false)
    objectView.gameObject.transform.position = Vector3(-10000, 0, -10000)
    local poolName = objectView.poolName
    local ret, value = this.deadCaches:TryGetValue(poolName)
    if not ret or value == nil then
        local cache = List:New()
        cache:Add(objectView)
        this.deadCaches:Add(poolName, cache)
    else
        value:Add(objectView)
    end
end
