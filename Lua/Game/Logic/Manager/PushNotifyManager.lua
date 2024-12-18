PushNotifyManager = {}
PushNotifyManager.__cname = "PushNotifyManager"
local this = PushNotifyManager

PushNotifyManager.IgnoreSchedule = 30

PushNotifyManager.PromptType = {
    Offline = "offline",
    Fight = "fight",
    FreeBox = "freeBox",
    Setting = "setting"
}

this.rootPath = "Game/Logic/Model/Push/"

---@class PushNotifyData
---@field data table<string, PushData[]>
---@field enable boolean
---@field enablePrompt boolean
---@field checkTS number

function PushNotifyManager.Init()
    if this.initialized == nil then
        this.initialized = true

        this.cooldown = ConfigManager.GetMiscConfig("push_notify_cooldown")
        this.config = ConfigManager.GetPush()

        this.data = this.LoadData()

        EventManager.AddListener(EventType.EFFECT_RES_ADD_COMPLETE, this.OnEffectResAddComplete)
    end

    ---@type PushBase[]
    this.pushList = {}

    for _, v in pairs(this.config) do
        local cls = require(this.rootPath .. v.id)
        if cls then
            local pushId = v.id
            local currentData = this.data.data[pushId] or {}

            table.insert(
                this.pushList,
                cls:Create(
                    DataManager.GetCityId(),
                    v,
                    currentData,
                    function(data)
                        this.data.data[pushId] = data
                        this.SaveData()
                    end
                )
            )
        end
    end
end

function PushNotifyManager.Clear()
    this.Refresh()
    this.SaveData()
    this.pushList = {}
end

function PushNotifyManager.JoinGame()
    NetManager.ClearPushNotify(
        function()
            Log("ClearPushNotify success:")
        end
    )
end

function PushNotifyManager.LeaveGame()
    if not (this.GetEnable() and this.IsUnlock()) then
        return
    end

    this.Refresh()
    local pushDataList = this.CheckInvalid(this.GetPushData(), GameManager.GameTime())
    Log("PushNotify: " .. JSON.encode(pushDataList))
    NetManager.SetPushNotify(
        pushDataList,
        function(rsp)
            Log("SetPushNotify success:" .. #pushDataList)

            for _, v in ipairs(pushDataList) do
                Analytics.Event(
                    "PushSuccess",
                    {
                        pushId = v.name,
                        pushSchedule = v.schedule
                    }
                )
            end
        end
    )
end

function PushNotifyManager.SetEnable(enable)
    this.data.enable = enable
    this.SaveData()

    Analytics.Event(
        "PushSwitch",
        {
            isSwitchOpen = enable
        }
    )
end

function PushNotifyManager.GetEnable()
    return this.data.enable
end

function PushNotifyManager.IsUnlock()
    return FunctionsManager.IsUnlock(FunctionsType.PushNotify)
end

---@param cb fun(ok:boolean)
function PushNotifyManager.OpenPromptPanel(type, cb)
    if this.GetEnable() then
        -- 如果已经允许，那么返回
        return
    end

    if this.data.checkTS + this.cooldown > GameManager.GameTime() then
        -- 冷却事件还没有过
        return
    end

    local f = function(ok)
        this.data.checkTS = GameManager.GameTime()
        this.SaveData()

        if cb ~= nil then
            cb(ok)
        end
    end

    local desc = ""
    local last = false
    if type == PushNotifyManager.PromptType.Offline then
        desc = "ui_ask_notification_offline"
    elseif type == PushNotifyManager.PromptType.Fight then
        desc = "ui_ask_notification_fight"
    elseif type == PushNotifyManager.PromptType.FreeBox then
        desc = "ui_ask_notification_chest"
    elseif type == PushNotifyManager.PromptType.Setting then
        desc = "ui_ask_notification_setting"
    else
        print("[error]" .. "unknown push prompt type: " .. type)
        return
    end

    if not this.data.enablePrompt or type == PushNotifyManager.PromptType.Setting then
        return
    end

    Utils.OpenMessageBox(
        {
            Title = "ui_ask_notification_title",
            Description = desc,
            ShowNo = true,
            ShowYes = true,
            ShowToggle = true,
            ToggleDefault = false,
            ToggleText = "ui_ask_notification_hide",
            OnYesFunc = function(toggle)
                this.SetEnable(true)
                this.data.enablePrompt = not toggle
                this.SaveData()

                f(true)
            end,
            OnNoFunc = function(toggle)
                this.data.enablePrompt = not toggle
                this.SaveData()

                f(false)
            end,
            OnCloseFunc = function(toggle)
                this.data.enablePrompt = not toggle
                this.SaveData()

                f(false)
            end
        },
        last
    )
end

---是否在开启推送询问的冷却时间内
---@return boolean
function PushNotifyManager.IsCooldown()
    return GameManager.GameTime() - this.data.checkTS > this.cooldown
end

---@return PushData[]
function PushNotifyManager.GetPushData()
    ---@type PushData[]
    local rt = {}
    for _, v in pairs(this.data.data) do
        for _, p in pairs(v) do
            table.insert(rt, p)
        end
    end

    return rt
end

function PushNotifyManager.Refresh()
    local now = Time2:New(GameManager.GameTime())
    for _, v in ipairs(this.pushList) do
        v:Refresh(now)
    end
end

---@param pushList PushData[]
---@param nowTS number
---@return PushData[]
function PushNotifyManager.CheckInvalid(pushList, nowTS)
    local rt = {}

    for _, p in ipairs(pushList) do
        if p.schedule - nowTS > PushNotifyManager.IgnoreSchedule then
            table.insert(rt, p)
        end
    end

    return rt
end

function PushNotifyManager.OnEffectResAddComplete(eventSign)
    for _, v in ipairs(this.pushList) do
        v:OnEvent(
            DataManager.GetCityId(),
            EventType.EFFECT_RES_ADD_COMPLETE,
            {
                eventSign = eventSign
            }
        )
    end
end

---@return PushNotifyData
function PushNotifyManager.NewData()
    ---@type PushNotifyData
    return {
        data = {},
        enable = true,
        checkTS = 0,
        enablePrompt = true
    }
end

---@return PushNotifyData
function PushNotifyManager.LoadData()
    local ldjs = PlayerPrefs.GetString(this.Key())
    if ldjs ~= "" then
        return JSON.decode(ldjs)
    end

    return this.NewData()
end

function PushNotifyManager.ResetCooldown()
    this.data.checkTS = 0
    this.SaveData()
end

function PushNotifyManager.EnablePrompt()
    this.data.enablePrompt = true
    this.SaveData()
end

function PushNotifyManager.PrintCooldown()
    if this.data.checkTS == 0 then
        Log("PushNotify CD: " .. 0)
        Log("PushNotify Data:" .. JSON.encode(this.data))
        return
    end
    local t = Time2:New(this.data.checkTS)
    Log("PushNotify CD: " .. t:ToLocalString())
    Log("PushNotify Data:" .. JSON.encode(this.data))
end

function PushNotifyManager.Key()
    return DataManager.Key2Prefs("PushNotify")
end

function PushNotifyManager.SaveData()
    PlayerPrefs.SetString(this.Key(), JSON.encode(this.data))
end

--切换帐号重置数据
function PushNotifyManager.Reset()
    this.initialized = nil
    EventManager.RemoveListener(EventType.EFFECT_RES_ADD_COMPLETE, this.OnEffectResAddComplete)
end
