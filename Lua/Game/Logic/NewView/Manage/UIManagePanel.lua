---@class UIManagePanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIManagePanel = Panel;

require "Game/Logic/NewView/Manage/OverTimeCell"
require "Game/Logic/NewView/Manage/UIPeopleCell"

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.allItems = {}
    this.allOverTimeItems = {}
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.Mask = SafeGetUIControl(this, "Mask")
    this.uidata.ButtonClose = SafeGetUIControl(this, "ImageTttleBg/ButtonClose")
    this.uidata.ButtonHelp = SafeGetUIControl(this, "ImagePeopleState/ButtonHelp")

    this.uidata.bgImage = SafeGetUIControl(this, "bgImage")
    this.uidata.PeopleN = SafeGetUIControl(this, "PeopleN")
    this.uidata.PeopleS = SafeGetUIControl(this, "PeopleS")
    this.uidata.OverTimeN = SafeGetUIControl(this, "OverTimeN")
    this.uidata.OverTimeS = SafeGetUIControl(this, "OverTimeS")
    this.uidata.BuyItem = SafeGetUIControl(this, "BuyItem")
    this.uidata.ImageVipTip = SafeGetUIControl(this, "ImagePeopleState/ImageVipTip")
    this.uidata.ImageTttleBg = SafeGetUIControl(this, "ImageTttleBg")
    this.uidata.ImagePeopleState = SafeGetUIControl(this, "ImagePeopleState")
    this.uidata.ImageBuildState = SafeGetUIControl(this, "ImageBuildState")
    this.uidata.ImageOverTimeState = SafeGetUIControl(this, "ImageOverTimeState")

    this.uidata.WorkCount = SafeGetUIControl(this, "ImagePeopleState/StateItem1/TextNum", "Text")
    this.uidata.SickCount = SafeGetUIControl(this, "ImagePeopleState/StateItem2/TextNum", "Text")
    this.uidata.RestCount = SafeGetUIControl(this, "ImagePeopleState/StateItem3/TextNum", "Text")

    this.uidata.PersonItem = SafeGetUIControl(this, "PersonItem")
    this.uidata.PeopleItem = SafeGetUIControl(this, "PeopleItem")
    this.uidata.OverTimeItem = SafeGetUIControl(this, "OverTimeItem")
    this.uidata.Content = SafeGetUIControl(this, "ImageBuildState/ScrollView/Viewport/Content")

    this.uidata.OverTimeContent = SafeGetUIControl(this, "ImageOverTimeState/ScrollView/Viewport/Content")

    SafeGetUIControl(this, "PeopleN/Text", "Text").text = GetLang("UI_Subtitle_Survival_Assign")
    SafeGetUIControl(this, "PeopleS/Text", "Text").text = GetLang("UI_Subtitle_Survival_Assign")
    SafeGetUIControl(this, "OverTimeN/Text", "Text").text = GetLang("UI_Building_Info_Workover")
    SafeGetUIControl(this, "OverTimeS/Text", "Text").text = GetLang("UI_Building_Info_Workover")
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.Mask, this.HideUI)
    SafeAddClickEvent(this.behaviour, this.uidata.ButtonClose, this.HideUI)
    SafeAddClickEvent(this.behaviour, this.uidata.ButtonHelp, function()
        ShowUI(UINames.UIManageState)
    end)

    SafeAddClickEvent(this.behaviour, SafeGetUIControl(this, "BuyItem/ButtonGo"), function()
        ShowUI(UINames.UISubscription,
            {
                configList = this.configList,
                packageList = this.packageList,
                nil,
                successBuyFunc = function()
                    this.UpPurchasedState()
                end,
            })
    end)

    -- 幸存者
    SafeAddClickEvent(this.behaviour, this.uidata.PeopleN, function()
        this.index = 1
        this.UpViewState()
    end)

    -- 加班
    SafeAddClickEvent(this.behaviour, this.uidata.OverTimeN, function()
        if FunctionsManager.IsOpen(this.cityId, FunctionsType.WorkOverTime) then
            this.index = 2
            this.UpViewState()
        else
            UIUtil.showText(GetLang("ui_statistics_lock_desc"))
        end
    end)

    this.UpgradeZoneFunc = function(cityId, zoneId, zoneType, level)
        if level ~= 1 then
            return
        end
        local peopleConfig = ConfigManager.GetPeopleConfigByZoneType(cityId, zoneType)
        if not peopleConfig then
            return
        end
        if this.peopleItems:ContainsKey(peopleConfig.type) then
            return
        end
        this.AddPeopleItem(peopleConfig)
    end
    this.AddListener(EventType.UPGRADE_ZONE, this.UpgradeZoneFunc)

    this.WorkStateChangeFunc = function(cityId)
        if this.cityId == cityId then
            this.RefreshAllPeopleItem()
        end
    end
    this.AddListener(EventType.WORK_STATE_CHANGE, this.WorkStateChangeFunc)

    this.CharacterRefreshFunc = function()
        this.RefreshAllPeopleItem()
    end
    this.AddListener(EventType.CHARACTER_REFRESH, this.CharacterRefreshFunc)

    this.AddListener(EventType.TIME_CITY_UPDATE, function()
        this.RefreshOverTimeItems()
    end)

    this.AddListener(EventType.TeQuanAutohange, function()
        local key = CharacterManager.GetTeQuanAutoKey()
        local count = CharacterManager.GetStorage(key)
        SafeGetUIControl(this, "ImagePeopleState/ImageVipTip/TextDes", "Text").text = GetLang("ui_city_subscription_people_purchased", count)
    end)
end

