
-- ================================
-- 网络模块的一些定义
-- ================================

-- 获取网络请求对象
function NewCs(key)
    local cs = require("Proxy.Net.ClientToServer")  -- 客户端到服务器的请求模块
	local vo = cs.newCS(key)                        -- 创建请求对象

    return vo
end

local sc = require("Proxy.Net.Proto.king_data").sc:new()
-- 获取SC对象
function Sc()
    return sc;
end

function NetOutPut(tag, info)
    local tools = require("Proxy.NetBase.Utils.DataTools")-- 数据工具模块
    tools.printTable(info, "G___________________________"..tag.."______________________________M\n")
end