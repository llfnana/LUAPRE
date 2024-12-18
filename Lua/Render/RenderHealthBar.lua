
require("Render/RenderObject")


RenderHealthBar = class("RenderHealthBar", RenderObject)

--local debugNum_WaitSetName = debugNum_WaitSetName or 0 
--local debugNum_LoadedSetName = debugNum_LoadedSetName or 0

RenderHealthBar.STATE_ATTACK = 1;
RenderHealthBar.STATE_DEFENCE = 2;
RenderHealthBar.STATE_DEATH = 3;
RenderHealthBar.STATE_INVALID = 4;

function RenderHealthBar:ctor()
	RenderObject.ctor( self )

	self.uidata = {};
	self.uidata.imgObj = nil;
	self.uidata.imgHp = nil;
	self.uidata.lbHeroNum = nil;
	self.cacheInfo = nil;
	self.mActionState = RenderHealthBar.STATE_INVALID;
end

function RenderHealthBar:Destroy()
	RenderObject.Destroy(self);
	self.uidata = nil;
end


function RenderHealthBar:Create()
	
	if( self.initParams == nil ) then
		error( "Create:self.initParams is nil!" )
		return;
	end
	if( self.state ~= RenderObjectState_None ) then
		error("Create: self.stat is not none!")
		return;
	end


	if( self.initParams == nil ) then
		error("[RenderHealthBar:Create] init params is nil")
		return;
	end
	
	--查询模型信息
	local modelResName = self.initParams.ModelName
	if( modelResName == nil ) then
		error("cant't find model name: modeid="..self.initParams.ModelId)
		return false
	end
	
	self.name = modelResName.."_"..self.initParams.Id
	
	local f = function( _go )
		self:OnModelLoaded(_go)
	end
	
	self.mPreHp = nil;
	self.state = RenderObjectState_Loading;
	self.mActionState = RenderHealthBar.STATE_INVALID;

	if self.initParams.PoolName ~= nil then
		GoPoolMgr.CurrentPool():GetObject( self.initParams.PoolName, modelResName, f );
	else
		self.resId = ResInterface.CreateModel( modelResName, f )
	end	
		
	return true;
end


