--现实中30秒对应游戏时间1小时
local Standard_Hour = 1 * 60 * 60
local Standard_Second = 30

CityClock = Clone(CityBase)
CityClock.__cname = "CityClock"

function CityClock:OnInit()
    self.cityDay = DataManager.GetCityDataByKey(self.cityId, DataKey.Day)
    self.cityClock = DataManager.GetCityDataByKey(self.cityId, DataKey.Clock)
    self.cityOnlineTime = DataManager.GetCityDataByKey(self.cityId, DataKey.OnlineTime)
    local h, m = math.modf(self.cityClock / 100)
    self.hour = h
    self.minute = math.modf(m * 100)
    self.second = 0
    self.dayTimeClock = self.cityConfig.game_day_times
    self.isNight = self.cityClock < self.dayTimeClock[1] or self.cityClock >= self.dayTimeClock[2]
    self.gameTimeRate = (Standard_Hour / Standard_Second)
    self.gameSpeedSubscribe =
        TestManager.GetTest(self.cityId).gameSpeed:subscribe(
            function(val)
                self.gameTimeRate = (Standard_Hour / Standard_Second) * val
            end
        )
    self.clockTemp = 0
    self.realTemp = 0
    self.isRuning = true
    self.randomSoundAcc = 0
    self.isPlayAudio = false
    self.randomSoundTotal = math.random(20, 60)
    self.timeGC = 0
    self:PlayAudio()
end

function CityClock:OnClear()
    self.gameSpeedSubscribe:unsubscribe()
    self.isRuning = false
    self = nil
end

--设置城市时间
function CityClock:SetCityClock(clockTime)
    local h, m = math.modf(clockTime / 100)
    self.hour = h
    self.minute = math.modf(m * 100)
    self.cityClock = self.hour * 100 + self.minute
    DataManager.SetCacheCityDataByKey(self.cityId, DataKey.Clock, self.cityClock)
end

--刷新城市时间
function CityClock:RefreshCityTime(pauseTimeAdd)
    if pauseTimeAdd then
        EventManager.Brocast(EventType.TIME_CITY_UPDATE, self.cityId)
        return
    end
    self.clockTemp = self.clockTemp + self.gameTimeRate * TimerFunction.deltaTime
    local minutes = math.modf(self.clockTemp / 60)
    
    if minutes >= 1 then
       
        self.clockTemp = self.clockTemp - minutes * 60

        local isNewHour, isNewDay, isNightChange = self:RefreshClock(minutes, 0, 0)
        if isNightChange then
            -- if UISchedulesPanel ~= nil and UISchedulesPanel.uidata ~= nil then
            --     UISchedulesPanel.ChangeTime(not self.isNight)
            -- end
            EventManager.Brocast(EventDefine.OnNightChange, not self.isNight)

            -- if self.isNight then
            --     self:ShowListToast("toast_is_night", ToastListColor.Blue, ToastListIconType.Night)
            -- else
            --     self:ShowListToast("toast_is_daytime", ToastListColor.Blue, ToastListIconType.Day)
            -- end
        end
        EventManager.Brocast(EventType.TIME_CITY_UPDATE, self.cityId)
        if isNewHour then
            EventManager.Brocast(EventType.TIME_CITY_PER_HOUR, self.cityId)
            -- Log("GameTime:" .. self:GetClockFormat() .. "|" .. GameManager.GameTime())
            -- self:PlayAudio()
        end

        if isNewDay then
            EventManager.Brocast(EventType.TIME_CITY_NEW_DAY, self.cityId)

            EventManager.Brocast(EventType.CHANGE_DUQI, self.cityId)
        end
        if isNightChange then
            EventManager.Brocast(EventType.CITY_NIGHT_CHANGE, self.cityId)

            EventManager.Brocast(EventType.CHANGE_DUQI, self.cityId)
        end
        if self.minute % self.cityConfig.refresh_duration == 0 then
            EventManager.Brocast(EventType.TIME_CITY_PER_REFRESH, self.cityId)
        end

        -- local isNight = self.cityClock < self.dayTimeClock[1] or self.cityClock >= self.dayTimeClock[2]
    end
