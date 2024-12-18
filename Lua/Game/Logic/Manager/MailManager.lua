MailManager = {}
MailManager._name = "MailManager"
--MailManager.respEvent = Event:New()
local this = MailManager

MailManager.showLog = false
-- 邮件过期时间
local MailExpireDuration = 3600 * 24 * 15 ---@type number

---@class MailServerData
---@field CreateTS number
---@field Status number

---@class MailClientData
---@field Id number
---@field Title string
---@field Content string
---@field CreateTS number
---@field Status number
---@field Attachment table<string, number>
---@field EffectiveTS number

MailManager.Status = {
    Unread = 1,
    Read = 2,
    Claimed = 3,
    Deleted = 4
}

MailManager.Type = {
    Server = "server",
    Client = "client"
}

MailManager.PlatformType = {
    iOS = "iOS",
    Android = "Android"
}


---@class MailExtendedVisible
---@field ts number[]
---@field city number[]
---@field verAssign number[]
---@field verMax number[]
---@field verMin number[]
---@field platform string
---@field silent boolean
---@field luaScript string

---@class MailExtendedReceive
---@field dataVer number
---@field ts number[]

---@class MailExtendedClaim
---@field verMin number[]
---@field city number[]

---@class MailExtended
---@field ver number
---@field visible MailExtendedVisible
---@field claim MailExtendedClaim
---@field receive MailExtendedReceive


---@class Mail
---@field Id number
---@field Title string
---@field Content string
---@field CreateTS number
---@field Status number
---@field Attachment table<string, number>
---@field Info table<string, string>
---@field Extended MailExtended
---@field Type string

---@class MailSaveData
---@field ServerData table<string, MailServerData>
---@field ClientData table<string, MailClientData>
---@field ClientIdx number

---@type Mail
Mail = {}

---@class MailExtendedClaimError
MailManager.ExtendedClaimError = {
    CityId = "cityId",
    VerMin = "verMin"
}

---有附件
---@param mail Mail
---@return boolean
function Mail.HasAttachment(mail)
    return mail.Attachment ~= nil and next(mail.Attachment) ~= nil
end

---有不能领取的附件
---@param mail Mail
---@return boolean
function Mail.HasAttachmentAndCannotClaim(mail)
    return Mail.HasClaim(mail) and
        (not Mail.CanExtendedClaim(mail) or not Mail.AttachmentCanClaimInCity(mail, DataManager.GetCityId()))
end

---返回附件是否可以在当前城市领取
---@param mail Mail
---@param cityId number
function Mail.AttachmentCanClaimInCity(mail, cityId)
    for k, v in pairs(mail.Attachment) do
        local type, name = MailManager.GetRewardInfo(k)
        if type == RewardType.Item then
            local itemConfig = ConfigManager.GetItemConfig(name)
            if itemConfig.scope == "City" and itemConfig.city_id ~= cityId then
                return false, itemConfig.city_id
            end
        elseif type == RewardType.Box then
            return BoxManager.GetAvailableCityId(name, cityId)
        elseif type == RewardType.Card then
            local cardConfig = ConfigManager.GetCardConfig(tonumber(name))
            local cardCityId = cardConfig.scope["Event"]
            if cardCityId == nil then
                -- 如果不是event，那么一律是1
                cardCityId = 1
            end
            
            return CardManager.IsCardValidInCurrentCity(tonumber(name)), cardCityId
        end
    end

    return true
end

---@param mail Mail
---@return boolean
function Mail.CanDelete(mail)
    local hasAttachment = Mail.HasAttachment(mail)
    -- 有附件并且状态是已领取，或者没附件并且状态是已读和已领取
    return (hasAttachment and mail.Status == MailManager.Status.Claimed) or
        (not hasAttachment and (mail.Status == MailManager.Status.Read or mail.Status == MailManager.Status.Claimed))
end

---@param mail Mail
---@return boolean
function Mail.CanClaim(mail)
    return Mail.HasClaim(mail) and Mail.CanExtendedClaim(mail) and
        Mail.AttachmentCanClaimInCity(mail, DataManager.GetCityId())
