---@class City.CityMapZoneBuild 
local ZoneBuild = class('CityMapZoneBuild')

---@param data CityBuildingData
function ZoneBuild:ctor(data)

    self.tid = data.tid -- 配置ID
    self.type = 1

    self.isOpenRoof = false
    self.gameObject = nil
    self.transform = nil
    self._spriteRenderer = nil
    self._animation = nil
    self._aniScaleX = 1 -- 默认动画缩放X

    self._checkEf = nil -- 验收特效

    self.position = nil --
    self.updateTime = 0.0

    self.offsetX = nil
    self.offsetY = nil

    self._efIdleGo = nil -- 呼吸特效
    self.configs = nil
    self.cursor = nil -- 建造光标
    self.data = data
    self.zoneId = data.zoneId
    self.cityId = data.cityId or DataManager.GetCityId()

    self.startBuild = false -- 是否开始建造

    self.mapItemData = MapManager.GetMapItemData(DataManager.GetCityId(), data.zoneId)

    self.OrnamentsGo = nil
end

function ZoneBuild:setOffset(x, y)
    self.offsetX = x
    self.offsetY = y
end

function ZoneBuild:init()
    self:initSortingLayer()
    self:initEvent()
    self:refresh()

    self.mapItemData:BindView(self)
end

-- 点击
function ZoneBuild:MouseUp()
    self.mapItemData:DisableShowUpgradeComplete()
    EventManager.Brocast(EventDefine.OnClickCityBuild, self.data)
end


--获取选中的中心点
function ZoneBuild:GetPoint()
    if self then
        return self.transform.position
    end

end

function ZoneBuild:initSortingLayer()
    self.sortValue = CityModule.getMainCtrl():GetSortingByPosition(self.transform.position.x, self.transform.position.y)

    local room = self.transform:Find("Room")
    local childCount = room.childCount

    -- 装修类家具放到 Ornaments 节点下，并只在城市1、2、3里显示

    local furniture_table = {}
    for i = 0, childCount - 1 do
        local child = room:GetChild(i)
        if child.name == CityUtils.OrnamentsName then
            self.OrnamentsGo = child.gameObject
            if CityUtils.IsShowOrnaments() then
                child.gameObject:SetActive(true)
                local subChildCount = child.childCount
                for j = 0, subChildCount - 1 do
                    table.insert(furniture_table, child:GetChild(j))
                end
            else
                child.gameObject:SetActive(false)
            end
        else
            table.insert(furniture_table, child)
        end
    end


    -- for i = 0, childCount - 1 do
    for i = 1, #furniture_table, 1 do
        local child = furniture_table[i]
        local x = child.position.x
        local y = child.position.y
        local order = CityModule.getMainCtrl():GetSortingByPosition(x, y)

        local goCount = child.childCount
        local childCurOrder = 3000
        local childSp = child.gameObject:GetComponent(typeof(SpriteRenderer))
        if childSp then
            childCurOrder = childSp.sortingOrder
        elseif child:GetChild(0).gameObject:GetComponent(typeof(SpriteRenderer)) then
            childCurOrder = child:GetChild(0).gameObject:GetComponent(typeof(SpriteRenderer)).sortingOrder
        end
        if goCount > 1 then
            -- 床特殊处理
            local childs = {}
            for j = 0, goCount - 1 do
                local go = child:GetChild(j).gameObject
                local spriteRenderer = go:GetComponent(typeof(SpriteRenderer))
                childs[j + 1] = spriteRenderer
            end

            -- local子节点坐标
            local localGo1 = childs[1].transform
            local localGo2 = childs[2].transform

            -- 图片像素底部坐标
            local mainCtrl = CityModule.getMainCtrl()
            local order1 = mainCtrl:GetSortingByPosition(localGo1.transform.position.x, localGo1.transform.position.y)
            local order2 = mainCtrl:GetSortingByPosition(localGo2.transform.position.x, localGo2.transform.position.y)

            childs[1].sortingOrder = order1
            childs[2].sortingOrder = order2 + 10

        elseif child.name == "ornament" then
            -- 装饰物
            -- local spriteRenderer = child.gameObject:GetComponent(typeof(SpriteRenderer))
            -- spriteRenderer.sortingOrder = order
        elseif childCurOrder < 3000 then
            -- 不参与排序的家具
            local spriteRenderer = child.gameObject:GetComponent(typeof(SpriteRenderer))
            if spriteRenderer == nil and child.childCount > 0 then
                spriteRenderer = child:GetChild(0).gameObject:GetComponent(typeof(SpriteRenderer))
            end
            if spriteRenderer then
                spriteRenderer.sortingOrder = childCurOrder
            end
        else
            -- 家具
            local spriteRenderer = child.gameObject:GetComponent(typeof(SpriteRenderer))
            if spriteRenderer == nil and child.childCount > 0 then
                spriteRenderer = child:GetChild(0).gameObject:GetComponent(typeof(SpriteRenderer))
            end
            if spriteRenderer then
                order = CityModule.getMainCtrl():GetSortingByPosition(x, child.transform.position.y)
                spriteRenderer.sortingOrder = order
                -- -- 图片像素底部坐标
                -- local bottomPositionY = child.transform.position.y - spriteRenderer.bounds.size.y / 2
                -- order = CityModule.getMainCtrl():GetSortingByPosition(x, bottomPositionY)
                -- spriteRenderer.sortingOrder = order
            end
        end
    end

    local developObj, developAnimation, developRenderer = self:GetUIDeveloping()
    developRenderer.sortingLayerName = "Building Front"
    developRenderer.sortingOrder = self.sortValue + 40
    local roof = self.transform:Find("Outside/roof")
    roof:GetComponent(typeof(SpriteRenderer)).sortingOrder = self.sortValue + 20

    local roofWall = self.transform:Find("Outside/roofWall")
    if roofWall then
        local childCount = roofWall.childCount
        for i = 0, childCount - 1 do
            local child = roofWall:GetChild(i)
            child.gameObject:GetComponent(typeof(SpriteRenderer)).sortingOrder = self.sortValue + 20
        end
    end
