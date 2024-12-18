---本地数据管理

--记录当前登录key-value
LocalDataKeyLogin =
{
    UseGoldAskAgain = 1, --英雄升星前的几个英雄数据
    RefreshStoreAskAgain = 2, --存在超值商品未购买时, 刷新确认
    RefreshEquipStoreAskAgain = 3, --存在超值商品未购买时, 刷新确认
    RefreshBoxStoreAskAgain = 4, --巨龙宝库存在钻石宝箱时,刷新确认
    PhyRecoverConstConfig = 5, --体力恢复的表配置（一般不怎么更新）
}

--记录当前内存数据的key-value
LocalDataKeyMem = 
{
    MemHeroStarUpPreInfo = 1, --英雄升星前的几个英雄数据    
}

--记录当前prefs数据
LocalDataKeyPrefs =
{
    PlayerLevelUpGuide = "PlayerLevelUpGuide", --
    PlayerCaptureOpenGuide = "PlayerCaptureOpenGuide", --
    SubMissionCompleteGuide = "SubMissionCompleteGuide", --
    
    BuildingCampOpenNewSoldierBu = "BuildingCampOpenNewSoldierBu", --记录开启兵种
    BuildingCampOpenNewSoldierFa = "BuildingCampOpenNewSoldierFa",--记录开启兵种
    BuildingCampOpenNewSoldierGong = "BuildingCampOpenNewSoldierGong",--记录开启兵种
    BuildingCampOpenNewSoldierQi = "BuildingCampOpenNewSoldierQi",--记录开启兵种
    BuildingCampOpenNewSoldierGuyong = "BuildingCampOpenNewSoldierGuyong",--记录开启兵种
    
    GuideGroupIng = "GuideGroupIng"; --当前正在进行中的引导组
    GuideGenLevelUpFlag = "GuideGenLevelUpFlag"; --当前操作时英雄升级这个引导是否已经操作过
    
    GenShowOrderType = "GenShowOrderType"; --英雄界面的英雄默认如何排序
    
    BuildingLibLastTecId = "LastLibTecId", -- 最后一次升级的科技
    BuildingLibTecCompleteCountContinuous = "LibTecCompleteCountContinuous" --一口气完成了几个科技（用钱）
}

LocalDataManager = class("LocalDataManager")
function LocalDataManager:ctor()
end

function LocalDataManager:Inst()
    if nil == self.instance then
        self.instance = LocalDataManager:New()
        self.instance:Init();
    end
    return self.instance;
end

function LocalDataManager:Init()   
    self.login = {};
    self.mem = {};
    self.prefs = {};
end
--------------------------------------------------本次登录后记录的类型
function LocalDataManager:OnPlayerLogin()
    self.login = {};
end

--返回有可能为nil要判断
function LocalDataManager:GetLoginSaveData(keyInLogin) --这个先加到LocalDataLogin里面
    local key = self:MakeKeyStr(keyInLogin);
    return  self.login[key];  
end

function LocalDataManager:SetLoginSaveData(keyInLogin, data)
    local key = self:MakeKeyStr(keyInLogin); 
    self.login[key] = data;
end

------------------------------------------------ 游戏中记录的类型
function LocalDataManager:SetMemSaveData(keyInMem, data)
    local key = self:MakeKeyStr(keyInMem);
    self.mem[key] = data;
end

function LocalDataManager:GetMemSaveData(keyInMem) --这个先加到LocalMemData里面
    local key = self:MakeKeyStr(keyInMem);
    return self.mem[key];
end

function LocalDataManager:RemoveMemSaveData(keyInMem)
    local key = self:MakeKeyStr(keyInMem)
    if nil ~= self.mem[key] then
        self.mem[key] = nil;
    end
end

------------------------------------------------ 存储类型
function LocalDataManager:SetPrefSaveDataInt(prefsKey, data)
    PlayerPrefs.SetInt(self:MakeKeyStr(prefsKey), data)
end
function LocalDataManager:GetPrefSaveDataInt(prefsKey)
    return PlayerPrefs.GetInt(self:MakeKeyStr(prefsKey), 0)
end
function LocalDataManager:DelPrefSaveDataInt(prefsKey)
    PlayerPrefs.DeleteKey(self:MakeKeyStr(prefsKey))
end

function LocalDataManager:SetPrefSaveDataString(prefsKey, data)
    PlayerPrefs.SetString(self:MakeKeyStr(prefsKey), data)
end
function LocalDataManager:GetPrefSaveDataString(prefsKey)
    return PlayerPrefs.GetString(self:MakeKeyStr(prefsKey), "")
end
function LocalDataManager:DelPrefSaveDataString(prefsKey)
    PlayerPrefs.DeleteKey(self:MakeKeyStr(prefsKey))
end

function LocalDataManager:SetPrefSaveDataFloat(prefsKey, data)
    PlayerPrefs.SetFloat(self:MakeKeyStr(prefsKey), data)
end
function LocalDataManager:GetPrefSaveDataFloat(prefsKey)
    return PlayerPrefs.GetFloat(self:MakeKeyStr(prefsKey), 0)
end
function LocalDataManager:DelPrefSaveDataFloat(prefsKey)
    PlayerPrefs.DeleteKey(self:MakeKeyStr(prefsKey))
end

function LocalDataManager:MakeKeyStr(key)
    return "111111111111111111111111111111111111111111";
end