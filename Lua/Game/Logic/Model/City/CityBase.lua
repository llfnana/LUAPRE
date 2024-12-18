CityBase = {}

function CityBase:New(cityId)
    local cls = Clone(self)
    cls:Init(cityId)
    return cls
end

function CityBase:Init(cityId)
    self.cityId = cityId
    self.cityConfig = ConfigManager.GetCityById(cityId)
    self:OnInit()
end

function CityBase:ShowListToast(msg, color, icon, sfxName, config)
    if DataManager.GetCityId() ~= self.cityId then
        return
    end
    
    -- 提示功能暂时改为通用提示
    EventManager.Brocast(EventDefine.ShowMainUITip, msg, icon, false, 3)
    -- UIUtil.showText(msg)
    -- GameToastList.Instance:Show(msg, color, icon, sfxName, config)
end

function CityBase:ShowToast(msg, color)
    if DataManager.GetCityId() ~= self.cityId then
        return
    end

    EventManager.Brocast(EventDefine.ShowMainUITip, msg, nil, false, 3)

    -- 提示功能暂时改为通用提示
    -- if self.isShowView then
    --     GameToast.Instance:Show(msg,color)
    -- end
end

function CityBase:ShowTaskToast(msg, color)
    if DataManager.GetCityId() ~= self.cityId then
        return
    end

    UIUtil.showTaskText(msg)
    
end

function CityBase:PlayAudioEffect(sfxName)
    if DataManager.GetCityId() ~= self.cityId then
        return
    end
    --  AudioManager.PlayEffect(sfxName)
end

function CityBase:InitView()
    self.isShowView = true
    self:OnInitView()
end

function CityBase:ClearView()
    self.isShowView = false
    self:OnClearView()
end

function CityBase:Clear()
    self:OnClear()
end

function CityBase:OnInit()
end

function CityBase:OnInitView()
end

function CityBase:OnClearView()
end

function CityBase:OnClear()
end
