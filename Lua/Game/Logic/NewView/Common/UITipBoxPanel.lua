---@class UITipBoxPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UITipBoxPanel = Panel;

---icon在哪一边
local UITipBoxDir = {
    Left = 1,
    Right = 2,
    Down = 3,
    Up = 4,
}

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    -- this.uidata.mask = this.BindUIControl("Mask", this.HideUI)
    this.uidata.bg = this.GetUIControl("Bg")
    this.uidata.top = this.GetUIControl("Bg/Top")
    this.uidata.line = this.GetUIControl("Bg/ImgLine")
    this.uidata.txtName = this.GetUIControl(this.uidata.top, "TxtName", "Text")
    this.uidata.btnGet = this.BindUIControl(this.uidata.top, "BtnGet", this.ClickGet)
    this.uidata.com = this.GetUIControl("Bg/Com")
    this.uidata.txtDesc = this.GetUIControl(this.uidata.com, "TxtDesc", "Text")
    this.uidata.one = this.GetUIControl("Bg/One")
    this.uidata.txtOneDesc = this.GetUIControl(this.uidata.one, "TxtDesc", "Text")
    this.uidata.txtRowDesc = this.GetUIControl(this.uidata.one, "TxtRowDesc", "Text")
    this.uidata.nonius = this.GetUIControl("Bg/Nonius")
    this.uidata.Prop = this.GetUIControl("Bg/Prop")
    this.uidata.addition = this.GetUIControl("Bg/Addition")
    this.uidata.txtAddition = this.GetUIControl(this.uidata.addition, "TxtAddition", "Text")
    this.uidata.additionProp = this.GetUIControl("Bg/AdditionProp")

    this.nonius = {}
    for i = 1, 4 do
        local go = this.uidata.nonius.transform:GetChild(i - 1).gameObject
        SafeSetActive(go, false)
        table.insert(this.nonius, go)
    end

    this.canvasWidth = 750
    this.canvasHeight = 1668
    local width = this.canvasWidth
    local height = this.canvasHeight
    this.bounds = {
        left = -width / 2,
        right = width / 2,
        top = height / 2,
        bottom = height / -2
    }
    this.offset = 0.3
end

function Panel.InitEvent()
    --绑定UGUI事件
end

function Panel.OnShow(data)
    this.cityId = DataManager.GetCityId()
    this.data = data
    local dir = this.data.dir or this.GetDir()

    ---目前只有两种样式
    ---一种有奖励【需要在调用前就把奖励数据构建好传递进来】
    ---一种无奖励
    if this.data.type == TooltipType.Item or this.data.type == TooltipType.Zone then
        this.RefreshItemInfo()
    elseif this.data.type == TooltipType.Attribute then
        this.RefreshAttributeInfo()
    else
        this.RefreshRewardInfo()
    end
    ForceRebuildLayoutImmediate(this.uidata.bg)

    this.RefreshNonius(dir)
    this.SetPosition(dir)
    ForceRebuildLayoutImmediate(this.uidata.bg)

    if this.flag == nil then
        TouchUtil.onOnceTap(this.HideUI)
        this.flag = true
    end
end

function Panel.ClickGet()
    if this.data.type == TooltipType.Attribute then
        ShowUI(UINames.UIPersonAttributeInfo)
    elseif this.data.type == TooltipType.Item then
        local productedInZoneType = this.config.producted_in[1]
        local zoneId = ConfigManager.GetZoneIdByZoneType(DataManager.GetCityId(), productedInZoneType)
        Utils.LookUpZone(zoneId, "ToolTip", true)
    elseif this.data.type == TooltipType.Zone then
        Utils.LookUpZone(this.data.itemId, "ToolTip", true)
    elseif this.config.producted_in ~= nil and next(this.config.producted_in) ~= nil then
        local productedInZoneType = this.config.producted_in[1]
        local zoneId = ConfigManager.GetZoneIdByZoneType(DataManager.GetCityId(), productedInZoneType)
        Utils.LookUpZone(zoneId, "ToolTip", true)
    end
    this.HideUI()
    -- HideUI(this.data.jump)
    this.HideLastPanel()
