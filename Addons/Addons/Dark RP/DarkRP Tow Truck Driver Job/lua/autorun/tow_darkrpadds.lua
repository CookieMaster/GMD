timer.Simple(10, function()

	TEAM_TOWER = AddExtraTeam("Tow Truck Driver", {
		color = Color(255, 165, 51, 255),
		model = "models/player/monk.mdl",
		description = [[You have the ability to tow vehicles.]],
		weapons = {"tow_attach"},
		command = "tower",
		max = 2,
		salary = 45,
		admin = 0,
		vote = false,
		hasLicense = false
	})
	
end)