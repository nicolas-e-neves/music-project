local note = {}
note.__index = note
note.children = {}


function note.new(data)
   return setmetatable(data, note)
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


function note:decideWhatToDraw(averageLine, lowestLine, highestLine, currentAccidentals, headOnly)
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

   if (not self.pitches) or #self.pitches <= 0 then return whatToDraw end -- Is it not a rest? (!)
   if highestLine > 5 or lowestLine < 1 then
      whatToDraw.drawLedgerLines = true
   end

   --[[
      EXAMPLE:
      currentAccidentals = {
         [60] =  0, C --> C
         [62] =  0, D --> D
         [64] = -1, E --> Eb
         [65] =  1, F --> F#
         [67] =  0, G --> G
         [69] =  0, A --> A
         [71] = -1, B --> Bb
      }
      self.pitches = {60, 64, 67} --> C, E, G
      self.accidentals = {0, 0, 0}
      currentPitchAccidentals = {0, -1, 0}
      whatToDraw.drawAccidentals = {false, true, false}
   ]]

   local currentPitchAccidentals = {}
   for index, pitch in ipairs(self.pitches) do
      currentPitchAccidentals[index] = currentAccidentals[pitch] or 0

      local isDifferent = (currentPitchAccidentals[index] ~= (self.accidentals[index] or 0))
      table.insert(whatToDraw.drawAccidentals, isDifferent)
   end

   if headOnly or self.duration >= 4 then return whatToDraw end --> Is there something else that needs to be drawn? (!)
   whatToDraw.drawStem = true

   if self.duration >= 1 then return whatToDraw end --> Does the note have a flag? (!)
   whatToDraw.drawFlag = true

   return whatToDraw
end


function note:draw(beatPosition, currentAccidentals, headOnly)
   --> TEMPORARY
   --headOnly = true

   local scale
   local spriteName
   local sprite
   local offsetY

   if self.pitches and #self.pitches > 0 then
      scale = 0.25
      spriteName = "note-"
      sprite = SPRITES[spriteName .. math.ceil(self.duration)]
      offsetY = 0.5
   else
      scale = SETTINGS.rests[self.duration].scale
      spriteName = "rest-"
      sprite = SPRITES[spriteName .. self.duration]
      offsetY = SETTINGS.rests[self.duration].offsetY
   end
   local spriteScale = scale / sprite:getHeight()

   local positionX = SETTINGS.getXforBeat(beatPosition)
   
   local lines = {}
   local highestIndex = 1
   local lowestIndex = 1
   local averageLine = 0

   if self.pitches == nil or #self.pitches == 0 then --> Rest
      averageLine = SETTINGS.rests[self.duration].line or 3
      table.insert(lines, averageLine)
   else
      for index, pitch in ipairs(self.pitches or {}) do
         if pitch > self.pitches[highestIndex] then highestIndex = index end
         if pitch < self.pitches[lowestIndex]  then lowestIndex  = index end

         local line = SETTINGS.getLineForPitch(pitch, self.duration)
         averageLine = averageLine + line
         table.insert(lines, line)
      end
      averageLine = averageLine / #lines
   end
   
   local lowestLine = lines[lowestIndex]
   local highestLine = lines[highestIndex]

   local whatToDraw = self:decideWhatToDraw(averageLine, lowestLine, highestLine, currentAccidentals, headOnly)
   local direction = whatToDraw.direction --> 1: Down ; -1: Up

   --> Don't draw if it's outside the screen
   --> -1: Outside to the left; 0: On screen; 1: Outside to the right;
   if positionX < CAMERA.x - 2 * sprite:getWidth() * spriteScale - WINDOW_X / 2 then return -1, whatToDraw end
   if positionX > CAMERA.x + 2 * sprite:getWidth() * spriteScale + WINDOW_X / 2 then return  1, whatToDraw end

   local positionsY = {}
   for _, line in ipairs(lines) do
      table.insert(positionsY, SETTINGS.getYforLine(line))
   end

   --> Get the Y positions of the highest and lowest notes for drawing stems
   local frontY = (direction < 0) and positionsY[highestIndex] or positionsY[lowestIndex]
   local backY = (direction < 0) and positionsY[lowestIndex] or positionsY[highestIndex]

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
         local offsetX = note.getExtraLineOffset(self.duration)
         local positionY = SETTINGS.getYforLine(i)

         love.graphics.line(
            positionX - offsetX,
            positionY,
            positionX + offsetX + sprite:getWidth() * spriteScale,
            positionY
         )
      end
   end

   local stemTip = frontY + (stemHeight + 0.5) / 4 * direction

   --> Draw stem
   if whatToDraw.drawStem then
      love.graphics.setLineWidth(SETTINGS.lineWidth)
      love.graphics.line(
         positionX + offsetX + widthOffset * direction,
         backY + SETTINGS.stemOffsetY * direction,
         positionX + offsetX + widthOffset * direction,
         stemTip
      )
   end
   love.graphics.setLineStyle("smooth")

   if whatToDraw.drawFlag then
      --> Draw flag
      local flagSprite = SPRITES["flag-" .. self.duration]
      local flagScale = SETTINGS.flags[self.duration].scale / flagSprite:getHeight()
      
      love.graphics.draw(
         flagSprite,
         positionX + offsetX + SETTINGS.lineWidth / 2 * ((direction > 0) and 1 or 0),
         stemTip,
         0, -- rotation
         flagScale, flagScale * -direction, -- scale
         0, 0 -- offset
      )
   end

   for index, positionY in ipairs(positionsY) do
      if self.pitches[index] and SETTINGS.colorfulNotes then
         local pitch = self.pitches[index] + (self.accidentals and self.accidentals[index] or 0)
         love.graphics.setColor(SETTINGS.colorScheme["note-" .. (pitch % 12)])
      --else
         --love.graphics.setColor(SETTINGS.colorScheme["print-color"])
      end
      if whatToDraw.drawAccidentals[index] then
         --> Draw accidental
         local accidental = self.accidentals[index] or 0
         local accidentalSprite = SPRITES["accidental" .. accidental]
         local accidentalScale = SETTINGS.accidentals[accidental].scale / accidentalSprite:getHeight()

         love.graphics.draw(
            accidentalSprite,
            positionX - accidentalSprite:getWidth() * accidentalScale - SETTINGS.accidentalSpacing,
            positionY,
            0, -- rotation
            accidentalScale, nil, -- scale
            0, accidentalSprite:getHeight() * SETTINGS.accidentals[accidental].offsetY -- offset
         )
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
   end
   
   love.graphics.setColor(SETTINGS.colorScheme["print-color"])
   return 0, whatToDraw
end


function note.getAllNotes()
   return note.children
end


return note