end

function Panel.HideLastPanel()
    if type(this.data.jump) == "string" then
        HideUI(this.data.jump)
    elseif type(this.data.jump) == "boolean" then
        return
    else
        if this.data.jump ~= nil and next(this.data.jump) ~= nil then
            for k, v in pairs(this.data.jump) do
                HideUI(v)
            end
        end
    end
end

function Panel.RefreshItemInfo()
    local itemId = this.data.itemId
    local jump = this.data.jump ~= nil and this.data.jump ~= ""
    local desc = this.GetDesc()
    SafeSetActive(this.uidata.top.gameObject, this.data.itemId ~= nil or this.data.title ~= nil)
    SafeSetActive(this.uidata.line.gameObject, this.data.itemId ~= nil or this.data.title ~= nil)
    SafeSetActive(this.uidata.com.gameObject, this.data.itemId ~= nil or this.data.title ~= nil)
    SafeSetActive(this.uidata.one.gameObject, this.data.itemId == nil and this.data.title == nil)
    SafeSetActive(this.uidata.btnGet.gameObject, jump and not DataManager.CheckInfinity(this.cityId, itemId) and
        this.config.producted_in ~= nil and next(this.config.producted_in) ~= nil)
    SafeSetActive(this.uidata.Prop.gameObject, false)
    SafeSetActive(this.uidata.addition.gameObject, false)
    SafeSetActive(this.uidata.additionProp.gameObject, false)


    --纯文本描述
    if this.data.itemId == nil and this.data.title == nil then
        SafeSetActive(this.uidata.txtOneDesc.gameObject, true)
        SafeSetActive(this.uidata.txtRowDesc.gameObject, false)
        this.uidata.txtOneDesc.text = desc
        if this.uidata.txtOneDesc.preferredWidth > 390 then
            SafeSetActive(this.uidata.txtOneDesc.gameObject, false)
            SafeSetActive(this.uidata.txtRowDesc.gameObject, true)
            this.uidata.txtRowDesc.text = desc
        end
    else
        this.uidata.txtDesc.text = desc
    end
end

function Panel.RefreshAttributeInfo()
    SafeSetActive(this.uidata.top.gameObject, true)
    SafeSetActive(this.uidata.line.gameObject, true)
    SafeSetActive(this.uidata.com.gameObject, true)
    SafeSetActive(this.uidata.one.gameObject, false)
    SafeSetActive(this.uidata.Prop.gameObject, false)
    SafeSetActive(this.uidata.addition.gameObject, false)
    SafeSetActive(this.uidata.additionProp.gameObject, false)
    local type = this.data.attribute
    local needJumpe = this.data.jump
    this.config = ConfigManager.GetNecessitiesConfig(this.cityId, type)
    this.uidata.txtName.text = GetLang(this.config.necessities_name)
    this.uidata.txtDesc.text = GetLang(this.config.necessities_desc)
    SafeSetActive(this.uidata.btnGet.gameObject, needJumpe ~= nil or needJumpe ~= "")
end

