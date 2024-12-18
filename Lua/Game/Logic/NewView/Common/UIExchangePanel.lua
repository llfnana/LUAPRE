---@class UIExchangePanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIExchangePanel = Panel;

function Panel.OnAwake()
    this.cachedata = {}
    this.InitPanel()
    this.InitEvent()

    this.param = nil
end

function Panel.InitPanel()
    this.uidata = {}

    this.uidata.btnClose = SafeGetUIControl(this, "BtnClose", "Button")

    this.uidata.inputFeild = SafeGetUIControl(this, "InputField", "InputField")
    this.uidata.pasteBtn = SafeGetUIControl(this, "InputField/BtnPaste", "Button")

    this.uidata.btnSumbit = SafeGetUIControl(this, "BtnSumbit", "Button")
    this.uidata.btnCancel = SafeGetUIControl(this, "BtnCancel", "Button")
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.btnClose.gameObject, this.HideUI)

    SafeAddClickEvent(this.behaviour, this.uidata.pasteBtn.gameObject, function ()
        this.uidata.inputFeild.text = Util.GetSystemCopyBuffer()
    end)

    SafeAddClickEvent(this.behaviour, this.uidata.btnSumbit.gameObject, function ()
        if this.uidata.inputFeild.text == "" then
            UIUtil.showText(GetLang("ui_gift_exchange_inputs"))
            return
        end
        PlayerModule.c2sExchangeGift(this.uidata.inputFeild.text, function (data)
            local rewards = data.a.msgWin.items
            local cityId = DataManager.GetCityId()
            for k, v in ipairs(rewards) do
                rewards[k] = Utils.ConvertAttachment2Rewards(v.id, v.count, RewardAddType.Item)
                DataManager.AddMaterial(cityId, v.id, v.count)
            end
            ResAddEffectManager.AddResEffectFromRewards(rewards, true)
            this.HideUI()
        end)
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.btnCancel.gameObject, function ()
        this.HideUI()
    end)

end

function Panel.OnShow(data)
    UIUtil.openPanelAction(this.gameObject)
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UIExchange)
    end)
end
