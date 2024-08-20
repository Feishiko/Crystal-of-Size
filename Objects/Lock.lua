local M = {}
local utility = require("Lua.utility")
function M:New()
    local o = utility.gameObject:New("Lock")
    o.x = nil
    o.y = nil
    o.width = 16
    o.height = 16
    o.sprite = love.graphics.newImage("Sprites/Door.png")
    o.sprite:setFilter("nearest")
    function o:Load()
    end

    function o:Update(dt)
    end

    function o:Draw()
        love.graphics.draw(o.sprite, o.x, o.y)
    end

    return o
end
return M