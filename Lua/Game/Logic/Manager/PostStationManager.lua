---驿站，保存暂时不能领取的数据
PostStationManager = {}
PostStationManager.__cname = "PostStationManager"

local this = PostStationManager

---@class RetentionData
---@field rewards Reward[]
---@field from table
---@field fromId table

function PostStationManager.Init()
    if this.initialized == nil then
        this.initialized = true

        this.data =
            DataManager.GetGlobalDataByKey(DataKey.PostStation) or
            {
                ---@type RetentionData[]
                retentionList = {},
            }
    end
end

function PostStationManager.InitView()
    --每次进入场景
    this.RestoreData(DataManager.GetCityId())
end

function PostStationManager.SaveData()
    DataManager.SetGlobalDataByKey(DataKey.PostStation, this.data)
end

---将暂存的奖励恢复到当前场景
function PostStationManager.RestoreData(cityId)
    for i = 1, #this.data.retentionList do
        local retention = this.data.retentionList[i]
        local curr, other = Utils.SplitRewardByCityId(cityId, retention.rewards)
        if #curr ~= 0 then
            
            local gainRewards = DataManager.AddReward(cityId, curr, retention.from, retention.fromId)
            retention.rewards = other
    
            Log("PostStationManager.RestoreData: " .. JSON.encode(curr))
            
            ResAddEffectManager.AddResEffectFromRewards(
                gainRewards,
                true,
                {
                    title = GetLang("ui_resource_get_buy"),
                    openLast = true
                }
            )
            
            Analytics.Event(
                "GainPurchaseRestore",
                {
                    from = retention.from,
                    fromId = retention.fromId,
                    gainReward = Utils.BIConvertRewards(gainRewards),
                    reward = Utils.BIConvertRewards(curr)
                }
            )
        end
    end
    
    Log("PostStationManager.RestoreData: " .. JSON.encode(this.data))
    this.SaveData()
end

---@param rewards Reward[]
function PostStationManager.AddRewards(rewards, from, fromId)
    --Log("PostStationManager.AddRewards1: " .. JSON.encode(rewards))
    local merge = false
    for i = 1, #this.data.retentionList do
        local retention = this.data.retentionList[i]
    
        if retention.from == from and retention.fromId == fromId then
            Utils.MergeRewards(rewards, retention.rewards)
            --Log("PostStationManager.AddRewards2: " .. JSON.encode(rewards))
            merge = true
            break
        end
    end
    
    if not merge then
        --Log("PostStationManager.AddRewards3: " .. JSON.encode(rewards))
        Utils.MustArrayInsert(
            this.data.retentionList,
            {
                rewards = rewards,
                from = from,
                fromId = fromId
            }
        )
    end

    Log("PostStationManager.AddRewards4: "  .. JSON.encode(this.data))
    this.SaveData()
    
    Analytics.Event(
        "AddPurchaseRestore",
        {
            reward = Utils.BIConvertRewards(rewards),
            from = from,
            fromId = fromId,
            PurchaseRestoreData = this.data
        }
    )
end

--切换帐号重置数据
function PostStationManager.Reset()
    this.initialized = nil
    this.data = nil
end
