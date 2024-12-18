---@class UIMessageBoxPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIMessageBoxPanel = Panel;

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
    this.uidata.panel = this.GetUIControl("Panel")
    this.uidata.title = this.GetUIControl("Panel/Title")
    this.uidata.txtTitle = this.GetUIControl("Panel/Title/Txt", "Text")
    this.uidata.btnClose = this.BindUIControl("Panel/Title/BtnClose", this.HideUI)
    this.uidata.reward = this.GetUIControl("Panel/Reward")
    this.uidata.items = this.GetUIControl("Panel/Reward/Items")
    this.uidata.item = this.uidata.items.transform:GetChild(0)
    this.uidata.comm = this.GetUIControl("Panel/Comm")
    this.uidata.txtDesc = this.GetUIControl("Panel/Comm/TxtDesc", "Text")
    this.uidata.need = this.GetUIControl("Panel/Need")
    this.uidata.needItems = this.GetUIControl("Panel/Need/Items")
    this.uidata.CostGemText = this.GetUIControl(this.uidata.needItems, "Item/Txt", "Text")
    this.uidata.btnYes = this.GetUIControl("Panel/Btns/BtnYes")
    this.uidata.btnNo = this.GetUIControl("Panel/Btns/BtnNo")
    this.uidata.btnGem = this.GetUIControl("Panel/Btns/BtnGem")
    this.uidata.txtYes = this.GetUIControl("Panel/Btns/BtnYes/Txt", "Text")
    this.uidata.txtNo = this.GetUIControl("Panel/Btns/BtnNo/Txt", "Text")
    this.uidata.txtGem = this.GetUIControl("Panel/Btns/BtnGem/Txt", "Text")
    this.uidata.tips = this.GetUIControl("Panel/Tips")
    this.uidata.tipNormal = this.BindUIControl("Panel/Tips/Normal", this.OnClickTip)
    this.uidata.tipSelect = this.GetUIControl("Panel/Tips/Select")
    this.uidata.txtTip = this.GetUIControl("Panel/Tips/Txt", "Text")
end

function Panel.InitEvent()
    --绑定UGUI事件
end

function Panel.OnShow(param)
    this.param = param or {}
    this.RefreshDisplay()
    this.InitListener()
    this.InitTimeFunc()
end

function Panel.RefreshDisplay()
    this.rewardItemList = List:New()

    SafeSetActive(this.uidata.title.gameObject, this.param.Title ~= nil)
    this.uidata.txtTitle.text = GetLang(this.param.Title and this.param.Title or "")

    SafeSetActive(this.uidata.comm.gameObject, this.param.Description ~= nil or this.param.DescriptionRaw ~= nil)
    this.uidata.txtDesc.text = this.param.DescriptionRaw and this.param.DescriptionRaw or
        GetLang(this.param.Description and this.param.Description or "")

    SafeSetActive(this.uidata.reward.gameObject,
        (this.param.Rewards ~= nil and next(this.param.Rewards) ~= nil) or
        (this.param.CardRewards ~= nil) and next(this.param.CardRewards) ~= nil)
    this.InitRewards()

    SafeSetActive(this.uidata.btnClose.gameObject, this.param.HideClose == nil)

    this.uidata.txtYes.text = GetLang(this.param.YesText and this.param.YesText or "ui_ok_btn")
    this.uidata.txtNo.text = GetLang(this.param.NoText and this.param.NoText or "ui_no_btn")
    this.uidata.txtGem.text = GetLang(this.param.GemButtonText and this.param.GemButtonText or "")
    SafeSetActive(this.uidata.btnYes.gameObject, this.param.ShowYes ~= nil)
    SafeSetActive(this.uidata.btnNo.gameObject, this.param.ShowNo ~= nil)
    SafeSetActive(this.uidata.btnGem.gameObject, this.param.ShowGemButton ~= nil)
    this.YesCallback = this.param.YesCallback
    this.NoCallback = this.param.NoCallback
    this.GemCallBack = this.param.OnCostFunc
    this.NoPlayEffect = this.param.NoPlayEffect

    SafeSetActive(this.uidata.need.gameObject, this.param.GemCost ~= nil)
    if this.param.GemButtonText then
        local gemMaxCount = DataManager.GetMaterialCount(this.cityId, ItemType.Gem)
        this.cityId = DataManager.GetCityId()
        if this.param.ShowGemMax then
            if this.param.GemCost > gemMaxCount then
                this.uidata.CostGemText.text = "<color=#e1423f>" ..
                    DataManager.GetMaterialCountFormat(this.cityId, ItemType.Gem) .. "</color> / " .. this.param.GemCost
            else
                this.uidata.CostGemText.text = "<color=#8ed740>" ..
                    DataManager.GetMaterialCountFormat(this.cityId, ItemType.Gem) .. "</color> / " .. this.param.GemCost
            end
        else
            this.uidata.CostGemText.text = this.param.GemCost
        end
        ForceRebuildLayoutImmediate(this.uidata.needItems)
    end

    SafeSetActive(this.uidata.tips.gameObject, this.param.ShowToggle ~= nil)
    if this.param.ShowToggle then
        this.toggleIsOn = this.param.ToggleDefault
        SafeSetActive(this.uidata.tipSelect.gameObject, this.toggleIsOn)
        this.uidata.txtTip.text = GetLang(this.param.ToggleText)
    end
