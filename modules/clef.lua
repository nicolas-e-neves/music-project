local clef = {}
clef.__index = clef
clef.children = {}


function clef.new(pitch, letter)
   local self = setmetatable({}, clef)
   self.type = "clef"
   self.letter = string.upper(letter) or "G"
   
   table.insert(clef.children, self)
   return self
end


function clef:getWidth()
   return SETTINGS.clefs[self.letter].drawScale * SPRITES[self.letter .. "-clef"]:getWidth()
end


function clef:draw(beatPosition)
   local sprite = SPRITES[self.letter .. "-clef"]

   love.graphics.draw(
      sprite,
      SETTINGS.clefMargin * SETTINGS.staffHeight / 2, -- position x
      SETTINGS.getYforLine(SETTINGS.clefs[self.letter].baseLine), -- position y
      0, -- rotation
      SETTINGS.staffHeight * SETTINGS.clefs[self.letter].drawScale, -- scale x
      nil, --scale y
      0, -- offset x
      SETTINGS.clefs[self.letter].offsetY * sprite:getHeight() -- offset y
   )
end


function clef.getAllClefs()
   return clef.children
end


return clef