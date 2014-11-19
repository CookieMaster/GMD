timer.Simple(2, function() 
	if not file.Exists( "craphead_scripts/tow_system/".. string.lower(game.GetMap()) .."/towtruck_location.txt", "DATA" ) then
		file.Write("craphead_scripts/tow_system/".. string.lower(game.GetMap()) .."/towtruck_location.txt", "0;-0;-0;0;0;0", "DATA")
	end
end)

function TOW_TowTruck_Position( ply )
	if ply:IsAdmin() then
		local HisVector = string.Explode(" ", tostring(ply:GetPos()))
		local HisAngles = string.Explode(" ", tostring(ply:GetAngles()))
		
		file.Write("craphead_scripts/tow_system/".. string.lower(game.GetMap()) .."/towtruck_location.txt", ""..(HisVector[1])..";"..(HisVector[2])..";"..(HisVector[3])..";"..(HisAngles[1])..";"..(HisAngles[2])..";"..(HisAngles[3]).."", "DATA")
		ply:ChatPrint("New position for the tow truck has been successfully set. The new position is now in effect!")
	else
		ply:ChatPrint("Only administrators can perform this action")
	end
end
concommand.Add("towtruck_setpos", TOW_TowTruck_Position)

local CurTowTrucks = 0

util.AddNetworkString("TowTruck_CreateTowTruck")
net.Receive("TowTruck_CreateTowTruck", function(length, ply)
	
	if ply.HasTowTruck then
		DarkRP.notify(ply, 1, 5, "You already own a tow truck!")
		return
	end
	
	if CurTowTrucks == TOWTRUCK_MaxTrucks then
		DarkRP.notify(ply, 1, 5, "The limitation of maximum tow trucks has been reached!")
		return
	end
	
	DarkRP.notify(ply, 1, 5, "You have successfully retrieved a tow truck!")
	
	local PositionFile = file.Read("craphead_scripts/tow_system/".. string.lower(game.GetMap()) .."/towtruck_location.txt", "DATA")
	local ThePosition = string.Explode( ";", PositionFile )
	local TheVector = Vector(ThePosition[1], ThePosition[2], ThePosition[3])
	local TheAngle = Angle(tonumber(ThePosition[4]), ThePosition[5], ThePosition[6])

	local TowTruck = ents.Create( "prop_vehicle_jeep" )
	TowTruck:SetKeyValue( "vehiclescript", TOWTRUCK_VehicleScript )
	TowTruck:SetPos( TheVector )
	TowTruck:SetAngles( TheAngle )
	TowTruck:SetRenderMode(RENDERMODE_TRANSADDFRAMEBLEND)
	TowTruck:SetModel( TOWTRUCK_VehicleModel )
	TowTruck:Spawn()
	TowTruck:Activate()
	TowTruck:SetNWInt( "Owner", ply:EntIndex() ) 
	TowTruck:SetHealth( TOWTRUCK_Health )
	TowTruck:keysOwn( ply )
	
	ply.HasTowTruck = true
	CurTowTrucks = CurTowTrucks + 1
end)

util.AddNetworkString("TOWTRUCK_RemoveTowTruck")
net.Receive("TOWTRUCK_RemoveTowTruck", function(length, ply)
	
	if ply.HasTowTruck then
		for _, ent in pairs(ents.GetAll()) do
			if ent:GetModel() == TOWTRUCK_VehicleModel then
				if ent:GetNWInt("Owner") == ply:EntIndex() then
					ent:Remove()
					DarkRP.notify(ply, 1, 5, "Your tow truck has been removed!")
				end
			end
		end
	else
		DarkRP.notify(ply, 1, 5, "You don't have a tow truck!")
	end

end)

