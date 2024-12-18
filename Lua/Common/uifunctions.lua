---------------------------------------------------
-- UI相关的工具函数
---------------------------------------------------
UIFunctions = UIFunctions or {}
local this = UIFunctions;

local _StrNotFoundReturnWhat = "";

local key2TbTabUI = {}


function InitUIFunctions()
    for _, v in pairs(TbTabUI) do
        key2TbTabUI[v.Name] = v
    end
end

--默认加载界面
function ShowUI(uiName, ...)
    if uiName == UINames.UIOpenBox then
        TutorialManager.isOpeningUIOpenBox = true 
    end
    internalShowUI(uiName, true, ...)
   --- print(uiName, "ffffffffffffffffffffffffffffffff打开")
    if key2TbTabUI[uiName] and key2TbTabUI[uiName].isPlayAudio == 1 then
        Audio.PlayAudio(DefaultAudioID.OpenUI)
    end
end

--同步加载界面
function ShowUISync(uiName, ...)
    --print('[WxExtends]微信小游戏只能异步加载界面')
    ShowUIAsync(uiName, ...)
end

--按顺序异步加载界面
function ShowUIByOrder(uiName, ...)
    internalShowUI(uiName, true, ...)
end

--异步加载界面
function ShowUIAsync(uiName, ...)
    internalShowUI(uiName, true, ...)
end

function internalShowUI(uiName, _isAsync, ...)
    if uiName == nil then
        error("ShowUI Error! uiName is nil!")
        return;
    end

    if key2TbTabUI == nil then
        error("call internalShowUI but key2TbTabUI is nil!");
        InitUIFunctions();
    end

    local tbTabUI = key2TbTabUI[uiName];
    if tbTabUI == nil then
        error("ShowUI Error! not find data in uitable! uiname=" .. uiName);
        return;
    end

    if tbTabUI.MutexGroup == nil then
        error("ShowUI read 'MutexGroup' from table error! uiName=" .. uiName)
        tbTabUI.MutexGroup = 1;
    end

    if tbTabUI.DiedTime == nil then
        error("ShowUI read 'DiedTime' from table error! uiName=" .. uiName)
        tbTabUI.DiedTime = 0;
    end

    if tbTabUI.BgName == nil then
        tbTabUI.BgName = "";
    end

    if IsUIVisible(uiName) then
        HideUI(uiName);
    end

    PanelManager:CreatePanel(uiName, tbTabUI.ResName, tbTabUI.MutexGroup, tbTabUI.DiedTime,
        tbTabUI.Layer, tbTabUI.IsFullScreen, tbTabUI.BgName, tbTabUI.HideModel, tbTabUI.AutoAdapt, _isAsync, ...);
end

function IsUIVisible(uiName)
    if uiName == nil then
        error("[IsUIVisible] uiName is nil!")
        return false;
    end

    local isVisible = PanelManager:IsUIVisible(uiName);
    return isVisible;
end

function IsTopUI(uiName)
    if uiName == nil then
        error("[IsTopUI] uiName is nil!")
        return false;
    end

    local isVisible = PanelManager:IsTopUI(uiName);
    return isVisible or false;
end

-- 关闭UI
function HideUI(nameUI)
    if nameUI == nil then
        error("[HideUI] nameUI is nil!")
        return;
    end
    PanelManager:ClosePanel(nameUI, false);

    Event.Brocast(EventDefine.OnUIHide, nameUI)
    if key2TbTabUI[nameUI] and key2TbTabUI[nameUI].isPlayAudio == 1 then
        Audio.PlayAudio(DefaultAudioID.HideUI)
    end

    -- error("heide nameUI is "..nameUI)

    -- 这边界面关闭的时候延迟检测，防止跳转打开其他界面的时候时候触发引导
    TimeModule.addDelay(0.1, function()
        CheckAllPanelClose()
    end)
    
end

--关闭清理所有UI
function HideUIAll()
    PanelManager:CloseAllPanel();
end

-- 检测引导界面是否开启
function CheckAllPanelClose()
    for key, value in pairs(key2TbTabUI) do
        local isVisible = PanelManager:IsUIVisible(value.Name)
        if isVisible   then
            -- error("isVisible nameUI is "..value.Name)
            if (value.Name ~= "UIGuide" and value.Name ~= "UIMain" and value.Name ~= "UITips" and value.Name ~= "UIResAdd" and value.Name ~= "UIWaitTip") then
                return false
            end
        end
    end
    EventManager.Brocast(EventType.ALL_PANEL_CLOSE)
    return true
end

-----------------------------------------------------------------------------------------------------------------图片
-- 对obj下面结点转灰(黑白)/禁用
-- bFontGrey目前使用的字色是改成color=#9f9f9f
------------------------------------------------------------
function GreyObject(obj, bGrey, bEnable, bFontGrey)
    if nil == bFontGrey then bFontGrey = true end;
    UIInterface.GreyObject(obj, bGrey, bEnable, bFontGrey);
end

-- 对obj下面结点灰度(混合)/禁用
------------------------------------------------------------
function GreyMixObject(obj, bGrey, bEnable)
    UIInterface.GreyMixObject(obj, bGrey, bEnable, true);
end

-- 设置玩家头像，暂时都使用这个，到时候再加具体逻辑，不然每个会有界面遗留 todo
------------------------------------------------------------
function SetPlayerHeadIcon(imgObj, strIconUrl)
    local bTabIcon = true;
    if bTabIcon then
        if strIconUrl == nil or strIconUrl == "" then
            error("SetPlayerHeadIcon, HeadId==nil");
            strIconUrl = 1;
        end

        --直接用全局的吧
        local contextName = GlobalBehaviour.GetGlobalResContextName();
        local group = GlobalBehaviour.GetGlobalUIResGroup();
        local fieldHead = TableManager:Inst():GetTabData(EnumTableID.TabHeadIcon, strIconUrl);
        if nil == fieldHead then
            error("@策划, 头像Icon配置错误，并没有头像ID=" .. strIconUrl);
            return;
        end

        local fieldIcon = TableManager:Inst():GetTabData(EnumTableID.TabIcon, fieldHead.IconID);
        if nil == fieldIcon then
            error("@策划, Icon配置错误，IconId=" .. fieldHead.IconID);
            return;
        end

        ResGroupInterface.SetObjectImage(contextName, group, imgObj, fieldIcon.IconName, false, 0, 0, "", true);
    else
        --读取本地缓存之类的
    end
end

-- 设置icon, _go上面需要绑定UISprite
------------------------------------------------------------
function SetIconByDefault(luaBhv, _go, _iconId, bAsyn)
    SetIconByID(luaBhv, _go, _iconId, false, 0, 0, nil, bAsyn)
end

function SetImageMaterial(luaBhv, _go, _materialId, bAsyn)
    if nil == _materialId then return end;
    local matInfo = TableManager:Inst():GetTabData(EnumTableID.TabIcon, _materialId)
    if matInfo == nil then
        error("[SetImageMaterial]Error:not find data in TabIcon! materialId=" .. _materialId .. " objName=" .. _go.name);
        return
    end
    luaBhv:SetImageMaterial(_go, matInfo.IconName, bAsyn);
end