-- 购买状态
function Panel.UpPurchasedState()
    local configList = {}
    local packageList = {}
    table.insert(configList, ShopManager.GetShopConfig(206))
    table.insert(packageList, ConfigManager.GetShopPackage(206))
    local purchased = ShopManager.CheckSubscriptionCanClaim(configList)

    local conf = ShopManager.GetShopConfig(206)
    local unlock = FunctionsManager.IsUnlock(conf.condition_functions_unlock)
    this.purchased = purchased
    this.configList = configList
    this.packageList = packageList

    SafeSetActive(this.uidata.BuyItem, not purchased and unlock)
    SafeSetActive(this.uidata.ImageVipTip, purchased)

    local titlePos = (purchased or not unlock) and 420 or 590
    local bgHight = (purchased or not unlock) and 1020 or 1190

    local position = this.uidata.ImageTttleBg.transform.localPosition
    local bgRect = this.uidata.bgImage.transform.rect

    this.uidata.ImageTttleBg.transform.localPosition = Vector3(position.x, titlePos, position.z)
    this.uidata.bgImage.transform.sizeDelta = Vector2(this.uidata.bgImage.transform.sizeDelta.x, bgHight)
end

function Panel.UpViewState()
    SafeSetActive(this.uidata.ImageBuildState, this.index == 1)
    SafeSetActive(this.uidata.ImageOverTimeState, this.index == 2)
    SafeSetActive(this.uidata.PeopleS, this.index == 1)
    SafeSetActive(this.uidata.PeopleN, this.index == 2)
    SafeSetActive(this.uidata.OverTimeS, this.index == 2)
    SafeSetActive(this.uidata.OverTimeN, this.index == 1)
end

function Panel.OnShow()
    UIUtil.openPanelAction(this.gameObject)

    this.InitViewData()
    this.InitEvent();

    this.AddOverTimeItem()

    --刷新幸存者状态显示
    this.UpdatePeopleState()

    this.UpViewState()

    this.UpPurchasedState()
end

function Panel.InitViewData()
    --初始化数据
    this.cityId = DataManager.GetCityId()

    if this.peopleItems == nil then 
        this.peopleItems = Dictionary:New()
    else 
        this.peopleItems:Clear()
    end
    local index = 1
    for ix, peopleCfgItem in pairs(ConfigManager.GetPeopleList(this.cityId)) do
        if peopleCfgItem.type ~= ProfessionType.FreeMan and MapManager.GetZoneCount(this.cityId, peopleCfgItem.zone_type, 1) > 0 then
            this.AddPeopleItem(peopleCfgItem, index)
            index = index + 1
        end
    end

    -- 再把多余的隐藏起来
    local count = this.peopleItems:Count()
    local allCount = #this.allItems
    for i = count + 1, allCount, 1 do
        this.allItems[i][2].gameObject:SetActive(false)
    end

    -- 加班管理
    this.index = 1
end

-- 填充加班item
function Panel.AddOverTimeItem()
    if this.OverTimeItems == nil then 
        this.OverTimeItems = Dictionary:New()
    else 
        this.OverTimeItems:Clear()
    end

    for i = 1, this.uidata.OverTimeContent.transform.childCount, 1 do
        this.uidata.OverTimeContent.transform:GetChild(i-1).gameObject:SetActive(false)
    end
    
    local index = 1
    for __, OverTimeItem in pairs(MapManager.GetOvertimeBuild(this.cityId)) do
        local go
        local item
        if index > #this.allOverTimeItems then 
            go = GOInstantiate(this.uidata.OverTimeItem)
            item = OverTimeCell.new()
            table.insert(this.allOverTimeItems, {item, go})
        else 
            item = this.allOverTimeItems[index][1]
            go = this.allOverTimeItems[index][2]
        end
        
        go.transform:SetParent(this.uidata.OverTimeContent.transform, false)
        SafeSetActive(go.gameObject, true)
        item:InitPanel(this.behaviour, go, OverTimeItem.zoneId)
        this.OverTimeItems:Add(OverTimeItem.zoneId, item)
        index = index + 1
    end
end

--刷新幸存者item
function Panel.RefreshOverTimeItems()
    this.OverTimeItems:ForEach(
        function(item)
            item:OnRefresh()
        end
    )
end

--填充幸存者item
function Panel.AddPeopleItem(peopleConfig, index)
    index = index or (this.peopleItems:Count() + 1)  -- 过关后，这个index 可能是 0
    local go
    local item
    if index > #this.allItems then 
        go = GOInstantiate(this.uidata.PeopleItem)
        item = UIPeopleCell.new()
        table.insert(this.allItems, {item, go})
    else 
        local value = this.allItems[index]
        item = value[1]
        go = value[2]
    end

    this.peopleItems:Add(peopleConfig.type, item)
    go.transform:SetParent(this.uidata.Content.transform, false)
    SafeSetActive(go.gameObject, true)
    item:InitPanel(this.behaviour, go, this.uidata.PersonItem, peopleConfig)
end

--刷新幸存者item
function Panel.RefreshAllPeopleItem()
    this.peopleItems:ForEach(
        function(i)
            i:OnUpdate()
        end
    )
    this.UpdatePeopleState()
end

--刷新幸存者状态显示
function Panel.UpdatePeopleState()
    local workCount, notWorkCount, restCount = CharacterManager.GetPeopleWorkStateCount(this.cityId)
    this.uidata.WorkCount.text = workCount
    this.uidata.SickCount.text = notWorkCount
    this.uidata.RestCount.text = restCount

    local key = CharacterManager.GetTeQuanAutoKey()
    local count = CharacterManager.GetStorage(key)
    SafeGetUIControl(this, "ImagePeopleState/ImageVipTip/TextDes", "Text").text = GetLang("ui_city_subscription_people_purchased", count)

end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UIManage)
    end)
end
