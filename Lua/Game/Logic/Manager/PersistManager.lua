PersistManager = {}
PersistManager._name = "PersistManager"
local this = PersistManager

-- 本地数据保存，用于保存缓存数据等不怕丢失的数据，只存本地不存服务器
function PersistManager.Init()
    this.data = {}
    local js = PlayerPrefs.GetString(this.Key())
    
    if js ~= "" then
        this.data = JSON.decode(js)
    end
end

function PersistManager.Key()
    return DataManager.Key2Prefs("Persist")
end

function PersistManager.Get(key)
    return this.data[key]
end

function PersistManager.Set(key, value)
    this.data[key] = value
    this.SaveData()
end

function PersistManager.SaveData()
    PlayerPrefs.SetString(this.Key(), JSON.encode(this.data))
end

function PersistManager.ClearData()
    this.data = {}
    this.SaveData()
end
