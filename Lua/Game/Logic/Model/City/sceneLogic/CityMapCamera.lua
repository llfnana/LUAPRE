------------------------------------------------------------------------
--- @desc 关卡相机
--- @author chenyl
------------------------------------------------------------------------

--region -------------引入模块-------------

--endregion

---@class City.Camera 相机
local CityMapCamera = class('CityMapCamera')

function CityMapCamera:ctor()
    self.gameObject = nil
    self.transform = nil
    self._camera = nil ---@type UnityEngine.Camera
    self._viewSize = nil --（高度）视野大小

    self._sceneSrs = {} ---@type UnityEngine.SpriteRenderer[] 场景渲染图
    self._sceneOffsets = {} ---@type number[] 渲染图移动偏移
    self._offsetHeight = 0.5 --高度相对偏移比例
    self._edgeSize = {x = 0, y = 0} ---移动边距

    self._moveSpeed = 0.02 --50
    self._muteDrag = false --禁用拖拽
end

function CityMapCamera:bind(go)
    self.gameObject = go
    self.transform = go.transform
    self._camera = go:GetComponent(typeof(Camera))
    --TODO 投影相机不应如此赋值，还有视野大小应该允许调整
    self._viewSize = self._camera.orthographicSize
    self._initCameraZ = -55
    self.zoomRecoverZ = -65

    self.roofActiveZ = -66              -- 屋顶激活的Z值
    self.roofActiveDirtyFlag = nil     -- 屋顶激活的脏标记

    self.maxZ = -38 -- -18                     -- 最大Z值
    self.minZ = -65 -- -104                    -- 最小Z值

    --监听拖拽事件
    --GameFramework.InputBase.Current:RegisterDraggingEvent(function (delta)
    --end)
    local DragCld = go.transform:Find("DragCld")
    Util.SetEvent(DragCld.gameObject, function (eventData)
        if self._muteDrag then
            return
        end
        self:_onPointerDrag(eventData)
    end, Define.EventType.OnDrag)

    local pinchCallback = function (go, scale, isStartedOverGui)
        -- self:_onPinch(scale)
        -- print("[error]" .. "pinch scale: " .. scale)
        if isStartedOverGui then --如果是在UI上操作，不处理
            return
        end
    
        local scaleDelta = scale - 1
        if scaleDelta ~= 0 then
            local z = self.transform.position.z
            local newZ = z + scaleDelta * 20
            self:setCameraZ(newZ)
        end
        
       
        if scaleDelta > 0 then
            self:setPosition(self.transform.position.x, self.transform.position.y, false)
        end
    end
    self.pinchCallback = pinchCallback
    TouchUtil.addPinch(pinchCallback, DragCld)

    self.CheckQuality = function ()
        local quality = PlayerModule.getQualityWitch()
        local isLow = Core.Instance.IsPhoneLow
        if  PlayerModule.getSdkPlatform() == "wx" and isLow  then
            quality =1
        end
        local universalAdditionalCameraData = go:GetComponent("UniversalAdditionalCameraData")
        universalAdditionalCameraData.renderPostProcessing = quality > 2
    end

    EventManager.AddListener(EventDefine.QualityChange, self.CheckQuality)

    self.SetBornPointHandler = function()
        self:SetToBornPoint()
    end
    EventManager.AddListener(EventType.TUTORIAL_INIT, self.SetBornPointHandler)
    self:CheckQuality()

    self:setCameraZ(self._initCameraZ)
    UpdateBeat:Add(self.update, self)

    self.Disabled = function()
        if isNil(self._camera) then 
            EventManager.RemoveListener(EventType.CITY_CAMERA_DISABLED, self.Disabled)
            EventManager.RemoveListener(EventType.CITY_CAMERA_ENABLED, self.Enabled)
        else 
            self._camera.enabled = false
        end
    end

    self.Enabled = function()
        if isNil(self._camera) then 
            EventManager.RemoveListener(EventType.CITY_CAMERA_DISABLED, self.Disabled)
            EventManager.RemoveListener(EventType.CITY_CAMERA_ENABLED, self.Enabled)
        else 
            self._camera.enabled = true
        end
    end

    EventManager.AddListener(EventType.CITY_CAMERA_DISABLED, self.Disabled)
    EventManager.AddListener(EventType.CITY_CAMERA_ENABLED, self.Enabled)
