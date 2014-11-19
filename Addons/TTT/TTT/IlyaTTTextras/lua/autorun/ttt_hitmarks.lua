if CLIENT then
	hit = false
	W = ScrW()/2
	H = ScrH()/2
	usermessage.Hook("HIT_MARK", function()
		hit = true
		opac = 150
		timer.Simple(0.2, function()   
			hook.Add("Think", "hit_fade", function()
				opac = opac - 5
				if opac <= 0 then
					hook.Remove("Think", "hit_fade")
					hit = false
				end
			end)
		end)
	end)
	hook.Add("HUDPaint", "HITMARKER", function()
		if hit then
			surface.SetDrawColor(255,255,255,opac)
			surface.DrawLine(W-2,H-2,W-8,H-8)
			surface.DrawLine(W+2,H-2,W+8,H-8)
			surface.DrawLine(W+2,H+2,W+8,H+8)
			surface.DrawLine(W-2,H+2,W-8,H+8)
		end
	end)
end

if SERVER then
	hook.Add("PlayerHurt", "Hit", function(ply, attacker)
		if IsValid(attacker) and attacker:IsPlayer() then
			umsg.Start( "HIT_MARK", attacker )
			umsg.End()
		end
	end)
end