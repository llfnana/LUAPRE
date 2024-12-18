PanelType = {
    AdAwardPanel = "AdAwardPanel",
    AdAwardToPrivilegePanel = "AdAwardToPrivilegePanel",
    DebugPanel = "DebugPanel",
    BuildPanel = "BuildPanel",
    UnlockPanel = "UnlockPanel",
    PeoplePanel = "PeoplePanel",
    SelectFoodPanel = "SelectFoodPanel",
    GeneratorPanel = "GeneratorPanel",
    GeneratorUpgradePanel = "GeneratorUpgradePanel",
    CharacterPanel = "CharacterPanel",
    ConsumptionAwardPanel = "ConsumptionAwardPanel",
    SchedulesPanel = "SchedulesPanel",
    SelectScenePanel = "SelectScenePanel",
    CardPanel = "CardPanel",
    TaskPanel = "TaskPanel",
    BattleArrayPanel = "BattleArrayPanel",
    CardInfoPanel = "CardInfoPanel",
    CardStarPanel = "CardStarPanel",
    ProtestResultPanel = "ProtestResultPanel",
    AdventurePanel = "AdventurePanel",
    OpenBoxPanel = "OpenBoxPanel",
    NewCardShowPanel = "NewCardShowPanel",
    ShopPanel = "ShopPanel",
    ShopOverTimeConfirmPanel = "ShopOverTimeConfirmPanel",
    ShopTimeMachinePanel = "ShopTimeMachinePanel",
    ShopSubscriptionConfirmPanel = "ShopSubscriptionConfirmPanel",
    ShopPopupPanel = "ShopPopupPanel",
    ShopSubscriptionGuidePanel = "ShopSubscriptionGuidePanel",
    TestUIPanel = "TestUIPanel",
    DataPanel = "DataPanel",
    StatisticalPanel = "StatisticalPanel",
    IdleBattleRewardTips = "IdleBattleRewardTips",
    OfflinePanel = "OfflinePanel",
    AudioTestPanel = "AudioTestPanel",
    BattleResultUI = "BattleResultUI",
    PersonAttributePanel = "PersonAttributePanel",
    SettingPanel = "SettingPanel",
    BattlePauseUI = "BattlePauseUI",
    HaloGroupPanel = "HaloGroupPanel",
    MessageBoxPanel = "MessageBoxPanel",
    MailboxPanel = "MailboxPanel",
    MailboxContentPanel = "MailboxContentPanel",
    MailboxMsgPanel = "MailboxMsgPanel",
    DiscordTipPanel = "DiscordTipPanel",
    SurveyInvitedPanel = "SurveyInvitedPanel",
    TaskMilestoneRewardPanel = "TaskMilestoneRewardPanel",
    CommonBoxOpenPanel = "CommonBoxOpenPanel",
    CommonNoBoxOpenPanel = "CommonNoBoxOpenPanel",
    TaskCompletePanel = "TaskCompletePanel",
    DissolveShopPanel = "DissolveShopPanel",
    DissolveShopDescPanel = "DissolveShopDescPanel",
    BuildAddHeroPanel = "BuildAddHeroPanel",
    WorkOvertimePanel = "WorkOvertimePanel",
    ChangeHeroInBuilding = "ChangeHeroInBuilding",
    EmptyPanel = "EmptyPanel",
    PeopleInfoPanel = "PeopleInfoPanel",
    JsonPanel = "JsonPanel",
    ConfigPanel = "ConfigPanel",
    CityPassSummary = "CityPassSummary",
    CityPassIntroduction = "CityPassIntroduction",
    CityPassEffect = "CityPassEffect",
    SelectScenePanelItem = "SelectScenePanelItem",
    EventScenePanel = "EventScenePanel",
    ProductionChainPanel = "ProductionChainPanel",
    EventVanPanel = "EventVanPanel",
    EventTrickPanel = "EventTrickPanel",
    CardTrickPanel = "CardTrickPanel",
    RogueSelectHeroPanel = "RogueSelectHeroPanel",
    BuildingManagementPanel = "BuildingManagementPanel",
    ProtestRiotsPanel = "ProtestRiotsPanel",
    PersonAttributeInstructionPanel = "PersonAttributeInstructionPanel",
    SlotPanel = "SlotPanel",
    RogueExitPanel = "RogueExitPanel",
    RogueBagPanel = "RogueBagPanel",
    RogueBoxPanel = "RogueBoxPanel",
    RogueSurvivorsPanel = "RogueSurvivorsPanel",
    EventSlotPanel = "EventSlotPanel",
    EventSlotRewardPanel = "EventSlotRewardPanel",
    EventGeneratorUpgradePanel = "EventGeneratorUpgradePanel",
    LeaderboardPanel = "LeaderboardPanel",
    LeaderboardRewardPanel = "LeaderboardRewardPanel",
    ProfilePanel = "ProfilePanel",
    EventMilestonePanel = "EventMilestonePanel",
    EventGroupPanel = "EventGroupPanel",
    EventRewardPanel = "EventRewardPanel",
    GoldenGrandpaPanel = "GoldenGrandpaPanel",
    EffectLayerTest = "EffectLayerTest",
    PlayerRatingPanel = "PlayerRatingPanel",
    PlayerRatingConfirmPanel = "PlayerRatingConfirmPanel",
    LuckCodePanel = "LuckCodePanel",
    StoryBookSkipPanel = "StoryBookSkipPanel",
    EventWarehousePanel = "EventWarehousePanel",
    BuildPanelCardInfoPanel = "BuildPanelCardInfoPanel",
    EventPlayInstructionsPanel = "EventPlayInstructionsPanel",
    HospitalPatientsPanel = "HospitalPatientsPanel",
    BuildWaitingListPanel = "BuildWaitingListPanel"
}
---@class PopupManager
PopupManager = {}
function PopupManager:Create(name)
    ---@type PopupManager
    PopupManager.Instance = ClassMono(name, PopupManager)
    return PopupManager.Instance
