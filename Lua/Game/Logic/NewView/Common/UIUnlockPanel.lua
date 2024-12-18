---@class UIUnlockPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIUnlockPanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.panel = this.GetUIControl("Panel", "CanvasGroup")
    this.uidata.mask = this.BindUIControl("Mask", this.HideUI)
    this.uidata.txtTip1 = this.GetUIControl("Panel/TxtTip1", "Text")
    this.uidata.txtTip2 = this.GetUIControl("Panel/TxtTip2", "Text")
    this.uidata.txtTitle = this.GetUIControl("Panel/TxtTitle", "Text")
    this.uidata.txtName = this.GetUIControl("Panel/Name/Txt", "Text")
    this.uidata.imgIcon = this.GetUIControl("Panel/ImgIcon", "Image")
    this.uidata.iconCanvasGroup = this.GetUIControl("Panel/ImgIcon", "CanvasGroup")
    this.uidata.flyImgIcon = this.GetUIControl("ImgIcon", "Image")
    this.uidata.effect = this.GetUIControl("Panel/Z_UI_renwu")
    this.uidata.effect1 = this.GetUIControl("Panel/E_UI_renwu_lizi")

    this.path = {
        [FunctionsType.Tasks] = "home_bt_task",
        [FunctionsType.Shop] = "home_bt_shop",
        [FunctionsType.Cards] = "home_bt_hero",
        [FunctionsType.Map] = "home_bt_map",
        [FunctionsType.Assist] = "home_bt_map",
        [FunctionsType.WorkerManagement] = "home_bt_manage",
        [FunctionsType.Setting] = "home_bt_set",
        [FunctionsType.Statistical] = "home_bt_statistics",
        [FunctionsType.FactoryGame] = "home_bt_games",
        
    }
    this.key = {
        [FunctionsType.Tasks] = "ui_task_title",
        [FunctionsType.Shop] = "ui_shop_title",
        [FunctionsType.Cards] = "ui_card_hero",
        [FunctionsType.Map] = "UI_Map_Title",
        [FunctionsType.Assist] = "ui_assist_title",
        [FunctionsType.WorkerManagement] = "UI_Title_People",
        [FunctionsType.Setting] = "UI_Setting_Title",
        [FunctionsType.Statistical] = "UI_Title_Statistical",
        [FunctionsType.FactoryGame] = "ui_gamemachine_title",
        
    }

    this.tween = nil
end

function Panel.InitEvent()
    --绑定UGUI事件
    UIUtil.CloseAllPanelOutBy(UINames.UIUnlock)
end

function Panel.OnShow(data)
    if data and data.type == FunctionsType.Tasks then
        SDKAnalytics.TraceEvent(138)
    end


    this.data = data or {}
    this.uidata.txtTip1.text = GetLang("ui_gameover_title")
    this.uidata.txtTip2.text = GetLang("ui_gameover_title")
    this.uidata.txtTitle.text = GetLang("ui_new_function_unlock")
    this.uidata.txtName.text = GetLang(this.key[this.data.type])
    this.SetImage(this.uidata.imgIcon, this.path[this.data.type], nil, true, true)
    this.SetImage(this.uidata.flyImgIcon, this.path[this.data.type], nil, nil, true)
    this.uidata.flyImgIcon.transform.localPosition = Vector3.New(19, 60, 0)
    this.PlayShowAni()
end

function Panel.PlayShowAni()
    SafeSetActive(this.uidata.panel.gameObject, true)
    SafeSetActive(this.uidata.imgIcon.gameObject, false)
    this.uidata.panel.alpha = 0
    this.uidata.panel.transform.localScale = Vector3(1, 0.3, 1)
    if this.tween == nil then
        this.tween = DOTween.Sequence()
    end
    this.tween:Append(Util.TweenTo(0.9, 1, 1, function(v)
        this.uidata.imgIcon.transform.localScale = Vector3(v, v, 1)
    end):SetEase(Ease.OutSine))
    this.tween:Append(Util.TweenTo(1, 0.9, 1, function(v)
        this.uidata.imgIcon.transform.localScale = Vector3(v, v, 1)
    end)):SetEase(Ease.OutSine)
    this.tween:SetLoops(-1)

    this.uidata.panel.transform:DOScaleY(1, 0.25):SetEase(Ease.OutBack)
    local tween = Util.TweenTo(0, 1, 0.25, function(v)
        this.uidata.panel.alpha = v
    end)
    TimeModule.addDelay(0.2, function()
        SafeSetActive(this.uidata.effect.gameObject, true)

        -- SafeSetActive(this.uidata.imgIcon.gameObject, true)
        this.uidata.iconCanvasGroup.alpha = 1
        this.uidata.imgIcon.transform.localScale = Vector3(2, 2, 1)
        Util.TweenTo(0, 1, 0.1, function(v)
            this.uidata.iconCanvasGroup.alpha = v
        end)
        Util.TweenTo(2, 1.5, 0.2, function(v)
            this.uidata.imgIcon.transform.localScale = Vector3(v, v, 1)
        end):OnComplete(function()
            SafeSetActive(this.uidata.effect1.gameObject, true)
            this.tween:Play()
        end)
    end)
end

function Panel.PlayHideAni()
    local go = UIMainPanel.hudUnlocks[this.data.type].buttons[1]
    SafeSetActive(this.uidata.panel.gameObject, false)
    SafeSetActive(this.uidata.flyImgIcon.gameObject, true)

    ---飞行动画
    this.uidata.flyImgIcon.transform:DOMove(go.transform.position, 0.5):SetEase(Ease.Linear):OnComplete(function()
        if this.data.flyOverBack then
            this.data.flyOverBack()
        end
    end)

    Util.TweenTo(1.5, 1, 0.2, function(v)
        this.uidata.flyImgIcon.transform.localScale = Vector3(v, v, 1)
    end)
end

function Panel.HideUI()
    this.tween:Kill()
    this.PlayHideAni()
    TimeModule.addDelay(0.5, function()
        HideUI(UINames.UIUnlock)
    end)
end
