AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function TOW_TruckNPC_Spawn()	
	if not file.IsDir("craphead_scripts", "DATA") then
		file.CreateDir("craphead_scripts", "DATA")
	end
	
	if not file.IsDir("craphead_scripts/tow_system/".. string.lower(game.GetMap()) .."", "DATA") then
		file.CreateDir("craphead_scripts/tow_system/".. string.lower(game.GetMap()) .."", "DATA")
	end
	
	if not file.Exists( "craphead_scripts/tow_system/".. string.lower(game.GetMap()) .."/towtrucknpc_location.txt", "DATA" ) then
		file.Write("craphead_scripts/tow_system/".. string.lower(game.GetMap()) .."/towtrucknpc_location.txt", "0;-0;-0;0;0;0", "DATA")
	end
	
	local PositionFile = file.Read("craphead_scripts/tow_system/".. string.lower(game.GetMap()) .."/towtrucknpc_location.txt", "DATA")
	 
	local ThePosition = string.Explode( ";", PositionFile )
		
	local TheVector = Vector(ThePosition[1], ThePosition[2], ThePosition[3])
	local TheAngle = Angle(tonumber(ThePosition[4]), ThePosition[5], ThePosition[6])
	
	local TowTruckNPC = ents.Create("npc_towtruck")
	TowTruckNPC:SetModel(TOWTRUCK_NPCModel)
	TowTruckNPC:SetPos(TheVector)
	TowTruckNPC:SetAngles(TheAngle)
	TowTruckNPC:Spawn()
	TowTruckNPC:SetMoveType(MOVETYPE_NONE)
	TowTruckNPC:SetSolid( SOLID_BBOX )
	TowTruckNPC:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		
	local Indicator = ents.Create("npc_indicator")
	Indicator:SetPos( TowTruckNPC:GetPos() + (TowTruckNPC:GetUp() * 90) )
	Indicator:SetParent( TowTruckNPC )
	Indicator:SetAngles( TowTruckNPC:GetAngles() )
	Indicator:Spawn()
	Indicator:SetCollisionGroup(COLLISION_GROUP_WORLD)
end
timer.Simple(1, TOW_TruckNPC_Spawn)

function TOW_TruckNPC_Position( ply )
	if ply:IsAdmin() then
		local HisVector = string.Explode(" ", tostring(ply:GetPos()))
		local HisAngles = string.Explode(" ", tostring(ply:GetAngles()))
		
		file.Write("craphead_scripts/tow_system/".. string.lower(game.GetMap()) .."/towtrucknpc_location.txt", ""..(HisVector[1])..";"..(HisVector[2])..";"..(HisVector[3])..";"..(HisAngles[1])..";"..(HisAngles[2])..";"..(HisAngles[3]).."", "DATA")
		ply:ChatPrint("New position for the tow truck NPC has been succesfully set. Please restart your server!")
	else
		ply:ChatPrint("Only administrators can perform this action")
	end
end
concommand.Add("towtrucknpc_setpos", TOW_TruckNPC_Position)

function ENT:AcceptInput(ply, caller)
	if caller:IsPlayer() && !caller.CantUse then
		caller.CantUse = true
		timer.Simple(3, function()  caller.CantUse = false end)

		if caller:IsValid() and caller:Team() == TEAM_TOWER then
			umsg.Start("TOW_TowTruck_Menu", caller)
			umsg.End()
		else
			DarkRP.notify(caller, 2, 5,  "Only towers can access this NPC!")
		end
	end
end