function RenderHealthBar:OnModelLoaded( _go )

	--说明这个UI已经被销毁了
	if nil == self.uidata then
		GameObject.Destroy(_go);
		return;
	end
	
	if not self:CheckStateOnResourceLoaded( _go ) then
		return;
	end			
	
	_go:SetActive( true );
	self.mainObject = _go;
	self.mainTransform = self.mainObject.transform;
	RenderObject.Init( self );
	self.state = RenderObjectState_Loaded

	self.mainObject.transform.localPosition = Vector3.zero;
	self.mainObject.transform.localRotation = Quaternion.identity;
	self.mainObject.transform.localScale = Vector3.one;

	if self.name ~= nil then
		_go.name = self.name;
	end

	--初始化
	--self.uidata.imgObj = _go.transform:Find("ImgHeroIcon").gameObject;
	--self.uidata.lbHeroNum = _go.transform:Find("LableHeroNum"):GetComponent("Text");
	self.uidata.imgHp = _go.transform:Find("imageBg/imageHealthBar"):GetComponent("Image");
	-- self.uidata.imgBgHp = _go.transform:Find("imageDamageBar"):GetComponent("Image");
	-- self.uidata.imgBgHpTween = self.uidata.imgBgHp:GetComponent("TweenFillAmount");
	
	--self.uidata.objMove = _go.transform:Find("imageMove").gameObject;
	--self.uidata.objDied = _go.transform:Find("imageDead").gameObject;
	self.uidata.imgAttackGo = _go.transform:Find("imageBg/ImageAtt").gameObject;
	self.uidata.imgDefenceGo = _go.transform:Find("imageBg/ImageDef").gameObject;
	-- self.uidata.imgDeadGo = _go.transform:Find("imageDead").gameObject;

	-- self.uidata.imgDeadGo:SetActive(false);
	self.uidata.imgAttackGo:SetActive(false);
	self.uidata.imgDefenceGo:SetActive(false);
	
	--绑定萌动
	local uiBindCom = _go:GetComponent(typeof(UIBindSceneObjectScale));
	if isNil(uiBindCom) then
		uiBindCom = _go:AddComponent(typeof(UIBindSceneObjectScale));
	end
	
	local bindParam = {};
	bindParam.bindObj = self.initParams.BindObj;
	bindParam.offset = {}
	bindParam.offset.x = self.initParams.BindOffset.x;
	bindParam.offset.y = self.initParams.BindOffset.y;
	bindParam.offset.z = self.initParams.BindOffset.z;
	bindParam.bindBestDistance = self.initParams.BindBestDistance;
	bindParam.bindScaleFactor = self.initParams.BindScaleFactor;
	bindParam.bindMaxScale = self.initParams.BindMaxScale;
	bindParam.bindMinScale = self.initParams.BindMinScale

	uiBindCom:SetSizeParam(bindParam.bindBestDistance, bindParam.bindScaleFactor, bindParam.bindMaxScale, bindParam.bindMinScale);
	uiBindCom:BindGameObject(bindParam.bindObj, false, bindParam.offset.x, bindParam.offset.y, bindParam.offset.z);
	
	
	if self.cacheInfo ~= nil then
		if self.cacheInfo.hp ~= nil and self.cacheInfo.maxhp ~= nil then
			self:SetHP( self.cacheInfo.hp, self.cacheInfo.maxhp )
		end
		--if self.cacheInfo.name ~= nil then
		--	self.uidata.lbHeroNum.text = self.cacheInfo.name;
		--end
		--if self.cacheInfo.nameColor ~= nil then
		--	self.uidata.lbHeroNum.color = self.cacheInfo.nameColor;
		--end
		--if self.cacheInfo.headAtlasName ~= nil then
		--	self:SetImage(self.uidata.imgObj,  self.cacheInfo.headAtlasName, self.cacheInfo.headImgName, self.cacheInfo.headMakePixelPerfect)
		--end

		--if self.cacheInfo.moveState  then
		--	self.uidata.objMove:SetActive(true);
		--end

		--if self.cacheInfo.diedState  then
		--	self.uidata.objDied:SetActive(true);
		--end
		  
		
		if self.mActionState == RenderHealthBar.STATE_DEFENCE then
			self.uidata.imgHp.fillAmount = 0;
			-- self.uidata.imgBgHp.fillAmount = 0;
		end
		
		-- self.uidata.imgDeadGo:SetActive(self.mActionState == RenderHealthBar.STATE_DEFENCE);
		self.uidata.imgAttackGo:SetActive(self.mActionState == RenderHealthBar.STATE_ATTACK);
		self.uidata.imgDefenceGo:SetActive(self.mActionState == RenderHealthBar.STATE_DEFENCE);
		
		self.cacheInfo = nil;
	end
	

	if self.initParams.OnLoadFinshCallback ~= nil then
		self.initParams.OnLoadFinshCallback()
	end
end

--设置血量(0-1)
function RenderHealthBar:SetHP( hp, maxhp )
	if self.state == RenderObjectState_Loaded then
		
		local value = hp/maxhp;
		
		if self.mPreHp == nil then
			self.mPreHp = value;
			-- self.uidata.imgBgHp.fillAmount = value;
		else
			-- self.uidata.imgBgHpTween.from = self.uidata.imgBgHp.fillAmount;
			-- self.uidata.imgBgHpTween.to = value;
			-- self.uidata.imgBgHpTween.delay = 0.1;
			-- self.uidata.imgBgHpTween.duration = 0.2;
			-- self.uidata.imgBgHpTween:Play();
			
			self.mPreHp = value;
		end
		
		self.uidata.imgHp.fillAmount = value;
	else
		if self.cacheInfo == nil then
			self.cacheInfo = {}
		end
		self.cacheInfo.hp = hp
		self.cacheInfo.maxhp = maxhp
	end
end

function RenderHealthBar:SetActionState(actState)
	if self.state == RenderObjectState_Loaded then
		
		self.mActionState = actState;
		
		-- self.uidata.imgDeadGo:SetActive(self.mActionState == RenderHealthBar.STATE_DEATH);
		self.uidata.imgAttackGo:SetActive(self.mActionState == RenderHealthBar.STATE_ATTACK);
		self.uidata.imgDefenceGo:SetActive(self.mActionState == RenderHealthBar.STATE_DEFENCE);
		
	else
	
		self.mActionState = actState;
	end
end

