local INT_BYTE_VAL = { 16777216, 65536, 256, 1 }
local STATUS_ALREADY_CONNECTED = "already connected"
local STATUS_TIMEOUT = "timeout"
local STATUS_CLOSE = "closed"
local HEAD_SIZE = 4

local function init(zeromvc)
    if zeromvc.Timer == nil then
        require("zeromvc.Timer")(zeromvc)
    end
    if zeromvc.ZeroSocket ~= nil then
        return
    end
    local ZeroSocket = zeromvc.createClass("ZeroSocket")

    function ZeroSocket:ctor(prototype, headSize, receiveHd, msgHd)
        require "socket"
        self.saveDate = ""
        self.msgHd = msgHd
        local function timerHd()
            local __body, __status, __partial = self.tcp:receive("*a") --用*a 不丢包
            if __status == STATUS_CLOSE then
                self:msgHd(false, STATUS_CLOSE)
                self.isConnect = false
                self._loadTimer:stop()
            else
                local data = (__body or __partial or "") .. self.saveDate
                local dateLen = #data
                if dateLen > 0 then
                    if dateLen > headSize then
                        local len1, len2, len3, len4 = string.byte(data, 1, headSize)
                        local len = len1 * INT_BYTE_VAL[1] + len2 * INT_BYTE_VAL[2] + len3 * INT_BYTE_VAL[3] + len4 + headSize
                        if dateLen == len then
                            self.saveDate = ""
                            receiveHd(self, string.sub(data, 5, -1))
                        elseif dateLen > len then
                            receiveHd(self, string.sub(data, 5, len))
                            self.saveDate = string.sub(data, len + 1, -1)
                        else
                            self.saveDate = data
                            print("正常出现断包")
                        end
                    else
                        print("小小包!可能不出现")
                        self.saveDate = data
                    end
                end
            end
        end

        self._loadTimer = zeromvc.Timer:new(1000 / 60, 0, timerHd)
    end

    function ZeroSocket:connect(host, port)
        local succ, status
        if not self.isConnect then
            self.tcp = socket.tcp()
            self.host = host
            self.port = port
            self.tcp:settimeout(100)
            succ, status = self.tcp:connect(self.host, self.port)
            self.tcp:settimeout(0)
            self.isConnect = (succ == 1 or status == STATUS_ALREADY_CONNECTED)
            if self.isConnect then
                self._loadTimer:play()
            end
        end
        self:msgHd(succ == 1, status)
        return self.isConnect
    end

    function ZeroSocket:disconnect()
        if self.isConnect then
            self.isConnect = false
            --            self.tcp:disconnect() --?
            self.tcp:close() --?
            self._loadTimer:stop()
        end
    end

    function ZeroSocket:send(data)
        local num = #data
        if num > 0 then
            if self.isConnect then
                local head = ""
                local res
                for i = 1, HEAD_SIZE do
                    res = math.floor(num / INT_BYTE_VAL[i])
                    num = num - res * INT_BYTE_VAL[i]
                    head = head .. string.char(res)
                end
                self.tcp:send(head .. data)
            end
        end
    end

    zeromvc.ZeroSocket = ZeroSocket
    zeromvc.Socket = ZeroSocket
    return ZeroSocket
end

return init