------------------------------------
--  This file holds fun commands  --
------------------------------------

function ulx.explode( calling_ply, target_plys )

	for k, v in pairs( target_plys ) do
	
		if ( not v:Alive() ) then
		
			if v == calling_ply then
		
				ULib.tsayError( calling_ply, "You are dead!" )
				
			else
			
				ULib.tsayError( calling_ply, target_ply:Nick() .. " is dead!" )
				
			end
		
		elseif v:IsFrozen() then
		
			if v == calling_ply then
		
				ULib.tsayError( calling_ply, "You are frozen!" )
				
			else
			
				ULib.tsayError( calling_ply, target_ply:Nick() .. " is frozen!" )
				
			end
			
		else
	
			local playerpos = v:GetPos()
			
			local waterlevel = v:WaterLevel()
			
			timer.Simple( 0.1, 
			
				function()
				
				local traceworld = {}
				
					traceworld.start = playerpos
					
					traceworld.endpos = traceworld.start + ( Vector( 0,0,-1 ) * 250 )
					
					local trw = util.TraceLine( traceworld )
					
					local worldpos1 = trw.HitPos + trw.HitNormal
					
					local worldpos2 = trw.HitPos - trw.HitNormal
					
				util.Decal( "Scorch",worldpos1,worldpos2 )
				
				end )
				
			if GetConVarNumber( "explode_ragdolls" ) == 1 then			
			
				v:SetVelocity( Vector( 0, 0, 10 ) * math.random( 75, 150 ) )
			
				timer.Simple( 0.05, function() v:Kill() end )
				
			elseif GetConVarNumber( "explode_ragdolls" ) == 0 then
			
				v:Kill()
				
			end
			
			util.ScreenShake( playerpos, 5, 5, 1.5, 200 )

			if ( waterlevel > 1 ) then
			
				local vPoint = playerpos + Vector(0,0,10)
				
					local effectdata = EffectData()
					
					effectdata:SetStart( vPoint )
					
					effectdata:SetOrigin( vPoint )
					
					effectdata:SetScale( 1 )
					
				util.Effect( "WaterSurfaceExplosion", effectdata )
				
				local vPoint = playerpos + Vector(0,0,10)
				
					local effectdata = EffectData()
					
					effectdata:SetStart( vPoint )
					
					effectdata:SetOrigin( vPoint )
					
					effectdata:SetScale( 1 )
					
				util.Effect( "HelicopterMegaBomb", effectdata ) 
				
			else
			
				local vPoint = playerpos + Vector( 0,0,10 )
				
					local effectdata = EffectData()
					
					effectdata:SetStart( vPoint )
					
					effectdata:SetOrigin( vPoint )
					
					effectdata:SetScale( 1 )
					
				util.Effect( "HelicopterMegaBomb", effectdata )
				
				v:EmitSound( Sound ("ambient/explosions/explode_4.wav") )
				
			end	
			
			ulx.fancyLogAdmin( calling_ply, "#A exploded #T", target_plys )
			
		end
		
	end	
	
end
local explode = ulx.command( "Custom", "ulx explode", ulx.explode, "!explode" )
explode:addParam{ type=ULib.cmds.PlayersArg }
explode:defaultAccess( ULib.ACCESS_ADMIN )
explode:help( "Explode a player" )

function ulx.launch( calling_ply, target_plys )

	for k,v in pairs( target_plys ) do
	
		v:SetVelocity( Vector( 0,0,50 ) * 50 )
		
	end

	ulx.fancyLogAdmin( calling_ply, "#A Launched #T", target_plys )

end
local launch = ulx.command( "Custom", "ulx launch", ulx.launch, "!launch" )
launch:addParam{ type=ULib.cmds.PlayersArg }
launch:defaultAccess( ULib.ACCESS_ADMIN )
launch:help( "Launch players into the air." )


function ulx.gravity( calling_ply, target_plys, gravnumber )

	for k,v in pairs( target_plys ) do
	
		if tonumber(gravnumber) == 0 then
		
			v:SetGravity( 0.000000000000000000000001 ) -- because float is dumb
			
		elseif tonumber(gravnumber) > 0 then
		
			v:SetGravity( gravnumber )
			
		end
		
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A set the gravity for #T to #s", target_plys, gravnumber )

end
local gravity = ulx.command( "Custom", "ulx gravity", ulx.gravity, "!gravity" )
gravity:addParam{ type=ULib.cmds.PlayersArg }
gravity:addParam{ type=ULib.cmds.StringArg, hint="gravity" }
gravity:defaultAccess( ULib.ACCESS_SUPERADMIN )
gravity:help( "Sets target's gravity." )


local prevrun
local prevwalk

