---@class UIMailPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIMailPanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.btnClose = SafeGetUIControl(this, "BtnClose", "Button")

    this.uidata.btnDeleteAll = SafeGetUIControl(this, "BtnDeleteAll", "Button")
    this.uidata.btnReceiveAll = SafeGetUIControl(this, "BtnReceiveAll", "Button")
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.btnClose.gameObject, this.HideUI)

    SafeAddClickEvent(this.behaviour, this.uidata.btnDeleteAll.gameObject, this.OnClickDeleteAll)
    SafeAddClickEvent(this.behaviour, this.uidata.btnReceiveAll.gameObject, this.OnClickReceiveAll)

    this.AddListener(EventDefine.OnMailListUpdate, function ()
        this.UpdateList()
        this.UpdateBtn()
    end)
    this.AddListener(EventDefine.OnMailListDelete, function ()
        this.UpdateList()
        this.UpdateBtn()
    end)
end

function Panel.OnShow()
    UIUtil.openPanelAction(this.gameObject)
    this.InitEvent()

    this.mailItems = {}
    this.UpdateList()
    this.UpdateBtn()
end

function Panel.UpdateList()
    this.mailItems = this.mailItems or {}
    this.mailList = clone(PlayerModule.getMailList())
    table.sort(this.mailList, function (a, b)
        if a.status ~= b.status then
            return a.status < b.status
        end
        if a.sendTime ~= b.sendTime then
            return a.sendTime > b.sendTime
        end
        return a.id < b.id
    end)

    local itemLen = #this.mailItems
    local datasLen = #this.mailList
    local len = math.max(itemLen, datasLen)

    for k = 1, len do
        local mailItem = this.mailItems[k] or this.GetMailItem(k)
        if this.mailList[k] ~= nil then
            mailItem:SetActive(true)
            this.UpItem(mailItem, k)
        else
            mailItem:SetActive(false)
        end
    end

    local empty = SafeGetUIControl(this, "Empty")
    empty:SetActive(datasLen <= 0)
end
function Panel.UpdateBtn()
    local canReceive = false
    local canDelete = false

    for k, v in ipairs(this.mailList) do
        if (v.status == 0 or v.status == 1) and #v.items > 0 and v.type == 2 then
            canReceive = true
        end
        if v.status == 2 or (v.status == 1 and #v.items == 0) then
            canDelete = true
        end
    end

    GreyObject(this.uidata.btnDeleteAll.gameObject, not canDelete, canDelete)
    GreyObject(this.uidata.btnReceiveAll.gameObject, not canReceive, canReceive)
end

function Panel.OnClickDeleteAll()
    PlayerModule.c2sDeleteAllMail(function ()
        this.UpdateList()
        this.UpdateBtn()
    end)
end
function Panel.OnClickReceiveAll()
    local allReward = {}
    for k, v in ipairs(this.mailList) do
        if v.status == 0 or v.status == 1 then
            for kk, vv in ipairs(v.items) do
                table.insert(allReward, Utils.ConvertAttachment2Rewards(vv.id, vv.count, RewardAddType.Item))
            end
        end
    end
    PlayerModule.c2sReceiveAllMail(function ()
        this.UpdateList()
        this.UpdateBtn()

        local rewards = {}
        local cityId = DataManager.GetCityId()
        for k, v in ipairs(allReward) do
            rewards[k] = Utils.ConvertAttachment2Rewards(v.id, v.count, RewardAddType.Item)
            if v.id == "Gamecoins1" or v.id == "Gamecoins2" then
                BagModule.useItem(v.id,v.count)
            else
                DataManager.AddMaterial(cityId, v.id, v.count)
            end
        end
        ResAddEffectManager.AddResEffectFromRewards(rewards, true)
    end)
end

function Panel.GetMailItem(k)
    local temp = SafeGetUIControl(this, "Scroll/Viewport/Content/MailItem")
    local go = GOInstantiate(temp)
    go.transform:SetParent(temp.transform.parent, false)
    if this.mailItems then
        this.mailItems[k] = go
    end
    return go
end
function Panel.UpItem(item, k)
    local data = this.mailList[k]
    local titleText = SafeGetUIControl(item, "TextTitle", "Text")
    local timeText = SafeGetUIControl(item, "TextTime", "Text")
    local timeTextBack = SafeGetUIControl(item, "TextTime/Text", "Text")
    local btn = SafeGetUIControl(item, "Button", "Button")
    local received = SafeGetUIControl(item, "Received", "Image")
    local icon = SafeGetUIControl(item, "Icon/Icon", "Image")
    received.gameObject:SetActive(data.status == 2 or data.status == 1)

    titleText.text = data.title
    local timeStr_, _timeStr = this.GetTimeText(data.sendTime)
    timeText.text = timeStr_
    timeTextBack.text = _timeStr

    local iconName = ""
    if data.type == 1 then
        if data.status == 0 then
            iconName = "icon_mail_close"
        else
            iconName = "icon_mail_open"
        end
    elseif data.type == 2 then
        if data.status == 2 then
            iconName = "icon_mail_open"
        else
            iconName = "icon_mail_reward"
        end
    end
    Utils.SetIcon(icon, iconName)

    SafeAddClickEvent(this.behaviour, btn.gameObject, function()
        if data.status == 0 then
            PlayerModule.c2sOpenMail(data.id, function ()
                ShowUI(UINames.UIMailDetails, {mailData = data})
            end)
        else
            ShowUI(UINames.UIMailDetails, {mailData = data})
        end
    end)
end

function Panel.GetTimeText(time)
    local nowTime = TimeModule.getServerTime(true)
    local subTime = nowTime - time

    local numStr = ""
    local backStr = ""

    local totalMinuteSec = 60
    local totalHourSec = 3600
    local totalDaySec = 86400

    numStr = subTime < totalMinuteSec and "" 
        or  subTime < totalHourSec and math.floor(subTime / totalMinuteSec)
        or  subTime < totalDaySec and math.floor(subTime / totalHourSec)
        or  math.floor(subTime / totalDaySec)
    backStr = subTime < totalMinuteSec and GetLang("ui_mail_time_just_now")
        or  subTime < totalHourSec and GetLang("UI_Mail_Time_Min") .. "" .. GetLang("UI_Mail_Time_Ago")
        or  subTime < totalDaySec and GetLang("UI_Mail_Time_Hour") .. "" .. GetLang("UI_Mail_Time_Ago")
        or  GetLang("UI_Mail_Time_Day") .. "" .. GetLang("UI_Mail_Time_Ago")

    return numStr, backStr
end

function Panel.HideUI()
    for k, v in pairs(this.mailItems) do
        GameObject.Destroy(v)
    end
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UIMail)
    end)
end
