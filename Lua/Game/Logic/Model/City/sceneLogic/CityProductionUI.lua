---@class CityProductionUI @城市生产项目UI
local Element = class("CityProductionUI")
CityProductionUI = Element

function Element:ctor()
    self.gameObject = nil
    self.isBind = false
end

function Element:bind(go)
    self.isBind = true
    self.gameObject = go
end

function Element:init(params)
    if self.isBind == false then
        return
    end
    self.zoneId = params.zoneId or nil
    self.mapItemData = MapManager.GetMapItemData(DataManager.GetCityId(), self.zoneId)
    self.activeSelf = self.gameObject.activeSelf

    local itemProduction = SafeGetUIControl(self.gameObject, "ItemProduction")
    itemProduction:SetActive(true)

    self.Image = SafeGetUIControl(self.gameObject, "ItemProduction/Icon", "Image")
    self.Fill = SafeGetUIControl(self.gameObject, "ItemProduction/Slider", "Slider")   
    self.PauseIcon = SafeGetUIControl(self.gameObject, "ItemProduction/Pause") 
    self.LockIcon = SafeGetUIControl(self.gameObject, "ItemProduction/Lock")

    local function activeGo(display)
        if self.mapItemData == nil then 
            self.mapItemData = MapManager.GetMapItemData(DataManager.GetCityId(), self.zoneId)
            if self.mapItemData == nil then 
                return 
            end 
        end
        if self.mapItemData:GetHasClick() == false then
            display = false
        end

        if self.activeSelf == display then 
            return
        end

        self.activeSelf = display
        if isNil(self.gameObject) then 
            if self.removeListener then 
                self.removeListener()
                self.removeListener = nil
            end
        else 
            self.gameObject:SetActive(display)
        end
    end
    self.activeGo = activeGo

    EventManager.AddListener(EventDefine.CityProductionUIDisplay, activeGo)
    self.removeListener = function ()
        EventManager.RemoveListener(EventDefine.CityProductionUIDisplay, activeGo)
    end

    self.itemIdRx = NumberRx:New(params.itemId)
    self.progressRx = NumberRx:New(params.progress)
    self.selectSpriteRx = NumberRx:New(params.selectSprite)
    self.iconRx = NumberRx:New(params.icon)
    self.rxList = List:New()
    self.rxList:Add(
        self.itemIdRx:subscribe(
            function(id)
                if id == -1 then
                    Utils.SetIcon(self.Image, "icon_worker_people_reset_1", function ()
                        self.Image:SetNativeSize()
                    end, true)
                    self.Image.transform.localScale = Vector3.New(0.6, 0.6, 1)
                else
                    if id ~= nil and type(id) == "string" then
                        Utils.SetItemIcon(self.Image, id, true, true)
                        self.Image.transform.localScale = Vector3.New(0.35, 0.35, 1)
                    end
                end
            end
        )
    )
    
    self.rxList:Add(
        self.progressRx:subscribe(
            function(value)
                self.Fill.value = value
            end
        )
    )
    self.rxList:Add(
        self.selectSpriteRx:subscribe(
            function(index)
                if index == 0 then
                    self.PauseIcon:SetActive(true)
                    self.LockIcon:SetActive(false)
                elseif index == 1 then
                    self.PauseIcon:SetActive(false)
                    self.LockIcon:SetActive(false)
                elseif index == 2 then
                    self.PauseIcon:SetActive(false)
                    self.LockIcon:SetActive(true)
                end
            end
        )
    )

    self.rxList:Add(
            self.iconRx:subscribe(
                    function(active)
                        if self.activeSelf == active then 
                            return
                        end
                
                        self.activeSelf = active
                        self.gameObject:SetActive(active)
                    end
            )
    )

    self:UpdateView(params)
end

function Element:UpdateView(params)
    if self.isBind == false then
        return
    end
    if self.itemIdRx.value ~= params.itemId then
        self.itemIdRx.value = params.itemId
    end
    if self.progressRx.value ~= params.progress then
        self.progressRx.value = params.progress
    end
    if self.selectSpriteRx.value ~= params.selectSprite then
        self.selectSpriteRx.value = params.selectSprite
    end
    if self.iconRx.value ~= params.icon then
        self.iconRx.value = params.icon
    end

    local isShow = not CityModule.getMainCtrl().camera:getRoofActive()
    isShow = isShow or false
    self.activeGo(isShow)
end

function Element:Clear()
    for k = 1, self.rxList:Count() do
        self.rxList[k]:unsubscribe()
    end
    self:removeListener()
end