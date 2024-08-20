local M = {}
local utility = require("Lua.utility")
function M:New()
    local o = utility.gameObject:New("Text")
    o.timer = 0
    o.x = nil
    o.y = nil
    o.string = ""
    function o:Load()
    end

    function o:Update(dt)
        o.timer = o.timer + dt * 160
    end

    function o:Draw()
        love.graphics.setColor(1, 1, 1, math.min(o.timer/200, 1))
        love.graphics.printf(o.string, o.x - 10 + math.min(o.timer/5, 10), o.y, DrawEvent.width - o.x)
        love.graphics.setColor(1, 1, 1)
    end

    return o
end
return M