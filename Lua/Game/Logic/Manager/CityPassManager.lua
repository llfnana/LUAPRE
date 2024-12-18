---@class CityPassManager
CityPassManager = {}
CityPassManager.__cname = "CityPassManager"
local this = CityPassManager

function CityPassManager.Init()
    this.cityId = DataManager.GetCityId()
    this.cityPassCoroutine = nil
    this.cityBuildingCoroutine = {}
    this.playNextPass = false
    this.isPlayingNextPass = false
    this.isPlayingCityPass = false
    if this.hasInit then
        return
    end
    this.hasInit = true
    --this.waitCityPassSeconds = WaitForSeconds(0.1)

    ---@type CityPassEffect cityPassEffectPanel
    this.cityPassEffectPanel = nil
end

function CityPassManager.Log(msg)
end

this.test = true
function CityPassManager.PlayCityPassTest()
    this.OpenSummaryPanel()
    -- if this.test then
    --     local function CityPassController()
    --         --打开结算面板
    --         this.OpenSummaryPanel()
    --     end
    --     this.cityPassCoroutine = UnityEngine.StartCoroutine(CityPassController)
    -- else
    --     this.StopCelebrateAnimation()
    -- end

    -- this.test = not this.test
end

function CityPassManager.Summary()
    --打开结算面板
    this.OpenSummaryPanel()
    Audio.PlayAudio(DefaultAudioID.OpenSummary)

    --wait
    -- this.WaitCityPass(-1)

    -- DataManager.lockSave = true
    -- MainUI.Instance:SetMainUIState(false)
    -- if MainUI.Instance.freezeboot ~= nil then
    --     MainUI.Instance.freezeboot:SetActive(false)
    -- end

    --初始化build
    -- this.ShowInitBuildView()
end

function CityPassManager.Celebrate()
    --初始化
    this.PlayCelebrateAnimation()

    --播放build动画
    this.PlayMapForRebuildAnimation()

    --播放庆祝动画
    --this.PlayCelebrateEffect()

    --wait
    this.WaitCityPass(0.01)

    --播放暴风雪动画
    this.PlayCityPassEffect()

    --wait
    this.WaitCityPass(2)
    AudioManager.PlayEffect("amb_firework_stop")
    AudioManager.PlayEffect("amb_trans_generator_stop")

    --wait
    this.WaitCityPass(2.5)
    AudioManager.PlayEffect("ui_rebuild_build_stop")
end

function CityPassManager.MapPass()
    --打开地图面板
    this.OpenBigMapPanel()

    --wait
    this.WaitCityPass(0.1)

    if this.cityPassEffectPanel ~= nil then
        PopupManager.Instance:ClosePanel(this.cityPassEffectPanel)
        this.cityPassEffectPanel = nil
    end

    --wait
    this.WaitCityPass(0.8)

    --结束庆祝动画
    CityPassManager.StopCelebrateAnimation()

    this.StopCityPass()
end

--开始过长
function CityPassManager.PlayCityPass()
    this.Summary()
    -- local function CityPassController()

    --     this.Celebrate()

    --     this.MapPass()
    -- end
    -- this.StopCityPass()
    -- this.cityPassCoroutine = UnityEngine.StartCoroutine(CityPassController)
    -- this.isPlayingCityPass = true
end

