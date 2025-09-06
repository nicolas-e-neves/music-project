function love.load()
   WINDOW_X, WINDOW_Y = 1280, 720
   DPI = love.graphics.getDPIScale()
   FULLSCREEN = true
   
   love.window.setTitle("Song")
   love.window.updateMode(WINDOW_X, WINDOW_Y, {fullscreen = FULLSCREEN, resizable = true, minwidth = 640, minheight = 360})
   love.window.setIcon(love.image.newImageData("sprites/F-clef.png"))
   --love.graphics.setDefaultFilter("linear", "linear")
   
   SHADERS = {}
   for _, shaderName in ipairs(love.filesystem.getDirectoryItems("shaders")) do
      local shaderName = shaderName:sub(1, -5) 
      local shaderCode = require("shaders/" .. shaderName)

      SHADERS[shaderName] = love.graphics.newShader(shaderCode)
   end

   SCHEMES = {}
   for _, schemeName in ipairs(love.filesystem.getDirectoryItems("schemes")) do
      local schemeName = schemeName:sub(1, -5) 
      SCHEMES[schemeName] = require("schemes/" .. schemeName)
   end

   TABS = {}
   for _, tabName in ipairs(love.filesystem.getDirectoryItems("tabs")) do
      local tabName = tabName:sub(1, -5)
      TABS[tabName] = require("tabs/" .. tabName)
   end

   AUDIO = require("modules/audio")
   SPRITES = require("modules/sprites")
   CAMERA = require("libraries/camera")()
   UI = require("libraries/ui2d")
   UI.Init("love")

   local fontScale = (DPI - 1) * 0.5 + 1
   UI.SetFontSize(20 / fontScale)

   STAFF_MODULES = {
      staffItem = require("modules/staffItem"),
      note = require("modules/note"),
      clef = require("modules/clef"),
      timeSignature = require("modules/timeSignature"),
      noteGroup = require("modules/noteGroup")
   }
   
   SETTINGS = require("modules/settings")


   --> CHANGE THESE LATER
   SETTINGS.colorScheme = SCHEMES["light"]
   SETTINGS.currentTab = TABS["song-selector"]
   --SETTINGS.loadSong("demo-1")
end


function love.update(dt)
   DPI = love.graphics.getDPIScale()
   WINDOW_X, WINDOW_Y = love.window.getMode()
   WINDOW_X, WINDOW_Y = WINDOW_X / DPI, WINDOW_Y / DPI

   UI.InputInfo()
   SETTINGS.currentTab.update(dt)
end

function love.draw()
   UI.SetColorTheme(SETTINGS.colorScheme["ui-theme"])
   SETTINGS.currentTab.draw()
end

function love.wheelmoved(dx, dy)
   UI.WheelMoved(dx, dy)

   local Callback = SETTINGS.currentTab.wheelmoved
   if Callback then
      Callback(dx, dy)
   end
end

function love.mousemoved(x, y, dx, dy, isTouch)
   local Callback = SETTINGS.currentTab.mousemoved
   if Callback then
      Callback(x, y, dx, dy, isTouch)
   end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
   local Callback = SETTINGS.currentTab.touchmoved
   if Callback then
      Callback(id, x, y, dx, dy, pressure)
   end
end

function love.keypressed(key, scancode, isrepeat)
   if key == "f11" then
      FULLSCREEN = not FULLSCREEN
      love.window.setFullscreen(FULLSCREEN)
   end

   UI.KeyPressed(key, isrepeat)

   local Callback = SETTINGS.currentTab.keypressed
   if Callback then
      Callback(key)
   end
end

function love.keyreleased(key, scancode)
	UI.KeyReleased()
end

function love.textinput(text)
	UI.TextInput(text)
end

function love.filedropped(file)
   local Callback = SETTINGS.currentTab.filedropped
   if Callback then
      Callback(file)
   end
end