function Panel.RefreshRewardInfo()
    local state = (this.data.rewards[1].addType == RewardAddType.Box or this.data.rewards[1].addType == RewardAddType.OpenBox) and
        1 or 2
    SafeSetActive(this.uidata.Prop.gameObject, true)
    SafeSetActive(this.uidata.top.gameObject, this.data.itemId ~= nil)
    SafeSetActive(this.uidata.line.gameObject, this.data.itemId ~= nil)
    SafeSetActive(this.uidata.com.gameObject, this.data.itemId ~= nil)
    SafeSetActive(this.uidata.one.gameObject, false)
    SafeSetActive(this.uidata.addition.gameObject, this.data.addition ~= nil and next(this.data.addition) ~= nil)
    SafeSetActive(this.uidata.additionProp.gameObject, this.data.addition ~= nil and next(this.data.addition) ~= nil)
    SafeSetActive(this.uidata.Prop.gameObject, this.data.rewards ~= nil and next(this.data.rewards) ~= nil)

    if this.data.itemId ~= nil then
        this.config = state == 1 and ConfigManager.GetBoxConfig(this.data.rewards[1].id) or
            ConfigManager.GetItemConfig(this.data.rewards[1].id)
        local key = this.config.name and this.config.name or this.config.name_key
        this.uidata.txtName.text = GetLang(key)
        this.uidata.txtDesc.text = state == 1 and GetLang("ui_shop_box_least") or this.GetDesc()
        if this.data.addition then
            this.uidata.txtDesc.text = GetLang("ui_shop_box_least")
            this.uidata.txtAddition.text = GetLang("UI_box_desc_reward")
        end
    end
    SafeSetActive(this.uidata.btnGet.gameObject, this.config ~= nil and
        this.config.producted_in ~= nil and next(this.config.producted_in) ~= nil)
    this.InitRewardItem(this.uidata.Prop, this.data.rewards)
    this.InitRewardItem(this.uidata.additionProp, this.data.addition)
end

function Panel.GetDesc()
    local itemId = this.data.itemId
    local isItem = ConfigManager.GetItemConfig(itemId) ~= nil
    local isBox = ConfigManager.GetBoxConfig(itemId) ~= nil
    local isZone = ConfigManager.GetZoneConfigById(itemId) ~= nil
    this.config = isItem and ConfigManager.GetItemConfig(itemId) or isBox and ConfigManager.GetBoxConfig(itemId) or
        isZone and ConfigManager.GetZoneConfigById(itemId) or nil
    this.uidata.txtName.text = this.config and
        GetLang(isItem and this.config.name_key or isBox and this.config.name or
            isZone and "zone_name_" .. this.config.assets_name or nil) or this.data.title
    local desc = nil
    if this.config then
        local descKey = isItem and this.config.desc_key or isBox and this.config.desc or
            isZone and this.config.desc_key[1] or nil
        if this.config.producted_in == nil or #this.config.producted_in == 0 then
            desc = GetLang(descKey)
        elseif this.config.scope == "Global" then
            desc = GetLang(descKey)
        elseif this.config.scope == "Card" then
            desc = GetLang(descKey)
        elseif DataManager.CheckInfinity(DataManager.GetCityId(), itemId) then
            desc = GetLang("UI_item_infinity_desc")
        elseif this.config.city_id == DataManager.GetCityId() then
            if descKey == "item_desc_common_format" then
                local zoneId = ConfigManager.GetZoneIdByZoneType(this.cityId, this.config.producted_in[1])
                local mapItemData = MapManager.GetMapItemData(this.cityId, zoneId)
                desc = GetLangFormat(descKey, mapItemData:GetName())
            else
                desc = GetLang(descKey)
            end
        else
            desc = GetLang("UI_item_infinity_desc")
        end
    else
        desc = this.data.text
    end
    return desc
end

function Panel.InitRewardItem(parent, rewards)
    for i = 1, parent.transform.childCount do
        local go = parent.transform:GetChild(i - 1).gameObject
        SafeSetActive(go, false)
    end
    if rewards == nil then
        return
    end
    local go = parent.transform:GetChild(0).gameObject
    for i, v in ipairs(rewards) do
        local item = nil
        if i >= parent.transform.childCount then
            item = GOInstantiate(go, parent.transform)
        else
            item = parent.transform:GetChild(i - 1).gameObject
        end
        SafeSetActive(item, true)
        this.RefreshRewardItem(item, v)
    end
end

