

--封装一些版本适配相关特殊逻辑

VersionAdapter = {}
local this = VersionAdapter;


--比较版本号，返回1 ：_ver1 > _ver2, 返回-1： _ver1 < _ver2, 返回0： 相等
function VersionAdapter.CompareVersion( _ver1, _ver2, _cmpPos )
	_cmpPos = _cmpPos or 3;
	local verArray1 = stringsplit( _ver1, '.' )
	local verArray2 = stringsplit( _ver2, '.' )
	if verArray1 == nil or #verArray1 < _cmpPos then
		error("VersionAdapter.CompareVersion Invalid Param1");
		return -1;
	end

	if verArray2 == nil or #verArray2 < _cmpPos then
		error("VersionAdapter.CompareVersion Invalid Param2");
		return 1;
	end	

	for i = 1, _cmpPos do
		local diff = tonumber(verArray1[i]) - tonumber(verArray2[i]);
		if diff > 0 then
			return 1;
		elseif diff < 0 then
			return -1;
		end
	end
	return 0;
end

--检查是否有某个静态方法
function VersionAdapter.HasStaticMethod( _funcName )
	return Util.HasStaticMethod(_funcName);
end

--检查对象是否有某个方法
function VersionAdapter.HasObjectMethod( _obj, _funcName )
	if _obj == nil then
		return false;
	end
	return Util.HasObjectMethod(_obj, _funcName);
end

