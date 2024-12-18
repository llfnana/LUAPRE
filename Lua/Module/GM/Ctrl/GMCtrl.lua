------------------------------------------------------------------------
--- @desc GM控制器
--- @author sakuya
------------------------------------------------------------------------

local json = require 'cjson'

---@class GMCTRL GM控制器
local Ctrl = class('GMCtrl')

function Ctrl:ctor(param)
    self.gameObject = nil
    self.transform = nil
end

function Ctrl:initEvent()
    SafeAddClickEvent(self.behaviour, self.btnOpenStagePreview, function()
        local param = {}
        param.isPreview = true
        param.stageId = self.selectStageId
        param.pathIdx = 1

        local sceneIns = SceneManager:Inst()
        if sceneIns.curScene == sceneIns.scenes[SceneNames.StageScene] then
            HomeModule.openScene(nil, function()
                StageModule.openScene(param) --加载关卡场景
            end)
        else
            StageModule.openScene(param) --加载关卡场景
        end
    end)

    SafeAddClickEvent(self.behaviour, self.btnDisplay, function()
        self:GMUIDisplayChange()
    end)
    SafeAddClickEvent(self.behaviour, self.fingerGame, function()
        self:OpenFingerGame()
    end)
end

function Ctrl.OpenFingerGame()
    ShowUI(UINames.UIFingerGuess)
end

function Ctrl:initCmdList()
    self.data = GMModule.getCommands()
    if self.listCmds == nil then
        self.listCmds = {}
        for k, v in pairs(self.data) do
            table.insert(self.listCmds, k)
            local go = GOInstantiate(self.oneCmd)
            go.transform:SetParent(self.content.transform, false)
            SafeSetActive(go, true)
            self:InitItem(go, k)
        end
    end
end

function Ctrl:InitItem(go, flagValue)
    local key = flagValue
    local data = self.data[key]
    local txtDesc = go.transform:Find("TxtDesc"):GetComponent("Text")
    local txtCmd = go.transform:Find("TxtCmd"):GetComponent("Text")
    local btn = go.transform:Find("ImgTarget")
    local parmams = ""
    for i, v in ipairs(data.defaultParam) do
        parmams = parmams .. "," .. v
    end
    txtDesc.text = "描述:" .. data.description
    txtCmd.text = "命令:" .. key .. parmams
    SafeAddClickEvent(self.behaviour, btn.gameObject, function()
        self.commandInput.text = key .. parmams
        self.commandInput:ActivateInputField()
    end)
end

function Ctrl:GMUIDisplayChange()
    self.GMDisplay = not self.GMDisplay
    self:upGMUI()
end

function Ctrl:upGMUI()
    local list = self:getAllTrsByTrs(self.gameObject.transform)
    for k, gameObject in ipairs(list) do
        if gameObject.transform.name ~= "Button" and gameObject.transform.name ~= "CommandView" then
            gameObject:SetActive(self.GMDisplay)
        end
    end
    self.btnText.text = self.GMDisplay and "隐藏GMUI" or "打开GMUI"
end

function Ctrl:getAllTrsByTrs(transform)
    -- print("打印子节点数量")
    -- print(transform.childCount)
    local objList = {}
    for i = 1, transform.childCount do
        local _transform = transform:GetChild(i - 1)
        table.insert(objList, _transform.gameObject)
    end
    return objList
end

function Ctrl:init()
    self.gameObject = GameObject.Find("UIGM")
    self.transform = self.gameObject.transform
    print("初始化GM控制器完成")
    -- print(self.gameObject.transform.name)

    self.btnOpenStagePreview = SafeGetUIControl(self, "MapPreview/OpenMap")
    self.btnDisplay = SafeGetUIControl(self, "Button")
    self.btnText = SafeGetUIControl(self, "Button/Text", "Text")
    self.mapList = SafeGetUIControl(self, "MapPreview/MapList")
    self.mapListDropdown = SafeGetUIControl(self, "MapPreview/MapList", "Dropdown")
    self.behaviour = self.gameObject:GetComponent("LuaBehaviour")
    self.commandView = SafeGetUIControl(self, "CommandView")
    self.commandText = SafeGetUIControl(self, "CommandView/bgPanel/InputField/Text", "Text")
    self.commandInput = SafeGetUIControl(self, "CommandView/bgPanel/InputField", "InputField")
    self.list = SafeGetUIControl(self, "Info")
    self.content = SafeGetUIControl(self, "Info/Viewport/Content")
    self.oneCmd = self.content.transform:GetChild(0).gameObject
    
    self.fingerGame=SafeGetUIControl(self,"BtnFinger")

    UpdateBeat:Add(self.update, self)

    self.selectStageId = 101
    self.GMDisplay = false
    self:upGMUI()

    self:initEvent()
    self:initMapDropDown()
end

function Ctrl:update(dt)
    if UnityEngine.Input.GetKey(UnityEngine.KeyCode.G) then
        -- 命令行呼出
        self:setCommandViewActive(true)
        self:initCmdList()
    end
    if UnityEngine.Input.GetKey(UnityEngine.KeyCode.Escape) then
        -- 命令行关闭
        self:setCommandViewActive(false)
    end
    if UnityEngine.Input.GetKey(UnityEngine.KeyCode.Return) then
        -- 命令行执行
        if self.gmViewActive then
            self:doCommand(self.commandText.text)
        end
    end
end

function Ctrl:doCommand(str)
    -- comand格式为 命令,参数1,参数2,参数3
    -- 例如 DiceRoll,5
    print(str)
    local fPos = string.find(str, "%,")
    local command = str
    if fPos ~= nil then
        -- 如果有参数
        local sub_str = string.sub(str, 1, fPos - 1) -- 从字符串头开始截取到 "." 之前
        command = sub_str
    end

    local params = {}
    for sub_str in string.gmatch(str, "[^%,]+") do
        if sub_str ~= command then
            table.insert(params, sub_str)
        end
    end

    GMModule.DoCommand(command, params)
    self.commandText.text = ""
    self:setCommandViewActive(false)
end

function Ctrl:setCommandViewActive(active)
    self.gmViewActive = active
    self.commandView:SetActive(active)
    self.commandInput:ActivateInputField()
    self.list.gameObject:SetActive(active)
end

function Ctrl:initMapDropDown()
    -- self.mapListDropdown.enabled = true

    -- local mapDataList = {}
    -- for k, v in pairs(TbStage) do
    --     table.insert(mapDataList, v.ID)
    -- end
    -- local mapIds = ""
    -- self.mapIndex = 1
    -- for i = 1, #mapDataList do
    --     if i == 1 then
    --         mapIds = "" .. mapDataList[i];
    --     else
    --         mapIds = mapIds .. "|" .. mapDataList[i];
    --     end
    --     -- if mapDataList[i] == defaultSelect then
    --     -- 	self.mapIndex = i;
    --     -- end
    -- end
    -- self.behaviour:SetDropDownOptions(self.mapList, mapIds, self.mapIndex - 1)
    -- self.behaviour:AddDropDownEvent(self.mapList, function(index)
    --     self.selectStageId = mapDataList[index + 1]
    --     print("选择关卡:" .. self.selectStageId)
    -- end)
end

return Ctrl
