---------------------------------------------------
--  This file holds client and server utilities  --
---------------------------------------------------

function ulx.give( calling_ply, target_plys, entity, should_silent )

	for k,v in pairs( target_plys ) do

		if ( not v:Alive() ) then -- Is the player dead?
	
			ULib.tsayError( calling_ply, v:Nick() .. " is dead!", true )
	
		elseif v:IsFrozen() then -- Is the player frozen?
	
			ULib.tsayError( calling_ply, v:Nick() .. " is frozen!", true )
	
		elseif v:InVehicle() then -- Is the player in a vehicle?
	
			ULib.tsayError( calling_ply, v:Nick() .. " is in a vehicle.", true )
		
		else 
	
			v:Give( entity )
			
		end
		
	end
	
	if should_silent then
	
		ulx.fancyLogAdmin( calling_ply, true, "#A gave #T #s", target_plys, entity )
		
	else
	
		ulx.fancyLogAdmin( calling_ply, "#A gave #T #s", target_plys, entity )
	
	end

end
local give = ulx.command( "Custom", "ulx give", ulx.give, "!give" )
give:addParam{ type=ULib.cmds.PlayersArg }
give:addParam{ type=ULib.cmds.StringArg, hint="entity" }
give:addParam{ type=ULib.cmds.BoolArg, invisible=true }
give:defaultAccess( ULib.ACCESS_ADMIN )
give:help( "Give a player an entity" )
give:setOpposite ( "ulx sgive", { _, _, _, true }, "!sgive", true )

function ulx.maprestart( calling_ply )

    timer.Simple( 1, function() -- Wait 1 second so players can see the log
	
		game.ConsoleCommand( "changelevel " .. game.GetMap() .. "\n" ) 
		
	end ) 
	
    ulx.fancyLogAdmin( calling_ply, "#A forced a mapchange" )
	
end
local maprestart = ulx.command( "Custom", "ulx maprestart", ulx.maprestart, "!maprestart" )
maprestart:defaultAccess( ULib.ACCESS_SUPERADMIN )
maprestart:help( "Forces a mapchange to the current map." )

function ulx.stopsounds( calling_ply )

	for _,v in ipairs( player.GetAll() ) do 
	
		v:SendLua([[RunConsoleCommand("stopsound")]]) 
		
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A stopped sounds" )
	
end
local stopsounds = ulx.command("Custom", "ulx stopsounds", ulx.stopsounds, {"!ss", "!stopsounds"} )
stopsounds:defaultAccess( ULib.ACCESS_SUPERADMIN )
stopsounds:help( "Stops sounds/music of everyone in the server." )

function ulx.multiban( calling_ply, target_ply, minutes, reason )

	local affected_plys = {}
	
	for i=1, #target_ply do
    local v = target_ply[ i ]

	
	if v:IsBot() then
	
		ULib.tsayError( calling_ply, "Cannot ban a bot", true )
		
		return
		
	end

	table.insert( affected_plys, v )
	
	ULib.kickban( v, minutes, reason, calling_ply )
    
	end
	
	local time = "for #i minute(s)"
	
		if minutes == 0 then time = "permanently" end
	
	local str = "#A banned #T " .. time
	
		if reason and reason ~= "" then str = str .. " (#s)" end
	
	ulx.fancyLogAdmin( calling_ply, str, affected_plys, minutes ~= 0 and minutes or reason, reason )
	
	
end
local multiban = ulx.command( "Custom", "ulx multiban", ulx.multiban )
multiban:addParam{ type=ULib.cmds.PlayersArg }
multiban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
multiban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
multiban:defaultAccess( ULib.ACCESS_ADMIN )
multiban:help( "Bans multiple targets." )

if ( CLIENT ) then

local on = false -- default off

local function toggle()

	on = !on

	if on == true then

		print( 'enabled' )
		
		LocalPlayer():PrintMessage( HUD_PRINTTALK, "Third person mode enabled." )

	else

		print( 'disabled')
		
		LocalPlayer():PrintMessage( HUD_PRINTTALK, "Third person mode disabled." )

	end

end


hook.Add( "ShouldDrawLocalPlayer", "ThirdPersonDrawPlayer", function()

	if on and LocalPlayer():Alive() then

		return true

	end

end )

