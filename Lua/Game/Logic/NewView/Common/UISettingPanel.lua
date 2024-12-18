---@class UISettingPanel : UIPanelBase
local Panel = UIPanelBaseMake()
local this = Panel
UISettingPanel = Panel

function Panel.OnAwake()
    this.cachedata = {}
    this.InitPanel()

    this.musicSwitch = true
    this.soundSwitch = true
    this.messageSwitch = true

    this.param = nil
end

function Panel.InitPanel()
    --绑定ui
    this.uidata = {}

    this.uidata.btnClose = SafeGetUIControl(this, "BtnClose", "Button")

    this.uidata.musicSwitch = SafeGetUIControl(this, "Menu/Item1/ImgBtnBg", "Image")
    this.uidata.soundSwitch = SafeGetUIControl(this, "Menu/Item2/ImgBtnBg", "Image")
    this.uidata.messageSwitch = SafeGetUIControl(this, "Menu/Item3/ImgBtnBg", "Image")
    this.uidata.temperatureSwtich = SafeGetUIControl(this, "Menu/Item4/ImgBtnBg", "Image")
    this.uidata.btnLanguage = SafeGetUIControl(this, "Menu/Item5/ImgButton", "Image")
    -- this.uidata.btnQuality = SafeGetUIControl(this, "Menu/Item6/ImgButton", "Image")
    this.uidata.musicIcon = SafeGetUIControl(this, "Menu/Item1/Icon", "Image")
    this.uidata.soundIcon = SafeGetUIControl(this, "Menu/Item2/Icon", "Image")

    this.uidata.btnFaceBook = SafeGetUIControl(this, "BtnFacebook", "Button")
    this.uidata.btnGoogle = SafeGetUIControl(this, "BtnGoogle", "Button")

    this.uidata.btnElse1 = SafeGetUIControl(this, "ElseMenu/Item1/Button", "Button")
    this.uidata.btnElse2 = SafeGetUIControl(this, "ElseMenu/Item2/Button", "Button")
    SafeGetUIControl(this, "ElseMenu/Item2"):SetActive(false)
    this.uidata.btnElse3 = SafeGetUIControl(this, "ElseMenu/Item3/Button", "Button")
    SafeGetUIControl(this, "ElseMenu/Item3"):SetActive(true)
    this.uidata.btnElse4 = SafeGetUIControl(this, "ElseMenu/Item4/Button", "Button")
    this.uidata.btnElse5 = SafeGetUIControl(this, "ElseMenu/Item5/Button", "Button")
    SafeGetUIControl(this, "ElseMenu/Item5"):SetActive(true)
    this.uidata.btnElse6 = SafeGetUIControl(this, "ElseMenu/Item6/Button", "Button")
    this.uidata.btnElse7 = SafeGetUIControl(this, "ElseMenu/Item7/Button", "Button")

    this.uidata.btnClearCacheFile = SafeGetUIControl(this, "ElseMenu/ClearCacheFile/Button", "Button")

    SafeGetUIControl(this, "ElseMenu/gameClub"):SetActive(false)
    this.uidata.gameClub = SafeGetUIControl(this, "ElseMenu/gameClub/Button", "Button")

    SafeGetUIControl(this, "ElseMenu/subscribeMessage"):SetActive(false)
    this.uidata.subscribeMessage = SafeGetUIControl(this, "ElseMenu/subscribeMessage/Button", "Button")

    this.uidata.textUid = SafeGetUIControl(this, "Btn_Copy/TextUid", "Text")

    this.uidata.TextVersion = SafeGetUIControl(this, "TextVersion", "Text")

    --兑换码功能开关
    SafeSetActive(this.uidata.btnElse6.transform.parent.gameObject, PlayerModule.getOpenExchange())

    this.uidata.Btn_Copy = SafeGetUIControl(this, "Btn_Copy", "Button")
end

function Panel.Init()
    this.InitStaticLanguageText()
    this.UpdateSettingPanel()
    this.UpdateButtonLanguage()
    this.UpdateUidAndVersion()
end

function Panel.UpdateUidAndVersion()
    this.uidata.textUid.text = "ID:"..PlayerModule.GetUid() .. GetLang("ui_setting_copy_id") -- .. "(默认数值)"
end

