----------------------------------------------------------
---全局事件处理
----------------------------------------------------------
GlobalBehaviour = GlobalBehaviour or {}
local this = GlobalBehaviour;

---全局逻辑处理
function GlobalBehaviour.Init()    
    --添加缓存的事件在点击完领取之后才出现效果效果
    Event.AddCacheEvent(EventDefine.OnMoneyChanged);
    Event.AddCacheEvent(EventDefine.OnItemChanged); 
    Event.AddCacheEvent(EventDefine.OnItemChangedDetail);
    Event.AddCacheEvent(EventDefine.OnPlayerExpChange);
    Event.AddCacheEvent(EventDefine.OnUIPowerAdd);
    Event.AddCacheEvent(EventDefine.OnPlayerLevelChange);
    Event.AddCacheEvent(EventDefine.OnPlayerFightValueChange);
    Event.AddCacheEvent(EventDefine.OnCastleLevelChange);
    
end

---任务跨天数据(也刷别的数据)
function GlobalBehaviour.CheckReFreshTime(curTime)   
    --Game里每5秒请求一次，可能有优化吧
    -- local nextRefreshTime = PlayerData:Inst():GetNextRefreshTime();
    -- if curTime > nextRefreshTime then
    --     GameService.GetRefreshTime();
    -- end
end

---被动断开连接
function GlobalBehaviour.OnDisConnect0(_isManual)
   --连接失败了...啥都不用做
end

function GlobalBehaviour.OnConnectFail0()
    --取消当前的引导，让人家能点那个退出按钮，退出后进来也就继续了
    GuideBhvGroup.CancelBhv("<<<< 由于断线重连取消了引导...");
end

function GlobalBehaviour.GetGlobalResContextName()
   return "ResGroupContext";
end

function GlobalBehaviour.GetGlobalUIResGroup()
    if nil == this.resContext then
        this.resContext = ResGroupInterface.CreateContext(this.GetGlobalResContextName());
    end
    if this.resGroupUI == nil then
        this.resGroupUI = ResGroupInterface.CreateResGroup(this.GetGlobalResContextName());
    end
    return this.resGroupUI;
end

function GlobalBehaviour.OnGamePlayerLogout()
    --清理本次事件，防止下次登录卡住
    Event.Reset();
end

function GlobalBehaviour.OnGamePlayerLogin()
    --不能在这里开始引导，因为家园里可能有一些东西没有初始化
end

----------------------------------------------------------
--- 无论什么UI只要OnShow完毕，就会进这里，作为引导等触发条件
function GlobalBehaviour.OnUIShow(uiName)
    --第一次登录
    --只有在显示主UI之后，才显示章节开启
    if this.firstEnterFlag ~= nil and uiName == UINames.UIMain then
        ShowUI(UINames.UIChapterPlot, 1);
        this.firstEnterFlag = nil;
        return;
    else
    end

    Event.Brocast(EventDefine.OnUIShow, uiName)
end

---当UI关闭后，都会走这里
function GlobalBehaviour.OnUIHide(uiName)    
   -- GuideFlow.OnUIHide(uiName);
    
    
    --清理tips界面
    --HideUI(UINames.UIToolTips);
    --HideUI(UINames.UISkillTips);
    
    --检查升级开启(必须在这界面关闭之后)
    if uiName == UINames.UILevelUp then
        --才先放动画之类的
        Event.Brocast( EventDefine.OnCastleLevelChangeEnsure);

        --再开引导
        GuideEventTrigger.OnLevelUp();
    elseif uiName == UINames.UIGetItem then
        --处理释放的消息
        Event.ReleaseCacheEvent();
        
        --可能是过场动画之类的东西吧
        if nil ~= this.chapterOpenId and this.chapterOpenId > 1 then
            ShowUI(UINames.UIChapterPlot, this.chapterOpenId);
            this.chapterOpenId = nil; --重置
        end      
    elseif uiName == UINames.UIChapterPlot then -- 在关闭这个动画界面后，再开启
        --弹出建筑提示开始
        this.OnChapterOpenAnimationOver();
    elseif uiName == UINames.UIFightResult then -- 战斗结束了，可能在副本场景里有引导过去的，结束引导
        -- if GuideBhvGroup.runningBhv ~= nil then
        --     GuideBhvGroup.CancelBhv();
        -- end
    end