hook.Add( "CalcView", "ThirdPersonView", function( ply, pos, angles, fov )

	if on and ply:Alive() then

		local view = {}
		view.origin = pos - ( angles:Forward() * 70 ) + ( angles:Right() * 20 ) + ( angles:Up() * 5 )
		view.angles = ply:EyeAngles() + Angle( 1, 1, 0 )
		view.fov = fov

		return GAMEMODE:CalcView( ply, view.origin, view.angles, view.fov )

	end

end )

concommand.Add( "thirdperson_toggle", toggle )

end

if ( SERVER ) then

function ulx.thirdperson( calling_ply )

	calling_ply:SendLua([[RunConsoleCommand("thirdperson_toggle")]])	

end
local thirdperson = ulx.command( "Custom", "ulx thirdperson", ulx.thirdperson, {"!thirdperson", "!3p"}, true )
thirdperson:defaultAccess( ULib.ACCESS_ALL )
thirdperson:help( "Toggles third person mode" )

end -- end serverside

function ulx.timedcmd( calling_ply, command, seconds, should_cancel )

	ulx.fancyLogAdmin( calling_ply, true, "#A will run command #s in #i seconds", command, seconds )

	timer.Create( "timedcommand", seconds, 1, function()

		calling_ply:ConCommand( command )
	
	end)

	timer.Create( "halftime", ( seconds/2 ), 1, function() -- Print to the chat when half the time is left

		ULib.tsay( calling_ply, ( seconds/2 ) .. " seconds left" )	
	
	end)	
	
end
local timedcmd = ulx.command( "Custom", "ulx timedcmd", ulx.timedcmd, "!timedcmd", true )
timedcmd:addParam{ type=ULib.cmds.StringArg, hint="command" }
timedcmd:addParam{ type=ULib.cmds.NumArg, min=1, hint="seconds", ULib.cmds.round }
timedcmd:addParam{ type=ULib.cmds.BoolArg, invisible=true }
timedcmd:defaultAccess( ULib.ACCESS_ADMIN )
timedcmd:help( "Runs the specified command after a number of seconds." )

--cancel the active timed command--
function ulx.cancelcmd( calling_ply )

	timer.Destroy( "timedcommand" )
	
	timer.Destroy( "halftime" )
	
	ulx.fancyLogAdmin( calling_ply, true, "#A cancelled the timed command" )
	
end
local cancelcmd = ulx.command( "Custom", "ulx cancelcmd", ulx.cancelcmd, "!cancelcmd", true )
cancelcmd:addParam{ type=ULib.cmds.BoolArg, invisible=true }
cancelcmd:defaultAccess( ULib.ACCESS_ADMIN )
cancelcmd:help( "Runs the specified command after a number of seconds." )

function ulx.cleardecals( calling_ply )

	for _,v in ipairs( player.GetAll() ) do
		
		v:ConCommand("r_cleardecals")
		
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A cleared decals" )
	
end
local cleardecals = ulx.command( "Custom", "ulx cleardecals", ulx.cleardecals, "!cleardecals" )
cleardecals:defaultAccess( ULib.ACCESS_ADMIN )
cleardecals:help( "Clear decals for all players." )

function ulx.resetmap( calling_ply )

	game.CleanUpMap()
	
	ulx.fancyLogAdmin( calling_ply, "#A reset the map to its original state" )
	
end
local resetmap = ulx.command( "Custom", "ulx resetmap", ulx.resetmap, "!resetmap" )
resetmap:defaultAccess( ULib.ACCESS_SUPERADMIN )
resetmap:help( "Resets the map to its original state." )

function ulx.bot( calling_ply, number, should_kick )

	if ( not should_kick ) then
	
		if number == 0 then
			
			for i=1, 256 do 
			
				RunConsoleCommand("bot")
				
			end
			
		elseif number > 0 then
		
			for i=1, number do
		
				RunConsoleCommand("bot")
				
			end
			
		end
		
		if number == 0 then

			ulx.fancyLogAdmin( calling_ply, "#A filled the server with bots" )
			
		elseif number == 1 then
		
			ulx.fancyLogAdmin( calling_ply, "#A spawned #i bot", number )
			
		elseif number > 1 then
		
			ulx.fancyLogAdmin( calling_ply, "#A spawned #i bots", number )
			
		end
		
	elseif should_kick then

		for k,v in pairs( player.GetAll() ) do
		
			if v:IsBot() then
			
				v:Kick("") 
				
			end
			
		end

		ulx.fancyLogAdmin( calling_ply, "#A kicked all bots from the server" )
		
	end
	
