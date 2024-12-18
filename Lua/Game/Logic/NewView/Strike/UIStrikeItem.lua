---@class UIStrikeItem
local Element = class("UIStrikeItem")
UIStrikeItem = Element


function Element:ctor()

end

function Element:InitPanel(behaviour, obj, appeaseIndex, totalPeople, cardLevel, callBack)
    self.gameObject = obj
    self.transform = obj.transform
    self.behaviour = behaviour

    self.callBack = callBack
    self.cityId = DataManager.GetCityId()
    self.appeaseIndex = appeaseIndex
    self.totalPeople = totalPeople

    self.AppeasePeople = SafeGetUIControl(self, "AppeasePeople")
    self.AppeaseValue = SafeGetUIControl(self, "AppeasePeople/TextReduceAnger", "Text")
    self.AppeaseName = SafeGetUIControl(self, "TextTitle", "Text")
    self.LockContent = SafeGetUIControl(self, "LockContent")
    self.NeedContent = SafeGetUIControl(self, "NeedContent")
    self.NeedIcon = SafeGetUIControl(self, "NeedContent/ImageIcon", "Image")
    self.NeedCount = SafeGetUIControl(self, "NeedContent/needCount", "Text")
    self.ImageIcon = SafeGetUIControl(self, "ImageIcon", "Image")

    self.ResourcesValue = SafeGetUIControl(self, "AppeaseCostGroup/ResourcesValue", "Text")
    self.ResourceIcon = SafeGetUIControl(self, "AppeaseCostGroup/ResourceIcon", "Image")
    self.AppeaseCostGroup = SafeGetUIControl(self, "AppeaseCostGroup", "CanvasGroup")

    self.cardRequireLevel = ProtestManager.GetAppeaseRequireCardLevel(self.cityId, self.appeaseIndex)
    --卡牌等级事件
    local function CardLevelFunc(lv)
        self.appeaseUnlock = lv >= self.cardRequireLevel
        SafeSetActive(self.LockContent, not self.appeaseUnlock)
        SafeSetActive(self.NeedContent, self.appeaseUnlock)
        GreyObject(self.gameObject, not self.appeaseUnlock, true, false)
        self.AppeaseName.color = self.appeaseUnlock and Color.New(203 / 255, 226 / 255, 253 / 255, 1) or Color.New(192 / 255, 202 / 255, 213 / 255, 1)
    end
    self.cardLevelRx = NumberRx:New(cardLevel)
    self.cardLevelSubscribe = self.cardLevelRx:subscribe(CardLevelFunc)

    SafeAddClickEvent(self.behaviour, self.gameObject, function()
        if ProtestManager.GetAppeaseCount(self.cityId) > 0 then
            GreyObject(self.gameObject, not self.appeaseUnlock, false)
            if self.callBack then
                self.callBack(self.appeaseUnlock, self.ItemCountColorIndex == 1, self.appeaseInfo)
            end
        end
    end)

end

function Element:SetCardLevel(cardLevel)
    if self.appeaseUnlock then
        return
    end
    self.cardLevelRx.value = cardLevel
end

--显示安抚缩放
function Element:ShowAppeaseScale()
    self.appeaseTween = self.AppeasePeople.transform:DOScale(Vector3(1.3, 1.3, 1.3), 0.1)
    self.appeaseTween:SetLoops(2, LoopType.Yoyo)
end

local COST_SHOW_TIME = 1
--显示安抚花费
function Element:ShowAppeaseCost(callBack)

    Util.TweenTo(0, 1, COST_SHOW_TIME / 2, function(value)
        self.AppeaseCostGroup.alpha = value
    end)

    -- self.alphaTween = self.AppeaseCostGroup:DOFade(1, COST_SHOW_TIME / 2)
    -- self.alphaTween:SetLoops(2, LoopType.Yoyo)
    -- self.alphaTween:SetEase(Ease.OutExpo)

    local tx = SafeGetUIControl(self, "AppeaseCostGroup").transform.localPosition
    -- local targetPosition = Vector3(tx.x, tx.y, tx.z)
    self.appeaseTween = SafeGetUIControl(self, "AppeaseCostGroup").transform:DOLocalMoveY(tx.y + 130, COST_SHOW_TIME)
    self.appeaseTween:SetEase(Ease.OutExpo)
    self.appeaseTween:OnComplete(
        function()
            SafeGetUIControl(self, "AppeaseCostGroup").transform.localPosition = tx
            self.AppeaseCostGroup.alpha = 0
            if callBack then
                callBack()
            end
        end
    )
