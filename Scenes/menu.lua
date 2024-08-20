local M = {}

local utility = require("Lua.utility")
M.coverSprite = love.graphics.newImage("Sprites/cover.png")
M.coverSprite:setFilter("nearest")
M.menuItems = { "New Game", "Load Game", "Exit Game" }
M.itemSelect = 1
M.rectY = nil

M.skewX = 0
M.skewY = 0
M.randomX = 0
M.randomY = 0
M.randomTimer = 0

M.music = love.audio.newSource(("Audio/mainArea.ogg"), "stream")
M.music:setLooping(true)

M.buttonSelectSound = love.audio.newSource("Sounds/ButtonHover.wav", "static")

function M:Load()
end

function M:Init()
    M.rectY = DrawEvent.height / 2 - 10
    M.music:play()
end

function M:Update(dt)
    -- Easing
    M.skewX = utility.Lerp(M.skewX, M.randomX, .2 * dt)
    M.skewY = utility.Lerp(M.skewY, M.randomY, .2 * dt)
    M.randomTimer = M.randomTimer + dt * 160
    if M.randomTimer > 120 then
        M.randomX = math.random(-2, 2)
        M.randomY = math.random(-2, 2)
        M.randomTimer = 0
    end

    if love.keyboard.wasPressed("up") and M.itemSelect > 1 then
        M.itemSelect = M.itemSelect - 1
        M.buttonSelectSound:play()
    end

    if love.keyboard.wasPressed("down") and M.itemSelect < 3 then
        M.itemSelect = M.itemSelect + 1
        M.buttonSelectSound:play()
    end

    if love.keyboard.wasPressed("lshift") or love.keyboard.wasPressed("return") then
        if M.itemSelect == 1 then
            M.music:stop()
            utility.scene:SceneChange("level")
        end
        if M.itemSelect == 2 then
            local gameCont = utility.gameObject:Find("GameCont") or {}
            M.music:stop()
            utility.scene:SceneChange("level")
            gameCont:GameLoad()
        end
        if M.itemSelect == 3 then
            love.window.close()
        end
    end

    M.rectY = utility.Lerp(M.rectY, DrawEvent.height / 2 - 10 + (M.itemSelect - 1) * 30, .2 * dt * 160)
end

function M:Draw()
    love.graphics.push()
    love.graphics.translate(DrawEvent.width/2 + M.skewX, DrawEvent.height/2 + M.skewY)
    love.graphics.scale(1.05, 1.05)
    love.graphics.draw(M.coverSprite, -M.coverSprite:getWidth()/2, -M.coverSprite:getHeight()/2)
    love.graphics.pop()
    local gameCont = utility.gameObject:Find("GameCont") or {}
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", DrawEvent.width / 2 - 60, M.rectY, 120, 22)
    love.graphics.setColor(1, 1, 1)
    for index, value in ipairs(M.menuItems) do
        love.graphics.push()
        love.graphics.translate(DrawEvent.width / 2, DrawEvent.height / 2 - 30 + 30 * index)
        love.graphics.scale(2, 2)
        local color = index == M.itemSelect and 1 or 0
        love.graphics.setColor(color, color, color)
        love.graphics.print(value, -gameCont.font:getWidth(value) / 2,
            -gameCont.font:getHeight(value) / 2)
        love.graphics.setColor(1, 1, 1)
        love.graphics.pop()
    end
end

return M