end

function CityMapCamera:unBind()
    EventManager.RemoveListener(EventDefine.QualityChange, self.CheckQuality)
    EventManager.RemoveListener(EventType.TUTORIAL_INIT, self.SetBornPointHandler)

    EventManager.RemoveListener(EventType.CITY_CAMERA_DISABLED, self.Disabled)
    EventManager.RemoveListener(EventType.CITY_CAMERA_ENABLED, self.Enabled)

    UpdateBeat:Remove(self.update, self)
    TouchUtil.removePinch(self.pinchCallback)
end

function CityMapCamera:setDragMute(isMute)
    self._muteDrag = isMute
end

function CityMapCamera:_onPointerDrag(eventData)
    local delta = eventData.delta
    local scale = 0.00036
    local position = self.transform.position
    local officeZ = self._initCameraZ - position.z
    local speed = self._moveSpeed + officeZ * scale;

    local offsetX = delta.x * speed
    local offsetY = delta.y * speed

    -- print('zhkxin 拖拽相机：', delta.x, delta.y)
    self:setPosition(position.x - offsetX, position.y - offsetY)
end

function CityMapCamera:moveToPosition(x, y, callback)
    --//计算相机的移动边界
    local viewSize = self:getCameraViewSize(math.abs(self.transform.position.z))
    local minX = -self._edgeSize.x + viewSize.width
    local maxX = self._edgeSize.x - viewSize.width
    local minY = -self._edgeSize.y + viewSize.height 
    local maxY = self._edgeSize.y - viewSize.height 

    x = Mathf.Clamp(x, minX, maxX)
    y = Mathf.Clamp(y, minY, maxY)

    local z = self.transform.position.z
    self.transform:DOMove(Vector3.New(x, y, z), 1):OnComplete(function ()
        if callback then
            callback()
        end
    end)
end

function CityMapCamera:setPosition(x, y, isLerp)
    
    --//计算相机的移动边界
    local viewSize = self:getCameraViewSize(math.abs(self.transform.position.z))
    local minX = -self._edgeSize.x + viewSize.width
    local maxX = self._edgeSize.x - viewSize.width
    local minY = -self._edgeSize.y + viewSize.height 
    local maxY = self._edgeSize.y - viewSize.height 

    -- local minX = -self._edgeSize.x + cameraHalfWidth
    -- local maxX = self._edgeSize.x - cameraHalfWidth
    -- local minY = -self._edgeSize.y + viewSize.height / 2
    -- local maxY = self._edgeSize.y - viewSize.height / 2

    --print('setPosition1:', minX, maxX, minY, maxY, x, y)
    --//保证不会移出包围盒
    x = Mathf.Clamp(x, minX, maxX)
    y = Mathf.Clamp(y, minY, maxY)
    --print('setPosition2:', minX, maxX, minY, maxY, x, y)

    --渲染图动态移动
    -- for i, v in ipairs(self._sceneSrs) do
    --     local _offset = self._sceneOffsets[i]
    --     local backX = x / maxX * _offset;
    --     local backY = y / maxY * _offset * self._offsetHeight;
    --     v.transform.position = Vector3.New(backX, backY, 0);
    -- end

    local z = self.transform.position.z

    -- local speed = 0.9;

    -- if isLerp then
    --     local lerpValue = Time.deltaTime * speed
    --     self.transform.position = Vector3.Lerp(self.transform.position, Vector3.New(x, y, z), lerpValue)
    --     return
    -- end
    self.transform.position = Vector3.New(x, y, z)
end

function CityMapCamera:setBgEdge(_edgeSize)
    self._edgeSize = _edgeSize
end

---@param sr UnityEngine.SpriteRenderer
function CityMapCamera:addSceneSr(sr, offset, isBackground)
    if isBackground then --背景图设置边距
        local size = sr.bounds.size --  + Vector3.New(offset, offset * self._offsetHeight, 0)
        self._edgeSize = size / 2
    end

    table.insert(self._sceneSrs, sr)
    table.insert(self._sceneOffsets, offset)
end