function Panel.RefreshRewardItem(item, data)
    local state = (data.addType == RewardAddType.Item or data.addType == RewardAddType.OverTime or
            data.addType == RewardAddType.DailyItem) and 1 or data.addType == RewardAddType.Card and 2 or
        data.addType == RewardAddType.Box and 3 or 4

    local config = state == 1 and ConfigManager.GetItemConfig(data.id) or state == 2
        and ConfigManager.GetCardConfig(data.id) or ConfigManager.GetBoxConfig(data.id) or nil

    if config == nil then
        error("config is nil:" .. ListUtil.dump(data))
    end
    local imgIcon = item.transform:Find("Img"):GetComponent("Image")
    local txtNum = item.transform:Find("Txt"):GetComponent("Text")
    this.SetImage(imgIcon, config.icon)
    txtNum.text = data.count
end

---显示隐藏游标
function Panel.RefreshNonius(dir)
    for i, v in ipairs(this.nonius) do
        SafeSetActive(v.gameObject, i == dir)
    end
end

function Panel.SetPosition(dir)
    local bgPosition = this.GetPosition(dir)
    local anchor = this.GetAnchor(dir)
    this.uidata.bg.transform.pivot = anchor
    this.uidata.bg.transform.position = Vector3(bgPosition.x, bgPosition.y, 0)
    this.CorrectionPosition(dir, bgPosition)
end

---获取icon所在方向
function Panel.GetDir()
    local pos = this.GetWorldToScreenPosition(this.data.go.transform.position)
    pos.x = -this.canvasWidth / 2 + pos.x
    pos.y = -this.canvasHeight / 2 + pos.y
    if pos.y + 300 > this.bounds.top then
        return UITipBoxDir.Up
    end
    if pos.x + 150 > this.bounds.right then
        return UITipBoxDir.Right
    end
    if pos.x - 150 < this.bounds.left then
        return UITipBoxDir.Left
    end
    return UITipBoxDir.Down
end

---获取bg坐标 整体偏移30px【this.offset】
function Panel.GetPosition(dir)
    local position = this.data.go.transform.position
    local bgPosition = Vector2(0, 0)
    if dir > 2 then
        local operation = dir == 3 and 1 or -1
        bgPosition.x = position.x
        bgPosition.y = position.y + operation * this.offset
    else
        local operation = dir == 1 and 1 or -1
        bgPosition.x = position.x + operation * this.offset
        bgPosition.y = position.y
    end

    return bgPosition
end

---偏移坐标水平游标特殊处理
function Panel.CorrectionPosition(dir, bgPosition)
    local pos = this.uidata.bg.transform.anchoredPosition
    this.uidata.bg.transform.anchoredPosition3D = Vector3(pos.x, pos.y, 0)
    --超出部分需要移动bg 跟游标
    if dir <= 2 then
        return
    end
    local size = this.uidata.bg.transform.sizeDelta

    local offset = this.OutBound(dir)
    local noniu = this.nonius[dir]
    if offset ~= 0 then
        local x = pos.x + offset + 5
        this.uidata.bg.transform.anchoredPosition3D = Vector3(x, pos.y, 0)
    end
    noniu.transform.position = Vector2(bgPosition.x, noniu.transform.position.y)
end

---是否越界 越界返回需要调整的偏移值
function Panel.OutBound(dir)
    if dir <= 2 then
        return
    end
    local pos = this.uidata.bg.transform.anchoredPosition
    local size = this.uidata.bg.transform.sizeDelta

    local offset = 0
    local width = this.canvasWidth / 2
    local option = pos.x <= 0 and -1 or 1
    local sum = math.abs(pos.x + option * size.x / 2)
    if sum >= width then
        offset = sum - width
    end
    return offset * option * -1
end

function Panel.GetWorldToScreenPosition(position)
    local pos = RectTransformUtility.WorldToScreenPoint(PanelManager:GetUICamera(), position)

    return pos
end

function Panel.GetAnchor(dir)
    local anchor = Vector2(0, 0)
    anchor.x = dir == 1 and 0 or dir == 2 and 1 or 0.5
    anchor.y = dir == 3 and 0 or dir == 4 and 1 or 0.5

    return anchor
end

function Panel.HideUI()
    this.flag = nil
    HideUI(UINames.UITipBox)
end
