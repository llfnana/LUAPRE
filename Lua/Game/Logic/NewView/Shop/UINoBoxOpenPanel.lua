---@class UINoBoxOpenPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UINoBoxOpenPanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.uidata.mask = this.BindUIControl("Mask", this.OnOverlayClick)
    this.uidata.title = this.GetUIControl("Title")
    this.uidata.txtTitle = this.GetUIControl(this.uidata.title, "Txt", "Text")
    this.uidata.scrollRect = this.GetUIControl("Scroll View")
    this.uidata.props = this.GetUIControl("Scroll View/Viewport/Content")

    this.uidata.prop = this.GetUIControl(this.uidata.props, "Item")

    this.items = nil
end

function Panel.InitEvent()
    --绑定UGUI事件
end

function Panel.OnShow(data)
    this.data = data
    this.itemHasShown = 0
    local rewardMap, rewardsFromOpenBox = Utils.SplitBoxRewards(this.data.rewardMap)
    this.rewardMap = rewardMap
    this.data.rewardsFromOpenBox = rewardsFromOpenBox
    this.title = this.data.title or GetLang("ui_shop_timeskip_get_resource")
    this.onCloseFunc = this.data.onCloseFunc
    this.hideFlying = this.data.hideFlying
    this.isShop = this.data.isShop
    this.eventSign = this.data.eventSign
    this.delayList = this.data.delayList
    this.items = {}

    this.uidata.title.gameObject:SetActive(this.title ~= nil)
    if this.title ~= nil then
        this.uidata.txtTitle.text = this.title
    end

    this.totalRes = {}
    if this.HasBoxReward(this.data) then
        for i = 1, (#this.data.rewardsFromOpenBox) do
            table.insert(this.totalRes, this.data.rewardsFromOpenBox[i])
        end
    end
    for i = 1, (#this.rewardMap) do
        table.insert(this.totalRes, this.rewardMap[i])
    end

    local childCount = this.uidata.props.transform.childCount
    for i = 1, childCount do
        local go = this.uidata.props.transform:GetChild(i - 1).gameObject
        SafeSetActive(go, false)
    end

    for i = 1, #this.totalRes do
        local item = this.InitItem(i, childCount)
        table.insert(this.items, item)
    end

    ForceRebuildLayoutImmediate(this.uidata.props.gameObject)

    if this.HasBoxReward(this.data) then
        setTimeout(
            function()
                this.ShowOpenBoxPanel(this.data.rewardsFromOpenBox)
            end,
            0
        )
        this.showOpenBoxPanel = true
    else
        this.OnAnimEvent()
    end

    -- GridLayoutGroup 没有加到 Wrapper，这里直接写死数字
    local line = math.ceil(#this.totalRes / 4)
    local height = line * 172 + (line - 1) * 33 + 12
    height = math.min(height, 888)
    this.uidata.scrollRect:GetComponent(typeof(UnityEngine.RectTransform)).sizeDelta = Vector2.New(630, height)
end

function Panel.InitItem(index, childCount)
    local reward = this.totalRes[index]
    local item = nil
    
    if index <= childCount then 
        item = this.uidata.props.transform:GetChild(index - 1).gameObject
    else 
        item = GOInstantiate(this.uidata.prop, this.uidata.props.transform)
    end
    SafeSetActive(item, true)

    local icon = item.transform:Find("ImgIcon"):GetComponent("Image")
    local num = item.transform:Find("TxtNum"):GetComponent("Text")

    Utils.SetRewardIcon4(reward, icon, nil, num, "+", true)

    return item
end

function Panel.HideUI()
    this.OnDestroyPanel()
    HideUI(UINames.UINoBoxOpen)
end

function Panel.HasBoxReward(data)
    return data.rewardsFromOpenBox ~= nil and #data.rewardsFromOpenBox > 0
end

function Panel.ShowOpenBoxPanel(rewards)
    -- this.OpenSubPanel(PanelType.OpenBoxPanel,
    --     {
    --         rewardsFromOpenBox = rewards,
    --         reOpen = nil,
    --         onClose = nil,
    --     })
    ShowUI(UINames.UIOpenBox, {
        rewardsFromOpenBox = rewards,
        reOpen = nil,
        onClose = nil,
    })
end

function Panel.OnOverlayClick()
    -- if this.itemHasShown >= #this.items then
    this.HideUI()
    -- end
end

function Panel.CheckHasNewCard()
    local hasNext = this.CheckHasNewCardShowing()
    if not hasNext then
        this.TimerClosePanel()
    end
end

function Panel.CheckHasNewCardShowing()
    if #this.newCard > 0 then
        local id = table.remove(this.newCard, 1)
        this.OpenSubPanel(PanelType.NewCardShowPanel, { cardId = id })
        return true
    end
    return false
end

function Panel.TimerClosePanel()
    this.hasNoNewCard = true
    local autoCloseSec = ConfigManager.GetMiscConfig("reward_panel_auto_close_sec") or 3
    this.autoCloseTimeout =
        setTimeout(
            function()
                this.autoCloseTimeout = nil
                this.ClosePanel()
            end,
            autoCloseSec * 1000
        )
end

function Panel.OnDestroyPanel()
    if (this.autoCloseTimeout ~= nil) then
        clearTimeout(this.autoCloseTimeout)
        this.autoCloseTimeout = nil
    end
    local sign = { realNum = 0 }
    for i = 1, #this.totalRes do
        if this.hideFlying then
            if this.isShop then
                if this.totalRes[i].addType == RewardAddType.Item and this.totalRes[i].id == "Gem" then
                    ResAddEffectManager.ResAddFlyingCollect(this.items[i].transform.position, this.totalRes[i], nil
                        , this.checkRealNum(sign),
                        function()
                            ResAddEffectManager.CostDelayView(this.delayList[i])
                        end)
                end
            end
        else
            ResAddEffectManager.ResAddFlyingCollect(this.items[i].transform.position, this.totalRes[i], nil,
                this.checkRealNum(sign),
                function()
                    ResAddEffectManager.CostDelayView(this.delayList[i])
                end)
        end
    end
    if sign.realNum == 0 then
        EventManager.Brocast(EventType.EFFECT_RES_ADD_COMPLETE, this.eventSign)
    end
    -- this.rewardContentUp.gameObject:SetActive(false)
    if this.onCloseFunc ~= nil then
        this.onCloseFunc()
    end
end

function Panel.checkRealNum(sign)
    sign.realNum = sign.realNum + 1
    if sign.realNum == 1 then
        return this.eventSign
    end
    return nil
end

function Panel.CheckShowNewCard()
    this.newCard = Utils.CheckNewCard(this.rewardMap)
end

function Panel.OnAnimEvent()
    local onFlyEnter = function(index)
        SafeSetActive(this.items[index], true)
        this.itemHasShown = this.itemHasShown + 1
    end
    for i = 1, #this.items do
        setTimeout(
            function()
                -- AudioManager.PlayEffect("ui_milestone_reward_show")
                onFlyEnter(i)
            end,
            (i) * 100
        )
    end
    -- setTimeout(
    --     function()
    --         this.CheckShowNewCard()
    --         this.CheckHasNewCard()
    --     end,
    --     (#this.itemAward + 2) * 100
    -- )
end