function CityMapCamera:getCameraViewSize(distance)
    local halfFOV = (self._camera.fieldOfView / 2) * Mathf.Deg2Rad
    local aspect = self._camera.aspect
    local height = distance * Mathf.Tan(halfFOV)
    local width = height * aspect

    -- local tx = self._camera.transform
    -- local v3List = {}
    -- v3List[ 1 ] = tx.position - ( tx.right * width )
    -- v3List[ 1 ] = v3List[ 1 ] + tx.up * height
    -- v3List[ 1 ] = v3List[ 1 ] + tx.forward * distance
    
    -- v3List[ 2 ] = tx.position + ( tx.right * width )
    -- v3List[ 2 ] = v3List[ 2 ] + tx.up * height
    -- v3List[ 2 ] = v3List[ 2 ] + tx.forward * distance
    
    -- v3List[ 3 ] = tx.position - ( tx.right * width )
    -- v3List[ 3 ] = v3List[ 3 ] - tx.up * height
    -- v3List[ 3 ] = v3List[ 3 ] + tx.forward * distance
    
    -- v3List[ 4 ] = tx.position + ( tx.right * width )
    -- v3List[ 4 ] = v3List[ 4 ] - tx.up * height
    -- v3List[ 4 ] = v3List[ 4 ] + tx.forward * distance

    -- Debug.DrawLine(v3List[1], v3List[2], Color.red)
    -- Debug.DrawLine(v3List[2], v3List[4], Color.red)
    -- Debug.DrawLine(v3List[4], v3List[3], Color.red)
    -- Debug.DrawLine(v3List[3], v3List[1], Color.red)

    return {width = width, height = height}
end

function CityMapCamera:debugDrawViewSize()
    local viewSize = self:getCameraViewSize(math.abs(self.transform.position.z))
    local height = viewSize.height
    local width = viewSize.width

    local tx = self._camera.transform
    local distance = math.abs(self.transform.position.z)
    local v3List = {}
    v3List[ 1 ] = tx.position - ( tx.right * width )
    v3List[ 1 ] = v3List[ 1 ] + tx.up * height
    v3List[ 1 ] = v3List[ 1 ] + tx.forward * distance
    
    v3List[ 2 ] = tx.position + ( tx.right * width )
    v3List[ 2 ] = v3List[ 2 ] + tx.up * height
    v3List[ 2 ] = v3List[ 2 ] + tx.forward * distance
    
    v3List[ 3 ] = tx.position - ( tx.right * width )
    v3List[ 3 ] = v3List[ 3 ] - tx.up * height
    v3List[ 3 ] = v3List[ 3 ] + tx.forward * distance
    
    v3List[ 4 ] = tx.position + ( tx.right * width )
    v3List[ 4 ] = v3List[ 4 ] - tx.up * height
    v3List[ 4 ] = v3List[ 4 ] + tx.forward * distance

    Debug.DrawLine(v3List[1], v3List[2], Color.red)
    Debug.DrawLine(v3List[2], v3List[4], Color.red)
    Debug.DrawLine(v3List[4], v3List[3], Color.red)
    Debug.DrawLine(v3List[3], v3List[1], Color.red)
end

-- 镜头跟随开启
function CityMapCamera:setCameraFocus(target)
    local followCp = self.gameObject:GetComponent("TransformFollow")
    followCp:SetTarget(target.transform)
    followCp.follow = true

    local viewSize = self:getCameraViewSize(math.abs(self.transform.position.z))
    local minX = -self._edgeSize.x + viewSize.width
    local maxX = self._edgeSize.x - viewSize.width
    local minY = -self._edgeSize.y + viewSize.height 
    local maxY = self._edgeSize.y - viewSize.height 
    --//保证不会移出包围盒
    followCp:SetRangeX(Vector2.New(minX, maxX))
    followCp:SetRangeY(Vector2.New(minY, maxY))

    Utils.SetFrameTarget(60)
end

-- 镜头跟随取消
function CityMapCamera:cancelCameraFocus()
    local followCp = self.gameObject:GetComponent("TransformFollow")
    followCp.follow = false

    Utils.SetFrameTarget()
end

-- 镜头跟随
function CityMapCamera:cameraFocus(target)
    -- local pos = target.transform.position
    -- if pos then 
    --     self:setPosition(pos.x, pos.y, true) 
    -- end
end

