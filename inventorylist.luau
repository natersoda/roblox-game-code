local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer
local invFolder = player:WaitForChild("Inventory")
local RarityData = require(ReplicatedStorage:WaitForChild("RarityData"))

local frame = script.Parent
local template = frame:WaitForChild("Template")

local function refreshUI()
	-- 1. Clear current list (except template and UILayouts)
	for _, child in pairs(frame:GetChildren()) do
		if child:IsA("TextLabel") and child.Name ~= "Template" then
			child:Destroy()
		end
	end

	-- 2. Create new labels
	for _, item in pairs(invFolder:GetChildren()) do
		if item.Value > 0 then
			-- Look up the chance in your RarityData module
			local data = RarityData[item.Name]
			local chanceText = data and tostring(data.Chance) or "???"

			local newLabel = template:Clone()
			newLabel.Name = item.Name
			-- Corrected the text concatenation and property lookup
			newLabel.Text = item.Name .. " x" .. item.Value .. " (1 in " .. chanceText .. ")"

			-- Match the color from your data module
			if data and data.Color then
				newLabel.TextColor3 = data.Color
			end

			newLabel.Visible = true
			newLabel.Parent = frame
		end
	end
end

-- 3. LOGIC FOR UPDATES
-- Refresh when the inventory visibility changes
frame:GetPropertyChangedSignal("Visible"):Connect(function()
	if frame.Visible then
		refreshUI()
	end
end)

-- Refresh when a new rock type is added OR a count changes
local function setupListeners()
	for _, item in pairs(invFolder:GetChildren()) do
		item.Changed:Connect(refreshUI)
	end
end

invFolder.ChildAdded:Connect(function(newItem)
	newItem.Changed:Connect(refreshUI)
	refreshUI()
end)

-- Initial setup
setupListeners()
if frame.Visible then refreshUI() end