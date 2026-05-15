local rock = script.Parent
local clickDetector = rock:WaitForChild("ClickDetector")

clickDetector.MouseClick:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local pebbles = leaderstats and leaderstats:FindFirstChild("Pebbles")

	-- We need to find the PickaxeLevel we created in the Big Script
	local pLevel = player:FindFirstChild("PickaxeLevel")

	if not pebbles or not pLevel then return end 

	local ownerID = rock:GetAttribute("OwnerID")

	-- This determines how many pebbles they get (Level 1 = 1, Level 2 = 2, etc.)
	local amountToGive = pLevel.Value

	-- 1. IF THE ROCK IS FREE
	if ownerID == nil then
		if player:GetAttribute("HasClaimedARock") then
			print("You already own a rock!")
			return
		end

		-- Claim the rock
		rock:SetAttribute("OwnerID", player.UserId)
		player:SetAttribute("HasClaimedARock", true)
		rock.BrickColor = BrickColor.new("Bright green")

		-- Give pebbles based on pickaxe level
		pebbles.Value += amountToGive

		-- --- CREATE THE NAME TAG ---
		if rock:FindFirstChild("OwnerTag") then rock.OwnerTag:Destroy() end

		local bgui = Instance.new("BillboardGui")
		bgui.Name = "OwnerTag"
		bgui.Parent = rock
		bgui.Adornee = rock 
		bgui.Size = UDim2.new(0, 200, 0, 50)
		bgui.StudsOffset = Vector3.new(0, 4, 0) 
		bgui.AlwaysOnTop = true 

		local label = Instance.new("TextLabel")
		label.Parent = bgui
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = player.Name .. "'s Rock"
		label.TextColor3 = Color3.new(1, 1, 1) 
		label.TextStrokeTransparency = 0 
		label.TextScaled = true 
		label.Font = Enum.Font.SourceSansBold
		-- ---------------------------

		print(player.Name .. " claimed this rock and got " .. amountToGive .. " pebbles!")

		-- 2. IF THE OWNER CLICKS AGAIN
	elseif ownerID == player.UserId then
		-- Give pebbles based on pickaxe level
		pebbles.Value += amountToGive
		print("Added " .. amountToGive .. " pebbles (Level " .. pLevel.Value .. ")")

	else
		print("This rock belongs to someone else!")
	end
end)