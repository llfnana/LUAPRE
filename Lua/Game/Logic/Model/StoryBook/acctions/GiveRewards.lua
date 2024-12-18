---@class GiveRewards : IActionBase
GiveRewards = Clone(IActionBase)
GiveRewards.__cname = "GiveRewards"
GiveRewards.type = EnumActionType.GiveRewards

function GiveRewards:PrepareInputs()
    
end

function GiveRewards:OnExecuteSelf()
    local cityId = DataManager.GetCityId()
    local rewards = Utils.ParseReward(self.dataBase.p1.rewards)
    local showRewards = DataManager.AddReward(cityId, rewards, "StoryBook", self.dataBase.id)
    ResAddEffectManager.AddResEffectFromRewards(showRewards)

    self:ExecuteNextNode()
end

return GiveRewards