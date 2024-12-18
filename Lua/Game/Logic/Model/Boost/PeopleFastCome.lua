PeopleFastCome = Clone(BoostBase)
PeopleFastCome.__cname = "PeopleFastCome"
function PeopleFastCome:OnEnter()
    local fastComeRx = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.PeopleFastCome]
    if fastComeRx ~= nil then
        fastComeRx.value = 1
    end
end
function PeopleFastCome:OnQuit()
    local fastComeRx = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.PeopleFastCome]
    if fastComeRx ~= nil then
        fastComeRx.value = 0
    end
end
return PeopleFastCome
