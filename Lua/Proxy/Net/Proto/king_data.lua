local data = require("Proxy.NetBase.Data.Data")
----------------------------SplitByYuki---------------------------------

local function GetKingDataRequire(flag, inputTarget)
    local makerSC = {}
    local makerCS = {}
    makerSC = require("Proxy.Net.Proto.king_sc_data")
    makerCS = flag and require("Proxy.Net.Proto.king_cs_data")
    return makerSC, makerCS
end

local makerSC, makerCS = GetKingDataRequire(true)
local king = {}
king.sc = {}
king.sc.new = function ()
	return makerSC.SCT_SC_NEW()
end

king.cs = {}
king.cs.new = function (key)
	return makerCS.CST_CS(key)
end

king.metaType = data.metaType
king.TYPE = data.TYPE
return king