function SetIconByID(luaBhv, _go, _iconId, bMakePixelPerfect, width, heigh, _materialId, bAsyn, bAlphaFadeout)
    if _go == nil then
        error("[SetIconByID]Error: _go is nil");
        return;
    end

    if _iconId == nil then
        _iconId = ID_Icon_Money_Big_Diamond;

        --把路径也打出来吧，不然也是个难找
        local goPath = get_go_path(_go, "Layer_")
        error("@策划: 设置图标没有配置，使用默认钻石图标，看下显示的名称是什么物品, goPath=" ..
            tostring(goPath));
        --return;
    end

    local iconInfo = TableManager:Inst():GetTabData(EnumTableID.TabIcon, _iconId)
    if iconInfo == nil then
        error("@策划 [SetIconByID] Icon配置错误 iconid=" .. _iconId .. " objName=" .. _go.name);
        return
    end

    --目前材质和Icon配置到同一个表里了
    local matName = "";
    if nil ~= _materialId then
        local matInfo = TableManager:Inst():GetTabData(EnumTableID.TabIcon, _materialId)
        if matInfo == nil then
            error("@策划 [SetIconByID] Icon表中材质配置错误 materialId=" ..
                _materialId .. " objName=" .. _go.name);
            return
        end
        matName = matInfo.IconName;
    end

    if iconInfo.IconName == nil or iconInfo.IconName == "" then
        error("@策划[SetIconByID] iconInfo.IconName is nil! 图片未配置: iconId=" .. _iconId)
        return;
    end

    SetObjectImage(luaBhv, _go, iconInfo.IconName, bMakePixelPerfect, width, heigh, matName, bAsyn, bAlphaFadeout);
end

--检查并设置图片（自动检查是Sprite还是Texture）
function SetObjectImage(luaBhv, obj, imgNameWithEx, bMakePixelPerfect, width, heigh, _matNameWithEx, bAsyn, bAlphaFadeout)
    if heigh == nil or width == nil then
        width = 0;
        heigh = 0;
    end

    if imgNameWithEx == nil then
        error("[SetObjectImage] imgNameWithEx is nil!")
        return;
    end

    if bMakePixelPerfect == nil then
        bMakePixelPerfect = false;
    end

    _matNameWithEx = _matNameWithEx or "";
    if nil == bAsyn then bAsyn = true; end --默认异步
    if nil == bAlphaFadeout then bAlphaFadeout = false; end
    luaBhv:SetObjectImage(obj, imgNameWithEx, bMakePixelPerfect, width, heigh, _matNameWithEx, bAsyn, bAlphaFadeout)
end

--设置Sprite图片(Image类型)
function SetImage(luaBhv, image, imgNameWithEx, bMakePixelPerfect, width, heigh, _matNameWithEx, _bAsyn)
    if heigh == nil or width == nil then
        width = 0;
        heigh = 0;
    end

    if bMakePixelPerfect == nil then
        bMakePixelPerfect = false;
    end

    _matNameWithEx = _matNameWithEx or "";
    if nil == _bAsyn then _bAsyn = true; end --默认异步	
    luaBhv:SetImage(image, imgNameWithEx, bMakePixelPerfect, width, heigh, _matNameWithEx, _bAsyn)
end

function SetTextHexColor(textComp, hexColor)
    Util.SetTextHexColor(textComp, hexColor)
end

--设置Sprite图片(Texture类型)
function SetTexture(luaBhv, rawImage, imgNameWithEx, bMakePixelPerfect, width, heigh, _matNameWithEx, _bAsyn)
    if heigh == nil or width == nil then
        width = 0;
        heigh = 0;
    end

    if bMakePixelPerfect == nil then
        bMakePixelPerfect = false;
    end

    _matNameWithEx = _matNameWithEx or "";
    if nil == _bAsyn then _bAsyn = true; end --默认异步	
    luaBhv:SetTexture(rawImage, imgNameWithEx, bMakePixelPerfect, width, heigh, _matNameWithEx, _bAsyn)
end

------------------------------------
-- 给一个OBJ下面绑定特效
-- parentObj：obj点
-- relyonScaleObj：特效依赖的缩放点（如果为空，则会相对于parentObj进行自适应缩放）
-- effName特效名称
-- addCallFun(effGameObject) 回调函数，回调返回带当前特效的OBJ可用于脚本控制删除
------------------------------------
function AddUIEffect(parentObj, relyScaleObj, effName, addCallFun)
    local bRet = UIInterface.AddUIEffect(parentObj, relyScaleObj, effName, addCallFun)
    if not bRet then
        error("AddUIEffect Error: Name= " .. effName);
    end
end

function ShowUseGoldAskAgain(eMoneyType, funGetGold, funEnsure, funCancel, staticGold, strRightText)
    --如果函数是空并且金钱是0，直接不用弹出框
end

--要支持所有的奖励，道具，货币,英雄。。。
--以后不要用这个
function SetBonusItem(luaBhv, gameObject, id, strName, iconId, quality, strCount, clickCall, bTips)
    --[[
	local iconBgID = ItemQualityToBgIconID(quality);
	local iconBgName = TableManager:Inst():GetTableDataByKey(EnumTableID.TabIcon, iconBgID, "IconName");	
	local iconName = TableManager:Inst():GetTableDataByKey(EnumTableID.TabIcon, iconId, "IconName");
	local strTip = "";
	
	--无论如何都得再找一次表了
	--有可能还不是item，这个接口没办法用了
	local fieldItem = TableManager:Inst():GetTabData(EnumTableID.TabItem, id);
	if fieldItem.TipStrID ~= nil and fieldItem.TipStrID > 0 then
		strTip  = GetStaticStr(fieldItem.TipStrID);
	end	
	
	local upEventCall;
	local downEventCall;
	if(bTips) then
		upEventCall = OnItemBoxPress;
		downEventCall = OnItemBoxDown;
	end

	luaBhv:AddItemBox(gameObject, id, iconBgName, iconName, strName, strCount, strTip, clickCall, bTips, downEventCall, upEventCall, true)
	]]

    --乱了乱了，就用下面这个不要乱改，不然如果加参数了就改不动了
    SetItemBox(luaBhv, gameObject, id, strCount, clickCall, bTips)
end

function SetHeroBox(luaBhv, gameObject, genId, strCount, clickCall, bTips, downEventCall, upEventCall, bAsyn)
    local tabInfo = TableManager:Inst():GetTabData(EnumTableID.TabGeneral, genId);
    local strName = GetStaticStr(tabInfo.NameID);
    local iconBgID = GetHeroIconQualityBg(tabInfo.Quality);
    local iconBgName = TableManager:Inst():GetTableDataByKey(EnumTableID.TabIcon, iconBgID, "IconName");
    local iconName = TableManager:Inst():GetTableDataByKey(EnumTableID.TabIcon, tabInfo.IconID, "IconName");

    bTips = bTips or false;
    if (bTips) then
        if upEventCall == nil then
            local funUp = function()
                OnHeroBoxPress(gameObject, genId, 0, tabInfo);
            end
            upEventCall = funUp;
        end

        if downEventCall == nil then
            local funDown = function()
                OnHeroBoxDown(gameObject, genId, 0, tabInfo);
            end
            downEventCall = funDown;
        end
    else
        upEventCall = nil;
        downEventCall = nil;
    end

    if nil == bAsyn then
        bAsyn = true;
    end

    luaBhv:AddItemBox(gameObject, genId, iconBgName, iconName, strName, strCount, "", clickCall, downEventCall,
        upEventCall, bAsyn);
end

