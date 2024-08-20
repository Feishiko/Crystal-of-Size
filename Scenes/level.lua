local M = {}

local utility = require("Lua.utility")
ldtk = require("Lua.ldtk")

local player = require("Objects.Player")
local gear = require("Objects.Gear")
local save = require("Objects.Save")
local needleUp = require("Objects.NeedleUp")
local needleDown = require("Objects.NeedleDown")
local needleLeft = require("Objects.NeedleLeft")
local needleRight = require("Objects.NeedleRight")
local key = require("Objects.Key")
local key2 = require("Objects.Key2")
local lock = require("Objects.Lock")
local text = require("Objects.Text")
local deathCount = require("Objects.DeathCount")

M.mainAreaMusic = love.audio.newSource("Audio/mainArea.ogg", "stream")
M.upperAreaMusic = love.audio.newSource("Audio/upperArea.ogg", "stream")
M.lowerAreaMusic = love.audio.newSource("Audio/lowerArea.ogg", "stream")

M.mainAreaMusic:setLooping(true)
M.upperAreaMusic:setLooping(true)
M.lowerAreaMusic:setLooping(true)

M.object = {}
M.collision = {}

M.wall = {}

M.levelSequence = {}
M.roomMusic = {}

M.locknum = 1

function M.wall:new(entity)
    local o = {}
    o.x = entity.x
    o.y = entity.y
    o.width = entity.width
    o.height = entity.height
    function o:draw()
        -- love.graphics.rectangle("fill", o.x, o.y, o.width, o.height)
    end

    return o
end

function M:Load()
    ldtk:load("Ldtk/levels.ldtk")

    function ldtk.onEntity(entity)
        -- print(entity.id)
        if entity.id == "Gear" then
            local gear = gear:New()
            gear.x = entity.x
            gear.y = entity.y
        end
        if entity.id == "Save" then
            local save = save:New()
            save.x = entity.x
            save.y = entity.y
        end
        if entity.id == "Needle_Up" then
            local needle = needleUp:New()
            needle.x = entity.x
            needle.y = entity.y
        end
        if entity.id == "Needle_Down" then
            local needle = needleDown:New()
            needle.x = entity.x
            needle.y = entity.y
        end
        if entity.id == "Needle_Left" then
            local needle = needleLeft:New()
            needle.x = entity.x
            needle.y = entity.y
        end
        if entity.id == "Needle_Right" then
            local needle = needleRight:New()
            needle.x = entity.x
            needle.y = entity.y
        end
        local gameCont = utility.gameObject:Find("GameCont") or {}
        if entity.id == "Key" then
            if not gameCont.saveGame.isRedKey then
                local key = key:New()
                key.x = entity.x
                key.y = entity.y
            end
        end
        local gameCont = utility.gameObject:Find("GameCont") or {}
        if entity.id == "Key2" then
            if not gameCont.saveGame.isGreenKey then
                local key2 = key2:New()
                key2.x = entity.x
                key2.y = entity.y
            end
        end
        local gameCont = utility.gameObject:Find("GameCont") or {}
        if entity.id == "Lock" then
            if not gameCont.saveGame.isLock[M.locknum] then
                local lock = lock:New()
                lock.x = entity.x
                lock.y = entity.y
            end
            M.locknum = M.locknum + 1
        end
        if entity.id == "Text" then
            local text = text:New()
            text.x = entity.x
            text.y = entity.y
            text.string = entity.props["String"]
        end
        if entity.id == "DeathCount" then
            local deathCount = deathCount:New()
            deathCount.x = entity.x
            deathCount.y = entity.y
        end
        if entity.id == "Blocker" then
            table.insert(M.collision, entity)
        end
    end

    function ldtk.onLayer(layer)
        table.insert(M.object, layer)
    end

    function ldtk.onLevelLoaded(level)
        M.object = {}
        M.collision = {}
        M:InitToDelete("Gear")
        M:InitToDelete("Save")
        M:InitToDelete("NeedleUp")
        M:InitToDelete("NeedleDown")
        M:InitToDelete("NeedleLeft")
        M:InitToDelete("NeedleRight")
        M:InitToDelete("Key")
        M:InitToDelete("Key2")
        M:InitToDelete("Lock")
        M:InitToDelete("Text")
        M:InitToDelete("DeathCount")
        M.locknum = 1

        -- Music
        if M.roomMusic[ldtk:getCurrent()] == nil then
            M.mainAreaMusic:stop()
            M.upperAreaMusic:stop()
            M.lowerAreaMusic:stop()
        else
            if not M.roomMusic[ldtk:getCurrent()]:isPlaying() then
                M.mainAreaMusic:stop()
                M.upperAreaMusic:stop()
                M.lowerAreaMusic:stop()
                M.roomMusic[ldtk:getCurrent()]:play()
            end
        end

        utility.gameObject:Find("GameCont").collision = {}
        utility.gameObject:Find("GameCont").roomID = ldtk:getCurrent()
        M.backGroundColor = level.backgroundColor
    end

    function ldtk.onLevelCreated(level)
        if level.props.create then
            load(level.props.create)()
        end
    end
