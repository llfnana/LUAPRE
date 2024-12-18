ResAddEffectManager = {}
ResAddEffectManager.__cname = "ResAddEffectManager"
local this = ResAddEffectManager

function ResAddEffectManager.Init()
    this.cityId = DataManager.GetCityId()
    this.itemList = List:New()
    this.timeoutIdList = List:New()
    this.CurvePool = {}
    this.ItemCollectTarget = {}
    this.DelayCountList = {}
    this.delayId = 0
end

function ResAddEffectManager.InitView(viewContent)
    this.viewContent = viewContent
end

function ResAddEffectManager.StartCollectTweenUI(tran, path, callback, targetpos, rotate, eventSign)
    local pos = this.GetCameraWorldToScreenPoint(targetpos)
    rotate = rotate and -1 or 1
    targetpos = targetpos or { 0, 0, 0 }
    local start = tran.transform.anchoredPosition
    local offx = pos.x - start.x
    local offy = pos.y + start.y
    tran.transform:DOMove(targetpos, 0.45):SetEase(Ease.InSine):OnComplete(function()
        if isNil(tran) == false then 
            SafeSetActive(tran.gameObject, false)
        end
    end)

    setTimeout(
        function()
            if callback then
                callback()
            end
            EventManager.Brocast(EventType.EFFECT_RES_ADD_COMPLETE, eventSign)
        end,
        500
    )
    -- return max
end

function ResAddEffectManager.GetCameraWorldToScreenPoint(position)
    local pos = RectTransformUtility.WorldToScreenPoint(PanelManager:GetUICamera(), position)

    -- pos.x = pos.x * Screen.widthRatio
    -- pos.y = pos.y * Screen.heightRatio
    return pos
end

function ResAddEffectManager.StartCollectTween(tran, path, callback, targetpos, rotate, isLocal)
    local obj = this.GetFlyCurve(path)
    if not obj then
        return
    end
    rotate = rotate and -1 or 1
    targetpos = targetpos or { 0, 0, 0 }
    isLocal = isLocal or false
    local max =
        CS.FrozenCity.Utils.StartTweenByDTParamsCollection(
            tran,
            obj,
            targetpos.x,
            targetpos.y,
            targetpos.z,
            rotate,
            isLocal
        )
    Log("flying target (" .. targetpos.x .. "," .. targetpos.y .. "," .. targetpos.z .. ") max" .. max)
    if callback then
        setTimeout(callback, max * 1000)
    end
    return max
end

function ResAddEffectManager.GetFlyCurve(path)
    Log("Get Fly Curve " .. path .. " " .. tostring(this.CurvePool[path]))
    if this.CurvePool[path] then
        return this.CurvePool[path]
    end
    local go = ResourceManager.Instantiate(path)
    this.CurvePool[path] = go
    return go
end

function ResAddEffectManager.AddClickEffectOnScreen(posScreen)
    if this.viewContent == nil then
        return
    end
    local view = ResourceManager.Instantiate("ui/Component/ClickEffect", this.viewContent)
    local pos = {}
    pos.x = -AppScreen.Width / 2 + posScreen.x * AppScreen.WidthRatio
    pos.y = -AppScreen.Height / 2 + posScreen.y * AppScreen.HeightRatio
    view.transform.anchoredPosition = Vector2(pos.x, pos.y)
    local lastTip = { timeoutId = 0 }
    lastTip.timeoutId =
        setTimeout(
            function()
                ResourceManager.Destroy(view)
                this.timeoutIdList:Remove(lastTip)
            end,
            2000
        )
    this.timeoutIdList:Add(lastTip)
end

