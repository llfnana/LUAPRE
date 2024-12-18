-----------------------------------------------
-- 文件：   Language.lua
-- 功能：   Language
-----------------------------------------------
Language = {}
Language.version = "Language 1.0"

local function dhLanguage()
    local curlanguage = PlayerModule.getLanguageList()[PlayerModule.getLanguage()].flag
    local path = 'TableExport.TbLocalizeTable'
    package.loaded[path] = nil
    local language = require(path)
    Language.languageData = {}
    for k , v in pairs(language) do
        if curlanguage == 'Cn' then
            Language.languageData[v.Key] = v.Cn
        elseif curlanguage == 'En' then
            Language.languageData[v.Key] = v.En
        elseif curlanguage == 'Id' then
            Language.languageData[v.Key] = v.Id
        end
    end
    -- local fix = ss.helper.data.checkLanguageFix(curlanguage)
    -- if fix then
    --     dump(fix, "语言补丁..............................")
    --     for k, v in pairs(fix) do
    --         Language.languageData[k] = v
    --     end
    -- end

    -- local funcPath = 'GameLang'
    -- table.merge( Language.languageData , require(funcPath)[curlanguage] )
end

local function addLang()
    -- local curlanguage = ss.helper.data.getCurLanguage()
    -- local path = 'auto.'.. curlanguage ..'.coreLanguage'
    -- Language.languageData = {}
    -- Language.languageData = require(path)['en-ww']
    -- local funcPath = 'GameLang'
    -- table.merge( Language.languageData , require(funcPath)[curlanguage] )
    dhLanguage()
end

local function reset()
    Language.languageData = {}
end

---本地化表查询输出
local function language(src, ...)
    local out = Language.languageData[src]
    if type(out) == "string" then
        local maps = {'%%d', '%%s', '%%.2f', '{0}', '{1}', '{2}', '{3}', '{4}'}
        local index = -1
        for i, v in ipairs(maps) do
            if not index or index <=0 then
                index = string.find(out, v)
            end
        end
        if index and index > 0 then
            if not pcall(string.format, out, ...) then
                return src
            end
            local oout = string.format(out, ...)
            for i, v in ipairs({ ... }) do
                oout = string.gsub(oout, "{" .. (i - 1) .. "}", v)
            end
            return oout
        else
            return out
        end
    elseif type(out) == "function" then
        return out(...)
    end
    if type(out) == "function" then
        return out(...)
    end
    return src
end

local function languageConf(src, ...)
    local out = Language.languageData[src]
    if out then
        return out
    end
    return src
end

Language.dhLanguage = dhLanguage
Language.language = language
Language.addLang = addLang
Language.reset = reset
--Language.addLangEach = addLangEach
Language.languageConf = languageConf
return Language