end

function ZoneBuild:InitView()
    self:InitFurnituresView()
    self:initSceneUI()
end

--- 初始化建筑场景UI
function ZoneBuild:initSceneUI()
    if self.buildStatusUI == nil then
        ResInterface.SyncLoadGameObject("BuildStatus", function (go)
            self.buildStatusUI = GOInstantiate(go, CityModule.getMainCtrl()._rootMapUI)
            local addName = GetLang(self.mapItemData.config.zone_type_name)
            self.buildStatusUI.transform.localPosition = Vector3.zero
            self.buildStatusUI.name = "BuildStatus_" .. addName
            self.BuildStatusImg = self.buildStatusUI.transform:Find("Canvas/Status"):GetComponent("Image")
            self.BuildStatusImgTween = self.BuildStatusImg.transform:DOLocalMoveY(400, 0.9):SetLoops(-1, LoopType.Yoyo)

            self.buildStatusUI.transform.position = self.transform.position

            local OutsidePrb = self.transform:Find("Outside")
            if OutsidePrb then
                local roofActive = CityModule.getMainCtrl().camera:getRoofActive()
                self:SetRoofDisplay(roofActive)
                -- self:SetTitleUIDisplay(roofActive)
                self:SetProductionUIDisplay(not roofActive)
            end

            local mapItems = MapManager.GetMap(self.cityId)
            local buildUnlock = mapItems.zones[self.zoneId] ~= nil
            if buildUnlock then
                --刷新titleUI
                self:refreshTitleUI()
            end

            self:CheckStartBuild()
            self.isUpgradingBuildAni = false
            --刷新建造升级进度
            self:upBuildingProgress(true)
        end)
    end
end

function ZoneBuild:UpdateBuildStatus()
    local status = self:GetBuildStatus()
    -- if self.mapItemData.config.zone_type == ZoneType.Carpentry then 
    --     print("zhkxin GetBuildStatus", status)
    -- end
    if isNil(self.BuildStatusImg) then
        return
    end

    if status == BuildStatus.None then
        self.BuildStatusImgTween:Pause()
        self.BuildStatusImg.gameObject:SetActive(false)
    else
        self.BuildStatusImgTween:Play()
        Utils.SetIcon(self.BuildStatusImg, status, nil, true, true)
        self:SetTitleUIDisplay(status == BuildStatus.OK)
    end
end

function ZoneBuild:GetBuildStatus()
    local buildLevel = self.mapItemData:GetLevel()
    if buildLevel == 0 or CityPassManager.isPlayingNextPass then
        return BuildStatus.None
    end
    -- 当该建筑物满足可升级等级时
    if self:CheckBuildUpgrade() then
        return BuildStatus.Up
    end
    -- 当该建筑物建造或升级完成后
    if self.mapItemData:GetShowUpgradeComplete() then
        return BuildStatus.OK
    end
    -- 当所需的原材料数量不足以生产出1个物资时
    if self.mapItemData:IsEnoughForOneOutput() then
        return BuildStatus.NoWork
    end
    -- 当该建筑物存在空岗位未派遣幸存者时
    if self.mapItemData:HasEmptyPost() then
        return BuildStatus.AddPeople
    end
    -- 当存在新岗位，且该建筑物的英雄等级未满足解锁该岗位时
    if self.mapItemData:IsPostLockByHeroLevel() then
        return BuildStatus.Post
    end
    -- 当该建筑物已解锁，并拥有Zones表card_id字段的数据条件，且未拥有该英雄时
    if self.mapItemData:NeedAndLockHero() then
        return BuildStatus.AddCard
    end

    return BuildStatus.None
end

function ZoneBuild:CheckBuildUpgrade()
    if self.mapItemData:GetLevel() >= self.mapItemData.config.max_level then
        return false
    end

    if self.mapItemData:IsUpgrading() then
        return false
    end

    if self.mapItemData:GetExp() < self.mapItemData:GetUpgradeExp() then
        return false
    end

    local costIsReady = self.mapItemData:GetUnlockLevelCostIsReady()
    local unlockData = self.mapItemData:GetUnlockLevelIsReady()

    return costIsReady and unlockData["AllReady"]
end

function ZoneBuild:GetUIDeveloping()
    if not self.developObj then
        self.developObj = SafeGetUIControl(self.gameObject, "Outside/act")
        self.developAnimation = self.developObj:GetComponent(typeof(SkeletonAnimation))
        self.developRenderer = self.developObj:GetComponent(typeof(MeshRenderer))
    end

    return self.developObj, self.developAnimation, self.developRenderer
end

function ZoneBuild:GetUIBuildProgress()
    if not self.buildProgressObj and self.buildStatusUI then
        local trans = self.buildStatusUI.transform:Find("Canvas/BuildProgress")
        self.buildProgressObj = trans.gameObject
        self.buildProgressSlider = trans:Find("Slider"):GetComponent("Slider")
        self.buildProgressText = trans:Find("Slider/Text"):GetComponent("Text")
    end
    return self.buildProgressObj, self.buildProgressSlider, self.buildProgressText