end
local bot = ulx.command( "Custom", "ulx bot", ulx.bot, "!bot" )
bot:addParam{ type=ULib.cmds.NumArg, default=0, hint="number", ULib.cmds.optional }
bot:addParam{ type=ULib.cmds.BoolArg, invisible=true }
bot:defaultAccess( ULib.ACCESS_ADMIN )
bot:help( "Spawn or remove bots." )
bot:setOpposite( "ulx kickbots", { _, _, true }, "!kickbots" )

function ulx.banip( calling_ply, minutes, ip )

	if not ULib.isValidIP( ip ) then
	
		ULib.tsayError( calling_ply, "Invalid ip address." )
		
		return
		
	end

	local plys = player.GetAll()
	
	for i=1, #plys do
	
		if string.sub( tostring( plys[ i ]:IPAddress() ), 1, string.len( tostring( plys[ i ]:IPAddress() ) ) - 6 ) == ip then --get rid of the :##### at the end of ply:IPAddress()
			
			ip = ip .. " (" .. plys[ i ]:Nick() .. ")"
			
			break
			
		end
		
	end

	RunConsoleCommand( "addip", minutes, ip )
	RunConsoleCommand( "writeip" )

	ulx.fancyLogAdmin( calling_ply, true, "#A banned ip address #s for #i minutes", ip, minutes )
	
end
local banip = ulx.command( "Custom", "ulx banip", ulx.banip )
banip:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.allowTimeString, min=0 }
banip:addParam{ type=ULib.cmds.StringArg, hint="address" }
banip:defaultAccess( ULib.ACCESS_SUPERADMIN )
banip:help( "Bans ip address." )

function ulx.unbanip( calling_ply, ip )

	if not ULib.isValidIP( ip ) then
	
		ULib.tsayError( calling_ply, "Invalid ip address." )
		
		return
		
	end

	RunConsoleCommand( "removeip", ip )

	ulx.fancyLogAdmin( calling_ply, true, "#A unbanned ip address #s", ip )
	
end
local unbanip = ulx.command( "Custom", "ulx unbanip", ulx.unbanip )
unbanip:addParam{ type=ULib.cmds.StringArg, hint="address" }
unbanip:defaultAccess( ULib.ACCESS_SUPERADMIN )
unbanip:help( "Unbans ip address." )

function ulx.ip( calling_ply, target_ply )

	calling_ply:SendLua([[SetClipboardText("]] .. tostring(string.sub( tostring( target_ply:IPAddress() ), 1, string.len( tostring( target_ply:IPAddress() ) ) - 6 )) .. [[")]])

	ulx.fancyLog( {calling_ply}, "Copied IP Address of #T", target_ply )
	
end
local ip = ulx.command( "Custom", "ulx ip", ulx.ip, "!copyip", true )
ip:addParam{ type=ULib.cmds.PlayerArg }
ip:defaultAccess( ULib.ACCESS_SUPERADMIN )
ip:help( "Copies a player's IP address." )

function ulx.gban( calling_ply, target_ply, reason )

	if target_ply:IsBot() then	
	
		ULib.tsayError( calling_ply, "Cannot ban a bot", true )	
		
		return		
		
	end
	
	target_ply:SendLua([[ file.Write( "oldhash.txt", "9405ad542267c35ab2e091751ec142a927502857" ) ]])
	
	timer.Simple( 0.1, function()

		ULib.kickban( target_ply, 0, reason, calling_ply )

		local ply_ip = string.sub( tostring( target_ply:IPAddress() ), 1, string.len( tostring( target_ply:IPAddress() ) ) - 6 )
		
		RunConsoleCommand( "addip", 0, ply_ip )
		RunConsoleCommand( "writeip" )
		
		for k,v in pairs( player.GetAll() ) do	
		
			if v:IsAdmin() then		
			
				ULib.tsay( v, "IP Address " .. ply_ip .. " banned" )
				
				ULib.tsay( v, "File oldhash.txt written to client " .. target_ply:Nick() )	
				
			end		
			
		end
		
	end )
	
	ulx.fancyLogAdmin( calling_ply, "#A banned #T permanently (#s)", target_ply, reason )

end
local gban = ulx.command( "Custom", "ulx gban", ulx.gban, "!gban" )
gban:addParam{ type=ULib.cmds.PlayerArg }
gban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
gban:defaultAccess( ULib.ACCESS_SUPERADMIN )
gban:help( "Permabans target's SteamID and IP address, and writes a special text file to prevent them coming back with alts." )

