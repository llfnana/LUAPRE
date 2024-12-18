
--资源加载卸载入口
--说明：所有加载入口都封装到此界面， 如果返回resid的接口，由调用方负责调用ResInterface.ReleaseRes释放

local res_interface = Core.Instance.ResMgr;
ResInterface = ResInterface or {}
local this = ResInterface;
this.IsUseAssetBundle = res_interface:IsUseAssetBundle()

function ResInterface.IsExist(_resName)
	if _resName == nil then
		return false
	end
	return res_interface:IsExist(_resName)
end

--同步加载一个文本（返回UTF8类型字符串）
--参数1-名称
--返回1-现在修改为无返回值，都通过提供_callback参数进行回掉
--注意：本函数虽然为同步加载资源调用，但是并没有返回值，需要提供callback函数处理
--这主要是因为不能保证一定是同步加载
function ResInterface.LoadTextSync( _resName, _callback, _ext )
	-- print('[WxExtends]微信小游戏只能异步加载：', _resName, debug.traceback())

	return ResInterface.LoadTextAsync(_resName, _callback, _ext)
end

--同步加载一个字体,返回一个ttf类型文件
function ResInterface.LoadFontSync(_resName,_ext)
	if _ext==nil then
		_ext = ".ttf";
	end
	local font = res_interface:SyncLoadFont(_resName.._ext);
	return font;
end

--异步加载一个文本（返回UTF8类型字符串）
--参数1-名称
--返回1-字符串
function ResInterface.LoadTextAsync( _resName, _callback,  _ext )
	if _ext == nil then
		_ext = ".txt";
	end	
	res_interface:AsyncLoadText( _resName.._ext, _callback );
end


function ResInterface.LoadFileStringAsync( _resNameWithExt, _callback )
	res_interface:AsyncLoadText( _resNameWithExt, _callback );
end

--注意：本函数虽然为同步加载资源调用，但是并没有返回值，需要提供callback函数处理
--这主要是因为不能保证一定是同步加载
function ResInterface.SyncLoadGameObject( _resName, _callback, _returnGameObjectPrefab )
	-- print('[WxExtends]微信小游戏只能异步加载：', _resName, debug.traceback())

	if _returnGameObjectPrefab == nil then
		_returnGameObjectPrefab = true;
	end

	--return res_interface:SyncLoadGameObject(  _resName..".prefab", _callback, 0, _returnGameObjectPrefab );
	local _isCreate = not _returnGameObjectPrefab
	return ResInterface.commonLoadGameObject(_resName, _callback, nil, _isCreate)
end

---@param sr UnityEngine.SpriteRenderer
function ResInterface.AsyncSetSpritePng(_resName, sr)
	if _resName == nil or _resName == "" then
		error("[ResInterface.AsyncSetSpritePng] _resName is nil!")
		return;
	end

	ResInterface.AsyncLoadSprite(_resName .. ".png", function (sprite)
		sr.sprite = sprite
	end)
end

function ResInterface.AsyncLoadSpritePng(_resName, _callback)
	if _resName == nil or _resName == "" then
		error("[ResInterface.AsyncLoadSpritePng] _resName is nil!")
		return
	end

	return ResInterface.AsyncLoadSprite(_resName .. ".png", _callback)
end

function ResInterface.AsyncLoadSprite(_resName, _callback)
	if _resName == nil then
		error("[ResInterface.AsyncLoadSprite] _resName is nil!")
		return
	end

	if _callback == nil then
		error("[ResInterface.AsyncLoadSprite] _callback is nil! _resName=".._resName)
		return
	end

	return res_interface:AsyncLoadSprite(_resName, _callback)
end

function ResInterface.SyncLoadSpritePng(_resName, _callback)
	return ResInterface.SyncLoadSprite(_resName .. ".png", _callback)
end

function ResInterface.SyncLoadSprite(_resName, _callback)
	-- print('[WxExtends]微信小游戏只能异步加载：', _resName, debug.traceback())

	return ResInterface.AsyncLoadSprite(_resName, _callback)
end

