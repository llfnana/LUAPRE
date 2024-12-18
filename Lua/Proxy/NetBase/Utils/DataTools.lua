local tools = {}

-- log输出格式化
local function logPrint(str)
    str = os.date("\nLog output date: %Y-%m-%d %H:%M:%S \n", os.time()) .. str
    print(str)
end
 
-- key值格式化
local function formatKey(key)
    local t = type(key)
    if t == "number" then
        return "["..key.."]"
    elseif t == "string" then
        local n = tonumber(key)
        if n then
            return "["..key.."]"
        end
    end
    return key
end
 
-- 栈
local function newStack()
    local stack = {
        tableList = {}
    }
    function stack:push(t)
        table.insert(self.tableList, t)
    end
    function stack:pop()
        return table.remove(self.tableList)
    end
    function stack:contains(t)
        for _, v in ipairs(self.tableList) do
            if v == t then
                return true
            end
        end
        return false
    end
    return stack
end

-- 输出打印table表 函数
function tools.printTable(tb, tag)
    local args = {tb}
    for k, v in pairs(args) do
        local root = v
        if type(root) == "table" then
            local temp = {
                tag,
                "------------------------ printTable start ------------------------\n",
                "local tableValue".." = {\n",
            }
            local stack = newStack()
            local function table2String(t, depth)
                stack:push(t)
                if type(depth) == "number" then
                    depth = depth + 1
                else
                    depth = 1
                end
                local indent = ""
                for i=1, depth do
                    indent = indent .. "    "
                end
                for k, v in pairs(t) do
                    local key = tostring(k)
                    local typeV = type(v)
                    if typeV == "table" then
                        if key ~= "__valuePrototype" then
                            if stack:contains(v) then
                                table.insert(temp, indent..formatKey(key).." = {检测到循环引用!},\n")
                            else
                                table.insert(temp, indent..formatKey(key).." = {\n")
                                table2String(v, depth)
                                table.insert(temp, indent.."},\n")
                            end
                        end
                    elseif typeV == "string" then
                        table.insert(temp, string.format("%s%s = \"%s\",\n", indent, formatKey(key), tostring(v)))
                    else
                        table.insert(temp, string.format("%s%s = %s,\n", indent, formatKey(key), tostring(v)))
                    end
                end
                stack:pop()
            end
            table2String(root)
            table.insert(temp, "}\n------------------------- printTable end -------------------------")
            print(table.concat(temp))
        else
            print("----------------------- printString start ------------------------\n"
                 .. tostring(root) .. "\n------------------------ printString end -------------------------")
        end
    end
end

function tools.encryptTime(ts)
    if ts < 100 then
        ts = os.time()
    end
    local rand = math.random(1, 3) -- 位移数
    local codeRand = math.random(1, 9) -- 替换规则索引
    local codeArr = { -- 替换规则
        { 'u', 't', 'k', 'q', 'a', 'b', 'r', 'e', 'i', 'w' },
        { 'q', 'a', 'y', 'm', 'x', 'n', 'b', 'w', 'h', 'l' },
        { 'p', 'h', 'e', 'z', 'f', 'k', 'n', 'r', 'w', 's' },
        { 'g', 'c', 'f', 'a', 'm', 'i', 'v', 'h', 'b', 'x' },
        { 'h', 'w', 'y', 'j', 'f', 'p', 'e', 'v', 'r', 'a' },
        { 'b', 'w', 'x', 's', 'g', 'u', 'y', 'p', 'k', 'l' },
        { 'l', 'c', 'y', 'x', 'g', 'o', 'v', 's', 'p', 'd' },
        { 'o', 'a', 'm', 'j', 'k', 'r', 'i', 'v', 'e', 'x' },
        { 't', 'r', 'm', 'z', 's', 'n', 'c', 'j', 'i', 'b' }
    }
    local cTime = string.sub(tostring(ts), 3) --第三位开始取服务器时间
    local ltime = bit.lshift(tonumber(cTime), rand) -- 左位移
    local atime = rand .. ltime -- 位移数和位移后的时间拼接
    local cipher = "" -- 加密串
    local len = #atime
    for i = 1, len do
        local index = tonumber(string.sub(atime, i, i)) + 1 --获取每个字符的索引
        local s = codeArr[codeRand][index] -- 单个字符加密值
        cipher = cipher .. s
    end
    return codeRand .. cipher
