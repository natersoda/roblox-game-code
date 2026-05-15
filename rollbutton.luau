local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 1. Define Variables
local button = script.Parent
local gui = button:FindFirstAncestorOfClass("ScreenGui")
local textLabel = button:FindFirstChildOfClass("TextLabel")
local remote = ReplicatedStorage:WaitForChild("RollRequest")

-- Access the Fast Rolls setting
local settingsFolder = button.Parent:WaitForChild("Settings")
local fastRolls = settingsFolder:WaitForChild("FastRolls")

-- 2. Setup Sizing (Absolute Targets)
local originalSize = button.Size 
local pressedSize = UDim2.new(
	originalSize.X.Scale * 0.9, originalSize.X.Offset, 
	originalSize.Y.Scale * 0.9, originalSize.Y.Offset
)

local isRolling = false

-- 3. Animation Logic (Tweens)
local pressInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local releaseInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Spin and Jiggle Parameters
local spinInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local jiggleInfo = TweenInfo.new(0.05, Enum.EasingStyle.Bounce, Enum.EasingDirection.InOut, 0, true)

-- Squish Functions
local function animatePress()
	-- Prevent squishing if the Slot Machine is already spinning
	if gui:GetAttribute("IsRolling") then return end

	TweenService:Create(button, pressInfo, {Size = pressedSize}):Play()
	if textLabel then
		local stroke = textLabel:FindFirstChildOfClass("UIStroke")
		if stroke then TweenService:Create(stroke, pressInfo, {Thickness = 3}):Play() end
	end
end

local function animateRelease()
	TweenService:Create(button, releaseInfo, {Size = originalSize}):Play()
	if textLabel then
		local stroke = textLabel:FindFirstChildOfClass("UIStroke")
		if stroke then stroke.Thickness = 1.5 end -- Instant reset for crispness
	end
end

-- Roll Animation (Refactored to be Non-Blocking)
local function playRollAnimation()
	-- Shake the rock slightly
	TweenService:Create(button, jiggleInfo, {Rotation = 5}):Play()

	-- Perform a full 360° spin
	button.Rotation = 0
	local spin = TweenService:Create(button, spinInfo, {Rotation = 360})
	spin:Play()

	-- We removed the .Completed:Wait() so the script continues immediately
end

-- 4. Connection Logic
button.MouseButton1Down:Connect(animatePress)

button.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		animateRelease()
	end
end)

-- 5. The Core Roll Function
button.MouseButton1Click:Connect(function()
	-- Check if the Slot Machine (ResultLabel) is currently busy
	if gui:GetAttribute("IsRolling") then 
		return 
	end

	if isRolling then return end
	isRolling = true

	-- FIRE SIGNAL IMMEDIATELY: Starts the server-side logic and Label reel
	remote:FireServer()

	-- PLAY ANIMATION IMMEDIATELY: Now happens in parallel with the roll
	if not fastRolls.Value then
		playRollAnimation()
	end

	-- Dynamic Cooldown
	local cooldown = fastRolls.Value and 0.05 or 0.2
	task.wait(cooldown)

	isRolling = false
end)