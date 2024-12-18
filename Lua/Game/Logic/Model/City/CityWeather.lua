CityWeather = Clone(CityBase)
CityWeather.__cname = "CityWeather"
local MonsterController = require "Game/Logic/Model/City/sceneLogic/CityMonster"
--初始化
function CityWeather:OnInit()
    self.temperature = 0

    self.isOpen = FunctionsManager.IsOpen(self.cityId, FunctionsType.Storm) and ConfigManager.GetMiscConfig("storm_enable")

    self:InitWeather()
end

function CityWeather:OnUpdate()
    if not self.isOpen then
        return
    end
    if CityManager.GetIsEventScene(self.cityId) then
        return
    end
    self:UpdateWeather()
end

function CityWeather:OnClearView()
    if self.isOpen then
        self:StopWeatherEffect()
    end
end

function CityWeather:OnClear()
    if self.isOpen then
        self:ClearWeather()
    end

    EventManager.RemoveListener(EventDefine.QualityChange, self.CheckQuality)
end

---------------------------------
---事件响应
---------------------------------
--功能解锁事件响应
function CityWeather:SetStormOpen(isOpen)
    if CityManager.GetIsEventScene(self.cityId) then
        return
    end
    if self.isOpen ~= isOpen then
        self.isOpen = isOpen
        if isOpen then
            self:InitWeather()
        end
    end
end
---------------------------------
---
---------------------------------

--初始化天气
function CityWeather:InitWeather()
    --毒气一直存在  isOpen = true 才有毒气爆发
    self:CreatePoisonGas()

    self.CheckQuality = function ()
        local quality = PlayerModule.getQualityWitch()
        if self.effect then
            self.effect:SetActive(quality >= 2)
        end
    end
    EventManager.AddListener(EventDefine.QualityChange, self.CheckQuality)
    self:CheckQuality()
    
    if CityManager.GetIsEventScene(self.cityId) then
        return
    end
    -- self.effectRoot = Camera.main.gameObject.transform
    self.weatherChange = ConfigManager.GetFormulaConfigById("weatherChange")
    self.isStormOfflinePause = ConfigManager.GetMiscConfig("is_storm_offline_pause")
    self.weatherData = DataManager.GetCityDataByKey(self.cityId, DataKey.WeatherData)
    if nil == self.weatherData or nil == self.weatherData.durationTime or self.isOpen == false then
        self.weatherData = self:GetWeatherData(WeatherType.Normal)
        DataManager.SetCityDataByKey(self.cityId, DataKey.WeatherData, self.weatherData)
    elseif self.isStormOfflinePause then
        if self.weatherData.performTime >= self.weatherData.durationTime then
            self.weatherData = self:ResetWeatherData(self.weatherData.type)
            DataManager.SetCityDataByKey(self.cityId, DataKey.WeatherData, self.weatherData)
        end
    else
        local performTime = GameManager.GameTime() - self.weatherData.startTime
        if performTime >= self.weatherData.durationTime then
            self.weatherData = self:ResetWeatherData(self.weatherData.type)
            DataManager.SetCityDataByKey(self.cityId, DataKey.WeatherData, self.weatherData)
        elseif self.weatherData.performTime ~= performTime then
            self.weatherData.performTime = performTime
        end
    end
    self.currWeatherEffect = WeatherEffectType.None
    self:OnWeatherChange(self.weatherData.type)
end

function CityWeather:UpdateWeather()
    --刷新天气运行时间
    self.weatherData.performTime = self.weatherData.performTime + TimerFunction.deltaTime

    if self.weatherData.performTime >= self.weatherData.durationTime then
        self.weatherData = self:ResetWeatherData(self.weatherData.type)
        DataManager.SetCityDataByKey(self.cityId, DataKey.WeatherData, self.weatherData)
        EventManager.Brocast(EventType.WEATHER_TYPE_CHANGE, self.cityId, self.weatherData.type)
        self:OnWeatherChange(self.weatherData.type)
    end
    --刷新天气剩余时间事件触发
    local stage = nil
    if self.weatherData.type == WeatherType.Storm then
        --切换天气阶段
        stage = self:GetWeatherStage()
        if self.isShowView then
            --self:CheckWeatherEffect(stage)
        end
        EventManager.Brocast(EventType.WEATHER_TIME_CHANGE, self.cityId, self:GetLeftTime())
    end
    self:SetTemperature(stage)
end

function CityWeather:ClearWeather()
    if self.weatherStageSubscribe then
        self.weatherStageSubscribe:unsubscribe()
        self.weatherStageSubscribe = nil
    end
end

