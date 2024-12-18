require "Common/class"
require "Common/define"
require "Common/constdef"
require "Common/uidefine"
require "Common/cm_functions"
require "Common/uifunctions"
require "Common/bit"
require "Common/safefunc"
require "Common/versionadapter"
require "Utils/IndexPQ"
require "Proxy/Net/NetDefine"
require "Table/StrDicEnum"
require "Table/TableManager"
require "Table/CoreDataCache"
require "Table/GameConfigEnum"

UIElementBase = require "Logic/UI/UIElementBase"
function UIPanelBaseMake()
    local makeFn = require "Logic/UI/UIPanelBase"
    return makeFn()
end
UIPanelListItem = require "Logic/UI/UIPanelListItem"

require "Logic/LuaClass"
require "Logic/Event/EventDefine"
Event = require "Logic/Event/events"
require "Logic/GameStatic"
require "Logic/Common/BonusList"
 require "Logic/Data/GameStateData"
require ("Logic/Language")

JumpUtil = require "Logic/Utils/JumpUtil"
MathUtil = require "Utils/MathUtil"
GameUtil = require "Utils/GameUtil"
StringUtil = require "Utils/StringUtil"
ListUtil = require "Utils/ListUtil"
TimeUtil = require "Utils/TimeUtil"
UIUtil = require "Utils/UIUtil"
TouchUtil = require "Utils/TouchUtil"
require "Logic/General/GeneralLogic"
require "Logic/Audio/Audio"
require "Logic/Scene/SceneManager"
require "Logic/Common/GlobalBehaviour"
require "Logic/Buff/BuffManager"

---@class Bit
---@field band fun(a:number,b:number):number
---@field bor fun(a:number,b:number):number
---@field lshift fun(b:number,n:number):number
---@field rshift fun(b:number,n:number):number
bit = require "bit" ---@type Bit 二进制运算

require "Utils/TimeMgr"
GoPoolMgr = require "Logic/Pool/GoPoolMgr"
require ("Logic/Event/GlobalEventHandler")
require ("Res/resinterface")
require ("Res/resgroupinterface")
require ("Render/Layer")
require ("Logic/Data/DataClean")
require ("Res/PreloadAsset")
require ("Logic/Common/StatisticsLogEvent")
require ("Logic/Hotfix/HotfixModule")

Define = require "Logic/GameDefine"