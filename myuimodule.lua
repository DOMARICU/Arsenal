local ui = {}

local function accscan()
	local success, result = pcall(function()
		local testGui = Instance.new("ScreenGui")
		testGui.Parent = game:GetService("CoreGui")
		testGui:Destroy()
		return game:GetService("CoreGui")
	end)

	if success then
		return result
	else
		warn("CoreGui is not available. UI is created in PlayerGui!")
		warn("(Uncertain and possibly recognizable)")
		return game.Players.LocalPlayer:WaitForChild("PlayerGui")
	end
end

function setDraggable(dragHandle, container)
	local UIS = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")

	local dragging, dragStart, startPos, dragConnection
	local target = container or dragHandle

	assert(dragHandle, "setDraggable: 'dragHandle' is required")
	assert(target, "setDraggable: 'container' or 'dragHandle' must be provided")
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			dragConnection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					dragConnection:Disconnect()
				end
			end)
		end
	end)

	-- Maus bewegt
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart

			RunService.RenderStepped:Wait()
			target.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end


function rd()
	local maxlength = 15
	local characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local randomName = ""

	for i = 1, maxlength do
		local randomIndex = math.random(1, #characters)
		randomName = randomName .. string.sub(characters, randomIndex, randomIndex)
	end

	return randomName
end 

local function checkAndDeleteExistingUI(parent, uiName)
	local existingUI = parent:FindFirstChild(uiName)

	if parent and uiName then print("Variablen wurden erfolgreich übergeben!") else print("UNKNOWN ERROR!")end

	if existingUI then existingUI:Destroy() end
end

function ui.new(config)
	local self = {}
	self.title = config.title or "New Window"
	self.tabs = {}
	self.activeTab = nil
	self.borderColor = config.borderColor or Color3.fromRGB(255, 0, 0)
	self.backgroundColor = config.backgroundColor or Color3.fromRGB(40, 40, 40)
	self.textColor = config.textColor or Color3.fromRGB(255, 255, 255)
	self.warnings = config.warnings or false



	function self:Begin()
		local parent = accscan()
		checkAndDeleteExistingUI(parent, self.title)

		local ScreenGui = Instance.new("ScreenGui")
		ScreenGui.Name = self.title
		ScreenGui.Parent = parent

		local MainFrame = Instance.new("Frame")
		MainFrame.Size = UDim2.new(0, 700, 0, 500)
		MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
		MainFrame.BackgroundColor3 = self.backgroundColor
		MainFrame.BorderSizePixel = 0
		MainFrame.Name = rd()
		MainFrame.Parent = ScreenGui

		local frameCorner = Instance.new("UICorner")
		frameCorner.CornerRadius = UDim.new(0, 10)
		frameCorner.Parent = MainFrame



		local Border = Instance.new("UIStroke")
		Border.Name = rd()
		Border.Color = self.borderColor
		Border.Thickness = 2
		Border.Parent = MainFrame

		local TitleBar = Instance.new("TextLabel")
		TitleBar.Name = rd()
		TitleBar.Text = self.title
		TitleBar.Size = UDim2.new(1, 0, 0, 40)
		TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		TitleBar.TextColor3 = self.textColor
		TitleBar.Font = Enum.Font.GothamBold
		TitleBar.TextSize = 18
		TitleBar.TextXAlignment = Enum.TextXAlignment.Center
		TitleBar.Parent = MainFrame

		local titleCorner = Instance.new("UICorner")
		titleCorner.CornerRadius = UDim.new(0, 10)
		titleCorner.Parent = TitleBar

		local SidePanel = Instance.new("Frame")
		SidePanel.Name = rd()
		SidePanel.Size = UDim2.new(0, 200, 1, -40)
		SidePanel.Position = UDim2.new(0, 0, 0, 40)
		SidePanel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		SidePanel.BorderSizePixel = 0
		SidePanel.Parent = MainFrame

		local sideCorner = Instance.new("UICorner")
		sideCorner.CornerRadius = UDim.new(0, 10)
		sideCorner.Parent = SidePanel

		local ContentArea = Instance.new("Frame")
		ContentArea.Name = rd()
		ContentArea.Size = UDim2.new(1, -200, 1, -40)
		ContentArea.Position = UDim2.new(0, 200, 0, 40)
		ContentArea.BackgroundColor3 = self.backgroundColor
		ContentArea.BorderSizePixel = 0
		ContentArea.ClipsDescendants = true
		ContentArea.Parent = MainFrame

		local contentCorner = Instance.new("UICorner")
		contentCorner.CornerRadius = UDim.new(0, 10)
		contentCorner.Parent = ContentArea

		local contentShadow = Instance.new("ImageLabel")
		contentShadow.Name = "Shadow"
		contentShadow.Size = UDim2.new(1, 30, 1, 30)
		contentShadow.Position = UDim2.new(0, -15, 0, -15)
		contentShadow.Image = "rbxassetid://1316045217"
		contentShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
		contentShadow.ImageTransparency = 0.9
		contentShadow.ScaleType = Enum.ScaleType.Slice
		contentShadow.SliceCenter = Rect.new(10, 10, 118, 118)
		contentShadow.BackgroundTransparency = 1
		contentShadow.ZIndex = 0
		contentShadow.Parent = ContentArea

		setDraggable(TitleBar, MainFrame)

		self.MainFrame = MainFrame
		self.SidePanel = SidePanel
		self.ContentArea = ContentArea
	end

	function self:AddTab(tabTitle)
		print("Aktuelle Anzahl der Tabs: " .. tostring(#self.tabs))
		if #self.tabs >= 5 then
			warn("Maximum of 5 tabs allowed!")
			return nil
		end

		local tab = {}
		tab.title = tabTitle
		tab.elements = {}

		if not self.SidePanel:FindFirstChild("TabLayout") then
			local TabLayout = Instance.new("UIListLayout")
			TabLayout.Name = "TabLayout"
			TabLayout.Padding = UDim.new(0, 10)
			TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
			TabLayout.Parent = self.SidePanel
		end

		local TabButton = Instance.new("TextButton")
		TabButton.Name = rd()
		TabButton.Text = tab.title
		TabButton.Size = UDim2.new(1, -20, 0, 40)
		TabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		TabButton.TextColor3 = self.textColor or Color3.fromRGB(255, 255, 255)
		TabButton.Font = Enum.Font.Gotham
		TabButton.TextSize = 14
		TabButton.Parent = self.SidePanel

		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 8)
		buttonCorner.Parent = TabButton

		local hoverEffect = Instance.new("UIStroke")
		hoverEffect.Color = Color3.fromRGB(100, 150, 255)
		hoverEffect.Thickness = 0
		hoverEffect.Parent = TabButton

		TabButton.MouseEnter:Connect(function()
			hoverEffect.Thickness = 2
		end)
		TabButton.MouseLeave:Connect(function()
			hoverEffect.Thickness = 0
		end)

		local TabFrame = Instance.new("ScrollingFrame")
		TabFrame.Name = rd()
		TabFrame.Size = UDim2.new(1, -10, 1, -10)
		TabFrame.Position = UDim2.new(0, 5, 0, 5)
		TabFrame.BackgroundColor3 = self.backgroundColor
		TabFrame.BorderSizePixel = 0
		TabFrame.ScrollBarThickness = 8
		TabFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 255)
		TabFrame.Visible = false
		TabFrame.ClipsDescendants = true
		TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		TabFrame.Parent = self.ContentArea
		tab.frame = TabFrame

		local TabContentLayout = Instance.new("UIListLayout")
		TabContentLayout.Padding = UDim.new(0, 10)
		TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
		TabContentLayout.Parent = TabFrame

		TabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			TabFrame.CanvasSize = UDim2.new(0, 0, 0, TabContentLayout.AbsoluteContentSize.Y + 10)
		end)

		TabButton.MouseButton1Click:Connect(function()
			if self.activeTab and self.activeTab.frame then
				self.activeTab.frame.Visible = false
				local currentIndex = table.find(self.tabs, self.activeTab)
				local newIndex = table.find(self.tabs, tab)
				local slideOutDirection = (newIndex > currentIndex) and 1 or -1

				self.activeTab.frame:TweenPosition(
					UDim2.new(0, 0, slideOutDirection, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quad,
					0.3,
					true
				)

				task.wait(0.3)
				self.activeTab.frame.Visible = false
			end

			if TabFrame then
				local slideInDirection = (self.activeTab and table.find(self.tabs, self.activeTab) < table.find(self.tabs, tab)) and 1 or -1
				TabFrame.Position = UDim2.new(0, 0, slideInDirection, 0)
				TabFrame.Visible = true
				TabFrame:TweenPosition(
					UDim2.new(0, 0, 0, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quad,
					0.3,
					true
				)
			else
				self:Warner("TabFrame not found for " .. tabTitle)
			end

			for _, t in ipairs(self.tabs) do
				if t.button then
					t.button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
					t.button.TextColor3 = Color3.fromRGB(200, 200, 200)
				end
			end

			TabButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
			TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)

			self.activeTab = tab
		end)

		table.insert(self.tabs, {
			frame = TabFrame,
			button = TabButton
		})

		function tab:AddButton(buttonConfig)
			if not buttonConfig or type(buttonConfig) ~= "table" then
				warn("Invalid buttonConfig passed to AddButton!")
				return
			end

			local button = Instance.new("TextButton")
			button.Name = rd()
			button.Text = buttonConfig.title or "Button"
			button.Size = UDim2.new(1, -10, 0, 40)
			button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			button.TextColor3 = self.textColor or Color3.fromRGB(255, 255, 255)
			button.Font = Enum.Font.Gotham
			button.TextSize = 16
			button.Parent = TabFrame

			local buttonCorner = Instance.new("UICorner")
			buttonCorner.CornerRadius = UDim.new(0, 8)
			buttonCorner.Parent = button

			if buttonConfig.callback then
				button.MouseButton1Click:Connect(buttonConfig.callback)
			end

			table.insert(tab.elements, button)
		end

		function tab:AddToggle(toggleConfig)
			if not toggleConfig or type(toggleConfig) ~= "table" then
				warn("Invalid toggleConfig passed to AddToggle!")
				return
			end

			local toggleContainer = Instance.new("Frame")
			toggleContainer.Size = UDim2.new(1, -10, 0, 40)
			toggleContainer.BackgroundTransparency = 1
			toggleContainer.Parent = tab.frame

			local toggleLabel = Instance.new("TextLabel")
			toggleLabel.Text = toggleConfig.title or "Toggle"
			toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
			toggleLabel.BackgroundTransparency = 1
			toggleLabel.TextColor3 = config.textColor or Color3.fromRGB(255, 255, 255)
			toggleLabel.Font = Enum.Font.Gotham
			toggleLabel.TextSize = 14
			toggleLabel.Parent = toggleContainer

			local switch = Instance.new("Frame")
			switch.Size = UDim2.new(0, 60, 0, 30)
			switch.Position = UDim2.new(0.8, 0, 0.5, -15)
			switch.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			switch.BorderSizePixel = 0
			switch.Parent = toggleContainer

			local switchCorner = Instance.new("UICorner")
			switchCorner.CornerRadius = UDim.new(0, 15)
			switchCorner.Parent = switch

			local knob = Instance.new("Frame")
			knob.Size = UDim2.new(0, 25, 0, 25)
			knob.Position = UDim2.new(0, 2, 0, 2)
			knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			knob.Parent = switch

			local knobCorner = Instance.new("UICorner")
			knobCorner.CornerRadius = UDim.new(0, 12)
			knobCorner.Parent = knob

			local knobShadow = Instance.new("UIStroke")
			knobShadow.Thickness = 2
			knobShadow.Color = Color3.fromRGB(0, 0, 0)
			knobShadow.Transparency = 0.5
			knobShadow.Parent = knob

			local on = toggleConfig.Currentvalue or false

			local function updateToggleVisual()
				knob:TweenPosition(
					UDim2.new(on and 1 or 0, on and -27 or 2, 0, 2),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quad,
					0.3,
					true
				)
				switch.BackgroundColor3 = on and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 100, 100)
			end

			updateToggleVisual()

			switch.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					on = not on
					updateToggleVisual()
					if toggleConfig.callback then
						toggleConfig.callback(on)
					end
				end
			end)

			table.insert(tab.elements, toggleContainer)
		end

		function tab:AddTextBox(textBoxConfig)
			if not textBoxConfig or type(textBoxConfig) ~= "table" then
				warn("Invalid textBoxConfig passed to AddTextBox!")
				return
			end

			local textBoxContainer = Instance.new("Frame")
			textBoxContainer.Name = rd()
			textBoxContainer.Size = UDim2.new(1, -20, 0, 60)
			textBoxContainer.BackgroundTransparency = 1
			textBoxContainer.Parent = tab.frame

			local textBoxLabel = Instance.new("TextLabel")
			textBoxLabel.Name = rd()
			textBoxLabel.Text = textBoxConfig.text or "Text Box"
			textBoxLabel.Size = UDim2.new(1, -20, 0, 20)
			textBoxLabel.Position = UDim2.new(0, 10, 0, 0)
			textBoxLabel.BackgroundTransparency = 1
			textBoxLabel.TextColor3 = config.textColor or Color3.fromRGB(255, 255, 255)
			textBoxLabel.Font = Enum.Font.Gotham
			textBoxLabel.TextSize = 14
			textBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
			textBoxLabel.Parent = textBoxContainer

			local textBox = Instance.new("TextBox")
			textBox.Name = rd()
			textBox.PlaceholderText = textBoxConfig.placeholder or "Enter text here"
			textBox.Size = UDim2.new(1, -20, 0, 30)
			textBox.Position = UDim2.new(0, 10, 0, 25)
			textBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			textBox.TextColor3 = config.textColor or Color3.fromRGB(255, 255, 255)
			textBox.Font = Enum.Font.Gotham
			textBox.TextSize = 14
			textBox.ClearTextOnFocus = true
			textBox.TextXAlignment = Enum.TextXAlignment.Center
			textBox.TextYAlignment = Enum.TextYAlignment.Center
			textBox.Text = ""
			textBox.Parent = textBoxContainer

			local textBoxCorner = Instance.new("UICorner")
			textBoxCorner.CornerRadius = UDim.new(0, 8)
			textBoxCorner.Parent = textBox

			local hoverEffect = Instance.new("UIStroke")
			hoverEffect.Color = Color3.fromRGB(150, 150, 255)
			hoverEffect.Thickness = 0
			hoverEffect.Transparency = 0.8
			hoverEffect.Parent = textBox

			textBox.MouseEnter:Connect(function()
				hoverEffect.Thickness = 2
			end)
			textBox.MouseLeave:Connect(function()
				hoverEffect.Thickness = 0
			end)

			textBox.Focused:Connect(function()
				textBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			end)
			textBox.FocusLost:Connect(function(enterPressed)
				textBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
				if enterPressed and textBoxConfig.callback then
					textBoxConfig.callback(textBox.Text)
				end
			end)

			local dummyPlaceholder = Instance.new("TextLabel")
			dummyPlaceholder.Text = textBox.PlaceholderText
			dummyPlaceholder.Font = textBox.Font
			dummyPlaceholder.TextSize = textBox.TextSize
			dummyPlaceholder.TextColor3 = Color3.fromRGB(200, 200, 200)
			dummyPlaceholder.Size = textBox.Size
			dummyPlaceholder.Position = textBox.Position
			dummyPlaceholder.BackgroundTransparency = 1
			dummyPlaceholder.ZIndex = textBox.ZIndex - 1
			dummyPlaceholder.TextXAlignment = Enum.TextXAlignment.Center
			dummyPlaceholder.TextYAlignment = Enum.TextYAlignment.Center
			dummyPlaceholder.Parent = textBoxContainer

			textBox.Changed:Connect(function()
				dummyPlaceholder.Visible = (textBox.Text == "")
			end)

			table.insert(tab.elements, textBoxContainer)
		end

		function tab:CreateSlider(config)
			if not config or type(config) ~= "table" then
				warn("Invalid config passed to CreateSlider!")
				return
			end

			local sliderID = config.ID or "Slider_" .. tostring(math.random(1000, 9999))
			local sliderName = config.Name or "Slider"
			local range = config.Range or {0, 100}
			local increment = config.Increment or 1
			local suffix = config.Suffix or ""
			local currentValue = config.CurrentValue or range[1]

			local sliderContainer = Instance.new("Frame")
			sliderContainer.Name = sliderID
			sliderContainer.Size = UDim2.new(1, -10, 0, 70)
			sliderContainer.BackgroundTransparency = 1
			sliderContainer.Parent = tab.frame

			local sliderLabel = Instance.new("TextLabel")
			sliderLabel.Text = sliderName .. ": " .. currentValue .. " " .. suffix
			sliderLabel.Size = UDim2.new(1, -20, 0, 20)
			sliderLabel.Position = UDim2.new(0, 10, 0, 5)
			sliderLabel.BackgroundTransparency = 1
			sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			sliderLabel.Font = Enum.Font.GothamBold
			sliderLabel.TextSize = 16
			sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
			sliderLabel.Parent = sliderContainer

			local sliderBar = Instance.new("Frame")
			sliderBar.Size = UDim2.new(1, -20, 0, 8)
			sliderBar.Position = UDim2.new(0, 10, 0, 35)
			sliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			sliderBar.Parent = sliderContainer

			local sliderBarCorner = Instance.new("UICorner")
			sliderBarCorner.CornerRadius = UDim.new(0, 10)
			sliderBarCorner.Parent = sliderBar

			local sliderFill = Instance.new("Frame")
			sliderFill.Size = UDim2.new((currentValue - range[1]) / (range[2] - range[1]), 0, 1, 0)
			sliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
			sliderFill.Parent = sliderBar

			local sliderFillCorner = Instance.new("UICorner")
			sliderFillCorner.CornerRadius = UDim.new(0, 10)
			sliderFillCorner.Parent = sliderFill

			local sliderKnob = Instance.new("Frame")
			sliderKnob.Size = UDim2.new(0, 20, 0, 20)
			sliderKnob.Position = UDim2.new((currentValue - range[1]) / (range[2] - range[1]), -10, 0.5, -10)
			sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			sliderKnob.Parent = sliderBar

			local sliderKnobCorner = Instance.new("UICorner")
			sliderKnobCorner.CornerRadius = UDim.new(0, 10)
			sliderKnobCorner.Parent = sliderKnob

			local UIS = game:GetService("UserInputService")
			local dragging = false

			local function updateSlider(input)
				local barStart = sliderBar.AbsolutePosition.X
				local barEnd = barStart + sliderBar.AbsoluteSize.X
				local mousePos = math.clamp(input.Position.X, barStart, barEnd)
				local percentage = (mousePos - barStart) / sliderBar.AbsoluteSize.X
				local newValue = math.floor((percentage * (range[2] - range[1]) + range[1]) / increment) * increment

				sliderKnob.Position = UDim2.new((newValue - range[1]) / (range[2] - range[1]), -10, 0.5, -10)
				sliderFill.Size = UDim2.new((newValue - range[1]) / (range[2] - range[1]), 0, 1, 0)
				sliderLabel.Text = sliderName .. ": " .. newValue .. " " .. suffix

				if config.Callback then
					config.Callback(newValue)
				end
			end

			sliderKnob.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
				end
			end)

			UIS.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			UIS.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					if sliderBar.AbsolutePosition.X <= input.Position.X and input.Position.X <= sliderBar.AbsolutePosition.X + sliderBar.AbsoluteSize.X then
						updateSlider(input)
					end
				end
			end)

			table.insert(tab.elements, sliderContainer)
		end

		table.insert(self.tabs, tab)
		return tab
	end

	function self:End()
		print("UI erstellt: " .. self.title)
	end

	self:Begin()
	return self
end

return ui
