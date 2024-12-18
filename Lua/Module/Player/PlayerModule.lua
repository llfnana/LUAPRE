------------------------------------------------------------------------
--- @desc 玩家模块
--- @author sakuya
------------------------------------------------------------------------
--region -------------引入模块-------------
require "Module/Player/PlayerCharge"
--endregion

--region -------------数据定义-------------

--endregion

--region -------------私有变量-------------
local module = {}
local fn = {}

local notice = nil -- 游戏公告

local uid = nil --玩家UID

---@class PlayerSettingData 设置数据
local setting = {
    musicOn = true, --音乐是否开启
    soundOn = true, --音效是否开启
    language = 2,   --语言
    quality = 2,    --画质
    generator = 0,  -- 净化器然不足每日提醒

}

local svrVersion = nil --服务端版本号

local sdkPlatform = "local" --SDK平台

local mailList = {} --邮件列表
local onceLoadingBg = nil
local openExchange = false
local offlineRewards = {
   
} --物资援助数据
--endregion
--region -------------公共变量-------------
--endregion

function module.init()
    fn.init()

    makergetFn(Sc(), "mail"):addEvent("mailList", fn.s2cInitMailList)
    makergetFn(Sc(), "mail"):addEventUpdate("mailList", fn.s2cUpMailList)
    makergetFn(Sc(), "mail"):addEventDelete("mailList", fn.s2cDelMailList)

    makergetFn(Sc(), "user"):addEvent("offline", fn.s2cUpOfflineRewards)
    makergetFn(Sc(), "user"):addEventUpdate("offline", fn.s2cUpOfflineRewards)
    
    makergetFn(Sc(), "derail"):addEvent("list", fn.s2cInitDerail)
end

function module.release()
end

--region -------------公有函数-------------


function module.getOpenExchange()
    return openExchange
end

function fn.s2cInitDerail(vo)
    local str = string.split(vo.switch, ";")
    local state = 0
    for i, v in ipairs(str) do
        local temp = string.split(v, ":")
        if temp[1] == "giftSwitch" then
            state = tonumber(temp[2])
            break
        end
    end
    
    openExchange = state == 1
end

---切换设置背景音乐
function module.switchSettingMusic()
    setting.musicOn = not setting.musicOn
    StorageModule.set(StorageModule.enum.SETTING, setting)

    Audio.SetEnableMusic(setting.musicOn) --设置背景音乐
end

---切换设置音效
function module.switchSettingSound()
    setting.soundOn = not setting.soundOn
    StorageModule.set(StorageModule.enum.SETTING, setting)

    Audio.SetEnableSound(setting.soundOn) --设置音效
end

---设置语言
function module.switchSettingLanguage(id)
    local list = module.getLanguageList()
    local lang = list[id]
    setting.language = id
    StorageModule.set(StorageModule.enum.SETTING, setting)
    Language.addLang()
    EventManager.Brocast(EventDefine.LanguageChange)
    module.c2sSetLang(lang.flag)
end

---切换设置画质
function module.switchSettingQuality(quality)
    setting.quality = quality
    StorageModule.set(StorageModule.enum.SETTING, setting)

    EventManager.Brocast(EventDefine.QualityChange)
end

--获取语言列表
function module.getLanguageList()
    
    return {
        [1] = {
            flag  = "En",
            value = "UI_language_english",
        },
        [2] = {
            flag  = "Cn",
            value = "UI_language_chinese",
        },
        -- [3] = {
        --     flag  = "Id",
        --     value = "UI_language_indonesian",
        -- },
    }
end

---设置玩家UID
function module.SetUid(_uid)
    uid = _uid
end

---获取玩家UID
function module.GetUid(_uid)
    return uid
end

--获取当前语言
function module.getLanguage()
    return setting.language
end

--获取邮件列表
function module.getMailList()
    local outList = {}
    for k, v in pairs(mailList) do
        table.insert(outList, v)
    end
    return outList
end

--获取物资援助数据
function module.getOfflineRewards()
    return offlineRewards
end

--获取邮件Data
function module.getMailDataById(id)
    return mailList[id]
end

--获取音乐开关
function module.getMusicWitch()
    return setting.musicOn
end
--获取音效开关
function module.getSoundWitch()
    return setting.soundOn
end
--获取画质等级
function module.getQualityWitch()
    return setting.quality or 2
end

---获取sdk平台
function module.getSdkPlatform()
    return sdkPlatform
end

-- 净化器每日燃料不足提醒
function module.getGeneratorEverydayWarnning() 
    local day = os.date("%j", os.time())

    -- 除非跨了一年再登录游戏
    return setting.generator ~= day
end

-- 净化器每日燃料不足提醒
function module.setGeneratorEverydayWarnning(isJumpToday) 
    if isJumpToday then 
        local day = os.date("%j", os.time())
        setting.generator = day
        StorageModule.set(StorageModule.enum.SETTING, setting)
    end
end

--endregion



--region -------------私有函数-------------

