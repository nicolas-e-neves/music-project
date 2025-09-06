noteGroup = {}
noteGroup.__index = noteGroup



function noteGroup.new()
   local self = setmetatable({}, noteGroup)
   self.type = "noteGroup"
   self.children = {}

   return self
end


function noteGroup:getAverageLine()
   local average = 0

   for _, note in pairs(self.children) do
      average = average + SETTINGS.getLineForPitch(note.pitch)
   end

   return average / #self.children
end


function noteGroup:getGroupDirection()
   local line = self:getAverageLine()
   return (line >= 3) and -1 or 1
end


function noteGroup:getFurthestNote(direction)
   --[[
      direction = -1 -> returns the highest note of the group
      direction = +1 -> returns the lowest note of the group
   --]]

   if not direction then
      direction = self:getGroupDirection()
   end
   local furthestNote, index, line = nil, 0, math.huge * -direction

   for i, note in pairs(self.children) do
      local currentLine = SETTINGS.getLineForPitch(note.pitch)

      if (direction < 0 and currentLine < line) or (direction > 0 and currentLine > line) then
         furthestNote, index, line = note, i, currentLine
      end
   end

   return furthestNote, index, line
end


function noteGroup:getTrajectory()
   --> Returns the difference in lines from the first to the last note in the group
   local lineFirst = SETTINGS.getLineForPitch(self.children[1].pitch)
   local lineLast = SETTINGS.getLineForPitch(self.children[#self.children].pitch)
   local difference = lineLast - lineFirst

   return sign(difference) * math.min(math.abs(difference), SETTINGS.beamMaxHeight)
end


function noteGroup:draw(beatPosition, accidentals)
   --local averageLine = self:getAverageLine()
   local noteCount = #self.children
   local direction = self:getGroupDirection()
   local furthestNote, furthestIndex, furthestLine = self:getFurthestNote(direction) -- (furthestIndex - 1) / (total - 1) -> t
   local trajectory = self:getTrajectory() --> (b - a)

   local stemHeight = SETTINGS.stemHeight + 0.5
   stemHeight = math.max(stemHeight - math.abs(trajectory) / 2, stemHeight / 2) --+ math.abs(trajectory)
   local passingLine = furthestLine + stemHeight * direction --> r
   --[[
      a + (b - a) * t = r
      a = r - (b - a) * t
      b = (r - a) / t + a
   --]]
   local t = (furthestIndex - 1) / (noteCount - 1)
   local beamFirstLine = passingLine - trajectory * t --> a
   local beamLastLine--> b
   if t == 0 then
      beamLastLine = beamFirstLine + trajectory
   else
      beamLastLine = (passingLine - beamFirstLine) / t + beamFirstLine 
   end

   local sprite = SPRITES["note-1"]
   local spriteScale = 0.25 / sprite:getHeight()
   local widthOffset = SETTINGS.lineWidth * 0.5
   local offsetX = (direction < 0) and 0 or sprite:getWidth() * spriteScale
   local beamX1 = SETTINGS.getXforBeat(beatPosition) + offsetX - widthOffset * direction

   local firstBeatPosition = beatPosition
   local lastBeatPosition = beatPosition
   local beamAmount = {}
   local maxBeamCount = 1
   
   for noteIndex, note in pairs(self.children) do
      if noteIndex == noteCount then break end
      lastBeatPosition = lastBeatPosition + note.beatDuration * SETTINGS.timeSignature.denominator / 4
   end
   local dBeatPosition = lastBeatPosition - firstBeatPosition -- self.children[noteCount].beatDuration

   local currentT = 0
   for noteIndex, note in pairs(self.children) do
      local step = self.children[noteIndex].beatDuration / dBeatPosition

      table.insert(beamAmount, -math.log(note.beatDuration * 0.99, 2))
      maxBeamCount = math.max(maxBeamCount, beamAmount[noteIndex])

      --> Draw stem
      local noteLine = SETTINGS.getLineForPitch(note.pitch)
      local positionX = SETTINGS.getXforBeat(beatPosition)
      local positionY = SETTINGS.getYforLine(noteLine)
      
      love.graphics.setLineWidth(SETTINGS.lineWidth)
      love.graphics.setLineStyle("rough")
      love.graphics.line(
         positionX + offsetX - widthOffset * direction,
         positionY - SETTINGS.stemOffsetY * direction,
         positionX + offsetX - widthOffset * direction,
         SETTINGS.getYforLine(lerp(beamFirstLine, beamLastLine, currentT)) --+ SETTINGS.beamWidth * 0.5 * direction
      )
      
      note:draw(beatPosition, accidentals, true)

      beatPosition = beatPosition + note.beatDuration * SETTINGS.timeSignature.denominator / 4
      accidentals[note.pitch] = note.accidental
      currentT = currentT + step
   end
   
   local beamX2 = SETTINGS.getXforBeat(lastBeatPosition) + offsetX - widthOffset * direction
   local beamY1 = SETTINGS.getYforLine(beamFirstLine)
   local beamY2 = SETTINGS.getYforLine(beamLastLine)
   
   for beamIndex = 1, maxBeamCount, 1 do
      currentT = 0
      for noteIndex = 1, noteCount, 1 do
         local step = self.children[noteIndex].beatDuration / dBeatPosition

         if beamIndex <= beamAmount[noteIndex] then
            local beamWidthOffset = SETTINGS.beamWidth * direction
            local beamCountOffset = beamWidthOffset * (1 + SETTINGS.beamSpacing) * (beamIndex - 1)

            local innerBeamX1, innerBeamX2, innerBeamY1, innerBeamY2
            if beamIndex == 1 then
               innerBeamX1, innerBeamX2, innerBeamY1, innerBeamY2 = beamX1, beamX2, beamY1, beamY2
            else
               local t1, t2 = currentT, currentT

               if noteIndex ~= noteCount then --> It's not the last in the group
                  local tIncrease = step - self.children[noteIndex + 1].beatDuration / dBeatPosition * 0.5
                  t2 = t2 + tIncrease
               end
               if noteIndex == noteCount or (beamAmount[noteIndex - 1] or 0) >= beamAmount[noteIndex] then
                  --> It's the last or it needs to connect to the one behind it
                  t1 = t1 - step / 2
               end

               innerBeamX1 = lerp(beamX1, beamX2, t1)
               innerBeamX2 = lerp(beamX1, beamX2, t2)
               innerBeamY1 = lerp(beamY1, beamY2, t1)
               innerBeamY2 = lerp(beamY1, beamY2, t2)
            end

            love.graphics.setLineStyle("smooth")
            love.graphics.polygon(
               "fill",
               innerBeamX1,
               innerBeamY1 + beamCountOffset,
               innerBeamX2,
               innerBeamY2 + beamCountOffset,

               innerBeamX2,
               innerBeamY2 + beamCountOffset + beamWidthOffset,
               innerBeamX1,
               innerBeamY1 + beamCountOffset + beamWidthOffset
            )
         end
         currentT = currentT + step
      end
   end

   return beatPosition, accidentals, self.children[noteCount].beatDuration
end


return noteGroup