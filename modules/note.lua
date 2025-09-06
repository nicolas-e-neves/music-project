local note = {}
note.__index = note
note.children = {}


function note.new(pitch, beatDuration)
   local self = setmetatable({}, note)
   self.type = "note"
   self.beatDuration = beatDuration
   
   local roundedPitch = SETTINGS.roundPitch(pitch)
   self.pitch = roundedPitch
   self.accidental = pitch ~= nil and (pitch - roundedPitch) or 0
   self.noteIndex = #note.children + 1

   table.insert(note.children, self)
   return self
end


function note.getExtraLineOffset(beatDuration)
   local sprite = SPRITES["note-" .. math.ceil(beatDuration)]
   local spriteScale = 0.25 / sprite:getHeight()

   return sprite:getWidth() * spriteScale * (SETTINGS.extraLineLengthScale - 1) / 2
end


function note.getStemPositionForLine(line, stemHeight)
   local direction = (line >= 3) and 1 or -1
   local positionY = SETTINGS.getYforLine(line)

   return positionY + stemHeight * direction
end


function note:decideWhatToDraw(line, currentAccidentals, headOnly)
   --[[
      ORDER TO DECIDE:
      --> Head
      --> Ledger lines
      --> Accidentals
      --> Stem
      --> Beam/Flag
   --]]
   local whatToDraw = {}
   whatToDraw.drawHead = true
   whatToDraw.drawLedgerLines = false
   whatToDraw.drawAccidentals = false
   whatToDraw.drawStem = false
   whatToDraw.drawFlag = false
   whatToDraw.direction = (line >= 3) and 1 or -1

   if not self.pitch then return whatToDraw end -- Is it not a rest? (!)
   if line > 5 or line < 1 then
      whatToDraw.drawLedgerLines = true
   end

   local currentPitchAccidental = currentAccidentals[self.pitch] or 0

   if self.accidental ~= currentPitchAccidental then
      whatToDraw.drawAccidentals = true
   end

   if headOnly or self.beatDuration >= 4 then return whatToDraw end --> Is there something else that needs to be drawn? (!)
   whatToDraw.drawStem = true

   if self.beatDuration >= 1 then return whatToDraw end --> Does the note have a flag? (!)
   whatToDraw.drawFlag = true

   return whatToDraw
end


