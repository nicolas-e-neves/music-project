local songSelector = {}


function songSelector.update(dt)
   
end


function songSelector.draw()
   love.graphics.setBackgroundColor(SETTINGS.colorScheme["background-color"])
   UI.Begin("Songs", 0, 0)
   
   for i, songFileName in ipairs(love.filesystem.getDirectoryItems("songs")) do
      local songFileName = songFileName:sub(1, -5)
      local song = require("songs/" .. songFileName)
      
      local songName = songFileName
      if song.Name then
         songName = song.Name
      end
      
      local clicked = UI.Button(songName)
      UI.SameLine()
      if clicked then
         if songName ~= SETTINGS.songName then
            SETTINGS.camera.x = 0
         end
         SETTINGS.camera.velocityX = 0
         SETTINGS.currentTab = TABS["sheet"]
         SETTINGS.loadSong(songFileName, true)
         break
      end
   end

   local sizeX, sizeY = UI.GetWindowSize("Songs")
   UI.SetWindowPosition("Songs", (WINDOW_X - sizeX) / 2, (WINDOW_Y - sizeY) / 2)
   
   UI.End()
	UI.RenderFrame()
end


function songSelector.filedropped(file)
   file:open("r")

   local fileName = file:getFilename()
   local extension = fileName:match("%.%w+$")
   if extension ~= ".lua" then return end

   fileName = fileName:sub(1, -5)
   SETTINGS.loadSong(fileName, true, true)
end



return songSelector