util.AddNetworkString("TOW_SubmitWarning")
net.Receive("TOW_SubmitWarning", function(length, ply)
	local PlayerToWarn = net.ReadString()
	local TowFine = net.ReadDouble()
	local Tower = ply:Nick()
	local Vehicle = net.ReadEntity()
	local doorData = Vehicle:getDoorData()
	
	for k, v in pairs(player.GetAll()) do
		if v:SteamID() == PlayerToWarn then
			if Vehicle.HasBeenTowed then
				DarkRP.notify(ply, 1, 5, "This vehicle has already been marked as succesfully towed.")
				return
			end
			if doorData.owner:SteamID() == ply:SteamID() then
				DarkRP.notify(ply, 1, 5, "You can't tow your own vehicle!")
				return
			end
			
			DarkRP.notify(v, 1, 5, "Your vehicle has been towed.")
			if TowFine == 0 then
				DarkRP.notify(v, 1, 5, "You can pick it up free of charge. The location has been marked on your map.")
			else
				DarkRP.notify(v, 1, 5, "You can pick it up for $".. TowFine ..". The location has been marked on your map.")
			end
			
			Vehicle.HasBeenTowed = true
			Vehicle.TowFine = TowFine
			
			umsg.Start("TOWCL_PlaceFine", ply)
				umsg.Entity(Vehicle)
				umsg.String(doorData.owner:SteamID())
				umsg.String(TowFine)
			umsg.End()
			
		end
	end

end)

util.AddNetworkString("TOW_PayTheFine")
net.Receive("TOW_PayTheFine", function(length, ply)
	local Vehicle = net.ReadEntity()
	
	if ply:getDarkRPVar("money") >= Vehicle.TowFine then
		ply:addMoney( Vehicle.TowFine * -1 )
		
		for k, v in pairs(player.GetAll()) do
			if v:Team() == TEAM_TOWER then
				TheCut = team.NumPlayers(TEAM_TOWER)
				v:addMoney( Vehicle.TowFine / TheCut )
				DarkRP.notify(v, 1, 5, ply:Nick().. " has paid a fine of $"..Vehicle.TowFine..". You have received $"..Vehicle.TowFine / TheCut)
			end
		end
	else
		DarkRP.notify(ply, 1, 5, "You cannot afford to pay your $"..Vehicle.TowFine.." tow fine.")
		return
	end
	DarkRP.notify(ply, 1, 5, "You have paid your tow fine of $"..Vehicle.TowFine..", and your vehicle has been unlocked.")
	
	Vehicle.HasBeenTowed = false
	Vehicle.TowFine = -1
	
	umsg.Start("TOWCL_PlaceFine", ply)
		umsg.Entity(Vehicle)
		umsg.String("n/a")
		umsg.String("0")
	umsg.End()
end)

function TOW_PayFine( ply, Vehicle )
	if Vehicle.HasBeenTowed then
		DarkRP.notify(ply, 1, 5, "This vehicle has an unpaid fine. Pay the fine to access the vehicle!")
		ply:ExitVehicle()
		umsg.Start("TOW_PayTowFine", ply)
			umsg.String(Vehicle.TowFine)
			umsg.Entity(Vehicle)
		umsg.End() 
	end
end
hook.Add("PlayerEnteredVehicle", "TOW_PayFine", TOW_PayFine)

