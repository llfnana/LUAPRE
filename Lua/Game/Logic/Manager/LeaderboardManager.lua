LeaderboardManager = {}
LeaderboardManager._name = "LeaderboardManager"
local this = LeaderboardManager

LeaderboardManager.Limit = 1000
LeaderboardManager.ExpireDuration = 60

---@class LeaderboardData
---@field rankList RankInfo[]
---@field group number
---@field rankSelf number
---@field scoreSelf number
---@field refreshTS number

function LeaderboardManager.Init()
    if this.initialized then
        return
    end

    this.initialized = true

    ---@type table<string, LeaderboardData>
    this.data = {}

    local ldjs = PlayerPrefs.GetString(this.Key())
    if ldjs ~= "" then
        this.data = JSON.decode(ldjs)
    end

    this.preLeaderboardScore = {}
end

function LeaderboardManager.NewData()
    this.data = {}
    this.SaveData()
end

function LeaderboardManager.Key()
    return DataManager.Key2Prefs("Leaderboard")
end

function LeaderboardManager.SaveData()
    PlayerPrefs.SetString(this.Key(), JSON.encode(this.data))
end

---排行榜是否过期，需要更新
------@param nowTS number
function LeaderboardManager.IsExpire(eventId, nowTS)
    local eventCache = this.GetCache(eventId)
    return not (eventCache ~= nil and eventCache.refreshTS + LeaderboardManager.ExpireDuration >= nowTS)
end

---@param nowTS number
---@param cb fun(rankList:RankInfo[], rankSelf:number, scoreSelf:number)
---@param forceServer boolean
function LeaderboardManager.Get(eventId, nowTS, forceServer, cb)
    if not forceServer then
        if not this.IsExpire(eventId, nowTS) then
            local eventCache = this.GetCache(eventId)

            if cb ~= nil then
                cb(eventCache.rankList, eventCache.rankSelf, eventCache.scoreSelf)
            end

            return
        end
    end

    local eventConfig = ConfigManager.GetEventSceneConfigById(eventId)
    local eventRankList = ConfigManager.GetEventRankByGroup(eventConfig.milestone_group)
    local leaderboardLimit = eventRankList[eventRankList:Count()].rank_end
    if leaderboardLimit > LeaderboardManager.Limit then
        leaderboardLimit = LeaderboardManager.Limit
    end

    NetManager.GetLeaderboardScore(
        eventId,
        leaderboardLimit,
        function(resp)
            if resp == nil then
                return
            end

            local rank = resp.rank + 1
            this.SetCache(eventId, resp.group, resp.rank_list, rank, resp.score)
            if cb ~= nil then
                cb(resp.rank_list, resp.group, rank, resp.score)
            end

            EventManager.Brocast(EventType.LEADERBOARD_REFRESH, eventId, resp.rank_list, resp.group, rank, resp.score)
        end
    )
end

function LeaderboardManager.GetCache(eventId)
    return this.data[tostring(eventId)]
end

---@private
function LeaderboardManager.SetCache(eventId, group, rankList, rank, score)
    this.data[tostring(eventId)] = {
        rankList = rankList,
        group = group,
        rankSelf = rank,
        scoreSelf = score,
        refreshTS = GameManager.GameTime()
    }

    this.SaveData()
end

--- 更新排行榜，当分数为0或者分数没变时，不上传服务器
---@param cb fun(rsp:table)
function LeaderboardManager.UploadScoreToServer(eventId, score, force, cb, immediately)
    if not force and (score == 0 or this.preLeaderboardScore[eventId] == score) then
        return
    end

    -- 如果活动已经结束，那么不上传
    local eventConfig = ConfigManager.GetEventSceneConfigById(eventId)
    if eventConfig.end_time < GameManager.GameTime() then
        return
    end

    -- NetManager.SetLeaderboardScore(
    --     eventId,
    --     ProfileManager.GetNickname(),
    --     ProfileManager.GetIcon(),
    --     score,
    --     function(rsp)
    --         if rsp == nil then
    --             return
    --         end

    --         this.preLeaderboardScore[eventId] = score

    --         if cb ~= nil then
    --             cb(rsp)
    --         end
    --     end,
    --     immediately
    -- )
end

---根据rank，返回对应的reward
---@param rankRewards EventRank[]
---@param rank number
---@return table
function LeaderboardManager.GetRewards(rankRewards, rank)
    for i = 1, #rankRewards do
        local rankReward = rankRewards[i]
        if rankReward.rank_start <= rank and rankReward.rank_end >= rank then
            return Utils.ParseReward(rankReward.rewards)
        end
    end

    return {}
end

---@param rankRewards EventRank[]
---@return number
function LeaderboardManager.GetRewardsMaxRankEnd(rankRewards)
    local maxRankEnd = 0
    for i = 1, #rankRewards do
        local rankReward = rankRewards[i]
        if rankReward.rank_end > maxRankEnd then
            maxRankEnd = rankReward.rank_end
        end
    end
    return maxRankEnd
end

---@param cb fun(rankList:RankInfo[], rankSelf:number, scoreSelf:number)
function LeaderboardManager.UploadAndGet(cb)
    this.UploadScoreToServer(EventSceneManager.GetEventId(), EventSceneManager.GetSumCashCount(), true, nil, false)
    this.Get(EventSceneManager.GetEventId(), GameManager.GameTime(), true, cb)
end

--切换帐号重置数据
function LeaderboardManager.Reset()
    this.initialized = nil
end
