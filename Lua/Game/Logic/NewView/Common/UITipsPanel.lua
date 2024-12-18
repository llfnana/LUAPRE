local Panel = {};
local this = Panel;
UITipsPanel = Panel;
--启动事件--
function this.Awake(obj, behaviour)
    this.gameObject = obj;
    this.transform = obj.transform;
    this.behaviour = behaviour;

    this.InitPanel();
end

--初始化面板--
function Panel.InitPanel()
    this.uidata = {};
    this.uidata.commList = SafeGetUIControl(this, "CommList")
    this.uidata.commItem = SafeGetUIControl(this, "CommList/Comm")

    this.uidata.tweens = {}
end

--启动事件--
function Panel.OnShow(data, overCallback)
    this.ShowCommTips(data, overCallback)
end

function Panel.ShowCommTips(data, overCallback)
    if this.uidata.commPool == nil then
        this.uidata.commPool = GoPoolMgr.createPool(this.uidata.commItem)
    end
    local go = this.uidata.commPool:get()
    go.transform:SetParent(this.uidata.commList.transform, false)
    local txt = go.transform:Find("Txt"):GetComponent("Text")
    txt.text = data
    ForceRebuildLayoutImmediate(go.gameObject)
    this.playAnim(go.transform, function()
        this.uidata.commPool:free(go)
        if overCallback ~= nil then
            overCallback()
        end
    end)
end

function Panel.playAnim(item, overCallback)
    --原始位置
    local homePosition = item.anchoredPosition
    local temp = item.anchoredPosition
    --原始大小
    local homeScale = item.localScale
    local canvasGroup = item:GetComponent("CanvasGroup")
    local homeAlpha = canvasGroup.alpha
    local tween = DOTween.Sequence()
    local index = #this.uidata.tweens + 1
    this.uidata.tweens[index] = tween

    tween:OnStart(function()
        canvasGroup.alpha = 1
        item.localScale = homeScale * 0.5
    end)
    --Q弹
    tween:Append(item:DOScale(Vector3.one * 1.5, 0.1))
    tween:Append(item:DOScale(Vector3.one * 0.8, 0.1))
    tween:Append(item:DOScale(Vector3.one, 0.1))
    tween:AppendInterval(1)
    -- 上移
    tween:Append(Util.TweenTo(0, 1, 1, function(value)
        temp.y = temp.y + value
        item.anchoredPosition = temp
        canvasGroup.alpha = 1 - value
    end))
    tween:OnComplete(function()
        this.uidata.tweens[index] = nil
        item.anchoredPosition = homePosition
        item.localScale = homeScale
        canvasGroup.alpha = homeAlpha
        SafeSetActive(item.gameObject, false)
        if overCallback ~= nil then
            overCallback()
        end
    end)

    tween:Play()
end

--销毁事件--
function Panel.OnDestroy()
    for i, v in ipairs(this.uidata.tweens) do
        if v then
            v:Kill()
        end
    end
end
