local button = script.Parent
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- This searches the entire UI for the frame named "inventory view"
local function findFrame(name)
	return playerGui:FindFirstChild(name, true) 
end

local frame = findFrame("inventory view")

button.MouseButton1Click:Connect(function()
	print("Click detected on: " .. button.Name)

	if frame then
		frame.Visible = not frame.Visible
		print("Frame is now: " .. tostring(frame.Visible))
	else
		-- This will tell us if the script still can't find the frame
		warn("Still can't find 'inventory view'! Check the name spelling.")
	end
end)