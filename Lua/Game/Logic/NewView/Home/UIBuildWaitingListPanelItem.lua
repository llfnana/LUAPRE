---@class UIBuildWaitingListPanelItem
local Element = class("UIBuildWaitingListPanelItem")
UIBuildWaitingListPanelItem = Element

function Element:ctor()
end

function Element:InitPanel(behaviour, obj, param)
    self.gameObject = obj;
    self.transform = obj.transform;
    self.behaviour = behaviour;
    param = param or {}

    if self.uidata == nil then self.uidata = {} end
    self.BuildIcon = SafeGetUIControl(self, "Item/ImgIcon", "Image")
    self.BuildNameText = SafeGetUIControl(self, "TxtName", "Text")
    self.BuildCurrentLevelText = SafeGetUIControl(self, "TxtNow", "Text")
    self.BuildTargetLevelText = SafeGetUIControl(self, "TxtNext", "Text")
    self.TimeProgressBar = SafeGetUIControl(self, "Progress/ImgBar")
    self.SpendResourcesIcon = SafeGetUIControl(self, "Need/ImgIcon", "Image")
    self.SpendResourcesText = SafeGetUIControl(self, "Need/TxtNum", "Text")
    self.SpendResourcesButton = SafeGetUIControl(self, "Btn")
    self.SpendResourcesButtonText = SafeGetUIControl(self, "Btn/Txt", "Text")
    self.TimeProgressText = SafeGetUIControl(self, "Progress/Txt", "Text")
end

function Element:OnInit(zoneId, parent)
    ---@type BuildWaitingListPanel
    self.parent = parent
    self.cityId = DataManager.GetCityId()
    self.zoneId = zoneId
    self.complete = false
    self.mapItemData = MapManager.GetMapItemData(self.cityId, self.zoneId)
    self.level = self.mapItemData:GetLevel()
    self.SubscriptionCity = ShopManager.CheckSubscriptionValid(ShopManager.SubscriptionType.City)

    SafeAddClickEvent(self.behaviour, self.SpendResourcesButton.gameObject, function()
        self:OnSpeedUpFun()
    end)

    --info
    local minLevel = self.level
    if minLevel == 0 then
        minLevel = 1
    end
    Utils.SetZoneIcon(self.BuildIcon, self.zoneId, 1)
    self.BuildNameText.text = self.mapItemData:GetUpgradeLevelName()
    self.BuildCurrentLevelText.text = GetLangFormat("UI_LEVEL", self.level)
    if self.level + 1 >= self.mapItemData.config.max_level then
        self.BuildTargetLevelText.text = GetLangFormat("UI_LEVEL", "MAX")
    else
        self.BuildTargetLevelText.text = GetLangFormat("UI_LEVEL", self.level + 1)
    end

    --progress
    self.progressSize = Vector2(336.5, 18.77)

    --cost
    self:InitCostOrTicketView()
end

function Element:IsComplete()
    return self.complete
end

function Element:Update()
    if self.mapItemData == nil then
        return
    end

    if self.mapItemData:IsDeveloping() then
        local lfTime, lfTotal = self.mapItemData:GetBuildLeftTime()
        if lfTime > 0 then
            local timeRate = 1.0 - (lfTime / lfTotal)
            self.TimeProgressText.text = Utils.GetTimeFormat3(lfTime)
            self.TimeProgressBar.transform.sizeDelta = Vector2(self.progressSize.x * timeRate, self.progressSize.y)
            self:UpdateCostOrTicketView()
        else

        end
    else
        self.complete = true
    end
end

function Element:InitCostOrTicketView()
    if self:IsBuildTicketValid() then
        Utils.SetItemIcon(self.SpendResourcesIcon, ItemType.BuildTicket)
        self.SpendResourcesButtonText.text = GetLangFormat("ui_city_subscription_build_min",
            ConfigManager.GetMiscConfig("build_ticket_time"))
    else
        Utils.SetItemIcon(self.SpendResourcesIcon, ItemType.Gem)
        self.SpendResourcesButtonText.text = GetLang("General_Botton_Finish_Now")
    end

    self:UpdateCostOrTicketView()
end

function Element:UpdateCostOrTicketView()
    if self:IsBuildTicketValid() then
        self.SpendResourcesText.text = 1
        -- self.SpendResourcesButton:SetInteractable(true)
    else
        local gemCost = self.mapItemData:GetSpeedCost()
        self.SpendResourcesText.text = gemCost
        -- self.SpendResourcesButton:SetInteractable(DataManager.GetMaterialCount(self.cityId, ItemType.Gem) >= gemCost)
    end
end

function Element:OnSpeedUpFun()
    if self:IsBuildTicketValid() then
        if self.mapItemData:UseTicketSpeedBuildUpgradeComplete() == false then
            return
        end
        self:InitCostOrTicketView()
    else
        local completeFunc = function()
            --self:OnDestroy()
            self.parent:HideUI()
        end

        local status = self.mapItemData:GetBuildStatus()
        if status == BuildingStatus.Building then
            if self.mapItemData:SpeedBuildComplete(completeFunc) == false then
                return
            end
        elseif status == BuildingStatus.Complete and self.mapItemData:IsUpgrading() then
            if self.mapItemData:SpeedUpgradeComplete(completeFunc) == false then
                return
            end
        end
    end
end

function Element:IsBuildTicketValid()
    if self.SubscriptionCity and
        DataManager.GetMaterialCount(self.cityId, ItemType.BuildTicket) > 0 and
        ConfigManager.GetMiscConfig("building_ticket_switch") then
        return true
    end

    return false
end

function Element:OnDestroy()
    if not Utils.IsNull(self.gameObject) then
        ResourceManager.Destroy(self.gameObject)
    end
end