end

function ZoneBuild:upBuildingProgress(noAni)
    if not self.mapItemData or not self.mapItemData.zoneData then
        return
    end

    local developObj, developAnimation = self:GetUIDeveloping()
    local buildProgressObj, buildProgressSlider, buildProgressText = self:GetUIBuildProgress()
    if self.mapItemData:IsDeveloping() then
        local lfTime, lfTotal = self.mapItemData:GetBuildLeftTime()
        -- 如果剩余时间小于等于0
        if lfTime <= 0 then
            self:UpdateBuildLeftTimeView()
        else
            if not self.isUpgradingBuildAni then
                self.isUpgradingBuildAni = true

                Audio.PlayAudio(DefaultAudioID.BuildConstruction)
                developObj:SetActive(true)

                local buildLevel = self.mapItemData:GetLevel()
                local aniName = buildLevel > 0 and "animation" or "animation4"
                local aniName2 = buildLevel > 0 and "animation2" or "animation5"
                self:playBuidAnim(aniName, false, function ()
                    self:playBuidAnim(aniName2, true)
                end)
            end

            buildProgressObj:SetActive(true)
            local p = 1 - lfTime / lfTotal
            buildProgressText.text = Utils.GetTimeFormat3(lfTime)
            if noAni then
                buildProgressSlider.value = p
            else
                Util.TweenTo(buildProgressSlider.value, p, 0.25, function (value)
                    buildProgressSlider.value = value
                end)
            end
        end
    else
        local animationName = developAnimation.AnimationName
        if animationName == "animation2" or animationName == "animation5" then
            developObj:SetActive(false)
        end
        buildProgressObj:SetActive(false)
        MapManager.RemoveBuildQueue(self.zoneId)
    end
end

function ZoneBuild:playBuidAnim(animName, loop, completeCb)
    local developObj, developAnimation = self:GetUIDeveloping()
    if developAnimation then
        if developAnimation.state then
            local entry = developAnimation.state:SetAnimation(0, animName, loop)
            entry:AddOnComplete(function ()
                if completeCb then
                    completeCb()
                end
            end)
        end
    else
        if completeCb then
            completeCb()
        end
    end
end

function ZoneBuild:refreshTitleUI()
    if self.buildStatusUI == nil then
        return
    end

    local level = self.mapItemData:GetLevel()
    local icon =  self.buildStatusUI.transform:Find("Canvas/BuildTitle/Icon"):GetComponent("Image")
    local zoneType = self.mapItemData.config.zone_type
    if zoneType == ZoneType.Infirmary then
        Utils.SetIcon(icon, "icon_sceneView_hospital")
        icon.transform.sizeDelta = Vector2.New(76, 62)
    elseif zoneType == ZoneType.Dorm then
        Utils.SetIcon(icon, "icon_sceneView_dorm")
        icon.transform.sizeDelta = Vector2.New(76, 62)
    elseif zoneType == ZoneType.Kitchen then
        Utils.SetIcon(icon, "icon_sceneView_kitchen")
        icon.transform.sizeDelta = Vector2.New(76, 62)
    elseif zoneType == ZoneType.Generator then
        Utils.SetIcon(icon, "icon_sceneView_generator")
        icon.transform.sizeDelta = Vector2.New(76, 62)
    elseif zoneType == ZoneType.Watchtower then
        Utils.SetIcon(icon, "icon_sceneView_watchtower")
        icon.transform.sizeDelta = Vector2.New(76, 62)
    elseif self.mapItemData:IsProductType() then
        local outputItemData = self.mapItemData:GetOutputInfo()
        Utils.SetItemIcon(icon, outputItemData.itemId)
        icon.transform.sizeDelta = Vector2.New(74.88, 74.88)
    end

    local txt = self.buildStatusUI.transform:Find("Canvas/BuildTitle/Text"):GetComponent("Text")
    txt.text = GetLang("UI_BuildingInfo_Level") .. level

    self:refreshStateIcon()
end

function ZoneBuild:refreshStateIcon()
    local state = self.buildStatusUI.transform:Find("Canvas/BuildTitle/IconState")
    local iconComplete = self.buildStatusUI.transform:Find("Canvas/BuildTitle/IconState/IconComplete"):GetComponent("Image")
    local iconCanUp = self.buildStatusUI.transform:Find("Canvas/BuildTitle/IconState/IconCanUp"):GetComponent("Image")

    state.gameObject:SetActive(false)
    iconComplete.gameObject:SetActive(false)
    iconCanUp.gameObject:SetActive(false)

    --hasClick
    local hasClick = self.mapItemData:GetHasClick()
    if hasClick == false then
        state.gameObject:SetActive(true)
        iconComplete.gameObject:SetActive(true)
        iconCanUp.gameObject:SetActive(false)
        -- self.StateGroup:SetActive(true)
        -- self.AddCardGroup:SetActive(false)
        -- self.UpgradeButton:SetActive(false)
        -- self.FinishButton:SetActive(true)
        return
    end

     --canUpgrade
     if self.mapItemData:GetLevel() < self.mapItemData.config.max_level then
        local unlockData = self.mapItemData:GetUnlockLevelIsReady()
        local costIsReady = self.mapItemData:GetUnlockLevelCostIsReady()
        local canUpgrade = costIsReady and unlockData["AllReady"]
        local isProgress = true
        if self.mapItemData:GetZoneType() ~= ZoneType.Generator then
            local p = self.mapItemData:GetExp() / self.mapItemData:GetUpgradeExp()
            p = math.min(p, 1)
            isProgress = p >= 1
        end
        if canUpgrade and isProgress and not self.startBuild then
            state.gameObject:SetActive(true)
            iconComplete.gameObject:SetActive(false)
            iconCanUp.gameObject:SetActive(true)
            -- self.StateGroup:SetActive(true)
            -- self.AddCardGroup:SetActive(false)
            -- self.UpgradeButton:SetActive(true)
            -- self.FinishButton:SetActive(false)
            return
        end
    end
