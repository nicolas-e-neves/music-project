local SPRITES = {}

--[[
SPRITES["G-clef"] = love.graphics.newImage("sprites/G-clef.png")
SPRITES["F-clef"] = love.graphics.newImage("sprites/F-clef.png")
SPRITES["C-clef"] = love.graphics.newImage("sprites/C-clef.png")

SPRITES["note-1"] = love.graphics.newImage("sprites/note-1.png")
SPRITES["rest-1"] = love.graphics.newImage("sprites/rest-1.png")
--]]

for _, imageName in ipairs(love.filesystem.getDirectoryItems("sprites")) do
   local imageName = imageName:sub(1, -5) -- > Remove ".png" from imageName

   SPRITES[imageName] = love.graphics.newImage("sprites/" .. imageName .. ".png")
end



return SPRITES