local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RarityData = require(ReplicatedStorage:WaitForChild("RarityData"))
local overheadTemplate = ServerStorage:WaitForChild("Overhead")

game.Players.PlayerAdded:Connect(function(player)
	print("System: Player " .. player.Name .. " joined. Waiting for character...")

	player.CharacterAdded:Connect(function(character)
		local head = character:WaitForChild("Head")
		local newOverhead = overheadTemplate:Clone()
		local display = newOverhead.RarityDisplay

		-- Ensure UIStroke exists for that black outline look
		local stroke = display:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
		stroke.Thickness = 2
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		stroke.Parent = display

		newOverhead.Parent = head
		newOverhead.Adornee = head

		-- Look for the Value we created in the leaderboard script
		local bestValue = player:WaitForChild("BestRarity", 10) 

		if not bestValue then
			warn("CRITICAL: BestRarity Value not found for " .. player.Name)
			display.Text = "Data Loading Error"
			return
		end

		local function updateOverhead()
			local best = bestValue.Value
			print("System: Updating overhead for " .. player.Name .. " to " .. best)

			if best == "None" or not RarityData[best] then
				display.Text = "No Rolls Yet"
				display.TextColor3 = Color3.fromRGB(255, 255, 255)
				stroke.Color = Color3.fromRGB(0,0,0)
			else
				local chance = RarityData[best].Chance
				display.Text = "" .. best .. " (1 in " .. tostring(chance) .. ")"
				display.TextColor3 = Color3.fromRGB(255, 255, 255)
				stroke.Color = RarityData[best].Color
			end
		end

		-- Initial Run
		updateOverhead()

		-- Listen for future changes
		bestValue.Changed:Connect(updateOverhead)
	end)
end)