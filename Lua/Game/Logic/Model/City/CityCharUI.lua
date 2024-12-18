--- 用于存放 CityChar 头顶上的UI
---

CityCharUI = {}

CityCharUI.UI = {
    Warning = "UICityCharacterWarning",
    Slider = "UICityCharacterSlider",
    Progress = "UICityCharacterProgress",
    Tips = "UICityCharacterTips",
} 

function CityCharUI.Init()
    CityCharUI.parent = GameObject.Find("Map/CharUI").transform
end

function CityCharUI.CreateFollowUI(uiName, followTarget, callback)
    ResInterface.SyncLoadGameObject(uiName, function(_go)
        local go = GOInstantiate(_go, CityCharUI.parent)
        go.transform.localPosition = Vector3(0, 0.5, 0)

        local followComponent = go:GetComponent("TransformFollow")
        followComponent.follow = true
        followComponent:SetTarget(followTarget)

        if callback then 
            callback(go)
        end
    end)
end



