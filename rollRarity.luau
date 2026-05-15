local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RarityData = require(ReplicatedStorage:WaitForChild("RarityData"))
local remote = ReplicatedStorage:WaitForChild("RollRequest")

-- 1. HELPER FUNCTION: Finds the correct folder and adds the rock
local function addRockToInventory(player, rockName)
    local inv = player:FindFirstChild("Inventory")
    
    -- If the folder isn't there, the player hasn't loaded yet.
    -- We should block the roll rather than guessing which folder to use.
    if not inv then 
        warn("Player data not loaded yet!")
        return false 
    end

    local itemValue = inv:FindFirstChild(rockName)
    if not itemValue then
        itemValue = Instance.new("IntValue")
        itemValue.Name = rockName
        itemValue.Value = 1
        itemValue.Parent = inv
    else
        itemValue.Value += 1
    end
    return true
end

-- 2. DYNAMIC INITIALIZATION: Find the easiest mineral automatically
local defaultRarity = nil
local lowestChanceValue = math.huge

for name, data in pairs(RarityData) do
	if data.Chance < lowestChanceValue then
		lowestChanceValue = data.Chance
		defaultRarity = name
	end
end

local cooldowns = {}

remote.OnServerEvent:Connect(function(player)
	if cooldowns[player.UserId] then return end
	cooldowns[player.UserId] = true

	local success, err = pcall(function()
		local leaderstats = player:WaitForChild("leaderstats", 5)
		local pebbles = leaderstats and leaderstats:WaitForChild("Pebbles", 5)
		local bestRarityValue = player:WaitForChild("BestRarity", 5)

		if pebbles and pebbles.Value >= 10 then
			pebbles.Value -= 10

			local rng = Random.new()
			local roll = rng:NextNumber(0, 1)
			local result = nil 

			-- RNG Logic
			for name, data in pairs(RarityData) do
				if roll <= (1 / data.Chance) then
					if not result or data.Chance > RarityData[result].Chance then
						result = name
					end
				end
			end

			-- Fallback to Common
			if not result then result = defaultRarity end 

			-- ADD TO INVENTORY
			addRockToInventory(player, result)

			-- Personal Best Logic
			local newChance = RarityData[result].Chance
			local oldRarityName = bestRarityValue.Value
			local oldChance = (RarityData[oldRarityName] and RarityData[oldRarityName].Chance) or 0

			if newChance > oldChance then
				bestRarityValue.Value = result
			end

			remote:FireClient(player, result, RarityData[result].Color, RarityData[result].Chance)
		else
			remote:FireClient(player, "Not enough Pebbles!", Color3.fromRGB(255, 0, 0), nil)
		end
	end)

	if not success then
		warn("Roll failed: " .. tostring(err))
	end

	task.wait(0.1)
	cooldowns[player.UserId] = nil
end)