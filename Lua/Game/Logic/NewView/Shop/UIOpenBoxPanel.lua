---@class UIOpenBoxPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIOpenBoxPanel = Panel;

local UIOpenBoxState = {
    None = 0,  ---无状态
    Drop = 1,  ---掉落
    shake = 2, ---震动
    Wait = 3,  ---等待
    Play = 4,  ---执行效果中
    End = 5,   ---结束
    Open = 6   ---打开
}

local BoxType = {
    ["box_blue"] = 1,
    ["box_purple"] = 2,
    ["box_gold"] = 3
}

local ColorType = {
    ["blue"] = 1,
    ["purple"] = 2,
    ["gold"] = 3
}

local BgPath = {
    [0] = "hero_img_Card_green",
    [1] = "hero_img_Card_blue",
    [2] = "hero_img_Card_purple",
    [3] = "hero_img_Card_orange"
}

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();
    this.param = nil
end

function Panel.InitPanel()
    -- 绑定ui
    this.uidata = {}
    this.uidata.mask = this.BindUIControl("Mask", this.HideUI)
    this.uidata.txtDianNum = this.GetUIControl("Resource/TxtNum", "Text")
    this.uidata.txtClose = this.GetUIControl("Txt", "Text")
    this.uidata.imgBoxIcon = this.GetUIControl("Box/ImgBox", "Image")
    this.uidata.box = this.GetUIControl("Box/Box", "SkeletonGraphic")
    this.uidata.light = this.GetUIControl("Box/Light", "SkeletonGraphic")
    this.uidata.one = this.GetUIControl("One")
    this.uidata.item = this.GetUIControl(this.uidata.one, "Item", "CanvasGroup")
    this.uidata.imgItem = this.GetUIControl(this.uidata.item.gameObject, "ImgBg", "Image")
    this.uidata.txtItemNum = this.GetUIControl(this.uidata.item.gameObject, "TxtNum", "Text")
    this.uidata.imgItemBg = this.GetUIControl(this.uidata.item.gameObject, "ImgBg", "Image")
    this.uidata.itemInfo = this.GetUIControl(this.uidata.one, "Info", "CanvasGroup")
    this.uidata.imgInfoBg = this.GetUIControl(this.uidata.itemInfo.gameObject, "ImgBg", "Image")
    this.uidata.txtName = this.GetUIControl(this.uidata.itemInfo.gameObject, "TxtName", "Text")
    this.uidata.repertory = this.GetUIControl(this.uidata.itemInfo.gameObject, "Repertory")
    this.uidata.txtRepertory = this.GetUIControl(this.uidata.repertory, "Txt", "Text")
    this.uidata.txtType = this.GetUIControl(this.uidata.repertory, "TxtType", "Text")
    this.uidata.txtRepertoryNum = this.GetUIControl(this.uidata.repertory, "TxtNum", "Text")
    this.uidata.imgRepertory = this.GetUIControl(this.uidata.repertory, "ImgIcon", "Image")
    this.uidata.hero = this.GetUIControl(this.uidata.itemInfo.gameObject, "Hero")
    this.uidata.txtHero = this.GetUIControl(this.uidata.hero, "Txt", "Text")
    this.uidata.star = this.GetUIControl(this.uidata.hero, "StarContent")
    this.uidata.progressBg = this.GetUIControl(this.uidata.hero, "ProgressBg")
    this.uidata.bar1 = this.GetUIControl(this.uidata.progressBg, "ImgBar1")
    this.uidata.bar2 = this.GetUIControl(this.uidata.progressBg, "ImgBar2")
    this.uidata.txtNow = this.GetUIControl(this.uidata.progressBg, "TxtNow", "Text")
    this.uidata.txtNext = this.GetUIControl(this.uidata.progressBg, "TxtNext", "Text")
    this.uidata.txtNeed = this.GetUIControl(this.uidata.progressBg, "TxtNeed", "Text")
    this.uidata.txtJump = this.GetUIControl("TxtJump", "Text")
    this.uidata.btnJump = this.BindUIControl(this.uidata.txtJump.gameObject, "Btn", this.ShowAll)
    this.uidata.card = this.GetUIControl(this.uidata.one, "Card")
    this.uidata.txtCardNum = this.GetUIControl(this.uidata.card, "TxtNum", "Text")
    this.uidata.all = this.GetUIControl("All")
    this.uidata.items = this.GetUIControl(this.uidata.all, "Items")
    this.uidata.btnGet = this.BindUIControl(this.uidata.all, "BtnGet", this.HideUI)
    this.uidata.txtGet = this.GetUIControl(this.uidata.btnGet, "Txt", "Text")

    this.lightAnch = this.uidata.light.transform.anchoredPosition

    -- 调整顶部高度-与胶囊错开
    if PlayerModule.getSdkPlatform() == "wx" then
        this.GetUIControl("Resource").transform.anchoredPosition = Vector3(-105, -LuaFramework.AppConst.cutout - 20, 0)
        print("offset top: ", LuaFramework.AppConst.cutout)
    end
