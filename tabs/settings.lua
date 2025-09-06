local settings = {}

local tabBarIndex = 1


function settings.update(dt)
   
end


function settings.draw()
   love.graphics.setBackgroundColor(SETTINGS.colorScheme["background-color"])
   SETTINGS.drawSheetContent()

   UI.Begin("Settings", 20, 20)

   local clicked = UI.Button(" < ")
   UI.SameLine()
   if clicked then
      if SETTINGS.songName then
         SETTINGS.camera.velocityX = 0
         SETTINGS.currentTab = TABS["sheet"]
      else
         SETTINGS.currentTab = TABS["song-selector"]
      end
      UI.End()
      UI.RenderFrame()
      return
   end
   
	local clicked, idx = UI.TabBar("my tab bar", { "Colors", "Sizes", "Camera" }, tabBarIndex)
	if clicked then
		tabBarIndex = idx
	end
	if tabBarIndex == 1 then
      if UI.CheckBox("Colorful Notes", state) then
         state = not state
         SETTINGS.colorfulNotes = state
      end

      local schemeNames = {}
      local schemePointers = {}
      local index = 1
      for _, scheme in pairs(SCHEMES) do
         schemeNames[index] = scheme.Name
         schemePointers[index] = scheme
         index = index + 1
      end

      local clicked, index = UI.ListBox("Color Scheme", math.min(#schemeNames, 15), 28, schemeNames)
      if clicked then
         SETTINGS.colorScheme = schemePointers[index]
      end
   elseif tabBarIndex == 2 then
      local sliderSize = 0.35 * WINDOW_X
      SETTINGS.noteSpacing = UI.SliderFloat("Note Spacing", SETTINGS.noteSpacing, 0.75, 4, sliderSize, 2)
      SETTINGS.staffHeightPercent = UI.SliderInt("Staff Size", SETTINGS.staffHeightPercent * 100, 5, 50, sliderSize) / 100
      SETTINGS.staffPositionYPercent = UI.SliderInt("Staff Height", SETTINGS.staffPositionYPercent * 100, 20, 80, sliderSize) / 100
      SETTINGS.barOffset = UI.SliderInt("Bar Offset", SETTINGS.barOffset * 100, 0, 100, sliderSize, "How much to offset the\nmeasure bar to the left") / 100
      SETTINGS.extraLineLengthScale = UI.SliderInt("Ledger Line Scale", (SETTINGS.extraLineLengthScale - 1) * 100, 25, 150, sliderSize) / 100 + 1
      SETTINGS.timeSignatureScale = UI.SliderInt("Time Signature Scale", SETTINGS.timeSignatureScale * 100, 40, 150, sliderSize) / 100
   end

   local sizeX, sizeY = UI.GetWindowSize("Settings")
   UI.SetWindowPosition("Settings", WINDOW_X - sizeX - 20, 20)
   
   UI.End()
	UI.RenderFrame()
end



return settings