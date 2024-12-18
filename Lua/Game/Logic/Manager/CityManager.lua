CityManager = {}
CityManager.__cname = "CityManager"
CityManager.cityList = Dictionary:New()

local this = CityManager

--获取城市初始化数据
function CityManager.GetInitCityZoneData(cityId)
    local zonesList = ConfigManager.GetZonesByCityId(cityId)
    local ret = {}
    for index, zone in pairs(zonesList) do
        if zone.finished then
            ret[zone.id] = {
                finished = true,
                furnitures = {},
                level = 1,
                v = ConfigManager.ZoneDataVersion,
                toolLevel = 1,
                boostLevel = 1
            }
            local zoneData = ret[zone.id]
            local furnituresList = ConfigManager.GetFurnituresList(cityId, zone.zone_type)
            for fid, furniture in pairs(furnituresList) do
                if furniture.finished then
                    zoneData.furnitures[furniture.id] = zoneData.furnitures[furniture.id] or {}
                    zoneData.furnitures[furniture.id]["ix_1"] = 1
                end
            end
            -- Analytics.Event("CompleteUpgradeBuilding", {zoneId = zone.id, buildingLevel = zoneData.level})
        end
    end
    return ret
end

--判断是否解锁城市
function CityManager.IsUnlock(cityId)
    return DataManager.userData["city" .. cityId] ~= nil
end

--跳转场景
function CityManager.JumpCity(cityId)
    if CityManager.IsUnlock(cityId) then
        CityManager.SelectCity(cityId, false)
    else
        CityManager.UnlockCity(cityId, DataManager.GetCityId())
    end
end

--跳转限时场景
function CityManager.JumpEventCity(eventId, cityId)
    if DataManager.userData["city" .. cityId] ~= nil then
        if DataManager.userData["city" .. cityId].eventData.eventId ~= eventId then
            DataManager.ClearCity(cityId)
            CityManager.UnlockCity(cityId, DataManager.GetCityId())
        else
            CityManager.SelectCity(cityId, false)
        end
    else
        CityManager.UnlockCity(cityId, DataManager.GetCityId())
    end
end

--解锁城市
function CityManager.UnlockCity(selectCityId, currCityId, forceClear)
    Audio.PlayAudio(DefaultAudioID.JieSuo)
    forceClear = forceClear or false
    local config = ConfigManager.GetCityById(selectCityId)
    DataManager.UseMaterials(currCityId, config.total_material_required, "UnlockCity", selectCityId)
    DataManager.userData.global.initCity = false
    this.SelectCity(selectCityId, forceClear)
end

--切换城市
function CityManager.SelectCity(cityId, forceClear)
    GameManager.changeSceneInfo = { ts = os.clock(), nextCityId = cityId, currentCityId = DataManager.GetCityId() }
    DataManager.userData.global.cityId = cityId
    DataManager.SaveCityData(cityId)
    CityModule.SelectScene(cityId)
    GameManager.LoadMode(ModeType.ChangeScene, forceClear)
end

-----------------------------------------------
---逻辑调用
-----------------------------------------------
--根据时间获取城市温度
function CityManager.GetTemperature(cityId)
    return ConfigManager.GetCityById(cityId).temperature[TimeManager.GetCityClockHour(cityId) + 1]
end

-- --获取爱心产出
-- function CityManager.GetHeartOutput(cityId, duration)
--     if cityId < DataManager.GetMaxCityId() then
--         return 0
--     end
--     if duration > 0 then
--         return Mathf.RoundToInt(ConfigManager.GetCityById(cityId).furniture_add_heart * duration)
--     end
--     return 0
-- end

--根据城市id获取打猎点使用时间
function CityManager.GetHuntUsageDuration(cityId)
    return ConfigManager.GetCityById(cityId).hunt_furniture_usage_duration
end

function CityManager.GetToolAssets(toolId, toolLevel)
    local furnitureConfig = ConfigManager.GetFurnitureById(toolId)
    if not furnitureConfig then
        return false
    end
    if furnitureConfig.tool_assets_name == "" then
        return false
    end
    local assetsId = 1
    if #furnitureConfig.tool_assets_id > 0 then
        assetsId = furnitureConfig.tool_assets_id[toolLevel]
    end
    return true, string.format("prefab/character/tools/%s_Lv%s", furnitureConfig.tool_assets_name, assetsId)
end

--获取白天时间
function CityManager.GetDayHours(cityId)
    local cityConfig = ConfigManager.GetCityById(cityId)
    local h2, m2 = math.modf(cityConfig.game_day_times[2] / 100)
    m2 = math.modf(m2 * 100)
    local h1, m1 = math.modf(cityConfig.game_day_times[1] / 100)
    m1 = math.modf(m1 * 100)
    local h = h2 - h1
    local m = m2 - m1
    return h + m / 60
end

--判断当前是否限时场景
function CityManager.GetIsEventScene(cityId)
    cityId = cityId or DataManager.GetCityId()
    local cityConfig = ConfigManager.GetCityById(cityId)
    if cityConfig ~= nil and cityConfig.is_event then
        return true
    end
    return false
end

--判断是否为指定活动场景
-- -@param type string
-- -@param cityId number
-- -@return boolean
function CityManager.IsEventScene(type, cityId)
    -- cityId = cityId or DataManager.GetCityId()
    -- local cityType, eventType = SceneUtil.GetCityAndEventType(cityId)
    -- if cityType == CityType.Event and eventType == type then
    --     return true
    -- end
    return false
end

--打开转生介绍
function CityManager.OpenCityPassIntroduction(cityId, callBack)
    local config = ConfigManager.GetCityById(cityId)
    local rewards = Utils.ParseReward(config.new_city_reward, false)
    local rewardArr = {}
    for index, rewardItem in pairs(rewards) do
        rewardArr[rewardItem.id] = rewardItem.count
    end
    local unlocks = {}
    for index, itemId in pairs(config.show_infinity_resource) do
        unlocks[itemId] = GetLang("ui_infinity_name")
    end
    -- local panel =
    --     PopupManager.Instance:OpenPanel(
    --         PanelType.CityPassIntroduction,
    --         {
    --             Rewards = rewardArr,
    --             Unlocks = unlocks
    --         }
    --     )
    ShowUI(UINames.UICityPassIntroduction, {
        Rewards = rewardArr,
        Unlocks = unlocks,
        ClosePanelAction = function()
            if callBack ~= nil then
                callBack()
            end
            DataManager.AddMaterials(cityId, rewardArr, "EnterNewCity", cityId)
            DataManager.SetCityDataByKey(cityId, DataKey.FristInit, false)
        end
    })
    -- panel.ClosePanelAction = function()
    --     if callBack ~= nil then
    --         callBack()
    --     end
    --     DataManager.AddMaterials(cityId, rewardArr, "EnterNewCity", cityId)
    --     DataManager.SetCityDataByKey(cityId, DataKey.FristInit, false)
    -- end
    DataManager.SetCityDataByKey(cityId, DataKey.FristInit, false)
end
