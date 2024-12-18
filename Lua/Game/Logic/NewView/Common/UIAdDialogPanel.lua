---@class UIAdDialogPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIAdDialogPanel = Panel;

function Panel.OnAwake()
    this.cachedata = {}
    this.InitPanel()
    this.InitEvent()

    this.param = nil
end

function Panel.InitPanel()
    this.uidata = {}

    this.uidata.textDialog = SafeGetUIControl(this, "Layout/TextDialog")
    this.uidata.textBtnClose = SafeGetUIControl(this, "Layout/TextDialog/BtnClose", "Button")
    this.uidata.textBtnNo = SafeGetUIControl(this, "Layout/TextDialog/BtnNo", "Button")
    this.uidata.textBtnYes = SafeGetUIControl(this, "Layout/TextDialog/BtnYes", "Button")
    this.uidata.textContent = SafeGetUIControl(this, "Layout/TextDialog/TxtContent", "Text")

    this.uidata.itemDialog = SafeGetUIControl(this, "Layout/ItemDialog")
    this.uidata.itemBtnClose = SafeGetUIControl(this, "Layout/ItemDialog/BtnClose", "Button")
    this.uidata.itemBtnWatch = SafeGetUIControl(this, "Layout/ItemDialog/BtnWatch", "Button")
    this.uidata.itemIcon = SafeGetUIControl(this, "Layout/ItemDialog/RewardIcon", "Image")
    this.uidata.itemNum = SafeGetUIControl(this, "Layout/ItemDialog/RewardText", "Text")

    this.uidata.jump = SafeGetUIControl(this, "Layout/Jump")
    this.uidata.jumpBtnGet = SafeGetUIControl(this, "Layout/Jump/BtnGet", "Button")
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.textBtnClose.gameObject, this.Cancel)
    SafeAddClickEvent(this.behaviour, this.uidata.itemBtnClose.gameObject, this.Cancel)

    SafeAddClickEvent(this.behaviour, this.uidata.textBtnNo.gameObject, this.Cancel)
    SafeAddClickEvent(this.behaviour, this.uidata.textBtnYes.gameObject, this.OnClickWatch)

    SafeAddClickEvent(this.behaviour, this.uidata.itemBtnWatch.gameObject, this.OnClickWatch)

    SafeAddClickEvent(this.behaviour, this.uidata.jumpBtnGet.gameObject, function ()
        local InitPackageList = function(configList)
            local packageList = {}
            for i = 1, #configList do
                table.insert(packageList, ConfigManager.GetShopPackage(configList[i].id))
            end
            return packageList
        end

        local configList = this.GetAdPrivilegeConfig()
        local config = configList[1]
        local packageList = InitPackageList(configList)
        -- 显示特权界面
        ShowUI(UINames.UISubscription,
        {
            configList = configList,
            packageList = packageList,
            buyFunc = function(cfg, cb, disableRewardsShow)
                -- 是否是首充双倍，要在购买前获取
                ShopManager.BuyWithDiamondConfirm(
                    DataManager.GetCityId(),
                    cfg,
                    function(rewards)
                        if PaymentManager.IsPurchaseByPackageId(cfg.id) then
                            UIUtil.showText(GetLang("toast_purchase_successed"))
                        end
    
                        if disableRewardsShow ~= true and #rewards > 0 then
                            ResAddEffectManager.AddResEffectFromRewards(
                                rewards,
                                true,
                                { hideFlying = true, isShop = true, eventSign = { shopId = config.id } }
                            )
                        end

                        -- 返回上层回调
                        if cb ~= nil then
                            cb()
                        end

                        this.UpdateView()
                    end,
                    function(errCode)
                    end
                )
            end,
            showRestoreButton = true,
        })
    end)
end

-- param: {sourceType, onReceive, }
function Panel.OnShow(param)
    this.param = param
    UIUtil.openPanelAction(this.gameObject)
    this.UpdateView()
end

-- 观看广告
function Panel.OnClickWatch()
    if AdManager.CheckMaxWatch() then 
        this.Cancel()
        return
    end
    
    local watchCount, maxCount, remainCount = AdManager.GetCount(this.param.sourceType)

    -- 当日观看广告达到上限
    if remainCount == 0 then 
        ShowTips(GetLang("ad_day_limit_tip1"))
        this.Cancel()
        return
    end

    print("zhkxin 观看广告", (ShopManager.IsFreeAd() and "有特权" or "无特权"))
    if ShopManager.IsFreeAd() then
        if this.param and this.param.onReceive then 
            this.param.onReceive()
        end
        -- 弹出奖励
        this.HideUI()
    else 
        AdManager.Show(function()
            if this.param and this.param.onReceive then 
                this.param.onReceive()
            end
            -- 弹出奖励
            this.HideUI()
        end)
    end
end

-- 点击取消
function Panel.Cancel()
    if this.param and this.param.onCancel then 
        this.param.onCancel(false)
    end
    this.HideUI()
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UIAdDialog)
    end)
end


function Panel.UpdateView()
    local _, reward = AdManager.GetMaxCountAndRewardFromConfig(this.param.sourceType)
    local isTextDialog = type(reward) == "number"
    this.uidata.textDialog:SetActive(isTextDialog)
    this.uidata.itemDialog:SetActive(isTextDialog == false)
    if this.param.sourceType == AdSourceType.UIOffline then 
        local minute = reward / 60
        this.uidata.textContent.text = GetLang("ad_offline_info", minute)
    elseif this.param.sourceType == AdSourceType.UIOfflineReward then
        local hour = reward / 3600
        this.uidata.textContent.text = GetLang("ad_assist_info", hour)
    elseif this.param.sourceType == AdSourceType.UIBuildFoold then 
        local reward = Utils.ParseReward(reward)
        Utils.SetItemIcon(this.uidata.itemIcon, reward[1].id, false, true)
        local itemConfig = ConfigManager.GetItemConfig(reward[1].id)
        local name = GetLang(itemConfig.name_key)
        this.uidata.itemNum.text =  name .. " +" .. reward[1].count
    end

    --商城是否解锁
    local isOpen = FunctionsManager.IsUnlock(FunctionsType.Shop)
    if isOpen then 
        -- 获取特权
        local configList = this.GetAdPrivilegeConfig()
        local isPrivilege = ShopManager.CheckSubscriptionCanClaim(configList)
        this.uidata.jump:SetActive(isPrivilege == false)
    else 
        this.uidata.jump:SetActive(false)
    end
end

-- 获取广告特权配表
function Panel.GetAdPrivilegeConfig()
    local list = ShopManager.GetAvailableItems(DataManager.GetCityId(), ShopManager.ShopItemType.Subscription)
    list = ShopManager.ConvAvailableItems2Group(list)
    return list[2]
end
