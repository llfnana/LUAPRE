--- 用于GM测试
local GM = {}

function GM.KeyDown()
    if Input.GetKeyDown("space") then
        local cityId = DataManager.GetCityId()
        for key, value in pairs(ConfigManager.GetMaterialListByCityId(cityId)) do
            DataManager.AddMaterial(cityId, value.id, 100000000)
        end

        for key, value in pairs(ConfigManager.GetCardListByCity(cityId)) do
            CardManager.AddCard(value.id, 10)
        end

        DataManager.AddMaterial(cityId, "BlackCoin", 1000000000)

        -- 英雄经验
        DataManager.AddMaterial(cityId, "Heart", 10000000000)
    end

    if Input.GetKeyDown("h") then
        DataManager.isResponse = false
    end

    if Input.GetKeyDown("g") then
        WeatherManager.ChangeWeather(cityId, WeatherType.Storm)
    end

    if Input.GetKeyDown("f") then
        ShowUI(UINames.UIMap)
    end

    if Input.GetKeyDown("d") then 
        for i = 1, 30, 1 do
            ProtestManager.RefreshCharacterFunc(cityId, false)
        end
    end

    if Input.GetKeyDown("c") then 
        GM.OpenCityPassIntroduction(5)
    end

    if Input.GetKeyDown("s") then 
        local PathCache = require "Game/Logic/Path/PathCache"
        PathCache.WritePath()
    end

    if Input.GetKeyDown("a") then 
        UIUtil.CloseAllPanelOutBy()
    end

    if Input.GetKeyDown("o") then 
        GM.OpenPanel()
    end

    if Input.GetKeyDown("q") then
        CityModule.getMainCtrl():ShowBuildFactoryGame()
    end
end

function GM.OpenPanel()
    if isNil(GM.gameObject) and not GM.isLoadingGMPanel then 
        GM.isLoadingGMPanel = true
        ResInterface.SyncLoadGameObject("GMPanel", function(_go)
            local parent = GameObject.Find("UICanvas/SafeArea/Layer_Top").transform
            GM.gameObject = GOInstantiate(_go, parent)
            GM.transform = GM.gameObject.transform
            GM.transform.localPosition = Vector3(0, 0, 0)
            GM.behaivour = GM.transform:GetComponent("LuaBehaviour")

            GM.InitPanel()
        end)
    else 
        if isNil(GM.gameObject) == false then 
            GM.gameObject:SetActive(true)
            GM.DefaultSelect()
        end
    end
end

function GM.InitPanel()
    GM.InitClose()

    GM.InitCityPanel()

    GM.InitStrike()
end

function GM.InitClose()
    local close = GM.transform:Find("ButtonList/btn_close").gameObject
    SafeAddClickEvent(GM.behaivour, close, function()
        GM.gameObject:SetActive(false)
    end)
end

function GM.InitCityPanel()
    GM.cityPanel = GM.transform:Find("CityPanel")
    local btn_CityPanel = GM.transform:Find("ButtonList/btn_CityPanel").gameObject
    SafeAddClickEvent(GM.behaivour, btn_CityPanel, function()
        GM.CloseAllPanel()
        GM.cityPanel:SetActive(true)
        GM.curCityText.text = "当前城市：" .. DataManager.GetCityId()
    end)

    GM.curCityText = GM.transform:Find("CityPanel/CurCity/Text"):GetComponent("Text")
    GM.curCityText.text = "当前城市：" .. DataManager.GetCityId()

    local cityCount = ConfigManager.GetCityCount()
    local item = GM.transform:Find("CityPanel/Layout/btn_city").gameObject
    local parent = GM.transform:Find("CityPanel/Layout")
    for i = 1, cityCount, 1 do
        local city = GOInstantiate(item, parent)
        city.name = "btn_city_" .. i
        local text = city.transform:Find("Text"):GetComponent("Text")
        text.text = "城市-" .. i
        city:SetActive(true)
        local btn = city:GetComponent("Button")

        SafeAddClickEvent(GM.behaivour, city, function()
            GM.OnClickCityButton(i)
        end)
    end

    btn_CityPanel:GetComponent("Button"):Select()
end

function GM.OnClickCityButton(cityId)
    print("[点击] 城市-", cityId)

    if DataManager.userData["city"..cityId] == nil then 
        DataManager.userData.global.initCity = false
    end
    CityManager.SelectCity(cityId, false)
end

-- 打开通关介绍
function GM.OpenCityPassIntroduction(cityId)
    local config = ConfigManager.GetCityById(cityId)
    local rewards = Utils.ParseReward(config.new_city_reward, false)
    local rewardArr = {}
    for _, rewardItem in pairs(rewards) do
        rewardArr[rewardItem.id] = rewardItem.count
    end
    local unlocks = {}
    for _, itemId in pairs(config.show_infinity_resource) do
        unlocks[itemId] = GetLang("ui_infinity_name")
    end
   
    ShowUI(UINames.UICityPassIntroduction, {
        Rewards = rewardArr,
        Unlocks = unlocks,
    })
end

-- 罢工界面
function GM.InitStrike()
    GM.strikePanel = GM.transform:Find("StrikePanel")
    local btn_StrikePanel = GM.transform:Find("ButtonList/btn_StrikePanel").gameObject
    SafeAddClickEvent(GM.behaivour, btn_StrikePanel, function()
        GM.CloseAllPanel()
        GM.strikePanel:SetActive(true)
    end)

    GM.StrikeDespairValueText = GM.transform:Find("StrikePanel/curDespairValue/Text"):GetComponent("Text")
    GM.StrikeDespairValueText.text = "当前绝望值：" .. DataManager.GetCityDataByKey(DataManager.GetCityId(), DataKey.Despair)

    local btn_AddDespairValue = GM.transform:Find("StrikePanel/btn_AddDespairValue").gameObject
    SafeAddClickEvent(GM.behaivour, btn_AddDespairValue, function()
        local cityId = DataManager.GetCityId();
        local cityProtest = ProtestManager.GetProtest(cityId)
        cityProtest:AddDespairValue(5)
        GM.StrikeDespairValueText.text = "当前绝望值：" .. DataManager.GetCityDataByKey(DataManager.GetCityId(), DataKey.Despair)
    end)
end

function GM.CloseAllPanel()
    GM.cityPanel:SetActive(false)
    GM.strikePanel:SetActive(false)
end

function GM.DefaultSelect()
    GM.transform:Find("ButtonList/btn_CityPanel"):GetComponent("Button"):Select()

    GM.CloseAllPanel()
    GM.cityPanel:SetActive(true)
    GM.curCityText.text = "当前城市：" .. DataManager.GetCityId()
end

return GM