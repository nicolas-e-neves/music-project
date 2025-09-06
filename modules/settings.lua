local SETTINGS = {}
SETTINGS.currentTab = {}
SETTINGS.staffPositionYPercent = 1 / 2
SETTINGS.staffHeightPercent = 1 / 5
SETTINGS.staffPositionY = SETTINGS.staffPositionYPercent * WINDOW_Y
SETTINGS.staffHeight = SETTINGS.staffHeightPercent * WINDOW_Y

--> Visual settings
SETTINGS.noteSpacing = 1.5 -- TODO: Set this automatically (kinda done)
SETTINGS.clefMargin = 0.1
SETTINGS.noteGradientDistance = 0.025
SETTINGS.barOffset = 0.2 --> How much to offset the measure bar to the left
SETTINGS.accidentalSpacing = 0.055
SETTINGS.extraLineLengthScale = 1.5 --> The width of the ledger lines compared to the width of a note
SETTINGS.lineWidth = 0.02
SETTINGS.beamWidth = 0.5 / 4 --> in staff height
SETTINGS.beamMaxHeight = 0.5 --> in lines
SETTINGS.beamSpacing = 0.5 --> Space between beans (in beam width)
SETTINGS.stemOffsetY = 0.03 --> How much to offset the note stem so it aligns better with the note sprite
SETTINGS.stemHeight = 3 --> in lines
SETTINGS.timeSignatureScale = 0.75 --> in staff height
SETTINGS.colorfulNotes = false

--> Song settings
SETTINGS.songName = ""
SETTINGS.currentClef = "G"
SETTINGS.timeSignature = {}
SETTINGS.timeSignature.numerator = 4
SETTINGS.timeSignature.denominator = 4
SETTINGS.tempo = 120

SETTINGS.sheetContent = {}

--> Camera settings
SETTINGS.camera = {}
SETTINGS.camera.scrollSpeed = 0.08
SETTINGS.camera.scrollDecay = 0.005
SETTINGS.camera.velocityX = 0
SETTINGS.camera.maxVelocity = 0.75
SETTINGS.camera.minVelocity = 0.005
SETTINGS.camera.x = 0
SETTINGS.camera.y = 0


--> Property settings
SETTINGS.clefs = {}
SETTINGS.clefs.G = {}
SETTINGS.clefs.G.offsetY = 0.653 --> Defines where the anchor point is in the clef sprite
SETTINGS.clefs.G.baseLine = 2
SETTINGS.clefs.G.scale = 1.85
SETTINGS.clefs.G.noteLineOffset = 17.5 --> Defines how much to offset the picth of a note to account for the clef

SETTINGS.clefs.F = {}
SETTINGS.clefs.F.offsetY = 0.316
SETTINGS.clefs.F.baseLine = 4
SETTINGS.clefs.F.scale = 0.8
SETTINGS.clefs.F.noteLineOffset = 11.5

SETTINGS.clefs.C = {}
SETTINGS.clefs.C.offsetY = 0.5
SETTINGS.clefs.C.baseLine = 3
SETTINGS.clefs.C.scale = 1
SETTINGS.clefs.C.noteLineOffset = 14.5

for clef, info in pairs(SETTINGS.clefs) do
	info.drawScale = info.scale / SPRITES[clef .. "-clef"]:getHeight() --> Converts image scale to staffHeight
end


SETTINGS.rests = {}
SETTINGS.rests[1] = {}
SETTINGS.rests[1].scale = 3.125 / 4
SETTINGS.rests[1].offsetY = 0.5
SETTINGS.rests[1].line = 3

SETTINGS.rests[1/2] = {}
SETTINGS.rests[1/2].scale = 1.5 / 4
SETTINGS.rests[1/2].offsetY = 0.5
SETTINGS.rests[1/2].line = 3

SETTINGS.rests[1/4] = {}
SETTINGS.rests[1/4].scale = 2.28 / 4
SETTINGS.rests[1/4].offsetY = 0.5
SETTINGS.rests[1/4].line = 3


SETTINGS.flags = {}
SETTINGS.flags[1/2] = {}
SETTINGS.flags[1/2].scale = 3.25 / 4

SETTINGS.flags[1/4] = {}
SETTINGS.flags[1/4].scale = 3.38 / 4


SETTINGS.accidentals = {}
SETTINGS.accidentals[-1] = {}
SETTINGS.accidentals[-1].scale = 2.2 / 4
SETTINGS.accidentals[-1].offsetY = 0.76

SETTINGS.accidentals[0] = {}
SETTINGS.accidentals[0].scale = 2 / 4
SETTINGS.accidentals[0].offsetY = 0.5

SETTINGS.accidentals[1] = {}
SETTINGS.accidentals[1].scale = 2.5 / 4
SETTINGS.accidentals[1].offsetY = 0.45



