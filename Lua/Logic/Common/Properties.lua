

--属性容器

Properties = class("Properties")


function Properties:ctor()
	self.values = {}
end

function Properties:SetValue( _k, _v )
	self.values[_k] = _v;
end

function Properties:GetValue( _k, _defaultValue )
	if nil == self.values[_k] then
		return _defaultValue;
	else
		return self.values[_k]
	end
end

function Properties:Clear()
	self.values = {}
end


function Properties:UpdateFromMsg( _msgPublicProperties, _calcOffset )
	
	local changeKV = nil;
	if _calcOffset then
		changeKV = {}
	end
	
	for i = 1, #_msgPublicProperties.props do
		local k = _msgPublicProperties.props[i].propId
		local v = nil
		if _msgPublicProperties.props[i]:HasField("uValue") then
			v = _msgPublicProperties.props[i].uValue
			
			if changeKV ~= nil then
				local oldValue = self:GetValue(k, 0);
				if oldValue ~= v then
					changeKV[k] = v - oldValue;
				end
			end
			
			
		
		elseif _msgPublicProperties.props[i]:HasField("szValue") then
			v = _msgPublicProperties.props[i].szValue
		elseif _msgPublicProperties.props[i]:HasField("fValue") then 
			v = _msgPublicProperties.props[i].fValue
			
			if changeKV ~= nil then
				local oldValue = self:GetValue(k, 0);
				if oldValue ~= v then
					changeKV[k] = v - oldValue;
				end
			end
		elseif _msgPublicProperties.props[i]:HasField("iValue") then
			v = _msgPublicProperties.props[i].iValue;
			
			if changeKV ~= nil then
				local oldValue = self:GetValue(k, 0);
				if oldValue ~= v then
					changeKV[k] = v - oldValue;
				end
			end
		end
		if v ~= nil then
			self.values[k] = v;
			--log("Properties set:"..k.."="..v)
		end
	end
	
	return changeKV;
	
end

