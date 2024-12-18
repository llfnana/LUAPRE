CameraEffectManager = {}
CameraEffectManager.__cname = "CameraEffectManager"

local this = CameraEffectManager

this.CameraEffType = {
    SmallSnow_5 = "prefab/enviroment/CameraFX/effect_camera_xiaoxue",
    SmallSnow_3 = "prefab/enviroment/CameraFX/effect_camera_xiaoxue_3s",
    Freeze = "prefab/enviroment/CameraFX/effect_camera_jiebing",
    Wind = "prefab/enviroment/CameraFX/effect_camera_feng",
    Snowstorm_3 = "prefab/enviroment/CameraFX/effect_camera_baofengxue_3s",
    Snowstorm_5 = "prefab/enviroment/CameraFX/effect_camera_baofengxue",
    Freezeing = "prefab/enviroment/CameraFX/effect_camera_jiebing",
    CityPassEffect = "prefab/enviroment/CameraFX/effect_camera_scene_change",
    glowSun = "prefab/enviroment/CameraFX/effect_camera_glow_sun"
}

local nofirst = nil
--初始化
function CameraEffectManager.Init()
    if nofirst == true then
        return
    end
    nofirst = true
    EventManager.AddListener(EventType.WARM_WARNING_CHANEG, CameraEffectManager.OnStartwarming)
    EventManager.AddListener(EventType.TIME_CITY_NEW_DAY, CameraEffectManager.OnFreshOneDay)
    this.cityWarmData = {}
    this.isStartGame = true
end

local mainCamera = nil
---实例化显示
function CameraEffectManager.PlayFreezeAndSnowstorm()
    if CityManager.GetIsEventScene() then
        return
    end
    if this.cityWarmData[DataManager.GetCityId()] == true then

        if WeatherManager.GetWeatherType(DataManager.GetCityId()) == WeatherType.Storm then
            this.OnSetFreeze(1, 2)
        else
            MainUI.Instance:SetMainUIStateFlag(false, "CameraEffect")
            this.OnSetFreeze(1, 2)
            local playWindEffCallback = function()
                MainUI.Instance:SetMainUIStateFlag(true, "CameraEffect")
                if this.windeff ~= nil then
                    ResourceManager.Destroy(this.windeff)
                    this.windeff = nil
                end
            end
            this.windeff = this.OnplayWind(playWindEffCallback)
        end
    else

        if WeatherManager.GetWeatherType(DataManager.GetCityId()) == WeatherType.Storm then
            CameraEffectManager.OnRoundFreese(1, 1)
        else
            CameraEffectManager.OnRoundFreese(1, 1)
            local playWindEffCallback = function()
                MainUI.Instance:SetMainUIStateFlag(true, "CameraEffect")
                if this.windeff ~= nil then
                    ResourceManager.Destroy(this.windeff)
                    this.windeff = nil
                end
            end
            this.windeff = this.OnplayWind(playWindEffCallback)
        end
    end
end

function CameraEffectManager.PlaysbigSnowEff()
    if mainCamera == nil then
        mainCamera = Camera.main
    end
    this.SwitchSceneSetfreezeState()
    if CityManager.GetIsEventScene() == true then
        if TimeManager.GetCityIsNight(DataManager.GetCityId()) == false then -- 在白天播放sun effect
            if this.glowSun ~= nil then
                ResourceManager.Destroy(this.glowSun)
                this.glowSun = nil
            end
            local sunfinishcallback = function()
                if this.glowSun ~= nil then
                    ResourceManager.Destroy(this.glowSun)
                    this.glowSun = nil
                end
            end
            this.glowSun = CameraEffectManager.OnPlayglowSun(sunfinishcallback)
        end
    else
        if this.smallSnowEff ~= nil then
            ResourceManager.Destroy(this.smallSnowEff)
            this.smallSnowEff = nil
        end
        local finishcallback = function()
            if this.smallSnowEff ~= nil then
                ResourceManager.Destroy(this.smallSnowEff)
                this.smallSnowEff = nil
            end
        end
        this.smallSnowEff = CameraEffectManager.OnplayBigSnowEff(finishcallback)
    end
end

function CameraEffectManager.ClearBigSnowEff()
    if CityManager.GetIsEventScene() then
        if this.glowSun ~= nil then
            ResourceManager.Destroy(this.glowSun)
            this.glowSun = nil
        end
    else
        if this.smallSnowEff ~= nil then
            ResourceManager.Destroy(this.smallSnowEff)
            this.smallSnowEff = nil
        end
    end
