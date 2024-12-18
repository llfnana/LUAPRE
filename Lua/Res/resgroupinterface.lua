------------------------------------------------------------------
-- 按资源组的方式加载，区别于ResInterface
------------------------------------------------------------------

ResGroupLuaInterface = ResGroupSystem.ResGroupLuaInterface;

RLQ_PRIORITY_MONOPOLIZE = 0  --加载队列优先级独占式
RLQ_PRIORITY_HIGH = 1        --加载队列优先级高
RLQ_PRIORITY_NORMAL = 2	  	 --加载队列优先普通
RLQ_PRIORITY_IDLE = 3		 --加载队列优先级-空闲	


--资源加载类型
eResLoadRequetType_UI = 0
eResLoadRequetType_Text = 1
eResLoadRequetType_GameObject = 2
eResLoadRequetType_Material = 3
eResLoadRequetType_Sprite = 4
eResLoadRequetType_Texture = 5
eResLoadRequetType_AnimClip = 7

------------------------------------------------------------
--- ResGroupLuaInterface所有函数都在这里调用吧
--- 其它脚本就不直接调用ResGroupLuaInterface的方法了免得修改后麻烦
------------------------------------------------------------
ResGroupInterface = {};
local this = ResGroupInterface;

------------------------------------------
--- 创建上下文
------------------------------------------
function ResGroupInterface.CreateContext(contextName, loadQueueFIFO)
    if nil == loadQueueFIFO then
        loadQueueFIFO = false;
    end
    local bRet = ResGroupLuaInterface.CreateContext(contextName, false); -- 创建上下文
    if not bRet then
        error("CreateContext error : " .. contextName);        
    end
    return bRet;
end

------------------------------------------
--- 创建资源组(返回ID)
------------------------------------------
function ResGroupInterface.CreateResGroup(contextName)
    local groupId = ResGroupLuaInterface.CreateResGroup(contextName);
    if groupId < 0 then
        error("CreateResGroup error : " .. contextName);
    end
    return groupId; 
end

------------------------------------------
--- 销毁资源组
------------------------------------------
function ResGroupInterface.UnloadResGroup(contextName, groupId, isRemoveGroup)
   ResGroupLuaInterface.UnloadResGroup(contextName, groupId, isRemoveGroup);
end

------------------------------------------
--- 销毁上下文
------------------------------------------
function ResGroupInterface.DestroyContext(contextName)
    ResGroupLuaInterface.DestroyContext(contextName); -- 上下文删除吗？
end

------------------------------------------
--- 播放一次prefab类型的特效(将加载特效并在特效放完时删除)
------------------------------------------
function ResGroupInterface.PlayOnceEffect(contextName, groupId, effName, bindPosObj, scaleX, scaleY, scaleZ, endCallFun)
    scaleX = scaleX or 1;
    scaleY = scaleY or 1;
    scaleZ = scaleZ or 1;
    ResGroupLuaInterface.PlayOnceEffect(contextName, groupId,  effName, bindPosObj, scaleX, scaleY, scaleZ, endCallFun);
end

------------------------------------------
--- 加载并播放特效（持续）
------------------------------------------
function ResGroupInterface.PlayEffect(contextName, groupId, effName, bindPosObj, scaleX, scaleY, scaleZ)
    scaleX = scaleX or 1;
    scaleY = scaleY or 1;
    scaleZ = scaleZ or 1;
    ResGroupLuaInterface.PlayEffect(contextName, groupId,  effName, bindPosObj, scaleX, scaleY, scaleZ);
end

------------------------------------------
--- 销毁播放特效
------------------------------------------
function ResGroupInterface.RemoveEffect(contextName, groupId, effName, bindPosObj)
    ResGroupLuaInterface.RemoveEffect(contextName, groupId,  effName, bindPosObj);
end

------------------------------------------
--- 停止播放特效（设置不可见）
------------------------------------------
function ResGroupInterface.RemoveEffect(effName, bindPosObj)
    local effTrans = bindPosObj.transform:Find(effName);
    if nil ~= effTrans then
        effTrans.gameObjct:SetActive(false);
    end
end

------------------------------------------
--- 加载Prefab
------------------------------------------
function ResGroupInterface.LoadPrefab(contextName, groupId, prefabName, callFun)
    ResGroupLuaInterface.LoadPrefab(contextName, groupId,  prefabName, callFun);    
end

------------------------------------------
--- 卸载prefab
------------------------------------------
function ResGroupInterface.DestroyGameObjct(contextName, groupId, prefabObj, bForceDestroy)
    ResGroupLuaInterface.DestroyGameObjct(contextName, groupId,  prefabObj, bForceDestroy);
end

------------------------------------------
--- 设置图像
------------------------------------------
function ResGroupInterface.SetObjectImage(contextName, groupId, goImg, iconName, bMakePixelPerfect, width, heigh, matName, bAsyn)
    ResGroupLuaInterface.SetObjectImage(contextName, groupId, goImg, iconName, bMakePixelPerfect, width, heigh, matName, bAsyn);
end
------------------------------------------
--- todo
------------------------------------------