function clamp(x, min, max)
	return math.max(min, math.min(x, max))
end


function lerp(a, b, t)
	return a + (b - a) * t
end


function sign(x)
	if x > 0 then
		return 1
	elseif x < 0 then
		return -1
	else
		return 0
	end
end


function SETTINGS.roundPitch(pitch, direction)
	if pitch == nil then return nil end
   direction = direction or 1

   local scaleIndex = pitch % 12
   local roundedWholeTone = math.floor(scaleIndex / 2) * 2

   local scaleOffset = (scaleIndex >= 5) and 1 or 0
   local octaveOffset = 12 * math.floor(pitch / 12)
   local flatAdjustment = (scaleIndex == 1 or scaleIndex == 3) and 2 or 0

   local roundedPitch = roundedWholeTone + scaleOffset + flatAdjustment + octaveOffset

   if direction < 0 and roundedPitch - pitch > 0 then
      roundedPitch = roundedPitch - 2
   end

   return roundedPitch
end


function SETTINGS.getLineForPitch(pitch, duration)
   if not pitch then
		local info = SETTINGS.rests[duration]
      return info and info.line or 3
   end

   local roundedPitch = SETTINGS.roundPitch(pitch)

   --> Convert 0 - 12 to 0 - 3.5
   local line = math.floor(roundedPitch * 0.58333 + 0.5) / 2 - SETTINGS.clefs[SETTINGS.currentClef].noteLineOffset

   return line
end


function SETTINGS.getYforLine(lineIndex)
	--> Calculate the y position from bottom to top
	return 1 / 4 * (3 - lineIndex)
end


function SETTINGS.clefWidth(clef)
	clef = celf or "G"

	return SETTINGS.clefs[clef].drawScale * SPRITES[clef .. "-clef"]:getWidth()
end


function SETTINGS.seconds2beat(seconds)
	--> Simplified from seconds * (SETTINGS.tempo / 60) * (4 / SETTINGS.timeSignature.denominator)
	local beats = seconds * SETTINGS.tempo / (15 * SETTINGS.timeSignature.denominator)

	return beats
end


function SETTINGS.getXforBeat(beatPosition)
	return beatPosition * SETTINGS.noteSpacing / SETTINGS.timeSignature.denominator * 4
end


function SETTINGS.drawBar(index, lastBeatDuration, whatGotDrawn, type)
	lastBeatDuration = lastBeatDuration or 1

	local noteHeadRatio = SPRITES["note-1"]:getWidth() / SPRITES["note-1"]:getHeight()

	local maxX = SETTINGS.getXforBeat(index * SETTINGS.timeSignature.numerator) - SETTINGS.lineWidth
	local minX = maxX - SETTINGS.noteSpacing * lastBeatDuration + 0.25 * noteHeadRatio + 2 * SETTINGS.lineWidth

	if whatGotDrawn.drawFlag and whatGotDrawn.direction < 0 then
		local flagSprite = SPRITES["flag-" .. lastBeatDuration]
   	local flagScale = SETTINGS.flags[lastBeatDuration].scale / flagSprite:getHeight()
		local flagWidth = flagScale * flagSprite:getWidth()
		minX = minX + flagWidth
	end

	local t = SETTINGS.barOffset

	if minX >= maxX then
		t = 0.5
	end

	local x = lerp(maxX, minX, SETTINGS.barOffset)
	love.graphics.setColor(SETTINGS.colorScheme["print-color"])
   love.graphics.line(x, -0.5, x, 0.5)
end


function SETTINGS.calculateMaxGroupForDuration(noteType, numerator, denominator)
	if noteType >= 1 then return 1 end
	noteType = 4 / noteType
	
	numerator = SETTINGS.timeSignature.numerator
	denominator = SETTINGS.timeSignature.denominator

	local currentDen = denominator
	local maxGroup = 2
	local measureDuration = numerator / denominator

	while currentDen <= noteType do
		if numerator % 2 == 1 then break end

		numerator = numerator / 2
		maxGroup = noteType / denominator * numerator
		currentDen = currentDen * 2

		if maxGroup < 5 then break end
	end

	return maxGroup
end


function SETTINGS.drawMiddleLines()
	--> Draw middle line for testing
   love.graphics.setColor(1,0,0)
   love.graphics.line(
      0,
      (WINDOW_Y * DPI * 0.5 - SETTINGS.staffPositionY) / SETTINGS.staffHeight,
      WINDOW_X * DPI / SETTINGS.staffHeight,
      (WINDOW_Y * DPI * 0.5 - SETTINGS.staffPositionY) / SETTINGS.staffHeight
   )
   love.graphics.line(
      (WINDOW_X * DPI *  0.5 / SETTINGS.staffHeight),
      (WINDOW_Y * DPI * -1 - SETTINGS.staffPositionY) / SETTINGS.staffHeight,
      (WINDOW_X * DPI *  0.5 / SETTINGS.staffHeight),
      (WINDOW_Y * DPI *  1 - SETTINGS.staffPositionY) / SETTINGS.staffHeight
   )
   love.graphics.setColor(SETTINGS.colorScheme["print-color"])