function ResAddEffectManager.ResAddFlyingClaim(startPos, targetPos, data, callback, rotate, path, hideEff, eventSign)
    if UIResAddPanel == nil or UIResAddPanel.uidata == nil then
        ShowUI(UINames.UIResAdd, {
            state = 2,
            startPos = startPos,
            targetPos = targetPos,
            data = data,
            callback = callback,
            rotate = rotate,
            path = path,
            hideEff = hideEff,
            eventSign = eventSign
        })
    else
        SafeSetActive(UIResAddPanel.gameObject, true)
        UIResAddPanel.AddFlyingClaim(startPos, targetPos, data, callback, rotate, path, hideEff, eventSign)
    end
    -- local view = ResourceManager.Instantiate("ui/FlyingBoxItem", this.viewContent)
    -- local rewardItem = FlyingBoxItem:Create(view)
    -- rewardItem:OnInit(data)
    -- if (hideEff) then
    --     rewardItem:HideEff()
    -- end
    -- if targetPos == nil then
    --     targetPos = Vector3(0, 0, 0)
    -- end
    -- local pos = Utils.GetCameraWorldToScreenPoint(startPos)
    -- pos.x = -Screen.Width / 2 + pos.x
    -- pos.y = -Screen.Height / 2 + pos.y
    -- targetPos.z = 0
    -- view.transform.anchoredPosition = Vector2(pos.x, pos.y)
    -- view.transform.localScale = Vector3(1, 1, 1)
    -- if path == nil then
    --     path = "ui/Animation/DT_ItemFromBox"
    -- end
    -- this.StartCollectTweenUI(
    --     view.transform,
    --     path,
    --     function()
    --         rewardItem:HideIcon()
    --         callback()
    --     end,
    --     targetPos,
    --     rotate,
    --     eventSign
    -- )
end

function ResAddEffectManager.ResAddFlyingCollect(startPos, data, rotate, eventSign, callback)
    local targetPos = this.GetItemCollectTarget(data)
    local vec3 = Vector3(startPos.x, startPos.y, startPos.z)
    this.ResAddFlyingClaim(
        vec3,
        targetPos,
        data,
        function()
            if callback ~= nil then
                callback()
            end
        end,
        rotate,
        "ui/Animation/DT_ItemToEnd",
        false,
        eventSign
    )
    -- setTimeout(
    --     function()
    --         this.ResAddFlyingClaim(vec3, targetPos, itemId, count, nil, rotate)
    --     end,
    --     1000
    -- )
end

function ResAddEffectManager.GetItemCollectTarget(reward)
    if reward.addType == RewardAddType.Card then
        return this.ItemCollectTarget["Card"]
    elseif reward.addType == RewardAddType.Box then
        return this.ItemCollectTarget["Box"]
    elseif reward.addType == RewardAddType.Item then
        local itemId = reward.id
        local itemType = ConfigManager.GetItemConfig(itemId).item_type
        if (this.UseFireResource() and itemId == GeneratorManager.GetConsumptionItemId(DataManager.GetCityId())) then
            if this.ItemCollectTarget["FireResource"] == nil then
                return UIMainPanel.uidata.statistics.transform.position
            end
            return this.ItemCollectTarget["FireResource"]
        elseif (this.ItemCollectTarget[itemType] ~= nil) then
            return this.ItemCollectTarget[itemType]
        else
            return UIMainPanel.uidata.statistics.transform.position
        end
    else
        return UIMainPanel.uidata.statistics.transform.position
    end
end

function ResAddEffectManager.UseFireResource()
    --TODO:考察燃料为空时的
    return not CityManager.GetIsEventScene(DataManager.GetCityId())
end

function ResAddEffectManager.SetItemCollectTarget(type, pos)
    if this.ItemCollectTarget == nil then
        this.ItemCollectTarget = {}
    end
    if pos then
        this.ItemCollectTarget[type] = pos
    else
        this.ItemCollectTarget[type] = nil
    end
end

function ResAddEffectManager.AddResEffect(pos, data, isLocal, eventSign)
    Audio.PlayAudio(DefaultAudioID.UIResAdd) --获得奖励
    if UIResAddPanel.uidata == nil then
        ShowUI(UINames.UIResAdd, {
            state = 1,
            pos = pos,
            data = data,
            isLocal = isLocal,
            eventSign = eventSign
        })
    else
        UIResAddPanel.AddItem(pos, data, isLocal, eventSign)
    end
end

function ResAddEffectManager.AddResEffects(poss, datas, isLocal, eventSign, callback)
    Audio.PlayAudio(DefaultAudioID.UIResAdd) --获得奖励
    if UIResAddPanel.uidata == nil then
        ShowUI(UINames.UIResAdd, {
            state = 1,
            pos = poss,
            data = datas,
            isLocal = isLocal,
            eventSign = eventSign,
            callback = callback,
        })
    else
        UIResAddPanel.AddItem(poss, datas, isLocal, eventSign, callback)
    end
end

function ResAddEffectManager.AddResEffectFromRewardStr(rewardStr, useBoard, boardConfig)
    local rewards = Utils.ParseReward(rewardStr)
    this.AddResEffectFromRewards(rewards, useBoard, boardConfig)
