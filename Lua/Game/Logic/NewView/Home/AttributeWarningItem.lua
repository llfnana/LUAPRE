AttributeWarningItem = class("AttributeWarningItem")

function AttributeWarningItem:InitPanel(behaviour, obj, type, count, func)
    self.gameObject = obj
    self.transform = obj.transform
    self.behaviour = behaviour

    self.ImageIcon = SafeGetUIControl(self, "content/ImageIcon", "Image")
    self.AttrCount = SafeGetUIControl(self, "content/AttrCount", "Text")

    Utils.SetAttributeIcon(self.ImageIcon, type)
    self.ImageIcon:SetNativeSize()
    self.tipsDesc = string.format("tooltip_%s_not_enough", type)

    self.callback = func

    self.isShow = false

    self:OnRefresh(count)

    self:OnInit(type, count)

    self:ShowTip()
end

--初始化
function AttributeWarningItem:OnInit(type, count)
    
    SafeAddClickEvent(self.behaviour, self.gameObject, function()

        if self.isShow then
            return
        end

        if self.callback then
            self.callback()
        end
        self.isShow = not self.isShow
        self:ShowTip(self.isShow)
        if self.isShow then
            TouchUtil.onOnceTap(function()
                self.isShow = false
                self:ShowTip(self.isShow)
            end)
        end
    end)
end

--刷新数值
function AttributeWarningItem:OnRefresh(count)
    self.AttrCount.text = count
    SafeGetUIControl(self, "WarningContent/TxtDes", "Text").text = GetLangFormat(self.tipsDesc, count, count * 10)
    local xx = GetLangFormat(self.tipsDesc .. "_harm")
    SafeGetUIControl(self, "WarningContent/TxtHarm", "Text").text = GetLangFormat(self.tipsDesc .. "_harm")
    SafeGetUIControl(self, "WarningContent/Txtadvice", "Text").text = GetLangFormat(self.tipsDesc .. "_advice")
end

--是否显示
function AttributeWarningItem:ShowTip(isShow)
    SafeSetActive(SafeGetUIControl(self, "WarningContent"), isShow)
end
