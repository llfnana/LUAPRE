------------------------------------------------------------------------
--- @desc 关卡地图Item
--- @author chenyl
------------------------------------------------------------------------

--region -------------引入模块-------------

--endregion

---@class City.MapItem 地图Item
local Item = class('CityMapItem')

function Item:ctor(tid)
    self.tid = tid

    self.gameObject = nil
    self.transform = nil
    self._animation = nil ---@type SkeletonAnimation
    self._animRenderer = nil

    self.position = nil ---@type City.Position 坐标

    self.offsetX = nil
    self.offsetY = nil

    self._efIdleGo = nil --呼吸特效
    self.configs = nil
end

function Item:setOffset(x, y)
    self.offsetX = x
    self.offsetY = y
end

function Item:bind(go)
    self.gameObject = go
    self.transform = go.transform
    self._animation = go:GetComponentInChildren(typeof(SkeletonAnimation))
    self._animRenderer = self._animation:GetComponent(typeof(MeshRenderer))
    self.buildSpriteRender = self.transform:Find("Renderer"):GetComponent(typeof(SpriteRenderer))
    self.buildSpriteTransform = self.transform:Find("Renderer")

    local tbItem = TbCityItem[self.tid]
    self.configs = tbItem.Content

    --图片资源
    if tbItem.IsImage then
        Utils.SetIcon(self.buildSpriteRender, tbItem.Res, function (_sprite)
            local xPos = self.buildSpriteTransform.localPosition.x + (self.offsetX and self.offsetX / 100 or 0)
            local yPos = self.buildSpriteTransform.localPosition.y + (self.offsetY and self.offsetY / 100 or 0)
            self.buildSpriteTransform.localPosition = Vector3.New(xPos, 0, 0);
            self.buildSpriteTransform.localPosition = Vector3.New(0, yPos, 0);
            self.buildSpriteRender.sortingLayerName = "Building"
        end)
        return
    end

    if not StringUtil.isEmpty(tbItem.Res) then 
        -- todo 临时代码
        -- local tempName = "building_1_zdg_400021"
        -- local spRes = string.format("%s_SkeletonData.asset", tempName)

        -- 正式代码
        local spRes = string.format("%s_SkeletonData.asset", tbItem.Res)
        if not ResInterface.IsExist(spRes) then
            spRes = string.format("building_1_zdg_400021_SkeletonData.asset", tempName)
        end
        --资源为Spine动画
        ResInterface.SyncLoadCommon(spRes, function (dataAsset)
            -- 骨骼加载成功
            self._animation.skeletonDataAsset = dataAsset
            self._animation:Initialize(true)
            self._animRenderer.sortingLayerName = "Building"
            local x, y = self.position.x, self.position.y
            self._animRenderer.sortingOrder = CityModule.getMapCtrl():getSortingOrder(x, y)
    
            self:playAnim("idle", true) --播放呼吸动画
        end)
    end
    
    --加载呼吸特效
    if not StringUtil.isEmpty(tbItem.ResEfIdle) then
        ResInterface.SyncLoadGameObject(tbItem.ResEfIdle, function (obj)
            local _efGo = GOInstantiate(obj, self.transform)
            _efGo.transform.position = self.transform.position

            Util.SetRendererLayer(_efGo, "Building", 10)

            self._efIdleGo = _efGo
        end)
    end
end

-- function Item:hideSpine()
--     self._animation.transform.gameObject:SetActive(false)
-- end
-- function Item:showSpine()
--     self._animation.transform.gameObject:SetActive(true)
-- end

function Item:FindAnimation(ani, name)
    local anims = Util.GetAnimationsList(ani.Skeleton.Data)
    for i = 0, anims.Length - 1 do
        local aname = anims[i]
        if aname == name then
            return true
        end
    end
    return false
end

function Item:playAnimOfSp(spAni, name, loop, cmpCB)
    if spAni == nil then
        if cmpCB then
            cmpCB()
        end
        return
    end

    if spAni.state == nil then
        if cmpCB then
            cmpCB()
        end
        return
    end

    if not self:FindAnimation(spAni, name) then
        if cmpCB then
            cmpCB()
        end
        return
    end
    local entry = spAni.state:SetAnimation(0, name, loop)
    if cmpCB ~= nil then
        entry:AddOnComplete(cmpCB)
    end
end

function Item:playAnim(name, loop, cmpCB)
    if self._animation == nil then
        if cmpCB then
            cmpCB()
        end
        return
    end

    if self._animation.state == nil then
        if cmpCB then
            cmpCB()
        end
        return
    end

    if not self:FindAnimation(self._animation, name) then
        if cmpCB then
            cmpCB()
        end
        return
    end
    local entry = self._animation.state:SetAnimation(0, name, loop)
    if cmpCB ~= nil then
        entry:AddOnComplete(cmpCB)
    end
end

function Item:destroy()

end

return Item