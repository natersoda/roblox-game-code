local function saveData(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local inventory = player:FindFirstChild("Inventory")
	local bestRarity = player:FindFirstChild("BestRarity")
	local pickaxeLevel = player:FindFirstChild("PickaxeLevel")

	if not leaderstats or not inventory or not bestRarity or not pickaxeLevel then return end

	local inventoryTable = {}
	for _, item in pairs(inventory:GetChildren()) do
		if item:IsA("IntValue") then
			inventoryTable[item.Name] = item.Value
		end
	end

	local dataToSave = {
		Pebbles = leaderstats.Pebbles.Value,
		BestRarity = bestRarity.Value,
		PickaxeLevel = pickaxeLevel.Value,
		Inventory = inventoryTable
	}

	pcall(function()
		PlayerData:SetAsync(player.UserId, dataToSave)
	end)
end