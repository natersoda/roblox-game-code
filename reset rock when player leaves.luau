game.Players.PlayerRemoving:Connect(function(player)
	-- Look through all the rocks in the workspace
	for _, rock in pairs(game.Workspace:GetDescendants()) do
		-- Check if this rock was owned by the player who just left
		if rock:GetAttribute("OwnerID") == player.UserId then
			-- Reset the rock
			rock:SetAttribute("OwnerID", nil)
			rock.BrickColor = BrickColor.new("Medium stone grey")

			-- Remove the name tag
			local tag = rock:FindFirstChild("OwnerTag")
			if tag then tag:Destroy() end

			print("Cleaned up " .. player.Name .. "'s rock")
		end
	end
end)