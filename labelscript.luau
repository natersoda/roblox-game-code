local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local label = script.Parent
local gui = label:FindFirstAncestorOfClass("ScreenGui")
local remote = ReplicatedStorage:WaitForChild("RollRequest")
local settingsFolder = gui:WaitForChild("Settings")
local fastRolls = settingsFolder:WaitForChild("FastRolls")

-- 1. FAKE TITLES POOL
local FAKE_TITLES = {
	-- BASIC (1 - 10)
	{Name = "Sandstone", Odds = "2", Color = Color3.fromRGB(163, 162, 165)},
	{Name = "Shale", Odds = "3", Color = Color3.fromRGB(105, 105, 105)},
	{Name = "Claystone", Odds = "5", Color = Color3.fromRGB(139, 69, 19)},
	{Name = "Pyrite", Odds = "10", Color = Color3.fromRGB(245, 222, 179)},

	-- UNCOMMON (10 - 100)
	{Name = "Coal", Odds = "30", Color = Color3.fromRGB(25, 25, 25)},
	{Name = "Graphite", Odds = "50", Color = Color3.fromRGB(50, 50, 50)},
	{Name = "Marble", Odds = "75", Color = Color3.fromRGB(220, 220, 220)},
	{Name = "Quartz", Odds = "100", Color = Color3.fromRGB(255, 255, 255)},

	-- RARE (100 - 1,000)
	{Name = "Fluorite", Odds = "150", Color = Color3.fromRGB(127, 255, 212)},
	{Name = "Lapis Lazuli", Odds = "250", Color = Color3.fromRGB(0, 71, 171)},
	{Name = "Malachite", Odds = "400", Color = Color3.fromRGB(14, 77, 14)},
	{Name = "Amethyst", Odds = "500", Color = Color3.fromRGB(153, 102, 204)},
	{Name = "Amber", Odds = "750", Color = Color3.fromRGB(255, 191, 0)},
	{Name = "Platinum", Odds = "1,000", Color = Color3.fromRGB(229, 228, 226)},

	-- EPIC (1,000 - 10,000)
	{Name = "Bismuth", Odds = "1,500", Color = Color3.fromRGB(160, 255, 255)},
	{Name = "Gold", Odds = "2,000", Color = Color3.fromRGB(255, 215, 0)},
	{Name = "Ruby", Odds = "2,500", Color = Color3.fromRGB(255, 50, 50)},
	{Name = "Jade", Odds = "3,500", Color = Color3.fromRGB(173, 255, 47)},
	{Name = "Sapphire", Odds = "5,000", Color = Color3.fromRGB(50, 100, 255)},
	{Name = "Emerald", Odds = "7,500", Color = Color3.fromRGB(80, 200, 120)},

	-- LEGENDARY (10,000 - 100,000)
	{Name = "Topaz", Odds = "12,500", Color = Color3.fromRGB(255, 200, 50)},
	{Name = "Tanzanite", Odds = "18,000", Color = Color3.fromRGB(100, 100, 255)},
	{Name = "Diamond", Odds = "25,000", Color = Color3.fromRGB(185, 242, 255)},
	{Name = "Meteorite", Odds = "45,000", Color = Color3.fromRGB(120, 90, 80)},
	{Name = "Black Opal", Odds = "75,000", Color = Color3.fromRGB(70, 0, 150)},
	{Name = "Opal", Odds = "100,000", Color = Color3.fromRGB(230, 230, 250)},

	-- MYTHIC & BEYOND (100,000 - 1,000,000+)
	{Name = "Stardust", Odds = "250,000", Color = Color3.fromRGB(255, 255, 150)},
	{Name = "Void Stone", Odds = "500,000", Color = Color3.fromRGB(20, 20, 30)},
	{Name = "Celestial", Odds = "750,000", Color = Color3.fromRGB(130, 200, 255)},
	{Name = "Vinny", Odds = "1,000,000", Color = Color3.fromRGB(100, 0, 0)},
	{Name = "Galaxy", Odds = "2,500,000", Color = Color3.fromRGB(180, 100, 255)},
}

-- 2. STATE TRACKING
local latestRollId = 0 
local rollSound = SoundService:WaitForChild("RollSound")
local fadeTween, strokeFadeTween = nil, nil

local fastPopInfo = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local slowPopInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

remote.OnClientEvent:Connect(function(rarityName, rarityColor, rarityChance)
	latestRollId += 1
	local thisRollId = latestRollId 

	if fadeTween then fadeTween:Cancel() end
	if strokeFadeTween then strokeFadeTween:Cancel() end

	label.TextTransparency = 0
	label.Visible = true
	local stroke = label:FindFirstChildOfClass("UIStroke")
	if stroke then 
		stroke.Transparency = 0 
		stroke.Color = Color3.fromRGB(0,0,0) -- LOCKED TO BLACK
	end

	gui:SetAttribute("IsRolling", true)

	-- 3. INTERACTION BRANCHING
	if fastRolls.Value then
		label.Text = rarityChance and rarityName .. " (1 in " .. tostring(rarityChance) .. ")" or rarityName
		label.TextColor3 = rarityColor

		-- Scale Punch only (No color flash)
		label.Size = UDim2.fromScale(0.3, 0.04) 
		TweenService:Create(label, fastPopInfo, {Size = UDim2.fromScale(0.8, 0.1)}):Play()

	elseif not fastRolls.Value and rarityChance then
		local spinAmount = math.random(14, 20)
		for i = 1, spinAmount do
			if thisRollId ~= latestRollId then return end 
			local fake = FAKE_TITLES[math.random(1, #FAKE_TITLES)]
			label.Text = fake.Name .. " (1 in " .. fake.Odds .. ")"
			label.TextColor3 = fake.Color

			local blurLevel = i < (spinAmount * 0.6) and 0.4 or 0
			label.TextTransparency = blurLevel
			if stroke then stroke.Transparency = blurLevel end

			rollSound.PlaybackSpeed = 1.4 + (i / spinAmount)
			rollSound:Play()
			task.wait(0.03 + (i / spinAmount)^2 * 0.18)
		end
	end

	-- 4. FINAL LANDING
	if thisRollId == latestRollId then
		label.TextTransparency = 0
		if stroke then stroke.Transparency = 0 end
		label.Text = rarityChance and rarityName .. " (1 in " .. tostring(rarityChance) .. ")" or rarityName
		label.TextColor3 = rarityColor

		if rarityChance then
			rollSound.PlaybackSpeed = math.clamp(1.6 + (math.log10(rarityChance) * 0.5), 0.8, 3.5)
		else
			rollSound.PlaybackSpeed = 0.7
		end
		rollSound:Play()

		TweenService:Create(label, slowPopInfo, {Size = UDim2.fromScale(0.8, 0.1)}):Play()

		task.wait(0.1)
		gui:SetAttribute("IsRolling", false)
	end

	-- 5. THE GUARDED FADE
	task.delay(5, function()
		if thisRollId == latestRollId then 
			fadeTween = TweenService:Create(label, TweenInfo.new(1.5), {TextTransparency = 1})
			fadeTween:Play()
			if stroke then
				strokeFadeTween = TweenService:Create(stroke, TweenInfo.new(1.5), {Transparency = 1})
				strokeFadeTween:Play()
			end
			fadeTween.Completed:Connect(function(state)
				if state == Enum.PlaybackState.Completed and thisRollId == latestRollId then
					label.Visible = false
				end
			end)
		end
	end)
end)