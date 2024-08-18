if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

local utility = require("Lua.utility")

utility.scene:SceneCreate("init", "Scenes.init")
utility.scene:SceneCreate("level", "Scenes.level")
utility.scene:SceneChange("init")
utility.scene:SceneInit(256, 256, "Crystal of Size", 3)