end

---@param mail Mail
---@return boolean
function Mail.HasClaim(mail)
    return Mail.HasAttachment(mail) and mail.Status < MailManager.Status.Claimed
end

---@param mail Mail
---@return boolean
function Mail.IsUnread(mail)
    return mail.Status == MailManager.Status.Unread
end

---@param mail Mail
---@return number
function Mail.CalcPriority(mail)
    if Mail.IsUnread(mail) then
        return 1
    end

    if Mail.CanClaim(mail) then
        return 2
    end

    return 3
end

---@return MailExtended
function Mail.GetDefaultExtended()
    ---@type MailExtended
    local extended = {
        visible = {
            ts = {0, 0},
            city = {1, 999},
            verAssign = {0, 0, 0},
            verMax = {0, 0, 0},
            verMin = {0, 0, 0},
            platform = "",
            silent = false,
            luaScript = ""
        },
        claim = {
            verMin = {0, 0, 0},
            city = {1, 999}
        },
        event = ""
    }
    return extended
end

---是否是静默邮件
---@param mail Mail
function Mail.IsSilent(mail)
    Log("IsSilent: " .. JSON.encode(mail))
    if mail.Extended == nil then
        return false
    end

    return (mail.Extended.silent or false)
end

---@param mail Mail
function Mail.IsVisible(mail)
    if mail.Status == MailManager.Status.Deleted then
        return false
    end

    return Mail.IsExtendedVisible(mail, GameManager.GameTime())
end

---检查邮件时间条件，判断是否永久不可用，即：收到
---@param mail Mail
function Mail.IsInvalidForEver(mail)
    if mail.Extended.ver == nil or mail.Extended.ver < 2 then
        MailManager.Log("Id: " .. mail.Id .. ", invalid ver: " .. JSON.encode(mail))
        return true
    end
    
    --可见时间检查
    if mail.Extended.visible.ts[2] ~= 0 and mail.Extended.visible.ts[2] < GameManager.GameTime() then
        MailManager.Log("Id: " .. mail.Id .. ", invalid visible.ts[2]: " .. JSON.encode(mail))
        --最大时间小于当前时间
        return true
    end
    
    if mail.Extended.visible.city[2] < DataManager.GetMaxCityId() then
        --邮件要求最大城市小于用户最大城市
        MailManager.Log("Id: " .. mail.Id .. ", invalid visible.city[2]: " .. JSON.encode(mail))
        return true
    end
    
    local currVerData = Utils.Version2Array(GameManager.version)
    
    if
    Utils.VersionIsValid(mail.Extended.visible.verMax) and
        not Utils.VersionIsZero(mail.Extended.visible.verMax) and
        Utils.VersionCompare(mail.Extended.visible.verMax, currVerData) == -1 then
        --最大版本闭比当前版本小
        MailManager.Log("Id: " .. mail.Id .. ", invalid visible.verMax: " .. JSON.encode(mail))
        return true
    end
    
    if mail.Extended.receive.ts[1] ~= 0 and mail.Extended.receive.ts[1] > DataManager.GetRegTimestamp() then
        -- 接收时间1不等于并且接收时间1大于注册时间
        MailManager.Log("Id: " .. mail.Id .. ", invalid receive.ts[1]: " .. JSON.encode(mail))
        return true
    end
    
    if mail.Extended.receive.ts[2] ~= 0 and mail.Extended.receive.ts[2] < DataManager.GetRegTimestamp() then
        -- 接收时间2不等于并且接收时间2小于注册时间
        MailManager.Log("Id: " .. mail.Id .. ", invalid receive.ts[2]: " .. JSON.encode(mail))
        return true
    end
    
    if mail.Extended.claim.city[2] < DataManager.GetMaxCityId() then
        --可获取最大city小于用户最大城市
        MailManager.Log("Id: " .. mail.Id .. ", invalid claim.city[2]: " .. JSON.encode(mail))
        return true
    end
    
    return false
end

---@param mail Mail
function Mail.GetCityIdOfExtended(mail)
    return mail.Extended.cityId
