local M = {}
local utility = require("Lua.utility")
function M:New()
    local o = utility.gameObject:New("Key")
    o.sprite = love.graphics.newImage("Sprites/Key.png")
    o.sprite:setFilter("nearest")
    o.x = nil
    o.y = nil
    o.width = 16
    o.height = 16
    function o:Load()
    end

    function o:Update(dt)
        local player = utility.gameObject:Find("Player") or {}
        if utility.collision:CollisionAABB(o.x, o.y, o.width, o.height, player.x, player.y, player.width, player.height) then
            local gameCont = utility.gameObject:Find("GameCont") or {}
            gameCont.saveGame.isRedKey = true
            gameCont.KeySoundPlay()
            player.key = player.key + 1
            self:Free()
        end
    end

    function o:Draw()
        love.graphics.draw(o.sprite, o.x, o.y + math.sin(os.clock()*2)*2)
    end

    return o
end
return M