end

function ZoneBuild:bind(go)
    self.gameObject = go
    self.transform = go.transform
end

---是否屋顶状态
function ZoneBuild:isRoof() return self.isOpenRoof end

-- 建筑点击事件
function ZoneBuild:initEvent()
    self.pressingBuild = false
    Util.SetEvent(self.gameObject, function(data)

        -- local callback = function()
        --     self:cbClickBuild() 
        -- end
        if self.pressingBuild == false then
            local cityId = DataManager.GetCityId()
            local mapItems = MapManager.GetMap(cityId)
            local mapItemData = MapManager.GetMapItemData(cityId, self.data.zoneId)
            local canUnlock = MapManager.GetCanLock(cityId, mapItemData.zoneId)
            local unlockData = mapItemData:GetUnlockLevelIsReady()
            local buildCanUnlock = unlockData and unlockData["AllReady"]
            local buildUnlock = mapItems.zones[self.zoneId] ~= nil
            if (not canUnlock or not buildCanUnlock) and not buildUnlock then
                return
            end
            self.mapItemData:DisableShowUpgradeComplete()
            self:UpdateBuildStatus()
            EventManager.Brocast(EventDefine.OnClickCityBuild, self.data)
        end
    end, Define.EventType.OnClick)
    Util.SetEvent(self.gameObject, function(data)
    end, Define.EventType.OnLongPress)
    Util.SetEvent(self.gameObject, function(data)
        if self.pressingBuild == false then
        end
        self.pressingBuild = true
    end, Define.EventType.OnLongPressing)
    Util.SetEvent(self.gameObject, function(data)
        self.pressingBuild = false
    end, Define.EventType.OnUp)

    -- 拖拽事件做一个穿透处理
    Util.SetEvent(self.gameObject, function(data)
        Util.PassDragEvent(self.gameObject, data) -- 事件渗透
    end, Define.EventType.OnDrag)


    self.eventList = {}
    UpdateBeat:Add(self.checkBuildStateIcon, self)
    self:eventOnSelf(EventType.TIME_CITY_UPDATE, function ()
        self:Update()
    end)
    self:eventOnSelf(EventDefine.OnCloseBuildUnlockPanel, function (zoneId)
        self:SetBuildPreShadow(false)
        self:UpdateBuildCursor()
    end)
    self:eventOnSelf(EventType.UPGRADE_ZONE, function (cityId, zoneId)
        if cityId == self.cityId and zoneId == self.zoneId then
            self:SetBuildProgressDisplay(false)
            self:refreshTitleUI()
            -- self:SetTitleUIDisplay(true)
            self:SetRoofDisplay(true)
        end
    end)

    self:eventOnSelf(EventDefine.LanguageChange, function()
        if self.buildStatusUI then
            local txt = self.buildStatusUI.transform:Find("Canvas/BuildTitle/Text"):GetComponent("Text")
            txt.text = GetLang("UI_BuildingInfo_Level") .. self.mapItemData:GetLevel()
        end
    end)

    if self.data.type == ZoneType.Generator then
        self:eventOnSelf(EventType.REFRESH_GENERATOR, Handler(self, self.RefreshGenerator))
        self:eventOnSelf(EventType.GENERATOR_ADD_FIRE, Handler(self, self.InitGeneratorEffect))
        self:eventOnSelf(EventType.GENERATOR_REDUCE_FIRE, Handler(self, self.InitGeneratorEffect))
        self:InitGeneratorEffect(self.cityId)
    end

end

function ZoneBuild:RefreshGenerator(cityId, type)
    self:InitGeneratorEffect(cityId, type)
    self:RefreshStatus()
end