end

function Panel.InitEvent()
    -- 绑定UGUI事件
end

function Panel.OnShow(data)
    TutorialManager.isOpeningUIOpenBox = false
    -- 数据初始化
    this.data = data
    this.curIndex = nil
    this.cityId = DataManager.GetCityId()
    this.uidata.txtClose.text = GetLang("Box_tap_to_draw")
    this.uidata.txtJump.text = GetLang("Box_card_open_skip")
    this.uidata.txtGet.text = GetLang("Box_card_claim")
    this.uidata.txtDianNum.text = DataManager.GetMaterialCountFormat(this.cityId, ItemType.Gem)

    this.reward = {}
    if this.data.rewardsFromOpenBox ~= nil then
        this.reward = this.data.rewardsFromOpenBox
    else
        this.reward = BoxManager.GetBoxRewardV2(this.data.boxId, this.data.count, this.data.to, this.data.toId)
        this.reward = Utils.PressRewards(this.reward)
    end
    if this.reward ~= nil then
        this.state = UIOpenBoxState.None
    end

    ---宝箱掉落流程
    if this.dumpTween then
        this.dumpTween:Kill()
    end
    this.uidata.box.transform.parent.transform.anchoredPosition = Vector2(30.5, -487.5)
    SafeSetActive(this.uidata.txtClose.gameObject, true)
    this.uidata.box:Initialize(true)
    local entry = this.uidata.box.AnimationState:SetAnimation(0, this.GetAniByState(UIOpenBoxState.Drop), false)
    entry:AddOnComplete(function()
        this.timer = TimeModule.addRepeat(0, 1, function()
            Audio.PlayAudio(DefaultAudioID.BoxHuangdong)
        end, this.uidata.box)
        if this.state ~= UIOpenBoxState.Play then
            local entry = this.uidata.box.AnimationState:SetAnimation(0, this.GetAniByState(UIOpenBoxState.shake), true)
        end
    end)
    -- 显示初始化
    SafeSetActive(this.uidata.one, false)
    SafeSetActive(this.uidata.txtJump.gameObject, false)
    SafeSetActive(this.uidata.all, false)
end

function Panel.GetAniByState(state)
    state = state or this.state
    local boxId = this.data.boxId and this.data.boxId or "box_blue"
    local type = BoxType[boxId] or 3
    local aniType = 0
    if state == UIOpenBoxState.Drop then
        aniType = 1
    elseif state == UIOpenBoxState.shake then
        aniType = 2
    elseif state == UIOpenBoxState.Open then
        aniType = 3
    elseif state == UIOpenBoxState.Play then
        aniType = 4
    end

    return aniType == 0 and "" or string.format("%d_%d", type, aniType)
end