end

function PopupManager:Awake()
    self.overlay = self.transform:Find("Overlay").gameObject
    self.loading = self.transform:Find("Loading").gameObject
    self.isShowLoading = false
    self.overlay:GetComponent(TypeButton).onClick:AddListener(
        function()
            self:OnOverlayClick()
        end
    )
    self.panelList = List:New()
    self.panelQueueList = {}
    self.lastClosePanelTs = 0
    self.lastOpenPanelTs = 0
    self.fullScreenRx = NumberRx:New(0)
    self.fullScreenRxSubscribe =
        self.fullScreenRx:subscribe(
        function(val)
           -- CameraManager.SetMainCameraEnable(val <= 0)
        end,
        false
    )
end

function PopupManager:OnDestroy()
    self.fullScreenRxSubscribe:unsubscribe()
end

-- 打开面板
---@return Panel
function PopupManager:OpenPanel(panelType, obj)
    local panel =
        self.panelList:Find(
        function(p)
            return p.panelType == panelType
        end
    )
    if panel ~= nil then
        self:RemovePanel(panel, false)
    else
        panel = self:AddPanel(panelType)
    end

    obj = obj or {}
    panel:SetData(obj)
    if self.panelList:Count() > 0 then
        -- 调用前一个
        self.panelList[self.panelList:Count()]:OnFocus(false)
    end

    self.panelList:Add(panel)
    self:RefreshPanelSort()
    GameToastList.Instance:SetOnPanelOpen(panelType)
    HudHandles.SetRightButtonActive(MainUI.Instance, false)
    self.lastOpenPanelTs = os.clock()
    return panel
end

-- 最后打开面板(待其他面板关闭)
function PopupManager:LastOpenPanel(panelType, obj, needHead)
    local panelQueue = {
        type = panelType,
        obj = obj
    }
    if needHead then
        table.insert(self.panelQueueList, 1, panelQueue)
    else
        table.insert(self.panelQueueList, panelQueue)
    end
    self:CheckPopupQueue()
end

-- 添加面板到Canvas
function PopupManager:AddPanel(panelType)
    Analytics.Event("UIPanelOpen", {panelType = panelType})
    require("Game/Logic/View/UI/" .. panelType)
    local panelView = ResourceManager.Instantiate("ui/" .. panelType, self.transform, true)
    local panel = panelView:GetComponent(TypeLuaMonoBehaviour).LuaTable
    panel.panelType = panelType
    if panel.isFullScreen then
        self.fullScreenRx.value = self.fullScreenRx.value + 1
    end
    return panel