function ZoneBuild:InitGeneratorEffect(cityId, type)
    local enable = GeneratorManager.GetIsEnable(cityId)
    local overload = GeneratorManager.GetIsOverload(cityId)
    local enableEffect1 = self.gameObject.transform:Find("Outside/Z_duqi_jinghuaduqi_001/eff"):GetComponent("ParticleSystem")
    local enableEffect2 = self.gameObject.transform:Find("Outside/Z_duqi_paopao/eff"):GetComponent("ParticleSystem")
    local overloadEffect1 = self.gameObject.transform:Find("Outside/Z_duqi_jinghuaduqi_002"):GetComponent("ParticleSystem")
    local overloadEffect2 = self.gameObject.transform:Find("Outside/Z_duqi_paopao_001"):GetComponent("ParticleSystem")

    local enableSaoMiao = self.gameObject.transform:Find("Outside/Z_UI_Jhq_saomiao/eff"):GetComponent("ParticleSystem")
    local enableSaoMiaoBack = self.gameObject.transform:Find("Outside/Z_UI_Jhq_saomiao_back/eff"):GetComponent("ParticleSystem")
    local overloadCircle = self.gameObject.transform:Find("Outside/Z_UI_Jhq_guozai/eff"):GetComponent("ParticleSystem")
    local overloadCircleBack = self.gameObject.transform:Find("Outside/Z_UI_Jhq_guozai_back/eff"):GetComponent("ParticleSystem")

    local wall = self.gameObject.transform:Find("Outside/wall/wall_3")
    SafeSetActive(wall.gameObject, not enable and not overload)

    -- 净化器特效
    if self.generatorEanble ~= nil and self.generatorEanble ~= enable then
        if enable then
            enableSaoMiao:Play()
            enableSaoMiaoBack:Stop()
        else
            enableSaoMiao:Stop()
            enableSaoMiaoBack:Play()
        end
    end

    if self.generatorOverload ~= nil and self.generatorOverload ~= overload then
        if overload then
            overloadCircle:Play()
            overloadCircleBack:Stop()
        else
            overloadCircle:Stop()
            overloadCircleBack:Play()
        end
    end

    if enable then
        enableEffect1:Play()
        enableEffect2:Play()
    else
        Audio.PlayAudio(DefaultAudioID.HideGenerator)
        enableEffect1:Stop()
        enableEffect2:Stop()
    end
    if overload then
        overloadEffect1:Play()
        overloadEffect2:Play()
    else
        overloadEffect1:Stop()
        overloadEffect2:Stop()
    end

    self.generatorEanble = enable
    self.generatorOverload = overload
end

--初始化所有家具显示
function ZoneBuild:InitFurnituresView()
    if self.mapItemData:GetBuildStatus() ~= BuildingStatus.Complete then
        return
    end

    local room = self.transform:Find("Room")
    local childCount = room.childCount
    for i = 0, childCount - 1 do
        local child = room:GetChild(i)
        if child.name == CityUtils.OrnamentsName then
            -- if child.gameObject.activeSelf then 
            local subChildCount = child.childCount;
            for j = 0, subChildCount - 1 do
                local subChild = child:GetChild(j)
                subChild.gameObject:SetActive(false)
            end
            -- end
        else
            if child.name ~= "ornament" then
                child.gameObject:SetActive(false)
            end
        end
    end

    self.furnitureViews = {}
    local furnitureList = self.mapItemData:GetFurnitureList()
    for furnitureId, count_in_room in pairs(furnitureList) do
        for i = 1, count_in_room, 1 do
            self:UpdateFurnitureView(furnitureId, i)
        end
    end
end
function ZoneBuild:UpdateFurnitureView(furnitureId, index, selectFurnitureId)
    local key = furnitureId .. "_" .. index
    local level = self.mapItemData:GetFurnitureLevel(furnitureId, index)

    local config = ConfigManager.GetFurnitureById(furnitureId)
    local furnitureAssetName = string.lower(config.assets_name)
    if not self.furnitureViews[key] then
        local furniture = self.transform:Find("Room/model_furniture_" .. furnitureAssetName .. "_" .. index)
        if furniture == nil then
            -- 没有找到，继续在装饰节点下找
            furniture = self.transform:Find("Room/".. CityUtils.OrnamentsName .. "/model_furniture_" .. furnitureAssetName .. "_" .. index)
            if furniture == nil then
                local name = GetLang(self.mapItemData.config.zone_type_name)
                print("[error][CityMapZoneBuild] city id = " .. DataManager.GetCityId() .. ", " .. name .. " 找不到家具  path = " .. ("Room/model_furniture_" .. furnitureAssetName .. "_" .. index))
                return
            else
                -- if CityUtils.IsShowOrnaments() == false then 
                --     -- 装饰类家具，不显示
                --     return
                -- end
            end
        end

        local furnitureGo = furniture ~= nil and furniture.gameObject or nil
        if furnitureGo then
            self.furnitureViews[key] = furnitureGo
        end
    end

    if self.furnitureViews[key] then
        if level == 0 then
            self.furnitureViews[key]:SetActive(false)
            return
        end

        local assets_id = 1-- config.assets_id[level] 临时都是1
        self.furnitureViews[key]:SetActive(true)

        self.furnitureFlash = self.furnitureFlash or {}
        -- 床特殊处理，套死
        if furnitureAssetName == "bed" then
            local bedUp = self.furnitureViews[key].transform:Find("model_furniture_bed_up_"):GetComponent(typeof(SpriteRenderer))
            local bedDown = self.furnitureViews[key].transform:Find("model_furniture_bed_down_"):GetComponent(typeof(SpriteRenderer))
            if not self.furnitureFlash[key .. 1] then
                self.furnitureFlash[key .. 1] = true
                self:PlayWhiteFlash(bedUp, key .. 1)
            end
            if not self.furnitureFlash[key .. 2] then
                self.furnitureFlash[key .. 2] = true
               self:PlayWhiteFlash(bedDown, key .. 2)
            end
            -- local resNameUp = "model_furniture_" .. furnitureAssetName .. "_" .. "lv" .. assets_id .. "_1"
            -- local resNameDown = "model_furniture_" .. furnitureAssetName .. "_" .. "lv" .. assets_id .. "_2"
            -- Utils.SetIcon(bedUp, resNameUp)
            -- Utils.SetIcon(bedDown, resNameDown)
        else
            local furnGo = self.furnitureViews[key]
            local spRenderer = furnGo:GetComponent(typeof(SpriteRenderer)) or furnGo:GetComponentInChildren(typeof(SpriteRenderer))

            if (selectFurnitureId and selectFurnitureId == furnitureId) or selectFurnitureId == nil then
                if not self.furnitureFlash[key] then
                    self.furnitureFlash[key] = true
                    self:PlayWhiteFlash(spRenderer, key)
                end
            end

            local resName = "model_furniture_" .. furnitureAssetName .. "_" .. "lv" .. assets_id
            Utils.SetIcon(spRenderer, resName)
        end
    end