end

-- function ResAddEffectManager.AddResEffectFromRewards(rewards)
--     local attachment = Utils.ConvertRewards2Attachment(rewards)
--     this.AddResEffectFromMailClaim(attachment)
-- end

--在boardConfig中加入eventSign来发送事件标记
function ResAddEffectManager.AddResEffectFromRewards(rewards, useBoard, boardConfig)
    if rewards == nil then 
        return error("zhkxin", debug.traceback())
    end
    local normalReward, rewardFromBox = Utils.SplitBoxRewards(rewards)
    if rewardFromBox ~= nil and #rewardFromBox > 0 then
        useBoard = true
    end

    if useBoard then
        if boardConfig == nil then
            boardConfig = {}
        end
        boardConfig.rewardMap = rewards

        local openLast = false
        if boardConfig.openLast ~= nil then
            openLast = boardConfig.openLast
        end

        -- local openFunc = PopupManager.Instance.OpenPanel
        -- if openLast then
        --     openFunc = PopupManager.Instance.LastOpenPanel
        -- end

        if #normalReward == 0 and #rewardFromBox > 0 then
            ShowUI(UINames.UIOpenBox, {
                rewardsFromOpenBox = rewardFromBox,
                reOpen = nil,
                onClose = boardConfig.onCloseFunc
            })
        else
            local delayList = {}

            for i = 1, #rewards do
                local isShop = boardConfig.isShop
                local willFly = false
                if isShop then
                    willFly = rewards[i].addType == RewardAddType.Item and rewards[i].id == ItemType.Gem
                else
                    willFly = (not boardConfig.hideFlying) and rewards[i].addType == RewardAddType.Item
                end
                if willFly then
                    local id = this.AddDelayView(rewards[i])
                    delayList[i] = id
                end
            end

            boardConfig.delayList = delayList

            ShowUI(UINames.UINoBoxOpen, boardConfig)
        end
        return
    end

    local awardNum = 0
    local rowNum = 0
    local lineNum = 0
    local paddingWidth = 200
    local paddingHeight = 300
    local rowDefault = 5
    awardNum = #rewards
    if awardNum > rowDefault then
        rowNum = rowDefault
        lineNum = math.floor(awardNum / rowNum) + 1
    else
        rowNum = awardNum
        lineNum = 1
    end
    local index = 0
    local realNum = 0
    local poss = {}
    for i = 1, #rewards do
        if (rewards[i].count ~= 0) then
            index = i - 1
            realNum = realNum + 1
            local pos = {
                x = index % rowDefault * paddingWidth + (rowNum - 1) * paddingWidth / -2,
                y = math.floor(index / rowDefault) * -paddingHeight + (lineNum - 1) * paddingHeight / 2
            }
            table.insert(poss, pos)
        end
    end
    this.AddResEffects(poss, rewards, true, boardConfig.eventSign)
    -- for i = 1, #rewards do
    --     if (rewards[i].count ~= 0) then
    --         index = i - 1
    --         realNum = realNum + 1
    --         local pos = {
    --             x = index % rowDefault * paddingWidth + (rowNum - 1) * paddingWidth / -2,
    --             y = math.floor(index / rowDefault) * -paddingHeight + (lineNum - 1) * paddingHeight / 2
    --         }
    --         if realNum == 1 and boardConfig ~= nil and boardConfig.eventSign ~= nil then
    --             this.AddResEffect(pos, rewards[i], true, boardConfig.eventSign)
    --         else
    --             this.AddResEffect(pos, rewards[i], true)
    --         end
    --     end
    -- end

    if boardConfig ~= nil and boardConfig.onCloseFunc ~= nil then
        boardConfig.onCloseFunc()
    end
end

function ResAddEffectManager.AddResEffectFromMailClaim(attachment)
    local awardNum = 0
    local rowNum = 0
    local lineNum = 0
    local paddingWidth = 200
    local paddingHeight = 300
    local rowDefault = 5
    for n, c in pairs(attachment) do
        if (tostring(c) ~= "0") then
            awardNum = awardNum + 1
        end
    end

    if awardNum > rowDefault then
        rowNum = rowDefault
        lineNum = math.floor(awardNum / rowNum) + 1
    else
        rowNum = awardNum
        lineNum = 1
    end
    local index = 0
    local rewards = {}
    for n, c in pairs(attachment) do
        if (tostring(c) ~= "0") then
            local itemType, itemName = MailManager.GetRewardInfo(n)
            local pos = {
                x = index % rowDefault * paddingWidth + (rowNum - 1) * paddingWidth / -2,
                y = math.floor(index / rowDefault) * -paddingHeight + (lineNum - 1) * paddingHeight / 2
            }
            local data = Utils.ConvertAttachment2Rewards(itemName, c, itemType)
            -- this.AddResEffect(pos, data, true)
            table.insert(rewards, data)
            index = index + 1
        end
    end
    ShowUI(UINames.UINoBoxOpen, { rewardMap = rewards })
    -- PopupManager.Instance:OpenPanel(PanelType.CommonNoBoxOpenPanel, { rewardMap = rewards })
