local Panel = {};
local this = Panel;
UIWaitTipPanel = Panel;
--启动事件--
function Panel.Awake(obj, behaviour)
    this.gameObject = obj;
    this.transform = obj.transform;
    this.behaviour = behaviour;
    this.cachedata = {};

    this._timer = nil

    this.InitPanel();
end

--初始化面板--
function Panel.InitPanel()
    -- 绑定ui
    this.uidata = {}

    this.uidata.mask = SafeGetUIControl(this, "Mask")
    this.uidata.img = SafeGetUIControl(this, "Mask/Img")

end

function Panel.OnShow()
    SafeSetActive(this.uidata.img, false)

    -- 如果界面打开很慢的话，可能已经关闭了
    if UIUtil.checkWaitTip() then 
        this._timer = TimeModule.addDelay(0.3, function()
            SafeSetActive(this.uidata.img, true)
        end)
    else 
        -- OnShow时，界面的load状态还没有完成，因此要下一帧才能移除
        StartCoroutine(function()
            Yield(nil)
            HideUI(UINames.UIWaitTip)
        end)
    end
end

function Panel.OnHide()
    this.ClearTimer()
end

function Panel.ClearTimer()
    if this._timer ~= nil then
        TimeModule.removeTimer(this._timer)
        this._timer = nil
    end
end