end

-- 关闭事件
function PopupManager:ClosePanel(panel, immediatelyDes)
    self:RemovePanel(panel, true)
    self:RefreshPanelSort(immediatelyDes)
    self:CheckPopupQueue()
    GameToastList.Instance:SetOnPanelClose(panel.panelType)
    GameToastList.Instance:CheckToastQueue()
    -- MainUI.Instance:CheckRightButtonShow()
    HudHandles.CheckRightButtonShow(MainUI.Instance)
end

-- 移除面板
function PopupManager:RemovePanel(panel, needDestroy)
    self.panelList:Remove(panel)
    if panel.isFullScreen then
        self.fullScreenRx.value = self.fullScreenRx.value - 1
    end
    if needDestroy then
        ResourceManager.Destroy(panel.gameObject)
    end
end

--显示panel
function PopupManager:ShowPanel(panelType)
    local panel =
        self.panelList:Find(
        function(p)
            return p.panelType == panelType
        end
    )
    if panel then
        panel.gameObject:SetActive(true)
    end
end

-- 隐藏panel
function PopupManager:HidePanel(panelType)
    local panel =
        self.panelList:Find(
        function(p)
            return p.panelType == panelType
        end
    )
    panel.gameObject:SetActive(false)
end

-- 获取panel
---@return Panel
function PopupManager:SearchOpenPanel(panelType)
    local panel =
        self.panelList:Find(
        function(p)
            return p.panelType == panelType
        end
    )

    return panel
end

-- 面板刷新排序
function PopupManager:RefreshPanelSort(immediatelyDes)
    if self.panelList:Count() > 0 then
        -- Map.Instance:CancelStatus() TODO 需要解耦
        if self.overlayTw ~= nil then
            self.overlayTw:Kill()
            self.overlayTw = nil
        end
        self.currentPanel = self.panelList[self.panelList:Count()]
        if self.currentPanel.isOverlay then
            if self.overlay.activeInHierarchy == false then
                self.overlay:SetActive(true)
                self.overlay:GetComponent(TypeImage).color = Color(0, 0, 0, 0)
            end
            local overlayColor = self.currentPanel.overlayColor or Color(0, 0, 0, 0.3)
            self.overlayTw = self.overlay:GetComponent(TypeImage):DOColor(overlayColor, 0.2)
        else
            self.overlay:GetComponent(TypeImage).color = Color(0, 0, 0, 0)
        end
        self.overlay.transform:SetAsLastSibling()
        self.currentPanel.transform:SetAsLastSibling()
        self.currentPanel:OnFocus(true)
        if self.isShowLoading then
            if self.overlay.activeInHierarchy == true then
                self.overlay.transform:SetAsLastSibling()
            end
            self.loading.transform:SetAsLastSibling()
        end
    else
        if self.overlay.activeInHierarchy == true then
            if immediatelyDes == true then
                self.overlay:SetActive(false)
            else
                self.overlayTw =
                    self.overlay:GetComponent(TypeImage):DOColor(Color(0, 0, 0, 0), 0.2):OnComplete(
                    function()
                        self.overlay:SetActive(false)
                    end
                )
            end
        end
        self.lastClosePanelTs = os.clock()
    end
end

-- 打开下一个面板
function PopupManager:OpenNextPanel(panel, panelType, obj)
    self:RemovePanel(panel, true)
    self:OpenPanel(panelType, obj)
end

-- 打开子面板
function PopupManager:OpenSubPanel(panel, panelType, obj)
    self:OpenPanel(panelType, obj)
    self.currentPanel.parentPanel = panel
    self:RefreshPanelSort()
end

-- 检查面板弹出退列
function PopupManager:CheckPopupQueue()
    if self.panelList:Count() > 0 then
        return
    end
    if #self.panelQueueList > 0 then
        local panelQueue = self.panelQueueList[1]
        table.remove(self.panelQueueList, 1)
        self:OpenPanel(panelQueue.type, panelQueue.obj)
    elseif not self.lockEvent then
        EventManager.Brocast(EventType.ALL_PANEL_CLOSE)
    end