end

function M:Init()
    M.player = player:New()

    M.levelSequence[1] = { 2, nil, 3, nil } -- Right Bottom Left Up
    M.levelSequence[2] = { nil, nil, 1, 4 }
    M.levelSequence[3] = { 1, nil, nil, nil }
    M.levelSequence[4] = { 5, 2, nil, nil }
    M.levelSequence[5] = { 17, 7, 4, 6 }
    M.levelSequence[6] = { nil, 5, nil, 13 }
    M.levelSequence[7] = { nil, 9, nil, 5 }
    M.levelSequence[8] = { 5, 5, 5, 5 } -- Teleport Room
    M.levelSequence[9] = { nil, nil, 10, 7 }
    M.levelSequence[10] = { 9, nil, 11, nil }
    M.levelSequence[11] = { 10, nil, 12, nil }
    M.levelSequence[12] = { 11, nil, 8, nil }
    M.levelSequence[13] = { nil, 6, 14, nil }
    M.levelSequence[14] = { 13, 15, nil, nil }
    M.levelSequence[15] = { 16, nil, nil, 14 }
    M.levelSequence[16] = { 8, nil, 15, nil }
    M.levelSequence[17] = { 18, nil, 5, nil }
    M.levelSequence[18] = { nil, nil, 17, nil }

    M.roomMusic[1] = M.mainAreaMusic
    M.roomMusic[2] = M.mainAreaMusic
    M.roomMusic[3] = M.mainAreaMusic
    M.roomMusic[4] = M.mainAreaMusic
    M.roomMusic[5] = M.mainAreaMusic
    M.roomMusic[17] = M.mainAreaMusic
    M.roomMusic[18] = M.mainAreaMusic

    M.roomMusic[6] = M.upperAreaMusic
    M.roomMusic[13] = M.upperAreaMusic
    M.roomMusic[14] = M.upperAreaMusic
    M.roomMusic[15] = M.upperAreaMusic
    M.roomMusic[16] = M.upperAreaMusic

    M.roomMusic[7] = M.lowerAreaMusic
    M.roomMusic[9] = M.lowerAreaMusic
    M.roomMusic[10] = M.lowerAreaMusic
    M.roomMusic[11] = M.lowerAreaMusic
    M.roomMusic[12] = M.lowerAreaMusic

    ldtk:goTo(1)
end

function M:Update(dt)
    utility.gameObject:Find("GameCont").collision = M.collision
    if M.player.x > DrawEvent.width then
        M.player.x = 0
        ldtk:goTo(M.levelSequence[ldtk:getCurrent()][1])
    end

    if M.player.x < 0 then
        M.player.x = DrawEvent.width
        ldtk:goTo(M.levelSequence[ldtk:getCurrent()][3])
    end

    if M.player.y < 0 then
        M.player.y = DrawEvent.height
        ldtk:goTo(M.levelSequence[ldtk:getCurrent()][4])
    end

    if M.player.y > DrawEvent.height then
        M.player.y = 0
        ldtk:goTo(M.levelSequence[ldtk:getCurrent()][2])
    end
end

function M:Draw()
    love.graphics.setColor(M.backGroundColor)
    love.graphics.rectangle("fill", 0, 0, DrawEvent.width, DrawEvent.height)
    for i = 1, 80, 1 do
        love.graphics.setColor(1, 1, 1, .1)
        love.graphics.line(i*10, 0, 0, i*10)
        love.graphics.setColor(1, 1, 1)
    end
    -- for i = 0, 20, 1 do
    --     for j = 0, 20 ,1 do
    --         local a = j % 2 == 1
    --         local b = i % 2 == 1
    --         love.graphics.setColor(1, 1, 1, ((not a or b) and (not b or a)) and .2 or 0)
    --         love.graphics.rectangle("fill", j*16, i*16, 16, 16)
    --         love.graphics.setColor(1, 1, 1)
    --     end
    -- end
    love.graphics.setColor(255, 255, 255)
    for index, value in ipairs(M.object) do
        value:draw()
    end
end

function M:InitToDelete(class)
    while true do
        local someClass = utility.gameObject:Find(class)
        if someClass ~= nil then
            someClass.Free()
        else
            break
        end
    end
end

return M