end

---扩展中条件可以领取
---@param mail Mail
---@return boolean, MailExtendedClaimError
function Mail.CanExtendedClaim(mail)
    if Utils.VersionCompare(mail.Extended.claim.verMin, Utils.Version2Array(GameManager.version)) > 0 then
        MailManager.Log("id: " .. mail.Id .. " claim.verMin: " .. JSON.encode(mail))
        return false, this.ExtendedClaimError.VerMin
    end
    
    if not (mail.Extended.claim.city[1] <= DataManager.GetMaxCityId() and DataManager.GetMaxCityId() < mail.Extended.claim.city[2]) then
        MailManager.Log("id: " .. mail.Id .. " claim.city: " .. JSON.encode(mail))
        return false, this.ExtendedClaimError.CityId
    end
    
    return true
end

---@param mail Mail
---@param nowTs number
function Mail.IsExtendedVisible(mail, nowTs)
    local visible = mail.Extended.visible

    if visible.ts[1] ~= 0 and visible.ts[2] ~= 0 then
        if visible.ts[1] > nowTs then
            -- 时间还没到
            MailManager.Log("id: " .. mail.Id .. " visible.ts[1]: " .. JSON.encode(visible))
            return false
        end
    
        if nowTs > visible.ts[2] then
            -- 时间过了，直接删除
            MailManager.Log("id: " .. mail.Id .. " visible.ts[2]: " .. JSON.encode(visible))
            return false
        end
    end
    
    --左闭又开
    if visible.city[1] ~= 0 and DataManager.GetMaxCityId() < visible.city[1] then
        MailManager.Log("id: " .. mail.Id .. " visible.city[1]: " .. JSON.encode(visible))
        return false
    end
    
    --左闭又开
    if visible.city[2] ~= 0 and visible.city[2] < DataManager.GetMaxCityId() then
        MailManager.Log("id: " .. mail.Id .. " visible.city[2]: " .. JSON.encode(visible))
        return false
    end

    if
    visible.platform ~= "" and
        (Application.platform == RuntimePlatform.Android or Application.platform == RuntimePlatform.IPhonePlayer)
    then
        MailManager.Log("Application.platform: " .. tostring(Application.platform))
        if visible.platform == MailManager.PlatformType.iOS and Application.platform ~= RuntimePlatform.IPhonePlayer then
            MailManager.Log("id: " .. mail.Id .. " visible.platform.ios: " .. JSON.encode(visible))
            return false
        end
        
        if visible.platform == MailManager.PlatformType.Android and Application.platform ~= RuntimePlatform.Android then
            MailManager.Log("id: " .. mail.Id .. " visible.platform.android: " .. JSON.encode(visible))
            return false
        end
    end
    
    local currVerData = Utils.Version2Array(GameManager.version)
    
    -- assign
    if
    Utils.VersionIsValid(visible.verAssign) and
        not Utils.VersionIsZero(visible.verAssign) and
        Utils.VersionCompare(visible.verAssign, currVerData) ~= 0
    then
        MailManager.Log("id: " .. mail.Id .. " visible.verAssign: " .. JSON.encode(visible))
        return false
    end
    
    -- max
    if
    Utils.VersionIsValid(visible.verMax) and
        not Utils.VersionIsZero(visible.verMax) and
        Utils.VersionCompare(visible.verMax, currVerData) == -1
    then
        MailManager.Log("id: " .. mail.Id .. " visible.verMax: " .. JSON.encode(visible))
        return false
    end
    
    if
    Utils.VersionIsValid(visible.verMin) and
        not Utils.VersionIsZero(visible.verMin) and
        Utils.VersionCompare(visible.verMin, currVerData) == 1
    then
        MailManager.Log("id: " .. mail.Id .. " visible.verMin: " .. JSON.encode(visible))
        return false
    end
    
    return true
end

---@param mail Mail
---@return boolean
function Mail.IsClient(mail)
    return mail.Type == MailManager.Type.Client
end

-----------------------------------------------------------------------------------
----- MailManager
-----------------------------------------------------------------------------------

