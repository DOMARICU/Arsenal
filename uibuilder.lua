local ui = require(script.Parent.ModuleScript)
local backend = require(script.Parent.backend)


local function builder()
	local window = ui.new({
		title = "Demo UI",
		borderColor = Color3.fromRGB(255, 0, 0),
		backgroundColor = Color3.fromRGB(40, 40, 40),
		textColor = Color3.fromRGB(255, 255, 255),
		warnings = true
	})

	local ragetab = window:AddTab("RAGE")
	
	ragetab:AddToggle({
		title = "Enable Aimbot",
		callback = function(state)
			backend.SetAimbot(state)
		end,
	})
	
	ragetab:AddToggle({
		title = "Enable Wallcheck",
		callback = function(state)
			backend.SetIgnoreWalls(state)
		end,
	})
	
	ragetab:CreateSlider({
		Name = "FOV CIRCLE",
		Range = {0, 350},
		Increment = 10,
		Suffix = "FOV CIRCLE",
		CurrentValue = 1,
		Callback = function(Value)
			backend.UpdateFOVCircleSize(Value)
		end,
	})

	window:End()
end

builder()
