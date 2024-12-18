GameUpdate = {}
local this = GameUpdate
this.isDifference = false

function GameUpdate.Update()
    if PlayerModule.getSdkPlatform() == "wx" then 
        if this.isDifference == false then 
            local appVersion = Core.Instance.appVersion

            local info = WeChatWASM.WX.GetAccountInfoSync();
            remoteAppVersion = info.miniProgram.version;
        
            -- 跟远程版本不一致，则强更
            if appVersion ~= remoteAppVersion then 
                this.isDifference = true
                Utils.ReLoginDailogWithoutNoButton("login_version_warning")
            end
        end
    end
end