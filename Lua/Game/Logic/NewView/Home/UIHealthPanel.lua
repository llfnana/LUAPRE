---@class UIHealthPanel : UIPanelBase
local Panel = UIPanelBaseMake()
local this = Panel
UIHealthPanel = Panel

function Panel.OnAwake()
    this.cachedata = {}
    this.InitPanel()
    

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.btnClose = SafeGetUIControl(this, "BtnClose", "Button")
    this.uidata.mask = SafeGetUIControl(this, "Mask")

    this.uidata.EmptyGo = SafeGetUIControl(this, "Empty")

    this.uidata.tempItem = SafeGetUIControl(this, "Item")
    this.uidata.content = SafeGetUIControl(this, "Scroll/Viewport/Content")
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.btnClose.gameObject, this.HideUI)

    SafeAddClickEvent(this.behaviour, this.uidata.mask, this.HideUI)
end

function Panel.OnShow()
    UIUtil.openPanelAction(this.gameObject)
    this.Init()
    this.InitEvent()
end

function Panel.Init()
    this.cityId = DataManager.GetCityId()
    UIUtil.RemoveAllGameobject(this.uidata.content)
    this.itemList = {}
    this.UpdatePanel()

    this.UpdatePerSecFunc = function()
        this.UpdatePanel()
    end
    this.AddListener(EventType.TIME_REAL_PER_SECOND, this.UpdatePerSecFunc)
end

function Panel.UpdatePanel()
    local sickInfirmarys = CharacterManager.GetCharactersBySickZone(this.cityId, ZoneType.Infirmary, EnumState.Sick)
    sickInfirmarys:Sort(Utils.SortCharacterByHealCount)
    local severeInfirmarys = CharacterManager.GetCharactersBySickZone(this.cityId, ZoneType.Infirmary, EnumState.Severe)
    local sickDorms = CharacterManager.GetCharactersBySickZone(this.cityId, ZoneType.Dorm, EnumState.Sick)
    local severeDorms = CharacterManager.GetCharactersBySickZone(this.cityId, ZoneType.Dorm, EnumState.Severe)

    local itemIndex = 0
    local itemCount = #this.itemList
    for i = 1, sickInfirmarys:Count(), 1 do
        itemIndex = itemIndex + 1
        if itemIndex <= itemCount then
            this.RefreshItem(this.itemList[itemIndex], sickInfirmarys[i])
        else
            table.insert(this.itemList, this.CreateItem(sickInfirmarys[i]))
            itemCount = itemCount + 1
        end
    end
    for i = 1, severeInfirmarys:Count(), 1 do
        itemIndex = itemIndex + 1
        if itemIndex <= itemCount then
            this.RefreshItem(this.itemList[itemIndex], severeInfirmarys[i])
        else
            table.insert(this.itemList, this.CreateItem(severeInfirmarys[i]))
            itemCount = itemCount + 1
        end
    end
    for i = 1, sickDorms:Count(), 1 do
        itemIndex = itemIndex + 1
        if itemIndex <= itemCount then
            this.RefreshItem(this.itemList[itemIndex], sickDorms[i])
        else
            table.insert(this.itemList, this.CreateItem(sickDorms[i]))
            itemCount = itemCount + 1
        end
    end
    for i = 1, severeDorms:Count(), 1 do
        itemIndex = itemIndex + 1
        if itemIndex <= itemCount then
            this.RefreshItem(this.itemList[itemIndex], severeDorms[i])
        else
            table.insert(this.itemList, this.CreateItem(severeDorms[i]))
            itemCount = itemCount + 1
        end
    end
    if itemIndex < itemCount then
        for i = itemCount, 1, -1 do
            if i > itemIndex then
                local item = this.itemList[i]
                GameObject.Destroy(item.gameObject)
                table.remove(this.itemList, i)
            end
        end
    end

    this.uidata.EmptyGo:SetActive(itemIndex == 0)
end

function Panel.CreateItem(character)
    local item = GOInstantiate(this.uidata.tempItem, this.uidata.content.transform)
    item:SetActive(true)
    this.RefreshItem(item, character)
    return item
end

function Panel.RefreshItem(item, character)
    local diseaseId = character:GetDiseaseId()
    local diseaseConfig = ConfigManager.GetDiseaseConfigById(diseaseId)
    local isHeal = character:GetHealCount() > 0
    local currState = character:GetState()
    local healSpeed = this.GetHealSpeed(character)
    local diseaseMedical = CharacterManager.GetDiseaseMedicalNeed(this.cityId, diseaseId)
    local medicalValue = BoostManager.GetBoost(this.cityId):GetRxBoosterValue(RxBoostType.MedicalValue)
    local sickTime = character:GetSickTime()
    local curTime = math.floor(diseaseMedical - sickTime)
    local totalTime = diseaseMedical

    local headImg = SafeGetUIControl(item, "Head/Icon", "Image")            -- 头像
    local professionName = SafeGetUIControl(item, "Title", "Text")          -- 职业
    local healRateText = SafeGetUIControl(item, "Details/Text3", "Text")    -- 治疗效率%
    local diseaseName = SafeGetUIControl(item, "Status", "Text")            -- 疾病名称
    local healSpeedText = SafeGetUIControl(item, "Details/Text1", "Text")   -- 治疗速度 x/秒
    local progressText = SafeGetUIControl(item, "Slider/Progress", "Text")  -- 治疗进度 x/x
    local healTimeText = SafeGetUIControl(item, "Details/Text2", "Text")    -- 治疗所需时间
    local slider = SafeGetUIControl(item, "Slider", "Slider")               -- 治疗进度条
    local virtualSlider = SafeGetUIControl(item, "Slider/VirtualSlider", "Slider") -- 虚拟进度条

    character:SetPeopleHead(headImg)
    professionName.text = character:GetProfessionName()
    healRateText.text = (character:GetHealRate() * 100) .. "%"
    diseaseName.text = isHeal and GetLang(diseaseConfig.name) or "?"
    healSpeedText.text = healSpeed .. "/" .. GetLang("UI_Mail_Time_Sec")
    healTimeText.text = healSpeed == 0 and "?" or Utils.GetTimeFormat4(math.floor(sickTime / healSpeed))
    progressText.text = string.format("%s/%s", curTime, totalTime)

    local p1 = 1 - sickTime / diseaseMedical
    if p1 >= 1 then
        p1 = 1
    end

    local p2 = p1
    if isHeal then
        p2 = medicalValue / diseaseMedical + p1
        if p2 >= 1 then
            p2 = 1
        end
    end
    slider.value = p1
    virtualSlider.value = p2
    -- slider.value = curTime / totalTime
end

function Panel.GetHealSpeed(character)
    local currState = character:GetState()

    local speed = 0
    if currState == EnumState.Sick then
        for key, value in pairs(character:GetHealNecessities()) do
            speed = value
        end
    end
    return speed
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UIHealth)
    end)
end