function MailManager.Init()
    if this.initialized then
        return
    end

    this.initialized = true
    this.unreadCountRx = NumberRx:New(0)
    this.serverLastRefreshTS = 0
    this.refreshMailTick = 0
    ---@type Mail[]
    this.showData = {}

    local nowTS = GameManager.GameTime()
    this.InitGlobalData(nowTS)
    this.RefreshClientList(nowTS)
    this.GainServerList(true, nowTS)

    --NetManager.AddRespEventListener(RespEvents.Mail, this.OnMailListFun)
    EventManager.AddListener(EventType.TIME_REAL_PER_SECOND, this.OnRefreshMail)
end

function MailManager.OnMailListFun()
    Log("mailList event")
    this.GainServerList(false, GameManager.GameTime())
end

function MailManager.OnRefreshMail()
    this.refreshMailTick = this.refreshMailTick + 1
    if this.refreshMailTick == 10 then
        this.refreshMailTick = 0
        this.RefreshUnreadCountRx()
        EventManager.Brocast(EventType.MAIL_LIST_CHANGE)
    end
end

function MailManager.GetUnreadCountRx()
    return this.unreadCountRx
end

function MailManager.SaveData()
    DataManager.SetGlobalDataByKey(DataKey.MailData, this.data)
end

---@param nowTS number
---@return table<number, number> id,status
---@private
function MailManager.InitGlobalData(nowTS)
    ---@type MailSaveData
    this.data =
        DataManager.GetGlobalDataByKey(DataKey.MailData) or
        {
            ServerData = {},
            ClientData = {},
            ClientIdx = 1
        }

    if this.data.ServerData == nil then
        this.data.ServerData = {}
    end

    if this.data.ClientData == nil then
        this.data.ClientData = {}
        this.data.ClientIdx = 1
    end

    MailManager.InitServerData()
    MailManager.InitClientData()
end

function MailManager.InitClientData()
    -- 清理过期的邮件，只要过期了，不管状态，都删掉
    for k, v in pairs(this.data.ClientData) do
        if this.IsExpireByCreateTs(v.CreateTS) then
            this.data.ClientData[k] = nil
        end
    end
end

function MailManager.InitServerData()
    for k, v in pairs(this.data.ServerData) do
        if this.IsExpireByCreateTs(v.CreateTS) then
            this.data.ServerData[k] = nil
        end
    end
end

---@param force boolean
---@param nowTS number
---@return Mail[]
---@private
function MailManager.GainServerList(force, nowTS)
    local mailOriginTS = this.serverLastRefreshTS
    if force then
        mailOriginTS = this.GetNowExpireTS()
    end

   -- NetManager.GetMailList(mailOriginTS, MailManager.OnGetServerList)

    this.serverLastRefreshTS = nowTS
end