end

function ZoneBuild:PlayWhiteFlash(spriteRenderer, key)
    local material = spriteRenderer.sharedMaterial

    local cityMaterials = GameObject.Find("CityMaterials")
    local materialSpriteRenderer = cityMaterials.transform:Find("MaterialWhiteFlash"):GetComponent(typeof(SpriteRenderer))
    local tempMaterial = materialSpriteRenderer.material
    -- ResInterface.LoadMaterial("furniture-flash-white", function (_material)
    spriteRenderer.sharedMaterial = tempMaterial
    TimeModule.addDelay(0.2, function ()
        if spriteRenderer == nil then
            return
        end
            spriteRenderer.sharedMaterial = material
        self.furnitureFlash[key] = false
    end)
    -- end)
end

---设置建造进度条显示隐藏
function ZoneBuild:SetBuildProgressDisplay(display)
    if self.buildStatusUI == nil then
        return
    end

    local buildProgressObj, buildProgressSlider, buildProgressText = self:GetUIBuildProgress()
    buildProgressObj:SetActive(display)
end

---设置TtitleUI显示隐藏
function ZoneBuild:SetTitleUIDisplay(display)
    if self.buildStatusUI == nil then
        return
    end
    display = display and self.mapItemData:IsUnlock()
    local titleUI = self.buildStatusUI.transform:Find("Canvas/BuildTitle")
    if titleUI then
        titleUI.gameObject:SetActive(display)
    end
end

---设置生产项目UI显示隐藏
function ZoneBuild:SetProductionUIDisplay(display)
    EventManager.Brocast(EventDefine.CityProductionUIDisplay, display, self.zoneId)
end


---设置屋顶显示隐藏
function ZoneBuild:SetRoofDisplay(display)
    local OutsidePrb = self.transform:Find("Outside")
    if OutsidePrb then
        local roof = OutsidePrb:Find("roof").transform
        local roofWall = OutsidePrb:Find("roofWall")

        local hasClick = self.mapItemData:GetHasClick()
        if hasClick == false then
            display = true
        end
        if self.startBuild then
            display = true
        end
        if self.mapItemData:IsUnlock() then
            roof.gameObject:SetActive(display)
            if roofWall then
                roofWall.gameObject:SetActive(display)
            end
        end

    end
end

---设置建筑显示隐藏
function ZoneBuild:SetBuildActive(active)
    self.transform:Find("Room").gameObject:SetActive(active)
    -- self.transform:Find("Outside").gameObject:SetActive(active)

    local function activeOutside(_active)
        self.transform:Find("Outside/floor").gameObject:SetActive(_active)
        self.transform:Find("Outside/wall").gameObject:SetActive(_active)
        if self.transform:Find("Outside/Light 2D") == nil then
            return
        end
        self.transform:Find("Outside/Light 2D").gameObject:SetActive(_active)
        local roofWall = self.transform:Find("Outside/roofWall")
        if roofWall then
            roofWall.gameObject:SetActive(_active)
        end
    end

    -- -- 首次建造完成的时候
    -- if not self.transform:Find("Outside/floor").gameObject.activeSelf then
    --     TimeModule.addDelay(0.5, function ()
    --         if self and self.transform then
    --             activeOutside(active)
    --         end
    --     end)
    --     return
    -- end

    activeOutside(active)
    -- local roof = self.transform:Find("Outside/roof").gameObject
    -- roof:SetActive(false)
    -- if self.mapItemData:IsUnlock() then
    --     roof:SetActive(active)
    -- end


end

---设置建造光标显示隐藏 
function ZoneBuild:SetBuildCursor(active, spineActive)
    -- 净化器不需要显示建造光标
    if self.mapItemData.config.zone_type == ZoneType.Generator then
        return
    end

    spineActive = spineActive or false
    -- 正在加载中
    if self.cursor == nil and self.isLoadingCursor == nil then
        self.isLoadingCursor = true
        ResInterface.SyncLoadGameObject("BuildCursor", function (go)
            self.cursor = GOInstantiate(go, self.transform)

            -- local OutsidePrb = self.transform:Find("Outside")
            -- local roof = OutsidePrb:Find("roof").transform
            -- local target = self.transform:Find("Cursor") or self.transform
            -- self.cursor.transform.position = target.position

            local img = self.cursor.transform:Find("ImageCursor")
            local ani = self.cursor.transform:Find("E_empty_area")
            ani.gameObject:SetActive(spineActive)
            img.gameObject:SetActive(not spineActive)
            self.cursor:SetActive(active)
        end)
        return
    end

    if self.cursor ~= nil then
        local img = self.cursor.transform:Find("ImageCursor")
        local ani = self.cursor.transform:Find("E_empty_area")
        ani.gameObject:SetActive(spineActive)
        img.gameObject:SetActive(not spineActive)
        self.cursor:SetActive(active)
    end
end

