HelpShiftManager = {}
HelpShiftManager.__cname = "HelpShiftManager"

local this = HelpShiftManager

function HelpShiftManager.AddEvent()
    this.isOpen = false
    this.helpShiftUnreadCount = 0
    --如果是true 说明在游戏内点击过 此时开启30秒轮询是否有未读消息
    HelpShiftSDK.Instance:Init(HelpShiftManager.ReceiveUnreadMessagesCount)
end

function HelpShiftManager.Init()
    this.helpShiftUnreadCount = 0
    clearInterval(this.timeId)
    if this.isOpen then
        this.timeId =
            setInterval(
            function()
                this.RequestUnreadMessagesCount()
            end,
            30000
        )
    end
    this.RequestUnreadMessagesCount()
end

function HelpShiftManager.ReceiveUnreadMessagesCount(count)
    Log("ReceiveUnreadMessagesCount: " .. count)
    this.helpShiftUnreadCount = count
    EventManager.Brocast(EventType.REFRESH_HELPSHIFT_REDPOINT)
end

function HelpShiftManager.GetHelpShiftUnreadMsgCount()
    return this.helpShiftUnreadCount
end

function HelpShiftManager.ClearHelpShiftUnreadMsg()
    this.helpShiftUnreadCount = 0
    EventManager.Brocast(EventType.REFRESH_HELPSHIFT_REDPOINT)
end

function HelpShiftManager.RequestUnreadMessagesCount()
    if this.helpShiftUnreadCount > 0 then
        return
    end
    HelpShiftSDK.Instance:RequestUnreadMessagesCount()
end

function HelpShiftManager.ShowFAQS()
    GameManager.DontReload = true
    HelpShiftSDK.Instance:ShowFAQS()
end

function HelpShiftManager.ShowConversation()
    GameManager.DontReload = true
    HelpShiftSDK.Instance:ShowConversation()
    this.isOpen = true
    clearInterval(this.timeId)
    this.timeId =
        setInterval(
        function()
            this.RequestUnreadMessagesCount()
        end,
        30000
    )
end

function HelpShiftManager.Clear()
    this.helpShiftUnreadCount = 0
    clearInterval(this.timeId)
end
