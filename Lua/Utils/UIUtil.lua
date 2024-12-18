------------------------------------------------------------------------
--- @desc UI工具
--- @author chenyl
------------------------------------------------------------------------

--region -------------数据定义-------------

---@class UIMessageBoxData
---@field Title string 标题【默认：提示】
---@field Description string 提示内容【默认：无】
---@field YesCallback function 确定回调
---@field NoCallback function 取消回调
---@field YesText string 确定按钮文字【默认：确定】
---@field NoText string 取消按钮文字【默认：取消】

--endregion

--region -------------默认参数-------------
local module = {}      -- 导出函数

local waitTipCount = 0 -- 等待提示计数
--endregion

--region -------------导出函数-------------

--region -------------UI方法-------------
---清除一个GameObject下的所有子物体
---@param gameObject UnityEngine.GameObject 目标go
function module.RemoveAllGameobject(gameObject)
    local childCount = gameObject.transform.childCount
    for i = 0, childCount - 1 do
        local child = gameObject.transform:GetChild(i)
        if child ~= nil then
            GameObject.Destroy(child.gameObject)
        end
    end
end

---节点下单层子物体隐藏
---@param gameObject UnityEngine.GameObject 目标go
function module.HideGameObjectChild(go)
    for i = 1, go.transform.childCount do
        local go = go.transform:GetChild(i - 1).gameObject
        SafeSetActive(go, false)
    end
end

local defaultParam = {
    UINames.UIMain,
    UINames.UIGuide,
}
function module.CloseAllPanelOutBy(str)
    local target = {}
    for i, v in ipairs(defaultParam) do
        table.insert(target, v)
    end
    target = str and table.insert(target, str) or target
    PanelManager:CloseAllPanelOutBy(target)
end

--endregion

--region -------------UI界面动画-------------

---Go入场动画,OutBack滑动
---@param go UnityEngine.GameObject 目标go
---@param offset UnityEngine.Vector3 偏移量
---@param delay number 延迟时间
---@param time number 动画时间
function module.PlayGoEnterAction(go, offset, delay, time)
    local localPos = go.transform.localPosition
    go.transform.localPosition = localPos + offset
    local seq = DOTween.Sequence()
    seq:AppendInterval(delay or 0)
    local tweener = go.transform:DOLocalMove(localPos, time or 0.2)
    tweener:SetEase(Ease.OutBack)
    seq:Append(tweener)
end

---界面入场动画 效果为获取画布的canvasGroup组件 播放0-1的alpha动画 以及上下回弹动画
---@param go UnityEngine.GameObject 目标界面go
function module.openPanelAction(go)
    -- 引导的时候不播放表现。界面卡顿存在UI位置获取问题
    if GameManager.TutorialOpen then
        return
    end

    local offset = 200
    local acTime = 0.25
    local canvasGroup = go:GetComponent("CanvasGroup")
    if canvasGroup == nil then
        go:AddComponent(typeof(CanvasGroup))
        canvasGroup = go:GetComponent("CanvasGroup")
    end
    canvasGroup.alpha = 0
    Util.TweenTo(0, 1, acTime, function(value)
        canvasGroup.alpha = value
    end):SetEase(Ease.OutCubic):OnComplete(function()
        canvasGroup.alpha = 1
    end)

    local localPosition = go.transform.localPosition
    go.transform.localPosition = go.transform.localPosition + Vector3(0, -offset, 0)
    go.transform:DOLocalMoveY(localPosition.y, acTime):SetEase(Ease.OutBack)
end

---界面入场动画 效果为获取画布的canvasGroup组件 播放0-1的alpha动画 以及上下回弹动画
---@param go UnityEngine.GameObject 目标界面go
---@param callBack function 动画结束回调
function module.hidePanelAction(go, callBack)
    local offset = 200
    local acTime = 0.25
    local canvasGroup = go:GetComponent("CanvasGroup")
    if canvasGroup == nil then
        go:AddComponent(typeof(CanvasGroup))
        canvasGroup = go:GetComponent("CanvasGroup")
    end
    local seq = DOTween.Sequence()
    seq:Append(Util.TweenTo(1, 0.5, acTime, function(value)
        canvasGroup.alpha = value
    end))
    seq:OnComplete(function()
        if callBack then
            callBack()
        end
        canvasGroup.alpha = 1
    end)
    seq:Play()
    local localPosition = go.transform.localPosition
    go.transform:DOLocalMoveY(localPosition.y - offset, acTime):SetEase(Ease.InBack)