function CityPassManager.PlayNextPass()
    this.isPlayingNextPass = true
    UIMainPanel.HideMainUI()
    --关闭UI毒气特效
    if UIMainPanel and UIMainPanel.uidata then
        UIMainPanel.StopDq()
    end
    this.PlayCelebrateAnimation()
    ---移动相机到中心点【更改小人、英雄的位置以及播放庆祝动作】
    Audio.PlayAudio(DefaultAudioID.HuanHu)
    local zoneId = ConfigManager.GetZoneIdByZoneType(this.cityId, ZoneType.Generator)
    local ctrl = CityModule.getMainCtrl() ---@type City.MainCtrl
    local build = ctrl.buildDict[zoneId].gameObject
    local floor = build.transform:Find("Outside/floor")

    ---镜头聚焦以及镜头持续拉高
    TimeModule.addDelay(0, function()
        ctrl.camera:zoomTo(floor, 1)
    end)
    TimeModule.addDelay(0.26, function()
        ctrl.camera:DoCameraSize(-100, 2)
    end)
    ---播放净化的风扩散，镜头拉远，营地周围的毒气散开， 直到俯瞰整个营地，毒气彻底消散
    WeatherManager.ChangeWeather(DataManager.GetCityId(), WeatherType.None)
    Audio.PlayAudio(DefaultAudioID.JingHuaFeng)

    ---播放建筑落下动画
    local tween = DOTween.Sequence()

    local index = 0
    local posOffset = Vector3(0, 0.2, 0)
    for k, v in pairs(ctrl.buildDict) do
        SafeSetActive(v.gameObject, false)
        v.transform.localPosition = v.transform.localPosition + posOffset
    end
    for k, v in pairs(ctrl.buildDict) do
        TimeModule.addDelay(0.1 * index, function()
            SafeSetActive(v.gameObject, true)
            v.transform:DOLocalMove(v.transform.localPosition - posOffset, 0.3):SetEase(Ease.OutCubic)
        end)
        index = index + 1
    end

    local buildEndTime = 0.1 * index
    local yhStartTime = buildEndTime + 0.5
    ---播放烟花、暴风雪特效
    local yhTime = 1.3
    TimeModule.addDelay(yhStartTime, function()
        if UIMainPanel.uidata then
            UIMainPanel.PlayEffectYH()
            Audio.PlayAudio(DefaultAudioID.YanHua)
        end
    end)

    local dqStartTime = yhStartTime + yhTime
    local dqTime = 0
    TimeModule.addDelay(dqStartTime, function()
    end)

    ---过场效果
    local interludeStartTime = dqStartTime + dqTime
    local interludeTime = 3.36
    TimeModule.addDelay(interludeStartTime, function()
        ShowUI(UINames.UIEffect)
    end)

    ---关卡到下一关动画 提前加载界面
    local goNextStartTime = interludeStartTime + interludeTime - 0.36
    TimeModule.addDelay(goNextStartTime, function()
        UIMainPanel.PlayDq()
        ShowUI(UINames.UIMap, {
            isPass = true,
            callback = function()
                this.isPlayingCityPass = false
            end
        })
    end)

    -- this.Celebrate()

    -- this.MapPass()
end

function CityPassManager.WaitCityPass(waitTime)
    if waitTime > 0 then
        UnityEngine.YieldReturn(WaitForSeconds(waitTime))
    else
        while (not this.playNextPass) do
            UnityEngine.YieldReturn(this.waitCityPassSeconds)
        end
        this.playNextPass = false
    end
end

function CityPassManager.StopCityPass()
    if this.cityPassCoroutine ~= nil then
        UnityEngine.StopCoroutine(this.cityPassCoroutine)
        this.cityPassCoroutine = nil
    end
    for zoneId, coroutine in pairs(this.cityBuildingCoroutine) do
        if coroutine ~= nil then
            UnityEngine.StopCoroutine(coroutine)
        end
    end
    this.cityBuildingCoroutine = {}

    AudioManager.PlayEffect("amb_firework_stop")
    AudioManager.PlayEffect("amb_trans_generator_stop")
    AudioManager.PlayEffect("ui_rebuild_build_stop")
   -- CameraEffectManager.ClearFreezeJieingEffect()
   -- CameraEffectManager.ClearCityPassEffect()

    this.isPlayingCityPass = false
end

--打开总结面板
function CityPassManager.OpenSummaryPanel()
    -- local panel = PopupManager.Instance:OpenPanel(PanelType.CityPassSummary)
    -- panel.ClosePanelAction = function()
    --     this.PlayNextPass()
    -- end
    ShowUI(UINames.UICityPassSummary, this.PlayNextPass)
end

--重置build显示
function CityPassManager.ShowInitBuildView()
    -- local map = Map.Instance
    -- local initZones = CityManager.GetInitCityZoneData(this.cityId)
    -- local zonesConfigList = ConfigManager.GetZonesByCityId(this.cityId)
    -- zonesConfigList:ForEachKeyValue(
    --     function(zoneId, zone)
    --         local mapItemData = MapItemData:New()
    --         mapItemData:InitData(this.cityId, zoneId, initZones[zoneId])
    --         local mapItem = map.zoneIdToMapItem[zoneId]
    --         if mapItem ~= nil then
    --             if initZones[zoneId] ~= nil then
    --                 mapItem:ShowEmptyView(mapItemData)
    --             else
    --                 mapItem:ShowBuildViewByMapItemData(mapItemData)
    --             end
    --         end
    --     end
    -- )

    -- local foodSystem = FoodSystemManager.GetFoodSystem(this.cityId)
    -- if foodSystem ~= nil then
    --     foodSystem:ClearView()
    -- end
end

