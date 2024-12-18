---@class UIFactoryGameMsgItemPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIFactoryGameMsgItemPanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
    this.ItemList = {}
    this.itemData = {}
    this.FlyItemList = {}
    this.FlyItem = {
        [1] = {id = "Coal4",index = 1},
        [2] = {id = "Hunger",index = 1},
        [3] = {id = "Sleep",index = 1},
        [4] = {id = "Gem",index = 1},
    }
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.Mask = SafeGetUIControl(this, "Mask")
    this.uidata.top = SafeGetUIControl(this, "Top")
    this.uidata.CoalItem = SafeGetUIControl(this, "Top/CoalItem")
    this.uidata.HungerItem = SafeGetUIControl(this, "Top/HungerItem")
    this.uidata.GemItem_1 = SafeGetUIControl(this, "Top/GemItem_1")
    this.uidata.SleepItem = SafeGetUIControl(this, "Top/SleepItem")

    this.uidata.CoalItem_text = SafeGetUIControl(this, "Top/CoalItem/TxtCount","Text")
    this.uidata.HungerItem_text = SafeGetUIControl(this, "Top/HungerItem/TxtCount","Text")
    this.uidata.GemItem_1_text = SafeGetUIControl(this, "Top/GemItem_1/TxtCount","Text")
    this.uidata.SleepItem_text = SafeGetUIControl(this, "Top/SleepItem/TxtCount","Text")

    
    this.uidata.flyItem = SafeGetUIControl(this, "fly/flyItem")
    this.uidata.fly = SafeGetUIControl(this, "fly")
    this.uidata.flyItem:SetActive(false)
    this.uidata.fly:SetActive(true)
    -- for i = 1, this.uidata.top.transform.childCount do
    --     local go = this.uidata.top.transform:Find(i).gameObject
    --     this.TopList[i] = go
    -- end

    this.uidata.itemList = SafeGetUIControl(this, "ItemList")
    this.uidata.contentRT = SafeGetUIControl(this, "ItemList/item")
    -- this.btnClose = this.BindUIControl("Mask", this.HideUI)
    this.uidata.contentRT:SetActive(false)
end

function Panel.InitEvent()
    --绑定UGUI事件
    
end

function Panel.OnShow(AddGameRewards, callback, PosList, resItem) 
    this.cb = callback
    -- if callback then
    --     callback()
    -- end
    this.cityId = DataManager.GetCityId()
    this.config = AddGameRewards
    this.PosList = PosList
    this.Playerinfos = CharacterManager.GetAttributeDebuffCount(this.cityId)
    this.uidata.CoalItem_text.text = resItem[1]
    this.uidata.HungerItem_text.text = resItem[2]
    this.uidata.GemItem_1_text.text = resItem[3]
    this.uidata.SleepItem_text.text = resItem[4]
    -- UIUtil.FormatCount()
    this.getItemInfo()
    local seq = DOTween.Sequence()
    seq:AppendCallback(function ()
        this.RefreshList()
    end)
    seq:AppendInterval(1)
    seq:AppendCallback(function ()
        this.uidata.fly:SetActive(true)
        this.uidata.itemList:SetActive(false)
        this.RefreshFlyList()
    end)
end

function Panel.getItemConfig()
    local data = BagModule.getMsgItems()
    -- DataManager.AddReward(this.cityId, data, "Shop")
    local config = {}
    for index, value in ipairs(data) do
        -- local itemdata = ConfigManager.GetItemConfig(value.id)
        -- if itemdata and itemdata.duration > 0 then
        --     local rewards = OverTimeProductionManager.Get(this.cityId):GetTimeSkipReward(itemdata.duration)
        --     local item = OverTimeProductionManager.Get(this.cityId):UseTimeSkip(value.id, "Shop", this.cityId)
        --     for i, val in ipairs(rewards) do
        --         if val.addType ~= RewardAddType.ZoneTime then
        --             table.insert(config, val)
        --         end
        --     end
        -- else
        table.insert(config, value)
        -- end
    end
    return config
end

function Panel.getItemInfo()
    local itemdata = {}
    for index, value in ipairs(this.config) do
        itemdata = nil
        itemdata = ConfigManager.GetItemConfig(value.id)
        if itemdata then
            -- ListUtil.assign(itemdata, value)
            itemdata.count = value.count
            table.insert(this.itemData, itemdata)
        end
    end
