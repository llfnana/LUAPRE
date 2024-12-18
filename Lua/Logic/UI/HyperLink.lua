


--超链接管理
HyperLinkType_BigMapPos = 1   --大地图坐标

HyperLink = HyperLink or {}
local this = HyperLink;


------------------------------------------------------
--获得超链接字符
--示例:  label.text = GetHyperLinkText(HyperLinkType_BigMapPos, 100, 100 );
------------------------------------------------------
function HyperLink.GetHyperLinkText( _linkType, ... )
	local args = {...}
	local showText = nil;
	local color = "[FFFF00]";

	if _linkType == HyperLinkType_BigMapPos then
		if #args ~= 2 then
			error("[AddHyperLink]invalid param!")
			return nil;
		end
		local posX = args[1]
		local posY = args[2]
		showText = "X:"..posX..",Y:"..posY
	end


	local url = tostring(_linkType);
	for i = 1, #args do
		url = url.."|"..tostring(args[i]);
	end

	return string.format("[url=%s][u]%s%s[-][/u][/url]", url, color, showText ); 

end


------------------------------------------------------
--处理点击字符串
------------------------------------------------------
function HyperLink.HandleClickUrl( _label )

	local url = _label:GetUrlAtPosition( UICamera.lastHit.point );
	--error(url);

	if url == nil then
		return;
	end

	local args = stringsplit(url,"|")
	if args == nil then
		return;
	end

	if #args < 1 then
		return;
	end

	local linkType = tonumber( args[1] )
	if linkType == HyperLinkType_BigMapPos then
		if #args == 3 then
			this.HandleBigMapPos( tonumber(args[2]), tonumber(args[3]) )
		end
	end


end


------------------------------------------------------
--处理大地图坐标跳转
------------------------------------------------------
function HyperLink.HandleBigMapPos( _posX, _posY )

	--GameLogicUtils.GotoBigMapPos( _posY, _posY )
end

