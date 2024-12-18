IncreaseMedicalValue = Clone(BoostBase)
IncreaseMedicalValue.__cname = "IncreaseMedicalValue"

function IncreaseMedicalValue:OnEnter()
    local medicalTime = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.MedicalTime]
    local medicalValue = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.MedicalValue]
    local medicalCureRate = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.MedicalCureRate]
    local cardId = self.boostData.cardId
    local boostLevel = CardManager.GetCardItemData(cardId):GetCardBoostLevel()
    self.effect = self.effects[boostLevel]
    medicalTime.value = tonumber(self.params.cure_duration)
    medicalValue.value = self.effect
    medicalCureRate.value = tonumber(self.params.cureRate)
end

function IncreaseMedicalValue:OnQuit()
    local medicalTime = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.MedicalTime]
    local medicalValue = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.MedicalValue]
    local medicalCureRate = BoostManager.GetBoost(self.cityId).rxBoostList[RxBoostType.MedicalCureRate]
    medicalTime.value = 0
    medicalValue.value = 0
    medicalCureRate.value = 0
end
return IncreaseMedicalValue