--重制天气数据
function CityWeather:ResetWeatherData(type)
    if type == WeatherType.Normal then
        return self:GetWeatherData(WeatherType.Storm)
    elseif type == WeatherType.Storm then
        return self:GetWeatherData(WeatherType.Normal)
    end

    -- print("[error][CityWeather] ResetWeatherData type = ", type)
    -- 没有天气时，使用正常的天气
    return self:GetWeatherData(WeatherType.Normal)
end

--获取天气持续时间
function CityWeather:GetWeatherData(type)
    local durationTime = 0
    if type == WeatherType.Storm then
        durationTime = math.random(self.weatherChange.constant_a, self.weatherChange.constant_b)
    elseif type == WeatherType.Normal then
        durationTime = math.random(self.weatherChange.constant_c, self.weatherChange.constant_d)
    end
    local data = {}
    data.type = type
    data.startTime = GameManager.GameTime()
    data.durationTime = durationTime
    data.performTime = 0
    return data
end

--切换天气
function CityWeather:ChangeWeather(type)
    --if not self.isOpen then
    --    return
    --end
    if self:GetWeatherType() == type then
        return
    end

    self:StopWeatherEffect()
    self.weatherData = self:GetWeatherData(type)
    DataManager.SetCityDataByKey(self.cityId, DataKey.WeatherData, self.weatherData)
    EventManager.Brocast(EventType.WEATHER_TYPE_CHANGE, self.cityId, self.weatherData.type)

    self:OnWeatherChange(self.weatherData.type)
end

--获取天气类型
function CityWeather:GetWeatherType()
    if self.weatherData then
        return self.weatherData.type
    end
    return WeatherType.None
end

--获取天气阶段
function CityWeather:GetWeatherStage()
    return math.floor(self.weatherData.performTime / self.weatherData.durationTime / 0.25)
end

--设置天气温度
function CityWeather:SetTemperature(stage)
    local temp = 0
    if stage then
        temp = self.weatherChange.constant_e + (self.weatherChange.constant_f - self.weatherChange.constant_e) / 3 * stage
    end
    if self.temperature ~= temp then
        self.temperature = temp
    end
end

--获取天气温度
function CityWeather:GetTemperature()
    return self.temperature
end

--获取剩余时间
function CityWeather:GetLeftTime()
    if self.weatherData then
        return self.weatherData.durationTime - self.weatherData.performTime
    end
    return 0
end

local StormEffectOverTime = 3.2

function CityWeather:CheckWeatherEffect(stage)
    local nextEffect = nil
    if self.weatherData.type == WeatherType.Storm then
        if stage == 0 then
            if self.currWeatherEffect == WeatherEffectType.None then
                if self.weatherData.durationTime * 0.25 - self.weatherData.performTime > 6 then
                    nextEffect = WeatherEffectType.Snow_Moderate_Start
                else
                    nextEffect = WeatherEffectType.Snow_Heavy_Start
                end
            end
        elseif stage == 1 then
            if self.currWeatherEffect == WeatherEffectType.None then
                nextEffect = WeatherEffectType.Snow_Heavy_Start
            elseif self.currWeatherEffect == WeatherEffectType.Snow_Moderate_Start then
                nextEffect = WeatherEffectType.Snow_Heavy_Start
            elseif self.currWeatherEffect == WeatherEffectType.Snow_Moderate_Loop then
                nextEffect = WeatherEffectType.Snow_Heavy_Loop
            end
        elseif stage == 2 then
            if self.currWeatherEffect == WeatherEffectType.None then
                nextEffect = WeatherEffectType.Snow_Heavy_Start
            end
        elseif stage == 3 then
            if self.currWeatherEffect == WeatherEffectType.None then
                if self:GetLeftTime() > 6 then
                    nextEffect = WeatherEffectType.Snow_Heavy_Start
                else
                    nextEffect = WeatherEffectType.Snow_Heavy_Loop
                end
            elseif self.currWeatherEffect == WeatherEffectType.Snow_Heavy_Loop then
                if self:GetLeftTime() <= StormEffectOverTime then
                    nextEffect = WeatherEffectType.Snow_Heavy_Over
                end
            end
        end
    end
    if nextEffect then
        self:SetWeatherEffect(nextEffect)
    end
end

--设置天气效果
function CityWeather:SetWeatherEffect(effect)
    --if self.currWeatherEffect ~= effect then
    --    if self.isShowView then
    --        if self.currWeatherEffect == WeatherEffectType.None then
    --            AudioManager.PlayEffect("amb_city_storm")
    --        end
    --        if effect == WeatherEffectType.None then
    --            AudioManager.PlayEffect("amb_city_storm_stop")
    --        end
    --    end
    --    self.currWeatherEffect = effect
    --    self:PlayWeatherEffect()
    --end
end


--region -------------修改-------------