end

-- 检查是否有面板打开
function PopupManager:IsOpenPanel()
    if self.panelList:Count() > 0 or #self.panelQueueList > 0 then
        return true
    end
    return false
end

--检测制定类型面板是否打开
function PopupManager:IsOpenPanelByType(type)
    if self.currentPanel == nil then
        return false
    end
    if self.currentPanel.isClosed then
        return false
    end
    return self.currentPanel.panelType == type
end

-- 关闭所有面板
function PopupManager:CloseAllPanel(closeOverlay)
    self.lockEvent = true
    --关闭面板应该从最上面开始关闭
    self.panelList:ReverseForEach(
        function(panel)
            if not panel.isClosed then
                panel:ClosePanel(true)
            end
        end
    )
    if self.overlayTw ~= nil then
        self.overlayTw:Kill()
    end
    -- if closeOverlay then
    self.overlay:SetActive(false)
    -- end
    self.lockEvent = false
end

-- 点击屏幕阴影处
function PopupManager:OnOverlayClick()
    if self.currentPanel ~= nil and self.currentPanel.isOpened == true and self.isShowLoading == false then
        self.currentPanel:OnOverlayClick()
    end
end

function PopupManager:UpdatePanel(panel)
    if not panel.isClosed then
        panel:OnUpdate()
    end
end

function PopupManager:Update()
    local count = self.panelList:Count()
    for i = 1, count do
        self:UpdatePanel(self.panelList[i])
    end
end

function PopupManager:ShowLoading()
    -- self.isShowLoading = true
    -- self.loading:SetActive(true)
    -- self.loadingTw =
    --     self.loading.transform:DORotate(Vector3(0, 0, -360), 3, RotateMode.FastBeyond360):SetLoops(-1):SetEase(
    --     Ease.Linear
    -- )
    -- self:RefreshPanelSort()
    UIUtil.showWaitTip()
end

function PopupManager:HideLoading()
    -- self.isShowLoading = false
    -- self.loading:SetActive(false)
    -- if self.loadingTw ~= nil then
    --     self.loadingTw:Kill()
    -- end
    -- self.loading.transform.localEulerAngles = Vector3(0, 0, 0)
    -- self:RefreshPanelSort()
    UIUtil.hideWaitTip()
end

function PopupManager:OnPressEsc()
    if not GameManager.TutorialOpen and self.isShowLoading == false then
        if
            self.currentPanel ~= nil and self.currentPanel.isOpened == true and self.currentPanel.escClose == true and
                self.panelList:Count() > 0
         then
            if self.currentPanel.panelType == PanelType.BattleArrayPanel then
                self.currentPanel:ClosePanel(true)
                SceneSystem.currentSceneSystem:Exit(true)
            elseif self.currentPanel.panelType == PanelType.BattleResultUI then
                self.currentPanel:ClosePanel(true)
                SceneSystem.currentSceneSystem:Exit(true)
            elseif self.currentPanel.panelType == PanelType.RogueSelectHeroPanel then
            else
                self.currentPanel:ClosePanel()
            end
        elseif (os.clock() - self.lastClosePanelTs) > 1 and self.panelList:Count() == 0 then
            UIUtil.showConfirmByData(
                {
                    Description = "UI_quit_game",
                    ShowYes = true,
                    ShowNo = true,
                    YesText = "ui_ok_btn",
                    NoText = "ui_no_btn",
                    OnYesFunc = function()
                        CS.FrozenCity.Utils.Quit()
                    end
                }
            )
        end
    end
end

function PopupManager:OpenErrorPanel(msg)
    UIUtil.showConfirmByData(
        {
            Description = msg,
            ShowYes = true,
            HideClose = true,
            YesText = "ui_ok_btn",
            OnYesFunc = function()
                CS.FrozenCity.Utils.Quit()
            end,
            OnCloseFunc = function()
                CS.FrozenCity.Utils.Quit()
            end
        }
    )
end

function PopupManager.ForceClosePanel()
    if PopupManager.Instance ~= nil then
        PopupManager.Instance:CloseAllPanel()
    end
end
