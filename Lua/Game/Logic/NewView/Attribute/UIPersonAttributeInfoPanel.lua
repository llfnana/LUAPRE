---@class UIPersonAttributeInfoPanel : UIPanelBase
local Panel = UIPanelBaseMake();
local this = Panel;
UIPersonAttributeInfoPanel = Panel;

function Panel.OnAwake()
    this.cachedata = {};
    this.InitPanel();
    this.InitEvent();

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}
    this.img1 = {}
    this.img2 = {}
    this.img3 = {}
    this.img4 = {}

    this.uidata.mask = this.BindUIControl("Mask", this.HideUI)
    this.uidata.btnClose = this.BindUIControl("BtnClose", this.HideUI)
    this.uidata.txtTitle = this.GetUIControl("ImgTitle/Txt", "Text")
    this.uidata.scroll = this.GetUIControl("Scroll View", "ScrollRect")
    this.uidata.content = this.GetUIControl("Scroll View/Viewport/Content")
    this.uidata.tab = this.GetUIControl("Tab")
    this.uidata.img1 = this.GetUIControl(this.uidata.content, "Image1")
    this.img1.txt1 = this.GetUIControl(this.uidata.img1, "Txt1", "Text")
    this.img1.txt2 = this.GetUIControl(this.uidata.img1, "Txt2", "Text")
    this.img1.txtImg1 = this.GetUIControl(this.uidata.img1, "Img1/Txt", "Text")
    this.img1.txtImg2 = this.GetUIControl(this.uidata.img1, "Img2/Txt", "Text")
    this.img1.txtImg3 = this.GetUIControl(this.uidata.img1, "Img3/Txt", "Text")
    this.img1.txtImg4 = this.GetUIControl(this.uidata.img1, "Img4/Txt", "Text")
    this.uidata.img2 = this.GetUIControl(this.uidata.content, "Image2")
    this.img2.txt1 = this.GetUIControl(this.uidata.img2, "Txt1", "Text")
    this.img2.txt2 = this.GetUIControl(this.uidata.img2, "Txt2", "Text")
    this.img2.txtImg1 = this.GetUIControl(this.uidata.img2, "Img1/Txt", "Text")
    this.img2.txtImg2 = this.GetUIControl(this.uidata.img2, "Img2/Txt", "Text")
    this.img2.txtImg3 = this.GetUIControl(this.uidata.img2, "Img3/Txt", "Text")
    this.img2.txtImg4 = this.GetUIControl(this.uidata.img2, "Img4/Txt", "Text")
    this.img2.txtImg5 = this.GetUIControl(this.uidata.img2, "Img5/Txt", "Text")
    this.uidata.img3 = this.GetUIControl(this.uidata.content, "Image3")
    this.img3.txt1 = this.GetUIControl(this.uidata.img3, "Txt1", "Text")
    this.img3.txt2 = this.GetUIControl(this.uidata.img3, "Txt2", "Text")
    this.img3.txtImg1 = this.GetUIControl(this.uidata.img3, "Img1/Txt", "Text")
    this.img3.txtImg2 = this.GetUIControl(this.uidata.img3, "Img2/Txt", "Text")
    this.img3.txtImg3 = this.GetUIControl(this.uidata.img3, "Img3/Txt", "Text")
    this.img3.txtImg4 = this.GetUIControl(this.uidata.img3, "Img4/Txt", "Text")
    this.img3.txtImg5 = this.GetUIControl(this.uidata.img3, "Img5/Txt", "Text")
    this.uidata.img4 = this.GetUIControl(this.uidata.content, "Image4")
    this.img4.txt1 = this.GetUIControl(this.uidata.img4, "Txt1", "Text")
    this.img4.txt2 = this.GetUIControl(this.uidata.img4, "Txt2", "Text")
    this.img4.txt3 = this.GetUIControl(this.uidata.img4, "Txt3", "Text")
    this.img4.txt4 = this.GetUIControl(this.uidata.img4, "Txt4", "Text")
    this.img4.txt5 = this.GetUIControl(this.uidata.img4, "Txt5", "Text")
    this.img4.txt6 = this.GetUIControl(this.uidata.img4, "Txt6", "Text")
    this.img4.txt7 = this.GetUIControl(this.uidata.img4, "Txt7", "Text")
    this.img4.txt8 = this.GetUIControl(this.uidata.img4, "Txt8", "Text")
    this.img4.txt9 = this.GetUIControl(this.uidata.img4, "Txt9", "Text")

    this.uidata.txtTitle.text = GetLang("UI_Title_Attribute")
    this.tab = {} ---所有页签内容
    for i = 1, this.uidata.tab.transform.childCount do
        local go = this.uidata.tab.transform:GetChild(i - 1).gameObject
        local normal = go.transform:Find("Normal").gameObject
        local select = go.transform:Find("Select").gameObject
        SafeSetActive(select, false)
        table.insert(this.tab, {
            [1] = normal,
            [2] = select,
        })
    end

    this.item = this.uidata.content.transform:GetChild(0):GetComponent("RectTransform")

    this.offset = 20
    this.size = this.item.sizeDelta
    this.curTabIndex = -1
    this.difTabIndex = 1
    this.lastX = 0
    this.minSpeed = 3000

    -- 监听拖拽事件
    Util.SetEvent(this.uidata.scroll.gameObject,
        function(eventData) this._onDragBegin(eventData) end,
        Define.EventType.OnDragBegin)
    Util.SetEvent(this.uidata.scroll.gameObject,
        function(eventData) this._onDrag(eventData) end,
        Define.EventType.OnDrag)
    Util.SetEvent(this.uidata.scroll.gameObject,
        function(eventData) this._onDragEnd(eventData) end,
        Define.EventType.OnDragEnd)