function CityMapCamera:SetToBornPoint()
    -- 新号进到时主界面-初始摄像机镜头中心是1-1的出生点
    local cityId = DataManager.GetCityId()
    if TutorialManager.CurrentStep and TutorialManager.CurrentStep.value == TutorialStep.FirstEnterCity and cityId ~= nil and cityId == 1 then
        local grid = GridManager.GetGridByMarkerType(cityId, GridMarker.TutorialBorn)
        local targetPosition = grid:GetBonePosition()
        local z = self.transform.position.z
        self.transform.position = Vector3.New(targetPosition.x, targetPosition.y, z)
    end 
end

function CityMapCamera:update()
    -- self:debugDrawViewSize()
--    local touch = Input.GetTouch(0)
--    if touch.phase == TouchPhase.Ended then
--        print('update end')
--    end
    -- local scroll = UnityEngine.Input.GetAxis("Mouse ScrollWheel")
    -- if scroll ~= 0 then
    --     local z = self.transform.position.z
    --     local newZ = z + scroll * 30
    --     self:setCameraZ(newZ)
    -- end

    -- if self._cameraFocus then
    --     self:cameraFocus(self.FocusTarget)
    -- end

    -- 此处做一个脏标记来标记计算屋顶是否显示
    local cameraZ =  self.transform:GetPositionZ()
    local flag = cameraZ < self.roofActiveZ
    if flag ~= self.roofActiveDirtyFlag then
        local buildDict = CityModule.getMainCtrl().buildDict
        self.roofActiveDirtyFlag = flag
        EventManager.Brocast(EventDefine.CitySceneUIDisplay, not flag)
        for k, v in pairs(CityModule.getMainCtrl().buildDict) do
            v:SetRoofDisplay(flag)
            v:SetTitleUIDisplay(flag)
            v:SetProductionUIDisplay(not flag)
        end
    end

    if UnityEngine.Application.isEditor then
        GM.KeyDown()
    end
end

-- 获屋顶是否要显示
function CityMapCamera:getRoofActive()
    return self.roofActiveDirtyFlag
end

function CityMapCamera:sceneToUiPos(scenePos)
    local point = self._camera:WorldToScreenPoint(scenePos)
    return PanelManager:ScreenToUiPos(point)
end

---放大镜头至建筑
function CityMapCamera:zoomTo(go, scale, offsetY, noAction)
    if self.ameraSizeTween then
        self.ameraSizeTween:Kill()
    end

    local targetX = go.transform.position.x
    local targetY = go.transform.position.y - 2 - (offsetY or 0)
    local targetPosition = Vector3.New(targetX, targetY, self._initCameraZ / scale)
    -- self:setCameraZ(self._initCameraZ)

    if not noAction then
        self:setCameraZ(self._initCameraZ)
    end
    local seq = DOTween.Sequence()
    seq:Append(self.transform:DOMove(targetPosition, 0.26):SetEase(Ease.OutCubic))
end

---镜头恢复
function CityMapCamera:zoomRecover()
    local seq = DOTween.Sequence()
    seq:Append(Util.TweenTo(self.transform.position.z, self.zoomRecoverZ, 0.26, function (value)
        self:setCameraZ(value)
    end):SetEase(Ease.InCubic))
end

function CityMapCamera:setZoomMin()
    self:setCameraZ(self.maxZ)
    -- local targetPosition = Vector3.New(self.transform.position.x, self.transform.position.x, self.maxZ)
    -- local seq = DOTween.Sequence()
    -- seq:Append(self.transform:DOMove(targetPosition, 0.26):SetEase(Ease.InCubic))
end
function CityMapCamera:setZoomMax()
    self:setCameraZ(self.minZ)
    -- local targetPosition = Vector3.New(self.transform.position.x, self.transform.position.x, self.minZ)
    -- local seq = DOTween.Sequence()
    -- seq:Append(self.transform:DOMove(targetPosition, 0.26):SetEase(Ease.OutCubic))
end

function CityMapCamera:DoCameraSize(z, duration, delay)
    -- Camera.main:DOOrthoSize(size, duration):SetDelay(delay):SetEase(Ease.InOutSine)
    local targetPosition = Vector3.New(self.transform.position.x, self.transform.position.x, z)
    delay = delay or 0
    self.ameraSizeTween = self.transform:DOMove(targetPosition, duration):SetDelay(delay):SetEase(Ease.InOutSine)
end

function CityMapCamera:setCameraZ(z)
    if z <= self.maxZ and z >= self.minZ then
        self.transform.position = Vector3.New(self.transform.position.x, self.transform.position.y, z)
    end
end

return CityMapCamera