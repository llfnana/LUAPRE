---@class BoostFactor
BoostFactor = {}
BoostFactor._cname = "BoostFactor"

function BoostFactor:New()
    local cls = Clone(self)
    cls.factorList = {1, 1, 1, 1, 1}
    cls.factor = 1
    return cls
end

function BoostFactor:Add(index, factor)
    if index < 1 or index > #self.factorList then
        print("[error]" .. "Boost Index 不合法")
    end
    self.factorList[index] = self.factorList[index] + factor
    self:Sum()
end

function BoostFactor:Remove(index, factor)
    if index < 1 or index > #self.factorList then
        print("[error]" .. "Boost Index 不合法")
    end
    self.factorList[index] = self.factorList[index] - factor
    self:Sum()
end

function BoostFactor:Set(index, factor)
    if index < 1 or index > #self.factorList then
        print("[error]" .. "Boost Index 不合法")
    end
    self.factorList[index] = factor
    self:Sum()
end

function BoostFactor:Division(index, factor)
    if index < 1 or index > #self.factorList then
        print("[error]" .. "Boost Index 不合法")
    end
    if factor < 0.000001 then
        print("[error]" .. "BoostFactor.Division.factor is error")
    end
    self.factorList[index] = self.factorList[index] / factor
    self:Sum()
end

function BoostFactor:Sum()
    local ret = 1
    for index, value in pairs(self.factorList) do
        ret = ret * value
    end
    self.factor = ret
end
