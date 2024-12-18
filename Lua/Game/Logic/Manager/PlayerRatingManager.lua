PlayerRatingManager = {}
PlayerRatingManager.__cname = "PlayerRatingManager"

local this = PlayerRatingManager
PlayerRatingManager.UnlockType = "PlayerRating"

PlayerRatingManager.initialized = false
function PlayerRatingManager.Init()
    if this.initialized then
        return
    end
    
    this.initialized = true
    EventManager.AddListener(EventType.FUNCTIONS_UNLOCK, this.FunctionUnlockFunc)
end

function PlayerRatingManager.FunctionUnlockFunc(unlockType)
    if unlockType == PlayerRatingManager.UnlockType then
        ---TODO 用户评价界面
        -- PopupManager.Instance:LastOpenPanel(PanelType.PlayerRatingPanel)
    end
end