end

---玩家首次进入所有动画处理完开始游戏
function GlobalBehaviour.OnPlayerFirstEnterStartGame()
    --目前使用第一个
    log(">>> CG end, start chapter open.");
    --GuideEventTrigger.OnCaptureOpen(1);   
end


---开启了新章节
function GlobalBehaviour.OnGrowthMissionCaptureOpen(growthId)    
    --需要等着领取奖励的UI关闭之后，再开始新的场景动画之类的
    this.chapterOpenId = growthId;
    log(">>> open new chapter, Id=" .. growthId);
end

---章节子任务被完成
function GlobalBehaviour.OnGrowthMissionSubComplete(missionInfo)
    --GuideEventTrigger.OnGrowthSubMissionComplete(missionInfo);
end

---所有的按钮点击(tab页按钮走下面)
function GlobalBehaviour.OnBtnClick(uiName, btnName, audioId)
   -- GuideFlow.DebugLog("点击了按钮:" ..uiName .. " >" .. btnName);

     --GuideFlow.OnUIClick(uiName, btnName, false);
    
    audioId = audioId or 0;
    if audioId <= 0 then
        Audio.OnCommonButtonClicked(); --普通的按钮点击
    else
        Audio.PlayAudio(audioId);
    end    
end

---由于Tab页实现方法不一样，所有Tab页点击，传来的UIName是Group的Name并不是UIName
function GlobalBehaviour.OnTabClick(tabGroupObjName, btnName, audioId)
    --GuideFlow.DebugLog("点击了Tab页:" ..tabGroupObjName .. " btnName="..btnName);
    
    --GuideFlow.OnUIClick(tabGroupObjName, btnName, true);

    audioId = audioId or 0;
    if audioId <= 0 then
        Audio.OnCommonButtonClicked(); --普通的按钮点击
    else
        Audio.PlayAudio(audioId);
    end
end


function GlobalBehaviour.OnClickBigMap(param)
    --GuideFlow.BigMapClick(param)    
end

function GlobalBehaviour.OnClickHome(param)
    --GuideFlow.OnClickHome(param)
end

function GlobalBehaviour.OnClickDungeonMap(param)
    --GuideFlow.OnClickDungeonMap(param)
end


---大地图搜索定位回调
function GlobalBehaviour.OnBigMapLocationCall(_objId, _gameObj)
   --GuideFlow.OnBigMapLocationCall(_objId, _gameObj);    
end

---大地图开始拖拽
function GlobalBehaviour.OnBigMapStartDrag()
    --GuideFlow.OnBigMapStartDrag();
end

---家园开始拖拽
function GlobalBehaviour.OnHomeStartDrag()
    --GuideFlow.OnHomeStartDrag();
end

---副本开始拖拽
function GlobalBehaviour.OnDungeonStartDrag()
    --GuideFlow.OnDungeonStartDrag();
end


function GlobalBehaviour.DoRayCast()
 
end

--主界面动画完毕
function GlobalBehaviour.OnMainUIAnimationRecover()
    --检查引导
    --GuideFlow.CheckStartGuide();
end

--------------------------------------------------- 家园全局事件
-- 家园建筑生成了一个头上图标
function GlobalBehaviour.OnHomeBuildingHeadMake(buildingIndex, headObj)
    
end

