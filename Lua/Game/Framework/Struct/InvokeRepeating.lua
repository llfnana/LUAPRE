local InvokeR = {}
InvokeR.__cname = "InvokeR"

function InvokeR:New()
    return Clone(InvokeR)
end

function InvokeR:Start(method, time, repeatRate)
    if self:IsInvoking() then
        return
    end
    self.method = method
    self.time = time
    self.repeatRate = repeatRate
    self.CoFunc = function()
        if self.time > 0 then
            WaitForSeconds(self.time)
        end
        if self.repeatRate ~= nil then
            while (self.isInvoking) do
                WaitForSeconds(self.repeatRate)
                self.method()
            end
        else
            self.method()
        end
        Yield(nil)
    end

    self.isInvoking = true
    self.Co = StartCoroutine(self.CoFunc)
end

function InvokeR:Stop()
    self.isInvoking = false
    if self.Co then
        StopCoroutine(self.Co)
    end
end

function InvokeR:IsInvoking()
    return self.isInvoking
end

--===========================================================================
-- 下面是暴露出来的方法
--===========================================================================

function Invoke(method, time)
    if not IsFunction(method) then
        return nil
    end
    local iv = InvokeR:New()
    iv:Start(method, time)
    return iv
end

function InvokeRepeating(method, time, repeatRate)
    if not IsFunction(method) then
        return nil
    end
    local iv = InvokeR:New()
    if time == nil then
        time = 0.0
    end
    iv:Start(method, time, repeatRate)
    return iv
end

function CancelInvoke(iv)
    if iv then
        iv:Stop()
    end
end

function IsInvoking(iv)
    if iv then
        return iv:IsInvoking()
    else
        return false
    end
end