end

function Element:SetAppeaseCount(appeaseCount, appeaseProgress, appeaseTime)
    if appeaseCount == 0 then
    elseif appeaseCount == 1 then
    end
end

function Element:playAni()
    self.transform:GetComponent("Animation"):Play()
end

function Element:OnRefresh()

    GreyObject(self.gameObject, not self.appeaseUnlock, true)

    --数据配置
    self.appeaseInfo = ProtestManager.GetAppeaseInfoByIndex(self.cityId, self.appeaseIndex)
    self.appeaseConfig = ConfigManager.GetProtestAppeaseConfigById(self.appeaseInfo.appeaseId)
    self.appeasePeopleCount = math.ceil(self.totalPeople * self.appeaseConfig.anti_anger)

    if self.materialSubscribe then
        self.materialSubscribe:unsubscribe()
        self.materialSubscribe = nil
    end
    self.ItemCountColorIndex = nil

    Utils.SetIcon(self.ImageIcon, self.appeaseInfo.appeaseIcon)

    self.AppeaseName.text = GetLang(self.appeaseInfo.appeaseName)
    self.AppeaseValue.text = "-" .. self.appeasePeopleCount

    if self.appeaseConfig.appease_type == "None" then
        self.ItemCountColorIndex = 1
        self.NeedCount.text = "-" 
        SafeGetUIControl(self, "NeedContent/ImageIcon"):SetActive(false)

    elseif self.appeaseConfig.appease_type == "BurnRes" or self.appeaseConfig.appease_type == "Resources" then
        SafeGetUIControl(self, "NeedContent/ImageIcon"):SetActive(true)
        Utils.SetItemIcon(self.NeedIcon, self.appeaseInfo.itemId)
        Utils.SetItemIcon(self.ResourceIcon, self.appeaseInfo.itemId)
        if self.appeaseInfo.itemCost > 0 then
            self.ItemCountColorIndex = 1
            self.NeedCount.text = "+" .. Utils.FormatCount(self.appeaseInfo.itemCost)
            self.ResourcesValue.text = "+" .. Utils.FormatCount(self.appeaseInfo.itemCost)
        else
            local itemCountAbs = math.abs(self.appeaseInfo.itemCost)
            self.NeedCount.text = "-" .. Utils.FormatCount(itemCountAbs)
            self.ResourcesValue.text = "-" .. Utils.FormatCount(itemCountAbs)
            --物品数量监听
            local function MaterialCountFunc(val)
                local isChange = false
                if nil == self.ItemCountColorIndex then
                    if itemCountAbs > val then
                        self.ItemCountColorIndex = 0
                    else
                        self.ItemCountColorIndex = 1
                    end
                    isChange = true
                elseif self.ItemCountColorIndex == 0 then
                    if itemCountAbs <= val then
                        self.ItemCountColorIndex = 1
                        isChange = true
                    end
                elseif self.ItemCountColorIndex == 1 then
                    if itemCountAbs > val then
                        self.ItemCountColorIndex = 0
                        isChange = true
                    end
                end
                if isChange then
                    -- self.ItemCount:SelectColor(self.ItemCountColorIndex)
                end
            end
            self.materialSubscribe =
                DataManager.GetMaterialRx(self.cityId, self.appeaseInfo.itemId):subscribe(MaterialCountFunc)
        end
    end

    ForceRebuildLayoutImmediate(self.LockContent)
    ForceRebuildLayoutImmediate(self.NeedContent)

end

function Element:OnDestroy()
    if self.cardLevelSubscribe then
        self.cardLevelSubscribe:unsubscribe()
        self.cardLevelSubscribe = nil
    end
    if self.appeaseCountSubscribe then
        self.appeaseCountSubscribe:unsubscribe()
        self.appeaseCountSubscribe = nil
    end
    if self.materialSubscribe then
        self.materialSubscribe:unsubscribe()
        self.materialSubscribe = nil
    end
end
