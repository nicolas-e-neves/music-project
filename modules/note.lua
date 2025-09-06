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


function note:draw(beatPosition, currentAccidentals, headOnly)
   --[[
   if headOnly == nil then
      headOnly = false
   else
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
   local WINDOW_X = love.window.getMode()
   
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


function note.getAllNotes()
   return note.children
end


return note