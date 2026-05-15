game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
-- LocalScript inside the TextLabel
local label = script.Parent
local player = game.Players.LocalPlayer

-- We need to wait for the leaderstats to exist when the player joins
local leaderstats = player:WaitForChild("leaderstats")
local clicksValue = leaderstats:WaitForChild("Pebbles")

-- Function to update the text
local function updateDisplay()
	label.Text = "" .. tostring(clicksValue.Value)
end

-- 1. Run it once immediately so it doesn't start at "Label"
updateDisplay()

-- 2. "Listen" for changes. Every time Value changes, run the function.
clicksValue.Changed:Connect(updateDisplay)