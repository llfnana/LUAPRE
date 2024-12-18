require "Logic/Buff/BuffData"
BuffManager= class("BuffManager")

BuffManager.instance = nil

function BuffManager:ctor()
    self.config = {}
    self:Init()
end

function BuffManager:Inst()
    if BuffManager.Instance == nil then
        BuffManager.Instance = BuffManager:New()
    end
    return BuffManager.Instance
end

function BuffManager:Init()
    self:InitConfig()
end

---创建一条buff数据
---@param id integer buffId
---@param param table buff参数
---@param rounds integer buff持续回合数
function BuffManager:CreateBuff(id, param, rounds)
    return BuffData.New(id, param, rounds)
end

---通过buffId获取buff配置信息
---@param id integer buffId
function BuffManager:GetBuffCfgById(id)
    return clone(self.config[id])
end

function BuffManager:InitConfig()
    local tb = TbBuff
    for k, v in ipairs(tb) do
        self.config[v.ID] = v
    end
end