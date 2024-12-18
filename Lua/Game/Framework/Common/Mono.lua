--===========================================================================
-- 本地属性和方法创建mono更新对象
--===========================================================================
local MonoUpdate = {}

function MonoUpdate:Create(owner, eventName)
    local cls = Clone(self)
    cls.owner = owner
    cls.eventName = eventName
    return cls
end

function MonoUpdate:SetHandle(func)
    if self.handle == func then
        return
    end
    self:DoActive(false)
    if IsFunction(func) then
        self.handle = func
        self:DoActive(true)
    else
        self.handle = nil
    end
end

function MonoUpdate:DoActive(b)
    if not self.handle then
        return
    end
    if b then
        if not self.active then
            if self.owner:IsActiveSelf() then
                self.active = true
                MonoEvent.AddListener(self.eventName, self.handle)
            end
        end
    else
        if self.active then
            self.active = false
            MonoEvent.RemoveListener(self.eventName, self.handle)
        end
    end
end

-- [设置MonoBehaviour的update等事件]
local function SetUpdateHandle(tbl, eventName, handle)
    local super = tbl.super
    local cls = super.updateFunc[eventName]
    if cls == nil then
        cls = MonoUpdate:Create(super, eventName)
        super.updateFunc[eventName] = cls
    end
    cls:SetHandle(handle)
end

--===========================================================================
-- Mono基类
--===========================================================================
-- [MonoBehaviour的基类table(ReadOnly)]
Mono = {}

-- [设置元表]
Mono.__index = Mono

-- [类名]
Mono.__cname = "Mono"

-- [Mono的基类保存, 派生类可以通过super找到基类]
Mono.super = Mono

-- [MonoBehaviour的方法: Update, LateUpdate, FixedUpdate]
Mono.updateFunc = {}

-- [MonoBehaviour this.gameObject]
Mono.gameObject = 0

-- [MonoBehaviour this.transform]
Mono.transform = 0

-- [MonoBehaviour绑定的LuaMonoBehaviour脚本]
Mono.luaBehaviour = 0

-- [设置Mono只读]
local function SetMonoReadOnly(tbl)
    local function newIndex(_, k, v)
        error(string.format("别碰我 我是Mono! [%s] = %s", k, tostring(v)))
    end
    setmetatable(tbl, {__newindex = newIndex})
end

function Mono:Init(monoObj)
    self.super.gameObject = monoObj
    self.super.transform = monoObj.transform
    self.super.luaBehaviour = monoObj.transform:GetComponent("LuaMonoBehaviour")
    self:Awake()
end

-- [在Mono:OnEnable和OnDisable时 处理MonoBehaviour的update等事件]
function Mono:DoActive(active)
    for key, value in pairs(self.super.updateFunc) do
        value:DoActive(active)
    end
    if active then
        self:OnEnable()
    else
        self:OnDisable()
    end
end

function Mono:Awake()
end

function Mono:OnEnable()
end

function Mono:Start()
end

function Mono:OnTriggerEnter(other)
end

function Mono:OnTriggerStay(other)
end

function Mono:OnTriggerExit(other)
end

function Mono:OnCollisionEnter(collision)
end

function Mono:OnCollisionStay(collision)
end

function Mono:OnCollisionExit(collision)
end

function Mono:OnApplicationFocus(focus)
end

function Mono:OnApplicationPause(pause)
end

function Mono:OnDisable()
end

function Mono:OnDestroy()
end

function Mono:OnClear()
    SetUpdateHandle(self, MonoEventType.Update, nil)
    SetUpdateHandle(self, MonoEventType.LateUpdate, nil)
    SetUpdateHandle(self, MonoEventType.FixedUpdate, nil)
    SetUpdateHandle(self, MonoEventType.AnimationEvent, nil)
    self:OnDestroy()
end

function Mono:OnApplicationQuit()
end

function Mono:Update()
end

function Mono:LateUpdate()
end

function Mono:FixedUpdate()
end

-- [是否激活]
function Mono:IsActiveSelf()
    return self.gameObject.activeSelf
end

-- [设置MonoBehaviour的update等事件 (下列事件不要重写)]
function Mono:SetUpdateHandle(needUpdate, needLateUpdate, needFixedUpdate)
    if needUpdate then
        local updateHandle = function()
            self:Update()
        end
        SetUpdateHandle(self, MonoEventType.Update, updateHandle)
    end

    if needLateUpdate then
        local lateUpdateHandle = function()
            self:LateUpdate()
        end
        SetUpdateHandle(self, MonoEventType.LateUpdate, lateUpdateHandle)
    end

    if needFixedUpdate then
        local fixedUpdateHandle = function()
            self:FixedUpdate()
        end
        SetUpdateHandle(self, MonoEventType.FixedUpdate, fixedUpdateHandle)
    end
end

function Mono:SetAnimationEvent(needEvent)
    if needEvent then
        local updateHandle = function()
            self:PanelAnimationClose()
        end
        SetUpdateHandle(self, MonoEventType.AnimationEvent, updateHandle)
    end
end

function Mono:PanelAnimationClose()
    -- body
end

function Mono:GetComponent(typeName)
    return self.gameObject:GetComponent(typeName)
end

function Mono:GetComponentByPath(path, typeName)
    local ret
    local ts = self.transform:Find(path)
    if ts then
        ret = ts.gameObject:GetComponent(typeName)
    end
    return ret
end

function Mono:GetTransformByPath(path)
    return self.transform:Find(path)
end

-- [设置Mono需要保护的方法名]
local protectedFunc = {
    IsActiveSelf = true,
    SetUpdate = true,
    SetLateUpdate = true,
    SetFixedUpdate = true,
    SetCoUpdate = true,
    UseTriggerStay = true,
    UseCollisionStay = true
}

function Mono.IsProtectedFunc(key)
    return protectedFunc[key]
end

SetMonoReadOnly(Mono) -- 最后设置为只读类 不允许修改