--播放build动画
function CityPassManager.PlayMapForRebuildAnimation()
    AudioManager.PlayEffect("ui_rebuild_build")
    --CameraEffectManager.PlayFreezeJieingEffect()

    local map = Map.Instance
    --local size = ConfigManager.GetMiscConfig("default_camera_size") - 5;
    local cameraSize = 60
    local maxFieldOfView = Map.Instance.sceneScript.maxFieldOfView
    if cameraSize >= maxFieldOfView then
        cameraSize = maxFieldOfView - 10
    end
    local centerPos = MainUI.Instance:GetCenterPos()
    map:FocusPos(centerPos, Vector3(0, 0, -1), cameraSize, 0)
    UnityEngine.YieldReturn(WaitForSeconds(0.5))

    ---@type Gennerator genneratorItem
    local genneratorItem = nil
    local sortZoneId = map:GetMapItemBySort()
    local count = sortZoneId:Count()

    local totalTime = 0
    for i = 1, count do
        local zoneId = sortZoneId[i]
        local zoneConfig = ConfigManager.GetZoneConfigById(zoneId)
        if zoneConfig ~= nil then
            totalTime = totalTime + zoneConfig.rebuild_animation_interval
        end
    end

    Map.Instance:DoCameraSizeByEase(maxFieldOfView, totalTime + 3, 0.5, Ease.OutExpo)

    for i = 1, count do
        local zoneId = sortZoneId[i]
        local mapItem = map.zoneIdToMapItem[zoneId]

        if MapManager.IsValidZoneId(this.cityId, zoneId) then
            local mapItemData = MapManager.GetMapItemData(this.cityId, zoneId)
            --map:FocusPos(centerPos, mapItemData:GetZonePoint(), cameraSize - 10)
            --UnityEngine.YieldReturn(waitSeconds1)
            --mapItem:ShowBuildViewByMapItemData(mapItemData, false, 1)
            --mapItem:ShowUpgradeEffect(true)
            --UnityEngine.YieldReturn(waitSeconds2)

            local level = 1
            local assets = mapItemData:GetBuildLevelAssets(level)
            mapItem:ShowBuildViewByMapItemData(mapItemData, true, level)
            if mapItemData.config.zone_type == ZoneType.Generator then
                genneratorItem = mapItem
                genneratorItem:HideAllCampfire()
            end

            local zoneConfig = ConfigManager.GetZoneConfigById(zoneId)
            local buildingCoroutine =
                UnityEngine.StartCoroutine(
                    function()
                        level = level + 1
                        while mapItemData:HasBuildLevelAssets(level) do
                            if assets ~= mapItemData:GetBuildLevelAssets(level) then
                                --UnityEngine.YieldReturn(WaitForSeconds(0.4))
                                UnityEngine.YieldReturn(WaitForSeconds(zoneConfig.rebuild_levelup_interval))
                                mapItem:ShowBuildViewByMapItemData(mapItemData, false, level)
                            end
                            assets = mapItemData:GetBuildLevelAssets(level)
                            level = level + 1
                        end
                        this.cityBuildingCoroutine[zoneId] = nil
                    end
                )
            this.cityBuildingCoroutine[zoneId] = buildingCoroutine

            if zoneConfig ~= nil then
                UnityEngine.YieldReturn(WaitForSeconds(zoneConfig.rebuild_animation_interval))
            end
        end
    end

    local waitCoroutine = true
    while waitCoroutine do
        local isOver = true
        for zoneId, coroutine in pairs(this.cityBuildingCoroutine) do
            if coroutine ~= nil then
                isOver = false
                break
            end
        end
        if isOver then
            waitCoroutine = false
        else
            UnityEngine.YieldReturn(0.01)
        end
    end

    UnityEngine.YieldReturn(WaitForSeconds(0.5))

    if genneratorItem ~= nil then
        AudioManager.PlayEffect("amb_trans_generator")
        genneratorItem:ShowAllCampfire()
        UnityEngine.YieldReturn(WaitForSeconds(1))
        AudioManager.PlayEffect("amb_firework")
        -- local celebrateEffect =
        --     ResourceManager.Instantiate("prefab/enviroment/effect/effect_zhuansheng_qingzhu", genneratorItem.transform)
        -- celebrateEffect.transform.localPosition = Vector3(0, 0, 0)
        UnityEngine.YieldReturn(WaitForSeconds(1.5))
    end

    --CameraEffectManager.ClearFreezeJieingEffect()

    Analytics.Event(
        "CityAnimationPlayCompleted",
        {
            currentCityId = this.cityId,
            nextCityId = this.cityId + 1
        }
    )

    --map:FocusPos(centerPos, Vector3(0, 0, -1), cameraSize - 10)
    --UnityEngine.StartCoroutine(ResetMapView)
end

