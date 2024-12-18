-------------------------------------------------------------
--- 打点说明
--- 第一章节的打点全部在打点表配置 Resources/LogEvent.txt 点ID为表的ID
--- 第二章节之后的使用任务打点，对应任务表的ID，打点填在任务表的LogPoint列，点ID为任务ID
--- 其它一些没有在表里的写到下面的固定配置点， 点ID为脚本配置，从5000开始
--- 要求所有的打点不冲突   LogEvent表，任务ID，StaticLogPoint
-------------------------------------------------------------

--得到英雄的打点 英雄id->打点ID
--todo 当前只添加了开宝箱得到的英雄的处理，其它获得英雄的地方没有添加 
local NewGeneralLogPoint ={
    [1205] = 5000, --得到雅典娜
}

local StaticLogPoint ={
     Chapter2_SetBox = 6000, --第二章的时候放箱子操作
}

local ServerTaskTargetType =
{
    TaskTarget_Logic = 0,
    TaskTarget_Own_Building		= 1,				--- 佣有建筑物数量，   param1 = 建筑物类型(-1为任意类型) 参数3=建筑物等级 param4=目标数量
    TaskTarget_Own_HeroStar		= 2,				--- 英雄星等，		  param1 = 英雄id(-1为任意英雄）param2=目标星等 param4=目标数量
    TaskTarget_Own_Hero_Count	= 3,				--- 佣有英雄数量，   param1 = 英雄等级， param4 = 目标数量
    TaskTarget_Own_Hero_Suit	= 4,				--- 英雄套装，	   param1 = 英雄id(-1为任意英雄）param2=套装id(-1为任意套装) param4 = 目标件数
    TaskTarget_History_Kill_Monster = 5,			--- 历史击杀怪物 param1 = 野怪id(-1为任意士兵）param4=目标数量
    TaskTarget_History_Recruit_Soldier = 6,			--- 历史招募士兵 param1 = 士兵id(-1为任意士兵) param4 = 目标数量
    TaskTarget_Technology_Levelup = 7,				--- 科技升级 param1=科技id param4 = 目标等级
    TaskTarget_History_Harvest_Resource_Count = 8,	--- 历史累计收获资源数量	param1=资源id(-1为任意资源) param4=目标数量
    TaskTarget_History_Harvest_Resource_Time  = 9,	--- 历史累计收获资源次数 param1=资源id(-1为任意资源) param4=目标次数
    TaskTarget_History_Plunder_Count = 10,			--- 历史掠夺资源数理 param1=资源id(-1为任意资源), param4=目标资源数量
    TaskTarget_History_Plunder_Time  = 11,			--- 历史掠夺资源次数 param1=资源id（-1为任意资源）, param4=目标掠夺次数
    TaskTarget_Resource_Speed = 12,					--- 资源生产速度	param1=资源id， param4=生产速度（xxxx/h）
    TaskTarget_History_Collect_Resource = 13,		--- 历史采集资源（超级矿） param1=资源id, param4=目标数量
    TaskTarget_History_Recruit_Soldier_Type = 14,	--- 历史招募兵种类型 param1=兵种类型id（战，骑，弓，法）， param4=目标数量
    TaskTarget_History_Clear_MainDungeon = 15,		--- 历史通关主线副本 param1=章， param2=节， param4=通关次数
    TaskTarget_History_Clear_MarchDungeon = 16,		--- 历史通关大地图副本 param1 = 副本id, param4=通关次数
    TaskTarget_Own_Building_Level = 17,				--- 拥有建筑物等级， param1 = 建筑物类型（-1为任意类型） param4 = 目标等级
    TaskTarget_Join_Alliance = 18,					--- 加入联盟 param4=进度
    TaskTarget_Used_Talent_Point = 19,				--- 天赋点使用 param4 = 目标数量
    TaskTarget_ChangeSoldier = 20,					--- 更换兵种 param1=英雄Id param2=士兵Id
    TaskTarget_SellEquip		= 50,				--- 出售装备		param1= 装备id(-1为任意装备）param2=装备等级(-1为任意等级）param3 = 品质(-1为任意品质） param4=目标出售数量
    TaskTarget_BuyInDragonShop  = 51,				--- 龙币商店购买装备 param1 = 装备id(-1为任意）param2=装备等级(-1为任意等级）param3 = 品质(-1为任意品质） param4=目标购买数量
    TaskTarget_Kill_Monster		= 52,				--- 击杀怪物	param1=怪物id(-1为任意）param2=怪物等级 param3=对param3操作(0大于等于， 1等于， 2大于） param4 = 目标击杀数量
    TaskTarget_Attack_Castle    = 53,				--- 攻击城堡 param1=城堡等级，param4=目标攻击数量
    TaskTarget_Attack_Castle_Succeed = 54,			--- 攻击城堡  param1=城堡等级 param4 = 目标获胜次数
    TaskTarget_Recruit_Soldier = 55,				--- 招募士兵 param1=士兵id(-1为任意) param4=目标招募数量
    TaskTarget_Harvest_Resource_Count = 56,			--- 收获资源 param1=资源id(-1为任意资源） param4=目标数量
    TaskTarget_Harvest_Resource_Time  = 57,			--- 收获次数 param1=资源id(-1为任意资源） param4=目标次数
    TaskTarget_UseItem = 58,						--- 使用道具, param1=道具id(-1为任意) param4=目标使用次数
    TaskTarget_Plunder_Count =  59,					--- 掠夺资源数理 param1=资源id(-1为任意资源), param4=目标资源数量
    TaskTarget_Plunder_Time  =  60,					--- 掠夺资源次数 param1=资源id(-1为任意资源), param4=目标掠夺次数
    TaskTarget_Treat_Soldier = 61,					--- 治疗士兵 param1=士兵id(-1为任意士兵), param4=目标治疗数量
    TaskTarget_Research_Technology_Level = 62,		--- 研究科技等级 param1=科技id, param5=等级
    TaskTarget_Own_Resource_Mine = 63,				--- 拥有资源矿 param1=资源矿类型id, param4=目标资源矿数量
    TaskTarget_Collect_Resource = 64,				--- 采集资源（超级矿） param1=资源id, param4=目标数量
    TaskTarget_Recruit_Soldier_Type = 65,			--- 招募兵种类型 param1=兵种类型id（战，骑，弓，法） param4=目标数量
    TaskTarget_Help_Ally_Count = 66,				--- 帮助盟友次数 param4=目标次数
    TaskTarget_Clear_MainDungeon = 67,				--- 通关主线副本 param1=章, param2=节, param4=通关次数
    TaskTarget_Clear_TeamDungeon = 68,				--- 通关组队副本 param1=副本id, param4=通关次数
    TaskTarget_Build_Levelup = 69,					--- 建筑升级 param1=建筑类型(-1为任意建筑), param4=升级次数
    TaskTarget_Research_Technology_Time = 70,		--- 研究科技次数 param=科技id, param4=升级次数
    TaskTarget_AllianceTask = 72,					--- 完成联盟任务
    TaskTarget_AllianceTalk = 73,					--- 联盟频道发言
    TaskTarget_Buy_MonthCard = 74,					--- 购买月卡
    TaskTarget_Buy_WeekCard = 75,					--- 购买周卡
    TaskTarget_MoveCity = 76,						--- 玩家迁城任务
    TaskTarget_UseItem_SpeedUp = 77,				--- 使用加速类型道具 param1=道具加速类型（-1为任意加速类型） param4=目标数量
    TaskTarget_Max = 100,
}

--------------------------------------------
--- 打点脚本
--- 说明： 有些内容需要加章节判断，能固定确定的不需要判断，按基本逻辑即可，完全看需要什么固定条件
--- 打点点位之间留10个空位防止之后策划增加新的东西
--------------------------------------------
StatisticsLogEvent = StatisticsLogEvent or {};
local this = StatisticsLogEvent;

----
this.cache_wait_staId = nil; --当前等领奖回来的

--------------------------------------
--主界面点击跳转
function StatisticsLogEvent.Event_UIMainGuideClickGoto(fieldMission)   
   -- error("Event_UIMainGuideClickGoto, fieldMission.TargetType1="..fieldMission.TargetType1);
    
    if fieldMission.TargetType1 == ServerTaskTargetType.TaskTarget_Own_Building_Level then --
        
        --param1 = 建筑物类型（-1为任意类型） param4 = 目标等级
        local buildingType = fieldMission.TargetType1_Param1;
        local targetLevel = fieldMission.TargetType1_Param4;

        if buildingType == eBuildingType.MainTower then
            if targetLevel == 2 then
                this.doStatistics(1000010);
            end
        elseif buildingType == eBuildingType.WoodLand then
            if targetLevel == 1 then --建造伐木场
                this.doStatistics(1000100);
            end
        elseif buildingType == eBuildingType.FoodLand then
            if targetLevel == 1 then --建造农庄
                this.doStatistics(1000160);
            end
        elseif buildingType == eBuildingType.BuCamp then
            if targetLevel == 1 then --主界面建造士兵营
                this.doStatistics(1000200);
            end
        end
    elseif fieldMission.TargetType1 == ServerTaskTargetType.TaskTarget_Recruit_Soldier_Type then --
        local soldierType =  fieldMission.TargetType1_Param1;
        --local soldierCount = fieldMission.TargetType1_Param4;

        if soldierType == eSoldier_Infantryinfo then   --人类剑士等
            this.doStatistics(1000260); --点击 主界面-招募任意数量人类剑士
        end
    elseif fieldMission.TargetType1 == ServerTaskTargetType.TaskTarget_Own_Hero_Count then --
        local targetLv =  fieldMission.TargetType1_Param1;
        local haveMinCount = fieldMission.TargetType1_Param4;
        if targetLv == 2 and  haveMinCount == 1 then --和任务对应上 --任意英雄升级到2级
            this.doStatistics(1000340);            
        end
        -- 击杀怪物	param1=怪物id(-1为任意）param2=怪物等级 param3=对param3操作(0大于等于， 1等于， 2大于） param4 = 目标击杀数量
    elseif fieldMission.TargetType1 == ServerTaskTargetType.TaskTarget_Kill_Monster then --
        local monsterType =  fieldMission.TargetType1_Param1;
        if nil ~= monsterType and monsterType == 1001 then --灾厄之龙
            this.doStatistics(1000440);
        end       
    end
end

--主界面点击领取奖励
function StatisticsLogEvent.Event_UIMainGuideClickGetAward(fieldMission)
    local staId;

    --error("fieldMission.TargetType1="..fieldMission.TargetType1 .. " param1="..tostring(fieldMission.TargetType1_Param1) ..
    --" param4="..tostring(fieldMission.TargetType1_Param4))

    if fieldMission.TargetType1 == ServerTaskTargetType.TaskTarget_Own_Building_Level then --
        --param1 = 建筑物类型（-1为任意类型） param4 = 目标等级
        local buildingType = fieldMission.TargetType1_Param1;
        local targetLevel = fieldMission.TargetType1_Param4;

        if buildingType == eBuildingType.MainTower then
            if targetLevel == 2 then
                staId = 1000060;
            end
        elseif buildingType == eBuildingType.WoodLand then
            if targetLevel == 1 then --伐木场领取奖励
                staId = 1000120;
            end
        elseif buildingType == eBuildingType.FoodLand then
            if targetLevel == 1 then --农庄建造领取奖励
                staId = 1000170;
            end
        elseif buildingType == eBuildingType.BuCamp then
            if targetLevel == 1 then --士兵营建造领取奖励
                staId = 1000230;
            end
        end
    elseif fieldMission.TargetType1 == ServerTaskTargetType.TaskTarget_Recruit_Soldier_Type then --
        local soldierType =  fieldMission.TargetType1_Param1;
        --local soldierCount = fieldMission.TargetType1_Param4;
        if soldierType == eSoldier_Infantryinfo then   --人类剑士等
            staId = 1000310;--点击 主界面-招募任意数量人类剑士（前往领取奖励）
        end
    elseif fieldMission.TargetType1 == ServerTaskTargetType.TaskTarget_Own_Hero_Count then --
        local targetLv =  fieldMission.TargetType1_Param1;
        local haveMinCount = fieldMission.TargetType1_Param4;

        if targetLv == nil or haveMinCount == nil then
            return;
        end
        
        if targetLv == 2 and  haveMinCount == 1 then
            staId = 1000410;--点击 主界面-升级亚瑟王到2级-领取
        end
    elseif fieldMission.TargetType1 == ServerTaskTargetType.TaskTarget_Kill_Monster then --
        local monsterType =  fieldMission.TargetType1_Param1;
        if nil ~= monsterType and monsterType == 1001 then --灾厄之龙
            staId =  1000510;
        end
    end

    if nil ~= staId then
        --因为是奖励的，记录下来，用于GetItem回来的时候判断，不然没办法判断回来的是什么东西
        this.cache_wait_staId = staId;

        this.doStatistics(staId);
    end
end

--任务界面Mission点击跳转
function StatisticsLogEvent.Event_UIMissionGuideClickGoto(fieldMission)
    if fieldMission.TargetType1 == ServerTaskTargetType.TaskTarget_Own_Building_Level then --
        --param1 = 建筑物类型（-1为任意类型） param4 = 目标等级
        local buildingType = fieldMission.TargetType1_Param1;
        local targetLevel = fieldMission.TargetType1_Param4;

        if buildingType == eBuildingType.MainTower then
            if targetLevel == 2 then
                this.doStatistics(1000020);
            end
        elseif buildingType == eBuildingType.WoodLand then
            if targetLevel == 1 then --建造伐木场
                this.doStatistics(1000090);
            end
        elseif buildingType == eBuildingType.FoodLand then
            if targetLevel == 1 then --建造农庄
                this.doStatistics(1000150);
            end
        elseif buildingType == eBuildingType.BuCamp then
            if targetLevel == 1 then --建造士兵营
                this.doStatistics(1000210);
            end
        end
    elseif fieldMission.TargetType1 == ServerTaskTargetType.TaskTarget_Recruit_Soldier_Type then --
        local soldierType =  fieldMission.TargetType1_Param1;
        --local soldierCount = fieldMission.TargetType1_Param4;

        if soldierType == eSoldier_Infantryinfo then   --人类剑士等
            this.doStatistics(1000270); --点击 任务界面-招募任意数量人类剑士-前往
        end
    elseif fieldMission.TargetType1 == ServerTaskTargetType.TaskTarget_Own_Hero_Count then --
        local targetLv =  fieldMission.TargetType1_Param1;
        local haveMinCount = fieldMission.TargetType1_Param4;
        if targetLv == 2 and  haveMinCount == 1 then --和任务对应上 --任意英雄升级到2级
            this.doStatistics(1000350);
        end
    elseif fieldMission.TargetType1 == ServerTaskTargetType.TaskTarget_Kill_Monster then --
        local monsterType =  fieldMission.TargetType1_Param1;
        if nil ~= monsterType and monsterType == 1001 then --灾厄之龙
            this.doStatistics(1000450);
        end
    end
end


--任务界面Mission点击领取奖励
function StatisticsLogEvent.Event_UIMissionGuideClickGetAward(fieldMission)
 
    local staId;
    if fieldMission.TargetType1 == ServerTaskTargetType.TaskTarget_Own_Building_Level then --
        --param1 = 建筑物类型（-1为任意类型） param4 = 目标等级
        local buildingType = fieldMission.TargetType1_Param1;
        local targetLevel = fieldMission.TargetType1_Param4;

        if buildingType == eBuildingType.MainTower then
            if targetLevel == 2 then
                staId = 1000070;               
            end
        elseif buildingType == eBuildingType.WoodLand then
            if targetLevel == 1 then --伐木场领取奖励
                staId = 1000130;
            end
        elseif buildingType == eBuildingType.FoodLand then
            if targetLevel == 1 then --农庄建造领取奖励
                staId = 1000180;
            end
        elseif buildingType == eBuildingType.BuCamp then
            if targetLevel == 1 then --士兵营建造领取奖励
                staId = 1000240;
            end
        end
    elseif fieldMission.TargetType1 == ServerTaskTargetType.TaskTarget_Recruit_Soldier_Type then --
        local soldierType =  fieldMission.TargetType1_Param1;
        --local soldierCount = fieldMission.TargetType1_Param4;

        if soldierType == eSoldier_Infantryinfo then   --人类剑士等
            staId = 1000320;--点击 任务界面-招募任意数量人类剑士-领取
        end
    elseif fieldMission.TargetType1 == ServerTaskTargetType.TaskTarget_Own_Hero_Count then --
        local targetLv =  fieldMission.TargetType1_Param1;
        local haveMinCount = fieldMission.TargetType1_Param4;
        if targetLv == 2 and  haveMinCount == 1 then
            staId = 1000420;--点击 任务界面-升级亚瑟王到2级-领取
        end
    elseif fieldMission.TargetType1 == ServerTaskTargetType.TaskTarget_Kill_Monster then --
        local monsterType =  fieldMission.TargetType1_Param1;
        if nil ~= monsterType and monsterType == 1001 then --灾厄之龙
            staId = 1000520;            
        end
    end

    if nil ~= staId then
        --因为是奖励的，记录下来，用于GetItem回来的时候判断，不然没办法判断回来的是什么东西
        this.cache_wait_staId = staId;
        
        this.doStatistics(staId);            
    end    
end

--建筑菜单之升级点击
function StatisticsLogEvent.Event_MenuBuildingLevelUpClick(buildingType, targetLevel)
    if buildingType == eBuildingType.MainTower then
        if targetLevel == 2 then
            this.doStatistics(1000030);
        end
    end
end

--建筑菜单之升级点击招募
function StatisticsLogEvent.Event_MenuBuildingRecruitSoldier(buildingInfo)
    if nil == buildingInfo then
        return;
    end
    
    local buildingType = GetBuildingTrueType(buildingInfo.buildingTabId);    
    if buildingType == eBuildingType.BuCamp then
        this.doStatistics(1000280);
    end
end

--建造界面之升级开始
function StatisticsLogEvent.Event_UIBuildingLevelUpStart(buildingType, targetLevel)
    if buildingType == eBuildingType.MainTower then
        if targetLevel == 2 then
            this.doStatistics(1000040); --1点击 主界面-主城堡-升级-升级
        end
    end
end

--建造界面之升级-立即完成
function StatisticsLogEvent.Event_UIBuildingLevelUpFinish(buildingType, targetLevel)
    if buildingType == eBuildingType.MainTower then
        if targetLevel == 2 then
            this.doStatistics(1000050); --1点击 主界面-主城堡-升级-立即完成
        end
    end
end

--建造界面之建造开始
function StatisticsLogEvent.Event_UIBuildingCreateStart(buildingType)
    if buildingType == eBuildingType.BuCamp then
        this.doStatistics(1000220); --点击 主界面-修建战士兵营-建造
    end
end

--建造界面之建造马上完成
function StatisticsLogEvent.Event_UIBuildingCreateFinish(buildingType)
    if buildingType == eBuildingType.WoodLand then --点击 主界面-伐木场-立即完成
        this.doStatistics(1000110);
    end
end

--招募界面之开始招募（走时间）
function StatisticsLogEvent.Event_UIRecruitSoldierStart(soliderID, soldierCount)
    if nil == soliderID or nil == soldierCount then
        return;
    end
    
    local fieldSoldier = TableManager:Inst():GetTabData(EnumTableID.TabSoldierInfo, soliderID, true);
    if nil == fieldSoldier then
        return;
    end
    
    local campType = fieldSoldier.SoldierType;
    if campType == eSoldier_Infantryinfo then --点击 战士兵营-招募
        this.doStatistics(1000290);
    end
end

--招募界面之马上完成（花钱）
function StatisticsLogEvent.Event_UIRecruitSoldierFinish(soliderID, soldierCount)
    if nil == soliderID or nil == soldierCount then
        return;
    end

    local fieldSoldier = TableManager:Inst():GetTabData(EnumTableID.TabSoldierInfo, soliderID, true);
    if nil == fieldSoldier then
        return;
    end

    local campType = fieldSoldier.SoldierType;
    if campType == eSoldier_Infantryinfo then --点击 战士兵营-立即完成
        this.doStatistics(1000300);
    end
end

--点主界面英雄
function StatisticsLogEvent.Event_UIMainClickHeroBtn()
    local cp = this.getChapter();
    if cp == 1 then --第一章
        this.doStatistics(1000360);   --1点击 主界面-英雄     
    end
end

--UIHero英雄界面点击英雄
function StatisticsLogEvent.Event_UIHeroClickHero(genId)
    local cp = this.getChapter();
    if cp == 1 then --第一章
        --点了亚瑟王
        if genId == 1203 then --1203=亚瑟王
            this.doStatistics(1000370);   --1点击 英雄-亚瑟王
        end
    end
end

--UIHeroDetails英雄详情界面点击+
function StatisticsLogEvent.Event_UIHeroDetailsClickAddExp(genId)
    if nil == genId then
        return;
    end
    
    local cp = this.getChapter();
    if cp == 1 then --第一章
        --点了亚瑟王
        if genId == 1203 then --1203=亚瑟王
            this.doStatistics(1000380);
        end
    end
end

--UIHeroUseExp英雄吃药
function StatisticsLogEvent.Event_UIHeroUseExpClick(genId, itemId)
    if nil == genId then
        return;
    end
    
    local cp = this.getChapter();
    if cp == 1 then --第一章
        --点了亚瑟王
        if genId == 1203 then --1203=亚瑟王
            this.doStatistics(1000390); --点击 亚瑟王-EXP+100
        end
    end
end

--UIHeroDetailsX
function StatisticsLogEvent.Event_UIHeroDetailsClickCloseX(genId)
    if nil == genId then
        return;
    end
    
    local cp = this.getChapter();
    if cp == 1 then --第一章
        --点了亚瑟王
        if genId == 1203 then --1203=亚瑟王
            this.doStatistics(1000400); --点击 亚瑟王-EXP+100
            
        end
    end
end

-- 点击大地图怪物
function StatisticsLogEvent.Event_BigMapNpcClick(objId)
    if nil == objId then
        return;
    end

    local npcData = BigMapDataModel.GetNPCData( objId )
    if npcData == nil then
        return;
    end

    if nil ~= npcData.resId and npcData.resId == 1001 then --如果是灾厄之龙
        this.doStatistics(1000460);
    end
end

-- 点击打怪物界面攻击
function StatisticsLogEvent.Event_UIAttackMonsterAttack(objId)
    if nil == objId then
        return;
    end

    local npcData = BigMapDataModel.GetNPCData( objId )
    if npcData == nil then
        return;
    end

    if nil ~= npcData.resId and npcData.resId == 1001 then --如果是灾厄之龙
        this.doStatistics(1000470);
    end
end

-- 点击出征界面攻击
function StatisticsLogEvent.Event_UIDispatchArmyGo(objId)
    if nil == objId then
        return;
    end

    local npcData = BigMapDataModel.GetNPCData( objId )
    if npcData == nil then
        return;
    end

    if nil ~= npcData.resId and npcData.resId == 1001 then --如果是灾厄之龙
        this.doStatistics(1000480);
    end
end

-- 进入战斗提示点击前往观战
function StatisticsLogEvent.Event_UIBattleStartEnterSceneYes(marchId)
    --检查行军列表有没有这个任务
   
 
end

-- 进入战斗提示点击前往观战
function StatisticsLogEvent.Event_UIBattleStartEnterSceneNo(marchId)

end


--获得奖励界面（这玩意根本没有回来的数据没办法知道哪里来的，只能通过前一个操作类型记录下来是哪个的领奖了，不知道有没有别的好办法）
function StatisticsLogEvent.Event_GetItemEnsure()
    if nil == this.cache_wait_staId then
        return; --没有期待
    end

    --error("this.cache_wait_staId="..this.cache_wait_staId)
    
    if this.cache_wait_staId == 1000060 --点击 主-升级主城到2级-领取
    or this.cache_wait_staId == 1000070 then --点击 任务界面-升级主城到2级-领取
        this.doStatistics(1000080);
        
    elseif this.cache_wait_staId == 1000120 --点击 主界面-修建一座伐木场（前往领取奖励）
    or this.cache_wait_staId == 1000130 then --点击 任务界面-修建一座伐木场-领取
        this.doStatistics(1000140);
        
    elseif this.cache_wait_staId == 1000170 --点击 主界面-修建一座农庄（前往领取奖励）
    or this.cache_wait_staId == 1000180 then --点击 任务界面-修建一座农庄-领取
        this.doStatistics(1000190);
        
    elseif this.cache_wait_staId == 1000230 --点击 任务界面-修建战士兵营-领取
    or this.cache_wait_staId == 1000240 then --点击 确定（获得 修建战士兵营 奖励）
        this.doStatistics(1000250);

    elseif this.cache_wait_staId == 1000310 --点击 任务界面-招募任意数量人类剑士-领取
    or this.cache_wait_staId == 1000320 then -- 点击 确定（获得 招募任意数量人类剑士 奖励）
        this.doStatistics(1000330);

    elseif this.cache_wait_staId == 1000410 --点击 主界面-升级亚瑟王到2级（前往领取奖励）
    or this.cache_wait_staId == 1000420 then -- 点击 确定（获得 招募任意数量人类剑士 奖励）
        this.doStatistics(1000430);

    elseif this.cache_wait_staId == 1000510 --点击 大地图-最终目标：打败灾厄之龙（前往领取奖励）
    or this.cache_wait_staId == 1000520 then -- 点击 任务界面-最终目标：打败灾厄之龙-领取
        this.doStatistics(1000530);
        
    end

    this.cache_wait_staId = nil; --clear
end

--开户宝箱打点
function StatisticsLogEvent.Event_OpenGetPlayerBox(openBox)
   local chapter = StatisticsLogEvent.getChapter()
    if chapter == 2 then --第二章也就这一个宝箱
        StatisticsLogEvent.doManual(StaticLogPoint.Chapter2_SetBox)
    end   
end

--获得新英雄打点
function StatisticsLogEvent.Event_GetNewGeneral(generalId)
    --error("StatisticsLogEvent.Event_GetNewGeneral ".. generalId)
    if generalId == nil then
        return
    end

    local LogPoint = NewGeneralLogPoint[generalId]
    if LogPoint == nil then
        return
    end

    StatisticsLogEvent.doManual(LogPoint)   
end

---------------------------------------------------------------------------
--固定的任务完成后对应的ID（从第二章节开始）
function StatisticsLogEvent.Event_GrowthMissionComplete(missionId)
    local fieldMission = TableManager:Inst():GetTabData(EnumTableID.Task, missionId, true)
    if nil == fieldMission then
        return
    end

    if nil == fieldMission.LogPoint or fieldMission.LogPoint <= 0 then
        return
    end

    StatisticsLogEvent.doManual(fieldMission.LogPoint)
end

----------------------------------------------------------------------------------------
--当前章节
function StatisticsLogEvent.getChapter()
    return GrowthMissionModule:Inst():GetCurrentChapter();
end

function StatisticsLogEvent.doStatistics(value)
    --error(tostring("StatisticsLogEvent----> " .. tostring(value)));
    StatisticsInterface.UploadLog(value);
end

-- 手动加的表里没有的JPushEvent
function StatisticsLogEvent.doManual(value)
    local strValue = tostring(value)
    --error("doManual----> " .. strValue)

    StatisticsInterface.AddCustomEvent(strValue)
end