--
function SetSoldierBox(luaBhv, gameObject, soldierId, strCount, clickCall, bTips, downEventCall, upEventCall, bAsyn)
    local tabInfo = TableManager:Inst():GetTabData(EnumTableID.TabSoldierInfo, soldierId);
    local strName = GetStaticStr(tabInfo.NameID);
    local iconBgID = ItemQualityToBgIconID(eQualityBlue); --士兵目前没有颜色
    local iconBgName = TableManager:Inst():GetTableDataByKey(EnumTableID.TabIcon, iconBgID, "IconName");
    local iconName = TableManager:Inst():GetTableDataByKey(EnumTableID.TabIcon, tabInfo.IconID, "IconName");

    bTips = bTips or false;
    if (bTips) then
        if upEventCall == nil then
            local funUp = function()
                OnSoldierBoxPress(gameObject, soldierId, 0, tabInfo);
            end
            upEventCall = funUp;
        end

        if downEventCall == nil then
            local funDown = function()
                OnSoldierBoxDown(gameObject, soldierId, 0, tabInfo);
            end
            downEventCall = funDown;
        end
    else
        upEventCall = nil;
        downEventCall = nil;
    end

    if nil == bAsyn then
        bAsyn = true;
    end

    luaBhv:AddItemBox(gameObject, soldierId, iconBgName, iconName, strName, strCount, "", clickCall, downEventCall,
        upEventCall, bAsyn);
end

function SetFuWenBox(luaBhv, gameObject, fwId, strCount, clickCall, bTips, downEventCall, upEventCall, bAsyn)
    local tabInfo = TableManager:Inst():GetTabData(EnumTableID.TabFuWen, fwId);
    local strName = GetStaticStr(tabInfo.NameID);

    --类型(1绿、2红、3蓝)
    local iconBgID = ID_Item_BgColorNormal; --统一使用白色，不然很难看	
    local iconBgName = TableManager:Inst():GetTableDataByKey(EnumTableID.TabIcon, iconBgID, "IconName");
    local iconName = TableManager:Inst():GetTableDataByKey(EnumTableID.TabIcon, tabInfo.IconID, "IconName");

    if nil == bAsyn then
        bAsyn = true;
    end

    luaBhv:AddItemBox(gameObject, fwId, iconBgName, iconName, strName, strCount, "", clickCall, downEventCall,
        upEventCall, bAsyn);
end

function SetSkillBox(luaBhv, gameObject, skillId, clickCall, bTips, downEventCall, upEventCall, bAsyn)
    local tabInfo = TableManager:Inst():GetTabData(EnumTableID.TabSkill, skillId, true);
    if nil == tabInfo then
        error("@策划 兵种技能配置错误，没有找到技能配置，SkillID=" .. skillId);
        return;
    end

    local strName = GetStaticStr(tabInfo.NameID);
    local iconName = TableManager:Inst():GetTableDataByKey(EnumTableID.TabIcon, tabInfo.IconID, "IconName");
    if nil == iconName then
        error("@策划 兵种技能配置错误，没有找到技能图标，SkillID=" ..
            skillId .. " 图标ID=" .. tabInfo.IconID);
        return;
    end

    bTips = bTips or false;
    if (bTips) then
        if downEventCall == nil then
            local funDown = function()
                OnSkillBoxDown(gameObject, skillId, 0, tabInfo);
            end
            downEventCall = funDown;
        end

        if upEventCall == nil then
            local funUp = function()
                OnSkillBoxPress(gameObject, skillId, 0, tabInfo);
            end
            upEventCall = funUp;
        end
    else
        upEventCall = nil;
        downEventCall = nil;
    end

    if nil == bAsyn then
        bAsyn = true;
    end

    luaBhv:AddItemBox(gameObject, skillId, "", iconName, strName, "", "", clickCall, downEventCall, upEventCall, bAsyn);
end

function SetSkillBoxScript(luaBhv, gameObject, skillId, objIconImg, clickCall, bTips, downEventCall, upEventCall)
    local tabInfo = TableManager:Inst():GetTabData(EnumTableID.TabSkill, skillId, true);
    if nil == tabInfo then
        error("@策划 兵种技能配置错误，没有找到技能配置，SkillID=" .. skillId);
        return;
    end

    SetIconByID(luaBhv, objIconImg, tabInfo.IconID);

    bTips = bTips or false;
    if (bTips) then
        if downEventCall == nil then
            local funDown = function()
                OnSkillBoxDown(gameObject, skillId, 0, tabInfo);
            end
            downEventCall = funDown;
        end

        if upEventCall == nil then
            local funUp = function()
                OnSkillBoxPress(gameObject, skillId, 0, tabInfo);
            end
            upEventCall = funUp;
        end
    else
        upEventCall = nil;
        downEventCall = nil;
    end

    luaBhv:AddLongPressEvent(gameObject, downEventCall, upEventCall, clickCall, 0.1);
end

function SetEquipBoxScript(luaBhv, gameObject, equipResId, objIconImg, objBgImg, clickCall, bTips, downEventCall,
                           upEventCall)
    local tabInfo = TableManager:Inst():GetTabData(EnumTableID.TabEquip, equipResId, true);
    if nil == tabInfo then
        error("@策划 装备表配置请检查，equipResId=" .. equipResId);
        return;
    end

    SetIconByID(luaBhv, objIconImg, tabInfo.IconId); --妈的小写
    if nil ~= objBgImg then
        local eqIconBgID = EquipQualityToBgIconID(tabInfo.Quality);
        SetIconByID(luaBhv, objBgImg, eqIconBgID);
    end

    bTips = bTips or false;
    if (bTips) then
        if downEventCall == nil then
            local funDown = function()
                OnEquipBoxDown(gameObject, equipResId, 0, tabInfo);
            end
            downEventCall = funDown;
        end

        if upEventCall == nil then
            local funUp = function()
                OnEquipBoxPress(gameObject, equipResId, 0, tabInfo);
            end
            upEventCall = funUp;
        end
    else
        upEventCall = nil;
        downEventCall = nil;
    end

    luaBhv:AddLongPressEvent(gameObject, downEventCall, upEventCall, clickCall, 0.1);
end

