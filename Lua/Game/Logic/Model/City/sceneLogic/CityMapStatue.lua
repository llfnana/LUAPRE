------------------------------------------------------------------------
--- @desc 关卡地图神像
--- @author chenyl
------------------------------------------------------------------------

--region -------------引入模块-------------

--endregion

---@class City.MapStatue : City.MapItem 地图神像
local Statue = class('CityMapStatue', CityMapItem)

function Statue:ctor(tid)
    CityMapItem.ctor(self, tid)

    self._isRepaired = false --是否已修复
end

function Statue:bind(go)
    CityMapItem.bind(self, go)

    Util.SetEvent(go, function ()
        self:_onClick()
    end, "onClick")

    --TODO 判断神像是否已修复
    self:playAnim("idle_broke", true)
end

function Statue:_onClick()
    if self._isRepaired then
        return
    end

    --显示修复界面
    ShowUI(UINames.UICityRepair, {
        tid = self.tid,
        onConfirm = function ()
            --TODO 判断消耗是否满足

            self:repair()

            Event.Brocast(EventDefine.OnCityRepair)
        end
    })
end

---修复
function Statue:repair()
    if self._isRepaired then
        return
    end

    self._isRepaired = true

    local tbItem = TbCityItem[self.tid]

    --播放特效-建设
    local _buildEfGo = nil
    ResInterface.SyncLoadGameObject('E_budling_4_zl_jz', function (obj)
        local _efGo = GOInstantiate(obj)
        Util.SetRendererLayer(_efGo, "Building", 10)

        _buildEfGo = _efGo
    end)
    --播放特效-升级
    TimeModule.addDelay(2, function ()
        ResInterface.SyncLoadGameObject('E_budling_4_zl_sj', function (obj)
            local _efGo = GOInstantiate(obj)
            Util.SetRendererLayer(_efGo, "Building", 10)

            TimeModule.addDelay(1, function ()
                _efGo:SetActive(false) --隐藏
            end)
        end)

        _buildEfGo:SetActive(false) --隐藏

        self:playAnim("idle", true) --播放正常待机动画

        --加载修复后的特效
        ResInterface.SyncLoadGameObject(tbItem.ResEfRun, function (obj)
            local _efGo = GOInstantiate(obj, self.transform)
            _efGo.transform.position = self.transform.position

            Util.SetRendererLayer(_efGo, "Building", 10)
        end)

        --Event.Brocast(EventDefine.OnCityRepairEnd)
    end)
end

return Statue