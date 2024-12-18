UpdateCompensateManager = {}
UpdateCompensateManager.__cname = "UpdateCompensateManager"

local this = UpdateCompensateManager

---更新补偿manager
function UpdateCompensateManager.Init()
    this.data = DataManager.GetGlobalDataByKey(DataKey.UpdateCompensate) or {}
    
    this.CompensateForVer0_5_0()
    this.CompensateForVer0_5_0_Remain_High_Box()
end

function UpdateCompensateManager.SaveData()
    DataManager.SetGlobalDataByKey(DataKey.UpdateCompensate, this.data)
end

--当用户更新到0。5。0以上的版本时，给一个补偿奖励
function UpdateCompensateManager.CompensateForVer0_5_0()
    -- https://app.asana.com/0/1202978830787416/1203319394760548/f
    if this.data.CompensateForVer0_5_0 then
        -- 用户已经领取
        return
    end
    -- 用户必须大于指定版本号
    local comp = Utils.VersionCompare(Utils.Version2Array(GameManager.version), {0, 5, 0})
    if comp < 0 then
        return
    end
    
    if DataManager.GetMaxCityId() < 3 then
        --玩家必须到达3场景
        return
    end
    
    if DataManager.GetRegTimestamp() >= 1668211200 then
        --玩家必须是1668211200前注册用户
        return
    end
    
    local reward = {}
    reward["Box.box_gold"] = 1
    local title = "update_mail_1_title"
    local content = "update_mail_1_text"
    
    MailManager.SendMailToSelf(title, content, reward, 0)
    this.data.CompensateForVer0_5_0 = true
    this.SaveData()
end

---更新到0。5。0用户，对于high box剩余的数量补偿
function UpdateCompensateManager.CompensateForVer0_5_0_Remain_High_Box()
    -- https://app.asana.com/0/1202978830787416/1203390090959846/f
    if this.data.CompensateForVer0_5_0_Remain_High_Box then
        -- 用户已经领取
        return
    end
    -- 2022/13/8 不再判断注册时间，所有用户的high box都兑换掉
    --if DataManager.GetRegTimestamp() >= 1668211200 then
    --    --玩家必须是1668211200前注册用户
    --    return
    --end
    -- 用户必须大于指定版本号
    local comp = Utils.VersionCompare(Utils.Version2Array(GameManager.version), {0, 5, 0})
    if comp < 0 then
        return
    end
    local count = BoxManager.GetBoxBagCount("high_box")
    if count == 0 then
        -- 没有剩余box
        return
    end
    local compensationCount = math.floor(count / 3)
    if count % 3 then
        compensationCount = compensationCount + 1
    end
    local reward = {}
    reward["Box.box_purple"] = compensationCount
    local title = "update_mail_2_title"
    local content = "update_mail_2_text"
    BoxManager.RemoveBoxBagCount("high_box")
    MailManager.SendMailToSelf(title, content, reward, 0)
    this.data.CompensateForVer0_5_0_Remain_High_Box = true
    this.SaveData()
end