function Panel.InitStaticLanguageText()
    local titleText = SafeGetUIControl(this, "TitleItem/Text", "Text")
    titleText.text = GetLang("UI_Setting_Title")

    local musicTitleText = SafeGetUIControl(this, "Menu/Item1/Title", "Text")
    local soundTitleText = SafeGetUIControl(this, "Menu/Item2/Title", "Text")
    local messageTitleText = SafeGetUIControl(this, "Menu/Item3/Title", "Text")
    local temperatureTitleText = SafeGetUIControl(this, "Menu/Item4/Title", "Text")
    local languageTitleText = SafeGetUIControl(this, "Menu/Item5/Title", "Text")
    local qualityTitleText = SafeGetUIControl(this, "Menu/Item6/Title", "Text")
    local TextVersion = SafeGetUIControl(this, "TextVersion", "Text")
    musicTitleText.text = GetLang("UI_Setting_Music")
    soundTitleText.text = GetLang("UI_Setting_Sound")
    messageTitleText.text = GetLang("UI_Setting_Message")
    temperatureTitleText.text = GetLang("UI_Setting_Heat Unit")
    languageTitleText.text = GetLang("UI_Setting_Language")
    qualityTitleText.text = GetLang("ui_setting_graphic_quality")
    
    TextVersion.text = AssetBundleVersion

    for i = 1, 3 do
        local txtOn = SafeGetUIControl(this, "Menu/Item"..i.."/ImgBtnBg/TxtOn", "Text")
        local txtOff = SafeGetUIControl(this, "Menu/Item"..i.."/ImgBtnBg/TxtOff", "Text")
        txtOn.text = GetLang("UI_Setting_Button_On")
        txtOff.text = GetLang("Ui_Setting_Button_Off")
    end

    local fansText = SafeGetUIControl(this, "ElseMenu/Item1/Text", "Text")
    local surveyText = SafeGetUIControl(this, "ElseMenu/Item2/Text", "Text")
    local serviceText = SafeGetUIControl(this, "ElseMenu/Item3/Text", "Text")
    local serverText = SafeGetUIControl(this, "ElseMenu/Item4/Text", "Text")
    local privateText = SafeGetUIControl(this, "ElseMenu/Item5/Text", "Text")
    local exchangeText = SafeGetUIControl(this, "ElseMenu/Item6/Text", "Text")
    fansText.text = GetLang("ui_setting_fanpage")
    surveyText.text = GetLang("UI_Survey")-- "问卷调查"
    serviceText.text = GetLang("UI_Setting_Customer_Support")
    serverText.text = GetLang("UI_Setting_Terms_of_Service")
    privateText.text = GetLang("UI_Setting_Privacy_Policy")
    exchangeText.text = GetLang("ui_gift_exchange")

    local textLow = SafeGetUIControl(this, "Menu/Item6/ImgBtnBg/TxtLow", "Text")
    local textMid = SafeGetUIControl(this, "Menu/Item6/ImgBtnBg/TxtMiddle", "Text")
    local textHigh = SafeGetUIControl(this, "Menu/Item6/ImgBtnBg/TxtHight", "Text")
    textLow.text = GetLang("ui_setting_graphic_quality_low")
    textMid.text = GetLang("ui_setting_graphic_quality_mid")
    textHigh.text = GetLang("ui_setting_graphic_quality_high")
end

---刷新设置面板
function Panel.UpdateSettingPanel()
    this.SwitchToggle(this.uidata.musicSwitch, this.musicSwitch)
    this.SwitchToggle(this.uidata.soundSwitch, this.soundSwitch)
    this.SwitchToggle(this.uidata.messageSwitch, this.messageSwitch)
    this.SwitchToggleUnred(this.uidata.temperatureSwtich, GeneratorManager.temperatureUnitSwitch)
    Utils.SetIcon(this.uidata.musicIcon, this.musicSwitch and "install_icon_music_01" or "install_icon_music")
    Utils.SetIcon(this.uidata.soundIcon, this.soundSwitch and "install_icon_sound_01" or "install_icon_sound")

    -- 画质选项刷新
    local quality = PlayerModule.getQualityWitch()
    this.SeletQuality(quality)
end

