---@class UIFactoryGameIItemInfoPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIFactoryGameIItemInfoPanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.Mask = SafeGetUIControl(this, "Mask")
    this.uidata.Bg = SafeGetUIControl(this, "Bg")
    this.uidata.TxtName = SafeGetUIControl(this, "Bg/Top/TxtName","Text")
    this.uidata.TxtDesc = SafeGetUIControl(this, "Bg/Com/TxtDesc","Text")
    this.uidata.Com = SafeGetUIControl(this, "Bg/Com")
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.Mask.gameObject, this.HideUI)
end

function Panel.OnShow(param)
    this.id = param and param.id or 1
    this.index = param.index
    local itemConfig = ConfigManager.GetItemConfig(this.id)
    this.uidata.TxtName.text = GetLang(itemConfig.name_key)
    this.uidata.TxtDesc.text = GetLang(itemConfig.desc_key)
    local target = param and param.target or nil
    target = param.target or Vector3.zero
    local x, y = this.GetTransformAnchor(target)
    local anchor = Vector2(x, y)
    this.uidata.Bg.transform.pivot = target and anchor or Vector2(0.5, 0.5)
    this.uidata.Bg.transform.anchorMin = target and anchor or Vector2(0.5, 0.5)
    this.uidata.Bg.transform.anchorMax = target and anchor or Vector2(0.5, 0.5)
    this.uidata.Bg.transform.position = target.transform.position
    ForceRebuildLayoutImmediate(this.uidata.Bg.gameObject)
    ForceRebuildLayoutImmediate(this.uidata.Com.gameObject)
end

function Panel.GetTransformAnchor(go)
    local rect = go:GetComponent("RectTransform")
    local center = RectTransformUtility.WorldToScreenPoint(PanelManager:GetUICamera(), rect.position);
    local uiCanvasRt = PanelManager.UICanvas.transform --ui画布
    local height = uiCanvasRt.rect.height
    local width = uiCanvasRt.rect.width
    local offset = 150
    local offsetX = center.x - offset
    offsetX = offsetX < 0 and 0 or offsetX
    local offsetY = center.y - offset
    offsetY = offsetY < 0 and 0 or offsetY
    ---默认右下角区域
    local x = Mathf.Floor(offsetX / (width / 2)) > 1 and 1 or Mathf.Floor(offsetX / (width / 2))
    local y = Mathf.Floor(offsetY / (height / 2))
    if this.index >= 3 and this.index < 8 then
        x = 1
    end
    -- print("道具提示",x,y)
    return x, y
end

function Panel.HideUI()
    HideUI(UINames.UIFactoryGameIItemInfo)
end