---一张一张卡显示
function Panel.StartOpen()
    if this.tween then
        this.card:Kill()
        this.info:Kill()
        this.tween:Kill()
    end
    if this.state == UIOpenBoxState.Play then
        this.state = UIOpenBoxState.Wait
        return
    end
    this.tween = DOTween.Sequence()
    this.card = DOTween.Sequence()
    this.info = DOTween.Sequence()
    local isFirst = this.curIndex == nil
    this.curIndex = isFirst and 0 or this.curIndex
    this.curIndex = this.curIndex + 1
    -- 如果已经开启过的话需要先将原先的卡牌信息渐隐
    local delayed = 0
    if not isFirst then
        delayed = 0.3
        this.tween:Append(Util.TweenTo(1, 0, delayed, function(v)
            this.uidata.item.alpha = v
            this.uidata.itemInfo.alpha = v
        end))
    end
    this.tween:AppendInterval(delayed)

    this.InitCardTween()
    this.tween:Append(this.card)

    this.InitInfoTween()
    this.info:OnComplete(function()
    end)
    this.tween:Join(this.info)
    if this.numTween then
        this.tween:Append(this.numTween)
    end

    this.tween:OnKill(function()
        if this.state == UIOpenBoxState.Play then
            this.uidata.item.alpha = 1
            this.uidata.itemInfo.alpha = 1
            this.uidata.txtCardNum.text = #this.reward - this.curIndex
            this.uidata.box.AnimationState:SetAnimation(0, this.GetAniByState(UIOpenBoxState.Play), true)
            this.uidata.light.transform.anchoredPosition = this.lightAnch + Vector2(0, 10000)
            this.uidata.card.transform.localScale = Vector3.one
            this.uidata.item.transform.anchoredPosition = Vector2(-150, this.uidata.item.transform.anchoredPosition.y)
            this.uidata.itemInfo.transform.anchoredPosition = Vector2(200,
                this.uidata.itemInfo.transform.anchoredPosition.y)
            this.InitInfoPanel(this.curIndex, true)
        end
    end)
    this.tween:OnComplete(function()
        this.state = UIOpenBoxState.Wait
    end)
    this.tween:Play()
    this.state = UIOpenBoxState.Play
end

function Panel.InitCardTween()
    -- 卡牌计数同时弹出【缩放效果 数量减少】
    this.card:OnStart(function()
        this.uidata.txtCardNum.text = #this.reward - this.curIndex + 1
    end)
    this.card:Append(Util.TweenTo(0, 0.5, 0.5, function(v)
        this.uidata.card.transform.localScale = Vector3(1, 1, 1) * (1 + v)
    end))
    this.card:InsertCallback(0.25, function()
        this.uidata.txtCardNum.text = #this.reward - this.curIndex
    end)
    this.card:Append(Util.TweenTo(0.5, 0, 0.5, function(v)
        this.uidata.card.transform.localScale = Vector3(1, 1, 1) * (1 + v)
    end))
end

function Panel.InitInfoTween()
    -- 卡牌信息弹出【卡牌光效 卡牌左移信息右移回弹效果】【卡牌进度计数数字滚动变化 进度条增长变化】
    local itemStart = this.uidata.item.transform.anchoredPosition
    local infoStart = this.uidata.itemInfo.transform.anchoredPosition
    this.info:OnStart(function()
        Audio.PlayAudio(DefaultAudioID.jiangliTanChu)
        local box = this.uidata.box.AnimationState:SetAnimation(0, this.GetAniByState(UIOpenBoxState.Open), false)
        box:AddOnComplete(function()
            this.uidata.box.AnimationState:SetAnimation(0, this.GetAniByState(UIOpenBoxState.Play), true)
        end)
        this.uidata.light.transform.anchoredPosition = this.lightAnch
        SafeSetActive(this.uidata.light.gameObject, true)
        local light = this.uidata.light.AnimationState:SetAnimation(0, "4", false)
        light:AddOnComplete(function()
            this.uidata.light.transform.anchoredPosition = this.lightAnch + Vector2(0, 10000)
        end)

        SafeSetActive(this.uidata.one.gameObject, true)
        SafeSetActive(this.uidata.txtJump.gameObject, true)
        this.uidata.item.alpha = 0
        this.uidata.itemInfo.alpha = 0

        this.uidata.item.transform.anchoredPosition = Vector2(0, itemStart.y)
        this.uidata.itemInfo.transform.anchoredPosition = Vector2(0, infoStart.y)

        this.InitInfoPanel(this.curIndex)
    end)
    this.info:AppendInterval(1.4)
    this.info:Append(Util.TweenTo(0, 1, 0.5, function(v)
        this.uidata.item.alpha = v
    end))
    this.info:AppendInterval(2.6)
    this.info:Append(Util.TweenTo(0, 1, 1, function(v)
        this.uidata.item.transform.anchoredPosition = Vector2(-150 * v, itemStart.y)
        this.uidata.itemInfo.transform.anchoredPosition = Vector2(200 * v, infoStart.y)
        if v > 0.5 then
            this.uidata.itemInfo.alpha = v
        end
    end))
    -- this.info:AppendInterval(0.2)
    -- this.info:Join(Util.TweenTo(0, 1, 1, function(v)
    --     this.uidata.itemInfo.alpha = v
    -- end))
