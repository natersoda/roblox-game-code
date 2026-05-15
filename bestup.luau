local label = script.Parent
local player = game.Players.LocalPlayer
local bestValue = player:WaitForChild("BestRarity")

local function update()
	label.Text = "Best Roll: " .. bestValue.Value
end

update()
bestValue.Changed:Connect(update)