local function getInitialSpeeds( ply ) -- fetch players' initial walk and run speeds, it's different for each gamemode

	timer.Simple( 0.1, function() -- for some reason this prints the run speed different than it actually is if i dont add the timer...

		prevrun = ply:GetRunSpeed()

		prevwalk = ply:GetWalkSpeed()
	
		ULib.console( ply, "Initial walk and run speeds fetched.\nWalk Speed: " .. prevwalk .. "\nRun Speed: " .. prevrun )
	
	end )

end
hook.Add( "PlayerInitialSpawn", "geturspeeds", getInitialSpeeds )

function ulx.speed( calling_ply, target_plys, walk, run )

	for k,v in pairs( target_plys ) do
	
		if walk == 0 and run == 0 then 
		
			GAMEMODE:SetPlayerSpeed( v, prevwalk, prevrun ) -- reset to the fetched default values
				
			ulx.fancyLogAdmin( calling_ply, "#A reset the walk and run speed for #T", target_plys )

		elseif walk > 0 and run == 0 then
		
			GAMEMODE:SetPlayerSpeed( v, walk, v:GetRunSpeed() ) -- skip over run speed
		
			ulx.fancyLogAdmin( calling_ply, "#A set the walk speed for #T to #s", target_plys, walk )
			
		elseif walk == 0 and run > 0 then
		
			GAMEMODE:SetPlayerSpeed( v, v:GetWalkSpeed(), run ) -- skip over walk speed
		
			ulx.fancyLogAdmin( calling_ply, "#A set the run speed for #T to #s", target_plys, run )
			
		elseif walk > 0 and run > 0 then
		
			GAMEMODE:SetPlayerSpeed( v, walk, run ) -- set both
			
			ulx.fancyLogAdmin( calling_ply, "#A set the walk speed for #T to #s and the run speed to #i", target_plys, walk, run )
		
		end
		
	end

end
local speed = ulx.command( "Custom", "ulx speed", ulx.speed, "!speed" )
speed:addParam{ type=ULib.cmds.PlayersArg }
speed:addParam{ type=ULib.cmds.NumArg, default=0, hint="walk speed", min=0, max=20000 }
speed:addParam{ type=ULib.cmds.NumArg, default=0, hint="run speed", min=0, max=20000 }
speed:defaultAccess( ULib.ACCESS_SUPERADMIN )
speed:help( "Sets target's speed.\nSet a value to 0 to leave it unchanged\nSet both to 0 to reset" )

function ulx.model( calling_ply, target_plys, model )
	
	for k,v in pairs( target_plys ) do 
	
		if ( not v:Alive() ) then
		
			ULib.tsayError( calling_ply, v:Nick() .. " is dead", true )
		
		else
		
			v:SetModel( model )

		end
		
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A set the model for #T to #s", target_plys, model )
	
end
local model = ulx.command( "Custom", "ulx model", ulx.model, "!model" )
model:addParam{ type=ULib.cmds.PlayersArg }
model:addParam{ type=ULib.cmds.StringArg, hint="model" }
model:defaultAccess( ULib.ACCESS_ADMIN )
model:help( "Set a player's model." )

function ulx.jumppower( calling_ply, target_plys, power )
	
	for k,v in pairs( target_plys ) do 
	
		if ( not v:Alive() ) then
		
			ULib.tsayError( calling_ply, v:Nick() .. " is dead", true )
		
		else
		
			v:SetJumpPower( power )

		end
		
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A set the jump power for #T to #s", target_plys, power )
	
end
local jumppower = ulx.command( "Custom", "ulx jumppower", ulx.jumppower, "!jumppower" )
jumppower:addParam{ type=ULib.cmds.PlayersArg }
jumppower:addParam{ type=ULib.cmds.NumArg, default=200, hint="power", ULib.cmds.optional }
jumppower:defaultAccess( ULib.ACCESS_ADMIN )
jumppower:help( "Set a player's jump power.\nDefault=200" )

function ulx.frags_deaths( calling_ply, target_plys, number, should_deaths )

	if ( not should_deaths ) then
	
		for k,v in pairs( target_plys ) do 
		
			v:SetFrags( number )

		end
		
		ulx.fancyLogAdmin( calling_ply, "#A set the frags for #T to #s", target_plys, number )
		
	elseif should_deaths then
	
		for k,v in pairs( target_plys ) do 
		
			v:SetDeaths( number )

		end
		
		ulx.fancyLogAdmin( calling_ply, "#A set the deaths for #T to #s", target_plys, number )
		
	end
	
end
local frags_deaths = ulx.command( "Custom", "ulx frags_deaths", ulx.frags_deaths, "!frags" )
frags_deaths:addParam{ type=ULib.cmds.PlayersArg }
frags_deaths:addParam{ type=ULib.cmds.NumArg, hint="number" }
frags_deaths:addParam{ type=ULib.cmds.BoolArg, invisible=true }
frags_deaths:defaultAccess( ULib.ACCESS_ADMIN )
frags_deaths:help( "Set a player's frags and deaths." )
frags_deaths:setOpposite( "ulx deaths", { _, _, _, true }, "!deaths" )
