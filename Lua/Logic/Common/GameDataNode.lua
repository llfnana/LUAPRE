---
---这个文件的主要目的是以此文件做为一个订阅者结点，关联数据-动态的UI变化之间的关系
---当数据改变时，动态提示给UI或者其它显示阅读者，这样不用在UI里时时处理每个逻辑事件
---数据相当于一个DB字典，关联数据逻辑
---用于红点提示/界面更新
---

GameDataNode = class("GameDataNode")    --菜单处理基类，同时封装了菜单逻辑数据和点击调用函数
function GameDataNode:ctor()    
    self.homeTextName = nil;
    self:InitFuncMap();
end


--把表里所有配置的函数注册在这里，提供子类对象去实现
function GameDataNode:InitFuncMap()
    self.funcMap = {}
    self.funcMap["OnClickMarch"] = self.OnClickMarch; 
end

--调用函数
function GameDataNode:Invoke( _funcName )
    if _funcName == nil then
        return;
    end

    local f = self.funcMap[stringTrim(_funcName)];
    if f == nil then
        ShowTips("未实现".._funcName);
        return;
    end
    f(self);
end

--把表里所有配置的函数注册在这里，提供子类对象去实现
function GameDataNode:InitFuncMap()
    self.funcMap = {}
    self.funcMap["OnClickMarch"] = self.OnClickMarch;
end

----------------------------------------------------------------------------------------
GameDataNodeHomeBuilding = class("GameDataNodeHomeBuilding", GameDataNode)
function GameDataNodeHomeBuilding:ctor()
    GameDataNode.ctor(self);

    self:Init();
end

function GameDataNodeHomeBuilding:Init()
    self.buildingIndex = nil;
    self.funOnBuildingStateChange = nil; --
    
end