end

--endregion

--region -------------提示-------------

---回退到主界面
function module.backToMain()
    module.backTo(UINames.UIMain)
end

---回退到界面
function module.backTo(uiName)
    PanelManager:BackTo(uiName)
end

---显示提示：功能未开放
function module.showTextNotOpen()
    print('功能未开放:', TbCommonText[100].Text)
    module.showText(TbCommonText[100].Text)
end

---显示确认弹窗
---@param data UIMessageBoxData
function module.showConfirmByData(data)
    --设置默认值
    data.Title = data.Title or ""
    data.Description = data.Description or StringUtil.EMPTY
    -- data.YesText = data.YesText or "确定"
    -- data.NoText = data.NoText or "取消"

    ShowUI(UINames.UIMessageBox, data)
end

---显示通用提示
---@param str string 提示内容
---@param overCallBack function 结束回调
function module.showText(str, overCallBack)
    Audio.PlayAudio(DefaultAudioID.UiTip)
    if UITipsPanel == nil or UITipsPanel.uidata == nil then
        ShowUI(UINames.UITips, str, overCallBack)
    else
        SafeSetActive(UITipsPanel.gameObject, true)
        UITipsPanel.ShowCommTips(str, overCallBack)
    end
end

---任务完成提示
---@param str string 提示内容
---@param overCallBack function 结束回调
    function module.showTaskText(str, overCallBack)
        -- Audio.PlayAudio(DefaultAudioID.UiTip)
        if UITipsPanel == nil or UITipsPanel.uidata == nil then
            ShowUI(UINames.UITips, str, overCallBack)
        else
            SafeSetActive(UITipsPanel.gameObject, true)
            UITipsPanel.ShowCommTips(str, overCallBack)
        end
    end

---显示通用气泡提示
---@param data UIComBubbleData
---@param overCallBack function 结束回调
function module.showBubbleTip(data, overCallBack)
    ShowUI(UINames.UIComBubble, data, overCallBack)
end

---------------------------------气泡提示---------------------------------------
---@param image UnityEngine.UI.Image
---@param itemId number
---@param dir ToolTipDir
---@param closeJump boolean
function module.AddItem(image, itemId, dir, closeJump, text, title)
    Util.SetEvent(image.gameObject, function()
        ShowUI(UINames.UITipBox, {
            go = image.gameObject,
            itemId = itemId,
            dir = dir,
            jump = closeJump,
            type = TooltipType.Item,
            text = text,
            title = title,
        })
    end, "onClick")
end

--添加Text 的ToolTip监听
function module.AddToolTip(image, text, dir, fontSize)
    module.AddItem(image, nil, dir, nil, text, nil)
end

function module.AddTitleToolTip(image, text, title, dir)
    module.AddItem(image, nil, dir, nil, text, title)
end

function module.AddToolTipBig(image, text, dir)
    module.AddItem(image, nil, dir, nil, text, nil)
end

---多少分钟的奖励
function module.AddItemOvertime(image, itemId, sec, addType, dir, closeJump)
    local oldReward = {}
    local itemOvertime = {
        addType = addType,
        id = itemId,
        count = sec
    }
    table.insert(oldReward, itemOvertime)
    local parseReward = Utils.RewardOverTime2Item(oldReward)
    module.AddReward(image, parseReward, dir, itemId)
end

---@param image UnityEngine.UI.Image
---@param rewards number
---@param dir ToolTipDir
function module.AddReward(image, rewards, dir, itemId)
    local id = (rewards[1].addType == RewardAddType.Box or rewards[1].addType == RewardAddType.OpenBox) and
        rewards[1].id or itemId
    Util.SetEvent(image.gameObject, function()
        ShowUI(UINames.UITipBox, {
            go = image.gameObject,
            itemId = id,
            rewards = rewards,
            dir = dir,
            type = TooltipType.BoxReward,
        })
    end, "onClick")
end