end

function Panel.InitInfoPanel(curIndex, isKill)
    local data = this.reward[this.curIndex]
    local state = (data.addType == RewardAddType.Item or data.addType == RewardAddType.OverTime or data.addType ==
        RewardAddType.DailyItem) and 1 or data.addType == RewardAddType.Card and 2 or 3
    local config = state == 1 and ConfigManager.GetItemConfig(data.id) or state == 2 and
        ConfigManager.GetCardConfig(data.id) or nil
    local bg = state == 1 and 0 or ColorType[config.color]
    SafeSetActive(this.uidata.hero.gameObject, state == 2)
    SafeSetActive(this.uidata.repertory.gameObject, state == 1)
    this.SetImage(this.uidata.imgItem, BgPath[bg])

    if state == 1 then
        this.uidata.txtType.text = GetLang("ui_open_box_resource")
        this.uidata.txtRepertory.text = GetLang("UI_Resources_Stock")
        this.SetImage(this.uidata.imgRepertory, config.icon)
        this.uidata.txtName.text = GetLang(config.name_key)
        this.uidata.txtRepertoryNum.text = DataManager.GetMaterialCountFormat(this.cityId, config.id)
    elseif state == 2 then
        this.uidata.txtName.text = GetLang(config.name)
        this.uidata.txtHero.text = GetLang(config.color_lang)
        -- 紫色史诗#a577c8 蓝色稀有#5c8cbf
        this.uidata.txtHero.color = config.color == "purple" and CreateColorFromHex(165, 119, 200) or
            CreateColorFromHex(92, 140, 191)
        if this.starItem == nil then
            this.starItem = StarItem.new()
            this.starItem:InitPanel(this.behaviour, this.uidata.star)
        end
        local cardItemData = CardManager.GetCardItemData(data.id)
        local starLevel = cardItemData:GetStarLevel()
        this.starItem:SetStarLevel(starLevel)
        local num = cardItemData:GetCardCount()
        local need = cardItemData:GetEatCardCount()
        this.uidata.txtNext.text = num
        this.uidata.txtNow.text = num - 1
        this.uidata.txtNeed.text = "/" .. need
        local progress = (num - 1) / need
        progress = progress > 1 and 1 or progress
        this.uidata.bar1.transform.sizeDelta = Vector2(progress * 172, 25)

        local startNow = Vector2(-8, -1.1)
        local startNext = Vector2(-8, -31.1)
        if this.numTween == nil then
            this.numTween = DOTween.Sequence()
        end
        this.numTween:Append(Util.TweenTo(0, 1, 0.5, function(v)
            local p = (num - 1 + v) / need
            this.uidata.bar1.transform.sizeDelta = Vector2(p * 172, 25)
            this.uidata.txtNow.transform.anchoredPosition = startNow + Vector2(0, v * 30)
            this.uidata.txtNext.transform.anchoredPosition = startNext + Vector2(0, v * 30)
        end))

        if not isKill then
            if cardItemData == nil or (cardItemData.cardData.count == 0 and cardItemData.cardData.level == 1) then
                ShowUI(UINames.UINewHero, {
                    cardId = data.id,
                })
            end
        end
    end

    this.RefreshItem(this.uidata.item, curIndex)
end

---显示所有奖励
function Panel.ShowAll()
    Audio.PlayAudio(DefaultAudioID.jianglizhanshi)
    if this.tween then
        this.tween:Kill()
        ---文字隐藏
        SafeSetActive(this.uidata.txtClose.gameObject, false)
        SafeSetActive(this.uidata.light.gameObject, false)
        ---宝箱下落
        this.dumpTween = Util.TweenTo(0, 1, 2, function(v)
            if isNil(this.uidata.box) == false then 
                this.uidata.box.transform.parent.transform.anchoredPosition = this.uidata.box.transform.parent.transform
                    .anchoredPosition + Vector2(0, -1000) * v
            end
        end)
    end
    SafeSetActive(this.uidata.one, false)
    SafeSetActive(this.uidata.txtJump.gameObject, false)
    SafeSetActive(this.uidata.all, true)
    for i = 1, this.uidata.items.transform.childCount do
        local go = this.uidata.items.transform:GetChild(i - 1).gameObject
        SafeSetActive(go, false)
    end
    local tween = DOTween.Sequence()
    for i, v in ipairs(this.reward) do
        local item = this.InitItem(i)
        local canvasGroup = item.transform:GetComponent("CanvasGroup")
        canvasGroup.alpha = 0
        tween:Insert(i * 0.1, Util.TweenTo(0, 1, 1, function(v)
            if isNil(canvasGroup) == false then 
                canvasGroup.alpha = v
            end
        end))
    end
    tween:Play()
    this.state = UIOpenBoxState.End
