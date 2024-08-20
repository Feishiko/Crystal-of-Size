local M = {}
local utility = require("Lua.utility")
function M:New()
    local o = utility.gameObject:New("NeedleUp")
    o.sprite = love.graphics.newImage("Sprites/Needle-Up.png")
    o.sprite:setFilter("nearest")
    o.x = nil
    o.y = nil
    o.width = 4
    o.height = 4
    function o:Load()
    end

    function o:Update(dt)
        local player = utility.gameObject:Find("Player") or {}
        if (utility.collision:CollisionAABB(o.x + 2, o.y + 2, o.width, o.height, player.x, player.y, player.width, player.height)) then
            local gameCont = utility.gameObject:Find("GameCont") or {}
            gameCont.Death()
        end
    end

    function o:Draw()
        love.graphics.draw(o.sprite, o.x, o.y)
    end

    return o
end
return M