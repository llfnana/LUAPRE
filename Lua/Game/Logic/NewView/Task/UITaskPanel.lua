---@class UITaskPanel : UIPanelBase
local Panel = UIPanelBaseMake()
local this = Panel
UITaskPanel = Panel

function Panel.OnAwake()
    this.cachedata = {}
    this.InitPanel()
    this.InitEvent()
    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    --关闭按钮
    this.uidata.Mask = SafeGetUIControl(this, "Mask")
    this.uidata.ButtonPass = SafeGetUIControl(this, "Image/ButtonPass")
    this.uidata.CityNameText = SafeGetUIControl(this, "Image/ImageCityName/Text", "Text")
    this.uidata.TaskCountText = SafeGetUIControl(this, "Image/Slider/HandleSlide/Handle/TextPrecess", "Text")
    this.uidata.TaskProgressSlider = SafeGetUIControl(this, "Image/Slider"):GetComponent("Slider")
    this.uidata.Content = SafeGetUIControl(this, "Image/ScrollView/Viewport/Content")

    this.uidata.ButtonRwd = SafeGetUIControl(this, "Image/ButtonRwd")


    this.uidata.ImgRed = SafeGetUIControl(this, "Image/ButtonPass/ImgRed")
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.Mask, this.HideUI)

    SafeAddClickEvent(this.behaviour, this.uidata.ButtonPass, function()
        local nextCityConfig = ConfigManager.GetCityById(this.cityId + 1)
        -- 没有下一级城市了
        if not nextCityConfig then 
            ShowUI(UINames.UIMessageBox, {
                Title = "ui_alert_title",
                Description = "Notice_finish_all_current",
                
                ShowYes = true,
            })
            return 
        end
        CityPassManager.PlayCityPass()
        this.HideUI()
    end)
end

function Panel.InitViewData()
    --初始化数据
    this.cityId = DataManager.GetCityId()

    this.taskMilestoneConfig = TaskManager.GetTaskMilestoneConfig(this.cityId)

    local milestoneReward = Utils.ParseReward(this.taskMilestoneConfig.rewards)
    UIUtil.AddReward(this.uidata.ButtonRwd, milestoneReward, ToolTipDir.Up)

    local cfg = ConfigManager.GetCityById(this.cityId)
    this.uidata.CityNameText.text = GetLang(cfg.city_name)

    this.twList = List:New()

    if this.MilestoneStatus == TaskMilestoneStatus.Finished and this.cityId < ConfigManager.GetCityCount() then
        SafeSetActive(this.uidata.ImgRed, true)
        GreyObject(this.uidata.ButtonPass, false, true, false)
    end

    this:RefreshMilestoneStatus(this.cityId)
    this:RefreshTaskItems(this.cityId)

    this.RefreshMilestoneFunc = function(cityId)
        if cityId ~= this.cityId then
            return
        end

        this:RefreshMilestoneStatus(cityId)
        this:RefreshTaskItems(cityId)
    end
    this.AddListener(EventType.TASK_MILESTONE_REFRESH, this.RefreshMilestoneFunc)

    this.RefreshTaskFunc = function(cityId)
        if cityId ~= this.cityId then
            return
        end
        this:RefreshMilestoneStatus(cityId)
        this:RefreshTaskItems(cityId)
    end
    this.AddListener(EventType.TASK_FINISH, this.RefreshTaskFunc)
    this.AddListener(EventType.TASK_REFRESH, this.RefreshTaskFunc)
    this.AddListener(EventType.TASK_CHANGE, this.RefreshTaskFunc)
    this.AddListener(EventType.TASK_COMPLETE, this.RefreshTaskFunc)
end

