--- 寻路优化
--- 1.找到出发点门口，寻路 (出发点, 出发点门口）
--- 2.找到目标点门口，寻路（目标点门口，目标点）
--- 3.寻路（出发点门口，目标点门口）（这部分做成缓存）

local isShort = true -- 路径简化
local PathCache = {}

--- 缓存结构
local RuntimeCache = {
    -- [4] = {
    --     ['110_178_196_123'] = {
    --         {110, 177}
    --     }
    -- }
}

local ConfigCache = {

}

--- 获取缓存 1.配置缓存，2.运行时缓存
function PathCache.GetCache(start, goal, city)
    if ConfigCache[city] == nil then 
        ConfigCache[city] = require ("Game/Logic/Path/FindPath" .. city)
    end

    local key1, key2 = PathCache.TransformKey(start, goal)
    local cells = PathCache.GetCacheInternal(ConfigCache, city, key1, key2, "Config") or PathCache.GetCacheInternal(RuntimeCache, city, key1, key2, "RunTime")
    return cells
end

function PathCache.GetCacheInternal(data, city, key1, key2, msg)
    local  cityData = data[city]
    if not cityData then 
        return nil 
    end

    local isReverse = false -- 倒序
    local pathData = cityData[key1]
    if not pathData then 
        pathData = cityData[key2]
        if not pathData then 
            return nil
        else 
            isReverse = true
        end
    end

    local cells = PathCache.TransformPositionToCell(pathData, isReverse, msg)
    if msg ~= nil and cells ~= nil then 
        -- print("[PathCache] GetCache from " .. msg, key1, key2)
    end

    return cells
end


function PathCache.AddCache(start, goal, city, path)
    local cityData = RuntimeCache[city]
    local key1, _ = PathCache.TransformKey(start, goal)
    if not cityData then 
        cityData = {}
        RuntimeCache[city] = cityData
    end

    local postions = PathCache.TransformCellToPosistion(path)
    cityData[key1] = postions

    return postions
end

-- 将格子路径转化为可缓存路径点
function PathCache.TransformCellToPosistion(cell)
    local positions = {}
    for index, value in ipairs(cell) do
        table.insert(positions, {value.position.x, value.position.y})
    end
    return positions
end

-- 将缓存路径点转化为格子路径
function PathCache.TransformPositionToCell(path, isReverse, msg)
    if not path then 
        return nil
    end

    local tempPath = {}
    if isShort then 
        for _, value in ipairs(path) do
            local dir = value[3]
            if dir then 
                -- 196, 164
                if dir == 1 or dir == 2 then 
                    table.insert(tempPath, {value[1], value[2]})
                    local count = (dir == 1) and (value[1]- value[4]) or (value[4] - value[1])
                    for i = 1, count, 1 do
                        table.insert(tempPath, {value[1] + ((dir == 1) and -1 or 1) * i, value[2]})
                    end
                elseif dir == 3 or dir == 4 then 
                    table.insert(tempPath, {value[1], value[2]})
                    local count = (dir == 3) and (value[2]- value[4]) or (value[4] - value[2])
                    for i = 1, count, 1 do
                        table.insert(tempPath, {value[1], value[2] + ((dir == 3) and -1 or 1) * i})
                    end
                end
            else
                table.insert(tempPath, value) 
            end
        end
    else
        tempPath = path
    end

    if msg ~= nil then 
        -- print("[PathCache] GetCache tempPath = " .. ListUtil.dump(tempPath))
    end

    local cells = {}
    if isReverse == false then 
        for index, value in ipairs(tempPath) do
            local cell = Utils.GetCell(value[1], value[2])
            table.insert(cells, cell)
        end
    else
        for i = #tempPath, 1, -1 do
            local value = tempPath[i]
            local cell = Utils.GetCell(value[1], value[2])
            table.insert(cells, cell)
        end
    end

    return cells
end

function PathCache.TransformKey(start, goal)
    local key1 = start.position.x .. "_" .. start.position.y .. "_" .. goal.position.x .. "_" .. goal.position.y
    local key2 = goal.position.x .. "_" .. goal.position.y .. "_" .. start.position.x .. "_" .. start.position.y
    return key1, key2
end

--- 在编辑器模式下，将运行时缓存路径转化为配置文件 
function PathCache.WritePath(cache)
    if not cache then 
        cache = RuntimeCache
    end
    for city, cityData in pairs(RuntimeCache) do
        local content = "return {"
        for key, pathData in pairs(cityData) do
            local pathStr = ""
            if isShort then 
                -- 直线：优化数据存储
                local x, y, dir, eValue 
                for index, value in ipairs(pathData) do
                    if x == nil then 
                        x = value[1]
                        y = value[2]
                    end

                    local nextValue = pathData[index+1]
                    if nextValue ~= nil then 
                        local nextDir = PathCache.CheckLine(value, nextValue)
                        if dir ~= nil then 
                            -- 直线结束 (不是直线或方向发生改变)
                            if nextDir == -1 or nextDir ~= dir then 
                                eValue = PathCache.GetLineEndValue(value, dir)
                                pathStr = pathStr .. PathCache.KVPairFormat2(PathCache.PositionFormat({x, y}, dir, eValue), 2)
                                x = nil
                                y = nil
                                dir = nil
                                eValue = nil
                            end
                        else
                            if nextDir == -1 then 
                                pathStr = pathStr .. PathCache.KVPairFormat2(PathCache.PositionFormat(value), 2)
                                x = nil
                                y = nil
                                dir = nil
                                eValue = nil
                            else 
                                dir = nextDir
                            end
                        end
                    else
                        -- 路径结束
                        if dir ~= nil then 
                            eValue = PathCache.GetLineEndValue(value, dir)
                            pathStr = pathStr .. PathCache.KVPairFormat2(PathCache.PositionFormat({x, y}, dir, eValue), 2)
                        else
                            pathStr = pathStr .. PathCache.KVPairFormat2(PathCache.PositionFormat(value), 2)
                        end 
                        x = nil
                        y = nil
                        dir = nil
                        eValue = nil
                    end
                end
            else
                for index, value in ipairs(pathData) do
                    pathStr = pathStr .. PathCache.KVPairFormat2(PathCache.PositionFormat(value), 2)
                end
            end
            content = content .. PathCache.KVPairFormat(key, pathStr, true, 1)
        end
        -- 每个城市写成一个文件
        content = content .. "}"
        PathCache.WriteFile(city, content)
    end
end

--- 格式化键值对
--- @param key any
--- @param value any
--- @param isKeyStr any key是否为字会串
--- @param tabDepth any
--- @return unknown
function PathCache.KVPairFormat(key, value, isKeyStr, tabDepth)
    local tabSpace = PathCache.GetTabSpace(tabDepth)
    if isKeyStr then 
        return  "\n" .. tabSpace .. "['" .. key .. "']" .. "={" .. value .. "\n".. tabSpace .. "},"
    end

    return  "\n" .. tabSpace .. "[" .. key .. "]" .. "={" .. value .. "\n" .. tabSpace .. "},"
end

--- 格式化键值对，key是连续的数值，所以不需要显示key
--- @param value any
--- @param tabDepth any
--- @return unknown
function PathCache.KVPairFormat2(value, tabDepth)
    local tabSpace = PathCache.GetTabSpace(tabDepth)
    return  "\n" .. tabSpace .. "{" .. value .. "},"
end

--- 直线判断
--- @param value any 当前坐标
--- @param nextValue any 下一坐标
--- @return integer 方向值，-1 表示不是直线或直接直线结束 dir = x-:1, x+:2, y-:3, y+:4
function PathCache.CheckLine(value, nextValue)
    if value[1] == nextValue[1] then 
        if value[2] > nextValue[2] then 
            return 3
        end
        return 4
    end

    if value[2] == nextValue[2] then 
        if value[1] > nextValue[1] then 
            return 1
        end
        return 2
    end

    return -1
end

--- 返回直线的结束值（x还是y，取决于 dir）
--- @param value any
--- @param dir any
function PathCache.GetLineEndValue(value, dir)
    if dir == 1 or dir == 2 then 
        return value[1]
    elseif dir == 3 or dir == 4 then
        return value[2]
    end
end

--- 获取格式化 Tab
--- @param depth any tab 深度
--- @return string
function PathCache.GetTabSpace(depth)
    local space = ""
    if depth then 
        if depth == 1 then 
            space = "\t"
        elseif depth == 2 then 
            space = "\t\t"
        elseif depth == 3 then 
            space = "\t\t\t"
        elseif depth == 4 then 
            space = "\t\t\t\t"
        elseif depth == 5 then 
            space = "\t\t\t\t\t"
        end
    end
    return space
end

--- 坐标格式
--- @param value any 当前坐标
--- @param dir any  方向，x-:1, x+:2, y-:3, y+:4
--- @param eValue any 直线结束的坐标点（x还是y取决于dir）
--- @return unknown 格式化后的坐标
function PathCache.PositionFormat(value, dir, eValue)
    local conetnt = value[1] .. ", " .. value[2]
    if dir then 
        conetnt = conetnt .. ", " .. dir .. ", " .. eValue
    end
    return conetnt
end

--- 写入本地文件
--- @param city any
--- @param content any
function PathCache.WriteFile(city, content)
    local file, err = io.open("FindPath/FindPath".. city .. ".lua", "w") -- "w" 表示写入模式，如果文件不存在将创建文件
    if not file then
        print("打开文件时出错：", err)
        return
    end
    
    -- 写入内容
    file:write(content)
    
    -- 关闭文件
    file:close()
end

return PathCache