end

function Panel.InitEvent()
    --绑定UGUI事件
end

function Panel.OnShow(param)
    UIUtil.openPanelAction(this.gameObject)
    if param == nil then
        this.uidata.content.transform.anchoredPosition = Vector2(200, 0)
    end
    local index = param or this.difTabIndex
    this.GoTabIndex(index)
    this.RefreshText()
end

function Panel.RefreshText()
    this.img1.txt1.text = GetLang("UI_Attribute_Warm")
    this.img1.txt2.text = GetLang("UI_Attribute_Warm_Low")
    this.img1.txtImg1.text = GetLang("data_analysis_meme_desc_4")
    this.img1.txtImg2.text = GetLang("ui_survivor_working_status_title_1")
    this.img1.txtImg3.text = GetLang("ui_survivor_working_status_title_4")
    this.img1.txtImg4.text = GetLang("ui_survivor_statistics_dead")

    this.img2.txt1.text = GetLang("UI_Attribute_Hunger")
    this.img2.txt2.text = GetLang("UI_Attribute_Hunger_Low")
    this.img2.txtImg1.text = GetLang("ui_survivor_statistics_hunger_select_food")
    this.img2.txtImg2.text = GetLang("ui_survivor_statistics_hunger_up")
    this.img2.txtImg3.text = GetLang("ui_survivor_statistics_good")
    this.img2.txtImg4.text = GetLang("ui_survivor_statistics_do_nothing")
    this.img2.txtImg5.text = GetLang("ui_survivor_statistics_dead")

    this.img3.txt1.text = GetLang("UI_Attribute_Rest_Solution")
    this.img3.txt2.text = GetLang("UI_Attribute_Rest_Low")
    this.img3.txtImg1.text = GetLang("ui_survivor_statistics_rest_up_zone")
    this.img3.txtImg2.text = GetLang("ui_survivor_statistics_hunger_up")
    this.img3.txtImg3.text = GetLang("ui_survivor_statistics_good")
    this.img3.txtImg4.text = GetLang("ui_survivor_statistics_do_nothing")
    this.img3.txtImg5.text = GetLang("ui_survivor_statistics_escape")

    this.img4.txt1.text = GetLang("UI_Attribute_Protest_Solution")
    this.img4.txt2.text = GetLang("ui_survivor_statistics_dead")
    this.img4.txt3.text = GetLang("ui_survivor_statistics_dead")
    this.img4.txt4.text = GetLang("ui_survivor_statistics_escape")
    this.img4.txt5.text = GetLang("↓")
    this.img4.txt6.text = GetLang("↓")
    this.img4.txt7.text = GetLang("↓")
    this.img4.txt8.text = GetLang("ui_protest_title")
    this.img4.txt9.text = GetLang("ui_survivor_statistics_rest_up_furniture")
end

function Panel._onDragBegin(eventData)
    this.lastPosition = eventData.position
    this.lastTime = TimeModule.getServerTime()
end

function Panel._onDrag(eventData)
end

function Panel._onDragEnd(eventData)
    local offset = eventData.position.x - this.lastPosition.x
    local time = TimeModule.getServerTime() - this.lastTime
    local speed = offset / time
    local index = this.curTabIndex
    if math.abs(offset) >= this.size.x / 2 or speed >= this.minSpeed then
        index = offset > 0 and this.curTabIndex - 1 or this.curTabIndex + 1
    end
    index = index < 1 and 1 or index
    index = index > #this.tab and #this.tab or index
    this.GoTabIndex(index)
end

function Panel.GoTabIndex(index)
    this.ChangeTab(index)
    ---坐标变化
    local temp = index - 1
    local x = temp * this.size.x + temp * this.offset
    x = -x

    local anchoredPosition = this.uidata.content.transform.anchoredPosition
    this.uidata.scroll.enabled = false

    local seq = DOTween.Sequence()
    seq:Append(Util.TweenTo(anchoredPosition.x, x, 0.3, function(value)
        this.uidata.content.transform.anchoredPosition = Vector2(value, 0)
    end))
    seq:OnComplete(function()
        this.uidata.scroll.enabled = true
    end)
    seq:Play()
end

function Panel.ChangeTab(index)
    if this.curTabIndex == index then
        return
    end
    this.ChangeTabStyle(this.curTabIndex, false)
    this.ChangeTabStyle(index, true)
    this.curTabIndex = index
end

function Panel.ChangeTabStyle(index, isSelect)
    if this.tab[index] == nil then
        return
    end
    SafeSetActive(this.tab[index][1], not isSelect)
    SafeSetActive(this.tab[index][2], isSelect)
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UIPersonAttributeInfo)
    end)
end
