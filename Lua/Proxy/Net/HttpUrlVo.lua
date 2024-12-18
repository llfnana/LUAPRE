local __VO = {}
local function newVO(prototype, url)
    ---@class HttpUrlVo http请求数据结构
    local obj = {}
    obj.tag = ""
    obj.contentType = "json"
    obj.method = "POST"
    obj.url = url or ""
    obj.data = ""
    obj.notShowItem = false --是否不显示道具获得
    obj.info = nil --请求信息
    obj.requestHeaders = {}
    obj.beforeFn = {}
    obj.behindFn = {}
    ---@param self HttpUrlVo
    obj.hasInfo = function(self, key)
        local paths = string.split(key, ".")
        local info = self.info or {}
        for _, path in ipairs(paths) do
            if rawget(info, path) == nil then
                return false
            end
            -- if info[path] == nil then
            --     return false
            -- end
            info = info[path]
        end

        return true
    end
    ---@return string 返回请求的url
    obj.getInfoPath = function(self)
        local path = ''
        local info = self.info or {}

        for i=1, 2 do --嵌套最多两层
            if not GameUtil.isTable(info) then
                break
            end
            local key = next(info)
            if key == nil then
                break
            end
            if i ~= 1 then
                path = path .. "."
            end

            path = path .. key
            info = info[key]
        end

        return path
    end

    return obj
end

-- 获取UrlVo构造
local function getUrlVo()
    local urlVo = newVO()
    return urlVo
end

__VO.new = newVO
__VO.getUrlVo = getUrlVo
return __VO