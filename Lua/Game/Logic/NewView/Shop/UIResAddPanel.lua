---@class UIResAddPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIResAddPanel = Panel;

require "Game/Logic/NewView/Common/UIFlyingBoxItem"

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.mask = this.GetUIControl("Mask")
    this.uidata.propOne = this.GetUIControl("Item")
    this.uidata.props = this.GetUIControl("Props")
    this.uidata.flyingClaims = this.GetUIControl("FlyingClaims")
    this.uidata.flyingBoxItem = this.GetUIControl("UIFlyingBoxItem")

    this.addNum = nil
    this.timeoutIdList = nil
end

function Panel.InitEvent()
    --绑定UGUI事件
end

function Panel.OnShow(data)
    this.addNum = 0
    if data.state == 1 then
        this.AddItem(data.pos, data.data, data.isLocal, data.eventSign, data.callback)
    elseif data.state == 2 then
        this.AddFlyingClaim(data.startPos, data.targetPos, data.data, data.callback, data.rotate, data.path, data
            .hideEff, data.eventSign)
    end
end

---@param pos Vector3
---@param data table
---@param isLocal boolean
---@param eventSign string
function Panel.AddItem(pos, data, isLocal, eventSign, callback)
    
    SafeSetActive(this.uidata.mask, true)
    -- SafeSetActive(this.uidata.flyingClaims, false)
    SafeSetActive(this.uidata.props, true)
    local target = {}
    if data[1] == nil then 
        table.insert(target, data)
    else 
        target = data
    end

    -- target = data[1] == nil and table.insert(target, data) or data
    local targetPos = {}
    if pos.x ~= nil then
        table.insert(targetPos, pos)
    else
        targetPos = pos
    end
    for i, v in ipairs(target) do
        this.AddItemOne(targetPos, target, isLocal, eventSign, i, callback)
    end
end

function Panel.AddItemOne(pos, data, isLocal, eventSign, index, callback)
    local item = this.GetItem()
    this.InitItem(item, data[index])
    -- local pos = pos[index]
    -- item.transform.position = pos

    local delayId = ResAddEffectManager.AddDelayView(data[index])


    -- icon缩小变大 再到标准规格
    -- 然后text向上做一个偏移动画
    local tween = DOTween.Sequence()

    local txt = item.transform:Find("TxtNum")
    local effect = item.transform:Find("ImgIcon/Z_UI_gain")
    SafeSetActive(effect.gameObject, true)
    local startPos = txt.transform.anchoredPosition - Vector3(0, 30, 0)
    txt.transform.anchoredPosition = startPos
    item.transform.localScale = Vector3.zero
    SafeSetActive(txt.gameObject, false)
    --Q弹
    tween:Append(item.transform:DOScale(Vector3.one * 1.5, 0.3))
    tween:Append(item.transform:DOScale(Vector3.one, 0.3))
    tween:Append(Util.TweenTo(0, 1, 0.8, function(value)
        SafeSetActive(txt.gameObject, true)
        txt.transform.anchoredPosition = startPos + Vector3(0, 30 * value, 0)
    end))
    tween:AppendInterval(0.6)
    tween:OnComplete(function()
        SafeSetActive(txt.gameObject, false)
    end)
    tween:AppendInterval(0.1)
    tween:AppendCallback(function()
        this.itemPool:free(item)
        this.addNum = this.addNum - 1
        ResAddEffectManager.ResAddFlyingCollect(item.transform.position, data[index], nil, eventSign,
            function()
                ResAddEffectManager.CostDelayView(delayId)
                if callback then
                    callback()
                end
            end)
    end)

    tween:Play()

    -- local showFlyingEffect = function()
    --     -- TimeModule.addDelay(1.333, function()
    --     --     -- item.gameObject:SetActive(false)
    --     --     this.itemPool:free(item)
    --     --     this.addNum = this.addNum - 1
    --     --     ResAddEffectManager.ResAddFlyingCollect(item.transform.position, data[index], nil, eventSign,
    --     --         function()
    --     --             ResAddEffectManager.CostDelayView(delayId)
    --     --             if callback then
    --     --                 callback()
    --     --             end
    --     --         end)
    --     -- end)
    --     setTimeout(
    --         function()
    --         this.itemPool:free(item)
    --         this.addNum = this.addNum - 1
    --         ResAddEffectManager.ResAddFlyingCollect(item.transform.position, data[index], nil, eventSign,
    --             function()
    --                 ResAddEffectManager.CostDelayView(delayId)
    --                 if callback then
    --                     callback()
    --                 end
    --             end)
    --         end,
    --         1333
    --     )
    -- end

    -- showFlyingEffect()
end

function Panel.GetItem()
    if this.itemPool == nil then
        this.itemPool = GoPoolMgr.createPool(this.uidata.propOne)
    end

    local item = this.itemPool:get()
    item.transform:SetParent(this.uidata.props.transform, false)
    SafeSetActive(item, true)

    return item
end

function Panel.InitItem(item, data)
    local icon = item.transform:Find("ImgIcon"):GetComponent("Image")
    local txt = item.transform:Find("TxtNum"):GetComponent("Text")
    icon.transform.localScale = Vector3(0.85, 0.85, 1)
    -- Utils.SetRewardIcon(data, icon, nil)
    -- txt.text = "+" .. Utils.FormatCount(data.count)
    
    Utils.SetRewardIcon4(data, icon, nil, txt, "+")
end

function Panel.AddFlyingClaim(startPos, targetPos, data, callback, rotate, path, hideEff, eventSign)
    SafeSetActive(this.uidata.mask, true)
    SafeSetActive(this.uidata.flyingClaims, true)

    local view = GOInstantiate(this.uidata.flyingBoxItem.gameObject, this.uidata.flyingClaims.transform)
    SafeSetActive(view.gameObject, true)
    local rewardItem = UIFlyingBoxItem:new()
    rewardItem:InitPanel(this.behaviour, view, nil)
    rewardItem:OnInit(data)
    if (hideEff) then
        rewardItem:HideEff()
    end
    if targetPos == nil then
        targetPos = Vector3(0, 0, 0)
    end
    -- local pos = ResAddEffectManager.GetCameraWorldToScreenPoint(startPos)
    -- pos.x = -Screen.width / 2 + pos.x
    -- pos.y = -Screen.height / 2 + pos.y
    targetPos.z = 0
    view.transform.position = startPos
    view.transform.localScale = Vector3(1, 1, 1)
    if path == nil then
        path = "ui/Animation/DT_ItemFromBox"
    end
    ResAddEffectManager.StartCollectTweenUI(
        view,
        path,
        function()
            rewardItem:HideIcon()
            SafeSetActive(this.uidata.mask, false)
            callback()
        end,
        targetPos,
        rotate,
        eventSign
    )
end

function Panel.GetCameraWorldToScreenPoint(position)
    local pos = RectTransformUtility.WorldToScreenPoint(PanelManager:GetUICamera(), position)

    -- pos.x = pos.x * Screen.widthRatio
    -- pos.y = pos.y * Screen.heightRatio
    return pos
end

function Panel.HideUI()
    HideUI(UINames.UIResAdd)
end