function Panel:RefreshMilestoneStatus(cityId)
    this.MilestoneStatus = TaskManager.RefreshAndGetTaskMilestoneStatus(cityId)
    local count, maxCount = TaskManager.GetTaskMilestoneProgress(cityId)
    if cityId >= ConfigManager.GetCityCount() then
        this.uidata.TaskCountText.text = count .. "/" .. maxCount
        this.uidata.TaskProgressSlider.value = count / maxCount
        SafeSetActive(this.uidata.ImgRed, false)
        SafeSetActive(this.uidata.ButtonPass, count >= maxCount)
    elseif this.MilestoneStatus == TaskMilestoneStatus.NoFinished then
        this.uidata.TaskCountText.text = count .. "/" .. maxCount
        this.uidata.TaskProgressSlider.value = count / maxCount
        SafeSetActive(this.uidata.ImgRed, false)
        GreyObject(this.uidata.ButtonPass, true, false, false)
    elseif this.MilestoneStatus == TaskMilestoneStatus.Finished or this.MilestoneStatus == TaskMilestoneStatus.Claimed then
        this.uidata.TaskCountText.text = count .. "/" .. maxCount
        this.uidata.TaskProgressSlider.value = count / maxCount
        SafeSetActive(this.uidata.ImgRed, true)
        GreyObject(this.uidata.ButtonPass, false, true, false)
    end
end

function Panel:RefreshTaskItems(cityId)
    local taskList = TaskManager.GetTask(cityId):GetAvailableTaskList()

    local childCount = this.uidata.Content.transform.childCount
    for k = 1, childCount do
        local index = k - 1
        local child = this.uidata.Content.transform:GetChild(index)
        child.gameObject:SetActive(false)
    end

    taskList:ForEach(
        function(taskItem, index)
            local item = this.uidata.Content.transform:GetChild(index - 1)
            item.gameObject:SetActive(true)
            local TextDes = item.transform:Find("TextDes"):GetComponent("Text")
            local TextPre = item.transform:Find("TextPre"):GetComponent("Text")
            local ImageIcon = item.transform:Find("ImageIcon"):GetComponent("Image")
            local ImageIconType = item.transform:Find("ImageIconType"):GetComponent("Image")
            local ButtonGo = item.transform:Find("ButtonGo").gameObject
            local ButtonGet = item.transform:Find("ButtonGet").gameObject

            local RewardCellItem = item.transform:Find("RewardCellItem")
            this.setRewardItem(RewardCellItem, taskItem)

            TextDes.text = taskItem:GetTaskDesc()
            local currCount, maxCount = taskItem:GetTaskProgress()

            if taskItem:GetTaskStatus() == TaskStatus.NotAccept then
                SafeSetActive(ButtonGet, true)
                TextPre.text = "<color=#3a3837>" ..
                    currCount .. "/" .. "</color>" .. "<color=#3a3837>" .. maxCount .. "</color>"
                -- TextPre.transform.localPosition = TextPre.transform.localPosition + Vector3(0, 100, 0)
            else
                SafeSetActive(ButtonGet, false)
                SafeSetActive(ButtonGo, taskItem:GetJumpButtonShow())
                TextPre.text = "<color=#60524f>" ..
                    currCount .. "/" .. "</color>" .. "<color=#60524f>" .. maxCount .. "</color>"
                -- TextPre.transform.localPosition = TextPre.transform.localPosition + Vector3(0, -100, 0)
            end

            -- 添加和适配
            local width = UIUtil.getTextSize(TextPre, currCount .. "/" .. maxCount)
            if width > 170 then 
                TextPre.alignment = UnityEngine.TextAnchor.MiddleRight
            else
                TextPre.alignment = UnityEngine.TextAnchor.MiddleCenter
            end
            
            ImageIcon:SetNativeSize()
            ImageIcon.transform.localScale = Vector2(1, 1)
            
            -- 任务图标
            taskItem:GetIconSprite(ImageIcon)

            -- 类型图标
            Utils.SetIcon(ImageIconType, taskItem:GetTypeIconSprite())

            SafeAddClickEvent(
                this.behaviour,
                ButtonGo,
                function()

                    if this.cityId == 1 then
                        SDKAnalytics.TraceEvent(140)
                    end

                    taskItem:LookUpZone()
                end
            )

            SafeAddClickEvent(
                this.behaviour,
                ButtonGet,
                function()

                    if taskItem.taskId == "10011001" then
                        SDKAnalytics.TraceEvent(143)
                    elseif taskItem.taskId == "10012001" then
                        SDKAnalytics.TraceEvent(145)
                    elseif taskItem.taskId == "10012007" then
                        SDKAnalytics.TraceEvent(154)
                    end

                    local rewards = taskItem:GainTaskReward()
                    if rewards == nil then 
                        -- 已经领取过或不可领取
                        return 
                    end
                    ResAddEffectManager.AddResEffectFromRewards(rewards, false, {
                        onCloseFunc = function()
                            -- this.OnClaimed(taskId)
                            this.OpenMilestoneRewardPanel()
                        end
                    })
                end
            )
        end
    )
