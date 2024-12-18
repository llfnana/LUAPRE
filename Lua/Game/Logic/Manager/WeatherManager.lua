WeatherManager = {}
WeatherManager.__cname = "WeatherManager"

local this = WeatherManager

--初始化天气数据
function WeatherManager.Init()
    this.cityId = DataManager.GetCityId()
    if not this.weatherItems then
        this.weatherItems = Dictionary:New()
    end
    if not this.weatherItems:ContainsKey(this.cityId) then
        this.weatherItems:Add(this.cityId, CityWeather:New(this.cityId))
        if this.weatherItems:Count() == 1 then
            EventManager.AddListener(EventType.FUNCTIONS_OPEN, this.FunctionsOpenFunc)
        end
    end
    this.buildQueue = {}
end

--初始化天气显示
function WeatherManager.InitView()
    this.GetWeather(this.cityId):InitView()
end

--天气刷新
function WeatherManager.OnUpdate()
    this.weatherItems:ForEach(this.ItemUpdate)
end

function WeatherManager.ItemUpdate(item)
    item:OnUpdate()
end

function WeatherManager.ClearView()
    this.GetWeather(this.cityId):ClearView()
end

--清除数据
function WeatherManager.Clear(force)
    this.buildQueue = {}
    Utils.SwitchSceneClear(this.cityId, this.weatherItems, force)
    if this.weatherItems:Count() == 0 then
        EventManager.RemoveListener(EventType.FUNCTIONS_OPEN, this.FunctionsOpenFunc)
    end
end

--获取加班对象
function WeatherManager.GetWeather(cityId)
    return this.weatherItems[cityId]
end

---------------------------------
---事件响应
---------------------------------
--功能解锁事件响应
function WeatherManager.FunctionsOpenFunc(cityId, type, isOpen)
    if type ~= FunctionsType.Storm then
        return
    end
    this.GetWeather(cityId):SetStormOpen(isOpen)
end
---------------------------------
---------------------------------

--获取天气类型
function WeatherManager.GetWeatherType(cityId)
    return this.GetWeather(cityId):GetWeatherType()
end

--获取天气温度
function WeatherManager.GetTemperature(cityId)
    return this.GetWeather(cityId):GetTemperature()
end

--获取天气剩余时间
function WeatherManager.GetLeftTime(cityId)
    return this.GetWeather(cityId):GetLeftTime()
end

--切换天气
function WeatherManager.ChangeWeather(cityId, type)
    return this.GetWeather(cityId):ChangeWeather(type)
end


-- 播放毒气表现
function WeatherManager.OnWeatherChange(cityId, type)
    return this.GetWeather(cityId):OnWeatherChange(type)
end