-- clickCall回调带itemID参数
function SetItemBox(luaBhv, gameObject, itemID, strCount, clickCall, bTips, downEventCall, upEventCall, bAsyn)
    if nil == bAsyn then
        bAsyn = true;
    end

    local quality = eQualityWhite;
    local iconID = 0;
    local strName;
    local strTips = "";

    local tabInfo;
    local at = GetAssetType(itemID)
    if at == eAssetType_Money then
        tabInfo = TableManager:Inst():GetTabData(EnumTableID.TabMoney, itemID);
        if tabInfo == nil then
            return;
        end

        quality = tabInfo.Quality;
        iconID = tabInfo.BigIcon;
        strName = GetStaticStr(tabInfo.Name);
    elseif at == eAssetType_Item then
        tabInfo = TableManager:Inst():GetTabData(EnumTableID.TabItem, itemID);
        if tabInfo == nil then
            error("@策划 Item配置错误，Item表中没有此物品，itemID=" .. itemID);
            return;
        end

        quality = tabInfo.Quality;
        iconID = tabInfo.IconID;
        strName = GetStaticStr(tabInfo.NameID);
        if tabInfo.TipStrID ~= nil and tabInfo.TipStrID > 0 then
            strTips = GetStaticStr(tabInfo.TipStrID);
        end
    elseif at == eAssetType_Equip then
        tabInfo = TableManager:Inst():GetTabData(EnumTableID.TabEquip, itemID);
        if tabInfo == nil then
            error("@策划 装备配置错误，Equip表中没有此装备，EquipID=" .. itemID);
            return;
        end

        quality = tabInfo.Quality;
        iconID = tabInfo.IconId;
        strName = GetStaticStr(tabInfo.NameId);
        strCount = "";
    else
        --可能要清理之类的
        luaBhv:AddItemBox(gameObject, itemID, "", "", "", "", "", nil, nil, nil, bAsyn)
        return;
    end

    local iconBgID = ItemQualityToBgIconID(quality);
    local iconBgName = TableManager:Inst():GetTableDataByKey(EnumTableID.TabIcon, iconBgID, "IconName");
    local iconName = TableManager:Inst():GetTableDataByKey(EnumTableID.TabIcon, iconID, "IconName");
    if nil == iconName then
        error("@策划 Icon配置错误，iconID=" .. iconID);
        return;
    end

    bTips = bTips or false;
    if (bTips) then
        if upEventCall == nil then
            local funUp = function()
                OnItemBoxPress(gameObject, itemID, at, tabInfo);
            end
            upEventCall = funUp;
        end

        if downEventCall == nil then
            local funDown = function()
                OnItemBoxDown(gameObject, itemID, at, tabInfo);
            end
            downEventCall = funDown;
        end
    else
        upEventCall = nil;
        downEventCall = nil;
    end


    luaBhv:AddItemBox(gameObject, itemID, iconBgName, iconName, strName, tostring(strCount), strTips, clickCall,
        downEventCall, upEventCall, bAsyn)
end

function SetItemIcon(luaBhv, iconObj, bgObj, itemID)
    local itemField = TableManager:Inst():GetTabData(EnumTableID.TabItem, itemID);
    if nil ~= iconObj then
        SetIconByID(luaBhv, iconObj, itemField["IconID"])
    end
    if nil ~= bgObj then
        local iconBgID = ItemQualityToBgIconID(itemField["Quality"]);
        SetIconByID(luaBhv, bgObj, iconBgID)
    end
end

function OnItemBoxPress(gameObject, itemID, at, tabInfo)
    HideUI(UINames.UIToolTips);
end

function OnItemBoxDown(gameObject, itemID, at, tabInfo)
    local nameID;
    local descID;

    if at == eAssetType_Money then
        nameID = tabInfo.Name;
        descID = tabInfo.Info;
    elseif at == eAssetType_Item then
        nameID = tabInfo.NameID;
        descID = tabInfo.DescID;
    elseif at == eAssetType_Equip then
        nameID = tabInfo.NameId; --nnd小写
        descID = tabInfo.NameId; --没有别的描述			
    end

    if nil == nameID or nil == descID then
        return;
    end

    ShowUI(UINames.UIToolTips, gameObject, nameID, descID);
end

function OnHeroBoxPress(gameObject, genId, at, tabInfo)
    HideUI(UINames.UIToolTips);
end

function OnHeroBoxDown(gameObject, genId, at, tabInfo)
    ShowUI(UINames.UIToolTips, gameObject, tabInfo.NameID, tabInfo.NameID); --士兵并无其它说明
end

function OnSoldierBoxPress(gameObject, soldierId, at, tabInfo)
    HideUI(UINames.UIToolTips);
end

function OnSoldierBoxDown(gameObject, soldierId, at, tabInfo)
    ShowUI(UINames.UIToolTips, gameObject, tabInfo.NameID, tabInfo.DescID);
end

---技能
function OnSkillBoxPress(gameObject, skillId, at, tabInfo)
    HideUI(UINames.UISkillTips);
end

function OnSkillBoxDown(gameObject, skillId, at, tabInfo)
    ShowUI(UINames.UISkillTips, skillId);
end

---装备
function OnEquipBoxPress(gameObject, equipResId, at, tabInfo)
    HideUI(UINames.UIToolTips);
end

function OnEquipBoxDown(gameObject, equipResId, at, tabInfo)
    --todo 改装备提示的时候，别忘了改这里
    ShowUI(UINames.UIToolTips, gameObject, tabInfo.NameId, tabInfo.NameId);
end

--联盟城市
function OnAllianceCityPress(gameObject)
    --HideUI(UINames.UIAllianceCityFunTips);
end

function OnAllianceCityDown(gameObject, functionId)
    --ShowUI(UINames.UIAllianceCityFunTips, gameObject, functionId);
end

function SetAllianceCityScript(luaBhv, gameObject, functionId, clickCall, bTips, downEventCall, upEventCall)
    bTips = bTips or false;
    if (bTips) then
        if upEventCall == nil then
            local funUp = function()
                --OnAllianceCityPress(gameObject);
            end
            upEventCall = funUp;
        end

        if downEventCall == nil then
            local funDown = function()
                --OnAllianceCityDown(gameObject,functionId);
            end
            downEventCall = funDown;
        end
    else
        upEventCall = nil;
        downEventCall = nil;
    end

    luaBhv:AddLongPressEvent(gameObject, downEventCall, upEventCall, clickCall, 0.1);
end

--联盟职位

function OnMemberBoxDown(gameObject, memberGUID)
    ShowUI(UINames.UIDuty, memberGUID);
end

function SetMemberBoxScript(luaBhv, gameObject, memberGUID, clickCall, bTips, downEventCall, upEventCall)
    bTips = bTips or false;
    if (bTips) then
        if clickCall == nil then
            OnMemberBoxDown(gameObject, memberGUID);
        end
    else
        upEventCall = nil;
        downEventCall = nil;
    end
    luaBhv:AddLongPressEvent(gameObject, downEventCall, upEventCall, clickCall, 0.1);
end

---------------------------------------------------------------------------------------------------------------文本
-- 给文本设置有换行符号的文本，不能直接text=str
function SetFormatText(lbText, strText)
    if nil == lbText then
        return;
    end
    strText = strText or "";
    lbText.text = string.gsub(strText, "\\n", "\n");
end

-------------------------------------------------------------------------------------------------------------模型
-- 添加血条
function AddHealthBar(bRedHealth, bindObj, offset, callBack, isActive)
    --ShowUI(UINames.UIHealthBar, bindObj, offset, callBack);

    --创建血条对象
    local hpParams = RenderHealthBarCreateParams.New();
    hpParams.IsActive = isActive
    if bRedHealth then
        hpParams.ModelName = StaticModelID.ID_Model_HealthBarRed;
    else
        hpParams.ModelName = StaticModelID.ID_Model_HealthBarBlue;
    end

    local parentTransform = PanelManager.GUILayerHUD:Find("DamageHPRoot");
    if parentTransform == nil then
        parentTransform = PanelManager.GUILayerHUD;
    end

    hpParams.Parent = parentTransform.gameObject;
    hpParams.BindObj = bindObj;
    hpParams.BindOffset = offset;
    hpParams.WorldPos = Vector3.New(10000, 10000, 10000); --创建的时候直接挪开，否则会在000点闪现

    hpParams.BindBestDistance = 20;
    hpParams.BindScaleFactor = 1.0;
    hpParams.BindMaxScale = 1.0;
    hpParams.BindMinScale = 0.8;

    hpParams.OnLoadFinshCallback = callBack;

    local hpObject = RenderSystem.GetInstance():CreateRenderObject(hpParams);

    if (not hpObject:Create()) then
        return nil;
    end

    return hpObject;
end

----------------------------------------------------------------------------------------------------------------逻辑
-- 警告提示
function ShowWarningTips(str)
    ShowUI(UINames.UITips, str);
