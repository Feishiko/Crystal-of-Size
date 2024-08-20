local M = {}

local gameCont = require("Objects.GameCont")

local utility = require("Lua.utility")

function M:Init()
    gameCont:New()
end

function M:Load()
end

function M:Update(dt)
    utility.scene:SceneChange("menu")
end

function M:Draw()
end

return M