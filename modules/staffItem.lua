staffItem = {}
staffItem.__index = staffItem

--[[

Current types:
   - "clef"
   - "key"
   - "time-signature"
   - "instrument"
   - "tempo"
   - "measure-number"
   - "note"
   - "rest"
   - "bar"
   - "triplet"
   - "chord"
   - "text"

]]



function staffItem.new(itemType)
   local self = setmetatable({}, staffItem)
   self.itemType = itemType

   return self
end


return staffItem