---@param resp Protocol_GetMailListResp
---@private
function MailManager.OnGetServerList(resp)
    if resp ~= nil then
        local mails = {}
        local silentMails = {}
        local invalidMails = {}
        -- 修改数据，增加type字段
        
        for i = 1, #resp.mail_list do
            ---@type Mail
            local m = {}
            m.Id = resp.mail_list[i].id
            m.CreateTS = resp.mail_list[i].create_ts
            m.Status = resp.mail_list[i].status
            m.Title = resp.mail_list[i].title
            m.Content = resp.mail_list[i].content
            m.Attachment = resp.mail_list[i].attachment
            m.Type = MailManager.Type.Server
            m.Info = resp.mail_list[i].info

            m.Extended = Mail.GetDefaultExtended()
            if m.Info ~= nil and m.Info.extended ~= nil then
                -- 对扩展数据设置值
                local extended = JSON.decode(m.Info.extended)
                for k, v in pairs(extended) do
                    m.Extended[k] = v
                end
            end
    
            if Mail.IsSilent(m) then
                table.insert(silentMails, m)
            elseif Mail.IsInvalidForEver(m) then
                table.insert(invalidMails, m)
            else
                table.insert(mails, m)
            end
        end
    
        Log("server mail: " .. #resp.mail_list .. ", mail: " .. #mails .. ", silent: " .. #silentMails .. ", invalid: " .. #invalidMails)
        this.SyncServerMailData(mails)
        this.ProcessSilentMail(silentMails, invalidMails)
        this.RefreshUnreadCountRx()
    end
end

---处理静默邮件，有静默标记和有脚本，都是静默邮件
---@param silentMails Mail[]
---@param delMails Mail[]
function MailManager.ProcessSilentMail(silentMails, delMails)
    if #silentMails == 0 and delMails == 0 then
        return
    end

    local canClaimMails = {}
    local ids = {}

    for i = 1, #silentMails do
        if Mail.IsVisible(silentMails[i]) then
            table.insert(canClaimMails, silentMails[i])
            table.insert(ids, silentMails[i].Id)
        end
    end
    
    if #canClaimMails ~= 0 then
        this.ClaimMails(canClaimMails)
        return
    end
    
    for i = 1, #delMails do
        table.insert(ids, delMails[i].Id)
    end
    
    MailManager.Log("ProcessSilentMail: " .. JSON.encode(canClaimMails))
    MailManager.Log("ProcessDeleteMail: " .. JSON.encode(delMails))
    
    if #ids > 0 then
        NetManager.SetMailStatus(ids, MailManager.Status.Deleted)
    end
end

---@param mail Mail
function MailManager.ProcessScriptMail(mail)
    if (mail.Extended.luaScript or "") == "" then
        return
    end

    CS.FrozenCity.Framework.LuaUtils.DoString(mail.Extended.luaScript)
end

---@private
---@param mails Mail[]
function MailManager.SyncServerMailData(mails)
    local locChange = false
    local tempServerMap = {} -- 用于快速反查邮件
    local delMails = {}
    
    for i = 1, #mails do
        local m = mails[i]

        tempServerMap[tostring(m.Id)] = 1

        local locData = this.data.ServerData[tostring(m.Id)]
        if locData == nil then
            -- 如果本地不存在，那么这是一个新增的邮件
            locData = {}
            locData.Status = m.Status
            locData.CreateTS = m.CreateTS
            this.data.ServerData[tostring(m.Id)] = locData

            locChange = true
        else
            -- 某些情况下Status没存上
            locData.Status = locData.Status or MailManager.Status.Unread
            -- 如果本地存在，status不同
            if m.Status < locData.Status then
                -- 服务器状态小于本地，那么更新服务器状态
                NetManager.SetMailStatus({m.Id}, locData.Status)
                m.Status = locData.Status
            elseif m.Status > locData.Status then
                -- 服务器状态大于本地状态，说明本地状态有回滚
                locData.Status = m.Status
                locChange = true
            end
        end
        
        if not Mail.IsInvalidForEver(m) then
            if
            Utils.ArrayHasEx(
                this.showData,
                function(v)
                    return v.Id == m.Id
                end
            )
            then
                print("[error]" .. "mail exist: " .. m.Id)
            else
                table.insert(this.showData, 1, m)
            end
        else
            this.Log("not available: " .. JSON.encode(m))
            table.insert(delMails, m.Id)
            this.data.ServerData[tostring(m.Id)] = nil
        end
    end

    if locChange then
        EventManager.Brocast(EventType.MAIL_LIST_CHANGE)
        this.SaveData()
    end
    
    if #delMails > 0 then
        NetManager.SetMailStatus(delMails, this.Status.Deleted)
    end
end

---获取邮件列表，如果这时候服务器列表还没回来，那么返回空
---@return Mail[]
---@public
function MailManager.GetMailList()
    local newList = {}
    for i = 1, #this.showData do
        if Mail.IsVisible(this.showData[i]) then
            table.insert(newList, this.showData[i])
        end
    end
    
    return newList
end

---@return boolean
---@public
function MailManager.HasUnread()
    for _, v in pairs(this.GetMailList()) do
        if Mail.IsUnread(v) then
            return true
        end
    end

    return false
end

---@return number
function MailManager.UnreadCount()
    local count = 0
    for _, v in pairs(this.GetMailList()) do
        if Mail.IsUnread(v) then
            count = count + 1
        end
    end

    return count
end

---@return boolean
function MailManager.HasClaim()
    for _, v in pairs(this.GetMailList()) do
        if v.attachment ~= nil and next(v.attachment) ~= nil and v.status ~= MailManager.Status.Claimed then
            return true
        end
    end
end

---@param ts number
---@return boolean
function MailManager.IsExpireByCreateTs(ts)
    return ts <= this.GetNowExpireTS()
end

---@return boolean
function MailManager.HasMails()
    for _, v in pairs(this.GetMailList()) do
        if v.Status < MailManager.Status.Deleted and (not this.IsExpireByCreateTs(v.CreateTS)) then
            return true
        end
    end

    return false
end

---@return number
function MailManager.GetNowExpireTS()
    local nowTS = GameManager.GameTime() ---@type number
    return nowTS - MailExpireDuration
end

---@param mails Mail[]
---@param status number
function MailManager.SetStatus(mails, status)
    local serverIds = {}
    -- update local data
    for i = 1, #mails do
        -- 状态只能从低向高
        if mails[i].Status < status then
            mails[i].Status = status
            if Mail.IsClient(mails[i]) then
                local v = this.data.ClientData[tostring(mails[i].Id)]
                v.Status = status
                this.data.ClientData[tostring(mails[i].Id)] = v
            else
                local v = this.data.ServerData[tostring(mails[i].Id)]
                v.Status = status
                this.data.ServerData[tostring(mails[i].Id)] = v

                table.insert(serverIds, mails[i].Id)
            end
        end
    end

    this.RefreshUnreadCountRx()
    this.SaveData()

    if #serverIds ~= 0 then
        NetManager.SetMailStatus(serverIds, status)
    end
end

---@param mails Mail[]
function MailManager.ClaimMails(mails)
    local rewards = {}
    local events = {}
    for i = 1, #mails do
        if Mail.HasAttachment(mails[i]) then
            local mailRewards = this.ConvertAttachmentList2Rewards(mails[i].Attachment)
            Utils.MergeRewards(mailRewards, rewards)
        end

        this.ProcessScriptMail(mails[i])
        -- 当有多个事件时，合并事件，只发送一次
        if mails[i].Extended.event ~= "" then
            events[mails[i].Extended.event] = 1
        end
    end

    local rt = DataManager.AddReward(DataManager.GetCityId(), rewards, "MailReward", "MailReward")

    for k in pairs(events) do
        this.ProcessEvent(k)
    end

    return rt
end

---@param m1 Mail
---@param m2 Mail
---@return boolean
function MailManager.SortMail(m1, m2)
    local p1 = Mail.CalcPriority(m1)
    local p2 = Mail.CalcPriority(m2)

    if p1 == p2 then
        return m1.CreateTS > m2.CreateTS
    end

    return p1 < p2
end

function MailManager.RefreshUnreadCountRx()
    local uc = this.UnreadCount()
    this.unreadCountRx.value = this.UnreadCount()
end

---@param descId string
function MailManager.ShowMsgbox(titleId, descId)
    UIUtil.showConfirmByData(
        {
            Title = titleId,
            Description = descId,
            ShowYes = true,
            YesText = "ui_yes_btn"
        }
    )
end

---接受一个服务器item string，返回item类型和名字
---@param itemStr string
---@return string, string
function MailManager.GetRewardInfo(itemStr)
    local nameParts = string.split(itemStr, ".")
    return nameParts[1], nameParts[2]
end

function MailManager.Attachment2Rewards(attachment)
    local rewards = {}
    for k, c in pairs(attachment) do
        local rewardType, id = this.GetRewardInfo(k)
        local reward = Utils.ConvertAttachment2Rewards(id, c, rewardType)
        table.insert(rewards, reward)
    end

    return rewards
end

function MailManager.GetNextClientId()
    this.data.ClientIdx = this.data.ClientIdx + 1
    this.SaveData()
    return this.data.ClientIdx
end

---@param title string      多语言key
---@param content string    多语言key
---@param attachment table<string, number>
---@param effectiveTS number 生效时间
function MailManager.SendMailToSelf(title, content, attachment, effectiveTS)
    ---@type MailClientData
    local newMail = {}
    newMail.Id = this.GetNextClientId()
    newMail.CreateTS = GameManager.GameTime()
    newMail.Content = content
    newMail.Title = title
    newMail.Attachment = attachment
    newMail.Status = MailManager.Status.Unread
    newMail.EffectiveTS = effectiveTS

    this.data.ClientData[tostring(newMail.Id)] = newMail
    this.SaveData()

    this.SyncClientMail({this.ConvertClientMailToMail(newMail)})
end

---刷新客户端邮件列表
---@param nowTS number
function MailManager.RefreshClientList(nowTS)
    local mails = {}
    for _, mail in pairs(this.data.ClientData) do
        -- 过期邮件初始化时已经干掉了
        if this.IsClientEffective(mail, nowTS) and mail.Status < MailManager.Status.Deleted then
            table.insert(mails, this.ConvertClientMailToMail(mail))
        end
    end

    this.SyncClientMail(mails)
end

---@param mails Mail[]
function MailManager.SyncClientMail(mails)
    if #mails == 0 then
        return
    end

    for i = 1, #mails do
        table.insert(this.showData, mails[i])
    end

    this.RefreshUnreadCountRx()

    EventManager.Brocast(EventType.MAIL_LIST_CHANGE)
end

---@param mail MailClientData
function MailManager.ConvertClientMailToMail(mail)
    ---@type Mail
    local m = {}
    m.Id = mail.Id
    m.CreateTS = mail.CreateTS
    m.Title = GetLang(mail.Title)
    m.Content = GetLang(mail.Content)
    m.Attachment = mail.Attachment
    m.Status = mail.Status
    m.Info = {}
    m.Extended = Mail.GetDefaultExtended()
    m.Type = MailManager.Type.Client

    return m
end

---@param mail MailClientData
---@param nowTS number
---@return boolean
function MailManager.IsClientEffective(mail, nowTS)
    return mail.EffectiveTS <= nowTS
end

function MailManager.ConvertAttachmentList2Rewards(attachment)
    local rt = {}
    for k, v in pairs(attachment) do
        local nameParts = string.split(k, ".")
        local nameClass = nameParts[1]
        local addType = string.format("addTo%s", nameClass)
        local name = nameParts[2]

        if addType == RewardAddType.Item then
            -- 只有item资源才需要判断cityId，其他的card，global，box都不需要
            local itemConfig = ConfigManager.GetItemConfig(name)
            if itemConfig ~= nil then
                table.insert(
                    rt,
                    {
                        addType = addType,
                        id = name,
                        count = v
                    }
                )
            end
        else
            if addType == RewardAddType.Card then
                name = tonumber(name)
            elseif addType == RewardAddType.Box then
                -- 邮件的box直接打开，不要保存到BoxManager
                addType = RewardAddType.OpenBox
            end

            table.insert(
                rt,
                {
                    addType = addType,
                    id = name,
                    count = v
                }
            )
        end
    end

    return rt
end

--注册resp event事件
function MailManager.AddEventListener(event, handler)
--    if this.respEvent then
--        this.respEvent:AddListener(event, handler)
--    end
end

--反注册resp event事件
function MailManager.RemoveEventListener(event, handler)
--    if this.respEvent then
--        this.respEvent:RemoveEventListener(event, handler)
--    end
end

---@param event string
function MailManager.ProcessEvent(event)
    if event == "" then
        return
    end

    Log("MailManager.ProcessEvent: " .. event)

    --this.respEvent:Brocast(event)
    Event.Brocast(event)
end

function MailManager.Log(s)
    if this.showLog then
        Log("[mail] " .. s)
    end
end

--切换帐号重置数据
function MailManager.Reset()
    this.initialized = nil
    NetManager.RemoveRespEventListener(RespEvents.Mail, this.OnMailListFun)
    EventManager.RemoveListener(EventType.TIME_REAL_PER_SECOND, this.OnRefreshMail)
end
