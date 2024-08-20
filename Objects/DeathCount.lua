local M = {}
local utility = require("Lua.utility")
function M:New()
    local o = utility.gameObject:New("DeathCount")
    o.x = nil
    o.y = nil
    function o:Load()
    end

    function o:Update(dt)
    end

    function o:Draw()
        local player = utility.gameObject:Find("Player") or {}
        love.graphics.print("[Death]: " .. player.deathCount, o.x, o.y)
        love.graphics.print("[Time]: " .. math.floor(player.gameTime/3600) .. ":" .. string.format("%02d", math.floor(player.gameTime/60) % 60) .. ":" .. string.format("%02d", math.floor(player.gameTime) % 60), o.x, o.y + 20)
    end

    return o
end
return M