function fn.init()
    setting = StorageModule.get(StorageModule.enum.SETTING, setting)

    Audio.SetEnableSound(setting.soundOn) --设置音效
    Audio.SetEnableMusic(setting.musicOn) --设置背景音乐

    if MiniGame.DHWXSDK.Instance.SDKFlag then
        sdkPlatform = "wx"
    else
        sdkPlatform = "local"
    end
end

--endregion

--region -------------网络请求-------------

--本地环境下充值测试
function module.c2sOrderTest(id, cid, cb)
    local function callback(data)
        if cb then
            cb(data)
        end
    end

    local vo = NewCs("order")
    vo.info.order.orderTest.goodsid = id
    vo.info.order.orderTest.shopCid = cid
    vo:add(callback, true)
    vo:send()
end

function module.c2sGetMail(cb)
    local function callback()
        if cb then
            cb()
        end
    end

    local vo = NewCs("mail")
    vo.info.mail.getMail = ""
    vo:add(callback, true)
    vo:send()
end
function module.c2sReceiveMail(id, cb)
    local function callback()
        if cb then
            cb()
        end
    end

    local vo = NewCs("mail")
    vo.info.mail.receiveItem.id = id
    vo:add(callback, true)
    vo:send()
end
function module.c2sOpenMail(id, cb)
    local function callback()
        if cb then
            cb()
        end
    end

    local vo = NewCs("mail")
    vo.info.mail.openMail.id = id
    vo:add(callback, true)
    vo:send()
end
function module.c2sReceiveAllMail(cb)
    local function callback()
        if cb then
            cb()
        end
    end

    local vo = NewCs("mail")
    vo.info.mail.receiveAllItems = ""
    vo:add(callback, true)
    vo:send()
end
function module.c2sDeleteAllMail(cb)
    local function callback()
        if cb then
            cb()
        end
    end

    local vo = NewCs("mail")
    vo.info.mail.delAllMails = ""
    vo:add(callback, true)
    vo:send()
end
function module.c2sDeleteMail(id, cb)
    local function callback()
        if cb then
            cb()
        end
    end

    local vo = NewCs("mail")
    vo.info.mail.delMail.id = id
    vo:add(callback, true)
    vo:send()
end

-- 同步城市id与净化器等级（致物质援助等级变化）
function module.c2sSyncCityAndGenerator(cityId, generatorLv, cb)
    local function callback()
        if cb then
            cb()
        end
    end

    local vo = NewCs("user")
    vo.info.user.syncCityAndGenerator.cityId = cityId
    vo.info.user.syncCityAndGenerator.gid = generatorLv
    vo:add(callback, true)
    vo:send()
end

--刷新净化物资离线时间
function module.c2sgetOfflineProfit(cb)
    local function callback()
        if cb then
            cb()
        end
    end

    local vo = NewCs("user")
    vo.info.user.getOfflineProfit = ""
    vo:add(callback, true)
    vo:send()
end

--领取物资援助奖励
function module.c2sReceiveOfflineRewards(cb)
    local function callback()
        if cb then
            cb()
        end
    end

    local vo = NewCs("user")
    vo.info.user.receiveOfflineProfit = ""
    vo:add(callback, true)
    vo:send()
end

--设置语言 设置语言-语言标识，zh中文en英文
function module.c2sSetLang(lang, cb)
    local function callback()
        if cb then
            cb()
        end
    end

    local vo = NewCs("user")
    vo.info.user.setLang.lang = ""
    vo:add(callback, true)
    vo:send()
end

--礼物兑换码兑换
function module.c2sExchangeGift(code, cb)
    local function callback(data)
        if cb then
            cb(data)
        end
    end

    local vo = NewCs("recode")
    vo.info.recode.exchange.key = code
    vo:add(callback, true)
    vo:send()
end

-- 解锁离线援助
function module.c2sUnlockOfflineProfit(cb)
    local function callback()
        if cb then
            cb()
        end
    end

    local vo = NewCs("user")
    vo.info.user.unlockOfflineProfit = ""
    vo:add(callback, true)
    vo:send()
end

function fn.s2cUpMailList(vo)
    for k, v in pairs(vo) do
        mailList[v.id] = v
    end

    EventManager.Brocast(EventDefine.OnMailListUpdate)
end
function fn.s2cInitMailList(vo)
    for k, v in pairs(vo) do
        mailList[v.id] = v
    end

    EventManager.Brocast(EventDefine.OnMailListUpdate)
end
function fn.s2cDelMailList(vo)
    for k, v in pairs(vo) do
        mailList[v.id] = nil
    end

    EventManager.Brocast(EventDefine.OnMailListDelete)
end

--物资援助
function fn.s2cUpOfflineRewards(vo)
    offlineRewards.todayGetDuration = vo.todayGetDuration or offlineRewards.todayGetDuration
    offlineRewards.todayDuration = vo.todayDuration or offlineRewards.todayDuration
    offlineRewards.beforeDuration = vo.beforeDuration or offlineRewards.beforeDuration
    offlineRewards.privilege = vo.privilege or offlineRewards.privilege
end

--endregion

local payAreaId = 1
function module.SetPayAreaId(areaId)
    payAreaId = areaId
end

function module.GetPayAreaId()
    return payAreaId
end

return module