-- 章节开启动画完成后的处理
function GlobalBehaviour.OnChapterOpenAnimationOver()
    --如果有开启的建筑，则先弹出开启的建筑提示
    --必须是开启等级相等，如果是跳过了等级，则不处理
    --检查地块开启？NO，目前地块开启只是限制建造，直接功能开启就可以，固定位置的建筑
    --要求地块开启的章节必须和建筑功能开启的章节匹配   
    --只取第一个1级的值
    local curChapter = GrowthMissionModule:Inst():GetCurrentChapter();
    local openBuildingList = {};
    for i = eBuildingType.MainTower, eBuildingType.MaxType - 1 do
        local buildingTabLv1 = MakeBuildingTabID(i, 1);
        -- local fieldHomeBuilding = TableManager:Inst():GetTabData(EnumTableID.TabHomeBuilding, buildingTabLv1, true);
        -- if nil ~= fieldHomeBuilding then    
        --     if fieldHomeBuilding.OpenChapter ~= nil and fieldHomeBuilding.OpenChapter == curChapter then
        --         table.insert(openBuildingList, buildingTabLv1);
        --     end
        -- end
    end
    
    --点击完所有开启后的回调
    --如果多个弹出框，是（最后一个）才回调    
    local funEnsureOpen = function()
        this.OnHomeBuildingOpenTipsOver();
    end

    local unlockCount = 0;
    if #openBuildingList > 0 then
        for  _, b in ipairs(openBuildingList) do
            unlockCount = unlockCount + 1;
            UIHomeBuildingUnLockPanel.TryAddShow(UIHomeBuildingUnLockPanelType.UnLockHomeBuildingType, b, funEnsureOpen);            
        end
    end

    --检查功能开启
    --联盟，副本，好友  
    local fieldFunOpen = TableManager:Inst():GetTabData(EnumTableID.TabFunOpen, eFunOpenType.FunOpen_Alliance, true);
    if nil ~= fieldFunOpen and fieldFunOpen.OpenLevel == curChapter and fieldFunOpen.IsDlg ~= nil and fieldFunOpen.IsDlg > 0 then
        unlockCount = unlockCount + 1;
        UIHomeBuildingUnLockPanel.TryAddShow(UIHomeBuildingUnLockPanelType.UnLockNewButtonAlliance, curChapter, funEnsureOpen);
    end

    fieldFunOpen = TableManager:Inst():GetTabData(EnumTableID.TabFunOpen, eFunOpenType.FunOpen_FuBen, true);
    if nil ~= fieldFunOpen and fieldFunOpen.OpenLevel == curChapter and fieldFunOpen.IsDlg ~= nil and fieldFunOpen.IsDlg > 0 then
        unlockCount = unlockCount + 1;
        UIHomeBuildingUnLockPanel.TryAddShow(UIHomeBuildingUnLockPanelType.UnLockNewButtonFuben, curChapter, funEnsureOpen);
    end

    fieldFunOpen = TableManager:Inst():GetTabData(EnumTableID.TabFunOpen, eFunOpenType.FunOpen_Friend, true);
    if nil ~= fieldFunOpen and fieldFunOpen.OpenLevel == curChapter and fieldFunOpen.IsDlg ~= nil and fieldFunOpen.IsDlg > 0 then
        unlockCount = unlockCount + 1;
        UIHomeBuildingUnLockPanel.TryAddShow(UIHomeBuildingUnLockPanelType.UnLockNewButtonFriend, curChapter, funEnsureOpen);
    end

    --这个不能马上调，得没有上面的任何一个的时候才调用
    if unlockCount == 0 then
        funEnsureOpen();    
    end    
end

-- 建筑开启弹出框之后的回调，放界面动画
function GlobalBehaviour.OnHomeBuildingOpenTipsOver()
    Event.Brocast( EventDefine.OnChapterOpenAnimationOver); --广播章节动画插入完毕
    
    --开始引导
    local growthId = GrowthMissionModule:Inst():GetCurrentChapter();
    --GuideEventTrigger.OnCaptureOpen(growthId);
end

function GlobalBehaviour.OnPurchaseResult( result )
    if result == 0 then
        ShowUI(UINames.UITips, GetStrDic(StrEnum.PayOkWait));
        
        Event.Brocast(EventDefine.OnClientPurchaseResult)
        Event.Brocast(EventDefine.OnPrivilegeCardRechargeState);
    else
        Event.Brocast(EventDefine.OnClientPurchaseFail)
    end
end

function GlobalBehaviour.OnSendMessageFail( msgid, protobufMsg, connServerType )
    --GuideFlow.OnSendMessageFail( msgid, protobufMsg, connServerType)   
end


function GlobalBehaviour.OnReConnect(  )
    --清理恭喜获得框这样的一些内容，防止出现一些问题
    Event.Reset();
    
    --GuideFlow.OnReConnect( )
end

function GlobalBehaviour.OnExitGame(  )
    -- function ShowEnsureAgain(str, funEnsure, funCancel, subStr, ensureType, strYes, strNo)

    local strYes = GetStrDic(StrEnum.ExitGame);
    local strNo = GetStrDic(StrEnum.ReturnGame);
    ShowEnsureAgain( GetStrDic(StrEnum.ConfirmQuitGame), funEnsure, funCancel, "", eEnsureAgainType.Normal, strYes, strNo ); 
end
