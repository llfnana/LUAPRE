SurveyManager = {}
SurveyManager.__cname = "SurveyManager"
local this = SurveyManager

SurveyManager.State = {
    Inactive = 0,
    Active = 1,
    Finished = 2,
    Claimed = 3
}

SurveyManager.PreconditionType = {
    Yes = "yes",
    No = "no",
    None = "none"
}

---@class SurveyData
---@field activeName string
---@field state table<string, number>

--问卷SDK 初始化
function SurveyManager.AddEvent()
    SurveySDK.Instance:Init(SurveyManager.OnCallBack)
end

function SurveyManager.Init()
    if not this.initialized then
        this.StateRx = NumberRx:New(0)
        this.InitConfig()
        this.InitData()
        this.InitListener()

        this.initialized = true
    end

    this.RefreshAvailable()
end

function SurveyManager.InitConfig()
    this.configDict = ConfigManager.GetAllSurvey()
    ---@type Survey[]
    this.configItems = {}
    for k, v in pairs(this.configDict) do
        table.insert(this.configItems, v)
    end

    table.sort(
        this.configItems,
        function(a, b)
            return a.sort < b.sort
        end
    )
end

function SurveyManager.InitData()
    ---@type SurveyData
    this.data = DataManager.GetGlobalDataByKey(DataKey.Survey) or this.NewData()
end

function SurveyManager.RefreshAvailable()
    this.ClearActive()
    -- 刷新所有配置，从后往前找到第一个可用问卷
    for i = #this.configItems, 1, -1 do
        local item = this.configItems[i]
        if item.scope == this.GetScope() then
            if FunctionsManager.IsUnlock(item.functions_unlock) then
                -- 前置条件是否达成
                if this.IsAvailablePrecondition(item.precondition, item.precondition_survey_list) then
                    local state = this.data.state[item.name] or SurveyManager.State.Active
                    if state ~= SurveyManager.State.Claimed then
                        this.SetActiveSurvey(item.name, state)
                    end

                    break
                end
            end
        end
    end
end

function SurveyManager.GetScope()
    if CityManager.GetIsEventScene(DataManager.GetCityId()) then
        return "Event"
    end

    return "City"
end

---@return SurveyData
function SurveyManager.NewData()
    return {
        state = {},
        activeName = ""
    }
end

function SurveyManager.ResetData()
    this.data = this.NewData()
    this.SaveData()
end

function SurveyManager.InitListener()
    EventManager.AddListener(EventType.FUNCTIONS_UNLOCK, this.OnFunctionsUnlock)
end

function SurveyManager.OnFunctionsUnlock(functionsUnlock)
    this.RefreshAvailable()
end

function SurveyManager.SetActiveSurvey(surveyName, state)
    this.data.activeName = surveyName
    this.SetState(surveyName, state)
    -- 不需要save data，SetState已经保存过
end

function SurveyManager.IsAvailablePrecondition(precondition, preconditionSurveyList)
    precondition = precondition or SurveyManager.PreconditionType.None

    if precondition == SurveyManager.PreconditionType.None then
        return true
    end

    if preconditionSurveyList == nil or #preconditionSurveyList == 0 then
        return false
    end

    local finishCount = 0
    for i = 1, #preconditionSurveyList do
        -- 没有领奖也算前置条件完成
        if this.GetState(preconditionSurveyList[i]) >= SurveyManager.State.Finished then
            finishCount = finishCount + 1
        end
    end

    if precondition == SurveyManager.PreconditionType.Yes then
        -- 如果是yes，只要finishCount 大于0就通过
        return finishCount > 0
    elseif precondition == SurveyManager.PreconditionType.No then
        -- 如果是no，只有finishCount是0才通过
        return finishCount == 0
    end

    return false
end

function SurveyManager.GetStateRx()
    return this.StateRx
end

---返回问卷状态
---@param surveyName string
function SurveyManager.GetState(surveyName)
    return this.data.state[surveyName] or SurveyManager.State.Inactive
end

---@private
function SurveyManager.SetState(surveyName, state)
    this.data.state[surveyName] = state
    this.SaveData()
    this.StateRx.value = state
end

---@private
function SurveyManager.SaveData()
    DataManager.SetGlobalDataByKey(DataKey.Survey, this.data)
end