end

-- 错误弹出框
function ShowErrorTips(str)
    ShowUI(UINames.UITips, str);
end

-- 正确提示
function ShowTips(str)
    ShowUI(UINames.UITips, str);
end

function ShowErrorTipsEx(strEnum, ...)
    local str = GetStrDic(strEnum);
    if str == nil then
        return;
    end

    ShowUI(UINames.UITips, string.format(str, unpack({ ... })));
end

function ShowTipsEx(strEnum, ...)
    local str = GetStrDic(strEnum);
    if str == nil then
        return;
    end

    ShowUI(UINames.UITips, string.format(str, unpack({ ... })));
end

function GetStrDic(strEnum, ...)
    if strEnum == nil then
        error("GetStrDic strEnum is nil!")
        return _StrNotFoundReturnWhat;
    end

    local str = TableManager:Inst():GetTableDataByKey(EnumTableID.TabStrDic, strEnum, "Str");
    if str == nil then
        if not GameStateData.IsChineseSimplified then
            str = TryGetStringFromChineseSimplifiedTable(EnumTableID.TabStrDic_ChineseSimplified, strEnum, "Str", ...)
        end
        if str == nil then
            return _StrNotFoundReturnWhat;
        end
    end

    if ... == nil then
        return str;
    end

    return string.format(str, ...);
end

--临时措施，如果当前不是简体中文，有可能是语言表格不全，尝试返回简体中文表格
function TryGetStringFromChineseSimplifiedTable(tableID, strEnum, strField, ...)
    return nil;

    -- if tableID == nil then
    -- 	error("TryGetStringFromChineseSimplifiedTable tableID is nil!")
    -- 	return nil;
    -- end

    -- local str = TableManager:Inst():GetTableDataByKey(tableID, strEnum, strField);
    -- if str == nil then
    -- 	return nil;
    -- end

    -- if ... == nil then
    -- 	return str;
    -- end

    -- local ret = string.format(str, ...)
    -- return ret;	
end

function GetStaticStr(id, bReplaceLineFeed)
    if id == nil then
        error("GetStaticStr id is nil!")
        return _StrNotFoundReturnWhat;
    end

    local numId = tonumber(id);
    if numId == nil then
        if GIsEdit or GIsDevelopment then
            error("[GetStaticStr]invalid param id=" .. id);
        end
        return _StrNotFoundReturnWhat;
    end

    local str;
    if numId < 1000000 then
        str = TableManager:Inst():GetTableDataByKey(EnumTableID.TabStaticStr, numId, "Str");
        if str == nil and not GameStateData.IsChineseSimplified then
            str = TryGetStringFromChineseSimplifiedTable(EnumTableID.TabStaticStr_ChineseSimplified, numId, "Str")
        end
    else
        str = TableManager:Inst():GetTableDataByKey(EnumTableID.TabStrDialouge, numId, "Str");
        if str == nil and not GameStateData.IsChineseSimplified then
            str = TryGetStringFromChineseSimplifiedTable(EnumTableID.TabStrDialouge_ChineseSimplified, numId, "Str")
        end
    end
    if str == nil then
        return _StrNotFoundReturnWhat;
    end
    if bReplaceLineFeed then
        return string.gsub(str, "\\n", "\n");
    else
        return str;
    end
end

function GetDialogueStr(id)
    local str = TableManager:Inst():GetTableDataByKey(EnumTableID.TabStrDialouge, id, "Str");
    if str == nil and not GameStateData.IsChineseSimplified then
        str = TryGetStringFromChineseSimplifiedTable(EnumTableID.TabStrDialouge_ChineseSimplified, id, "Str")
    end

    if str == nil then
        return _StrNotFoundReturnWhat;
    end

    return str;
end

function GetGameConfig(id)
    return TableManager:Inst():GetTableDataByKey(EnumTableID.TabGameConfig, id, "Value");
end

function GetGameConfigAsNumber(id)
    return tonumber(TableManager:Inst():GetTableDataByKey(EnumTableID.TabGameConfig, id, "Value"));
end

--得到格式化的战力
function GetFormatPower(power)
    return NumberFormatWithDep(power)
end

------------------------------------------------------------
-- 提示金钱不足
------------------------------------------------------------
function TipMoneyNotEnough(eMoneyType)
    local Name = TableManager:Inst():GetTableDataByKey(EnumTableID.TabMoney, eMoneyType, "Name");
    local moneyName = GetStaticStr(Name);
    local tips = string.format(GetStrDic(StrEnum.LimitBuildingCreateUpMoney), moneyName)
    ShowTips(tips);
end

--按千分之一减少/增加
function RefixSliderAddSubCountOnce(maxDataValue)
    local wei = math.floor(math.log10(maxDataValue));
    --local wei = math.log10(maxDataValue);
    if wei < 2 then wei = 2 end
    local value = (10 ^ (wei - 2));
    return value;
end

---------------------------------------------
-- 根据颜色得到物品的Item背景id
---------------------------------------------
function ItemQualityToBgIconID(eQuality)
    if nil == eQuality then
        eQuality = eQualityNormal;
    end

    if eQuality == eQualityNormal then
        return ID_Item_BgColorNormal;
    elseif eQuality == eQualityOrange then
        return ID_Item_BgColorOrange;
    elseif eQuality == eQualityPurple then
        return ID_Item_BgColorPurple;
    elseif eQuality == eQualityBlue then
        return ID_Item_BgColorBlue;
    elseif eQuality == eQualityGreen then
        return ID_Item_BgColorGreen;
    elseif eQuality == eQualityWhite then
        return ID_Item_BgColorWhite;
    else
        error("SetItemImgObjQualityIcon Error : color = " .. eQuality)
        return -1;
    end
end

---------------------------------------------
-- 根据颜色得到装备背景id
---------------------------------------------
function EquipQualityToBgIconID(eQuality)
    if nil == eQuality then
        eQuality = eQualityNormal;
    end

    if eQuality == eQualityNormal then
        return ID_Equip_BgColorNormal;
    elseif eQuality == eQualityOrange then
        return ID_Equip_BgColorOrange;
    elseif eQuality == eQualityPurple then
        return ID_Equip_BgColorPurple;
    elseif eQuality == eQualityBlue then
        return ID_Equip_BgColorBlue;
    elseif eQuality == eQualityGreen then
        return ID_Equip_BgColorGreen;
    elseif eQuality == eQualityWhite then
        return ID_Equip_BgColorWhite;
    else
        error("SetItemImgObjQualityIcon Error : eQuality = " .. eQuality)
        return -1;
    end
end

---------------------------------------------
--  设置英雄obj上image的颜色背景框
---------------------------------------------
function SetHeroImgObjQualityIcon(luaBhv, imgObj, eQuality)
    if nil == imgObj then
        return;
    end

    if nil == eQuality then
        eQuality = eQualityNormal;
    end

    local iconBgID = GetHeroIconQualityBg(eQuality);
    SetIconByID(luaBhv, imgObj, iconBgID);
end

function GetHeroIconQualityBg(eQuality)
    if eQuality == eQualityNormal then
        return ID_Icon_BgColorNormal;
    elseif eQuality == eQualityOrange then
        return ID_Icon_BgColorOrange;
    elseif eQuality == eQualityPurple then
        return ID_Icon_BgColorPurple;
    elseif eQuality == eQualityBlue then
        return ID_Icon_BgColorBlue;
    elseif eQuality == eQualityGreen then
        return ID_Icon_BgColorGreen;
    elseif eQuality == eQualityWhite then
        return ID_Icon_BgColorWhite;
    else
        error("SetHeroImgObjColorIcon Error : color = " .. eQuality)
    end
    return ID_Icon_BgColorNormal;