end

function Panel.RefreshList()
    for index, value in ipairs(this.config) do
        local item = this.ItemList[index]
        if item == nil then
            item = this.CreateItem()
            table.insert(this.ItemList, item)
        end
        this.InitItem(item, value, index)
    end
    ForceRebuildLayoutImmediate(this.uidata.contentRT.transform.parent.gameObject)
end

function Panel.InitItem(item, value, index)
    local icon = SafeGetUIControl(item, "Icon", "Image")
    local Num = SafeGetUIControl(item, "Num", "Text")
    local data = ConfigManager.GetItemConfig(value.id)
    SetImage(this.behaviour, icon, data.icon)
    Num.text = Utils.FormatCount(value.count)
end

function Panel.CreateItem()
    local itemGo = GameObject.Instantiate(this.uidata.contentRT)
    itemGo.transform:SetParent(this.uidata.contentRT.transform.parent, false)
    itemGo.transform.localScale = Vector3.one
    itemGo:SetActive(true)
    return itemGo
end

function Panel.RefreshFlyList()
    for index, value in ipairs(this.config) do
        local item = this.FlyItemList[index]
        if item == nil then
            item = this.CreateFlyItem()
            table.insert(this.FlyItemList, item)
        end
        local seq = DOTween.Sequence()
        seq:AppendInterval(1)
        if value.id == "Sleep" then
            seq:Append(item.transform:DOMove(this.uidata.SleepItem.transform.position, 0.5):SetEase(Ease.Linear))
        elseif value.id == "Hunger" then
            seq:Append(item.transform:DOMove(this.uidata.HungerItem.transform.position, 0.5):SetEase(Ease.Linear))
        elseif value.id == "Gem" then
            seq:Append(item.transform:DOMove(this.uidata.GemItem_1.transform.position, 0.5):SetEase(Ease.Linear))
        elseif value.id == "Gamecoins1" or value.id == "Gamecoins2" then
            seq:Append(item.transform:DOMove(this.PosList[value.id], 0.5):SetEase(Ease.Linear))
        else
            seq:Append(item.transform:DOMove(this.uidata.CoalItem.transform.position, 0.5):SetEase(Ease.Linear))
        end
        seq:Join(item.transform:DOScale(0.3, 0.5))
        -- seq:AppendInterval(0.3)
        seq:AppendCallback(function()
            this.Playerinfos = CharacterManager.GetAttributeDebuffCount(this.cityId)
            this.uidata.CoalItem_text.text = Utils.FormatCount(DataManager.GetMaterialCount(this.cityId, "Coal" .. this.cityId)) 
            this.uidata.HungerItem_text.text = this.Playerinfos.Hunger  or 0
            this.uidata.GemItem_1_text.text = Utils.FormatCount(DataManager.GetMaterialCount(this.cityId, ItemType.Gem))
            this.uidata.SleepItem_text.text = this.Playerinfos.Rest or 0
            item:SetActive(false)
        end)
        this.InitFlyItem(item, value, index)
    end
    TimeModule.addDelay(1.8, function ()
        this.HideUI()
    end)
end

function Panel.InitFlyItem(item, value, index)
    local icon = SafeGetUIControl(item, "icon", "Image")
    local Num = SafeGetUIControl(item, "Num", "Text")
    local data = ConfigManager.GetItemConfig(value.id)
    SetImage(this.behaviour, icon, data.icon)
    Num.text = Utils.FormatCount(value.count)
end

function Panel.CreateFlyItem()
    local itemGo = GameObject.Instantiate(this.uidata.flyItem)
    itemGo.transform:SetParent(this.uidata.flyItem.transform.parent, false)
    itemGo.transform.localScale = Vector3.one
    itemGo:SetActive(true)
    -- ForceRebuildLayoutImmediate(this.uidata.flyItem.transform.parent.gameObject)
    return itemGo
end

function Panel.PlayHideAni(item)
    this.HideUI()
end

function Panel.HideUI()
    this.cb()
    HideUI(UINames.UIFactoryGameMsgItem)
end