ResourceManager = {}
ResourceManager.__cname = "ResourceManager"

local this = ResourceManager

--根据路径和资源类型加载资源
function ResourceManager.Load(path, type)
    if type then
        return AssetBundleManager.Load(path, type)
    else
        return AssetBundleManager.Load(path)
    end
end

--实例化资源
function ResourceManager.Instantiate(pathOrPrefab, parent, ignoreQueue)
    ignoreQueue = ignoreQueue or false
    local prefab = nil
    if type(pathOrPrefab) == "string" then
        prefab = this.Load(pathOrPrefab, TypeGameObject)
    else
        prefab = pathOrPrefab
    end
    if nil == prefab then
        return nil
    end
    local obj
    if parent then
        obj = Object.Instantiate(prefab, parent)
    else
        obj = Object.Instantiate(prefab)
    end
    -- if BattleUIManager.IsExistBattleScene() == true then
    --     if obj and not ignoreQueue and not GameManager.isEditor then
    --         AppRender.SetGameObjectQueue(obj.transform)
    --     end
    -- end

    return obj
end

-- this.quenes = Dictionary:New()
-- this.queueOpaque = 2000
-- this.queueTransparent = 3000

-- function ResourceManager.SetGameObjectQueue(obj)
--     local renderers = obj:GetComponentsInChildren(TypeRenderer)
--     if obj.name == "Generator_Lv2" then
--     end
--     for i = 0, renderers.Length - 1, 1 do
--         if nil ~= renderers[i] and nil ~= renderers[i].sharedMaterial then
--             this.SetQueue(renderers[i])
--         end
--     end
-- end

-- function ResourceManager.SetQueue(renderer)
--     local material = renderer.sharedMaterial
--     if nil == material then
--         return
--     end
--     local renderType = material:GetTag("RenderType", true, "None")
--     if renderType == "Transparent" then
--         if this.quenes:ContainsKey(material) then
--             material.renderQueue = this.quenes[material]
--         else
--             material.renderQueue = this.queueTransparent
--             this.quenes:Add(material, this.queueTransparent)
--             this.queueTransparent = this.queueTransparent + 1
--         end
--     elseif renderType == "Opaque" and not material:HasProperty("_QueueOffset") then
--         if this.quenes:ContainsKey(material) then
--             material.renderQueue = this.quenes[material]
--         else
--             material.renderQueue = this.queueOpaque
--             this.quenes:Add(material, this.queueOpaque)
--             this.queueOpaque = this.queueOpaque + 1
--         end
--     end
-- end

--回收
function ResourceManager.Destroy(go)
    Object.Destroy(go)
end
