---@class UIPeopleCell
local Element = class("UIPeopleCell")
UIPeopleCell = Element
require "Game/Logic/NewView/Manage/PersonCell"

function Element:ctor()

end

function Element:InitPanel(behaviour, obj, PersonItem, peopleConfig)
    self.gameObject = obj
    self.transform = obj.transform
    self.behaviour = behaviour
    self.PersonItem = PersonItem

    if self.uidata == nil then self.uidata = {} end
    self.uidata.ImageIcon = SafeGetUIControl(self, "ImageIcon", "Image")
    self.uidata.ImageItemIcon = SafeGetUIControl(self, "ImageItemIcon", "Image")
    self.uidata.TextPre = SafeGetUIControl(self, "TextPre", "Text")
    self.uidata.TextBuild = SafeGetUIControl(self, "lab/TextBuild", "Text")
    self.uidata.TextJob = SafeGetUIControl(self, "lab/TextJob", "Text")
    self.uidata.ButtonSub = SafeGetUIControl(self, "ButtonSub")
    self.uidata.ButtonAdd = SafeGetUIControl(self, "ButtonAdd")
    self.uidata.Content = SafeGetUIControl(self, "Content")

    self.cityId = DataManager.GetCityId()
    self.peopleConfig = peopleConfig
    local zoneId = ConfigManager.GetZoneIdByZoneType(self.cityId, self.peopleConfig.zone_type)
    self.mapItemData = MapManager.GetMapItemData(self.cityId, zoneId)

    Utils.SetZoneBonusIcon(self.mapItemData.config.id, self.uidata.ImageItemIcon, nil, nil, UINames.UIManage)
    Utils.SetZoneIcon(self.uidata.ImageIcon, zoneId, 1) -- ImageBuildState

    UIUtil.AddZone(self.uidata.ImageIcon, self.mapItemData.config.id, UINames.UIManage, self.mapItemData:GetLevel())

    local typeLang = ""
    if self.peopleConfig.people_name ~= "" then
        typeLang = GetLang(self.peopleConfig.people_name)
    end

    self.uidata.TextBuild.text = self.mapItemData:GetName()
    self.uidata.TextJob.text = typeLang
    -- Utils.SetZoneBonusIcon(self.mapItemData.config.id, self.ResIcon, self.ResIconBg)

    local zoneType = self.peopleConfig.zone_type
    local furnitureId = self.peopleConfig.furniture_id
    local unlockIndexs = MapManager.GetUnlockFurnitureIndexs(self.cityId, zoneType, furnitureId)
    self.unlockIndexs = unlockIndexs
    -- 小人列表
    self.workStateList = List:New()
    for i = 1, unlockIndexs:Count(), 1 do
        local grid = GridManager.GetGridByFurnitureId(self.cityId, furnitureId, unlockIndexs[i], GridStatus.Unlock)
        self.workStateList:Add(grid:GetFurnitureWorkState())
    end

    self.peopleList = {}

    UIUtil.RemoveAllGameobject(self.uidata.Content.transform)
    self:OnUpdate()

    SafeAddClickEvent(self.behaviour, self.uidata.ButtonAdd, function()
        GameManager.TeQuanAuto = true
        self:Assignment()
    end)

    SafeAddClickEvent(self.behaviour, self.uidata.ButtonSub, function()
        GameManager.TeQuanAuto = true
        self:CancelAssignment()
    end)
end

function Element:OnUpdate()
    local canUseToolCount = self.mapItemData:GetCanUseToolCount()
    local peopleStateCount = CharacterManager.GetPeopleStateCount(self.cityId, self.peopleConfig.type)
    local normalCount = peopleStateCount[EnumState.Normal] or 0
    local sickCount = peopleStateCount[EnumState.Sick] or 0
    local protestCount = peopleStateCount[EnumState.Protest] or 0
    local maxCount = math.min(self.unlockIndexs:Count(), canUseToolCount)
    local totalCount = normalCount + sickCount + protestCount
    local omWork = self.mapItemData:GetCanWorkTool()

    self.uidata.TextPre.text = omWork .. "/" .. maxCount

    GreyObject(self.uidata.ButtonAdd, totalCount >= maxCount, totalCount < maxCount)
    GreyObject(self.uidata.ButtonSub, totalCount <= 0, totalCount > 0)


    -- 排序
    self.workStateList:Sort(
        function(s1, s2)
            if s1 == s2 then
                return false
            end
            return s1 < s2
        end
    )

    self.workCount = 0
    self.notWorkCount = 0

    -- 小人
    for i = 1, self.workStateList:Count(), 1 do
        local workState = WorkStateType.None
        local hasPeople = true
        if i <= normalCount then
            workState = self.workStateList[i]
        elseif i <= normalCount + sickCount then
            if self.workStateList[i] ~= WorkStateType.Disable then
                workState = WorkStateType.Sick
            else
                workState = self.workStateList[i]
            end
        elseif i <= normalCount + sickCount + protestCount then
            if self.workStateList[i] ~= WorkStateType.Disable then
                workState = WorkStateType.Protest
            else
                workState = self.workStateList[i]
            end
        else
            hasPeople = false
            if self.workStateList[i] ~= WorkStateType.Work then
                workState = self.workStateList[i]
            end
        end
        if hasPeople then
            if workState == WorkStateType.Work then
                self.workCount = self.workCount + 1
            elseif workState ~= WorkStateType.None then
                self.notWorkCount = self.notWorkCount + 1
            end
        end

        local needLevel = self.mapItemData:GetFurnitureNeedCardLevel(self.mapItemData:GetToolFurnitureId(), i)

        if self.peopleList[i] then
            self.peopleList[i]:OnRefresh(workState, hasPeople, needLevel)
        else
            local go = GOInstantiate(self.PersonItem)
            go.transform:SetParent(self.uidata.Content.transform, false)
            SafeSetActive(go.gameObject, true)
            local item = PersonCell.new()
            item:InitPanel(self.behaviour, go, workState, hasPeople, needLevel)

            table.insert(self.peopleList,item)
        end
    end
end

--分配
function Element:Assignment()
    if CharacterManager.Assignment(self.cityId, self.peopleConfig.type) then
        self:OnUpdate()
    else
        -- GameToast.Instance:Show(GetLang("UI_People_NO_Person"), ToastIconType.Warning)
        UIUtil.showText(GetLang("UI_People_NO_Person"))
    end
end

--取消分配
function Element:CancelAssignment()
    if CharacterManager.CancelAssignment(self.cityId, self.peopleConfig.type) then
        self:OnUpdate()
    end
end