end

function Panel.InitListener()
    SafeAddClickEvent(this.behaviour, this.uidata.btnYes.gameObject, this.OnClickYes)
    SafeAddClickEvent(this.behaviour, this.uidata.btnNo.gameObject, this.OnClickNo)
    SafeAddClickEvent(this.behaviour, this.uidata.btnGem.gameObject, this.OnClickGem)
end

function Panel.InitTimeFunc()
    if this.param.UpdateFunc ~= nil then
        local updateFunc = this.param.UpdateFunc
        -- 避免重复设置
        this.param.UpdateFunc = nil
        this.updateFuncUUID =
            setInterval(
                function()
                    if updateFunc(this.param) then
                        this.RefreshDisplay(this.param)
                    end
                end,
                1000
            )
    end

    if this.param.ClosePanelLeftTime ~= nil then
        this.closeLeftTimeUUID =
            setTimeout(
                function()
                    this.HideUI()
                end,
                this.param.ClosePanelLeftTime * 1000
            )
        -- 避免重复设置
        this.param.ClosePanelLeftTime = nil
    end
end

function Panel.InitRewards()
    this.rewardItemList = {}
    this.rewardItemDataList = {}
    this.rewardIndex = 0

    for i = 1, this.uidata.items.transform.childCount, 1 do
        SafeSetActive(this.uidata.items.transform:GetChild(i - 1).gameObject, false)
    end

    if this.param.Rewards then
        this.InitRewardItem(1)
    end
    if this.param.CardRewards then
        this.InitRewardItem(2)
    end
end

function Panel.InitRewardItem(type)
    local data = type == 1 and this.GetReward() or this.param.CardRewards
    
    for i, v in ipairs(data) do
        this.rewardIndex = this.rewardIndex + i
        local item = nil
        if this.rewardIndex >= this.uidata.items.transform.childCount then
            item = GOInstantiate(this.uidata.item, this.uidata.items.transform)
        else
            item = this.uidata.items.transform:GetChild(this.rewardIndex).gameObject
        end
        SafeSetActive(item.gameObject, true)

        local icon = item.transform:Find("ImgIcon"):GetComponent("Image")
        local txt = item.transform:Find("Txt"):GetComponent("Text")

        local itemId = v.id
        itemId = type == 2 and tonumber(itemId) or itemId
        local config = ConfigManager.GetItemConfig(itemId)
        if config == nil then
            config = ConfigManager.GetCardConfig(itemId)
            Utils.SetCardHeroIcon(icon, config.id)
        else
            Utils.SetItemIcon(icon, config.id)
        end
        txt.text = "x" .. Utils.FormatCount(v.count)
        this.rewardItemList[this.rewardIndex] = item
        this.rewardItemDataList[this.rewardIndex] = {
            id = itemId,
            count = v.count,
            addType = type == 1 and RewardAddType.Item or type == 2 and RewardAddType.Card or RewardAddType.OpenBox
        }
    end
end

function Panel.GetReward()
    local datas = {}
    for k, v in pairs(this.param.Rewards) do
        local data = Utils.ConvertAttachment2Rewards(k, v)
        table.insert(datas, data)
    end
    return datas
end

function Panel.HideUI()
    if this.updateFuncUUID ~= nil then
        clearInterval(this.updateFuncUUID)
    end

    if this.closeLeftTimeUUID ~= nil then
        clearTimeout(this.closeLeftTimeUUID)
    end

    if this.param.OnCloseFunc ~= nil then
        this.param.OnCloseFunc(this.toggleIsOn)
    end
    HideUI(UINames.UIMessageBox)
end

function Panel.OnClickTip()
    -- if this.Toggle == nil then
    --     return
    -- end
    this.toggleIsOn = not this.toggleIsOn
    SafeSetActive(this.uidata.tipSelect.gameObject, this.toggleIsOn)
end

--点击确认按钮
function Panel.OnClickYes()
    if this.YesCallback ~= nil then
        this.YesCallback(this.toggleIsOn)
    end
    this.HideUI()
end

--点击取消按钮
function Panel.OnClickNo()
    if this.NoCallback ~= nil then
        this.NoCallback(this.toggleIsOn)
    end
    this.HideUI()
end

--点击取消按钮
function Panel.OnClickGem()
    if this.GemCallBack ~= nil then
        if this.rewardItemList and not this.NoPlayEffect then
            for i, v in ipairs(this.rewardItemList) do
                ResAddEffectManager.AddResEffect(this.rewardItemList[i].gameObject.transform.position,
                    this.rewardItemDataList[i])
            end
        end
        this.GemCallBack(this.toggleIsOn)
    end
    this.HideUI()
end