---设置建筑虚影显示隐藏
function ZoneBuild:SetBuildPreShadow(active)
    local OutsidePrb = self.transform:Find("Outside")
    local roof = OutsidePrb:Find("roof").transform
    local walls = OutsidePrb:Find("wall").transform
    local floor = OutsidePrb:Find("floor").transform
    local roofRenderer = roof:GetComponent(typeof(SpriteRenderer))
    local roofSprite = roofRenderer.sprite

    if active and self.preShadow == nil and self.isLoadingBuildPreShadow == nil then
        self.isLoadingBuildPreShadow = true
        ResInterface.SyncLoadGameObject("BuildPreShadow", function (go)
            self.preShadow = GOInstantiate(go, self.transform)
            local imageBuild = SafeGetUIControl(self.preShadow, "roof", typeof(SpriteRenderer))
            imageBuild.sprite = roofSprite
            imageBuild.transform.position = roof.position
            if roofRenderer then
                imageBuild.sortingLayerName = roofRenderer.sortingLayerName
                imageBuild.sortingOrder = roofRenderer.sortingOrder
            end

            local imageFloor = SafeGetUIControl(self.preShadow, "floor", typeof(SpriteRenderer))
            imageFloor.sprite = floor:GetComponent(typeof(SpriteRenderer)).sprite
            imageFloor.transform.position = floor.position
            for i = 1, 5 do
                local wall = walls:Find("wall_" .. i)
                if wall then
                    local shadowWall = SafeGetUIControl(self.preShadow, "wall/wall_" .. i)
                    local shadowWallImage = SafeGetUIControl(self.preShadow, "wall/wall_" .. i, typeof(SpriteRenderer))
                    local wallRenderer = wall:GetComponent(typeof(SpriteRenderer))
                    if wallRenderer then
                        shadowWallImage.sortingLayerName = wallRenderer.sortingLayerName
                        shadowWallImage.sortingOrder = wallRenderer.sortingOrder
                        shadowWallImage.sprite = wall:GetComponent(typeof(SpriteRenderer)).sprite
                        shadowWallImage.transform.position = wall.position
                    end
                    shadowWall:SetActive(wallRenderer ~= nil)
                end
            end

            self.preShadow.transform.position = self.transform.position

            -- self.mapItemData:IsUnlock()
            self.preShadow:SetActive(self.mapItemData:IsUnlock() == false)
        end)
        return
    end

    if self.preShadow ~= nil then
        self.preShadow:SetActive(active)
    end
end

---建筑点击事件回调方法
function ZoneBuild:cbClickBuild()
end

function ZoneBuild:CheckStartBuild()
    if self.mapItemData:IsDeveloping() then 
        self.startBuild = true
        MapManager.AddBuildQueue(self.zoneId)
        self:SetRoofDisplay(true)
    end
end

--- 刷新升级倒计时
function ZoneBuild:UpdateBuildLeftTimeView()
    self.mapItemData:CheckBuildComplete()
    if self.mapItemData:GetBuildStatus() == BuildingStatus.Complete then
        MapManager.RemoveBuildQueue(self.zoneId)
        self.startBuild = false

        local developObj, developAnimation = self:GetUIDeveloping()

        local buildLevel = self.mapItemData:GetLevel()
        local aniName = buildLevel == 1 and "animation6" or "animation3"
        self:playBuidAnim(aniName, false, function ()
            developObj:SetActive(false)
            self.isUpgradingBuildAni = false
        end)
    end
end

---更新事件
function ZoneBuild:Update()
    -- 未初始化完成
    if not self.buildStatusUI then 
        return
    end

    self:upBuildingProgress()
    -- 这里是为了即时刷新建筑光标
    self:UpdateBuildCursor()
    self:UpdateBuildStatus()
end

function ZoneBuild:checkBuildStateIcon()
    self.updateTime = self.updateTime + Time.deltaTime
    if self.updateTime > 0.1 then
        self.updateTime = 0
        local cityId = DataManager.GetCityId()
        local mapItems = MapManager.GetMap(cityId)
        if mapItems == nil then return end
        local buildLevel = self.mapItemData:GetLevel()
        local buildUnlock = mapItems.zones[self.zoneId] ~= nil and buildLevel > 0
        if self.buildStatusUI ~= nil and buildUnlock then
            self:refreshStateIcon()
            -- self.buildText:RefreshLevelView()
        end
    end
end

function ZoneBuild:bindProductionUI()
    self.mapItemData:BindGridView()
end

function ZoneBuild:refresh()

end

function ZoneBuild:UpdateBuildView()

end
---只刷新cursor
function ZoneBuild:UpdateBuildCursor()
    local cityId = DataManager.GetCityId()
    local mapItems = MapManager.GetMap(cityId)

    if self.preShadow and self.preShadow.gameObject.activeSelf then
        self:SetBuildCursor(false)
        return
    end

    local mapItemData = self.mapItemData
    local buildLevel = mapItemData:GetLevel()
    local unlockData = mapItemData:GetUnlockLevelIsReady()
    local canUpgrade = false    -- 建筑是否满足了升级的材料花费需求
    if mapItems.zones[self.zoneId] == nil then
        local costIsReady = mapItemData:GetUnlockLevelCostIsReady()
        canUpgrade = costIsReady and unlockData["AllReady"]
    end

    local buildUnlock = mapItems.zones[self.zoneId] ~= nil and buildLevel > 0                   --建筑是否解锁
    local canUnlock = MapManager.GetCanLock(cityId, mapItemData.zoneId)
    local buildCanUnlock = unlockData and unlockData["AllReady"]    --建筑是否可以解锁
    self:SetBuildCursor(buildCanUnlock and (not buildUnlock) and canUnlock, canUpgrade)