local max_particles_config = { 20, 20, 30 }
--创建毒气特效
function CityWeather:CreatePoisonGas()
    local efectid = self.cityId
    if efectid > 1 then
        efectid =3
    end

    if self.effect then
        return self.effect
    end

    self.effect = GameObject.Find("E_poison_gas_map_" .. efectid)
    self.heavyGasTrans1 = self.effect.transform:GetChild(1);
    if self.effect.transform.childCount > 2 then 
        self.heavyGasTrans2 = self.effect.transform:GetChild(2);
        if self.heavyGasTrans2 then
            SafeSetActive(self.heavyGasTrans2.gameObject,false)
        end
        
    end

    SafeSetActive(self.heavyGasTrans1.gameObject,false)
        
    return self.effect
end

--毒气状态切换
function CityWeather:OnWeatherChange(new_type)
    if new_type == WeatherType.Normal then
        self:StopHeavyGasEffect()
        EventManager.Brocast(EventType.CHANGE_DUQI, self.cityId)
    elseif new_type == WeatherType.Storm then
        EventManager.Brocast(EventDefine.ShowMainUIBanner, "home_img_gas", 2)
        Audio.PlayAudio(DefaultAudioID.Duqi)
        self:PlayHeavyGasEffect()

        EventManager.Brocast(EventType.CHANGE_DUQI, self.cityId)
    else
        self:FadeGasEffect()
    end
end

--播放丧尸自爆动画
function CityWeather:DoZombieEffect(zombie)
    local duration = zombie.duration
    -- Tween 动画完成  特效需要0.5的提前
    TimeModule.addDelay(duration - 0.5, function()
        SafeSetActive(zombie.effect, true)
    end)

    TimeModule.addDelay(duration, function()
        Audio.PlayAudio(DefaultAudioID.ZiBao)
        SafeSetActive(zombie.go, false)
    end)
end

--播放重毒气
function CityWeather:PlayHeavyGasEffect()
    local cfg = max_particles_config
    local particles1 = self.heavyGasTrans1:GetComponentsInChildren(typeof(ParticleSystem));
    self:SetMaxParticles(particles1, cfg[2])
    SafeSetActive(self.heavyGasTrans1.gameObject, true)

    if self.heavyGasTrans2 then
        local particles2 = self.heavyGasTrans2:GetComponentsInChildren(typeof(ParticleSystem));
        self:SetMaxParticles(particles2, cfg[3])
        SafeSetActive(self.heavyGasTrans2.gameObject, true)
    end

end

--关闭重毒气
function CityWeather:StopHeavyGasEffect()
    local cfg = max_particles_config
    local particles1 = self.heavyGasTrans1:GetComponentsInChildren(typeof(ParticleSystem));

    local particles2 = nil
    if self.heavyGasTrans2 then
        particles2 = self.heavyGasTrans2:GetComponentsInChildren(typeof(ParticleSystem));
    end

    local c1 = cfg[2]
    local c2 = cfg[3]
    local const_value = 20
    self.stopTimer = TimeModule.addRepeat(0, 0.5, function()
        c1 = c1 - math.max(c1 / 2, const_value)
        c2 = c2 - math.max(c2 / 2, const_value)

        self:SetMaxParticles(particles1, math.max(c1, 0))

        if self.heavyGasTrans2 then
            self:SetMaxParticles(particles2, math.max(c2, 0))
        end

        if c1 < 0 and c2 < 0 then
            TimeModule.removeTimer(self.stopTimer)
            self.stopTimer = nil
        end
    end)
    TimeModule.addDelay(3, function()
        SafeSetActive(self.heavyGasTrans1.gameObject, false)

        if self.heavyGasTrans2 then
            SafeSetActive(self.heavyGasTrans2.gameObject, false)
        end
    end)
end

--毒气消失 轻重都关闭
function CityWeather:FadeGasEffect()
    self:StopHeavyGasEffect()
    local cfg = max_particles_config
    local moderate_particles = self.effect.transform:GetChild(0):GetComponentsInChildren(typeof(ParticleSystem));

    local c = cfg[1]
    local const_value = 10
    self.fadeTimer = TimeModule.addRepeat(0, 0.5, function()
        c = c - math.max(c / 2, const_value)
        self:SetMaxParticles(moderate_particles, math.max(c, 0))

        if c < 0 then
            TimeModule.removeTimer(self.fadeTimer)
            self.fadeTimer = nil
        end
    end)
    TimeModule.addDelay(3, function()
        if self.effect then
            SafeSetActive(self.effect, false)
        end
    end)
end

function CityWeather:SetMaxParticles(particles, maxParticles)
    for i = 0, particles.Length - 1 do
        if particles[i] then 
           particles[i].main.maxParticles = maxParticles;
        end
    end
end
--endregion


