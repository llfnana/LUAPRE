local Material = UnityEngine.Material
----------------------------------------------
-- 模型渲染到纹理帮助文件
-- 其中用的纹理，材质，摄像机等都在运行时创建
----------------------------------------------

--------------------------------------------------------------
--------------------------------------------------------------
-- 可配参数结构
UIModel_Texture_Param = class("UIModel_Texture_Param")
-- 构造
function UIModel_Texture_Param:ctor(modelRootObj, uiTextureScript, fCameraSize, textureSize, camoffset)
	-- 加载模型的根节点
	self.ModelRootObj = modelRootObj
	-- 用于显示映射的UITexture脚本实例
	self.mUITextureScript = uiTextureScript;
	-- 创建的RenderTexture纹理shader 
	self.mShaderType = "Unlit/Transparent UIModel"
	-- 创建的RenderTexture纹理size
	self.mTextureSize = textureSize or 1024
	-- 创建的RenderTexture深度
	self.mTextureDepth = 16
	-- 创建的CameraSize
	self.mCameraSize = fCameraSize or 0.4
	-- 摄像机偏移
	self.mCameraOffset = camoffset

end
--------------------------------------------------------------
--------------------------------------------------------------
-- 类
UIModel_Texture = class("UIModel_Texture")
-- 构造
function UIModel_Texture:ctor()
	-- 创建的材质
	self.mMaterial = nil
	-- 创建的RanderTexture
	self.mRanderTexture = nil
	-- 创建的摄像机
	self.mCamera = nil
	self.mCameraScript = nil
	self.mBaseCameraSize = 0.4
	-- 修正size
	self.mRefixCameraSize = 0.4
	-- 记录当前的aspect
	self.mCurAspect = 0
	
	self.Param = nil
end
-- 创建相关资源
function UIModel_Texture:Create(Param)
	
	self.Param = Param
	-- 修正下模型的根节点的layer
	--SetLayer(Param.ModelRootObj, ConstDefine.UIModel)
	-- 创建RenderTexture
	local lRanderTexture = UnityEngine.RenderTexture.New(Param.mTextureSize,Param.mTextureSize,Param.mTextureDepth)
	lRanderTexture.filterMode = UnityEngine.FilterMode.Bilinear --{Point, Bilinear, Trilinear}
	-- 创建材质
	local lShader = UnityEngine.Shader.Find(Param.mShaderType)
	local lMaterial = Material.New(lShader)
	lMaterial.mainTexture = lRanderTexture
	lMaterial.name = "uimodel"
	-- UITexture关联材质
	Param.mUITextureScript.material = lMaterial
	Param.mUITextureScript.mainTexture = lRanderTexture
	-- 创建摄像机
	local lCameraObj = GameObject.New()
	local lCamera = lCameraObj:AddComponent( typeof(Camera) )
	self.mCameraScript = lCamera
	self.mCurAspect = lCamera.aspect
	self.mBaseCameraSize = Param.mCameraSize
	lCamera.targetTexture = lRanderTexture
	AddChild(Param.ModelRootObj.transform.parent,lCameraObj.gameObject)
	SetLayerName(lCameraObj,ConstDefine.UIModel)
	lCameraObj.name = "CameraUIModel"
	-- 设置摄像机相关参数
	local vCamPos = Vector3.New(Param.ModelRootObj.transform.localPosition.x,0,Param.ModelRootObj.transform.localPosition.z)
	if self.Param.mCameraOffset ~= nil then
		vCamPos = vCamPos + self.Param.mCameraOffset
	end
	lCameraObj.transform.localPosition = vCamPos
	lCamera.cullingMask = Util.GetLayerMask( ConstDefine.UIModel )
	lCamera.clearFlags = UnityEngine.CameraClearFlags.SolidColor
	lCamera.orthographic = true
	lCamera.nearClipPlane = -10
	lCamera.farClipPlane = 10
	lCamera.backgroundColor = Color.New(0, 0, 0, 0)
	self:RefixCameraSize()
	-- 赋值
	self.mMaterial = lMaterial
	self.mRanderTexture = lRanderTexture
	self.mCamera = lCameraObj
	
	-----------------------------------
	-----------------------------------
	-- 增加PC端分辨率检测
	--if not UnityEngine.Application.isMobilePlatform then
		-- 非移动端
		--UpdateBeat:Add(self.Update, self)
	--end
	-----------------------------------
	-----------------------------------
end
-- 释放资源
function UIModel_Texture:Release()
	if self.mMaterial then destroy(self.mMaterial) end
	if self.mRanderTexture then destroy(self.mRanderTexture) end
	if self.mCamera then destroy(self.mCamera) end

	self.mMaterial = nil
	self.mRanderTexture = nil
	self.mCamera = nil
	self.Param = nil
	-----------------------------------
	-----------------------------------
	-- 增加PC端分辨率检测
	--if not UnityEngine.Application.isMobilePlatform then
		-- 非移动端
	--	UpdateBeat:Remove(self.Update, self)
	--end
	-----------------------------------
	-----------------------------------
end

-- 修正摄像机size
function UIModel_Texture:RefixCameraSize()
	-- 摄像机orthographicSize根据当前的aspect动态调整，标准为屏幕16：9 摄像机size = 0.4
	self.mCurAspect = UnityEngine.Screen.width / UnityEngine.Screen.height
	self.mRefixCameraSize = self.mBaseCameraSize * 100 / (16/9) * self.mCurAspect / 100
	self.mCameraScript.orthographicSize = self.mRefixCameraSize
end

-- 检测分辨率
function UIModel_Texture:Update()
	local aspect = UnityEngine.Screen.width / UnityEngine.Screen.height
	if math.Approximately(aspect, self.mCurAspect) == false then
		self:RefixCameraSize()
	end
end

--
function UIModel_Texture:ResetPos(rootPos,cameraPos)
	self.Param.ModelRootObj.transform.localPosition = rootPos
	self.mCamera.transform.localPosition = cameraPos
end