---@class UIShopTimeMachineItem
local Element = class("UIShopTimeMachineItem")
UIShopTimeMachineItem = Element

UIShopTimeMachineItem.Status = {
    InCD = "inCD",
    Remain = "remain",
    Limit = "limit",
    None = "none",
}

function Element:ctor()
end

function Element:InitPanel(behaviour, obj, param)
    self.gameObject = obj;
    self.transform = obj.transform;
    self.behaviour = behaviour;
    param = param or {}

    if self.uidata == nil then self.uidata = {} end
    self.Cell1 = SafeGetUIControl(self, "Prop/1")
    self.Cell2 = SafeGetUIControl(self, "Prop/2")
    self.Cell3 = SafeGetUIControl(self, "Prop/3")
    self.Cell4 = SafeGetUIControl(self, "Prop/4")
    self.ItemName = SafeGetUIControl(self, "Title/TxtNum", "Text")
    self.Icon = SafeGetUIControl(self, "ImgIcon", "Image")
    self.BtnOpen = SafeGetUIControl(self, "BtnOpen")
    self.TxtOpen = SafeGetUIControl(self, "BtnOpen/TxtOpen", "Text")
    self.Consume = SafeGetUIControl(self, "BtnOpen/Consume")
    self.TxtConsumeNum = SafeGetUIControl(self, "BtnOpen/Consume/TxtNum", "Text")
    self.Num = SafeGetUIControl(self, "TxtNum")
    self.TxtNum = SafeGetUIControl(self, "TxtNum/Txt", "Text")
end

---@param data ShopPanelItemData
function Element:OnInit(data)
    self.cityId = DataManager.GetCityId()
    self.shopPanelItemData = data
    self.CellList, self.ResourceIconList = self:InitCell()
    self.rewards = Utils.ParseReward(self.shopPanelItemData.package.reward)

    -- fixed text
    self.ItemName.text = GetLang(self.shopPanelItemData.config.name)
    Utils.SetIcon(self.Icon, self.shopPanelItemData.config.banner_pic, function()
        self.Icon.gameObject:SetActive(true)
    end)

    if #self.rewards == 0 then
        print("[error]" .. "invalid timeMachine rewards")
        return
    end

    if self.rewards[1].addType == RewardAddType.ItemType then
        self.ItemId = Utils.GetItemId(self.cityId, self.rewards[1].id)
    else
        self.ItemId = self.rewards[1].id
    end

    self.ItemConfig = ConfigManager.GetItemConfig(self.ItemId)
    self.CostGemCount = self:GetCostGemCount()

    if ShopManager.HasCD(self.shopPanelItemData.config.condition_claim_cd) then
        self.RefreshCooldownFunc = function()
            self:Refresh()
        end
        EventManager.AddListener(EventType.TIME_REAL_PER_SECOND, self.RefreshCooldownFunc)
    end

    self:RefreshResourceIcon()

    SafeAddClickEvent(self.behaviour, self.BtnOpen, function()
        self:OnClickButton()
    end)
    SafeAddClickEvent(self.behaviour, self.gameObject, function()
        self:OnClickButton()
    end)

    self:Refresh()
end

function Element:Refresh()
    if not ShopManager.CheckItem(self.cityId, self.shopPanelItemData.config.id, ShopManager.Action.Show) then
        self.gameObject:SetActive(false)
        self.shopPanelItemData.rebuildFunc()
        return
    end

    local status = self:GetStatus()
    self.Consume.gameObject:SetActive(status == UIShopTimeMachineItem.Status.None)
    self.TxtOpen.gameObject:SetActive(status == UIShopTimeMachineItem.Status.Remain)
    self.Num.gameObject:SetActive(status == UIShopTimeMachineItem.Status.Remain)

    if status == UIShopTimeMachineItem.Status.Remain then
        local count = DataManager.GetMaterialCount(self.cityId, self.ItemId)
        self.TxtNum.text = math.floor(count)
    elseif status == UIShopTimeMachineItem.Status.None then
        self.TxtConsumeNum.text = self.CostGemCount
    end
end

function Element:GetStatus()
    local count = DataManager.GetMaterialCount(self.cityId, self.ItemId)
    if count > 0 then
        return UIShopTimeMachineItem.Status.Remain
    end

    local inCD = ShopManager.GetShopItemInCooldown(self.shopPanelItemData.config)
    if inCD then
        return UIShopTimeMachineItem.Status.InCD
    end

    if ShopManager.GetShopItemRemainCount(self.shopPanelItemData.config.id) == 0 then
        return UIShopTimeMachineItem.Status.Limit
    end

    return UIShopTimeMachineItem.Status.None
end