end

function CameraEffectManager.PlayFreezeJieingEffect()
    if this.warmingfreezeEff == nil then
        this.warmingfreezeEff =
            ResourceManager.Instantiate(this.CameraEffType.Freezeing, mainCamera.gameObject.transform)
    end
end

function CameraEffectManager.ClearFreezeJieingEffect()
    if this.warmingfreezeEff ~= nil then
        ResourceManager.Destroy(this.warmingfreezeEff)
        this.warmingfreezeEff = nil
    end
end

function CameraEffectManager.PlayCityPassEffect()
    if this.cityPassEff == nil then
        this.cityPassEff = --ResourceManager.Instantiate(this.CameraEffType.SmallSnow, mainCamera.gameObject.transform)
            ResourceManager.Instantiate(this.CameraEffType.CityPassEffect, mainCamera.gameObject.transform)
    end
end

function CameraEffectManager.ClearCityPassEffect()
    if this.cityPassEff ~= nil then
        ResourceManager.Destroy(this.cityPassEff)
        this.cityPassEff = nil
    end
end

---------------------------------
---事件响应
---------------------------------
function CameraEffectManager.OnStartwarming(cityId, value, isinitData)
    this.cityWarmData[cityId] = value
    this.cityId = DataManager.GetCityId()
    if this.cityId == cityId then
        if mainCamera == nil then
            mainCamera = Camera.main
        end
        LogWarning("重新启动游戏:" .. tostring(isinitData) .. "是否开始寒潮预警:" .. tostring(value))
        if this.isExistCityScene() == false then
            LogWarning("别的场景我返回了")
            return
        end
        if this.isStartGame == true then
            this.isStartGame = false
            if value == true then
                if this.roundtime ~= nil then
                    this.roundtime:Dispose()
                    this.roundtime = nil
                end
            end
        else
            if value == true then
                this.OnSetFreeze(1, 2)
                if this.warmingsnowstormEff ~= nil then
                    ResourceManager.Destroy(this.warmingsnowstormEff)
                    this.warmingsnowstormEff = nil
                end
                local playfinishCallback = function()
                    if this.warmingsnowstormEff ~= nil then
                        ResourceManager.Destroy(this.warmingsnowstormEff)
                        this.warmingsnowstormEff = nil
                    end
                end
                this.warmingsnowstormEff = CameraEffectManager.OnplayBigSnowEff(playfinishCallback)
            else
                this.OnSetFreeze(0, 2)
            end
        end
    end
end

function CameraEffectManager.ClearBigSnowSnowEff()
    ResourceManager.Destroy(this.warmingsnowstormEff)
end

local smalltimeDatas = {}
local smallltimeList = {}

local bigtimeDatas = {}
local bigtimeList = {}

local smallSnowconfig = nil
local bigSnowconfig = nil
--角色刷新事件响应
function CameraEffectManager.OnFreshOneDay()
    if smallSnowconfig == nil then
        smallSnowconfig = ConfigManager.GetMiscConfig("snow_show_random_period")
        bigSnowconfig = ConfigManager.GetMiscConfig("heavy_snow_show_random_period")
    end

    smalltimeDatas = {}
    smallltimeList = {}
    for key, value in pairs(smallSnowconfig) do
        local datas = string.split(value, "|")
        local time = {}
        time.min = tonumber(datas[1]) / 100
        time.max = tonumber(datas[2]) / 100
        table.insert(smallltimeList, time)
    end

    for k, time in pairs(smallltimeList) do
        local ranOne1 = math.random(time.min, time.max - 1)
        local ranOne2 = math.random(1, 60)
        local ranOne = ranOne1 * 100 + ranOne2
        table.insert(smalltimeDatas, ranOne)
        UnityEngine.PlayerPrefs.SetInt("Smalleffect" .. k, ranOne)
    end

    bigtimeDatas = {}
    bigtimeList = {}
    for key, value in pairs(bigSnowconfig) do
        local datas = string.split(value, "|")
        local time = {}
        time.min = tonumber(datas[1]) / 100
        time.max = tonumber(datas[2]) / 100
        table.insert(bigtimeList, time)
    end

    for k, time in pairs(bigtimeList) do
        local ranOne1 = math.random(time.min, time.max - 1)
        local ranOne2 = math.random(1, 60)
        local ranOne = ranOne1 * 100 + ranOne2
        table.insert(bigtimeDatas, ranOne)
        UnityEngine.PlayerPrefs.SetInt("bigffect" .. k, ranOne)
    end
