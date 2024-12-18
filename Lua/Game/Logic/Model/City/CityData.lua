---@class CityData
CityData = Clone(CityBase)
CityData.__cname = "CityData"

function CityData:OnInit()
    self.infinityMaterial = {}
    for index, materialType in pairs(self.cityConfig.infinity_resource) do
        self.infinityMaterial[materialType] = true
    end
    self.allBag = {}
    self.viewDelayBag = {}
    self.cityBagData = DataManager.GetCityDataByKey(self.cityId, DataKey.Bag)
    self.globalBagData = DataManager.GetGlobalDataByKey(DataKey.Bag)
    local initItemList = ConfigManager.GetInitItemList(self.cityId)
    initItemList:ForEach(
        function(item)
            if item.scope == "City" then
                local count = (tonumber(self.cityBagData[item.id]) or 0) * 1.0
                self.allBag[item.id] = NumberRx:New(count)
                self.allBag[item.id]:subscribe(
                    function(val)
                        self.cityBagData[item.id] = tostring(val)
                        DataManager.userData["city" .. self.cityId][DataKey.Bag] = self.cityBagData
                        -- DataManager.SetCityDataByKey(self.cityId, DataKey.Bag, self.cityBagData)
                    end,
                    false
                )
            elseif item.scope == "Global" then
                local count = (tonumber(self.globalBagData[item.id]) or 0) * 1.0
                if DataManager.globalRx[item.id] == nil then
                    DataManager.globalRx[item.id] = NumberRx:New(count)
                end
                self.allBag[item.id] = DataManager.globalRx[item.id]
                self.allBag[item.id].value = count
                self.allBag[item.id]:subscribe(
                    function(val)
                        self.globalBagData[item.id] = tostring(val)
                        DataManager.userData.global[DataKey.Bag] = self.globalBagData
                        -- DataManager.SetGlobalDataByKey(DataKey.Bag, self.globalBagData)
                    end,
                    false
                )
            end
        end
    )
    self:MergeCharacterData()
end

function CityData:MergeCharacterData()
    local characterData = DataManager.GetCityDataByKey(self.cityId, DataKey.CharacterData)
    local zoneDatas = DataManager.GetCityDataByKey(self.cityId, DataKey.Zones)
    local professionTypeModify = {}
    local needSave = false

    --修改职业
    local function ModifyProfessionType(professionType)
        if nil == professionType then
            return true
        end
        if professionType == ProfessionType.FreeMan then
            return false
        end
        if professionTypeModify[professionType] == false then
            return false
        end
        if professionTypeModify[professionType] == nil then
            local needModify = true
            local peopleConfig = ConfigManager.GetPeopleConfigByType(self.cityId, professionType)
            if nil ~= peopleConfig then
                ConfigManager.GetZoneIdsByZoneType(self.cityId, peopleConfig.zone_type):ForEach(
                    function(zoneId)
                        if zoneDatas[zoneId] and zoneDatas[zoneId].finished and zoneDatas[zoneId].level >= 1 then
                            needModify = false
                            return true
                        end
                    end
                )
            end
            professionTypeModify[professionType] = needModify
        end
        return professionTypeModify[professionType]
    end

    --遍历小人数据，检测职业是否需要修正
    local function EacheCharacterInfo(id, info)
        local isModify = false
        if nil == info.id then
            info.id = id
            isModify = true
        end
        if nil == info.serialNumber then
            info.serialNumber = characterData.serialNumber
            characterData.serialNumber = characterData.serialNumber + 1
            isModify = true
        end
        if nil == info.isNew then
            info.isNew = true
            isModify = true
        end
        if nil == info.state then
            info.state = EnumState.Normal
            isModify = true
        end
        if ModifyProfessionType(info.professionType) then
            info.professionType = ProfessionType.FreeMan
            isModify = true
        end
        if nil == info.gender then
            info.gender = Utils.GetGender(info.serialNumber)
            isModify = true
        end
        if nil == info.skinId then
            info.skinId = Utils.GetSkinId(info.serialNumber)
            isModify = true
        end
        if nil == info.attributeInfo then
            info.attributeInfo = Utils.GetAttributeInfo(self.cityId)
            isModify = true
        end
        if nil == info.markState then
            info.markState = EnumMarkState.None
            isModify = true
        end
        if isModify then
            needSave = true
        end
    end
    --老数据从数组结构变为散列表结构
    if characterData.version == nil then
        local infosCopy = {}
        for index, info in ipairs(characterData.infos) do
            EacheCharacterInfo(info.id, info)
            infosCopy[info.id] = Clone(info)
        end
        local characterDataNew = {}
        characterDataNew.serialNumber = characterData.serialNumber
        characterDataNew.fillTypes = Clone(characterData.fillTypes)
        characterDataNew.infos = infosCopy
        characterDataNew.version = 2
        DataManager.SetCityDataByKey(self.cityId, DataKey.CharacterData, characterDataNew)
    elseif characterData.version == 1 then
        characterData.attributeRecords = nil
        for id, info in pairs(characterData.infos) do
            info.attributeRecords = nil
            EacheCharacterInfo(id, info)
        end
        characterData.version = 2
        DataManager.SetCityDataByKey(self.cityId, DataKey.CharacterData, characterData)
    else
        for id, info in pairs(characterData.infos) do
            EacheCharacterInfo(id, info)
        end
        if needSave then
            DataManager.SetCityDataByKey(self.cityId, DataKey.CharacterData, characterData)
        end
    end
