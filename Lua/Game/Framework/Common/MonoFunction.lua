---打印函数
function Log(msg)
    -- Debug.Log(tostring(msg))
    -- Debug.Log(tostring(msg) .. "\n" .. debug.traceback())
end

function LogFormat(format, ...)
    -- Debug.LogFormat(format, ...)
end

function LogWarning(msg)
    -- Debug.LogWarning(msg)
end

function LogWarningFormat(format, ...)
    -- Debug.LogWarningFormat(format, ...)
end
----

local timeCache = 0
function LogDelay(msg)
    local delay = (os.clock() - timeCache) * 1000
    timeCache = os.clock()
    if msg ~= nil then
        -- Debug.Log(tostring(msg) .. ": " .. string.format("%.2f", delay) .. "ms")
    else
        -- Debug.Log("Delay: " .. string.format("%.2f", delay) .. "ms")
    end
end

--
function InitGameObject(go)
    if go then
        go.transform.localPosition = Vector3.zero
        go.transform.localRotation = Quaternion.identity
        go.transform.localScale = Vector3.one
    end
end

function SetGameObjectParent(parent, go)
    SetTransformParent(parent, go.transform)
end

function SetTransformParent(parent, ts)
    ts:SetParent(parent)
    ts.localPosition = Vector3.zero
    ts.localRotation = Quaternion.identity
    -- ts.localScale = Vector3.one
end

--创建新都组件
--name 组建名字
--parent 组建父
function NewGameObject(name, parent)
    local go = GameObject(name)
    SetGameObjectParent(parent, go)
    return go
end

--根据路径和类型获取组件
--go 父组件
--path 组件中的相对路径
--typeName 要获取的子组件类型
function GetComponentByPath(go, path, typeName)
    local tf = go.transform:Find(path)
    if tf == nil then
        return nil
    end
    return tf.gameObject:GetComponent(typeName)
end

function AddComponment(go, typeName)
    return go:AddComponent(typeName)
end

--根据类型获取
--go 父组件
--path 组件中的相对路径
function GetGameObject(go, path)
    return go.transform:Find(path).gameObject
end

--根据类型获取组件
--go 父组件
--type 要获取的子组件类型
function GetComponent(go, typeName)
    local cls = go:GetComponent(typeName)
    if not cls then
        cls = AddComponment(go, typeName)
    end
    return cls
end

--根据类型获取组件
--go 父组件
--type 要获取的子组件类型
function GetComponentByTransform(ts, typeName)
    return ts.gameObject:GetComponent(typeName)
end

--获取子组件
--go 父组件
--type 要获取的子组件类型
--tag 组件的tag
--retys 返回要获取的所有组件
function GetComponentsInChildren(go, typeName, tag)
    local tys = go:GetComponentsInChildren(typeName)
    if tag == nil then
        return tys
    end
    local retys = {}
    for key, value in pairs(tys) do
        if value.gameobject.tag == tag then
            table.insert(retys, value)
        end
    end
    return retys
end

function GetComponentInChildren(go, typeName)
    return go:GetComponentInChildren(typeName)
end

--从go获取luaTable
function GetTableFromGameobject(go)
    local tbl
    if go then
        local luaBehaviour = go:GetComponent(TypeLuaMonoBehaviour)
        if luaBehaviour then
            tbl = luaBehaviour.LuaTable
        end
    end
    return tbl
end

function GetTransformInChildren(parent, childName)
    local count = parent.transform.childCount
    if count == 0 then
        return nil
    end
    local child = parent.transform:Find(childName)
    if nil ~= child then
        return child
    end
    for i = 0, count - 1 do
        child = GetTransformInChildren(parent.transform:GetChild(i).gameObject, childName)
        if nil ~= child then
            break
        end
    end
    return child
end

function GetTransformsInChildren(parentTs, childName)
    local childs = {}
    local function ForeachParent(ts)
        if nil ~= ts then
            local item = ts:Find(childName)
            if nil ~= item then
                table.insert(childs, item)
            end
            local childCount = ts.childCount
            for i = 0, childCount - 1 do
                ForeachParent(ts:GetChild(i))
            end
        end
    end
    ForeachParent(parentTs)
    return childs
end
