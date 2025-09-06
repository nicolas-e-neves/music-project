local timeSignature = {}
timeSignature.__index = timeSignature
timeSignature.children = {}


function timeSignature.new(numerator, denominator)
   local self = setmetatable({}, timeSignature)
   self.type = "timeSignature"
   self.numerator = numerator or 4
   self.denominator = denominator or 4
   
   table.insert(timeSignature.children, self)
   return self
end


function timeSignature.findSprites(numerator, denominator)
   local numeratorSprite = SPRITES["signature" .. numerator] or SPRITES["number" .. numerator]
   local denominatorSprite = SPRITES["signature" .. denominator] or SPRITES["number" .. denominator]

   return numeratorSprite, denominatorSprite
end


function timeSignature:getWidth()
   local numeratorSprite, denominatorSprite = timeSignature.findSprites(self.numerator, self.denominator)
   local spriteScale = 0.5 / sprite:getHeight()

   return math.max(numeratorSprite:getWidth() * spriteScale, denominatorSprite:getWidth() * spriteScale)
end


function timeSignature:draw(beatPosition)
   local numeratorSprite, denominatorSprite = timeSignature.findSprites(self.numerator, self.denominator)
   local spriteScale = 0.5 / numeratorSprite:getHeight()

   love.graphics.setColor(SETTINGS.colorScheme["print-color"])
   love.graphics.draw(
      numeratorSprite,
      SETTINGS.getXforBeat(beatPosition), -- position x
      SETTINGS.getYforLine(6), -- position y
      0, -- rotation
      spriteScale * SETTINGS.timeSignatureScale, -- scale x
      nil, --scale y
      0, -- offset x
      numeratorSprite:getHeight() * 2 -- offset y
   )
   love.graphics.draw(
      denominatorSprite,
      SETTINGS.getXforBeat(beatPosition), -- position x
      SETTINGS.getYforLine(6), -- position y
      0, -- rotation
      spriteScale * SETTINGS.timeSignatureScale, -- scale x
      nil, --scale y
      0, -- offset x
      denominatorSprite:getHeight() -- offset y
   )
end


function timeSignature.getAllTimeSignatures()
   return timeSignature.children
end


return timeSignature