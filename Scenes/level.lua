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

M.object = {}
M.collision = {}

M.wall = {}

M.levelSequence = {}

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
        print(entity.id)
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
    M.levelSequence[4] = { nil, 2, nil, nil }

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
