local sheetTab = {}
sheetTab.playing = false
sheetTab.beatPosition = 0
sheetTab.songIndex = 1


function findNoteOnBeatPosition(targetBeatPosition)
   --currentIndex = currentIndex or 1

   local nonLegato = 1/32 --> CHANGE THIS LATER
   local extraPause = false

   local beatPosition = 0
   for i, content in ipairs(SETTINGS.sheetContent) do

      if content.type == "note" then
         beatPosition = beatPosition + content.beatDuration

         if beatPosition >= targetBeatPosition then
            if beatPosition - nonLegato < targetBeatPosition then
               extraPause = true
            end
            return content, extraPause
         end

      elseif content.type == "noteGroup" then

         for j, note in ipairs(content.children) do
            beatPosition = beatPosition + note.beatDuration
            
            if beatPosition >= targetBeatPosition then
               if beatPosition - nonLegato < targetBeatPosition then
                  extraPause = true
               end
               return note, extraPause
            end
         end

      end

   end
end


function sheetTab.update(dt)
   --if true then return end
   SETTINGS.staffPositionY = SETTINGS.staffPositionYPercent * WINDOW_Y
   SETTINGS.staffHeight = SETTINGS.staffHeightPercent * WINDOW_Y
   
   CAMERA.y = (WINDOW_Y / 2) + SETTINGS.camera.y

   local clefWidth = SETTINGS.clefWidth(SETTINGS.currentClef)
   
   local firstBeatDuration = 0
   for _, item in pairs(SETTINGS.sheetContent.systems[1][1].content[1]) do
      if item.type == "note" then
         firstBeatDuration = item.duration
         break
      end
   end
   local extraLineOffset = STAFF_MODULES.note.getExtraLineOffset(firstBeatDuration)
   
   if not sheetTab.playing then
      local sign = (SETTINGS.camera.velocityX > 0) and 1 or -1

      SETTINGS.camera.x = SETTINGS.camera.x + SETTINGS.camera.velocityX
      if SETTINGS.camera.x < 0 then
         SETTINGS.camera.x = math.max(SETTINGS.camera.x, -math.abs(SETTINGS.camera.velocityX))
      end
      SETTINGS.camera.velocityX = math.max(math.abs(SETTINGS.camera.velocityX) * SETTINGS.camera.scrollDecay^dt, 0)
      
      local holding = love.mouse.isDown(1) or (#love.touch.getTouches() > 0)
      if not holding then
         SETTINGS.camera.velocityX = math.min(SETTINGS.camera.velocityX, SETTINGS.camera.maxVelocity)
      end
      if SETTINGS.camera.velocityX <= SETTINGS.camera.minVelocity then
         SETTINGS.camera.velocityX = 0
      end
      
      SETTINGS.camera.velocityX = SETTINGS.camera.velocityX * sign
   else
      sheetTab.beatPosition = sheetTab.beatPosition + SETTINGS.seconds2beat(dt)
      SETTINGS.camera.x = SETTINGS.getXforBeat(sheetTab.beatPosition)

      local note, extraPause = findNoteOnBeatPosition(sheetTab.beatPosition)
      if note and note.pitch ~= nil and not extraPause then
         local pitchChange = note.pitch + note.accidental - 69
         AUDIO.sine:setPitch(2^(pitchChange/12))

         AUDIO.sine:setLooping(true)
         AUDIO.sine:play()
      else
         if not note then
            sheetTab.playing = false
         end
         AUDIO.sine:stop()
      end
   end

   CAMERA.x = SETTINGS.camera.x - 2 * SETTINGS.clefMargin - clefWidth - SETTINGS.noteGradientDistance - extraLineOffset + (WINDOW_X / 2)
end


function sheetTab.draw()
   love.graphics.setBackgroundColor(SETTINGS.colorScheme["background-color"])
   SETTINGS.drawSheetContent()
   --SETTINGS.drawMiddleLines()

   --> Draw UI
   UI.Begin("Options", 20, 20)
   UI.SetWindowPosition("Options", 20, 20)

   local clicked = UI.Button(" < ")
   if clicked then
      sheetTab.playing = false
      SETTINGS.currentTab = TABS["song-selector"]
      UI.End()
      UI.RenderFrame()
      return
   end
   
   UI.SameLine()

   local clicked = UI.Button(" ⚙ ")
   if clicked then
      sheetTab.playing = false
      SETTINGS.currentTab = TABS["settings"]
      UI.End()
      UI.RenderFrame()
      return
   end

   --local sizeX, sizeY = UI.GetWindowSize("Options")
   --UI.SetWindowPosition("Options", WINDOW_X - sizeX - 20, 20)
   
   UI.End()
	UI.RenderFrame()
end


function sheetTab.keypressed(key, scancode, isrepeat)
   if key ~= "space" then return end
   sheetTab.playing = not sheetTab.playing
   sheetTab.beatPosition = 0
   if not sheetTab.playing then
      AUDIO.sine:stop()
   end
end


function sheetTab.applyCameraScroll(dx, dy, modifier, add)
   add = add or 0
   SETTINGS.camera.velocityX = -dx * modifier + SETTINGS.camera.velocityX * add
end


function sheetTab.wheelmoved(dx, dy)
   if love.mouse.isDown(1) then return end
   sheetTab.applyCameraScroll(dy, dx, SETTINGS.camera.scrollSpeed, 1)
end

function sheetTab.mousemoved(x, y, dx, dy, isTouch)
   if not love.mouse.isDown(1) then return end
   sheetTab.applyCameraScroll(dx, dy, 1 / SETTINGS.staffHeight)
end

function sheetTab.touchmoved(id, x, y, dx, dy, pressure)
   sheetTab.applyCameraScroll(dx, dy, 1 / SETTINGS.staffHeight)
end




return sheetTab