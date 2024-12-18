UserTypeManager = {}
UserTypeManager.__cname = "UserTypeManager"

local this = UserTypeManager

--UserTypeManager.isInitialized = false
--
--function UserTypeManager.Init()
--    if this.isInitialized then
--        return
--    end
--end

function UserTypeManager.Is(userType)
    local rt = true
    local config = ConfigManager.GetUserTypeConfig(userType)
    if config == nil then
        print("[error]" .. "not found userType: " .. userType)
        return false
    end
    
    if #config.pay7amount == 2 then
        local amount = Utils.ToAmount(ShopManager.GetUserPayAmount(7, this.GetNow()))
        
        rt = rt and Utils.ToAmount(config.pay7amount[1]) <= amount and amount < Utils.ToAmount(config.pay7amount[2])
    end
    
    if #config.pay60amount == 2 then
        local amount = Utils.ToAmount(ShopManager.GetUserPayAmount(60, this.GetNow()))
        
        rt = rt and Utils.ToAmount(config.pay60amount[1]) <= amount and amount < Utils.ToAmount(config.pay60amount[2])
    end
    
    if #config.loginday == 2 then
        local day = DataManager.GetLoginInfo().count
        
        rt = rt and config.loginday[1] <= day and day < config.loginday[2]
    end
    
    return rt
end

---@return table<string, boolean>
function UserTypeManager.GetAllType()
    local allUserTypeList = ConfigManager.GetAllUserTypeConfig()
    local rt = {}
    
    for k, v in pairs(allUserTypeList) do
        rt[k] = this.Is(k)
    end
    return rt
end

---返回UserType
function UserTypeManager.GetUserType()
    --用户类型只有一种，如果有2个，那肯定是配错了
    local allUserTypeList = ConfigManager.GetAllUserTypeConfig()
    
    for k, v in pairs(allUserTypeList) do
        if this.Is(k) then
            return k
        end
    end
    print("[error]" .. "not found valid UserType")
    return ""
end

function UserTypeManager.GetNow()
    return Time2:New(GameManager.GameTime())
end
