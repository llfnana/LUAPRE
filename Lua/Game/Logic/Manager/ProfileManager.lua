ProfileManager = {}
ProfileManager._name = "ProfileManager"
local this = ProfileManager

---@class ProfileData
---@field icon string
---@field nickname string
---@field lang string
---@field changeCount number

ProfileManager.NicknameMinLength = 3
ProfileManager.NicknameMaxLength = 16

ProfileManager.ErrorIdIsProfanity = 100001

function ProfileManager.Init()
    if this.initialize == nil then
        this.initialize = true

        ---@type ProfileData
        this.data = DataManager.GetGlobalDataByKey(DataKey.Profile) or ProfileManager.NewData()
        this.changeFreeCount = ConfigManager.GetMiscConfig("profile_change_free_count")
        this.changeGemCount = ConfigManager.GetMiscConfig("profile_change_gem_count")
        this.SetLanguage("en")

        --todo: 临时加在这里,设置排行榜分组
        NetManager.SetExtended(1)
    end
end

---@private
---@return ProfileData
function ProfileManager.NewData()
    return {
        icon = "",
        nickname = "",
        lang = "",
        changeCount = 0
    }
end

function ProfileManager.SaveData()
    DataManager.SetGlobalDataByKey(DataKey.Profile, this.data)
end

function ProfileManager.CheckAndGetIcon(id, uid)
    if id == nil or id == "" then
        return tostring(uid % 10 + 1)
    end

    return id
end

function ProfileManager.CheckAndGetNickname(nickname, uid)
    if nickname == nil or nickname == "" then
        return "Survivor_" .. tonumber(uid) % 10000
    end

    return nickname
end

function ProfileManager.GetIcon()
    return this.CheckAndGetIcon(this.data.icon, DataManager.uid)
end

function ProfileManager.GetNickname()
    return this.CheckAndGetNickname(this.data.nickname, DataManager.uid)
end

function ProfileManager.GetChangeCount()
    return this.data.changeCount or 0
end

function ProfileManager.IncrChangeCount()
    this.data.changeCount = this.GetChangeCount() + 1
end

function ProfileManager.ChangeIsFree()
    return this.GetChangeCount() < this.changeFreeCount
end

function ProfileManager.IsEnoughCostForChange()
    local gemCount = DataManager.GetMaterialCount(DataManager.GetCityId(), ItemType.Gem)
    return gemCount >= this.changeGemCount
end

function ProfileManager.GetChangeGemCost()
    return this.changeGemCount
end

---@param cb fun(errId: number)
function ProfileManager.SetProfile(nickname, icon, cb)
    local function SetProfileResponse(resp, errMsg)
        if resp ~= nil then
            local isFree = this.ChangeIsFree()
            if resp.err_id == 0 then
                this.data.nickname = nickname
                this.data.icon = icon
                Analytics.Event(
                    "EventChangeUserInfo",
                    {
                        eventId = 1--EventSceneManager.GetEventId(),
                        isUsedGem = not isFree
                    }
                )
                EventManager.Brocast(EventType.REFRESH_EVENT_PROFILE)
                if not isFree then
                    DataManager.UseMaterial(
                        DataManager.GetCityId(),
                        ItemType.Gem,
                        this.changeGemCount,
                        "Profile",
                        "Profile"
                    )
                end
                this.IncrChangeCount()
                this.SaveData()
            end
            if cb ~= nil then
                cb(resp.err_id)
            end
        else
            if cb ~= nil then
                cb(errMsg)
            end
        end
    end
    NetManager.SetProfile(nickname, icon, SetProfileResponse)
end

--- 设置语言
---@param cb fun() 成功时调用
---@param force boolean
function ProfileManager.SetLanguage(lang, cb, force)
    force = force or false

    if not force and (lang == "" or this.data.lang == lang) then
        Log("lang same.")
    -- return --每次都发送设置语言消息
    end

    NetManager.SetProfileLanguage(
        lang,
        function(resp, err)
            if resp ~= nil then
                this.data.lang = lang
                this.SaveData()

                if cb ~= nil then
                    cb()
                end
            end
        end
    )
end

--切换帐号重置数据
function ProfileManager.Reset()
    this.initialize = nil
end
