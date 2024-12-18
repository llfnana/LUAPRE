------------------------------------------------------------------------
--- @desc 玩家充值
--- @author sakuya
------------------------------------------------------------------------
PlayerCharge = class("PlayerCharge")
local Charge = PlayerCharge

function Charge:ctor()
    self.orderBackFlag = 0
    self.maxPollingCount = 8
end

-- 发起充值
--@param id number ID
--@param productId string 产品ID
--@param productName string 产品名称
--@param productNum number 产品数量
--@param price number 产品金额
--@param currencyType string 货币类型
--@param timestamp number 时间戳
--@param callback function 回调
function Charge:goCharge(id, productId, productName, productNum, price, currencyType, timestamp)
    timestamp = timestamp or os.time()
    local targetPlatform = PlayerModule.getSdkPlatform()
    -- 如果是电魂微信SDK
    if targetPlatform == "wx" then
        MiniGame.DHWXSDK.Instance:SetPayCallback(function(info)
            self:pollingCharge(info, function (data)
                MiniGame.DHWXSDK.Instance:AnalyticsPay(PlayerModule.GetUid(), "DDID", productId, price)
            end)
        end)

        local areaId = PlayerModule.GetPayAreaId()
        if areaId ~= 1 or areaId ~= 100 then 
            print("[Error] Pay areaId = ", areaId)
        end
        print("[支付] areaId = ", areaId)
        MiniGame.DHWXSDK.Instance:Pay(NetModule.getServerId(), id, areaId, productId, productName, productNum, price * 100,
            currencyType, timestamp)
    elseif targetPlatform == "local" then
        PlayerModule.c2sOrderTest(0, id, function(info)
            self:pollingCharge(info)
        end)
    end
end

-- 轮询充值是否成功
--@param callback function 充值成功以后的回调
function Charge:pollingCharge(info, callback)
    local okCall = function(data)
        -- 轮询成功
        if callback then
            callback(data)
        end
        EventManager.Brocast(EventDefine.OnChargeSuccess, data)
    end
    local failCall = function(data)
        -- 轮询失败
        self.orderBackFlag = self.orderBackFlag + 1
        if self.orderBackFlag < self.maxPollingCount then
            self:pollingChare(info)
        else
            EventManager.Brocast(EventDefine.OnChargeFail, info)
        end
    end

    local errorCall = function(data)
        EventManager.Brocast(EventDefine.OnChargeFail, info)
    end

    if type(info) == "string" then
        local jsonInfo = JSON.decode(info)

        if jsonInfo.code == -1 then
            errorCall()
            return
        end
    end

    self:c2sorderBack(okCall, failCall, errorCall)
end

function Charge:c2sorderBack(callback1, callback2, errorCall)
    local vo = NewCs("order")
    vo.info.order.orderBack = ""
    vo:add(errorCall, true, 0)
    vo:add(callback1, true, 1)
    vo:add(callback2, true, 2)
    vo:send()
end