end

function tools.encryptData(info, mse)
    -- 替换规则
    local codeArr = {
        { ["W"] = "(", ["L"] = ".", ["k"] = "`", ["S"] = "*", ["D"] = "$", ["y"] = "_", ["C"] = ")", ["g"] = "@", ["X"] = "?", ["F"] = "<", ["1"] = ",", ["I"] = "#", ["x"] = "^", ["t"] = "-", ["Y"] = "&", ["V"] = ">", ["P"] = "|", ["a"] = "!", ["n"] = ";", ["6"] = "%" },
        { ["s"] = ">", ["9"] = ",", ["k"] = "!", ["J"] = "%", ["2"] = "(", ["U"] = ".", ["y"] = "*", ["C"] = "|", ["x"] = "^", ["3"] = "?", ["u"] = "_", ["M"] = "$", ["Z"] = "<", ["w"] = "@", ["b"] = ";", ["t"] = ")", ["N"] = "&", ["j"] = "`", ["g"] = "-", ["P"] = "#" },
        { ["z"] = "|", ["Q"] = "_", ["1"] = "!", ["B"] = ")", ["N"] = "*", ["e"] = "&", ["q"] = "(", ["p"] = "$", ["H"] = ";", ["u"] = "-", ["0"] = "#", ["c"] = ".", ["h"] = "`", ["7"] = ">", ["g"] = ",", ["A"] = "@", ["i"] = "<", ["d"] = "%", ["C"] = "^", ["F"] = "?" },
        { ["f"] = "`", ["L"] = "#", ["o"] = "%", ["U"] = "!", ["a"] = "?", ["R"] = ">", ["j"] = "*", ["="] = "$", ["h"] = ",", ["Y"] = "-", ["K"] = "@", ["C"] = "<", ["1"] = ".", ["i"] = "^", ["B"] = "&", ["w"] = "(", ["v"] = "|", ["u"] = "_", ["F"] = ";", ["d"] = ")" },
        { ["J"] = ",", ["f"] = "#", ["2"] = ";", ["C"] = "$", ["k"] = "|", ["u"] = ")", ["e"] = "?", ["="] = ".", ["5"] = "^", ["G"] = "_", ["w"] = "!", ["X"] = "(", ["8"] = "<", ["K"] = ">", ["v"] = "`", ["A"] = "%", ["O"] = "&", ["T"] = "-", ["l"] = "@", ["H"] = "*" },
        { ["y"] = "|", ["1"] = "!", ["u"] = "%", ["j"] = "&", ["d"] = "(", ["G"] = ";", ["R"] = "-", ["V"] = ".", ["8"] = "<", ["k"] = "#", ["E"] = "_", ["3"] = "^", ["K"] = "@", ["L"] = "*", ["Z"] = "`", ["W"] = ",", ["="] = ")", ["T"] = "$", ["Q"] = ">", ["l"] = "?" },
        { ["D"] = "?", ["q"] = ".", ["C"] = "<", ["1"] = ">", ["e"] = "#", ["6"] = "&", ["k"] = "!", ["3"] = "|", ["t"] = ",", ["="] = "(", ["S"] = "_", ["a"] = "$", ["h"] = "-", ["n"] = "%", ["X"] = ";", ["m"] = "^", ["u"] = ")", ["H"] = "`", ["x"] = "@", ["l"] = "*" },
        { ["R"] = "_", ["k"] = "-", ["9"] = "#", ["F"] = "*", ["d"] = "?", ["P"] = ">", ["K"] = "!", ["6"] = "(", ["Z"] = "$", ["r"] = ",", ["z"] = "@", ["t"] = ".", ["S"] = ")", ["j"] = "<", ["x"] = "|", ["8"] = "&", ["I"] = "%", ["b"] = "^", ["D"] = ";", ["0"] = "`" },
        { ["x"] = "*", ["Y"] = "%", ["f"] = "<", ["N"] = ".", ["o"] = "^", ["k"] = ")", ["t"] = "@", ["z"] = "`", ["+"] = "#", ["m"] = ">", ["S"] = ",", ["Q"] = ";", ["="] = "(", ["i"] = "-", ["h"] = "$", ["T"] = "!", ["L"] = "|", ["r"] = "?", ["V"] = "&", ["s"] = "_" },
        { ["k"] = ">", ["G"] = "^", ["8"] = "|", ["U"] = ";", ["W"] = "!", ["m"] = "#", ["L"] = "`", ["N"] = "-", ["r"] = "$", ["V"] = "(", ["w"] = "&", ["n"] = "@", ["+"] = "*", ["y"] = "_", ["0"] = ")", ["P"] = ".", ["j"] = "%", ["z"] = "<", ["v"] = ",", ["c"] = "?" },
        { ["D"] = ">", ["W"] = "|", ["4"] = "#", ["i"] = ";", ["l"] = "$", ["S"] = "^", ["1"] = "-", ["7"] = "%", ["I"] = "<", ["2"] = "(", ["Z"] = "@", ["0"] = "?", ["J"] = ")", ["e"] = "!", ["f"] = ",", ["w"] = "_", ["Y"] = ".", ["O"] = "&", ["h"] = "*", ["z"] = "`" },
        { ["s"] = ">", ["D"] = "?", ["="] = "@", ["R"] = "!", ["H"] = "&", ["L"] = "`", ["h"] = ",", ["i"] = "^", ["f"] = "|", ["V"] = "#", ["c"] = "(", ["Z"] = "_", ["d"] = "%", ["g"] = "*", ["b"] = ".", ["7"] = ")", ["8"] = "$", ["p"] = "<", ["k"] = "-", ["T"] = ";" },
        { ["Y"] = "?", ["e"] = "-", ["f"] = "%", ["H"] = "#", ["F"] = "`", ["c"] = "$", ["s"] = "@", ["Q"] = ",", ["z"] = "^", ["L"] = "*", ["W"] = "!", ["T"] = ")", ["9"] = "_", ["2"] = "|", ["r"] = "(", ["="] = ".", ["G"] = "<", ["y"] = ";", ["8"] = "&", ["4"] = ">" },
        { ["V"] = "^", ["6"] = "$", ["5"] = "-", ["n"] = "%", ["O"] = "<", ["u"] = "*", ["a"] = "_", ["r"] = "(", ["M"] = "#", ["S"] = "!", ["i"] = "`", ["P"] = ",", ["1"] = ">", ["K"] = "@", ["Z"] = ")", ["h"] = ";", ["2"] = ".", ["E"] = "|", ["m"] = "?", ["8"] = "&" },
        { ["5"] = "*", ["t"] = "#", ["b"] = ")", ["u"] = ">", ["V"] = "$", ["h"] = "@", ["S"] = "`", ["2"] = ".", ["s"] = ";", ["W"] = "!", ["M"] = ",", ["X"] = "_", ["Z"] = "%", ["m"] = "&", ["7"] = "|", ["v"] = "^", ["E"] = "(", ["0"] = "?", ["d"] = "<", ["3"] = "-" },
        { ["1"] = "%", ["F"] = "@", ["X"] = ";", ["5"] = "&", ["h"] = "|", ["V"] = "`", ["l"] = "$", ["7"] = "#", ["O"] = "_", ["D"] = "*", ["Q"] = "!", ["j"] = "(", ["H"] = "-", ["c"] = ")", ["="] = "^", ["8"] = ".", ["r"] = ">", ["9"] = ",", ["R"] = "<", ["E"] = "?" },
        { ["8"] = "&", ["A"] = ")", ["q"] = ".", ["a"] = "*", ["="] = "#", ["7"] = "^", ["S"] = "$", ["Z"] = ",", ["k"] = "?", ["L"] = "!", ["v"] = "<", ["Y"] = ">", ["w"] = "`", ["n"] = "(", ["p"] = ";", ["h"] = "|", ["t"] = "%", ["+"] = "_", ["U"] = "-", ["X"] = "@" },
        { ["U"] = ">", ["+"] = "@", ["T"] = "^", ["q"] = "%", ["t"] = "_", ["g"] = "#", ["Q"] = ",", ["K"] = "`", ["c"] = "$", ["F"] = "!", ["e"] = "&", ["x"] = "|", ["u"] = ".", ["a"] = ")", ["5"] = "(", ["X"] = "?", ["1"] = "<", ["s"] = ";", ["4"] = "-", ["V"] = "*" },
        { ["R"] = "?", ["Q"] = "^", ["f"] = ")", ["I"] = "&", ["O"] = "@", ["l"] = "#", ["A"] = "!", ["M"] = ",", ["E"] = "|", ["G"] = "_", ["q"] = "(", ["7"] = ".", ["S"] = "<", ["a"] = "*", ["d"] = "`", ["o"] = ">", ["e"] = "-", ["h"] = "$", ["H"] = "%", ["N"] = ";" },
        { ["H"] = ",", ["Z"] = ";", ["P"] = "$", ["N"] = "@", ["k"] = "%", ["z"] = ".", ["d"] = ">", ["m"] = "(", ["O"] = "-", ["w"] = "`", ["y"] = "&", ["c"] = "_", ["u"] = "|", ["n"] = "^", ["b"] = "<", ["+"] = ")", ["7"] = "#", ["h"] = "?", ["i"] = "!", ["W"] = "*" }
    }

    local codeNumArr = { "!", "a", "_", "Z", "#", "H", "$", "j", "%", "S", "(", "k", ")", "U", "&", "V", ",", "9", "*", "l" }
    local codeNumXArr = { "q", "w", "r", "d", "g" }

    local data = string.sub(info, 2, #info - 1) -- 去掉头部“{”尾部“}”
    local base64Str = mime.b64(data) --Base64编码
    tools.debugShow("base64Str", base64Str)
    local len = #base64Str
    --头部
    local codeXRand = math.random(1, 5) -- 获取头部替换规则id
    if len < 5 then
        codeXRand = 1
    end
    local xStr = "" -- 头部随机字符串
    for i = 1, codeXRand do
        local randId = math.random(1, len)
        local s = string.sub(base64Str, randId, randId) -- 单个字符加密值
        xStr = xStr .. s
    end
    local xCode = codeNumXArr[codeXRand] -- 头部替换规则标识

    --base64
    local encodeStr = ""
    local codeRand = math.random(1, 20) -- 获取替换规则id
    local randCodeArr = codeArr[codeRand]-- 替换规则

    for i = 1, len do
        local s = string.sub(base64Str, i, i) -- 单个字符加密值
        if randCodeArr[s] then
            s = randCodeArr[s]
        end
        encodeStr = encodeStr .. s
    end
    local nCode = codeNumArr[codeRand]-- 主体替换规则标识
    --头部插入x混淆码，尾部插入第N种兑换码标识符

    if mse == 2 then
        -- 加密字符串key：token(头8位) + 秘钥 + x码 + n码 + uid
        local parm1 = #king.serverinfo.token > 8 and string.sub(king.serverinfo.token, 1, 8) or ""
        local parm2 = "MTc4bDA5NTE"
        local parm3 = xStr
        local parm4 = nCode
        local parm5 = xCode
        local parm6 = king.serverinfo.uid
        local mdStr = parm1 .. parm2 .. parm3 .. parm4 .. parm5 .. parm6--加密字符串key
        tools.debugShow("mdStr", mdStr)
        local keyLen = #mdStr
        local chrStr = ""

        for m = 1, len do
            local s1 = string.sub(encodeStr, m, m) -- encodeStr单个字符
            local n = (m - 1) % keyLen + 1
            local s2 = string.sub(mdStr, n, n) -- mdStr单个字符
            local perStr = string.char(bit.bxor(string.byte(s1), string.byte(s2)))--s1,s2分别取ASCII进行异或处理，再还原为字符
            chrStr = chrStr .. perStr
        end
        encodeStr = chrStr
    end

    local encodeTotal = xStr .. encodeStr .. xCode .. nCode
    tools.debugShow("encodeTotal", encodeTotal)

    return encodeTotal
end

return tools