function TOW_TowVehicleFromTruck( ply, key )
	local Vehicle = ply:GetVehicle()
	
	if ply:InVehicle() and ply:GetVehicle():GetClass() == "prop_vehicle_jeep" then
		if ply:GetVehicle():GetModel() == TOWTRUCK_VehicleModel then
			if key == IN_ATTACK2 then
				if ply:Team() == TEAM_TOWER then
					if !constraint.FindConstraints(Vehicle, "Rope")[1] and Vehicle.IsTowing then
						Vehicle.IsTowing = false
					end
					
					local pos = Vehicle:GetPos()
					local isClose = ply:GetShootPos():Distance( pos + Vehicle:GetForward() * -133.3848 + Vehicle:GetUp() * 47.928 ) < 152
					
					if ( not Vehicle.LastUse or Vehicle.LastUse < CurTime() ) and isClose then
						
						Vehicle.LastUse = CurTime() + 2
						
						if not Vehicle.IsTowing then
							local trace = util.TraceLine( {start = pos + Vector(0, 0, 27), endpos = pos + Vehicle:GetForward() * -200 + Vector(0, 0, 27), filter = Vehicle} )
							local ent = trace.Entity
							
							if not ent:IsValid() then
								local cars = ents.FindInBox( pos + Vehicle:GetRight() * 35 + Vehicle:GetForward() * -200, pos + Vehicle:GetRight() * -35 + Vehicle:GetUp() * 100 )
								DarkRP.notify(ply, 1, 5, "There is no vehicle behind the tow truck!")
								
								for i=1, #cars do
									if cars[i] != Vehicle and cars[i]:IsVehicle() then
										ent = cars[i]
										break
									end
								end
							end
							
							if ent:IsValid() and ent:IsVehicle() and ent:GetPhysicsObject():GetMass() < 8000 then
								local carfront = ent:NearestPoint( ent:GetPos() + Vector(0, 0, 12.5) + ent:GetForward() * 500 )
								if carfront:Distance( pos + Vehicle:GetForward() * -133.3848 + Vehicle:GetUp() * 73.928 ) < 75 then
									local constraint, rope = constraint.Rope( Vehicle, ent, 0, 0, Vector(0, -133.3848, 73.9280), ent:WorldToLocal(carfront), 60, 0, 17000, 1.5, "cable/cable2", false )
									Vehicle.IsTowing = true
									ent:Fire( "HandBrakeOff", "", 0.5 )
									DarkRP.notify(ply, 1, 5, "Vehicle successfully attached!")
								end
							end
						else
							local trace = util.TraceLine( {start = pos + Vector(0, 0, 27), endpos = pos + Vehicle:GetForward() * -200 + Vector(0, 0, 27), filter = Vehicle} )
							local ent = trace.Entity
							
							constraint.RemoveConstraints( Vehicle, "Rope" )
							Vehicle.IsTowing = false
							ent:Fire( "HandBrakeOn", "", 0.5 )
							DarkRP.notify(ply, 1, 5, "Vehicle successfully unattached!")
						end
					end
					if isClose then
						return
					end
				end
			end
		end
	end
end
hook.Add("KeyPress", "TOW_TowVehicleFromTruck", TOW_TowVehicleFromTruck)

function TOWTRUCK_Removal( ent )
	if ent:GetModel() == TOWTRUCK_VehicleModel then
		player.GetByID(ent:GetNWInt("Owner")).HasTowTruck = false
		CurTowTrucks = CurTowTrucks - 1
	end
end
hook.Add("EntityRemoved", "TOWTRUCK_Removal", TOWTRUCK_Removal)

function TOWTRUCK_Disconnect( ply )
	for _, ent in pairs(ents.GetAll()) do
		if ent:GetModel() == TOWTRUCK_VehicleModel then
			if ent:GetNWInt("Owner") == ply:EntIndex() then
				ent:Remove()
			end
		end
	end
end
hook.Add("PlayerDisconnected", "TOWTRUCK_Disconnect", TOWTRUCK_Disconnect)

function TOWTRUCK_JobChange( ply )
	for _, ent in pairs(ents.FindByClass("prop_vehicle_jeep")) do
		if ply:Team() != TEAM_TOWER then
			if ply.HasTowTruck then
				if ent:GetNWInt("Owner") == ply:EntIndex() then
					if ent:IsValid() then
						ent:Remove()
					end
				end
			end
		end
	end
end
hook.Add("PlayerSwitchWeapon", "TOWTRUCK_JobChange", TOWTRUCK_JobChange)

function TOWTRUCK_CustomExit(ply, vehicle)
	if vehicle:GetModel() == TOWTRUCK_VehicleModel then
		ply:SetPos( vehicle:GetPos() + Vector(-90,125,20) )
	end
end
hook.Add("PlayerLeaveVehicle", "TOWTRUCK_CustomExit", TOWTRUCK_CustomExit)