end

function CameraEffectManager.OnPlayRandomEff(cityId)
    if mainCamera == nil then
        mainCamera = Camera.main
    end
    if this.isExistCityScene() == false or WeatherManager.GetWeatherType(cityId) == WeatherType.Storm then
        return
    end
    if smallSnowconfig == nil then
        smallSnowconfig = ConfigManager.GetMiscConfig("snow_show_random_period")
        smallltimeList = {}
        for key, value in pairs(smallSnowconfig) do
            local datas = string.split(value, "|")
            local time = {}
            time.min = tonumber(datas[1]) / 100
            time.max = tonumber(datas[2]) / 100
            table.insert(smallltimeList, time)
        end

        bigSnowconfig = ConfigManager.GetMiscConfig("heavy_snow_show_random_period")
        for key, value in pairs(bigSnowconfig) do
            local datas = string.split(value, "|")
            local time = {}
            time.min = tonumber(datas[1]) / 100
            time.max = tonumber(datas[2]) / 100
            table.insert(bigtimeList, time)
        end
    end
    if #smalltimeDatas == 0 then
        for index = 1, #smallSnowconfig do
            local time = UnityEngine.PlayerPrefs.GetInt("Smalleffect" .. index, smallltimeList[index].min * 100 + 50)
            table.insert(smalltimeDatas, time)
        end
    end

    if #bigtimeDatas == 0 then
        for index = 1, #bigSnowconfig do
            local time = UnityEngine.PlayerPrefs.GetInt("bigffect" .. index, bigtimeList[index].min * 100 + 50)
            table.insert(bigtimeDatas, time)
        end
    end

    local time = TimeManager.GetSpecialClockFormat(cityId)
    for key, value in pairs(smalltimeDatas) do
        if time == value then
            if this.RadomssmallSnow ~= nil then
                ResourceManager.Destroy(this.RadomssmallSnow)
                this.RadomssmallSnow = nil
            end
            local smallfinish = function()
                if this.RadomssmallSnow ~= nil then
                    ResourceManager.Destroy(this.RadomssmallSnow)
                    this.RadomssmallSnow = nil
                end
            end
            this.RadomssmallSnow = this.OnplaySmallSnowEff(smallfinish)
            break
        end
    end

    for key, value in pairs(bigtimeDatas) do
        if time == value then
            if this.RadombigSnow ~= nil then
                ResourceManager.Destroy(this.RadombigSnow)
                this.RadombigSnow = nil
            end
            local bigfinish = function()
                if this.RadombigSnow ~= nil then
                    ResourceManager.Destroy(this.RadombigSnow)
                    this.RadombigSnow = nil
                end
            end
            this.RadombigSnow = this.OnplayBigSnowEff(bigfinish)
            break
        end
    end
end

--大雪
function CameraEffectManager.OnplayBigSnowEff(playfinishCallback)
    local smallSnowEff = nil
    local snowtype = math.random(1, 2)
    if snowtype == 1 then --播放大雪 3s 特效
        smallSnowEff = ResourceManager.Instantiate(this.CameraEffType.Snowstorm_3, mainCamera.gameObject.transform)
        this.smallSnowTimer = LTimer.new(6.3)
        this.smallSnowTimer:AddEvent(LTimerEvent.Stop, playfinishCallback)
        this.smallSnowTimer:Start()
    elseif snowtype == 2 then
        smallSnowEff = ResourceManager.Instantiate(this.CameraEffType.Snowstorm_5, mainCamera.gameObject.transform)
        this.smallSnowTimer = LTimer.new(8.3)
        this.smallSnowTimer:AddEvent(LTimerEvent.Stop, playfinishCallback)
        this.smallSnowTimer:Start()
    end
    return smallSnowEff
end

