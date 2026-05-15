local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Wait for the event, but don't hang forever (timeout of 5 seconds)
local buyEvent = ReplicatedStorage:WaitForChild("BuyItem", 5)

-- Dictionary for static items
local items = {
	["Sword"] = 50,
	["SpeedCoil"] = 100,
}

if buyEvent then
	buyEvent.OnServerEvent:Connect(function(player, itemName)
		local pebbles = player.leaderstats:FindFirstChild("Pebbles")
		local pLevel = player:FindFirstChild("PickaxeLevel")
		local inventory = player:FindFirstChild("Inventory")

		-- Safety Check: If data hasn't loaded yet, block the purchase
		if not pebbles or not pLevel or not inventory then 
			warn("Purchase failed: " .. player.Name .. "'s data is not ready.")
			return 
		end

		-- 1. SCALING PICKAXE LOGIC
		if itemName == "Pickaxe" then
			local dynamicPrice = 50 * pLevel.Value

			if pebbles.Value >= dynamicPrice then
				pebbles.Value -= dynamicPrice
				pLevel.Value += 1
				print(player.Name .. " upgraded to Pickaxe Level " .. pLevel.Value)
			end

			-- 2. REGULAR ITEM LOGIC
		elseif items[itemName] then
			local cost = items[itemName]
			if pebbles.Value >= cost then
				pebbles.Value -= cost

				-- Try to give tool from ServerStorage
				local toolTemplate = ServerStorage:FindFirstChild("Items") and ServerStorage.Items:FindFirstChild(itemName)
				if toolTemplate then
					toolTemplate:Clone().Parent = player.Backpack
				end
			end
		end
	end)
else
	warn("CRITICAL: BuyItem RemoteEvent missing from ReplicatedStorage!")
end