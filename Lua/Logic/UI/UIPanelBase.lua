
local UIPanelList = require "Logic/UI/UIPanelList"

---创建UI面板对象
local function makeFun()
    local uiName = debug.getinfo(2, 'S').short_src
    uiName = string.match(uiName, "/([^/]+)Panel$")

    ---@class UIPanelBase
    local Panel = {
        panelName = uiName, --面板名
        __class = uiName, --类名
        __base = {}, --基类函数映射
        Print = function(...)
            local msg = string.format('[UIPanelBase] %s', uiName)
            print(msg, ...)
        end ---打印日志
    }

    setmetatable(Panel, {
        ---@param t UIPanelBase
        __newindex = function(t, k, v)
            if GameUtil.isFunction(v) then
                t.__base[k] = v
            end
            rawset(t, k, v)
        end
    })

    local this = Panel

    function Panel.Awake(obj, behaviour)
        this.gameObject = obj
        this.transform = obj.transform
        this.behaviour = behaviour

        this.InitLocalize() 
        this.OnAwake()
    end

    --初始化本地化
    function Panel.InitLocalize()
        local components = this.transform:GetComponentsInChildren(typeof(Text), true)
        for i = 0, components.Length - 1 do
            local component = components[i]
            local textLocalize = component:GetComponent("TextLocalize")
            if textLocalize then
                component.text = GetLang(textLocalize.key)
            end
        end
    end

    function Panel.OnAwake() end

    function Panel.OnShow() end

    function Panel.Hide()
        this.RemoveEvents() --移除所有逻辑事件监听
        if this.OnHide then
            this.OnHide()
        end
    end

    function Panel.HideUI()
        if UINames[this.panelName] == nil then
            error('[UIPanelBase] not find panelName:' .. this.panelName)
            return
        end
        HideUI(this.panelName)
    end

    function Panel.OnDestroy() end

    ---获取Transform组件
    function Panel.GetTransform(comp, path)
        if path == nil then
            path = comp
            comp = this
        end

        local compTr = comp.transform
        if compTr == nil then
            error("[UIPanelBase] transform is nil!" .. path)
            return
        end

        local node = compTr:Find(path)
        if node == nil then
            error("[UIPanelBase] not find node:" .. path)
            return
        end

        return node
    end

    ---获取UI控件
    ---@param comp UnityEngine.GameObject|UnityEngine.Transform UI组件【可选】
    ---@param path string
    ---@param compName string
    ---@return UnityEngine.GameObject|UnityEngine.Component
    function Panel.GetUIControl(comp, path, compName)
        if comp ~= nil and path ~= nil and compName == nil then --两个参数
            if GameUtil.isString(comp) then --两个字符串：path, compName
                compName = path
                path = comp
                comp = this
            end
        elseif comp ~= nil and compName == nil then --一个参数：path
            path = comp
            comp = this
        end
        return SafeGetUIControl(comp, path, compName)
    end

    ---绑定点击事件
    ---@param comp UnityEngine.GameObject|UnityEngine.Transform UI组件【可选】
    ---@param path string
    ---@param func function
    ---@return UnityEngine.GameObject
    function Panel.BindUIControl(comp, path, func)
        if func == nil then
            func = path
            path = comp
            comp = this
        end

        local go = SafeGetUIControl(comp, path)

        if func ~= nil then
            SafeAddClickEvent(this.behaviour, go, func)
        end

        return go
    end

    ---初始化列表
    ---@param path string
    ---@param itemInit fun(i: UIPanelListDItem)|table
    ---@return UIPanelList
    function Panel.GetList(path, itemInit)
        local go = this.GetUIControl(path)
        local list = UIPanelList.new()
        list:InitPanel(this.behaviour, go, itemInit)

        return list
    end

    ---设置图片
    ---@param image UnityEngine.UI.Image
    ---@param res string 资源名
    ---@param isPng boolean 是否是png格式【默认true】
    function Panel.SetImage(image, res, isPng, active, native)
        if isPng == nil or isPng then
            res = res .. '.png'
        end

        if not ResInterface.IsExist(res) then
            return
        end

        ResInterface.SyncLoadSprite(res, function (sprite)
            if isNil(image) == false then 
                image.sprite = sprite
                if active ~= nil then 
                    image.gameObject:SetActive(active)
                end
                if native then 
                    image:SetNativeSize()
                end
            end
        end)
    end

    function Panel.SetColor(graphicComp, color)
        graphicComp.color = color
    end

    function Panel.AddClickEvent(go, func)
        SafeAddClickEvent(this.behaviour, go, func)
    end

    ---监听逻辑事件
    function Panel.AddListener(event, handler)
        if this.__events == nil then
            this.__events = {}
        end

        EventManager.AddListener(event, handler)
        table.insert(this.__events, { event, handler })
    end

    ---取消监听所有逻辑事件
    function Panel.RemoveEvents()
        local events = this.__events
        if events ~= nil then
            for _, v in ipairs(events) do
                EventManager.RemoveListener(v[1], v[2])
            end
            this.__events = nil
        end
    end

    ---调用基类方法
    function Panel.BaseCall(key, ...)
        --local fun = this['__' .. key]
        --local fun1 = rawget(this, '__' .. key)
        local fun = this.__base[key]
        if fun == nil or not GameUtil.isFunction(fun) then
            error('UIPanelBase中不存在方法', key)
            return
        end
        fun(...)
    end

    setmetatable(Panel, nil) --清除元表

    return Panel
end

return makeFun