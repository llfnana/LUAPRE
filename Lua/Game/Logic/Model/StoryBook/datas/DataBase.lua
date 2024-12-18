---@class DataBase
DataBase = {
    ---@type string id
    id = "",
    ---@type string behavior
    behavior = "",
    ---@type string type
    type = "",
    ---@type number city_id
    city_id = 0,
    ---@type string param_index
    param_index = "",
    ---@type string next
    next = "",
    ---@type table<string, string> p1
    p1 = {},
    ---@type table<string, string>[] p2
    p2 = {},
}
DataBase.__cname = "DataBase"

---@return DataBase
function DataBase:Create()
    return Clone(self)
end