Utils = {}
Utils.__index = Utils
local this = Utils
local Funit = {
    "K",
    "M",
    "B",
    "T",
    "aa",
    "bb",
    "cc",
    "dd",
    "ee",
    "ff",
    "gg",
    "hh",
    "ii",
    "jj",
    "kk",
    "ll",
    "mm",
    "nn",
    "oo",
    "pp",
    "qq",
    "rr",
    "ss",
    "tt",
    "uu",
    "vv",
    "ww",
    "xx",
    "yy",
    "zz"
}

----zzh add from md5 20230322
-- bit lib implementions
local function check_int(n)
    -- checking not float
    if (n - math.floor(n) > 0) then
        error("trying to use bitwise operation on non-integer!")
    end
    local mike = 1
    t = 1
    --local mike = 2
end

local function tbl_to_number(tbl)
    local n = #tbl

    local rslt = 0
    local power = 1
    for i = 1, n do
        rslt = rslt + tbl[i] * power
        power = power * 2
    end

    return rslt
end

local function expand(tbl_m, tbl_n)
    local big = {}
    local small = {}
    if (#tbl_m > #tbl_n) then
        big = tbl_m
        small = tbl_n
    else
        big = tbl_n
        small = tbl_m
    end
    -- expand small
    for i = #small + 1, #big do
        small[i] = 0
    end
end

local to_bits = function()
end

local function bit_not(n)
    local tbl = to_bits(n)
    local size = math.max(#tbl, 32)
    for i = 1, size do
        if (tbl[i] == 1) then
            tbl[i] = 0
        else
            tbl[i] = 1
        end
    end
    return tbl_to_number(tbl)
end

to_bits = function(n)
    check_int(n)
    if (n < 0) then
        -- negative
        return to_bits(bit_not(math.abs(n)) + 1)
    end
    -- to bits table
    local tbl = {}
    local cnt = 1
    while (n > 0) do
        local last = math.fmod(n, 2)
        if (last == 1) then
            tbl[cnt] = 1
        else
            tbl[cnt] = 0
        end
        n = (n - last) / 2
        cnt = cnt + 1
    end

    return tbl
end

local function bit_or(m, n)
    local tbl_m = to_bits(m)
    local tbl_n = to_bits(n)
    expand(tbl_m, tbl_n)

    local tbl = {}
    local rslt = math.max(#tbl_m, #tbl_n)
    for i = 1, rslt do
        if (tbl_m[i] == 0 and tbl_n[i] == 0) then
            tbl[i] = 0
        else
            tbl[i] = 1
        end
    end

    return tbl_to_number(tbl)
end

local function bit_and(m, n)
    local tbl_m = to_bits(m)
    local tbl_n = to_bits(n)
    expand(tbl_m, tbl_n)

    local tbl = {}
    local rslt = math.max(#tbl_m, #tbl_n)
    for i = 1, rslt do
        if (tbl_m[i] == 0 or tbl_n[i] == 0) then
            tbl[i] = 0
        else
            tbl[i] = 1
        end
    end

    return tbl_to_number(tbl)
end

local function bit_xor(m, n)
    local tbl_m = to_bits(m)
    local tbl_n = to_bits(n)
    expand(tbl_m, tbl_n)

    local tbl = {}
    local rslt = math.max(#tbl_m, #tbl_n)
    for i = 1, rslt do
        if (tbl_m[i] ~= tbl_n[i]) then
            tbl[i] = 1
        else
            tbl[i] = 0
        end
    end

    --table.foreach(tbl, print)

    return tbl_to_number(tbl)
end
-- >>
local function bit_rshift(n, bits)
    check_int(n)

    local high_bit = 0
    if (n < 0) then
        -- negative
        n = bit_not(math.abs(n)) + 1
        high_bit = 2147483648 -- 0x80000000
    end

    for i = 1, bits do
        n = n / 2
        n = bit_or(math.floor(n), high_bit)
    end
    return math.floor(n)
end
-->>
-- logic rightshift assures zero filling shift
local function bit_logic_rshift(n, bits)
    check_int(n)
    if (n < 0) then
        -- negative
        n = bit_not(math.abs(n)) + 1
    end
    for i = 1, bits do
        n = n / 2
    end
    return math.floor(n)
end
--<<
local function bit_lshift(n, bits)
    check_int(n)

    if (n < 0) then
        -- negative
        n = bit_not(math.abs(n)) + 1
    end

    for i = 1, bits do
        n = n * 2
    end
    return bit_and(n, 4294967295) -- 0xFFFFFFFF
end

local function bit_xor2(m, n)
    local rhs = bit_or(bit_not(m), bit_not(n))
    local lhs = bit_or(m, n)
    local rslt = bit_and(lhs, rhs)
    return rslt
end

----zzh end from md5 20230322

--浮点转int
function Utils.RoundToInt(v)
    local a, b = math.modf(v)
    if b > 0.5 then
        a = a + 1
    end
    return a
end

-- y < 4096, z < 1024, x < 1024
function Utils.PositionToGridId(x, y, z)
    --return y << 12 | z << 10 | x
    return x*1000 + z
    --return bit_or(bit_or(bit_lshift(y, 12), bit_lshift(z, 10)), x)
end

--hanabi modify
function Utils.GridIdToPosition(girdId)
    local x = girdId / 1000
    local y = 0
    local z = girdId % 1000

    --local mask = 0x000003FF
    ----local x = girdId & mask
    --local x = bit_and(girdId, mask)
    ---- local z = girdId >> 10 & mask
    --local z = bit_and(bit_rshift(girdId, 10), mask)
    ----local y = girdId >> 20 & mask
    --local y = bit_and(bit_rshift(girdId, 20), mask)
    return x, y, z
end

--- 通过 Cell 获取 Grid
--- @param cell any
--- @return unknown
function Utils.GetGridByCell(cell)
    local grid_id = Utils.PositionToGridId(cell.position.x, 0, cell.position.y)
    return GridManager.GetGridById(DataManager.userData.global.cityId, grid_id)
end

--- 通过 x, y 获取 Grid
--- @param x any
--- @param y any
--- @return unknown
function Utils.GetGridByXY(x, y)
    local grid_id = Utils.PositionToGridId(x, 0, y)
    return GridManager.GetGridById(DataManager.userData.global.cityId, grid_id)
end

--拉姆达表达式
function Utils.LamdaExpression(b, value1, value2)
    if b then
        return value1
    else
        return value2
    end
end

--使用区域编号升序排序格子
function Utils.SortGridByAscendingUseZoneNumber(g1, g2)
    if g1:GetZoneNumber() == g2:GetZoneNumber() then
        return false
    end
    return g1:GetZoneNumber() < g2:GetZoneNumber()
end

--使用编号升序排序格子
function Utils.SortGridByAscendingUseSerialNumber(g1, g2)
    if g1.serialNumber == g2.serialNumber then
        return false
    end
    return g1.serialNumber < g2.serialNumber
end

--使用编号降序排序格子
function Utils.SortGridByDescendingUseSerialNumber(g1, g2)
    if g1.serialNumber == g2.serialNumber then
        return false
    end
    return g1.serialNumber > g2.serialNumber
end

--使用索引升序排序格子
function Utils.SortGridByAscendingUseMarkerIndex(g1, g2)
    if g1.markerIndex == g2.markerIndex then
        return false
    end
    return g1.markerIndex < g2.markerIndex
end

--使用健康升序排序角色
function Utils.SortCharacterByAscendingUseHealth(c1, c2)
    local h1 = c1:GetAttribute(AttributeType.Hunger) + c1:GetAttribute(AttributeType.Rest)
    local h2 = c2:GetAttribute(AttributeType.Hunger) + c2:GetAttribute(AttributeType.Rest)
    if h1 == h2 then
        return false
    end
    return h1 > h2
end

--使用健康降叙排序角色
function Utils.SortCharacterByDescendingUseHealth(c1, c2)
    local h1 = c1:GetAttribute(AttributeType.Hunger) + c1:GetAttribute(AttributeType.Rest)
    local h2 = c2:GetAttribute(AttributeType.Hunger) + c2:GetAttribute(AttributeType.Rest)
    if h1 == h2 then
        return false
    end
    return h1 < h2
end

--使用角色编号排序
function Utils.SortCharacterBySerialNumber(c1, c2)
    local sn1 = c1:GetSerialNumber()
    local sn2 = c2:GetSerialNumber()
    if sn1 == sn2 then
        return false
    end
    return sn1 < sn2
end

function Utils.SortCharacterByHealCount(c1, c2)
    local sn1 = c1:GetHealCount()
    local sn2 = c2:GetHealCount()
    if sn1 == sn2 then
        return false
    end
    return sn1 > sn2
end

--是否是家具
function Utils.IsFurnitureGrid(markerType)
    if
        markerType == GridMarker.None or markerType == GridMarker.Door or markerType == GridMarker.Idle or
        markerType == GridMarker.Queue or
        markerType == GridMarker.Born or
        markerType == GridMarker.TutorialBorn or
        markerType == GridMarker.TutorialCardBorn or
        markerType == GridMarker.TutorialCardDelete or
        markerType == GridMarker.Items or
        markerType == GridMarker.Hunt or
        markerType == GridMarker.Stairs or
        markerType == GridMarker.Doctor or
        markerType == GridMarker.Speech or
        markerType == GridMarker.Protest or
        markerType == GridMarker.Protest2 or
        markerType == GridMarker.Special1ForIdle or
        markerType == GridMarker.Special2ForIdle or
        markerType == GridMarker.Special3ForIdle or
        markerType == GridMarker.VanBorn or
        markerType == GridMarker.VanQueue or
        markerType == GridMarker.VanDestroy or
        markerType == GridMarker.Occlusion  
    then
        return false
    end
    return true
end

function Utils.IsQueueGrid(markerType)
    if markerType == GridMarker.Queue or markerType == GridMarker.VanQueue then
        return true
    end
    return false
end

--是否是升序格子
function Utils.IsAscendingGrid(markerType)
    if
        markerType == GridMarker.None or markerType == GridMarker.Idle or markerType == GridMarker.Born or
        markerType == GridMarker.Items or
        markerType == GridMarker.Hunt or
        markerType == GridMarker.Table or
        markerType == GridMarker.Stairs
    then
        return false
    end
    return true
end

--编号排序
function Utils.IsSortGrid(markerType)
    -- if this.IsAscendingGrid(markerType) then
    --     return true
    -- end
    -- return false
    if markerType == GridMarker.Bed then
        return true
    end
    return false
end

--是否是缓存格子
function Utils.IsCacheGrid(markerType)
    if
        markerType == GridMarker.Door or markerType == GridMarker.Born or markerType == GridMarker.Hunt or
        markerType == GridMarker.OfficeBorn or
        markerType == GridMarker.TutorialBorn
    then
        return true
    end
    return false
end

--根据属性类型获取状态条图片名
function Utils.GetCharacterStateSliderName(attributeType)
    if attributeType == AttributeType.Warm then
        return "dorm_img_gas"
    elseif attributeType == AttributeType.Hunger then
        return "dorm_img_hunger"
    elseif attributeType == AttributeType.Rest then
        return "dorm_img_rest_2"
    end
end

--根据属性类型获取状态条进度条背景名
function Utils.GetCharacterStateSliderBgName(attributeType)
    if attributeType == AttributeType.Warm then
        return "dorm_img_gas_0"
    elseif attributeType == AttributeType.Hunger then
        return "dorm_img_hunger_1"
    elseif attributeType == AttributeType.Rest then
        return "dorm_img_rest"
    end
end

--根据属性类型获取索引
function Utils.GetSelectIndexByAttributeType(attributeType)
    if attributeType == AttributeType.Warm then
        return 0
    elseif attributeType == AttributeType.Hunger then
        return 1
    elseif attributeType == AttributeType.Rest then
        return 2
    elseif attributeType == AttributeType.Fun then
        return 3
    elseif attributeType == AttributeType.Security then
        return 4
    elseif attributeType == AttributeType.Comfort then
        return 5
    elseif attributeType == AttributeType.EventStrike then
        return 6
    end
end

--根据索引获取属性类型
function Utils.GetAttributeTypeBySelectIndex(index)
    if index == 0 then
        return AttributeType.Warm
    elseif index == 1 then
        return AttributeType.Hunger
    elseif index == 2 then
        return AttributeType.Rest
    elseif index == 3 then
        return AttributeType.Fun
    elseif index == 4 then
        return AttributeType.Security
    elseif index == 5 then
        return AttributeType.Comfort
    elseif index == 6 then
        return AttributeType.EventStrike
    end
end

--根据状态类型获取索引
function Utils.GetSelectIndexByEnumState(state)
    if state == EnumState.Normal then
        return 1
    elseif state == EnumState.HealthLow then
        return 2
    elseif state == EnumState.Severe then
        return 3
    elseif state == EnumState.Sick then
        return 4
    elseif state == EnumState.Dead then
        return 5
    elseif state == EnumState.Protest then
        return 6
    elseif state == EnumState.Celebrate then
        return 7
    elseif state == EnumState.EventStrike then
        return 8
    elseif state == EnumState.RunAway then
        return 9
    else
        return 0
    end
end

--根据索引获取状态类型
function Utils.GetEnumStateBySelectIndex(index)
    if index == 1 then
        return EnumState.Normal
    elseif index == 2 then
        return EnumState.HealthLow
    elseif index == 3 then
        return EnumState.Severe
    elseif index == 4 then
        return EnumState.Sick
    elseif index == 5 then
        return EnumState.Dead
    elseif index == 6 then
        return EnumState.Protest
    elseif index == 7 then
        return EnumState.Celebrate
    elseif index == 8 then
        return EnumState.EventStrike
    elseif index == 9 then
        return EnumState.RunAway
    else
        return 0
    end
end

function Utils._SetImg(comp, name, callback, active, native)
    if isNil(comp) then 
        error(debug.traceback())
        return
    end

    if name == nil then
        return
    end

    local sprite = nil
    ResInterface.SyncLoadSpritePng(name, function(_sprite)
        if isNil(comp) == false then 
            comp.sprite = _sprite

            if active ~= nil then 
                comp.gameObject:SetActive(active)
            end

            if native then 
                comp:SetNativeSize()
            end
        end

        if callback then
            callback()
        end
    end)
end

--设置路径获取图片
function Utils.SetIcon(imageComp, name, callback, active, native)
    Utils._SetImg(imageComp, name, callback, active, native)
end

--设置常用的图片
function Utils.SetCommonIcon(imageComp, type, callback)
    Utils._SetImg(imageComp, string.format("icon_%s", type), callback, true)
end


--获取常用的图片
function Utils.GetCommonIcon(type)
    local sprite = nil
    ResInterface.SyncLoadSpritePng(string.format("icon_%s", type), function(_sprite)
        sprite = _sprite
    end)
    return sprite
end

--设置属性图片
function Utils.SetAttributeIcon(imageComp, type, callback)
    Utils._SetImg(imageComp, string.format("icon_%s", string.lower(type)), callback, true)
end

--设置物品图片
function Utils.SetItemIcon(imageComp, itemId, nativeSize, active)
    local itemConfig = ConfigManager.GetItemConfig(itemId)
    if itemConfig == nil then
        print("[error] Item表里不存在 itemId = " .. itemId,  debug.traceback())
        return nil
    end
    Utils._SetImg(imageComp, itemConfig.icon, nil, active, nativeSize)
end

--获取物品图片
function Utils.GetItemIcon(itemId)
    local itemConfig = ConfigManager.GetItemConfig(itemId)
    if itemConfig == nil then
        print("[error] item config is nil.itemId = " .. itemId)
        return nil
    end
    local sprite = nil
    ResInterface.SyncLoadSpritePng(itemConfig.icon, function(_sprite)
        sprite = _sprite
    end)
    return sprite
end


--设置宝箱icon
function Utils.SetIBoxIcon(imageComp, boxId, active)
    local box = ConfigManager.GetBoxConfig(boxId)

    Utils._SetImg(imageComp, box.icon, nil, active)
end

--设置宝箱icon图片
function Utils.SetBoxIcon(imageComp, boxId, nativeSize, active)
    local box = ConfigManager.GetBoxConfig(boxId)
    if box == nil then
        error(debug.traceback())
        return nil
    end

    Utils._SetImg(imageComp, box.icon, nil, active, nativeSize)
end

--获取Card的图片
function Utils.SetCardIcon(ImageIcon, type)
    Utils._SetImg(ImageIcon, string.format("icon_%s", type))
end

--获取CardBoost的图片
function Utils.GetCardBoostIcon(icon)
    return ResourceManager.Load(string.format("images/icon_card/%s", icon), TypeSprite)
end

--设置Card头像的图片
function Utils.SetCardHeroIcon(ImageIcon, cardId, isNativeSize, scale)
    local config = ConfigManager.GetCardConfig(tonumber(cardId)) 
    if not config then 
        print("英雄头像不存在 cardId = " .. cardId, debug.traceback())
        return
    end

    Utils._SetImg(ImageIcon, string.format("card_icon_%s", ConfigManager.GetCardConfig(tonumber(cardId)).picture), function()
        if scale and isNil(ImageIcon) == false then
            ImageIcon.transform.localScale = Vector2(scale, scale)
        end
    end, true, isNativeSize)
end

--设置Card头像的图片
function Utils.SetCardHeroIconByColor(ImageIcon, color, isNativeSize, scale)
    Utils._SetImg(ImageIcon, string.format("icon_mini_card_%s_random", color), function()
        if scale and isNil(ImageIcon) == false then
            ImageIcon.transform.localScale = Vector2(scale, scale)
        end
    end, true, isNativeSize)
end

--设置奖励Icon和bg
---当类型为card时，返回2个结果，icon和bg
function Utils.SetRewardIcon(reward, iconImage, bgImage)
    if reward.addType == RewardAddType.Item or reward.addType == RewardAddType.OverTime then
        Utils.SetItemIcon(iconImage, reward.id, nil, true)
    elseif reward.addType == RewardAddType.Card then
        if reward.id ~= nil then
            Utils.SetCardHeroIcon(iconImage, reward.id)
        else
            -- 返回问号图
            Utils.SetIcon(iconImage, "icon_dead", nil, true)
        end
    elseif reward.addType == RewardAddType.Box then
        Utils.SetIBoxIcon(iconImage, reward.id, true)
    elseif reward.addType == RewardAddType.ItemOverTime then
        -- 返回时间产出图标
        Utils.SetIcon(iconImage, "icon_dead", nil, true)
    elseif reward.addType == RewardAddType.OpenBox then
        -- 返回开宝箱图标
        Utils.SetIBoxIcon(iconImage, reward.id, true)
    end
end

--设置奖励Icon和bg
---当类型为card时，返回2个结果，icon和bg
---icon套装
function Utils.SetRewardIcon2(reward, iconImage, iconImage2, bgImage, fgImage)
    iconImage2.gameObject:SetActive(true)
    -- bgImage.gameObject:SetActive(true)
    fgImage.gameObject:SetActive(true)
    iconImage.transform.localScale = Vector3(1, 1, 1)
    if
        reward.addType == RewardAddType.Item or reward.addType == RewardAddType.OverTime or
        reward.addType == RewardAddType.DailyItem
    then
        iconImage.sprite = Utils.GetItemIcon(reward.id)
        iconImage2.gameObject:SetActive(false)
        bgImage.gameObject:SetActive(false)
        fgImage.gameObject:SetActive(false)
        iconImage.transform.localScale = Vector3(1.2, 1.2, 1)
    elseif reward.addType == RewardAddType.Card then
        if reward.id ~= nil then
            Utils.SetCardHeroIcon(iconImage, reward.id)
            iconImage2.gameObject:SetActive(false)
        else
            iconImage.sprite = ResourceManager.Load("images/icon_card/icon_card_mini_add_hero_shedow", TypeSprite)
            -- bgImage.sprite =
            --     ResourceManager.Load(
            --     string.format("images/icon_card/icon_card_mini_quality_%s", reward.color),
            --     TypeSprite
            -- )
            iconImage2.sprite = ResourceManager.Load("images/symbol/symbol_random", TypeSprite)
        end

        -- fgImage.sprite = ResourceManager.Load("images/icon_card/icon_card_mini_flame", TypeSprite)
    elseif reward.addType == RewardAddType.Box then
        Utils.SetBoxIcon(iconImage, reward.id)
        iconImage2.gameObject:SetActive(false)
        bgImage.gameObject:SetActive(false)
        fgImage.gameObject:SetActive(false)
        iconImage.transform.localScale = Vector3(1.2, 1.2, 1)
    elseif reward.addType == RewardAddType.ItemOverTime then
        -- 返回时间产出图标，还没有
        iconImage.sprite = ResourceManager.Load("images/icon/icon_dead", TypeSprite)
        iconImage2.gameObject:SetActive(false)
        bgImage.gameObject:SetActive(false)
        fgImage.gameObject:SetActive(false)
        iconImage.transform.localScale = Vector3(1.2, 1.2, 1)
    elseif reward.addType == RewardAddType.OpenBox then
        -- box图标单独做，所以不需要放大
        Utils.SetBoxIcon(iconImage, reward.id)
        iconImage2.gameObject:SetActive(false)
        bgImage.gameObject:SetActive(false)
        fgImage.gameObject:SetActive(false)
    elseif reward.addType == RewardAddType.Boost then
        local boostCfg = ConfigManager.GetBoostConfig(reward.id)
        iconImage.sprite = this.GetCardBoostIcon(boostCfg.icon)
        iconImage2.gameObject:SetActive(false)
        bgImage.gameObject:SetActive(false)
        fgImage.gameObject:SetActive(false)
        iconImage.transform.localScale = Vector3(1.2, 1.2, 1)
    elseif reward.addType == RewardAddType.ProtestPeople then
        iconImage.sprite = ResourceManager.Load("images/icon/icon_riots", TypeSprite)
        iconImage2.gameObject:SetActive(false)
        bgImage.gameObject:SetActive(false)
        fgImage.gameObject:SetActive(false)
    end
end

function Utils.SetRewardTooltips(reward, icon, from)
    -- if
    --     reward.addType == RewardAddType.Item or reward.addType == RewardAddType.DailyItem or
    --     reward.addType == RewardAddType.OverTime
    -- then
    --     ToolTipManager.AddItem(icon, reward.id)
    -- elseif reward.addType == RewardAddType.Box or reward.addType == RewardAddType.OpenBox then
    --     -- ToolTipManager.AddTitleToolTip(icon, GetLang(box.desc), GetLang(box.name))
    --     local box = ConfigManager.GetBoxConfig(reward.id)
    --     ToolTipManager.AddBoxReward(icon, reward.id)
    -- elseif reward.addType == RewardAddType.Card and reward.color ~= nil then
    --     ToolTipManager.AddTitleToolTip(
    --         icon,
    --         GetLangFormat("item_desc_randomCard", GetLang("ui_card_color_" .. reward.color), reward.count),
    --         GetLangFormat("item_name_randomCard", GetLang("ui_card_color_" .. reward.color))
    --     )
    -- elseif reward.addType == RewardAddType.Card and reward.id ~= nil then
    --     ToolTipManager.AddClick(
    --         icon.gameObject,
    --         function()
    --             PopupManager.Instance:OpenPanel(
    --                 PanelType.CardInfoPanel,
    --                 {
    --                     cardItemData = CardManager.CreateFullCardItem(ConfigManager.GetCardConfig(reward.id)),
    --                     readyOnly = true,
    --                     from = from
    --                 }
    --             )
    --         end
    --     )
    -- elseif reward.addType == RewardAddType.Boost then
    --     ToolTipManager.AddBoostDescToolTip(icon, reward)
    -- end
end

---新版UI设计使用 jiaxing 8/29/2022
---待所有UI界面替换完成后废弃SetRewardIcon2接口
function Utils.SetRewardIcon3(reward, iconImage, iconImage2, bgImage, fgImage)
    iconImage2.gameObject:SetActive(true)
    bgImage.gameObject:SetActive(true)
    fgImage.gameObject:SetActive(true)
    iconImage.transform.localScale = Vector3(1, 1, 1)
    if
        reward.addType == RewardAddType.Item or reward.addType == RewardAddType.OverTime or
        reward.addType == RewardAddType.DailyItem
    then
        iconImage2.sprite = Utils.GetItemIcon(reward.id)
        iconImage.gameObject:SetActive(false)
        bgImage.gameObject:SetActive(false)
        fgImage.gameObject:SetActive(false)
        iconImage.transform.localScale = Vector3(1.2, 1.2, 1)
    elseif reward.addType == RewardAddType.Card then
        if reward.id ~= nil then
            Utils.SetCardHeroIcon(iconImage, reward.id)
            iconImage2.gameObject:SetActive(false)
        else
            iconImage.sprite = ResourceManager.Load("images/icon_card/icon_card_mini_add_hero_shedow", TypeSprite)
            iconImage2.sprite = ResourceManager.Load("images/symbol/symbol_random", TypeSprite)
        end
    elseif reward.addType == RewardAddType.Box then
        Utils.SetBoxIcon(iconImage2, reward.id)
        iconImage.gameObject:SetActive(false)
        bgImage.gameObject:SetActive(false)
        fgImage.gameObject:SetActive(false)
        iconImage.transform.localScale = Vector3(1.2, 1.2, 1)
    elseif reward.addType == RewardAddType.ItemOverTime then
        -- 返回时间产出图标，还没有
        iconImage2.sprite = ResourceManager.Load("images/icon/icon_dead", TypeSprite)
        iconImage.gameObject:SetActive(false)
        bgImage.gameObject:SetActive(false)
        fgImage.gameObject:SetActive(false)
        iconImage.transform.localScale = Vector3(1.2, 1.2, 1)
    elseif reward.addType == RewardAddType.OpenBox then
        -- box图标单独做，所以不需要放大
        Utils.SetBoxIcon(iconImage2, reward.id)
        iconImage.gameObject:SetActive(false)
        bgImage.gameObject:SetActive(false)
        fgImage.gameObject:SetActive(false)
    elseif reward.addType == RewardAddType.Boost then
        local boostCfg = ConfigManager.GetBoostConfig(reward.id)
        iconImage2.sprite = this.GetCardBoostIcon(boostCfg.icon)
        iconImage.gameObject:SetActive(false)
        bgImage.gameObject:SetActive(false)
        fgImage.gameObject:SetActive(false)
        iconImage.transform.localScale = Vector3(1.2, 1.2, 1)
    end
end

---设置奖励icon，第4版
---icon套装
---@param reward Reward
function Utils.SetRewardIcon4(reward, icon, bg, count, prefix_count, nativeSize)
    if reward.addType == RewardAddType.Item or reward.addType == RewardAddType.OverTime or
        reward.addType == RewardAddType.DailyItem
    then
        Utils.SetItemIcon(icon, reward.id, nativeSize, true)
    elseif reward.addType == RewardAddType.Card then
        if reward.id ~= nil then
            Utils.SetCardHeroIcon(icon, reward.id, nativeSize)
        elseif reward.color ~= nil then 
            -- 配置了颜色
            Utils.SetCardHeroIconByColor(icon, reward.color, nativeSize)
            -- icon.sprite = ResourceManager.Load("images/icon_card/icon_card_mini_add_hero_shedow", TypeSprite)
        end
    elseif reward.addType == RewardAddType.Box then
        Utils.SetBoxIcon(icon, reward.id, nativeSize, true)
    elseif reward.addType == RewardAddType.ItemOverTime then
        -- 返回时间产出图标，还没有
        icon.sprite = ResourceManager.Load("images/icon/icon_dead", TypeSprite)
        icon.gameObject:SetActive(true)
    elseif reward.addType == RewardAddType.OpenBox then
        this.SetBoxIcon(icon, reward.id, nativeSize, true)
    elseif reward.addType == RewardAddType.Boost then
        local boostCfg = ConfigManager.GetBoostConfig(reward.id)
        this.GetCardBoostIcon(boostCfg.icon)
        icon.gameObject:SetActive(true)
    end

    if count ~= nil then
        count.text = (prefix_count or "") .. this.FormatCount(reward.count)
    end
end

function Utils.SetZoneIcon(ImageIcon, zoneId, level, isNativeSiz)
    local zoneCfg = ConfigManager.GetZoneConfigById(zoneId)
    local resName = zoneCfg and zoneCfg.icon[level] or "icon_zone_Empty"
    
    ResInterface.AsyncLoadSpritePng(resName, function(_sprite)
        if isNil(ImageIcon) == false then 
            ImageIcon.sprite = _sprite
            if isNativeSiz then
                ImageIcon:SetNativeSize()
            end
            ImageIcon.gameObject:SetActive(true)
        end
    end)
end

function Utils.SetIconItem(ImageIcon, icon)
    ResInterface.AsyncLoadSpritePng(icon, function(_sprite)
        ImageIcon.sprite = _sprite
    end)
end

function Utils.GetZoneBonus(zoneId)
    local zoneCfg = ConfigManager.GetZoneConfigById(zoneId)
    if zoneCfg then
        if zoneCfg.zone_bonus then
            return zoneCfg.zone_bonus
        else
        end
    else
    end
end

function Utils.SetZoneBonusIcon(zoneId, bonusIconImage, callback)
    -- if dir == nil then
    --     dir = ToolTipDir.Up
    -- end
    local zoneCfg = ConfigManager.GetZoneConfigById(zoneId)

    local itemId = ""
    --- 特殊处理，当建筑是厨房时，使用实时的数据
    if zoneCfg.zone_type == ZoneType.Kitchen then
        itemId = DataManager.GetCityDataByKey(DataManager.GetCityId(), DataKey.FoodType)
        Utils.SetItemIcon(bonusIconImage, itemId)
        -- UIUtil.AddItem(bonusIconImage, itemId, dir)
        return
    end

    local tryItem = string.match(zoneCfg.zone_bonus, "item_(%w+)")
    local tryIcon = string.match(zoneCfg.zone_bonus, "attr_(%w+)")
    local bonusIcon = nil

    if tryItem ~= nil then
        Utils.SetItemIcon(bonusIconImage, tryItem)
        -- UIUtil.AddItem(bonusIconImage, tryItem, dir, panel)
    elseif tryIcon ~= nil then
        Utils.SetAttributeIcon(bonusIconImage, string.lower(tryIcon))
        -- UIUtil.AddAttribute(bonusIconImage, tryIcon, false, dir)
    else

        return
    end
end

-- 设置zone图片
function Utils.SetZoneIconByType(ImageIcon, cityId, zoneType, level, isNativeSize)
    local zoneList = ConfigManager.GetZonesByCityId(cityId)
    local zoneIIcon = ""

    zoneList:ForEachKeyValue(
        function(key, value)
            if value.zone_type == zoneType and value.city_id == cityId then
                zoneIIcon = value.icon[level]
                return true
            end

            return false
        end
    )

    ResInterface.AsyncLoadSpritePng(zoneIIcon, function(_sprite)
        ImageIcon.sprite = _sprite

        if isNativeSize then
            ImageIcon:SetNativeSize()
        end

    end)
end

--设置Card半身图片
function Utils.SetCardHeroHalfPic(imageComp, cardId, callback)
    local sprite = nil
    ResInterface.SyncLoadSpritePng(string.format("hero_head_%s", cardId), function(_sprite)
        if isNil(imageComp) == false then 
            imageComp.sprite = _sprite
            imageComp.gameObject:SetActive(true)
        end
        
        if callback then
            callback()
        end
    end)
end

--设置Build半身图片
function Utils.SetCardHeroBuildPic(imageComp, cardId, callback)
    local sprite = nil
    local picturenName = string.format("hero_head_%s", cardId)
    ResInterface.SyncLoadSpritePng(picturenName, function(_sprite)
        imageComp.sprite = _sprite
        imageComp.gameObject:SetActive(true)
        if callback then
            callback()
        end
    end)
end

--设置家具图标
function Utils.SetFurnitureIcon(imageComp, icon, isNativeSize)
    local sprite = nil
    ResInterface.SyncLoadSpritePng(string.format("icon_furniture_%s", icon), function(_sprite)
        imageComp.sprite = _sprite
        if isNativeSize then
            imageComp:SetNativeSize()
        end
    end)
    -- return sprite
end

--获取性别
function Utils.GetGender(peopleId)
    if peopleId == 1 then --伐木场 男
        return "male"
    elseif peopleId == 2 then --建厨房女
       -- return "male"
        return "female"
    elseif peopleId == 3 then  --吃饭女
        return "female"
    elseif peopleId == 4 then --建猎人小屋 男
        return "male"
    elseif math.random() >= 0.5 then
        return "male"
    else
        return "female"
    end
end

--获取皮肤id
function Utils.GetSkinId(peopleId)
    if peopleId <= 2 then
        return 1
    elseif peopleId <= 4 then
        return 2
    else
        return math.random(1, 2)
    end
end

--获取初始化属性
function Utils.GetAttributeInfo(cityId)
    local info = {}
    info[AttributeType.Hunger] = ConfigManager.GetNecessitiesStartValue(cityId, AttributeType.Hunger)
    info[AttributeType.Rest] = ConfigManager.GetNecessitiesStartValue(cityId, AttributeType.Rest)
    info[AttributeType.Comfort] = ConfigManager.GetNecessitiesStartValue(cityId, AttributeType.Comfort)
    info[AttributeType.Fun] = ConfigManager.GetNecessitiesStartValue(cityId, AttributeType.Fun)
    return info
end

--设置小人图标
function Utils.SetCharacterIcon(imageComp, cityId, gender)
    local path = ""
    if CityManager.GetIsEventScene(cityId) then
        path = string.format("icon_people_%s_%s", gender, cityId)
    else
        path = string.format("icon_people_%s", gender)
    end
    return Utils.SetIcon(imageComp, path)
end

--获取小人名称
function Utils.GetCharacterName(cityId, peopleId)
    if tonumber(peopleId) < 1 or tonumber(peopleId) > 4 then
        peopleId = tostring(4)
    end
    if CityManager.GetIsEventScene(cityId) then
        return GetLang(string.format("people_name_%s_%s", tostring(cityId), tostring(peopleId)))
    else
        return GetLang(string.format("people_name_%s", tostring(peopleId)))
    end
end

--根据gender，skinId获取小人Id
function Utils.GetPeopleId(gender, skinId)
    if gender == "male" and tonumber(skinId) == 1 then
        return 1
    elseif gender == "male" and tonumber(skinId) == 4 then
        return 2
    elseif gender == "female" and tonumber(skinId) == 3 then
        return 3
    elseif gender == "male" and tonumber(skinId) == 5 then
        return 4
    end

    return 4
end

--获取Pic
function Utils.GetPic(picName)
    return ResourceManager.Load(string.format("images/pic/%s", picName), TypeSprite)
end

--时钟格式化
function Utils.GetClockFormat(clockTime)
    local h, m = math.modf(clockTime / 100)
    m = Mathf.RoundToInt(m * 100)
    return this.GetClockFormat2(h, m)
end

--时钟格式化
function Utils.GetClockFormat2(h, m)
    h = Utils.LamdaExpression(h > 9, h, "0" .. h)
    m = Utils.LamdaExpression(m > 9, m, "0" .. m)
    return string.format("%s:%s", h, m)
end

--时间格式化
function Utils.GetTimeFormat(time)
    local h = math.modf(time / 3600)
    local m = math.modf(time / 60 - h * 60)
    local s = math.modf(time - m * 60 - h * 3600)
    m = Utils.LamdaExpression(m > 9, m, "0" .. m)
    s = Utils.LamdaExpression(s > 9, s, "0" .. s)
    if h > 0 then
        h = Utils.LamdaExpression(h > 9, h, "0" .. h)
        return string.format("%s:%s:%s", h, m, s)
    else
        return string.format("%s:%s", m, s)
    end
end

--时间格式化 1h0m1s 1h 1m 1s -1s
function Utils.GetTimeFormat2(time)
    local ret = ""
    if time < 0 then
        ret = "-"
        time = math.abs(time)
    end
    local h = math.modf(time / 3600)
    local m = math.modf((time % 3600) / 60)
    local s = math.modf(time % 60)
    local s2 = time % 60
    if h > 0 then
        ret = ret .. h .. GetLang("UI_Mail_Time_Hour")
        if s > 0 then
            ret = ret .. m .. GetLang("UI_Time_Minute") .. s .. GetLang("UI_Mail_Time_Sec")
        elseif m > 0 then
            ret = ret .. m .. GetLang("UI_Time_Minute")
        end
    elseif m > 0 then
        ret = ret .. m .. GetLang("UI_Time_Minute")
        if s > 0 then
            ret = ret .. s .. GetLang("UI_Mail_Time_Sec")
        end
    elseif s2 > 0 then
        if s2 < 1 then
            ret = ret .. Utils.CutZeroStr(string.format("%.2f", s2)) .. GetLang("UI_Mail_Time_Sec")
        else
            ret = ret .. Utils.CutZeroStr(string.format("%.1f", s2)) .. GetLang("UI_Mail_Time_Sec")
        end
    end
    return ret
end

--时间格式化 1h0m1s 1h 1m 1s -1s 小于10秒 9.2s
function Utils.GetTimeFormat3(time)
    local ret = ""
    if time < 0 then
        ret = "-"
        time = math.abs(time)
    end
    local h = math.modf(time / 3600)
    local m = math.modf((time % 3600) / 60)
    local s = math.modf(time % 60)
    local s2 = time % 60
    if h > 0 then
        ret = ret .. h .. GetLang("UI_Mail_Time_Hour")
        if s > 0 then
            ret = ret .. m .. GetLang("UI_Mail_Time_Min") .. s .. GetLang("UI_Mail_Time_Sec")
        elseif m > 0 then
            ret = ret .. m .. GetLang("UI_Mail_Time_Min")
        end
    elseif m > 0 then
        ret = ret .. m .. GetLang("UI_Mail_Time_Min")
        if s > 0 then
            ret = ret .. s .. GetLang("UI_Mail_Time_Sec")
        end
    elseif s2 > 0 then
        if s2 > 10 then
            ret = ret .. s .. GetLang("UI_Mail_Time_Sec")
        else
            ret = ret .. string.format("%.1f", s2) .. GetLang("UI_Mail_Time_Sec")
        end
    end
    return ret
end

--时间格式化 1h0m1s 1h 1m 1s -1s 小于10秒 9.2s
function Utils.GetTimeFormat4(time)
    local ret = ""
    if time < 0 then
        ret = "-"
        time = math.abs(time)
    end
    local d = math.modf(time / (3600 * 24))
    local h = math.modf((time / 3600) % 24)
    local m = math.modf((time % 3600) / 60)
    local s = math.modf(time % 60)
    local s2 = time % 60
    if d > 0 then
        ret = ret .. d .. GetLang("UI_Mail_Time_Day")
        if s > 0 then
            ret = ret .. h .. GetLang("UI_Mail_Time_Hour")
            ret = ret .. m .. GetLang("UI_Mail_Time_Min")
            ret = ret .. s .. GetLang("UI_Mail_Time_Sec")
        elseif m > 0 then
            ret = ret .. h .. GetLang("UI_Mail_Time_Hour")
            ret = ret .. m .. GetLang("UI_Mail_Time_Min")
        elseif h > 0 then
            ret = ret .. h .. GetLang("UI_Mail_Time_Hour")
        end
    elseif h > 0 then
        ret = ret .. h .. GetLang("UI_Mail_Time_Hour")
        if s > 0 then
            ret = ret .. m .. GetLang("UI_Mail_Time_Min")
            ret = ret .. s .. GetLang("UI_Mail_Time_Sec")
        elseif m > 0 then
            ret = ret .. m .. GetLang("UI_Mail_Time_Min")
        end
    elseif m > 0 then
        ret = ret .. m .. GetLang("UI_Mail_Time_Min")
        if s > 0 then
            ret = ret .. s .. GetLang("UI_Mail_Time_Sec")
        end
    elseif s2 > 0 then
        if s2 > 10 then
            ret = ret .. s .. GetLang("UI_Mail_Time_Sec")
        else
            ret = ret .. string.format("%.1f", s2) .. GetLang("UI_Mail_Time_Sec")
        end
    end
    return ret
end

--只显示前count个最大时间单位
function Utils.GetTimeFormat5(time, count)
    local ret = ""
    if time < 0 then
        ret = "-"
        time = math.abs(time)
    end

    if time < 60 then
        return ret .. string.format("%.1f", time % 60) .. GetLang("UI_Mail_Time_Sec")
    end

    local times = { 0, 0, 0, 0 }
    local timeNames = {
        GetLang("UI_Mail_Time_Sec"),
        GetLang("UI_Mail_Time_Min"),
        GetLang("UI_Mail_Time_Hour"),
        GetLang("UI_Mail_Time_Day")
    }

    times[4] = math.modf(time / (3600 * 24))
    times[3] = math.modf((time / 3600) % 24)
    times[2] = math.modf((time % 3600) / 60)
    times[1] = math.modf(time % 60)

    local mask = false
    for i = 4, 1, -1 do
        if times[i] > 0 then
            mask = true
        end

        if mask and count > 0 then
            count = count - 1
            ret = ret .. times[i] .. timeNames[i]
        end
    end

    return ret
end

--只显示分钟小时
function Utils.GetTimeFormat6(time)
    local h = math.modf(time / 3600)
    local m = math.modf(time / 60 - h * 60)
    local s = math.modf(time - m * 60 - h * 3600)
    m = Utils.LamdaExpression(m > 9, m, "0" .. m)
    h = Utils.LamdaExpression(h > 9, h, "0" .. h)
    return string.format("%s:%s", h, m)
end

--只显示分钟
function Utils.GetTimeFormatByMin(time, minName)
    minName = minName or "min"
    return math.floor(time / 60) .. minName
end

--时间格式化 最多显示2个有效单位
function Utils.GetTimeFormat7(time)
    return this.GetTimeFormat5(time, 2)
end

--分解时间戳，返回时间信息的数组[day, hour, minute, second]
function Utils.ParseTimestamp(timestamp)
    local ret = { 0, 0, 0, 0 }

    ret[4] = math.modf(timestamp / Time2.Day)
    local h = timestamp % Time2.Day
    ret[3] = math.modf(h / Time2.Hour)
    local m = math.modf(h % Time2.Hour)
    ret[2] = math.modf(m / Time2.Minute)
    local s = math.modf(m % Time2.Minute)
    ret[1] = math.modf(s)

    return ret
end

--获取时钟间隔
local function ClockInterval(startClock, endClock)
    local eH, eM = math.modf(endClock / 100)
    eM = Mathf.RoundToInt(eM * 100)
    local sH, sM = math.modf(startClock / 100)
    sM = Mathf.RoundToInt(sM * 100)
    if eH == sM then
        return eM - sM
    else
        return (eH - sH - 1) * 60 + 60 - sM + eM
    end
end

--获取时钟间隔
function Utils.GetClockInterval(startDay, startClock, endDay, endClock)
    if startDay == endDay then
        return ClockInterval(startClock, endClock)
    else
        local sI = ClockInterval(startClock, 2400)
        local eI = ClockInterval(0, endClock)
        return sI + eI + (endDay - startDay - 1) * 24 * 60
    end
end

--创建奖励UI
function Utils.CreateRewardItem(parentRoot)
    local go = ResourceManager.Instantiate("ui/RewardItem", parentRoot)
    -- SetGameObjectParent(parentRoot, go)
    local rewardItem = {}
    rewardItem.iconImage = GetComponentByPath(go, "Icon", TypeImage)
    rewardItem.countText = GetComponentByPath(go, "Count", TypeText)
    rewardItem.UpdateFunc = function(type, count)
        rewardItem.iconImage.sprite = Utils.GetItemIcon(type)
        rewardItem.countText.text = count
    end
    return rewardItem
end

--返回灰色的UI材质
function Utils.GetGrayMaterial()
    if Utils.GrayMaterial == nil then
        -- local shader = Shader.Find("UI/Gray")
        -- Utils.GrayMaterial = Material(shader)
        -- Utils.GrayMaterial = ResourceManager.Load("Material/UI-Gray", typeof(Material))
        -- ResInterface.LoadMaterial("Effect/Materials/UI/UI-Gray", function (_material) 
        --     Utils.GrayMaterial = _material
        -- end)
    end
    return Utils.GrayMaterial
end

--设置Image灰色材质
function Utils.SetImageGray(image)
    image.material = Utils.GetGrayMaterial()
    image:SetMaterialDirty()
end

--取消置Image灰色材质
function Utils.ClearImageGray(image)
    image.material = nil
    image:SetMaterialDirty()
end

function Utils.SetBtnDisable(btn)
    btn:SetInteractable(false)
    local image = btn.gameObject:GetComponent(TypeImage)
    image.material = Utils.GetGrayMaterial()
    image:SetMaterialDirty()
end

function Utils.SetBtnEnable(btn)
    btn:SetInteractable(true)
    local image = btn.gameObject:GetComponent(TypeImage)
    image.material = nil
    image:SetMaterialDirty()
end

--获取格林尼治时间戳
function Utils.GetUtcTimeStamp(timeStamp)
    return os.time(os.date("!*t", timeStamp))
end

--获取格林尼治O时间戳
function Utils.GetZeroUtcTimeStamp(timeStamp)
    local utcDate = os.date("!*t", timeStamp)
    return os.time({ year = utcDate.year, month = utcDate.month, day = utcDate.day, hour = 0 })
end

---奖励转换格式
---@param rewardStr string 奖励字符串
---@param notOverTimeExchange boolean 默认false，进行overtime奖励转换
---@return Reward[]
function Utils.ParseReward(rewardStr, notOverTimeExchange)
    local ret = {}
    if rewardStr == "" then
        return ret
    end

    local rewardArr = string.split(rewardStr, ",")
    for i = 1, #rewardArr, 1 do
        local rewardItem = {}
        local itemArr = string.split(rewardArr[i], "?")
        local itemLeftArr = string.split(itemArr[1], "*")
        rewardItem.addType = itemLeftArr[1]
        rewardItem.count = tonumber(itemLeftArr[2])
        if #itemArr > 1 then
            local paramsArr = string.split(itemArr[2], "&")
            for ix, paramItem in pairs(paramsArr) do
                local paramItem = string.split(paramItem, "=")
                local paramKey = paramItem[1]
                local paramValue = tonumber(paramItem[2]) or paramItem[2]
                rewardItem[paramKey] = paramValue
            end
        end
        table.insert(ret, rewardItem)
    end

    if notOverTimeExchange == true then
        return ret
    end

    return this.RewardOverTime2Item(ret)
end

--是否包含秒产物品
---@param rewards Reward[]
---@return boolean
function Utils.HasOverTimeItemInRewards(rewards)
    if rewards == nil then
        return
    end

    for i = 1, #rewards do
        local reward = rewards[i]
        if Utils.IsOverTimeItem(reward) then
            return true
        end
    end

    return false
end

--是否为秒产物品
---@param reward Reward
---@return boolean
function Utils.IsOverTimeItem(reward)
    if reward == nil then
        return false
    end
    if
        reward.addType == RewardAddType.ItemOverTime or reward.addType == RewardAddType.OverTime or
        reward.addType == RewardAddType.OverTimeResType
    then
        return true
    end

    return false
end

--遍历奖励列表，将ItemOverTime奖励转换为item奖励
---@param rewards Reward[]
function Utils.RewardOverTime2Item(rewards)
    local newReward = {}

    for i = 1, #rewards do
        local reward = rewards[i]
        if reward.addType == RewardAddType.ItemOverTime then
            -- 所有资源都要有保底，所以guarantee参数无视
            local output =
                OverTimeProductionManager.Get(DataManager.GetCityId()):GetItemOverTime(reward.count, reward.guarantee)

            for k, v in pairs(output) do
                table.insert(
                    newReward,
                    {
                        addType = RewardAddType.Item,
                        id = k,
                        count = v
                    }
                )
            end
        elseif reward.addType == RewardAddType.OverTime then
            table.insert(
                newReward,
                {
                    addType = RewardAddType.Item,
                    id = reward.id,
                    count = OverTimeProductionManager.Get(DataManager.GetCityId()):Get(
                        reward.id,
                        reward.count,
                        reward.guarantee
                    )
                }
            )
        elseif reward.addType == RewardAddType.OverTimeResType then
            --在所有秒产中获取查找res type匹配的项目
            local itemOverTimeRewards =
                OverTimeProductionManager.Get(DataManager.GetCityId()):GetItemOverTimeReward(reward.count)
            local rewardsByResType = {}
            for i = 1, #itemOverTimeRewards do
                local itemCfg = ConfigManager.GetItemConfig(itemOverTimeRewards[i].id)
                if itemCfg.resource_type == tonumber(reward.resType) then
                    table.insert(rewardsByResType, itemOverTimeRewards[i])
                end
            end
            if #rewardsByResType > 0 then
                -- 随机取其中n个
                local randItemList = this.RandomGetArrayN(rewardsByResType, tonumber(reward.rand))
                for i = 1, #randItemList do
                    table.insert(newReward, randItemList[i])
                end
            end
        else
            table.insert(newReward, reward)
        end
    end

    return newReward
end

--向奖励列表中追加奖励
function Utils.AppendRewards(rewards, reward)
    local found = false
    for i = 1, #rewards do
        if rewards[i].addType == reward.addType and rewards[i].id == reward.id then
            rewards[i].count = rewards[i].count + reward.count
            found = true
        end
    end

    if found then
        return rewards
    end

    -- 如果是card的颜色随机，或者是addToItemOverTime类型，他们不存在id属性，所以永远不会found=true
    -- 这两种类型都作为新增
    table.insert(rewards, reward)

    return rewards
end

---将src中的项目，合并到dest中
---src，dest是reward的数组
function Utils.MergeRewards(src, dest)
    for i = 1, #src do
        dest = this.AppendRewards(dest, Clone(src[i]))
    end

    return dest
end

---合并相同id的物品
function Utils.PressRewards(rewards)
    local rt = {}
    for i = 1, #rewards do
        local found = false
        for j = 1, #rt do
            if
                rewards[i].addType == rt[j].addType and rewards[i].id ~= nil and rt[j].id ~= nil and
                rewards[i].id == rt[j].id
            then
                found = true
                rt[j].count = math.floor(rt[j].count * 1.0 + rewards[i].count * 1.0)
                break
            end
        end

        if not found then
            table.insert(rt, Clone(rewards[i]))
        end
    end

    return rt
end

---对奖励数量乘以一个系数，floor表示是否取整
---@param rewards Reward[]
---@param ratio number
---@param floor boolean
function Utils.MultiRewards(rewards, ratio, floor)
    local mul = {}
    for i = 1, #rewards do
        local newReward = Clone(rewards[i])
        newReward.count = newReward.count * ratio

        if floor then
            newReward.count = math.floor(newReward.count)
        end

        table.insert(mul, newReward)
    end

    return mul
end

---返回奖励中符合当前场景的奖励
---@param rewards Reward[]
---@return Reward[], Reward[] 分别返回符合场景的奖励，和不符合场景的奖励
function Utils.SplitRewardByCityId(cityId, rewards)
    local curr = {}
    local other = {}
    for i = 1, #rewards do
        local reward = rewards[i]
        if reward.addType == RewardAddType.Item or reward.addType == RewardAddType.OverTime then
            local config = ConfigManager.GetItemConfig(reward.id)
            if config.city_id == cityId or config.scope == "Global" then
                table.insert(curr, reward)
            else
                table.insert(other, reward)
            end
        elseif reward.addType == RewardAddType.Card then
            if CardManager.IsCardValidInCurrentCity(reward.id) then
                table.insert(curr, reward)
            else
                table.insert(other, reward)
            end
        elseif reward.addType == RewardAddType.Boost then
            local config = ConfigManager.GetBoostConfig(reward.id)
            if
                config.scope == "Global" or (config.scope == "City" and not CityManager.GetIsEventScene(cityId)) or
                (config.scope == "Event" and CityManager.GetIsEventScene(cityId))
            then
                table.insert(curr, reward)
            else
                table.insert(other, reward)
            end
        elseif reward.addType == RewardAddType.OpenBox then
            local boxRewards = BoxManager.InspectBox(reward.id, cityId)
            if #boxRewards > 0 then
                table.insert(curr, reward)
            else
                table.insert(other, reward)
            end
        else
            table.insert(curr, reward)
        end
    end

    return curr, other
end

---返回普通奖励和box开出的奖励
---@param rewards Reward[]
---@return Reward[], Reward[]
function Utils.SplitBoxRewards(rewards)
    local normalRewards = {}
    local boxRewards = {}

    function IsBoxShowAssets(boxId)
        local boxConfig = ConfigManager.GetBoxConfig(boxId)
        if boxConfig.assets_name == nil or boxConfig.assets_name == "" then
            return false
        end
        return true
    end

    if rewards ~= nil then 
        for i = 1, #rewards do
            if rewards[i].origin ~= nil and rewards[i].origin == RewardAddType.Box and IsBoxShowAssets(rewards[i].originId) then
                table.insert(boxRewards, rewards[i])
            else
                table.insert(normalRewards, rewards[i])
            end
        end
    end

    return normalRewards, boxRewards
end

---是否包含动态奖励，不检测Box中的奖励
---@param rewards Reward[]
function Utils.RewardsIsDynamic(rewards)
    for i = 1, #rewards do
        if
            rewards[i].addType == RewardAddType.OverTime or rewards[i].addType == RewardAddType.ItemOverTime or
            rewards[i].addType == RewardAddType.OverTimeResType
        then
            return true
        end
    end

    return false
end

---根据item返回产出这种item的建筑,并且已经建造好的列表
function Utils.GetZoneListByItemId(cityId, itemId)
    local zoneList = List:New()
    local itemCfg = ConfigManager.GetItemConfig(itemId)
    if nil == itemCfg then
        return zoneList
    end

    for _, zoneType in ipairs(itemCfg.producted_in) do
        local zoneCfgList = ConfigManager.GetZoneConfigListByType(cityId, zoneType)
        zoneList:Merge(zoneCfgList)
    end

    for i = zoneList:Count(), 1, -1 do
        if not MapManager.IsZoneUnlock(cityId, zoneList[i].id) then
            zoneList:RemoveAt(i)
        end
    end

    return zoneList
end

--- 根据item返回产出这种item的建筑，包括在建的
function Utils.GetZoneListByItemIdIncludeBuilding(cityId, itemId)
    local itemCfg = ConfigManager.GetItemConfig(itemId)
    local zoneList = List:New()

    for _, zoneType in ipairs(itemCfg.producted_in) do
        local zoneCfgList = ConfigManager.GetZoneConfigListByType(cityId, zoneType)
        zoneList:Merge(zoneCfgList)
    end

    for i = zoneList:Count(), 1, -1 do
        local mapItemData = MapManager.GetMapItemData(cityId, zoneList[i].id)

        --if not MapManager.IsZoneUnlock(cityId, zoneList[i].id) then
        -- 只要建筑不是空
        if mapItemData:GetBuildStatus() == "Empty" then
            zoneList:RemoveAt(i)
        end
    end

    return zoneList
end

--打乱数组
function Utils.RandomArray(arr)
    local tmp, index
    for i = 1, #arr - 1 do
        index = math.random(i, #arr)
        if i ~= index then
            tmp = arr[index]
            arr[index] = arr[i]
            arr[i] = tmp
        end
    end
end

function Utils.RandomByWeight(arr, weightArr)
    local sum = 0
    for i = 1, #weightArr do
        sum = sum + weightArr[i]
    end
    if sum <= 0 then
        print("[error]" .. "Random Max is 0")
        return nil
    end
    local compare = math.random(1, sum)
    local weightIndex = 1
    while sum > 0 do
        sum = sum - weightArr[weightIndex]
        if (sum < compare) then
            return arr[weightIndex]
        end
        weightIndex = weightIndex + 1
    end
    return nil
end

---返回数组中的值，n表示取几次，n应小于arr大小
function Utils.RandomGetArrayN(arr, n)
    local rt = {}
    for i = 1, n do
        if #arr == 0 then
            break
        end

        local idx = math.random(1, #arr)
        table.insert(rt, arr[idx])
        table.remove(arr, idx)
    end

    return rt
end

function Utils.SwitchSceneClear(currCityId, itemList, forceClear)
    if forceClear then
        itemList:ForEachKeyValue(
            function(cityId, item)
                item:Clear()
            end
        )
        itemList:Clear()
    else
        if itemList:Count() == 2 then
            local nextCityId = DataManager.GetCityId()
            local maxCityId = DataManager.GetMaxCityId()
            local contentMaxCity = false
            itemList:ForEachKeyValue(
                function(cityId, item)
                    if cityId == maxCityId then
                        contentMaxCity = true
                    end
                end
            )
            local removeList = Dictionary:New()
            if contentMaxCity and maxCityId ~= nextCityId then
                itemList:ForEachKeyValue(
                    function(cityId, item)
                        if cityId ~= maxCityId and cityId ~= nextCityId then
                            removeList:Add(cityId, item)
                        end
                    end
                )
            else
                itemList:ForEachKeyValue(
                    function(cityId, item)
                        if cityId ~= currCityId and cityId ~= nextCityId then
                            removeList:Add(cityId, item)
                        end
                    end
                )
            end

            removeList:ForEachKeyValue(
                function(cityId, item)
                    itemList:Remove(cityId)
                    item:Clear()
                end
            )
        end
    end
end

--打乱数组
function Utils.RichText(txt, color, size)
    local ret = txt
    if color ~= nil then
        ret = "<color=" .. color .. ">" .. ret .. "</color>"
    end
    if size ~= nil and size > 0 then
        ret = "<size=" .. size .. ">" .. ret .. "</size>"
    end
    return ret
end

--获得时区（Bug）
function Utils.GetTimeZone()
    --中时区的时间
    local a = os.date("!*t", os.time())
    local b = os.date("*t", os.time())
    local timeZone = (b.hour - a.hour) * 3600 + (b.min - a.min) * 60
    return math.ceil(timeZone / 3600)
end

--获取相机
function Utils.GetCamera()
    if GameManager.GetModeType() == ModeType.MainScene then
        return MainUI.Instance.camera
    elseif GameManager.GetModeType() == ModeType.BattleScene then
        return BattleUI.Instance.camera
    else
        return CS.FrozenCity.SpriteAPI:GetUICamera()
    end
end

--获取相机世界转换屏幕
function Utils.GetCameraWorldToScreenPoint(pos)
    local pos = Utils.GetCamera():WorldToScreenPoint(pos)
    pos.x = pos.x * AppScreen.WidthRatio
    pos.y = pos.y * AppScreen.HeightRatio
    return pos
end

--获取画布
function Utils.GetCanvas()
    if GameManager.GetModeType() == ModeType.MainScene then
        return MainUI.Instance.canvas
    elseif GameManager.GetModeType() == ModeType.BattleScene then
        return BattleUI.Instance.canvas
    elseif GameManager.GetModeType() == ModeType.RoguelikeScene then
        return RogueExploreUI.Instance.canvas
    end
end

--UI对象转换屏幕坐标
function Utils.GetLocalPointInRectangleByUI(target)
    if isNil(target) then
        -- print ("zhkxin GetLocalPointInRectangleByUI -1. ", debug.traceback())
        return 
    end
   
    local canvasTrans = PanelManager.SafeArea
    local screenPoint = RectTransformUtility.WorldToScreenPoint(PanelManager:GetUICamera(), target.transform.position)
    local r, p = RectTransformUtility.ScreenPointToLocalPointInRectangle(canvasTrans, screenPoint, PanelManager:GetUICamera(), Vector3.zero)
    return p
end

--UI对象转换屏幕坐标
function Utils.GetLocalPointInRectangleByPosition(position)
    local canvasTrans = PanelManager.SafeArea
    local screenPoint = RectTransformUtility.WorldToScreenPoint(PanelManager:GetUICamera(), position)
    local r, p = RectTransformUtility.ScreenPointToLocalPointInRectangle(canvasTrans, screenPoint, PanelManager:GetUICamera(), Vector3.zero)
    return p
end

--UI对象转换世界坐标
function Utils.GetWorldPointInRectangleByUI(target)
    local canvasTrans = PanelManager.UICanvas.transform
    local screenPoint = RectTransformUtility.WorldToScreenPoint(PanelManager:GetUICamera(), target.transform.position)
    local r, p = RectTransformUtility.ScreenPointToWorldPointInRectangle(canvasTrans, screenPoint, PanelManager:GetUICamera(), Vector3.zero)
    return p
end

--场景对象转换屏幕坐标
function Utils.GetLocalPointInRectangleByScene(target)
    local screenPoint = PanelManager:GetUICamera():WorldToScreenPoint(target.transform.position)
    -- local screenPoint = Camera.main:WorldToScreenPoint(target.transform.position)
    return Vector2(screenPoint.x - Screen.width / 2, screenPoint.y - Screen.height / 2)
end


--获得
function Utils.GetUUID()
    local seed = { "e", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f" }
    local tb = {}
    for i = 1, 32 do
        table.insert(tb, seed[math.random(1, 16)])
    end
    local sid = table.concat(tb)
    return string.format(
        "%s-%s-%s-%s-%s",
        string.sub(sid, 1, 8),
        string.sub(sid, 9, 12),
        string.sub(sid, 13, 16),
        string.sub(sid, 17, 20),
        string.sub(sid, 21, 32)
    )
end

--获得
function Utils.GetShortUUID()
    local seed = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f" }
    local tb = {}
    for i = 1, 8 do
        table.insert(tb, seed[math.random(1, 16)])
    end
    local sid = table.concat(tb)
    return string.format("%s", string.sub(sid, 1, 8))
end

--格式化数字单位
function Utils.FormatCount(x)
    local ab = ""
    local ret
    if x < 0 then
        ab = "-"
        x = math.abs(x)
    end
    if x < 0.0001 then
        ab = ""
        x = 0
    end
    if x == 0 then
        ret = "0"
    elseif x < 0.1 then
        ret = this.GetRoundPreciseDecimal(x, 3)
        ret = this.CutZeroStr(ret)
    elseif x < 10 then
        ret = this.GetFloorPreciseDecimal(x, 2)
        ret = this.CutZeroStr(ret)
    elseif x < 100 then
        ret = this.GetFloorPreciseDecimal(x, 1)
        ret = this.CutZeroStr(ret)
    elseif x < 1000 then
        ret = math.floor(x)
        if ret == 0 then
            ret = x
        end
    elseif x < 100000 then
        ret = math.floor(x)
        local exponent = Util.MathLog(x, 10)
        if exponent >= 3 then
            local len = string.len(ret)
            ret = string.sub(ret, 1, len - 3) .. "," .. string.sub(ret, len - 2)
        end
    else
        local exponent = Util.MathLog(x, 10)
        local index = math.floor(exponent / 3)
        local e = Funit[index]
        local cc = x / (10 ^ (index * 3))
        ret = string.format("%.1f", cc)
        ret = this.CutZeroStr(ret)
        ret = ret .. e
    end
    ret = ab .. ret
    return ret
end

function Utils.RoundDown(number, decimals)
    local power = 10 ^ decimals
    return math.floor(number * power) / power
end

function Utils.Round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

--计算用
function Utils.RoundCount(n)
    local t = math.floor(math.log(n, 10))
    t = math.max(t, 0)
    local k = t % 3
    local arr = { -1, 0, 0, 1, 2 }
    local a = n
    if t < #arr then
        k = arr[t + 1]
        a = this.RoundDown(n, 2 + k - t)
    else
        a = this.Round(n, 2 + k - t)
    end
    -- Log(t .. "  " .. k .. " " .. a)
    return a
end

function Utils.CutZeroStr(str)
    if not string.find(str, "%.") then
        return str
    end
    while string.find(str, "0", string.len(str), true) ~= nil do
        str = string.sub(str, 0, string.len(str) - 1)
        if string.find(str, ".", string.len(str), true) ~= nil then
            str = string.sub(str, 0, string.len(str) - 1)
            break
        end
    end
    return str
end

function Utils.GetPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum
    end
    n = n or 0
    n = math.floor(n)
    if n < 0 then
        n = 0
    end
    local nDecimal = 10 ^ n
    local nTemp = math.floor(nNum * nDecimal)
    local nRet = nTemp / nDecimal
    return nRet
end

function Utils.GetRoundPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum
    end
    n = n or 0
    n = math.floor(n)
    local format = "%." .. n .. "f"
    local roundNum = string.format(format, nNum)
    return tonumber(roundNum)
end

function Utils.GetFloorPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum
    end
    n = n or 0
    n = math.floor(n)
    nNum = math.floor(nNum * (10 ^ n)) / (10 ^ n)
    return tonumber(string.format("%." .. n .. "f", nNum))
end

function Utils.DeepCopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end

    return _copy(object)
end

---@param zoneId number
---@param from string
---@param openUnlock boolean
function Utils.LookUpZone(zoneId, from, openUnlock)
    Utils.LookUpFurniture(zoneId, "", 0, from, {}, openUnlock)
end

---@param zoneId number
---@param furnitureId string
---@param furnitureIdx number
---@param from string
---@param extented number
---@param openUnlock boolean
function Utils.LookUpFurniture(zoneId, furnitureId, furnitureIdx, from, extented, openUnlock)
    local cityId = DataManager.GetCityId()
    local mapItems = MapManager.GetMap(cityId)
    local mapItemData = MapManager.GetMapItemData(cityId, zoneId)
    local canUnlock = MapManager.GetCanLock(cityId, mapItemData.zoneId)
    local unlockData = mapItemData:GetUnlockLevelIsReady()
    local buildCanUnlock = unlockData and unlockData["AllReady"]
    local buildUnlock = mapItems.zones[zoneId] ~= nil
    if (not canUnlock or not buildCanUnlock) and not buildUnlock then
        UIUtil.showText(GetLang("toast_building_not_available"))
        return
    end
    print("Utils.LookUpFurniture-zoneId" .. zoneId .. ",furnitureId" .. furnitureId)
    local mainCtrl = CityModule.getMainCtrl()
    local build = mainCtrl.buildDict[zoneId]
    mainCtrl:ShowBuildView(build.data, from, extented)

    EventManager.Brocast(EventDefine.HideBottomMainUI)
    
    HideUI(UINames.UITask)

    local cityId = DataManager.GetCityId()
    local zoneConfig = ConfigManager.GetZoneConfigById(zoneId)
    local mapItemData = MapManager.GetMapItemData(cityId, zoneId)

    if not MapManager.GetCanLock(DataManager.GetCityId(), zoneId) then
        UIUtil.showText(GetLang("toast_building_not_available"))
        -- GameToast.Instance:Show(GetLang("toast_building_not_available"), ToastIconType.Warning)
        return
    end
    -- local status = this.GetMapItemDataStatus(mapItemData)

    -- if
    --     status == MapItemDataStatus.Upgrading or status == MapItemDataStatus.Normal or
    --     status == MapItemDataStatus.MaxLevel
    -- then
    --     --关闭当前界面
    --     -- PopupManager.Instance:CloseAllPanel()
    --     HideUI(UINames.UITask)
    --     -- 区分不同建筑打开不同ui
    --     if zoneConfig.zone_type == ZoneType.Generator then
    --         -- 活动
    --         if CityManager.GetIsEventScene() then
    --             -- if CityManager.IsEventScene(EventCityType.Water) then
    --             --     PopupManager.Instance:OpenPanel(PanelType.CardTrickPanel)
    --             -- else
    --             --     PopupManager.Instance:OpenPanel(PanelType.EventSlotPanel)
    --             -- end
    --         else
    --             -- 升级中
    --             if status == MapItemDataStatus.Upgrading then
    --                 -- PopupManager.Instance:LastOpenPanel(
    --                 --     PanelType.GeneratorUpgradePanel,
    --                 --     { zoneId = zoneId, from = from, extented = extented },
    --                 --     true
    --                 -- )
    --                 ShowUI(UINames.UIBuildGeneratorUpgrade)
    --             else
    --                 ShowUI(UINames["UIBuild" .. ZoneType.Generator])
    --                 -- PopupManager.Instance:LastOpenPanel(
    --                 --     PanelType.GeneratorPanel,
    --                 --     { zoneId = zoneId, from = from, extented = extented },
    --                 --     true
    --                 -- )
    --             end
    --         end
    --         EventManager.Brocast(EventDefine.onSelectZone, zoneId)
    --     elseif zoneConfig.zone_type == ZoneType.Warehouse then
    --         -- PopupManager.Instance:LastOpenPanel(
    --         --     PanelType.EventWarehousePanel,
    --         --     { zoneId = zoneId, from = from, extented = extented },
    --         --     true
    --         -- )
    --     else
    --         ShowUI(UINames[UINames.UIBuild],
    --             { zoneType = zoneConfig.zone_type, zoneId = zoneId, from = from, extented = extented })
    --         -- PopupManager.Instance:LastOpenPanel(
    --         --     PanelType.BuildPanel,
    --         --     {
    --         --         zoneId = zoneId,
    --         --         furnitureId = furnitureId,
    --         --         furnitureIdx = furnitureIdx,
    --         --         from = from,
    --         --         extented = extented
    --         --     },
    --         --     true
    --         -- )
    --         EventManager.Brocast(EventDefine.onSelectZone, zoneId)
    --     end
    -- else -- building, unlock
    --     if openUnlock then
    --         --关闭当前界面
    --         HideUI(UINames.UITask)
    --         -- PopupManager.Instance:CloseAllPanel()
    --         if zoneConfig.zone_type == ZoneType.Generator then
    --             -- PopupManager.Instance:LastOpenPanel(
    --             --     PanelType.GeneratorUpgradePanel,
    --             --     { zoneId = zoneId, from = from, extented = extented },
    --             --     true
    --             -- )
    --         else
    --             ShowUI(UINames.UIBuildUnlock, { zoneId = zoneId, from = from })
    --             -- PopupManager.Instance:LastOpenPanel(
    --             --     PanelType.UnlockPanel,
    --             --     { zoneId = zoneId, from = from, extented = extented },
    --             --     true
    --             -- )
    --         end
    --         EventManager.Brocast(EventDefine.onSelectZone, zoneId)
    --     else
    --         UIUtil.showText(GetLang("toast_building_not_available"))
    --         -- GameToast.Instance:Show(GetLang("toast_building_not_available"), ToastIconType.Warning)
    --     end
    -- end
end

function Utils.GetCardOccupationLang(occupation)
    return GetLang("ui_card_" .. occupation)
end

function Utils.GetCardMainTypeLang(type)
    return GetLang("ui_card_main_type_" .. type)
end

function Utils.GetCardSubTypeLang(subType)
    return GetLang("ui_card_sub_type_" .. subType)
end

function Utils.GetCardZoneTypeLang(zoneType)
    return GetLang("ui_" .. zoneType)
end

--根据属性类型获取颜色因素
function Utils.GetColorFactorByAttributeType(type, factor)
    local colorFactor = ConfigManager.GetMiscConfig("color_factor_" .. type)
    if factor < colorFactor[1] then
        return 0
    elseif factor < colorFactor[2] then
        return 1
    elseif factor < colorFactor[3] then
        return 2
    else
        return 3
    end
end

-- 返回数组中是否包含
---@param array any[]
---@param value any
---@return boolean
function Utils.ArrayHas(array, value)
    for _, i in ipairs(array) do
        if i == value then
            return true
        end
    end
    return false
end

function Utils.ArrayHasEx(array, comf)
    for i = 1, #array do
        if comf(array[i]) then
            return true
        end
    end
    return false
end

--加载StreamingAssets文本文件
function Utils.LoadStreamingAssetsText(file, cb)
    AppHttp.LoadStreamingAssetsText(
        file,
        function(retText)
            cb(retText)
        end,
        function()
            cb(nil, true)
        end
    )
end

-- 返回table的长度
function Utils.GetTableLength(tbl)
    if tbl == nil then
        return 0
    end

    local getN = 0
    for n in pairs(tbl) do
        getN = getN + 1
    end
    return getN
end

function Utils.Type(t)
    local tt = type(t)

    if tt == "table" or tt == "array" then
        -- 如果是空table，那么他就是table
        if Utils.GetTableLength(t) == 0 then
            return "table"
        end

        if Utils.IsArray(t) then
            return "array"
        else
            return "table"
        end
    end

    return tt
end

function Utils.IsArraySimple(t)
    assert(not (t[1] == nil and t[2] ~= nil))
    return t[1] ~= nil
end

function Utils.IsArray(tableT)
    --has to be a table in the first place of course
    if type(tableT) ~= "table" then
        return false
    end

    --not sure exactly what this does but piFace wrote it and it catches most cases all by itself
    local piFaceTest = #tableT > 0 and next(tableT, #tableT) == nil
    if piFaceTest == false then
        return false
    end

    --must have a value for 1 to be an array
    if tableT[1] == nil then
        return false
    end

    --all keys must be integers from 1 to #tableT for this to be an array
    for k, v in pairs(tableT) do
        if type(k) ~= "number" or (k > #tableT) or (k < 1) or math.floor(k) ~= k then
            return false
        end
    end

    --every numerical key except the last must have a key one greater
    for k, v in ipairs(tableT) do
        if tonumber(k) ~= nil and k ~= #tableT then
            if tableT[k + 1] == nil then
                return false
            end
        end
    end

    --otherwise we probably got ourselves an array
    return true
end

---将"addToItem*5?id=Gem"类型的数据转换为{"item.Gem":1}类型数据
---@param rewardStr string
---@return table<string, number>
function Utils.ConvertRewardsStr2Attachment(rewardStr)
    local rewards = this.ParseReward(rewardStr)

    return this.ConvertRewards2Attachment(rewards)
end

function Utils.ConvertAttachment2Rewards(item, count, type)
    local addType = RewardAddType.Item
    if type == RewardType.Card then
        addType = RewardAddType.Card
    elseif type == RewardType.Box then
        addType = RewardAddType.OpenBox
    end

    local data = {
        id = item,
        count = count,
        addType = addType
    }
    return data
end

---转换rewards类型到attachment，不支持秒产
function Utils.ConvertRewards2Attachment(rewards)
    local rt = {}
    for i = 1, #rewards do
        if rewards[i].addType == RewardAddType.Item then
            rt[RewardType.Item .. "." .. rewards[i].id] =
                (rt[RewardType.Item .. "." .. rewards[i].id] or 0) + rewards[i].count
        elseif rewards[i].addType == RewardAddType.Card then
            rt[RewardType.Card .. "." .. rewards[i].id] =
                (rt[RewardType.Card .. "." .. rewards[i].id] or 0) + rewards[i].count
        elseif rewards[i].addType == RewardAddType.Box then
            rt[RewardType.Box .. "." .. rewards[i].id] =
                (rt[RewardType.Box .. "." .. rewards[i].id] or 0) + rewards[i].count
        end
    end

    return rt
end

---转换rewards为BI用，reward中id字段都用字符串
function Utils.BIConvertRewards(rewards)
    local rt = {}
    for i = 1, #rewards do
        local reward = Clone(rewards[i])
        if reward.id ~= nil then
            reward.id = tostring(reward.id)
        end

        -- 由于id在tga上是数字类型，所以这里换一个名字
        reward.rewardId = reward.id
        reward.id = nil
        reward.sort = nil
        table.insert(rt, reward)
    end

    return rt
end

function Utils.CheckNewCard(rewards)
    local hasCard = {}
    local getCard = {}
    local newCard = {}
    for i = 1, #rewards, 1 do
        local value = rewards[i]
        if value.addType == RewardAddType.Card then
            local cardItemData = CardManager.GetCardItemData(value.id)
            local cardNum = cardItemData:GetCardCount()
            if hasCard[value.id] == nil then
                hasCard[value.id] = cardNum
            end
            if getCard[value.id] == nil then
                getCard[value.id] = 0
            end
            getCard[value.id] = getCard[value.id] + value.count
            -- Log("id " .. value.id .. " has card " .. cardNum .. " this time " .. getCard[value.id])
        end
    end
    for id, num in pairs(getCard) do
        -- Log("Get Card num " .. getCard[id] .. " Has Card " .. hasCard[id])
        if hasCard[id] < getCard[id] then
            -- Log("New Card " .. id)
            table.insert(newCard, id)
        end
    end
    return newCard
end

this.VersionLength = 3

---返回版本比较，a>b: 1, a==b: 0, a<b: -1
---@param a number[]
---@param b number[]
---@return number
function Utils.VersionCompare(a, b)
    if not this.VersionIsValid(a) or not this.VersionIsValid(b) then
        return 0
    end

    for i = 1, this.VersionLength do
        if a[i] > b[i] then
            return 1
        elseif a[i] < b[i] then
            return -1
        end
    end

    return 0
end

---字符版本号"0.0.0"转换为数组[0, 0, 0]
---@param ver string
---@return number[]
function Utils.Version2Array(ver)
    local s = string.split(ver, ".")

    local verData = {}
    for i = 1, #s do
        table.insert(verData, tonumber(s[i]))
    end

    if not this.VersionIsValid(verData) then
        return nil
    end

    return verData
end

---数组[0, 0, 0]转换为字符版本号"0.0.0"
---@param d number[]
---@return string
function Utils.Array2Version(d)
    if not this.VersionIsValid(d) then
        return ""
    end

    return d[1] .. "." .. d[2] .. "." .. d[3]
end

---检查版本号是否有效，0版本无效，没有3个元素的数组也是无效
---@param ver number[]
function Utils.VersionIsValid(ver)
    if not ver or #ver ~= this.VersionLength then
        return false
    end

    for i = 1, #ver do
        if type(ver[i]) ~= "number" then
            return false
        end
    end

    return true
end

---@param ver number[]
function Utils.VersionIsZero(ver)
    return ver[1] + ver[2] + ver[3] == 0
end

function Utils.GainZeroVersion()
    return { 0, 0, 0 }
end

---@param diamondFunc fun(): number --返回消耗钻石数量的函数
---@param confirmFunc fun()
---@param expireTime number
---@param confirmCount number --确认数量
---@return boolean --返回false表示钻石不足
function Utils.ShowDiamondConfirmBox(diamondFunc, confirmFunc, expireTime, confirmCount)
    if confirmCount == nil then
        -- 如果是空，那么读取misc
        confirmCount = ConfigManager.GetMiscConfig("diamond_confirm_count")
    end

    if confirmCount == nil then
        confirmCount = -1
    end

    if confirmCount == -1 or diamondFunc() <= confirmCount then
        confirmFunc()
        return true
    end

    if DataManager.GetMaterialCount(DataManager.GetCityId(), ItemType.Gem) < diamondFunc() then
        return false
    end

    if expireTime ~= nil then
        expireTime = expireTime - 1
    end

    UIUtil.showConfirmByData(
        {
            Title = "ui_diamond_use_tips_title",
            DescriptionRaw = GetLangFormat("ui_diamond_use_tips_show", diamondFunc()),
            ShowGemButton = true,
            GemCost = diamondFunc(),
            GemButtonText = "ui_yes_btn",
            OnCostFunc = function()
                confirmFunc()
            end,
            UpdateFunc = function(data)
                data.DescriptionRaw = GetLangFormat("ui_diamond_use_tips_show", diamondFunc())
                data.GemCost = diamondFunc()
                return true
            end,
            ClosePanelLeftTime = expireTime
        }
    )

    return true
end

--根据坐标获取朝向
function Utils.GetDirection(startPos, endPos)
    return Vector3.Normalize(endPos - startPos)
end

--根据位置获取角度
function Utils.GetUIAngle(startPos, endPos, direction)
    direction = direction or Vector3.up
    local dir = endPos - startPos
    local angle = Vector3.Angle(direction, dir) + 0.1
    local cross = Vector3.Cross(direction, dir)
    local dirF = 0
    if cross.z > 0 then
        dirF = 1
    else
        dirF = -1
    end
    return math.modf(angle * dirF)
end

--根据坐标获取屏幕中的距离
function Utils.GetUIDistance(startPos, endPos)
    local distance = Vector3.Distance(endPos, startPos)
    return distance * 1 / Utils.GetCanvas().transform.localScale.x
end

function Utils.GetUISpace(space)
    return space * Utils.GetCanvas().transform.localScale.x
end

function Utils.BuildCardRedDotSortFunc(selectedCardId)
    return function(a, b)
        if a:GetLevel() == b:GetLevel() then
            local quality = CardManager.CompareCardColor(a.config.color, b.config.color)
            if quality == 0 then
                if a:GetID() == selectedCardId then
                    return true
                elseif b:GetID() == selectedCardId then
                    return false
                end
                return a.config.sort < b.config.sort
            else
                return quality > 0
            end
        else
            return a:GetLevel() > b:GetLevel()
        end
    end
end

--根据3个点获取贝塞尔曲线路径
function Utils.GetBezierCurveWithThreePoints(point_1, point_2, point_3, vertexCount)
    local pointList = List:New()
    for ratio = 0, 1, 1 / vertexCount do
        local tangentLineVertex1 = Vector3.Lerp(point_1, point_2, ratio)
        local tangentLineVertex2 = Vector3.Lerp(point_2, point_3, ratio)
        local bezierPoint = Vector3.Lerp(tangentLineVertex1, tangentLineVertex2, ratio)
        pointList:Add(bezierPoint)
    end
    pointList:Add(point_3)
    return pointList
end

---返回建筑状态
---@param mapItemData MapItemData
---@return string    返回MapItemData.Status
function Utils.GetMapItemDataStatus(mapItemData)
    if not MapManager.GetCanLock(mapItemData.cityId, mapItemData.zoneId) then
        return MapItemDataStatus.Lock
    end

    if mapItemData:GetBuildStatus() == BuildingStatus.Empty then
        return MapItemDataStatus.Unlock
    end

    if mapItemData:IsBuilding() then
        return MapItemDataStatus.Building
    end

    if mapItemData:IsUpgrading() then
        return MapItemDataStatus.Upgrading
    end

    if mapItemData:GetLevel() == mapItemData.config.max_level then
        return MapItemDataStatus.MaxLevel
    end

    return MapItemDataStatus.Normal
end

function Utils.TableInsert(array, item)
    setmetatable(
        array,
        {
            __jsontype = "array",
            __name = "json.array"
        }
    )

    table.insert(array, item)
end

function Utils.TableInsertPos(array, pos, item)
    setmetatable(
        array,
        {
            __jsontype = "array",
            __name = "json.array"
        }
    )

    table.insert(array, pos, item)
end

---@param params MessageBoxParams
---@param last boolean lastOpenPanel
function Utils.OpenMessageBox(params, last)
    if last == true then
        PopupManager.Instance:LastOpenPanel(PanelType.MessageBoxPanel, params)
        return
    end

    UIUtil.showConfirmByData(params)
end

--- 返回item id，不适用于material
function Utils.GetItemId(cityId, itemType)
    if CityManager.GetIsEventScene(cityId) then
        local itemConfig = ConfigManager.GetItemByType(cityId, itemType)
        if itemConfig.type == "TimeSkip" then
            return itemType .. "_" .. cityId
        end

        return itemType .. cityId
    end

    return itemType
end

--- 返回排序物品
function Utils.SortItems(items)
    local ret = List:New()
    for itemId, count in pairs(items) do
        local item = {}
        item.itemId = itemId
        item.count = count
        ret:Add(item)
    end
    ret:Sort(
        function(p1, p2)
            return ConfigManager.GetItemConfig(p1.itemId).sort < ConfigManager.GetItemConfig(p2.itemId).sort
        end
    )
    return ret
end

---将浮点数的价格转换为整形的价格（美元=>美分）
function Utils.ToAmount(price)
    return math.floor((price + 0.5) * 100)
end

--尺寸适配
function Utils.SizeDeltaAdapter(sizeDelta)
    return this.SizeAdapter(sizeDelta.x, sizeDelta.y)
end

--尺寸适配
function Utils.SizeAdapter(sizeWidth, sizeHeight)
    local screenWidth = 0
    local screenHeight = 0
    if sizeWidth > Screen.width then
        local scale = sizeWidth / Screen.width
        screenWidth = Screen.width * scale
        screenHeight = Screen.height * scale
    elseif sizeHeight > Screen.height then
        local scale = sizeHeight / Screen.height
        screenWidth = Screen.width * scale
        screenHeight = Screen.height * scale
    else
        screenWidth = Screen.width
        screenHeight = Screen.height
    end

    local ratio = sizeHeight / sizeWidth
    local height = 0
    local width = 0
    if (screenHeight / screenWidth) >= ratio then
        height = screenHeight
        width = screenHeight / ratio
    else
        width = screenWidth
        height = screenWidth * ratio
    end
    return Vector2(width, height)
end

function Utils.IsNull(obj)
    return CS.FrozenCity.Utils.IsNull(obj)
end

function Utils.NotNull(obj)
    return not this.IsNull(obj)
end

--强制转换对象成为一个数组，array必须是一个合法的数组，才能正确转换，否则无法正确序列化为json
function Utils.MustArrayInsert(array, value)
    local meta = getmetatable(array)
    if meta ~= nil then
        meta.__jsontype = nil
        meta.__name = nil
        setmetatable(array, meta)
    end

    table.insert(array, value)
end

--平滑移动scroll view
function Utils.DoTweenVerticalScrollView(scrollView, content, height)
    if content.transform.rect.height - height < scrollView.transform.rect.height then
        height = height - (scrollView.transform.rect.height - (content.transform.rect.height - height))
    end

    return content.transform:DOAnchorPos(Vector2(0, height), 0.5)
end

-- 微信设置剪切板
function Utils.WXSetClipboardData(msg)
    local  privacy = WeChatWASM.RequirePrivacyAuthorizeOption.New()
    privacy.success = function (res)
        print("zhkxin RequirePrivacyAuthorize success", res and res.errMsg)
        local setClipboard =  WeChatWASM.SetClipboardDataOption.New()
        setClipboard.data = msg
        setClipboard.success = function(res)
            print("zhkxin setClipboard success", res and res.errMsg)
        end
        setClipboard.fail = function(res)
            print("zhkxin setClipboard fail", res and res.errMsg)
        end
        setClipboard.complete = function(res)
            print("zhkxin setClipboard complete", res and res.errMsg)
        end
        WeChatWASM.WX.SetClipboardData(setClipboard)
    end
    privacy.fail = function (res)
        print("zhkxin RequirePrivacyAuthorize fail", res and res.errMsg)
    end
    privacy.complete = function (res)
        print("zhkxin RequirePrivacyAuthorize complete", res and res.errMsg)
    end

    WeChatWASM.WX.RequirePrivacyAuthorize(privacy)
end

function Utils.FormatSize(size)
    if (size > 1000000) then
        local mSize = size / 1000000
        return string.format("%.2f", mSize) .. " M"
    elseif (size > 1000) then
        local kSize = size / 1000;
        return string.format("%.2f", kSize) .. " K"
    else
        return size .. " K"
    end
end

-- 重新登录弹窗(与服务器断开连接)
function Utils.ReLoginDailog(description, yesText)
    ShowUI(UINames.UIMessageBox, {
        Title = "ui_alert_title",
        Description = description,
        
        ShowYes = true,
        YesText = yesText,
        YesCallback = function ()
            -- 重登
            Utils.RestartMiniProgram()
        end,

        ShowNo = true,
        NoCallback = function () 
            -- 退出
            Utils.ExitMiniProgram()
        end,

        OnCloseFunc = function()
            -- 退出
            Utils.ExitMiniProgram()
        end
    })
end

-- 重新登录弹窗(顶号，强更)
function Utils.ReLoginDailogWithoutNoButton(description)
    ShowUI(UINames.UIMessageBox, {
        Title = "ui_alert_title",
        Description = description,
        
        ShowYes = true,
        YesCallback = function ()
            -- 重登
            Utils.RestartMiniProgram()
        end,

        OnCloseFunc = function()
            -- 重登
            Utils.RestartMiniProgram()
        end
    })
end

-- 退出游戏弹窗(停服维护)
function Utils.ReloginByServicePause(description)
    ShowUI(UINames.UIMessageBox, {
        Title = "ui_alert_title",
        Description = description,
        
        ShowYes = true,
        YesCallback = function ()
            -- 重登
            Utils.ExitMiniProgram()
        end,

        OnCloseFunc = function()
            -- 重登
            Utils.ExitMiniProgram()
        end
    })
end

function Utils.RestartMiniProgram(path)
    if PlayerModule.getSdkPlatform() == "wx" then
        local option = WeChatWASM.RestartMiniProgramOption.New()
        option.complete = function(res)
            print("zhkxin RestartMiniProgram complete: ", res.errMsg)
        end
        option.fail = function(res)
            print("zhkxin RestartMiniProgram fail: ", res.errMsg)
        end
        option.success = function(res)
            print("zhkxin RestartMiniProgram success: ", res.errMsg)
        end

        if path then 
            option.path = path
        end
        WeChatWASM.WX.RestartMiniProgram(option)
    else 
        GameStateData.isGameLogicRunning = false
        SceneManager:Inst():ChangeScene(SceneNames.LoginScene, function(_scene) end, false)
    end
end

function Utils.ExitMiniProgram()
    if PlayerModule.getSdkPlatform() == "wx" then
        local option = WeChatWASM.ExitMiniProgramOption.New()
        option.complete = function(res)
            print("zhkxin ExitMiniProgram complete: ", res.errMsg)
        end
        option.fail = function(res)
            print("zhkxin ExitMiniProgram fail: ", res.errMsg)
        end
        option.success = function(res)
            print("zhkxin ExitMiniProgram success: ", res.errMsg)
        end
        WeChatWASM.WX.ExitMiniProgram(option)
    else 
        Application.Quit()
    end
end

--- 获取表的数量
--- @param table table
--- @return integer
function Utils.GetTableCount(table)
    if table == nil or next(table) == nil then 
        return 0
    end 

    local count = 0
    for key, value in pairs(table) do
        count = count + 1
    end
    return count
end

--- 获取格子
function Utils.GetCell(x, y)
    local mapCtrl = CityModule.getMapCtrl()
    return mapCtrl:getCellByXY(x,y)
end

function Utils.SetFrameTarget(frame)
    frame = frame or Utils.GetFrameTarget()
    Application.targetFrameRate = frame
    if PlayerModule.getSdkPlatform() == "wx" then
        WeChatWASM.WX.SetPreferredFramesPerSecond(frame)
    end
end

function Utils.GetFrameTarget()
    if Application.isEditor then
        return -1
    end

    return 30
end