end

function CityData:OnClear()
    self = nil
end

--判断原材料这个场景是否无正无穷
function CityData:CheckInfinity(materialType)
    return self.infinityMaterial[materialType] == true
end

--获得原材料数量Rx
function CityData:GetMaterialRx(materialType)
    return self.allBag[materialType] or NumberRx:New(0)
end

function CityData:GetMaterialDelayRx(materialType)
    local itemId = materialType .. "_Delay"
    if self.allBag[itemId] == nil then
        self.allBag[itemId] = NumberRx:New(0)
    end
    return self.allBag[itemId]
end

--获得原材料数量
function CityData:GetMaterialCount(materialType)
    if self:CheckInfinity(materialType) then
        return MathUtil.maxinteger
    end
    local ret = 0
    if self.allBag[materialType] then
        ret = self.allBag[materialType].value
    end
    return ret
end

--获得原材料数量
function CityData:GetMaterialCountFormat(materialType, noDelay)
    -- if self:CheckInfinity(materialType) then
    --     return GetLang("ui_infinity_name")
    -- end

    -- if self.allBag[materialType] == nil then
    -- end

    -- return Utils.FormatCount(self.allBag[materialType].value)
    return self:GetViewMaterialCountFormat(materialType, noDelay)
end

--获得用于显示的原材料数量（已计算resEffct延迟）
function CityData:GetViewMaterialCountFormat(materialType, noDelay)
    if self:CheckInfinity(materialType) then
        return GetLang("ui_infinity_name")
    end

    if self.allBag[materialType] == nil then
        print("[error]" .. "not found material: " .. materialType)
    end

    local delay = self:GetViewDelayValue(materialType)
    if noDelay then
        delay = 0
    end

    local viewValue = self.allBag[materialType].value - delay

    return Utils.FormatCount(viewValue)
end

function CityData:GetViewDelayValue(materialType)
    if self.viewDelayBag[materialType] == nil then
        return 0
    end
    return self.viewDelayBag[materialType]
end

--设置原材料
function CityData:SetMaterial(materialType, val, to, toId)
    val = tonumber(val)
    self.allBag[materialType].value = val
end

--使用原材料
function CityData:UseMaterial(materialType, val, to, toId)
    val = tonumber(val)
    if self:CheckInfinity(materialType) then
        return
    end
    self.allBag[materialType].value = self.allBag[materialType].value - val
    if val > 0 then
        EventManager.Brocast(EventType.USE_ITEM, self.cityId, materialType, val)
    end
    if to ~= "Delay" then
        local csObj = {
            currency = materialType,
            value = val,
            balance = self.allBag[materialType].value,
            to = to,
            totoId = toId
        }
        Analytics.CurrencySink(csObj)
    end
end

--添加原材料
function CityData:AddMaterial(materialType, val, from, fromId)
    val = tonumber(val)
    if self:CheckInfinity(materialType) then
        return
    end
    if self.allBag[materialType] == nil then
        print("[error] materialType:" .. materialType .. "," .. "cityId:" .. self.cityId .. "," .. debug.traceback())
        return
    end
    self.allBag[materialType].value = self.allBag[materialType].value + val
    if val > 0 then
        EventManager.Brocast(EventType.COLLECT_ITEM, self.cityId, materialType, val)
    end
end

--添加原材料延时显示数量
function CityData:AddMaterialViewDelay(materialType, val)
    val = tonumber(val)
    local itemId = materialType .. "_Delay"
    if self.allBag[itemId] == nil then
        self.allBag[itemId] = NumberRx:New(0)
    end
    if self.viewDelayBag[materialType] == nil then
        self.viewDelayBag[materialType] = 0
    end
    self.viewDelayBag[materialType] = self.viewDelayBag[materialType] + val
    self:AddMaterial(itemId, val, "Delay", itemId)
end

function CityData:CostMaterialViewDelay(materialType, val)
    val = tonumber(val)
    local itemId = materialType .. "_Delay"
    self.viewDelayBag[materialType] = self.viewDelayBag[materialType] - val
    self:UseMaterial(itemId, val, "Delay", itemId)
end

function CityData:ClearMaterialViewDelay()
    for materialType, val in pairs(self.viewDelayBag) do
        local itemId = materialType .. "_Delay"
        self:UseMaterial(itemId, val, "Delay", itemId)
    end
    self.viewDelayBag = {}
end

--判断原材料是否足够
function CityData:CheckMaterials(input)
    local ret = true
    for itemId, count in pairs(input) do
        if self:GetMaterialCount(itemId) < tonumber(count) then
            ret = false
            break
        end
    end
    return ret
end

--使用原材料 By一个字典
function CityData:UseMaterials(input, to, toId)
    for itemId, count in pairs(input) do
        self:UseMaterial(itemId, count, to, toId)
    end
end

--添加原材料 By一个字典
function CityData:AddMaterials(output, from, fromId)
    for itemId, count in pairs(output) do
        self:AddMaterial(itemId, count, from, fromId)
    end
end
