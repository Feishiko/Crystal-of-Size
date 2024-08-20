local M = {}
local utility = require("Lua.utility")
local json = require("Lua.json")
function M:New()
    local o = utility.gameObject:New("GameCont")
    o.collision = {}
    o.keep = true
    o.saveGame = {}
    o.saveGame.x = 30
    o.saveGame.y = 80
    o.saveGame.roomID = 1
    o.saveGame.isGrowth = nil
    o.saveGame.isRedKey = false
    o.saveGame.isGreenKey = false
    o.saveGame.key = 0
    o.saveGame.isLock = {}
    o.saveGame.isLock[1] = false
    o.saveGame.isLock[2] = false
    o.saveGame.deathCount = 0
    o.saveGame.gameTime = 0
    o.font = love.graphics.setNewFont("Fonts/fusion-pixel-10px-monospaced-latin.ttf", 10)
    o.font:setFilter("nearest", "nearest")

    o.deathTimer = 0
    o.isDead = false
    o.fadeTimer = 0
    o.isFade = false

    o.deathSound = love.audio.newSource("Sounds/DEATH.wav", "static")
    o.keySound = love.audio.newSource("Sounds/key.wav", "static")

    o.zIndex = 100
    function o:Load()
    end

    function o:Update(dt)
        o.deathTimer = o.deathTimer + (o.isDead and dt * 160 or 0)
        if o.deathTimer > 50 then
            local player = utility.gameObject:Find("Player")
            player.isDead = false
            o:GameLoad()
            o.isFade = true
            o.isDead = false
            o.deathTimer = 0
        end
        o.fadeTimer = o.fadeTimer + (o.isFade and dt * 160 or 0)
        if o.fadeTimer > 50 then
            o.fadeTimer = 0
            o.isFade = false
        end
    end

    function o:Draw()
        love.graphics.setColor(1, 1, 1, 0)
        if o.isFade then
            love.graphics.setColor(1, 1, 1, 1 - o.fadeTimer / 50)
        end
        if o.isDead then
            love.graphics.setColor(1, 1, 1, o.deathTimer / 50)
        end
        love.graphics.rectangle("fill", 0, 0, DrawEvent.width, DrawEvent.height)
        love.graphics.setColor(1, 1, 1)
    end

    function o:GameSave()
        local player = utility.gameObject:Find("Player") or {}
        o.saveGame.x = player.x
        o.saveGame.y = player.y
        o.saveGame.isGrowth = player.isGrowth
        o.saveGame.key = player.key
        o.saveGame.roomID = ldtk:getCurrent()
        o.saveGame.deathCount = player.deathCount
        o.saveGame.gameTime = player.gameTime
        local text = json.encode(o.saveGame)
        if (not love.filesystem.getInfo("savefile")) then
            love.filesystem.newFile("savefile")
        end
        love.filesystem.write("savefile", text)
    end

    function o:GameLoad()
        local player = utility.gameObject:Find("Player") or {}
        if love.filesystem.getInfo("savefile") then
            local text = love.filesystem.read("savefile")
            o.saveGame = json.decode(text)
        end
        player.x = o.saveGame.x
        player.y = o.saveGame.y
        player.isGround = true
        player.isGrowth = o.saveGame.isGrowth
        player.key = o.saveGame.key
        player.isGround = false
        player.isJump = false
        player.isRun = false
        player.isDrop = true
        player.dropTimer = 0
        player.jumpTimer = 0
        player.gameTime = o.saveGame.gameTime
        player.deathCount = o.saveGame.deathCount
        ldtk:goTo(o.saveGame.roomID)
    end

    function o:Death()
        local player = utility.gameObject:Find("Player") or {}
        if not o.isDead then
            o.deathSound:stop()
            o.deathSound:play()
        end
        o.isDead = true
        if not player.isDead then
            player.deathCount = player.deathCount + 1
            o.saveGame.deathCount = player.deathCount
            o.saveGame.gameTime = player.gameTime
            local text = json.encode(o.saveGame)
            if (not love.filesystem.getInfo("savefile")) then
                love.filesystem.newFile("savefile")
            end
            love.filesystem.write("savefile", text)
        end
        local player = utility.gameObject:Find("Player")
        player.isDead = true
    end

    function o.KeySoundPlay()
        o.keySound:play()
    end

    return o
end

return M