end

--刷新真实时间
function CityClock:RefreshRealTime()
    self.realTemp = self.realTemp + TimerFunction.deltaTime
    if self.realTemp >= 1 then
        self.realTemp = self.realTemp - 1
        EventManager.Brocast(EventType.TIME_REAL_PER_SECOND, self.cityId)
    end
end

--刷新
function CityClock:OnUpdate()
    -- if GameManager.GamePause.value then
    --     return
    -- end

    TutorialManager.CheckTutorialNeedStop()

    if TutorialManager.StopTime.value then
        self:RefreshCityTime(true)
        return
    end
    if not self.isRuning then
        return
    end
    self:RefreshCityTime()
    self:RefreshRealTime()
end

--刷新城市时间
function CityClock:RefreshClock(minutes, hours, days)
    self.randomSoundAcc = self.randomSoundAcc + minutes
    if self.randomSoundAcc >= self.randomSoundTotal and self.hour >= 0 and self.hour <= 4 then
        self.randomSoundAcc = 0
        self.randomSoundTotal = math.random(50, 70)
        -- if math.random(1, 100) > 50 then
        --     if CityManager.GetIsEventScene() == false then
        --         self:PlayAudioEffect("amb_pm_owl")
        --     end
        -- end
    end
    local isNewHour = false
    local isNewDay = false
    local isNightChange = false
    self.minute = self.minute + minutes
    if self.minute >= 60 then
        local hour = math.floor(self.minute / 60)
        self.minute = self.minute - hour * 60
        hours = hours + hour
    end
    if hours > 0 then
        isNewHour = true
        self.hour = self.hour + hours
        if self.hour >= 24 then
            local day = math.floor(self.hour / 24)
            self.hour = self.hour - day * 24
            days = days + day
        end
    end
    if days > 0 then
        isNewDay = true
        self.cityDay = self.cityDay + days
        DataManager.SetCityDataByKey(self.cityId, DataKey.Day, self.cityDay)
    end
    self.cityClock = self.hour * 100 + self.minute
    DataManager.SetCacheCityDataByKey(self.cityId, DataKey.Clock, self.cityClock)
    self.cityOnlineTime = TimeManager.GameTime()
    DataManager.SetCacheCityDataByKey(self.cityId, DataKey.OnlineTime, self.cityOnlineTime)

    if self.cityClock >= self.dayTimeClock[1] and self.cityClock < self.dayTimeClock[2] then
        if self.isNight then
            self.isNight = false
            isNightChange = true
        end
    else
        if not self.isNight then
            self.isNight = true
            isNightChange = true
        end
    end
    return isNewHour, isNewDay, isNightChange
end

--返回格式化时间
function CityClock:GetClockFormat()
    return Utils.GetClockFormat2(self.hour, self.minute)
end

function CityClock:GetClockSpecailFormat()
    return self.hour * 100 + self.minute
end

--获取昼夜交替返回系数
function CityClock:GetClockDayAndNight()
    return self.hour + self.minute / 60
end

--返回昼夜时间 0-1
function CityClock:GetDayRatio()
    return self.cityClock / 2400 --1h=100s
end

function CityClock:PlayAudio()
    -- local time = self:GetClockDayAndNight()
    -- if self.isPlayAudio then
    --     if time == 19  then
    --         Audio.PlayAudio(DefaultAudioID.YeWanScene)
    --     elseif time == 6 then
    --         Audio.PlayAudio(DefaultAudioID.BaiTianScene)
    --     end
    -- else
    --     if time >= 19  and time < 24 or time < 7 then
    --         Audio.PlayAudio(DefaultAudioID.YeWanScene)
    --     else
    --         Audio.PlayAudio(DefaultAudioID.BaiTianScene)
    --     end
    --     self.isPlayAudio = true
    -- end
    Audio.PlayAudio(DefaultAudioID.BaiTianScene)
end
