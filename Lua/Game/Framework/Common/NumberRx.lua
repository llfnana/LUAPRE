NumberRx = class2("NumberRx")

function NumberRx:ctor(t, val)
    self._value = val
    self.subject = Rx.Subject.create()
end

function NumberRx.Get:value()
    return self._value
end

function NumberRx.Set:value(val)
    self._value = val
    if self.subject then
        self.subject:onNext(val)
    end
end

function NumberRx:subscribe(func, isInit)
    if isInit == nil or isInit == true then
        func(self._value)
    end
    return self.subject:subscribe(func)
end

-- declare("NumberRx", NumberRx)

--[[
    释放示例
    local gem = NumberRx:New(0)
    local temp = gem:subscribe(function....)
    temp:unsubscribe()

    如果需要rx原始的操作
    local gem = NumberRx:New(0)
    gem:subject:原始操作
]]
