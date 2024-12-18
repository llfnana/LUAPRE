--region -------------数据定义-------------

--endregion

---@class UIElementBase
local Element = class("UIBaseElement")

function Element:ctor()
    self.uidata = {} ---@type table UI组件数据

    self.gameObject = nil
    self.transform = nil
    self.behaviour = nil

    self.param = nil

    self._events = nil

    self:OnCtor()
end

function Element:OnCtor() end

function Element:InitPanel(behaviour, go, param)
    self.gameObject = go
    self.transform = go.transform
    self.behaviour = behaviour
    self.param = param
    self.uidata = {}

    self:OnInitPanel(param)
end

function Element:OnInitPanel(param) end

function Element:GetUIControl(path, comp)
    return SafeGetUIControl(self, path, comp)
end

function Element:BindUIControl(path, selfFunc)
    local go = self:GetUIControl(path)

    if selfFunc ~= nil then
        self:AddClickSelf(go, selfFunc)
    end

    return go
end

---添加自身点击事件
function Element:AddClickSelf(go, func)
    SafeAddClickEvent(self.behaviour, go, Handler(self, func))
end

function Element:AddListener(event, handler, obj)
    Event.AddListener(event, handler, obj)
    if self._events == nil then
        self._events = {}
    end
    table.insert(self._events, { event = event, handler = handler })
end

---@param isPng boolean 是否是png格式【默认true】
function Element:SetImage(image, res, isPng)
    if isPng == nil or isPng then
        res = res .. '.png'
    end

    if not ResInterface.IsExist(res) then
        return
    end

    Utils.SetIcon(image, res)
end

function Element:Destroy()
    --事件监听移除
    if self._events ~= nil then
        for _, v in ipairs(self._events) do
            Event.RemoveListener(v.event, v.handler)
        end
        self._events = nil
    end

    GODestroy(self.gameObject)
end

return Element