--播放庆祝动画
function CityPassManager.PlayCelebrateAnimation()
    -- Map.Instance.uiRoot.gameObject:SetActive(false)
    local characters = CharacterManager.GetAllCharactersByList(this.cityId)
    for i = 1, characters:Count(), 1 do
        characters[i]:SetNextState(EnumState.Celebrate)
    end
    -- local heroes = MapManager.GetAllHeroByList(this.cityId)
    -- for i = 1, heroes:Count(), 1 do
    --     heroes[i]:SetNextState(EnumState.Celebrate)
    -- end

    -- local panel = PopupManager.Instance:OpenPanel(PanelType.CityPassEffect)
    -- panel.ClosePanelAction = function()
    --     local map = Map.Instance
    --     map.zoneIdToMapItem:ForEachKeyValue(
    --         function(zoneId, mapItem)
    --             if MapManager.IsValidZoneId(this.cityId, zoneId) then
    --                 local mapItemData = MapManager.GetMapItemData(this.cityId, zoneId)
    --                 mapItem:ShowBuildViewByMapItemData(mapItemData, true)
    --             end
    --         end
    --     )
    --     local function CityPassController()
    --         this.MapPass()
    --     end
    --     this.StopCityPass()
    --     this.cityPassCoroutine = UnityEngine.StartCoroutine(CityPassController)
    --     this.cityPassEffectPanel = nil
    -- end

    -- this.cityPassEffectPanel = panel

    -- CameraEffectManager.ClearBigSnowEff()
end

--播放暴风雪动画 :冰和风特效
function CityPassManager.PlayCityPassEffect()
    AudioManager.PlayEffect("amb_trans_storm")
    CameraEffectManager.PlayCityPassEffect()
end

--播放小人庆祝动画
--function CityPassManager.PlayCelebrateEffect()
--    local characters = CharacterManager.GetAllCharactersByList(this.cityId)
--    for i = 1, characters:Count(), 1 do
--        characters[i]:PlayCelebrateEffect()
--    end
--end

--结束庆祝动画
function CityPassManager.StopCelebrateAnimation()
    Map.Instance.uiRoot.gameObject:SetActive(true)
    local characters = CharacterManager.GetAllCharactersByList(this.cityId)
    --local characters = CharacterManager.GetCharactersByStateType(this.cityId, EnumState.Celebrate)
    for i = 1, characters:Count(), 1 do
        local state = characters[i].info.state
        characters[i]:PlayAnimEx(AnimationType.Walk)
        characters[i]:SetNextState(EnumState.Normal)
        characters[i]:SetNextSchedules()
    end

    local heroes = MapManager.GetAllHeroByList(this.cityId)
    for i = 1, heroes:Count(), 1 do
        heroes[i]:PlayAnimEx(AnimationType.Walk)
        heroes[i]:SetNextState(EnumState.Normal)
        heroes[i]:SetNextSchedules()
    end

    if this.cityPassEffectPanel ~= nil then
        PopupManager.Instance:ClosePanel(this.cityPassEffectPanel)
        this.cityPassEffectPanel = nil
    end

    MainUI.Instance:SetMainUIState(true)
    if MainUI.Instance.freezeboot ~= nil then
        MainUI.Instance.freezeboot:SetActive(true)
    end
    DataManager.lockSave = false
end

--打开地图Panel
function CityPassManager.OpenBigMapPanel()
    local panel =
        PopupManager.Instance:OpenPanel(
            PanelType.SelectScenePanel,
            {
                currentMapType = MapUIManager.MapType.ScaleSmall
            }
        )
    panel:PlayUnlockAnimation()
    Audio.PlayAudio(DefaultAudioID.JieSuo)
    panel.ClosePanelAction = function()
        this.PlayNextPass()
    end
end

--切换地图
function CityPassManager.SwitchScene()
    while (GameManager.GetModeType() == ModeType.ChangeScene) do
        UnityEngine.YieldReturn(this.waitCityPassSeconds)
    end
end

--保存小人死亡数据
function CityPassManager.AddDeathCount(count)
    local cityPassData = DataManager.GetCityDataByKey(this.cityId, DataKey.CityPass)
    if cityPassData == nil then
        DataManager.SetCityDataByKey(this.cityId, DataKey.CityPass, {})
        cityPassData = DataManager.GetCityDataByKey(this.cityId, DataKey.CityPass)
    end

    if cityPassData.deathCount == nil then
        cityPassData.deathCount = count
    else
        cityPassData.deathCount = cityPassData.deathCount + count
    end

    DataManager.SaveCityData(this.cityId)
end

--获取小人死亡数据
function CityPassManager.GetDeathCount()
    local cityPassData = DataManager.GetCityDataByKey(this.cityId, DataKey.CityPass)
    if cityPassData == nil then
        return 0
    end
    if cityPassData.deathCount == nil then
        return 0
    end

    return cityPassData.deathCount
end
