---@class CityCharacterWarningUI @城市人物警报UI
local Element = class("CityCharacterWarningUI")
CityCharacterWarningUI = Element

local DefaultScale = Vector3(0.5, 0.5, 0.5)
local StartScale = Vector3.one
local ToScale = Vector3(1.3, 1.3, 1.3)
local DelayTime = 1000

function Element:ctor()
    self.gameObject = nil
    self.isBind = false
end

function Element:bind(go)
    self.isBind = true
    self.gameObject = go

    self.normalRoot = SafeGetUIControl(self.gameObject, "NormalRoot")
    self.normalIcon = SafeGetUIControl(self.gameObject, "NormalRoot/NormalIcon", "Image")
    self.stateRoot = SafeGetUIControl(self.gameObject, "StateRoot")
    self.stateIcon = SafeGetUIControl(self.gameObject, "StateRoot/StateIcon", "Image")
end

function Element:OnShow(params)
    if isNil(self.normalIcon)  or isNil(self.stateIcon) then return end
    self.normalIcon.enabled = false
    self.stateIcon.enabled = false

    self.stepRx = NumberRx:New(-1)
    self.showItems = List:New()

    local function AddShowItem(item)
        if self.showItems:Contains(item) then
            return
        end
        self.showItems:Add(item)
        if params.showRx.value then
            if isNil(item) == false then
                item.enabled = true
            end
        end
    end
    local function RemoveShowItem(item)
        if not self.showItems:Contains(item) then
            return
        end
        self.showItems:Remove(item)
        if params.showRx.value then
            if isNil(item) == false then
                item.enabled = false
            end
        end
    end

    self.normalRxList = List:New()
    self.normalRxList:Add(
        self.stepRx:subscribe(
            function(step)
                if step == -1 then
                    if self.tween then
                        self.tween:Kill()
                        self.tween = nil
                    end
                    if self.timeOutId then
                        clearTimeout(self.timeOutId)
                        self.timeOutId = nil
                    end
                    self.normalRoot.transform.localScale = DefaultScale
                    RemoveShowItem(self.normalIcon)
                elseif step == 1 then
                    AddShowItem(self.normalIcon)
                    self.normalRoot.transform.localScale = DefaultScale
                    self.tween = self.normalRoot.transform:DOScale(StartScale, 0.2)
                    self.tween:OnComplete(
                        function()
                            if self.stepRx.value == 1 then
                                self.stepRx.value = 2
                            end
                        end
                    )
                elseif step == 2 then
                    self.tween = self.normalRoot.transform:DOScale(ToScale, 0.1):SetLoops(6, LoopType.Yoyo)
                    self.tween:OnComplete(
                        function()
                            if self.stepRx.value == 2 then
                                self.stepRx.value = 3
                            end
                        end
                    )
                elseif step == 3 then
                    local function TimeOutFunc()
                        self.timeOutId = nil
                        if self.stepRx.value == 3 then
                            self.stepRx.value = 4
                        end
                    end
                    self.timeOutId = setTimeout(TimeOutFunc, DelayTime)
                elseif step == 4 then
                    RemoveShowItem(self.normalIcon)
                    local function TimeOutFunc()
                        self.timeOutId = nil
                        if self.stepRx.value == 4 then
                            self.stepRx.value = 1
                        end
                    end
                    self.timeOutId = setTimeout(TimeOutFunc, DelayTime)
                end
            end
        )
    )

    self.rxList = List:New()
    self.rxList:Add(
        params.showRx:subscribe(
            function(b)
                self.showItems:ForEach(
                    function(item)
                        item.enabled = b
                    end
                )
                if b then
                    if self.currState == EnumState.Normal then
                        if nil ~= self.warningIndex and self.warningIndex ~= -1 then
                            if self.stepRx.value == -1 then
                                self.stepRx.value = 1
                            end
                        end
                    else
                        self.stepRx.value = -1
                        if self.currState ~= EnumState.Celebrate then
                            if not self.playStateTween then
                                self:PlayStateTween()
                            end
                        end
                    end
                else
                    self.stepRx.value = -1
                    self:StopStateTween()
                end
            end
        )
    )
    
    self.rxList:Add(
        params.stateRx:subscribe(
            function(index)
                local state = Utils.GetEnumStateBySelectIndex(index)
                if self.currState == state then
                    return
                end
                if self.currState then
                    self.prevState = self.currState
                end
                self.currState = state

                if self.currState == EnumState.Sick then
                    self.stateIcon.transform.localPosition = Vector3.New(0, -32, 0)
                else
                    self.stateIcon.transform.localPosition = Vector3.zero
                end

                local needStop = true
                local needPlay = true
                if self.prevState == EnumState.Normal then
                    needStop = false
                elseif self.prevState == EnumState.Protest then
                    RemoveShowItem(self.stateIcon)
                elseif self.prevState == EnumState.Dead then
                    RemoveShowItem(self.stateIcon)
                elseif self.prevState == EnumState.EventStrike then
                    RemoveShowItem(self.stateIcon)
                elseif self.prevState == EnumState.RunAway then
                    RemoveShowItem(self.stateIcon)
                elseif self.prevState == EnumState.Severe then
                    RemoveShowItem(self.stateIcon)
                elseif self.prevState == EnumState.Sick then
                    RemoveShowItem(self.stateIcon)
                    -- RemoveShowItem(self.sickProgressBg)
                    -- RemoveShowItem(self.sickProgress)
                elseif self.prevState == EnumState.Celebrate then
                    needStop = false
                end
                if self.currState == EnumState.Normal then
                    needPlay = false
                elseif self.currState == EnumState.Protest then
                    Utils.SetAttributeIcon(self.stateIcon, "protester", function ()
                        self.stateIcon:SetNativeSize()
                    end)
                    AddShowItem(self.stateIcon)
                elseif self.currState == EnumState.Dead then
                    Utils.SetAttributeIcon(self.stateIcon, "dead", function ()
                        self.stateIcon:SetNativeSize()
                    end)
                    AddShowItem(self.stateIcon)
                elseif self.currState == EnumState.EventStrike then
                    Utils.SetAttributeIcon(self.stateIcon, "runaway", function ()
                        self.stateIcon:SetNativeSize()
                    end)
                    AddShowItem(self.stateIcon)
                elseif self.currState == EnumState.RunAway then
                    Utils.SetAttributeIcon(self.stateIcon, "runaway", function ()
                        self.stateIcon:SetNativeSize()
                    end)
                    AddShowItem(self.stateIcon)
                elseif self.currState == EnumState.Severe then
                    Utils.SetAttributeIcon(self.stateIcon, "health_low", function ()
                        self.stateIcon:SetNativeSize()
                    end)
                    AddShowItem(self.stateIcon)
                elseif self.currState == EnumState.Sick then
                    Utils.SetAttributeIcon(self.stateIcon, "health_low", function ()
                        self.stateIcon:SetNativeSize()
                    end)
                    AddShowItem(self.stateIcon)
                    -- AddShowItem(self.sickProgressBg)
                    -- AddShowItem(self.sickProgress)
                elseif self.currState == EnumState.Celebrate then
                    needPlay = false
                end
                if params.showRx.value then
                    if needPlay then
                        if not self.playStateTween then
                            self:PlayStateTween()
                        end
                        if self.stepRx.value ~= -1 then
                            self.stepRx.value = -1
                        end
                    elseif needStop then
                        if self.playStateTween then
                            self:StopStateTween()
                        end
                        if nil ~= self.warningIndex and self.warningIndex ~= -1 then
                            if self.stepRx.value == -1 then
                                self.stepRx.value = 1
                            end
                        end
                    end
                end
            end
        )
    )

    self.rxList:Add(
        params.attributeRx:subscribe(
            function(index)
                self.warningIndex = index
                if index ~= -1 then
                    Utils.SetAttributeIcon(self.normalIcon, Utils.GetAttributeTypeBySelectIndex(index))
                end
                local needStop = true
                if params.showRx.value and self.currState == EnumState.Normal then
                    needStop = index == -1
                end
                if needStop then
                    self.stepRx.value = -1
                elseif self.stepRx.value == -1 then
                    self.stepRx.value = 1
                end
            end
        )
    )
    -- self.rxList:Add(
    --     params.sickRx:subscribe(
    --         function(progress)
    --             self.sickProgress.size = Vector2(progress, self.sickProgress.size.y)
    --         end
    --     )
    -- )
    self.rxList:Add(
        -- params.markRx:subscribe(
        --     function(mark)
        --         if mark == EnumMarkState.Talk then
        --         else
        --         end
        --     end
        -- )
    )
    self.rxList:Add(
        params.warmShowRx:subscribe(
            function(isShow)
                if true then
                    return
                end
                if isShow then
                    AddShowItem(self.warmIcon)
                    AddShowItem(self.warmSliderBg)
                    AddShowItem(self.warmSlider)

                    if nil ~= self.tweenWarm then
                        self.tweenWarm:Kill()
                        self.tweenWarm = nil
                    end
                    local fromValue = params.warmFromRx.value / 100
                    local toValue = params.warmToRx.value / 100
                    local function WarmProgressFunc(p)
                        self.warmSlider.size = Vector2(p * self.warmSliderBg.size.x, self.warmSlider.size.y)
                    end
                    WarmProgressFunc(fromValue)
                    self.tweenWarm = DOTween.To(WarmProgressFunc, fromValue, toValue, 2.5)
                    self.tweenWarm:OnComplete(
                        function()
                            params.warmShowRx.value = false
                        end
                    )
                else
                    if nil ~= self.tweenWarm then
                        self.tweenWarm:Kill()
                        self.tweenWarm = nil
                    end
                    RemoveShowItem(self.warmIcon)
                    RemoveShowItem(self.warmSliderBg)
                    RemoveShowItem(self.warmSlider)
                end
            end
        )
    )
end

function Element:PlayStateTween()
    self.playStateTween = true
    self.stateRoot.transform.localScale = StartScale
    self.tweenState = self.stateRoot.transform:DOScale(Vector3(1.2, 1.2, 1.2), 0.5)
    self.tweenState:SetLoops(-1, DG.Tweening.LoopType.Yoyo)
end

function Element:StopStateTween()
    if self.tweenState then
        self.tweenState:Kill()
        self.tweenState = nil
    end
    self.stateRoot.transform.localScale = StartScale
    self.playStateTween = false
end

function Element:destroy()
    for key, value in pairs(self.normalRxList) do
        value:unsubscribe()
    end
    self.normalRxList:Clear()

    for key, value in pairs(self.rxList) do
        value:unsubscribe()
    end
    self.rxList:Clear()

    if self.gameObject then 
        GODestroy(self.gameObject)
    end

    self.gameObject = nil
    self.isBind = false
end