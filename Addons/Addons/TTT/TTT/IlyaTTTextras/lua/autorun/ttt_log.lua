if CLIENT then
	
	COL_WHITE = Color(255,255,255)
	COL_RED = Color(255,0,0)
	COL_YELLOW = Color(224,211,27)
	COL_GREEN = Color(0,255,0)
	COL_BLUE = Color(0,0,255)
	COL_GREY = Color(120,120,120)
	
	local function role2color(role)
		if role == "[INNOCENT]" then
			return COL_GREEN
		elseif role == "[TRAITOR]" then
			return COL_RED
		elseif role == "[DETECTIVE]" then
			return COL_BLUE
		else
			return COL_GREY
		end
	end
	
	net.Receive("DeathLog", function()
		temp_deathlog = net.ReadTable()
		MsgC(COL_WHITE, 
[[--------------------------------------------------------------------------------
---------------------------------TTT DEATH LOG----------------------------------
--------------------------------------------------------------------------------]])
		Msg("\n")
		for k, v in pairs(temp_deathlog)do
			ex = string.Explode(";", v)
			MsgC(COL_WHITE, ex[1])
			MsgC(role2color(ex[2]), ex[2].." ")
			MsgC(COL_WHITE, ex[3].." ")
			MsgC(COL_WHITE, ex[4])
			MsgC(role2color(ex[5]), ex[5])
			Msg("\n")
		end
		MsgC(COL_WHITE, 
[[--------------------------------------------------------------------------------
---------------------------------TTT DEATH LOG----------------------------------
--------------------------------------------------------------------------------]])
		Msg("\n")
	end)
	
	net.Receive("DamageLog", function()
		temp_damagelog = net.ReadTable()
		MsgC(COL_WHITE, 
[[--------------------------------------------------------------------------------
---------------------------------TTT DAMAGE LOG---------------------------------
--------------------------------------------------------------------------------]])
		Msg("\n")
		for k, v in pairs(temp_damagelog)do
			ex = string.Explode(";", v)
			if ex[1] == "KILL:" then
				MsgC(COL_RED, ex[1].." ")
				MsgC(COL_WHITE, ex[2])
				MsgC(role2color(ex[3]), ex[3].." ")
				MsgC(COL_WHITE, ex[4].." ")
				MsgC(COL_WHITE, ex[5])
				MsgC(role2color(ex[6]), ex[6])
			elseif ex[1] == "DMG:" then
				MsgC(COL_YELLOW, ex[1].." ")
				MsgC(COL_WHITE, ex[2])
				MsgC(role2color(ex[3]), ex[3].." ")
				MsgC(COL_WHITE, ex[4].." ")
				MsgC(COL_WHITE, ex[5])
				MsgC(role2color(ex[6]), ex[6].." ")
				MsgC(COL_WHITE, ex[7].." ")
				MsgC(COL_YELLOW, ex[8].." ")
				MsgC(COL_WHITE, ex[9])
			elseif ex[1] == "DNA:" then
				MsgC(COL_BLUE, ex[1].." ")
				MsgC(COL_WHITE, ex[2])
				MsgC(role2color(ex[3]), ex[3].." ")
				MsgC(COL_WHITE, ex[4].." ")
				MsgC(COL_WHITE, ex[5])
				MsgC(role2color(ex[6]), ex[6])
			end
			Msg("\n")
		end
		MsgC(COL_WHITE, 
[[--------------------------------------------------------------------------------
---------------------------------TTT DAMAGE LOG---------------------------------
--------------------------------------------------------------------------------]])
		Msg("\n")
	end)
	
	return 
end

util.AddNetworkString("DeathLog")
util.AddNetworkString("DamageLog")

hook.Add("TTTEndRound", "PostRoundDawg", function()
	TTT_POST_ROUND = true
end)

hook.Add("TTTBeginRound", "ResetLog", function()
	TTT_POST_ROUND = false
	ttt_deathlog = {}
	ttt_damagelog = {}
	for k, v in pairs(player.GetAll())do
		v.isded = false
	end
end)

ttt_deathlog = {}
ttt_damagelog = {}

TTT_ROLEZ = {
	[0] = "[INNOCENT]",
	[1] = "[TRAITOR]",
	[2] = "[DETECTIVE]"
}

hook.Add( "PlayerDeath", "TTT Death Log", function( v, w, k)
	if !TTT_POST_ROUND then
		v.isded = true
		tttrolev = TTT_ROLEZ[v:GetRole()]
		if k:IsPlayer() then
			tttrolea = TTT_ROLEZ[k:GetRole()]
			killername = k:Nick()
		else
			tttrolea = "[WOLRD/OBJECT]"
			killername = "World"
		end
		local String = killername..";"..tttrolea..";killed;"..v:Nick()..";"..tttrolev
		table.insert(ttt_deathlog, String)
		local String2 = "KILL:;"..killername..";"..tttrolea..";killed;"..v:Nick()..";"..tttrolev
		table.insert(ttt_damagelog, String2)
	end
end)

hook.Add("PlayerHurt", "TTT Damage Log", function(v, a, h, amt)
	if !TTT_POST_ROUND then
		vtttrole = TTT_ROLEZ[v:GetRole()]
		if a:IsPlayer() then
			atttrole = TTT_ROLEZ[a:GetRole()]
			attname = a:Nick()
		else
			atttrole = "[WOLRD/OBJECT]"
			attname = "World"
		end
		local String = "DMG:;"..attname..";"..atttrole..";hurt;"..v:Nick()..";"..vtttrole..";with;"..math.Round(amt)..";damage"
		table.insert(ttt_damagelog, String)
	end
end)

hook.Add("TTTFoundDNA", "TTT DNA Log", function(ply, own, ent)
	if !TTT_POST_ROUND then
		plytttrole = TTT_ROLEZ[ply:GetRole()]
		owntttrole = TTT_ROLEZ[own:GetRole()]
		local String = "DNA:;"..ply:Nick()..";"..plytttrole..";found DNA of;"..own:Nick()..";"..owntttrole
		table.insert(ttt_damagelog, String)
	end
end)

concommand.Add("print_ttt_deathlog", function(ply,cmd,arg)
	--if ply:IsAdmin() or ply:IsSuperAdmin() or ply:IsUserGroup("admin") then 
		if ply.isded or TTT_POST_ROUND then
			net.Start("DeathLog")
			net.WriteTable(ttt_deathlog)
			net.Send(ply)
		end
	--end
end)

concommand.Add("print_ttt_damagelog", function(ply,cmd,arg)
	--if not ply:IsAdmin() or ply:IsSuperAdmin() or ply:IsUserGroup("admin") then
		if ply.isded or TTT_POST_ROUND then
			net.Start("DamageLog")
			net.WriteTable(ttt_damagelog)
			net.Send(ply)
		end
	--end
end)
