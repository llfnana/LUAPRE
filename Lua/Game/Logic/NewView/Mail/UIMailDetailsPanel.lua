---@class UIMailDetailsPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIMailDetailsPanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.btnClose = SafeGetUIControl(this, "BtnClose", "Button")

    this.uidata.textContent = SafeGetUIControl(this, "MailBox/TextScroll/Viewport/Content")
    this.uidata.textMail = SafeGetUIControl(this, "MailBox/TextScroll/Viewport/Content/TextMail", "HyperlinkText")   --邮件内容
    this.uidata.textTitle = SafeGetUIControl(this, "MailBox/TitleItem/TextTitle", "Text")           --标题时间
    this.uidata.textTime = SafeGetUIControl(this, "MailBox/TitleItem/TextTime", "Text")             --时间数字
    this.uidata.textTimeBack = SafeGetUIControl(this, "MailBox/TitleItem/TextTime/Text", "Text")    --时间天分秒

    this.uidata.btnReceive = SafeGetUIControl(this, "BtnReceive", "Button")
    this.uidata.btnDelete = SafeGetUIControl(this, "BtnDelete", "Button")

    this.uidata.warning = SafeGetUIControl(this, "BottomTip")

    this.uidata.rwdBoxScrollContent = SafeGetUIControl(this, "RwdBox/Scroll/Viewport/Content")
    this.uidata.titleItem = SafeGetUIControl(this, "RwdBox/TitleItem")                                 --奖励标题
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.btnClose.gameObject, this.HideUI)
    SafeAddClickEvent(this.behaviour, this.uidata.btnReceive.gameObject, this.OnClickReceive)
    SafeAddClickEvent(this.behaviour, this.uidata.btnDelete.gameObject, this.OnClickDelete)

    -- 绑定超链接函数
    this.uidata.textMail.luaFunction = function (data)
        Application.OpenURL(data)
    end
end

function Panel.OnClickReceive()
    PlayerModule.c2sReceiveMail(this.mailData.id, function ()
        this.mailData = PlayerModule.getMailDataById(this.mailData.id)
        this.UpdatePanel()

        local rewards = {}
        local cityId = DataManager.GetCityId()
        for k, v in ipairs(this.mailData.items) do
            rewards[k] = Utils.ConvertAttachment2Rewards(v.id, v.count, RewardAddType.Item)
            if v.id == "Gamecoins1" or v.id == "Gamecoins2" then
                BagModule.useItem(v.id,v.count)
            else
                DataManager.AddMaterial(cityId, v.id, v.count)
            end
            -- DataManager.AddMaterial(cityId, v.id, v.count)
        end
        ResAddEffectManager.AddResEffectFromRewards(rewards, true)
    end)
end
function Panel.OnClickDelete()
    PlayerModule.c2sDeleteMail(this.mailData.id, function ()
        this.HideUI()
    end)
end

function Panel.OnShow(param)
    UIUtil.openPanelAction(this.gameObject)

    this.mailData = param.mailData

    this.uidata.warning:SetActive(false)
    this.UpdatePanel()
end

function Panel.UpdatePanel()
    local data  = this.mailData
    this.uidata.textMail.text = data.content
    ForceRebuildLayoutImmediate(this.uidata.textContent)
    this.uidata.textTitle.text = TimeUtil.formatDate(data.sendTime)
    local numStr, backStr = this.GetTimeText(data.sendTime)
    this.uidata.textTime.text = numStr
    this.uidata.textTimeBack.text = backStr

    this.uidata.titleItem:SetActive(not (data.type == 1))

    local rwds = data.items
    local canReceive = rwds and #rwds > 0 and (data.status == 0 or data.status == 1) and data.type == 2
    this.uidata.btnReceive.gameObject:SetActive(canReceive)
    -- GreyObject(this.uidata.btnReceive.gameObject, not canReceive, canReceive)
    this.uidata.btnDelete.gameObject:SetActive(data.status == 2 or data.type == 1)

    this.UpdateRwdPanel()
end

function Panel.UpdateRwdPanel()
    local parent = this.uidata.rwdBoxScrollContent
    local temp = SafeGetUIControl(this, "RwdBox/MailRwdItem")

    local received = this.mailData.status == 2 -- 是否已领取
    UIUtil.RemoveAllGameobject(parent)
    for k, v in ipairs(this.mailData.items) do
        local newRwdItem = GOInstantiate(temp)
        newRwdItem.transform:SetParent(parent.transform, false)
        newRwdItem:SetActive(true)

        local icon = SafeGetUIControl(newRwdItem, "Icon", "Image")
        Utils.SetItemIcon(icon, v.id)
        local countText = SafeGetUIControl(newRwdItem, "BgCount/Text", "Text")
        countText.text = "+" .. Utils.FormatCount(v.count)
        local imageBtn = SafeGetUIControl(newRwdItem, "ImageBtn")
        UIUtil.AddItem(imageBtn, v.id)

        if received then
            GreyObject(icon.gameObject, true, false)
            GreyObject(countText.gameObject, true, false)
        end
    end
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
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UIMailDetails)
    end)
end
