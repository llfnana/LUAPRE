ModeChangeScene = Clone(ModeNormal)
ModeChangeScene.__cname = "ModeChangeScene"

---模式进入
function ModeChangeScene:OnEnter()
    GameManager.GamePause = true
end

---模式刷新
function ModeChangeScene:OnForceUpdate()
end

---模式停止
function ModeChangeScene:OnExit()
end