end

---单个奖励的格子
function Panel.InitItem(i)
    local go = this.uidata.items.transform:GetChild(0).gameObject
    local item = nil
    local count = this.uidata.items.transform.childCount
    if i >= count then
        item = GOInstantiate(go, this.uidata.items.transform)
    else
        item = this.uidata.items.transform:GetChild(i).gameObject
    end
    SafeSetActive(item, true)
    this.RefreshItem(item, i)
    return item
end

---刷新单个奖励的显示
function Panel.RefreshItem(item, i)
    -- Audio.PlayAudio(DefaultAudioID.jiangliTanChu)
    local data = this.reward[i]

    local state = (data.addType == RewardAddType.Item or data.addType == RewardAddType.OverTime or data.addType ==
        RewardAddType.DailyItem) and 1 or data.addType == RewardAddType.Card and 2 or 3

    local config = state == 1 and ConfigManager.GetItemConfig(data.id) or state == 2 and
        ConfigManager.GetCardConfig(data.id) or nil

    local bg = state == 1 and 0 or ColorType[config.color]
    local prop = item.transform:Find("Prop")
    local hero = item.transform:Find("Hero")
    local imgBg = item.transform:Find("ImgBg"):GetComponent("Image")
    local parent = state == 1 and prop or state == 2 and hero or nil
    SafeSetActive(prop.gameObject, state == 1)
    SafeSetActive(hero.gameObject, state == 2)
    this.SetImage(imgBg, BgPath[bg])

    local imgBg = item.transform:Find("ImgBg"):GetComponent("Image")
    local imgIcon = parent.transform:Find("ImgIcon"):GetComponent("Image")
    local txtNum = item.transform:Find("TxtNum"):GetComponent("Text")
    this.SetImage(imgIcon, state == 2 and "hero_head_" .. config.id or config.icon)
    if config.color then
        this.SetImage(imgBg, this.GetCardRareText(config.color))
    end
    if state == 2 then
        local buildType = parent.transform:Find("ImgBuildType"):GetComponent("Image")
        local occupationIcon = parent.transform:Find("ImgOccupationIcon"):GetComponent("Image")
        local typeIcon = parent.transform:Find("ImgType"):GetComponent("Image")

        Utils.SetIconItem(buildType, config.zone_type_icon)

        Utils.SetCardIcon(occupationIcon, "hero_" .. config.occupation)
        Utils.SetCardIcon(typeIcon, "card_main_type_" .. config.type)
    end
    txtNum.text = data.count
end

function Panel.GetCardRareText(str)
    if str == "blue" then
        return GetLang("ui_card_color_blue")
    elseif str == "purple" then
        return GetLang("ui_card_color_purple")
    elseif str == "orange" then
        return GetLang("ui_card_color_orange")
    else
        return GetLang("ui_card_color_blue")
    end
end

function Panel.CheckHasBoxRewards(reward)
    local hasId = {}
    self.boxIdList = {}
    for i = 1, #reward do
        if hasId[reward[i].originId] == nil then
            table.insert(self.boxIdList, reward[i].originId)
            hasId[reward[i].originId] = true
        end
    end
end

function Panel.HideUI()
    TimeModule.removeTimer(this.timer)
    this.timer = nil
    if this.state == UIOpenBoxState.None then
        Audio.PlayAudio(DefaultAudioID.openBox)
        this.StartOpen()
    elseif this.state == UIOpenBoxState.Play then
        this.StartOpen()
        return
    elseif this.state == UIOpenBoxState.Wait then
        if this.curIndex >= #this.reward then
            this.ShowAll()
        else
            this.StartOpen()
            Audio.PlayAudio(DefaultAudioID.openBox)
        end
        
    elseif this.state == UIOpenBoxState.End then
        this.starItem = nil
        HideUI(UINames.UIOpenBox)
        if this.data.onClose ~= nil then 
            this.data.onClose();
        end
    else
        return
    end
end