end

---------------------------------------------
--  设置装备obj上image的颜色背景框
---------------------------------------------
function SetEquipObjQualityIcon(luaBhv, imgObj, eQuality)
    if nil == imgObj then
        return;
    end

    if nil == eQuality then
        eQuality = eQualityNormal;
    end

    if eQuality == eQualityNormal then
        SetIconByID(luaBhv, imgObj, ID_Equip_BgColorNormal);
    elseif eQuality == eQualityOrange then
        SetIconByID(luaBhv, imgObj, ID_Equip_BgColorOrange);
    elseif eQuality == eQualityPurple then
        SetIconByID(luaBhv, imgObj, ID_Equip_BgColorPurple);
    elseif eQuality == eQualityBlue then
        SetIconByID(luaBhv, imgObj, ID_Equip_BgColorBlue);
    elseif eQuality == eQualityGreen then
        SetIconByID(luaBhv, imgObj, ID_Equip_BgColorGreen);
    elseif eQuality == eQualityWhite then
        SetIconByID(luaBhv, imgObj, ID_Equip_BgColorWhite);
    else
        error("SetEquipObjQualityIcon Error : color = " .. eQuality)
    end
end

---------------------------------------------
--  设置天赋上image的颜色背景框
---------------------------------------------
function SetTalentQualityIcon(luaBhv, imgObj, eQuality)
    if nil == imgObj then
        return;
    end

    if nil == eQuality then
        eQuality = eQualityNormal;
    end

    if eQuality == eQualityNormal then
        SetIconByID(luaBhv, imgObj, ID_Talent_BgColorNormal);
    elseif eQuality == eQualityOrange then
        SetIconByID(luaBhv, imgObj, ID_Talent_BgColorOrange);
    elseif eQuality == eQualityPurple then
        SetIconByID(luaBhv, imgObj, ID_Talent_BgColorPurple);
    elseif eQuality == eQualityBlue then
        SetIconByID(luaBhv, imgObj, ID_Talent_BgColorBlue);
    elseif eQuality == eQualityGreen then
        SetIconByID(luaBhv, imgObj, ID_Talent_BgColorGreen);
    elseif eQuality == eQualityWhite then
        SetIconByID(luaBhv, imgObj, ID_Talent_BgColorWhite);
    else
        error("SetTalentQualityIcon Error : Quality = " .. eQuality)
    end
end

---------------------------------------------
--  设置英雄品质底图(头像小图标IconID)
---------------------------------------------
function SetHeroImgObjQualityIconType(luaBhv, imgObj, eQuality)
    if nil == imgObj then
        return;
    end

    if nil == eQuality then
        eQuality = eQualityNormal;
    end

    if eQuality == eQualityNormal then
        SetIconByID(luaBhv, imgObj, ID_Icon_BgColorNormal_Type);
    elseif eQuality == eQualityOrange then
        SetIconByID(luaBhv, imgObj, ID_Icon_BgColorOrange_Type);
    elseif eQuality == eQualityPurple then
        SetIconByID(luaBhv, imgObj, ID_Icon_BgColorPurple_Type);
    elseif eQuality == eQualityBlue then
        SetIconByID(luaBhv, imgObj, ID_Icon_BgColorBlue_Type);
    elseif eQuality == eQualityGreen then
        SetIconByID(luaBhv, imgObj, ID_Icon_BgColorGreen_Type);
    elseif eQuality == eQualityWhite then
        SetIconByID(luaBhv, imgObj, ID_Icon_BgColorWhite_Type);
    else
        error("SetHeroImgObjQualityIconType Error : color = " .. eQuality)
    end
end

---------------------------------------------
--  设置英雄品质底图(图片大图标对应PhotoID)
---------------------------------------------
function SetHeroPhothObjQualityIconType(luaBhv, imgObj, eQuality)
    if nil == imgObj then
        return;
    end

    if nil == eQuality then
        eQuality = eQualityNormal;
    end

    if eQuality == eQualityNormal then
        SetIconByID(luaBhv, imgObj, ID_Icon_HeroPhoto_BgColorNormal_Type);
    elseif eQuality == eQualityOrange then
        SetIconByID(luaBhv, imgObj, ID_Icon_HeroPhoto_BgColorOrange_Type);
    elseif eQuality == eQualityPurple then
        SetIconByID(luaBhv, imgObj, ID_Icon_HeroPhoto_BgColorPurple_Type);
    elseif eQuality == eQualityBlue then
        SetIconByID(luaBhv, imgObj, ID_Icon_HeroPhoto_BgColorBlue_Type);
    elseif eQuality == eQualityGreen then
        SetIconByID(luaBhv, imgObj, ID_Icon_HeroPhoto_BgColorGreen_Type);
    elseif eQuality == eQualityWhite then
        SetIconByID(luaBhv, imgObj, ID_Icon_HeroPhoto_BgColorWhite_Type);
    else
        error("SetHeroPhothObjQualityIconType Error : color = " .. eQuality)
    end
end

---------------------------------------------
--  设置英雄带兵种类图标
---------------------------------------------
function SetHeroSoldierTypeIcon(luaBhv, imgObj, soldierType)
    if nil == imgObj then
        return;
    end

    if nil == soldierType then
        return;
    end

    if soldierType == eSoldier_Infantryinfo then
        SetIconByID(luaBhv, imgObj, ID_Icon_eSoldier_Infantryinfo);
    elseif soldierType == eSoldier_Cavalry then
        SetIconByID(luaBhv, imgObj, ID_Icon_eSoldier_Cavalry);
    elseif soldierType == eSoldier_Archer then
        SetIconByID(luaBhv, imgObj, ID_Icon_eSoldier_Archer);
    elseif soldierType == eSoldier_Master then
        SetIconByID(luaBhv, imgObj, ID_Icon_eSoldier_Master);
    else
        error("SetHeroSoldierTypeIcon Error : soldierType = " .. soldierType)
    end
end

function GetTextColorByQuality(quality)
    if this.qualityToColor == nil then
        this.qualityToColor = {}
        this.qualityToColor[eQualityType_White] = Color.New(0.859, 0.855, 0.855, 1)
        this.qualityToColor[eQualityType_Green] = Color.New(0.686, 0.965, 0.247, 1)
        this.qualityToColor[eQualityType_Blue] = Color.New(0.247, 0.767, 0.965, 1)
        this.qualityToColor[eQualityType_Purple] = Color.New(0.5, 0, 0.5, 1)
        this.qualityToColor[eQualityType_Orange] = Color.New(0.622, 1, 0, 1)
    end
    return this.qualityToColor[quality];
end

function FormatColorTextByQuality(quality, text)
    if quality == eQualityType_White then
        return "<color=#FFFFFF>" .. text .. "</color>";
    elseif quality == eQualityType_Green then
        return "<color=#3CB371>" .. text .. "</color>";
    elseif quality == eQualityType_Blue then
        return "<color=#4169E1>" .. text .. "</color>"
    elseif quality == eQualityType_Purple then
        return "<color=#800080>" .. text .. "</color>"
    elseif quality == eQualityType_Orange then
        return "<color=#FF8C00>" .. text .. "</color>"
    else
        return text;
    end