end


function SETTINGS.clearSongContent()
	SETTINGS.songName = ""
	SETTINGS.currentClef = "G"
	SETTINGS.tempo = 120
	SETTINGS.timeSignature.numerator = 4
	SETTINGS.timeSignature.denominator = 4
	SETTINGS.sheetContent = {}
end


function SETTINGS.loadSong(songName, shouldClear, fileDropped)
	if songName == "" then warn("invalid song name") return end
	
	if shouldClear then
		SETTINGS.clearSongContent()
	end
	
	local songTable
	if not fileDropped then
		songTable = require("songs/" .. songName)
	else
		songTable = require(songName)
	end
	
	if not (songTable and songName) then
		error("Song \"" .. songName .. "\" not found")
	end
	
	if songTable.Name == SETTINGS.songName then return end
	SETTINGS.songName = songTable.Name

	love.window.setTitle(SETTINGS.songName .. " - Song")

	local currentNoteGroup = nil
	local minBeatDuration = math.huge
	
	-- the songTable is a table containing other tables with two values, one for the note and another for the duration
	for _, info in ipairs(songTable) do
		local newItem

		if info[1] == "start-group" and not currentNoteGroup then
			currentNoteGroup = STAFF_MODULES.noteGroup.new()
		end

		if info[1] == "end-group" and currentNoteGroup then
			table.insert(SETTINGS.sheetContent, currentNoteGroup)
			currentNoteGroup = nil
		end

		if info[1] == "note" then
			local newNote = STAFF_MODULES.note.new(info[2], info[3])
			minBeatDuration = math.min(minBeatDuration, newNote.beatDuration)

			if not currentNoteGroup or newNote.beatDuration >= 1 or not newNote.pitch then
				newItem = newNote
				if currentNoteGroup then
					table.insert(SETTINGS.sheetContent, currentNoteGroup)
					currentNoteGroup = nil
				end
			else
				table.insert(currentNoteGroup.children, newNote)
			end
		end

		--[
		if info[1] == "clef" then
         SETTINGS.currentClef = info[2]
      end

		if info[1] == "tempo" then
			SETTINGS.tempo = info[2]
		end

		if info[1] == "time-signature" then
			SETTINGS.timeSignature.numerator = info[2]
			SETTINGS.timeSignature.denominator = info[3]

			newItem = STAFF_MODULES.timeSignature.new(info[2], info[3])
		end
		--]]
		
		if newItem then
			table.insert(SETTINGS.sheetContent, newItem)
		end
	end

	--> Calculate the proper note spacing
	SETTINGS.noteSpacing = 0.305652 / minBeatDuration + 0.591304
end


function SETTINGS.loadSongNEW(songName, shouldClear, fileDropped)
			if songName == "" then
						warn("invalid song name")
						return
			end

			if shouldClear then
						SETTINGS.clearSongContent()
			end

			local songTable
			if not fileDropped then
						songTable = require("songs/" .. songName)
			else
						songTable = require(songName)
			end

			if not (songTable and songName) then
						error("Song \"" .. songName .. "\" not found")
			end

			if songTable.title == SETTINGS.songName then
						return
			end
			SETTINGS.songName = songTable.title

			love.window.setTitle(SETTINGS.songName .. " - Song")

			local minBeatDuration = math.huge

			for _, system in ipairs(songTable.systems) do
						for measureNumber, measure in ipairs(system) do
									if measureNumber == 1 and measure.info then
												for _, info in ipairs(measure.info) do
															SETTINGS.currentClef = info.clef or SETTINGS.currentClef or "G"
															SETTINGS.tempo = info.tempo or SETTINGS.tempo or 120

															if info.time then
																		SETTINGS.timeSignature.numerator = info.time[1]
																		SETTINGS.timeSignature.denominator = info.time[2]
															else
																		warn("Measure without time signature info found. Keeping previous time signature.")
															end
															local newItem = STAFF_MODULES.timeSignature.new(info[2], info[3])
															table.insert(SETTINGS.sheetContent, newItem)
												end
									end

									if measure.content then
												for _, voice in ipairs(measure.content) do
															local currentNoteGroup = nil

															for _, noteInfo in ipairs(voice) do
																		local newItem

																		if noteInfo.type == "start-group" and not currentNoteGroup then
																					currentNoteGroup = STAFF_MODULES.noteGroup.new()
																		end

																		if noteInfo.type == "end-group" and currentNoteGroup then
																					table.insert(SETTINGS.sheetContent, currentNoteGroup)
																					currentNoteGroup = nil
																		end

																		if noteInfo.type == "note" then
																					local newNote = STAFF_MODULES.note.new(noteInfo.pitches and noteInfo.pitches[1] or nil,
																									noteInfo.duration, noteInfo.articulation)
																					minBeatDuration = math.min(minBeatDuration, newNote.beatDuration)

																					if not currentNoteGroup or newNote.beatDuration >= 1 or not newNote.pitch then
																								newItem = newNote
																								if currentNoteGroup then
																											table.insert(SETTINGS.sheetContent, currentNoteGroup)
																											currentNoteGroup = nil
																								end
																					else
																								table.insert(currentNoteGroup.children, newNote)
																					end
																		end
																		if newItem then
																					table.insert(SETTINGS.sheetContent, newItem)
																		end
															end
												end
									end
						end
			end
			-- > Calculate the proper note spacing
			SETTINGS.noteSpacing = 0.305652 / minBeatDuration + 0.591304