function Element:OnClickButton()
    local status = self:GetStatus()

    if status == UIShopTimeMachineItem.Status.InCD then
        return
    end

    Analytics.Event(
        "ShopTimeSkipIconTap",
        {
            diamondPrice = self.CostGemCount,
            reward = OverTimeProductionManager.Get(self.cityId):GetTimeSkipReward(self.ItemConfig.duration),
            itemId = self.ItemConfig.id,
            packageKey = self.shopPanelItemData.package.id,
            itemNum = DataManager.GetMaterialCount(self.cityId, self.ItemConfig.id)
        }
    )

    ShowUI(UINames.UITimeMachine, {
        config = self.shopPanelItemData.config,
        package = self.shopPanelItemData.package,
        itemConfig = self.ItemConfig,
        status = self:GetStatus(),
        onClick = function(cb)
            self:OnConfirmPanelClick(self.shopPanelItemData.config, cb)
        end
    })
end

function Element:OnConfirmPanelClick(config, cb)
    local status = self:GetStatus()

    if status == UIShopTimeMachineItem.Status.InCD then
        return
    end

    -- 没有，先买个
    if status == UIShopTimeMachineItem.Status.None then
        self.shopPanelItemData.onBuyButtonClick(
            self.shopPanelItemData.config,
            function()
                self:ExchangeTimeMachine(config, cb)
            end,
            true
        )

        return
    end

    self:ExchangeTimeMachine(config, cb)
    self:Refresh()
end

---使用时间机器
function Element:ExchangeTimeMachine(config, cb)
    local zoneMapItemDataList = OverTimeProductionManager.Get(self.cityId):GetValidUpgradingZoneList()
    local buildingRewards = {}
    for i = 1, #zoneMapItemDataList do
        table.insert(
            buildingRewards,
            {
                name = zoneMapItemDataList[i].zoneId,
                time = zoneMapItemDataList[i]:GetBuildLeftTime()
            }
        )
    end
    ShopManager.Analytics(
        "ShopTimeSkipIconUse",
        {
            diamondPrice = self.CostGemCount,
            reward = OverTimeProductionManager.Get(self.cityId):GetTimeSkipReward(self.ItemConfig.duration),
            itemId = self.ItemConfig.id,
            packageKey = self.shopPanelItemData.package.id,
            itemNum = DataManager.GetMaterialCount(self.cityId, self.ItemConfig.id),
            buildingName = buildingRewards
        }
    )

    local rewards = OverTimeProductionManager.Get(self.cityId):UseTimeSkip(self.ItemId, "Shop", config.id)
    if #rewards > 0 then
        cb()
        local showReward = {}
        for i = 1, #rewards do
            if rewards[i].addType ~= RewardAddType.ZoneTime then
                table.insert(showReward, rewards[i])
            end
        end
        ResAddEffectManager.AddResEffectFromRewards(
            showReward,
            true,
            { hideFlying = true, isShop = false, title = GetLang("ui_shop_timeskip_get_resource"),
                eventSign = { shopId = config.id } }
        )
    end
end

function Element:RefreshResourceIcon()
    local rewards = self:GetTimeSkipRewardsForShow()
    local resourceCount = #rewards
    if resourceCount > 4 then
        resourceCount = 4
    end

    local resourceIconList = self.ResourceIconList[resourceCount]
    for i = 1, #resourceIconList do
        local itemConfig = ConfigManager.GetItemConfig(rewards[i].id)
        Utils.SetIcon(resourceIconList[i], itemConfig.icon, nil, true)
    end

    -- 多的要隐藏掉
    if resourceCount < 4 then 
        for i = resourceCount + 1, 4 do
            self.CellList[i]:SetActive(false)
        end
    end
end

function Element:GetTimeSkipRewardsForShow()
    local rewards = OverTimeProductionManager.Get(self.cityId):GetItemOverTimeReward(1)
    table.sort(
        rewards,
        function(a, b)
            local aCfg = ConfigManager.GetItemConfig(a.id)
            local bCfg = ConfigManager.GetItemConfig(b.id)

            return aCfg.sort > bCfg.sort
        end
    )

    if CityManager.GetIsEventScene(self.cityId) then
        local cashId = Utils.GetItemId(self.cityId, ItemType.Cash)
        table.insert(
            rewards,
            1,
            {
                addType = RewardAddType.Item,
                id = cashId,
                count = OverTimeProductionManager.Get(self.cityId):GetOverTime(cashId, 1)
            }
        )
    end

    return rewards
end

function Element:GetCostGemCount()
    -- 默认返回第一个消耗，而且假定第一个消耗就是想看到的那个消耗
    if Utils.GetTableLength(self.shopPanelItemData.package.cost) > 0 then
        for k, v in pairs(self.shopPanelItemData.package.cost) do
            return v
        end
    end

    return 0
end

function Element:InitCell()
    local cellList = {
        self.Cell1, self.Cell2, self.Cell3, self.Cell4
    }

    local resourceIconList = {}
    for i = 1, #cellList do
        local images = {}
        for j = 1, i do
            local image = cellList[j]:GetComponent("Image")
            table.insert(images, image)
        end

        table.insert(resourceIconList, images)
    end

    return cellList, resourceIconList
end

function Element:OnDestroy()
    if self.shopPanelItemData then 
        if ShopManager.HasCD(self.shopPanelItemData.config.condition_claim_cd) then
            EventManager.RemoveListener(EventType.TIME_REAL_PER_SECOND, self.RefreshCooldownFunc)
        end
    end
end
