local TweenService = game:GetService("TweenService")
local button = script.Parent

-- 1. REFERENCES
local settings = button.Parent:WaitForChild("Settings")
local fastRolls = settings:WaitForChild("FastRolls")

-- 2. COLOR DEFINITIONS
local GREEN_ON = Color3.fromRGB(85, 255, 127)
local RED_OFF = Color3.fromRGB(255, 85, 127)
local TWEEN_TIME = 0.25

-- 3. UPDATE FUNCTION
local function updateVisuals(isFast)
	local targetColor = isFast and GREEN_ON or RED_OFF
	local targetText = isFast and "FAST ROLL: ON" or "FAST ROLL: OFF"

	-- Smoothly fade the background color
	local colorTween = TweenService:Create(button, TweenInfo.new(TWEEN_TIME), {
		BackgroundColor3 = targetColor
	})

	button.Text = targetText
	colorTween:Play()
end

-- 4. TOGGLE LOGIC
button.MouseButton1Click:Connect(function()
	-- Flip the value
	fastRolls.Value = not fastRolls.Value
end)

-- 5. LISTEN FOR CHANGES
-- This ensures the button updates even if the setting is changed by another script
fastRolls.Changed:Connect(updateVisuals)

-- Initialize the button state on join
updateVisuals(fastRolls.Value)