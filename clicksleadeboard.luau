local DataStoreService = game:GetService("DataStoreService")
local PlayerData = DataStoreService:GetDataStore("PlayerSaveData_V1")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 1. INITIALIZE DATA ON JOIN
game.Players.PlayerAdded:Connect(function(player)
	-- CREATE FOLDERS IMMEDIATELY (Prevents other scripts from failing/looping)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local pebbles = Instance.new("IntValue")
	pebbles.Name = "Pebbles"
	pebbles.Value = 0
	pebbles.Parent = leaderstats

	local bestRarity = Instance.new("StringValue")
	bestRarity.Name = "BestRarity"
	bestRarity.Value = "None"
	bestRarity.Parent = player 

	local pickaxeLevel = Instance.new("IntValue")
	pickaxeLevel.Name = "PickaxeLevel"
	pickaxeLevel.Value = 1
	pickaxeLevel.Parent = player 

	local inventory = Instance.new("Folder")
	inventory.Name = "Inventory"
	inventory.Parent = player

	-- LOAD FROM CLOUD
	local success, data = pcall(function()
		return PlayerData:GetAsync(player.UserId)
	end)

	if success and data then
		pebbles.Value = data.Pebbles or 0
		bestRarity.Value = data.BestRarity or "None"
		pickaxeLevel.Value = data.PickaxeLevel or 1

		if data.Inventory then
			for rockName, amount in pairs(data.Inventory) do
				local rockVal = Instance.new("IntValue")
				rockVal.Name = rockName
				rockVal.Value = amount
				rockVal.Parent = inventory
			end
		end
		print("Data successfully loaded for " .. player.Name)
	else
		warn("New player or data load failed for " .. player.Name)
	end
end)

-- 2. ENHANCED SAVE FUNCTION
local function saveData(player)
	local stats = player:FindFirstChild("leaderstats")
	local inventoryFolder = player:FindFirstChild("Inventory")

	-- Safety: Don't save if the player didn't even load in (prevents overwriting with 0s)
	if not stats or not inventoryFolder then return end

	local inventoryTable = {}
	for _, item in pairs(inventoryFolder:GetChildren()) do
		if item:IsA("IntValue") then
			inventoryTable[item.Name] = item.Value
		end
	end

	local dataToSave = {
		Pebbles = stats.Pebbles.Value,
		BestRarity = player.BestRarity.Value,
		PickaxeLevel = player.PickaxeLevel.Value,
		Inventory = inventoryTable
	}

	local success, err = pcall(function()
		PlayerData:SetAsync(player.UserId, dataToSave)
	end)

	if success then
		print("Successfully saved data for " .. player.Name)
	else
		warn("FAILED to save data for " .. player.Name .. ": " .. tostring(err))
	end
end

game.Players.PlayerRemoving:Connect(saveData)

game:BindToClose(function()
	local finished = Instance.new("BindableEvent")
	local count = 0
	local players = game.Players:GetPlayers()

	if #players == 0 then return end

	for _, player in pairs(players) do
		count = count + 1
		task.spawn(function()
			saveData(player)
			count = count - 1
			if count == 0 then
				finished:Fire()
			end
		end)
	end

	finished.Event:Wait() -- waits until ALL players are saved
	finished:Destroy()
end)