function ResInterface.SyncLoadCommon(_resName, _callback)
	if _resName == nil then
		error("[ResInterface.SyncLoadCommon] _resName is nil!")
		return
	end

	if _callback == nil then
		error("[ResInterface.SyncLoadCommon] _callback is nil! _resName=".._resName)
		return
	end

	-- print('[WxExtends]微信小游戏只能异步加载：', _resName, debug.traceback())

	return res_interface:AsyncLoadCommon(_resName, _callback)
end

--异步加载GameObject, 通用
function ResInterface.commonLoadGameObject( _resName, _callback, _intParam, _isCreate )
	if _intParam == nil then
		_intParam = 0;
	end
	return res_interface:AsyncLoadGameObject( _resName..".prefab", _callback, _isCreate, _intParam )
end

--加载模型，返回resId, 默认是异步
function ResInterface.CreateModel( _resName, _callback, _intParam ) --, _async )
	if _intParam == nil then
		_intParam = 0;
	end
	--if _async then
		return res_interface:AsyncLoadGameObject( _resName..".prefab", _callback, true, _intParam )
	--else
	--	return res_interface:SyncLoadGameObject(  _resName..".prefab", _callback, _intParam, true );
	--end
end

--异步加载模型，返回没有实例化的原始资源对象
function ResInterface.LoadModel( _resName, _callback, _intParam )
	return ResInterface.commonLoadGameObject( _resName, _callback, _intParam, false )
end

--异步加载特效，返回实例化创建的特效对象
function ResInterface.CreateEffect( _resName, _callback, _intParam )
	return ResInterface.commonLoadGameObject( _resName, _callback, _intParam, true )
end

function ResInterface.CreateEffectSync( _resName, _callback )
	--return ResInterface.commonLoadGameObject( _resName, _callback, _intParam, true )
	return ResInterface.SyncLoadGameObject(_resName, _callback, false)
end

--异步加载特效，返回没有实例化的原始资源对象
function ResInterface.LoadEffect( _resName, _callback, _intParam )
	return ResInterface.commonLoadGameObject( _resName, _callback, _intParam, false )
end

--异步加载ui，返回实例化创建的特效对象
function ResInterface.CreateUIPrefab( _resName, _callback, _intParam )
	return ResInterface.commonLoadGameObject( _resName, _callback, _intParam, true )
end

--异步加载ui，返回没有实例化的原始资源对象
function ResInterface.LoadUIPrefab( _resName, _callback, _intParam )
	return ResInterface.commonLoadGameObject( _resName, _callback, _intParam, false )
end

--释放资源调用
function ResInterface.ReleaseRes( _resId )
	res_interface:ReleaseRes( _resId )
end

--加载场景
function ResInterface.LoadSceneSwitch( _sceneName, _loadedCallback, _progressCallback, _loadErrorCallback, loadMode )
	loadMode = loadMode or 0
	return res_interface:AsyncLoadScene( _sceneName..".unity", _loadedCallback, _progressCallback, loadMode, _loadErrorCallback )
end

--加载材质
function ResInterface.LoadMaterial( _matname, _callback )
	return res_interface:AsyncLoadMaterial( _matname..".mat", _callback)
end

--预加载Shader AssetBundle
function ResInterface.PreLoadShader( _shaderVariants )
	res_interface:WarmupShader( _shaderVariants )
end


--预加载AssetBundle
function ResInterface.PreLoadAssetBundle( _assetBundle )
	res_interface:PreLoadAssetBundle(_assetBundle, true)
end


--预加载资源
function ResInterface.PreloadAsset(_tag, _resNameWithExt, _async, _instCount)
	if _async == nil then
		_async = true;
	end

	_instCount = _instCount or 0;

	res_interface:PreloadAsset( _tag, _resNameWithExt, _async, _instCount )
end

--预加载模型资源
function ResInterface.PreloadModel(_tag, _modelId, _async, _instCount, _isBlue)
	if _async == nil then
		_async = true;
	end
	_instCount = _instCount or 0;	
	if _isBlue == nil then
		_isBlue = true;
	end
	res_interface:PreloadModel( _tag, _modelId, _async, _instCount, _isBlue )
end

--卸载预加载资源
function ResInterface.UnloadPreload( _tag )
	res_interface:UnloadPreload( _tag )
end


--预加载场景
function ResInterface.StartPreloadScene( _resNameWithoutExt )
	res_interface:StartPreloadScene( _resNameWithoutExt..".unity", 0 );
end