function Panel.InitEvent()
    --绑定UGUI事件
    SafeAddClickEvent(this.behaviour, this.uidata.btnClose.gameObject, this.HideUI)

    -- 音乐音量
    SafeAddClickEvent(this.behaviour, this.uidata.musicSwitch.gameObject, function ()
        local b = not this.musicSwitch
        this.SwitchToggle(this.uidata.musicSwitch, b)
        this.musicSwitch = b
        Utils.SetIcon(this.uidata.musicIcon, this.musicSwitch and "install_icon_music_01" or "install_icon_music")
        PlayerModule.switchSettingMusic()
    end)
    -- 声音音量
    SafeAddClickEvent(this.behaviour, this.uidata.soundSwitch.gameObject, function ()
        local b = not this.soundSwitch
        this.SwitchToggle(this.uidata.soundSwitch, b)
        this.soundSwitch = b
        Utils.SetIcon(this.uidata.soundIcon, this.soundSwitch and "install_icon_sound_01" or "install_icon_sound")
        PlayerModule.switchSettingSound()
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.messageSwitch.gameObject, function ()
        local b = not this.messageSwitch
        this.SwitchToggle(this.uidata.messageSwitch, b)
        this.messageSwitch = b
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.temperatureSwtich.gameObject, function ()
        local b = not GeneratorManager.temperatureUnitSwitch
        this.SwitchToggleUnred(this.uidata.temperatureSwtich, b)
        GeneratorManager.SwitchTemperatureUnit(b)
    end)
    
    --低画质按钮
    local btn1 = SafeGetUIControl(this, "Menu/Item6/ImgBtnBg/Btn1")
    SafeAddClickEvent(this.behaviour, btn1, function ()
        PlayerModule.switchSettingQuality(1)
        this.SeletQuality(1)
    end)
    --中画质按钮
    local btn2 = SafeGetUIControl(this, "Menu/Item6/ImgBtnBg/Btn2")
    SafeAddClickEvent(this.behaviour, btn2, function ()
        PlayerModule.switchSettingQuality(2)
        this.SeletQuality(2)
    end)
    --高画质按钮
    local btn3 = SafeGetUIControl(this, "Menu/Item6/ImgBtnBg/Btn3")
    SafeAddClickEvent(this.behaviour, btn3, function ()
        PlayerModule.switchSettingQuality(3)
        this.SeletQuality(3)
    end)

    SafeAddClickEvent(this.behaviour, this.uidata.btnLanguage.gameObject, function ()
        ShowUI(UINames.UISettingLanguage)
    end)

    SafeAddClickEvent(this.behaviour, this.uidata.btnElse1.gameObject, function ()
        UIUtil.showText('暂无功能')
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.btnElse2.gameObject, function ()
        -- 打开问卷调查
        MiniGame.DHWXSDK.Instance:SetSurveyCloseCallback(function (data)
            print("[error]" .. "ojb 9子K  " .. data)
        end)
        local uid = PlayerModule.GetUid()
        MiniGame.DHWXSDK.Instance:Survey("14057716", "1", "1", tostring(uid), "1", "1")
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.btnElse3.gameObject, function ()
        -- 打开客服
        MiniGame.DHWXSDK.Instance:Service("1", "1", "1", "1", "1")
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.btnElse4.gameObject, function ()
        -- UIUtil.showText('服务条款')
        ShowUI(UINames.UIClauseInfo,2)
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.btnElse5.gameObject, function ()
        -- UIUtil.showText('隐私协议')
        ShowUI(UINames.UIClauseInfo,1)
    end)
    SafeAddClickEvent(this.behaviour, this.uidata.btnElse6.gameObject, function ()
        ShowUI(UINames.UIExchange)
    end)

    -- 公告
    SafeAddClickEvent(this.behaviour, this.uidata.btnElse7.gameObject, function ()
        ShowUI(UINames.UINotice, PlayerModule.notice)
    end)

     -- 清除缓存
     SafeAddClickEvent(this.behaviour, this.uidata.btnClearCacheFile.gameObject, function ()
        ShowUI(UINames.UIMessageBox, {
            Title = "ui_alert_title",
            DescriptionRaw = GetLang("UI_Setting_Button_cleancache_tip"),
            
            ShowYes = true,
            YesCallback = function ()
                if PlayerModule.getSdkPlatform() == "wx" then
                    WeChatWASM.WX.CleanAllFileCache(function()
                        Utils.RestartMiniProgram()
                    end);
                end
            end,
            ShowNo = true,
        })
    end)

    SafeAddClickEvent(this.behaviour, this.uidata.gameClub.gameObject, function ()
        if PlayerModule.getSdkPlatform() == "wx" then 
            -- 游戏圈
            MiniGame.DHWXSDK.Instance:GameUpdateGameClub(1, -30, -100, 200, 60)
        else

        end
    end)

    SafeAddClickEvent(this.behaviour, this.uidata.subscribeMessage.gameObject, function ()
        if PlayerModule.getSdkPlatform() == "wx" then 
            local option =  WeChatWASM.RequestSubscribeSystemMessageOption.New()
            local msgTypeList = System.Array.CreateInstance(typeof(System.String), 2)
            msgTypeList[0] = "SYS_MSG_TYPE_INTERACTIVE"
            msgTypeList[1] = "SYS_MSG_TYPE_RANK"
            option.msgTypeList = msgTypeList
            option.complete = function(res)
                print("zhkxing RequestSubscribeSystemMessage complete:", res.errMsg)
            end
            option.fail = function(res)
                print("zhkxing RequestSubscribeSystemMessage fail:", res.errMsg, res.errCode)
            end

            option.success = function(res)
                print("zhkxing RequestSubscribeSystemMessage success:", res.errMsg)
            end
            WeChatWASM.WX.RequestSubscribeSystemMessage(option)
        else

        end
    end)

    SafeAddClickEvent(this.behaviour, this.uidata.Btn_Copy.gameObject, function ()
        -- 复制到剪切板
        if PlayerModule.getSdkPlatform() == "wx" then
            Utils.WXSetClipboardData(PlayerModule.GetUid())
        else
            ShowTips(GetLang("ui_setting_copy_userid"))
            Util.SystemCopyBuffer(PlayerModule.GetUid())
            -- UnityEngine.GUIUtility.systemCopyBuffer
        end
    end)

    this.AddListener(EventDefine.LanguageChange, function ()
        this.UpdateButtonLanguage()
        this.InitStaticLanguageText()
        this.UpdateUidAndVersion()
    end)