--小雪
function CameraEffectManager.OnplaySmallSnowEff(playfinishCallback)
    local smallSnowEff = nil
    local snowtype = math.random(1, 2)
    if snowtype == 1 then --播放小雪 3s 特效
        smallSnowEff = ResourceManager.Instantiate(this.CameraEffType.SmallSnow_3, mainCamera.gameObject.transform)
        this.smallSnowTimer = LTimer.new(6.3)
        this.smallSnowTimer:AddEvent(LTimerEvent.Stop, playfinishCallback)
        this.smallSnowTimer:Start()
    elseif snowtype == 2 then
        smallSnowEff = ResourceManager.Instantiate(this.CameraEffType.SmallSnow_5, mainCamera.gameObject.transform)
        this.smallSnowTimer = LTimer.new(8.3)
        this.smallSnowTimer:AddEvent(LTimerEvent.Stop, playfinishCallback)
        this.smallSnowTimer:Start()
    end
    return smallSnowEff
end

function CameraEffectManager.OnplayWind(playfinishCallback)
    local snowstormEff = ResourceManager.Instantiate(this.CameraEffType.Wind, mainCamera.gameObject.transform)
    this.freesnowTimer = LTimer.new(3)
    this.freesnowTimer:AddEvent(LTimerEvent.Stop, playfinishCallback)
    this.freesnowTimer:Start()
    return snowstormEff
end

function CameraEffectManager.OnPlayglowSun(playfinishCallback)
    local snowstormEff = ResourceManager.Instantiate(this.CameraEffType.glowSun, mainCamera.gameObject.transform)
    this.freesnowTimer = LTimer.new(5)
    this.freesnowTimer:AddEvent(LTimerEvent.Stop, playfinishCallback)
    this.freesnowTimer:Start()
    return snowstormEff
end

function CameraEffectManager.OnRoundFreese(value, duration)
    if this.isExistCityScene() == false then
        return
    end
    MainUI.Instance:SetMainUIFreeze(value, duration)
    this.roundtime = LTimer.new(2)
    this.roundtime:AddEvent(LTimerEvent.Stop, CameraEffectManager.OnSetFreeze, 0, 2)
    this.roundtime:Start()
end

function CameraEffectManager.OnSetFreeze(value, duration)
    if this.isExistCityScene() == false then
        return
    end
    MainUI.Instance:SetMainUIFreeze(value, duration)
end

function CameraEffectManager.isExistCityScene()
    local value = true
    -- if CityManager.GetIsEventScene() == true or BattleUIManager.IsExistBattleScene() == true then
    --     value = false
    -- end
    return value
end

--在切换场景的时候 回复界面结冰
function CameraEffectManager.SwitchSceneSetfreezeState()
    if this.cityWarmData[DataManager.GetCityId()] == true then
        this.OnSetFreeze(1, 0)
    end
end

function CameraEffectManager.RoguelikeSnow()
    if this.RoguebigSnow ~= nil then
        ResourceManager.Destroy(this.RoguebigSnow)
        this.RoguebigSnow = nil
    end
    local bigfinish = function()
        if this.RoguebigSnow ~= nil then
            ResourceManager.Destroy(this.RoguebigSnow)
            this.RoguebigSnow = nil
        end
    end
    this.RoguebigSnow = this.OnplayBigSnowEff(bigfinish)
    this.RoguebigSnow.transform.localPosition = luaVector3.New(0, 0, 30)
end

function CameraEffectManager.ClearCityCameraEffect()
    if this.windeff ~= nil then
        ResourceManager.Destroy(this.windeff)
        this.windeff = nil
    end
    if this.glowSun ~= nil then
        ResourceManager.Destroy(this.glowSun)
        this.glowSun = nil
    end
    if this.smallSnowEff ~= nil then
        ResourceManager.Destroy(this.smallSnowEff)
        this.smallSnowEff = nil
    end
    if this.warmingfreezeEff ~= nil then
        ResourceManager.Destroy(this.warmingfreezeEff)
        this.warmingfreezeEff = nil
    end
    if this.warmingsnowstormEff ~= nil then
        ResourceManager.Destroy(this.warmingsnowstormEff)
        this.warmingsnowstormEff = nil
    end
    if this.RadomssmallSnow ~= nil then
        ResourceManager.Destroy(this.RadomssmallSnow)
        this.RadomssmallSnow = nil
    end
    if this.RadombigSnow ~= nil then
        ResourceManager.Destroy(this.RadombigSnow)
        this.RadombigSnow = nil
    end
    if this.RoguebigSnow ~= nil then
        ResourceManager.Destroy(this.RoguebigSnow)
        this.RoguebigSnow = nil
    end
    if this.freesnowTimer ~= nil then
        this.freesnowTimer:Dispose()
        this.freesnowTimer = nil
    end
end