end

function FormatColorStrByQuality(quality, text, id)
    local at = GetAssetType(id)
    if at == eAssetType_FuWen then
        local data = TableManager:Inst():GetTabData(EnumTableID.TabFuWen, id)
        if data ~= nil then
            if data.Type == 1 then
                return "<color=#b7e23a>" .. text .. "</color>"
            elseif data.Type == 2 then
                return "<color=#d2502eff>" .. text .. "</color>"
            elseif data.Type == 3 then
                return "<color=#6390db>" .. text .. "</color>"
            end
        end
    end

    if quality == eQualityType_White then
        return "<color=#FFFFFF>" .. text .. "</color>";
    elseif quality == eQualityType_Green then
        return "<color=#b7e23a>" .. text .. "</color>";
    elseif quality == eQualityType_Blue then
        return "<color=#6390db>" .. text .. "</color>"
    elseif quality == eQualityType_Purple then
        return "<color=#9c60ff>" .. text .. "</color>"
    elseif quality == eQualityType_Orange then
        return "<color=#FF8C00>" .. text .. "</color>"
    else
        return text;
    end
end

---------------------------------------------
--  设置士兵头像Icon(只是在没有带兵的时候，需要一个加号这样的默认图标的处理)
---------------------------------------------
function SetHeroArmyIcon(luaBhv, imgObj, iconID)
    if nil == iconID or iconID < 1 then
        iconID = ID_Icon_Empty_SoldierID; --army_empty	
    end
    SetIconByID(luaBhv, imgObj, iconID)
end

local propId2NameId = nil;
function GetPropName(propId)
    if propId2NameId == nil then
        propId2NameId = {};
        propId2NameId[CombatPropertyID.COMBAT_PROP_HPMAX] = StrEnum.COMBAT_PROP_HPMAX;
        propId2NameId[CombatPropertyID.COMBAT_PROP_BODY_FORCE_MAX] = StrEnum.COMBAT_PROP_BODY_FORCE_MAX;
        propId2NameId[CombatPropertyID.COMBAT_PROP_SOLDIER_COUNT] = StrEnum.COMBAT_PROP_SOLDIER_COUNT;
        propId2NameId[CombatPropertyID.COMBAT_PROP_BODY_FORCE] = StrEnum.COMBAT_PROP_BODY_FORCE;
        propId2NameId[CombatPropertyID.COMBAT_PROP_PHY_ATTACK] = StrEnum.COMBAT_PROP_PHY_ATTACK;
        propId2NameId[CombatPropertyID.COMBAT_PROP_MANA_ATTACK] = StrEnum.COMBAT_PROP_MANA_ATTACK;
        propId2NameId[CombatPropertyID.COMBAT_PROP_PHY_DEF] = StrEnum.COMBAT_PROP_PHY_DEF;
        propId2NameId[CombatPropertyID.COMBAT_PROP_MANA_DEF] = StrEnum.COMBAT_PROP_MANA_DEF;
        propId2NameId[CombatPropertyID.COMBAT_PROP_BLOOD] = StrEnum.COMBAT_PROP_BLOOD;
        propId2NameId[CombatPropertyID.COMBAT_PROP_BLOCK] = StrEnum.COMBAT_PROP_BLOCK;
        propId2NameId[CombatPropertyID.COMBAT_PROP_RESIST] = StrEnum.COMBAT_PROP_RESIST;
        propId2NameId[CombatPropertyID.COMBAT_PROP_CRIT] = StrEnum.COMBAT_PROP_CRIT;
        propId2NameId[CombatPropertyID.COMBAT_PROP_ATTACK_SPEED] = StrEnum.COMBAT_PROP_ATTACK_SPEED;
        propId2NameId[CombatPropertyID.COMBAT_PROP_HATRED] = StrEnum.COMBAT_PROP_HATRED;
        propId2NameId[CombatPropertyID.COMBAT_PROP_PYH_PENETRATE] = StrEnum.COMBAT_PROP_PYH_PENETRATE;
        propId2NameId[CombatPropertyID.COMBAT_PROP_MAGIC_PENETRATE] = StrEnum.COMBAT_PROP_MAGIC_PENETRATE;

        propId2NameId[CombatPropertyID.COMBAT_PROP_SKILLRATE] = StrEnum.COMBAT_PROP_SKILLRATE;
        propId2NameId[CombatPropertyID.COMBAT_PROP_REFLECT] = StrEnum.COMBAT_PROP_REFLECT;
        propId2NameId[CombatPropertyID.COMBAT_PROP_CRITDAMAGE] = StrEnum.COMBAT_PROP_CRITDAMAGE;
        propId2NameId[CombatPropertyID.COMBAT_PROP_EX_PYH_PENETRATE] = StrEnum.COMBAT_PROP_EX_PYH_PENETRATE;
        propId2NameId[CombatPropertyID.COMBAT_PROP_EX_MAGIC_PENETRATE] = StrEnum.COMBAT_PROP_EX_MAGIC_PENETRATE;
        propId2NameId[CombatPropertyID.COMBAT_PROP_EX_BLOCK] = StrEnum.COMBAT_PROP_EX_BLOCK;
        propId2NameId[CombatPropertyID.COMBAT_PROP_EX_RESIST] = StrEnum.COMBAT_PROP_EX_RESIST;
        propId2NameId[CombatPropertyID.COMBAT_PROP_EX_CRIT] = StrEnum.COMBAT_PROP_EX_CRIT;


        propId2NameId[CombatPropertyID.COMBAT_PROP_SWORD] = StrEnum.COMBAT_PROP_SWORD;
        propId2NameId[CombatPropertyID.COMBAT_PROP_INTELLIGENCE] = StrEnum.COMBAT_PROP_INTELLIGENCE;
        propId2NameId[CombatPropertyID.COMBAT_PROP_CONTROL] = StrEnum.COMBAT_PROP_CONTROL;
        propId2NameId[CombatPropertyID.COMBAT_PROP_SPEED] = StrEnum.COMBAT_PROP_SPEED;

        --[[
		propId2NameId[CombatPropertyID.COMBAT_PROP_SWORD_GROWUP] = StrEnum.COMBAT_PROP_SWORD_GROWUP;
		propId2NameId[CombatPropertyID.COMBAT_PROP_INTELLIGENCE_GROWUP] = StrEnum.COMBAT_PROP_INTELLIGENCE_GROWUP;
		propId2NameId[CombatPropertyID.COMBAT_PROP_CONTROL_GROWUP] = StrEnum.COMBAT_PROP_CONTROL_GROWUP;
		propId2NameId[CombatPropertyID.COMBAT_PROP_SPEED_GROWUP] = StrEnum.COMBAT_PROP_SPEED_GROWUP;
		]]

        propId2NameId[CombatPropertyID.COMBAT_PROP_GENERAL_LEVEL] = StrEnum.COMBAT_PROP_GENERAL_LEVEL;
    end

    local errorPropName = "<NULL>";
    if propId == nil then
        error("propId is nil");
        return errorPropName;
    end

    local textId = propId2NameId[propId];
    if textId == nil then
        error("no find propId name. propId = " .. propId);
        return errorPropName;
    end

    local text = GetStrDic(textId);
    if text == nil or text == "" then
        error("propId name is null. textId = " .. textId);
        return errorPropName;
    end

    return text;
end

