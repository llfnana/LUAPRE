-- Event 事件定义
EventDefine = {
    OnSelectServer = "OnSelectServer",
    OnCloseNoticeAndSDKLogin = "OnCloseNoticeAndSDKLogin",
    OnServerConnectSuccess = "OnServerConnectSuccess",
    OnServerConnectFail = "OnServerConnectFail",
    OnServerDisconnect = "OnServerDisconnect",
    NotifyWaitUIState = "NotifyWaitUIState",
    OnLoginHandShake = "OnLoginHandShake",
    OnRecvEnterGameResult = "OnRecvEnterGameResult",
    LanguageChange = "LanguageChange",
    QualityChange = "QualityChange",
    OnCloseBuildUnlockPanel = "OnCloseBuildUnlockPanel",
    CityProductionUIDisplay = "CityProductionUIDisplay",
    CitySceneUIDisplay = "CitySceneUIDisplay",
    OnSubscriptionRefresh = "OnSubscriptionRefresh",
    OnNightChange = "OnNightChange",
    OnBoostRemove = "OnBoostRemove",

    HideLoadingUI = "HideLoadingUI", -- 关闭Loading界面
    HideMainUI = "HideMainUI",
    ShowMainUI = "ShowMainUI",
    --------------------- 基础 ---------------------
    OnSceneLoadingProgress = "OnSceneLoadingProgress",
    OnSceneLoadingComplete = "OnSceneLoadingComplete",
    --------------------- 邮件 ---------------------
    OnMailListDelete = "OnMailListDelete",
    OnMailListUpdate = "OnMailListUpdate",
    --------------------- 通用 ---------------------
    OnUIShow = "OnUIShow", -- 界面显示
    OnUIHide = "OnUIHide", -- 界面关闭
    OnObtainHide = "OnObtainHide", -- 获得界面关闭
    OnResourceChange = "OnResourceChange", -- 资源改变
    OnItemChange = "OnItemChange", -- 道具发生改变
    OnNetworkRequest = "OnNetworkStart", -- 网络请求发送
    OnNetworkReceive = "OnNetworkReceive", -- 网络请求接收
    MsgItemPanelClose = "MsgItemPanelClose", -- 道具面板关闭

    OnChargeFail = "OnChargeFail", -- 充值失败
    OnChargeSuccess = "OnChargeSuccess", -- 充值成功
    --------------------- 主界面 ---------------------
    OnClickCityBuild = "OnClickCityBuild", -- 点击主城建筑
    OnClickExitCityBuild = "OnClickExitCityBuild", -- 点击退出主城建筑UI

    OnOpenStoryBookDialog = "OnOpenStoryBookDialog", --打开对话剧情

    HideBottomMainUI = "HideBottomMainUI", -- 隐藏主界面底部UI
    ShowBottomMainUI = "ShowBottomMainUI", -- 显示主界面底部UI

    onSelectZone = "onSelectZone", -- 点击主城建筑缩放效果

    ShowMainUITip = "ShowMainUITip", -- 显示主界面提示
    HideMainUITip = "HideMainUITip", -- 隐藏主界面提示
    ShowMainUIBanner = "ShowMainUIBanner", -- 显示主界面Banner
    --------------------- 离线收益 ---------------------
    OnOfflineOver = "OnOfflineOver", -- 离线收益结算结束
    OnFactoryGameDraw = "OnFactoryGameDraw",
}

WMTrackEventDefine = {
    gameBeginCG = "gameBeginCG", -- 游戏开始播放CG
    gameSkipCG = "gameSkipCG", -- 游戏跳过播放CG
    gameEndCG = "gameEndCG", -- 游戏CG播放结束
    gameResReqBegin = "gameResReqBegin", -- 资源版本核对请求开始
    gameResReqError = "gameResReqError", -- 资源版本核对网络错误
    gameResReqSuccess = "gameResReqSuccess", -- 资源版本核对正确
    gameUpdateAssetBegin = "gameUpdateAssetBegin", -- 资源开始下载
    gameUpdateAssetError = "gameUpdateAssetError", -- 资源下载失败
    gameUpdateAssetSuccess = "gameUpdateAssetSuccess", -- 资源下载成功
    gameResDecBegin = "gameResDecBegin", -- 资源开始解压
    gameResDecError = "gameResDecError", -- 资源解压失败
    gameResDecSuccess = "gameResDecSuccess", -- 资源解压成功
    gameGetServerListBegin = "gameGetServerListBegin", -- 游戏请求服务器列表开始
    gameGetServerListError = "gameGetServerListError", -- 游戏失败获取服务器列表
    gameGetServerListSuccess = "gameGetServerListSuccess", -- 游戏成功获取服务器列表
    roleLoginErrorSDK = "roleLoginErrorSDK", -- 角色登录失败
    roleReconnection = "roleReconnection", -- 角色断网重连成功
    Toturial_begin = "Toturial_begin", -- 新手关开始
    Toturial_skip = "Toturial_skip", -- 新手关跳过
    Toturial_complete = "Toturial_complete", -- 新手关结束
    level_2 = "level_2", -- 主城level2完成
    level_3 = "level_3", -- 主城level3完成
    level_4 = "level_4", -- 基地level4完成
    level_5 = "level_5", -- 基地level5完成
    level_6 = "level_6", -- 基地level6完成
    level_7 = "level_7", -- 基地level7完成
    level_8 = "level_8", -- 基地level8完成
    level_9 = "level_9", -- 基地level9完成
    level_10 = "level_10", -- 基地level10完成
    retention_2d = "2d_retention", -- 次日留存
    retention_7d = "7d_retention", -- 7日留存
    retention_15d = "15d_retention", -- 15日留存
    retention_30d = "30d_retention", -- 30日留存
    JoinGroup = "Join Group", -- 成功加入公会
    CreateGroup = "Create Group", -- 成功创建公会
    finishmandatorytutorial = "finishmandatorytutorial" -- 强制性引导完成
}
