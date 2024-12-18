if jit then

  jit.off();
  jit.flush();
  LuaJitMode = "off"
  --据说关闭jit具有更好的稳定性，这里备注，暂时不处理
end



local luaPathLogic = LuaConst.luaDir
local luaPathBase = luaPathLogic .. "/ToLua/Lua";
local luaExName = LuaConst.luaExt

package.path = package.path .. ";?" .. luaExName ..";" .. luaPathLogic.."/Msg/?" .. luaExName .. ";" .. luaPathLogic .. "/PublicStruct/?" .. luaExName .. ";";
package.path = package.path .. luaPathLogic.."/Msg/pblua/?" .. luaExName .. ";" ..luaPathLogic.."/3rd/pbc/?" .. luaExName .. ";";
package.path = package.path .. luaPathBase.."/?"..luaExName .. ";" ..luaPathBase.."/protobuf/?"..luaExName.. ";"


--主入口函数。从这里开始lua逻辑
function Main()
	math.randomseed(os.time())
    print("Lua Main call")
end

--场景切换通知
function OnLevelWasLoaded(level)
	collectgarbage("collect")
	Time.timeSinceLevelLoad = 0
end