--显示问卷
function SurveyManager.Show()
    if this.data.activeName == "" then
        return
    end

    local hash = this.configDict[this.data.activeName].hash
    Log("Survey show, id: " .. this.data.activeName .. " hash: " .. hash)

    if GameManager.isEditor then
        PopupManager.Instance:ShowLoading()
        setTimeout(
            function()
                PopupManager.Instance:HideLoading()
                this.OnCallBack("Success", "")
            end,
            2000
        )
    else
        local params = {}
        params.version = GameManager.version
        params = this.GenerateParams(params)
        local jsonParams = JSON.encode(params)
        Log("survey params: " .. jsonParams)
        --禁止游戏返回时loading
        GameManager.DontReload = true
        SurveySDK.Instance:ShowSurvey(hash, jsonParams)
    end

    this.Analytics("SurveyClickButton", {})
end

--问卷SDK 回调
function SurveyManager.OnCallBack(success, result)
    Log("SurveyCallBack" .. success .. " | " .. result)

    if success == "Success" then
        this.SetState(this.data.activeName, SurveyManager.State.Finished)
        this.Analytics("SurveyFinished", {})
    else
        local rt = JSON.encode(result)

        this.Analytics(
            "SurveyOpenFail",
            {
                errorCode = rt.errorCode
            }
        )
    end
end

function SurveyManager.GetActiveState()
    return this.GetState(this.data.activeName)
end

function SurveyManager.ClaimActiveSurveyReward()
    if this.data.activeName == "" then
        return
    end

    -- local item = this.configDict[this.data.activeName]
    -- local rewards = Utils.ParseReward(item.rewards)
    -- local rt = DataManager.AddReward(DataManager.GetCityId(), rewards, "survey", item.hash)
    this.SetState(this.data.activeName, SurveyManager.State.Claimed)
    -- this.Analytics(
    --     "SurveyRewardsClaimed",
    --     {
    --         resource = rt
    --     }
    -- )

    SurveyManager.ClearActive()
    -- return rt
end

function SurveyManager.ClearActive()
    this.StateRx.value = 0
    this.data.activeName = ""
    this.SaveData()
end

function SurveyManager.GetActiveRewards()
    if this.data.activeName == "" then
        return {}
    end

    local item = this.configDict[this.data.activeName]
    return Utils.ParseReward(item.rewards)
end

function SurveyManager.GetActiveName()
    return this.data.activeName
end

function SurveyManager.Analytics(event, data)
    data.hash = this.configDict[this.data.activeName].hash
    data.paidAmount = PaymentManager.GetPriceCount()
    data.countryCode = SDKManager.GetCountry()
    data.loginDays = DataManager.GetLoginInfo().count
    data.cardBattleLevel = CardManager.GetBattleLevel()
    data.cityId = DataManager.GetMaxCityId()
    data.reg = DataManager.GetGlobalDataByKey(DataKey.RegisterTS)
    data.currCityId = DataManager.GetCityId()
    data.milestoneId = TaskManager.GetSceneTaskProgress(DataManager.GetCityId())
    data.battleTeamPower = HeroBattleDataManager.GetTeamPower()

    Analytics.Event(event, data)
end

function SurveyManager.GenerateParams(data)
    --data.id = this.data.activeName
    data.hash = this.configDict[this.data.activeName].hash
    data.paidAmount = tostring(PaymentManager.GetPriceCount())
    data.countryCode = tostring(SDKManager.GetCountry())
    data.loginDays = tostring(DataManager.GetLoginInfo().count)
    data.cardBattleLevel = tostring(CardManager.GetBattleLevel())
    data.cityId = tostring(DataManager.GetMaxCityId())
    data.reg = tostring(DataManager.GetGlobalDataByKey(DataKey.RegisterTS))
    data.currCityId = tostring(DataManager.GetCityId())
    data.milestoneId = tostring(TaskManager.GetSceneTaskProgress(DataManager.GetCityId()))
    data.battleTeamPower = tostring(HeroBattleDataManager.GetTeamPower())
    data.AccountID = SDKManager.fpid
    data.role_id = SDKManager.fpid
    return data
end

--切换帐号重置数据
function SurveyManager.Reset()
    this.initialized = nil
    EventManager.RemoveListener(EventType.FUNCTIONS_UNLOCK, this.OnFunctionsUnlock)
end
