BuffData = class("BuffData")

function BuffData:ctor(id, param, round)
    self.id = id
    self.param = param
    self.rounds = round
    -- self.infinity = infinity or false
    -- self.level = 0
end