
---@class Pool 池对象
local Pool = class('Pool')

---@param createObj fun():any 创建对象函数
---@param size number 池大小
function Pool:ctor(createObj, size)
    self.createObj = createObj

    --self.freeObjects = {}
    self.map = {} ---@type table<any, boolean> 对象是否空闲
    self.size = size or 16 --池大小（-1表示无限大）
    self._curSize = 0 --当前大小

    --for _ = 1, self.size do
    --    table.insert(self.freeObjects, createObj())
    --end
end

function Pool:get()
    local obj = nil
    for k, v in pairs(self.map) do
        if v == true then
            obj = k
            break
        end
    end

    if obj == nil then
        obj = self.createObj()
        self._curSize = self._curSize + 1
    end
    self.map[obj] = false

    return obj
end

---释放对象
function Pool:free(obj)
    if obj == nil or self.map[obj] == nil then
        Log.error('An object to be freed cause error')
        return
    end

    if self._curSize < self.size or self.size == -1 then --入池
        self.map[obj] = true
    else --池满
        self:destroy(obj)
    end

    --if obj.reset then --执行obj的reset方法
    --    obj.reset()
    --end
end

---@private
function Pool:destroy(obj)
    self.map[obj] = nil
    self._curSize = self._curSize - 1
end

function Pool:clear()
    for k in pairs(self.map) do
        self:destroy(k)
    end
    --self.map = {}
    --self._curSize = 0
end

return Pool