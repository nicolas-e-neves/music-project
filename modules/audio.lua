local AUDIO = {}

for _, audioName in ipairs(love.filesystem.getDirectoryItems("audio")) do
   local audioName = audioName:sub(1, -5) -- > Remove ".png" from audioName

   AUDIO[audioName] = love.audio.newSource("audio/" .. audioName .. ".wav", "static")
end



return AUDIO