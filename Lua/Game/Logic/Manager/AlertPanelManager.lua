AlertPanelManager = {}
AlertPanelManager._name = "AlertPanelManager"
local this = AlertPanelManager

---显示能源警告对话框
---@param onYes fun(popup:boolean)  popup是否弹出了确认框
function AlertPanelManager.ShowFuelAlertPanel(zoneId, furnitureId, costConfig, onYes, silence)
    if silence or not FunctionsManager.IsUnlock(FunctionsType.ResourceAlertTips) then
        if onYes ~= nil then
            onYes(false)
        end
        
        return
    end
    local currItemId = GeneratorManager.GetConsumptionItemId(DataManager.GetCityId())
    if costConfig[currItemId] == nil then
        -- 消耗材料没有燃料，随便造
        if onYes ~= nil then
            onYes(false)
        end
        
        return
    end
    
    local costCount = costConfig[currItemId]

    if DataManager.CheckInfinity(DataManager.GetCityId(), currItemId) then
        -- 无穷，随便造
        if onYes ~= nil then
            onYes(false)
        end
        
        return
    end
    
    local alertMinute = ConfigManager.GetMiscConfig("resources_tip_int")
    local consumptionSpeedPerMinute = GeneratorManager.GetConsumptionCountForMaterialCheck(DataManager.GetCityId())
    if DataManager.GetMaterialCount(DataManager.GetCityId(), currItemId) - costCount >
        alertMinute * consumptionSpeedPerMinute then
        --库存足够
        if onYes ~= nil then
            onYes(false)
        end
    
        return
    end
    
    local noTips = this.GetFuelAlertTodayData()
    local today = this.GetTodayString()
    if today == noTips.date and noTips.dontTips == true then
        --今天不需要提示
        if onYes ~= nil then
            onYes(false)
        end
        
        return
    end
    
    --PopupManager.Instance:OpenPanel(PanelType.FuelAlertPanel, {
    --    zoneId = zoneId,
    --    furnitureId = furnitureId,
    --    onYes = onYes
    --})
    
    
    local content = ""
    local fuelRemainMinute = ConfigManager.GetMiscConfig("resources_tip_int")
    if furnitureId ~= nil then
        content = GetLangFormat("Popup_Overload_Furniture", fuelRemainMinute)
    else
        content = GetLangFormat("Popup_Overload_Building", fuelRemainMinute)
    end
    
    UIUtil.showConfirmByData( {
        ShowToggle = true,
        ToggleDefault = AlertPanelManager.GetFuelAlertTodayData().dontTips,
        ToggleText = "Popup_Overload_Check",
        DescriptionRaw = content,
        Title = "Popup_Overload_Title",
        ShowYes = true,
        YesColor = 1,
        ShowNo = true,
        NoColor = 1,
        OnYesFunc = function(toggle)
            if onYes ~= nil then
                onYes(true)
            end
    
            AlertPanelManager.SetFuelAlertTodayData(toggle)
        end,
        OnNoFunc = function(toggle)
            AlertPanelManager.SetFuelAlertTodayData(toggle)
        end
    })
end

function AlertPanelManager.GetFuelAlertTodayData()
    return PersistManager.Get(DataKey.FuelAlertTodayNoTips) or {
        date = "",
        dontTips = false
    }
end

function AlertPanelManager.SetFuelAlertTodayData(dontTips)
    PersistManager.Set(DataKey.FuelAlertTodayNoTips, {
        date = this.GetTodayString(),
        dontTips = dontTips
    })
end

function AlertPanelManager.GetTodayString()
    local now = Time2:New(GameManager.GameTime())
    return string.format("%d-%02d-%02d", now:Date().year, now:Date().month, now:Date().day)
end
