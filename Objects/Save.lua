local M = {}
local utility = require("Lua.utility")
function M:New()
    local o = utility.gameObject:New("Save")
    o.x = nil
    o.y = nil
    o.width = 10
    o.height = 2
    o.couldSave = false
    o.suckTimer = 100
    o.saveTimer = 100
    o.saveSound = love.audio.newSource("Sounds/save.wav", "static")
    function o:Load()
    end

    function o:Update(dt)
        o.dt = dt
        o.suckTimer = o.suckTimer + dt * 160
        o.saveTimer = o.saveTimer + dt * 160
        local player = utility.gameObject:Find("Player") or {}
        if utility.collision:CollisionAABB(o.x, o.y - 10, o.width, o.height, player.x, player.y, player.width, player.height) then
            o.couldSave = true
        else
            o.couldSave = false
        end
        if (o.couldSave and love.keyboard.wasPressed("up") and player.isGround) then
            o.suckTimer = 0
            o.downTimer = 0
            o.saveTimer = 0
            o.saveSound:stop()
            o.saveSound:play();
            local gameCont = utility.gameObject:Find("GameCont") or {}
            gameCont.GameSave()
        end
    end

    function o:Draw()
        for i = 0, math.min(math.floor(o.suckTimer), 10), 1 do
            love.graphics.setColor(1, 1, 1, 1 - i*.1)
            love.graphics.line(o.x, o.y - i, o.x + o.width, o.y - i)
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(o.couldSave and "Up" or "", o.x, o.y - 30)

        local saveText = "Game Saved!"
        local font = utility.gameObject:Find("GameCont").font or {}
        love.graphics.print(o.saveTimer >= 100 and "" or saveText, DrawEvent.width/2 - font:getWidth(saveText)/2, DrawEvent.height/2 - font:getHeight(saveText)/2)
    end

    return o
end
return M