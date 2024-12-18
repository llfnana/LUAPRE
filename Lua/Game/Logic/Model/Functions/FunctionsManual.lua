FunctionsManual = Clone(FunctionsBase)
FunctionsManual.__cname = "FunctionsManual"

function FunctionsManual:OnIsCity(cityId)
    return false
end

return FunctionsManual