--创建天气效果
function CityWeather:CreateWeatherEffect()
    -- local effectPath = nil
    -- if self.currWeatherEffect == WeatherEffectType.Snow_Moderate_Start then
    --     effectPath = "prefab/enviroment/CameraFX/effect_camera_baofengxue_start"
    -- elseif self.currWeatherEffect == WeatherEffectType.Snow_Moderate_Loop then
    --     effectPath = "prefab/enviroment/CameraFX/effect_camera_baofengxue_loop"
    -- elseif self.currWeatherEffect == WeatherEffectType.Snow_Moderate_Over then
    --     effectPath = "prefab/enviroment/CameraFX/effect_camera_baofengxue_over"
    -- elseif self.currWeatherEffect == WeatherEffectType.Snow_Heavy_Start then
    --     effectPath = "prefab/enviroment/CameraFX/effect_camera_dabaofengxue_start"
    -- elseif self.currWeatherEffect == WeatherEffectType.Snow_Heavy_Loop then
    --     effectPath = "prefab/enviroment/CameraFX/effect_camera_dabaofengxue_loop"
    -- elseif self.currWeatherEffect == WeatherEffectType.Snow_Heavy_Over then
    --     effectPath = "prefab/enviroment/CameraFX/effect_camera_dabaofengxue_over"
    -- end
    -- return ResourceManager.Instantiate(effectPath, self.effectRoot)
end

--播放天气效果
function CityWeather:PlayWeatherEffect()
    if self.currWeatherEffect == WeatherEffectType.Snow_Moderate_Start then
        self:CreateWeatherEffect()

        self.startEffectTimer = LTimer.new(3)
        self.startEffectTimer:AddEvent(
                LTimerEvent.Stop,
                function()
                    if self.currWeatherEffect ~= WeatherEffectType.Snow_Moderate_Start then
                        return
                    end
                    self:SetWeatherEffect(WeatherEffectType.Snow_Moderate_Loop)
                end
        )
        self.startEffectTimer:Start()
    elseif self.currWeatherEffect == WeatherEffectType.Snow_Moderate_Loop then
        self:CreateWeatherEffect()
    elseif self.currWeatherEffect == WeatherEffectType.Snow_Heavy_Start then
        self:CreateWeatherEffect()

        self.startEffectTimer = LTimer.new(3)
        self.startEffectTimer:AddEvent(
                LTimerEvent.Stop,
                function()
                    if self.currWeatherEffect ~= WeatherEffectType.Snow_Heavy_Start then
                        return
                    end
                    self:SetWeatherEffect(WeatherEffectType.Snow_Heavy_Loop)
                end
        )
        self.startEffectTimer:Start()
    elseif self.currWeatherEffect == WeatherEffectType.Snow_Heavy_Loop then
        self:CreateWeatherEffect()
    elseif self.currWeatherEffect == WeatherEffectType.Snow_Heavy_Over then
        self:CreateWeatherEffect()

        self.overEffectTimer = LTimer.new(5)
        self.overEffectTimer:AddEvent(
                LTimerEvent.Stop,
                function()
                    self:SetWeatherEffect(WeatherEffectType.None)
                    self:StopOverEffect()
                end
        )
        self.overEffectTimer:Start()

        self.loopEffectTimer = LTimer.new(3)
        self.loopEffectTimer:AddEvent(
                LTimerEvent.Stop,
                function()
                    self:StopLoopEffect()
                end
        )
        self.loopEffectTimer:Start()
    elseif self.currWeatherEffect == WeatherEffectType.None then
        self:StopStartEffect()
        self:StopLoopEffect()
        self:StopOverEffect()
    end
end

--停止天气效果
function CityWeather:StopWeatherEffect()
    self:StopStartEffect()
    self:StopLoopEffect()
    self:StopOverEffect()
    self:SetWeatherEffect(WeatherEffectType.None)
end

--停止开始效果
function CityWeather:StopStartEffect()
    if nil ~= self.startEffect then
        ResourceManager.Destroy(self.startEffect)
        self.startEffect = nil
    end
    if nil ~= self.startEffectTimer then
        self.startEffectTimer:Dispose()
        self.startEffectTimer = nil
    end
end

--停止循环效果
function CityWeather:StopLoopEffect()
    if nil ~= self.loopEffect then
        ResourceManager.Destroy(self.loopEffect)
        self.loopEffect = nil
    end
    if nil ~= self.loopEffectTimer then
        self.loopEffectTimer:Dispose()
        self.loopEffectTimer = nil
    end
end

--停止结束效果
function CityWeather:StopOverEffect()
    if nil ~= self.overEffect then
        ResourceManager.Destroy(self.overEffect)
        self.overEffect = nil
    end
    if nil ~= self.overEffectTimer then
        self.overEffectTimer:Dispose()
        self.overEffectTimer = nil
    end
end
