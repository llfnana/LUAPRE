Analytics = {}
Analytics.__cname = "Analytics"
local this = Analytics

--Adjust
function Analytics.TraceAdjust(eventToken)
    AnalyticsSDK.TraceAdjust(eventToken)
end

--BI
function Analytics.TraceBI(eventName, paramsJson)
    AnalyticsSDK.TraceBI(eventName, paramsJson)
end

--TGA UserSet
function Analytics.UserSet(traceType, paramsStr)
    AnalyticsSDK.UserSet(traceType, paramsStr)
end

--TGA
function Analytics.TraceEvent(eventName, json)
    local jsonStr = JSON.encode(json)
    -- LogWarning("[TGA] " .. eventName .. " : " .. jsonStr)
   -- AnalyticsSDK.TraceEvent(eventName, jsonStr)
end

--LoadingStep
function Analytics.LoadingStep(step)
    if GameManager.ColdStart then
        local obj = {}
        obj.step = step
        obj.patchVersion = GameManager.version
        this.TraceEvent("LoadingStep", obj)
        Log("LoadingStep: " .. step)
    end
end

--Error
function Analytics.Error(errorEvent, errorMessage)
    -- local obj = json or {}
    -- obj.errorEvent = errorEvent
    -- if errorMessage ~= nil then
    --     obj.errorMessage = errorMessage
    -- end
    -- this.TraceEvent("Error", obj)
    -- SDKManager.ErrorLog(JSON.encode(obj))
end

function Analytics.ErrorRaw(errorObj)
    -- this.TraceEvent("Error", errorObj)
    -- SDKManager.ErrorLog(JSON.encode(errorObj))
end

--UserFirstTimeOpen
function Analytics.UserFirstTimeOpen()
    this.TraceEvent("UserFirstTimeOpen", {patchVersion = GameManager.version})
    if Application.platform == RuntimePlatform.Android then
        Analytics.TraceAdjust("b45yml")
    elseif Application.platform == RuntimePlatform.IPhonePlayer then
        Analytics.TraceAdjust("gbcltd")
    end
end

--正常Event 带有City数据
function Analytics.Event(eventName, obj)
    obj = obj or {}
    obj.currentCityId = DataManager.GetCityId()
    obj.cityId = DataManager.GetMaxCityId()
    obj.genLevel = DataManager.GetMaxCeneratorId()
    obj.cityTime = TimeManager.GetCityClock(DataManager.GetCityId())
    obj.BCBattleMaxLevel = DataManager.GetMaxBattleLevel()
    obj.patchVersion = GameManager.version
    obj.gemNum = DataManager.GetMaterialCount(DataManager.GetCityId(), ItemType.Gem)
    obj.userType = UserTypeManager.GetUserType()
    this.TraceEvent(eventName, obj)
end

--正常Event CurrencySink
function Analytics.CurrencySink(obj)
    if ConfigManager.GetMiscConfig("currency_tga_filter") == true then
        local item = ConfigManager.GetItemConfig(obj.currency)
        if item ~= nil and (item.type == ItemUseType.Food or item.type == ItemUseType.Material) then
            return
        end
    end
    if GameManager.isEditor then
        return
    end
    this.Event("CurrencySink", obj)
end

--正常Event CurrencySource
function Analytics.CurrencySource(obj)
    if ConfigManager.GetMiscConfig("currency_tga_filter") == true then
        local item = ConfigManager.GetItemConfig(obj.currency)
        if item ~= nil and (item.type == ItemUseType.Food or item.type == ItemUseType.Material) then
            return
        end
    end
    if GameManager.isEditor then
        return
    end
    this.Event("CurrencySource", obj)
end
