HappyMailManager = {}
HappyMailManager._name = "HappyMailManager"

local this = HappyMailManager

---@class HappyMailData
---@field preSend table<string, number>


function HappyMailManager.Init()
    if this.initialized == nil then
        ---@type HappyMailData
        this.data = DataManager.GetGlobalDataByKey(DataKey.HappyMail) or {
            preSend = {}
        }
    
        local delay = this.GetNextDay(this.GetNow()) * 1000;
        --print("[error]" .. "delay: " .. delay)
        setTimeout(function()
            --print("[error]" .. "happyMail refresh")
            this.Update()
        end, delay)
        
        this.initialized = true
    end
    
    
    this.Update()
end

function HappyMailManager.SaveData()
    DataManager.SetGlobalDataByKey(DataKey.HappyMail, this.data)
end

---返回距离第二天凌晨的秒数
---@param now Time2
function HappyMailManager.GetNextDay(now)
    return now:GetToday() + Time2.Day - now:Timestamp()
end

function HappyMailManager.Update()
    local now = this.GetNow()
    --print("[error]" .. "now: ".. now:Timestamp())
    local allConfig = ConfigManager.GetAllHappyMail()
    
    for k, v in pairs(allConfig) do
        if this.CheckAvailable(v, DataManager.GetCityId(), now) then
            this.SendMail(v, now)
        end
    end
end

---@param config HappyMail
---@param cityId number
---@param now Time2
---@return boolean
function HappyMailManager.CheckAvailable(config, cityId, now)
    if not this.IsAvailableResend(config, now) then
        return false
    end
    
    if not this.IsAvailableCity(config, cityId) then
        return false
    end
    
    if not this.IsAvailableTime(config, now) then
        return false
    end
    
    return true
end

---@param config HappyMail
---@param now Time2
---@return boolean
function HappyMailManager.IsAvailableResend(config, now)
    local preSendTS = this.data.preSend[tostring(config.id)] or 0
    --print("[error]" .. "id: ".. config.id .. "preSendTS: " .. preSendTS .. " today: " .. now:GetToday())
    return preSendTS < now:GetToday()
end

---@param config HappyMail
---@param cityId number
---@return boolean
function HappyMailManager.IsAvailableCity(config, cityId)
    return config.startCity <= cityId and config.endCity > cityId
end

---@param config HappyMail
---@param now Time2
---@return boolean
function HappyMailManager.IsAvailableTime(config, now)
    return config.startTime <= now:Timestamp() and config.endTime > now:Timestamp()
end

---@param config HappyMail
---@param now Time2
function HappyMailManager.SendMail(config, now)
    this.data.preSend[tostring(config.id)] = now:Timestamp()
    this.SaveData()
    local attachment = Utils.ConvertRewardsStr2Attachment(config.rewards)
    MailManager.SendMailToSelf(config.title, config.content, attachment, 0)
end

---@return Time2
function HappyMailManager.GetNow()
    return Time2:New(GameManager.GameTime())
end
