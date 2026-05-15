game.Players.PlayerAdded:Connect(function(player)
	local inv = Instance.new("Folder")
	inv.Name = "Inventory"
	inv.Parent = player

	-- When the player rolls a rock, we will create/update values here
end)