local M = {}
local utility = require("Lua.utility")
local gameCont = require("Objects.GameCont")
function M:New()
    local o = utility.gameObject:New("Player")
    o.x = 30
    o.y = 80
    o.face = 1
    o.width = 5
    o.height = 9
    o.isGround = false
    o.isJump = false
    o.isRun = false
    o.isDrop = true
    o.dropTimer = 0
    o.gameCont = gameCont:New()
    o.jumpSpd = { 2, 2, 1, 1, 1, 1, 0 }
    o.jumpTimer = 0
    o.currentFrame = 1
    o.currentFrameTimer = 0
    o.isGrowth = false
    o.spd = .5
    o.isDead = false
    o.key = 0
    o.deathCount = 0
    o.gameTime = 0
    o.jumpSound = love.audio.newSource("Sounds/JUMP.wav", "static")
    o.unlockSound = love.audio.newSource("Sounds/unlock.wav", "static")
    o.spriteSheet = love.graphics.newImage("Sprites/Player-Sheet.png")
    o.spriteSheet:setFilter("nearest")
    o.keySprite = love.graphics.newImage("Sprites/Key.png")
    o.spriteSheet:setFilter("nearest")
    function o:Load()
    end

    function o:Update(dt)
        -- Time Used
        o.gameTime = o.gameTime + dt

        love.window.setTitle("Size Gear - [Death]: " .. o.deathCount .. " [Time]: " .. math.floor(o.gameTime/3600) .. ":" .. string.format("%02d", math.floor(o.gameTime/60) % 60) .. ":" .. string.format("%02d", math.floor(o.gameTime) % 60))

        -- Movement
        o.spd = o.isGrowth and 1 or .5
        o.width = o.isGrowth and 10 or 5
        o.height = o.isGrowth and 18 or 9
        o.dropTimer = o.dropTimer + (o.isDrop and dt*160 or 0)

        -- Load Game
        if love.keyboard.wasPressed("r") then
            local gameCont = utility.gameObject:Find("GameCont") or {}
            gameCont.GameLoad()
        end

        -- Debug
        -- if love.keyboard.wasPressed("tab") then
        --     o.x = utility.GetMouseX()
        --     o.y = utility.GetMouseY()
        -- end

        if not o.isDead then
            if love.keyboard.isDown("left") then
                o:TryMove(-o.spd * dt * 160, 0)
                o.face = -1
            end
            if love.keyboard.isDown("right") then
                -- Lock
                local isPass = true
                local isCollision, lock = utility.collision:CollisionPoint(o.x + o.width + (o.spd * dt * 160), o.y, "Lock")
                print(isCollision, lock)
                if (isCollision) then
                    if (o.key > 0) then
                        o.key = o.key - 1
                        o.unlockSound:stop()
                        o.unlockSound:play()
                        lock:Free()
                        local gameCont = utility.gameObject:Find("GameCont") or {}
                        for index, value in ipairs(gameCont.saveGame.isLock) do
                            if not value then
                                gameCont.saveGame.isLock[index] = true
                                break
                            end
                        end
                    else
                        isPass = false
                    end
                end
                if isPass then
                    o:TryMove(o.spd * dt * 160, 0)
                end
                o.face = 1
            end
            if love.keyboard.isDown("left") or love.keyboard.isDown("right") then
                o.isRun = true
            else
                o.isRun = false
            end
            if love.keyboard.wasPressed("lshift") and o.isGround then
                o.isJump = false
                o.isGround = false
                o.isDrop = false
                o.jumpSound:stop()
                o.jumpSound:play()
            end
            if love.keyboard.wasReleased("lshift") and not o.isJump then
                o.isDrop = true
            end
            if love.keyboard.isDown("lshift") and not o.isJump then
                o.jumpTimer = o.jumpTimer + dt * 160
                o:TryMove(0, -o.jumpSpd[math.min(7, 1 + math.floor(o.jumpTimer / (o.isGrowth and 10 or 5)))] * dt * 160)
                if (1 + math.floor(o.jumpTimer / (o.isGrowth and 10 or 5)) == 7) then
                    o.isDrop = true
                end
            end
        end

        for index, value in pairs(utility.gameObject:Find("GameCont").collision) do
            if (utility.collision:CollisionAABB(o.x, o.y + dt * 160, o.width, o.height, value.x, value.y, value.width, value.height)) then
                o.isGround = true
                o.isJump = true
                o.jumpTimer = 0
                o.dropTimer = 0
                break;
            else
                o.isGround = false
            end
        end
        o:TryMove(0, o.isGround and 0 or math.min(1, o.dropTimer/30) * dt * 160)

        -- Animation
        o.currentFrameTimer = o.currentFrameTimer + dt * 160
    end

    function o:Draw()
        -- love.graphics.rectangle("line", o.x, o.y, o.width, o.height)
        love.graphics.push()
        love.graphics.translate(o.x + 4, o.y + 10*(o.isGrowth and 2 or 1))
        love.graphics.scale(o.face*(o.isGrowth and 2 or 1), o.isGrowth and 2 or 1)
        if o.isGround then
            if o.isRun then
                love.graphics.draw(o.spriteSheet,
                    o:animation(o.spriteSheet, 10, 10, 1, 4)[(math.floor(o.currentFrameTimer / 10) % 4) + 1], -5.5, -10)
            else
                love.graphics.draw(o.spriteSheet,
                    o:animation(o.spriteSheet, 10, 10, 0, 5)[(math.floor(o.currentFrameTimer / 10) % 5) + 1], -5.5, -10)
            end
        end

        if not o.isGround then
            if not o.isDrop then
                love.graphics.draw(o.spriteSheet,
                    o:animation(o.spriteSheet, 10, 10, 2, 2)[(math.floor(o.currentFrameTimer / 10) % 2) + 1], -5.5, -10)
            else
                love.graphics.draw(o.spriteSheet,
                    o:animation(o.spriteSheet, 10, 10, 3, 2)[(math.floor(o.currentFrameTimer / 10) % 2) + 1], -5.5, -10)
            end
        end
        love.graphics.pop()
        -- Key
        for i = 0, o.key - 1, 1 do
            love.graphics.draw(o.keySprite, 0 + i*16, 0)
        end
        -- love.graphics.rectangle("line", o.x, o.y, o.width, o.height)
    end

    -- TODO: Still need to fix this function to make drop stable
    function o:TryMove(dx, dy)
        local collision = false
        for index, value in pairs(utility.gameObject:Find("GameCont").collision) do
            if (utility.collision:CollisionAABB(o.x + dx, o.y + dy, o.width, o.height, value.x, value.y, value.width, value.height)) then
                collision = true
            end
        end
        if not collision then
            o.x = o.x + dx
            o.y = o.y + dy
        else
            -- X
            local i = 0
            local isBreak = false
            while true do
                for index, value in pairs(utility.gameObject:Find("GameCont").collision) do
                    if (utility.collision:CollisionAABB(o.x + dx - i, o.y + dy, o.width, o.height, value.x, value.y, value.width, value.height)) then
                        isBreak = true
                    end
                end
                if isBreak then break end
                i = i + 1
            end
            i = 0
            local isBreak = false
            while true do
                for index, value in pairs(utility.gameObject:Find("GameCont").collision) do
                    if (utility.collision:CollisionAABB(o.x + dx, o.y + dy - i, o.width, o.height, value.x, value.y, value.width, value.height)) then
                        isBreak = true
                    end
                end
                if isBreak then break end
                i = i + 1
            end
        end
    end

    function o:animation(tex, width, height, row, frame)
        local animation = {}
        for i = 1, frame, 1 do
            table.insert(animation, love.graphics.newQuad((i - 1) * width, row * height, width, height, tex))
        end
        return animation
    end

    return o
end

return M