end
---刷新cursor和建筑本身active
function ZoneBuild:UpdateBuildIcon()
    local cityId = DataManager.GetCityId()
    local mapItems = MapManager.GetMap(cityId)

    local mapItemData = self.mapItemData
    local buildLevel = mapItemData:GetLevel()
    local unlockData = mapItemData:GetUnlockLevelIsReady()
    local canUpgrade = false    -- 建筑是否满足了升级的材料花费需求
    if mapItems.zones[self.zoneId] == nil then
        local costIsReady = mapItemData:GetUnlockLevelCostIsReady()
        canUpgrade = costIsReady and unlockData["AllReady"]
    end

    local buildUnlock = mapItems.zones[self.zoneId] ~= nil and buildLevel > 0                   --建筑是否解锁
    local canUnlock = MapManager.GetCanLock(cityId, mapItemData.zoneId)
    local buildCanUnlock = unlockData and unlockData["AllReady"]    --建筑是否可以解锁
    self:SetBuildCursor(buildCanUnlock and (not buildUnlock) and canUnlock, canUpgrade)
    self:SetBuildActive(buildUnlock)
end
function ZoneBuild:ClearFurnitureView()

end
function ZoneBuild:RefreshStatus()
    if self.data.type == ZoneType.Generator then
        local status = GeneratorManager.GetStatus(self.cityId)
        if status == "Lack" then
            -- if self.tipItem == nil then
            --     self.tipItem = ResourceManager.Instantiate("ui/View/SceneViewGeneratorTip", self.mapUI)
            --     ---@type SceneViewGeneratorTip
            --     self.tipText = SceneViewGeneratorTip:Create(self.tipItem)
            --     self.tipItem.transform.position = self:GetTipPoint()
            --     self:UpdateLackTime()
            -- end
            EventManager.Brocast(EventDefine.ShowMainUITip,
                "toast_insufficient_fuel",
                ToastListIconType.FireWarning,
                false,
                3,
                "generator_insuffcient_assets"
            )
            -- if self.buildTextItem ~= nil then
            --     self.buildTextItem:SetActive(false)
            -- end
            self:ShowGeneratorLackTip()
        end
    end
end

-- 净化器建筑头顶显示 ui 燃料不足
function ZoneBuild:ShowGeneratorLackTip()
    local realShow = function()
        self.generatorTipUI:SetActive(true)
        local remainTime = GeneratorManager.ConsumptionLeftTime(self.cityId)
        self.gereratorTipText.text = GetLang("UI_generator_status_fuel_alert_tips", remainTime)

        local seq = DOTween.Sequence()
        seq:Append(self.generatorTipUI.transform:DOLocalMoveX(0, 0.5):SetEase(Ease.OutBack))
        seq:AppendInterval(3)
        seq:OnComplete(
            function()
                self.generatorTipUI:SetActive(false)
            end
        )
    end

    if self.gereratorTipResGuid == nil then
        self.gereratorTipResGuid =  ResInterface.SyncLoadGameObject("UIGeneratorWarning", function(go)
            if self.transform == nil then
                ResInterface.ReleaseRes(self.gereratorTipResGuid)
                self.gereratorTipResGuid = nil
            end

            self.generatorTipUI = GOInstantiate(go, self.transform)

            self.gereratorTipText = self.generatorTipUI.transform:Find("Content/TxtMassage"):GetComponent("Text")
            realShow()
        end)
    else
        if self.generatorTipUI then
            realShow()
        end
    end
end

function ZoneBuild:UpdateCampfireView()

end

---@private
---@param data HomeBuildingData
function ZoneBuild:_refreshData(data) end

function ZoneBuild:setData(data)
    if self.data == data then return end

    self.data = data

    self:_refreshData(data)
end

function ZoneBuild:eventOnSelf(key, callback)
    EventManager.AddListener(key, callback)
    table.insert(self.eventList, {event = key, handler = callback})
end
function ZoneBuild:RemoveEvent()
    if self.eventList == nil then return end
    for _, v in ipairs(self.eventList) do
        Event.RemoveListener(v.event, v.handler)
    end

    UpdateBeat:Remove(self.checkBuildStateIcon, self)
end

function ZoneBuild:destroy()
    -- Event.RemoveListener(EventDefine.OnCityBuildingUpdate, self._refreshData)
    if self.mapItemData then
        self.mapItemData:UnBindView()
    end

    if self.generatorTipUI then
        GODestroy(self.generatorTipUI)
        self.generatorTipUI = nil
    end

    if self.gereratorTipResGuid then
        ResInterface.ReleaseRes(self.gereratorTipResGuid)
        self.gereratorTipResGuid = nil
    end

    if self.BuildStatusImgTween then
        self.BuildStatusImgTween:Kill()
        self.BuildStatusImgTween = nil
    end

    GODestroy(self.gameObject)
    self:RemoveEvent()

    self.gameObject = nil
    self.transform = nil
end

-- 镜头拉近时，选中的建筑要显示装饰类家具
function ZoneBuild:ShowOrnaments()
    if self.OrnamentsGo and self.OrnamentsGo.activeSelf == false then
        self.OrnamentsGo:SetActive(true)
    end
end

function ZoneBuild:HideOrnaments()
    if self.OrnamentsGo and self.OrnamentsGo.activeSelf then
        self.OrnamentsGo:SetActive(false)
    end
end

return ZoneBuild