end

function ResAddEffectManager.AddResEffectFromNormalBoard(reward, useBoard, eventSign, items, callback)
    local awardNum = 0
    local rowNum = 0
    local lineNum = 0
    local paddingWidth = 200
    local paddingHeight = 300
    local rowDefault = 5
    for item, num in pairs(reward) do
        if (num ~= "+0") then
            awardNum = awardNum + 1
        end
    end
    if awardNum > rowDefault then
        rowNum = rowDefault
        lineNum = math.floor(awardNum / rowNum) + 1
    else
        rowNum = awardNum
        lineNum = 1
    end
    local index = 0
    local rewards = {}
    local targetItems = {}
    local sign = { realNum = 0 }
    for item, num in pairs(reward) do
        if (num ~= "+0" and tostring(num) ~= "0") then
            local pos = items[item]
            table.insert(targetItems, pos)
            local data = Utils.ConvertAttachment2Rewards(item, num, nil)
            table.insert(rewards, data)
            index = index + 1
        end
    end
    this.AddResEffects(targetItems, rewards, true, eventSign, callback)
    -- for item, num in pairs(reward) do
    --     if (num ~= "+0" and tostring(num) ~= "0") then
    --         local pos = items[item]
    --         local data = Utils.ConvertAttachment2Rewards(item, num, nil)
    --         table.insert(rewards, data)
    --         if not useBoard then
    --             sign.realNum = sign.realNum + 1
    --             if sign.realNum == 1 then
    --                 this.AddResEffect(pos, data, true, eventSign)
    --             else
    --                 this.AddResEffect(pos, data, true)
    --             end
    --         end
    --         index = index + 1
    --     end
    -- end
    if #rewards > 0 and useBoard then
        ShowUI(UINames.UINoBoxOpen, { rewardMap = rewards, eventSign = eventSign })
        -- PopupManager.Instance:OpenPanel(PanelType.CommonNoBoxOpenPanel, { rewardMap = rewards, eventSign = eventSign })
    end
end

function ResAddEffectManager.Clear()
    this.itemList:ForEach(
        function(item)
            ResourceManager.Destroy(item.gameObject)
        end
    )
    this.timeoutIdList:ForEach(
        function(lastTip)
            clearTimeout(lastTip.timeoutId)
        end
    )
    for id, item in pairs(this.CurvePool) do
        ResourceManager.Destroy(item.gameObject)
    end
    this.CurvePool = {}
    this.itemList:Clear()
    this.timeoutIdList:Clear()
    this.ClearDelayView()
end

function ResAddEffectManager.AddDelayView(reward)
    if reward.addType ~= RewardAddType.Item then
        return nil
    end
    local cityId = DataManager.GetCityId()
    local delayView = {
        id = this.delayId,
        cityId = cityId,
        itemId = reward.id,
        count = reward.count
    }
    if this.DelayCountList == nil then
        this.DelayCountList = {}
    end
    if this.delayId == nil then
        this.delayId = 0
    end
    this.DelayCountList[this.delayId] = delayView
    this.delayId = this.delayId + 1
    DataManager.AddMaterialViewDelay(cityId, reward.id, reward.count)
    return delayView.id
end

function ResAddEffectManager.CostDelayView(delayId)
    if this.DelayCountList == nil or this.DelayCountList[delayId] == nil then
        return
    end
    local delayView = this.DelayCountList[delayId]
    DataManager.CostMaterialViewDelay(delayView.cityId, delayView.itemId, delayView.count)
    this.DelayCountList[delayId] = nil
end

function ResAddEffectManager.ClearDelayView()
    for delayId, view in pairs(this.DelayCountList) do
        this.CostDelayView(delayId)
    end
    this.DelayCountList = {}
end