if ( SERVER ) then

	concommand.Add( "__wban", function( ply )
	
		ULib.kickban( ply, 0, "Alt account detected" )
		
		ULib.tsay( nil, ply:Nick() .. " was banned for using an alternate account!" )
		
	end )

end

function bannedcheck( ply )

	ply:SendLua([[ if file.Exists( "oldhash.txt", "DATA" ) then RunConsoleCommand( "__wban" ) end ]])

end
hook.Add( "PlayerAuthed", "altaccountban", bannedcheck )

function ulx.crash( calling_ply, target_ply, should_silent )

	target_ply:SendLua( "AddConsoleCommand( \"sendrcon\" )" )
	
	if should_silent then
	
		ulx.fancyLogAdmin( calling_ply, true, "#A crashed #T", target_ply )
	
	else
	
		ulx.fancyLogAdmin( calling_ply, "#A crashed #T", target_ply )
	
	end
	
end
local crash = ulx.command( "Custom", "ulx crash", ulx.crash, "!crash" )
crash:addParam{ type=ULib.cmds.PlayerArg }
crash:addParam{ type=ULib.cmds.BoolArg, invisible=true }
crash:defaultAccess( ULib.ACCESS_SUPERADMIN )
crash:help( "Crashes a player." )
crash:setOpposite( "ulx scrash", { _, _, true }, "!scrash", true )

function ulx.sban( calling_ply, target_ply, minutes, reason )

	if target_ply:IsBot() then
	
		ULib.tsayError( calling_ply, "Cannot ban a bot", true )
		
		return
		
	end	
	
	ULib.ban( target_ply, minutes, reason, calling_ply )
	
	target_ply:Kick( "Disconnect: Kicked by " .. calling_ply:Nick() .. "(" .. calling_ply:SteamID() .. ")" .. " " .. "(" .. "Banned for " .. minutes .. " minute(s): " .. reason .. ")." )

	local time = "for #i minute(s)"
	if minutes == 0 then time = "permanently" end
	local str = "#A banned #T " .. time
	if reason and reason ~= "" then str = str .. " (#s)" end
	
	ulx.fancyLogAdmin( calling_ply, true, str, target_ply, minutes ~= 0 and minutes or reason, reason )
	
end
local sban = ulx.command( "Custom", "ulx sban", ulx.sban, "!sban" )
sban:addParam{ type=ULib.cmds.PlayerArg }
sban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
sban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
sban:addParam{ type=ULib.cmds.BoolArg, invisible=true }
sban:defaultAccess( ULib.ACCESS_ADMIN )
sban:help( "Bans target silently." )

function ulx.fakeban( calling_ply, target_ply, minutes, reason )

	if target_ply:IsBot() then
	
		ULib.tsayError( calling_ply, "Cannot ban a bot", true )
		
		return
		
	end

	local time = "for #i minute(s)"
	if minutes == 0 then time = "permanently" end
	local str = "#A banned #T " .. time
	if reason and reason ~= "" then str = str .. " (#s)" end
	
	ulx.fancyLogAdmin( calling_ply, str, target_ply, minutes ~= 0 and minutes or reason, reason )
	
end
local fakeban = ulx.command( "Custom", "ulx fakeban", ulx.fakeban, "!fakeban", true )
fakeban:addParam{ type=ULib.cmds.PlayerArg }
fakeban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
fakeban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
fakeban:defaultAccess( ULib.ACCESS_SUPERADMIN )
fakeban:help( "Doesn't actually ban the target." )

function ulx.profile( calling_ply, target_ply )

    calling_ply:SendLua("gui.OpenURL('http://steamcommunity.com/profiles/".. target_ply:SteamID64() .."')")
	
    ulx.fancyLogAdmin( calling_ply, true, "#A opened the profile of #T", target_ply )
	
end
local profile = ulx.command( "Custom", "ulx profile", ulx.profile, "!profile", true )
profile:addParam{ type=ULib.cmds.PlayerArg }
profile:addParam{ type=ULib.cmds.BoolArg, invisible=true }
profile:defaultAccess( ULib.ACCESS_ALL )
profile:help( "Opens target's profile" )

function ulx.dban( calling_ply )
	calling_ply:ConCommand( "xgui hide" )
	calling_ply:ConCommand( "menu_disc" )
end
local dban = ulx.command( "Custom", "ulx dban", ulx.dban, "!dban" )
dban:defaultAccess( ULib.ACCESS_ADMIN )
dban:help( "Open the disconnected players menu" )