end

function Panel.OnShow()
    Audio.PlayAudio(DefaultAudioID.openTask)  --打开任务
    UIUtil.openPanelAction(this.gameObject)

    this.InitViewData()

    this.OpenMilestoneRewardPanel()
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UITask)
    end)

    -- 通关引导
    local count, maxCount = TaskManager.GetSceneTaskProgress(this.cityId)
    if count == maxCount then
        if this.cityId == 1 and TutorialManager.IsNeverTrigger(TutorialStep.ToCity2) then
            TutorialManager.TriggerTutorial(TutorialStep.ToCity2)
        end
    end
end

-- 任务奖励
function Panel.setRewardItem(RewardCellItem, taskItem)
    local CountText = RewardCellItem.transform:Find("TextTime"):GetComponent("Text")
    local ImageIcon = RewardCellItem.transform:Find("ImageIcon"):GetComponent("Image")
    local ImageIconBg = RewardCellItem.transform:Find("ImageIconBg"):GetComponent("Image")

    local reward = taskItem:GetRewards()[1]
    if reward.addType == RewardAddType.Item then
        CountText.text = Utils.FormatCount(reward.count)
        UIUtil.AddItem(ImageIcon, reward.id, nil, UINames.UITask)
    elseif reward.addType == RewardAddType.Card then
        CountText.text = reward.count
        local config = ConfigManager.GetCardConfig(reward.id)
        local manageType = CardManager.GetCardManageType(reward.id)
        if manageType == CardManageType.manage then
            UIUtil.AddTitleToolTip(ImageIcon, GetLang("reward_desc_card"), GetLang(config.name))
        elseif manageType == CardManageType.peaceManage then
            UIUtil.AddTitleToolTip(ImageIcon, GetLang("reward_desc_card_peace"), GetLang(config.name))
        elseif manageType == CardManageType.overall then
            UIUtil.AddTitleToolTip(ImageIcon, GetLang("reward_desc_card_overall"), GetLang(config.name))
        else
            UIUtil.AddTitleToolTip(ImageIcon, GetLang("reward_desc_card"), GetLang(config.name))
        end
    elseif reward.addType == RewardAddType.Box or reward.addType == RewardAddType.OpenBox then
        CountText.text = reward.count

        UIUtil.AddBoxReward(ImageIcon, reward.id)
    elseif reward.addType == RewardAddType.OverTime then
        CountText.text = Utils.GetTimeFormatByMin(reward.count)
        UIUtil.AddItemOvertime(ImageIcon, reward.id, reward.count, RewardAddType.OverTime)
    end

    -- 图标
    Utils.SetRewardIcon(reward, ImageIcon)
end

function Panel.OpenMilestoneRewardPanel(delaySec)
    local showPanel = function()
        -- 领取奖励
        local rewards = TaskManager.GetTask(this.cityId):GainTaskMilestoneReward()
        local newCardIds = Utils.CheckNewCard(rewards)
        print("zhkxin 过关宝箱奖励：", ListUtil.dump(rewards))
        ResAddEffectManager.AddResEffectFromRewards(rewards, true, {
            onCloseFunc = function()
                if #newCardIds > 0 then
                    --只要有新卡，就关闭任务界面
                    this.HideUI()
                    return
                end

                local count, maxCount = TaskManager.GetSceneTaskProgress(this.cityId)
                if count == maxCount then
                    this.HideUI()
                end
            end
        })
    end

    local state = TaskManager.RefreshAndGetTaskMilestoneStatus(this.cityId)
    if state == TaskMilestoneStatus.Finished then
        showPanel()
    end
end