function module.AddBoxReward(image, boxId, dir)
    local baseRewardStr, additionRewardStr = BoxManager.GetBoxRewardDetails(boxId)

    local baseReward = Utils.ParseReward(baseRewardStr, false)
    local additionReward = Utils.ParseReward(additionRewardStr, false)

    Util.SetEvent(image.gameObject, function()
        ShowUI(UINames.UITipBox, {
            go = image.gameObject,
            itemId = boxId,
            rewards = baseReward,
            dir = dir,
            type = TooltipType.BoxReward,
            addition = additionReward,
        })
    end, "onClick")
end

--添加属性 的ToolTip监听
function module.AddAttribute(image, type, needJump, dir)
    Util.SetEvent(image.gameObject, function()
        ShowUI(UINames.UITipBox, {
            go = image.gameObject,
            dir = dir,
            attribute = type,
            jump = needJump,
            type = TooltipType.Attribute,
        })
    end, "onClick")
end

-- --添加技能 的ToolTip监听
-- function ToolTipManager.AddSkill(image, isBoost, cardItemData, skillId, index, dir)
--     this.AddClick(
--         image.gameObject,
--         function()
--             this.ShowSkillToolTip(
--                 image.transform.position,
--                 image.transform.sizeDelta.y / 2,
--                 isBoost,
--                 cardItemData,
--                 skillId,
--                 index,
--                 dir
--             )
--         end,
--         true
--     )
-- end

-- --添加技能 的ToolTip监听
-- function ToolTipManager.AddSkillShort(image, isBoost, cardItemData, skillId, index, dir)
--     this.AddClick(
--         image.gameObject,
--         function()
--             this.ShowSkillToolTipShort(
--                 image.transform.position,
--                 image.transform.sizeDelta.y / 2,
--                 isBoost,
--                 cardItemData,
--                 skillId,
--                 index,
--                 dir
--             )
--         end,
--         true
--     )
-- end

--添加zone 的ToolTip监听
function module.AddZone(image, id, needJump, lv)
    module.AddZoneType(image, id, needJump, lv, nil)
end

function module.AddZoneType(image, id, needJump, lv, num)
    local config = ConfigManager.GetZoneConfigById(id)
    local mapItemData = MapManager.GetMapItemData(DataManager.GetCityId(), id)
    local text = num ~= nil and GetLang(config.zone_type_name) .. " x " .. num
        or mapItemData:GetName()
    local title = mapItemData:GetDesc()
    Util.SetEvent(image.gameObject, function()
        ShowUI(UINames.UITipBox, {
            go = image.gameObject,
            itemId = id,
            dir = ToolTipDir.Up,
            jump = needJump,
            type = TooltipType.Zone,
            text = text,
            title = title,
        })
    end, "onClick")
end

---------------------------------气泡提示---------------------------------------

function module.showWaitTip()
    waitTipCount = waitTipCount + 1
    if waitTipCount == 1 then
        ShowUISync(UINames.UIWaitTip)
    end

    -- 十秒后关闭
    TimeModule.addDelay(10,function()
        module.hideWaitTip()
    end)

end

function module.hideWaitTip()
    waitTipCount = waitTipCount - 1
    if waitTipCount <= 0 then
        HideUI(UINames.UIWaitTip)
    end
end

function module.checkWaitTip()
    return waitTipCount > 0
end

function module.isClickTarget(screenPos, target)
    -- 将点击位置转换为UI坐标
    local uiPos = PanelManager:GetUICamera():ScreenToWorldPoint(screenPos)

    -- 获取UI范围
    local uiRect = target.transform

    -- 判断点击位置是否在UI范围内
    return RectTransformUtility.RectangleContainsScreenPoint(uiRect, uiPos)
end

--endregion
-- 注：会把富文本也算进去
function module.getTextSize(textComp, text)
    text = text or textComp.text
    local font = textComp.font
    local fontSize = textComp.fontSize
    local fontStyle = textComp.fontStyle

    font:RequestCharactersInTexture(text, fontSize, fontStyle)
    local totalSize = 0
    local chars = System.String.ToCharArray(System.String.New(text))
    for i = 1, chars.Length do
        local b, fontInfo = font:GetCharacterInfo(chars[i-1], nil, fontSize, fontStyle)
        totalSize = totalSize + fontInfo.advance
    end

    return totalSize
end

return module
