---@class UIOutputCell
local Element = class("UIOutputCell")
UIOutputCell = Element


function Element:ctor()

end

function Element:InitPanel(behaviour, obj, itemId)
    self.gameObject = obj
    self.transform = obj.transform
    self.behaviour = behaviour

    self.cityId = DataManager.GetCityId()
    self.itemId = itemId
    self.rxList = List:New()

    if self.uidata == nil then self.uidata = {} end
    self.uidata.ImageIcon = SafeGetUIControl(self, "ImageIcon","Image")
    self.uidata.TextRes = SafeGetUIControl(self, "TextRes", "Text")
    self.uidata.TextOutput = SafeGetUIControl(self, "TextOutput", "Text")
    self.uidata.TextUse = SafeGetUIControl(self, "TextUse", "Text")

    SafeGetUIControl(self, "TextUseFen", "Text").text = "/" .. GetLang("UI_Time_Minute")
    SafeGetUIControl(self, "TextOutputFen", "Text").text = "/" .. GetLang("UI_Time_Minute")

    self.rxList:Add(
        DataManager.GetMaterialRx(self.cityId, itemId):subscribe(
            function(val)
                self.uidata.TextRes.text = DataManager.GetMaterialCountFormat(self.cityId, itemId)
                self:OnUpdate()
            end
        )
    )
end

function Element:OnUpdate()
    local outputValue = StatisticalManager.GetOnlineProductionsByItemId(self.cityId, self.itemId) * 60
    if outputValue < 0 then
        outputValue = 0
    else
        outputValue = Utils.GetRoundPreciseDecimal(outputValue, 3)
    end
    self.uidata.TextOutput.text = "+" .. Utils.FormatCount(outputValue)

    local consumptionCount = StatisticalManager.GetOnlineConsumptions(self.cityId, self.itemId) * 60
    if consumptionCount < 0 then
        consumptionCount = 0
    else
        consumptionCount = Utils.GetRoundPreciseDecimal(consumptionCount, 3)
    end
    self.uidata.TextUse.text = "-" .. Utils.FormatCount(consumptionCount)

    self.uidata.TextUse.color = outputValue < consumptionCount and Color.New(191 / 255, 57 / 255, 54 / 255, 255) or Color.New(50 / 255, 50 / 255, 50 / 255, 255)

    Utils.SetItemIcon(self.uidata.ImageIcon, self.itemId)
    UIUtil.AddItem(self.uidata.ImageIcon, self.itemId, nil, UINames.UIDataPreview)

    -- 设置颜色
    -- if outputValue < consumptionCount then
    --     self.Consumption:SelectColor(1)
    -- else
    --     self.Consumption:SelectColor(0)
    -- end
end

function Element:OnDestroy()
    self.rxList:ForEach(
        function(rx)
            rx:unsubscribe()
        end
    )
    self.rxList:Clear()
end