function SetEquipDisplayParam(luaBhv, go, equipResId)
    -- 此函数可以进一步优化, 真对下面的 transform:Find(""),
    if go == nil or equipResId == nil then
        return;
    end

    local equipRes = TableManager:Inst():GetTabData(EnumTableID.TabEquip, equipResId);
    if equipRes == nil then
        return;
    end

    local transform = go.transform;
    if transform == nil then
        return;
    end

    local btnGo = transform:Find("Btn").gameObject;
    if btnGo == nil then
        error("equip prefab is illegal. lost Btn node");
        return;
    end

    local bgImgGo   = transform:Find("Btn/ImgItemBg").gameObject;
    local iconImgGo = transform:Find("Btn/ImgItemIcon").gameObject;
    local numLabel  = transform:Find("Btn/LabelNum"):GetComponent("Text");
    local nameLabel = transform:Find("Btn/LabelName"):GetComponent("Text");

    if bgImgGo == nil or iconImgGo == nil or numLabel == nil or nameLabel == nil then
        error("equip prefab is illegal. lost widget");
        return;
    end

    SetEquipObjQualityIcon(luaBhv, bgImgGo, equipRes.Quality);
    SetIconByID(luaBhv, iconImgGo, equipRes.IconId);
end

--消费确认
function ShowCostEnsure(str, funEnsure, funCancel, moneyType, moneyCnt)
    ShowUI(UINames.UICostEnsure, str, funEnsure, funCancel, moneyType, moneyCnt);
end

--调用二次确认
function ShowEnsureAgain(str, funEnsure, funCancel, subStr, ensureType, strYes, strNo)
    ShowUI(UINames.UIEnsureAgain, str, funEnsure, funCancel, subStr, ensureType, strYes, strNo);
end

--调用通用逻辑提示框
function ShowCommonEnsure(strMain, ensureCall, strYes, strSub, bWithCloseButton, closeCall)
    ShowUI(UINames.UICommonEnsure, strMain, ensureCall, strYes, strSub, bWithCloseButton, closeCall);
end

--提示
function ShowEnsureTips(str)
    ShowUI(UINames.UIEnsureTips, str);
end

------------------------------------------------------------------------------------------
function UIFunctions.PlayOnceEffect(luaBhv, effName, bindObj, xOffset, yOffset, zOffset, funEndCall)
    xOffset = xOffset or 0;
    yOffset = yOffset or 0;
    zOffset = zOffset or 0;

    luaBhv:PlayOnceEffect(effName, bindObj, xOffset, yOffset, zOffset, funEndCall);
end

----之后可能有扩展之类的
function UIFunctions.PlayEffect(luaBhv, effName, bindObj)
    luaBhv:PlayEffect(effName, bindObj);
end

function UIFunctions.PlayAnimation(objAnmCtrl, strGroupName, bForward, funEndCallBack)
    if bForward == nil then
        bForward = true
    end

    UIInterface.PlayAnimation(objAnmCtrl, strGroupName, bForward, funEndCallBack);
end

function UIFunctions.ResetAnimation(objAnmCtrl, strGroupName)
    UIInterface.ResetAnimation(objAnmCtrl, strGroupName);
end

----------------------------------------------------------------------------------------------
-- 纯脚本设置Text滚动到，支持5种类型
--startNum,endNum 开始和结束数字
--updateGap： float,变化多大了才更新一次(主要是效率，不用第次Update都设置
--fmt :对应的字符串格式比如写数字用{d},可以写 XXXX-{d}-AAAA, 输出则会直接是XXXX-1234-AAAA（如果为空，则会显示默认的{d})
--usedTimeSec: 这段滚动共用多长时间
--increasePerSec: 每秒增量或者减量(负值)
--digitCount: 如果有小数点，精确到几位小数点
--funEndCall: 当滚动结束时的回调，回调参数为结束时候的值
----------------------------------------------------------------------------------------------
UIFunctions.TextSpringType =
{
    Thousands = 0,     --"千分位: {d}"
    MemCapacity = 1,   --"内存容量类型:{d}"
    TimeCountDown = 2, --"倒计时: {d}d {h}:{m}:{s}"
    TimeShow = 3,      --"时间显示:{d}"
    Normal = 4,        --"正常数字:{d}"
}

function UIFunctions.TextSpringTo(obj, springStyle, startNum, endNum, updateGap, fmt, usedTimeSec, digitCount, funEndCall)
    UITextSpringNumberScript.NumberStartGoto(obj, springStyle, startNum, endNum, updateGap, fmt, usedTimeSec, digitCount,
        funEndCall);
end

--increasePerSec表示每秒的变化量
function UIFunctions.TextSpringStart(obj, springStyle, startNum, updateGap, fmt, increasePerSec, digitCount)
    UITextSpringNumberScript.NumberStart(obj, springStyle, startNum, updateGap, fmt, increasePerSec, digitCount);
end

--显示加速
function UIFunctions.ShowSpeedUpPanel(eItemUseLogicType, startTime, leaveTime, endTime, freeTime, ...)
    freeTime = freeTime or 0;
    ShowUI(UINames.UISpeedUp, eItemUseLogicType, startTime, leaveTime, endTime, freeTime, ...);
end

function UIFunctions.OnRequestError(message, errorMessage, isLuaCall)
    isLuaCall = isLuaCall or false;
    local tempIndex = isLuaCall == true and message or StrEnum[message];
    if tempIndex == nil then
        ShowUI(UINames.UITips, "None String Dictionary!: " .. message);
        print("[Error] None String Dictionary!: " .. message);
        return
    end

    local tempStr = GetStrDic(tempIndex);
    if errorMessage ~= nil then
        tempStr = string.format(tempStr, errorMessage);
    end
    ShowUI(UINames.UITips, tempStr);
end

function SafeCall(_obj, _fun, ...)
    if _obj == nil then
        error("[SafeCall] _obj is nil!");
    elseif _fun == nil then
        error("[SafeCall] _fun is nil!");
    else
        _fun(_obj, ...);
    end
end

--每个UI在InitPanel中首先调用这个函数，保证界面能关闭
function InitCloseUIButton(_uiptr, _path, _clickFunc)
    if _uiptr == nil then
        error("[InitCloseUIButton] param1 is nil!")
        return;
    end

    if _path == nil then
        error("[InitCloseUIButton] param2 is nil!")
        return;
    end

    if _clickFunc == nil then
        error("[InitCloseUIButton] param3 is nil!")
        return;
    end


    if _uiptr.uidata == nil then
        error("[InitCloseUIButton] this.uidata is nil!");
        return;
    end
    if _uiptr.transform == nil then
        error("[InitCloseUIButton] this.transform is nil!")
        return;
    end
    if _uiptr.behaviour == nil then
        error("[InitCloseUIButton] this.behaviour is nil!")
        return;
    end

    local node = _uiptr.transform:Find(_path)
    if node == nil then
        error("[InitCloseUIButton] not find node:" .. _path);
        return;
    end

    local btn = node.gameObject;
    _uiptr.behaviour:AddClickEvent(btn, _clickFunc);
    return btn;
end

function ForceRebuildLayoutImmediate(obj)
    if obj == nil then
        return
    end

    Util.ForceRebuildLayoutImmediate(obj)
end

function SetMenuOffset(trans, offsetY)
    offsetY = offsetY or 0
    local pos = trans.anchoredPosition
    trans.anchoredPosition = Vector3(pos.x, pos.y - LuaFramework.AppConst.cutout + offsetY, 0)
end
