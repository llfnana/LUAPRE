---@class UIFactoryGameAwdPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIFactoryGameAwdPanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.BtnRigth = SafeGetUIControl(this, "BtnRigth")
    this.uidata.BtnLeft = SafeGetUIControl(this, "BtnLeft")
    this.uidata.BtnClose = SafeGetUIControl(this, "BtnClose")
    this.uidata.TextMain = SafeGetUIControl(this, "TextMain")
    this.uidata.Text_Tip_1 = SafeGetUIControl(this, "TextMain/Text_Tip_1/TextNum", "Text")
    this.uidata.Text_Tip_2 = SafeGetUIControl(this, "TextMain/Text_Tip_2/TextNum", "Text")
    this.uidata.Text_Tip_3 = SafeGetUIControl(this, "TextMain/Text_Tip_3/TextNum", "Text")
    -- this.textList = {}
    -- for i = 1, this.uidata.TextMain.transform.childCount do
    --     local go = this.uidata.TextMain.transform:Find("Text_Tip_" .. i).gameObject
    --     this.textList[i] = go
    -- end
    this.uidata.levelTxt = SafeGetUIControl(this, "Top/umg_Title_1/Titel_1","Text")
    this.uidata.AwdName = SafeGetUIControl(this, "Top/Titel_1","Text")
    this.uidata.Top_Titel = SafeGetUIControl(this, "Top/Titel","Text")
    this.uidata.Top_Titel.text = GetLang("ui_gamemachine_title")
    this.uidata.TitleItem_Titel = SafeGetUIControl(this, "TitleItem/Text","Text")
    this.uidata.TitleItem_Titel.text = GetLang("ui_gamemachine_pricelist")
    this.uidata.itemList = SafeGetUIControl(this, "itemList")
    this.itemList = {}
    for i = 1, this.uidata.itemList.transform.childCount do
        local go = this.uidata.itemList.transform:Find("UIFactoryAwdItem_" .. i).gameObject
        this.itemList[i] = go
    end
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.BtnRigth, function ()
        this.level = this.level + 1
        if this.level > #this.data then
            this.level = 1
        end
        this.Refresh()
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.BtnLeft, function ()
        this.level = this.level - 1
        if this.level < 1 then
            this.level = #this.data
        end
        
        this.Refresh()
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.BtnClose, this.HideUI)
end

function Panel.OnShow(level)
    this.level = level or 1
    this.data = ConfigManager.GetCasinoAll()
    this.Refresh()
end

function Panel.Refresh()
    this.isShowBtn()
    this.RefreshText()
    this.RefreshItem()
    this.uidata.levelTxt.text = this.level
end

function Panel.RefreshText()
    local data = ConfigManager.GetCasino(this.level)
    local cityId = DataManager.GetCityId()
    this.uidata.AwdName.text = GetLang("ui_gamemachine_mapname") .. GetLang(ConfigManager.GetCityById(cityId).city_name)
    this.uidata.Text_Tip_1.text = data.times_max 
    this.uidata.Text_Tip_2.text = data.times_max_ad 
    this.uidata.Text_Tip_3.text = string.format("%0.2f",data.frequency / 3600)  .. "h"
end

function Panel.RefreshItem()
    local list = ConfigManager.GetCasino_RwdConfig()  
    local config = list[this.level]
    for index, value in ipairs(this.itemList) do
        this.InitItem(value, index, config.rwd[index])
    end
end

function Panel.InitItem(go, i, data)
    local icon = go.transform:Find("Icon"):GetComponent("Image")
    local Num = go.transform:Find("Num"):GetComponent("Text")
    local bg = go.transform:Find("Bg")
    local img_icon_1 = go.transform:Find("img_icon_1")
    local time_text = go.transform:Find("img_icon_1/Text"):GetComponent("Text")
    local itemConfig = ConfigManager.GetItemConfig(data.id)
    img_icon_1:SetActive(false)
    if data.id == "Resources10" or data.id == "Resources30" or data.id == "Resources60" then
        time_text.text = itemConfig.duration / 60 .. GetLang("UI_Mail_Time_Min")
        img_icon_1:SetActive(true)
    end
    local itemConfig = ConfigManager.GetItemConfig(data.id)
    local path =  ResInterface.IsExist(itemConfig.icon .. ".png") and
    itemConfig.icon or "icon_item_timeskip120"
    
    ResInterface.SyncLoadSprite( path .. ".png", function(_sprite)
        icon.sprite = _sprite
    end)
    Num.text = data.num
    SafeAddClickEvent(this.behaviour, bg.gameObject, function ()
        ShowUI(UINames.UIFactoryGameIItemInfo,
        {
            id = data.id,
            target = go.gameObject,
            index = i,
        })
    end)
end

function Panel.isShowBtn()
    -- this.uidata.BtnLeft:SetActive(this.level > 1)
    -- this.uidata.BtnRigth:SetActive(this.level < 5)
end

function Panel.HideUI()
    HideUI(UINames.UIFactoryGameAwd)
end