end


function SETTINGS.drawSheetContent()
	SETTINGS.staffPositionY = SETTINGS.staffPositionYPercent * WINDOW_Y
	SETTINGS.staffHeight = SETTINGS.staffHeightPercent * WINDOW_Y

	love.graphics.translate(0, SETTINGS.staffPositionY)
   love.graphics.scale(SETTINGS.staffHeight)
   
   --> Drawing the staff lines
   love.graphics.setLineStyle("rough")
   love.graphics.setLineWidth(SETTINGS.lineWidth)
   love.graphics.setColor(SETTINGS.colorScheme["print-color"])

   for i = 1, 5, 1 do
      local y = SETTINGS.getYforLine(i)
      love.graphics.line(0, y, WINDOW_X, y)
   end
   love.graphics.setLineStyle("smooth")

   --> Drawing the clef
   love.graphics.draw(
      SPRITES[SETTINGS.currentClef .. "-clef"],
      SETTINGS.clefMargin, -- position x
      SETTINGS.getYforLine(SETTINGS.clefs[SETTINGS.currentClef].baseLine), -- position y
      0, -- rotation
      SETTINGS.clefs[SETTINGS.currentClef].drawScale, -- scale x
      nil, --scale y
      0, -- offset x
      SETTINGS.clefs[SETTINGS.currentClef].offsetY * SPRITES[SETTINGS.currentClef .. "-clef"]:getHeight() -- offset y
   )

   --> Drawing the sheet content
   local clefWidth = SETTINGS.clefWidth(SETTINGS.currentClef)

   love.graphics.setShader(SHADERS["gradient-cut"])
   SHADERS["gradient-cut"]:send("minX", (clefWidth + 2 * SETTINGS.clefMargin))
   SHADERS["gradient-cut"]:send("distance", SETTINGS.noteGradientDistance)
   SHADERS["gradient-cut"]:send("staffHeight", SETTINGS.staffHeight)
   --SHADERS.gradientCut:send("screenSize", {windowX, windowY})

   CAMERA:attach(0, 0, WINDOW_X, WINDOW_Y)

   local accidentals = {}
   local beatPosition = 0
	local lastBeatDuration = 1
	local screenSide = -1

	local defaultWhatToDraw = {}
	defaultWhatToDraw.drawHead = true
   defaultWhatToDraw.drawLedgerLines = false
   defaultWhatToDraw.drawAccidentals = false
   defaultWhatToDraw.drawStem = false
   defaultWhatToDraw.drawFlag = false
	defaultWhatToDraw.direction = 0

	local whatGotDrawn = defaultWhatToDraw

   for i, content in ipairs(SETTINGS.sheetContent) do
      if content.type == "note" and screenSide <= 0 then
         screenSide, whatGotDrawn = content:draw(beatPosition, accidentals, false)

         if content.pitch ~= nil then
            accidentals[content.pitch] = content.accidental
         end
			lastBeatDuration = content.beatDuration
         beatPosition = beatPosition + content.beatDuration * SETTINGS.timeSignature.denominator / 4

      elseif content.type == "noteGroup" and screenSide <= 0 then
         beatPosition, accidentals, lastBeatDuration = content:draw(beatPosition, accidentals)
			whatGotDrawn = defaultWhatToDraw

      elseif content.type == "timeSignature" then
         SETTINGS.timeSignature.numerator = content.numerator
         SETTINGS.timeSignature.denominator = content.denominator
         content:draw(beatPosition)
      end

      if beatPosition > 0 and beatPosition % SETTINGS.timeSignature.numerator == 0 then
         --> Measure reached
         SETTINGS.drawBar(beatPosition / SETTINGS.timeSignature.numerator, lastBeatDuration, whatGotDrawn)
         accidentals = {}
      end
   end

   love.graphics.setShader()
   CAMERA:detach()
   love.graphics.origin()
end


return SETTINGS