function note:draw(beatPosition, currentAccidentals, headOnly, noteData)
   --[
   --> TEMPORARY
   if noteData then
      headOnly = true
   end
   --]]

   local scale
   local spriteName
   local sprite
   local offsetY

   if self.pitch then
      scale = 0.25
      spriteName = "note-"
      sprite = SPRITES[spriteName .. math.ceil(self.beatDuration)]
      offsetY = 0.5
   else
      scale = SETTINGS.rests[self.beatDuration].scale
      spriteName = "rest-"
      sprite = SPRITES[spriteName .. self.beatDuration]
      offsetY = SETTINGS.rests[self.beatDuration].offsetY
   end
   local spriteScale = scale / sprite:getHeight()

   local positionX = SETTINGS.getXforBeat(beatPosition)
   
   local line = SETTINGS.getLineForPitch(self.pitch, self.beatDuration)
   local whatToDraw = self:decideWhatToDraw(line, currentAccidentals, headOnly)
   local direction = whatToDraw.direction --> 1: Down ; -1: Up

   --> Don't draw if it's outside the screen
   --> -1: Outside to the left; 0: On screen; 1: Outside to the right;
   if positionX < CAMERA.x - 2 * sprite:getWidth() * spriteScale - WINDOW_X / 2 then return -1, whatToDraw end
   if positionX > CAMERA.x + 2 * sprite:getWidth() * spriteScale + WINDOW_X / 2 then return  1, whatToDraw end

   local positionY = SETTINGS.getYforLine(line)

   local widthOffset = SETTINGS.lineWidth * 0.5
   local offsetX = (direction >= 1) and 0 or sprite:getWidth() * spriteScale --> offset to draw on the right or the left

   -- TODO: Calculate line height automatically
   local stemHeight = SETTINGS.stemHeight
   
   --[[
      ORDER TO DRAW:
      --> Ledger lines
      --> Stem
      --> Beam/Flag
      --> Head

      --> Accidentals (doesn't matter)
   --]]

   love.graphics.setColor(SETTINGS.colorScheme["print-color"])
   
   --> Draw ledger lines
   love.graphics.setLineStyle("rough")
   if whatToDraw.drawLedgerLines then
      local increment = (line > 5) and -1 or 1
      local rounded = line + increment * (line % 1)
      
      for i = rounded, clamp(line, 0, 6), increment do
         local offsetX = note.getExtraLineOffset(self.beatDuration)
         local positionY = SETTINGS.getYforLine(i)

         love.graphics.line(
            positionX - offsetX,
            positionY,
            positionX + offsetX + sprite:getWidth() * spriteScale,
            positionY
         )
      end
   end

   --> Draw stem
   if whatToDraw.drawStem then
      love.graphics.setLineWidth(SETTINGS.lineWidth)
      love.graphics.line(
         positionX + offsetX + widthOffset * direction,
         positionY + SETTINGS.stemOffsetY * direction,
         positionX + offsetX + widthOffset * direction,
         positionY + (stemHeight + 0.5) / 4 * direction
      )
   end
   love.graphics.setLineStyle("smooth")

   if whatToDraw.drawFlag then
      --> Draw flag
      local flagSprite = SPRITES["flag-" .. self.beatDuration]
      local flagScale = SETTINGS.flags[self.beatDuration].scale / flagSprite:getHeight()
      
      love.graphics.draw(
         flagSprite,
         positionX + offsetX + SETTINGS.lineWidth / 2 * ((direction > 0) and 1 or 0),
         positionY + (stemHeight + 0.5) / 4 * direction,
         0, -- rotation
         flagScale, flagScale * -direction, -- scale
         0, 0 -- offset
      )
   end

   if self.pitch and SETTINGS.colorfulNotes then
      local pitch = self.pitch + self.accidental
      love.graphics.setColor(SETTINGS.colorScheme["note-" .. (pitch % 12)])
   --else
      --love.graphics.setColor(SETTINGS.colorScheme["print-color"])
   end

   if whatToDraw.drawHead then
      --> Draw note head
      love.graphics.draw(
         sprite,
         positionX,
         positionY,
         0, -- rotation
         spriteScale, nil, -- scale
         0, offsetY * sprite:getHeight() -- offset
      )
   end

   if whatToDraw.drawAccidentals then
      local accidentalSprite = SPRITES["accidental" .. self.accidental]
      local accidentalScale = SETTINGS.accidentals[self.accidental].scale / accidentalSprite:getHeight()

      love.graphics.draw(
         SPRITES["accidental" .. self.accidental],
         positionX - accidentalSprite:getWidth() * accidentalScale - SETTINGS.accidentalSpacing,
         positionY,
         0, -- rotation
         accidentalScale, nil, -- scale
         0, accidentalSprite:getHeight() * SETTINGS.accidentals[self.accidental].offsetY -- offset
      )
   end
   love.graphics.setColor(SETTINGS.colorScheme["print-color"])
   return 0, whatToDraw
end


function note:decideWhatToDrawNEW(averageLine, lowestLine, highestLine, noteData, currentAccidentals, headOnly)
   --[[
      ORDER TO DECIDE:
      --> Head
      --> Ledger lines
      --> Accidentals
      --> Stem
      --> Beam/Flag
   --]]
   local whatToDraw = {}
   whatToDraw.drawHead = true
   whatToDraw.drawLedgerLines = false
   whatToDraw.drawAccidentals = {}
   whatToDraw.drawStem = false
   whatToDraw.drawFlag = false
   whatToDraw.direction = (averageLine >= 3) and 1 or -1

   if (not noteData.pitches) or #noteData.pitches <= 0 then return whatToDraw end -- Is it not a rest? (!)
   if highestLine > 5 or lowestLine < 1 then
      whatToDraw.drawLedgerLines = true
   end

   local currentPitchAccidentals = {}
   for index, pitch in ipairs(noteData.pitches) do
      currentPitchAccidentals[index] = currentAccidentals[pitch] or 0

      local corresponds = currentPitchAccidentals[index] ~= noteData[index]
      table.insert(whatToDraw.drawAccidentals, corresponds)
   end

   if headOnly or noteData.duration >= 4 then return whatToDraw end --> Is there something else that needs to be drawn? (!)
   whatToDraw.drawStem = true

   if noteData.duration >= 1 then return whatToDraw end --> Does the note have a flag? (!)
   whatToDraw.drawFlag = true

   return whatToDraw
end


function note:drawNEW(beatPosition, currentAccidentals, headOnly, noteData)
   --> TEMPORARY
   if noteData then
      headOnly = true
   end

   local scale
   local spriteName
   local sprite
   local offsetY

   if noteData.pitches and #noteData.pitches > 0 then
      scale = 0.25
      spriteName = "note-"
      sprite = SPRITES[spriteName .. math.ceil(noteData.duration)]
      offsetY = 0.5
   else
      scale = SETTINGS.rests[noteData.duration].scale
      spriteName = "rest-"
      sprite = SPRITES[spriteName .. noteData.duration]
      offsetY = SETTINGS.rests[noteData.duration].offsetY
   end
   local spriteScale = scale / sprite:getHeight()

   local positionX = SETTINGS.getXforBeat(beatPosition)
   
   local lines = {}
   local highestIndex = 1
   local lowestIndex = 1
   local averageLine = 0

   for index, pitch in ipairs(noteData.pitches or {}) do
      if pitch > noteData[highestIndex] then highestIndex = index end
      if pitch < noteData[lowestIndex]  then lowestIndex  = index end

      local line = SETTINGS.getLineForPitch(pitch, noteData.duration)
      averageLine = averageLine + line
      table.insert(lines, line)
   end
   averageLine = averageLine / #lines
   local lowestLine = lines[lowestIndex]
   local highestLine = lines[highestIndex]

   local whatToDraw = self:decideWhatToDrawNEW(averageLine, lowestLine, highestLine, noteData, currentAccidentals, headOnly)
   local direction = whatToDraw.direction --> 1: Down ; -1: Up

   --> Don't draw if it's outside the screen
   --> -1: Outside to the left; 0: On screen; 1: Outside to the right;
   if positionX < CAMERA.x - 2 * sprite:getWidth() * spriteScale - WINDOW_X / 2 then return -1, whatToDraw end
   if positionX > CAMERA.x + 2 * sprite:getWidth() * spriteScale + WINDOW_X / 2 then return  1, whatToDraw end

   local positionsY = {}
   for _, line in ipairs(lines) do
      table.insert(positionsY, SETTINGS.getYforLine(line))
   end

   local widthOffset = SETTINGS.lineWidth * 0.5
   local offsetX = (direction >= 1) and 0 or sprite:getWidth() * spriteScale --> offset to draw on the right or the left

   -- TODO: Calculate line height automatically
   local stemHeight = SETTINGS.stemHeight
   
   --[[
      ORDER TO DRAW:
      --> Ledger lines
      --> Stem
      --> Beam/Flag
      --> Head

      --> Accidentals (doesn't matter)
   --]]

   love.graphics.setColor(SETTINGS.colorScheme["print-color"])
   
   --> Draw ledger lines
   love.graphics.setLineStyle("rough")
   if whatToDraw.drawLedgerLines then
      local lineToUse
      local increment

      if highestLine > 5 then
         lineToUse = highestLine
         increment = -1
      else
         lineToUse = lowestLine
         increment = 1
      end
      local rounded = lineToUse + increment * (lineToUse % 1)
      
      for i = rounded, clamp(lineToUse, 0, 6), increment do
         local offsetX = note.getExtraLineOffset(noteData.duration)
         local positionY = SETTINGS.getYforLine(i)

         love.graphics.line(
            positionX - offsetX,
            positionY,
            positionX + offsetX + sprite:getWidth() * spriteScale,
            positionY
         )
      end
   end

   --> Draw stem
   if whatToDraw.drawStem then
      love.graphics.setLineWidth(SETTINGS.lineWidth)
      love.graphics.line(
         positionX + offsetX + widthOffset * direction,
         positionY + SETTINGS.stemOffsetY * direction,
         positionX + offsetX + widthOffset * direction,
         positionY + (stemHeight + 0.5) / 4 * direction
      )
   end
   love.graphics.setLineStyle("smooth")

   if whatToDraw.drawFlag then
      --> Draw flag
      local flagSprite = SPRITES["flag-" .. self.beatDuration]
      local flagScale = SETTINGS.flags[self.beatDuration].scale / flagSprite:getHeight()
      
      love.graphics.draw(
         flagSprite,
         positionX + offsetX + SETTINGS.lineWidth / 2 * ((direction > 0) and 1 or 0),
         positionY + (stemHeight + 0.5) / 4 * direction,
         0, -- rotation
         flagScale, flagScale * -direction, -- scale
         0, 0 -- offset
      )
   end

   if self.pitch and SETTINGS.colorfulNotes then
      local pitch = self.pitch + self.accidental
      love.graphics.setColor(SETTINGS.colorScheme["note-" .. (pitch % 12)])
   --else
      --love.graphics.setColor(SETTINGS.colorScheme["print-color"])
   end

   if whatToDraw.drawHead then
      --> Draw note head
      love.graphics.draw(
         sprite,
         positionX,
         positionY,
         0, -- rotation
         spriteScale, nil, -- scale
         0, offsetY * sprite:getHeight() -- offset
      )
   end

   if whatToDraw.drawAccidentals then
      local accidentalSprite = SPRITES["accidental" .. self.accidental]
      local accidentalScale = SETTINGS.accidentals[self.accidental].scale / accidentalSprite:getHeight()

      love.graphics.draw(
         SPRITES["accidental" .. self.accidental],
         positionX - accidentalSprite:getWidth() * accidentalScale - SETTINGS.accidentalSpacing,
         positionY,
         0, -- rotation
         accidentalScale, nil, -- scale
         0, accidentalSprite:getHeight() * SETTINGS.accidentals[self.accidental].offsetY -- offset
      )
   end
   love.graphics.setColor(SETTINGS.colorScheme["print-color"])
   return 0, whatToDraw
end


function note.getAllNotes()
   return note.children
end


return note