local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local gui = script.Parent

-- 1. CLEAN REFERENCES
local container = gui:WaitForChild("UpgradeContainer")
local upgradeBtn = container:WaitForChild("UpgradeButton")
local closeBtn = container:WaitForChild("CloseButton")
local clickSound = upgradeBtn:FindFirstChild("ClickSound")

local upgradeEvent = ReplicatedStorage:WaitForChild("UpgradeRequest")
local UPGRADE_COST = 100 

-- 2. NPC INTERACTION (Open/Close)
local function setupNPC()
	local npc = workspace:FindFirstChild("ShopNPC")
	if not npc then return end

	local prompt = npc:FindFirstChildOfClass("ProximityPrompt") or npc:FindFirstChildWhichIsA("ProximityPrompt", true)
	if prompt then
		prompt.Triggered:Connect(function()
			container.Visible = not container.Visible
		end)
	end
end

-- 3. UPGRADE CLICK (No Animation)
upgradeBtn.MouseButton1Click:Connect(function()
	if clickSound then clickSound:Play() end

	-- Just fire the event directly
	upgradeEvent:FireServer()
end)

-- 4. CLOSE CLICK
closeBtn.MouseButton1Click:Connect(function()
	if clickSound then clickSound:Play() end
	container.Visible = false
end)

-- 5. INITIALIZE
setupNPC()

-- Set the cost text
local costLabel = upgradeBtn:FindFirstChild("CostLabel")
if costLabel then 
	costLabel.Text = tostring(UPGRADE_COST) .. " Pebbles" 
end

