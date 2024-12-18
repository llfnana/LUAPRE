--Warning 已删掉本地数据库(sqlite)，若要重新使用这个功能，则需要修改 

NotifMgr = class("NotifMgr")
local tooNearTime = 300

function NotifMgr:ctor()
    self.tags = {}
end

function NotifMgr:Inst()
    if nil == self.instance then
        self.instance = NotifMgr:New()
    end
    return self.instance;
end

function NotifMgr:Init()
end

function NotifMgr:Clear()
    --self:ClearLocalNotifications()
    self:CleanTags()
    self:DeleteAlias()
end

-- 添加本地推送
-- @delayTime 单位为秒
function NotifMgr:AddLocalNotification(delayTime, content)
    NotificationMgr:AddLocalNotification(delayTime, content)
end

-- 清除本地推送
function NotifMgr:ClearLocalNotifications()
    NotificationMgr:ClearLocalNotifications()
end

-- 添加标签
function NotifMgr:AddTag(tag)
    if not self.tags[tag] then
        NotificationMgr:AddTag(tag)
        self.tags[tag] = 1
    end
end

-- 删除标签
function NotifMgr:DeleteTag(tag)
    if self.tags[tag] then
        NotificationMgr:DeleteTag(tag)
        self.tags[tag] = nil
    end
end

-- 清除标签
function NotifMgr:CleanTags()
    NotificationMgr:CleanTags()
end

-- 获取别名
function NotifMgr:GetAlias()
    return self.alias or ''
end

-- 设置别名
function NotifMgr:SetAlias(alias)
    self.alias = alias
    NotificationMgr:SetAlias(alias)
end

-- 删除别名
function NotifMgr:DeleteAlias()
    self.alias = nil
    NotificationMgr:DeleteAlias()
end

-- 游戏焦点变化通知
function NotifMgr:OnFocus(bFocus)
    if bFocus then
        --self:ClearLocalNotifications()
    else
        --if GameStateData.isGameLogicRunning then
        --    self:AddLocalNotification(10, 'test')
        --end
    end
end

--添加本地推送,并指定Id
function NotifMgr:AddLocalNotificationWithId(type, param, delayTime, content)
    local id = self:CreateNotifyId(type, param)
    print("add local notification ..delayTime" .. delayTime .. "content" .. content .. "id=" .. id .. "type" .. type .. "param" .. param)
    NotificationMgr:AddLocalNotificationWithId(id, delayTime, content)
end

--移除指定Id的本地推送
function NotifMgr:TryDelNotificationById(type, param)
    local id = self:CreateNotifyId(type, param)
    local isNeedRemove = self:CheckIsNeedRemove(type, param)
    if isNeedRemove then
        print("remove notification by id " .. id .. "type" .. type .. "param" .. param)
        NotificationMgr:RemoveNotificationById(id)
    end
end

function NotifMgr:TryRemoveNotificationById(type, param)
    local id = self:CreateNotifyId(type, param)
    local isNeedRemove = self:CheckIsNeedRemove(type, param)
    if isNeedRemove then
        print("upd remove notification by id " .. id .. "type" .. type .. "param" .. param)
        NotificationMgr:RemoveNotificationById(id)
    end
end

NotifyType = {
    keji = 1,
    buildingLevelUp = 2,
    produceSoldier = 3,
    healSoldier = 4,
    cityResourceFull = 9,
    box = 10,
    tanbao = 11,
}

function NotifMgr:CreateNotifyId(type, param)
    if type == nil or param == nil then
        return 0
    end
    return tonumber(type) + tonumber(param) * 10
end

function NotifMgr:GetNotifyStateByGroupId(group)
    if group == nil then
        return true
    end

    --如果不存在,则默认是true
    return true;
end

function NotifMgr:GetNotifyContentByType(type)
    local tbl = TableManager:Inst():GetTabData(EnumTableID.TabNotify, type)
    if tbl then
        return GetStaticStr(tbl.DescID)
    end
    error("not find NotifyId==" .. type)
    return ""
end

function NotifMgr:IsExistNotify(type, param)
    local notifyId = self:CreateNotifyId(type, param)
    
    return false, 0;
end

function NotifMgr:GetMaxTriggerTime(type)
    local selectSql = string.format("select count(1), max(TriggerTime) from %s where Type=%u", DBTable.PlayerNotify, type)

    return 0;
end

function NotifMgr:CheckIsNeedRemove(type, param)
    local notifyId = self:CreateNotifyId(type, param)

    return false;
end
--添加或更新本地推送..
function NotifMgr:AddOrUpdNotifyById(type, param, triggerStamp, ...)
    if type == nil or param == nil or triggerStamp == nil then
        return
    end

    local tbl = TableManager:Inst():GetTabData(EnumTableID.TabNotify, type)
    if tbl == nil then
        error("type 为" .. type .. "TabNotify中没有此数据")
        return
    end

    local isOpen = self:GetNotifyStateByGroupId(tbl.Group)
    if not isOpen then
        print("推送type为" .. type .. "设置为关闭")
        return
    end

    local desc = GetStrDic(tbl.DescID)
    if desc == nil then
        return
    end
    local content = desc
    if ... ~= nil then
        content = string.format(desc, ...)
    end

    local isTooNear = false;
    if triggerStamp - TimeMgr:Inst():GetServerTime() < tooNearTime then
        isTooNear = true
    end

    local isExist, existId = self:IsExistNotify(type, param)
    if isExist then
        if not isTooNear then
            print("已经存在 ID" .. existId .. "type" .. type .. "param" .. param .. "进行更新.")
            self:TryRemoveNotificationById(type, param)
            self:AddLocalNotificationWithId(type, param, triggerStamp - TimeMgr:Inst():GetServerTime(), content)
            return
        else
            print("已经存在 ID" .. existId .. "type" .. type .. "param" .. param .. "但是小于300s,直接移除这条推送.")
            self:TryDelNotificationById(type, param)
        end

    end

    local interval = tbl.Interval
    local lastTriggerTime = self:GetMaxTriggerTime(type)
    if (triggerStamp > (lastTriggerTime + interval)) then
        if not isTooNear then
            self:AddLocalNotificationWithId(type, param, triggerStamp - TimeMgr:Inst():GetServerTime(), content)
            local notifyId = self:CreateNotifyId(type, param)
        else
            print("type" .. type .. "param" .. param .. "但是小于300s,所以不添加..")
        end

    else
        print("推送id为" .. self:CreateNotifyId(type, param) .. "type" .. type .. "param" .. param .. "小于间隔时间,所以不添加.还剩" .. (lastTriggerTime + interval - triggerStamp) .. "秒")
    end
end


--推送设置在数据库中是否存在
function NotifMgr:IsExistNotifySetting(group)
    return false;
end

--保存推送设置
function NotifMgr:SaveNotifySetting(group, isOpen)
    local isOpenNum = 1
    if isOpen ~= nil and isOpen == false then
        isOpenNum = 0
    end
    local isExist = self:IsExistNotifySetting(group)
    if isExist then
    else
    end
end


--获取所有的不推送的Group集合
function NotifMgr:GetNoPushGroupIdList()
    local list = {}
    return list
end