end

function Panel.SeletQuality(quality)
    local imgBtn = SafeGetUIControl(this, "Menu/Item6/ImgBtnBg/ImgButton")
    local textLow = SafeGetUIControl(this, "Menu/Item6/ImgBtnBg/TxtLow", "Text")
    local textMid = SafeGetUIControl(this, "Menu/Item6/ImgBtnBg/TxtMiddle", "Text")
    local textHigh = SafeGetUIControl(this, "Menu/Item6/ImgBtnBg/TxtHight", "Text")

    textLow.color = quality == 1 and Color.New(215 / 255, 242 / 255, 184 / 255, 1) or Color.New(58 / 255, 56 / 255, 55 / 255, 1)
    textMid.color = quality == 2 and Color.New(215 / 255, 242 / 255, 184 / 255, 1) or Color.New(58 / 255, 56 / 255, 55 / 255, 1)
    textHigh.color = quality == 3 and Color.New(215 / 255, 242 / 255, 184 / 255, 1) or Color.New(58 / 255, 56 / 255, 55 / 255, 1)

    local x = quality == 1 and -78 or quality == 2 and 0 or 78
    imgBtn.transform:DOLocalMoveX(x, 0.2)
end

function Panel.UpdateButtonLanguage()
    local txtLanguage = SafeGetUIControl(this, "Menu/Item5/ImgButton/TxtOn", "Text")
    local langKey = PlayerModule.getLanguageList()[PlayerModule.getLanguage()].value
    local langStr = GetLang(langKey)
    txtLanguage.text = langStr
end

function Panel.SwitchToggle(item, b)
    this.SetEnableToggle(item, b, true, true)
end

function Panel.SwitchToggleUnred(item, b)
    this.SetEnableToggle(item, b, true, false)
end

function Panel.SetEnableToggle(item, enable, isAni, red)
    local btn = SafeGetUIControl(item, "ImgButton", "Image")
    local offsetX = 37
    if isAni then
        btn.transform:DOLocalMoveX(enable and offsetX or -offsetX, 0.2)
    else
        btn.transform.localPosition = Vector3.New(enable and offsetX or -offsetX, 0, 0)
    end

    local txtOn = SafeGetUIControl(item, "TxtOn", "Text")
    local txtOff = SafeGetUIControl(item, "TxtOff", "Text")
    txtOn.color = enable and Color.New(215 / 255, 242 / 255, 184 / 255, 1) or Color.New(58 / 255, 56 / 255, 55 / 255, 1)
    txtOff.color = enable and Color.New(58 / 255, 56 / 255, 55 / 255, 1) or Color.New(243 / 255, 203 / 255, 185 / 255, 1)

    local resName = enable and "com_bt_green_s" or "com_bt_red_s"
    resName = red and resName or "com_bt_green_s"
    Utils.SetIcon(btn, resName)
end

function Panel.OnShow()
    UIUtil.openPanelAction(this.gameObject)

    this.musicSwitch = PlayerModule.getMusicWitch()
    this.soundSwitch = PlayerModule.getSoundWitch()
    this.Init()
    this.InitEvent()
end

function Panel.HideUI()
    UIUtil.hidePanelAction(this.gameObject, function()
        HideUI(UINames.UISetting)
    end)
end
