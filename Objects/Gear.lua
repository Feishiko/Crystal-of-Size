local M = {}
local utility = require("Lua.utility")
function M:New()
    local o = utility.gameObject:New("Gear")
    o.x = nil
    o.y = nil
    o.width = 16
    o.height = 16
    o.sprite = love.graphics.newImage("Sprites/Gear.png")
    function o:Load()
    end

    function o:Update(dt)
        local player = utility.gameObject:Find("Player") or {}
        if utility.collision:CollisionAABB(o.x, o.y, o.width, o.height, player.x, player.y, player.width, player.height) then
            player.isGrowth = not player.isGrowth
            self:Free()
        end
    end

    function o:Draw()
        love.graphics.push()
        love.graphics.translate(o.x + 8, o.y + 8)
        love.graphics.rotate(os.clock())
        love.graphics.draw(o.sprite, -8, -8)
        love.graphics.pop()
    end

    return o
end
return M